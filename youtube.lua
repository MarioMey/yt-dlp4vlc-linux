-- YouTube Link Resolver for VLC with Separate Video and Audio URLs
-- Place this script in VLC's lua/playlist directory

local yt_dlp_path = 'yt-dlp.exe';
local yt_dlp_silent_path = 'yt-dlp-silent.exe';

function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

function probe()
    -- Check if the input is a YouTube link
    return vlc.access == "http" or vlc.access == "https" and 
           (string.match(vlc.path, "youtube%.com") or string.match(vlc.path, "youtu%.be"))
end

function parse()
    -- Construct the full YouTube URL
    local youtube_url = vlc.access .. "://" .. vlc.path
    local cmd_hidden = yt_dlp_silent_path
    
	
	local video_url = '';
	local audio_url = '';
	
    -- Check if ytp-dlp-silent.exe exists, if not, fall back to Powershell
    local yt_dlp_silent_exists = io.open(yt_dlp_silent_path, "r") ~= nil
    if not yt_dlp_silent_exists then
        vlc.msg.info(yt_dlp_silent_path .. " not found. Falling back to " .. yt_dlp_path)
		cmd_hidden = 'PowerShell.exe -windowstyle hidden cmd /c &'
		
		 local cmd = string.format(
        '%s "%s" -g %s',
			cmd_hidden,
			yt_dlp_path,
			youtube_url
		)

		-- Execute yt-dlp to get the direct video and audio URLs
		local handle = io.popen(cmd)
				
		-- Read video URL (first line)
		video_url = handle:read("*l")
		
		-- Read audio URL (second line)
		audio_url = handle:read("*l")
		
		handle:close()
	else      
		vlc.msg.info(yt_dlp_silent_path .. " found. Running program")
		local cmd = string.format(
			'%s -s "%s -g %s"',
			cmd_hidden,
			yt_dlp_path,
			youtube_url
		)
	
		local process = io.popen("start /B " .. cmd)
		process:close()
		
	  -- Wait for yt-dlp-output.txt to be created
		local output_file = "yt-dlp-output.txt"
		local file_exists = false
		local timeout = 0
		local timeout_limit = 10 -- Timeout after 10 seconds

		-- Check for file every 1 second until it's created
		while not file_exists do
			local file_test = os.rename(output_file, output_file) -- Try renaming (checking file existence)
			if file_test then
				file_exists = true
			else
				-- Wait a little before trying again
				vlc.msg.info("Waiting for output file...")
				sleep(1) -- Sleep for 1 second
				timeout = timeout + 1
				if timeout > timeout_limit then
					vlc.msg.warn("Timeout reached. The output file was not created.")
					break
				end
			end
		end

		vlc.msg.info("File found")
		-- Open the file to read the video and audio URLs
		local file = io.open(output_file, "r")
		video_url = file:read("*l")
		audio_url = file:read("*l")
		file:close()

		-- Delete the file after reading
		os.remove(output_file)
	end
	
    vlc.msg.info("Video URL: " .. video_url)
    vlc.msg.info("Audio URL: " .. audio_url)

    -- Trim any whitespace
    video_url = video_url and video_url:gsub("^%s+", ""):gsub("%s+$", "") or ""
    audio_url = audio_url and audio_url:gsub("^%s+", ""):gsub("%s+$", "") or ""

    -- Log the resolved URLs
    vlc.msg.info("[YouTube Resolver] Original URL: " .. youtube_url)
    vlc.msg.info("[YouTube Resolver] Video URL: " .. video_url)

    if audio_url and audio_url ~= "" then
        vlc.msg.info("[YouTube Resolver] Audio URL: " .. audio_url)
        return {
            {
                path = video_url,
                name = vlc.path .. " (Video)",
                options = {
                    -- Add audio URL as input option
                    ":input-slave=" .. audio_url
                }
            }
        }
    else
        vlc.msg.warn("[YouTube Resolver] No separate audio URL found. Playing single URL with both video and audio.")
        return {
            {
                path = video_url,
                name = vlc.path .. " (Video + Audio)"
            }
        }
    end
end

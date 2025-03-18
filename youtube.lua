-- YouTube Link Resolver for VLC with Separate Video and Audio URLs
-- Place this script in VLC's lua/playlist directory

function probe()
    -- Check if the input is a YouTube link
    return vlc.access == "http" or vlc.access == "https" and 
           (string.match(vlc.path, "youtube%.com") or string.match(vlc.path, "youtu%.be"))
end

function parse()
    -- Construct the full YouTube URL
    local youtube_url = vlc.access .. "://" .. vlc.path

    -- Path to yt-dlp executable (modify as needed)
    local yt_dlp_path = "C:\\YT-DLP\\yt-dlp.exe"

    -- Construct the command to get the direct video and audio URLs
    local cmd = string.format(
        '%s -g "%s"',
        yt_dlp_path,
        youtube_url
    )

    -- Execute yt-dlp to get the direct video and audio URLs
    local handle = io.popen(cmd)
    
    -- Read video URL (first line)
    local video_url = handle:read("*l")
    
    -- Read audio URL (second line)
    local audio_url = handle:read("*l")
    
    handle:close()

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

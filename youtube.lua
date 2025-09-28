-- YouTube Link Resolver for VLC with Separate Video and Audio URLs (Linux version)
-- Place this script in VLC's lua/playlist directory

local yt_dlp_path = 'yt-dlp' -- in Linux no ".exe"

function sleep(s)
  local ntime = os.time() + s
  repeat until os.time() > ntime
end

function probe()
    -- Check if the input is a YouTube link
    return (vlc.access == "http" or vlc.access == "https") and
           (string.match(vlc.path, "youtube%.com") or string.match(vlc.path, "youtu%.be"))
end

function parse()
    -- Construct the full YouTube URL
    local youtube_url = vlc.access .. "://" .. vlc.path

    -- Extract "quality" query parameter if present
    local quality = youtube_url:match("[&?]quality=(%d+)[pP]?")
    youtube_url = youtube_url:gsub("[&?]quality=%d+[pP]?", ""):gsub("[&?]$", "") -- Remove trailing ? or &

    local allowed_qualities = {
        ["144"] = true,
        ["360"] = true,
        ["480"] = true,
        ["720"] = true,
        ["1080"] = true,
        ["2160"] = true
    }

    local format_string = "bestvideo+bestaudio" -- Default to highest available
    if quality and allowed_qualities[quality] then
        format_string = string.format("bestvideo[height=%s]+bestaudio", quality)
        vlc.msg.info("Using requested quality: " .. quality .. "p")
    else
        vlc.msg.info("No valid quality specified. Defaulting to best available.")
    end

    -- Ejecutar yt-dlp directamente en Linux
    local cmd = string.format(
        '%s -f "%s" -g "%s"',
        yt_dlp_path,
        format_string,
        youtube_url
    )

    local handle = io.popen(cmd)
    local video_url = handle:read("*l")
    local audio_url = handle:read("*l")
    handle:close()

    video_url = video_url and video_url:gsub("^%s+", ""):gsub("%s+$", "") or ""
    audio_url = audio_url and audio_url:gsub("^%s+", ""):gsub("%s+$", "") or ""

    vlc.msg.info("[YouTube Resolver] Original URL: " .. youtube_url)
    vlc.msg.info("[YouTube Resolver] Video URL: " .. video_url)

    if audio_url and audio_url ~= "" then
        return {
            {
                path = video_url,
                name = vlc.path .. " (Video)",
                options = {
                    ":input-slave=" .. audio_url
                }
            }
        }
    else
        return {
            {
                path = video_url,
                name = vlc.path .. " (Video + Audio)"
            }
        }
    end
end

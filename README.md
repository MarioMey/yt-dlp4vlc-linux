Simple lua script that wraps `yt-dlp` into VLC in Linux.

Forked from [yt-dlp4vlc](https://github.com/FalloNero/yt-dlp4vlc). Thanks, FalloNero.

### Installation:
- It requires [yt-dlp](https://github.com/yt-dlp/yt-dlp/) installed. So, install it if you don't have it. And always keep it up to date (`yt-dlp -U`).
- Copy `yt-dlp-linux.lua` to `~/.local/share/vlc/lua/playlist`. VLC will read this file before the one installed at system-wide.
- Copy `yt-dlp-linux-info.lua` to `~/.local/share/vlc/lua/extensions` to show as Extension and it can show what's inside `descriptor()`: author, version, description, etc. **This step is not necessary**.

### Usage:
- Copy a YouTube address and just paste it on VLC, by pressing Ctrl-V in main window (or paste it in "Open Network Stream").
- If you add `&quality=360` to address, you tell the script to tell yt-dlp to play only in 360p (qualities: 144p, 360p, 480p, 720p, 1080p, 2160p).
- Wait some seconds for yt-dlp to get URL and VLC to start playing.
- Enjoy, of course.

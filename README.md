Simple lua script that wraps yt-dlp.exe into VLC

By default it requires yt-dlp.exe in the VLC directory but feel free to change its path in the script

Also uses a powershell command to hide the cmd window that appears meanwhile yt-dlp cooks the links,
also it uses if found yt-dlp-silent.exe that just a c++ wrapper that does kinda the same without using powershell


Simply open a network stream in VLC and let it rip

add &quality=xxx to the URL to select the video quality, omit to default to maximum quality possible

360p
480p
720p
1080p
2160p

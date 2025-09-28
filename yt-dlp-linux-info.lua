-- Descriptor/extension para mostrar información (no afecta al resolver)
-- Guardar como: ~/.local/share/vlc/lua/extensions/yt-dlp-info.lua

function descriptor()
  return {
    title = "yt-dlp for Linux VLC",
    version = "1.0",
    author = "Mario Mey",
    url = "https://github.com/MarioMey/yt-dlp4vlc-linux/",
    shortdesc = "A lua script that wraps yt-dlp into VLC",
    description = "Forked from https://github.com/FalloNero/yt-dlp4vlc and modified to run in Linux",
    capabilities = {}
  }
end

local dlg = nil

function activate()
  if dlg then dlg:delete() end
  dlg = vlc.dialog("yt-dlp for VLC")
  local info = string.format("Título: %s\nVersión: %s\nAutor: %s\nURL: %s",
    descriptor().title, descriptor().version, descriptor().author, descriptor().url)
  dlg:add_label(info, 1,1,1,1)
end

function deactivate()
  if dlg then dlg:delete() dlg = nil end
end

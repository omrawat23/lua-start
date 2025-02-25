fx_version "cerulean"
lua54 "yes"
games { "gta5" }

ui_page "build/index.html"

shared_scripts {
  '@ox_lib/init.lua',
  "cfg/cfg.lua",
}

client_scripts {
  "client/framework.lua",
  "client/client.lua"
}

server_scripts {
  "server/framework.lua",
  "server/server.lua"
}

files {
  "build/index.html",
  "build/**/*"
}

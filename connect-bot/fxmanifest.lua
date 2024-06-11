fx_version "adamant"
game "gta5"

version "1.0"
lua54 "yes"

shared_script {
  "config.lua"
}

server_script {
  "@vrp/lib/vehicles.lua",
  "@vrp/lib/itemlist.lua",
  "@vrp/lib/utils.lua",
  "commands.lua",
  "index.lua",
  "lib/*",
  "connection/*",
}
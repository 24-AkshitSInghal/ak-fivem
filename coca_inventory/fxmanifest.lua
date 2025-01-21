fx_version "cerulean"

description "COCA Inventory"
author "Cocain Monster"
version '1.0.0'

lua54 'yes'

games {
  "gta5",
  "rdr3"
}

client_script "client/**/*"

shared_script {
  "config.lua",
  "client/player.lua",
  "client/use_functions.lua"
} 

server_scripts {
  "server/**/*",
  "@oxmysql/lib/MySQL.lua",
}

ui_page {
  'ui/index.html'
}

files {
  'ui/index.html',
  'ui/style.css',
  'ui/script.js',
  'ui/images/bg.png',
  'ui/images/items/*.png',
  'ui/*ttf'
}

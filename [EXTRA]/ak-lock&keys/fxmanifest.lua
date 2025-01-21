fx_version 'cerulean'
game 'gta5'

author 'Akiller24'
description 'Vehicle locks including lockpicking'

client_script {
     'client/client.lua'
}

server_script {
     'server/server.lua',
     "@oxmysql/lib/MySQL.lua",
}

ui_page {
     'ui/index.html',
}
files {
     'ui/index.html',
     'ui/style.css',
     'ui/script.js',
}
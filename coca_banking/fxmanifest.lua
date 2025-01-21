fx_version 'cerulean'
game 'gta5'

author 'Cocaine Monster'
description 'Banking Script'

client_script {
    'client/client.lua',
}

server_script {
    'server/*.lua',
    "@oxmysql/lib/MySQL.lua",
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/pricedown.ttf',
    'html/bank-icon.png',
    'html/logo.png',
    'html/styles.css',
    'html/scripts.js',
}

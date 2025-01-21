fx_version 'cerulean'
game 'gta5'

author 'Akiller24'
description 'Car Dealership Script'

client_script {
    'client/*.lua',
}

server_script {
    'server/*.lua',
    "@oxmysql/lib/MySQL.lua",

}

shared_script "config.lua"
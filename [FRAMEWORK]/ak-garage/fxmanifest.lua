fx_version  'cerulean'
games       { 'gta5' }

name        'zerodream_parking'
author      'Akkariin'
description 'ZeroDream Parking Script'
version     '1.0.3'
url         'https://github.com/kasuganosoras/zerodream_parking'

shared_scripts {
    'config.lua',
    'locales/*.lua',
}

client_scripts {
    'client/*.lua',
 
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/utils.lua',
    'server/api.lua',
    'server/main.lua',
}

exports {
    'IsParkingVehicle',
    'ImpoundVehicle',
}

server_exports {
    'ImpoundVehicle',
}
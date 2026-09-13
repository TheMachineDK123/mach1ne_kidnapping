fx_version 'cerulean'
game 'gta5'

author 'TheMach1neDK'
description '@TheMach1neDK - Kidnappings mission'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@st_libs/init.lua',
    'config.lua'
}

st_libs {
    'interaction',
    'notification',
    'textui',
    'progress',
    'hintui'
}

client_scripts {
    '@es_extended/imports.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/imports.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql',
    'ox_inventory',
    'st_libs'
}

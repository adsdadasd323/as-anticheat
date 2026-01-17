fx_version 'cerulean'
game 'gta5'

author 'AS Framework'
description 'Anti-Cheat System for AS Framework'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

server_scripts {
    'server/main.lua',
    'server/detections.lua',
    'server/bans.lua'
}

client_scripts {
    'client/main.lua',
    'client/checks.lua'
}

dependencies {
    'as-core',
    'oxmysql'
}

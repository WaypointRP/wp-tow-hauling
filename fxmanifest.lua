fx_version 'cerulean'
game 'gta5'

description 'Waypoint Hauling'
author 'BackSH00TER - Waypoint RP'
version '1.0.0'

shared_script {
    -- '@ox_lib/init.lua', -- Uncomment this if you are planning to use any ox scripts (such as ox notify)
    'shared/config.lua',
    'shared/framework.lua',
}

client_scripts {
    'client.lua',
    'instructional-buttons.lua',
}

server_scripts {
    'server.lua',
}

lua54 'yes'

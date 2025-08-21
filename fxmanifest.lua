fx_version 'cerulean'
game 'gta5'

name 'qb-analyzer-npc'
author 'you'
version '1.0.1'
description 'NPC with qb-target to analyze player inventory (informational only)'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu'   -- added
}

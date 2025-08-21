fx_version 'cerulean'
game 'gta5'

name 'qb-analyzer-npc'
author 'you'
version '1.2.0'
description 'NPC with qb-target to analyze player inventory (QB or OX inventory support, informational only, categorized menu)'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    -- OX is optional; do not hard-depend here
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'qb-menu'
    -- 'ox_inventory'  -- OPTIONAL: only if you use OX
}

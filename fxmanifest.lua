fx_version 'cerulean'
game 'gta5'

name "LU-foresics"
author "Eliza Lasal"
version "25.8.21"
description 'Informative Foresics Script'

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

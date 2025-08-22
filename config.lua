print("^2LU^7-^2foresics ^7v^41^7.^45 ^7- ^2foresics Script by ^1Eliza Lasal^7")

-- If you need support I now have a discord available, it helps me keep track of issues and give better support.

-- https://discord.gg/cqtggDqnW6

Config = {}

-- Inventory system selection
-- "auto" -> detect running resources (prefers OX if both and PreferOxWhenBoth=true)
-- "qb"   -> force QBCore inventory
-- "ox"   -> force OX Inventory
Config.Inventory = {
    System = "auto",
    PreferOxWhenBoth = true
}

-- 🔒 Job lock for showing the qb-target option
-- Map jobs to minimum grade required (number). If a job isn't listed, it's not allowed.
Config.JobLock = {
    Enabled = true,
    Allowed = {
        police    = 0,
        -- add more jobs here with their required minimum grade
    }
}

-- Analyzer NPCs
Config.Peds = {
    {
        model = 's_m_y_cop_01',
        coords = vec4(466.368103, -994.516724, 26.092180, 272.677124),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    }
}

Config.Command = {
    Enabled     = true,         -- toggle the /command
    Name        = "analyzeinv", -- command name
    Suggestion  = true,         -- chat suggestion
    EmoteOnUse  = false          -- hold clipboard during command flow
}


-- Category-aware informational messages
-- For Drugs, you can set enhancement booleans:
--   speed = true/false, armor = true/false, health = true/false
Config.ItemDescriptions = {
    -- General
    bandage = {
        desc = "Stops minor bleeding.",
        category = "General"
    },
    sandwich = {
        desc = "A quick snack for hunger.",
        category = "General"
    },
    weapon_pistol = {
        desc = "Standard sidearm.",
        category = "General"
    },

    -- Ingredients
     ["lead_nitride"] = { desc = "Illegal Chemical Ingredient", category = "Ingredients" },
    

    -- Drugs (examples — set any of speed/armor/health to true/false)
    drug_2step = {
            desc     = "Illegal Synthetic Stimulant",
            category = "Drugs",
            speed    = true,
            armor    = true,
            health   = false
        },   
    }
        


-- UI text
Config.MenuTitle  = "🔍 Inventory Analyzer"
Config.CloseLabel = "⬅ Close"

Config.Notify = {
    Empty = "Your inventory is empty.",
    Fetch = "Contacting analyzer...",
    NoAuth = "You are not authorized to use this."
}

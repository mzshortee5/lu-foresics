Config = {}

-- Choose which inventory system to use:
-- "auto" = detect automatically (prefers OX if started, otherwise QB)
-- "qb"   = force QBCore inventory
-- "ox"   = force OX Inventory
Config.Inventory = {
    System = "auto",              -- "auto" | "qb" | "ox"
    PreferOxWhenBoth = true       -- if both are present and System="auto", prefer OX
}

-- Analyzer NPCs
Config.Peds = {
    {
        model = 's_m_y_cop_01',
        coords = vec4(441.77, -981.92, 30.69, 90.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    }
}

-- Category-aware informational messages
-- category can be: "Drugs", "Ingredients", or "General"
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
    water = {
        desc = "Bottle of water that quenches thirst.",
        category = "Ingredients"
    },
    flour = {
        desc = "Used for baking and cooking.",
        category = "Ingredients"
    },
    sugar = {
        desc = "Sweet ingredient for recipes.",
        category = "Ingredients"
    },

    -- Drugs (examples — adjust to your server’s items)
    weed = {
        desc = "Cannabis plant, can be rolled into joints.",
        category = "Drugs"
    },
    coke = {
        desc = "Cocaine powder.",
        category = "Drugs"
    },
    meth = {
        desc = "Crystalline stimulant.",
        category = "Drugs"
    }
}

-- UI text
Config.MenuTitle = "🔍 Inventory Analyzer"
Config.CloseLabel = "⬅ Close"

Config.Notify = {
    Empty = "Your inventory is empty.",
    Fetch = "Contacting analyzer..."
}

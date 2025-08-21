Config = {}

-- Place one or more analyzer NPCs here
Config.Peds = {
    {
        model = 's_m_y_cop_01',
        coords = vec4(441.77, -981.92, 30.69, 90.0), -- Mission Row example
        scenario = 'WORLD_HUMAN_CLIPBOARD'          -- optional idle anim
    }
}

-- Category-aware informational messages
-- category can be: "Drugs", "Ingredients", or "General" (default fallback)
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

-- Menu title text
Config.MenuTitle = "🔍 Inventory Analyzer"
-- Button text for close
Config.CloseLabel = "⬅ Close"
-- Notify texts
Config.Notify = {
    Empty = "Your inventory is empty.",
    Fetch = "Contacting analyzer..."
}

Config = {}

Config.Peds = {
    {
        model = 's_m_y_cop_01',
        coords = vec4(441.77, -981.92, 30.69, 90.0),
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    }
}

-- Items + descriptions + categories
-- category = "Drugs", "Ingredients", or "General"
Config.ItemDescriptions = {
    water = {
        desc = "Bottle of water that quenches thirst.",
        category = "Ingredients"
    },
    sandwich = {
        desc = "A quick snack for hunger.",
        category = "General"
    },
    bandage = {
        desc = "Stops minor bleeding.",
        category = "General"
    },
    weapon_pistol = {
        desc = "Standard sidearm.",
        category = "General"
    },

    -- Example drugs
    weed = {
        desc = "Cannabis plant, can be rolled into joints.",
        category = "Drugs"
    },
    coke = {
        desc = "Cocaine powder.",
        category = "Drugs"
    },

    -- Example ingredients
    flour = {
        desc = "Used for baking and cooking.",
        category = "Ingredients"
    },
    sugar = {
        desc = "Sweet ingredient for recipes.",
        category = "Ingredients"
    }
}


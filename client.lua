local QBCore = exports['qb-core']:GetCoreObject()

-- When player opens menu
RegisterNetEvent("analyzer:client:showMenu", function(itemList)
    if not itemList or next(itemList) == nil then
        QBCore.Functions.Notify("Your inventory is empty.", "error", 3500)
        return
    end

    -- Sort into categories
    local categorized = {
        Drugs = {},
        Ingredients = {},
        General = {}
    }

    for _, item in ipairs(itemList) do
        local info = Config.ItemDescriptions[item.name]
        local cat = info and info.category or "General"

        categorized[cat] = categorized[cat] or {}
        table.insert(categorized[cat], item)
    end

    -- Build qb-menu
    local menu = {
        { header = "🔍 Inventory Analyzer", isMenuHeader = true }
    }

    local function addCategory(catName, items)
        if not items or #items == 0 then return end
        menu[#menu+1] = { header = "📂 " .. catName, isMenuHeader = true }
        for _, item in ipairs(items) do
            menu[#menu+1] = {
                header = ("%s x%s"):format(item.label, item.count),
                txt = "Select to view info",
                params = {
                    event = "analyzer:client:analyzeItem",
                    args = { name = item.name, label = item.label }
                }
            }
        end
    end

    addCategory("Drugs", categorized.Drugs)
    addCategory("Ingredients", categorized.Ingredients)
    addCategory("General", categorized.General)

    menu[#menu+1] = { header = "⬅ Close", params = { event = "qb-menu:closeMenu" } }
    exports['qb-menu']:openMenu(menu)
end)

-- Show notify on selection
RegisterNetEvent("analyzer:client:analyzeItem", function(data)
    local name  = data.name
    local label = data.label or name
    local info  = Config.ItemDescriptions[name]

    if info then
        QBCore.Functions.Notify(("%s: %s"):format(label, info.desc), "success", 6000)
    else
        QBCore.Functions.Notify(("No analysis data available for %s."):format(label), "error", 4500)
    end
end)

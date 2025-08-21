local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}

-- Helpers
local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    return hash
end

-- Spawn analyzer NPC(s)
CreateThread(function()
    for _, p in ipairs(Config.Peds) do
        local hash = loadModel(p.model)
        if not hash then goto continue end

        local ped = CreatePed(4, hash, p.coords.x, p.coords.y, p.coords.z - 1.0, p.coords.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)

        if p.scenario then
            TaskStartScenarioInPlace(ped, p.scenario, 0, true)
        end

        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = "client",
                    event = "analyzer:client:open",
                    icon = "fas fa-search",
                    label = "Analyze Inventory"
                }
            },
            distance = 2.0
        })

        spawnedPeds[#spawnedPeds+1] = ped
        SetModelAsNoLongerNeeded(hash)
        ::continue::
    end
end)

-- Cleanup spawned NPCs on resource stop
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeletePed(ped) end
    end
end)

-- Open → fetch inventory (strictly informational)
RegisterNetEvent("analyzer:client:open", function()
    QBCore.Functions.Notify(Config.Notify.Fetch or "Contacting analyzer...", "primary", 1200)
    TriggerServerEvent("analyzer:server:getInventory")
end)

-- Build categorized menu using qb-menu
RegisterNetEvent("analyzer:client:showMenu", function(itemList)
    if not itemList or next(itemList) == nil then
        QBCore.Functions.Notify(Config.Notify.Empty or "Your inventory is empty.", "error", 3500)
        return
    end

    -- Categorize items based on Config.ItemDescriptions
    local categorized = { Drugs = {}, Ingredients = {}, General = {} }

    for _, item in ipairs(itemList) do
        local info = Config.ItemDescriptions[item.name]
        local cat = (info and info.category) or "General"
        categorized[cat] = categorized[cat] or {}
        table.insert(categorized[cat], item)
    end

    -- Sort each category by label asc
    local function sortByLabel(t)
        table.sort(t, function(a, b) return (a.label or a.name) < (b.label or b.name) end)
    end
    for _, t in pairs(categorized) do sortByLabel(t) end

    -- Build qb-menu
    local menu = {
        { header = Config.MenuTitle or "🔍 Inventory Analyzer", isMenuHeader = true }
    }

    local function addCategory(catName, items)
        if items and #items > 0 then
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
    end

    -- Order: Drugs → Ingredients → General
    addCategory("Drugs", categorized.Drugs)
    addCategory("Ingredients", categorized.Ingredients)
    addCategory("General", categorized.General)

    menu[#menu+1] = { header = Config.CloseLabel or "⬅ Close", params = { event = "qb-menu:closeMenu" } }
    exports['qb-menu']:openMenu(menu)
end)

-- On item selection → show info via qb-notify (strictly informational)
RegisterNetEvent("analyzer:client:analyzeItem", function(data)
    local name  = data.name
    local label = data.label or name
    local info  = Config.ItemDescriptions[name]

    if info and info.desc then
        QBCore.Functions.Notify(("%s: %s"):format(label, info.desc), "success", 6000)
    else
        QBCore.Functions.Notify(("No analysis data available for %s."):format(label), "error", 4500)
    end
end)

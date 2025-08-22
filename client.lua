local QBCore = exports['qb-core']:GetCoreObject()
local spawnedPeds = {}

-- Cache player data for quick checks
local PlayerData = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- Emote helpers (used when command invokes the analyzer)
local Analyzer_EmoteActive = false

local function StartClipboardEmote()
    if Config.Command and Config.Command.EmoteOnUse == false then return end
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return end
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
    Analyzer_EmoteActive = true
end

local function StopClipboardEmote()
    if Analyzer_EmoteActive then
        ClearPedTasks(PlayerPedId())
        Analyzer_EmoteActive = false
    end
end

CreateThread(function()
    if Config.Command and Config.Command.Enabled and Config.Command.Suggestion ~= false then
        local cmd = (Config.Command.Name or "analyzeinv")
        TriggerEvent("chat:addSuggestion", "/"..cmd, "Open the Inventory Analyzer")
    end
end)

local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) then return nil end
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    return hash
end

-- 🔒 Job check helper
local function isJobAllowed()
    if not Config.JobLock or not Config.JobLock.Enabled then return true end
    local pdata = PlayerData and PlayerData.job and PlayerData or QBCore.Functions.GetPlayerData()
    if not pdata or not pdata.job then return false end
    local jname = pdata.job.name
    local jgrade = (pdata.job.grade and (pdata.job.grade.level or pdata.job.grade)) or 0
    local min = Config.JobLock.Allowed[jname]
    if min == nil then return false end
    return jgrade >= min
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
                    icon  = "fas fa-search",
                    label = "Analyze Inventory",
                    canInteract = function(entity, distance, data)
                        return isJobAllowed()
                    end
                }
            },
            distance = 2.0
        })

        spawnedPeds[#spawnedPeds+1] = ped
        SetModelAsNoLongerNeeded(hash)
        ::continue::
    end
end)

-- Cleanup on stop
AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeletePed(ped) end
    end
end)

-- Open → fetch inventory (respect job lock)
RegisterNetEvent("analyzer:client:open", function(data)
    -- Job lock (client side)
    local function unauthorized()
        QBCore.Functions.Notify(Config.Notify.NoAuth or "You are not authorized to use this.", "error", 3500)
        StopClipboardEmote()
    end
    if Config.JobLock and Config.JobLock.Enabled then
        local pdata = QBCore.Functions.GetPlayerData()
        local name  = pdata.job and pdata.job.name
        local grade = pdata.job and ((pdata.job.grade and (pdata.job.grade.level or pdata.job.grade)) or 0) or 0
        local min   = name and Config.JobLock.Allowed[name]
        if not (min ~= nil and grade >= min) then return unauthorized() end
    end

    -- Start clipboard emote only if the command passed the flag
    if data and data.withEmote then
        StartClipboardEmote()
    end

    QBCore.Functions.Notify(Config.Notify.Fetch or "Contacting analyzer...", "primary", 1200)
    TriggerServerEvent("analyzer:server:getInventory")
end)

-- Build categorized QB-Menu
RegisterNetEvent("analyzer:client:showMenu", function(itemList)
    if not itemList or next(itemList) == nil then
        QBCore.Functions.Notify(Config.Notify.Empty or "Your inventory is empty.", "error", 3500)
        StopClipboardEmote()
        return
    end

    local categorized = { Drugs = {}, Ingredients = {}, General = {} }

    for _, item in ipairs(itemList) do
        local info = Config.ItemDescriptions[item.name]
        local cat = (info and info.category) or "General"
        categorized[cat] = categorized[cat] or {}
        table.insert(categorized[cat], item)
    end

    local function sortByLabel(t)
        table.sort(t, function(a, b) return (a.label or a.name) < (b.label or b.name) end)
    end
    for _, t in pairs(categorized) do sortByLabel(t) end

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
                        args  = { name = item.name, label = item.label }
                    }
                }
            end
        end
    end

    addCategory("Drugs", categorized.Drugs)
    addCategory("Ingredients", categorized.Ingredients)
    addCategory("General", categorized.General)

    menu[#menu+1] = {
        header = Config.CloseLabel or "⬅ Close",
        params = { event = "analyzer:client:closeMenu" }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("analyzer:client:closeMenu", function()
    StopClipboardEmote()
    exports['qb-menu']:closeMenu()
end)

-- On selection → qb-notify with enhancements flags (informational only)
RegisterNetEvent("analyzer:client:analyzeItem", function(data)
    local name  = data.name
    local label = data.label or name
    local info  = Config.ItemDescriptions[name]

    if info and info.desc then
        local msg = ("%s: %s"):format(label, info.desc)

        -- If it's a Drug category, append enhancement flags
        if (info.category == "Drugs") then
            local effects = {}
            if info.speed  then effects[#effects+1] = "Speed"  end
            if info.armor  then effects[#effects+1] = "Armor"  end
            if info.health then effects[#effects+1] = "Health" end

            if #effects > 0 then
                msg = msg .. " | Enhancements: " .. table.concat(effects, ", ")
            else
                msg = msg .. " | Enhancements: none"
            end
        end

        QBCore.Functions.Notify(msg, "success", 8000)
    else
        QBCore.Functions.Notify(("No analysis data available for %s."):format(label), "error", 4500)
    end
end)

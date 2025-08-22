local QBCore = exports['qb-core']:GetCoreObject()

-- Job-gate helper (server-side)
local function IsJobAllowedServer(Player)
    if not Config.JobLock or not Config.JobLock.Enabled then return true end
    local job = Player and Player.PlayerData and Player.PlayerData.job
    if not job then return false end
    local name  = job.name
    local grade = (job.grade and (job.grade.level or job.grade)) or 0
    local min   = Config.JobLock.Allowed[name]
    return (min ~= nil) and (grade >= min)
end

-- Command (job-locked, optional via Config.Command)
CreateThread(function()
    if Config.Command and Config.Command.Enabled then
        local cmdName = Config.Command.Name or "analyzeinv"
        QBCore.Commands.Add(cmdName, "Open Inventory Analyzer (job-only)", {}, false, function(source, _)
            local src    = source
            local Player = QBCore.Functions.GetPlayer(src)
            if not Player then return end

            if IsJobAllowedServer(Player) then
                local withEmote = not (Config.Command.EmoteOnUse == false)
                TriggerClientEvent("analyzer:client:open", src, { withEmote = withEmote })
            else
                TriggerClientEvent("QBCore:Notify", src, Config.Notify.NoAuth or "You are not authorized to use this.", "error", 3500)
            end
        end, "user")

        print(("[qb-analyzer-npc] Command '/%s' registered."):format(cmdName))
    else
        print("[qb-analyzer-npc] Command disabled via Config.Command.Enabled=false")
    end
end)

-- Detect inventory system
local function detectInventorySystem()
    local cfg = (Config.Inventory and Config.Inventory.System) or "auto"
    if cfg == "qb" or cfg == "ox" then
        return cfg
    end

    local oxState = GetResourceState('ox_inventory')
    local qbState = GetResourceState('qb-core')
    local oxRunning = (oxState == 'started' or oxState == 'starting')
    local qbRunning = (qbState == 'started' or qbState == 'starting')

    if oxRunning and qbRunning then
        return Config.Inventory.PreferOxWhenBoth and "ox" or "qb"
    elseif oxRunning then
        return "ox"
    else
        return "qb"
    end
end

local INV_SYSTEM = detectInventorySystem()
print(("[qb-analyzer-npc] Inventory system: %s"):format(INV_SYSTEM))

-- Normalize any item shape to { name, label, count }
local function normalizeItem(entry)
    if not entry then return nil end
    local name  = entry.name
    local label = entry.label or entry.description or entry.title or entry.name
    local count = entry.count or entry.amount or entry.quantity or entry.stack or 0
    if not name or count <= 0 then return nil end
    return { name = name, label = label, count = count }
end

-- QB inventory fetch
local function getInventoryQB(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return {} end

    local inv = Player.PlayerData.items or {}
    local results = {}
    for _, slot in pairs(inv) do
        if slot and slot.name and (slot.amount or 0) > 0 then
            local norm = normalizeItem({ name = slot.name, label = slot.label, count = slot.amount })
            if norm then results[#results+1] = norm end
        end
    end
    return results
end

-- OX inventory fetch
local function getInventoryOX(src)
    local results = {}
    local ok, inv = pcall(function()
        return exports.ox_inventory:GetInventory(src)
    end)

    if ok and inv then
        local items = inv.items or inv
        for _, item in pairs(items) do
            local norm = normalizeItem(item)
            if norm then results[#results+1] = norm end
        end
    end
    return results
end

local function getPlayerInventory(src)
    if INV_SYSTEM == 'ox' then
        return getInventoryOX(src)
    else
        return getInventoryQB(src)
    end
end

-- Main event: gather inventory and send to client for menu
RegisterNetEvent("analyzer:server:getInventory", function()
    local src = source
    local results = getPlayerInventory(src)
    TriggerClientEvent("analyzer:client:showMenu", src, results or {})
end)

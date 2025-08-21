local QBCore = exports['qb-core']:GetCoreObject()

-- Detect inventory system based on config + running resources
local function detectInventorySystem()
    local cfg = (Config.Inventory and Config.Inventory.System) or "auto"
    if cfg == "qb" or cfg == "ox" then
        return cfg
    end

    -- auto-detect
    local oxState = GetResourceState('ox_inventory')
    local qbState = GetResourceState('qb-core')  -- presence of qb-core guarantees QB inv is possible
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

-- Normalize items into { name, label, count }
local function normalizeItem(entry)
    if not entry then return nil end
    local name = entry.name
    local label = entry.label or entry.description or entry.title or entry.name
    local count = entry.count or entry.amount or entry.quantity or entry.stack or 0
    if not name or not count or count <= 0 then return nil end
    return { name = name, label = label, count = count }
end

-- Fetch inventory for QB
local function getInventoryQB(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return {} end

    local inv = Player.PlayerData.items or {}
    local results = {}

    -- QB items are an array of slots: { name, label, amount, ... }
    for _, slot in pairs(inv) do
        if slot and slot.name and (slot.amount or 0) > 0 then
            local norm = normalizeItem({ name = slot.name, label = slot.label, count = slot.amount })
            if norm then
                results[#results+1] = norm
            end
        end
    end
    return results
end

-- Fetch inventory for OX
local function getInventoryOX(src)
    local results = {}

    -- OX patterns differ across versions; try a few safely.
    -- Preferred: exports.ox_inventory:GetInventory(source)
    local ok, inv = pcall(function()
        return exports.ox_inventory:GetInventory(src)
    end)

    if ok and inv then
        -- inv.items may be a map keyed by slot (or array) with entries having name, label/description, count
        local items = inv.items or inv
        for _, item in pairs(items) do
            -- Some OX builds store item data under item slot tables:
            -- { name="water", label=? , count=?, metadata=? }
            local norm = normalizeItem(item)
            if norm then
                results[#results+1] = norm
            end
        end
    else
        -- Fallback: some versions expose Search or other getters
        -- If you know your ox api, you can swap here; we keep it safe/no-crash.
        -- Example (commented as it may not exist on all builds):
        -- local items = exports.ox_inventory:GetPlayerItems(src) -- hypothetical
        -- if items then ... end
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

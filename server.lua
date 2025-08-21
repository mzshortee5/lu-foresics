local QBCore = exports['qb-core']:GetCoreObject()

-- Gathers a simple inventory list: name, label, count (no mutations)
RegisterNetEvent("analyzer:server:getInventory", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local inv = Player.PlayerData.items or {}
    local results = {}

    for _, item in pairs(inv) do
        if item and item.name and (item.amount or 0) > 0 then
            results[#results+1] = {
                name  = item.name,
                label = item.label or item.name,
                count = item.amount
            }
        end
    end

    TriggerClientEvent("analyzer:client:showMenu", src, results)
end)

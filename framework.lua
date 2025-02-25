Framework = {
    core = nil,
    current = nil
}

function Framework.Init()
    if Framework.ESX() then
        Framework.current = 'ESX'
        Framework.core = exports['es_extended']:getSharedObject()
    elseif Framework.QBCore() then
        Framework.current = 'QB'
        Framework.core = exports['qb-core']:GetCoreObject()
    end
end

function Framework.GetPlayer(source)
    if Framework.current == 'ESX' then
        return Framework.core.GetPlayerFromId(source)
    else
        return Framework.core.Functions.GetPlayer(source)
    end
end

function Framework.CreateUseableItem(name, cb)
    if Framework.current == 'ESX' then
        Framework.core.RegisterUsableItem(name, cb)
    else
        Framework.core.Functions.CreateUseableItem(name, cb)
    end
end

function Framework.AddItem(player, item, amount, info)
    if Framework.current == 'ESX' then
        player.addInventoryItem(item, amount, info)
    else
        player.Functions.AddItem(item, amount, nil, info)
    end
end

function Framework.RemoveMoney(player, account, amount, reason)
    if Framework.current == 'ESX' then
        player.removeAccountMoney(account, amount)
    else
        player.Functions.RemoveMoney(account, amount, reason)
    end
end

function Framework.Notify(source, message, type)
    if Config.Notify == 'ox' then
        TriggerClientEvent('ox_lib:notify', source, {
            description = message,
            type = type
        })
    elseif Config.Notify == 'qb' then
        TriggerClientEvent('QBCore:Notify', source, message, type)
    else
        if Framework.current == 'ESX' then
            TriggerClientEvent('esx:showNotification', source, message)
        end
    end
end

function Framework.SpawnVehicle(model, coords, heading)
    if Config.Target == 'ox_target' then
        return exports.ox_lib:spawnVehicle({
            model = model,
            coords = coords,
            heading = heading
        })
    else
        -- Default spawning logic
        local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
        return vehicle
    end
end

function Framework.GetMoney(player, account)
    if Framework.current == 'ESX' then
        return player.getAccount(account).money
    else
        return player.PlayerData.money[account]
    end
end

function Framework.CreateTarget(...)
    if Config.Target == 'ox_target' then
        return exports.ox_target:addBoxZone(...)
    elseif Config.Target == 'qb-target' then
        return exports['qb-target']:AddBoxZone(...)
    end
end

function Framework.HasItem(player, item)
    if Framework.current == 'ESX' then
        local item = player.getInventoryItem(item)
        return item and item.count > 0
    else
        local item = player.Functions.GetItemByName(item)
        return item and item.amount > 0
    end
end

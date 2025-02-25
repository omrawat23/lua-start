-- Function to get the core object based on the configured framework
local function GetCoreObject()
  if Config.framework == "qb" then
    return exports["qb-core"]:GetCoreObject()
  elseif Config.framework == "esx" then
    return exports["es_extended"]:getSharedObject()
  else
    print("Unsupported framework:", Config.framework)
    return nil
  end
end

local Core = GetCoreObject()
local ESX = nil
if Config.framework == "esx" then
    ESX = GetCoreObject()
end

-- Table to store active rentals
local activeRentals = {}

-- Function to create rental document item
local function CreateRentalDocument(info)
  return {
    name = "rental_document",
    info = info,
    label = "Vehicle Rental Agreement",
    description = string.format(
      "Vehicle: %s\nPlate: %s\nRenter: %s\nExpires: %s",
      info.vehicle,
      info.plate,
      info.name,
      info.expires
    ),
  }
end

-- Function to get player object based on the configured framework
local function GetPlayer(src)
  print("GetPlayer called with source:", src)
  if Config.framework == "qb" then
    if Core and Core.Functions then
      local player = Core.Functions.GetPlayer(src)
      if player then
        print("GetPlayer (QBCore) returned player:", player.PlayerData.citizenid)
      else
        print("GetPlayer (QBCore) returned nil")
      end
      return player
    else
      print("QBCore Player or Functions are nil")
      return nil
    end
  elseif Config.framework == "esx" then
    if ESX then
      local player = ESX.GetPlayerFromId(src)
      if player then
        print("GetPlayer (ESX) returned player:", player.identifier)
      else
        print("GetPlayer (ESX) returned nil")
      end
      return player
    else
      print("ESX is nil")
      return nil
    end
  else
    print("Unsupported framework:", Config.framework)
    return nil
  end
end

-- Function to remove money from player based on the configured framework
local function RemoveMoney(Player, paymentMethod, amount, reason)
  print("RemoveMoney called with paymentMethod:", paymentMethod, "amount:", amount, "reason:", reason)

  if Config.framework == "qb" then
    if Player and Player.Functions then
      local success = Player.Functions.RemoveMoney(paymentMethod, amount, reason)
      print("RemoveMoney (QBCore) returned:", success)
      return success
    else
      print("QBCore Player or Functions are nil")
      return false
    end
  elseif Config.framework == "esx" then
    if paymentMethod == "cash" then
      -- Check if player has enough money first
      if Player.getMoney() >= amount then
        Player.removeMoney(amount)
        print("RemoveMoney (ESX - cash) successful")
        return true
      else
        print("Not enough cash")
        return false
      end
    elseif paymentMethod == "bank" then
      -- Check account balance first
      if Player.getAccount("bank").money >= amount then
        Player.removeAccountMoney("bank", amount)
        print("RemoveMoney (ESX - bank) successful")
        return true
      else
        print("Not enough bank balance")
        return false
      end
    else
      print("Unsupported payment method:", paymentMethod)
      return false
    end
  else
    print("Unsupported framework:", Config.framework)
    return false
  end
end

-- Function to add item to player inventory based on the configured framework
local function AddItem(Player, itemName, count, info)
  if Config.framework == "qb" then
    if Player and Player.Functions then
      Player.Functions.AddItem(itemName, count, false, info)
    else
      print("QBCore Player or Functions are nil")
    end
  elseif Config.framework == "esx" then
    Player.addInventoryItem(itemName, count, info)
  else
    print("Unsupported framework:", Config.framework)
  end
end

-- Function to remove item from player inventory based on the configured framework
local function RemoveItem(Player, itemName, count, slot)
  if Config.framework == "qb" then
    if Player and Player.Functions then
      Player.Functions.RemoveItem(itemName, count, slot)
    else
      print("QBCore Player or Functions are nil")
    end
  elseif Config.framework == "esx" then
      if Player then
          Player.removeInventoryItem(itemName, count)
      else
          print("ESX Player is nil")
      end
  else
    print("Unsupported framework:", Config.framework)
  end
end

-- Function to get items by name from player inventory based on the configured framework
local function GetItemsByName(Player, itemName)
  if Config.framework == "qb" then
    if Player and Player.Functions then
      return Player.Functions.GetItemsByName(itemName)
    else
      print("QBCore Player or Functions are nil")
      return {}
    end
  elseif Config.framework == "esx" then
    local items = {}
    if Player and Player.inventory then
      for i = 1, #Player.inventory, 1 do
        local item = Player.inventory[i]
        if item and item.name == itemName then
          table.insert(items, item)
        end
      end
    end
    return items
  else
    print("Unsupported framework:", Config.framework)
    return {}
  end
end

-- Function to trigger client event for notifications based on the configured framework
local function Notify(src, message, type)
  if Config.Notify == "qb" then
    TriggerClientEvent("QBCore:Notify", src, message, type)
  elseif Config.Notify == "ox" then
    TriggerClientEvent("ox_lib:notify", src, message, { type = type })
  elseif Config.framework == "esx" then
    TriggerClientEvent("esx:showNotification", src, message)
  else
    print("Unsupported notification system:", Config.Notify)
  end
end

-- Function to check if a player has a license (ESX Implementation)
local function HasLicense(Player, licenseType)
  if Config.framework == "esx" then
    local licenseItemName = ""
    if licenseType == "car" then
      licenseItemName = "driverlicense"
    elseif licenseType == "boat" then
      licenseItemName = "boatlicense"
    elseif licenseType == "aircraft" then
      licenseItemName = "pilotlicense"
    end

    if Player and Player.inventory then
      for i = 1, #Player.inventory, 1 do
        local item = Player.inventory[i]
        if item and item.name == licenseItemName and item.count > 0 then
          return true
        end
      end
    end
    return false
  else
    print("HasLicense function only implemented for ESX framework.")
    return false
  end
end

-- Payment and rental processing
RegisterNetEvent("rental:pay", function(price, model, rental, color, paymentMethod, duration)
  local src = source
  local Player = GetPlayer(src)

  if not Player then
      print("Player not found for source:", src)
      Notify(src, "Player not found!", "error")
      return
  end

  -- Input validation
  if not price or type(price) ~= "number" or price <= 0 then
      Notify(src, "Invalid rental price!", "error")
      return
  end

  if not model or type(model) ~= "string" then
      Notify(src, "Invalid vehicle model!", "error")
      return
  end

  if not color then
      Notify(src, "Please select a color!", "error")
      return
  end

  if not duration or type(duration) ~= "number" or duration <= 0 then
      duration = 24 -- Default to 24 hours if not specified
  end

  -- Calculate total price based on duration
  local totalPrice = price * (duration / 24)

  -- Check for license if required
  if Config.framework == "esx" and rental.licenseRequired then
      if not HasLicense(Player, rental.licenseRequired) then
          Notify(src, "You need a " .. rental.licenseRequired .. " license!", "error")
          return
      end
  end

  -- Process payment
  local success = RemoveMoney(Player, paymentMethod, totalPrice, "vehicle-rental")

  if success then
      -- Store rental information
      activeRentals[src] = {
          model = model,
          price = totalPrice,
          startTime = os.time(),
          duration = duration,
          plate = nil -- Will be set when vehicle spawns
      }

      -- Spawn vehicle for player
      TriggerClientEvent("rental:spawnVehicle", src, model, rental, color, duration)
      Notify(src, string.format("Vehicle rented for $%d for %d hours", totalPrice, duration), "success")
  else
      Notify(src, "Insufficient funds!", "error")
  end
end)

-- Give rental document to player
RegisterNetEvent("rental:giveRentalDocument", function(info)
  local src = source
  local Player = GetPlayer(src)

  if not Player then
    return
  end

  local documentItem = CreateRentalDocument(info)
  AddItem(Player, documentItem.name, 1, documentItem.info)

  if Config.framework == "qb" then
    TriggerClientEvent(
      "inventory:client:ItemBox",
      src,
      QBCore.Shared.Items[documentItem.name],
      "add"
    )
  elseif Config.framework == "esx" then
    if Config.Inventory == "ox" then
      exports.ox_inventory:AddItem(src, documentItem.name, 1, documentItem.info)
    end
  end

  if activeRentals[src] then
    activeRentals[src].plate = info.plate
  end
end)

-- Remove rental document from player
RegisterNetEvent("rental:removeRentalDocument", function(plate)
  local src = source
  local Player = GetPlayer(src)

  if not Player then
    return
  end

  local items = GetItemsByName(Player, "rental_document")
  if items then
    for _, item in ipairs(items) do
      if item and item.info and item.info.plate == plate then
        RemoveItem(Player, item.name, 1, item.slot)

        if Config.framework == "qb" then
          TriggerClientEvent(
            "inventory:client:ItemBox",
            src,
            QBCore.Shared.Items[item.name],
            "remove"
          )
        elseif Config.framework == "esx" then
          if Config.Inventory == "ox" then
            exports.ox_inventory:RemoveItem(src, item.name, 1, item.info)
          else
            -- Default ESX inventory handling
            TriggerClientEvent('esx:showNotification', src, "Rental document removed")
          end
        end
        break
      end
    end
  end

  activeRentals[src] = nil
end)

-- Check rental expiration periodically
CreateThread(function()
  while true do
    Wait(60000)
    local currentTime = os.time()

    for src, rental in pairs(activeRentals) do
      if rental and rental.startTime + rental.duration * 3600 < currentTime then
        TriggerClientEvent("rental:returnVehicle", src)
        Notify(src, "Your rental has expired!", "error")
        activeRentals[src] = nil
      end
    end
  end
end)

-- Handle player disconnection
AddEventHandler("playerDropped", function()
  local src = source
  if activeRentals[src] then
    activeRentals[src] = nil
  end
end)

-- Handle resource stop
AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end

  for src, _ in pairs(activeRentals) do
    TriggerClientEvent("rental:returnVehicle", src)
  end
end)

-- QB-Core item use registration
if Config.framework == "qb" and Core and Core.Functions then
  Core.Functions.CreateUseableItem("rental_document", function(source, item)
    if not item.info then
      return
    end

    local src = source
    local Player = GetPlayer(src)
    if not Player then
      return
    end

    Notify(
      src,
      string.format(
        "Rental Info:\nVehicle: %s\nPlate: %s\nExpires: %s",
        item.info.vehicle,
        item.info.plate,
        item.info.expires
      ),
      "primary"
    )
  end)
end

-- Export active rentals for other resources
exports("GetActiveRentals", function()
  return activeRentals
end)

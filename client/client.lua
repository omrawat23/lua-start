local rentedVehicle = nil
local rentalBlip = nil
local rentalTimer = nil
local rentalData = {}

-- Properly initialize ox_lib
local lib = nil
if GetResourceState('ox_lib') == 'started' then
    lib = exports.ox_lib
end

-- Function to get the core object based on the configured framework
local function GetCoreObject()
  if Config.framework == "qb" then
    return exports["qb-core"]:GetCoreObject()
  elseif Config.framework == "esx" then
    ESX = exports["es_extended"]:getSharedObject()
    return ESX
  else
    print("Unsupported framework:", Config.framework)
    return nil
  end
end

local Core = GetCoreObject()

-- Function to get player data based on the configured framework
local function GetPlayerData()
  if Config.framework == "qb" and Core and Core.Functions then
    return Core.Functions.GetPlayerData()
  elseif Config.framework == "esx" and ESX then
    return ESX.GetPlayerData()
  else
    print("Unsupported framework:", Config.framework)
    return nil
  end
end

-- Fixed Notify function - specifically fixing export calling method
local function Notify(message, type)
  if Config.Notify == "qb" then
    if Core and Core.Functions then
      Core.Functions.Notify(message, type)
    end
  elseif Config.Notify == "ox" then
    if lib then
      -- Fix for the export error - use proper method
      lib:notify({
        title = "Vehicle Rental",
        description = message,
        type = type
      })
    else
      -- Fallback to native notification
      SetNotificationTextEntry("STRING")
      AddTextComponentString(message)
      DrawNotification(false, false)
    end
  elseif Config.Notify == "esx" then
    local notifyType = type
    if type == "error" then
      notifyType = "error"
    elseif type == "success" then
      notifyType = "success"
    else
      notifyType = "info"
    end

    if ESX and ESX.ShowNotification then
      ESX.ShowNotification(message, notifyType, 3000)
    else
      SetNotificationTextEntry("STRING")
      AddTextComponentString(message)
      DrawNotification(false, false)
    end
  else
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
  end
end

-- Function to check for licenses based on the configured framework
local function HasLicense(licenseType)
  local playerData = GetPlayerData()
  if Config.framework == "qb" then
    return playerData and playerData.metadata and
        playerData.metadata[Config.DriverLicense[licenseType]] or false
  elseif Config.framework == "esx" then
    local hasLicense = false
    if ESX then
      ESX.TriggerServerCallback(
        "esx_license:checkLicense",
        function(has)
          hasLicense = has
        end,
        GetPlayerServerId(PlayerId()),
        Config.DriverLicense[licenseType]
      )
      Wait(100)
    end
    return hasLicense
  else
    print("Unsupported framework:", Config.framework)
    return false
  end
end

-- Helper function for 3D text - Define BEFORE it's used
local function DrawText3D(x, y, z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  local px, py, pz = table.unpack(GetGameplayCamCoords())

  if onScreen then
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 41, 41, 90)
  end
end

-- Initialize Target
CreateThread(function()
  for _, rental in pairs(Config.Locations) do
    local model = rental.ped.hash
    RequestModel(model)
    while not HasModelLoaded(model) do
      Wait(100)
    end

    local ped =
      CreatePed(
      4,
      model,
      rental.coords.x,
      rental.coords.y,
      rental.coords.z,
      rental.coords.w,
      false,
      true
    )
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)

    if rental.ped.scenario then
      TaskStartScenarioInPlace(ped, rental.ped.scenario, 0, true)
    end

    local blip = AddBlipForCoord(rental.coords.x, rental.coords.y, rental.coords.z)
    SetBlipSprite(blip, rental.blip.sprite)
    SetBlipColour(blip, rental.blip.colour)
    SetBlipScale(blip, 0.75)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(rental.blip.label)
    EndTextCommandSetBlipName(blip)

    local targetOptions = {
      {
        type = "client",
        event = "rental:openMenu",
        icon = "fas fa-car",
        label = "Rent a Vehicle",
        rental = rental,
      },
      {
        type = "client",
        event = "rental:returnVehicle",
        icon = "fas fa-undo",
        label = "Return Vehicle",
        canInteract = function()
          return rentedVehicle ~= nil
        end,
      },
    }

    if Config.Target == "qb-target" then
      exports["qb-target"]:AddTargetEntity(ped, {
        options = targetOptions,
        distance = Config.TargetDistance["rental:openMenu"] or 2.5,
      })
    elseif Config.Target == "ox_target" then
      exports.ox_target:addLocalEntity(ped, targetOptions)
    else
      print("Unsupported target resource:", Config.Target)
    end
  end
end)

-- Generate Rental Document
local function GenerateRentalDocument(vehicleData, plate)
  local playerData = GetPlayerData()
  if not playerData then
    Notify("Could not get player data", "error")
    return
  end

  local info = {
    plate = plate,
    vehicle = vehicleData.model,
  }

  if Config.framework == "qb" then
    info.name =
      playerData.charinfo and
      playerData.charinfo.firstname .. " " .. playerData.charinfo.lastname or
      "Unknown"
  elseif Config.framework == "esx" then
    info.name = playerData.name or "Unknown"
  else
    info.name = "Unknown"
  end

  TriggerServerEvent("rental:giveRentalDocument", info)
end


-- Open Rental Menu Event Handler
RegisterNetEvent("rental:openMenu")
AddEventHandler("rental:openMenu", function(data)
  local rental = data.rental or data
  local categories = {}

  for _, category in ipairs(rental.categories) do
    local categoryVehicles = {}
    for _, vehicle in ipairs(category.vehicles) do
      table.insert(categoryVehicles, {
        id = vehicle.model,
        model = vehicle.model,
        price = vehicle.money,
        image = vehicle.img,
        seats = vehicle.seats or 2,
        speed = vehicle.speed or "100 km/h",
        efficiency = vehicle.efficiency or "80%",
        colors = vehicle.colors,
        type = vehicle.type or "bike",
      })
    end

    table.insert(categories, {
      name = category.name,
      vehicles = categoryVehicles,
    })
  end

  SendNUIMessage({
    action = "openRentalMenu",
    data = {
      coords = rental.coords,
      ped = rental.ped,
      blip = rental.blip,
      spawnpoint = rental.spawnpoint,
      categories = categories,
      type = rental.type,
    },
  })
  SetNuiFocus(true, true)
end)

RegisterNetEvent("rental:rentVehicle")
AddEventHandler("rental:rentVehicle", function(data)
  print("rental:rentVehicle event handler started")
  if rentedVehicle then
    Notify("Return your current rental first!", "error")
    print("rental:rentVehicle - Already have a rental")
    return
  end

  local vehicleType = data.rental.type or "bike"
  local hasRequiredLicense = true -- Assume true initially

  if Config.DriverLicense and Config.DriverLicense[vehicleType] then
    hasRequiredLicense = HasLicense(vehicleType)
  end

  if not hasRequiredLicense then
    Notify("You need a " .. vehicleType .. " license!", "error")
    print("rental:rentVehicle - Missing license")
    return
  end

  print("rental:rentVehicle - Triggering server event")
  TriggerServerEvent(
    "rental:pay",
    data.price,
    data.model,
    data.rental,
    data.color,
    data.paymentMethod,
    data.duration or 24 -- Added duration parameter with default
  )
  print("rental:rentVehicle event handler finished")
end)

-- Spawn Vehicle Event Handler
RegisterNetEvent("rental:spawnVehicle")
AddEventHandler("rental:spawnVehicle", function(vehicleModel, rental, color, duration)
  print("rental:spawnVehicle event handler started")
  RequestModel(vehicleModel)
  while not HasModelLoaded(vehicleModel) do
    Wait(100)
  end

  local spawnpoint = rental.spawnpoint
  rentedVehicle =
    CreateVehicle(
    vehicleModel,
    spawnpoint.x,
    spawnpoint.y,
    spawnpoint.z,
    spawnpoint.w,
    true,
    false
  )

  if color then
    local r, g, b = color:match("rgb%((%d+), (%d+), (%d+)%)")
    if r and g and b then
      SetVehicleModKit(rentedVehicle, 0)
      SetVehicleCustomPrimaryColour(
        rentedVehicle,
        tonumber(r),
        tonumber(g),
        tonumber(b)
      )
      SetVehicleCustomSecondaryColour(
        rentedVehicle,
        tonumber(r),
        tonumber(g),
        tonumber(b)
      )
    end
  end

  local plate = "RENT" .. math.random(100, 999)
  SetVehicleNumberPlateText(rentedVehicle, plate)
  SetEntityAsMissionEntity(rentedVehicle, true, true)
  TaskWarpPedIntoVehicle(PlayerPedId(), rentedVehicle, -1)

  rentalBlip = AddBlipForEntity(rentedVehicle)
  SetBlipSprite(rentalBlip, 225)
  SetBlipColour(rentalBlip, 3)
  SetBlipScale(rentalBlip, 0.75)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Rented Vehicle")
  EndTextCommandSetBlipName(rentalBlip)

  rentalData = {
    model = vehicleModel,
    plate = plate,
    duration = duration or 24,
    startTime = GetGameTimer()
  }
  GenerateRentalDocument(rentalData, plate)

  Notify("Vehicle rented successfully!", "success")
  SetNuiFocus(false, false)
  print("rental:spawnVehicle event handler finished")
end)

-- Return Vehicle Event Handler
RegisterNetEvent("rental:returnVehicle")
AddEventHandler("rental:returnVehicle", function()
  if rentedVehicle then
    DeleteVehicle(rentedVehicle)
    RemoveBlip(rentalBlip)

    if rentalTimer then
      -- Safe way to clear timer
      if type(rentalTimer) == "number" then
        ClearTimeout(rentalTimer)
      end
      rentalTimer = nil
    end

    TriggerServerEvent("rental:removeRentalDocument", rentalData.plate)

    rentedVehicle = nil
    rentalBlip = nil
    rentalData = {}

    Notify("Vehicle returned successfully!", "success")
  else
    Notify("You have no rented vehicle!", "error")
  end
  SetNuiFocus(false, false)
end)

-- Clean up on resource stop
AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end
  if rentedVehicle then
    DeleteVehicle(rentedVehicle)
    RemoveBlip(rentalBlip)
  end
end)

-- NUI Callbacks
RegisterNUICallback("closeRentalMenu", function(data, cb)
  SetNuiFocus(false, false)
  cb({ok = true})
end)

RegisterNUICallback("rental:rentVehicle", function(data, cb)
  TriggerEvent("rental:rentVehicle", data)
  cb({ok = true})
end)

RegisterNUICallback("rental:returnVehicle", function(data, cb)
  TriggerEvent("rental:returnVehicle")
  cb({ok = true})
end)

-- Add hover text for rental document
CreateThread(function()
  while true do
    Wait(0)
    if rentalData and rentalData.plate then
      local player = PlayerPedId()
      local vehicle = GetVehiclePedIsIn(player, false)

      if vehicle ~= 0 and GetVehicleNumberPlateText(vehicle) == rentalData.plate then
        local coords = GetEntityCoords(player)

        -- Calculate time remaining
        local timeElapsed = (GetGameTimer() - (rentalData.startTime or 0)) / 60000 -- Convert to minutes
        local hoursRemaining = math.max(0, (rentalData.duration or 24) - (timeElapsed / 60))

        local text = string.format(
          "Rental Info:\nPlate: %s\nVehicle: %s\nTime Remaining: %.1f hours",
          rentalData.plate,
          rentalData.model or "Unknown",
          hoursRemaining
        )

        DrawText3D(coords.x, coords.y, coords.z + 1.5, text)
      end
    end
  end
end)
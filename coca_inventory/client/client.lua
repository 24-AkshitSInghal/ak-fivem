local isInventoryOpen = false
local isTrunkOpen = true
local playerId = GetPlayerServerId(PlayerId())
local stopToggleInventory = false

local function drawNativeNotification(text)
  SetTextComponentFormat("STRING")
  AddTextComponentString(text)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterKeyMapping('inventory_open_key', 'Open Inventory', 'keyboard', 'TAB')

RegisterCommand('inventory_open_key', function()
  local ped = GetPlayerPed(-1)
  if IsPedInAnyVehicle(ped, false) then
    local veh = GetVehiclePedIsIn(ped, false)
    local plate = GetVehicleNumberPlateText(veh):gsub(' ', '')

    -- Trigger a server event to request access to the inventory
    TriggerServerEvent('coca_inventory:Server:RequestOpenCarInventory', 'glovebox', plate)
  else
    Wait(50)
    ToggleInventory('drop', Config.invetoryData['drop'].MaxWeight)
  end
end, false)

RegisterKeyMapping('pocket_1', 'Pocket 1', 'keyboard', '1')
RegisterCommand('pocket_1', function()
  DisableControlAction(0, 157, true)
  local itemName = GetItemNamefromIndex(1)
  if itemName == '' then return end
  HandleItemUse(itemName, 1)
end, false)

RegisterKeyMapping('pocket_2', 'Pocket 2', 'keyboard', '2')
RegisterCommand('pocket_2', function()
  DisableControlAction(0, 158, true)
  local itemName = GetItemNamefromIndex(2)
  if itemName == '' then return end
  HandleItemUse(itemName, 2)
end, false)

RegisterKeyMapping('pocket_3', 'Pocket 3', 'keyboard', '3')
RegisterCommand('pocket_3', function()
  DisableControlAction(0, 159, true)
  local itemName = GetItemNamefromIndex(3)
  if itemName == '' then return end
  HandleItemUse(itemName, 3)
end, false)

RegisterKeyMapping('pocket_4', 'Pocket 4', 'keyboard', '4')
RegisterCommand('pocket_4', function()
  DisableControlAction(0, 160, true)
  local itemName = GetItemNamefromIndex(4)
  if itemName == '' then return end
  HandleItemUse(itemName, 4)
end, false)

RegisterKeyMapping('pocket_5', 'Pocket 5', 'keyboard', '5')
RegisterCommand('pocket_5', function()
  DisableControlAction(0, 161, true)
  local itemName = GetItemNamefromIndex(5)
  if itemName == '' then return end
  HandleItemUse(itemName, 5)
end, false)


RegisterCommand('trunk', function()
  local ped = GetPlayerPed(-1)
  local coords = GetEntityCoords(ped)
  local vehicle = GetClosestVehicle(coords, 5.0, 0, 127)
  if vehicle ~= 0 and vehicle ~= nil then
    local trunkcoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)

    if IsBackEngine(GetEntityModel(vehicle)) then
      trunkcoords = GetOffsetFromEntityInWorldCoords(vehicle, 0, 2.5, 0)
    end

    local vehicleClassIndex = GetVehicleClass(vehicle)
    local playerToVehicleDis = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, trunkcoords, true)

    local distanceThreshold = 1
    if vehicleClassIndex == 20 or vehicleClassIndex == 11 then
      distanceThreshold = 1.9
    end

    if playerToVehicleDis < distanceThreshold and not IsPedInAnyVehicle(ped, false) then
      if GetVehicleDoorLockStatus(vehicle) < 2 then
        local plate = GetVehicleNumberPlateText(vehicle):gsub(' ', '')
        -- Trigger a server event to request access to the trunk inventory
        local vehicleClassName = GetVehicleClassName(vehicle)
        TriggerServerEvent('coca_inventory:Server:RequestOpenCarInventory', 'trunk', plate, vehicleClassName)
      end
    end
  end
end)

-- Wait for a response from the server
RegisterNetEvent('coca_inventory:Client:AccessGranted', function(inventoryType, vehicleClassName)
  if inventoryType == 'trunk' then
    isTrunkOpen = true
    ToggleInventory(inventoryType, Config.VehicleLimit[vehicleClassName])
    OpenTrunk()
  else
    ToggleInventory(inventoryType, Config.invetoryData['glovebox'].MaxWeight)
  end
end)

-- If access is denied
RegisterNetEvent('coca_inventory:Client:AccessDenied', function(inventoryType)
  drawNativeNotification("The " .. inventoryType .. " is already being accessed by another player.")
end)



function ToggleInventory(inventoryName, inventoryMaxSpace)
  if stopToggleInventory then return end
  isInventoryOpen = not isInventoryOpen
  SetNuiFocus(isInventoryOpen, isInventoryOpen)
  if isInventoryOpen then
    FetchPlayerInventory()
  end
  Wait(500)

  SendNUIMessage({
    type = "toggleInventory",
    display = isInventoryOpen,
    inventoryName = inventoryName,
    inventoryMaxSpace = inventoryMaxSpace
  })
end

function RefreshNuiPlayerInventory(inventory)
  SendNUIMessage({
    type = "updatePlayerInventory",
    inventory = inventory
  })
end

function RefreshNuiOtherInventory(data)
  SendNUIMessage({
    type = "updateOtherInventory",
    inventorydata = data
  })
end

function FetchPlayerInventory()
  local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
  TriggerServerEvent('coca_inventory:Server:FetchInventory', characterId)
end

function RemoveItemFromInventorybyIndex(itemIndex, count)
  local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
  TriggerServerEvent('coca_inventory:Server:RemoveItembyIndex', characterId, itemIndex, count)
end

RegisterNetEvent('coca_inventory:Client:ItemUse', function(UsedItemName, itemIndex)
  HandleItemUse(UsedItemName, itemIndex)
end)

CreateThread(function()
  while true do
    Wait(1500)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    if characterId then
      TriggerServerEvent('coca_inventory:Server:InitializeInventory', characterId)
      break
    end
  end
end)


RegisterNUICallback('ui-closeInventory', function(data, cb)
  ToggleInventory("close")
  if isTrunkOpen then
    isTrunkOpen = false
    CloseTrunk()
  end
  cb({})
end)

RegisterNUICallback('ui-useItem', function(data, cb)
  local name        = data.name
  local index       = data.index
  local inventory   = data.inventory
  local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
  if name then
    TriggerServerEvent('coca_inventory:Server:ItemUse', characterId, index, inventory)
  end
  cb({})
end)


RegisterNUICallback('UI-PlayerInventoy', function(data, cb)
  local recivedInventory = data
  local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
  local newInventory = {}

  for index, item in ipairs(recivedInventory) do
    if not item.name or item.name == '' then
      table.insert(newInventory, index, { name = '', count = 0 })
    else
      local newItem = { name = item.name, count = item.count }
      table.insert(newInventory, index, newItem)
    end
  end

  SetNewInventory(newInventory)
  TriggerServerEvent('coca_inventory:Server:SaveNewInventory', characterId, newInventory)
  cb('ok')
end)

RegisterNetEvent('load', function(result)
  SendNUIMessage({
    type = "print",
    data = result
  })
end)



RegisterNetEvent('coca_inventory:statusAlert', function(status)
  drawNativeNotification(status)
end)

RegisterNetEvent('coca_inventory:stopInventoryUI', function(state)
  stopToggleInventory = state
end)

RegisterNetEvent('coca_inventory:Client:OpenCarInventory', function(inventoryType, InventoryData)
  local data = nil
  local inventoryItems = {}

  -- Initialize each slot
  for i = 1, 80 do
    inventoryItems[i] = { name = '', count = 0 }
  end

  -- Decode the inventory data based on the inventory type
  if InventoryData then
    if inventoryType == 'trunk' and InventoryData.trunk_inventory then
      data = json.decode(InventoryData.trunk_inventory)
    elseif inventoryType == 'glovebox' and InventoryData.glovebox_inventory then
      data = json.decode(InventoryData.glovebox_inventory)
    end
  end

  -- If there is data, populate inventoryItems with it
  if data then
    for index, item in ipairs(data) do
      local itemConfig = Config.Items[item.name]
      if itemConfig then
        -- Populate item details from config
        for key, value in pairs(itemConfig) do
          item[key] = value
        end
        -- Add item to inventoryItems
        inventoryItems[index] = item
      end
    end
  end

  -- Print the inventoryItems for debugging
  print(json.encode(inventoryItems))

  -- Refresh the NUI with the inventoryItems
  RefreshNuiOtherInventory({ inventory = inventoryItems })
end)

RegisterNUICallback('UI-Glovebox', function(data, cb)
  local ped = GetPlayerPed(-1)
  local recivedInventory = data
  local veh = GetVehiclePedIsIn(ped, false)
  local plate = GetVehicleNumberPlateText(veh):gsub(' ', '')

  -- Prepare drop inventory data
  local newInventory = {}

  for index, item in ipairs(recivedInventory) do
    print(item.name)
    if not item.name or item.name == '' then
      table.insert(newInventory, index, { name = '', count = 0 })
    else
      local newItem = { name = item.name, count = item.count }
      table.insert(newInventory, index, newItem)
    end
  end
  print("here")
  TriggerServerEvent('coca_inventory:Server:SetGloveBoxInventory', plate, newInventory)
  cb('ok')
end)

RegisterNUICallback('UI-Trunk', function(data, cb)
  local ped = GetPlayerPed(-1)
  local recivedInventory = data
  local coords = GetEntityCoords(ped)
  local vehicle = GetClosestVehicle(coords, 5.0, 0, 127)
  local plate = GetVehicleNumberPlateText(vehicle):gsub(' ', '')

  -- Prepare drop inventory data
  local newInventory = {}

  for index, item in ipairs(recivedInventory) do
    if not item.name or item.name == '' then
      table.insert(newInventory, index, { name = '', count = 0 })
    else
      local newItem = { name = item.name, count = item.count }
      table.insert(newInventory, index, newItem)
    end
  end

  TriggerServerEvent('coca_inventory:Server:SetTrunkInventory', plate, newInventory)
  cb('ok')
end)

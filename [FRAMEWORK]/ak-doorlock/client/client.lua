local Doors = {}
local PlayerPed = PlayerPedId()

Doors = Config.Doors
Wait(2000)

function DrawText3D(x, y, z, text)
	local onScreen, _x, _y = World3dToScreen2d(x, y, z)
	local px, py, pz = table.unpack(GetGameplayCamCoords())
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)

	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x, _y)
	local factor = (string.len(text)) / 370
	DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

local function handleDoorStateChange(doorIndex, lockState)
    local door = Doors[doorIndex]
    if door then
        DoorSystemSetDoorState(door.DoorHash, lockState)
        DoorSystemSetOpenRatio(door.DoorHash, 0.0)
        door.Locked = lockState
        Doors[doorIndex] = door
    end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(10)
        end
    end
    return animDict
end

for k, v in pairs(Config.Doors) do
    AddDoorToSystem(v.DoorHash, v.ModelHash, v.Coordinates)
    DoorSystemSetDoorState(v.DoorHash, v.Locked)
end

RegisterNetEvent('coca_props_door:update', handleDoorStateChange)


function changeDoorState()
    local PlayerPed = PlayerPedId()
    local nearestDoorIndex = nil
    local minDistance = math.huge
    local anim = "fob_click_fp"
    local animDict = "anim@mp_player_intmenu@key_fob@"

    local fraction = exports['coca_spawnmanager']:GetCharacterFraction()

    ensureAnimDict(animDict)
    for k, v in pairs(Doors) do
        local coords = v.LabelCoords
        local distance = #(coords - GetEntityCoords(PlayerPed))
        if distance <= 2 and distance < minDistance then
            minDistance = distance
            nearestDoorIndex = k
        end
    end

    local requiredFraction = Doors[nearestDoorIndex].type
    local accessItemName = Doors[nearestDoorIndex].SpecialAccess
    local door = Doors[nearestDoorIndex]

    if nearestDoorIndex and (requiredFraction == nil or requiredFraction == fraction or fraction == 'admin') and accessItemName == nil then
        local lockState = door.Locked ~= 0 and 0 or 1
        TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, -8.0, 4000, 32, 0, false, false, false)
        TriggerServerEvent("coca_props_door:doorStateChange", nearestDoorIndex, lockState)
        return
    end

    if nearestDoorIndex and (requiredFraction == nil or requiredFraction == fraction or accessItemName ~= nil)  then
        local doPlayerHaveItem = exports['coca_inventory']:HasItemInInventory(accessItemName)
        if not doPlayerHaveItem and fraction ~= "admin" then return end
        local lockState = door.Locked ~= 0 and 0 or 1
        TaskPlayAnim(PlayerPedId(), animDict, anim, 8.0, -8.0, 4000, 32, 0, false, false, false)
        TriggerServerEvent("coca_props_door:doorStateChange", nearestDoorIndex, lockState)
    end
end

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('coca_props_door:Server:RequestDoorStates')
end)

RegisterNetEvent("coca_props_door:setDoors", function(doors)
    Doors = doors
    print(Doors)
    for k, v in pairs(Doors) do
        AddDoorToSystem(v.DoorHash, v.ModelHash, v.Coordinates)
        DoorSystemSetDoorState(v.DoorHash, v.Locked)
    end
    DoorSystemSetHoldOpen("vanilla_2", true)
    
end)



local accessCache = {}
local cacheCleanupInterval = 30000 -- 30 seconds

-- Function to clean up old cache entries
local function cleanUpCache()
    local currentTime = GetGameTimer()
    for key, data in pairs(accessCache) do
        if currentTime - data.timestamp >= 10000 then
            accessCache[key] = nil
        end
    end
end

CreateThread(function()
    local lastCleanup = GetGameTimer()

    local characterId = nil

    while characterId == nil do
        Wait(1000)
        characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    end

    local fraction = exports['coca_spawnmanager']:GetCharacterFraction()

    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local currentTime = GetGameTimer()

        for _, door in pairs(Doors) do
            local doorCoords = door.LabelCoords
            local distance = #(doorCoords - playerCoords)

            if distance <= 2 then
                sleep = 5
                local text = door.Locked ~= 0 and "Locked ~r~[E]~s~" or "Unlocked ~g~[E]~s~"

                if not door.Hidden then
                    DrawText3D(doorCoords.x, doorCoords.y, doorCoords.z, text)
                    if IsControlJustPressed(1, 38) then
                        changeDoorState()
                    end
                else
                    local cacheKey = door.SpecialAccess
                    local cachedData = accessCache[cacheKey]
                    local hasAccessItem = false

                    if cachedData and (currentTime - cachedData.timestamp < 10000) then
                        hasAccessItem = cachedData.result
                    else
                        hasAccessItem = exports['coca_inventory']:HasItemInInventory(door.SpecialAccess)
                        accessCache[cacheKey] = {
                            result = hasAccessItem,
                            timestamp = currentTime
                        }
                    end

                    if hasAccessItem or fraction == 'admin' then
                        DrawText3D(doorCoords.x, doorCoords.y, doorCoords.z, text)
                        if IsControlJustPressed(1, 38) then
                            changeDoorState()
                        end
                    end
                end
            end
        end

        -- Clean up cache periodically
        if currentTime - lastCleanup >= cacheCleanupInterval then
            cleanUpCache()
            lastCleanup = currentTime
        end

        Wait(sleep)
    end
end)

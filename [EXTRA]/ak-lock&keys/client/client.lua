local ownedPlates = {}
local characterId = nil
local Result = nil
local NUI_status = false

-- Function to check if the vehicle is owned by the player
local function isVehicleOwnedByPlayer(plate)
    for _, ownedPlate in ipairs(ownedPlates) do
        if ownedPlate == plate then
            return true
        end
    end
    return false
end

function QuickVehicleHorn(vehicle, num)
    for i = 1, num do
        local timer = GetGameTimer()
        while GetGameTimer() - timer < 50 do
            SoundVehicleHornThisFrame(vehicle)
            Citizen.Wait(0)
        end
        Citizen.Wait(50)
    end
end

function PlayKeyAnim(vehicle)
    local playerPed = GetPlayerPed(-1)
    if playerPed and not IsEntityDead(playerPed) and not IsPedInAnyVehicle(playerPed) then
        local modelHash = GetHashKey("p_car_keys_01")
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(0)
        end
        local keyObject = CreateObject(modelHash, GetEntityCoords(playerPed), true, true, true)
        AttachEntityToEntity(keyObject, playerPed, GetPedBoneIndex(playerPed, 57005), 0.09, 0.03, -0.02, -76.0, 13.0,
            28.0, false, true, true, true, 0, true)
        SetModelAsNoLongerNeeded(modelHash)
        ClearPedTasks(playerPed)
        SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
        TaskTurnPedToFaceEntity(playerPed, vehicle, 500)
        local animDict = "anim@mp_player_intmenu@key_fob@"
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Citizen.Wait(0)
        end
        TaskPlayAnim(playerPed, animDict, "fob_click", 3.0, 1000, 51)
        PlaySoundFromEntity(-1, "Remote_Control_Fob", playerPed, "PI_Menu_Sounds", true, 0)
        Wait(1250)
        DetachEntity(keyObject, true, true)
        DeleteObject(keyObject)
        RemoveAnimDict(animDict)
        ClearPedTasksImmediately(playerPed)
    end
end

function StartLockPickCircle(circles, seconds, callback)
    Result = nil
    print(circles, "This be the lock")
    NUI_status = true
    SendNUIMessage({
        type = "startLockpick",
        value = circles,
        time = seconds,
    })
    while NUI_status do
        Wait(5)
        SetNuiFocus(NUI_status, true)
    end
    Wait(1000)
    SetNuiFocus(false, false)
    lockpickCallback = callback
    return Result
end

function ToggleVehicleLock(vehicle)
    local locked = GetVehicleDoorLockStatus(vehicle) ~= 0

    if not locked then
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleDoorsLockedForAllPlayers(veh, false)
        QuickVehicleHorn(vehicle, 2)
    else
        SetVehicleDoorsLocked(vehicle, 0)
        SetVehicleDoorsLockedForAllPlayers(veh, true)
        QuickVehicleHorn(vehicle, 1)
    end
end

RegisterNUICallback('fail', function()
    ClearPedTasks(PlayerPedId())
    Result = false
    Wait(100)
    NUI_status = false
end)

RegisterNUICallback('success', function()
    Result = true
    Wait(100)
    NUI_status = false
    SetNuiFocus(false, false)
    print(Result)
    return Result
end)


RegisterKeyMapping('togglecarlock', 'Lock/Unlock car', 'keyboard', 'L')
RegisterCommand('togglecarlock', function()
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)

    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local plate = GetVehicleNumberPlateText(vehicle)

        if isVehicleOwnedByPlayer(plate) then
            ToggleVehicleLock(vehicle)
        end
    else
        local vehicle = GetClosestVehicle(playerPos, 5.0, 0, 70)

        if DoesEntityExist(vehicle) then
            local vehiclePos = GetEntityCoords(vehicle)
            local distance = #(vehiclePos - playerPos)

            if distance < 2.0 then
                local plate = GetVehicleNumberPlateText(vehicle)

                if isVehicleOwnedByPlayer(plate) then
                    PlayKeyAnim(vehicle)
                    ToggleVehicleLock(vehicle)
                end
            end
        end
    end
end, false)

-- Event to receive owned vehicle plates from the server
RegisterNetEvent('ak-carlock:receiveOwnedVehicles', function(plates)
    ownedPlates = plates
end)

-- Event to receive to add car keys
RegisterNetEvent('ak-carlock:addCarPlate', function(plates)
    table.insert(ownedPlates, plates)
end)

-- Event to receive to remove car keys
RegisterNetEvent('ak-carlock:removeCarPlate', function(plates)
    table.remove(ownedPlates, plates)
end)

CreateThread(function()
    while true do
        Wait(1500)
        characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
        if characterId then
            TriggerServerEvent('ak-carlock:fetchOwnedVehicles', characterId)
            break
        end
    end
end)

-- Monitor if the player is trying to start the engine
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Run every frame

        local playerPed = GetPlayerPed(-1)
        if IsPedInAnyVehicle(playerPed, false) then -- If the player is in a vehicle
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            local plate = GetVehicleNumberPlateText(vehicle)
            -- SetVehicleNeedsToBeHotwired(vehicle, false)

            local EngineOn = GetIsVehicleEngineRunning(vehicle)
            local speed = GetEntitySpeed(vehicle) * 3.6 -- Convert m/s to km/h
            if speed < 10 then
                if not EngineOn then
                    local playerOwned = isVehicleOwnedByPlayer(plate)
                    if not playerOwned then
                        SetVehicleEngineOn(vehicle, false, true, true)
                        Citizen.Wait(2000)
                    end
                end
            end
        end
    end
end)


function GetAllOwnedVehiclePlate()
    return ownedPlates
end

exports('GetAllOwnedVehiclePlate', GetAllOwnedVehiclePlate)
exports('StartLockPickCircle', StartLockPickCircle)

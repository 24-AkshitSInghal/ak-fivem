_g = {
    clientCallbacks   = {},
    parkingVehicles   = {},
    currentCallbackId = 0,
}

Citizen.CreateThread(function()
    for mName, mData in pairs(Config.parking) do
        if mData.showBlip then
            mData.blipHandle = AddBlipForCoord(mData.pos)
            SetBlipSprite(mData.blipHandle, mData.blipSprite)
            SetBlipColour(mData.blipHandle, mData.blipColor)
            SetBlipScale(mData.blipHandle, 1.0)
            SetBlipAsShortRange(mData.blipHandle, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(mData.name)
            EndTextCommandSetBlipName(mData.blipHandle)
        end
    end
end)

local function DrawText3D(x, y, z, text)
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

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function InitCommands()
    RegisterCommand("findvehicle", function(source, args, rawCommand)
        local plate = table.concat(args, ' ')
        if plate then
            FindVehicle(plate)
        else
            drawNativeNotification("No vehicle found with this plate")
        end
    end, false)
end

function CreateParkingCar(payload)
    if not payload.props then return false end
    local model = (type(payload.props.model) == 'number' and payload.props.model or GetHashKey(payload.props.model))
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(model, payload.position, 0.0, false, false)
    SetEntityCoordsNoOffset(vehicle, payload.position)
    SetEntityRotation(vehicle, payload.rotation, 2, true)
    SetVehicleOnGroundProperly(vehicle)
    if Config.lockedCar or payload.owner ~= _g.identifier then
        SetVehicleDoorsLocked(vehicle, 2)
        SetVehicleDoorsLockedForAllPlayers(vehicle, true)
        SetVehicleUndriveable(vehicle, true)
    end
    SetVehicleProperties(vehicle, payload.props)
    SetVehicleEngineOn(vehicle, false, false, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(vehicle, true)
    FreezeEntityPosition(vehicle, true)
    if payload.data then
        SetVehicleExtraData(vehicle, payload.data)
    end
    return vehicle
end

function ProcessParking()
    local playerPed   = GetPlayerPed(-1)
    local playerCrd   = GetEntityCoords(playerPed)
    _g.isOnVehicle    = IsPedInAnyVehicle(playerPed, false)
    _g.driveVehicle   = _g.isOnVehicle and GetVehiclePedIsIn(playerPed, false) or nil
    _g.isEngineOn     = _g.isOnVehicle and GetIsVehicleEngineRunning(_g.driveVehicle) or false
    _g.isParkingCar   = _g.isOnVehicle and IsParkingVehicle(_g.driveVehicle) or false
    _g.parkingCar     = _g.isParkingCar and GetCurrentParkingCar() or nil

    local findParking = false
    for id, parking in pairs(Config.parking) do
        local distance = #(playerCrd - parking.pos)
        if distance <= Config.vehicleRenderDistance then
            _g.currentParking = id
            findParking = true
            break
        end
    end
    if not findParking then
        _g.currentParking = nil

        Wait(1000)
    end

    playerPed, playerCrd = nil, nil
end

function ProcessCarLoading()
    _g.closeVehicle = nil
    if _g.parkingVehicles then
        local parkingName = _g.currentParking
        if parkingName then
            local playerPed = GetPlayerPed(-1)
            local playerCrd = GetEntityCoords(playerPed)
            local vehicles  = _g.parkingVehicles[parkingName] or {}
            for plate, vehicle in pairs(vehicles) do
                local distance = #(playerCrd - vehicle.position)
                if distance <= Config.vehicleRenderDistance then
                    if not vehicle.entity or not DoesEntityExist(vehicle.entity) then
                        vehicle.entity = CreateParkingCar(vehicle)
                        DebugPrint("Creating vehicle for " .. vehicle.plate .. " result " .. tostring(vehicle.entity))
                        Wait(200)
                    else
                        SetEntityCoordsNoOffset(vehicle.entity, vehicle.position)
                        SetEntityRotation(vehicle.entity, vehicle.rotation, 2, true)
                    end
                else
                    if vehicle.entity then
                        DeleteEntity(vehicle.entity)
                        vehicle.entity = nil
                    end
                end
                if distance < 3 then
                    _g.closeVehicle = vehicle
                end
            end
        else
            for parkingName, vehicles in pairs(_g.parkingVehicles) do
                for plate, vehicle in pairs(vehicles) do
                    if vehicle.entity then
                        DebugPrint("Deleting vehicle for " .. vehicle.plate)
                        DeleteEntity(vehicle.entity)
                        vehicle.entity = nil
                    end
                end
            end
        end
        parkingName, playerPed, playerCrd, vehicles, distance = nil, nil, nil, nil, nil
    end
end

function ParkingAction(parkingName, vehicle)
    local playerPed = GetPlayerPed(-1)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

    if not IsParkingVehicle(vehicle) then
        if not Config.stopEngine or not GetIsVehicleEngineRunning(vehicle) then
            if GetEntitySpeed(vehicle) < 1 then
                if IsPedInAnyVehicle(playerPed, false) then
                    TaskLeaveAnyVehicle(playerPed, 0, 0)
                end
                Citizen.Wait(1800)
                local payload = {
                    model    = GetEntityModel(vehicle),
                    class    = GetVehicleClass(vehicle),
                    plate    = GetVehicleNumberPlateText(vehicle),
                    props    = GetVehicleProperties(vehicle),
                    position = GetEntityCoords(vehicle),
                    rotation = GetEntityRotation(vehicle, 2),
                    data     = GetVehicleExtraData(vehicle),
                    parking  = parkingName,
                }
                FreezeEntityPosition(vehicle, true)
                TriggerServerCallback('zerodream_parking:saveVehicle', function(result)
                    _g.requestPending = false
                    SendNotification(result.message)
                    if result.success then
                        FreezeEntityPosition(vehicle, true)
                        SetEntityCompletelyDisableCollision(vehicle, true, false)
                        Wait(500)
                        if _g.parkingVehicles[parkingName] and _g.parkingVehicles[parkingName][payload.plate] then
                            local parkingTemp = _g.parkingVehicles[parkingName][payload.plate]
                            if parkingTemp.entity and DoesEntityExist(parkingTemp.entity) then
                                CopyVehicleDamages(vehicle, parkingTemp.entity)
                            end
                        end
                        Wait(100)
                        DeleteEntity(vehicle)
                    else
                        FreezeEntityPosition(vehicle, false)
                    end
                end, payload, characterId)
            else
                _g.requestPending = false
                SendNotification(_U('VEHICLE_IS_MOVING'))
            end
        else
            _g.requestPending = false
            SendNotification(_U('STOP_ENGINE_FIRST'))
        end
    else
        TriggerServerCallback('zerodream_parking:driveOutVehicle', function(result)
            _g.requestPending = false
            if result.success then
                while not NetworkGetEntityIsNetworked(vehicle) do
                    NetworkRegisterEntityAsNetworked(vehicle)
                    Citizen.Wait(100)
                end
                FreezeEntityPosition(vehicle, false)
                SetEntityInvincible(vehicle, false)
                SetVehicleDoorsLocked(vehicle, 0)
                SetVehicleDoorsLockedForAllPlayers(vehicle, false)
                SetVehicleUndriveable(vehicle, false)
                SetVehicleHasBeenOwnedByPlayer(vehicle, PlayerPedId())
                SetEntityAsMissionEntity(vehicle, true, false)
                _g.ignoreEntity = NetworkGetNetworkIdFromEntity(vehicle)
                TriggerLatentServerEvent('zerodream_parking:syncDamage', 1024000, _g.ignoreEntity,
                    GetVehicleDamageData(vehicle))
            end
            SendNotification(result.message)
        end, GetVehicleNumberPlateText(vehicle), characterId)
    end
end

function ParkingVehicle()
    if _g.requestPending then
        return
    end

    _g.requestPending = true
    local playerPed = GetPlayerPed(-1)
    local playerCrd = GetEntityCoords(playerPed)

    if _g.currentParking then
        local parking = Config.parking[_g.currentParking]
        local PlayerId = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(PlayerId)
        local coords = GetEntityCoords(vehicle)

        local distance = #(coords - parking.pos)

        if distance <= parking.size then
            local parkingName = _g.currentParking
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                if DoesEntityExist(vehicle) then
                    ParkingAction(parkingName, vehicle)
                end
            -- else
            --     local closeVeh = GetClosestVehicle(playerCrd.x, playerCrd.y, playerCrd.z, 3.0, 0, 127)
            --     if closeVeh and DoesEntityExist(closeVeh) then
            --         _g.ignoreRemove = closeVeh
            --         PlayKeyAnim(closeVeh)
            --         QuickVehicleHorn(closeVeh, 2)
            --         ParkingAction(parkingName, closeVeh)
            --     else
            --         _g.requestPending = false
            --     end
            end
        end
    else
        _g.requestPending = false
    end
end

function FindVehicle(plate)
    TriggerServerCallback('zerodream_parking:findVehicle', function(result)
        if result.success then
            SetNewWaypoint(result.data.x, result.data.y)
        end
        SendNotification(result.message)
    end, plate)
end

RegisterNetEvent('zerodream_parking:syncParkingVehicles', function(serverTime, vehicles)
    DebugPrint('Received parking vehicles list')
    _g.reciveTime = GetGameTimer()
    _g.serverTime = serverTime
    _g.parkingVehicles = vehicles
end)


RegisterNetEvent('zerodream_parking:addParkingVehicle', function(parking, plate, data)
    if not _g.parkingVehicles[parking] then
        _g.parkingVehicles[parking] = {}
    end
    _g.parkingVehicles[parking][plate] = data
end)


RegisterNetEvent('zerodream_parking:removeParkingVehicle', function(parking, plate)
    if _g.parkingVehicles[parking] then
        local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
        if not DoesEntityExist(vehicle) or GetVehicleNumberPlateText(vehicle) ~= plate then
            if _g.parkingVehicles[parking][plate] and _g.parkingVehicles[parking][plate].entity then
                if not _g.ignoreRemove or _g.ignoreRemove ~= _g.parkingVehicles[parking][plate].entity then
                    DeleteEntity(_g.parkingVehicles[parking][plate].entity)
                    _g.ignoreRemove = nil
                end
            end
        end
        _g.parkingVehicles[parking][plate] = nil
    end
end)

RegisterNetEvent('zerodream_parking:syncDamage', function(vehicle, damageData)
    if _g.ignoreEntity and _g.ignoreEntity == vehicle then
        _g.ignoreEntity = nil
        return
    end
    vehicle = NetworkGetEntityFromNetworkId(vehicle)
    if DoesEntityExist(vehicle) then
        SetVehicleDamageData(vehicle, damageData)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if _g.parkingVehicles then
            for _, vehicles in pairs(_g.parkingVehicles) do
                for _, vehicle in pairs(vehicles) do
                    if vehicle.entity then
                        DeleteEntity(vehicle.entity)
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    -- Wait for 1 second
    Wait(1000)

    -- Wait for the game to be ready
    DebugPrint('Waiting for game load...')
    while not IsGameReady() do
        Wait(0)
    end

    -- Load player data
    DebugPrint('Loading player data...')
    TriggerServerCallback('zerodream_parking:getPlayerData', function(data)
        _g.identifier = data.identifier
    end)

    -- Wait for data load
    while not _g.identifier do
        Wait(0)
    end

    -- Initialize commands
    DebugPrint('Initializing commands...')
    InitCommands()

    -- Notify server that client is ready
    DebugPrint('Client is ready!')
    TriggerServerEvent('zerodream_parking:ready')

    -- Enter main loop
    while true do
        Wait(500)
        ProcessParking()
        ProcessCarLoading()
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if _g.currentParking then
            if _g.isOnVehicle then
                if not _g.isParkingCar then
                    local parking = Config.parking[_g.currentParking]
                    if parking.notify then
                        local PlayerId = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(PlayerId)
                        local coords = GetEntityCoords(vehicle)

                        local distance = #(coords - parking.pos)
                        if distance <= parking.size and GetPedInVehicleSeat(vehicle, -1) == PlayerId then
                            if not _g.isEngineOn then
                                DrawText3D(coords.x, coords.y, coords.z,
                                    "Press ~y~[P]~w~ to Park Vehicle in ~y~" .. parking.name)

                                if IsDisabledControlJustReleased(0, 199) then
                                    ParkingVehicle()
                                end
                            else
                                DrawText3D(coords.x, coords.y, coords.z, "Turn the ~y~engine off~w~ to park")
                            end
                        end
                    end
                else
                    local parkFees = GetParkingFeeByCar(_g.parkingCar)
                    local PlayerId = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(PlayerId)
                    local coords = GetEntityCoords(vehicle)

                    if parkFees > 0 then
                        DrawText3D(coords.x, coords.y, coords.z, "Press ~y~[P]~w~ to pay")
                        drawNativeNotification("~y~Lenny Parky~w~: your total parking price is ~g~$" .. parkFees)
                        if IsDisabledControlJustReleased(0, 199) then
                            ParkingVehicle()
                        end
                    end
                end
            end
        else
            Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        collectgarbage("collect")
        Wait(60000)
    end
end)

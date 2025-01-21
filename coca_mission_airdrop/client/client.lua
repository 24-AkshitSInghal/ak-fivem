local PlaneSpawnsCoords = {
    { x = 4914.334,  y = 3551.220,  z = 1000.719 },
    { x = 4362.331,  y = 1883.537,  z = 1000.719 },
    { x = 4178.330,  y = -1322.256, z = 1000.719 },
    { x = 3048.685,  y = -2752.134, z = 1000.719 },
    { x = 1186.052,  y = -4040.244, z = 1000.719 },
    { x = -1872.587, y = -4052.439, z = 1000.719 },
    { x = -4266.108, y = -2497.561, z = 1000.719 },
    { x = -4266.108, y = -2497.561, z = 1000.719 },
    { x = -5499.819, y = 1810.366,  z = 1000.719 },
    { x = -4837.717, y = 5603.049,  z = 1000.719 },
}

IsDropStarted = GlobalState.isMissionStarted
local flareGunHash = GetHashKey("WEAPON_FLAREGUN")
Timer = false

local function DrawText3D(x, y, z, text)
    SetTextScale(0.5, 0.5)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent("coca_mission_airdrop:cl_started", function(state)
    IsDropStarted = state
end)

RegisterNetEvent("coca_mission_airdrop:cl_ended", function(state)
    IsDropStarted = state
    Timer = false
end)

RegisterNetEvent("coca_mission_airdrop:cl_requestState", function(state)
    IsDropStarted = state
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    TriggerServerEvent('coca_mission_airdrop:requestState')
end)

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end




function IsFlareGunEquipped()
    local currentWeapon = GetSelectedPedWeapon(PlayerPedId())
    return currentWeapon == flareGunHash
end

local function getClosestCoord(playerCoords, coordsList)
    local closestDistance = math.huge
    local closestCoord = nil

    for _, coord in ipairs(coordsList) do
        local distance = math.sqrt(
            (coord.x - playerCoords.x) ^ 2 +
            (coord.y - playerCoords.y) ^ 2 +
            (coord.z - playerCoords.z) ^ 2
        )

        if distance < closestDistance then
            closestDistance = distance
            closestCoord = coord
        end
    end

    return closestCoord
end

function LoadModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(25)
    end
end

RegisterCommand("shootflare", function()
    local playerPed = PlayerPedId()

    if Timer or IsDropStarted then
        drawNativeNotification("~o~Operator~s~ at Air base is Busy. Please Wait!")
        return
    end

    if IsFlareGunEquipped() then
        if IsDropStarted then
            drawNativeNotification("~o~Operator~s~ at Air base is Busy. Please Wait!")
            return
        end

        drawNativeNotification("Shoot the ~b~flare gun~s~ in the sky to call the ~y~Air drop~s~!")
        Timer = true;
        SetCurrentPedWeapon(playerPed, flareGunHash, true)
        Wait(500)
        SetPlayerCanDoDriveBy(PlayerId(), true)

        local startTime = GetGameTimer()
        while true do
            Wait(0)
            if IsPedShooting(playerPed) and IsFlareGunEquipped() then
                if IsDropStarted then
                    drawNativeNotification("~o~Operator~s~ at Air base is Busy. Please Wait!")
                    return
                end

                local pitch = GetGameplayCamRelativePitch()

                if pitch >= 75 and pitch <= 90 then
                    if IsDropStarted then
                        drawNativeNotification("~o~Operator~s~ at Air base is Busy. Please Wait!")
                        return
                    end
                    TriggerServerEvent("coca_mission_airdrop:started")
                    SpawnPlane()
                else
                    TriggerEvent('chat:addMessage', {
                        color = { 255, 0, 0 },
                        multiline = true,
                        args = { "Air Base", "Unable to receive your flare gun shot for airdrop." }
                    })
                end
                break
            elseif GetGameTimer() - startTime >= 15000 then
                Timer = false;
                drawNativeNotification("You didn't shoot the ~b~flare gun~s~ in time!")
                break
            end
        end
    else
        Timer = false;
        drawNativeNotification("You need to equip a ~b~flare gun~s~!")
    end
end)

function SpawnPlane()
    local planeModel = GetHashKey("bombushka")
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local pilotModel = GetHashKey("s_m_m_pilot_01")
    local closestCoord = getClosestCoord(playerCoords, PlaneSpawnsCoords)

    LoadModel(planeModel)

    LoadModel(pilotModel)

    local rad = GetRandomFloatInRange(-3.14, 3.14)
    local heading = rad * 57.2958 - 90

    AirPlane = CreateVehicle(planeModel, closestCoord.x, closestCoord.y, closestCoord.z, heading, true, false)
    SetVehicleEngineOn(AirPlane, true, true, true)
    SetEntityProofs(AirPlane, true, true, true, true, true, true, true, false)
    SetVehicleHasBeenOwnedByPlayer(AirPlane, true)
    Pilot = CreatePedInsideVehicle(AirPlane, 6, pilotModel, -1, true, false)
    SetBlockingOfNonTemporaryEvents(Pilot, true)

    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "Air Base", "Agent Zero, Flare signal received. Proceeding as planned, over." }
    })

    Wait(10000)

    TriggerEvent('chat:addMessage', {
        color = { 255, 215, 0 },
        multiline = true,
        args = { "Pilot", "Alpha 69, cargo is loading. Will notify when ready for departure, over." }
    })

    Wait(30000)

    TriggerEvent('chat:addMessage', {
        color = { 255, 215, 0 },
        multiline = true,
        args = { "Pilot", "Alpha 69, cargo loaded and ready at base. Awaiting air clearance, over." }
    })

    Wait(30000)

    TaskPlaneMission(Pilot, AirPlane, 0, 0, playerCoords.x, playerCoords.y, playerCoords.z + 250, 4,
        GetVehicleModelMaxSpeed(planeModel),
        1.0,
        0.0, 2000, 50)

    ControlLandingGear(AirPlane, 3)
    local targetCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z + 250)
    local prevDistance = 9999999

    TriggerEvent('chat:addMessage', {
        color = { 255, 215, 0 },
        multiline = true,
        args = { "Pilot", "Alpha 69, plane started and taking off. Heading to target coordinates, over." }
    })

    while true do
        Wait(1000)

        local planeCoords = GetEntityCoords(AirPlane)
        local distanceToTarget = #(planeCoords - targetCoords)
        print(distanceToTarget)
        if (prevDistance < distanceToTarget) then
            TriggerEvent('chat:addMessage', {
                color = { 255, 215, 0 },
                multiline = true,
                args = { "Pilot", "Alpha 69, unable to reach coordinates, taking another round. Requesting stay connected, over." }
            })
        end

        prevDistance = distanceToTarget

        if distanceToTarget < 50 then
            Wait(1000)
            TriggerEvent('chat:addMessage', {
                color = { 255, 215, 0 },
                multiline = true,
                args = { "Pilot", "Alpha 69, cargo dropped at target coordinates. Returning to base, over." }
            })
            TaskPlaneMission(Pilot, AirPlane, 0, 0, 7999.2313, 3746.341, 1000.23, 4,
                GetVehicleModelMaxSpeed(planeModel),
                1.0,
                0.0, 2000.0, 300.0)
            break
        end
    end
    DropCrate(playerCoords)
    SetModelAsNoLongerNeeded(planeModel)
    SetModelAsNoLongerNeeded(pilotModel)
end

local isDropBeingOpened = false
local dropEntity = nil

function DropCrate(dropCoodrs)
    local pos = vector3(dropCoodrs.x, dropCoodrs.y, dropCoodrs.z + 200)
    local ground = vector3(dropCoodrs.x, dropCoodrs.y, dropCoodrs.z - 100)
    local dropModel = GetHashKey('prop_drop_crate_01_set2')
    local weaponModel = GetHashKey("weapon_flare")

    RequestWeaponAsset(weaponModel)
    while not HasWeaponAssetLoaded(weaponModel) do
        Wait(0)
    end

    LoadModel(dropModel)

    ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z, ground.x, ground.y, ground.z, 0, false,
        weaponModel, 0, true, true, -1.0)
    ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z, ground.x, ground.y, ground.z, 0, false,
        weaponModel, 0, true, true, -1.0)
    ShootSingleBulletBetweenCoords(pos.x, pos.y, pos.z, ground.x, ground.y, ground.z, 0, false,
        weaponModel, 0, true, true, -1.0)

    local drop = CreateObject(dropModel, pos.x, pos.y, pos.z, true, true, true)
    SetEntityLodDist(drop, 1000)

    ActivatePhysics(drop)
    SetObjectPhysicsParams(drop, 9999999.0, 100, 0.0, 0.0, 0.0, 700.0, 0.0, 0.0, 0.0, 1, 0.0)
    SetDamping(drop, 2, 0.1)

    local downwardVelocity = -5.0
    SetEntityVelocity(drop, 0.0, 0.0, downwardVelocity)
    Wait(25000)
    dropEntity = drop

    TriggerServerEvent("coca_mission_airdrop:ended", dropCoodrs, dropEntity)

    SetModelAsNoLongerNeeded(dropModel)
end

RegisterNetEvent('coca_mission_airdrop:notifyAllPlayers', function(coords, Entity)
    dropEntity = Entity
    isDropBeingOpened = false
    OpenDrop(coords)
end)

function OpenDrop(coords)
    while true do
        local sleep = 1500
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local dropCoords = coords
        local distance = #(playerCoords - dropCoords)
        if not isDropBeingOpened  then
            print(distance)
            if(distance < 5.0) then
                sleep = 10
                DrawText3D(dropCoords.x, dropCoords.y, dropCoords.z, "Press ~o~[E]~s~ to open the drop crate.")
                if distance < 2.0 and IsControlJustPressed(1, 51) then 
                    isDropBeingOpened = true
                    TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
                    Citizen.Wait(10000)
                    ClearPedTasksImmediately(playerPed)
                    TriggerServerEvent('coca_mission_airdrop:openCrate', dropEntity)
                end
            end
        else
            break
        end
        Citizen.Wait(sleep)
    end
end

RegisterNetEvent('coca_mission_airdrop:openCrate', function()
    if DoesEntityExist(dropEntity) then
        DeleteObject(dropEntity)
        dropEntity = nil
        isDropBeingOpened = false
    end
end)

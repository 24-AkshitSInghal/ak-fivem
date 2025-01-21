local carry = {
    InProgress = false,
    targetSrc = -1,
    type = "",
    personCarrying = {
        animDict = "missfinale_c2mcs_1",
        anim = "fin_c2_mcs_1_camman",
        flag = 49,
    },
    personCarried = {
        animDict = "nm",
        anim = "firemans_carry",
        attachX = 0.27,
        attachY = 0.15,
        attachZ = 0.63,
        flag = 33,
    }
}

function CheckInProgress()
    return carry.InProgress
end

exports('carryinprogress', CheckInProgress)

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function GetClosestPlayer(radius)
    local targets = GetActivePlayers()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = -1
    local closestDistance = 2

    for _, targetId in ipairs(targets) do
        local targetPed = GetPlayerPed(targetId)
        if targetPed ~= playerPed then
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(targetCoords - playerCoords)
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = targetId
                closestDistance = distance
            end
        end
    end
    if closestDistance ~= -1 and closestDistance <= radius then
        return closestPlayer
    else
        return nil
    end
end

local function ensureAnimDict(animDict)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    return animDict
end

RegisterCommand("carry", function(source, args)
    local playerPed = PlayerPedId()

    if carry.type == "beingcarried" then
        return
    end

    if IsPedInAnyVehicle(playerPed, true) or IsEntityPositionFrozen(playerPed) then
        drawNativeNotification("You can\'t ~r~carry~s~ this person!")
        return
    end

    if not carry.InProgress then
        local closestPlayer = GetClosestPlayer(1)
        if closestPlayer then
            local targetPed = GetPlayerPed(closestPlayer)
            local targetSrc = GetPlayerServerId(closestPlayer)

            print("target GetPlayerPed -> ", targetPed, "target GetPlayerServerId -> ", targetSrc, "player PlayerPedId",
                playerPed)

            if IsEntityPositionFrozen(targetPed) then
                drawNativeNotification("You can\'t ~r~carry~s~ this person!")
                return
            end

            if targetSrc ~= -1 then
                carry.InProgress = true
                carry.targetSrc = targetSrc
                TriggerServerEvent("coca_playercarry:sync", targetSrc)
                ensureAnimDict(carry.personCarrying.animDict)
                carry.type = "carrying"
            else
                drawNativeNotification("No one nearby to ~r~carry~s~!")
            end
        else
            drawNativeNotification("No one nearby to ~r~carry~~!")
        end
    else
        carry.InProgress = false
        ClearPedSecondaryTask(PlayerPedId())
        DetachEntity(PlayerPedId(), true, false)
        TriggerServerEvent("coca_playercarry:stop", carry.targetSrc)
        carry.targetSrc = 0
        carry.type = ""
    end
end, false)

TargetPed = ""

RegisterNetEvent("coca_playercarry:syncTarget", function(targetSrc)
    TargetPed = GetPlayerPed(GetPlayerFromServerId(targetSrc))
    carry.InProgress = true
    ensureAnimDict(carry.personCarried.animDict)
    AttachEntityToEntity(PlayerPedId(), TargetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY,
        carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
    carry.type = "beingcarried"
end)

RegisterNetEvent("coca_playercarry:cl_stop", function()
    carry.InProgress = false
    carry.type = ""
    carry.targetSrc = 0
    ClearPedSecondaryTask(PlayerPedId())
    DetachEntity(PlayerPedId(), true, false)
end)

CreateThread(function()
    while true do
        if carry.InProgress then
            if carry.type == "beingcarried" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000,
                        carry.personCarried.flag, 0, false, false, false)
                end

                if GetVehiclePedIsTryingToEnter(PlayerPedId()) then
                    AttachEntityToEntity(PlayerPedId(), TargetPed, 0, carry.personCarried.attachX,
                        carry.personCarried.attachY,
                        carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)
                end
            elseif carry.type == "carrying" then
                if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 3) then
                    TaskPlayAnim(PlayerPedId(), carry.personCarrying.animDict, carry.personCarrying.anim, 8.0, -8.0,
                        100000, carry.personCarrying.flag, 0, false, false, false)
                end
            end
        end
        Wait(100)
    end
end)

-- Check is player is carrying someone and try to enter car
RegisterKeyMapping('getInCar', 'Enter Vehicle', 'keyboard', 'F')

RegisterCommand('getInCar', function()
    local playerPed = PlayerPedId()
    local vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 5.0, 0, 70)

    if carry.type == "beingcarried" then
        AttachEntityToEntity(PlayerPedId(), TargetPed, 0, carry.personCarried.attachX, carry.personCarried.attachY,
            carry.personCarried.attachZ, 0.5, 0.5, 180, false, false, false, false, 2, false)

        if not IsEntityPlayingAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 3) then
            TaskPlayAnim(PlayerPedId(), carry.personCarried.animDict, carry.personCarried.anim, 8.0, -8.0, 100000,
                carry.personCarried.flag, 0, false, false, false)
        end
    end


    if carry.InProgress and GetVehiclePedIsTryingToEnter(playerPed) then
        TaskLeaveVehicle(
            playerPed,
            vehicle,
            1
        )
        drawNativeNotification("You cannot ~r~enter~s~ a car right now!");
    end
end)

-- function getVehicleInDirection(coordFrom, coordTo)
--     local rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10,
--         GetPlayerPed(-1), 0)
--     local a, b, c, d, vehicle = GetRaycastResult(rayHandle)
--     return vehicle
-- end

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(0)
--         if carry.type == "carrying" and IsControlJustReleased(0, 166) then -- F5 key
--             local playerPed = PlayerPedId()
--             local coordA = GetEntityCoords(playerPed, true)
--             local coordB = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 5.0, 0.0)
--             local veh = getVehicleInDirection(coordA, coordB)
--             if DoesEntityExist(veh) then
--                 if IsEntityDead(carry.targetSrc) then
--                     drawNativeNotification("You can put him in vehicle while player is dead")
--                 else
--                     carry.InProgress = false
--                     ClearPedSecondaryTask(playerPed)
--                     DetachEntity(playerPed, true, false)
--                     TriggerServerEvent("coca_playercarry:stop", carry.targetSrc)

--                     local vehNetId = NetworkGetNetworkIdFromEntity(veh)
--                     TriggerServerEvent("coca_playercarry:getInCar", vehNetId, carry.targetSrc)

--                     carry.targetSrc = 0
--                     carry.type = ""
--                 end
                
--             end
--         end
--     end
-- end)

-- RegisterNetEvent("coca_playercarry:getInCar", function(vehNetId)
--     local playerPed = PlayerPedId()
--     local veh = NetworkGetEntityFromNetworkId(vehNetId)
 
    
    
--     if DoesEntityExist(veh) then
       
--         local seatFound = false
--         for seat = 2, -1, -1 do
--             print(seat, IsVehicleSeatFree(veh, seat))
--             if IsVehicleSeatFree(veh, seat) then
--                 TaskWarpPedIntoVehicle(playerPed, veh, seat)
--                 seatFound = true
--                 print(seatFound)
--                 break
--             end
--         end
--         if not seatFound then
--             print("No free seat available")
--         end
--     end
-- end)







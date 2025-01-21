local isHookerThreadActive = false
local isUsingHooker = false
local disableVehicleControls = false
local hookerModels = Config.HookerPedModels
local hasPayed = nil
local hookerName = 'Maggie'

local PLAYER_ID = PlayerId()

-- Vehicle controls that will get disabled while interacting with a hooker in your car
local VEHICLE_CONTROLS = {
    [59] = true, -- INPUT_VEH_MOVE_LR
    [60] = true, -- INPUT_VEH_MOVE_UD
    [61] = true, -- INPUT_VEH_MOVE_UP_ONLY
    [62] = true, -- INPUT_VEH_MOVE_DOWN_ONLY
    [63] = true, -- INPUT_VEH_MOVE_LEFT_ONLY
    [64] = true, -- INPUT_VEH_MOVE_RIGHT_ONLY
    [71] = true, -- INPUT_VEH_ACCELERATE
    [72] = true, -- INPUT_VEH_BRAKE
    [73] = true, -- INPUT_VEH_DUCK
    [86] = true  -- INPUT_VEH_HORN
}
-- Utils --

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
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


local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
    end
end

-- This only works with mp peds, everyone else will be male regardless. IsPedMale() returns true regardless, so this is better.
local function GetPedGender(ped)
    if GetEntityModel(ped) == `mp_f_freemode_01` then
        return "female"
    else
        return "male"
    end
end


-- Checkers/Getters Functions --
local function GetNearbyPeds()
    local handle, ped = FindFirstPed()
    local success = false
    local peds = {}
    repeat
        peds[#peds + 1] = ped
        success, ped = FindNextPed(handle)
    until not success
    EndFindPed(handle)
    return peds
end

local function IsPedEligibleHooker(ped)
    local pedModel = GetEntityModel(ped)
    if not hookerModels[pedModel] then
        return false
    end

    if IsPedInjured(ped) then
        return false
    end

    if IsPedWalking(ped) or IsPedRunning(ped) or IsPedSprinting(ped) then
        return false
    end

    if IsPedInAnyVehicle(ped, true) then
        return false
    end

    if IsPedAPlayer(ped) then
        return false
    end

    return true
end


-- add need high class car
local function CanVehiclePickUpHookers(vehicle)
    if not IsVehicleDriveable(vehicle, false) then
        return false
    end

    local class = GetVehicleClass(vehicle)
    if Config.BlackListedVehicleClasses[class] then
        return false
    end

    local model = GetEntityModel(vehicle)
    if Config.BlackListedVehicles[model] then
        return false
    end

    return true
end


-- Audio --
local function PlayHookerSpeach(hooker, speechName, speechParam)
    if not IsAnySpeechPlaying(hooker) then
        PlayPedAmbientSpeechNative(hooker, speechName, speechParam)
    end
end


-- AI Behavior --
local function MakeHookerCalm(hooker)
    local _void, groupHash = AddRelationshipGroup("ProstituteInPlay")
    SetRelationshipBetweenGroups(1, groupHash, `PLAYER`)
    SetPedRelationshipGroupHash(hooker, groupHash)

    SetPedConfigFlag(hooker, 26, true)            -- CPED_CONFIG_FLAG_DontDragMeOutCar
    SetPedConfigFlag(hooker, 115, true)           -- CPED_CONFIG_FLAG_FallOutOfVehicleWhenKilled
    SetPedConfigFlag(hooker, 229, true)           -- CPED_CONFIG_FLAG_DisablePanicInVehicle
    SetBlockingOfNonTemporaryEvents(hooker, true) -- Makes the hooker not react to everything around them
end

local function ResetHookerCalm(hooker)
    SetPedConfigFlag(hooker, 26, false)            -- CPED_CONFIG_FLAG_DontDragMeOutCar
    SetPedConfigFlag(hooker, 115, false)           -- CPED_CONFIG_FLAG_FallOutOfVehicleWhenKilled
    SetPedConfigFlag(hooker, 229, false)           -- CPED_CONFIG_FLAG_DisablePanicInVehicle
    SetBlockingOfNonTemporaryEvents(hooker, false) -- Makes the hooker not react to everything around them
end


-- Other Functions --
local function IsInSecludedArea(hooker, vehicle)
    local vehicleSpeed = GetEntitySpeed(vehicle)
    if vehicleSpeed >= 0.1 then
        return false
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local hasLineOfSight = false
    for _index, ped in pairs(GetNearbyPeds()) do
        if ped ~= playerPed and ped ~= hooker and GetPedType(ped) ~= 28 then
            if HasEntityClearLosToEntity(ped, vehicle, 17) then
                if #(coords - GetEntityCoords(ped)) < 75.0 then
                    hasLineOfSight = true
                end
            end
        end
    end

    if hasLineOfSight then
        return false
    end

    return true
end

local function PlaySexSceneAnim(hooker, playerPed, hookerAnim, playerAnim, flag, wait)
    local animTime = GetAnimDuration("mini@prostitutes@sexnorm_veh", hookerAnim) * 1000
    TaskPlayAnim(hooker, "mini@prostitutes@sexnorm_veh", hookerAnim, 2.0, 2.0, animTime, flag, 0.0, false, false, false)
    TaskPlayAnim(playerPed, "mini@prostitutes@sexnorm_veh", playerAnim, 2.0, 2.0, animTime, flag, 0.0, false, false,
        false)

    if wait then
        Wait(animTime)
    end
end

local function PlaySexScene(scene, hooker, vehicle)
    local playerPed = PlayerPedId()
    local playerGender = GetPedGender(playerPed)
    local timer = 8
    local speach = {}
    local animation = {
        hooker = {},
        player = {}
    }

    speach.param = "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR"

    if scene == "SERVICE_BLOWJOB" then
        if playerGender == "male" then
            speach.name = "SEX_ORAL"
        else
            speach.name = "SEX_ORAL_FEM"
        end

        timer = 4

        -- Hooker anims
        animation.hooker.enter1 = "proposition_to_BJ_p1_prostitute"
        animation.hooker.enter2 = "proposition_to_BJ_p2_prostitute"
        animation.hooker.loop = "BJ_loop_prostitute"
        animation.hooker.exit1 = "BJ_to_proposition_p1_prostitute"
        animation.hooker.exit2 = "BJ_to_proposition_p2_prostitute"

        -- Player anims
        animation.player.enter1 = "proposition_to_BJ_p1_male"
        animation.player.enter2 = "proposition_to_BJ_p2_male"
        animation.player.loop = "BJ_loop_male"
        animation.player.exit1 = "BJ_to_proposition_p1_male"
        animation.player.exit2 = "BJ_to_proposition_p2_male"
    else
        if playerGender == "male" then
            speach.name = "SEX_GENERIC"
        else
            speach.name = "SEX_GENERIC_FEM"
        end

        -- Hooker anims
        animation.hooker.enter1 = "proposition_to_sex_p1_prostitute"
        animation.hooker.enter2 = "proposition_to_sex_p2_prostitute"
        animation.hooker.loop = "sex_loop_prostitute"
        animation.hooker.exit1 = "sex_to_proposition_p1_prostitute"
        animation.hooker.exit2 = "sex_to_proposition_p2_prostitute"

        -- Player anims
        animation.player.enter1 = "proposition_to_sex_p1_male"
        animation.player.enter2 = "proposition_to_sex_p2_male"
        animation.player.loop = "sex_loop_male"
        animation.player.exit1 = "sex_to_proposition_p1_male"
        animation.player.exit2 = "sex_to_proposition_p2_male"
    end

    PlaySexSceneAnim(hooker, playerPed, animation.hooker.enter1, animation.player.enter1, 2, true)
    PlaySexSceneAnim(hooker, playerPed, animation.hooker.enter2, animation.player.enter2, 2, true)

    local loopWait = GetAnimDuration("mini@prostitutes@sexnorm_veh", animation.hooker.loop) * 1000 / 2
    PlaySexSceneAnim(hooker, playerPed, animation.hooker.loop, animation.player.loop, 1, false)

    if scene == "SERVICE_SEX" or scene == "SERVICE_SEX_BACKDOOR" then
        CreateThread(function()
            Wait(250)

            while timer > 0 do
                ApplyForceToEntity(vehicle, 1, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, 0, true, true, true, true, false)
                Wait(780)
            end
        end)
    end

    if service == "SERVICE_BLOWJOB" then
        TriggerEvent("coca_ui_player:RelieveStress", 18)
    elseif service == "SERVICE_SEX_BACKDOOR" then
        TriggerEvent("coca_ui_player:RelieveStress", 85)
    else
        TriggerEvent("coca_ui_player:RelieveStress", 40)
    end

    while timer > 0 do
        if not DoesEntityExist(hooker) then return end

        PlayHookerSpeach(hooker, speach.name, speach.param)
        Wait(loopWait)

        timer = timer - 1
    end

    PlaySexSceneAnim(hooker, playerPed, animation.hooker.exit1, animation.player.exit1, 2, true)
    PlaySexSceneAnim(hooker, playerPed, animation.hooker.exit2, animation.player.exit2, 2, true)
    PlaySexSceneAnim(hooker, playerPed, "proposition_loop_prostitute", "proposition_loop_male", 1, false)
end

local function DisableVehicleControlsLoop()
    while disableVehicleControls do
        for control, state in pairs(VEHICLE_CONTROLS) do
            DisableControlAction(0, control, state)
        end

        Wait(0)
    end
end

local function DisableVehicleControls(state)
    disableVehicleControls = state
    if disableVehicleControls then
        CreateThread(DisableVehicleControlsLoop)
    end
end

local hookerNames = {
    "Sandy",
    "Candy",
    "Roxy",
    "Lola",
    "Daisy",
    "Misty",
    "Bella",
    "Ruby",
    "Maggie"
}

local function GetRandomHookerName()
    math.randomseed(GetGameTimer())
    return hookerNames[math.random(#hookerNames)]
end


-- Threads/Loops --
local function HookerLoop(hooker)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local randomname = GetRandomHookerName()
    hookerName = randomname

    while true do
        if vehicle ~= 0 and #(GetEntityCoords(vehicle) - GetEntityCoords(hooker)) < 7.5 and GetEntitySpeed(vehicle) <= 0.1 then
            if IsPlayerPressingHorn(PLAYER_ID) then
                break
            end
        else
            HookerInteractionCanceled()
            return
        end

        Wait(0)
    end

    isUsingHooker = true

    -- Add relationships and set config flags so the hooker stays calm
    MakeHookerCalm(hooker)

    -- Task the hooker to enter the vehicle
    TaskEnterVehicle(hooker, vehicle, 10000, 0, 1.0, 1, 0)

    -- Wait until the hooker is in the vehicle
    while true do
        local taskState = GetScriptTaskStatus(hooker, "SCRIPT_TASK_ENTER_VEHICLE")
        if taskState == 7 then
            if GetPedInVehicleSeat(vehicle, 0) == hooker then
                break
            else
                HookerInteractionCanceled()
                return
            end
        elseif taskState == 2 then
            HookerInteractionCanceled()
            return
        end

        if not DoesEntityExist(hooker) or IsPedInjured(hooker) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
            HookerInteractionCanceled()
            return
        end

        Wait(100)
    end

    -- Hooker tells player to go to secluded area
    PlayHookerSpeach(hooker, "HOOKER_SECLUDED", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")

    -- Wait until she was finished speaking before we give hint to player
    while IsAnySpeechPlaying(hooker) do
        Wait(100)
    end

    local timeToFindArea = 120 * 1000
    local startTimer = GetGameTimer()
    local endTime = startTimer + timeToFindArea
    local isShowingHint = false
    local shouldAsyncThreadsBreak = false

    -- Wait until we are in a secluded area
    while true do
        Wait(500)

        -- If something wen wrong the cancel
        if not DoesEntityExist(hooker) then
            shouldAsyncThreadsBreak = true
            HookerInteractionCanceled()
            return
        end

        if IsPedInjured(hooker) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
            shouldAsyncThreadsBreak = true
            ResetHookerCalm(hooker)
            HookerInteractionCanceled()
            return
        end

        local isAreaSecluded = IsInSecludedArea(hooker, vehicle)
        if isAreaSecluded then
            shouldAsyncThreadsBreak = true
            break
        end

        -- Check if it has gone more then 3 min since we let her in, if so cancel
        local gameTimer = GetGameTimer()
        if gameTimer > endTime then
            shouldAsyncThreadsBreak = true
            PlayHookerSpeach(hooker, "HOOKER_LEAVES_ANGRY", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
            TaskLeaveVehicle(hooker, vehicle, 0)

            while IsAnySpeechPlaying(hooker) do
                Wait(100)
            end

            drawNativeNotification("~p~"..hookerName.."~w~: You couldn't find a private spot in time, ~p~honey~w~ I have other customers too.")

            ResetHookerCalm(hooker)
            HookerInteractionCanceled()
            return
        end

        -- If not moving, show hint that we should move
        local vehicleSpeed = GetEntitySpeed(vehicle)
        if not isShowingHint and vehicleSpeed <= 0.1 then
            isShowingHint = true

            Wait(500)

            -- Only check if we are in a secluded area every 500ms even when we stand still
            CreateThread(function()
                while true do
                    vehicleSpeed = GetEntitySpeed(vehicle)
                    if vehicleSpeed > 0.1 then
                        shouldAsyncThreadsBreak = true
                        isShowingHint = false
                        break
                    end
                    Wait(500)
                end
            end)

            -- Display the help text
            CreateThread(function()
                while not shouldAsyncThreadsBreak do
                   
                    drawNativeNotification("~p~"..hookerName.."~w~:Let's find a more private spot, ~q~babe~w~." )
                    Wait(5000)
                end
            end)
        end
    end

    SetVehicleLights(vehicle, 1)     -- Turn off vehicle lights
    DisableVehicleControls(true)     -- Disable vehicle movement
    LoadAnimDict("mini@prostitutes@sexnorm_veh")

    Wait(500)
    PlayHookerSpeach(hooker, "HOOKER_OFFER_SERVICE", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
    PlaySexSceneAnim(hooker, PlayerPedId(), "proposition_loop_prostitute", "proposition_loop_male", 1, false)

    while IsAnySpeechPlaying(hooker) do
        Wait(100)
    end

    -- Offer services loop
    local servicesCompleted = 0
    local maxService = math.random(1, 4)
    while true do
        if not DoesEntityExist(hooker) then
            HookerInteractionCanceled()
            DisableVehicleControls(false)
            return
        end

        if IsPedInjured(hooker) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
            break
        end

        if servicesCompleted >= maxService then
            break
        end

        if servicesCompleted > 0 then
            PlayHookerSpeach(hooker, "HOOKER_OFFER_AGAIN", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
        end

        local service = OfferServices()
        if service == "SERVICE_DECLINE" then
            break
        else
            local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
            TriggerServerEvent('coca_nightclub:moneyCheck', service, characterId)


            local startTime = GetGameTimer()

            while hasPayed == nil do
                Wait(100)
                if GetGameTimer() - startTime > 30000 then     -- 30 seconds in milliseconds
                    break
                end
            end

            if not hasPayed or hasPayed == nil then
                hasPayed = nil
                drawNativeNotification("~p~"..hookerName.."~w~:~q~Aww~s~ You can't afford me ~q~babe~w~, next time try ~q~harder~s~!")
                break
            end

            hasPayed = nil
            PlaySexScene(service, hooker, vehicle)
            servicesCompleted = servicesCompleted + 1
        end

        Wait(100)
    end

    if servicesCompleted >= maxService then
        PlayHookerSpeach(hooker, "HOOKER_HAD_ENOUGH", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
        
        drawNativeNotification("~p~"..hookerName.."~w~: Bye ~q~Sweetie~s~, I am tired now" )
    elseif servicesCompleted == 0 then
        PlayHookerSpeach(hooker, "HOOKER_LEAVES_ANGRY", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
       
        drawNativeNotification("~p~"..hookerName.."~w~: ~q~Fuck you~s~, You wasted my time, ~q~Asshole")
    else
        PlayHookerSpeach(hooker, "HOOKER_DECLINED", "SPEECH_PARAMS_FORCE_SHOUTED_CLEAR")
       
        drawNativeNotification("~p~"..hookerName.."~w~: ~q~Goodnight darling~s~")
    end

    ClearPedTasks(hooker)
    ClearPedTasks(PlayerPedId())
    RemoveAnimDict("mini@prostitutes@sexnorm_veh")

    TaskLeaveVehicle(hooker, vehicle, 0)
    DisableVehicleControls(false)

    Wait(2000)
    SetVehicleLights(vehicle, 0)

    -- Reset
    Wait(5000)
    ResetHookerCalm(hooker)
    HookerInteractionCanceled()
end

local function LookingForHookerThread()
    if isUsingHooker then
        return
    end

    isHookerThreadActive = true
    while true do
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if not vehicle then
            break
        end

        local vehicleSpeed = GetEntitySpeed(vehicle)
        if vehicleSpeed <= 0.1 then
            local vehicleCoords = GetEntityCoords(vehicle)

            for _index, ped in pairs(GetNearbyPeds()) do
                if ped == playerPed then
                    goto nextPed
                end

                local dist = #(GetEntityCoords(ped) - vehicleCoords)
                if dist > 7.5 then
                    goto nextPed
                end

                if not IsPedEligibleHooker(ped) then
                    goto nextPed
                end

                if not CanVehiclePickUpHookers(vehicle) then
                    break
                end

                if not IsVehicleSeatFree(vehicle, 0) then
                    break
                end

                HookerLoop(ped)
                ::nextPed::
            end
        end

        Wait(500)
    end
    isHookerThreadActive = false
end

function HookerInteractionCanceled()
    isUsingHooker = false
    isHookerThreadActive = false -- Restart looking for hooker thread
end

-- Events --
CreateThread(function()
    while true do
        Wait(2000)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle and not isHookerThreadActive and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            LookingForHookerThread()
        end
    end
end)


RegisterNetEvent('coca_banking:paymentReturn', function(state)
    hasPayed = state
end)

function OfferServices()
    Wait(1000)
    local serviceSelected = null
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleCoords = GetEntityCoords(vehicle)
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.9, "        ~q~Services Available~w~          ")
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.7, "    Press ~q~[6]~w~ for ~bold~Blow Job    ")
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.56,"    Press ~q~[7]~w~ for ~bold~vanilla Sex ")
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.43,"    Press ~q~[8]~w~ for ~bold~Anal Sex    ")
        DrawText3D(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.30,"    Press ~q~[9]~w~ to Decline Service    ")

        if IsDisabledControlJustReleased(0, 159) then -- Key '6'
            serviceSelected = "SERVICE_BLOWJOB"
            break
        elseif IsDisabledControlJustReleased(0, 161) then -- Key '7'
            serviceSelected = "SERVICE_SEX"
            break
        elseif IsDisabledControlJustReleased(0, 162) then -- Key '8'
            serviceSelected = "SERVICE_SEX_BACKDOOR"
            break
        elseif IsDisabledControlJustReleased(0, 163) then -- Key '9'
            serviceSelected = "SERVICE_DECLINE"
            break
        end
    end
    print("Service Selected: " .. serviceSelected)
    return serviceSelected
end

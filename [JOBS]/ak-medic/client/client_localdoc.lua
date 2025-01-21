local isOnBed = false
local timer = 0
local doctorPed
local currentBedCoords
local shouldDrawMarker = false
local markerCoords

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

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

function ShuffleArray(array)
    for i = #array, 2, -1 do
        local j = math.random(i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

-- Function to find a free bed
function GetFreeBed()
    local shuffledBeds = ShuffleArray(Config.Beds)

    for _, bed in ipairs(shuffledBeds) do
        local isOccupied = IsBedOccupied(bed.Loc)
        if not isOccupied then
            return bed
        end
    end

    return nil
end

function IsBedOccupied(bedLocation)
    local checkRadius = 1.5
    local playerId = PlayerPedId()
    local entities = GetEntitiesWithinRadius(bedLocation, checkRadius)

    for _, entity in ipairs(entities) do
        if IsEntityAPed(entity) then
            if entity ~= playerId and #(GetEntityCoords(entity) - bedLocation) < checkRadius then
                return true
            end
        end
    end

    return false
end

-- Function to get all entities (players and peds) within a radius of a given location
function GetEntitiesWithinRadius(coords, radius)
    local entities = {}

    -- Get all players
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        local playerCoords = GetEntityCoords(playerPed)

        -- Calculate distance between player and coords
        local distance = #(playerCoords - coords)

        if distance <= radius then
            table.insert(entities, playerPed)
        end
    end

    return entities
end

function GetOnTheBed(bed)
    local ped = PlayerPedId()
    isOnBed = true
    SetEntityCoords(ped, bed.Loc + bed.OffSet)
    SetEntityHeading(ped, bed.Heading)
    currentBedCoords = bed.Loc

    RequestAnimDict('anim@gangops@morgue@table@')
    while not HasAnimDictLoaded('anim@gangops@morgue@table@') do
        Wait(10)
    end

    TaskPlayAnim(ped, 'anim@gangops@morgue@table@', 'ko_front', 8.0, -8.0, -1, 1, 0, false, false, false)

    local startTime = GetGameTimer()
    local duration = 30000 -- 7 seconds in milliseconds

    while GetGameTimer() - startTime < duration do
        Citizen.Wait(0)
        local elapsed = GetGameTimer() - startTime
        local percentage = math.floor((elapsed / duration) * 100)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z,
            ("Local Doctor Taking Care of you ~r~%d%%"):format(percentage))
    end

    HealingDone()
end

function HealingDone()
    if currentBedCoords and isOnBed then
        local playerPed = PlayerPedId()
        local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
        if exports.coca_banking:RemoveCash(characterId, 1000) then
            NetworkResurrectLocalPlayer(GetEntityCoords(playerPed, true), true, false)
            Wait(200)
            SetEntityHealth(playerPed, 200)
            drawNativeNotification("~r~Nancy~w~ : You are charged $1000")
            Config.DiscordNotification = false
        else
            NetworkResurrectLocalPlayer(GetEntityCoords(playerPed, true), true, false)
            Wait(200)
            SetEntityHealth(playerPed, 200)
            drawNativeNotification("~r~Nancy~w~ : We treated you with poor people funds")
            Config.DiscordNotification = false
        end
        TriggerEvent("coca_ui_player:IncreaseHungerBar", 25)
        TriggerEvent("coca_ui_player:IncreaseThistBar", 35)
        Wait(500)
        ClearAround()
    end
end

function ClearAround()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    ClearPedSecondaryTask(ped)
    RequestAnimDict('switch@franklin@bed')
    while not HasAnimDictLoaded('switch@franklin@bed') do
        Wait(50)
    end
    SetEntityHeading(ped, GetEntityHeading(ped) + 90.0)
    TaskPlayAnim(ped, 'switch@franklin@bed', 'sleep_getup_rubeyes', -8.0, 8.0, 5000, 0, 0, 0, 0, 0)
    Wait(5000)
    FreezeEntityPosition(ped, false)
    isOnBed = false
    currentBedCoords = nil
    markerCoords = nil
    shouldDrawMarker = false
end

function Discharge()
    ClearAround()
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if shouldDrawMarker then
            DrawMarker(20, markerCoords + vector3(0.0, 0.0, 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 225,
                225,
                0.8, true, true, 2, false, nil, nil, false)
        else
            Wait(1000)
        end
    end
end)

function CreateDoctor()
    Wait(1000)

    RequestModel(`s_m_m_doctor_01`)
    while not HasModelLoaded(`s_m_m_doctor_01`) do
        Wait(10)
    end

    doctorPed = CreatePed(2, `s_m_m_doctor_01`, Config.DoctorPos, 156.0, true, false)
    SetEntityInvincible(doctorPed, true)
    SetBlockingOfNonTemporaryEvents(doctorPed, true)

    while not DoesEntityExist(doctorPed) do
        print('Waiting until the ped is created')
        Wait(10)
    end

    TaskGoStraightToCoord(doctorPed, vector3(315.53173828125, -581.87268066406, 43.284164428711), 0.3, -1, 0.0, 0.0)
    Wait(4000)
    ClearPedTasks(doctorPed)
    Wait(100)
    TaskGoStraightToCoord(doctorPed, GetEntityCoords(PlayerPedId()), 0.3, -1, 0.0, 0.0)
    SetEntityMaxSpeed(doctorPed, 1.0)

    while (#(GetEntityCoords(doctorPed) - GetEntityCoords(PlayerPedId()))) > 2 do
        Wait(50)
    end

    ClearPedTasksImmediately(doctorPed)
    TaskLookAtEntity(doctorPed, PlayerPedId(), 10000, 2048, 3)

    if isOnBed then
        local clipModel = CreateObject(GetHashKey('p_amb_clipboard_01'), GetEntityCoords(doctorPed), true, true, true)
        local penModel = CreateObject(GetHashKey('prop_pencil_01'), GetEntityCoords(doctorPed), true, true, true)

        while not DoesEntityExist(clipModel) or not DoesEntityExist(penModel) do
            Wait(0)
        end

        AttachEntityToEntity(penModel, doctorPed, GetPedBoneIndex(doctorPed, 58866), 0.12, 0.00, 0.001, -150.0, 0.0, 0.0,
            1, 1, 0, 1, 0, 1)
        AttachEntityToEntity(clipModel, doctorPed, GetPedBoneIndex(doctorPed, 18905), 0.10, 0.02, 0.08, -68.0, 0.0, -40.0,
            1, 1, 0, 1, 0, 1)
        TaskPlayAnim(doctorPed, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8.0, 5000, 49, 0, false, false, false)

        Wait(5000)
        ClearPedTasks(doctorPed)
        DeleteObject(clipModel)
        DeleteObject(penModel)
    end

    -- TaskGoStraightToCoord(doctorPed, Config.DoctorPos, 30000, 1.5, 1.0, 1073741824, 0) -- For me the bellow was better

    TaskGoStraightToCoord(doctorPed, vector3(315.53173828125, -581.87268066406, 43.284164428711), 0.3, -1, 0.0, 0.0)
    Wait(4000)
    ClearPedTasks(doctorPed)
    Wait(100)

    TaskGoStraightToCoord(doctorPed, Config.DoctorPos, 0.3, -1, 0.0, 0.0)

    while (#(GetEntityCoords(doctorPed) - Config.DoctorPos)) > 1 do
        Wait(500)
    end

    DeleteEntity(doctorPed)
end

function StartClipBoardAnim(closestBed)
    local ped = PlayerPedId()
    local playerHealth = GetEntityHealth(PlayerPedId())
    if playerHealth > 110 then
        RequestAnimDict('missheistdockssetup1clipboard@base')
        while not HasAnimDictLoaded('missheistdockssetup1clipboard@base') do
            Wait(10)
        end

        local clipModel = CreateObject(GetHashKey('p_amb_clipboard_01'), GetEntityCoords(ped), true, true, true)
        local penModel = CreateObject(GetHashKey('prop_pencil_01'), GetEntityCoords(ped), true, true, true)
        while not DoesEntityExist(clipModel) or not DoesEntityExist(penModel) do
            Wait(0)
        end

        AttachEntityToEntity(penModel, ped, GetPedBoneIndex(PlayerPedId(), 58866), 0.12, 0.00, 0.001, -150.0, 0.0, 0.0, 1,
            1,
            0, 1, 0, 1)
        AttachEntityToEntity(clipModel, ped, GetPedBoneIndex(PlayerPedId(), 18905), 0.10, 0.02, 0.08, -68.0, 0.0, -40.0,
            1, 1,
            0, 1, 0, 1)
        TaskPlayAnim(ped, 'missheistdockssetup1clipboard@base', 'base', 8.0, -8.0, 5000, 49, 0, false, false, false)

        local startTime = GetGameTimer()
        local duration = 5000 -- 7 seconds in milliseconds
        local location = vector3(312.449, -592.772, 43.284)
        while GetGameTimer() - startTime < duration do
            Citizen.Wait(0)
            local elapsed = GetGameTimer() - startTime
            local percentage = math.floor((elapsed / duration) * 100)
            DrawText3D(location.x, location.y, location.z,
                ("Filling Form ~r~%d%%"):format(percentage))
        end

        DeleteEntity(clipModel)
        DeleteEntity(penModel)
        ClearPedTasks(ped)
        Wait(10)

        FreezeEntityPosition(PlayerPedId(), false)

        markerCoords = closestBed.Loc
        shouldDrawMarker = true

        drawNativeNotification("~r~Nancy~w~: Go to ward (A) public beds area")



        local attempt = 0


        while shouldDrawMarker and attempt <= 45 do
            Wait(500)
            attempt = attempt + 1
            if (attempt == 0) then
                break
            end
            local pedCoords = GetEntityCoords(PlayerPedId())
            local bedCoords = closestBed.Loc
            local distance = #(pedCoords - bedCoords)
            if distance < 1.5 then
                CreateThread(function()
                    GetOnTheBed(closestBed)
                end)
                CreateDoctor()
                break
            end
        end
    else
        print("medic", "low health")
        shouldDrawMarker = false

        CreateThread(function()
            GetOnTheBed(closestBed)
        end)
        CreateDoctor()
    end
end

Citizen.CreateThread(function()
    local model = "s_f_y_scrubs_01"                         -- Model for the NPC (receptionist model)
    local animDict = "anim@amb@business@bgen@bgen_no_work@" -- Animation dictionary for receptionist
    local animName = "stand_phone_phoneputdown_idle_c"      -- Animation name for receptionist (sitting at desk)

    -- Request the model
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do
        Wait(10)
    end

    -- NPC coordinates and heading
    local npcCoords = vector3(311.59, -594.049, 42.284)
    local npcHeading = 339.516

    -- Create the NPC
    local npc = CreatePed(1, GetHashKey(model), npcCoords.x, npcCoords.y, npcCoords.z, npcHeading, false, true)
    SetEntityHeading(npc, npcHeading)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    -- Request the animation dictionary
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    -- Create synchronized scene
    local netScene = CreateSynchronizedScene(npcCoords.x, npcCoords.y, npcCoords.z, vec3(0.0, 0.0, npcHeading), 2)
    TaskSynchronizedScene(npc, netScene, animDict, animName, 1.0, -4.0, 261, 0, 0)
    SetSynchronizedSceneLooped(netScene, true)

    -- Clean up
    SetModelAsNoLongerNeeded(GetHashKey(model))
end)

-- nancy desk
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local location = vector3(312.449, -592.772, 43.284)

        local distance = #(playerCoords - vector3(location.x, location.y, location.z))

        if distance < 2.0 then
            sleep = 5
            DrawText3D(location.x, location.y, location.z, "Press ~r~[E]~w~ to get treated by local doctor")

            if IsControlJustReleased(0, 38) then
                local playerHealth = GetEntityHealth(PlayerPedId())
                if playerHealth < 200 then
                    FreezeEntityPosition(PlayerPedId(), true)
                    local closestBed = GetFreeBed()

                    if closestBed then
                        StartClipBoardAnim(closestBed)
                    else
                        drawNativeNotification("~r~Nancy~w~ : You have to wait no bed is free right now")
                    end
                else
                    drawNativeNotification("~r~Nancy~w~ : You dont need medical attention")
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

-- get on bed

local layingOnBed = false;

CreateThread(function()
    local playerped = PlayerPedId();
    while true do
        local coords = GetEntityCoords(playerped);
        local sleep = 1500
        for _, bed in ipairs(Config.Beds) do
            local dis = #(bed.Loc - coords)
            if (dis < 3) then
                sleep = 5
                if layingOnBed then
                    DrawText3D(bed.Loc.x, bed.Loc.y, bed.Loc.z, "~r~[E]~w~ get up")
                else
                    DrawText3D(bed.Loc.x, bed.Loc.y, bed.Loc.z, "~r~[E]~w~ to lay on bed")
                end

                if IsControlJustReleased(0, 38) then
                    print("helo")
                    local isOccupied = IsBedOccupied(bed.Loc)
                    if isOccupied then
                        drawNativeNotification("Bed is already Occupied")
                    else
                        print("med", layingOnBed)
                        if layingOnBed then
                            local ped = PlayerPedId()
                            layingOnBed = false
                            ClearPedTasks(ped)
                            ClearPedSecondaryTask(ped)
                            RequestAnimDict('switch@franklin@bed')
                            while not HasAnimDictLoaded('switch@franklin@bed') do
                                Wait(50)
                            end
                            SetEntityHeading(ped, GetEntityHeading(ped) + 90.0)
                            TaskPlayAnim(ped, 'switch@franklin@bed', 'sleep_getup_rubeyes', -8.0, 8.0, 5000, 0, 0, 0, 0,
                                0)
                            Wait(5000)
                            FreezeEntityPosition(ped, false)
                        else
                            local ped = PlayerPedId()
                            layingOnBed = true
                            SetEntityCoords(ped, bed.Loc + bed.OffSet)
                            SetEntityHeading(ped, bed.Heading)
                            FreezeEntityPosition(ped, true)
                            RequestAnimDict('anim@gangops@morgue@table@')
                            while not HasAnimDictLoaded('anim@gangops@morgue@table@') do
                                Wait(10)
                            end

                            TaskPlayAnim(ped, 'anim@gangops@morgue@table@', 'ko_front', 8.0, -8.0, -1, 1, 0, false, false,
                                false)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

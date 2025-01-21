local carryingPet = false
local petToCarry = nil
local npcCoords = vector3(-619.16, 300.89, 81.3)
local heading = 40.87
local petEntity = nil
local totatPetSell = 0;

local petModels = {
    GetHashKey("a_c_cat_01"),
    GetHashKey("a_c_chop"),
    GetHashKey("a_c_husky"),
    GetHashKey("a_c_poodle"),
    GetHashKey("a_c_pug"),
    GetHashKey("a_c_retriever"),
    GetHashKey("a_c_rottweiler"),
    GetHashKey("a_c_shepherd"),
    GetHashKey("a_c_westy")
}

local function IsPedPet(ped)
    local pedModel = GetEntityModel(ped)
    for _, model in ipairs(petModels) do
        if pedModel == model then
            return true
        end
    end
    return false
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
end

local function CarryPet(petEntity)
    local playerPed = PlayerPedId()
    LoadAnimDict("amb@world_human_bum_freeway@male@base")

    -- Play the carry animation
    TaskPlayAnim(playerPed, "amb@world_human_bum_freeway@male@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)

    -- Attach the pet to the player's chest with adjusted offsets and rotation
    local boneIndex = GetPedBoneIndex(playerPed, 24818) -- Chest bone
    AttachEntityToEntity(petEntity, playerPed, boneIndex, 0.0, 0.35, 0.0, 60.0, -50.0, -30.0, false, false, false, false,
        2,
        true)

    -- Freeze the pet's position to prevent movement
    FreezeEntityPosition(petEntity, true)
end

local function DropPet()
    local playerPed = PlayerPedId()
    if petToCarry ~= nil then
        DetachEntity(petToCarry, true, true)
        ClearPedTasks(playerPed)
        FreezeEntityPosition(petToCarry, false)
        petToCarry = nil
        carryingPet = false
        petEntity = nil
    end
end

RegisterKeyMapping('carryPet', 'Carry Pet', 'keyboard', 'E')
RegisterCommand('carryPet', function()
    if not carryingPet then
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        local handle, entity = FindFirstPed()
        local success
        repeat
            local pos = GetEntityCoords(entity)
            local distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, pos.x, pos.y, pos.z, true)
            if IsEntityAPed(entity) and not IsPedDeadOrDying(entity) and distance < 2.0 and IsPedPet(entity) then
                petEntity = entity
                break
            end
            success, entity = FindNextPed(handle)
        until not success
        EndFindPed(handle)
        if petEntity ~= nil then
            petToCarry = petEntity
            print("helo")
            print(petEntity)
            CarryPet(petEntity)
            carryingPet = true
        end
    else
        DropPet()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if carryingPet then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local distance = GetDistanceBetweenCoords(coords, GetEntityCoords(petToCarry), true)
            local isInVehicle = IsPedInAnyVehicle(playerPed, false)   -- Check if player is in any vehicle
            if isInVehicle then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local driverPed = GetPedInVehicleSeat(vehicle, -1)
                local isPlayerDriving = driverPed == playerPed

                if isPlayerDriving then
                    DropPet()
                end
            elseif distance > 2.0 then -- Drop pet if player moves too far
                DropPet()
            end
        end
    end
end)


Citizen.CreateThread(function()
    RequestModel(GetHashKey("a_m_m_skidrow_01"))

    while not HasModelLoaded(GetHashKey("a_m_m_skidrow_01")) do
        Wait(10)
    end


    local npc = CreatePed(1, GetHashKey("a_m_m_skidrow_01"), npcCoords, heading, false, true)

    FreezeEntityPosition(npc, true)
    SetEntityHeading(npc, heading)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    -- Play the bartender animation
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)

    -- Release model memory
    SetModelAsNoLongerNeeded(GetHashKey("a_m_m_skidrow_01"))
end)

-- Function to calculate the distance between two coordinates
function GetDistance(coords1, coords2)
    return #(coords1 - coords2)
end

-- Function to display a message in chat
function SendMessage(message)
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0 },
        multiline = true,
        args = { "Pete the Pet Peddler", message }
    })
end

-- Register the /talk command
RegisterCommand('talk', function(source, args)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Check if the player is close enough to the NPC
    if GetDistance(playerCoords, npcCoords) < 3.0 then
        -- Display the conversation message in chat
        SendMessage(
        "Psst! Hey you, yeah you! Fancy yourself a pet whisperer? I'm your guy! Pete's the name, pet smuggling's the game! I'll buy any living, breathing critter you can sneak past the fuzz. Cash in hand, no questions asked. What do ya say, wanna make some fast dough?")
    end
end)

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


CreateThread(function()
    while true do
        local sleep = 2000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        
        if GetDistance(playerCoords, npcCoords) < 3.0 and carryingPet then
            sleep = 10
            DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z+1, "Press ~p~[K]~s~ to sell pet.")
        
            if IsControlJustPressed(1, 311) then
                totatPetSell = totatPetSell + 1
                if(totatPetSell > 2) then
                    SendMessage("I dont have any deals right now come back later.")
                else
                   
                    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
                    local cash  = Math.random(800, 3000)
                    TriggerServerEvent("coca_banking:addCashToCharacterId", characterId, cash)
                    SendMessage("Thanks for the pet! Here's " .. cash.. ". The pet has been taken care of.")
                    local petId = NetworkGetNetworkIdFromEntity(petEntity)
                    print("petEntity", petId, petEntity)
                    TriggerServerEvent('coca_mission_pet:removePet', petId)

                    ClearPedTasks(playerPed)
                    carryingPet = false
                end
                
            end
        end
        Wait(sleep)
    end
end)

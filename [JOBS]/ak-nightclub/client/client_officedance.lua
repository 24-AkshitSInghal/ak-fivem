local InLapdance = false
local NearText = false
local NearMarker = false
local startingCoords = vector3(95.21,  -1294.53, 29.4)
local npc = nil

local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- office secratery
Citizen.CreateThread(function()
    local model = 'Amaindian'
    RequestModel(GetHashKey(model))

    while not HasModelLoaded(GetHashKey(model)) do
        Wait(10)
    end

    for _, item in pairs(Config.Locations11) do
        npc = CreatePed(1, GetHashKey(model), item.x, item.y, item.z, item.heading, false, true)

        FreezeEntityPosition(npc, true)
        SetEntityHeading(npc, item.heading)
        SetEntityInvincible(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        TaskStartScenarioInPlace(npc, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", 0, true)
        SetModelAsNoLongerNeeded(GetHashKey(model))
    end
end)

RegisterNetEvent('coca_nightclub:showNotify', function(notify)
    drawNativeNotification(notify)
end)

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

Citizen.CreateThread(function()
    while true do
        if not NearMarker then
            Citizen.Wait(1500)
        else
            Citizen.Wait(1)
        end

        if NearMarker then
            if NearText then
                DrawText3D(startingCoords.x, startingCoords.y, startingCoords.z, "~q~[E]~w~ - Demand Sexy dance")
                if IsControlPressed(0, 38) then
                    local doPlayerHaveItem = exports['coca_inventory']:HasItemInInventory("vanillacard")
                    if(doPlayerHaveItem) then
                        Lapdance()
                        Citizen.Wait(5000)
                    else
                        drawNativeNotification("~q~Babe~w~ I am Off Limit. try other ~q~Strippers~w~")
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600)

        local Player = PlayerPedId()
        local coords = GetEntityCoords(Player)
        local markerdist = #(coords - startingCoords)
        if markerdist < 20 then
            NearMarker = true
        else
            NearMarker = false
        end
        if markerdist < 2.2 then
            NearText = true
        else
            NearText = false
        end
    end
end)

RegisterNetEvent('coca_nightclub:setEntityVisibility', function(visible)
    SetEntityVisible(npc, visible, false) 
end)

function Lapdance()
    local Player = PlayerPedId()
    
    InLapdance = true
    local lapdancerModel = 'Amaindian'

    RequestModel(lapdancerModel)
    InCooldown = true

    while not HasModelLoaded(lapdancerModel) do
        Wait(20)
    end

    TaskGoToCoordAnyMeans(Player, 94.880, -1290.823, 29.26, 1.0, 0, 0, 786603, 1.0)
    Citizen.Wait(3000)
    TriggerServerEvent('coca_nightclub:setEntityVisibility', false)
    local SpawnObject = CreatePed(4, lapdancerModel, 94.157, -1293.43, 29.26, false, true)
    SetEntityHeading(SpawnObject, 16.769)
    SetEntityInvincible(SpawnObject, true)
    SetBlockingOfNonTemporaryEvents(SpawnObject, true)

    RequestAnimDict("mini@strip_club@idles@stripper")
    while not HasAnimDictLoaded("mini@strip_club@idles@stripper") do
        Citizen.Wait(20)
    end
    TaskPlayAnim(SpawnObject, "mini@strip_club@idles@stripper", lapdancerModel, 8.0, -8.0, -1, 0, 0, false, false, false)

    FreezeEntityPosition(SpawnObject, true)
    

    FreezeEntityPosition(SpawnObject, false)
    TaskGoToCoordAnyMeans(SpawnObject, 95.0, -1290.999, 29.26, 174.93, 0, 0, 0, 0xbf800000)
    Citizen.Wait(3000)

    FreezeEntityPosition(SpawnObject, true)
    SetEntityHeading(SpawnObject, 8.98)
    RequestAnimDict("mini@strip_club@private_dance@part2")
    while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
        Citizen.Wait(20)
    end
    TaskPlayAnim(SpawnObject, "mini@strip_club@private_dance@part2", "priv_dance_p2", 8.0, -8.0, -1, 0, 0, false, false,
        false)
    Citizen.Wait(30000)

    SetEntityHeading(SpawnObject, 211.68)

    RequestAnimDict("mini@strip_club@private_dance@part2")
    while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
        Citizen.Wait(20)
    end
    TaskPlayAnim(SpawnObject, "mini@strip_club@private_dance@part2", "priv_dance_p2", 8.0, -8.0, -1, 0, 0, false, false,
        false)
    Citizen.Wait(30000)


    RequestAnimDict("mini@strip_club@private_dance@part1")
    while not HasAnimDictLoaded("mini@strip_club@private_dance@part1") do
        Citizen.Wait(100)
    end
    SetEntityHeading(SpawnObject, 8.98)
    

    TaskPlayAnim(SpawnObject, "mini@strip_club@private_dance@part1", "priv_dance_p1", 8.0, -8.0, -1, 0, 0,
        false,
        false, false)
    Citizen.Wait(15000)


    RequestAnimDict("mini@strip_club@backroom@")
    while not HasAnimDictLoaded("mini@strip_club@backroom@") do
        Citizen.Wait(20)
    end
    TaskPlayAnim(SpawnObject, "mini@strip_club@backroom@", "stripper_b_backroom_idle_b", 8.0, -8.0, -1, 0, 0, false,
        false, false)
    Citizen.Wait(5000)

    FreezeEntityPosition(SpawnObject, false)
    TaskGoToCoordAnyMeans(SpawnObject, 94.14, -1293.515, 29.26, 174.93, 0, 0, 0, 0xbf800000)
    Citizen.Wait(2000)

    RequestAnimDict("mini@strip_club@idles@stripper")
    while not HasAnimDictLoaded("mini@strip_club@idles@stripper") do
        Citizen.Wait(20)
    end
    TaskPlayAnim(SpawnObject, "mini@strip_club@idles@stripper", lapdancerModel, 8.0, -8.0, -1, 0, 0, false, false, false)
   
    Citizen.Wait(700)
    DeleteEntity(SpawnObject)
    TriggerServerEvent('coca_nightclub:setEntityVisibility', true)
    TriggerEvent("coca_ui_player:RelieveStress", 50)
    InLapdance = false
    
end

Citizen.CreateThread(function()
    while true do
        if not InLapdance then
            Citizen.Wait(1000)
        else
            Citizen.Wait(0)
        end

        if InLapdance then
            SetFollowPedCamViewMode(4)
            DisableControlAction(2, 24, true)
            DisableControlAction(2, 257, true)
            DisableControlAction(2, 25, true)
            DisableControlAction(2, 263, true)
            DisableControlAction(2, 32, true)
            DisableControlAction(2, 34, true)
            DisableControlAction(2, 8, true)
            DisableControlAction(2, 9, true)
        end
    end
end)

Citizen.CreateThread(function()
    
    while true do
        if not InLapdance then
            Citizen.Wait(1000)
        else
            Citizen.Wait(0)
        end

        if InLapdance then
            local Player = PlayerPedId()
            local coords = GetEntityCoords(Player)
            local sitdist = #(coords - vector3(94.78, -1290.1, 27.8))
            if sitdist < 2 then
                local dict = "mini@strip_club@lap_dance_2g@ld_2g_reach"
                RequestAnimDict(dict)

                while not HasAnimDictLoaded(dict) do
                    Citizen.Wait(20)
                end

                -- Move and freeze player
                SetEntityCoords(Player, 94.3, -1290.0, 27.8)
                FreezeEntityPosition(Player, true)
                SetEntityHeading(Player, 215.2)

                -- Play the initial animation
                TaskPlayAnim(Player, dict, "ld_2g_sit_idle", 8.0, -8.0, -1, 1, 0, false, false, false)

                -- Keep the animation playing while InLapdance is true
                repeat
                   
                        TaskPlayAnim(Player, dict, "ld_2g_sit_idle", 8.0, -8.0, -1, 1, 0, false, false, false)
                
                    Citizen.Wait(550)
                until not InLapdance

                -- Unfreeze player and reset position
                FreezeEntityPosition(Player, false)
                SetEntityCoords(Player, 94.666, -1290.89, 28.46)
                Citizen.Wait(200)
            end
        end
    end
end)


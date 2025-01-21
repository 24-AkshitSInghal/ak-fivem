local hunger = 100
local thirst = 100
local stress = 0
local hungerDecayRate = 0.1   
local thirstDecayRate = 0.15  

CreateThread(function()
    while true do
        local player = PlayerPedId()
        if not IsPauseMenuActive() then

            
            -- hunger = hunger - (hungerDecayRate * 0.29)
            -- thirst = thirst - (thirstDecayRate * 0.29)
           
           
            if hunger <= 5 then
        
                ApplyDamageToPed(player, 1, false)
            end

            if thirst <= 5 then
               
               
                ApplyDamageToPed(player, 1, false)
               
            end

            
            hunger = math.max(hunger, 0)
            thirst = math.max(thirst, 0)

        
            local currentHealth = GetEntityHealth(player) - 100
            SendNUIMessage({
                toggle = true,
                armour = GetPedArmour(player),
                health = currentHealth,
                hunger = math.floor(hunger),
                thirst = math.floor(thirst),
                stress = stress,
                config = { health = 99, armour = 1, hunger = 80, thirst = 80, stress = 1}
            })
        else
            SendNUIMessage({
                toggle = false
            })
        end
        Wait(1000)
    end
end)


CreateThread(function()
    Wait(100)
    while true do
        local radarEnabled = IsRadarEnabled()
        local player = PlayerPedId()
        if not IsPedInAnyVehicle(player) and radarEnabled then
            SendNUIMessage({
                action = 'notinveh'
            })
            DisplayRadar(false)
        elseif IsPedInAnyVehicle(player) and not radarEnabled then
            SendNUIMessage({
                action = 'inveh'
            })
            DisplayRadar(true)
        end
        Wait(500)
    end
end)


RegisterNetEvent("coca_ui_player:IncreaseHungerBar", function(value)
    hunger = math.min(value + hunger,100)
end)

RegisterNetEvent("coca_ui_player:IncreaseThistBar", function(value)
    thirst = math.min(value + thirst, 100)
end)

-- manage stress

Citizen.CreateThread(function()
    while true do
        local wait = 1000        -- default 2 minutes
        local shakeIntensity = 0.0 -- Initialize shake intensity
        if stress >= 100 then
            wait = 15000           -- 30 seconds to cycle if stress is below 7000
            shakeIntensity = 0.1   -- High intensity shake
        elseif stress >= 75 then
            wait = 30000           -- 1 minute to cycle if stress is below 4000
            shakeIntensity = 0.75  -- Medium intensity shake
        elseif stress >= 50 then
            wait = 60000           -- 1 minute to cycle if stress is below 4000
            shakeIntensity = 0.05  -- Medium intensity shake
        elseif stress >= 10 then
            wait = 120000          -- 2 minutes to cycle if stress is below 2000
            shakeIntensity = 0.02  -- Low intensity shake
        end
        if stress > 10 then
      
            TriggerScreenblurFadeIn(1000.0)
            ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", shakeIntensity) -- Add camera shake with dynamic intensity
            Wait(2500)
            TriggerScreenblurFadeOut(1000.0)
            ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.0) -- Stop camera shake
        end
        Citizen.Wait(wait)
    end
end)

RegisterNetEvent("coca_ui_player:AddStress", function(addstress)
    stress = math.min(stress + addstress,100)
end)

RegisterNetEvent("coca_ui_player:RelieveStress", function(relstress)
    stress = math.max(stress - relstress, 0)
end)

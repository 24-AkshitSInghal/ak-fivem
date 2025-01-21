local hasPayed = nil

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

RegisterNetEvent('coca_ui_player:paymentReturn', function(state)
    print(state)
    hasPayed = state
end)

interactableProps = {
    ["prop_watercooler"] = {
        text = "Press ~b~[E]~w~ to drink water",
        animDict = "mp_player_intdrink",
        animName = "loop_bottle",
        action = function(playerId)

            interactableProps["prop_watercooler"].lastUsed = GetGameTimer()

            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Citizen.Wait(100)
            end

            TaskPlayAnim(playerId, animDict, animName, 8.0, -8, -1, 49, 0, false, false, false)

            Citizen.Wait(animDuration)
            ClearPedTasks(playerId)

            TriggerEvent("coca_ui_player:IncreaseThistBar", 20)
        end,
        cooldown = 600,
        lastUsed = 0
    },
    ["prop_vend_water_01"] = {
        text = "Press ~b~[E]~w~ to buy Sparkling water",
        animDict = "mp_player_intdrink",
        animName = "loop_bottle",
        action = function(playerId)
            BuyItem(playerId, "prop_vend_soda_02", 30, "You bought a Chilled Sparkling water.",
                "amb@world_human_drinking_fat@beer@male@idle_a", "idle_c", 12000, nil, 30, 5)
        end,
        cooldown = 300,
        lastUsed = 0
    },
    ["prop_vend_coffe_01"] = {
        text = "Press ~b~[E]~w~ to buy coffee",
        action = function(playerId)
            BuyItem(playerId, "prop_vend_coffe_01", 20, "You purchased a hot cup of coffee.",
                "amb@world_human_aa_coffee@idle_a",
                "idle_a", 20000,nil , 5, 10)
        end,
        cooldown = 600,
        lastUsed = 0
    },
    ["prop_vend_soda_02"] = {
        text = "Press ~b~[E]~w~ to buy soda",
        action = function(playerId)
            BuyItem(playerId, "prop_vend_soda_02", 10, "You bought a refreshing soda.",
                "amb@world_human_drinking_fat@beer@male@idle_a", "idle_c", 12000, nil, 10, nil)
        end,
        cooldown = 450,
        lastUsed = 0
    },
    ["prop_vend_soda_01"] = {
        text = "Press ~b~[E]~w~ to buy soda",
        action = function(playerId)
            BuyItem(playerId, "prop_vend_soda_01", 10, "You bought a refreshing soda.",
                "amb@world_human_drinking_fat@beer@male@idle_a", "idle_c", 12000, nil, 10, nil)
        end,
        cooldown = 450,
        lastUsed = 0
    },
    ["prop_vend_snak_01"] = {
        text = "Press ~b~[E]~w~ to buy snacks",
        cost = 30,
        action = function(playerId)
            BuyItem(playerId, "prop_vend_snak_01", 30, "You bought a tasty snack.",
                "mp_player_inteat@burger", "mp_player_int_eat_burger", 15000, 20, -10, nil)
        end,
        cooldown = 600,
        lastUsed = 0
    }
}

function BuyItem(playerId, item, cost, successMessage, animDict, animName, animDuration, hungerIncrese, thistIncrease, stressRelief)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
    TriggerServerEvent('coca_ui_player:moneyCheck', cost, characterId)

    local startTime = GetGameTimer()

    while hasPayed == nil do
        Wait(100)
        if GetGameTimer() - startTime > 15000 then
            return drawNativeNotification("You don't have enough ~r~cash~w~")
        end
    end

    if not hasPayed or hasPayed == nil then
        hasPayed = nil
        drawNativeNotification("You don't have enough ~r~cash~w~")
        return
    end

    hasPayed = nil

    drawNativeNotification(successMessage)

    interactableProps[item].lastUsed = GetGameTimer()

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerId, animDict, animName, 8.0, -8, -1, 49, 0, false, false, false)

    Citizen.Wait(animDuration)
    ClearPedTasks(playerId)

    if hungerIncrese ~= nil then
        TriggerEvent("coca_ui_player:IncreaseHungerBar", hungerIncrese)
    end

    if thistIncrease ~= nil then
        TriggerEvent("coca_ui_player:IncreaseThistBar", thistIncrease)
    end

    if stressRelief ~= nil then
        TriggerEvent("coca_ui_player:RelieveStress", stressRelief)
    end
  
end

local props = {}

Citizen.CreateThread(function()
    while true do
        props = {}
        for model, data in pairs(interactableProps) do
            local object = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 3.0, GetHashKey(model), false, false,
                false)
            if DoesEntityExist(object) then
                table.insert(props, { object = object, data = data })
            end
        end
        Citizen.Wait(1000) -- Adjust interval as needed
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerId = PlayerPedId()
        local playerCoords = GetEntityCoords(playerId)
        local playerHeading = GetEntityHeading(playerId)
        for _, propData in ipairs(props) do
            local prop = propData.object
            local propCoords = GetEntityCoords(prop)
            local distance = #(playerCoords - propCoords)
            local heading = (propCoords - playerCoords)
            local cooldown = propData.data.cooldown
            local lastUsed = propData.data.lastUsed
            local currentTime = GetGameTimer()
            local dot = heading.x * math.cos(math.rad(playerHeading)) + heading.y * math.sin(math.rad(playerHeading))
            if currentTime - lastUsed >= cooldown * 1000 then
                if distance < 1.5 and dot > -0.1 then -- Within 1.5 units and facing prop
                    DrawText3D(propCoords.x, propCoords.y, propCoords.z + 0.5, propData.data.text)
                    if IsControlJustReleased(0, 38) then -- "E" key
                        propData.data.action(playerId)
                    end
                end
            end
        end
    end
end)

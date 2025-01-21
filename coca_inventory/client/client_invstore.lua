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

local function createBlips()
    for shopName, shop in pairs(Config.Shops) do
        for _, location in ipairs(shop.Locations) do
            local blip = AddBlipForCoord(location.x, location.y, location.z)
            SetBlipSprite(blip, shop.blipSprite)
            SetBlipColour(blip, shop.blipColour)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(shop.type)
            EndTextCommandSetBlipName(blip)
        end
    end
end

local function isPlayerNearShop()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearShop = false

    for shopName, shop in pairs(Config.Shops) do
        for _, location in ipairs(shop.Locations) do
            local distance = #(playerCoords - vector3(location.x, location.y, location.z))
            if distance < 3.0 then
                DrawText3D(location.x, location.y, location.z + 1, "Press ~y~[E]~w~ to open " .. shopName)
                nearShop = true
                if distance < 1.5 and IsControlJustReleased(0, 38) then -- 38 is the default key for 'E'
                    
                    local shopItems = {}
                    for i = 1, 80 do
                        shopItems[i] = {} -- Initialize each slot
                    end

                    RequestAnimDict("pickup_object")
                    while not HasAnimDictLoaded("pickup_object") do
                        Wait(7)
                    end
                    TaskPlayAnim(playerPed, "pickup_object", "pickup_low", 8.0, -8.0, -1, 1, 0, false, false, false)
                    Wait(2000)

                    ClearPedTasks(playerPed)

                    local currentIndex = 1
                    for _, item in ipairs(shop.Items) do
                        local itemConfig = Config.Items[item.name]

                        if not itemConfig then goto continue end

                        for key, value in pairs(itemConfig) do
                            item[key] = value
                        end
                        item['count'] = 50
                        shopItems[currentIndex] = item
                        currentIndex = currentIndex + 1

                        ::continue::
                    end

                    ToggleInventory('store', Config.invetoryData["store"].MaxWeight)
                    RefreshNuiOtherInventory({ inventory = shopItems })
                end
            end
        end
    end
    return nearShop
end

Citizen.CreateThread(function()
    createBlips()
    while true do
        local waitTime = 1000 -- Default wait time when not near any shop
        if isPlayerNearShop() then
            waitTime = 0      -- Set to 0 to continuously check when near a shop
        end
        Citizen.Wait(waitTime)
    end
end)


local hasPayed = nil

RegisterNUICallback('checkCash', function(data, cb)
    local cost = tonumber(data)
    local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

    -- Register an event to listen for the server response
    RegisterNetEvent('coca_inventory:paymentReturn', function(result)
        hasPayed = result
    end)

    -- Trigger server event
    TriggerServerEvent('coca_inventory:CashCheck', cost, characterId)

    -- Wait for the server response asynchronously
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()

        while hasPayed == nil do
            Wait(100)
            if GetGameTimer() - startTime > 10000 then
                drawNativeNotification("You don't have enough ~r~cash~w~")
                cb({ success = false })
                return
            end
        end

        if not hasPayed then
            drawNativeNotification("You don't have enough ~r~cash~w~")
            cb({ success = false })
        else
            cb({ success = true })
        end

        -- Cleanup
        hasPayed = nil
    end)
end)



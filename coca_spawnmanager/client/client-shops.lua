local function drawNativeNotification(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.Shops) do
        if v.blip == true then
            local blip = AddBlipForCoord(vector3(v.x, v.y, v.z))

            SetBlipSprite(blip, v.blipSprite)
            SetBlipColour(blip, v.blipColour)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(v.type)

            EndTextCommandSetBlipName(blip)
        end
    end
end)

local function startCustomization(shopType)
    local customizationOptions = {
        ["Tattoo Shop"] = {
            ped = false,
            headBlend = false,
            faceFeatures = false,
            headOverlays = false,
            components = false,
            props = false,
            tattoos = true
        },
        ["Clothing Shop"] = {
            ped = false,
            headBlend = false,
            faceFeatures = false,
            headOverlays = false,
            components = true,
            props = true,
            tattoos = false
        },
        ["Barber Shop"] = {
            ped = false,
            headBlend = false,
            faceFeatures = false,
            headOverlays = true,
            components = false,
            props = false,
            tattoos = false
        }
    }

    exports["fivem-appearance"]:startPlayerCustomization(function(appearance)
        if not appearance then return end
        local ped = PlayerPedId()
        local characterId = Config.CurrentCharacterId
        print(characterId)
        local clothing = {
            model = exports["fivem-appearance"]:getPedModel(ped),
            tattoos = exports["fivem-appearance"]:getPedTattoos(ped),
            appearance = exports["fivem-appearance"]:getPedAppearance(ped)
        }
        Wait(4000)
        TriggerServerEvent("coca_spawnmanager:updateClothing", characterId, clothing)
    end, customizationOptions[shopType])
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

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerId = PlayerPedId()
        local playerCoords = GetEntityCoords(playerId)
        local shopNearby = false

        for k, v in pairs(Config.Shops) do
            local shopCoords = vector3(v.x, v.y, v.z)
            local distance = #(playerCoords - shopCoords)

            if distance < 2 then
                shopNearby = true
                DrawText3D(v.x, v.y, v.z + 0.25, "Press ~y~[E]~w~ to open " .. v.type)
                if IsControlJustReleased(0, 38) then -- "E" key
                    startCustomization(v.type)
                end
            end
        end

        if not shopNearby then
            Citizen.Wait(500)
        end
    end
end)

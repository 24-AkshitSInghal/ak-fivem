local showServerId = false

RegisterKeyMapping('toggleServerId', 'Toggle Server ID Display', 'keyboard', 'HOME')
RegisterCommand('toggleServerId', function()
    showServerId = not showServerId
end)

local disPlayerNames = 10
local playerDistances = {}
local playerCharacterIds = {}

local function DrawText3D(position, text, r, g, b)
    local onScreen, _x, _y = World3dToScreen2d(position.x, position.y, position.z + 1.2)
    if not onScreen then return end

    local dist = #(GetGameplayCamCoords() - position)
    local scale = (1 / dist) * 2 * ((1 / GetGameplayCamFov()) * 100)

    SetTextScale(0.20 * scale, 0.70 * scale)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextColour(r, g, b, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

Citizen.CreateThread(function()
    Wait(500)
    while true do
        local sleep = 1500
        if showServerId then
            sleep = 5
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local playerServerId = GetPlayerServerId(PlayerId())

            for _, id in ipairs(GetActivePlayers()) do
                if id ~= playerServerId then
                    local targetPed = GetPlayerPed(id)
                    local distance = playerDistances[id]
                    if distance and distance < disPlayerNames then
                        local targetPedCoords = GetEntityCoords(targetPed)
                        local characterId = playerCharacterIds[GetPlayerServerId(id)]
                        if characterId then
                            local text = tostring(characterId)
                            local color = NetworkIsPlayerTalking(id) and { 1, 126, 188 } or { 255, 255, 255 }
                            DrawText3D(targetPedCoords, text, table.unpack(color))
                        end
                    end
                end
            end
        end
        Citizen.Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, id in ipairs(GetActivePlayers()) do
            local targetPed = GetPlayerPed(id)
            playerDistances[id] = #(playerCoords - GetEntityCoords(targetPed))
        end
        Wait(1000)
    end
end)

-- Request all character IDs every 30 seconds
Citizen.CreateThread(function()
    while true do
        TriggerServerEvent('coca_spawnmanager:getAllCharacterIds')
        Wait(30000) -- Adjust the delay as needed
    end
end)

-- Receive all character IDs from the server
RegisterNetEvent('coca_spawnmanager:receiveAllCharacterIds', function(characterIds)
    playerCharacterIds = characterIds
end)

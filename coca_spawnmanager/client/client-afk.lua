-- kick AFK player

local afkTimeout       = 1200 -- AFK kick time limit in seconds
local timer            = 0

local currentPosition  = nil
local previousPosition = nil
local currentHeading   = nil
local previousHeading  = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)

        playerPed = PlayerPedId()
        if playerPed then
            currentPosition = GetEntityCoords(playerPed, true)
            currentHeading  = GetEntityHeading(playerPed)

            if currentPosition == previousPosition and currentHeading == previousHeading then
                if timer > 0 then
                    if timer <= 60 then
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 0, 0 },
                            multiline = true,
                            args = { "Server", "You will be ~r~AFK Kicked~s~ in " .. timer .. "sec." }
                        })
                    end

                    timer = timer - 10
                else
                    TriggerServerEvent('coca_spawnmanager:kickplayer')
                end
            else
                timer = afkTimeout
            end

            -- (always) update variables
            previousPosition = currentPosition
            previousHeading  = currentHeading
        end
    end
end)

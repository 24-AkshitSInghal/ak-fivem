-- @main

CreateThread(function ()
    while true do
        local playerId = PlayerId()
        SendNUIMessage({
            talking = MumbleIsPlayerTalking(playerId),
            radio = radio
        })
        Wait(500)
    end
end)

AddEventHandler('pma-voice:setTalkingMode', function(newTalkingRange)
    SendNUIMessage({
        toggleprox = true,
        proximity = newTalkingRange,
    })
end)

AddEventHandler("pma-voice:radioActive", function(radioTalking) 
    radio = radioTalking
end)
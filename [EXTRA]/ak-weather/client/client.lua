
local currentWeather = 'EXTRASUNNY'
local currentTime = { hour = 12, minute = 0 }


RegisterNetEvent('weatherSync:updateWeather', function(newWeather)
    currentWeather = newWeather
    SetWeatherTypeOverTime(currentWeather, 15.0)
    Citizen.Wait(15000)
    SetWeatherTypePersist(currentWeather)
    SetWeatherTypeNow(currentWeather)
    SetWeatherTypeNowPersist(currentWeather)
end)

RegisterNetEvent('weatherSync:updateTime', function(hour, minute)
    currentTime.hour = hour
    currentTime.minute = minute
    NetworkOverrideClockTime(currentTime.hour, currentTime.minute, 0)
end)

-- Trigger weather and time sync when the player spawns
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('weatherSync:request')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(60000) -- Check every minute
        TriggerServerEvent('weatherSync:request')
    end
end)

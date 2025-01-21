local weathers = { 'CLEAR', 'EXTRASUNNY', 'CLOUDS', 'OVERCAST', 'RAIN', 'CLEARING', 'SMOG', 'FOGGY'}

-- Function to set random weather and time
local function setRandomWeatherAndTime()
	-- Select a random weather type
	local randomWeatherIndex = math.random(1, #weathers)
	local currentWeather = weathers[randomWeatherIndex]

	-- Generate random time
	local currentTime = {
		hour = math.random(0, 23),  -- Random hour between 0 and 23
		minute = math.random(0, 59) -- Random minute between 0 and 59
	}

	return currentWeather, currentTime
end

-- Set the random weather and time
local currentWeather, currentTime = setRandomWeatherAndTime()

-- Increment time every real-time minute
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(60000)                   -- Wait 1 real-time minute
		currentTime.minute = currentTime.minute + 6 -- 1 real minute = 6 in-game minutes
		if currentTime.minute >= 60 then
			currentTime.minute = 0
			currentTime.hour = currentTime.hour + 1
			if currentTime.hour >= 24 then
				currentTime.hour = 0
			end
		end
		TriggerClientEvent('weatherSync:updateTime', -1, currentTime.hour, currentTime.minute)
	end
end)

-- Change weather every 15 real-time minutes
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(900000) -- Wait 15 real-time minutes
		currentWeather = weathers[math.random(#weathers)]
		TriggerClientEvent('weatherSync:updateWeather', -1, currentWeather)
		print('Weather has been changed to: ' .. currentWeather)
	end
end)

RegisterServerEvent('weatherSync:request', function()
	TriggerClientEvent('weatherSync:updateWeather', source, currentWeather)
	TriggerClientEvent('weatherSync:updateTime', source, currentTime.hour, currentTime.minute)
end)


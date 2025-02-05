
local fraction = nil

Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/ooc', 'Out Of Character chat Message. (Global Chat)', {
		{ name = "Message", help = "Put your questions or help request." }
	})

	TriggerEvent('chat:addSuggestion', '/me', 'Send message in the third person. (Proximity Chat)', {
		{ name = "Action", help = "action." }
	})

	TriggerEvent('chat:addSuggestion', '/gme', 'Send message in the third person. (Global Chat)', {
		{ name = "Action", help = "action." }
	})

	TriggerEvent('chat:addSuggestion', '/do', 'Send action message. (Proximity Chat)', {
		{ name = "Action", help = "action." }
	})

	-- TriggerEvent('chat:addSuggestion', '/report', 'Send report message to admins.', {
	-- 	{ name = "Action", help = "action." }
	-- })

	-- TriggerEvent('chat:addSuggestion', '/adminhelp', 'To call Any Active Admins.', {
	-- 	{ name = "Action", help = "action." }
	-- })

	while not fraction do
		Wait(1000)
		fraction = exports['coca_spawnmanager']:GetCharacterFraction()
	end

	if fraction == "admin" then
		TriggerEvent('chat:addSuggestion', '/darkmsg','(admin) Send a anonymous message in game. (Global Chat)', {
			{ name = "Message", help = "Anonymous Message." }
		})
	end
end)

--Standard Chat
RegisterNetEvent('SendProximityMessage')
AddEventHandler('SendProximityMessage', function(id, name, message)
	local myID = PlayerId()
	local pID = GetPlayerFromServerId(id)
	if pID == myID then
		TriggerEvent('chatMessage', "^r" .. name .. "", { 128, 128, 128 }, "^r " .. message)
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myID)), GetEntityCoords(GetPlayerPed(pID)), true) < 19.999 then
		TriggerEvent('chatMessage', "^r" .. name .. "", { 128, 128, 128 }, "^r " .. message)
	end
end)

--/me Command
RegisterNetEvent('SendProximityMessageMe')
AddEventHandler('SendProximityMessageMe', function(id, name, message)
	local myID = PlayerId()
	local pID = GetPlayerFromServerId(id)
	if pID == myID then
		TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^6 ^*ME | ^7" .. name .. "^7: " .. "^r " .. message)
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myID)), GetEntityCoords(GetPlayerPed(pID)), true) < 19.999 then
		TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^6 ^*ME | ^7" .. name .. "^7: " .. "^r " .. message)
	end
end)

--/do Command
RegisterNetEvent('SendProximityMessageDo')
AddEventHandler('SendProximityMessageDo', function(id, name, message)
	local myID = PlayerId()
	local pID = GetPlayerFromServerId(id)
	if pID == myID then
		TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^9 ^*DO | " .. name .. "^7:  " .. "^r  " .. message)
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(myID)), GetEntityCoords(GetPlayerPed(pID)), true) < 19.999 then
		TriggerEvent('chatMessage', "", { 255, 0, 0 }, " ^9 ^*DO | " .. name .. "^7:  " .. "^r  " .. message)
	end
end)

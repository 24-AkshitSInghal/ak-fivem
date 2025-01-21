function AddLogtoDiscord(action, src, msg)
	exports["ak-logs"]:CreateLog({
		category = "chat", -- (* required)
		title = "Chat Logs", -- (* required)
		action = action,
		color = "purple",
		players = { -- Players Table (id, role)
			{ id = src, role = "Player" },
		},
		info = { -- Event Information (name, value)
			{ name = "Chat Message", value = msg },
		},
	})
	
end

AddEventHandler('chatMessage', function(source, name, message)
	CancelEvent()
end)

--/me Command
RegisterCommand('me', function(source, args, user)
	local name = GetPlayerName(source)
	TriggerClientEvent("SendProximityMessageMe", -1, source, name, table.concat(args, " "))
	AddLogtoDiscord('ME', source, table.concat(args, " "))
end, false)

--/do Command
RegisterCommand('do', function(source, args, user)
	local name = GetPlayerName(source)
	TriggerClientEvent("SendProximityMessageDo", -1, source, name, table.concat(args, " "))
	AddLogtoDiscord('DO', source, table.concat(args, " "))
end, false)

--/gme Command
RegisterCommand('gme', function(source, args, user)
	TriggerClientEvent('chatMessage', -1, "^3^*GLOBAL ME | ^7" .. GetPlayerName(source) .. "^r", { 128, 128, 128 },
		table.concat(args, " "))
	AddLogtoDiscord('GME', source, table.concat(args, " "))
end, false)

--/ooc Command
RegisterCommand('ooc', function(source, args, user)
	TriggerClientEvent('chatMessage', -1, "^*OOC | " .. GetPlayerName(source) .. "^r", { 128, 128, 128 },
		table.concat(args, " "))
	AddLogtoDiscord('OOC', source, table.concat(args, " "))
end, false)

-- /darkmsg Command
RegisterCommand('darkmsg', function(source, args, user)
	TriggerClientEvent('chatMessage', -1, "^0^*^*Anonymous Message^7", { 0, 0, 0 }, "^0^*" ..
		table.concat(args, " ") .. "^7")
	AddLogtoDiscord('DARKMSG', source, table.concat(args, " "))
end, false)



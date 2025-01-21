-- Animations
animDict1 = "mp_player_int_upperwank"
animDict2 = "anim@mp_player_intcelebrationmale@wank"
anim1 = "mp_player_int_wank_01_enter"
anim2 = "mp_player_int_wank_01_exit"
anim3 = "wank"

RegisterNetEvent("coca_essenitial:triggerText", function(text, player)
	local playerPed = GetPlayerPed(GetPlayerFromServerId(player))
	local playerCoords = GetEntityCoords(playerPed)
	local displayTime = 3000 -- Display time in milliseconds

	local startTime = GetGameTimer()
	print("here")
	Citizen.CreateThread(function()
		while (GetGameTimer() - startTime) < displayTime do
			Citizen.Wait(0)
			print("here2")
			local onScreen, _x, _y = World3dToScreen2d(playerCoords.x, playerCoords.y, playerCoords.z + 1.0)
			local px, py, pz = table.unpack(GetGameplayCamCoords())
			local distance = #(GetEntityCoords(PlayerPedId()) - playerCoords)

			if distance <= 10.0 then
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
		end
	end)
end)

function DisplayText(text)
	TriggerServerEvent("coca_essenitial:sharetext", text)
end

-- Get Animations
function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

-- Rock, Paper, Scissors
RegisterCommand("rps", function(source, args, command)
	local text = rpsPrefix
	local options = { "Rock!", "Paper!", "Scissors!" }
	local choice = ""
	if args[1] == "r" then
		choice = options[1]
	elseif args[1] == "p" then
		choice = options[2]
	elseif args[1] == "s" then
		choice = options[3]
	else
		return
	end
	text = choice
	loadAnimDict(animDict1)
	TaskPlayAnim(PlayerPedId(-1), animDict1, anim1, 8.0, -8, -1, 8, 0, 0, 0, 0)
	Citizen.Wait(700)
	DisplayText(text)
end)
TriggerEvent("chat:addSuggestion", "/rps", "Rock, Paper, Scissors", {
	{ name = "r/p/s", help = "r=Rock, p=Paper or s=Scissors" },
})

-- Flip Coin
RegisterCommand("flip", function(source, args, command)
	
	local options = { "Heads", "Tails" }
	text = options[math.random(1, #options)]
	loadAnimDict(animDict1)
	TaskPlayAnim(PlayerPedId(-1), animDict1, anim2, 8.0, -8, -1, 8, 0, 0, 0, 0)
	Citizen.Wait(700)
	DisplayText(text)
end)
TriggerEvent("chat:addSuggestion", "/flip", "Flip a coin")

-- Roll Dice
RegisterCommand("roll", function(source, args, command)
	local dice = {}
	local maxDice = 2
	local maxDiceSides = 12
	local numOfDice = tonumber(args[1]) and tonumber(args[1]) or 1
	local numOfSides = tonumber(args[2]) and tonumber(args[2]) or 6
	if (numOfDice < 1 or numOfDice > maxDice) then numOfDice = 1 end
	if (numOfSides < 2 or numOfSides > maxDiceSides) then numOfSides = 6 end
	for i = 1, numOfDice do
		dice[i] = math.random(1, numOfSides)
		text = dice[i] .. "/" .. numOfSides .. "  "
	end
	loadAnimDict(animDict2)
	TaskPlayAnim(PlayerPedId(-1), animDict2, anim3, 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(1500)
	ClearPedTasks(GetPlayerPed(-1))
	DisplayText(text)
end)

TriggerEvent("chat:addSuggestion", "/roll", "Roll dice", {
	{ name = "Dice",  help = "Number of dice " },
	{ name = "Sides", help = "Number of sides" },
})

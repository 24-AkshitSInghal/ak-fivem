local PlayerUpdatedData = nil
local characterId = nil

local banks = {
	{ name = "Bank", id = 108, x = 150.266,         y = -1040.203,       z = 29.374 },
	{ name = "Bank", id = 108, x = -1212.980,       y = -330.841,        z = 37.787 },
	{ name = "Bank", id = 108, x = -2962.582,       y = 482.627,         z = 15.703 },
	{ name = "Bank", id = 108, x = 314.187,         y = -278.621,        z = 54.170 },
	{ name = "Bank", id = 108, x = -351.534,        y = -49.529,         z = 49.042 },
	{ name = "Bank", id = 108, x = 241.727,         y = 220.706,         z = 106.286 },
	{ name = "Bank", id = 108, x = 1176.0833740234, y = 2706.3386230469, z = 38.157722473145 },
}

function DrawText3D(x, y, z, text)
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

local function drawNativeNotification(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Check if player is in a vehicle
function IsInVehicle()
	local ply = PlayerPedId()
	if IsPedSittingInAnyVehicle(ply) then
		return true
	else
		return false
	end
end

-- Display Map Blips
Citizen.CreateThread(function()
	for _, item in pairs(banks) do
		item.blip = AddBlipForCoord(item.x, item.y, item.z)
		SetBlipSprite(item.blip, item.id)
		SetBlipAsShortRange(item.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(item.name)
		EndTextCommandSetBlipName(item.blip)
	end
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

function bankanimation()
	local player = GetPlayerPed(-1)
	if (DoesEntityExist(player) and not IsEntityDead(player)) then
		loadAnimDict("mp_common")
		TaskPlayAnim(player, "mp_common", "givetake1_a", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
		Citizen.Wait(1000)
		ClearPedTasks(PlayerPedId())
	end
end

RegisterNetEvent("coca_banking:RecivePlayerData", function(data)
	PlayerUpdatedData = data
	SendNUIMessage(
		{
			refreshheader = true,
			currentBalance = PlayerUpdatedData.bankaccount,
			name = PlayerUpdatedData.name,
		}
	)
end)

RegisterNetEvent("coca_bank:transactionStatus", function(NotificationText)
	drawNativeNotification(NotificationText)
end)

-- If GUI setting turned on, listen for INPUT_PICKUP keypress
Citizen.CreateThread(function()
	while true do
		local sleep = 1500

		local playerId = PlayerPedId()
		local playerCoords = GetEntityCoords(playerId, 0)

		for _, bank in pairs(banks) do
			local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, bank.x, bank.y, bank.z)
			if distance < 3.0 and not IsInVehicle() then
				sleep = 0 -- Make the loop faster when near a bank
				DrawText3D(bank.x, bank.y, bank.z + 0.25, "Press ~y~[E]~w~ to access bank")

				if IsControlJustReleased(0, 38) then -- E key
					bankanimation()
					FreezeEntityPosition(playerId, true)
					characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
					Wait(1000)
					TriggerServerEvent("coca_banking:FetchPlayerData", characterId)
					Wait(1500)
					openBankUI()
				end
			end
		end
		Citizen.Wait(sleep)
	end
end)

function openBankUI()
	SetNuiFocus(true, true)
	SendNUIMessage(
		{
			openBank = true,
		}
	)
end

function closeGui()
	SetNuiFocus(false, false)
	SendNUIMessage(
		{
			openBank = false,
		}
	)
end

-- NUI Callback Methods
RegisterNUICallback('close', function(data, cb)
	local playerId = PlayerPedId()
	FreezeEntityPosition(playerId, false)
	closeGui()
	cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
	SendNUIMessage({ openSection = "withdraw" })
	cb('ok')
end)

RegisterNUICallback('deposit', function(data, cb)
	SendNUIMessage({ openSection = "deposit" })
	cb('ok')
end)

RegisterNUICallback('transfer', function(data, cb)
	SendNUIMessage({ openSection = "transfer" })
	cb('ok')
end)

RegisterNUICallback('withdrawSubmit', function(data, cb)
	TriggerServerEvent('coca_banking:withdraw', data.amount, characterId)
	cb('ok')
end)

RegisterNUICallback('depositSubmit', function(data, cb)
	TriggerServerEvent('coca_banking:deposit', data.amount, characterId)
	cb('ok')
end)

RegisterNUICallback('transferSubmit', function(data, cb)
	TriggerServerEvent('coca_banking:transfertoBank', data.amount, data.toPlayer, characterId)
	cb('ok')
end)


RegisterCommand('cash', function(source, args)
	if not characterId then
		characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
	end
	TriggerServerEvent("coca_banking:ShowCash", characterId)
end)

RegisterNetEvent('coca_banking:ShowCash', function(balance, show)
	SendNUIMessage({
		ShowCash = true,
		cash = balance,
		show = show
	})
end)

RegisterNetEvent("coca_banking:addCash", function(balance)
	SendNUIMessage({
		addCash = true,
		amount = balance
	})
end)

RegisterNetEvent("coca_banking:removeCash", function(amount)
	SendNUIMessage({
		removeCash = true,
		amount = amount
	})
end)

RegisterCommand('bank', function(source, args)
	if not characterId then
		characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
	end
	TriggerServerEvent("coca_banking:ShowBank", characterId)
end)

RegisterNetEvent('coca_banking:ShowBank', function(balance, show)
	print(show, balance)
	SendNUIMessage({
		ShowBank = true,
		balance = balance,
		show = show
	})
end)

RegisterNetEvent("coca_bank:addBalance", function(amount)
	SendNUIMessage({
		addBalance = true,
		amount = amount
	})
end)

RegisterNetEvent("coca_banking:removeBank", function(amount)
	SendNUIMessage({
		removeBalance = true,
		amount = amount
	})
end)

-- TriggerEvent('chat:addSuggestion', '/givecash', '(admin) Usage: /givecash [Id] [amount]')
-- RegisterCommand('givecash', function(source, args)
-- 	if not characterId then
-- 		characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
-- 	end

-- 	if #args < 2 then
-- 		return
-- 	end

-- 	local senderCharacterId = characterId
-- 	local targetCharacterId = args[1]

-- 	local serveIdOfTargert = exports['coca_spawnmanager']:GetServerIdByCharacterId(targetCharacterId)

-- 	-- here get the distance and if it is bigger than 2 then return 

-- 	local cash = args[2]
-- 	print(characterId)
-- 	TriggerServerEvent('coca_banking:GiveCash', cash, targetCharacterId, senderCharacterId)
-- end)

TriggerEvent('chat:addSuggestion', '/givecash', '(admin) Usage: /givecash [Id] [amount]')

RegisterCommand('givecash', function(source, args)
	-- Ensure there are at least two arguments provided
	if #args < 2 then
		return
	end

	-- Retrieve the active character ID for the sender
	local senderCharacterId = exports['coca_spawnmanager']:GetActiveCharacterId()

	-- Retrieve the target character ID and the cash amount from the arguments
	local targetCharacterId = args[1]
	local cash = tonumber(args[2])

	if not cash or cash <= 0 then
		return
	end

	-- Get the server ID of the target character
	local serverIdOfTarget = exports['coca_spawnmanager']:GetServerIdByCharacterId(targetCharacterId)

	print(serverIdOfTarget)
	if not serverIdOfTarget then
		return
	end

	-- Get the Ped ID of the target character
	local targetPed = GetPlayerPed(GetPlayerFromServerId(serverIdOfTarget))

	-- Check if the target Ped exists
	if not DoesEntityExist(targetPed) then
		return
	end

	-- Get the coordinates of the player and the target Ped
	local playerPed = PlayerPedId()
	local playerCoords = GetEntityCoords(playerPed)
	local targetCoords = GetEntityCoords(targetPed)

	-- Calculate the distance between the player and the target Ped
	local distance = #(playerCoords - targetCoords)

	-- Check if the distance is greater than 2
	if distance > 2 then
		return
	end

	-- Trigger the server event to give cash
	TriggerServerEvent('coca_banking:GiveCash', cash, targetCharacterId, senderCharacterId)
end)

local hasPayed = nil

function RemoveCash(givenCharacterId, money)
	local cost = tonumber(money)

	RegisterNetEvent('coca_banking:paymentStatus', function(result)
		hasPayed = result
	end)

	TriggerServerEvent('coca_banking:removeCashToCharacterId', givenCharacterId, cost)

	local startTime = GetGameTimer()

	while hasPayed == nil do
		Wait(100)
		print(hasPayed)
		if GetGameTimer() - startTime > 3000 then
			drawNativeNotification("You don't have enough ~r~cash~w~")
			hasPayed = nil
			return false
		end
	end

	if not hasPayed then
		drawNativeNotification("You don't have enough ~r~cash~w~")
		hasPayed = nil
		return false
	else
		hasPayed = nil
		return true
	end
	
end

exports('RemoveCash', RemoveCash)

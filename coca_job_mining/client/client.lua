local isMiningActive = true
local impacts = 0
local totalMining = 0
local locations = {
	{ ['x'] = 3004.3,  ['y'] = 2763.46, ['z'] = 43.7 },
	{ ['x'] = 3005.6,  ['y'] = 2770.58, ['z'] = 42.91 },
	{ ['x'] = 3001.81, ['y'] = 2790.85, ['z'] = 44.76 },
	{ ['x'] = 2987.66, ['y'] = 2880.84, ['z'] = 45.16 },
	{ ['x'] = 2997.42, ['y'] = 2750.77, ['z'] = 44.32 },
	{ ['x'] = 2986.03, ['y'] = 2751.63, ['z'] = 43.22 },
	{ ['x'] = 3002.53, ['y'] = 2759.12, ['z'] = 43.11 },
	{ ['x'] = 3005.37, ['y'] = 2781.34, ['z'] = 44.06 },
}

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

local function drawNativeNotification(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

local function CheckIfPlayerCanMine(callback)
	local hasPickAxe = exports.coca_inventory:HasItemInInventory('pickaxe')
	local hasHelmet = exports.coca_inventory:HasItemInInventory('mininghelmet')
	local isWearingMiningHelmet = IsPedWearingHelmet(PlayerPedId())

	callback(hasPickAxe and isWearingMiningHelmet and hasHelmet)
end

function IsPedWearingHelmet(ped)
	local helmetDrawable = 89 -- Example value for a construction helmet
	local helmetTexture = 4 -- Example value for the default texture
	local currentHelmetDrawable = GetPedPropIndex(ped, 0)
	local currentHelmetTexture = GetPedPropTextureIndex(ped, 0)

	return currentHelmetDrawable == helmetDrawable and currentHelmetTexture == helmetTexture
end

-- Mining Location Blip
Citizen.CreateThread(function()
	local blipLocation = Config.MiningBlip
	local blip = AddBlipForCoord(vector3(blipLocation.x, blipLocation.y, blipLocation.z))

	SetBlipSprite(blip, 486)
	SetBlipColour(blip, 0)
	SetBlipScale(blip, 0.7)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Mining')
	EndTextCommandSetBlipName(blip)
end)

-- Mining Interaction
Citizen.CreateThread(function()
	while true do
		local sleep = 1500
		local ped = PlayerPedId()

		for i = 1, #locations do
			local loc = locations[i]
			local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), loc.x, loc.y, loc.z, true)

			if dist < 8 then
				sleep = 5
				DrawText3D(loc.x, loc.y, loc.z, "Press ~o~[E]~w~ to start mining.")

				if dist < 1.5 and IsControlJustReleased(1, 38) then
					if isMiningActive == false then
						Wait(2000)
						drawNativeNotification("You need rest. Come back later!")
						goto continue
					end
					CheckIfPlayerCanMine(function(canMine)
						if canMine then
							totalMining = totalMining + 1
							Animation()
							if totalMining == Config.MaxMiningCount then
								isMiningActive = false
								drawNativeNotification("You need rest. Come back later!")
							end
						else
							drawNativeNotification("You need a ~r~pickaxe~w~ and ~r~helmet~w~ on your head.")
							Citizen.Wait(5000)
						end
					end)
					Citizen.Wait(10) -- Optional wait to prevent rapid triggering
				end
			end
			::continue::
		end
		Citizen.Wait(sleep)
	end
end)

function Animation()
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
	local ped = PlayerPedId()
	local pickaxe = nil

	while impacts < 5 do
		Citizen.Wait(200)

		RequestAnimDict("melee@large_wpn@streamed_core")
		while not HasAnimDictLoaded("melee@large_wpn@streamed_core") do
			Citizen.Wait(100)
		end

		TaskPlayAnim(ped, "melee@large_wpn@streamed_core", "ground_attack_on_spot", 8.0, 8.0, -1, 80, 0, 0, 0, 0)
		SetEntityHeading(ped, 220.0)

		if impacts == 0 then
			pickaxe = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true)
			AttachEntityToEntity(pickaxe, ped, GetPedBoneIndex(ped, 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0,
				true, true, false, true, 1, true)
		end

		Citizen.Wait(2500)
		ClearPedTasks(ped)
		impacts = impacts + 1

		if impacts == 5 then
			local pickaxeId = NetworkGetNetworkIdFromEntity(pickaxe)
			TriggerServerEvent('coca_job_mining:removePickaxe', pickaxeId)
			impacts = 0
			TriggerServerEvent("coca_inventory:Server:AddItem", characterId, 'stones', 1, "You found ~o~5~w~ Stones")
			break
		end
	end
end

-- WASHING


-- Variables for caching
local lastCheckTime = 0
local cachedHaveStones = false

Citizen.CreateThread(function()
	Wait(60000)
		while true do
		local sleep = 1500
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local isNearWater = IsEntityInWater(playerPed)

		if isNearWater then
			-- Check if it's time to refresh the cache
			if GetGameTimer() - lastCheckTime > 30000 then -- 30 seconds in milliseconds
				cachedHaveStones = exports.coca_inventory:HasItemInInventory('stones')
				lastCheckTime = GetGameTimer()
			end

			if cachedHaveStones then
				sleep = 0
				DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, "Press ~b~[E]~w~ to wash stones")
				if IsControlJustReleased(0, 38) then -- 'E' key
					WashStones()
					Wait(3000)
					sleep = 1500 -- Reset sleep time after action
				end
			end
		end

		Citizen.Wait(sleep)
	end
end)

function WashStones()
	local ped = PlayerPedId()
	local hasStones = exports.coca_inventory:HasItemInInventory('stones')
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

	if hasStones then
		FreezeEntityPosition(ped, true)
		TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
		TriggerServerEvent('coca_inventory:Server:RemoveItem', characterId, 'stones', 1)
		local startTime = GetGameTimer()
		local duration = 15000
		while GetGameTimer() - startTime < duration do
			Citizen.Wait(100)
		end
		ClearPedTasks(ped)

		TriggerServerEvent('coca_inventory:Server:AddItem', characterId, "washedstones", 1)
		FreezeEntityPosition(ped, false)
		drawNativeNotification('stones Washer')
	else
		drawNativeNotification("You do not have stones to wash.")
	end
end

-- SMELTING


-- Mining Interaction
Citizen.CreateThread(function()
	while true do
		local sleep = 1500
		local ped = PlayerPedId()


		local loc = Config.Remelting
		local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), loc.x, loc.y, loc.z, true)

		if dist < 8 then
			sleep = 5
			DrawText3D(loc.x, loc.y, loc.z, "Press ~o~[E]~w~ to start smelting stones.")

			if dist < 1.5 and IsControlJustReleased(1, 38) then
				local hasStones = exports.coca_inventory:HasItemInInventory('washedstones')
				if hasStones == false then
					Wait(1000)
					drawNativeNotification("You dont have more stones!")
				else
					smeltStones()
				end

				Citizen.Wait(100) -- Optional wait to prevent rapid triggering
			end
		end


		Citizen.Wait(sleep)
	end
end)


function smeltStones()
	local ped = PlayerPedId()
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
	local hasStones = exports.coca_inventory:HasItemInInventory('washedstones')
	print("helo")
	Wait(200)

	if hasStones then
		TriggerEvent('coca_inventory:stopInventoryUI', true)
		TriggerServerEvent('coca_inventory:Server:RemoveItem', characterId, 'washedstones', 1)
		Wait(700)
		FreezeEntityPosition(ped, true)
		TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)

		local startTime = GetGameTimer()
		local duration = 15000

		while GetGameTimer() - startTime < duration do
			Citizen.Wait(100)
		end

		ClearPedTasks(ped)
		FreezeEntityPosition(ped, false)

		-- Calculate total chance for random selection
		local totalChance = 0
		for ore, data in pairs(Config.Ores) do
			totalChance = totalChance + data.chance
		end

		-- Determine which item(s) are selected based on chances
		local accumulatedChance = 0
		local itemsFound = {}
		local numberOfItems = math.random(1, 3) -- Randomly select between 1 to 3 items
		local notificationMessage = 'Smelting Done. Found: '

		for i = 1, numberOfItems do
			local foundItem = nil
			local randomNum = math.random(1, totalChance)

			for ore, data in pairs(Config.Ores) do
				accumulatedChance = accumulatedChance + data.chance
				if randomNum <= accumulatedChance then
					foundItem = ore
					break
				end
			end

			if foundItem then
				table.insert(itemsFound, { item = foundItem, count = 1 })
				notificationMessage = notificationMessage .. "~o~" .. foundItem .. "~w~"
				if i < numberOfItems then
					notificationMessage = notificationMessage .. ' ,'
				end
			end
		end
		
		TriggerServerEvent('coca_inventory:Server:AddMutipleItem', characterId, itemsFound, notificationMessage)
		Wait(1000)
		
		TriggerEvent('coca_inventory:stopInventoryUI', false)
	else
		drawNativeNotification("You do not have stones to wash.")
	end
end

function useSalvage(itemData, itemName, itemIndex)
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
	TriggerEvent('coca_inventory:stopInventoryUI', true)
	RemoveItemFromInventorybyIndex(itemIndex, 1)
	Wait(700)

	local items = { "electronics", "scrap", "wire", "rubber", "glass" }


	local chanceToAddItems = math.random()

	if chanceToAddItems > 0.2 then
		local totalItemsToAdd = math.random(1, 3)
		local addedItems = {}
		local msg = "Found: "
		for i = 1, totalItemsToAdd do
			local randomItem = items[math.random(1, #items)]
			table.insert(addedItems, { item = randomItem, count = 1 })
			msg = msg .. "~d~" .. randomItem
			if i < totalItemsToAdd then
				msg = msg .. "~w~, "
			end
		end

		TriggerServerEvent('coca_inventory:Server:AddMutipleItem', characterId, addedItems, msg)
	else
		drawNativeNotification("No usefull item found.")
	end
	TriggerEvent('coca_inventory:stopInventoryUI', false)
end

local istalking = false

CreateThread(function ()
	
	local sellingLocation = Config.Sell
	local model = 'ig_bankman' -- Model for a pawn shop owner
	RequestModel(GetHashKey(model))

	while not HasModelLoaded(GetHashKey(model)) do
		Wait(10)
	end

	local npc = CreatePed(1, GetHashKey(model), sellingLocation.x, sellingLocation.y, sellingLocation.z,
		sellingLocation.heading, false, true)

	FreezeEntityPosition(npc, true)
	SetEntityHeading(npc, sellingLocation.heading)
	SetEntityInvincible(npc, true)
	SetBlockingOfNonTemporaryEvents(npc, true)

	TaskStartScenarioInPlace(npc, "WORLD_HUMAN_SEAT_LEDGE", 0, true) -- Changed scenario to sitting
end)

Citizen.CreateThread(function()
	local sellingLocation = Config.Sell
	local characterId = nil
	while true do
		Wait(1500)
		characterId = exports['coca_spawnmanager']:GetActiveCharacterId()
		if characterId then
			break
		end
	end

	while true do
		local sleep = 1500
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local distance = GetDistanceBetweenCoords(playerCoords, sellingLocation.x, sellingLocation.y, sellingLocation.z,
			true)

		if distance < 2.0 then
			sleep = 5
			if not istalking then
				DrawText3D(sellingLocation.x, sellingLocation.y, sellingLocation.z + 1, 'Press ~y~[E]~s~ to Talk')
			end

			if IsControlJustReleased(0, 38) or istalking then -- E key
				if not istalking then
					TriggerEvent('chat:addMessage', {
						color = { 255, 215, 0 }, -- Gold color
						multiline = true,
						args = { "Goldie McWealth", "I deal in jewels and precious items. If you have any, I'm the guy." }
					})
				end
				istalking = true
				DrawText3D(sellingLocation.x, sellingLocation.y, sellingLocation.z + 1,
					"Press ~p~[K]~s~ to sell precious items.")
				print("here")
				if IsControlJustPressed(1, 311) then
					TriggerServerEvent('coca_inventory:Server:SellAllItembyCategoryAndGiveCash', characterId, 'pawn')
					TriggerEvent('chat:addMessage', {
						color = { 255, 215, 0 }, -- Gold color
						multiline = true,
						args = { "Goldie McWealth", "Here is your Cash. Don't Spend all your money on hookers, hehe" }
					})
					istalking = false
				end
				
			end
		else
			istalking = false
		end

		Wait(sleep)
	end
end)


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

local function addFishingBlips()
	for _, info in pairs(Config.Locations) do
		if info.position then
			local blip = AddBlipForCoord(info.x, info.y, info.z)
			SetBlipSprite(blip, 68) -- 68 is the sprite ID for a fishing blip
			SetBlipDisplay(blip, 0)
			SetBlipScale(blip, 0.8)
			SetBlipColour(blip, 3)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Fishing Spot")
			EndTextCommandSetBlipName(blip)
		end
	end
end

local function CheckIfPlayerCanFish(callback)
	local hasFishingRod = exports.coca_inventory:HasItemInInventory('fishingrod')
	local hasBait = exports.coca_inventory:HasItemInInventory('bait')
	local canFish = hasFishingRod and hasBait
	if not canFish then
		drawNativeNotification("You need a fishing rod and some bait")
	end
	callback(canFish)
end

local function GetFishProbability()
	local randomNumber = math.random()
	local accumulatedProbability = 0
	local playerPed = PlayerPedId()
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

	for _, fish in pairs(Config.Fishes) do
		accumulatedProbability = accumulatedProbability + fish['chance']
		if randomNumber <= accumulatedProbability then
			drawNativeNotification('You caught a ~b~' .. fish['label'])
			print(fish.name)
			TriggerServerEvent('coca_inventory:Server:AddItem', characterId, fish.name, 1)
			TriggerServerEvent('coca_inventory:Server:RemoveItem', characterId, 'bait', 1)
			if math.random(1, 100) <= 10 then -- 90% chance the fishing rod breaks
				TriggerServerEvent('coca_inventory:Server:RemoveItem', characterId, 'fishingrod', 1)
				Wait(3000)
				drawNativeNotification("The fish snapped your fishing rod and ~r~broke~s~ it!")
				FreezeEntityPosition(playerPed, false)
				TriggerEvent('coca_inventory:stopInventoryUI', false)
			end
			break
		end
	end
end

local function startFishing(location, data)
	local randomWait = math.random(500, 2000)
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local count = 1
	local catchPeriod = 500
	local failure = 200
	local msg = ''
	local fishing = true

	TriggerEvent('coca_inventory:stopInventoryUI', true)
	FreezeEntityPosition(playerPed, true)
	SetEntityHeading(playerPed, data['h'])
	TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, true)
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

	while fishing do
		if randomWait > 0 then
			count = count + 1
			if count >= 100 then
				count = 1
				msg = 'Waiting' .. ''
			elseif count >= 75 then
				msg = 'Waiting' .. '...'
			elseif count >= 50 then
				msg = 'Waiting' .. '..'
			elseif count >= 25 then
				msg = 'Waiting' .. '.'
			end
			randomWait = randomWait - 1
		elseif catchPeriod > 0 then
			catchPeriod = catchPeriod - 1
			msg = 'Press ~b~[E]~w~ to catch the fish'
			DrawText3D(coords.x, coords.y, coords.z + 1.25, 'The rod is ~y~twitching~w~')
		elseif failure > 0 then
			failure = failure - 1
			if failure == 1 then
				msg = 'The fish got away..'
				if math.random(1, 100) <= 30 then -- can
					TriggerServerEvent('coca_inventory:Server:RemoveItem', characterId, 'fishingrod', 1)
					drawNativeNotification("The fish snapped your fishing rod and ~r~broke~s~ it!")
					fishing = false
					FreezeEntityPosition(playerPed, false)
					TriggerEvent('coca_inventory:stopInventoryUI', false)
				end
			end
		else
			ClearPedTasks(playerPed)
			fishing = false
			local fishingRod = GetClosestObjectOfType(coords.x, coords.y, coords.z, 15.0,
				GetHashKey("prop_fishing_rod_01"), false, false, false)
			if fishingRod ~= 0 then
				SetEntityAsMissionEntity(fishingRod, false, true)
				DeleteObject(fishingRod)
			end
		end

		if IsControlJustReleased(0, 38) then -- e key
			ClearPedTasks(playerPed)
			local fishingRod = GetClosestObjectOfType(coords.x, coords.y, coords.z, 15.0,
				GetHashKey("prop_fishing_rod_01"), false, false, false)
			if fishingRod ~= 0 then
				SetEntityAsMissionEntity(fishingRod, false, true)
				DeleteObject(fishingRod)
			end
			fishing = false
			FreezeEntityPosition(playerPed, false)
			if randomWait <= 0 and catchPeriod > 0 then
				GetFishProbability()
			end
		elseif IsControlJustReleased(0, 18) or
			IsControlJustReleased(0, 73) or
			IsControlJustReleased(0, 27) or
			IsControlJustReleased(0, 22) or
			IsControlJustReleased(0, 24) or
			IsControlJustReleased(0, 177) or
			IsControlJustReleased(0, 25) then -- X key
			ClearPedTasks(playerPed)
			local fishingRod = GetClosestObjectOfType(coords.x, coords.y, coords.z, 15.0,
				GetHashKey("prop_fishing_rod_01"), false, false, false)
			if fishingRod ~= 0 then
				SetEntityAsMissionEntity(fishingRod, false, true)
				DeleteObject(fishingRod)
			end
			fishing = false
			FreezeEntityPosition(playerPed, false)
			TriggerEvent('coca_inventory:stopInventoryUI', false)
		end

		DrawText3D(coords.x, coords.y, coords.z + 1.1, msg)
		Citizen.Wait(5)
	end
end

local function handleFishingSpots()
	local isFishing = false
	Citizen.CreateThread(function()
		while true do
			local sleepTime = 1000
			if not isFishing then
				local playerPed = PlayerPedId()
				local playerCoords = GetEntityCoords(playerPed)
				for _, spot in pairs(Config.Locations) do
					local distance = GetDistanceBetweenCoords(playerCoords, spot.x, spot.y, spot.z, true)
					if distance < 8.0 then
						sleepTime = 5
						DrawText3D(spot.x, spot.y, spot.z, 'Press ~b~[E]~s~ to start fishing')
						if distance < 10.0 and IsControlJustReleased(0, 38) then -- E key
							CheckIfPlayerCanFish(function(canFish)
								if canFish then
									startFishing(_, spot)
								else
									drawNativeNotification("You need a ~r~fishing rod~w~ and some ~r~bait~w~")
								end
							end)
							Citizen.Wait(10)
						end
					end
				end
			end
			Citizen.Wait(sleepTime)
		end
	end)
end

Citizen.CreateThread(addFishingBlips)
Citizen.CreateThread(handleFishingSpots)


-- SELLING

Citizen.CreateThread(function()
	local sellingLocation = Config.sellinglocation

	local blip = AddBlipForCoord(vector3(sellingLocation.x, sellingLocation.y, sellingLocation.z))

	SetBlipSprite(blip, 120) -- Assuming you want to use the pawn shop icon (ID: 662), change it to your desired sprite ID
	SetBlipColour(blip, 3) -- Assuming you want the blip color to be yellow, change it to your desired color
	SetBlipScale(blip, 0.7)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Fish Selling')
	EndTextCommandSetBlipName(blip)
end)

local istalking = false

Citizen.CreateThread(function()
	local sellingLocation = Config.sellinglocation
	local model = 's_m_m_dockwork_01' -- Model for a dock worker, which is more fitting for a fish seller
	RequestModel(GetHashKey(model))

	while not HasModelLoaded(GetHashKey(model)) do
		Wait(10)
	end
	npc = CreatePed(1, GetHashKey(model), sellingLocation.x, sellingLocation.y, sellingLocation.z,
		sellingLocation.heading, false,
		true)

	FreezeEntityPosition(npc, true)
	SetEntityHeading(npc, 357.16)
	SetEntityInvincible(npc, true)
	SetBlockingOfNonTemporaryEvents(npc, true)

	TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true) -- Changed scenario to clipboard, as if taking inventory or orders
	local characterId = exports['coca_spawnmanager']:GetActiveCharacterId()

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
						color = { 0, 191, 255 },
						multiline = true,
						args = { "Finny McGill", "Fresh fish, best prices! Got any fish to sell?" }
					})
				end
				istalking = true

				DrawText3D(sellingLocation.x, sellingLocation.y, sellingLocation.z + 1,
					"Press ~p~[K]~s~ to sell fishes.")

				if IsControlJustPressed(1, 311) then
					TriggerServerEvent('coca_inventory:Server:SellAllItembyCategoryAndGiveCash', characterId, 'fish')
					TriggerEvent('chat:addMessage', {
						color = { 0, 191, 255 }, 
						multiline = true,
						args = { "Finny McGill", "Here's your cash. Pleasure Doing Business, Byee!" }
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

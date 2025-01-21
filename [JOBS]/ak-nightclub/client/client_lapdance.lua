local InLapdance = false
local InCooldown = false
local NearText = false
local NearMarker = false
local startingCoords = vector3(126.052, -1282.47, 29.4)
local cardTypePlayerHave = nil

local lapDancerPeds = {
	"s_f_y_stripper_04",
	"csb_stripper_09",
	"csb_stripper_08",
	"s_f_y_stripper_07"
}

function GetRandomLapDancerPedModel()
	local randomIndex = math.random(#lapDancerPeds)
	return lapDancerPeds[randomIndex]
end

local function drawNativeNotification(text)
	SetTextComponentFormat("STRING")
	AddTextComponentString(text)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

RegisterNetEvent('coca_nightclub:showNotify', function(notify)
	drawNativeNotification(notify)
	cardTypePlayerHave = nil
end)

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(true)
	AddTextComponentString(text)
	SetDrawOrigin(x, y, z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
	ClearDrawOrigin()
end

Citizen.CreateThread(function()
	while true do
		if not NearMarker then
			Citizen.Wait(1500)
		else
			Citizen.Wait(1)
		end

		if NearMarker then
			if NearText then
				DrawText3D(startingCoords.x, startingCoords.y, startingCoords.z, "~p~[E]~w~ - Ask for a lap dance")
				if IsControlPressed(0, 38) and not InCooldown then
					local doPlayerHaveWildCard = exports['coca_inventory']:HasItemInInventory("vuwildcard")
					local doPlayerHaveNormalCard = exports['coca_inventory']:HasItemInInventory("vunormalcard")
					local doPlayerHaveUtimateCard = exports['coca_inventory']:HasItemInInventory("vanillacard")

					if (doPlayerHaveUtimateCard) then
						cardTypePlayerHave = "vanillacard"
						TriggerServerEvent('coca_nightclub:buy')
					elseif (doPlayerHaveWildCard) then
						cardTypePlayerHave = "vuwildcard"
						TriggerServerEvent('coca_nightclub:buy')
					elseif doPlayerHaveNormalCard then
						cardTypePlayerHave = "vunormalcard"
						TriggerServerEvent('coca_nightclub:buy')
					else
						drawNativeNotification("~q~Oww!~w~ Where is your ~p~VU Card~w~")
					end
					Citizen.Wait(5000)
				elseif IsControlPressed(0, 38) and InCooldown then
					drawNativeNotification("You need to wait for you next ~q~Stripper~s~!")
					Citizen.Wait(5000)
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(600)

		local Player = PlayerPedId()
		local coords = GetEntityCoords(Player)
		local markerdist = #(coords - startingCoords)
		if markerdist < 20 then
			NearMarker = true
		else
			NearMarker = false
		end
		if markerdist < 2.2 then
			NearText = true
		else
			NearText = false
		end
	end
end)

RegisterNetEvent('coca_nightclub:lapdance', function()
	local Player = PlayerPedId()
	local lapdancerModel = GetRandomLapDancerPedModel()

	if(cardTypePlayerHave ~= "vanillacard") then
		exports['coca_inventory']:RemoveInventoryItem(cardTypePlayerHave, 1)
	end
	

	if (cardTypePlayerHave == 'vuwildcard' or cardTypePlayerHave == "vanillacard") then
		lapdancerModel = "s_f_y_stripper_10"
	end

	RequestModel(lapdancerModel)
	InCooldown = true

	TriggerServerEvent('coca_nightclub:active')
	while not HasModelLoaded(lapdancerModel) do
		Wait(20)
	end

	cardTypePlayerHave = nil

	local SpawnObject = CreatePed(4, lapdancerModel, 116.59, -1301.04, 28.05, false, true)
	SetEntityHeading(SpawnObject, 179.31)

	if lapdancerModel == 'csb_stripper_09' then
		SetPedComponentVariation(SpawnObject, 3, 0) -- Torso
		SetPedComponentVariation(SpawnObject, 6, -1) -- Underwear
		SetPedComponentVariation(SpawnObject, 8, 0) -- Underwear
	elseif lapdancerModel == 's_f_y_stripper_04' then
		SetPedComponentVariation(SpawnObject, 3, 0, 1, 2) -- Torso
		SetPedComponentVariation(SpawnObject, 6, -1) -- Underwear
	elseif lapdancerModel == 's_f_y_stripper_10' then
		SetPedComponentVariation(SpawnObject, 3, 0) -- Torso
		SetPedComponentVariation(SpawnObject, 4, 1) -- Shooes
		SetPedComponentVariation(SpawnObject, 6, 0) -- Underwear
		SetPedComponentVariation(SpawnObject, 10, 0) -- Decals ??
		SetPedComponentVariation(SpawnObject, 11, 0) -- Auxiliary parts for torso
		SetPedComponentVariation(SpawnObject, 9, 1)
	end

	RequestAnimDict("mini@strip_club@idles@stripper")
	while not HasAnimDictLoaded("mini@strip_club@idles@stripper") do
		Citizen.Wait(20)
	end
	TaskPlayAnim(SpawnObject, "mini@strip_club@idles@stripper", lapdancerModel, 8.0, -8.0, -1, 0, 0, false, false, false)

	InLapdance = true
	SetBlockingOfNonTemporaryEvents(SpawnObject, true)
	FreezeEntityPosition(SpawnObject, true)
	TaskGoToCoordAnyMeans(Player, 118.29, -1301.43, 28.42, 1.0, 0, 0, 786603, 1.0)
	Citizen.Wait(18000)

	FreezeEntityPosition(SpawnObject, false)
	TaskGoToCoordAnyMeans(SpawnObject, 118.0, -1300.3, 28.17, 174.93, 0, 0, 0, 0xbf800000)
	Citizen.Wait(2000)

	TaskGoToCoordAnyMeans(SpawnObject, 118.74, -1301.91, 29.27, 174.93, 0, 0, 0, 0xbf800000)
	Citizen.Wait(2100)

	FreezeEntityPosition(SpawnObject, true)
	SetEntityHeading(SpawnObject, 216.6)
	RequestAnimDict("mini@strip_club@private_dance@part2")
	while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
		Citizen.Wait(20)
	end
	TaskPlayAnim(SpawnObject, "mini@strip_club@private_dance@part2", "priv_dance_p2", 8.0, -8.0, -1, 0, 0, false, false,
		false)
	Citizen.Wait(30000)

	if (lapdancerModel == 's_f_y_stripper_10') then
		SetEntityHeading(SpawnObject, 40.68)

		RequestAnimDict("mini@strip_club@private_dance@part2")
		while not HasAnimDictLoaded("mini@strip_club@private_dance@part2") do
			Citizen.Wait(20)
		end
		TaskPlayAnim(SpawnObject, "mini@strip_club@private_dance@part2", "priv_dance_p2", 8.0, -8.0, -1, 0, 0, false,
			false,
			false)
		Citizen.Wait(30000)
		SetEntityHeading(SpawnObject, 216.6)
	end


	RequestAnimDict("mini@strip_club@backroom@")
	while not HasAnimDictLoaded("mini@strip_club@backroom@") do
		Citizen.Wait(20)
	end
	TaskPlayAnim(SpawnObject, "mini@strip_club@backroom@", "stripper_b_backroom_idle_b", 8.0, -8.0, -1, 0, 0, false,
		false, false)
	Citizen.Wait(5000)

	FreezeEntityPosition(SpawnObject, false)
	TaskGoToCoordAnyMeans(SpawnObject, 116.59, -1301.04, 28.17, 174.93, 0, 0, 0, 0xbf800000)
	Citizen.Wait(2000)

	RequestAnimDict("mini@strip_club@idles@stripper")
	while not HasAnimDictLoaded("mini@strip_club@idles@stripper") do
		Citizen.Wait(20)
	end
	TaskPlayAnim(SpawnObject, "mini@strip_club@idles@stripper", lapdancerModel, 8.0, -8.0, -1, 0, 0, false, false, false)
	SetEntityHeading(SpawnObject, 308.6)

	InLapdance = false
	TriggerEvent("coca_ui_player:RelieveStress", 25)
	

	-- Attach the cigarette to the NPC
	Wait(2000)
    PlayScenarioForDuration(SpawnObject, "WORLD_HUMAN_PROSTITUTE_HIGH_CLASS", 90000)
	Citizen.Wait(90000)

	InCooldown = false
	TriggerServerEvent('coca_nightclub:idle')
	
	DeleteEntity(SpawnObject)
end)

Citizen.CreateThread(function()
	while true do
		if not InLapdance then
			Citizen.Wait(1000)
		else
			Citizen.Wait(0)
		end

		if InLapdance then
			SetFollowPedCamViewMode(4)
			DisableControlAction(2, 24, true)
			DisableControlAction(2, 257, true)
			DisableControlAction(2, 25, true)
			DisableControlAction(2, 263, true)
			DisableControlAction(2, 32, true)
			DisableControlAction(2, 34, true)
			DisableControlAction(2, 8, true)
			DisableControlAction(2, 9, true)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		if not InLapdance then
			Citizen.Wait(1000)
		else
			Citizen.Wait(0)
		end

		if InLapdance then
			local Player = PlayerPedId()
			local coords = GetEntityCoords(Player)
			local sitdist = #(coords - vector3(118.75, -1301.97, 28.42))
			if sitdist < 2 then
				local dict = "mini@strip_club@lap_dance_2g@ld_2g_reach"
				RequestAnimDict(dict)

				while not HasAnimDictLoaded(dict) do
					Citizen.Wait(20)
				end

				-- Move and freeze player
				SetEntityCoords(Player, 119.06, -1302.66, 27.78)
				FreezeEntityPosition(Player, true)
				SetEntityHeading(Player, 40.0)

				-- Play the initial animation
				TaskPlayAnim(Player, dict, "ld_2g_sit_idle", 8.0, -8.0, -1, 1, 0, false, false, false)

				-- Keep the animation playing while InLapdance is true
				repeat
					TaskPlayAnim(Player, dict, "ld_2g_sit_idle", 8.0, -8.0, -1, 1, 0, false, false, false)

					Citizen.Wait(550)
				until not InLapdance

				-- Unfreeze player and reset position
				FreezeEntityPosition(Player, false)
				SetEntityCoords(Player, 118.75, -1301.99, 28.42)
				Citizen.Wait(200)
			end
		end
	end
end)


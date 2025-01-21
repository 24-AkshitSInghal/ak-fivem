--/huk Command
Citizen.CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/huk', 'Put your hands up and kneel.', {})
end)

local HUKToggle = false

RegisterNetEvent("HUKCommand")
AddEventHandler("HUKCommand", function()
	HUKToggle = not HUKToggle
	ToggleHUK(HUKToggle)
end)

function ToggleHUK(toggle)

local lPed = PlayerPedId()

if(toggle) then

		RequestAnimDict("random")
		RequestAnimDict("random@getawaydriver")
		while not HasAnimDictLoaded("random@getawaydriver") do
			Citizen.Wait(100)
		end

		TaskPlayAnim(lPed, "random@getawaydriver", "idle_2_hands_up", 1.0, -1, -1, 0, 0, 0, 0, 0)
			Citizen.Wait(3500)
			TaskPlayAnim(lPed, "random@getawaydriver", "idle_a", 1.0, -1, -1, 1, 0, 0, 0, 0)
			SetEnableHandcuffs(lPed, true)

	else
		if IsEntityPlayingAnim(lPed, "random@getawaydriver", "idle_a", 3) and IsEntityPlayingAnim(lPed, "mp_arresting", "idle", 3) then
			StopAnimTask(lPed, "random@getawaydriver", "idle_a", 3)
			StopAnimTask(lPed, "random@getawaydriver", "idle_2_hands_up", 3)
			TaskPlayAnim(lPed, "random@getawaydriver", "hands_up_2_idle", 1.0, -1, -1, 0, 0, 0, 0, 0)
			ClearPedSecondaryTask(lPed)
			TaskPlayAnim(lPed, "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
			SetEnableHandcuffs(lPed, true)

			elseif IsEntityPlayingAnim(lPed, "random@getawaydriver", "idle_a", 3) then
			StopAnimTask(lPed, "random@getawaydriver", "idle_a", 3)
			StopAnimTask(lPed, "random@getawaydriver", "idle_2_hands_up", 3)
			TaskPlayAnim(lPed, "random@getawaydriver", "hands_up_2_idle", 1.0, -1, -1, 0, 0, 0, 0, 0)
			ClearPedSecondaryTask(lPed)
			SetEnableHandcuffs(lPed, false)

		end
	end
end





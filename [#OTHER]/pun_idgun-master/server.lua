local requirePermissions = false

RegisterNetEvent("pun_idgun:c_s:RequestToggle")
AddEventHandler("pun_idgun:c_s:RequestToggle", function()
	local _source = source
	
		TriggerClientEvent("pun_idgun:s_c:ToggleAllowed", _source)
	
end)

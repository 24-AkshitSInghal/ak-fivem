local holdingCam = false
local holdingMic = false
local camModel = "prop_v_cam_01"
local camAnimDict = "missfinale_c2mcs_1"
local camAnimName = "fin_c2_mcs_1_camman"
local micModel = "p_ing_microphonel_01"
local micAnimDict = "missheistdocksprep1hold_cellphone"
local micAnimName = "hold_cellphone"
local mic_net = nil
local cam_net = nil
local UI = { x = 0.000, y = -0.001 }
local fov_max = 70.0
local fov_min = 5.0
local zoomspeed = 10.0
local speed_lr = 8.0
local speed_ud = 8.0
local fov = (fov_max + fov_min) * 0.5
local currentCameraMode = nil 

Citizen.CreateThread(function()
	while true do
		local sleep = 1500
		if holdingCam then
			sleep = 10
			ensureAnimDictLoaded(camAnimDict)

			if not IsEntityPlayingAnim(PlayerPedId(), camAnimDict, camAnimName, 3) then
				playAnimation(PlayerPedId(), camAnimDict, camAnimName)
			end

			disableCamActions()
		end
		Wait(sleep)
	end
end)

RegisterNetEvent("coca_job_news:GetCam", function()
	if not holdingCam then
		spawnAndAttachCamera()
	else
		removeCamera()
	end
end)

RegisterNetEvent("coca_job_news:GetMic", function()
	if not holdingMic then
		spawnAndAttachMicrophone()
	else
		removeMicrophone()
	end
end)

RegisterCommand('startmovie', function()
	if holdingCam and currentCameraMode == nil then
		startMovieCam()
	end
end)

RegisterCommand('startnews', function(src, args)
	local heading = table.concat(args, " ") or "BREAKING NEWS"
	if holdingCam and currentCameraMode == nil then
		startNewsCam(heading)
	end
end)


function ensureAnimDictLoaded(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(100)
	end
end

function playAnimation(ped, dict, name)
	TaskPlayAnim(ped, dict, name, 1.0, -1, -1, 50, 0, 0, 0, 0)
end

function disableCamActions()
	DisablePlayerFiring(PlayerId(), true)
	DisableControlAction(0, 25, true)
	DisableControlAction(0, 44, true)
	DisableControlAction(0, 37, true)
	SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
end

function spawnAndAttachCamera()
	RequestModel(GetHashKey(camModel))
	while not HasModelLoaded(GetHashKey(camModel)) do
		Citizen.Wait(100)
		RequestModel(GetHashKey(camModel))
	end

	local camspawned = createObject(camModel)
	attachEntityToPlayer(camspawned, 28422)
	playAnimation(PlayerPedId(), camAnimDict, camAnimName)
	cam_net = ObjToNet(camspawned)
	holdingCam = true
	DisplayNotification(
		"Start News cam by command ~o~/startnews (news heading)~s~ or Movie Cam by command ~o~/startmovie~s~")
end

function removeCamera()
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(NetToObj(cam_net), 1, 1)
	DeleteEntity(NetToObj(cam_net))
	cam_net = nil
	holdingCam = false
	currentCameraMode = nil 
end

function spawnAndAttachMicrophone()
	RequestModel(GetHashKey(micModel))
	while not HasModelLoaded(GetHashKey(micModel)) do
		Citizen.Wait(100)
		RequestModel(GetHashKey(micModel))
	end
	ensureAnimDictLoaded(micAnimDict)

	local micspawned = createObject(micModel)
	attachEntityToPlayer(micspawned, 60309, { 0.055, 0.05, 0.0, 240.0 })
	playAnimation(PlayerPedId(), micAnimDict, micAnimName)
	mic_net = ObjToNet(micspawned)
	holdingMic = true
end

function removeMicrophone()
	ClearPedSecondaryTask(PlayerPedId())
	DetachEntity(NetToObj(mic_net), 1, 1)
	DeleteEntity(NetToObj(mic_net))
	mic_net = nil
	holdingMic = false
end

function createObject(model)
	local plyCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, -5.0)
	return CreateObject(GetHashKey(model), plyCoords.x, plyCoords.y, plyCoords.z, true, true, true)
end

function attachEntityToPlayer(entity, boneIndex, offset)
	offset = offset or { 0.0, 0.0, 0.0 }
	AttachEntityToEntity(entity, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), boneIndex), offset[1], offset[2],
		offset[3], offset[4] or 0.0, 0.0, 0.0, true, true, false, true, 0, true)
end

function startMovieCam()
	local lPed = PlayerPedId()
	local movcamera = true

	currentCameraMode = "movie" 

	setupTimecycle()
	local scaleform = requestScaleform("security_camera")
	local cam1 = createFlyCamera(lPed)

	while movcamera and not IsEntityDead(lPed) do
		if IsControlJustPressed(0, 177) then
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
			movcamera = false
		end
		handleCamera(cam1, scaleform)
		Citizen.Wait(5)
	end

	resetCamera(scaleform, cam1)
	currentCameraMode = nil 
end

function startNewsCam(heading)
	local lPed = PlayerPedId()
	local newscamera = true

	currentCameraMode = "news" 

	setupTimecycle()
	local scaleform = requestScaleform("security_camera")
	local scaleform2 = requestScaleform("breaking_news")
	local cam2 = createFlyCamera(lPed)

	while newscamera and not IsEntityDead(lPed) do
		if IsControlJustPressed(1, 177) then
			PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
			newscamera = false
		end
		handleCamera(cam2, scaleform, scaleform2, heading)
		Citizen.Wait(5)
	end

	resetCamera(scaleform, cam2)
	currentCameraMode = nil -- Reset camera mode when news cam stops
end

function setupTimecycle()
	SetTimecycleModifier("default")
	SetTimecycleModifierStrength(0.3)
end

function requestScaleform(name)
	local scaleform = RequestScaleformMovie(name)
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(10)
	end
	return scaleform
end

function createFlyCamera(entity)
	local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)
	AttachCamToEntity(cam, entity, 0.0, 0.0, 1.0, true)
	SetCamRot(cam, 2.0, 1.0, GetEntityHeading(entity))
	SetCamFov(cam, fov)
	RenderScriptCams(true, false, 0, true, false)
	return cam
end

function handleCamera(cam, scaleform, scaleform2, heading)
	SetEntityRotation(PlayerPedId(), 0, 0, new_z, 2, true)
	local zoomvalue = (1.0 / (fov_max - fov_min)) * (fov - fov_min)
	CheckInputRotation(cam, zoomvalue)
	HandleZoom(cam)
	HideHUDThisFrame()

	if scaleform2 then
		DrawScaleformMovie(scaleform, 0.5, 0.52, 1.0, 1.07, 255, 255, 255, 255)
		DrawScaleformMovie(scaleform2, 0.5, 0.63, 1.0, 1.0, 255, 255, 255, 255)
		Breaking(heading)
	else
		drawRct(UI.x + 0.0, UI.y + 0.0, 0.99999, 0.15, 0, 0, 0, 255)
		drawRct(UI.x + 0.0, UI.y + 0.85, 0.99999, 0.16, 0, 0, 0, 255)
		DrawScaleformMovie(scaleform, 0.5, 0.52, 1.0, 1.07, 255, 255, 255, 255)
	end

	updateCameraRotation(PlayerPedId())
end

function resetCamera(scaleform, cam)
	ClearTimecycleModifier()
	fov = (fov_max + fov_min) * 0.5
	RenderScriptCams(false, false, 0, true, false)
	SetScaleformMovieAsNoLongerNeeded(scaleform)
	DestroyCam(cam, false)
	SetNightvision(false)
	SetSeethrough(false)
end

function updateCameraRotation(ped)
	local camHeading = GetGameplayCamRelativeHeading()
	local camPitch = GetGameplayCamRelativePitch()
	camPitch = math.max(math.min(42.0, camPitch), -70.0)
	camHeading = (camHeading + 180.0) / 360.0
	Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", (camPitch + 70.0) / 112.0)
	Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", (camHeading * -1.0) + 1.0)
end

function HideHUDThisFrame()
	for _, component in ipairs({ 1, 2, 3, 4, 6, 7, 8, 9, 13, 11, 12, 15, 18, 19 }) do
		HideHudComponentThisFrame(component)
	end
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX * -1.0 * speed_ud * (zoomvalue + 0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY * -1.0 * speed_lr * (zoomvalue + 0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	local control1, control2 = 241, 242
	if IsPedSittingInAnyVehicle(PlayerPedId()) then
		control1, control2 = 17, 16
	end

	if IsControlJustPressed(0, control1) then
		fov = math.max(fov - zoomspeed, fov_min)
	end
	if IsControlJustPressed(0, control2) then
		fov = math.min(fov + zoomspeed, fov_max)
	end

	local current_fov = GetCamFov(cam)
	if math.abs(fov - current_fov) < 0.1 then
		fov = current_fov
	end
	SetCamFov(cam, current_fov + (fov - current_fov) * 0.05)
end

function drawRct(x, y, width, height, r, g, b, a)
	DrawRect(x + width / 2, y + height / 2, width, height, r, g, b, a)
end

function Breaking(text)
	SetTextColour(255, 255, 255, 255)
	SetTextFont(8)
	SetTextScale(1.2, 1.2)
	SetTextWrap(0.0, 1.0)
	SetTextCentre(false)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 205)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.2, 0.85)
end

function DisplayNotification(string)
	SetTextComponentFormat("STRING")
	AddTextComponentString(string)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

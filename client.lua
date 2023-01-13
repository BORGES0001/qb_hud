-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local ped = 0
local voice = 2
local armour = 0
local street = ""
local health = 200
local hunger = 100
local thirst = 100
local talking = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATE
-----------------------------------------------------------------------------------------------------------------------------------------
local hours = 20
local minutes = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
local beltSpeed = 0
local seatLock = false
local entVelocity = 0
local beltLock = false
local showHud = false
local frequency = "OFF"
local compass = "N"
-- 1 = Whispering / 2 = Speaking / 3 = Shouting
local micOption = 1
-- 1 = Connected but not talking / 2 = Talking / 3 = Disconnected
local micState = 2
-- local texto = 0

function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE CAR LOCK
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:carLock")
AddEventHandler("vrp_hud:carLock", function(status)
	seatLock = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SALTYCHAT
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("SaltyChat_TalkStateChanged",function(bool)
	if bool and GetEntityHealth(PlayerPedId()) > 101 then
		micState = 1
	else
		micState = 2
	end
end)

AddEventHandler("SaltyChat_VoiceRangeChanged",function(meters,bool,ranges)
	if bool == 0 then
		micOption = 1
	elseif bool == 1 then 
		micOption = 2
	elseif bool == 2 then
		micOption = 3
	elseif bool == 3 then
		micOption = 4	
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:update")
AddEventHandler("vrp_hud:update", function(rHunger, rThirst)
	hunger, thirst = rHunger, rThirst
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUSHUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("statusHunger")
AddEventHandler("statusHunger",function(number)
	hunger = parseInt(number)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUSTHIRST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("statusThirst")
AddEventHandler("statusThirst",function(number)
	thirst = parseInt(number)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- GCPHONE
-----------------------------------------------------------------------------------------------------------------------------------------
local menu_celular = false
RegisterNetEvent("status:celular")
AddEventHandler("status:celular",function(status)
	menu_celular = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EVENTS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:Tokovoip")
AddEventHandler("vrp_hud:Tokovoip", function(option)
	if option == 1 then
		micOption = 2
	elseif option == 2 then
		micOption = 3
	elseif option == 3 then
		micOption = 1
	end
end)

RegisterNetEvent("hud:channel")
AddEventHandler("hud:channel", function(freq)
	if freq == 0 then
		freq = "NA"
	end
	frequency = freq
	updateDisplayHud()
end)

RegisterNetEvent("hudActived")
AddEventHandler("hudActived",function(status)
	updateDisplayHud()

	showHud = status

	SendNUIMessage({ showHud = showHud })
end)

RegisterNetEvent("vrp_hud:TokovoipTalking")
AddEventHandler("vrp_hud:TokovoipTalking", function(state)
	micState = state
	--updateDisplayHud()
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADUPDATE - 100
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local sleep = 500
		if IsPauseMenuActive() or IsScreenFadedOut() or menu_celular or not showHud then
			SendNUIMessage({ showHud = false })
		else          
			ped = PlayerPedId()
			armour = GetPedArmour(ped)
			heading = GetEntityHeading(ped)
			street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
			local year, month, dayOfWeek, hour, minute = GetLocalTime()
			health = GetEntityHealth(ped) - 100
			x,y,z = table.unpack(GetEntityCoords(ped))
			hours = GetClockHours()
			minutes = GetClockMinutes()
			
			if hours <= 9 then
				hours = "0"..hours
			end
		
			if minutes <= 9 then
				minutes = "0"..minutes
			end

			if health <= 1 then
				health = health - 0.999
			end

			if armour == 0 then
				armour = armour + 0.001
			end

			updateDisplayHud()

			if IsPedInAnyVehicle(ped) then
				sleep = 100
			end
		end
		Citizen.Wait(sleep)
	end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATEDISPLAYHUD
-----------------------------------------------------------------------------------------------------------------------------------------
function updateDisplayHud()
	local camRot = GetGameplayCamRot(0)
	local heading = parseInt(round(360.0 - ((camRot.z + 360.0) % 360.0)))

	if heading <= 90 then
		compass = "N"
	elseif heading <= 180 then
		compass = "L"
	elseif heading <= 240 then
		compass = "S"
	else
		compass = "O"
	end

	if IsPedInAnyVehicle(ped) then
		TriggerEvent("nation:hud")
		local vehicle = GetVehiclePedIsUsing(ped)
		local fuel = GetVehicleFuelLevel(vehicle)
		local engine = GetVehicleEngineHealth(vehicle) / 10
		local speed = GetEntitySpeed(vehicle) * 3.6
		local rpm = GetVehicleCurrentRpm(vehicle)

		SendNUIMessage({ showHud = showHud, vehicle = true, speaking = micOption, frequency = frequency, compass = compass, seatLock = seatLock, life = health , shield = armour, hunger = hunger, thirst = thirst, street = street, time = hours..":"..minutes, mic = micState, fuel = fuel, engine = engine, speed = parseInt(speed), rpm = rpm, seatBelt = beltLock })
	else
		SendNUIMessage({ showHud = showHud, vehicle = false, speaking = micOption, frequency = frequency, compass = compass, seatLock = seatLock, life = health, shield =  armour, hunger = hunger, thirst = thirst, street = street, time = hours..":"..minutes, mic = micState })
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    SetFlyThroughWindscreenParams(20.0, 2.0, 15.0, 15.0) -- Parametros para sair voando à aprox.. 120KM/h, mas pode ir mudando conforme seu gosto. Se deixar tudo em 0.00 seu boneco voa assim que entra no carro.
    SetPedConfigFlag(PlayerPedId(), 32, true)
end)

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		if IsPedInAnyVehicle(ped) then
			timeDistance = 5
			local veh = GetVehiclePedIsUsing(ped)
			local vehClass = GetVehicleClass(veh)
			if (vehClass >= 0 and vehClass <= 7) or (vehClass >= 9 and vehClass <= 12) or (vehClass >= 17 and vehClass <= 20) then
			

				if beltLock then
					DisableControlAction(1,75,true)
				end
			
				if IsControlJustReleased(1,47) then
					beltLock = not beltLock

					if not beltLock then
						TriggerEvent("vrp_sound:source","unbelt",0.5)
						SetPedConfigFlag(PlayerPedId(), 32, true) -- Habilita
					else
						TriggerEvent("vrp_sound:source","belt",0.5)
						SetPedConfigFlag(PlayerPedId(), 32, false)
					end
				end
			end
		end

		if IsPedInAnyVehicle(ped)  then
			if not IsMinimapRendering() then
				DisplayRadar(true)
			end
		else
			if IsMinimapRendering() then
				DisplayRadar(false)
			end
		end

		Citizen.Wait(timeDistance)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud",function(source,args)
	showHud = not showHud
	updateDisplayHud()
	SendNUIMessage({ hud = showHud })
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOVIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("movie",function(source,args)
	if exports["chat"]:statusChat() then
		showMovie = not showMovie

		updateDisplayHud()
		SendNUIMessage({ movie = showMovie })
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
local internet = true -- Váriavel que vai gerenciar se o jogador tem internet ou não.
local keys = {22,37,45,80,140,250,263,310,140,141,257,142,143,24,25,58} -- Teclas que vão ser desabilitadas quando a internet cair, verificar em https://docs.fivem.net/docs/game-references/controls/

function block()
    Citizen.CreateThread( function()
        while not internet do
            local ped = PlayerPedId()
            for k,v in pairs(keys) do 
                DisableControlAction(0, v, true) -- Nativa para desabilitar as teclas
            end
                DisablePlayerFiring(ped, true) -- Desativa o tiro
            Citizen.Wait(0)
        end
    end)
end

RegisterNUICallback("lock",function(data,cb) -- Callback quando a internet cai
    if not internet then
        return
    end
    internet = false -- Seta a váriavel de internet como false
    TriggerEvent('qb_connection:close', true) -- Evento a ser disparado pra a alguns scripts para fechar a nui, como inventário e coisas do gênero! 
    local ped = PlayerPedId()
    FreezeEntityPosition(ped,true) --  Freeza o jogador
    block() -- ativa a thread pra bloquear teclas 
    cb('ok')
end)

RegisterNUICallback("unlock",function(data,cb) -- Callback quando a internet volta
    if internet then
        return
    end
    internet = true -- Seta a váriavel de internet como true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped,false) -- Remove o freeze do jogador
	TriggerEvent('qb_connection:close', false) -- Ativa novamente funções como inv e tals
    cb('ok')
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- Minimap
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	RequestStreamedTextureDict("circlemap", false)
	while not HasStreamedTextureDictLoaded("circlemap") do
		Wait(100)
	end

	Citizen.Wait(10000)

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

	SetMinimapClipType(1)
	SetMinimapComponentPosition('minimap', 'L', 'B', 0.01, 0.0, 0.14, 0.27)
	SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.15, 0.15, 0.15, 0.15)
	SetMinimapComponentPosition('minimap_blur', 'L', 'B', 0.012, 0.022, 0.226, 0.292)

    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(10)
    SetRadarBigmapEnabled(false, false)
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)

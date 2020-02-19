----------------------------
--        VARIABLES
----------------------------

local PlayerTeam = nil

local CanSpawnVeh = true

local blips = {
	-- Example {title="", colour=, id=, x=, y=, z=},

	--{title="Example 1", colour=5, id=446, x = -347.291, y = -133.370, z = 38.009},
    {title="Hamajistan Camp", colour=16, id=310, x = 2414.78, y = 3331.33, z = 47.14},
    {title="Cops", colour=38, id=188, x = 2619.55, y = 3297.63, z = 45.17}
}

local Zones = {
    -- Example {title="", colour=, id=, x=, y=, z=},
    
    {title="Fight Area", colour=16, x = 2515.4, y = 3312.88, z = 50.82, size= 100.0}
}

----------------------------
--          NOTES
----------------------------

-- terro :  X:  2605.52/Y: 3308.04/Z: 53.76  // Heading : 76.46

-- ct :  X:  2424.7/Y: 3335.31/Z: 48.07  // Heading : 286.19

----------------------------
--        FUNCTION
----------------------------

local function setModel(_model)
    local model = _model
    if IsModelInCdimage(model) and IsModelValid(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        if model ~= "mp_f_freemode_01" and model ~= "mp_m_freemode_01" then 
            SetPedRandomComponentVariation(PlayerPedId(), true)
        else
            SetPedComponentVariation(PlayerPedId(), 11, 0, 240, 0)
            SetPedComponentVariation(PlayerPedId(), 8, 0, 240, 0)
            SetPedComponentVariation(PlayerPedId(), 11, 6, 1, 0)
        end
        SetModelAsNoLongerNeeded(model)
    end
end

function spawnCar(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(0)
    end

    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, x + 2, y + 2, z + 1, 0.0, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
end

function alert(msg) 
    SetTextComponentFormat("STRING")
    AddTextComponentString(msg)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function notify(type, string)
    exports['mythic_notify']:SendAlert(type, string)
end

function notifyWithTimer(type, string, time)
exports['mythic_notify']:SendAlert(type, string, time)
end

function giveWeapon(weaponHash)
    GiveWeaponToPed(PlayerPedId(), GetHashKey(weaponHash), 999, false, false --[[equips when gotten]])
end

function tpto(posX, posY, posZ)
    SetPedCoordsKeepVehicle(PlayerPedId(), posX, posY, posZ)
end

function nocop()
    ClearPlayerWantedLevel(PlayerPedId())
end

function ShowNotification(text)
	-- SetNotificationTextEntry("STRING")
	-- AddTextComponentString(text)
    -- DrawNotification(0,1)
    exports['mythic_notify']:SendAlert('error', text, 2500)
end

function respawn()
    if PlayerTeam == 'ct' then
        nocop()
        setModel('csb_mweather')
        tpto(2605.52, 3308.04, 53.76)
        -- Give weapons 
        giveWeapon('weapon_combatmg') 
        giveWeapon('weapon_carbinerifle')
        giveWeapon('weapon_grenade')
        giveWeapon('weapon_combatpistol')
        -- 
        notify('success', 'Respawned')
    elseif PlayerTeam == 't' then
        nocop()
        setModel('ig_hunter') 
        tpto(2424.7, 3335.31, 48.07)
        -- Give weapons 
        giveWeapon('weapon_mg')
        giveWeapon('weapon_assaultrifle')
        giveWeapon('weapon_pipebomb')
        giveWeapon('weapon_pistol_mk2')
        -- 
        notify('success', 'Respawned')
    else
        notify('error', 'Plz select a team')
    end
    
end

function showhelp()
    notifyWithTimer('inform', '--------------- HELP ---------------', 7000)
    notifyWithTimer('inform', '/team [t, ct] "t" is for Hamajistan & "ct" is for Supercops', 7000)
    notifyWithTimer('inform', '/car to spawn your car', 7000)
    notifyWithTimer('inform', '/respawn to respwan in your own camp', 7000)
end

function ActivateTimeLimiter()
    CanSpawnVeh = false
    Citizen.Wait(5000)
    CanSpawnVeh = true
end

----------------------------
--      FIVEM EVENTS
----------------------------

Citizen.CreateThread( function()
    while true do 
		local p = PlayerPedId()
		if (DoesEntityExist(p) and not IsEntityDead(p)) then
			local weapon = GetSelectedPedWeapon(p)
			local sniperRifle = GetHashKey("WEAPON_SNIPERRIFLE")
			local marksmanRifle = GetHashKey("WEAPON_MARKSMANRIFLE")
			local marksmanRifle2 = GetHashKey("WEAPON_MARKSMANRIFLE_MK2")
			local heavySniper = GetHashKey("WEAPON_HEAVYSNIPER") 
			local heavySniper2 = GetHashKey("WEAPON_HEAVYSNIPER_MK2")
			
			if (weapon == sniperRifle or 
			weapon == marksmanRifle or 
			weapon == marksmanRifle2 or 
			weapon == heavySniper or 
			weapon == heavySniper2) then
				-- do nothing = do not remove recticles from snipers
			else
				HideHudComponentThisFrame(14) -- remove crosshair
			end
		end
   		Citizen.Wait(0)
    end 
end )

Citizen.CreateThread(function()

    for _, info in pairs(blips) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 1.0)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
	
end)

Citizen.CreateThread(function()
    for k,v in pairs(Zones) do
        local blip = AddBlipForRadius(v.x, v.y, v.z , v.size) 
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, v.colour)
        SetBlipAlpha (blip, 128)
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite (blip, v.id)
        SetBlipDisplay(blip, 4)
        SetBlipScale  (blip, 0.9)
        SetBlipColour (blip, v.color)
        SetBlipAsShortRange(blip, true)
        --
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end
end)

Citizen.CreateThread(function()
    -- main loop popo
    timer = 500
	alreadyDead = false
    while true do
        Citizen.Wait(50)
		local playerPed = PlayerPedId()
        if IsEntityDead(playerPed) and not alreadyDead then
			killer = GetPedKiller(playerPed)
			killername = false
			for id = 0, 64 do
				if killer == GetPlayerPed(id) then
					killername = GetPlayerName(id)
				end				
			end
            if killer == playerPed then
                TriggerServerEvent('playerDied',0,0)
                Citizen.Wait(timer)
                respawn()
            elseif killername then
                TriggerServerEvent('playerDied',killername,1)
                Citizen.Wait(timer)
                respawn()
            else
                TriggerServerEvent('playerDied',0,2)
                Citizen.Wait(timer)
                respawn()
			end
			alreadyDead = true
		end
		if not IsEntityDead(playerPed) then
			alreadyDead = false
		end
	end
end)

----------------------------
--    REGISTRED EVENTS
----------------------------

AddEventHandler("playerSpawned", function()
    NetworkSetFriendlyFireOption(true)
    SetCanAttackFriendly(PlayerPedId(), true, true)
end)

RegisterCommand('team', function(source, args)
    if args[1]=="ct" then
        PlayerTeam = 'ct'
        nocop()
        setModel('csb_mweather')
        tpto(2605.52, 3308.04, 53.76)
        -- Give weapons 
        giveWeapon('weapon_combatmg') 
        giveWeapon('weapon_carbinerifle')
        giveWeapon('weapon_grenade')
        giveWeapon('weapon_combatpistol')
        -- 
        notify('success', 'Switched to Team : SUPER COPS')
    end
    if args[1]=='t' then
        PlayerTeam = 't'
        nocop()
        setModel('ig_hunter') 
        tpto(2424.7, 3335.31, 48.07)
        -- Give weapons 
        giveWeapon('weapon_mg')
        giveWeapon('weapon_assaultrifle')
        giveWeapon('weapon_pipebomb')
        giveWeapon('weapon_pistol_mk2')
        -- 
        notify('success', 'Switched to Team : HAMAJISTAN')
    end
end, false)

RegisterCommand('car', function(source, args)
    if CanSpawnVeh == true then
        if PlayerTeam == 't' then
            spawnCar('rebel2')
            notify('inform', 'You Spawned a car')
            ActivateTimeLimiter()
        elseif PlayerTeam == 'ct' then
            spawnCar('mesa3')
            notify('inform', 'You Spawned a car')
            ActivateTimeLimiter()
        else
            notify('error', 'Youre not in a team.')
        end
    else
        notify('error', 'You need to wait 10sec.')
    end
end, false)

RegisterNetEvent('showNotification')
AddEventHandler('showNotification', function(text)
	notify('inform', text)
end)

RegisterCommand('respawn', function(source)
    respawn()
end, false)

RegisterCommand('help', function()
    showhelp()
end)
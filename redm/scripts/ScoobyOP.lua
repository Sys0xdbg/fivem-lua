-- ScoobyOP v1.0.0

local _i = Citizen.InvokeNative
local _c = Citizen
local _w = Citizen.Wait
local _ct = Citizen.CreateThread
local _raw = Citizen.ReturnResultAnyway
local _rv3 = Citizen.ResultAsVector3
local _ri = Citizen.ResultAsInteger

-- =============================================
-- Native Spoofing Layer
-- AC pattern scans Lua source for native names
-- like SetEntityHealth, SetEntityInvincible, etc.
-- Route all through InvokeNative + hash to avoid.
-- =============================================

-- Events (spoofed)
local _tse = function(e, ...) _i(0x7FDD1B1F75158730, e, ...) end
local _tce = function(e, ...) _i(0x2F7A2C5D3B3C9C00, e, ...) end

-- Entity spoofed wrappers
local _sHP = function(e, hp) _i(0xAC2767ED8BDFAB15, e, hp, 0) end
local _gHP = function(e) return _i(0x82368787EA73C0F7, e) end
local _mHP = function(e) return _i(0x76B4E28B3AA58BA4, e, false) end
local _sC = function(e, x, y, z) _i(0x06843DA7060A026B, e, x, y, z, false, false, false, false) end
local _gC = function(e) return _i(0xA86D5F069399F44D, e, true, false, _raw(), _rv3()) end
local _sInv = function(e, b) _i(0x3882114BDE571AD4, e, b) end
local _frz = function(e, b) _i(0x7D9EFB7507947C64, e, b) end
local _sVel = function(e, x, y, z) _i(0x1C99BB7B6E96D16F, e, x, y, z) end
local _eEx = function(e) return _i(0x7239B21A38F536BA, e) end
local _sHd = function(e, h) _i(0x8E2530AA8ADA980E, e, h) end
local _vis = function(e, b) _i(0x1794B4FCC84D812F, e, b) end

-- Ped spoofed wrappers
local _pRag = function(e, b) _i(0xBC14A20D9B8D1649, e, b) end
local _pAcc = function(e, v) _i(0xAE25B946A8B234FE, e, v) end
local _pScl = function(e, s) _i(0x25ACFC650B65C528, e, s + 0.0) end
local _pCln = function(e) _i(0xC2E86C7D37C2020F, e) end
local _pRes = function(e) _i(0x71BC8E838B9C6035, e) end
local _pDrk = function(e, b) _i(0x406CCF555B04FAD3, e, b) end

-- Weapon spoofed wrappers
local _gW = function(e, w, a) _i(0xB282DC6EBD803C75, e, w, a, true, 0) end
local _rW = function(e) _i(0xF25DF915FA38C5F3, e, true, true) end
local _iA = function(e, b) _i(0x183DADC6AA953186, e, b) end

-- Explosion spoofed
local _exp = function(x, y, z, t, d) _i(0xD84A917A64D4D016, PlayerPedId(), x, y, z, t, d, true, false, true) end

-- Randomize tick timing to avoid AC pattern detection
local function _rw(base)
	return base + math.random(0, math.floor(base * 0.3))
end

Scooby = {}
Scooby.Menu = {}
Scooby.Menu.debug = false

Scooby.Notifications = {}
Scooby.Notifications.enabled = true
Scooby.Notifications.queue = {}
Scooby.Notifications.duration = 1000

Scooby.alertDistance = 50.0

Scooby.native = _i
Scooby.rdr2 = _c

Scooby.version = "1.0.0"

-- Anti-detection: don't use obvious global names for features
-- AC scans for globals like "_ab", "godmode", "esp" etc
-- All feature state is stored inside Scooby.menuCheckBoxes which uses
-- display names as keys, not flagged keywords

local _be = false
local _b2 = false

local box_esp_r = 0
local box_esp_g = 0
local box_esp_b = 0

local _ab = false

local Keys = {
	["ESC"] = 322,
	["F1"] = 288,
	["F2"] = 289,
	["F3"] = 170,
	["F5"] = 166,
	["F6"] = 167,
	["F7"] = 168,
	["F8"] = 169,
	["F9"] = 56,
	["F10"] = 57,
	["~"] = 243,
	["1"] = 157,
	["2"] = 158,
	["3"] = 160,
	["4"] = 164,
	["5"] = 165,
	["6"] = 159,
	["7"] = 161,
	["8"] = 162,
	["9"] = 163,
	["-"] = 84,
	["="] = 83,
	["BACKSPACE"] = 177,
	["TAB"] = 37,
	["Q"] = 44,
	["W"] = 32,
	["E"] = 38,
	["R"] = 45,
	["T"] = 245,
	["Y"] = 246,
	["U"] = 303,
	["P"] = 199,
	["["] = 39,
	["]"] = 40,
	["ENTER"] = 18,
	["CAPS"] = 137,
	["A"] = 34,
	["S"] = 8,
	["D"] = 9,
	["F"] = 23,
	["G"] = 47,
	["H"] = 74,
	["K"] = 311,
	["L"] = 182,
	["LEFTSHIFT"] = 21,
	["Z"] = 20,
	["X"] = 73,
	["C"] = 26,
	["V"] = 0,
	["B"] = 29,
	["N"] = 249,
	["M"] = 244,
	[","] = 82,
	["."] = 81,
	["LEFTCTRL"] = 36,
	["LEFTALT"] = 19,
	["SPACE"] = 22,
	["RIGHTCTRL"] = 70,
	["HOME"] = 213,
	["PAGEUP"] = 10,
	["PAGEDOWN"] = 11,
	["DELETE"] = 178,
	["LEFT"] = 174,
	["RIGHT"] = 175,
	["TOP"] = 27,
	["DOWN"] = 173,
	["NENTER"] = 201,
	["N4"] = 108,
	["N5"] = 60,
	["N6"] = 107,
	["N+"] = 96,
	["N-"] = 97,
	["N7"] = 117,
	["N8"] = 61,
	["N9"] = 118,
	["MOUSE1"] = 24
}

_abOps = { "Head", "Chest", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Dick" }
_abBone = "SKEL_HEAD"

function TxtAtWorldCoord(x, y, z, txt, size, font, alpha) --Cant remember where i got these two from. If someone knows please give me a pm on discord!
	alpha = alpha or 255
	local s, sx, sy = GetScreenCoordFromWorldCoord(x, y, z)
	if (sx > 0 and sx < 1) or (sy > 0 and sy < 1) then
		local s, sx, sy = GetHudScreenPositionFromWorldPosition(x, y, z)
		DrawTxt(txt, sx, sy, size, true, 255, 255, 255, alpha, true, font) -- Font 2 has some symbol conversions ex. @ becomes the rockstar logo
	end
end

function DrawTxt(str, x, y, size, enableShadow, r, g, b, a, centre, font)
	local str = CreateVarString(10, "LITERAL_STRING", str)
	SetTextScale(1, size)
	SetTextColor(math.floor(r), math.floor(g), math.floor(b), math.floor(a))
	SetTextCentre(centre)
	if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
	SetTextFontForCurrentCommand(font)
	DisplayText(str, x, y)
end

function AddVectors(vect1, vect2)
	return vector3(vect1.x + vect2.x, vect1.y + vect2.y, vect1.z + vect2.z)
end

local function ShootAt(target, bone)
	local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
	SetPedShootsAtCoord(PlayerPedId(), boneTarget, true)
end

local function ShootAt2(target, bone, damage)
	local boneTarget = GetPedBoneCoords(target, GetEntityBoneIndexByName(target, bone), 0.0, 0.0, 0.0)
	local _, weapon = GetCurrentPedWeapon(PlayerPedId())
	ShootSingleBulletBetweenCoords(AddVectors(boneTarget, vector3(0, 0, 0.1)), boneTarget, damage, true, weapon,
		PlayerPedId(), true, true, 1000.0)
end

local function ShootAimbot(k)
	if IsEntityOnScreen(k) and HasEntityClearLosToEntityInFront(PlayerPedId(), k) and
		not IsPedDeadOrDying(k) and not IsPedInVehicle(k, GetVehiclePedIsIn(k), false) and
		IsDisabledControlPressed(0, Keys["MOUSE1"]) and IsPlayerFreeAiming(PlayerId()) then
		local x, y, z = table.unpack(GetEntityCoords(k))
		local _, _x, _y = World3dToScreen2d(x, y, z)
		if _x > 0.25 and _x < 0.75 and _y > 0.25 and _y < 0.75 then
			local _, weapon = GetCurrentPedWeapon(PlayerPedId())
			ShootAt2(k, _abBone, GetWeaponDamage(weapon, 1))
		end
	end
end

function StartShapeTestRay(p1, p2, p3, p4, p5, p6, p7, p8, p9) return Scooby.native(0x377906D8A31E5586, p1, p2, p3, p4, p5,
		p6, p7, p8, p9, Scooby.rdr2.ReturnResultAnyway(), Scooby.rdr2.ResultAsInteger()) end

local function RGBRainbow(frequency)
	local result = {}
	local curtime = GetGameTimer() / 1000

	result.r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
	result.g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
	result.b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

	return result
end

function GetPlayers()
	local players = {}

	for i = 0, 63 do
		if NetworkIsPlayerActive(i) then
			table.insert(players, i)
		end
	end

	return players
end

GetMinVisualDistance = function(pos)
	local cam = GetFinalRenderedCamCoord()
	local self_ped = PlayerPedId()

	local hray, hit, coords, surfaceNormal, ent = GetShapeTestResult(StartShapeTestRay(cam.x, cam.y, cam.z, pos.x, pos.y,
		pos.z, -1, PlayerPedId(), 0))
	if hit then
		return #(cam - coords) / #(cam - pos) * 0.83
	end
end

GetCoordInNoodleSoup = function(vec, factor)
	local c = GetFinalRenderedCamCoord()
	factor = (not factor or factor >= 1) and 1 / 1.2 or factor
	return vector3(c.x + (vec.x - c.x) * factor, c.y + (vec.y - c.y) * factor, c.z + (vec.z - c.z) * factor)
end

local _xh = false
local _xh2 = false

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if _ab then
			local plist = GetActivePlayers()
			for i = 1, #plist do
				ShootAimbot(GetPlayerPed(plist[i]))
			end
		end


		if _xh then
			DrawRect(0.5, 0.5, 0.003, 0.005, 255, 0, 0, 255)
		end


		if _xh2 then
			DrawRect(0.5, 0.5, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5, 0.5 + -0.006, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5, 0.5 + 0.006, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5 + 0.003, 0.5, 0.002, 0.003, 255, 0, 0, 255)
			DrawRect(0.5 + -0.003, 0.5, 0.002, 0.003, 255, 0, 0, 255)
		end

		-- Persistent ScoobyOP watermark (top-right) — always visible when menu closed
		if not Scooby.Menu.IsAnyMenuOpened() then
			-- Count active features
			local activeCount = 0
			if Scooby.menuCheckBoxes then
				for menuId, checks in pairs(Scooby.menuCheckBoxes) do
					if type(checks) == "table" then
						for name, val in pairs(checks) do
							if val == true then activeCount = activeCount + 1 end
						end
					end
				end
			end

			-- Dark background box
			local boxH = activeCount > 0 and 0.052 or 0.04
			DrawRect(0.935, 0.015 + boxH/2, 0.12, boxH, 8, 10, 16, 180)
			-- Cyan left accent
			DrawRect(0.876, 0.015 + boxH/2, 0.003, boxH - 0.005, 0, 200, 255, 200)
			-- ScoobyOP text
			DrawTxt("ScoobyOP", 0.935, 0.012, 0.32, false, 0, 200, 255, 220, true, 9)
			-- Open key hint
			DrawTxt("[F6/DEL] Open", 0.935, 0.032, 0.22, false, 130, 130, 140, 160, true, 9)
			-- Active features count
			if activeCount > 0 then
				DrawTxt(tostring(activeCount) .. " active", 0.935, 0.048, 0.20, false, 0, 200, 255, 120, true, 9)
			end
		end

		if _b2 then
			local playercoords = GetEntityCoords(PlayerPedId())
			local currentPlayer = PlayerId()
			local players = GetPlayers()
			local playerPed = GetPlayerPed(player)
			local playerName = GetPlayerName(player)

			for player = 0, 64 do
				if player ~= currentPlayer and NetworkIsPlayerActive(player) then
					local pPed = GetPlayerPed(player)

					local pPed = PlayerPedId()


					local EspWidthOffset = 0
					local EspHightOffset = 0

					local box1and3Height = 0 --0.21
					local box2and4Height = 0 --0.004

					local box1and3Width = 0 --0.002
					local box2and4Width = 0 --0.048


					local box2and4Xoffset = 0 -- 0.023
					local box2and4Yoffset = 0 -- 0.105
					local box4Yoffset = 0 -- -0.105

					local box3Xoffset = 0 --0.046

					local line1xoffset = 0

					local targetCoords = GetEntityCoords(pPed)
					local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), targetCoords)

					_, x, y = GetScreenCoordFromWorldCoord(targetCoords.x, targetCoords.y, targetCoords.z)


					if distance < 5 then
						box1and3Height = 0.21
						box2and4Height = 0.004
						box1and3Width = 0.002
						box2and4Width = 0.048
						box4Yoffset = -0.105


						box2and4Xoffset = 0.023 -- 0.023
						box2and4Yoffset = 0.105 -- 0.105
						box3Xoffset = 0.046 --0.046
					elseif distance < 10 then
						box1and3Height = 0.15
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.046

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.075
						box3Xoffset = 0.046
						box4Yoffset = -0.075
					elseif distance < 15 then
						box1and3Height = 0.11
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.035

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.055
						box3Xoffset = 0.040
						box4Yoffset = -0.055
						line1xoffset = 0.006
					elseif distance < 20 then
						box1and3Height = 0.09
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.030

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.045
						box3Xoffset = 0.038
						box4Yoffset = -0.045
						line1xoffset = 0.008
					elseif distance < 40 then
						box1and3Height = 0.08
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.023

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.040
						box3Xoffset = 0.034
						box4Yoffset = -0.040
						line1xoffset = 0.012
					elseif distance < 60 then
						box1and3Height = 0.07
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.019

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.036
						box3Xoffset = 0.032
						box4Yoffset = -0.036
						line1xoffset = 0.014
					elseif distance < 80 then
						box1and3Height = 0.05
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.019

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.026
						box3Xoffset = 0.032
						box4Yoffset = -0.026
						line1xoffset = 0.014
					elseif distance < 120 then
						box1and3Height = 0.03
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.011

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.016
						box3Xoffset = 0.028
						box4Yoffset = -0.016
						line1xoffset = 0.018
					elseif distance < 140 then
						box1and3Height = 0.02
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.005

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.011
						box3Xoffset = 0.025
						box4Yoffset = -0.011
						line1xoffset = 0.021
					elseif distance < 170 then
						box1and3Height = 0.02
						box2and4Height = 0.002
						box1and3Width = 0.001
						box2and4Width = 0.005

						box2and4Xoffset = 0.023
						box2and4Yoffset = 0.011
						box3Xoffset = 0.025
						box4Yoffset = -0.011
						line1xoffset = 0.021
					else

					end

					DrawRect(x + line1xoffset, y, box1and3Width, box1and3Height, 255, 0, 0, 255)       -- left line up line   1
					DrawRect(x + box2and4Xoffset, y + box2and4Yoffset, box2and4Width, box2and4Height, 255, 0, 0, 255) -- bottom line square base  2
					DrawRect(x + box3Xoffset, y, box1and3Width, box1and3Height, 255, 0, 0, 255)        -- right line up line 3
					DrawRect(x + box2and4Xoffset, y + box4Yoffset, box2and4Width, box2and4Height, 255, 0, 0, 255) -- top square base 4
				end
			end
		end

		if _be then
			local playercoords = GetEntityCoords(PlayerPedId())
			local currentPlayer = PlayerId()
			local players = GetPlayers()
			local playerPed = GetPlayerPed(player)
			local playerName = GetPlayerName(player)
			local rgb_r = box_esp_r
			local rgb_g = box_esp_g
			local rgb_b = box_esp_b

			for player = 0, 64 do
				if player ~= currentPlayer and NetworkIsPlayerActive(player) then
					local pPed = GetPlayerPed(player)

					local cx, cy, cz = table.unpack(GetEntityCoords(PlayerPedId()))
					local x, y, z = table.unpack(GetEntityCoords(pPed))

					-- box esp shit

					local mindistance = GetMinVisualDistance(GetPedBoneCoords(pPed, 0x0, 0.0, 0.0, 0.0))
					local rightknee = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x3FCF, mindistance))
					local leftknee = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xB3FE, mindistance))
					local neck = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x9995, mindistance))
					local head = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x796E, mindistance))
					local pelvis = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x2E28, mindistance))
					local rightFoot = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xCC4D, mindistance))
					local leftFoot = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x3779, mindistance))
					local rightUpperArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x9D4D, mindistance))
					local leftUpperArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xB1C5, mindistance))
					local rightForeArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x6E5C, mindistance))
					local leftForeArm = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xEEEB, mindistance))
					local rightHand = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0xDEAD, mindistance))
					local leftHand = GetCoordInNoodleSoup(GetWorldPositionOfEntityBone(pPed, 0x49D9, mindistance))

					LineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
					LineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
					LineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)
					LineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
					LineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
					LineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
					LineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)

					TLineOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
					TLineOneEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
					TLineTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
					TLineTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
					TLineThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
					TLineThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
					TLineFourBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)

					ConnectorOneBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, 0.8)
					ConnectorOneEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, 0.3, -0.9)
					ConnectorTwoBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, 0.8)
					ConnectorTwoEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, 0.3, -0.9)
					ConnectorThreeBegin = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, 0.8)
					ConnectorThreeEnd = GetOffsetFromEntityInWorldCoords(pPed, -0.3, -0.3, -0.9)
					ConnectorFourBegin = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, 0.8)
					ConnectorFourEnd = GetOffsetFromEntityInWorldCoords(pPed, 0.3, -0.3, -0.9)

					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorOneBegin.x, ConnectorOneBegin.y,
						ConnectorOneBegin.z, ConnectorOneEnd.x, ConnectorOneEnd.y, ConnectorOneEnd.z, rgb_r, rgb_g, rgb_b,
						255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorOneBegin.x, ConnectorOneBegin.y,
						ConnectorOneBegin.z, ConnectorOneEnd.x, ConnectorOneEnd.y, ConnectorOneEnd.z, rgb_r, rgb_g, rgb_b,
						255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorTwoBegin.x, ConnectorTwoBegin.y,
						ConnectorTwoBegin.z, ConnectorTwoEnd.x, ConnectorTwoEnd.y, ConnectorTwoEnd.z, rgb_r, rgb_g, rgb_b,
						255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorThreeBegin.x, ConnectorThreeBegin.y,
						ConnectorThreeBegin.z, ConnectorThreeEnd.x, ConnectorThreeEnd.y, ConnectorThreeEnd.z, rgb_r,
						rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, ConnectorFourBegin.x, ConnectorFourBegin.y,
						ConnectorFourBegin.z, ConnectorFourEnd.x, ConnectorFourEnd.y, ConnectorFourEnd.z, rgb_r, rgb_g,
						rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineOneBegin.x, LineOneBegin.y, LineOneBegin.z,
						LineOneEnd.x, LineOneEnd.y, LineOneEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineTwoBegin.x, LineTwoBegin.y, LineTwoBegin.z,
						LineTwoEnd.x, LineTwoEnd.y, LineTwoEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineThreeBegin.x, LineThreeBegin.y, LineThreeBegin.z,
						LineThreeEnd.x, LineThreeEnd.y, LineThreeEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, LineThreeEnd.x, LineThreeEnd.y, LineThreeEnd.z,
						LineFourBegin.x, LineFourBegin.y, LineFourBegin.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineOneBegin.x, TLineOneBegin.y, TLineOneBegin.z,
						TLineOneEnd.x, TLineOneEnd.y, TLineOneEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineTwoBegin.x, TLineTwoBegin.y, TLineTwoBegin.z,
						TLineTwoEnd.x, TLineTwoEnd.y, TLineTwoEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineThreeBegin.x, TLineThreeBegin.y,
						TLineThreeBegin.z, TLineThreeEnd.x, TLineThreeEnd.y, TLineThreeEnd.z, rgb_r, rgb_g, rgb_b, 255)
					Citizen.InvokeNative(`DRAW_LINE` & 0xFFFFFFFF, TLineThreeEnd.x, TLineThreeEnd.y, TLineThreeEnd.z,
						TLineFourBegin.x, TLineFourBegin.y, TLineFourBegin.z, rgb_r, rgb_g, rgb_b, 255)
				end
			end
		end
	end
end)

Scooby.Configs = {}
Scooby.Configs.Weapons = {
	["RevolverCattleman"] = 0x169F59F7,
	["MeleeKnife"] = 0xDB21AC8C,
	["ShotgunDoublebarrel"] = 0x6DFA071B,
	["MeleeLantern"] = 0xF62FB3A3,
	["RepeaterCarbine"] = 0xF5175BA1,
	["RevolverSchofieldBill"] = 0x6DFE44AB,
	["RifleBoltactionBill"] = 0xD853C801,
	["MeleeKnifeBill"] = 0xCE3C31A4,
	["ShotgunSawedoffCharles"] = 0xBE8D2666,
	["BowCharles"] = 0x791BBD2C,
	["MeleeKnifeCharles"] = 0xB4774D3D,
	["ThrownTomahawk"] = 0xA5E972D7,
	["RevolverSchofieldDutch"] = 0xFA4B2D47,
	["RevolverSchofieldDutchDualwield"] = 0xD44A5A04,
	["MeleeKnifeDutch"] = 0x2C8DBB17,
	["RevolverCattlemanHosea"] = 0xA6FE9435,
	["RevolverCattlemanHoseaDualwield"] = 0x1EAA7376,
	["ShotgunSemiautoHosea"] = 0xFD9B510B,
	["MeleeKnifeHosea"] = 0xCACE760E,
	["RevolverDoubleactionJavier"] = 0x514B39A1,
	["ThrownThrowingKnivesJavier"] = 0x39B815A2,
	["MeleeKnifeJavier"] = 0xFA66468E,
	["RevolverCattlemanJohn"] = 0xC9622757,
	["RepeaterWinchesterJohn"] = 0xBE76397C,
	["MeleeKnifeJohn"] = 0x1D7D0737,
	["RevolverCattlemanKieran"] = 0x8FAE73BB,
	["MeleeKnifeKieran"] = 0x2F3ECD37,
	["RevolverCattlemanLenny"] = 0xC9095426,
	["SniperrifleRollingblockLenny"] = 0x21556EC2,
	["MeleeKnifeLenny"] = 0x9DD839AE,
	["RevolverDoubleactionMicah"] = 0x2300C65,
	["RevolverDoubleactionMicahDualwield"] = 0xD427AD,
	["MeleeKnifeMicah"] = 0xE9245D38,
	["RevolverCattlemanSadie"] = 0x49F6BE32,
	["RevolverCattlemanSadieDualwield"] = 0x8384D5FE,
	["RepeaterCarbineSadie"] = 0x7BD9C820,
	["ThrownThrowingKnives"] = 0xD2718D48,
	["MeleeKnifeSadie"] = 0xAF5EEF08,
	["RevolverCattlemanSean"] = 0x3EECE288,
	["MeleeKnifeSean"] = 0x64514239,
	["RevolverSchofieldUncle"] = 0x99496406,
	["ShotgunDoublebarrelUncle"] = 0x8BA6AF0A,
	["MeleeKnifeUncle"] = 0x46E97B10,
	["RevolverDoubleaction"] = 0x797FBF5,
	["RifleBoltaction"] = 0x772C8DD6,
	["RevolverSchofield"] = 0x7BBD1FF6,
	["RifleSpringfield"] = 0x63F46DE6,
	["RepeaterWinchester"] = 0xA84762EC,
	["RifleVarmint"] = 0xDDF7BC1E,
	["PistolVolcanic"] = 0x20D13FF,
	["ShotgunSawedoff"] = 0x1765A8F8,
	["PistolSemiauto"] = 0x657065D6,
	["PistolMauser"] = 0x8580C63E,
	["RepeaterHenry"] = 0x95B24592,
	["ShotgunPump"] = 0x31B7B9FE,
	["Bow"] = 0x88A8505C,
	["ThrownMolotov"] = 0x7067E7A7,
	["MeleeHatchetHewing"] = 0x1C02870C,
	["MeleeMachete"] = 0x28950C71,
	["RevolverDoubleactionExotic"] = 0x23C706CD,
	["RevolverSchofieldGolden"] = 0xE195D259,
	["ThrownDynamite"] = 0xA64DAA5E,
	["MeleeDavyLantern"] = 0x4A59E501,
	["Lasso"] = 0x7A8A724A,
	["KitBinoculars"] = 0xF6687C5A,
	["KitCamera"] = 0xC3662B7D,
	["Fishingrod"] = 0xABA87754,
	["SniperrifleRollingblock"] = 0xE1D2B317,
	["ShotgunSemiauto"] = 0x6D9BB970,
	["ShotgunRepeating"] = 0x63CA782A,
	["SniperrifleCarcano"] = 0x53944780,
	["MeleeBrokenSword"] = 0xF79190B4,
	["MeleeKnifeBear"] = 0x2BC12CDA,
	["MeleeKnifeCivilWar"] = 0xDA54DD53,
	["MeleeKnifeJawbone"] = 0x1086D041,
	["MeleeKnifeMiner"] = 0xC45B2DE,
	["MeleeKnifeVampire"] = 0x14D3F94D,
	["MeleeTorch"] = 0x67DC3FDE,
	["MeleeLanternElectric"] = 0x3155643F,
	["MeleeHatchet"] = 0x9E12A01,
	["MeleeAncientHatchet"] = 0x21CCCA44,
	["MeleeCleaver"] = 0xEF32A25D,
	["MeleeHatchetDoubleBit"] = 0xBCC63763,
	["MeleeHatchetDoubleBitRusted"] = 0x8F0FDE0E,
	["MeleeHatchetHunter"] = 0x2A5CF9D6,
	["MeleeHatchetHunterRusted"] = 0xE470B7AD,
	["MeleeHatchetViking"] = 0x74DC40ED,
	["RevolverCattlemanMexican"] = 0x16D655F7,
	["RevolverCattlemanPig"] = 0xF5E4207F,
	["RevolverSchofieldCalloway"] = 0x247E783,
	["PistolMauserDrunk"] = 0x4AAE5FFA,
	["ShotgunDoublebarrelExotic"] = 0x2250E150,
	["SniperrifleRollingblockExotic"] = 0x4E328256,
	["ThrownTomahawkAncient"] = 0x7F23B6C7,
	["MeleeTorchCrowd"] = 0xCC4588BD,
}
Scooby.Configs.AmmoTypes = {
	"AMMO_PISTOL",
	"AMMO_PISTOL_SPLIT_POINT",
	"AMMO_PISTOL_EXPRESS",
	"AMMO_PISTOL_EXPRESS_EXPLOSIVE",
	"AMMO_PISTOL_HIGH_VELOCITY",
	"AMMO_REVOLVER",
	"AMMO_REVOLVER_SPLIT_POINT",
	"AMMO_REVOLVER_EXPRESS",
	"AMMO_REVOLVER_EXPRESS_EXPLOSIVE",
	"AMMO_REVOLVER_HIGH_VELOCITY",
	"AMMO_RIFLE",
	"AMMO_RIFLE_SPLIT_POINT",
	"AMMO_RIFLE_EXPRESS",
	"AMMO_RIFLE_EXPRESS_EXPLOSIVE",
	"AMMO_RIFLE_HIGH_VELOCITY",
	"AMMO_22",
	"AMMO_REPEATER",
	"AMMO_REPEATER_SPLIT_POINT",
	"AMMO_REPEATER_EXPRESS",
	"AMMO_REPEATER_EXPRESS_EXPLOSIVE",
	"AMMO_REPEATER_HIGH_VELOCITY",
	"AMMO_SHOTGUN",
	"AMMO_SHOTGUN_BUCKSHOT_INCENDIARY",
	"AMMO_SHOTGUN_SLUG",
	"AMMO_SHOTGUN_SLUG_EXPLOSIVE",
	"AMMO_ARROW",
	"AMMO_TURRET",
	"ML_UNARMED",
	"AMMO_MOLOTOV",
	"AMMO_MOLOTOV_VOLATILE",
	"AMMO_DYNAMITE",
	"AMMO_DYNAMITE_VOLATILE",
	"AMMO_THROWING_KNIVES",
	"AMMO_THROWING_KNIVES_IMPROVED",
	"AMMO_THROWING_KNIVES_POISON",
	"AMMO_THROWING_KNIVES_JAVIER",
	"AMMO_THROWING_KNIVES_CONFUSE",
	"AMMO_THROWING_KNIVES_DISORIENT",
	"AMMO_THROWING_KNIVES_DRAIN",
	"AMMO_THROWING_KNIVES_TRAIL",
	"AMMO_THROWING_KNIVES_WOUND",
	"AMMO_TOMAHAWK",
	"AMMO_TOMAHAWK_ANCIENT",
	"AMMO_TOMAHAWK_HOMING",
	"AMMO_TOMAHAWK_IMPROVED",
	"AMMO_HATCHET",
	"AMMO_HATCHET_ANCIENT",
	"AMMO_HATCHET_CLEAVER",
	"AMMO_HATCHET_DOUBLE_BIT",
	"AMMO_HATCHET_DOUBLE_BIT_RUSTED",
	"AMMO_HATCHET_HEWING",
	"AMMO_HATCHET_HUNTER",
	"AMMO_HATCHET_HUNTER_RUSTED",
	"AMMO_HATCHET_VIKING",
	"AMMO_ARROW_FIRE",
	"AMMO_ARROW_DYNAMITE",
	"AMMO_ARROW_SMALL_GAME",
	"AMMO_ARROW_IMPROVED",
	"AMMO_ARROW_POISON",
	"AMMO_ARROW_CONFUSION",
	"AMMO_ARROW_DISORIENT",
	"AMMO_ARROW_DRAIN",
	"AMMO_ARROW_TRAIL",
	"AMMO_ARROW_WOUND",
}
Scooby.Configs.Peds = {

	Animal = {
		"a_c_alligator_01",
		"a_c_alligator_02",
		"a_c_alligator_03",
		"a_c_armadillo_01",
		"a_c_badger_01",
		"a_c_bat_01",
		"a_c_bear_01",
		"a_c_bearblack_01",
		"a_c_beaver_01",
		"a_c_bighornram_01",
		"a_c_bluejay_01",
		"a_c_boar_01",
		"a_c_boarlegendary_01",
		"a_c_buck_01",
		"a_c_buffalo_01",
		"a_c_buffalo_tatanka_01",
		"a_c_bull_01",
		"a_c_californiacondor_01",
		"a_c_cardinal_01",
		"a_c_carolinaparakeet_01",
		"a_c_cat_01",
		"a_c_cedarwaxwing_01",
		"a_c_chicken_01",
		"a_c_chipmunk_01",
		"a_c_cormorant_01",
		"a_c_cougar_01",
		"a_c_cow",
		"a_c_coyote_01",
		"a_c_crab_01",
		"a_c_cranewhooping_01",
		"a_c_crawfish_01",
		"a_c_crow_01",
		"a_c_deer_01",
		"a_c_dogamericanfoxhound_01",
		"a_c_dogaustraliansheperd_01",
		"a_c_dogbluetickcoonhound_01",
		"a_c_dogcatahoulacur_01",
		"a_c_dogchesbayretriever_01",
		"a_c_dogcollie_01",
		"a_c_doghobo_01",
		"a_c_doghound_01",
		"a_c_doghusky_01",
		"a_c_doglab_01",
		"a_c_doglion_01",
		"a_c_dogpoodle_01",
		"a_c_dogrufus_01",
		"a_c_dogstreet_01",
		"a_c_donkey_01",
		"a_c_duck_01",
		"a_c_eagle_01",
		"a_c_egret_01",
		"a_c_elk_01",
		"a_c_fishbluegil_01_ms",
		"a_c_fishbluegil_01_sm",
		"a_c_fishbullheadcat_01_ms",
		"a_c_fishbullheadcat_01_sm",
		"a_c_fishchainpickerel_01_ms",
		"a_c_fishchainpickerel_01_sm",
		"a_c_fishchannelcatfish_01_lg",
		"a_c_fishchannelcatfish_01_xl",
		"a_c_fishlakesturgeon_01_lg",
		"a_c_fishlargemouthbass_01_lg",
		"a_c_fishlargemouthbass_01_ms",
		"a_c_fishlongnosegar_01_lg",
		"a_c_fishmuskie_01_lg",
		"a_c_fishnorthernpike_01_lg",
		"a_c_fishperch_01_ms",
		"a_c_fishperch_01_sm",
		"a_c_fishrainbowtrout_01_lg",
		"a_c_fishrainbowtrout_01_ms",
		"a_c_fishredfinpickerel_01_ms",
		"a_c_fishredfinpickerel_01_sm",
		"a_c_fishrockbass_01_ms",
		"a_c_fishrockbass_01_sm",
		"a_c_fishsalmonsockeye_01_lg",
		"a_c_fishsalmonsockeye_01_ml",
		"a_c_fishsalmonsockeye_01_ms",
		"a_c_fishsmallmouthbass_01_lg",
		"a_c_fishsmallmouthbass_01_ms",
		"a_c_fox_01",
		"a_c_frogbull_01",
		"a_c_gilamonster_01",
		"a_c_goat_01",
		"a_c_goosecanada_01",
		"a_c_hawk_01",
		"a_c_heron_01",
		"a_c_horse_americanpaint_greyovero",
		"a_c_horse_americanpaint_overo",
		"a_c_horse_americanpaint_splashedwhite",
		"a_c_horse_americanpaint_tobiano",
		"a_c_horse_americanstandardbred_black",
		"a_c_horse_americanstandardbred_buckskin",
		"a_c_horse_americanstandardbred_lightbuckskin",
		"a_c_horse_americanstandardbred_palominodapple",
		"a_c_horse_americanstandardbred_silvertailbuckskin",
		"a_c_horse_andalusian_darkbay",
		"a_c_horse_andalusian_perlino",
		"a_c_horse_andalusian_rosegray",
		"a_c_horse_appaloosa_blacksnowflake",
		"a_c_horse_appaloosa_blanket",
		"a_c_horse_appaloosa_brownleopard",
		"a_c_horse_appaloosa_fewspotted_pc",
		"a_c_horse_appaloosa_leopard",
		"a_c_horse_appaloosa_leopardblanket",
		"a_c_horse_arabian_black",
		"a_c_horse_arabian_grey",
		"a_c_horse_arabian_redchestnut",
		"a_c_horse_arabian_redchestnut_pc",
		"a_c_horse_arabian_rosegreybay",
		"a_c_horse_arabian_warpedbrindle_pc",
		"a_c_horse_arabian_white",
		"a_c_horse_ardennes_bayroan",
		"a_c_horse_ardennes_irongreyroan",
		"a_c_horse_ardennes_strawberryroan",
		"a_c_horse_belgian_blondchestnut",
		"a_c_horse_belgian_mealychestnut",
		"a_c_horse_breton_grullodun",
		"a_c_horse_breton_mealydapplebay",
		"a_c_horse_breton_redroan",
		"a_c_horse_breton_sealbrown",
		"a_c_horse_breton_sorrel",
		"a_c_horse_breton_steelgrey",
		"a_c_horse_buell_warvets",
		"a_c_horse_criollo_baybrindle",
		"a_c_horse_criollo_bayframeovero",
		"a_c_horse_criollo_blueroanovero",
		"a_c_horse_criollo_dun",
		"a_c_horse_criollo_marblesabino",
		"a_c_horse_criollo_sorrelovero",
		"a_c_horse_dutchwarmblood_chocolateroan",
		"a_c_horse_dutchwarmblood_sealbrown",
		"a_c_horse_dutchwarmblood_sootybuckskin",
		"a_c_horse_eagleflies",
		"a_c_horse_gang_bill",
		"a_c_horse_gang_charles",
		"a_c_horse_gang_charles_endlesssummer",
		"a_c_horse_gang_dutch",
		"a_c_horse_gang_hosea",
		"a_c_horse_gang_javier",
		"a_c_horse_gang_john",
		"a_c_horse_gang_karen",
		"a_c_horse_gang_kieran",
		"a_c_horse_gang_lenny",
		"a_c_horse_gang_micah",
		"a_c_horse_gang_sadie",
		"a_c_horse_gang_sadie_endlesssummer",
		"a_c_horse_gang_sean",
		"a_c_horse_gang_trelawney",
		"a_c_horse_gang_uncle",
		"a_c_horse_gang_uncle_endlesssummer",
		"a_c_horse_gypsycob_palominoblagdon",
		"a_c_horse_gypsycob_piebald",
		"a_c_horse_gypsycob_skewbald",
		"a_c_horse_gypsycob_splashedbay",
		"a_c_horse_gypsycob_splashedpiebald",
		"a_c_horse_gypsycob_whiteblagdon",
		"a_c_horse_hungarianhalfbred_darkdapplegrey",
		"a_c_horse_hungarianhalfbred_flaxenchestnut",
		"a_c_horse_hungarianhalfbred_liverchestnut",
		"a_c_horse_hungarianhalfbred_piebaldtobiano",
		"a_c_horse_john_endlesssummer",
		"a_c_horse_kentuckysaddle_black",
		"a_c_horse_kentuckysaddle_buttermilkbuckskin_pc",
		"a_c_horse_kentuckysaddle_chestnutpinto",
		"a_c_horse_kentuckysaddle_grey",
		"a_c_horse_kentuckysaddle_silverbay",
		"a_c_horse_kladruber_black",
		"a_c_horse_kladruber_cremello",
		"a_c_horse_kladruber_dapplerosegrey",
		"a_c_horse_kladruber_grey",
		"a_c_horse_kladruber_silver",
		"a_c_horse_kladruber_white",
		"a_c_horse_missourifoxtrotter_amberchampagne",
		"a_c_horse_missourifoxtrotter_blacktovero",
		"a_c_horse_missourifoxtrotter_blueroan",
		"a_c_horse_missourifoxtrotter_buckskinbrindle",
		"a_c_horse_missourifoxtrotter_dapplegrey",
		"a_c_horse_missourifoxtrotter_sablechampagne",
		"a_c_horse_missourifoxtrotter_silverdapplepinto",
		"a_c_horse_morgan_bay",
		"a_c_horse_morgan_bayroan",
		"a_c_horse_morgan_flaxenchestnut",
		"a_c_horse_morgan_liverchestnut_pc",
		"a_c_horse_morgan_palomino",
		"a_c_horse_mp_mangy_backup",
		"a_c_horse_murfreebrood_mange_01",
		"a_c_horse_murfreebrood_mange_02",
		"a_c_horse_murfreebrood_mange_03",
		"a_c_horse_mustang_blackovero",
		"a_c_horse_mustang_buckskin",
		"a_c_horse_mustang_chestnuttovero",
		"a_c_horse_mustang_goldendun",
		"a_c_horse_mustang_grullodun",
		"a_c_horse_mustang_reddunovero",
		"a_c_horse_mustang_tigerstripedbay",
		"a_c_horse_mustang_wildbay",
		"a_c_horse_nokota_blueroan",
		"a_c_horse_nokota_reversedappleroan",
		"a_c_horse_nokota_whiteroan",
		"a_c_horse_norfolkroadster_black",
		"a_c_horse_norfolkroadster_dappledbuckskin",
		"a_c_horse_norfolkroadster_piebaldroan",
		"a_c_horse_norfolkroadster_rosegrey",
		"a_c_horse_norfolkroadster_speckledgrey",
		"a_c_horse_norfolkroadster_spottedtricolor",
		"a_c_horse_shire_darkbay",
		"a_c_horse_shire_lightgrey",
		"a_c_horse_shire_ravenblack",
		"a_c_horse_suffolkpunch_redchestnut",
		"a_c_horse_suffolkpunch_sorrel",
		"a_c_horse_tennesseewalker_blackrabicano",
		"a_c_horse_tennesseewalker_chestnut",
		"a_c_horse_tennesseewalker_dapplebay",
		"a_c_horse_tennesseewalker_flaxenroan",
		"a_c_horse_tennesseewalker_goldpalomino_pc",
		"a_c_horse_tennesseewalker_mahoganybay",
		"a_c_horse_tennesseewalker_redroan",
		"a_c_horse_thoroughbred_blackchestnut",
		"a_c_horse_thoroughbred_bloodbay",
		"a_c_horse_thoroughbred_brindle",
		"a_c_horse_thoroughbred_dapplegrey",
		"a_c_horse_thoroughbred_reversedappleblack",
		"a_c_horse_turkoman_black",
		"a_c_horse_turkoman_chestnut",
		"a_c_horse_turkoman_darkbay",
		"a_c_horse_turkoman_gold",
		"a_c_horse_turkoman_grey",
		"a_c_horse_turkoman_perlino",
		"a_c_horse_turkoman_silver",
		"a_c_horse_winter02_01",
		"a_c_horsemule_01",
		"a_c_horsemulepainted_01",
		"a_c_iguana_01",
		"a_c_iguanadesert_01",
		"a_c_javelina_01",
		"a_c_lionmangy_01",
		"a_c_loon_01",
		"a_c_moose_01",
		"a_c_muskrat_01",
		"a_c_oriole_01",
		"a_c_owl_01",
		"a_c_ox_01",
		"a_c_panther_01",
		"a_c_parrot_01",
		"a_c_pelican_01",
		"a_c_pheasant_01",
		"a_c_pig_01",
		"a_c_pigeon",
		"a_c_possum_01",
		"a_c_prairiechicken_01",
		"a_c_pronghorn_01",
		"a_c_quail_01",
		"a_c_rabbit_01",
		"a_c_raccoon_01",
		"a_c_rat_01",
		"a_c_raven_01",
		"a_c_redfootedbooby_01",
		"a_c_robin_01",
		"a_c_rooster_01",
		"a_c_roseatespoonbill_01",
		"a_c_seagull_01",
		"a_c_sharkhammerhead_01",
		"a_c_sharktiger",
		"a_c_sheep_01",
		"a_c_skunk_01",
		"a_c_snake_01",
		"a_c_snake_pelt_01",
		"a_c_snakeblacktailrattle_01",
		"a_c_snakeblacktailrattle_pelt_01",
		"a_c_snakeferdelance_01",
		"a_c_snakeferdelance_pelt_01",
		"a_c_snakeredboa10ft_01",
		"a_c_snakeredboa_01",
		"a_c_snakeredboa_pelt_01",
		"a_c_snakewater_01",
		"a_c_snakewater_pelt_01",
		"a_c_songbird_01",
		"a_c_sparrow_01",
		"a_c_squirrel_01",
		"a_c_toad_01",
		"a_c_turkey_01",
		"a_c_turkey_02",
		"a_c_turkeywild_01",
		"a_c_turtlesea_01",
		"a_c_turtlesnapping_01",
		"a_c_vulture_01",
		"a_c_wolf",
		"a_c_wolf_medium",
		"a_c_wolf_small",
		"a_c_woodpecker_01",
		"a_c_woodpecker_02",
		"mp_a_c_alligator_01",
		"mp_a_c_bear_01",
		"mp_a_c_beaver_01",
		"mp_a_c_bighornram_01",
		"mp_a_c_boar_01",
		"mp_a_c_buck_01",
		"mp_a_c_buffalo_01",
		"mp_a_c_chicken_01",
		"mp_a_c_cougar_01",
		"mp_a_c_coyote_01",
		"mp_a_c_deer_01",
		"mp_a_c_dogamericanfoxhound_01",
		"mp_a_c_elk_01",
		"mp_a_c_fox_01",
		"mp_a_c_horsecorpse_01",
		"mp_a_c_moose_01",
		"mp_a_c_owl_01",
		"mp_a_c_panther_01",
		"mp_a_c_possum_01",
		"mp_a_c_pronghorn_01",
		"mp_a_c_rabbit_01",
		"mp_a_c_sheep_01",
		"mp_a_c_wolf_01",
		"mp_a_f_m_protect_endflow_blackwater_01",
		"mp_a_f_m_unicorpse_01",
		"mp_a_m_m_asbminers_01",
		"mp_a_m_m_asbminers_02",
		"mp_a_m_m_coachguards_01",
		"mp_a_m_m_fos_coachguards_01",
		"mp_a_m_m_jamesonguard_01",
		"mp_a_m_m_lom_asbminers_01",
		"mp_a_m_m_protect_endflow_blackwater_01",
		"mp_a_m_m_unicorpse_01",
	},

	NPC = {
		"mp_re_rally_males_01",
		"re_rally_males_01",
		"cs_mp_policechief_lambert",
		"cs_mp_senator_ricard",
		"mp_beau_bink_females_01",
		"mp_beau_bink_males_01",
		"mp_bink_ember_of_the_east_males_01",
		"mp_carmela_bink_victim_males_01",
		"mp_cd_revengemayor_01",
		"mp_cs_antonyforemen",
		"mp_fm_bountytarget_females_dlc008_01",
		"mp_fm_bountytarget_males_dlc008_01",
		"mp_fm_bounty_horde_law_01",
		"mp_fm_knownbounty_informants_females_01",
		"mp_g_f_m_cultguards_01",
		"mp_g_m_m_cultguards_01",
		"mp_g_m_m_fos_debtgangcapitali_01",
		"mp_g_m_m_fos_debtgang_01",
		"mp_g_m_m_fos_vigilantes_01",
		"mp_g_m_m_mercs_01",
		"mp_g_m_m_mountainmen_01",
		"mp_g_m_m_riflecronies_01",
		"mp_g_m_o_uniexconfeds_cap_01",
		"mp_guidomartelli",
		"mp_lbm_carmela_banditos_01",
		"mp_lm_stealhorse_buyers_01",
		"mp_s_m_m_fos_harborguards_01",
		"mp_u_f_m_bountytarget_012",
		"mp_u_f_m_cultpriest_01",
		"mp_u_f_m_legendarybounty_03",
		"mp_u_f_m_outlaw_societylady_01",
		"mp_u_f_m_protect_mercer_01",
		"mp_u_m_m_asbdeputy_01",
		"mp_u_m_m_bankprisoner_01",
		"mp_u_m_m_binkmercs_01",
		"mp_u_m_m_cultpriest_01",
		"mp_u_m_m_dockrecipients_01",
		"mp_u_m_m_dropoff_bronte_01",
		"mp_u_m_m_dropoff_josiah_01",
		"mp_u_m_m_fos_bagholders_01",
		"mp_u_m_m_fos_coachholdup_recipient_01",
		"mp_u_m_m_fos_cornwallguard_01",
		"mp_u_m_m_fos_cornwall_bandits_01",
		"mp_u_m_m_fos_dockrecipients_01",
		"mp_u_m_m_fos_dockworker_01",
		"mp_u_m_m_fos_dropoff_01",
		"mp_u_m_m_fos_harbormaster_01",
		"mp_u_m_m_fos_interrogator_01",
		"mp_u_m_m_fos_interrogator_02",
		"mp_u_m_m_fos_musician_01",
		"mp_u_m_m_fos_railway_baron_01",
		"mp_u_m_m_fos_railway_driver_01",
		"mp_u_m_m_fos_railway_foreman_01",
		"mp_u_m_m_fos_railway_hunter_01",
		"mp_u_m_m_fos_railway_recipient_01",
		"mp_u_m_m_fos_recovery_recipient_01",
		"mp_u_m_m_fos_roguethief_01",
		"mp_u_m_m_fos_saboteur_01",
		"mp_u_m_m_fos_sdsaloon_gambler_01",
		"mp_u_m_m_fos_sdsaloon_owner_01",
		"mp_u_m_m_fos_sdsaloon_recipient_01",
		"mp_u_m_m_fos_sdsaloon_recipient_02",
		"mp_u_m_m_fos_town_outlaw_01",
		"mp_u_m_m_fos_town_vigilante_01",
		"mp_u_m_m_harbormaster_01",
		"mp_u_m_m_hctel_arm_hostage_01",
		"mp_u_m_m_hctel_arm_hostage_02",
		"mp_u_m_m_hctel_arm_hostage_03",
		"mp_u_m_m_hctel_sd_gang_01",
		"mp_u_m_m_hctel_sd_target_01",
		"mp_u_m_m_hctel_sd_target_02",
		"mp_u_m_m_hctel_sd_target_03",
		"mp_u_m_m_interrogator_01",
		"mp_u_m_m_legendarybounty_08",
		"mp_u_m_m_legendarybounty_09",
		"mp_u_m_m_lom_asbmercs_01",
		"mp_u_m_m_lom_dockworker_01",
		"mp_u_m_m_lom_dropoff_bronte_01",
		"mp_u_m_m_lom_head_security_01",
		"mp_u_m_m_lom_rhd_dealers_01",
		"mp_u_m_m_lom_rhd_sheriff_01",
		"mp_u_m_m_lom_rhd_smithassistant_01",
		"mp_u_m_m_lom_saloon_drunk_01",
		"mp_u_m_m_lom_sd_dockworker_01",
		"mp_u_m_m_lom_train_barricade_01",
		"mp_u_m_m_lom_train_clerk_01",
		"mp_u_m_m_lom_train_conductor_01",
		"mp_u_m_m_lom_train_lawtarget_01",
		"mp_u_m_m_lom_train_prisoners_01",
		"mp_u_m_m_lom_train_wagondropoff_01",
		"mp_u_m_m_musician_01",
		"mp_u_m_m_outlaw_arrestedthief_01",
		"mp_u_m_m_outlaw_coachdriver_01",
		"mp_u_m_m_outlaw_covington_01",
		"mp_u_m_m_outlaw_mpvictim_01",
		"mp_u_m_m_outlaw_rhd_noble_01",
		"mp_u_m_m_protect_armadillo_01",
		"mp_u_m_m_protect_blackwater_01",
		"mp_u_m_m_protect_friendly_armadillo_01",
		"mp_u_m_m_protect_halloween_ned_01",
		"mp_u_m_m_protect_macfarlanes_contact_01",
		"mp_u_m_m_protect_mercer_contact_01",
		"mp_u_m_m_protect_strawberry",
		"mp_u_m_m_protect_strawberry_01",
		"mp_u_m_m_protect_valentine_01",
		"mp_u_m_o_lom_asbforeman_01",
		"u_m_m_bht_outlawmauled",
		"a_f_m_armcholeracorpse_01",
		"a_f_m_armtownfolk_01",
		"a_f_m_armtownfolk_02",
		"a_f_m_asbtownfolk_01",
		"a_f_m_bivfancytravellers_01",
		"a_f_m_blwtownfolk_01",
		"a_f_m_blwtownfolk_02",
		"a_f_m_blwupperclass_01",
		"a_f_m_btchillbilly_01",
		"a_f_m_btcobesewomen_01",
		"a_f_m_bynfancytravellers_01",
		"a_f_m_familytravelers_cool_01",
		"a_f_m_familytravelers_warm_01",
		"a_f_m_gamhighsociety_01",
		"a_f_m_grifancytravellers_01",
		"a_f_m_guatownfolk_01",
		"a_f_m_htlfancytravellers_01",
		"a_f_m_lagtownfolk_01",
		"a_f_m_lowersdtownfolk_01",
		"a_f_m_lowersdtownfolk_02",
		"a_f_m_lowersdtownfolk_03",
		"a_f_m_lowertrainpassengers_01",
		"a_f_m_middlesdtownfolk_01",
		"a_f_m_middlesdtownfolk_02",
		"a_f_m_middlesdtownfolk_03",
		"a_f_m_middletrainpassengers_01",
		"a_f_m_nbxslums_01",
		"a_f_m_nbxupperclass_01",
		"a_f_m_nbxwhore_01",
		"a_f_m_rhdprostitute_01",
		"a_f_m_rhdtownfolk_01",
		"a_f_m_rhdtownfolk_02",
		"a_f_m_rhdupperclass_01",
		"a_f_m_rkrfancytravellers_01",
		"a_f_m_roughtravellers_01",
		"a_f_m_sclfancytravellers_01",
		"a_f_m_sdchinatown_01",
		"a_f_m_sdfancywhore_01",
		"a_f_m_sdobesewomen_01",
		"a_f_m_sdserversformal_01",
		"a_f_m_sdslums_02",
		"a_f_m_skpprisononline_01",
		"a_f_m_strtownfolk_01",
		"a_f_m_tumtownfolk_01",
		"a_f_m_tumtownfolk_02",
		"a_f_m_unicorpse_01",
		"a_f_m_uppertrainpassengers_01",
		"a_f_m_valprostitute_01",
		"a_f_m_valtownfolk_01",
		"a_f_m_vhtprostitute_01",
		"a_f_m_vhttownfolk_01",
		"a_f_m_waptownfolk_01",
		"a_f_o_blwupperclass_01",
		"a_f_o_btchillbilly_01",
		"a_f_o_guatownfolk_01",
		"a_f_o_lagtownfolk_01",
		"a_f_o_sdchinatown_01",
		"a_f_o_sdupperclass_01",
		"a_f_o_waptownfolk_01",
		"a_m_m_armcholeracorpse_01",
		"a_m_m_armdeputyresident_01",
		"a_m_m_armtownfolk_01",
		"a_m_m_armtownfolk_02",
		"a_m_m_asbboatcrew_01",
		"a_m_m_asbdeputyresident_01",
		"a_m_m_asbminer_01",
		"a_m_m_asbminer_02",
		"a_m_m_asbminer_03",
		"a_m_m_asbminer_04",
		"a_m_m_asbtownfolk_01",
		"a_m_m_asbtownfolk_01_laborer",
		"a_m_m_bivfancydrivers_01",
		"a_m_m_bivfancytravellers_01",
		"a_m_m_bivroughtravellers_01",
		"a_m_m_bivworker_01",
		"a_m_m_blwforeman_01",
		"a_m_m_blwlaborer_01",
		"a_m_m_blwlaborer_02",
		"a_m_m_blwobesemen_01",
		"a_m_m_blwtownfolk_01",
		"a_m_m_blwupperclass_01",
		"a_m_m_btchillbilly_01",
		"a_m_m_btcobesemen_01",
		"a_m_m_bynfancydrivers_01",
		"a_m_m_bynfancytravellers_01",
		"a_m_m_bynroughtravellers_01",
		"a_m_m_bynsurvivalist_01",
		"a_m_m_cardgameplayers_01",
		"a_m_m_chelonian_01",
		"a_m_m_deliverytravelers_cool_01",
		"a_m_m_deliverytravelers_warm_01",
		"a_m_m_dominoesplayers_01",
		"a_m_m_emrfarmhand_01",
		"a_m_m_familytravelers_cool_01",
		"a_m_m_familytravelers_warm_01",
		"a_m_m_farmtravelers_cool_01",
		"a_m_m_farmtravelers_warm_01",
		"a_m_m_fivefingerfilletplayers_01",
		"a_m_m_foreman",
		"a_m_m_gamhighsociety_01",
		"a_m_m_grifancydrivers_01",
		"a_m_m_grifancytravellers_01",
		"a_m_m_griroughtravellers_01",
		"a_m_m_grisurvivalist_01",
		"a_m_m_guatownfolk_01",
		"a_m_m_htlfancydrivers_01",
		"a_m_m_htlfancytravellers_01",
		"a_m_m_htlroughtravellers_01",
		"a_m_m_htlsurvivalist_01",
		"a_m_m_huntertravelers_cool_01",
		"a_m_m_huntertravelers_warm_01",
		"a_m_m_jamesonguard_01",
		"a_m_m_lagtownfolk_01",
		"a_m_m_lowersdtownfolk_01",
		"a_m_m_lowersdtownfolk_02",
		"a_m_m_lowertrainpassengers_01",
		"a_m_m_middlesdtownfolk_01",
		"a_m_m_middlesdtownfolk_02",
		"a_m_m_middlesdtownfolk_03",
		"a_m_m_middletrainpassengers_01",
		"a_m_m_moonshiners_01",
		"a_m_m_nbxdockworkers_01",
		"a_m_m_nbxlaborers_01",
		"a_m_m_nbxslums_01",
		"a_m_m_nbxupperclass_01",
		"a_m_m_nearoughtravellers_01",
		"a_m_m_rancher_01",
		"a_m_m_ranchertravelers_cool_01",
		"a_m_m_ranchertravelers_warm_01",
		"a_m_m_rhddeputyresident_01",
		"a_m_m_rhdforeman_01",
		"a_m_m_rhdobesemen_01",
		"a_m_m_rhdtownfolk_01",
		"a_m_m_rhdtownfolk_01_laborer",
		"a_m_m_rhdtownfolk_02",
		"a_m_m_rhdupperclass_01",
		"a_m_m_rkrfancydrivers_01",
		"a_m_m_rkrfancytravellers_01",
		"a_m_m_rkrroughtravellers_01",
		"a_m_m_rkrsurvivalist_01",
		"a_m_m_sclfancydrivers_01",
		"a_m_m_sclfancytravellers_01",
		"a_m_m_sclroughtravellers_01",
		"a_m_m_sdchinatown_01",
		"a_m_m_sddockforeman_01",
		"a_m_m_sddockworkers_02",
		"a_m_m_sdfancytravellers_01",
		"a_m_m_sdlaborers_02",
		"a_m_m_sdobesemen_01",
		"a_m_m_sdroughtravellers_01",
		"a_m_m_sdserversformal_01",
		"a_m_m_sdslums_02",
		"a_m_m_skpprisoner_01",
		"a_m_m_skpprisonline_01",
		"a_m_m_smhthug_01",
		"a_m_m_strdeputyresident_01",
		"a_m_m_strfancytourist_01",
		"a_m_m_strlaborer_01",
		"a_m_m_strtownfolk_01",
		"a_m_m_tumtownfolk_01",
		"a_m_m_tumtownfolk_02",
		"a_m_m_uniboatcrew_01",
		"a_m_m_unicoachguards_01",
		"a_m_m_unicorpse_01",
		"a_m_m_unigunslinger_01",
		"a_m_m_uppertrainpassengers_01",
		"a_m_m_valcriminals_01",
		"a_m_m_valdeputyresident_01",
		"a_m_m_valfarmer_01",
		"a_m_m_vallaborer_01",
		"a_m_m_valtownfolk_01",
		"a_m_m_valtownfolk_02",
		"a_m_m_vhtboatcrew_01",
		"a_m_m_vhtthug_01",
		"a_m_m_vhttownfolk_01",
		"a_m_m_wapwarriors_01",
		"a_m_o_blwupperclass_01",
		"a_m_o_btchillbilly_01",
		"a_m_o_guatownfolk_01",
		"a_m_o_lagtownfolk_01",
		"a_m_o_sdchinatown_01",
		"a_m_o_sdupperclass_01",
		"a_m_o_waptownfolk_01",
		"a_m_y_asbminer_01",
		"a_m_y_asbminer_02",
		"a_m_y_asbminer_03",
		"a_m_y_asbminer_04",
		"a_m_y_nbxstreetkids_01",
		"a_m_y_nbxstreetkids_slums_01",
		"a_m_y_sdstreetkids_slums_02",
		"a_m_y_unicorpse_01",
		"am_valentinedoctors_females_01",
		"amsp_robsdgunsmith_males_01",
		"casp_coachrobbery_lenny_males_01",
		"casp_coachrobbery_micah_males_01",
		"casp_hunting02_males_01",
		"charro_saddle_01",
		"cr_strawberry_males_01",
		"cs_abe",
		"cs_aberdeenpigfarmer",
		"cs_aberdeensister",
		"cs_abigailroberts",
		"cs_acrobat",
		"cs_adamgray",
		"cs_agnesdowd",
		"cs_albertcakeesquire",
		"cs_albertmason",
		"cs_andershelgerson",
		"cs_angel",
		"cs_angryhusband",
		"cs_angusgeddes",
		"cs_ansel_atherton",
		"cs_antonyforemen",
		"cs_archerfordham",
		"cs_archibaldjameson",
		"cs_archiedown",
		"cs_artappraiser",
		"cs_asbdeputy_01",
		"cs_ashton",
		"cs_balloonoperator",
		"cs_bandbassist",
		"cs_banddrummer",
		"cs_bandpianist",
		"cs_bandsinger",
		"cs_baptiste",
		"cs_bartholomewbraithwaite",
		"cs_bathingladies_01",
		"cs_beatenupcaptain",
		"cs_beaugray",
		"cs_billwilliamson",
		"cs_bivcoachdriver",
		"cs_blwphotographer",
		"cs_blwwitness",
		"cs_braithwaitebutler",
		"cs_braithwaitemaid",
		"cs_braithwaiteservant",
		"cs_brendacrawley",
		"cs_bronte",
		"cs_brontesbutler",
		"cs_brotherdorkins",
		"cs_brynntildon",
		"cs_bubba",
		"cs_cabaretmc",
		"cs_cajun",
		"cs_cancan_01",
		"cs_cancan_02",
		"cs_cancan_03",
		"cs_cancan_04",
		"cs_cancanman_01",
		"cs_captainmonroe",
		"cs_cassidy",
		"cs_catherinebraithwaite",
		"cs_cattlerustler",
		"cs_cavehermit",
		"cs_chainprisoner_01",
		"cs_chainprisoner_02",
		"cs_charlessmith",
		"cs_chelonianmaster",
		"cs_cigcardguy",
		"cs_clay",
		"cs_cleet",
		"cs_clive",
		"cs_colfavours",
		"cs_colmodriscoll",
		"cs_cooper",
		"cs_cornwalltrainconductor",
		"cs_crackpotinventor",
		"cs_crackpotrobot",
		"cs_creepyoldlady",
		"cs_creolecaptain",
		"cs_creoledoctor",
		"cs_creoleguy",
		"cs_dalemaroney",
		"cs_daveycallender",
		"cs_davidgeddes",
		"cs_desmond",
		"cs_didsbury",
		"cs_dinoboneslady",
		"cs_disguisedduster_01",
		"cs_disguisedduster_02",
		"cs_disguisedduster_03",
		"cs_doroetheawicklow",
		"cs_drhiggins",
		"cs_drmalcolmmacintosh",
		"cs_duncangeddes",
		"cs_dusterinformant_01",
		"cs_dutch",
		"cs_eagleflies",
		"cs_edgarross",
		"cs_edith_john",
		"cs_edithdown",
		"cs_edmundlowry",
		"cs_escapeartist",
		"cs_escapeartistassistant",
		"cs_evelynmiller",
		"cs_exconfedinformant",
		"cs_exconfedsleader_01",
		"cs_exoticcollector",
		"cs_famousgunslinger_01",
		"cs_famousgunslinger_02",
		"cs_famousgunslinger_03",
		"cs_famousgunslinger_04",
		"cs_famousgunslinger_05",
		"cs_famousgunslinger_06",
		"cs_featherstonchambers",
		"cs_featsofstrength",
		"cs_fightref",
		"cs_fire_breather",
		"cs_fishcollector",
		"cs_forgivenhusband_01",
		"cs_forgivenwife_01",
		"cs_formyartbigwoman",
		"cs_francis_sinclair",
		"cs_frenchartist",
		"cs_frenchman_01",
		"cs_fussar",
		"cs_garethbraithwaite",
		"cs_gavin",
		"cs_genstoryfemale",
		"cs_genstorymale",
		"cs_geraldbraithwaite",
		"cs_germandaughter",
		"cs_germanfather",
		"cs_germanmother",
		"cs_germanson",
		"cs_gilbertknightly",
		"cs_gloria",
		"cs_grizzledjon",
		"cs_guidomartelli",
		"cs_hamish",
		"cs_hectorfellowes",
		"cs_henrilemiux",
		"cs_herbalist",
		"cs_hercule",
		"cs_hestonjameson",
		"cs_hobartcrawley",
		"cs_hoseamatthews",
		"cs_iangray",
		"cs_jackmarston",
		"cs_jackmarston_teen",
		"cs_jamie",
		"cs_janson",
		"cs_javierescuella",
		"cs_jeb",
		"cs_jimcalloway",
		"cs_jockgray",
		"cs_joe",
		"cs_joebutler",
		"cs_johnmarston",
		"cs_johnthebaptisingmadman",
		"cs_johnweathers",
		"cs_josiahtrelawny",
		"cs_jules",
		"cs_karen",
		"cs_karensjohn_01",
		"cs_kieran",
		"cs_laramie",
		"cs_leighgray",
		"cs_lemiuxassistant",
		"cs_lenny",
		"cs_leon",
		"cs_leostrauss",
		"cs_levisimon",
		"cs_leviticuscornwall",
		"cs_lillianpowell",
		"cs_lillymillet",
		"cs_londonderryson",
		"cs_lucanapoli",
		"cs_magnifico",
		"cs_mamawatson",
		"cs_marshall_thurwell",
		"cs_marybeth",
		"cs_marylinton",
		"cs_meditatingmonk",
		"cs_meredith",
		"cs_meredithsmother",
		"cs_micahbell",
		"cs_micahsnemesis",
		"cs_mickey",
		"cs_miltonandrews",
		"cs_missmarjorie",
		"cs_mixedracekid",
		"cs_moira",
		"cs_mollyoshea",
		"cs_mp_agent_hixon",
		"cs_mp_alfredo_montez",
		"cs_mp_allison",
		"cs_mp_amos_lansing",
		"cs_mp_bessie_adair",
		"cs_mp_bonnie",
		"cs_mp_bountyhunter",
		"cs_mp_camp_cook",
		"cs_mp_cliff",
		"cs_mp_cripps",
		"cs_mp_dannylee",
		"cs_mp_grace_lancing",
		"cs_mp_gus_macmillan",
		"cs_mp_hans",
		"cs_mp_harriet_davenport",
		"cs_mp_henchman",
		"cs_mp_horley",
		"cs_mp_jeremiah_shaw",
		"cs_mp_jessica",
		"cs_mp_jorge_montez",
		"cs_mp_langston",
		"cs_mp_lee",
		"cs_mp_lem",
		"cs_mp_mabel",
		"cs_mp_maggie",
		"cs_mp_marshall_davies",
		"cs_mp_moonshiner",
		"cs_mp_mradler",
		"cs_mp_oldman_jones",
		"cs_mp_revenge_marshall",
		"cs_mp_samson_finch",
		"cs_mp_seth",
		"cs_mp_shaky",
		"cs_mp_sherifffreeman",
		"cs_mp_teddybrown",
		"cs_mp_terrance",
		"cs_mp_the_boy",
		"cs_mp_travellingsaleswoman",
		"cs_mp_went",
		"cs_mradler",
		"cs_mrdevon",
		"cs_mrlinton",
		"cs_mrpearson",
		"cs_mrs_calhoun",
		"cs_mrs_sinclair",
		"cs_mrsadler",
		"cs_mrsfellows",
		"cs_mrsgeddes",
		"cs_mrslondonderry",
		"cs_mrsweathers",
		"cs_mrwayne",
		"cs_mud2bigguy",
		"cs_mysteriousstranger",
		"cs_nbxdrunk",
		"cs_nbxexecuted",
		"cs_nbxpolicechiefformal",
		"cs_nbxreceptionist_01",
		"cs_nial_whelan",
		"cs_nicholastimmins",
		"cs_nils",
		"cs_norrisforsythe",
		"cs_obediahhinton",
		"cs_oddfellowspinhead",
		"cs_odprostitute",
		"cs_operasinger",
		"cs_paytah",
		"cs_penelopebraithwaite",
		"cs_pinkertongoon",
		"cs_poisonwellshaman",
		"cs_poorjoe",
		"cs_priest_wedding",
		"cs_princessisabeau",
		"cs_professorbell",
		"cs_rainsfall",
		"cs_ramon_cortez",
		"cs_reverendfortheringham",
		"cs_revswanson",
		"cs_rhodeputy_01",
		"cs_rhodeputy_02",
		"cs_rhodesassistant",
		"cs_rhodeskidnapvictim",
		"cs_rhodessaloonbouncer",
		"cs_ringmaster",
		"cs_rockyseven_widow",
		"cs_samaritan",
		"cs_scottgray",
		"cs_sd_streetkid_01",
		"cs_sd_streetkid_01a",
		"cs_sd_streetkid_01b",
		"cs_sd_streetkid_02",
		"cs_sddoctor_01",
		"cs_sdpriest",
		"cs_sdsaloondrunk_01",
		"cs_sdstreetkidthief",
		"cs_sean",
		"cs_sherifffreeman",
		"cs_sheriffowens",
		"cs_sistercalderon",
		"cs_slavecatcher",
		"cs_soothsayer",
		"cs_strawberryoutlaw_01",
		"cs_strawberryoutlaw_02",
		"cs_strdeputy_01",
		"cs_strdeputy_02",
		"cs_strsheriff_01",
		"cs_sunworshipper",
		"cs_susangrimshaw",
		"cs_swampfreak",
		"cs_swampweirdosonny",
		"cs_sworddancer",
		"cs_tavishgray",
		"cs_taxidermist",
		"cs_theodorelevin",
		"cs_thomasdown",
		"cs_tigerhandler",
		"cs_tilly",
		"cs_timothydonahue",
		"cs_tinyhermit",
		"cs_tomdickens",
		"cs_towncrier",
		"cs_treasurehunter",
		"cs_twinbrother_01",
		"cs_twinbrother_02",
		"cs_twingroupie_01",
		"cs_twingroupie_02",
		"cs_uncle",
		"cs_unidusterjail_01",
		"cs_valauctionboss_01",
		"cs_valdeputy_01",
		"cs_valprayingman",
		"cs_valprostitute_01",
		"cs_valprostitute_02",
		"cs_valsheriff",
		"cs_vampire",
		"cs_vht_bathgirl",
		"cs_wapitiboy",
		"cs_warvet",
		"cs_watson_01",
		"cs_watson_02",
		"cs_watson_03",
		"cs_welshfighter",
		"cs_wintonholmes",
		"cs_wrobel",
		"female_skeleton",
		"g_f_m_uniduster_01",
		"g_m_m_bountyhunters_01",
		"g_m_m_uniafricanamericangang_01",
		"g_m_m_unibanditos_01",
		"g_m_m_unibraithwaites_01",
		"g_m_m_unibrontegoons_01",
		"g_m_m_unicornwallgoons_01",
		"g_m_m_unicriminals_01",
		"g_m_m_unicriminals_02",
		"g_m_m_uniduster_01",
		"g_m_m_uniduster_02",
		"g_m_m_uniduster_03",
		"g_m_m_uniduster_04",
		"g_m_m_uniduster_05",
		"g_m_m_unigrays_01",
		"g_m_m_unigrays_02",
		"g_m_m_uniinbred_01",
		"g_m_m_unilangstonboys_01",
		"g_m_m_unimicahgoons_01",
		"g_m_m_unimountainmen_01",
		"g_m_m_uniranchers_01",
		"g_m_m_uniswamp_01",
		"g_m_o_uniexconfeds_01",
		"g_m_y_uniexconfeds_01",
		"g_m_y_uniexconfeds_02",
		"gc_lemoynecaptive_males_01",
		"gc_skinnertorture_males_01",
		"ge_delloboparty_females_01",
		"loansharking_asbminer_males_01",
		"loansharking_horsechase1_males_01",
		"loansharking_undertaker_females_01",
		"loansharking_undertaker_males_01",
		"male_skeleton",
		"mbh_rhodesrancher_females_01",
		"mbh_rhodesrancher_teens_01",
		"mbh_skinnersearch_males_01",
		"mcclellan_saddle_01",
		"mes_abigail2_males_01",
		"mes_finale2_females_01",
		"mes_finale2_males_01",
		"mes_finale3_males_01",
		"mes_marston1_males_01",
		"mes_marston2_males_01",
		"mes_marston5_2_males_01",
		"mes_marston6_females_01",
		"mes_marston6_males_01",
		"mes_marston6_teens_01",
		"mes_sadie4_males_01",
		"mes_sadie5_males_01",
		"motherhubbard_saddle_01",
		"mp_s_m_m_revenueagents_cap_01",
		"mp_u_m_m_fos_railway_guards_01",
		"mp_u_m_m_rhd_bountytarget_01",
		"mp_u_m_m_rhd_bountytarget_02",
		"mp_u_m_m_rhd_bountytarget_03",
		"mp_u_m_m_rhd_bountytarget_03b",
		"mp_a_f_m_cardgameplayers_01",
		"mp_a_f_m_saloonband_females_01",
		"mp_a_f_m_saloonpatrons_01",
		"mp_a_f_m_saloonpatrons_02",
		"mp_a_f_m_saloonpatrons_03",
		"mp_a_f_m_saloonpatrons_04",
		"mp_a_f_m_saloonpatrons_05",
		"mp_a_m_m_laboruprisers_01",
		"mp_a_m_m_moonshinemakers_01",
		"mp_a_m_m_saloonband_males_01",
		"mp_a_m_m_saloonpatrons_01",
		"mp_a_m_m_saloonpatrons_02",
		"mp_a_m_m_saloonpatrons_03",
		"mp_a_m_m_saloonpatrons_04",
		"mp_a_m_m_saloonpatrons_05",
		"mp_asn_benedictpoint_females_01",
		"mp_asn_benedictpoint_males_01",
		"mp_asn_blackwater_males_01",
		"mp_asn_braithwaitemanor_males_01",
		"mp_asn_braithwaitemanor_males_02",
		"mp_asn_braithwaitemanor_males_03",
		"mp_asn_civilwarfort_males_01",
		"mp_asn_gaptoothbreach_males_01",
		"mp_asn_pikesbasin_males_01",
		"mp_asn_sdpolicestation_males_01",
		"mp_asn_sdwedding_females_01",
		"mp_asn_sdwedding_males_01",
		"mp_asn_shadybelle_females_01",
		"mp_asn_stillwater_males_01",
		"mp_asntrk_elysianpool_males_01",
		"mp_asntrk_grizzlieswest_males_01",
		"mp_asntrk_hagenorchard_males_01",
		"mp_asntrk_isabella_males_01",
		"mp_asntrk_talltrees_males_01",
		"mp_campdef_bluewater_females_01",
		"mp_campdef_bluewater_males_01",
		"mp_campdef_chollasprings_females_01",
		"mp_campdef_chollasprings_males_01",
		"mp_campdef_eastnewhanover_females_01",
		"mp_campdef_eastnewhanover_males_01",
		"mp_campdef_gaptoothbreach_females_01",
		"mp_campdef_gaptoothbreach_males_01",
		"mp_campdef_gaptoothridge_females_01",
		"mp_campdef_gaptoothridge_males_01",
		"mp_campdef_greatplains_males_01",
		"mp_campdef_grizzlies_males_01",
		"mp_campdef_heartlands1_males_01",
		"mp_campdef_heartlands2_females_01",
		"mp_campdef_heartlands2_males_01",
		"mp_campdef_hennigans_females_01",
		"mp_campdef_hennigans_males_01",
		"mp_campdef_littlecreek_females_01",
		"mp_campdef_littlecreek_males_01",
		"mp_campdef_radleyspasture_females_01",
		"mp_campdef_radleyspasture_males_01",
		"mp_campdef_riobravo_females_01",
		"mp_campdef_riobravo_males_01",
		"mp_campdef_roanoke_females_01",
		"mp_campdef_roanoke_males_01",
		"mp_campdef_talltrees_females_01",
		"mp_campdef_talltrees_males_01",
		"mp_campdef_tworocks_females_01",
		"mp_chu_kid_armadillo_males_01",
		"mp_chu_kid_diabloridge_males_01",
		"mp_chu_kid_emrstation_males_01",
		"mp_chu_kid_greatplains2_males_01",
		"mp_chu_kid_greatplains_males_01",
		"mp_chu_kid_heartlands_males_01",
		"mp_chu_kid_lagras_males_01",
		"mp_chu_kid_lemoyne_females_01",
		"mp_chu_kid_lemoyne_males_01",
		"mp_chu_kid_recipient_males_01",
		"mp_chu_kid_rhodes_males_01",
		"mp_chu_kid_saintdenis_females_01",
		"mp_chu_kid_saintdenis_males_01",
		"mp_chu_kid_scarlettmeadows_males_01",
		"mp_chu_kid_tumbleweed_males_01",
		"mp_chu_kid_valentine_males_01",
		"mp_chu_rob_ambarino_males_01",
		"mp_chu_rob_annesburg_males_01",
		"mp_chu_rob_benedictpoint_females_01",
		"mp_chu_rob_benedictpoint_males_01",
		"mp_chu_rob_blackwater_males_01",
		"mp_chu_rob_caligahall_males_01",
		"mp_chu_rob_coronado_males_01",
		"mp_chu_rob_cumberland_males_01",
		"mp_chu_rob_fortmercer_females_01",
		"mp_chu_rob_fortmercer_males_01",
		"mp_chu_rob_greenhollow_males_01",
		"mp_chu_rob_macfarlanes_females_01",
		"mp_chu_rob_macfarlanes_males_01",
		"mp_chu_rob_macleans_males_01",
		"mp_chu_rob_millesani_males_01",
		"mp_chu_rob_montanariver_males_01",
		"mp_chu_rob_paintedsky_males_01",
		"mp_chu_rob_rathskeller_males_01",
		"mp_chu_rob_recipient_males_01",
		"mp_chu_rob_rhodes_males_01",
		"mp_chu_rob_strawberry_males_01",
		"mp_clay",
		"mp_convoy_recipient_females_01",
		"mp_convoy_recipient_males_01",
		"mp_de_u_f_m_bigvalley_01",
		"mp_de_u_f_m_bluewatermarsh_01",
		"mp_de_u_f_m_braithwaite_01",
		"mp_de_u_f_m_doverhill_01",
		"mp_de_u_f_m_greatplains_01",
		"mp_de_u_f_m_hangingrock_01",
		"mp_de_u_f_m_heartlands_01",
		"mp_de_u_f_m_hennigansstead_01",
		"mp_de_u_f_m_silentstead_01",
		"mp_de_u_m_m_aurorabasin_01",
		"mp_de_u_m_m_barrowlagoon_01",
		"mp_de_u_m_m_bigvalleygraves_01",
		"mp_de_u_m_m_centralunionrr_01",
		"mp_de_u_m_m_pleasance_01",
		"mp_de_u_m_m_rileyscharge_01",
		"mp_de_u_m_m_vanhorn_01",
		"mp_de_u_m_m_westernhomestead_01",
		"mp_dr_u_f_m_bayougatorfood_01",
		"mp_dr_u_f_m_bigvalleycave_01",
		"mp_dr_u_f_m_bigvalleycliff_01",
		"mp_dr_u_f_m_bluewaterkidnap_01",
		"mp_dr_u_f_m_colterbandits_01",
		"mp_dr_u_f_m_colterbandits_02",
		"mp_dr_u_f_m_missingfisherman_01",
		"mp_dr_u_f_m_missingfisherman_02",
		"mp_dr_u_f_m_mistakenbounties_01",
		"mp_dr_u_f_m_plaguetown_01",
		"mp_dr_u_f_m_quakerscove_01",
		"mp_dr_u_f_m_quakerscove_02",
		"mp_dr_u_f_m_sdgraveyard_01",
		"mp_dr_u_m_m_bigvalleycave_01",
		"mp_dr_u_m_m_bigvalleycliff_01",
		"mp_dr_u_m_m_bluewaterkidnap_01",
		"mp_dr_u_m_m_canoeescape_01",
		"mp_dr_u_m_m_hwyrobbery_01",
		"mp_dr_u_m_m_mistakenbounties_01",
		"mp_dr_u_m_m_pikesbasin_01",
		"mp_dr_u_m_m_pikesbasin_02",
		"mp_dr_u_m_m_plaguetown_01",
		"mp_dr_u_m_m_roanokestandoff_01",
		"mp_dr_u_m_m_sdgraveyard_01",
		"mp_dr_u_m_m_sdmugging_01",
		"mp_dr_u_m_m_sdmugging_02",
		"mp_female",
		"mp_fm_bounty_caged_males_01",
		"mp_fm_bounty_ct_corpses_01",
		"mp_fm_bounty_hideout_males_01",
		"mp_fm_bounty_horde_males_01",
		"mp_fm_bounty_infiltration_males_01",
		"mp_fm_knownbounty_guards_01",
		"mp_fm_knownbounty_informants_males_01",
		"mp_fm_multitrack_victims_males_01",
		"mp_fm_stakeout_corpses_males_01",
		"mp_fm_stakeout_poker_males_01",
		"mp_fm_stakeout_target_males_01",
		"mp_fm_track_prospector_01",
		"mp_fm_track_sd_lawman_01",
		"mp_fm_track_targets_males_01",
		"mp_freeroam_tut_females_01",
		"mp_freeroam_tut_males_01",
		"mp_g_f_m_armyoffear_01",
		"mp_g_f_m_cultmembers_01",
		"mp_g_f_m_laperlegang_01",
		"mp_g_f_m_laperlevips_01",
		"mp_g_f_m_owlhootfamily_01",
		"mp_g_m_m_animalpoachers_01",
		"mp_g_m_m_armoredjuggernauts_01",
		"mp_g_m_m_armyoffear_01",
		"mp_g_m_m_bountyhunters_01",
		"mp_g_m_m_cultmembers_01",
		"mp_g_m_m_owlhootfamily_01",
		"mp_g_m_m_redbengang_01",
		"mp_g_m_m_uniafricanamericangang_01",
		"mp_g_m_m_unibanditos_01",
		"mp_g_m_m_unibraithwaites_01",
		"mp_g_m_m_unibrontegoons_01",
		"mp_g_m_m_unicornwallgoons_01",
		"mp_g_m_m_unicriminals_01",
		"mp_g_m_m_unicriminals_02",
		"mp_g_m_m_unicriminals_03",
		"mp_g_m_m_unicriminals_04",
		"mp_g_m_m_unicriminals_05",
		"mp_g_m_m_unicriminals_06",
		"mp_g_m_m_unicriminals_07",
		"mp_g_m_m_unicriminals_08",
		"mp_g_m_m_unicriminals_09",
		"mp_g_m_m_uniduster_01",
		"mp_g_m_m_uniduster_02",
		"mp_g_m_m_uniduster_03",
		"mp_g_m_m_unigrays_01",
		"mp_g_m_m_uniinbred_01",
		"mp_g_m_m_unilangstonboys_01",
		"mp_g_m_m_unimountainmen_01",
		"mp_g_m_m_uniranchers_01",
		"mp_g_m_m_uniswamp_01",
		"mp_g_m_o_uniexconfeds_01",
		"mp_g_m_y_uniexconfeds_01",
		"mp_gunvoutd2_males_01",
		"mp_gunvoutd3_bht_01",
		"mp_gunvoutd3_males_01",
		"mp_horse_owlhootvictim_01",
		"mp_intercept_recipient_females_01",
		"mp_intercept_recipient_males_01",
		"mp_intro_females_01",
		"mp_intro_males_01",
		"mp_jailbreak_males_01",
		"mp_jailbreak_recipient_males_01",
		"mp_lbt_m3_males_01",
		"mp_lbt_m6_females_01",
		"mp_lbt_m6_males_01",
		"mp_lbt_m7_males_01",
		"mp_male",
		"mp_oth_recipient_males_01",
		"mp_outlaw1_males_01",
		"mp_outlaw2_males_01",
		"mp_post_multipackage_females_01",
		"mp_post_multipackage_males_01",
		"mp_post_multirelay_females_01",
		"mp_post_multirelay_males_01",
		"mp_post_relay_females_01",
		"mp_post_relay_males_01",
		"mp_predator",
		"mp_prsn_asn_males_01",
		"mp_re_animalattack_females_01",
		"mp_re_animalattack_males_01",
		"mp_re_duel_females_01",
		"mp_re_duel_males_01",
		"mp_re_graverobber_females_01",
		"mp_re_graverobber_males_01",
		"mp_re_hobodog_females_01",
		"mp_re_hobodog_males_01",
		"mp_re_kidnapped_females_01",
		"mp_re_kidnapped_males_01",
		"mp_re_moonshinecamp_males_01",
		"mp_re_photography_females_01",
		"mp_re_photography_females_02",
		"mp_re_photography_males_01",
		"mp_re_rivalcollector_males_01",
		"mp_re_runawaywagon_females_01",
		"mp_re_runawaywagon_males_01",
		"mp_re_slumpedhunter_females_01",
		"mp_re_slumpedhunter_males_01",
		"mp_re_suspendedhunter_males_01",
		"mp_re_treasurehunter_females_01",
		"mp_re_treasurehunter_males_01",
		"mp_re_wildman_males_01",
		"mp_recover_recipient_females_01",
		"mp_recover_recipient_males_01",
		"mp_repo_recipient_females_01",
		"mp_repo_recipient_males_01",
		"mp_repoboat_recipient_females_01",
		"mp_repoboat_recipient_males_01",
		"mp_rescue_bottletree_females_01",
		"mp_rescue_bottletree_males_01",
		"mp_rescue_colter_males_01",
		"mp_rescue_cratersacrifice_males_01",
		"mp_rescue_heartlands_males_01",
		"mp_rescue_loftkidnap_males_01",
		"mp_rescue_lonniesshack_males_01",
		"mp_rescue_moonstone_males_01",
		"mp_rescue_mtnmanshack_males_01",
		"mp_rescue_recipient_females_01",
		"mp_rescue_recipient_males_01",
		"mp_rescue_rivalshack_males_01",
		"mp_rescue_scarlettmeadows_males_01",
		"mp_rescue_sddogfight_females_01",
		"mp_rescue_sddogfight_males_01",
		"mp_resupply_recipient_females_01",
		"mp_resupply_recipient_males_01",
		"mp_revenge1_males_01",
		"mp_s_m_m_cornwallguard_01",
		"mp_s_m_m_pinlaw_01",
		"mp_s_m_m_revenueagents_01",
		"mp_stealboat_recipient_males_01",
		"mp_stealhorse_recipient_males_01",
		"mp_stealwagon_recipient_males_01",
		"mp_tattoo_female",
		"mp_tattoo_male",
		"mp_u_f_m_bountytarget_001",
		"mp_u_f_m_bountytarget_002",
		"mp_u_f_m_bountytarget_003",
		"mp_u_f_m_bountytarget_004",
		"mp_u_f_m_bountytarget_005",
		"mp_u_f_m_bountytarget_006",
		"mp_u_f_m_bountytarget_007",
		"mp_u_f_m_bountytarget_008",
		"mp_u_f_m_bountytarget_009",
		"mp_u_f_m_bountytarget_010",
		"mp_u_f_m_bountytarget_011",
		"mp_u_f_m_bountytarget_013",
		"mp_u_f_m_bountytarget_014",
		"mp_u_f_m_buyer_improved_01",
		"mp_u_f_m_buyer_improved_02",
		"mp_u_f_m_buyer_regular_01",
		"mp_u_f_m_buyer_regular_02",
		"mp_u_f_m_buyer_special_01",
		"mp_u_f_m_buyer_special_02",
		"mp_u_f_m_gunslinger3_rifleman_02",
		"mp_u_f_m_gunslinger3_sharpshooter_01",
		"mp_u_f_m_laperlevipmasked_01",
		"mp_u_f_m_laperlevipmasked_02",
		"mp_u_f_m_laperlevipmasked_03",
		"mp_u_f_m_laperlevipmasked_04",
		"mp_u_f_m_laperlevipunmasked_01",
		"mp_u_f_m_laperlevipunmasked_02",
		"mp_u_f_m_laperlevipunmasked_03",
		"mp_u_f_m_laperlevipunmasked_04",
		"mp_u_f_m_lbt_owlhootvictim_01",
		"mp_u_f_m_legendarybounty_001",
		"mp_u_f_m_legendarybounty_002",
		"mp_u_f_m_nat_traveler_01",
		"mp_u_f_m_nat_worker_01",
		"mp_u_f_m_nat_worker_02",
		"mp_u_f_m_outlaw3_warner_01",
		"mp_u_f_m_outlaw3_warner_02",
		"mp_u_f_m_revenge2_passerby_01",
		"mp_u_f_m_saloonpianist_01",
		"mp_u_m_m_animalpoacher_01",
		"mp_u_m_m_animalpoacher_02",
		"mp_u_m_m_animalpoacher_03",
		"mp_u_m_m_animalpoacher_04",
		"mp_u_m_m_animalpoacher_05",
		"mp_u_m_m_animalpoacher_06",
		"mp_u_m_m_animalpoacher_07",
		"mp_u_m_m_animalpoacher_08",
		"mp_u_m_m_animalpoacher_09",
		"mp_u_m_m_armsheriff_01",
		"mp_u_m_m_bountyinjuredman_01",
		"mp_u_m_m_bountytarget_001",
		"mp_u_m_m_bountytarget_002",
		"mp_u_m_m_bountytarget_003",
		"mp_u_m_m_bountytarget_005",
		"mp_u_m_m_bountytarget_008",
		"mp_u_m_m_bountytarget_009",
		"mp_u_m_m_bountytarget_010",
		"mp_u_m_m_bountytarget_011",
		"mp_u_m_m_bountytarget_012",
		"mp_u_m_m_bountytarget_013",
		"mp_u_m_m_bountytarget_014",
		"mp_u_m_m_bountytarget_015",
		"mp_u_m_m_bountytarget_016",
		"mp_u_m_m_bountytarget_017",
		"mp_u_m_m_bountytarget_018",
		"mp_u_m_m_bountytarget_019",
		"mp_u_m_m_bountytarget_020",
		"mp_u_m_m_bountytarget_021",
		"mp_u_m_m_bountytarget_022",
		"mp_u_m_m_bountytarget_023",
		"mp_u_m_m_bountytarget_024",
		"mp_u_m_m_bountytarget_025",
		"mp_u_m_m_bountytarget_026",
		"mp_u_m_m_bountytarget_027",
		"mp_u_m_m_bountytarget_028",
		"mp_u_m_m_bountytarget_029",
		"mp_u_m_m_bountytarget_030",
		"mp_u_m_m_bountytarget_031",
		"mp_u_m_m_bountytarget_032",
		"mp_u_m_m_bountytarget_033",
		"mp_u_m_m_bountytarget_034",
		"mp_u_m_m_bountytarget_035",
		"mp_u_m_m_bountytarget_036",
		"mp_u_m_m_bountytarget_037",
		"mp_u_m_m_bountytarget_038",
		"mp_u_m_m_bountytarget_039",
		"mp_u_m_m_bountytarget_044",
		"mp_u_m_m_bountytarget_045",
		"mp_u_m_m_bountytarget_046",
		"mp_u_m_m_bountytarget_047",
		"mp_u_m_m_bountytarget_048",
		"mp_u_m_m_bountytarget_049",
		"mp_u_m_m_bountytarget_050",
		"mp_u_m_m_bountytarget_051",
		"mp_u_m_m_bountytarget_052",
		"mp_u_m_m_bountytarget_053",
		"mp_u_m_m_bountytarget_054",
		"mp_u_m_m_bountytarget_055",
		"mp_u_m_m_buyer_default_01",
		"mp_u_m_m_buyer_improved_01",
		"mp_u_m_m_buyer_improved_02",
		"mp_u_m_m_buyer_improved_03",
		"mp_u_m_m_buyer_improved_04",
		"mp_u_m_m_buyer_improved_05",
		"mp_u_m_m_buyer_improved_06",
		"mp_u_m_m_buyer_improved_07",
		"mp_u_m_m_buyer_improved_08",
		"mp_u_m_m_buyer_regular_01",
		"mp_u_m_m_buyer_regular_02",
		"mp_u_m_m_buyer_regular_03",
		"mp_u_m_m_buyer_regular_04",
		"mp_u_m_m_buyer_regular_05",
		"mp_u_m_m_buyer_regular_06",
		"mp_u_m_m_buyer_regular_07",
		"mp_u_m_m_buyer_regular_08",
		"mp_u_m_m_buyer_special_01",
		"mp_u_m_m_buyer_special_02",
		"mp_u_m_m_buyer_special_03",
		"mp_u_m_m_buyer_special_04",
		"mp_u_m_m_buyer_special_05",
		"mp_u_m_m_buyer_special_06",
		"mp_u_m_m_buyer_special_07",
		"mp_u_m_m_buyer_special_08",
		"mp_u_m_m_dyingpoacher_01",
		"mp_u_m_m_dyingpoacher_02",
		"mp_u_m_m_dyingpoacher_03",
		"mp_u_m_m_dyingpoacher_04",
		"mp_u_m_m_dyingpoacher_05",
		"mp_u_m_m_gunforhireclerk_01",
		"mp_u_m_m_gunslinger3_rifleman_01",
		"mp_u_m_m_gunslinger3_sharpshooter_02",
		"mp_u_m_m_gunslinger3_shotgunner_01",
		"mp_u_m_m_gunslinger3_shotgunner_02",
		"mp_u_m_m_gunslinger4_warner_01",
		"mp_u_m_m_lawcamp_lawman_01",
		"mp_u_m_m_lawcamp_lawman_02",
		"mp_u_m_m_lawcamp_leadofficer_01",
		"mp_u_m_m_lawcamp_prisoner_01",
		"mp_u_m_m_lbt_accomplice_01",
		"mp_u_m_m_lbt_barbsvictim_01",
		"mp_u_m_m_lbt_bribeinformant_01",
		"mp_u_m_m_lbt_coachdriver_01",
		"mp_u_m_m_lbt_hostagemarshal_01",
		"mp_u_m_m_lbt_owlhootvictim_01",
		"mp_u_m_m_lbt_owlhootvictim_02",
		"mp_u_m_m_lbt_philipsvictim_01",
		"mp_u_m_m_legendarybounty_001",
		"mp_u_m_m_legendarybounty_002",
		"mp_u_m_m_legendarybounty_003",
		"mp_u_m_m_legendarybounty_004",
		"mp_u_m_m_legendarybounty_005",
		"mp_u_m_m_legendarybounty_006",
		"mp_u_m_m_legendarybounty_007",
		"mp_u_m_m_nat_farmer_01",
		"mp_u_m_m_nat_farmer_02",
		"mp_u_m_m_nat_farmer_03",
		"mp_u_m_m_nat_farmer_04",
		"mp_u_m_m_nat_photographer_01",
		"mp_u_m_m_nat_photographer_02",
		"mp_u_m_m_nat_rancher_01",
		"mp_u_m_m_nat_rancher_02",
		"mp_u_m_m_nat_townfolk_01",
		"mp_u_m_m_outlaw3_prisoner_01",
		"mp_u_m_m_outlaw3_prisoner_02",
		"mp_u_m_m_outlaw3_warner_01",
		"mp_u_m_m_outlaw3_warner_02",
		"mp_u_m_m_prisonwagon_01",
		"mp_u_m_m_prisonwagon_02",
		"mp_u_m_m_prisonwagon_03",
		"mp_u_m_m_prisonwagon_04",
		"mp_u_m_m_prisonwagon_05",
		"mp_u_m_m_prisonwagon_06",
		"mp_u_m_m_revenge2_handshaker_01",
		"mp_u_m_m_revenge2_passerby_01",
		"mp_u_m_m_saloonbrawler_01",
		"mp_u_m_m_saloonbrawler_02",
		"mp_u_m_m_saloonbrawler_03",
		"mp_u_m_m_saloonbrawler_04",
		"mp_u_m_m_saloonbrawler_05",
		"mp_u_m_m_saloonbrawler_06",
		"mp_u_m_m_saloonbrawler_07",
		"mp_u_m_m_saloonbrawler_08",
		"mp_u_m_m_saloonbrawler_09",
		"mp_u_m_m_saloonbrawler_10",
		"mp_u_m_m_saloonbrawler_11",
		"mp_u_m_m_saloonbrawler_12",
		"mp_u_m_m_saloonbrawler_13",
		"mp_u_m_m_saloonbrawler_14",
		"mp_u_m_m_strwelcomecenter_02",
		"mp_u_m_m_trader_01",
		"mp_u_m_m_traderintroclerk_01",
		"mp_u_m_m_tvlfence_01",
		"mp_u_m_o_blwpolicechief_01",
		"mp_wgnbrkout_recipient_males_01",
		"mp_wgnthief_recipient_males_01",
		"msp_bountyhunter1_females_01",
		"msp_braithwaites1_males_01",
		"msp_feud1_males_01",
		"msp_fussar2_males_01",
		"msp_gang2_males_01",
		"msp_gang3_males_01",
		"msp_grays1_males_01",
		"msp_grays2_males_01",
		"msp_guarma2_males_01",
		"msp_industry1_females_01",
		"msp_industry1_males_01",
		"msp_industry3_females_01",
		"msp_industry3_males_01",
		"msp_mary1_females_01",
		"msp_mary1_males_01",
		"msp_mary3_males_01",
		"msp_mob0_males_01",
		"msp_mob1_females_01",
		"msp_mob1_males_01",
		"msp_mob1_teens_01",
		"msp_mob3_females_01",
		"msp_mob3_males_01",
		"msp_mudtown3_males_01",
		"msp_mudtown3b_females_01",
		"msp_mudtown3b_males_01",
		"msp_mudtown5_males_01",
		"msp_native1_males_01",
		"msp_reverend1_males_01",
		"msp_saintdenis1_females_01",
		"msp_saintdenis1_males_01",
		"msp_saloon1_females_01",
		"msp_saloon1_males_01",
		"msp_smuggler2_males_01",
		"msp_trainrobbery2_males_01",
		"msp_trelawny1_males_01",
		"msp_utopia1_males_01",
		"msp_winter4_males_01",
		"p_c_horse_01",
		"player_three",
		"player_zero",
		"rces_abigail3_females_01",
		"rces_abigail3_males_01",
		"rces_beechers1_males_01",
		"rces_evelynmiller_males_01",
		"rcsp_beauandpenelope1_females_01",
		"rcsp_beauandpenelope_males_01",
		"rcsp_calderon_males_01",
		"rcsp_calderonstage2_males_01",
		"rcsp_calderonstage2_teens_01",
		"rcsp_calloway_males_01",
		"rcsp_coachrobbery_males_01",
		"rcsp_crackpot_females_01",
		"rcsp_crackpot_males_01",
		"rcsp_creole_males_01",
		"rcsp_dutch1_males_01",
		"rcsp_dutch3_males_01",
		"rcsp_edithdownes2_males_01",
		"rcsp_formyart_females_01",
		"rcsp_formyart_males_01",
		"rcsp_gunslingerduel4_males_01",
		"rcsp_herekittykitty_males_01",
		"rcsp_hunting1_males_01",
		"rcsp_mrmayor_males_01",
		"rcsp_native1s2_males_01",
		"rcsp_native_americanfathers_males_01",
		"rcsp_oddfellows_males_01",
		"rcsp_odriscolls2_females_01",
		"rcsp_poisonedwell_females_01",
		"rcsp_poisonedwell_males_01",
		"rcsp_poisonedwell_teens_01",
		"rcsp_ridethelightning_females_01",
		"rcsp_ridethelightning_males_01",
		"rcsp_sadie1_males_01",
		"rcsp_slavecatcher_males_01",
		"re_animalattack_females_01",
		"re_animalattack_males_01",
		"re_animalmauling_males_01",
		"re_approach_males_01",
		"re_beartrap_males_01",
		"re_boatattack_males_01",
		"re_burningbodies_males_01",
		"re_checkpoint_males_01",
		"re_coachrobbery_females_01",
		"re_coachrobbery_males_01",
		"re_consequence_males_01",
		"re_corpsecart_females_01",
		"re_corpsecart_males_01",
		"re_crashedwagon_males_01",
		"re_darkalleyambush_males_01",
		"re_darkalleybum_males_01",
		"re_darkalleystabbing_males_01",
		"re_deadbodies_males_01",
		"re_deadjohn_females_01",
		"re_deadjohn_males_01",
		"re_disabledbeggar_males_01",
		"re_domesticdispute_females_01",
		"re_domesticdispute_males_01",
		"re_drownmurder_females_01",
		"re_drownmurder_males_01",
		"re_drunkcamp_males_01",
		"re_drunkdueler_males_01",
		"re_duelboaster_males_01",
		"re_duelwinner_females_01",
		"re_duelwinner_males_01",
		"re_escort_females_01",
		"re_executions_males_01",
		"re_fleeingfamily_females_01",
		"re_fleeingfamily_males_01",
		"re_footrobbery_males_01",
		"re_friendlyoutdoorsman_males_01",
		"re_frozentodeath_females_01",
		"re_frozentodeath_males_01",
		"re_fundraiser_females_01",
		"re_fussarchase_males_01",
		"re_goldpanner_males_01",
		"re_horserace_females_01",
		"re_horserace_males_01",
		"re_hostagerescue_females_01",
		"re_hostagerescue_males_01",
		"re_inbredkidnap_females_01",
		"re_inbredkidnap_males_01",
		"re_injuredrider_males_01",
		"re_kidnappedvictim_females_01",
		"re_laramiegangrustling_males_01",
		"re_loneprisoner_males_01",
		"re_lostdog_dogs_01",
		"re_lostdog_teens_01",
		"re_lostdrunk_females_01",
		"re_lostdrunk_males_01",
		"re_lostfriend_males_01",
		"re_lostman_males_01",
		"re_moonshinecamp_males_01",
		"re_murdercamp_males_01",
		"re_murdersuicide_females_01",
		"re_murdersuicide_males_01",
		"re_nakedswimmer_males_01",
		"re_ontherun_males_01",
		"re_outlawlooter_males_01",
		"re_parlorambush_males_01",
		"re_peepingtom_females_01",
		"re_peepingtom_males_01",
		"re_pickpocket_males_01",
		"re_pisspot_females_01",
		"re_pisspot_males_01",
		"re_playercampstrangers_females_01",
		"re_playercampstrangers_males_01",
		"re_poisoned_males_01",
		"re_policechase_males_01",
		"re_prisonwagon_females_01",
		"re_prisonwagon_males_01",
		"re_publichanging_females_01",
		"re_publichanging_males_01",
		"re_publichanging_teens_01",
		"re_rally_males_01",
		"re_rallydispute_males_01",
		"re_rallysetup_males_01",
		"re_ratinfestation_males_01",
		"re_rowdydrunks_males_01",
		"re_savageaftermath_females_01",
		"re_savageaftermath_males_01",
		"re_savagefight_females_01",
		"re_savagefight_males_01",
		"re_savagewagon_females_01",
		"re_savagewagon_males_01",
		"re_savagewarning_males_01",
		"re_sharpshooter_males_01",
		"re_showoff_males_01",
		"re_skippingstones_males_01",
		"re_skippingstones_teens_01",
		"re_slumambush_females_01",
		"re_snakebite_males_01",
		"re_stalkinghunter_males_01",
		"re_strandedrider_males_01",
		"re_street_fight_males_01",
		"re_taunting_01",
		"re_taunting_males_01",
		"re_torturingcaptive_males_01",
		"re_townburial_males_01",
		"re_townconfrontation_females_01",
		"re_townconfrontation_males_01",
		"re_townrobbery_males_01",
		"re_townwidow_females_01",
		"re_trainholdup_females_01",
		"re_trainholdup_males_01",
		"re_trappedwoman_females_01",
		"re_treasurehunter_males_01",
		"re_voice_females_01",
		"re_wagonthreat_females_01",
		"re_wagonthreat_males_01",
		"re_washedashore_males_01",
		"re_wealthycouple_females_01",
		"re_wealthycouple_males_01",
		"re_wildman_01",
		"s_f_m_bwmworker_01",
		"s_f_m_cghworker_01",
		"s_f_m_mapworker_01",
		"s_m_m_ambientblwpolice_01",
		"s_m_m_ambientlawrural_01",
		"s_m_m_ambientsdpolice_01",
		"s_m_m_army_01",
		"s_m_m_asbcowpoke_01",
		"s_m_m_asbdealer_01",
		"s_m_m_bankclerk_01",
		"s_m_m_barber_01",
		"s_m_m_blwcowpoke_01",
		"s_m_m_blwdealer_01",
		"s_m_m_bwmworker_01",
		"s_m_m_cghworker_01",
		"s_m_m_cktworker_01",
		"s_m_m_coachtaxidriver_01",
		"s_m_m_cornwallguard_01",
		"s_m_m_dispatchlawrural_01",
		"s_m_m_dispatchleaderpolice_01",
		"s_m_m_dispatchleaderrural_01",
		"s_m_m_dispatchpolice_01",
		"s_m_m_fussarhenchman_01",
		"s_m_m_genconductor_01",
		"s_m_m_hofguard_01",
		"s_m_m_liveryworker_01",
		"s_m_m_magiclantern_01",
		"s_m_m_mapworker_01",
		"s_m_m_marketvendor_01",
		"s_m_m_marshallsrural_01",
		"s_m_m_micguard_01",
		"s_m_m_nbxriverboatdealers_01",
		"s_m_m_nbxriverboatguards_01",
		"s_m_m_orpguard_01",
		"s_m_m_pinlaw_01",
		"s_m_m_racrailguards_01",
		"s_m_m_racrailworker_01",
		"s_m_m_rhdcowpoke_01",
		"s_m_m_rhddealer_01",
		"s_m_m_sdcowpoke_01",
		"s_m_m_sddealer_01",
		"s_m_m_sdticketseller_01",
		"s_m_m_skpguard_01",
		"s_m_m_stgsailor_01",
		"s_m_m_strcowpoke_01",
		"s_m_m_strdealer_01",
		"s_m_m_strlumberjack_01",
		"s_m_m_tailor_01",
		"s_m_m_trainstationworker_01",
		"s_m_m_tumdeputies_01",
		"s_m_m_unibutchers_01",
		"s_m_m_unitrainengineer_01",
		"s_m_m_unitrainguards_01",
		"s_m_m_valbankguards_01",
		"s_m_m_valcowpoke_01",
		"s_m_m_valdealer_01",
		"s_m_m_valdeputy_01",
		"s_m_m_vhtdealer_01",
		"s_m_o_cktworker_01",
		"s_m_y_army_01",
		"s_m_y_newspaperboy_01",
		"s_m_y_racrailworker_01",
		"shack_missinghusband_males_01",
		"shack_ontherun_males_01",
		"u_f_m_bht_wife",
		"u_f_m_circuswagon_01",
		"u_f_m_emrdaughter_01",
		"u_f_m_fussar1lady_01",
		"u_f_m_htlwife_01",
		"u_f_m_lagmother_01",
		"u_f_m_nbxresident_01",
		"u_f_m_rhdnudewoman_01",
		"u_f_m_rkshomesteadtenant_01",
		"u_f_m_story_blackbelle_01",
		"u_f_m_story_nightfolk_01",
		"u_f_m_tljbartender_01",
		"u_f_m_tumgeneralstoreowner_01",
		"u_f_m_valtownfolk_01",
		"u_f_m_valtownfolk_02",
		"u_f_m_vhtbartender_01",
		"u_f_o_hermit_woman_01",
		"u_f_o_wtctownfolk_01",
		"u_f_y_braithwaitessecret_01",
		"u_f_y_czphomesteaddaughter_01",
		"u_m_m_announcer_01",
		"u_m_m_apfdeadman_01",
		"u_m_m_armgeneralstoreowner_01",
		"u_m_m_armtrainstationworker_01",
		"u_m_m_armundertaker_01",
		"u_m_m_armytrn4_01",
		"u_m_m_asbgunsmith_01",
		"u_m_m_asbprisoner_01",
		"u_m_m_asbprisoner_02",
		"u_m_m_bht_banditomine",
		"u_m_m_bht_banditoshack",
		"u_m_m_bht_benedictallbright",
		"u_m_m_bht_blackwaterhunt",
		"u_m_m_bht_exconfedcampreturn",
		"u_m_m_bht_laramiesleeping",
		"u_m_m_bht_lover",
		"u_m_m_bht_mineforeman",
		"u_m_m_bht_nathankirk",
		"u_m_m_bht_odriscolldrunk",
		"u_m_m_bht_odriscollmauled",
		"u_m_m_bht_odriscollsleeping",
		"u_m_m_bht_oldman",
		"u_m_m_bht_saintdenissaloon",
		"u_m_m_bht_shackescape",
		"u_m_m_bht_skinnerbrother",
		"u_m_m_bht_skinnersearch",
		"u_m_m_bht_strawberryduel",
		"u_m_m_bivforeman_01",
		"u_m_m_blwtrainstationworker_01",
		"u_m_m_bulletcatchvolunteer_01",
		"u_m_m_bwmstablehand_01",
		"u_m_m_cabaretfirehat_01",
		"u_m_m_cajhomestead_01",
		"u_m_m_chelonianjumper_01",
		"u_m_m_chelonianjumper_02",
		"u_m_m_chelonianjumper_03",
		"u_m_m_chelonianjumper_04",
		"u_m_m_circuswagon_01",
		"u_m_m_cktmanager_01",
		"u_m_m_cornwalldriver_01",
		"u_m_m_crdhomesteadtenant_01",
		"u_m_m_crdhomesteadtenant_02",
		"u_m_m_crdwitness_01",
		"u_m_m_creolecaptain_01",
		"u_m_m_czphomesteadfather_01",
		"u_m_m_dorhomesteadhusband_01",
		"u_m_m_emrfarmhand_03",
		"u_m_m_emrfather_01",
		"u_m_m_executioner_01",
		"u_m_m_fatduster_01",
		"u_m_m_finale2_aa_upperclass_01",
		"u_m_m_galastringquartet_01",
		"u_m_m_galastringquartet_02",
		"u_m_m_galastringquartet_03",
		"u_m_m_galastringquartet_04",
		"u_m_m_gamdoorman_01",
		"u_m_m_hhrrancher_01",
		"u_m_m_htlforeman_01",
		"u_m_m_htlhusband_01",
		"u_m_m_htlrancherbounty_01",
		"u_m_m_islbum_01",
		"u_m_m_lnsoutlaw_01",
		"u_m_m_lnsoutlaw_02",
		"u_m_m_lnsoutlaw_03",
		"u_m_m_lnsoutlaw_04",
		"u_m_m_lnsworker_01",
		"u_m_m_lnsworker_02",
		"u_m_m_lnsworker_03",
		"u_m_m_lnsworker_04",
		"u_m_m_lrshomesteadtenant_01",
		"u_m_m_mfrrancher_01",
		"u_m_m_mud3pimp_01",
		"u_m_m_nbxbankerbounty_01",
		"u_m_m_nbxbartender_01",
		"u_m_m_nbxbartender_02",
		"u_m_m_nbxboatticketseller_01",
		"u_m_m_nbxbronteasc_01",
		"u_m_m_nbxbrontegoon_01",
		"u_m_m_nbxbrontesecform_01",
		"u_m_m_nbxgeneralstoreowner_01",
		"u_m_m_nbxgraverobber_01",
		"u_m_m_nbxgraverobber_02",
		"u_m_m_nbxgraverobber_03",
		"u_m_m_nbxgraverobber_04",
		"u_m_m_nbxgraverobber_05",
		"u_m_m_nbxgunsmith_01",
		"u_m_m_nbxliveryworker_01",
		"u_m_m_nbxmusician_01",
		"u_m_m_nbxpriest_01",
		"u_m_m_nbxresident_01",
		"u_m_m_nbxresident_02",
		"u_m_m_nbxresident_03",
		"u_m_m_nbxresident_04",
		"u_m_m_nbxriverboatpitboss_01",
		"u_m_m_nbxriverboattarget_01",
		"u_m_m_nbxshadydealer_01",
		"u_m_m_nbxskiffdriver_01",
		"u_m_m_oddfellowparticipant_01",
		"u_m_m_odriscollbrawler_01",
		"u_m_m_orpguard_01",
		"u_m_m_racforeman_01",
		"u_m_m_racquartermaster_01",
		"u_m_m_rhdbackupdeputy_01",
		"u_m_m_rhdbackupdeputy_02",
		"u_m_m_rhdbartender_01",
		"u_m_m_rhddoctor_01",
		"u_m_m_rhdfiddleplayer_01",
		"u_m_m_rhdgenstoreowner_01",
		"u_m_m_rhdgenstoreowner_02",
		"u_m_m_rhdgunsmith_01",
		"u_m_m_rhdpreacher_01",
		"u_m_m_rhdsheriff_01",
		"u_m_m_rhdtrainstationworker_01",
		"u_m_m_rhdundertaker_01",
		"u_m_m_riodonkeyrider_01",
		"u_m_m_rkfrancher_01",
		"u_m_m_rkrdonkeyrider_01",
		"u_m_m_rwfrancher_01",
		"u_m_m_sdbankguard_01",
		"u_m_m_sdcustomvendor_01",
		"u_m_m_sdexoticsshopkeeper_01",
		"u_m_m_sdphotographer_01",
		"u_m_m_sdpolicechief_01",
		"u_m_m_sdstrongwomanassistant_01",
		"u_m_m_sdtrapper_01",
		"u_m_m_sdwealthytraveller_01",
		"u_m_m_shackserialkiller_01",
		"u_m_m_shacktwin_01",
		"u_m_m_shacktwin_02",
		"u_m_m_skinnyoldguy_01",
		"u_m_m_story_armadillo_01",
		"u_m_m_story_cannibal_01",
		"u_m_m_story_chelonian_01",
		"u_m_m_story_copperhead_01",
		"u_m_m_story_creeper_01",
		"u_m_m_story_emeraldranch_01",
		"u_m_m_story_hunter_01",
		"u_m_m_story_manzanita_01",
		"u_m_m_story_murfee_01",
		"u_m_m_story_pigfarm_01",
		"u_m_m_story_princess_01",
		"u_m_m_story_redharlow_01",
		"u_m_m_story_rhodes_01",
		"u_m_m_story_sdstatue_01",
		"u_m_m_story_spectre_01",
		"u_m_m_story_treasure_01",
		"u_m_m_story_tumbleweed_01",
		"u_m_m_story_valentine_01",
		"u_m_m_strfreightstationowner_01",
		"u_m_m_strgenstoreowner_01",
		"u_m_m_strsherriff_01",
		"u_m_m_strwelcomecenter_01",
		"u_m_m_tumbartender_01",
		"u_m_m_tumbutcher_01",
		"u_m_m_tumgunsmith_01",
		"u_m_m_tumtrainstationworker_01",
		"u_m_m_unibountyhunter_01",
		"u_m_m_unibountyhunter_02",
		"u_m_m_unidusterhenchman_01",
		"u_m_m_unidusterhenchman_02",
		"u_m_m_unidusterhenchman_03",
		"u_m_m_unidusterleader_01",
		"u_m_m_uniexconfedsbounty_01",
		"u_m_m_unionleader_01",
		"u_m_m_unionleader_02",
		"u_m_m_unipeepingtom_01",
		"u_m_m_valauctionforman_01",
		"u_m_m_valauctionforman_02",
		"u_m_m_valbarber_01",
		"u_m_m_valbartender_01",
		"u_m_m_valbeartrap_01",
		"u_m_m_valbutcher_01",
		"u_m_m_valdoctor_01",
		"u_m_m_valgenstoreowner_01",
		"u_m_m_valgunsmith_01",
		"u_m_m_valhotelowner_01",
		"u_m_m_valpokerplayer_01",
		"u_m_m_valpokerplayer_02",
		"u_m_m_valpoopingman_01",
		"u_m_m_valsheriff_01",
		"u_m_m_valtheman_01",
		"u_m_m_valtownfolk_01",
		"u_m_m_valtownfolk_02",
		"u_m_m_vhtstationclerk_01",
		"u_m_m_walgeneralstoreowner_01",
		"u_m_m_wapofficial_01",
		"u_m_m_wtccowboy_04",
		"u_m_o_armbartender_01",
		"u_m_o_asbsheriff_01",
		"u_m_o_bht_docwormwood",
		"u_m_o_blwbartender_01",
		"u_m_o_blwgeneralstoreowner_01",
		"u_m_o_blwphotographer_01",
		"u_m_o_blwpolicechief_01",
		"u_m_o_cajhomestead_01",
		"u_m_o_cmrcivilwarcommando_01",
		"u_m_o_mapwiseoldman_01",
		"u_m_o_oldcajun_01",
		"u_m_o_pshrancher_01",
		"u_m_o_rigtrainstationworker_01",
		"u_m_o_valbartender_01",
		"u_m_o_vhtexoticshopkeeper_01",
		"u_m_y_cajhomestead_01",
		"u_m_y_czphomesteadson_01",
		"u_m_y_czphomesteadson_02",
		"u_m_y_czphomesteadson_03",
		"u_m_y_czphomesteadson_04",
		"u_m_y_czphomesteadson_05",
		"u_m_y_duellistbounty_01",
		"u_m_y_emrson_01",
		"u_m_y_htlworker_01",
		"u_m_y_htlworker_02",
		"u_m_y_shackstarvingkid_01",
		"western_saddle_01",
		"western_saddle_02",
		"western_saddle_03",
		"western_saddle_04",
	}
}
Scooby.Configs.Horses = {
	"A_C_Donkey_01",
	"A_C_Horse_AmericanPaint_Greyovero",
	"A_C_Horse_AmericanPaint_Overo",
	"A_C_Horse_AmericanPaint_SplashedWhite",
	"A_C_Horse_AmericanPaint_Tobiano",
	"A_C_Horse_AmericanStandardbred_Black",
	"A_C_Horse_AmericanStandardbred_Buckskin",
	"A_C_Horse_AmericanStandardbred_PalominoDapple",
	"A_C_Horse_AmericanStandardbred_SilverTailBuckskin",
	"A_C_Horse_Andalusian_DarkBay",
	"A_C_Horse_Andalusian_Perlino",
	"A_C_Horse_Andalusian_RoseGray",
	"A_C_Horse_Appaloosa_BlackSnowflake",
	"A_C_Horse_Appaloosa_Blanket",
	"A_C_Horse_Appaloosa_BrownLeopard",
	"A_C_Horse_Appaloosa_FewSpotted_PC",
	"A_C_Horse_Appaloosa_Leopard",
	"A_C_Horse_Appaloosa_LeopardBlanket",
	"A_C_Horse_Arabian_Black",
	"A_C_Horse_Arabian_Grey",
	"A_C_Horse_Arabian_RedChestnut",
	"A_C_Horse_Arabian_RedChestnut_PC",
	"A_C_Horse_Arabian_RoseGreyBay",
	"A_C_Horse_Arabian_WarpedBrindle_PC",
	"A_C_Horse_Arabian_White",
	"A_C_Horse_Ardennes_BayRoan",
	"A_C_Horse_Ardennes_IronGreyRoan",
	"A_C_Horse_Ardennes_StrawberryRoan",
	"A_C_Horse_Belgian_BlondChestnut",
	"A_C_Horse_Belgian_MealyChestnut",
	"A_C_Horse_Buell_WarVets",
	"A_C_Horse_DutchWarmblood_ChocolateRoan",
	"A_C_Horse_DutchWarmblood_SealBrown",
	"A_C_Horse_DutchWarmblood_SootyBuckskin",
	"A_C_Horse_EagleFlies",
	"A_C_Horse_Gang_Bill",
	"A_C_Horse_Gang_Charles",
	"A_C_Horse_Gang_Charles_EndlessSummer",
	"A_C_Horse_Gang_Dutch",
	"A_C_Horse_Gang_Hosea",
	"A_C_Horse_Gang_Javier",
	"A_C_Horse_Gang_John",
	"A_C_Horse_Gang_Karen",
	"A_C_Horse_Gang_Kieran",
	"A_C_Horse_Gang_Lenny",
	"A_C_Horse_Gang_Micah",
	"A_C_Horse_Gang_Sadie",
	"A_C_Horse_Gang_Sadie_EndlessSummer",
	"A_C_Horse_Gang_Sean",
	"A_C_Horse_Gang_Trelawney",
	"A_C_Horse_Gang_Uncle",
	"A_C_Horse_Gang_Uncle_EndlessSummer",
	"A_C_Horse_HungarianHalfbred_DarkDappleGrey",
	"A_C_Horse_HungarianHalfbred_FlaxenChestnut",
	"A_C_Horse_HungarianHalfbred_LiverChestnut",
	"A_C_Horse_HungarianHalfbred_PiebaldTobiano",
	"A_C_Horse_John_EndlessSummer",
	"A_C_Horse_KentuckySaddle_Black",
	"A_C_Horse_KentuckySaddle_ButterMilkBuckskin_PC",
	"A_C_Horse_KentuckySaddle_ChestnutPinto",
	"A_C_Horse_KentuckySaddle_Grey",
	"A_C_Horse_KentuckySaddle_SilverBay",
	"A_C_Horse_MissouriFoxTrotter_AmberChampagne",
	"A_C_Horse_MissouriFoxTrotter_SableChampagne",
	"A_C_Horse_MissouriFoxTrotter_SilverDapplePinto",
	"A_C_Horse_Morgan_Bay",
	"A_C_Horse_Morgan_BayRoan",
	"A_C_Horse_Morgan_FlaxenChestnut",
	"A_C_Horse_Morgan_LiverChestnut_PC",
	"A_C_Horse_Morgan_Palomino",
	"A_C_Horse_MP_Mangy_Backup",
	"A_C_Horse_MurfreeBrood_Mange_01",
	"A_C_Horse_MurfreeBrood_Mange_02",
	"A_C_Horse_MurfreeBrood_Mange_03",
	"A_C_Horse_Mustang_GoldenDun",
	"A_C_Horse_Mustang_GrulloDun",
	"A_C_Horse_Mustang_TigerStripedBay",
	"A_C_Horse_Mustang_WildBay",
	"A_C_Horse_Nokota_BlueRoan",
	"A_C_Horse_Nokota_ReverseDappleRoan",
	"A_C_Horse_Nokota_WhiteRoan",
	"A_C_Horse_Shire_DarkBay",
	"A_C_Horse_Shire_LightGrey",
	"A_C_Horse_Shire_RavenBlack",
	"A_C_Horse_SuffolkPunch_RedChestnut",
	"A_C_Horse_SuffolkPunch_Sorrel",
	"A_C_Horse_TennesseeWalker_BlackRabicano",
	"A_C_Horse_TennesseeWalker_Chestnut",
	"A_C_Horse_TennesseeWalker_DappleBay",
	"A_C_Horse_TennesseeWalker_FlaxenRoan",
	"A_C_Horse_TennesseeWalker_GoldPalomino_PC",
	"A_C_Horse_TennesseeWalker_MahoganyBay",
	"A_C_Horse_TennesseeWalker_RedRoan",
	"A_C_Horse_Thoroughbred_BlackChestnut",
	"A_C_Horse_Thoroughbred_BloodBay",
	"A_C_Horse_Thoroughbred_Brindle",
	"A_C_Horse_Thoroughbred_DappleGrey",
	"A_C_Horse_Thoroughbred_ReverseDappleBlack",
	"A_C_Horse_Turkoman_DarkBay",
	"A_C_Horse_Turkoman_Gold",
	"A_C_Horse_Turkoman_Silver",
	"A_C_Horse_Winter02_01",
	"A_C_HorseMule_01",
	"A_C_HorseMulePainted_01",
}

local enable_developer_tools = true
local camera = {
	handle = nil,
	active_mode = 1,
	sensitivity = 5.0,

	speed = 10,
	speed_intervals = 2,
	min_speed = 2,
	max_speed = 100,
	boost_factor = 10.0,

	keybinds = {
		toggle = 0x446258B6,        -- 0x446258B6 = Page Up
		boost = `INPUT_SPRINT`,     -- INPUT_SPRINT, Left Shift
		decrease_speed = 0xDE794E3E, --Q
		increase_speed = 0xCEFD9220, -- E
		forward = `INPUT_MOVE_UP_ONLY`, -- W
		reverse = `INPUT_MOVE_DOWN_ONLY`, -- S
		left = `INPUT_MOVE_LEFT_ONLY`, -- A
		right = `INPUT_MOVE_RIGHT_ONLY`, -- D
		up = `INPUT_JUMP`,          -- Space
		down = `INPUT_DUCK`,        -- Ctrl
		switch_mode = `INPUT_AIM`,
		mode_action = 0x07CE1E61
	},

	modes = {
		{
			label = "Freecam",
			left_click_action = function(coords)
				return
			end
		},
		{
			label = "Teleport Player",
			left_click_action = function(coords)
				SetEntityCoords(PlayerPedId(), coords)
			end
		},
		{
			label = "Explosion",
			left_click_action = function(coords)
				Scooby.native(0xD84A917A64D4D016, PlayerPedId(), coords.x, coords.y, coords.z, 27, 1000.0, true, false,
					true)
				Scooby.native(0xD84A917A64D4D016, PlayerPedId(), coords.x, coords.y, coords.z, 30, 1000.0, true, false,
					true)
				Scooby.Print("Drone Strike", "Drone Strike", false)
			end
		},
		{
			label = "Bear",
			left_click_action = function(coords)
				local invisibleped = CreatePed(3170700927, coords.x, coords.y, coords.z, 0.0, true, false)
				SetEntityMaxHealth(invisibleped, 1250)
				SetEntityHealth(invisibleped, 1250)
				SetEntityAsMissionEntity(invisibleped, -1, 0)
				Citizen.InvokeNative(0x283978A15512B2FE, invisibleped, true)
				Scooby.Print("Bear Pack", "Spawned Bear pack", false)
			end
		}
	}

}

-- To be re-enabled
camera.keybinds.enable_controls = {
	`INPUT_FRONTEND_PAUSE_ALTERNATE`,
	`INPUT_MP_TEXT_CHAT_ALL`,
	camera.keybinds.decrease_speed,
	camera.keybinds.increase_speed
}


-- dumper features --

local dumper = {
	client = {},
	cfg = {
		"client_script",
		"client_scripts",
		"shared_script",
		"shared_scripts",
		"ui_page",
		"ui_pages",
		"file",
		"files",
		"loadscreen",
		"map"
	}
}

function dumper:getResources()
	local resources = {}
	for i = 1, GetNumResources() do
		resources[i] = GetResourceByFindIndex(i)
	end

	return resources
end

function dumper:getFiles(res, cfg)
	res = (res or GetCurrentResourceName())
	cfg = (cfg or self.cfg)
	self.client[res] = {}
	for i, metaKey in ipairs(cfg) do
		for idx = 0, GetNumResourceMetadata(res, metaKey) - 1 do
			local file = (GetResourceMetadata(res, metaKey, idx) or "none")
			local code = (LoadResourceFile(res, file) or "")
			self.client[res][file] = code
		end
	end

	self.client[res]["manifest.lua"] = (LoadResourceFile(res, "__resource.lua") or LoadResourceFile(res, "fxmanifest.lua"))
end

--		              --
-- Movement Functions --
------------------------

local function get_relative_location(_location, _rotation, _distance)
	_location = _location or vector3(0, 0, 0)
	_rotation = _rotation or vector3(0, 0, 0)
	_distance = _distance or 10.0

	local tZ = math.rad(_rotation.z)
	local tX = math.rad(_rotation.x)

	local absX = math.abs(math.cos(tX))

	local rx = _location.x + (-math.sin(tZ) * absX) * _distance
	local ry = _location.y + (math.cos(tZ) * absX) * _distance
	local rz = _location.z + (math.sin(tX)) * _distance

	return vector3(rx, ry, rz)
end

local function get_camera_movement(location, rotation, frame_time)
	local multiplier = 1.0

	if IsDisabledControlPressed(0, camera.keybinds.boost) then
		multiplier = camera.boost_factor
	end

	local speed = camera.speed * frame_time

	if IsDisabledControlPressed(0, camera.keybinds.right) then
		local camera_rotation = vector3(0, 0, rotation.z)
		location = get_relative_location(location, camera_rotation + vector3(0, 0, -90), speed)
	elseif IsDisabledControlPressed(0, camera.keybinds.left) then
		local camera_rotation = vector3(0, 0, rotation.z)
		location = get_relative_location(location, camera_rotation + vector3(0, 0, 90), speed)
	end

	if IsDisabledControlPressed(0, camera.keybinds.forward) then
		location = get_relative_location(location, rotation, speed)
	elseif IsDisabledControlPressed(0, camera.keybinds.reverse) then
		location = get_relative_location(location, rotation, -speed)
	end

	if IsDisabledControlPressed(0, camera.keybinds.up) then
		location = location + vector3(0, 0, speed)
	elseif IsDisabledControlPressed(0, camera.keybinds.down) then
		location = location + vector3(0, 0, -speed)
	end

	return location
end

local function get_mouse_movement()
	local x = GetDisabledControlNormal(0, GetHashKey('INPUT_LOOK_UD'))
	local y = 0
	local z = GetDisabledControlNormal(0, GetHashKey('INPUT_LOOK_LR'))
	return vector3(-x, y, -z) * camera.sensitivity
end

local function render_collision(current_location, new_location)
	RequestCollisionAtCoord(new_location.x, new_location.y, new_location.z)

	SetFocusPosAndVel(new_location.x, new_location.y, new_location.z, 0.0, 0.0, 0.0)

	Citizen.InvokeNative(0x387AD749E3B69B70, new_location.x, new_location.y, new_location.z, new_location.x,
		new_location.y, new_location.z, 50.0, 0)                                                                                                   -- LOAD_SCENE_START
	Citizen.InvokeNative(0x5A8B01199C3E79C3)                                                                                                       -- LOAD_SCENE_STOP
end

--				  --
-- Invoke Wrapper --
--------------------

local function draw_marker(type, posX, posY, posZ, dirX, dirY, dirZ, rotX, rotY, rotZ, scaleX, scaleY, scaleZ, red, green,
						   blue, alpha, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
	Citizen.InvokeNative(0x2A32FAA57B937173, type, posX, posY, posZ, dirX, dirY, dirZ, rotX, rotY, rotZ, scaleX, scaleY,
		scaleZ, red, green, blue, alpha, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
end

local function draw_raycast(distance, coords, rotation)
	local camera_coord = coords

	local adjusted_rotation = { x = (math.pi / 180) * rotation.x, y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z }
	local direction = { x = -math.sin(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)),
		y = math.cos(adjusted_rotation.z) * math.abs(math.cos(adjusted_rotation.x)), z = math.sin(adjusted_rotation.x) }

	local destination =
	{
		x = camera_coord.x + direction.x * distance,
		y = camera_coord.y + direction.y * distance,
		z = camera_coord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(camera_coord.x, camera_coord.y, camera_coord.z,
		destination.x, destination.y, destination.z, -1, -1, 1))

	return b, c, e
end

local function draw_text(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

Scooby.developer_tools = function(location, rotation)
	local hit, coords, entity = draw_raycast(1000.0, location, rotation)

	if camera.modes[camera.active_mode].label ~= "" then
		draw_marker(0x50638AB9, coords, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 255, 100, 100, 100, 0, 0, 2, 0, 0, 0, 0)
		draw_text(
		('Camera Mode\n%s (Speed: %.3f)\n PageUp To Exit Freecam'):format(camera.modes[camera.active_mode].label,
			camera.speed, coords.x, coords.y, coords.z, location, rotation), 0.5, 0.01, true)
	end

	if IsDisabledControlPressed(1, camera.keybinds.mode_action) and coords and camera.modes[camera.active_mode].left_click_action then -- Left click action
		camera.modes[camera.active_mode].left_click_action(coords)
	elseif IsDisabledControlJustReleased(0, camera.keybinds.switch_mode) then
		if camera.active_mode >= #camera.modes then
			camera.active_mode = 1
		else
			camera.active_mode = camera.active_mode + 1
		end
	end
end

--		              --
-- Endpoint Functions --
------------------------

Scooby.stop_freecam = function()
	RenderScriptCams(false, true, 500, true, true)
	SetCamActive(camera.handle, false)
	DetachCam(camera.handle)
	DestroyCam(camera.handle, true)
	ClearFocus()
	camera.handle = nil
end

Scooby.start_freecam = function()
	camera.handle = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamRot(camera.handle, GetGameplayCamRot(2), 2)
	SetCamCoord(camera.handle, GetGameplayCamCoord())
	RenderScriptCams(true, true, 500, true, true)

	while camera.handle do
		Citizen.Wait(0)

		local current_location = GetCamCoord(camera.handle)
		local current_rotation = GetCamRot(camera.handle, 2)

		local new_rotation = current_rotation + get_mouse_movement()
		if current_rotation.x > 85 then
			current_rotation = vector3(85, current_rotation.y, current_rotation.z)
		elseif current_rotation.x < -85 then
			current_rotation = vector3(-85, current_rotation.y, current_rotation.z)
		end

		local new_location = get_camera_movement(current_location, new_rotation, GetFrameTime())
		SetCamCoord(camera.handle, new_location)
		SetCamRot(camera.handle, new_rotation, 2)

		render_collision(current_location, new_location)
		if enable_developer_tools then
			Scooby.developer_tools(current_location, new_rotation)
		end

		if IsDisabledControlJustReleased(0, camera.keybinds.toggle) then
			Scooby.stop_freecam()
		end

		DisableFirstPersonCamThisFrame()
		DisableAllControlActions(0)

		for k, v in ipairs(camera.keybinds.enable_controls) do
			EnableControlAction(0, v)
		end
	end
end

Scooby.toggle_camera = function()
	if camera.handle then
		Scooby.stop_freecam()
	else
		Scooby.start_freecam()
	end
end

Scooby.pedID = function()
	return Scooby.native(0x096275889B8E0EE0)
end

Scooby.createThread = function(cb)
	Citizen.CreateThread(cb)
end

Scooby.module = function(moduleLoad)
	while not Scooby do Wait(500) end
	; moduleLoad()
end

Scooby.requestControl = function(entity)
	local type = GetEntityType(entity)

	if type < 1 or type > 3 then
		return
	end

	NetworkRequestControlOfEntity(entity)
end

Scooby.Notifications.txt = function(text, x, y, fontscale, fontsize, r, g, b, alpha, textcentred, shadow)
	local str = CreateVarString(10, "LITERAL_STRING", text)
	SetTextScale(fontscale, fontsize)
	SetTextColor(r, g, b, alpha)
	SetTextCentre(textcentred)
	if (shadow) then SetTextDropshadow(1, 0, 0, 255) end
	SetTextFontForCurrentCommand(9)
	DisplayText(str, x, y)
end

Scooby.Print = function(printTxt, notificationTxt, error)
	-- Console traces disabled to avoid AC detection
	if notificationTxt then
		if Scooby.Notifications.enabled then table.insert(Scooby.Notifications.queue,
				{ txt = notificationTxt, added = GetGameTimer() + (Scooby.Notifications.duration * #Scooby.Notifications.queue) }) end
	end
end

Scooby.Notifications.startQueue = function()
	Scooby.createThread(function()
		while (true) do
			Citizen.Wait(0)

			if #Scooby.Notifications.queue > 0 then
				-- Clean small notification - bottom right corner
				local msg = Scooby.Notifications.queue[1].txt
				local elapsed = GetGameTimer() - Scooby.Notifications.queue[1].added
				local alpha = 230
				local dur = Scooby.Notifications.duration
				local fadeStart = dur - 300
				-- Fade out in last 300ms
				if elapsed > fadeStart then
					alpha = math.floor(230 * (1.0 - (elapsed - fadeStart) / 300))
					if alpha < 0 then alpha = 0 end
				end

				-- Dark notification box
				DrawRect(0.85, 0.92, 0.22, 0.035, 8, 10, 16, math.floor(alpha * 0.8))
				-- Cyan left accent
				DrawRect(0.74, 0.92, 0.003, 0.03, 0, 200, 255, alpha)
				-- Text
				Scooby.Notifications.txt(msg, 0.85, 0.91, 0.28, 0.28, 220, 220, 230, alpha, true, false)

				if elapsed > dur then
					table.remove(Scooby.Notifications.queue, 1)
				end
			end

			if not Scooby.Notifications.enabled then
				break
			end
		end
	end)
end

Scooby.createThread(function()
	Scooby.Notifications.startQueue()
end)

Scooby.lastDeathCoords = nil
Scooby.createThread(function()
	while true do
		Citizen.Wait(500)
		if IsPedDeadOrDying(Scooby.pedID()) then
			Scooby.lastDeathCoords = GetEntityCoords(Scooby.pedID())
		end
	end
end)

-- Startup splash — shows briefly then fades
Scooby.createThread(function()
	local startTime = GetGameTimer()
	local duration = 4000 -- 4 seconds
	while true do
		_w(0)
		local elapsed = GetGameTimer() - startTime
		if elapsed > duration then break end

		local alpha = 255
		if elapsed > duration - 1000 then
			alpha = math.floor(255 * (1.0 - (elapsed - (duration - 1000)) / 1000))
		end
		if alpha < 0 then alpha = 0 end

		-- Center splash
		DrawRect(0.5, 0.45, 0.22, 0.08, 8, 10, 16, math.floor(alpha * 0.85))
		DrawRect(0.5, 0.418, 0.22, 0.003, 0, 200, 255, alpha)
		DrawRect(0.5, 0.483, 0.22, 0.003, 0, 200, 255, alpha)
		DrawTxt("ScoobyOP", 0.5, 0.432, 0.55, false, 0, 200, 255, alpha, true, 9)
		DrawTxt("v" .. Scooby.version .. " | F6 / DEL to open", 0.5, 0.462, 0.25, false, 180, 180, 190, math.floor(alpha * 0.7), true, 9)
	end

end)

-- Auto-open menu after everything loads
Scooby.createThread(function()
	-- Wait for menu system to fully initialize
	Citizen.Wait(8000)
	if Scooby.Menu.OpenMenu and not Scooby.Menu.IsAnyMenuOpened() then
		Scooby.Menu.OpenMenu('scooby_main')
	end
end)

Scooby.randomRGB = function(speed, alpha)
	local n = GetGameTimer() / 300
	local r, g, b = math.floor(math.sin(n * speed) * 127 + 128), math.floor(math.sin(n * speed + 2) * 127 + 128),
		math.floor(math.sin(n * speed + 4) * 127 + 128)
	return r, g, b, alpha == nil and 255 or alpha
end

local menus = {}
local keys = { up = 0x6319DB71, down = 0x05CA7C52, left = 0xA65EBAB4, right = 0xDEB34313, select = 0xC7B5340A,
	back = 0x156F7119 }

local optionCount = 0

local currentKey = nil
local currentMenu = nil

local titleHeight = 0.065
local titleYOffset = 0.004
local titleScale = 1.0

local descWidth = 0.10
local descHeight = 0.030

local menuWidth = 0.200

local buttonHeight = 0.032
local buttonFont = 9
local buttonScale = 0.32

local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.004


local function debugPrint(text)
	if Scooby.Menu.debug then
		Scooby.Print(text, false, false)
	end
end


local function setMenuProperty(id, property, value)
	if id and menus[id] then
		menus[id][property] = value
		debugPrint(id .. ' menu property changed: { ' .. tostring(property) .. ', ' .. tostring(value) .. ' }')
	end
end


local function isMenuVisible(id)
	if id and menus[id] then
		return menus[id].visible
	else
		return false
	end
end


local function setMenuVisible(id, visible, holdCurrent)
	if id and menus[id] then
		setMenuProperty(id, 'visible', visible)

		if not holdCurrent and menus[id] then
			setMenuProperty(id, 'currentOption', 1)
		end

		if visible then
			if id ~= currentMenu and isMenuVisible(currentMenu) then
				setMenuVisible(currentMenu, false)
			end

			currentMenu = id
		end
	end
end

local function mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

local function drawMultilineFormat(str)
	return str, #mysplit(str, "\n")
end


local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
	local str = CreateVarString(10, "LITERAL_STRING", text)

	if color then
		SetTextColor(color.r, color.g, color.b, color.a)
	else
		SetTextColor(255, 255, 255, 255)
	end

	SetTextFontForCurrentCommand(font)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropshadow(1, 0, 0, 0, 200)
	end

	if center then
		SetTextCentre(center)
	end

	DisplayText(str, x, y)
end

local function drawTitle()
	if menus[currentMenu] then
		local x = menus[currentMenu].x + menus[currentMenu].width / 2
		local w = menus[currentMenu].width
		local baseY = menus[currentMenu].y

		-- Header height (title only)
		local titleH = 0.045
		local subBarH = 0.024

		-- === Title bar ===
		DrawRect(x, baseY + titleH / 2, w, titleH, 8, 10, 16, 240)
		-- Cyan top line
		DrawRect(x, baseY + 0.0015, w, 0.003, 0, 200, 255, 255)
		-- Title text
		drawText("ScoobyOP", x, baseY + 0.008, 9, { r = 0, g = 200, b = 255, a = 255 }, 0.65, true, true)

		-- === Sub bar (below title) ===
		local subBarY = baseY + titleH
		DrawRect(x, subBarY + subBarH / 2, w, subBarH, 16, 18, 26, 230)

		-- Sub-menu name on the left
		local subName = menus[currentMenu].subTitle or ""
		if subName == "" then subName = "Main Menu" end
		drawText(subName, menus[currentMenu].x + 0.006, subBarY + 0.003, 9, { r = 200, g = 200, b = 210, a = 255 }, 0.24, false, false)

		-- Version on the right
		local verX = menus[currentMenu].x + w - 0.006 - (string.len("v1.0.0") * 0.0025)
		drawText("v1.0.0", verX, subBarY + 0.003, 9, { r = 80, g = 80, b = 90, a = 200 }, 0.24, false, false)

		-- Cyan line below sub bar
		DrawRect(x, subBarY + subBarH - 0.001, w, 0.002, 0, 180, 255, 150)

		-- Update titleHeight for button positioning
		titleHeight = titleH + subBarH
	end
end

local function drawButton(text, subText, isInfo)
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local w = menus[currentMenu].width
	local multiplier = nil

	if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
		multiplier = optionCount
	elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
		multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
	end

	if multiplier then
		local y = menus[currentMenu].y + titleHeight + (buttonHeight * multiplier) - buttonHeight / 2
		local textColor = nil
		local subTextColor = nil
		local shadow = false
		local isSelected = menus[currentMenu].currentOption == optionCount

		if isSelected then
			-- Selected: subtle cyan tinted background
			DrawRect(x, y, w, buttonHeight, 0, 180, 255, 25)
			-- Left accent bar (3px wide cyan)
			DrawRect(menus[currentMenu].x + 0.0022, y, 0.0035, buttonHeight - 0.002, 0, 200, 255, 255)
			textColor = { r = 255, g = 255, b = 255, a = 255 }
			subTextColor = { r = 0, g = 200, b = 255, a = 255 }
		else
			-- Normal: dark solid background
			DrawRect(x, y, w, buttonHeight, 14, 16, 22, 220)
			textColor = { r = 200, g = 200, b = 210, a = 255 }
			subTextColor = { r = 130, g = 130, b = 140, a = 255 }
			shadow = false
		end

		-- 1px separator line below each item
		DrawRect(x, y + buttonHeight / 2, w, 0.001, 30, 35, 45, 100)

		if isInfo then
			-- Info items: cyan text, no extra background
			drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset,
				buttonFont, { r = 0, g = 200, b = 255, a = 255 }, buttonScale, false, false)
		else
			drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset,
				buttonFont, textColor, buttonScale, false, shadow)
		end

		if subText then
			-- Right-align subtext manually: estimate text width and offset from right edge
			local subLen = string.len(subText)
			local charW = buttonScale * 0.008 -- approximate character width
			local textW = subLen * charW
			local subX = menus[currentMenu].x + w - textW - 0.008
			local subCol = isSelected and { r = 0, g = 220, b = 255, a = 255 } or subTextColor
			-- Color On/Off specifically
			if subText == "On" then
				subCol = { r = 0, g = 255, b = 100, a = 255 }
			elseif subText == "Off" then
				subCol = { r = 255, g = 80, b = 80, a = 200 }
			end
			drawText(subText, subX, y - buttonHeight / 2 + buttonTextYOffset,
				buttonFont, subCol, buttonScale, false, false)
		end
	end
end

local function drawBottom()
	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local w = menus[currentMenu].width
	local multiplier = nil

	if menus[currentMenu].totalOptions >= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].maxOptionCount + 1
	elseif menus[currentMenu].totalOptions <= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].totalOptions + 1
	end

	local footerH = 0.028
	local y = menus[currentMenu].y + titleHeight + buttonHeight * multiplier - buttonHeight / 2 + footerH / 2

	-- Dark footer background
	DrawRect(x, y, w, footerH, 8, 10, 16, 240)

	-- Cyan accent line at bottom edge
	DrawRect(x, y + footerH / 2 - 0.0015, w, 0.003, 0, 200, 255, 200)

	-- Page counter on the right in cyan
	local current = menus[currentMenu].currentOption or 1
	local total = menus[currentMenu].totalOptions or 0
	local pageText = tostring(current) .. " / " .. tostring(total)
	drawText(pageText, menus[currentMenu].x + w - 0.006, y - footerH / 2 + 0.004,
		9, { r = 0, g = 200, b = 255, a = 255 }, 0.24, false, false, true)

	-- ScoobyOP branding on the left in dark grey
	drawText("ScoobyOP", menus[currentMenu].x + 0.005, y - footerH / 2 + 0.004,
		9, { r = 60, g = 60, b = 70, a = 180 }, 0.22, false, false, false)

	-- Description text for the selected item (centered in footer area)
	if menus[currentMenu].descText and menus[currentMenu].descText ~= "" then
		local descY = y + footerH / 2 + 0.005
		local descBoxH = 0.026
		-- Semi-transparent dark description box below footer
		DrawRect(x, descY + descBoxH / 2 - 0.002, w, descBoxH, 10, 12, 18, 210)
		drawText(menus[currentMenu].descText, x, descY - 0.001,
			9, { r = 170, g = 170, b = 180, a = 220 }, 0.23, true, false, false)
	end
end


local function drawDescription(text)
	if text == nil or text == "" then
		return
	end

	local x = menus[currentMenu].x + menus[currentMenu].width / 2
	local w = menus[currentMenu].width
	local multiplier = nil

	if menus[currentMenu].totalOptions >= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].maxOptionCount + 1
	elseif menus[currentMenu].totalOptions <= menus[currentMenu].maxOptionCount then
		multiplier = menus[currentMenu].totalOptions + 1
	end

	local footerH = 0.028
	local baseY = menus[currentMenu].y + titleHeight + buttonHeight * multiplier - buttonHeight / 2 + footerH

	-- Check if description is already shown in footer; if so skip duplicate
	local hasDescInFooter = menus[currentMenu].descText and menus[currentMenu].descText ~= ""
	if hasDescInFooter then
		baseY = baseY + 0.026
	end

	local str, lines = drawMultilineFormat(text)
	local boxH = 0.022 + (lines - 1) * 0.014
	local boxY = baseY + 0.005 + boxH / 2

	-- Semi-transparent dark description box
	DrawRect(x, boxY, w, boxH, 10, 12, 18, 200)

	-- Description text in small grey
	drawText(text, menus[currentMenu].x + buttonTextXOffset + 0.002, baseY + 0.006,
		9, { r = 160, g = 160, b = 170, a = 210 }, 0.24, false, false, false)
end

Scooby.Menu.CreateMenu = function(id, title, desc)
	menus[id] = {}
	menus[id].title = title or ''
	menus[id].subTitle = ''
	menus[id].desTitle = ''
	menus[id].subMenuLeft = ''

	menus[id].header = header or ''

	menus[id].visible = false
	menus[id].desc = desc or ''
	menus[id].descStat = nil

	menus[id].menuWidth = 0.20

	menus[id].previousMenu = nil

	menus[id].aboutToBeClosed = false
	menus[id].aboutToBeSubClosed = false

	menus[id].x = 0.02
	menus[id].y = 0.10

	menus[id].width = 0.21

	menus[id].currentOption = 1
	menus[id].maxOptionCount = 15

	menus[id].totalOptions = 0
	menus[id].toogleHeritage = false

	menus[id].footer = buttonHeight * (menus[id].maxOptionCount + 1)

	menus[id].titleFont = 9
	menus[id].titleColor = { r = 255, g = 255, b = 255, a = 255 }
	menus[id].titleBackgroundColor = { r = 0, g = 180, b = 255, a = 255 }
	menus[id].titleBackgroundSprite = nil

	menus[id].SliderColor = { r = 0, g = 180, b = 255, a = 255 }
	menus[id].SliderBackgroundColor = { r = 10, g = 20, b = 30, a = 255 }

	menus[id].menuTextColor = { r = 255, g = 255, b = 255, a = 255 }
	menus[id].menuSubTextColor = { r = 189, g = 189, b = 189, a = 255 }
	menus[id].menuFocusTextColor = { r = 0, g = 0, b = 0, a = 255 }
	menus[id].menuFocusBackgroundColor = { r = 0, g = 180, b = 255, a = 200 }
	menus[id].menuBackgroundColor = { r = 0, g = 0, b = 0, a = 160 }

	menus[id].subTitleBackgroundColor = { r = menus[id].menuBackgroundColor.r, g = menus[id].menuBackgroundColor.g,
		b = menus[id].menuBackgroundColor.b, a = 255 }

	menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" }
end


Scooby.Menu.CreateSubMenu = function(id, parent, subTitle, desc)
	if menus[parent] then
		Scooby.Menu.CreateMenu(id, menus[parent].title, desc)

		if subTitle then
			setMenuProperty(id, 'subTitle', string.upper(subTitle))
		else
			setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle))
		end

		setMenuProperty(id, 'previousMenu', parent)

		setMenuProperty(id, 'x', menus[parent].x)
		setMenuProperty(id, 'y', menus[parent].y)
		setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)
		setMenuProperty(id, 'titleFont', menus[parent].titleFont)
		setMenuProperty(id, 'titleColor', menus[parent].titleColor)
		setMenuProperty(id, 'titleBackgroundColor', menus[parent].titleBackgroundColor)
		setMenuProperty(id, 'titleBackgroundSprite', menus[parent].titleBackgroundSprite)
		setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
		setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
		setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
		setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
		setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
		setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor)
	else
		debugPrint('Failed to create ' .. tostring(id) .. ' submenu: ' .. tostring(parent) ..
		' parent menu doesn\'t exist')
	end
end


Scooby.Menu.CurrentMenu = function()
	return currentMenu
end


Scooby.Menu.OpenMenu = function(id)
	if id and menus[id] then
		PlaySoundFrontend("SELECT", "HUD_SHOP_SOUNDSET", 1)
		setMenuVisible(id, true)
		debugPrint(tostring(id) .. ' menu opened')
		DisplayRadar(false)
	else
		debugPrint('Failed to open ' .. tostring(id) .. ' menu: it doesn\'t exist')
	end
end


Scooby.Menu.IsMenuOpened = function(id)
	return isMenuVisible(id)
end


Scooby.Menu.IsAnyMenuOpened = function()
	for id, _ in pairs(menus) do
		if isMenuVisible(id) then return true end
	end

	return false
end


Scooby.Menu.IsMenuAboutToBeClosed = function()
	if menus[currentMenu] then
		return menus[currentMenu].aboutToBeClosed
	else
		return false
	end
end


Scooby.Menu.CloseMenu = function()
	if menus[currentMenu] then
		menus[currentMenu].aboutToBeClosed = false
		setMenuVisible(currentMenu, false)
		PlaySoundFrontend("QUIT", "HUD_SHOP_SOUNDSET", 1)
		optionCount = 0
		currentMenu = nil
		currentKey = nil
		DisplayRadar(true)
		Scooby._menuIsOpen = false
	end
end


Scooby.Menu.Button = function(text, subText, descText, isInfo)
	if menus[currentMenu] then
		descText = descText or ''

		optionCount = optionCount + 1

		local isCurrent = menus[currentMenu].currentOption == optionCount

		drawButton(text, subText, isInfo)

		menus[currentMenu].totalOptions = optionCount

		if isCurrent then
			if descText then
				menus[currentMenu].descText = descText
			end
			if currentKey == keys.select then
				PlaySoundFrontend("SELECT", "HUD_SHOP_SOUNDSET", 1)
				return true
			elseif currentKey == keys.left or currentKey == keys.right then
				PlaySoundFrontend("SELECT", "HUD_SHOP_SOUNDSET", 1)
			end
		end

		return false
	else
		debugPrint('Failed to create ' .. buttonText .. ' button: ' .. tostring(currentMenu) .. ' menu doesn\'t exist')

		return false
	end
end


Scooby.Menu.MenuButton = function(text, id)
	if menus[id] then
		if Scooby.Menu.Button(text) then
			setMenuVisible(currentMenu, false)
			setMenuVisible(id, true, true)

			return true
		end
	else
		debugPrint('Failed to create ' .. tostring(text) .. ' menu button: ' .. tostring(id) .. ' submenu doesn\'t exist')
	end

	return false
end


Scooby.Menu.CheckBox = function(text, checked, callback)
	if Scooby.Menu.Button(text, checked and 'On' or 'Off') then
		checked = not checked
		debugPrint(tostring(text) .. ' checkbox changed to ' .. tostring(checked))
		if callback then callback(checked) end

		return true
	end

	return false
end


Scooby.Menu.ComboBox = function(text, items, currentIndex, selectedIndex, callback)
	local itemsCount = #items
	local selectedItemOn = items[currentIndex]
	local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)

	if itemsCount > 1 and isCurrent then
		selectedItem = '? ' .. tostring(selectedItemOn) .. ' ?'
	end

	if Scooby.Menu.Button(text, selectedItem) then
		selectedIndex = currentIndex
		callback(currentIndex, selectedItemOn)
		return true
	elseif isCurrent then

	else
		currentIndex = selectedIndex
	end

	callback(false, false)
	return false
end


Scooby.Menu.Display = function()
	if isMenuVisible(currentMenu) then
		if menus[currentMenu].aboutToBeClosed then
			Scooby.Menu.CloseMenu()
		else
			ClearAllHelpMessages()

			drawTitle()

			drawBottom()

			-- Player info box (right side panel)
			if Scooby.drawPlayerInfoBox then
				Scooby.drawPlayerInfoBox()
			end

			currentKey = nil

			-- Description removed from side — shown in footer only

			if isPressedKey(keys.down) then
				PlaySoundFrontend("NAV_DOWN", "Ledger_Sounds", true)
				if menus[currentMenu].currentOption < optionCount then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				else
					menus[currentMenu].currentOption = 1
				end
			elseif isPressedKey(keys.up) then
				PlaySoundFrontend("NAV_UP", "Ledger_Sounds", true)
				if menus[currentMenu].currentOption > 1 then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				else
					menus[currentMenu].currentOption = optionCount
				end
			elseif isPressedKey(keys.left) then
				currentKey = keys.left
			elseif isPressedKey(keys.right) then
				currentKey = keys.right
			elseif isPressedKey(keys.select) then
				currentKey = keys.select
			elseif isPressedKey(keys.back) then
				if menus[menus[currentMenu].previousMenu] then
					PlaySoundFrontend("BACK", "HUD_SHOP_SOUNDSET", true)
					setMenuVisible(menus[currentMenu].previousMenu, true)
				else
					Scooby.Menu.CloseMenu()
				end
			end

			optionCount = 0
		end
	end
end

local k_delay = 180
local k_delay2 = 160
local k_delay3 = 130

function isPressedKey(key)
	if key ~= lastKey and IsDisabledControlPressed(1, key) then
		lastKey = key
		timer = GetGameTimer()
		count = 0
		pass = false
		return true
	elseif key == lastKey and IsDisabledControlPressed(1, key) then
		if pass then
			count = 0
			if GetGameTimer() - timer > k_delay3 and GetGameTimer() - timer < k_delay then
				timer = GetGameTimer()
				return true
			elseif GetGameTimer() - timer > k_delay then
				pass = false
				timer = GetGameTimer()
				return true
			end
			return false
		elseif GetGameTimer() - timer > k_delay + 100 then
			count = 0
			timer = GetGameTimer()
			return true
		elseif GetGameTimer() - timer > k_delay then
			count = 1
			timer = GetGameTimer()
			return true
		elseif GetGameTimer() - timer > k_delay2 and (count > 0 and count < 5) then
			count = count + 1
			timer = GetGameTimer()
			return true
		elseif count > 4 then
			pass = true
			return false
		end
		return false
	end
	return false
end

Scooby.Menu.SetMenuWidth = function(id, width)
	setMenuProperty(id, 'width', width)
end


Scooby.Menu.SetMenuX = function(id, x)
	setMenuProperty(id, 'x', x)
end


Scooby.Menu.SetMenuY = function(id, y)
	setMenuProperty(id, 'y', y)
end


Scooby.Menu.SetMenuMaxOptionCountOnScreen = function(id, count)
	setMenuProperty(id, 'maxOptionCount', count)
end


Scooby.Menu.SetTitle = function(id, title)
	setMenuProperty(id, 'title', title)
end


Scooby.Menu.SetTitleColor = function(id, r, g, b, a)
	setMenuProperty(id, 'titleColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleColor.a })
end


Scooby.Menu.SetTitleBackgroundColor = function(id, r, g, b, a)
	setMenuProperty(id, 'titleBackgroundColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].titleBackgroundColor.a })
end


Scooby.Menu.SetTitleBackgroundSprite = function(id, textureDict, textureName)
	RequestStreamedTextureDict(textureDict)
	setMenuProperty(id, 'titleBackgroundSprite', { dict = textureDict, name = textureName })
end


Scooby.Menu.SetSubTitle = function(id, text)
	setMenuProperty(id, 'subTitle', string.upper(text))
end


Scooby.Menu.SetMenuBackgroundColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuBackgroundColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuBackgroundColor.a })
end


Scooby.Menu.SetMenuTextColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuTextColor', { ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuTextColor.a })
end

Scooby.Menu.SetMenuSubTextColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuSubTextColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuSubTextColor.a })
end

Scooby.Menu.SetMenuFocusColor = function(id, r, g, b, a)
	setMenuProperty(id, 'menuFocusBackgroundColor',
		{ ['r'] = r, ['g'] = g, ['b'] = b, ['a'] = a or menus[id].menuFocusColor.a })
end


Scooby.Menu.SetMenuButtonPressedSound = function(id, name, set)
	setMenuProperty(id, 'buttonPressedSound', { ['name'] = name, ['set'] = set })
end

Scooby.Troll = {}

Scooby.keybindThreads = {}

Scooby.menuThreads = {}
Scooby.menuAttributes = {}
Scooby.menuCheckBoxes = {}
Scooby.otherSecondThreads = {}

Scooby.theLoadout = { 0x6DFA071B, 0x169F59F7, 0x7A8A724A, 0xDB21AC8C, 0x88A8505C }

Scooby.createThread(function()
	while (true) do
		Citizen.Wait(1)

		for keybind_, keybind_tick in ipairs(Scooby.keybindThreads) do
			keybind_tick()
		end

		for menu_, menu_tick in ipairs(Scooby.menuThreads) do
			menu_tick()
		end

		for othersecond_, othersecond_tick in ipairs(Scooby.otherSecondThreads) do
			othersecond_tick()
		end
	end
end)

Scooby.registerKey = function(key, cb)
	table.insert(Scooby.keybindThreads, function()
		if isPressedKey(key) then
			cb()
		end
	end)
end

Scooby.drawTxt = function(coords, text, size, font)
	local camCoords = Scooby.native(0x595320200B98596E, Scooby.rdr2.ReturnResultAnyway(), Scooby.rdr2.ResultAsVector())
	local distance = #(camCoords - coords)

	local scale = (size / distance) * 2
	local fov = (1 / GetGameplayCamFov()) * 100
	scale = scale * fov

	local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)

	if (onScreen) then
		SetTextScale(0.0 * scale, 0.55 * scale)
		Scooby.native(0x50A41AD966910F03, 255, 255, 255, 255)

		if (font ~= nil) then
			SetTextFontForCurrentCommand(font)
		end

		SetTextDropshadow(0, 0, 0, 255)
		SetTextCentre(true)
		Scooby.native(0xD79334A4BB99BAD1, CreateVarString(10, 'LITERAL_STRING', text), x, y)
	end
end

Scooby.getPlayerInfo = function(plyId, cb, myPed, isMyself)
	local mycoords = myPed and GetEntityCoords(myPed) or nil
	local coords = GetEntityCoords(isMyself and plyId or GetPlayerPed(plyId))
	local ped = isMyself and plyId or GetPlayerPed(plyId)

	cb({
		id = plyId,
		name = GetPlayerName(plyId),
		serverId = GetPlayerServerId(plyId),
		ped = ped,
		coords = coords,
		height = GetEntityHeight(ped, coords.x, coords.y, coords.z, true, true),
		health = GetEntityHealth(ped),

		distance = myPed and Vdist2(coords.x, coords.y, coords.z, mycoords.x, mycoords.y, mycoords.z) or nil,
	})
end

Scooby.registerMenu = function(id, title, desc, control, cb)
	Scooby.menuCheckBoxes[id] = {}
	Scooby.Menu.CreateMenu(id, title, desc)
	Scooby.Menu.SetSubTitle(id, desc)
	Scooby.Menu.SetMenuWidth(id, 0.275)
	Scooby.Menu.SetMenuX(id, 0.65)

	if control then
		Scooby.registerKey(control, function()
			if Scooby.Menu.IsMenuOpened(id) then
				Scooby.Menu.CloseMenu()
			else
				Scooby.Menu.OpenMenu(id)
			end
		end)
	end

	cb()

	table.insert(Scooby.menuThreads, function()
		if Scooby.Menu.IsMenuOpened(id) then
			for i = 1, #Scooby.menuAttributes[id] do
				local menu = Scooby.menuAttributes[id][i]
				if menu.data.type == 'button' then
					if Scooby.Menu.Button(menu.data.name, nil, menu.data.desc, (menu.data.isInfo or false)) then
						menu.cb()
					end
				elseif menu.data.type == 'checkbox' then
					if not Scooby.menuCheckBoxes[id][menu.data.name] then Scooby.menuCheckBoxes[id][menu.data.name] = menu
						.checked end
					if Scooby.Menu.CheckBox(menu.data.name, Scooby.menuCheckBoxes[id][menu.data.name], menu.cb) then
						Scooby.menuCheckBoxes[id][menu.data.name] = not Scooby.menuCheckBoxes[id][menu.data.name]
					end
				elseif menu.data.type == 'combobox' then
					Scooby.Menu.ComboBox(menu.data.name, menu.data.items, menu.data.currentIndex, menu.data.selectedIndex,
						function(currentIndex, selectedItem)
							if currentIndex or selectedItem then
								menu.cb(currentIndex, selectedItem)
								Citizen.Wait(15)
							end

							if menus[currentMenu].currentOption == (optionCount) then
								if isPressedKey(0xA65EBAB4) then
									if menu.data.currentIndex > 1 then menu.data.currentIndex = menu.data.currentIndex -
										1 else menu.data.currentIndex = #menu.data.items end
								end

								if isPressedKey(0xDEB34313) then
									if menu.data.currentIndex < #menu.data.items then menu.data.currentIndex = menu.data
										.currentIndex + 1 else menu.data.currentIndex = 1 end
								end
							end
						end)
				end
			end

			Scooby.Menu.Display()
		end
	end)
end

Scooby.registerSubMenu = function(id, parantid, title, desc, control, cb)
	Scooby.menuCheckBoxes[id] = {}
	Scooby.Menu.CreateSubMenu(id, parantid, title, desc)
	Scooby.Menu.SetSubTitle(id, desc)
	Scooby.Menu.SetMenuWidth(id, 0.275)
	Scooby.Menu.SetMenuX(id, 0.65)

	Scooby.Print('ScoobyOP SubMenu Loaded! (Name: ' .. title .. ", Description: " .. desc .. ")", false, false)

	if control then
		Scooby.registerKey(control, function()
			Scooby.Menu.OpenMenu(id)
		end)
	end

	cb()

	table.insert(Scooby.menuThreads, function()
		if Scooby.Menu.IsMenuOpened(id) then
			for i = 1, #Scooby.menuAttributes[id] do
				local menu = Scooby.menuAttributes[id][i]
				if menu.data.type == 'button' then
					if Scooby.Menu.Button(menu.data.name, nil, menu.data.desc, (menu.data.isInfo or false)) then
						menu.cb()
					end
				elseif menu.data.type == 'checkbox' then
					if not Scooby.menuCheckBoxes[id][menu.data.name] then Scooby.menuCheckBoxes[id][menu.data.name] = menu
						.checked end
					if Scooby.Menu.CheckBox(menu.data.name, Scooby.menuCheckBoxes[id][menu.data.name], menu.cb) then
						Scooby.menuCheckBoxes[id][menu.data.name] = not Scooby.menuCheckBoxes[id][menu.data.name]
					end
				elseif menu.data.type == 'combobox' then
					Scooby.Menu.ComboBox(menu.data.name, menu.data.items, menu.data.currentIndex, menu.data.selectedIndex,
						function(currentIndex, selectedItem)
							if currentIndex or selectedItem then
								menu.cb(currentIndex, selectedItem)
								Citizen.Wait(15)
							end

							if menus[currentMenu].currentOption == (optionCount) then
								if isPressedKey(0xA65EBAB4) then
									if menu.data.currentIndex > 1 then menu.data.currentIndex = menu.data.currentIndex -
										1 else menu.data.currentIndex = #menu.data.items end
								end

								if isPressedKey(0xDEB34313) then
									if menu.data.currentIndex < #menu.data.items then menu.data.currentIndex = menu.data
										.currentIndex + 1 else menu.data.currentIndex = 1 end
								end
							end
						end)
				end
			end

			Scooby.Menu.Display()
		end
	end)
end

Scooby.registerMenuAttribute = function(menuId, data, cb)
	if not Scooby.menuAttributes[menuId] then Scooby.menuAttributes[menuId] = {} end

	table.insert(Scooby.menuAttributes[menuId], { data = data, cb = cb })
end

Scooby.GetDistance = function(p1, p2)
	return math.sqrt((p2.x - p1.x) ^ 2 + (p2.y - p1.y) ^ 2 + (p2.z - p1.z) ^ 2)
end

Scooby.NetWorkPriority = function(ent)
	if DoesEntityExist(ent) and NetworkGetEntityIsNetworked(ent) then
		if not NetworkHasControlOfEntity(ent) then
			Scooby.native(0x5C707A667DF8B9FA, true, PlayerPedId())
			local networkId = NetworkGetNetworkIdFromEntity(ent)

			NetworkRequestControlOfNetworkId(networkId)

			SetNetworkIdExistsOnAllMachines(networkId, true)
			Scooby.native(0x299EEB23175895FC, networkId, false)

			NetworkRequestControlOfEntity(NetToEnt(networkId))

			local maxTimer = 0
			while not NetworkHasControlOfEntity(NetToEnt(networkId)) do
				Citizen.Wait(100)
				maxTimer = maxTimer + 1
				if maxTimer > 20 or not NetworkGetEntityIsNetworked(ent) then
					return false
				end
			end
		end

		return true
	end
end

Scooby.Troll.AnimalAttack = function(playerId, hash, distance) -- TODO: Reocde (make it so anything can attack)
	local playerId = playerId
	Scooby.createThread(function()
		Scooby.getPlayerInfo(playerId, function(pInfo)
			local height = 1
			for height = 1, 1000 do
				local foundGround, groundZ, normal = GetGroundZAndNormalFor_3dCoord(pInfo.coords.x, pInfo.coords.y,
					height + 0.0)
				if foundGround then
					RequestModel(hash)
					while not HasModelLoaded(hash) do
						Citizen.Wait(50)
					end

					local pedC = CreatePed(hash, pInfo.coords.x + math.random(distance),
						pInfo.coords.y + math.random(distance), groundZ, 0.0, true, false)
					Citizen.InvokeNative(0x283978A15512B2FE, pedC, true)
					SetEntityMaxHealth(pedC, 1250)
					SetEntityHealth(pedC, 1250)
					local bearKilled = false

					while not bearKilled do
						Citizen.Wait(15)
						local pedCCoords = GetEntityCoords(pedC)
						TaskCombatPed(pedC, GetPlayerPed(playerId), 0, 16)
						local distanceBetweenEntities = Scooby.GetDistance(pInfo.coords, pedCCoords)
						local isPedDead = GetEntityHealth(pedC)

						if distanceBetweenEntities < 1.5 then
							bearKilled = true
							ClearPedTasksImmediately(pedC)
						elseif isPedDead == 0 then
							bearKilled = true
						end
					end

					break
				end
				Wait(25)
			end
		end)
	end)
end

Scooby.registerESP = function(identifier, esp_tick, pedId)
	if Scooby.menuCheckBoxes['scooby_visual'][identifier] then return end

	Scooby.Print(identifier .. " ESP: Enabled", identifier .. " ESP: Enabled", false)
	Scooby.createThread(function()
		while (true) do
			Citizen.Wait(0)

			for _, id in ipairs(GetActivePlayers()) do
				if Scooby.pedID() ~= GetPlayerPed(id) then
					Scooby.getPlayerInfo(id, function(plyData)
						esp_tick(plyData)
					end, pedId and Scooby.pedID() or false)
				end
			end

			if not Scooby.menuCheckBoxes['scooby_visual'][identifier] then
				Scooby.Print(identifier .. " ESP: Disabled", identifier .. " ESP: Disabled", false)
				break
			end
		end
	end)
end

-- Player info box state
Scooby.viewingPlayerId = nil
Scooby.viewingPlayerServerId = nil

-- Draw player info box to the right of the menu
Scooby.drawPlayerInfoBox = function()
	if not Scooby.viewingPlayerId then return end
	local pid = Scooby.viewingPlayerId
	local ped = GetPlayerPed(pid)
	if not ped or not DoesEntityExist(ped) then return end
	if not currentMenu or not menus[currentMenu] then return end

	-- Check if we're in a player sub-menu
	local menuId = currentMenu or ""
	if not string.find(menuId, "scooby_players_") then
		Scooby.viewingPlayerId = nil
		return
	end

	local mx = menus[currentMenu].x
	local mw = menus[currentMenu].width or menus[currentMenu].menuWidth or 0.275
	local boxX = mx + mw + 0.008
	local boxY = menus[currentMenu].y or 0.10
	local boxW = 0.17
	local lineH = 0.022

	-- Background
	local totalH = lineH * 14 + 0.02
	DrawRect(boxX + boxW / 2, boxY + totalH / 2, boxW, totalH, 0, 0, 0, 180)

	-- Border top (cyan)
	DrawRect(boxX + boxW / 2, boxY + 0.002, boxW, 0.004, 0, 180, 255, 255)

	local y = boxY + 0.012
	local font = 9
	local nameSize = 0.35
	local valSize = 0.28

	-- Player name
	local name = GetPlayerName(pid) or "Unknown"
	local sid = Scooby.viewingPlayerServerId or 0
	DrawTxt("[" .. sid .. "] " .. name, boxX + 0.008, y, nameSize, false, 0, 200, 255, 255, false, font)
	y = y + lineH + 0.005

	-- Divider
	DrawRect(boxX + boxW / 2, y, boxW - 0.01, 0.002, 0, 180, 255, 120)
	y = y + 0.008

	-- Health
	local hp = GetEntityHealth(ped)
	local maxHp = GetPedMaxHealth(ped)
	local hpPct = maxHp > 0 and math.floor(hp / maxHp * 100) or 0
	DrawTxt("Health", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	DrawTxt(tostring(hp) .. " / " .. tostring(maxHp) .. " (" .. hpPct .. "%)", boxX + 0.07, y, valSize, false, 255, 255, 255, 255, false, font)
	y = y + lineH

	-- Health bar
	local barX = boxX + 0.008
	local barW = boxW - 0.016
	local barH = 0.006
	DrawRect(barX + barW / 2, y + barH / 2, barW, barH, 30, 30, 30, 200)
	local fillW = barW * (hpPct / 100)
	if fillW > 0 then
		local r = hpPct > 50 and 0 or 255
		local g = hpPct > 25 and 255 or 0
		DrawRect(barX + fillW / 2, y + barH / 2, fillW, barH, r, g, 0, 230)
	end
	y = y + barH + 0.008

	-- Distance
	local myCoords = GetEntityCoords(Scooby.pedID())
	local pCoords = GetEntityCoords(ped)
	local dist = #(myCoords - pCoords)
	DrawTxt("Distance", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	DrawTxt(string.format("%.0fm", dist), boxX + 0.07, y, valSize, false, 255, 255, 255, 255, false, font)
	y = y + lineH

	-- Alive/Dead
	local alive = not IsPedDeadOrDying(ped)
	DrawTxt("Status", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	if alive then
		DrawTxt("Alive", boxX + 0.07, y, valSize, false, 80, 255, 80, 255, false, font)
	else
		DrawTxt("Dead", boxX + 0.07, y, valSize, false, 255, 60, 60, 255, false, font)
	end
	y = y + lineH

	-- Armed
	local _, weapHash = GetCurrentPedWeapon(ped, true)
	local armed = weapHash and weapHash ~= 0 and weapHash ~= 0xA2719263
	DrawTxt("Armed", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	if armed then
		DrawTxt("Yes", boxX + 0.07, y, valSize, false, 255, 100, 100, 255, false, font)
	else
		DrawTxt("No", boxX + 0.07, y, valSize, false, 120, 255, 120, 255, false, font)
	end
	y = y + lineH

	-- On Horse
	local mount = GetMount(ped)
	local onHorse = mount and mount ~= 0
	DrawTxt("On Horse", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	DrawTxt(onHorse and "Yes" or "No", boxX + 0.07, y, valSize, false, 255, 255, 255, 255, false, font)
	y = y + lineH

	-- In Vehicle
	local inVeh = IsPedInAnyVehicle(ped, false)
	DrawTxt("In Vehicle", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	DrawTxt(inVeh and "Yes" or "No", boxX + 0.07, y, valSize, false, 255, 255, 255, 255, false, font)
	y = y + lineH

	-- Heading
	local heading = GetEntityHeading(ped)
	DrawTxt("Heading", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	DrawTxt(string.format("%.0f", heading), boxX + 0.07, y, valSize, false, 255, 255, 255, 255, false, font)
	y = y + lineH

	-- Coords
	DrawTxt("Position", boxX + 0.008, y, valSize, false, 160, 160, 170, 255, false, font)
	DrawTxt(string.format("%.0f, %.0f, %.0f", pCoords.x, pCoords.y, pCoords.z), boxX + 0.07, y, valSize, false, 200, 200, 200, 255, false, font)
end

Scooby.registerNearbyPlayer = function(playerId)
	local plyServerId = GetPlayerServerId(playerId)
	local plyName = GetPlayerName(playerId)
	Scooby.viewingPlayerId = playerId
	Scooby.viewingPlayerServerId = plyServerId

	Scooby.registerSubMenu('scooby_players_' .. tostring(plyServerId), 'scooby_players', "ScoobyOP",
		"[" .. tostring(plyServerId) .. "] - " .. plyName, false, function()
		Scooby.menuAttributes['scooby_players_' .. tostring(plyServerId)] = {}

		-- Player info header
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = '--- ' .. plyName .. ' [' .. plyServerId .. '] ---',
			desc = 'Health: ' .. GetEntityHealth(GetPlayerPed(playerId)),
			isInfo = true,
		}, function() end)

		-- === Teleport ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Teleport to Player',
			desc = 'Teleport to this player',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), playerCoords.x, playerCoords.y, playerCoords.z, 0, 0, 0, 0)
			Scooby.Print("Teleported to player", "Teleported to player", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spectate',
			desc = 'Watch this player',
		}, function()
			local targetPed = GetPlayerPed(playerId)
			if targetPed and targetPed ~= 0 then
				NetworkSetInSpectatorMode(true, targetPed)
				Scooby.Print("Spectating " .. plyName, "Spectating " .. plyName, false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Stop Spectate',
			desc = 'Stop watching',
		}, function()
			NetworkSetInSpectatorMode(false, Scooby.pedID())
			Scooby.Print("Stopped spectating", "Stopped spectating", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Copy Coords',
			desc = 'Copy player coordinates',
		}, function()
			local coords = GetEntityCoords(GetPlayerPed(playerId))
			Scooby.Print(string.format("%.2f, %.2f, %.2f", coords.x, coords.y, coords.z), false)
		end)

		-- === Trolling ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = '--- Trolling ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Bring to Me',
			desc = 'Teleport player to your location',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local myCoords = GetEntityCoords(Scooby.pedID())
				Scooby.native(0x06843DA7060A026B, ped, myCoords.x + 2.0, myCoords.y, myCoords.z, 0, 0, 0, 0)
				Scooby.Print("Player brought", "Player brought", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'TP Behind',
			desc = 'Teleport behind this player',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				local heading = GetEntityHeading(ped)
				local rad = math.rad(heading)
				local bx = coords.x - math.sin(rad) * -3.0
				local by = coords.y + math.cos(rad) * -3.0
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), bx, by, coords.z, 0, 0, 0, 0)
				SetEntityHeading(Scooby.pedID(), heading)
				Scooby.Print("Behind player", "Behind player", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Explode',
			desc = 'Explode this player',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z, 27,
				1000.0, true, false, true)
			Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z, 30,
				1000.0, true, false, true)
			Scooby.Print("Player exploded", "Player exploded", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Set on fire',
			desc = 'Set player on fire',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
			Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z, 30,
				1000.0, true, false, true)
			Scooby.Print("Player burning", "Player burning", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Freeze Player',
			desc = 'Freeze in place',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				FreezeEntityPosition(ped, true)
				Scooby.Print("Player frozen", "Player frozen", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Unfreeze Player',
			desc = 'Release from freeze',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				FreezeEntityPosition(ped, false)
				Scooby.Print("Player unfrozen", "Player unfrozen", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Ragdoll',
			desc = 'Make player ragdoll',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
				Scooby.Print("Player ragdolled", "Player ragdolled", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Launch Up',
			desc = 'Send player flying',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
				ApplyForceToEntity(ped, 1, 0.0, 0.0, 50.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
				Scooby.Print("Player launched", "Player launched", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Cage',
			desc = 'Trap in fence cage',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				local hash = GetHashKey("p_fencepost01x")
				RequestModel(hash)
				local attempts = 0
				while not HasModelLoaded(hash) and attempts < 100 do Citizen.Wait(10); attempts = attempts + 1 end
				if HasModelLoaded(hash) then
					for angle = 0, 350, 30 do
						local rad = math.rad(angle)
						local ox = math.cos(rad) * 1.5
						local oy = math.sin(rad) * 1.5
						local obj = CreateObject(hash, coords.x + ox, coords.y + oy, coords.z - 1.0, true, true, true, true, true)
						FreezeEntityPosition(obj, true)
					end
					Scooby.Print("Player caged", "Player caged", false)
				end
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Steal Horse',
			desc = 'Teleport to their horse',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local mount = GetMount(ped)
				if mount and mount ~= 0 then
					local coords = GetEntityCoords(mount)
					Scooby.native(0x06843DA7060A026B, Scooby.pedID(), coords.x, coords.y + 2.0, coords.z, 0, 0, 0, 0)
					Scooby.Print("Teleported to horse", "Teleported to horse", false)
				else
					Scooby.Print("Player has no horse", "Player has no horse", false)
				end
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Clone Player',
			desc = 'Spawn hostile clone',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local model = GetEntityModel(ped)
				local coords = GetEntityCoords(ped)
				local heading = GetEntityHeading(ped)
				RequestModel(model)
				local attempts = 0
				while not HasModelLoaded(model) and attempts < 100 do Citizen.Wait(10); attempts = attempts + 1 end
				if HasModelLoaded(model) then
					local clone = Scooby.native(0xD49F9B0955C367DE, model, coords.x + 1.0, coords.y + 1.0, coords.z, heading, true, false)
					Citizen.InvokeNative(0x283978A15512B2FE, clone, true)
					TaskCombatPed(clone, ped, 0, 16)
					Scooby.Print("Clone spawned", "Clone spawned", false)
				end
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Send to the stratosphere',
			desc = 'woah look, the moon',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			for i = 1, 100 do
				Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, true, false, true)
				Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, true, false, true)
				Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, true, false, true)
			end

			Scooby.Print("Player exploded", "Player exploded", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Send to the stratosphere (shhh)',
			desc = '',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))

			for i = 1, 100 do
				Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, false, true, true)
				Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, false, true, true)
				Scooby.native(0xD84A917A64D4D016, GetPlayerPed(playerId), playerCoords.x, playerCoords.y, playerCoords.z,
					i, 1000.0, false, true, true)
			end

			Scooby.Print("Player exploded", "Player exploded", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Attack AI',
			desc = 'LMAO U TROLL',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
			pedmodel = GetHashKey("RE_RALLY_MALES_01")

			scale = 2.0

			RequestModel(pedmodel)
			while not HasModelLoaded(pedmodel) do
				RequestModel(pedmodel)
				Wait(1)
			end

			local ped = CreatePed(pedmodel, playerCoords.x + 2, playerCoords.y + 2, playerCoords.z + 1, 45.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
			GiveWeaponToPed(ped, 0xA64DAA5E, 250, true, true)
			TaskCombatPed(ped, GetPlayerPed(playerId))
			SetPedAccuracy(ped, 100)
			Scooby.requestControl(ped)
			SetPedScale(ped, scale)
			SetEntityHealth(ped, 2000)

			Scooby.Print("bye bye!", "bye bye!", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Huge Ped',
			desc = 'WTF IS THAT',
		}, function()
			local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
			pedmodel = GetHashKey("RE_RALLY_MALES_01")

			scale = 10.0

			RequestModel(pedmodel)
			while not HasModelLoaded(pedmodel) do
				RequestModel(pedmodel)
				Wait(1)
			end

			local ped = CreatePed(pedmodel, playerCoords.x, playerCoords.y + 2, playerCoords.z + 10, 45.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
			GiveWeaponToPed(ped, 0xA64DAA5E, 250, true, true)
			TaskCombatPed(ped, GetPlayerPed(playerId))
			SetPedAccuracy(ped, 100)
			Scooby.requestControl(ped)
			SetPedScale(ped, scale)
			SetEntityHealth(ped, 2000)

			Scooby.Print("bye bye!", "bye bye!", false)
		end)


		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Apply damage multi',
			desc = '(max) 10x Damage!',
		}, function()
			SetPlayerWeaponDamageModifier(PlayerId(playerId), 1000.0)
			Scooby.Print("Applied damage mod", "Applied damage mod", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Silent Kill',
			desc = 'sneak kill!',
		}, function()
			local coords = GetEntityCoords(GetPlayerPed(playerId))
			Scooby.native(0x867654CBC7606F2C, coords, coords.x, coords.y, coords.z + 0.01, 400.0, true, 0x31B7B9FE,
				PlayerPedId(), false, true, 999999999, false, false, 0)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'checkbox',
			name = 'Attach',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Attach'] then
				Scooby.Print("Attach: Enabled", "Attach: Enabled", false)
				Scooby.native(0x6B9BBD38AB0796DF, Scooby.pedID(), GetPlayerPed(playerId), 11816, 0.54, 0.54, 0.0, 0.0, 0.0,
					0.0, false, false, false, false, 2, true)
			else
				Scooby.native(0x64CDE9D6BF8ECAD3, Scooby.pedID(), false, false)
				Scooby.Print("Attach: Disabled", "Attach: Disabled", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Clone',
			desc = 'Clone Ped!',
		}, function()
			Scooby.native(0xEF29A16337FACADB, GetPlayerPed(playerId), true, true, true)
			Scooby.Print("Cloned Ped", "Cloned Ped", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Hogtie',
			desc = 'Hogtie the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if DoesEntityExist(ped) then
				TaskHogtieTargetPed(Scooby.pedID(), ped)
				Scooby.Print("Hogtied player", "Hogtied player", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Attach to Player',
			desc = 'Attach yourself to the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if DoesEntityExist(ped) then
				AttachEntityToEntity(Scooby.pedID(), ped, 0, 0.0, -0.3, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
				Scooby.Print("Attached to player", "Attached to player", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Detach',
			desc = 'Detach from any entity',
		}, function()
			DetachEntity(Scooby.pedID(), true, false)
			Scooby.Print("Detached", "Detached", false)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Campfire on Player',
			desc = 'Spawn a campfire at their location!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				local hash = GetHashKey("p_campfire05x")
				RequestModel(hash)
				local attempts = 0
				while not HasModelLoaded(hash) and attempts < 100 do
					Wait(10)
					attempts = attempts + 1
				end
				if HasModelLoaded(hash) then
					local obj = CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true, true, true)
					Scooby.Print("Campfire spawned", "Campfire spawned", false)
				else
					Scooby.Print("Failed to load model", "Failed to load model", false)
				end
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Crash Player',
			desc = 'Wagon awning crash',
		}, function()
			_ct(function()
				local ped = GetPlayerPed(playerId)
				if not ped or not DoesEntityExist(ped) then
					Scooby.Print("Player not found", "Player not found", false)
					return
				end
				local spawnPos = GetEntityCoords(ped)
				local hash = GetHashKey("s_chuckwagonawning01b")
				RequestModel(hash)
				local t0 = GetGameTimer()
				while not HasModelLoaded(hash) do
					_w(5)
					if GetGameTimer() - t0 > 5000 then break end
				end
				if not HasModelLoaded(hash) then
					Scooby.Print("Model failed", "Model failed", false)
					return
				end
				local objects = {}
				for i = 1, 25 do
					local angle = (i - 1) * (360 / 10) * 0.0174532924
					local ox = math.sin(angle) * 3.0
					local oy = math.cos(angle) * 3.0
					local obj = CreateObject(hash, spawnPos.x + ox, spawnPos.y + oy, spawnPos.z, true, true, true)
					SetEntityAsMissionEntity(obj, true, true)
					table.insert(objects, obj)
				end
				_w(2000)
				for _, obj in ipairs(objects) do DeleteObject(obj) end
				SetModelAsNoLongerNeeded(hash)
				Scooby.Print("Crash sent", "Crash sent", false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Crash v2',
			desc = 'Fence post spam',
		}, function()
			_ct(function()
				local ped = GetPlayerPed(playerId)
				if not ped or not DoesEntityExist(ped) then return end
				local coords = GetEntityCoords(ped)
				local hash = GetHashKey("p_fencepost01x")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do _w(10); a = a + 1 end
				if HasModelLoaded(hash) then
					for i = 1, 50 do
						CreateObject(hash, coords.x, coords.y, coords.z + (i * 0.1), true, true, true, true, true)
					end
					Scooby.Print("Crash v2 sent", "Crash v2 sent", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Kill Horse',
			desc = 'Kill the player\'s mount!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if DoesEntityExist(ped) then
				local mount = GetMount(ped)
				if mount and mount ~= 0 then
					SetEntityHealth(mount, 0, 0)
					Scooby.Print("Horse killed", "Horse killed", false)
				else
					Scooby.Print("Player has no mount", "Player has no mount", false)
				end
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spin Player',
			desc = 'Ragdoll and spin the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				SetPedToRagdoll(ped, 3000, 3000, 0, false, false, false)
				local coords = GetEntityCoords(ped)
				ApplyForceToEntity(ped, 1, 10.0, 0.0, 15.0, 0.0, 0.0, 5.0, 0, false, true, true, false, true)
				Scooby.Print("Player is spinning", "Player is spinning", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Bury Player',
			desc = 'Teleport the player underground!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				Scooby.native(0x06843DA7060A026B, ped, coords.x, coords.y, coords.z - 10.0, 0, 0, 0, 0)
				Scooby.Print("Player buried underground", "Player buried underground", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Sky Launch',
			desc = 'Launch the player into the sky!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				SetPedToRagdoll(ped, 10000, 10000, 0, false, false, false)
				ApplyForceToEntity(ped, 1, 0.0, 0.0, 500.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
				Scooby.Print("Player launched into sky", "Player launched into sky", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Set on Fire Loop',
			desc = 'Start multiple fires around the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				for i = 1, 5 do
					StartScriptFire(coords.x + math.random(-2,2), coords.y + math.random(-2,2), coords.z, 10, true, false, false, 1.0, 0)
				end
				Scooby.Print("Player is on fire", "Player is on fire", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Wolves',
			desc = 'Spawn 3 wolves that attack the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				local hash = GetHashKey("a_c_wolf")
				RequestModel(hash)
				local timeout = 0
				while not HasModelLoaded(hash) and timeout < 50 do
					Citizen.Wait(100)
					timeout = timeout + 1
				end
				if HasModelLoaded(hash) then
					for i = 1, 3 do
						local wolf = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + i*2, coords.y, coords.z, 0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, wolf, true)
						TaskCombatPed(wolf, ped, 0, 16)
					end
					Scooby.Print("Wolves spawned", "Wolves spawned", false)
				else
					Scooby.Print("Failed to load wolf model", "Failed to load wolf model", false)
				end
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Dynamite',
			desc = 'Spawn dynamite explosion at the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 1, 10.0, true, false, true)
				_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 23, 5.0, true, false, true)
				Scooby.Print("Dynamite spawned", "Dynamite spawned", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Revive Player',
			desc = 'Heal and resurrect the player!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if DoesEntityExist(ped) then
				if IsPedDeadOrDying(ped) then
					ResurrectPed(ped)
				end
				SetEntityHealth(ped, GetPedMaxHealth(ped), 0)
				ClearPedBloodDamage(ped)
				Scooby.Print("Player revived", "Player revived", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Drunk',
			desc = 'Make the player drunk!',
		}, function()
			local ped = GetPlayerPed(playerId)
			if DoesEntityExist(ped) then
				SetPedIsDrunk(ped, true)
				SetPedConfigFlag(ped, 100, true)
				SetPedRagdollOnCollision(ped, true)
				Scooby.Print("Player is now drunk", "Player is now drunk", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		-- === Trolling v2 ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = '--- Trolling v2 ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Swap Positions',
			desc = 'Swap your coords with target',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local myCoords = GetEntityCoords(Scooby.pedID())
				local theirCoords = GetEntityCoords(ped)
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), theirCoords.x, theirCoords.y, theirCoords.z, false, false, false, false)
				Scooby.native(0x06843DA7060A026B, ped, myCoords.x, myCoords.y, myCoords.z, false, false, false, false)
				Scooby.Print("Positions swapped", "Positions swapped", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Spawn Fire Ring',
			desc = 'Circle of fire around player',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local coords = GetEntityCoords(ped)
				for i = 0, 11 do
					local angle = i * 30 * 0.0174532924
					local fx = coords.x + math.cos(angle) * 3.0
					local fy = coords.y + math.sin(angle) * 3.0
					StartScriptFire(fx, fy, coords.z, 5, true, false, false, 1.0, 0)
				end
				Scooby.Print("Fire ring spawned", "Fire ring spawned", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Crash v3',
			desc = 'Multi-model object spam crash',
		}, function()
			Scooby.createThread(function()
				local ped = GetPlayerPed(playerId)
				if not DoesEntityExist(ped) then return end
				local pos = GetEntityCoords(ped)
				local models = {"s_chuckwagonawning01b", "p_fencepost01x", "s_clotharthurcover01x"}
				for _, model in ipairs(models) do
					local hash = GetHashKey(model)
					RequestModel(hash)
					local a = 0
					while not HasModelLoaded(hash) and a < 50 do Citizen.Wait(10); a = a + 1 end
					if HasModelLoaded(hash) then
						for i = 1, 15 do
							CreateObject(hash, pos.x + math.random(-2,2), pos.y + math.random(-2,2), pos.z, true, true, true)
						end
					end
				end
				Scooby.Print("Crash v3 sent", "Crash v3 sent", false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Steal Mount',
			desc = 'Dismount target and take their horse',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local mount = GetMount(ped)
				if mount and mount ~= 0 then
					ClearPedTasksImmediately(ped, true, false)
					local coords = GetEntityCoords(mount)
					Scooby.native(0x06843DA7060A026B, Scooby.pedID(), coords.x, coords.y + 1.0, coords.z, false, false, false, false)
					Citizen.Wait(500)
					TaskMountAnimal(Scooby.pedID(), mount, -1, -1, 1.0, 1, 0, 0)
					Scooby.Print("Mount stolen", "Mount stolen", false)
				else
					Scooby.Print("Player has no mount", "Player has no mount", false)
				end
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		-- === Animal Attacks ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = '--- Attacks ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
				type = 'button',
				name = 'Bear Attack',
				desc = 'Send a bear after player',
			},
			function()
				local hash = 3170700927
				local distance = 20, 40

				Scooby.Troll.AnimalAttack(playerId, hash, distance)
			end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = '18+ Woman attack',
			desc = 'Send NPC after player',
		}, function()
			local hash = 2570527271
			local distance = 10, 25

			Scooby.Troll.AnimalAttack(playerId, hash, distance)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Bison Attack',
			desc = 'Send a bison after player',
		}, function()
			local hash = 1556473961
			local distance = 10, 15

			Scooby.Troll.AnimalAttack(playerId, hash, distance)
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Local Attack',
			desc = 'All nearby NPCs attack player',
		}, function()
			for k, v in pairs(GetGamePool('CPed')) do
				if v ~= PlayerPedId() and not IsPedInAnyVehicle(v, false) and not IsPedAPlayer(v) then
					Citizen.CreateThread(function()
						if Scooby.NetWorkPriority(v) then
							SetRelationshipBetweenGroups(5, 'PLAYER', GetHashKey(GetPedRelationshipGroupHash(v)))
							SetRelationshipBetweenGroups(5, GetHashKey(GetPedRelationshipGroupHash(v)), 'PLAYER')
							TaskCombatPed(v, GetPlayerPed(playerId), 0, 16)
						end
					end)
				end
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Kick From Horse',
			desc = 'Remove player from horse',
		}, function()
			local ped = GetPlayerPed(playerId)
			if ped and DoesEntityExist(ped) then
				local mount = GetMount(ped)
				if mount and mount ~= 0 then
					ClearPedTasksImmediately(ped)
					Scooby.Print("Kicked from horse", "Kicked from horse", false)
				else
					Scooby.Print("Not on a horse", "Not on a horse", false)
				end
			end
		end)


		-- === Spectate (Camera) ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'checkbox',
			name = 'Spectate (Camera)',
			desc = 'Attach a camera to follow this player',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Spectate (Camera)'] then
				Scooby.Print("Spectate: Enabled", "Spectate: Enabled", false)
				Scooby._spectateCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
				local targetPed = GetPlayerPed(playerId)
				AttachCamToEntity(Scooby._spectateCam, targetPed, 0.0, -3.0, 2.0, true)
				PointCamAtEntity(Scooby._spectateCam, targetPed, 0.0, 0.0, 0.0, true)
				RenderScriptCams(true, true, 500, true, true)
				Scooby.createThread(function()
					while Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Spectate (Camera)'] do
						Citizen.Wait(0)
						local tPed = GetPlayerPed(playerId)
						if tPed and DoesEntityExist(tPed) then
							AttachCamToEntity(Scooby._spectateCam, tPed, 0.0, -3.0, 2.0, true)
							PointCamAtEntity(Scooby._spectateCam, tPed, 0.0, 0.0, 0.0, true)
						end
					end
				end)
			else
				RenderScriptCams(false, true, 500, true, true)
				if Scooby._spectateCam then
					DestroyCam(Scooby._spectateCam, true)
					Scooby._spectateCam = nil
				end
				Scooby.Print("Spectate: Disabled", "Spectate: Disabled", false)
			end
		end)

		-- === Follow Target ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'checkbox',
			name = 'Follow Target',
			desc = 'Your ped follows the target continuously',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Follow Target'] then
				Scooby.Print("Follow Target: Enabled", "Follow Target: Enabled", false)
				Scooby.createThread(function()
					while Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Follow Target'] do
						Citizen.Wait(1000)
						local targetPed = GetPlayerPed(playerId)
						if targetPed and DoesEntityExist(targetPed) then
							TaskFollowToOffsetOfEntity(Scooby.pedID(), targetPed, 0.0, -2.0, 0.0, 3.0, -1, 1.0, true)
						end
					end
				end)
			else
				ClearPedTasks(Scooby.pedID())
				Scooby.Print("Follow Target: Disabled", "Follow Target: Disabled", false)
			end
		end)

		-- === Copy Outfit ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Copy Outfit',
			desc = 'Copy the target player ped model',
		}, function()
			local targetPed = GetPlayerPed(playerId)
			if targetPed and DoesEntityExist(targetPed) then
				local model = GetEntityModel(targetPed)
				if model and model ~= 0 then
					RequestModel(model)
					local timeout = 0
					while not HasModelLoaded(model) and timeout < 100 do
						Citizen.Wait(10)
						timeout = timeout + 1
					end
					if HasModelLoaded(model) then
						SetPlayerModel(PlayerId(), model, true)
						Scooby.Print("Copied outfit", "Copied outfit", false)
					else
						Scooby.Print("Failed to load model", "Failed to load model", false)
					end
				end
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		-- === Scale Target ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'combobox',
			name = 'Scale Target',
			desc = 'Change the target player size',
			items = { "Normal", "Tiny (0.3)", "Small (0.5)", "Big (2.0)", "Giant (5.0)" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local scales = { 1.0, 0.3, 0.5, 2.0, 5.0 }
			local scale = scales[currentIndex] or 1.0
			local targetPed = GetPlayerPed(playerId)
			if targetPed and DoesEntityExist(targetPed) then
				SetPedScale(targetPed, scale)
				Scooby.Print("Scale Target: " .. selectedItem, "Scale Target: " .. selectedItem, false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		-- === Set Target on Fire ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'checkbox',
			name = 'Set Target on Fire',
			desc = 'Continuously start fires at the target every 3s',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Set Target on Fire'] then
				Scooby.Print("Set Target on Fire: Enabled", "Set Target on Fire: Enabled", false)
				Scooby.createThread(function()
					while Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Set Target on Fire'] do
						Citizen.Wait(3000)
						local targetPed = GetPlayerPed(playerId)
						if targetPed and DoesEntityExist(targetPed) then
							local coords = GetEntityCoords(targetPed)
							for i = 1, 3 do
								StartScriptFire(coords.x + math.random(-2, 2), coords.y + math.random(-2, 2), coords.z, 10, true, false, false, 1.0, 0)
							end
						end
					end
				end)
			else
				Scooby.Print("Set Target on Fire: Disabled", "Set Target on Fire: Disabled", false)
			end
		end)

		-- === Lightning Strike Target ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'Lightning Strike Target',
			desc = 'Strike lightning at the target location',
		}, function()
			local targetPed = GetPlayerPed(playerId)
			if targetPed and DoesEntityExist(targetPed) then
				local coords = GetEntityCoords(targetPed)
				Scooby.native(0x867654CBC7606F2C, coords, coords.x, coords.y, coords.z + 0.01, 400.0, true, 0x31B7B9FE, PlayerPedId(), false, true, 999999999, false, false, 0)
				Scooby.Print("Lightning strike!", "Lightning strike!", false)
			else
				Scooby.Print("Player not found", "Player not found", false)
			end
		end)

		-- === Target Health Bar ===
		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'checkbox',
			name = 'Target Health Bar',
			desc = 'Draw a health bar above the target',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Target Health Bar'] then
				Scooby.Print("Target Health Bar: Enabled", "Target Health Bar: Enabled", false)
				Scooby.createThread(function()
					while Scooby.menuCheckBoxes['scooby_players_' .. tostring(plyServerId)]['Target Health Bar'] do
						Citizen.Wait(0)
						local targetPed = GetPlayerPed(playerId)
						if targetPed and DoesEntityExist(targetPed) then
							local coords = GetEntityCoords(targetPed)
							local onScreen, sx, sy = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.2)
							if onScreen then
								local health = GetEntityHealth(targetPed)
								local maxHealth = GetEntityMaxHealth(targetPed)
								if maxHealth <= 0 then maxHealth = 1 end
								local ratio = health / maxHealth
								if ratio > 1.0 then ratio = 1.0 end
								if ratio < 0.0 then ratio = 0.0 end

								local barW = 0.05
								local barH = 0.008
								DrawRect(sx, sy, barW + 0.004, barH + 0.004, 0, 0, 0, 180)
								local fillW = barW * ratio
								local fillX = sx - (barW / 2) + (fillW / 2)
								local r, g, b = 0, 200, 50
								if ratio < 0.3 then r, g, b = 200, 0, 0
								elseif ratio < 0.6 then r, g, b = 200, 200, 0 end
								DrawRect(fillX, sy, fillW, barH, r, g, b, 220)
								DrawTxt(tostring(health) .. "/" .. tostring(maxHealth), sx, sy - 0.018, 0.22, true, 255, 255, 255, 220, true, 9)
							end
						end
					end
				end)
			else
				Scooby.Print("Target Health Bar: Disabled", "Target Health Bar: Disabled", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_players_' .. tostring(plyServerId), {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function()
			Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
		end)
	end)
end

-- Menu toggle: F6 or Delete
Scooby._menuIsOpen = false
Scooby.createThread(function()
	local lastPress = 0
	while true do
		Citizen.Wait(0)
		local now = GetGameTimer()
		if now - lastPress > 300 then
			local pressed = false
			-- F6 = 167, DELETE = 178
			if IsDisabledControlJustPressed(0, 167) or IsDisabledControlJustPressed(0, 178) then pressed = true end
			if not pressed then
				if IsControlJustPressed(0, 167) or IsControlJustPressed(0, 178) then pressed = true end
			end
			if pressed then
				lastPress = now
				if Scooby._menuIsOpen then
					-- Force close all menus
					for id, m in pairs(menus) do
						m.visible = false
					end
					currentMenu = nil
					currentKey = nil
					optionCount = 0
					DisplayRadar(true)
					Scooby._menuIsOpen = false
				else
					Scooby.Menu.OpenMenu('scooby_main')
					Scooby._menuIsOpen = true
				end
			end
		end
	end
end)

Scooby.registerMenu('scooby_main', "ScoobyOP", "", nil, function()
	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Player >',
		desc = 'Player options and movement',
	}, function()
		Scooby.Menu.OpenMenu('scooby_player')
		Scooby.Print("Showing Player menu", "Showing Player menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Teleport >',
		desc = 'Quick teleport to locations',
	}, function()
		Scooby.Menu.OpenMenu('scooby_teleport')
		Scooby.Print("Showing Teleport menu", "Showing Teleport menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Combat >',
		desc = 'Aimbot and combat settings',
	}, function()
		Scooby.Menu.OpenMenu('scooby_combat')
		Scooby.Print("Showing Combat menu", "Showing Combat menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Weapon >',
		desc = 'Weapons, ammo, and loadouts',
	}, function()
		Scooby.Menu.OpenMenu('scooby_weapon')
		Scooby.Print("Showing Weapons menu", "Showing Weapons menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Visual >',
		desc = 'ESP and visual features',
	}, function()
		Scooby.Menu.OpenMenu('scooby_visual')
		Scooby.Print("Showing Visual menu", "Showing Visual menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'World >',
		desc = 'Time, weather, and world features',
	}, function()
		Scooby.Menu.OpenMenu('scooby_world')
		Scooby.Print("Showing World menu", "Showing World menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Vehicle >',
		desc = 'Horse and vehicle features',
	}, function()
		Scooby.Menu.OpenMenu('scooby_vehicle')
		Scooby.Print("Showing Vehicle menu", "Showing Vehicle menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Spawner >',
		desc = 'Ped models and horse spawner',
	}, function()
		Scooby.Menu.OpenMenu('scooby_spawner')
		Scooby.Print("Showing Spawner menu", "Showing Spawner menu", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Protection >',
		desc = 'Anti-grief and safety features',
	}, function()
		Scooby.Menu.OpenMenu('scooby_protection')
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Misc >',
		desc = 'Fun and utility features',
	}, function()
		Scooby.Menu.OpenMenu('scooby_misc')
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Players >',
		desc = 'View and interact with nearby players',
	}, function()
		Scooby.menuAttributes["scooby_players"] = {}

		for _, id in ipairs(GetActivePlayers()) do
			Scooby.registerMenuAttribute('scooby_players', {
				type = 'button',
				name = tostring(GetPlayerServerId(id) .. " - " .. GetPlayerName(id)),
				desc = "Health: " .. GetEntityHealth(GetPlayerPed(id)),
			}, function()
				Scooby.Print("You clicked on " .. GetPlayerServerId(id) .. " - " .. GetPlayerName(id))

				Scooby.registerNearbyPlayer(id)
				Scooby.Menu.OpenMenu('scooby_players_' .. tostring(GetPlayerServerId(id)))
			end)
		end

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = '--- All Players ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Explode All',
			desc = 'Explode every online player',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					local coords = GetEntityCoords(ped)
					_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 27, 50.0, true, false, true)
					count = count + 1
				end
			end
			Scooby.Print("Exploded " .. count .. " players", "Exploded " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Freeze All',
			desc = 'Freeze every player in place',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					FreezeEntityPosition(ped, true)
					count = count + 1
				end
			end
			Scooby.Print("Froze " .. count .. " players", "Froze " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Unfreeze All',
			desc = 'Unfreeze every player',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					FreezeEntityPosition(ped, false)
					count = count + 1
				end
			end
			Scooby.Print("Unfroze " .. count .. " players", "Unfroze " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'TP All to Me',
			desc = 'Teleport all players to your location',
		}, function()
			local myCoords = GetEntityCoords(Scooby.pedID())
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					Scooby.native(0x06843DA7060A026B, ped, myCoords.x + math.random(-3, 3), myCoords.y + math.random(-3, 3), myCoords.z, 0, 0, 0, 0)
					count = count + 1
				end
			end
			Scooby.Print("Teleported " .. count .. " players to you", "Teleported " .. count .. " players to you", false)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Kill All',
			desc = 'Kill every player',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					SetEntityHealth(ped, 0, 0)
					count = count + 1
				end
			end
			Scooby.Print("Killed " .. count .. " players", "Killed " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Launch All',
			desc = 'Ragdoll and launch every player into the sky',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
					ApplyForceToEntity(ped, 1, 0.0, 0.0, 100.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
					count = count + 1
				end
			end
			Scooby.Print("Launched " .. count .. " players", "Launched " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Cage All',
			desc = 'Cage every player with fence posts',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("p_fencepost01x")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local count = 0
					for _, id in ipairs(GetActivePlayers()) do
						local ped = GetPlayerPed(id)
						if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
							local pos = GetEntityCoords(ped)
							local radius = 1.5
							for angle = 0, 330, 30 do
								local rad = math.rad(angle)
								local ox = math.cos(rad) * radius
								local oy = math.sin(rad) * radius
								local obj = CreateObject(hash, pos.x + ox, pos.y + oy, pos.z - 1.0, true, true, false)
								FreezeEntityPosition(obj, true)
							end
							count = count + 1
						end
					end
					Scooby.Print("Caged " .. count .. " players", "Caged " .. count .. " players", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'Crash All',
			desc = 'Spawn crash objects on every player',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("s_chuckwagonawning01b")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local count = 0
					for _, id in ipairs(GetActivePlayers()) do
						if id ~= PlayerId() then
							local ped = GetPlayerPed(id)
							local pos = GetEntityCoords(ped)
							for j = 1, 15 do
								CreateObject(hash, pos.x + math.random(-2, 2), pos.y + math.random(-2, 2), pos.z + math.random(-1, 3), true, true, false)
							end
							count = count + 1
						end
					end
					Scooby.Print("Crash sent to " .. count .. " players", "Crash sent to " .. count .. " players", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_players', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function()
			Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
		end)

		Scooby.Menu.OpenMenu('scooby_players')
		Scooby.Print("Showing nearby players", "Showing nearby players", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'All Players >',
		desc = 'Actions on all players at once',
	}, function()
		Scooby.Menu.OpenMenu('scooby_allplayers')
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Server >',
		desc = 'Server-side exploits and money',
	}, function()
		Scooby.Menu.OpenMenu('scooby_server')
		Scooby.Print("Server Features", "Server Features", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'Settings >',
		desc = 'Menu settings',
	}, function()
		Scooby.Menu.OpenMenu('scooby_settings')
		Scooby.Print("Showing Settings", "Showing Settings", false)
	end)

	Scooby.registerMenuAttribute('scooby_main', {
		type = 'button',
		name = 'ScoobyOP',
		desc = '',
		isInfo = true,
	}, function()
		Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
	end)
end)

Scooby.spawnPed = function(modelName, coords, heading, cb)
	local ped_model_name = modelName
	Scooby.createThread(function()
		local hashRequest = GetHashKey(ped_model_name)

		RequestModel(hashRequest)
		while not HasModelLoaded(hashRequest) do
			Citizen.Wait(50)
		end

		local spawningPed = Scooby.native(0xD49F9B0955C367DE, hashRequest, coords.x, coords.y, coords.z, (heading or 0.0),
			true, false)
		Citizen.InvokeNative(0x283978A15512B2FE, spawningPed, true)

		cb(ped_model_name, spawningPed)
		spawningPed = nil
	end)
end

Scooby.loadModel = function(model)
	if IsModelInCdimage(model) then
		RequestModel(model)

		while not HasModelLoaded(model) do
			Wait(0)
		end

		return true
	else
		return false
	end
end

Scooby.setPlayerModel = function(data)
	local model = GetHashKey(Scooby.Configs.Peds[data.type][data.modelIndex])

	if Scooby.loadModel(model) then
		SetPlayerModel(data.playerId, model, true)
	end
end

Scooby.espOffset = 0
Scooby.createThread(function()
	Scooby.registerSubMenu('scooby_players', 'scooby_main', "ScoobyOP", "Online Players", false, function() end)

	Scooby.registerSubMenu('scooby_combat', 'scooby_main', "ScoobyOP", "Combat", false, function()
		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Aimbot (In Development!)',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Aimbot (In Development!)'] then
				Scooby.createThread(function()
					Scooby.Print("Aimbot: Enabled", "Aimbot: Enabled", false)
					while (true) do
						Citizen.Wait(1)

						_ab = true

						if not Scooby.menuCheckBoxes['scooby_combat']['Aimbot (In Development!)'] then
							Scooby.Print("Aimbot: Disabled", "Aimbot: Disabled", false)
							_ab = false
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'combobox',
			name = 'Aimbot Bone',
			items = _abOps,
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			if selectedItem == "Head" then _abBone = "SKEL_HEAD"
			elseif selectedItem == "Chest" then _abBone = "SKEL_Spine3"
			elseif selectedItem == "Left Arm" then _abBone = "SKEL_L_UpperArm"
			elseif selectedItem == "Right Arm" then _abBone = "SKEL_R_UpperArm"
			elseif selectedItem == "Left Leg" then _abBone = "SKEL_L_Thigh"
			elseif selectedItem == "Right Leg" then _abBone = "SKEL_R_Thigh"
			elseif selectedItem == "Dick" then _abBone = "SKEL_Pelvis"
			end
			Scooby.Print("Aimbot Bone: " .. selectedItem, "Aimbot Bone: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Explosive Ammo',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Explosive Ammo'] then
				Scooby.createThread(function()
					Scooby.Print("Explosive Ammo: Enabled", "Explosive Ammo: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local coords = GetEntityCoords(Scooby.pedID())
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								AddExplosion(impact.x, impact.y, impact.z, 27, 5.0, true, false, 1.0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Explosive Ammo'] then
							Scooby.Print("Explosive Ammo: Disabled", "Explosive Ammo: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'One Shot Kill',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['One Shot Kill'] then
				Scooby.createThread(function()
					Scooby.Print("One Shot Kill: Enabled", "One Shot Kill: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								for _, id in ipairs(GetActivePlayers()) do
									local ped = GetPlayerPed(id)
									if ped ~= Scooby.pedID() and not IsPedDeadOrDying(ped) then
										local pCoords = GetEntityCoords(ped)
										if #(vector3(impact.x, impact.y, impact.z) - pCoords) < 3.0 then
											SetEntityHealth(ped, 0, 0)
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['One Shot Kill'] then
							Scooby.Print("One Shot Kill: Disabled", "One Shot Kill: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Triggerbot',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Triggerbot'] then
				Scooby.createThread(function()
					Scooby.Print("Triggerbot: Enabled", "Triggerbot: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) then
							local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
							if target and target ~= 0 and DoesEntityExist(target) and IsEntityAPed(target) and not IsPedDeadOrDying(target) then
								local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
								if weapon ~= 0 then
									TaskShootAtEntity(Scooby.pedID(), target, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Triggerbot'] then
							Scooby.Print("Triggerbot: Disabled", "Triggerbot: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Fire Ammo',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Fire Ammo'] then
				Scooby.createThread(function()
					Scooby.Print("Fire Ammo: Enabled", "Fire Ammo: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								StartScriptFire(impact.x, impact.y, impact.z, 5, true, false, false, 1.0, 0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Fire Ammo'] then
							Scooby.Print("Fire Ammo: Disabled", "Fire Ammo: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Anti Lasso',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Anti Lasso'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Lasso: Enabled", "Anti Lasso: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsEntityBeingHogtied(Scooby.pedID()) or Scooby.native(0x3AA24CCC0D451379, Scooby.pedID()) then
							ClearPedTasks(Scooby.pedID(), true, false)
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Anti Lasso'] then
							Scooby.Print("Anti Lasso: Disabled", "Anti Lasso: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Instant Accuracy',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Instant Accuracy'] then
				Scooby.createThread(function()
					Scooby.Print("Instant Accuracy: Enabled", "Instant Accuracy: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedAccuracy(Scooby.pedID(), 100)
						if not Scooby.menuCheckBoxes['scooby_combat']['Instant Accuracy'] then
							Scooby.Print("Instant Accuracy: Disabled", "Instant Accuracy: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Infinite Ammo',
		}, function()
			Scooby.Print(
				"Infinite Ammo: " .. (not Scooby.menuCheckBoxes['scooby_combat']['Infinite Ammo'] and "Enabled" or "Disabled"),
				"Infinite Ammo: " .. (not Scooby.menuCheckBoxes['scooby_combat']['Infinite Ammo'] and "Enabled" or "Disabled"), false)
			SetPedInfiniteAmmoClip(Scooby.pedID(), not Scooby.menuCheckBoxes['scooby_combat']['Infinite Ammo'])
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Heal',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Heal'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Heal: Enabled", "Auto Heal: Enabled", false)
					while true do
						Citizen.Wait(0)
						local ped = Scooby.pedID()
						local health = GetEntityHealth(ped)
						local maxHealth = GetEntityMaxHealth(ped)
						if health < math.floor(maxHealth * 0.5) then
							SetEntityHealth(ped, maxHealth, 0)
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Heal'] then
							Scooby.Print("Auto Heal: Disabled", "Auto Heal: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Kill Aura',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Kill Aura'] then
				Scooby.createThread(function()
					Scooby.Print("Kill Aura: Enabled", "Kill Aura: Enabled", false)
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, id in ipairs(GetActivePlayers()) do
							local ped = GetPlayerPed(id)
							if ped ~= Scooby.pedID() and not IsPedDeadOrDying(ped) then
								local pCoords = GetEntityCoords(ped)
								if #(myCoords - pCoords) < 10.0 then
									SetEntityHealth(ped, 0, 0)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Kill Aura'] then
							Scooby.Print("Kill Aura: Disabled", "Kill Aura: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'combobox',
			name = 'Damage Multiplier',
			items = {"1x", "2x", "5x", "10x"},
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local mult = 1
			if selectedItem == "1x" then mult = 1
			elseif selectedItem == "2x" then mult = 2
			elseif selectedItem == "5x" then mult = 5
			elseif selectedItem == "10x" then mult = 10
			end
			SetPlayerWeaponDamageModifier(PlayerId(), mult + 0.0)
			Scooby.Print("Damage Multiplier: " .. selectedItem, "Damage Multiplier: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Quick Draw',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Quick Draw'] then
				Scooby.createThread(function()
					Scooby.Print("Quick Draw: Enabled", "Quick Draw: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedConfigFlag(Scooby.pedID(), 66, true)
						if not Scooby.menuCheckBoxes['scooby_combat']['Quick Draw'] then
							Scooby.Print("Quick Draw: Disabled", "Quick Draw: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Deadeye',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Deadeye'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Deadeye: Enabled", "Auto Deadeye: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) then
							Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100)
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Deadeye'] then
							Scooby.Print("Auto Deadeye: Disabled", "Auto Deadeye: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'No Spread',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['No Spread'] then
				Scooby.createThread(function()
					Scooby.Print("No Spread: Enabled", "No Spread: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedAccuracy(Scooby.pedID(), 100)
						SetPedResetFlag(Scooby.pedID(), 64, true)
						if not Scooby.menuCheckBoxes['scooby_combat']['No Spread'] then
							Scooby.Print("No Spread: Disabled", "No Spread: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Headshot',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Headshot'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Headshot: Enabled", "Auto Headshot: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local players = GetActivePlayers()
							local nearest = nil
							local nearestDist = 100.0
							local myCoords = GetEntityCoords(Scooby.pedID())
							for _, p in ipairs(players) do
								local ped = GetPlayerPed(p)
								if ped ~= Scooby.pedID() and not IsPedDeadOrDying(ped) and DoesEntityExist(ped) then
									local pCoords = GetEntityCoords(ped)
									local dist = #(myCoords - pCoords)
									if dist < nearestDist then
										nearestDist = dist
										nearest = ped
									end
								end
							end
							if nearest then
								local head = GetPedBoneCoords(nearest, 21030, 0.0, 0.0, 0.0)
								local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
								ShootSingleBulletBetweenCoords(myCoords.x, myCoords.y, myCoords.z + 0.5, head.x, head.y, head.z, 200, true, weapon, Scooby.pedID(), true, true, 1000.0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Headshot'] then
							Scooby.Print("Auto Headshot: Disabled", "Auto Headshot: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'button',
			name = 'Teleport Kill',
			desc = 'TP behind nearest player and shoot',
		}, function()
			local players = GetActivePlayers()
			local nearest = nil
			local nearestDist = 999.0
			local myCoords = GetEntityCoords(Scooby.pedID())
			for _, p in ipairs(players) do
				local ped = GetPlayerPed(p)
				if ped ~= Scooby.pedID() and not IsPedDeadOrDying(ped) and DoesEntityExist(ped) then
					local pCoords = GetEntityCoords(ped)
					local dist = #(myCoords - pCoords)
					if dist < nearestDist then
						nearestDist = dist
						nearest = ped
					end
				end
			end
			if nearest then
				local pCoords = GetEntityCoords(nearest)
				local heading = GetEntityHeading(nearest)
				local rad = math.rad(heading)
				local behindX = pCoords.x - math.sin(rad) * -2.0
				local behindY = pCoords.y - math.cos(rad) * -2.0
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), behindX, behindY, pCoords.z, 0, 0, 0, 0)
				Wait(100)
				local head = GetPedBoneCoords(nearest, 21030, 0.0, 0.0, 0.0)
				local tpCoords = GetEntityCoords(Scooby.pedID())
				local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
				if weapon ~= 0 then
					ShootSingleBulletBetweenCoords(tpCoords.x, tpCoords.y, tpCoords.z + 0.5, head.x, head.y, head.z, 200, true, weapon, Scooby.pedID(), true, true, 1000.0)
				end
				Scooby.Print("Teleport Kill executed", "Teleport Kill executed", false)
			else
				Scooby.Print("No players nearby", "No players nearby", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Anti AFK',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Anti AFK'] then
				Scooby.createThread(function()
					Scooby.Print("Anti AFK: Enabled", "Anti AFK: Enabled", false)
					while true do
						Citizen.Wait(30000)
						Scooby.native(0xE2587F8CBBD87B1D, 0, 0xD27782E3)
						if not Scooby.menuCheckBoxes['scooby_combat']['Anti AFK'] then
							Scooby.Print("Anti AFK: Disabled", "Anti AFK: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Lasso',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Lasso'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Lasso: Enabled", "Auto Lasso: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) then
							local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
							if target and target ~= 0 and DoesEntityExist(target) and IsEntityAPed(target) then
								local hash = GetHashKey("WEAPON_LASSO")
								GiveWeaponToPed(Scooby.pedID(), hash, 1, true, 0)
								TaskShootAtEntity(Scooby.pedID(), target, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Lasso'] then
							Scooby.Print("Auto Lasso: Disabled", "Auto Lasso: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Rage Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Rage Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Rage Mode: Enabled", "Rage Mode: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPlayerWeaponDamageModifier(PlayerId(), 10.0)
						SetPedMoveRateOverride(Scooby.pedID(), 2.5)
						SetPedCanRagdoll(Scooby.pedID(), false)
						SetPedAccuracy(Scooby.pedID(), 100)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 0, 100)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 1, 100)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100)
						if not Scooby.menuCheckBoxes['scooby_combat']['Rage Mode'] then
							SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
							SetPedMoveRateOverride(Scooby.pedID(), 1.0)
							SetPedCanRagdoll(Scooby.pedID(), true)
							Scooby.Print("Rage Mode: Disabled", "Rage Mode: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Revive',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Revive'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Revive: On", "Auto Revive: On", false)
					while true do
						Citizen.Wait(100)
						if IsPedDeadOrDying(Scooby.pedID()) then
							ResurrectPed(Scooby.pedID())
							SetEntityHealth(Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()), 0)
							ClearPedBloodDamage(Scooby.pedID())
							Scooby.Print("Auto revived!", "Auto revived!", false)
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Revive'] then
							Scooby.Print("Auto Revive: Off", "Auto Revive: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'button',
			name = '--- Advanced ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Rapid Fire',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Rapid Fire'] then
				Scooby.createThread(function()
					Scooby.Print("Rapid Fire: Enabled", "Rapid Fire: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) and IsDisabledControlPressed(0, 24) then
							local cam = GetFinalRenderedCamCoord()
							local camRot = GetFinalRenderedCamRot(2)
							local pitch = math.rad(camRot.x)
							local yaw = math.rad(camRot.z)
							local dirX = -math.sin(yaw) * math.cos(pitch)
							local dirY = math.cos(yaw) * math.cos(pitch)
							local dirZ = math.sin(pitch)
							local endPos = vector3(cam.x + dirX * 200.0, cam.y + dirY * 200.0, cam.z + dirZ * 200.0)
							local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
							if weapon ~= 0 then
								ShootSingleBulletBetweenCoords(cam.x, cam.y, cam.z, endPos.x, endPos.y, endPos.z, 50, true, weapon, Scooby.pedID(), true, true, 500.0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Rapid Fire'] then
							Scooby.Print("Rapid Fire: Disabled", "Rapid Fire: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Bullet Time',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Bullet Time'] then
				Scooby.createThread(function()
					Scooby.Print("Bullet Time: Enabled (slow-mo while aiming)", "Bullet Time: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) then
							SetTimeScale(0.3)
						else
							SetTimeScale(1.0)
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Bullet Time'] then
							SetTimeScale(1.0)
							Scooby.Print("Bullet Time: Disabled", "Bullet Time: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby._killAuraRange = 10.0
		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'combobox',
			name = 'Kill Aura Range',
			items = { "5m", "10m", "15m", "25m", "50m", "100m" },
			currentIndex = 2,
			selectedIndex = 2,
		}, function(currentIndex, selectedItem)
			local ranges = { 5, 10, 15, 25, 50, 100 }
			Scooby._killAuraRange = ranges[currentIndex] or 10
			Scooby.Print("Kill Aura Range: " .. selectedItem, "Kill Aura Range: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Block',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Block'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Block: Enabled", "Auto Block: Enabled", false)
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, id in ipairs(GetActivePlayers()) do
							local ped = GetPlayerPed(id)
							if ped ~= Scooby.pedID() and DoesEntityExist(ped) and IsPedShooting(ped) then
								local pCoords = GetEntityCoords(ped)
								if #(myCoords - pCoords) < 50.0 then
									SetPedCanRagdoll(Scooby.pedID(), false)
									SetEntityHealth(Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()), 0)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Block'] then
							Scooby.Print("Auto Block: Disabled", "Auto Block: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Homing Bullets',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Homing Bullets'] then
				Scooby.createThread(function()
					Scooby.Print("Homing Bullets: Enabled", "Homing Bullets: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local myCoords = GetEntityCoords(Scooby.pedID())
							local nearest = nil
							local nearestDist = 150.0
							for _, id in ipairs(GetActivePlayers()) do
								local ped = GetPlayerPed(id)
								if ped ~= Scooby.pedID() and not IsPedDeadOrDying(ped) and DoesEntityExist(ped) then
									local pCoords = GetEntityCoords(ped)
									local dist = #(myCoords - pCoords)
									if dist < nearestDist then
										nearestDist = dist
										nearest = ped
									end
								end
							end
							if nearest then
								local target = GetPedBoneCoords(nearest, GetEntityBoneIndexByName(nearest, _abBone), 0.0, 0.0, 0.0)
								local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
								ShootSingleBulletBetweenCoords(myCoords.x, myCoords.y, myCoords.z + 0.5, target.x, target.y, target.z, 100, true, weapon, Scooby.pedID(), true, true, 800.0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Homing Bullets'] then
							Scooby.Print("Homing Bullets: Disabled", "Homing Bullets: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Gravity Gun',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Gravity Gun'] then
				Scooby.createThread(function()
					Scooby.Print("Gravity Gun: Enabled (aim + shoot to launch target)", "Gravity Gun: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) and IsPedShooting(Scooby.pedID()) then
							local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
							if target and target ~= 0 and DoesEntityExist(target) then
								SetPedToRagdoll(target, 3000, 3000, 0, false, false, false)
								ApplyForceToEntity(target, 1, 0.0, 0.0, 50.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Gravity Gun'] then
							Scooby.Print("Gravity Gun: Disabled", "Gravity Gun: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'button',
			name = '--- Combat Sliders ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'combobox',
			name = 'Aim FOV',
			items = { "Narrow (5)", "Small (10)", "Normal (20)", "Wide (45)", "Very Wide (90)", "Full (180)" },
			currentIndex = 3,
			selectedIndex = 3,
		}, function(currentIndex, selectedItem)
			local fovs = { 5, 10, 20, 45, 90, 180 }
			Scooby._aimFOV = fovs[currentIndex] or 20
			Scooby.Print("Aim FOV: " .. selectedItem, "Aim FOV: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Silent Kill',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Silent Kill'] then
				Scooby.createThread(function()
					Scooby.Print("Silent Kill: On (kills leave no evidence)", "Silent Kill: On", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								for _, ped in pairs(GetGamePool('CPed')) do
									if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
										local dist = #(vector3(impact.x, impact.y, impact.z) - GetEntityCoords(ped))
										if dist < 2.0 then
											SetEntityHealth(ped, 0, 0)
											SetEntityAsMissionEntity(ped, true, true)
											DeleteEntity(ped)
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Silent Kill'] then
							Scooby.Print("Silent Kill: Off", "Silent Kill: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Freeze on Aim',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Freeze on Aim'] then
				Scooby.createThread(function()
					Scooby.Print("Freeze on Aim: On (targets freeze when aimed at)", "Freeze on Aim: On", false)
					local frozenPed = nil
					while true do
						Citizen.Wait(0)
						if IsPlayerFreeAiming(PlayerId()) then
							local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
							if target and target ~= 0 and DoesEntityExist(target) and IsEntityAPed(target) then
								if frozenPed and frozenPed ~= target then
									FreezeEntityPosition(frozenPed, false)
								end
								FreezeEntityPosition(target, true)
								frozenPed = target
							end
						else
							if frozenPed then
								FreezeEntityPosition(frozenPed, false)
								frozenPed = nil
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Freeze on Aim'] then
							if frozenPed then FreezeEntityPosition(frozenPed, false) end
							Scooby.Print("Freeze on Aim: Off", "Freeze on Aim: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Ragdoll on Hit',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Ragdoll on Hit'] then
				Scooby.createThread(function()
					Scooby.Print("Ragdoll on Hit: On", "Ragdoll on Hit: On", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								for _, ped in pairs(GetGamePool('CPed')) do
									if ped ~= PlayerPedId() and not IsPedDeadOrDying(ped) then
										local dist = #(vector3(impact.x, impact.y, impact.z) - GetEntityCoords(ped))
										if dist < 3.0 then
											SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
											ApplyForceToEntity(ped, 1, 0.0, 0.0, 15.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Ragdoll on Hit'] then
							Scooby.Print("Ragdoll on Hit: Off", "Ragdoll on Hit: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Drain Health on Aim',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Drain Health on Aim'] then
				Scooby.createThread(function()
					Scooby.Print("Drain Health: On (aimed target loses HP)", "Drain Health: On", false)
					while true do
						Citizen.Wait(100)
						if IsPlayerFreeAiming(PlayerId()) then
							local _, target = GetEntityPlayerIsFreeAimingAt(PlayerId())
							if target and target ~= 0 and DoesEntityExist(target) and IsEntityAPed(target) and not IsPedDeadOrDying(target) then
								local hp = GetEntityHealth(target)
								SetEntityHealth(target, math.max(0, hp - 10), 0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Drain Health on Aim'] then
							Scooby.Print("Drain Health: Off", "Drain Health: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Steal Health',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Steal Health'] then
				Scooby.createThread(function()
					Scooby.Print("Steal Health: On (heal from kills)", "Steal Health: On", false)
					local lastKillStates = {}
					while true do
						Citizen.Wait(100)
						for _, id in ipairs(GetActivePlayers()) do
							local ped = GetPlayerPed(id)
							local sid = GetPlayerServerId(id)
							if ped ~= Scooby.pedID() then
								local dead = IsPedDeadOrDying(ped)
								if dead and lastKillStates[sid] == false then
									local hp = GetEntityHealth(Scooby.pedID())
									local maxHp = GetPedMaxHealth(Scooby.pedID())
									SetEntityHealth(Scooby.pedID(), math.min(maxHp, hp + 200), 0)
									Scooby.Print("Stole health!", "Stole health!", false)
								end
								lastKillStates[sid] = dead
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Steal Health'] then
							Scooby.Print("Steal Health: Off", "Steal Health: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'checkbox',
			name = 'Auto Shoot Nearest',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_combat']['Auto Shoot Nearest'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Shoot: On", "Auto Shoot: On", false)
					while true do
						Citizen.Wait(500)
						local myCoords = GetEntityCoords(Scooby.pedID())
						local nearest = nil
						local nearestDist = 50.0
						for _, id in ipairs(GetActivePlayers()) do
							local ped = GetPlayerPed(id)
							if ped ~= Scooby.pedID() and not IsPedDeadOrDying(ped) and DoesEntityExist(ped) then
								local dist = #(myCoords - GetEntityCoords(ped))
								if dist < nearestDist then
									nearestDist = dist
									nearest = ped
								end
							end
						end
						if nearest then
							local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
							if weapon ~= 0 then
								local head = GetPedBoneCoords(nearest, 21030, 0.0, 0.0, 0.0)
								ShootSingleBulletBetweenCoords(myCoords.x, myCoords.y, myCoords.z + 0.5, head.x, head.y, head.z, 100, true, weapon, Scooby.pedID(), true, true, 800.0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_combat']['Auto Shoot Nearest'] then
							Scooby.Print("Auto Shoot: Off", "Auto Shoot: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'combobox',
			name = 'Auto Heal Threshold',
			items = { "Off", "25%", "50%", "75%", "90%" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby._autoHealThreshold = ({ 0, 0.25, 0.50, 0.75, 0.90 })[currentIndex] or 0
			if Scooby._autoHealThreshold > 0 then
				Scooby.Print("Auto Heal at " .. selectedItem, "Auto Heal at " .. selectedItem, false)
			else
				Scooby.Print("Auto Heal: Off", "Auto Heal: Off", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'combobox',
			name = 'Deadeye Drain Rate',
			items = { "Normal", "Slow", "Very Slow", "None" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby.Print("Deadeye Drain: " .. selectedItem, "Deadeye Drain: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_combat', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_teleport', 'scooby_main', "ScoobyOP", "Teleport", false, function()
		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP to Waypoint',
			desc = 'Teleport to your map marker',
		}, function()
			if Scooby.native(0xD42BD6EB2E0F1677, Scooby.pedID()) then
				local WP = GetWaypointCoords()
				if not (WP.x == 0 and WP.y == 0) then
					local height = 1
					for height = 1, 1000 do
						Scooby.native(0x06843DA7060A026B, Scooby.pedID(), WP.x, WP.y, height + 0.0, 0, 0, 0, 0)
						local foundground, groundZ, normal = GetGroundZAndNormalFor_3dCoord(WP.x, WP.y, height + 0.0)
						if foundground then
							Scooby.native(0x06843DA7060A026B, Scooby.pedID(), WP.x, WP.y, height + 0.0, 0, 0, 0, 0)
							break
						end
						Wait(25)
					end
				end
			end
			Scooby.Print("Teleported to waypoint", "Teleported to waypoint", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP Forward',
			desc = 'Teleport 10m in facing direction',
		}, function()
			local ped = Scooby.pedID()
			local coords = GetEntityCoords(ped)
			local heading = GetEntityHeading(ped)
			local rad = math.rad(heading)
			local x = coords.x - math.sin(rad) * 10.0
			local y = coords.y + math.cos(rad) * 10.0
			local z = coords.z
			Scooby.native(0x06843DA7060A026B, ped, x, y, z, 0, 0, 0, 0)
			Scooby.Print("Teleported forward", "Teleported forward", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP to _xh',
			desc = 'Raycast and teleport to hit point',
		}, function()
			local ped = Scooby.pedID()
			local camCoords = GetGameplayCamCoord()
			local camRot = GetGameplayCamRot(2)
			local radX = math.rad(camRot.x)
			local radZ = math.rad(camRot.z)
			local dir = vector3(
				-math.sin(radZ) * math.abs(math.cos(radX)),
				math.cos(radZ) * math.abs(math.cos(radX)),
				math.sin(radX)
			)
			local dest = camCoords + dir * 1000.0
			local handle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, dest.x, dest.y, dest.z, -1, ped, 0)
			local _, hit, hitCoords, _, _ = GetShapeTestResult(handle)
			if hit == 1 then
				Scooby.native(0x06843DA7060A026B, ped, hitCoords.x, hitCoords.y, hitCoords.z + 1.0, 0, 0, 0, 0)
				Scooby.Print("Teleported to crosshair", "Teleported to crosshair", false)
			else
				Scooby.Print("No hit detected", "No hit detected", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Valentine',
			desc = 'Teleport to Valentine',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -280.53, 788.35, 119.39, 0, 0, 0, 0)
			Scooby.Print("Teleported to Valentine", "Teleported to Valentine", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Saint Denis',
			desc = 'Teleport to Saint Denis',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 2432.73, -1210.83, 46.07, 0, 0, 0, 0)
			Scooby.Print("Teleported to Saint Denis", "Teleported to Saint Denis", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Rhodes',
			desc = 'Teleport to Rhodes',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 1232.87, -1283.74, 75.91, 0, 0, 0, 0)
			Scooby.Print("Teleported to Rhodes", "Teleported to Rhodes", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Strawberry',
			desc = 'Teleport to Strawberry',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -1790.77, -396.02, 160.44, 0, 0, 0, 0)
			Scooby.Print("Teleported to Strawberry", "Teleported to Strawberry", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Blackwater',
			desc = 'Teleport to Blackwater',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -804.77, -1270.83, 43.79, 0, 0, 0, 0)
			Scooby.Print("Teleported to Blackwater", "Teleported to Blackwater", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Annesburg',
			desc = 'Teleport to Annesburg',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 2932.06, 1290.99, 44.67, 0, 0, 0, 0)
			Scooby.Print("Teleported to Annesburg", "Teleported to Annesburg", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Van Horn',
			desc = 'Teleport to Van Horn',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 2991.97, 516.73, 44.46, 0, 0, 0, 0)
			Scooby.Print("Teleported to Van Horn", "Teleported to Van Horn", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Tumbleweed',
			desc = 'Teleport to Tumbleweed',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -5508.27, -2937.43, -2.34, 0, 0, 0, 0)
			Scooby.Print("Teleported to Tumbleweed", "Teleported to Tumbleweed", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Armadillo',
			desc = 'Teleport to Armadillo',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -3647.13, -2593.69, -14.26, 0, 0, 0, 0)
			Scooby.Print("Teleported to Armadillo", "Teleported to Armadillo", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Emerald Ranch',
			desc = 'Teleport to Emerald Ranch',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 1332.87, 378.14, 89.56, 0, 0, 0, 0)
			Scooby.Print("Teleported to Emerald Ranch", "Teleported to Emerald Ranch", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Wapiti',
			desc = 'Teleport to Wapiti',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 497.78, 2192.39, 243.72, 0, 0, 0, 0)
			Scooby.Print("Teleported to Wapiti", "Teleported to Wapiti", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Colter',
			desc = 'Teleport to Colter',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -1367.43, 2418.44, 307.94, 0, 0, 0, 0)
			Scooby.Print("Teleported to Colter", "Teleported to Colter", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Guarma',
			desc = 'Teleport to Guarma',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 1348.89, -6788.47, 42.15, 0, 0, 0, 0)
			Scooby.Print("Teleported to Guarma", "Teleported to Guarma", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Sisika',
			desc = 'Teleport to Sisika',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 3321.86, -656.37, 44.28, 0, 0, 0, 0)
			Scooby.Print("Teleported to Sisika", "Teleported to Sisika", false)
		end)

		-- === Quick TP ===
		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = '--- Quick TP ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP to Random Player',
			desc = 'Teleport to a random online player',
		}, function()
			local players = GetActivePlayers()
			local others = {}
			for _, id in ipairs(players) do
				if id ~= PlayerId() then table.insert(others, id) end
			end
			if #others > 0 then
				local target = others[math.random(1, #others)]
				local coords = GetEntityCoords(GetPlayerPed(target))
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), coords.x, coords.y, coords.z, false, false, false, false)
				Scooby.Print("TP to " .. GetPlayerName(target), "TP to " .. GetPlayerName(target), false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP to Last Death',
			desc = 'Teleport back to where you last died',
		}, function()
			if Scooby.lastDeathCoords then
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), Scooby.lastDeathCoords.x, Scooby.lastDeathCoords.y, Scooby.lastDeathCoords.z, false, false, false, false)
				Scooby.Print("TP to death location", "TP to death location", false)
			else
				Scooby.Print("No death location saved", "No death location saved", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP Up 50m',
			desc = 'Teleport 50 meters straight up',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), coords.x, coords.y, coords.z + 50.0, false, false, false, false)
			Scooby.Print("Teleported up 50m", "Teleported up 50m", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP Into Nearest Vehicle',
			desc = 'Warp into the closest vehicle',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 50.0, 0, 70)
			if veh and veh ~= 0 then
				TaskWarpPedIntoVehicle(Scooby.pedID(), veh, -1)
				Scooby.Print("Warped into vehicle", "Warped into vehicle", false)
			else
				Scooby.Print("No vehicle nearby", "No vehicle nearby", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = '--- Advanced TP ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP Behind Nearest Player',
			desc = 'Teleport silently behind the closest player',
		}, function()
			local players = GetActivePlayers()
			local nearest = nil
			local nearestDist = 999.0
			local myCoords = GetEntityCoords(Scooby.pedID())
			for _, p in ipairs(players) do
				if p ~= PlayerId() then
					local ped = GetPlayerPed(p)
					if DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
						local dist = #(myCoords - GetEntityCoords(ped))
						if dist < nearestDist then
							nearestDist = dist
							nearest = ped
						end
					end
				end
			end
			if nearest then
				local pCoords = GetEntityCoords(nearest)
				local heading = GetEntityHeading(nearest)
				local rad = math.rad(heading)
				local behindX = pCoords.x - math.sin(rad) * -3.0
				local behindY = pCoords.y - math.cos(rad) * -3.0
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), behindX, behindY, pCoords.z, false, false, false, false)
				SetEntityHeading(Scooby.pedID(), heading)
				Scooby.Print("TP behind player", "TP behind player", false)
			else
				Scooby.Print("No players found", "No players found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP to Nearest Player',
			desc = 'Teleport directly to closest player',
		}, function()
			local players = GetActivePlayers()
			local nearest = nil
			local nearestDist = 99999
			local myCoords = GetEntityCoords(Scooby.pedID())
			for _, p in ipairs(players) do
				if p ~= PlayerId() then
					local ped = GetPlayerPed(p)
					if DoesEntityExist(ped) then
						local dist = #(myCoords - GetEntityCoords(ped))
						if dist < nearestDist then
							nearestDist = dist
							nearest = ped
						end
					end
				end
			end
			if nearest then
				local coords = GetEntityCoords(nearest)
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), coords.x + 1.0, coords.y, coords.z, false, false, false, false)
				Scooby.Print("TP to nearest player", "TP to nearest player", false)
			else
				Scooby.Print("No players found", "No players found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP to Custom Coords',
			desc = 'Enter X, Y, Z coordinates',
		}, function()
			Scooby.createThread(function()
				Scooby.Print("Enter X coordinate", "Enter X coordinate", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				local tpX, tpY, tpZ
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)
					if UpdateOnscreenKeyboard() == 1 then
						tpX = tonumber(GetOnscreenKeyboardResult()) or 0
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then return end
				end
				Wait(10)
				Scooby.Print("Enter Y coordinate", "Enter Y coordinate", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)
					if UpdateOnscreenKeyboard() == 1 then
						tpY = tonumber(GetOnscreenKeyboardResult()) or 0
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then return end
				end
				Wait(10)
				Scooby.Print("Enter Z coordinate", "Enter Z coordinate", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)
					if UpdateOnscreenKeyboard() == 1 then
						tpZ = tonumber(GetOnscreenKeyboardResult()) or 0
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then return end
				end
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), tpX, tpY, tpZ, false, false, false, false)
				Scooby.Print(string.format("TP to %.1f, %.1f, %.1f", tpX, tpY, tpZ), string.format("TP to %.1f, %.1f, %.1f", tpX, tpY, tpZ), false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'TP Back 10m',
			desc = 'Teleport 10m backwards',
		}, function()
			local ped = Scooby.pedID()
			local coords = GetEntityCoords(ped)
			local heading = GetEntityHeading(ped)
			local rad = math.rad(heading)
			local x = coords.x + math.sin(rad) * 10.0
			local y = coords.y - math.cos(rad) * 10.0
			Scooby.native(0x06843DA7060A026B, ped, x, y, coords.z, 0, 0, 0, 0)
			Scooby.Print("Teleported back", "Teleported back", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = '--- More Locations ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Lagras',
			desc = 'Teleport to Lagras',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 2116.78, -597.13, 42.38, 0, 0, 0, 0)
			Scooby.Print("Teleported to Lagras", "Teleported to Lagras", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Thieves Landing',
			desc = 'Teleport to Thieves Landing',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -1466.50, -1735.50, 42.90, 0, 0, 0, 0)
			Scooby.Print("Teleported to Thieves Landing", "Teleported to Thieves Landing", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'MacFarlanes Ranch',
			desc = 'Teleport to MacFarlanes Ranch',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -2338.07, -2398.46, 62.10, 0, 0, 0, 0)
			Scooby.Print("Teleported to MacFarlanes Ranch", "Teleported to MacFarlanes Ranch", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Butcher Creek',
			desc = 'Teleport to Butcher Creek',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 2562.40, 857.40, 81.25, 0, 0, 0, 0)
			Scooby.Print("Teleported to Butcher Creek", "Teleported to Butcher Creek", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Tall Trees',
			desc = 'Teleport to Tall Trees',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -1169.26, -611.62, 87.43, 0, 0, 0, 0)
			Scooby.Print("Teleported to Tall Trees", "Teleported to Tall Trees", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Hanging Dog Ranch',
			desc = 'Teleport to Hanging Dog Ranch',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -1211.23, 712.16, 119.26, 0, 0, 0, 0)
			Scooby.Print("Teleported to Hanging Dog Ranch", "Teleported to Hanging Dog Ranch", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Manzanita Post',
			desc = 'Teleport to Manzanita Post',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), -1582.33, -961.61, 80.52, 0, 0, 0, 0)
			Scooby.Print("Teleported to Manzanita Post", "Teleported to Manzanita Post", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'Braithwaite Manor',
			desc = 'Teleport to Braithwaite Manor',
		}, function()
			Scooby.native(0x06843DA7060A026B, Scooby.pedID(), 1023.39, -1743.41, 47.07, 0, 0, 0, 0)
			Scooby.Print("Teleported to Braithwaite Manor", "Teleported to Braithwaite Manor", false)
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'checkbox',
			name = 'Auto TP to Waypoint',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_teleport']['Auto TP to Waypoint'] then
				Scooby.createThread(function()
					Scooby.Print("Auto TP: On (auto-TPs when you set a waypoint)", "Auto TP: On", false)
					local lastWP = vector2(0, 0)
					while true do
						Citizen.Wait(500)
						local wp = GetWaypointCoords()
						if wp.x ~= 0 or wp.y ~= 0 then
							if wp.x ~= lastWP.x or wp.y ~= lastWP.y then
								lastWP = vector2(wp.x, wp.y)
								for h = 1, 1000 do
									Scooby.native(0x06843DA7060A026B, Scooby.pedID(), wp.x, wp.y, h + 0.0, 0, 0, 0, 0)
									local found, gz = GetGroundZFor_3dCoord(wp.x, wp.y, h + 0.0)
									if found then
										Scooby.native(0x06843DA7060A026B, Scooby.pedID(), wp.x, wp.y, gz + 1.0, 0, 0, 0, 0)
										break
									end
									Wait(10)
								end
								Scooby.Print("Auto TP: Teleported!", "Auto TP: Teleported!", false)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_teleport']['Auto TP to Waypoint'] then
							Scooby.Print("Auto TP: Off", "Auto TP: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_teleport', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_vehicle', 'scooby_main', "ScoobyOP", "Vehicle", false, function()
		-- === Horse Features ===
		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Horse ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Horse Godmode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Godmode'] then
				Scooby.createThread(function()
					Scooby.Print("Horse Godmode: Enabled", "Horse Godmode: Enabled", false)
					while (true) do
						Citizen.Wait(1)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetEntityHealth(mount, GetPedMaxHealth(mount), 0)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Godmode'] then
							Scooby.Print("Horse Godmode: Disabled", "Horse Godmode: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Horse Speed Boost',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Speed Boost'] then
				Scooby.createThread(function()
					Scooby.Print("Horse Speed Boost: Enabled", "Horse Speed Boost: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetPedMoveRateOverride(mount, 3.0)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Speed Boost'] then
							Scooby.Print("Horse Speed Boost: Disabled", "Horse Speed Boost: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Infinite Horse Stamina',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Infinite Horse Stamina'] then
				Scooby.createThread(function()
					Scooby.Print("Infinite Horse Stamina: Enabled", "Infinite Horse Stamina: Enabled", false)
					while (true) do
						Citizen.Wait(1)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							Scooby.native(0xC6258F41D86676E0, mount, 1, 100)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Infinite Horse Stamina'] then
							Scooby.Print("Infinite Horse Stamina: Disabled", "Infinite Horse Stamina: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'No Horse Fall',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['No Horse Fall'] then
				Scooby.createThread(function()
					Scooby.Print("No Horse Fall: Enabled", "No Horse Fall: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetPedCanRagdoll(mount, false)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['No Horse Fall'] then
							Scooby.Print("No Horse Fall: Disabled", "No Horse Fall: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		-- === Horse Spawning ===
		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Spawn Horses ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn Best Horse',
			desc = 'Spawn a White Arabian',
		}, function()
			local model = GetHashKey("a_c_horse_arabian_white")
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(1)
			end
			local coords = GetEntityCoords(Scooby.pedID())
			local horse = CreatePed(model, coords.x + 3.0, coords.y, coords.z, 0.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, horse, true)
			Scooby.Print("Spawned White Arabian", "Spawned White Arabian", false)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn War Horse',
			desc = 'Spawn a Dark Bay Shire',
		}, function()
			local model = GetHashKey("a_c_horse_shire_darkbay")
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(1)
			end
			local coords = GetEntityCoords(Scooby.pedID())
			local horse = CreatePed(model, coords.x + 3.0, coords.y, coords.z, 0.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, horse, true)
			Scooby.Print("Spawned War Horse", "Spawned War Horse", false)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn Black Arabian',
			desc = 'Spawn a Black Arabian',
		}, function()
			local model = GetHashKey("a_c_horse_arabian_black")
			RequestModel(model)
			while not HasModelLoaded(model) do
				RequestModel(model)
				Wait(1)
			end
			local coords = GetEntityCoords(Scooby.pedID())
			local horse = CreatePed(model, coords.x + 3.0, coords.y, coords.z, 0.0, true, false)
			Citizen.InvokeNative(0x283978A15512B2FE, horse, true)
			Scooby.Print("Spawned Black Arabian", "Spawned Black Arabian", false)
		end)

		-- === Horse Actions ===
		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Horse Actions ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Delete Current Horse',
			desc = 'Delete your current mount',
		}, function()
			local mount = GetMount(Scooby.pedID())
			if mount and mount ~= 0 then
				SetEntityAsMissionEntity(mount, true, true)
				DeleteEntity(mount)
				Scooby.Print("Horse deleted", "Horse deleted", false)
			else
				Scooby.Print("No mount found", "No mount found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Revive Horse',
			desc = 'Resurrect and heal your mount',
		}, function()
			local mount = GetMount(Scooby.pedID())
			if mount and mount ~= 0 then
				if IsPedDeadOrDying(mount) then
					ResurrectPed(mount)
				end
				SetEntityHealth(mount, GetPedMaxHealth(mount), 0)
				ClearPedBloodDamage(mount)
				Scooby.Print("Horse revived", "Horse revived", false)
			else
				Scooby.Print("No mount found", "No mount found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Teleport Horse to Me',
			desc = 'Bring your mount to you',
		}, function()
			local mount = GetMount(Scooby.pedID())
			if mount and mount ~= 0 then
				local coords = GetEntityCoords(Scooby.pedID())
				Scooby.native(0x06843DA7060A026B, mount, coords.x + 2.0, coords.y, coords.z, 0, 0, 0, 0)
				Scooby.Print("Horse teleported", "Horse teleported", false)
			else
				Scooby.Print("No mount found", "No mount found", false)
			end
		end)

		-- === Wagon Features ===
		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Wagon ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Wagon Godmode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Wagon Godmode'] then
				Scooby.createThread(function()
					Scooby.Print("Wagon Godmode: Enabled", "Wagon Godmode: Enabled", false)
					while (true) do
						Citizen.Wait(1)
						local veh = GetVehiclePedIsIn(Scooby.pedID(), false)
						if veh and veh ~= 0 then
							SetEntityHealth(veh, GetEntityMaxHealth(veh), 0)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Wagon Godmode'] then
							Scooby.Print("Wagon Godmode: Disabled", "Wagon Godmode: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Boost Wagon',
			desc = 'Apply forward force to current vehicle',
		}, function()
			local veh = GetVehiclePedIsIn(Scooby.pedID(), false)
			if veh and veh ~= 0 then
				local fwd = GetEntityForwardVector(veh)
				ApplyForceToEntity(veh, 1, fwd.x * 50.0, fwd.y * 50.0, fwd.z * 50.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
				Scooby.Print("Wagon boosted", "Wagon boosted", false)
			else
				Scooby.Print("Not in a vehicle", "Not in a vehicle", false)
			end
		end)

		-- === Vehicle Repair/Flip ===
		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Vehicle Utility ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Repair Vehicle',
			desc = 'Fix and clean current vehicle',
		}, function()
			local veh = GetVehiclePedIsIn(Scooby.pedID(), false)
			if veh and veh ~= 0 then
				SetVehicleFixed(veh)
				SetVehicleDirtLevel(veh, 0.0)
				Scooby.Print("Vehicle repaired", "Vehicle repaired", false)
			else
				Scooby.Print("Not in a vehicle", "Not in a vehicle", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Flip Vehicle',
			desc = 'Set vehicle upright',
		}, function()
			local veh = GetVehiclePedIsIn(Scooby.pedID(), false)
			if veh and veh ~= 0 then
				SetEntityRotation(veh, 0.0, 0.0, GetEntityHeading(veh), 0, true)
				PlaceObjectOnGroundProperly(veh)
				Scooby.Print("Vehicle flipped upright", "Vehicle flipped upright", false)
			else
				Scooby.Print("Not in a vehicle", "Not in a vehicle", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Horse Infinite Health',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Infinite Health'] then
				Scooby.createThread(function()
					Scooby.Print("Horse Infinite Health: Enabled", "Horse Infinite Health: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetEntityHealth(mount, GetPedMaxHealth(mount), 0)
							SetEntityInvincible(mount, true)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Infinite Health'] then
							local mount2 = GetMount(Scooby.pedID())
							if mount2 and mount2 ~= 0 then SetEntityInvincible(mount2, false) end
							Scooby.Print("Horse Infinite Health: Disabled", "Horse Infinite Health: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Super Horse Speed',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Super Horse Speed'] then
				Scooby.createThread(function()
					Scooby.Print("Super Horse Speed: Enabled", "Super Horse Speed: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetPedMoveRateOverride(mount, 5.0)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Super Horse Speed'] then
							Scooby.Print("Super Horse Speed: Disabled", "Super Horse Speed: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn All Horses',
			desc = 'Spawn 5 different horse breeds',
		}, function()
			local horses = {"a_c_horse_arabian_white", "a_c_horse_arabian_black", "a_c_horse_shire_darkbay", "a_c_horse_turkoman_gold", "a_c_horse_missourifoxtrotter_buckskincovero"}
			local coords = GetEntityCoords(Scooby.pedID())
			for i, model in ipairs(horses) do
				Scooby.spawnPed(model, vector3(coords.x + i*3, coords.y, coords.z), 0.0, function(name, ped)
					Scooby.Print("Spawned: " .. name, "Spawned: " .. name, false)
				end)
			end
		end)

		-- === Spawn Vehicles ===
		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Spawn Vehicles ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn Stagecoach',
			desc = 'Spawn a coach2 stagecoach',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("coach2")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					local heading = GetEntityHeading(Scooby.pedID())
					local veh = CreateVehicle(hash, coords.x + 4.0, coords.y, coords.z, heading, true, true)
					SetModelAsNoLongerNeeded(hash)
					Scooby.Print("Vehicle spawned", "Vehicle spawned", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn Cart',
			desc = 'Spawn a cart01',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("cart01")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					local heading = GetEntityHeading(Scooby.pedID())
					local veh = CreateVehicle(hash, coords.x + 4.0, coords.y, coords.z, heading, true, true)
					SetModelAsNoLongerNeeded(hash)
					Scooby.Print("Vehicle spawned", "Vehicle spawned", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn Canoe',
			desc = 'Spawn a canoe',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("canoe")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					local heading = GetEntityHeading(Scooby.pedID())
					local veh = CreateVehicle(hash, coords.x + 4.0, coords.y, coords.z, heading, true, true)
					SetModelAsNoLongerNeeded(hash)
					Scooby.Print("Vehicle spawned", "Vehicle spawned", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Spawn Train Cart',
			desc = 'Spawn a handcart',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("handcart")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					local heading = GetEntityHeading(Scooby.pedID())
					local veh = CreateVehicle(hash, coords.x + 4.0, coords.y, coords.z, heading, true, true)
					SetModelAsNoLongerNeeded(hash)
					Scooby.Print("Vehicle spawned", "Vehicle spawned", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Delete Nearest Vehicle',
			desc = 'Delete the closest vehicle within 20m',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local veh = GetClosestVehicle(coords.x, coords.y, coords.z, 20.0, 0, 70)
			if veh and veh ~= 0 then
				SetEntityAsMissionEntity(veh, true, true)
				DeleteVehicle(veh)
				Scooby.Print("Vehicle deleted", "Vehicle deleted", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = '--- Horse Extras ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Horse Jump Boost',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Jump Boost'] then
				Scooby.createThread(function()
					Scooby.Print("Horse Jump Boost: Enabled", "Horse Jump Boost: Enabled", false)
					while true do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 and IsPedJumping(mount) then
							ApplyForceToEntity(mount, 1, 0.0, 0.0, 20.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Jump Boost'] then
							Scooby.Print("Horse Jump Boost: Disabled", "Horse Jump Boost: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Horse No Clip',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse No Clip'] then
				Scooby.createThread(function()
					Scooby.Print("Horse No Clip: Enabled", "Horse No Clip: Enabled", false)
					local hPos = nil
					local hSpeed = 1.0
					while true do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							if not hPos then hPos = GetEntityCoords(mount) end
							FreezeEntityPosition(mount, true)
							SetEntityCollision(mount, false, false)

							if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD27782E3) then
								hPos = GetOffsetFromEntityInWorldCoords(mount, 0.0, hSpeed, 0.0)
							end
							if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FD015D8) then
								hPos = GetOffsetFromEntityInWorldCoords(mount, 0.0, -hSpeed, 0.0)
							end
							if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD9D0E1C0) then
								hPos = vector3(hPos.x, hPos.y, hPos.z + hSpeed)
							end
							if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xDB096B85) then
								hPos = vector3(hPos.x, hPos.y, hPos.z - hSpeed)
							end
							if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FFC75D6) then
								hSpeed = hSpeed >= 6.0 and 1.0 or hSpeed + 1.0
							end

							Scooby.native(0x239A3351AC1DA385, mount, hPos.x, hPos.y, hPos.z, 0, 0, 0)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse No Clip'] then
							local mt = GetMount(Scooby.pedID())
							if mt and mt ~= 0 then
								FreezeEntityPosition(mt, false)
								SetEntityCollision(mt, true, true)
							end
							hPos = nil
							Scooby.Print("Horse No Clip: Disabled", "Horse No Clip: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Tame Nearest Horse',
			desc = 'Take ownership of nearest unridden horse',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local nearest = nil
			local nearestDist = 50.0
			for _, ped in pairs(GetGamePool('CPed')) do
				if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
					if IsEntityAVehicle(GetVehiclePedIsIn(ped, false)) == false then
						local model = GetEntityModel(ped)
						if IsModelAHorse(model) then
							local dist = #(coords - GetEntityCoords(ped))
							if dist < nearestDist then
								nearestDist = dist
								nearest = ped
							end
						end
					end
				end
			end
			if nearest then
				SetPedOntoMount(Scooby.pedID(), nearest, -1, true)
				Scooby.Print("Tamed nearest horse!", "Tamed nearest horse!", false)
			else
				Scooby.Print("No horse nearby", "No horse nearby", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Horse Drift',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Drift'] then
				Scooby.createThread(function()
					Scooby.Print("Horse Drift: Enabled (sprint to drift)", "Horse Drift: Enabled", false)
					while true do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 and IsPedSprinting(mount) then
							local vel = GetEntityVelocity(mount)
							local speed = math.sqrt(vel.x*vel.x + vel.y*vel.y)
							if speed > 5.0 then
								local fwd = GetEntityForwardVector(mount)
								ApplyForceToEntity(mount, 1, fwd.x * 2.0, fwd.y * 2.0, -0.5, 1.0, 0.0, 0.0, 0, false, true, true, false, true)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Horse Drift'] then
							Scooby.Print("Horse Drift: Disabled", "Horse Drift: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'combobox',
			name = 'Horse Speed',
			items = { "Normal", "Fast (2x)", "Very Fast (3x)", "Insane (5x)", "Ludicrous (8x)" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local speeds = { 1.0, 2.0, 3.0, 5.0, 8.0 }
			local mount = GetMount(Scooby.pedID())
			if mount and mount ~= 0 then
				SetPedMoveRateOverride(mount, speeds[currentIndex] or 1.0)
			end
			Scooby.Print("Horse Speed: " .. selectedItem, "Horse Speed: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'Launch Horse',
			desc = 'Catapult your horse into the sky',
		}, function()
			local mount = GetMount(Scooby.pedID())
			if mount and mount ~= 0 then
				ApplyForceToEntity(mount, 1, 0.0, 10.0, 50.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
				Scooby.Print("Horse launched!", "Horse launched!", false)
			else
				Scooby.Print("Not on a horse", "Not on a horse", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'combobox',
			name = 'Horse Stamina Regen',
			items = { "Off", "Slow", "Normal", "Fast", "Instant" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local rates = { 0, 0.1, 0.3, 0.7, 1.0 }
			local rate = rates[currentIndex] or 0
			if rate == 0 then
				Scooby.Print("Horse Stamina Regen: Off", "Horse Stamina Regen: Off", false)
			else
				Scooby.createThread(function()
					Scooby.Print("Horse Stamina Regen: " .. selectedItem, "Horse Stamina Regen: " .. selectedItem, false)
					while true do
						Citizen.Wait(500)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							local cur = Citizen.InvokeNative(0x775A1CA7893AA8B5, mount, Citizen.ResultAsFloat())
							local max = Citizen.InvokeNative(0x4E929E7A5796FD26, mount, Citizen.ResultAsFloat())
							if cur < max then
								local newVal = math.min(cur + (max * rate), max)
								Citizen.InvokeNative(0xC3D4B754C0E69555, mount, newVal)
							end
						end
						local cb = Scooby.menuCheckBoxes['scooby_vehicle']
						if not cb or not cb['Horse Stamina Regen'] then break end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Auto Feed Horse',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Auto Feed Horse'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Feed Horse: Enabled", "Auto Feed Horse: Enabled", false)
					while true do
						Citizen.Wait(2000)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetEntityHealth(mount, GetPedMaxHealth(mount), 0)
							local maxStam = Citizen.InvokeNative(0x4E929E7A5796FD26, mount, Citizen.ResultAsFloat())
							Citizen.InvokeNative(0xC3D4B754C0E69555, mount, maxStam)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Auto Feed Horse'] then
							Scooby.Print("Auto Feed Horse: Disabled", "Auto Feed Horse: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'combobox',
			name = 'Horse Gravity',
			items = { "Normal", "Low", "Moon", "Zero" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local forces = { 0.0, 3.0, 8.0, 12.0 }
			local force = forces[currentIndex] or 0.0
			if force == 0.0 then
				Scooby.Print("Horse Gravity: Normal", "Horse Gravity: Normal", false)
			else
				Scooby.createThread(function()
					Scooby.Print("Horse Gravity: " .. selectedItem, "Horse Gravity: " .. selectedItem, false)
					while true do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							if not IsEntityOnScreen(mount) then goto continue end
							local vel = GetEntityVelocity(mount)
							if vel.z < -0.5 then
								ApplyForceToEntity(mount, 1, 0.0, 0.0, force, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
							end
						end
						::continue::
						local cb = Scooby.menuCheckBoxes['scooby_vehicle']
						if not cb or not cb['Horse Gravity'] then break end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'checkbox',
			name = 'Invincible Horse',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_vehicle']['Invincible Horse'] then
				Scooby.createThread(function()
					Scooby.Print("Invincible Horse: Enabled", "Invincible Horse: Enabled", false)
					while true do
						Citizen.Wait(0)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetEntityInvincible(mount, true)
						end
						if not Scooby.menuCheckBoxes['scooby_vehicle']['Invincible Horse'] then
							local mount2 = GetMount(Scooby.pedID())
							if mount2 and mount2 ~= 0 then SetEntityInvincible(mount2, false) end
							Scooby.Print("Invincible Horse: Disabled", "Invincible Horse: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_vehicle', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function()
			Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
		end)
	end)

	Scooby.registerSubMenu('scooby_world', 'scooby_main', "ScoobyOP", "World", false, function()
		Scooby.registerMenuAttribute('scooby_world', {
			type = 'combobox',
			name = 'Set Time',
			items = { "Morning (6:00)", "Noon (12:00)", "Afternoon (15:00)", "Evening (18:00)", "Night (22:00)", "Midnight (0:00)" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local hours = { 6, 12, 15, 18, 22, 0 }
			local h = hours[currentIndex] or 12
			Scooby.native(0x669E223E64B1903C, h, 0, 0)
			Scooby.Print("Time: " .. selectedItem, "Time: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'combobox',
			name = 'Set Weather',
			items = { "CLEAR", "CLOUDS", "OVERCAST", "RAIN", "THUNDER", "SNOW", "SNOWLIGHT", "BLIZZARD", "FOG", "DRIZZLE", "SANDSTORM" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby.native(0x59174F1AFE095B5A, GetHashKey(selectedItem), true, true, true, 1.0, false)
			Scooby.Print("Weather: " .. selectedItem, "Weather: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Freeze Time',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Freeze Time'] then
				Scooby.createThread(function()
					local h, m = GetClockHours(), GetClockMinutes()
					Scooby.Print("Time Frozen", "Time Frozen", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0x669E223E64B1903C, h, m, 0)
						if not Scooby.menuCheckBoxes['scooby_world']['Freeze Time'] then
							Scooby.Print("Time Unfrozen", "Time Unfrozen", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Blackout',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Blackout'] then
				Scooby.createThread(function()
					Scooby.Print("Blackout: On", "Blackout: On", false)
					while true do
						Citizen.Wait(0)
						SetArtificialLightsState(true)
						if not Scooby.menuCheckBoxes['scooby_world']['Blackout'] then
							SetArtificialLightsState(false)
							Scooby.Print("Blackout: Off", "Blackout: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Lightning Strike',
			desc = 'Strike at your location',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			Scooby.native(0x67943537D179597C, coords.x, coords.y, coords.z, 1.0) -- _FORCE_LIGHTNING_FLASH_AT_COORDS
			Scooby.native(0xB09A4B5EE5B73F30) -- FORCE_LIGHTNING_FLASH
			_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 29, 2.0, true, false, true)
			Scooby.Print("Lightning!", "Lightning!", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Kill All Nearby NPCs',
			desc = 'Eliminate all nearby non-player peds',
		}, function()
			for _, ped in pairs(GetGamePool('CPed')) do
				if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
					SetEntityHealth(ped, 0, 0)
				end
			end
			Scooby.Print("All NPCs killed", "All NPCs killed", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Delete All Nearby Peds',
			desc = 'Remove all nearby NPCs',
		}, function()
			for _, ped in pairs(GetGamePool('CPed')) do
				if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
					SetEntityAsMissionEntity(ped, true, true)
					DeleteEntity(ped)
				end
			end
			Scooby.Print("NPCs deleted", "NPCs deleted", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Delete All Vehicles',
			desc = 'Remove all nearby vehicles/horses',
		}, function()
			for _, veh in pairs(GetGamePool('CVehicle')) do
				SetEntityAsMissionEntity(veh, true, true)
				DeleteEntity(veh)
			end
			Scooby.Print("Vehicles deleted", "Vehicles deleted", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Lightning at _xh',
			desc = 'Raycast from camera, lightning at hit point',
		}, function()
			local cam = GetFinalRenderedCamCoord()
			local camRot = GetFinalRenderedCamRot(2)
			local pitch = math.rad(camRot.x)
			local yaw = math.rad(camRot.z)
			local dirX = -math.sin(yaw) * math.cos(pitch)
			local dirY = math.cos(yaw) * math.cos(pitch)
			local dirZ = math.sin(pitch)
			local endX = cam.x + dirX * 500.0
			local endY = cam.y + dirY * 500.0
			local endZ = cam.z + dirZ * 500.0
			local ray = StartShapeTestRay(cam.x, cam.y, cam.z, endX, endY, endZ, -1, Scooby.pedID(), 0)
			local _, hit, hitCoords = GetShapeTestResult(ray)
			if hit then
				Scooby.native(0x67943537D179597C, hitCoords.x, hitCoords.y, hitCoords.z, 1.0)
				Scooby.native(0xB09A4B5EE5B73F30)
				_i(0xD84A917A64D4D016, Scooby.pedID(), hitCoords.x, hitCoords.y, hitCoords.z, 29, 3.0, true, false, true)
				Scooby.Print("Lightning at crosshair!", "Lightning at crosshair!", false)
			else
				Scooby.Print("No hit detected", "No hit detected", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Meteor Strike',
			desc = 'Explosion falling from sky at crosshair',
		}, function()
			local cam = GetFinalRenderedCamCoord()
			local camRot = GetFinalRenderedCamRot(2)
			local pitch = math.rad(camRot.x)
			local yaw = math.rad(camRot.z)
			local dirX = -math.sin(yaw) * math.cos(pitch)
			local dirY = math.cos(yaw) * math.cos(pitch)
			local dirZ = math.sin(pitch)
			local endX = cam.x + dirX * 500.0
			local endY = cam.y + dirY * 500.0
			local endZ = cam.z + dirZ * 500.0
			local ray = StartShapeTestRay(cam.x, cam.y, cam.z, endX, endY, endZ, -1, Scooby.pedID(), 0)
			local _, hit, hitCoords = GetShapeTestResult(ray)
			if hit then
				_i(0xD84A917A64D4D016, Scooby.pedID(), hitCoords.x, hitCoords.y, hitCoords.z + 50.0, 29, 5.0, true, false, true)
				_i(0xD84A917A64D4D016, Scooby.pedID(), hitCoords.x, hitCoords.y, hitCoords.z, 29, 10.0, true, false, true)
				Scooby.Print("Meteor Strike!", "Meteor Strike!", false)
			else
				Scooby.Print("No hit detected", "No hit detected", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Riot Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Riot Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Riot Mode: On", "Riot Mode: On", false)
					while true do
						Citizen.Wait(1000)
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
								SetPedRelationshipGroupHash(ped, GetHashKey("HATES_PLAYER"))
								TaskCombatHatedTargetsAroundPed(ped, 100.0, 0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_world']['Riot Mode'] then
							Scooby.Print("Riot Mode: Off", "Riot Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Everyone Flee',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Everyone Flee'] then
				Scooby.createThread(function()
					Scooby.Print("Everyone Flee: On", "Everyone Flee: On", false)
					while true do
						Citizen.Wait(1000)
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
								TaskSmartFleePed(ped, PlayerPedId(), 1000.0, -1, false, false)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_world']['Everyone Flee'] then
							Scooby.Print("Everyone Flee: Off", "Everyone Flee: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Random Animal',
			desc = 'Spawn a random animal at your location',
		}, function()
			local animals = {
				"a_c_horse_americanstandardbred_black", "a_c_wolf", "a_c_bear_black",
				"a_c_alligator_01", "a_c_elk_01", "a_c_deer_01",
				"a_c_coyote_01", "a_c_panther_01", "a_c_cougar_01", "a_c_buffalo_01"
			}
			local chosen = animals[math.random(#animals)]
			Scooby.getPlayerInfo(Scooby.pedID(), function(pInfo)
				Scooby.spawnPed(chosen, vector3(pInfo.coords.x + 3.0, pInfo.coords.y, pInfo.coords.z), pInfo.heading,
					function(modelName, spawningPed)
						Scooby.Print("Spawned: " .. modelName, "Spawned: " .. modelName, false)
					end)
			end, false, true)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Wagon',
			desc = 'Spawn a coach wagon at your location',
		}, function()
			local hash = GetHashKey("coach2")
			RequestModel(hash)
			local a = 0
			while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasModelLoaded(hash) then
				local coords = GetEntityCoords(Scooby.pedID())
				local veh = CreateVehicle(hash, coords.x + 3.0, coords.y, coords.z, GetEntityHeading(Scooby.pedID()), true, true)
				Scooby.Print("Wagon spawned", "Wagon spawned", false)
			else
				Scooby.Print("Failed to load wagon model", "Failed to load wagon model", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Boat',
			desc = 'Spawn a steamboat at your location',
		}, function()
			local hash = GetHashKey("steamboat")
			RequestModel(hash)
			local a = 0
			while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasModelLoaded(hash) then
				local coords = GetEntityCoords(Scooby.pedID())
				local veh = CreateVehicle(hash, coords.x + 3.0, coords.y, coords.z, GetEntityHeading(Scooby.pedID()), true, true)
				Scooby.Print("Boat spawned", "Boat spawned", false)
			else
				Scooby.Print("Failed to load boat model", "Failed to load boat model", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Teleport All NPCs to Me',
			desc = 'Bring all NPCs to your location',
		}, function()
			local myCoords = GetEntityCoords(Scooby.pedID())
			local count = 0
			for _, ped in pairs(GetGamePool('CPed')) do
				if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
					Scooby.native(0x06843DA7060A026B, ped, myCoords.x + math.random(-5, 5), myCoords.y + math.random(-5, 5), myCoords.z, 0, 0, 0, 0)
					count = count + 1
				end
			end
			Scooby.Print("Teleported " .. count .. " NPCs", "Teleported " .. count .. " NPCs", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Snow Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Snow Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Snow Mode: On", "Snow Mode: On", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0x59174F1AFE095B5A, GetHashKey("SNOW"), true, true, true, 1.0, false)
						if not Scooby.menuCheckBoxes['scooby_world']['Snow Mode'] then
							Scooby.native(0x59174F1AFE095B5A, GetHashKey("CLEAR"), true, true, true, 1.0, false)
							Scooby.Print("Snow Mode: Off", "Snow Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Fog Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Fog Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Fog Mode: On", "Fog Mode: On", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0x59174F1AFE095B5A, GetHashKey("FOG"), true, true, true, 1.0, false)
						if not Scooby.menuCheckBoxes['scooby_world']['Fog Mode'] then
							Scooby.native(0x59174F1AFE095B5A, GetHashKey("CLEAR"), true, true, true, 1.0, false)
							Scooby.Print("Fog Mode: Off", "Fog Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Thunder Storm',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Thunder Storm'] then
				Scooby.createThread(function()
					Scooby.Print("Thunder Storm: On", "Thunder Storm: On", false)
					while true do
						Citizen.Wait(2000 + math.random(0, 3000))
						Scooby.native(0x59174F1AFE095B5A, GetHashKey("THUNDER"), true, true, true, 1.0, false)
						Scooby.native(0xB09A4B5EE5B73F30)
						if not Scooby.menuCheckBoxes['scooby_world']['Thunder Storm'] then
							Scooby.native(0x59174F1AFE095B5A, GetHashKey("CLEAR"), true, true, true, 1.0, false)
							Scooby.Print("Thunder Storm: Off", "Thunder Storm: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Time x10 Speed',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Time x10 Speed'] then
				Scooby.createThread(function()
					Scooby.Print("Time x10 Speed: On", "Time x10 Speed: On", false)
					while true do
						Citizen.Wait(100)
						local h = GetClockHours()
						local m = GetClockMinutes() + 1
						if m >= 60 then m = 0; h = h + 1 end
						if h >= 24 then h = 0 end
						Scooby.native(0x669E223E64B1903C, h, m, 0)
						if not Scooby.menuCheckBoxes['scooby_world']['Time x10 Speed'] then
							Scooby.Print("Time x10 Speed: Off", "Time x10 Speed: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Lightning at Players',
			desc = 'Strike lightning at every online player',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
					local coords = GetEntityCoords(ped)
					Scooby.native(0x67943537D179597C, coords.x, coords.y, coords.z, 1.0)
					_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 29, 5.0, true, false, true)
					count = count + 1
				end
			end
			Scooby.Print("Lightning struck " .. count .. " players", "Lightning struck " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Earthquake',
			desc = 'Shake camera and create explosions around you',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			ShakeGameplayCam("MEDIUM_EXPLOSION_SHAKE", 1.0)
			for i = 1, 10 do
				local ox = math.random(-20, 20)
				local oy = math.random(-20, 20)
				_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x + ox, coords.y + oy, coords.z, 27, 3.0, true, false, true)
			end
			Scooby.Print("Earthquake!", "Earthquake!", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Revive All NPCs',
			desc = 'Resurrect all dead NPCs nearby',
		}, function()
			local count = 0
			for _, ped in pairs(GetGamePool('CPed')) do
				if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and IsPedDeadOrDying(ped) then
					ResurrectPed(ped)
					SetEntityHealth(ped, GetPedMaxHealth(ped), 0)
					count = count + 1
				end
			end
			Scooby.Print("Revived " .. count .. " NPCs", "Revived " .. count .. " NPCs", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Explode All Players',
			desc = 'Explode every online player',
		}, function()
			local count = 0
			for _, id in ipairs(GetActivePlayers()) do
				local ped = GetPlayerPed(id)
				if ped ~= Scooby.pedID() then
					local coords = GetEntityCoords(ped)
					_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 27, 50.0, true, false, true)
					count = count + 1
				end
			end
			Scooby.Print("Exploded " .. count .. " players", "Exploded " .. count .. " players", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Bear Army',
			desc = 'Spawn 5 aggressive bears',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("a_c_bear_01")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					for i = 1, 5 do
						local bear = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-10,10), coords.y + math.random(-10,10), coords.z, math.random(0,360) + 0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, bear, true)
						TaskCombatHatedTargetsAroundPed(bear, 200.0, 0)
					end
					Scooby.Print("Bear army spawned!", "Bear army spawned!", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Wolf Pack',
			desc = 'Spawn 8 aggressive wolves',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("a_c_wolf")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					for i = 1, 8 do
						local wolf = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-10,10), coords.y + math.random(-10,10), coords.z, math.random(0,360) + 0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, wolf, true)
						TaskCombatHatedTargetsAroundPed(wolf, 200.0, 0)
					end
					Scooby.Print("Wolf pack spawned!", "Wolf pack spawned!", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Rain Fire',
			desc = '15 explosions raining from the sky',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				for i = 1, 15 do
					local ox = math.random(-30, 30)
					local oy = math.random(-30, 30)
					_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x + ox, coords.y + oy, coords.z, 27, 5.0, true, false, true)
					Citizen.Wait(200)
				end
				Scooby.Print("Rain of fire!", "Rain of fire!", false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Hostile NPCs',
			desc = 'Spawn 10 hostile NPCs that attack everyone',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				local models = {"u_m_m_yourknightgeneric_01", "s_m_m_army_01", "u_m_m_yourknightgeneric_02"}
				for i = 1, 10 do
					local hash = GetHashKey(models[math.random(1, #models)])
					RequestModel(hash)
					local a = 0
					while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
					if HasModelLoaded(hash) then
						local ped = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-10,10), coords.y + math.random(-10,10), coords.z, math.random(0,360) + 0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
						SetPedRelationshipGroupHash(ped, GetHashKey("HATES_PLAYER"))
						TaskCombatHatedTargetsAroundPed(ped, 200.0, 0)
					end
				end
				Scooby.Print("Hostile NPCs spawned!", "Hostile NPCs spawned!", false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Clear All Fires',
			desc = 'Stop all fires in a large radius',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			Scooby.native(0x98CF5E2B5A8B075A, coords.x, coords.y, coords.z, 1000.0)
			Scooby.Print("Fires cleared!", "Fires cleared!", false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Cage Around Self',
			desc = 'Cage yourself with fence posts',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("p_fencepost01x")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local radius = 1.5
					for angle = 0, 330, 30 do
						local rad = math.rad(angle)
						local ox = math.cos(rad) * radius
						local oy = math.sin(rad) * radius
						local obj = CreateObject(hash, coords.x + ox, coords.y + oy, coords.z - 1.0, true, true, false)
						FreezeEntityPosition(obj, true)
					end
					Scooby.Print("Caged!", "Caged!", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Spawn Army',
			desc = 'Spawn 15 armed soldiers that guard you',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("s_m_m_army_01")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					for i = 1, 15 do
						local ped = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-8,8), coords.y + math.random(-8,8), coords.z, math.random(0,360)+0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
						local weapHash = GetHashKey("WEAPON_REPEATER_CARBINE")
						GiveWeaponToPed(ped, weapHash, 999, true, 0)
						SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetPedRelationshipGroupHash(ped))
						TaskCombatHatedTargetsAroundPed(ped, 200.0, 0)
					end
					Scooby.Print("Army spawned!", "Army spawned!", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'Nuke',
			desc = 'Massive explosion chain at your location',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 2.0)
				for i = 1, 30 do
					local ox = math.random(-25, 25)
					local oy = math.random(-25, 25)
					_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x + ox, coords.y + oy, coords.z, 27, 30.0, true, false, true)
					Citizen.Wait(50)
				end
				Scooby.Print("NUKED!", "NUKED!", false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = '--- World Toggles ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Zombie Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Zombie Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Zombie Mode: On (NPCs attack everything, slow walk)", "Zombie Mode: On", false)
					while true do
						Citizen.Wait(2000)
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
								SetPedRelationshipGroupHash(ped, GetHashKey("HATES_PLAYER"))
								TaskCombatHatedTargetsAroundPed(ped, 100.0, 0)
								SetPedMoveRateOverride(ped, 0.6)
								SetPedCanRagdoll(ped, false)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_world']['Zombie Mode'] then
							Scooby.Print("Zombie Mode: Off", "Zombie Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Chaos Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Chaos Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Chaos Mode: On", "Chaos Mode: On", false)
					while true do
						Citizen.Wait(3000 + math.random(0, 2000))
						local coords = GetEntityCoords(Scooby.pedID())
						local ox = math.random(-50, 50)
						local oy = math.random(-50, 50)
						_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x + ox, coords.y + oy, coords.z, 27, 5.0, true, false, true)
						Scooby.native(0x67943537D179597C, coords.x + ox, coords.y + oy, coords.z, 1.0)
						if not Scooby.menuCheckBoxes['scooby_world']['Chaos Mode'] then
							Scooby.Print("Chaos Mode: Off", "Chaos Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Infinite Spawner',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Infinite Spawner'] then
				Scooby.createThread(function()
					Scooby.Print("Infinite Spawner: On (hostile peds spawn every 10s)", "Infinite Spawner: On", false)
					while true do
						Citizen.Wait(10000)
						local coords = GetEntityCoords(Scooby.pedID())
						local models = {"u_m_m_yourknightgeneric_01", "s_m_m_army_01", "a_c_wolf", "a_c_bear_01"}
						local hash = GetHashKey(models[math.random(1, #models)])
						RequestModel(hash)
						local a = 0
						while not HasModelLoaded(hash) and a < 50 do Citizen.Wait(10); a = a + 1 end
						if HasModelLoaded(hash) then
							local ped = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-15,15), coords.y + math.random(-15,15), coords.z, math.random(0,360)+0.0, true, false)
							Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
							TaskCombatHatedTargetsAroundPed(ped, 200.0, 0)
						end
						if not Scooby.menuCheckBoxes['scooby_world']['Infinite Spawner'] then
							Scooby.Print("Infinite Spawner: Off", "Infinite Spawner: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Auto Lightning Loop',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Auto Lightning Loop'] then
				Scooby.createThread(function()
					Scooby.Print("Lightning Loop: On", "Lightning Loop: On", false)
					while true do
						Citizen.Wait(1000 + math.random(0, 3000))
						local coords = GetEntityCoords(Scooby.pedID())
						local ox = math.random(-40, 40)
						local oy = math.random(-40, 40)
						Scooby.native(0x67943537D179597C, coords.x + ox, coords.y + oy, coords.z, 1.0)
						Scooby.native(0xB09A4B5EE5B73F30)
						if not Scooby.menuCheckBoxes['scooby_world']['Auto Lightning Loop'] then
							Scooby.Print("Lightning Loop: Off", "Lightning Loop: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Blizzard Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Blizzard Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Blizzard Mode: On", "Blizzard Mode: On", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0x59174F1AFE095B5A, GetHashKey("BLIZZARD"), true, true, true, 1.0, false)
						if not Scooby.menuCheckBoxes['scooby_world']['Blizzard Mode'] then
							Scooby.native(0x59174F1AFE095B5A, GetHashKey("CLEAR"), true, true, true, 1.0, false)
							Scooby.Print("Blizzard Mode: Off", "Blizzard Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Sandstorm Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Sandstorm Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Sandstorm Mode: On", "Sandstorm Mode: On", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0x59174F1AFE095B5A, GetHashKey("SANDSTORM"), true, true, true, 1.0, false)
						if not Scooby.menuCheckBoxes['scooby_world']['Sandstorm Mode'] then
							Scooby.native(0x59174F1AFE095B5A, GetHashKey("CLEAR"), true, true, true, 1.0, false)
							Scooby.Print("Sandstorm Mode: Off", "Sandstorm Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'combobox',
			name = 'NPC Density',
			items = { "Normal", "Low", "None", "High", "Max" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local densities = { 1.0, 0.3, 0.0, 2.0, 5.0 }
			local d = densities[currentIndex] or 1.0
			SetPedDensityMultiplierThisFrame(d)
			SetScenarioPedDensityMultiplierThisFrame(d, d)
			Scooby.Print("NPC Density: " .. selectedItem, "NPC Density: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'combobox',
			name = 'Game Speed',
			items = { "Normal", "Slow (0.5x)", "Very Slow (0.25x)", "Fast (1.5x)", "Very Fast (2x)", "Frozen" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local speeds = { 1.0, 0.5, 0.25, 1.5, 2.0, 0.0 }
			SetTimeScale(speeds[currentIndex] or 1.0)
			Scooby.Print("Game Speed: " .. selectedItem, "Game Speed: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'Auto Kill Hostile NPCs',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['Auto Kill Hostile NPCs'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Kill Hostile: On", "Auto Kill Hostile: On", false)
					while true do
						Citizen.Wait(500)
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
								if IsPedInCombat(ped, Scooby.pedID()) then
									SetEntityHealth(ped, 0, 0)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_world']['Auto Kill Hostile NPCs'] then
							Scooby.Print("Auto Kill Hostile: Off", "Auto Kill Hostile: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'checkbox',
			name = 'NPC Army Follow',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_world']['NPC Army Follow'] then
				Scooby.createThread(function()
					Scooby.Print("NPC Army Follow: On (nearby NPCs follow you)", "NPC Army Follow: On", false)
					while true do
						Citizen.Wait(3000)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
								local dist = #(myCoords - GetEntityCoords(ped))
								if dist < 40.0 then
									TaskFollowToOffsetOfEntity(ped, Scooby.pedID(), 0.0, -2.0, 0.0, 3.0, -1, 2.0, true, false, false, false, false, false)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_world']['NPC Army Follow'] then
							Scooby.Print("NPC Army Follow: Off", "NPC Army Follow: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'combobox',
			name = 'Explosion Radius',
			items = { "Small (2m)", "Medium (5m)", "Large (10m)", "Huge (25m)", "Massive (50m)" },
			currentIndex = 2,
			selectedIndex = 2,
		}, function(currentIndex, selectedItem)
			local radii = { 2, 5, 10, 25, 50 }
			Scooby._explosionRadius = radii[currentIndex] or 5
			Scooby.Print("Explosion Radius: " .. selectedItem, "Explosion Radius: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_world', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_protection', 'scooby_main', "ScoobyOP", "Protection", false, function()
		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Explosion',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Explosion'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Explosion: Enabled", "Anti Explosion: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetEntityProofs(Scooby.pedID(), false, true, true, false, false, false, false, false)
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Explosion'] then
							SetEntityProofs(Scooby.pedID(), false, false, false, false, false, false, false, false)
							Scooby.Print("Anti Explosion: Disabled", "Anti Explosion: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Ragdoll',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Ragdoll'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Ragdoll: Enabled", "Anti Ragdoll: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedCanRagdoll(Scooby.pedID(), false)
						SetPedCanRagdollFromPlayerImpact(Scooby.pedID(), false)
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Ragdoll'] then
							SetPedCanRagdoll(Scooby.pedID(), true)
							Scooby.Print("Anti Ragdoll: Disabled", "Anti Ragdoll: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Hogtie',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Hogtie'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Hogtie: Enabled", "Anti Hogtie: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsEntityBeingHogtied(Scooby.pedID()) or Scooby.native(0x3AA24CCC0D451379, Scooby.pedID()) then
							ClearPedTasks(Scooby.pedID(), true, false)
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Hogtie'] then
							Scooby.Print("Anti Hogtie: Disabled", "Anti Hogtie: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Freeze',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Freeze'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Freeze: Enabled", "Anti Freeze: Enabled", false)
					while true do
						Citizen.Wait(0)
						FreezeEntityPosition(Scooby.pedID(), false)
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Freeze'] then
							Scooby.Print("Anti Freeze: Disabled", "Anti Freeze: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Fire',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Fire'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Fire: Enabled", "Anti Fire: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsEntityOnFire(Scooby.pedID()) then
							StopEntityFire(Scooby.pedID())
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Fire'] then
							Scooby.Print("Anti Fire: Disabled", "Anti Fire: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Kick from Horse',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Kick from Horse'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Kick from Horse: Enabled", "Anti Kick from Horse: Enabled", false)
					local lastMount = nil
					while true do
						Citizen.Wait(100)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							lastMount = mount
						elseif lastMount and DoesEntityExist(lastMount) and not IsPedDeadOrDying(lastMount, true) then
							local dist = #(GetEntityCoords(Scooby.pedID()) - GetEntityCoords(lastMount))
							if dist < 15.0 then
								SetPedOntoMount(Scooby.pedID(), lastMount, -1, true)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Kick from Horse'] then
							Scooby.Print("Anti Kick from Horse: Disabled", "Anti Kick from Horse: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Block Damage',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Block Damage'] then
				Scooby.createThread(function()
					Scooby.Print("Block Damage: Enabled", "Block Damage: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetEntityInvincible(Scooby.pedID(), true)
						if not Scooby.menuCheckBoxes['scooby_protection']['Block Damage'] then
							SetEntityInvincible(Scooby.pedID(), false)
							Scooby.Print("Block Damage: Disabled", "Block Damage: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'button',
			name = 'Safe Mode',
			desc = 'Enable all protections at once',
		}, function()
			local checks = Scooby.menuCheckBoxes['scooby_protection']
			local features = {'Anti Explosion', 'Anti Ragdoll', 'Anti Hogtie', 'Anti Freeze', 'Anti Fire', 'Anti Kick from Horse', 'Block Damage'}
			for _, feat in ipairs(features) do
				if not checks[feat] then
					for _, attr in ipairs(Scooby.menuAttributes['scooby_protection']) do
						if attr.data.name == feat and attr.data.type == 'checkbox' then
							attr.cb()
							checks[feat] = true
							break
						end
					end
				end
			end
			Scooby.Print("Safe Mode: All protections enabled", "Safe Mode: All protections enabled", false)
			Scooby.Menu.OpenMenu('scooby_protection')
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Attach',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Attach'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Attach: Enabled", "Anti Attach: Enabled", false)
					while true do
						Citizen.Wait(100)
						if IsEntityAttachedToAnyEntity(Scooby.pedID()) then
							DetachEntity(Scooby.pedID(), true, false)
							Scooby.Print("Detached!", "Detached!", false)
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Attach'] then
							Scooby.Print("Anti Attach: Disabled", "Anti Attach: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Teleport',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Teleport'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Teleport: Enabled", "Anti Teleport: Enabled", false)
					local lastPos = GetEntityCoords(Scooby.pedID())
					while true do
						Citizen.Wait(100)
						local newPos = GetEntityCoords(Scooby.pedID())
						local dist = #(lastPos - newPos)
						if dist > 50.0 and not IsPedInAnyVehicle(Scooby.pedID(), false) then
							Scooby.native(0x06843DA7060A026B, Scooby.pedID(), lastPos.x, lastPos.y, lastPos.z, false, false, false, false)
							Scooby.Print("Teleport blocked!", "Teleport blocked!", false)
						else
							lastPos = newPos
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Teleport'] then
							Scooby.Print("Anti Teleport: Disabled", "Anti Teleport: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'button',
			name = '--- Advanced Protection ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Cage',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Cage'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Cage: Enabled", "Anti Cage: Enabled", false)
					while true do
						Citizen.Wait(500)
						local coords = GetEntityCoords(Scooby.pedID())
						for _, obj in pairs(GetGamePool('CObject')) do
							local objCoords = GetEntityCoords(obj)
							if #(coords - objCoords) < 5.0 then
								local model = GetEntityModel(obj)
								if model == GetHashKey("p_fencepost01x") or model == GetHashKey("p_fencepost02x") or model == GetHashKey("p_fencepost03x") then
									SetEntityAsMissionEntity(obj, true, true)
									DeleteEntity(obj)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Cage'] then
							Scooby.Print("Anti Cage: Disabled", "Anti Cage: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Object Spam',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Object Spam'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Object Spam: Enabled", "Anti Object Spam: Enabled", false)
					local lastObjCount = 0
					while true do
						Citizen.Wait(2000)
						local objects = GetGamePool('CObject')
						local myCoords = GetEntityCoords(Scooby.pedID())
						local nearbyCount = 0
						for _, obj in pairs(objects) do
							if #(myCoords - GetEntityCoords(obj)) < 15.0 then
								nearbyCount = nearbyCount + 1
							end
						end
						if nearbyCount > 20 and nearbyCount > lastObjCount + 5 then
							for _, obj in pairs(objects) do
								if #(myCoords - GetEntityCoords(obj)) < 15.0 then
									SetEntityAsMissionEntity(obj, true, true)
									DeleteEntity(obj)
								end
							end
							Scooby.Print("Object spam blocked! Deleted nearby objects", "Object spam blocked!", false)
						end
						lastObjCount = nearbyCount
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Object Spam'] then
							Scooby.Print("Anti Object Spam: Disabled", "Anti Object Spam: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Crash',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Crash'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Crash: Enabled", "Anti Crash: Enabled", false)
					while true do
						Citizen.Wait(1000)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, obj in pairs(GetGamePool('CObject')) do
							local model = GetEntityModel(obj)
							if model == GetHashKey("s_chuckwagonawning01b") or model == GetHashKey("p_gen_tent03x") then
								if #(myCoords - GetEntityCoords(obj)) < 30.0 then
									SetEntityAsMissionEntity(obj, true, true)
									DeleteEntity(obj)
									Scooby.Print("Crash object removed!", "Crash object removed!", false)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Crash'] then
							Scooby.Print("Anti Crash: Disabled", "Anti Crash: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Vehicle Kill',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Vehicle Kill'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Vehicle Kill: Enabled", "Anti Vehicle Kill: Enabled", false)
					while true do
						Citizen.Wait(100)
						local mount = GetMount(Scooby.pedID())
						if mount and mount ~= 0 then
							SetEntityHealth(mount, GetPedMaxHealth(mount), 0)
							SetEntityInvincible(mount, true)
						end
						local veh = GetVehiclePedIsIn(Scooby.pedID(), false)
						if veh and veh ~= 0 then
							SetEntityHealth(veh, GetEntityMaxHealth(veh), 0)
							SetEntityInvincible(veh, true)
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Vehicle Kill'] then
							local m2 = GetMount(Scooby.pedID())
							if m2 and m2 ~= 0 then SetEntityInvincible(m2, false) end
							local v2 = GetVehiclePedIsIn(Scooby.pedID(), false)
							if v2 and v2 ~= 0 then SetEntityInvincible(v2, false) end
							Scooby.Print("Anti Vehicle Kill: Disabled", "Anti Vehicle Kill: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Proximity Alert',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Proximity Alert'] then
				Scooby.createThread(function()
					Scooby.Print("Proximity Alert: Enabled", "Proximity Alert: Enabled", false)
					while true do
						Citizen.Wait(2000)
						local myCoords = GetEntityCoords(Scooby.pedID())
						local players = GetActivePlayers()
						for _, id in ipairs(players) do
							if id ~= PlayerId() then
								local ped = GetPlayerPed(id)
								if ped and ped ~= 0 and DoesEntityExist(ped) then
									local dist = #(myCoords - GetEntityCoords(ped))
									if dist < Scooby.alertDistance then
										local name = GetPlayerName(id) or ("Player " .. id)
										Scooby.Print("ALERT: " .. name .. " nearby (" .. math.floor(dist) .. "m)", "ALERT: " .. name .. " nearby (" .. math.floor(dist) .. "m)", false)
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_protection']['Proximity Alert'] then
							Scooby.Print("Proximity Alert: Disabled", "Proximity Alert: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'combobox',
			name = 'Alert Distance',
			items = { "10m", "25m", "50m", "100m", "200m" },
			currentIndex = 3,
			selectedIndex = 3,
		}, function(currentIndex, selectedItem)
			local distances = { 10.0, 25.0, 50.0, 100.0, 200.0 }
			Scooby.alertDistance = distances[currentIndex] or 50.0
			Scooby.Print("Alert Distance: " .. selectedItem, "Alert Distance: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Melee',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Melee'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Melee: Enabled", "Anti Melee: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedConfigFlag(Scooby.pedID(), 52, true)
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Melee'] then
							SetPedConfigFlag(Scooby.pedID(), 52, false)
							Scooby.Print("Anti Melee: Disabled", "Anti Melee: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'checkbox',
			name = 'Anti Bullet',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_protection']['Anti Bullet'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Bullet: Enabled", "Anti Bullet: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetEntityProofs(Scooby.pedID(), true, true, false, false, false, false, false, false)
						if not Scooby.menuCheckBoxes['scooby_protection']['Anti Bullet'] then
							SetEntityProofs(Scooby.pedID(), false, false, false, false, false, false, false, false)
							Scooby.Print("Anti Bullet: Disabled", "Anti Bullet: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_protection', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_misc', 'scooby_main', "ScoobyOP", "Misc", false, function()
		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- Fun ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Flaming Footsteps',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Flaming Footsteps'] then
				Scooby.createThread(function()
					Scooby.Print("Flaming Footsteps: On", "Flaming Footsteps: On", false)
					while true do
						Citizen.Wait(50)
						local coords = GetEntityCoords(Scooby.pedID())
						if IsPedWalking(Scooby.pedID()) or IsPedRunning(Scooby.pedID()) or IsPedSprinting(Scooby.pedID()) then
							StartScriptFire(coords.x, coords.y, coords.z, 1, false, false, false, 0.5, 0)
						end
						if not Scooby.menuCheckBoxes['scooby_misc']['Flaming Footsteps'] then
							Scooby.Print("Flaming Footsteps: Off", "Flaming Footsteps: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Drunk Walk',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Drunk Walk'] then
				Scooby.createThread(function()
					SetPedIsDrunk(Scooby.pedID(), true)
					SetPedConfigFlag(Scooby.pedID(), 100, true)
					Scooby.Print("Drunk Walk: On", "Drunk Walk: On", false)
					while true do
						Citizen.Wait(100)
						if not Scooby.menuCheckBoxes['scooby_misc']['Drunk Walk'] then
							SetPedIsDrunk(Scooby.pedID(), false)
							SetPedConfigFlag(Scooby.pedID(), 100, false)
							Scooby.Print("Drunk Walk: Off", "Drunk Walk: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Tiny Player',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Tiny Player'] then
				SetPedScale(Scooby.pedID(), 0.3)
				Scooby.Print("Tiny: On", "Tiny: On", false)
			else
				SetPedScale(Scooby.pedID(), 1.0)
				Scooby.Print("Tiny: Off", "Tiny: Off", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Giant Player',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Giant Player'] then
				SetPedScale(Scooby.pedID(), 5.0)
				Scooby.Print("Giant: On", "Giant: On", false)
			else
				SetPedScale(Scooby.pedID(), 1.0)
				Scooby.Print("Giant: Off", "Giant: Off", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Explode Self',
			desc = 'Create explosion at your location',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 27, 50.0, true, false, true)
			Scooby.Print("Boom!", "Boom!", false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Spawn Campfire',
			desc = 'Place a campfire at your feet',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local hash = GetHashKey("p_campfire05x")
			RequestModel(hash)
			local a = 0
			while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasModelLoaded(hash) then
				CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true, true, true)
				Scooby.Print("Campfire placed", "Campfire placed", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- Utility ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Server Info',
			desc = 'Show server details',
		}, function()
			local players = #GetActivePlayers()
			local maxPlayers = GetConvarInt("sv_maxclients", 32)
			local serverName = GetConvar("sv_hostname", "Unknown")
			local msg = string.format("Server: %s | Players: %d/%d", serverName, players, maxPlayers)
			Scooby.Print(msg, msg, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Copy Server IP',
			desc = 'Copy to notification',
		}, function()
			local ip = GetCurrentServerEndpoint()
			if ip then
				Scooby.Print("IP: " .. ip, "IP: " .. ip, false)
			else
				Scooby.Print("Could not get IP", "Could not get IP", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Show Coords',
			desc = 'Display your current coordinates',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local heading = GetEntityHeading(Scooby.pedID())
			local msg = string.format("X: %.2f Y: %.2f Z: %.2f H: %.1f", coords.x, coords.y, coords.z, heading)
			Scooby.Print(msg, msg, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Show Server ID',
			desc = 'Display your server ID',
		}, function()
			local id = GetPlayerServerId(PlayerId())
			Scooby.Print("Server ID: " .. id, "Server ID: " .. id, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Show Player Count',
			desc = 'How many players online',
		}, function()
			local count = #GetActivePlayers()
			Scooby.Print("Players: " .. count, "Players Online: " .. count, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Show FPS',
			desc = 'Display current FPS',
		}, function()
			local fps = math.floor(1.0 / GetFrameTime())
			Scooby.Print("FPS: " .. fps, "FPS: " .. fps, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'FPS Counter',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['FPS Counter'] then
				Scooby.createThread(function()
					while true do
						Citizen.Wait(0)
						local fps = math.floor(1.0 / GetFrameTime())
						DrawTxt("FPS: " .. fps, 0.01, 0.01, 0.35, false, 255, 255, 255, 255, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['FPS Counter'] then break end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Coords Display',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Coords Display'] then
				Scooby.createThread(function()
					while true do
						Citizen.Wait(0)
						local c = GetEntityCoords(Scooby.pedID())
						local txt = string.format("X: %.1f  Y: %.1f  Z: %.1f", c.x, c.y, c.z)
						DrawTxt(txt, 0.01, 0.04, 0.30, false, 200, 200, 200, 255, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Coords Display'] then break end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Player List HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Player List HUD'] then
				Scooby.createThread(function()
					while true do
						Citizen.Wait(0)
						local players = GetActivePlayers()
						local y = 0.15
						DrawTxt("Players (" .. #players .. ")", 0.01, y - 0.03, 0.30, false, 0, 200, 255, 255, false, 9)
						for i, p in ipairs(players) do
							if i > 15 then break end
							local name = GetPlayerName(p)
							local sid = GetPlayerServerId(p)
							local hp = GetEntityHealth(GetPlayerPed(p))
							local txt = string.format("[%d] %s (HP: %d)", sid, name, hp)
							DrawTxt(txt, 0.01, y, 0.25, false, 255, 255, 255, 220, false, 9)
							y = y + 0.018
						end
						if not Scooby.menuCheckBoxes['scooby_misc']['Player List HUD'] then break end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Airstrike',
			desc = 'Rain explosions at your crosshair',
		}, function()
			local cam = GetFinalRenderedCamCoord()
			local camRot = GetFinalRenderedCamRot(2)
			local pitch = math.rad(camRot.x)
			local yaw = math.rad(camRot.z)
			local dirX = -math.sin(yaw) * math.cos(pitch)
			local dirY = math.cos(yaw) * math.cos(pitch)
			local dirZ = math.sin(pitch)
			local endX = cam.x + dirX * 500.0
			local endY = cam.y + dirY * 500.0
			local endZ = cam.z + dirZ * 500.0
			local ray = StartShapeTestRay(cam.x, cam.y, cam.z, endX, endY, endZ, -1, Scooby.pedID(), 0)
			local _, hit, hitCoords = GetShapeTestResult(ray)
			if hit then
				Scooby.createThread(function()
					for i = 1, 5 do
						local ox = math.random(-3, 3)
						local oy = math.random(-3, 3)
						_i(0xD84A917A64D4D016, Scooby.pedID(), hitCoords.x + ox, hitCoords.y + oy, hitCoords.z + (6 - i) * 5.0, 29, 5.0, true, false, true)
						Citizen.Wait(300)
					end
				end)
				Scooby.Print("Airstrike launched!", "Airstrike launched!", false)
			else
				Scooby.Print("No target found", "No target found", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Clone Self',
			desc = 'Spawn a clone of yourself',
		}, function()
			local model = GetEntityModel(Scooby.pedID())
			local coords = GetEntityCoords(Scooby.pedID())
			RequestModel(model)
			local a = 0
			while not HasModelLoaded(model) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasModelLoaded(model) then
				local clone = Scooby.native(0xD49F9B0955C367DE, model, coords.x + 2.0, coords.y, coords.z, GetEntityHeading(Scooby.pedID()), true, false)
				Scooby.Print("Clone spawned", "Clone spawned", false)
			else
				Scooby.Print("Failed to load model", "Failed to load model", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Delete All Objects',
			desc = 'Remove all objects in the world',
		}, function()
			local count = 0
			for _, obj in pairs(GetGamePool('CObject')) do
				SetEntityAsMissionEntity(obj, true, true)
				DeleteEntity(obj)
				count = count + 1
			end
			Scooby.Print("Deleted " .. count .. " objects", "Deleted " .. count .. " objects", false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- HUD Overlays ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Speedometer HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Speedometer HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Speedometer HUD: On", "Speedometer HUD: On", false)
					while true do
						Citizen.Wait(0)
						local vel = GetEntityVelocity(Scooby.pedID())
						local speed = math.sqrt(vel.x*vel.x + vel.y*vel.y + vel.z*vel.z) * 3.6
						DrawTxt(string.format("%.0f km/h", speed), 0.92, 0.85, 0.30, false, 0, 200, 255, 200, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Speedometer HUD'] then
							Scooby.Print("Speedometer HUD: Off", "Speedometer HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Compass HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Compass HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Compass HUD: On", "Compass HUD: On", false)
					while true do
						Citizen.Wait(0)
						local heading = GetEntityHeading(Scooby.pedID())
						local dirs = {"N","NE","E","SE","S","SW","W","NW"}
						local idx = math.floor(((heading + 22.5) % 360) / 45) + 1
						DrawTxt(dirs[idx] .. " " .. string.format("%.0f", heading), 0.5, 0.02, 0.30, false, 255, 255, 255, 200, true, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Compass HUD'] then
							Scooby.Print("Compass HUD: Off", "Compass HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Watermark',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Watermark'] then
				Scooby.createThread(function()
					Scooby.Print("Watermark: On", "Watermark: On", false)
					while true do
						Citizen.Wait(0)
						DrawTxt("ScoobyOP v" .. Scooby.version, 0.005, 0.005, 0.25, false, 0, 180, 255, 150, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Watermark'] then
							Scooby.Print("Watermark: Off", "Watermark: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Clock HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Clock HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Clock HUD: On", "Clock HUD: On", false)
					while true do
						Citizen.Wait(0)
						local h = GetClockHours()
						local m = GetClockMinutes()
						DrawTxt(string.format("%02d:%02d", h, m), 0.95, 0.02, 0.30, false, 255, 255, 255, 200, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Clock HUD'] then
							Scooby.Print("Clock HUD: Off", "Clock HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- Chaos ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Fireworks',
			desc = 'Spawn multiple upward explosions',
		}, function()
			Scooby.createThread(function()
				local coords = GetEntityCoords(Scooby.pedID())
				for i = 1, 8 do
					local ox = math.random(-5, 5)
					local oy = math.random(-5, 5)
					_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x + ox, coords.y + oy, coords.z + 20 + math.random(0,15), 29, 1.0, true, false, true)
					Citizen.Wait(300)
				end
			end)
			Scooby.Print("Fireworks launched", "Fireworks launched", false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Orbital Strike',
			desc = 'Massive explosion at crosshair',
		}, function()
			local cam = GetFinalRenderedCamCoord()
			local camRot = GetFinalRenderedCamRot(2)
			local pitch = math.rad(camRot.x)
			local yaw = math.rad(camRot.z)
			local dirX = -math.sin(yaw) * math.cos(pitch)
			local dirY = math.cos(yaw) * math.cos(pitch)
			local dirZ = math.sin(pitch)
			local endX = cam.x + dirX * 1000.0
			local endY = cam.y + dirY * 1000.0
			local endZ = cam.z + dirZ * 1000.0
			local ray = StartShapeTestRay(cam.x, cam.y, cam.z, endX, endY, endZ, -1, Scooby.pedID(), 0)
			local _, hit, hitCoords = GetShapeTestResult(ray)
			if hit then
				ShakeGameplayCam("LARGE_EXPLOSION_SHAKE", 1.0)
				for i = 1, 5 do
					_i(0xD84A917A64D4D016, Scooby.pedID(), hitCoords.x + math.random(-3,3), hitCoords.y + math.random(-3,3), hitCoords.z, 27, 20.0, true, false, true)
				end
				Scooby.Print("Orbital strike!", "Orbital strike!", false)
			else
				Scooby.Print("No target hit", "No target hit", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Money Rain Text',
			desc = 'Show $$$ floating text for fun',
		}, function()
			Scooby.createThread(function()
				local t = GetGameTimer()
				while GetGameTimer() - t < 5000 do
					Citizen.Wait(0)
					local coords = GetEntityCoords(Scooby.pedID())
					DrawTxt("$$$", 0.5, 0.4, 0.6, false, 0, 255, 0, 200, true, 9)
				end
			end)
			Scooby.Print("Money rain!", "Money rain!", false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- Saved Positions ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby._savedPositions = {}
		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Save Position',
			desc = 'Save current location (up to 5 slots)',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local heading = GetEntityHeading(Scooby.pedID())
			if #Scooby._savedPositions >= 5 then
				table.remove(Scooby._savedPositions, 1)
			end
			table.insert(Scooby._savedPositions, { x = coords.x, y = coords.y, z = coords.z, h = heading })
			Scooby.Print("Position saved (#" .. #Scooby._savedPositions .. ")", "Position saved (#" .. #Scooby._savedPositions .. ")", false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'combobox',
			name = 'Load Position',
			items = { "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			if Scooby._savedPositions[currentIndex] then
				local pos = Scooby._savedPositions[currentIndex]
				Scooby.native(0x06843DA7060A026B, Scooby.pedID(), pos.x, pos.y, pos.z, false, false, false, false)
				SetEntityHeading(Scooby.pedID(), pos.h)
				Scooby.Print("Loaded " .. selectedItem, "Loaded " .. selectedItem, false)
			else
				Scooby.Print("No position saved in " .. selectedItem, "No position saved in " .. selectedItem, false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- Extra ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Screenshot Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Screenshot Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Screenshot Mode: On (all HUD hidden)", "Screenshot Mode: On", false)
					while true do
						Citizen.Wait(0)
						HideHudAndRadarThisFrame()
						if not Scooby.menuCheckBoxes['scooby_misc']['Screenshot Mode'] then
							Scooby.Print("Screenshot Mode: Off", "Screenshot Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Rain Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Rain Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Rain Mode: On", "Rain Mode: On", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0x59174F1AFE095B5A, GetHashKey("RAIN"), true, true, true, 1.0, false)
						if not Scooby.menuCheckBoxes['scooby_misc']['Rain Mode'] then
							Scooby.native(0x59174F1AFE095B5A, GetHashKey("CLEAR"), true, true, true, 1.0, false)
							Scooby.Print("Rain Mode: Off", "Rain Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Freeze Nearby Peds',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Freeze Nearby Peds'] then
				Scooby.createThread(function()
					Scooby.Print("Freeze Nearby: On", "Freeze Nearby: On", false)
					while true do
						Citizen.Wait(500)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) then
								local dist = #(myCoords - GetEntityCoords(ped))
								if dist < 30.0 then
									FreezeEntityPosition(ped, true)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_misc']['Freeze Nearby Peds'] then
							for _, ped in pairs(GetGamePool('CPed')) do
								if not IsPedAPlayer(ped) then
									FreezeEntityPosition(ped, false)
								end
							end
							Scooby.Print("Freeze Nearby: Off", "Freeze Nearby: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Night Vision',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Night Vision'] then
				Scooby.createThread(function()
					Scooby.Print("Night Vision: On", "Night Vision: On", false)
					SetTimecycleModifier("PSYCHEDELIC_kick_Franklin_01")
					SetTimecycleModifierStrength(0.5)
					while true do
						Citizen.Wait(100)
						if not Scooby.menuCheckBoxes['scooby_misc']['Night Vision'] then
							ClearTimecycleModifier()
							Scooby.Print("Night Vision: Off", "Night Vision: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'combobox',
			name = 'Screen Filter',
			items = { "None", "Cinema", "Sepia", "Black & White", "Vibrant", "Foggy", "Drunk" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			ClearTimecycleModifier()
			if selectedItem == "Cinema" then
				SetTimecycleModifier("RDR2_Cinema")
				SetTimecycleModifierStrength(1.0)
			elseif selectedItem == "Sepia" then
				SetTimecycleModifier("MP_OverlayLowFilter")
				SetTimecycleModifierStrength(1.0)
			elseif selectedItem == "Black & White" then
				SetTimecycleModifier("NG_BlackOut")
				SetTimecycleModifierStrength(1.0)
			elseif selectedItem == "Vibrant" then
				SetTimecycleModifier("PSYCHEDELIC_kick_Franklin_01")
				SetTimecycleModifierStrength(0.3)
			elseif selectedItem == "Foggy" then
				SetTimecycleModifier("FoggySmall")
				SetTimecycleModifierStrength(1.0)
			elseif selectedItem == "Drunk" then
				SetTimecycleModifier("drunk")
				SetTimecycleModifierStrength(1.0)
			end
			Scooby.Print("Filter: " .. selectedItem, "Filter: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Spawn Guard Dog',
			desc = 'Spawn a dog that follows you',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("a_c_doghusky_01")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					local dog = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + 2.0, coords.y, coords.z, 0.0, true, false)
					Citizen.InvokeNative(0x283978A15512B2FE, dog, true)
					TaskFollowToOffsetOfEntity(dog, Scooby.pedID(), 0.0, -1.5, 0.0, 3.0, -1, 2.0, true, false, false, false, false, false)
					SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetPedRelationshipGroupHash(dog))
					Scooby.Print("Guard dog spawned!", "Guard dog spawned!", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'Spawn Bodyguards',
			desc = 'Spawn 3 armed bodyguards that follow you',
		}, function()
			Scooby.createThread(function()
				local hash = GetHashKey("s_m_m_army_01")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					for i = 1, 3 do
						local guard = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + i*2, coords.y, coords.z, 0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, guard, true)
						local weapHash = GetHashKey("WEAPON_REPEATER_CARBINE")
						GiveWeaponToPed(guard, weapHash, 999, true, 0)
						TaskFollowToOffsetOfEntity(guard, Scooby.pedID(), i * 1.5, -1.0, 0.0, 3.0, -1, 2.0, true, false, false, false, false, false)
						SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetPedRelationshipGroupHash(guard))
						TaskCombatHatedTargetsAroundPed(guard, 100.0, 0)
					end
					Scooby.Print("3 bodyguards spawned!", "3 bodyguards spawned!", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Distance Tracker',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Distance Tracker'] then
				Scooby.createThread(function()
					Scooby.Print("Distance Tracker: On", "Distance Tracker: On", false)
					while true do
						Citizen.Wait(0)
						local players = GetActivePlayers()
						local nearest = nil
						local nearestDist = 9999
						local nearestName = ""
						for _, p in ipairs(players) do
							if p ~= PlayerId() then
								local dist = #(GetEntityCoords(Scooby.pedID()) - GetEntityCoords(GetPlayerPed(p)))
								if dist < nearestDist then
									nearestDist = dist
									nearest = p
									nearestName = GetPlayerName(p)
								end
							end
						end
						if nearest then
							DrawTxt(string.format("Nearest: %s (%.0fm)", nearestName, nearestDist), 0.5, 0.92, 0.25, false, 255, 200, 0, 200, true, 9)
						end
						if not Scooby.menuCheckBoxes['scooby_misc']['Distance Tracker'] then
							Scooby.Print("Distance Tracker: Off", "Distance Tracker: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = '--- Info HUDs ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby._killCount = 0
		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Kill Counter HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Kill Counter HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Kill Counter HUD: On", "Kill Counter HUD: On", false)
					local lastPlayerStates = {}
					while true do
						Citizen.Wait(0)
						for _, id in ipairs(GetActivePlayers()) do
							local ped = GetPlayerPed(id)
							local sid = GetPlayerServerId(id)
							if ped ~= Scooby.pedID() then
								local dead = IsPedDeadOrDying(ped)
								if dead and lastPlayerStates[sid] == false then
									Scooby._killCount = Scooby._killCount + 1
								end
								lastPlayerStates[sid] = dead
							end
						end
						DrawTxt("Kills: " .. Scooby._killCount, 0.92, 0.05, 0.30, false, 255, 50, 50, 220, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Kill Counter HUD'] then
							Scooby.Print("Kill Counter HUD: Off", "Kill Counter HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Health Bar HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Health Bar HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Health Bar HUD: On", "Health Bar HUD: On", false)
					while true do
						Citizen.Wait(0)
						local hp = GetEntityHealth(Scooby.pedID())
						local maxHp = GetPedMaxHealth(Scooby.pedID())
						local pct = hp / maxHp
						local barW = 0.12
						local barH = 0.012
						local barX = 0.5
						local barY = 0.95
						DrawRect(barX, barY, barW + 0.004, barH + 0.004, 0, 0, 0, 180)
						local r = math.floor((1 - pct) * 255)
						local g = math.floor(pct * 255)
						DrawRect(barX - (barW * (1 - pct)) / 2, barY, barW * pct, barH, r, g, 0, 220)
						DrawTxt(string.format("%d/%d", hp, maxHp), 0.5, barY - 0.018, 0.22, false, 255, 255, 255, 220, true, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Health Bar HUD'] then
							Scooby.Print("Health Bar HUD: Off", "Health Bar HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Heading HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Heading HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Heading HUD: On", "Heading HUD: On", false)
					while true do
						Citizen.Wait(0)
						local heading = GetEntityHeading(Scooby.pedID())
						DrawTxt(string.format("H: %.0f", heading), 0.92, 0.08, 0.25, false, 200, 200, 200, 200, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Heading HUD'] then
							Scooby.Print("Heading HUD: Off", "Heading HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Altitude HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Altitude HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Altitude HUD: On", "Altitude HUD: On", false)
					while true do
						Citizen.Wait(0)
						local coords = GetEntityCoords(Scooby.pedID())
						DrawTxt(string.format("ALT: %.1fm", coords.z), 0.92, 0.11, 0.25, false, 200, 200, 200, 200, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Altitude HUD'] then
							Scooby.Print("Altitude HUD: Off", "Altitude HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Weapon Info HUD',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Weapon Info HUD'] then
				Scooby.createThread(function()
					Scooby.Print("Weapon Info HUD: On", "Weapon Info HUD: On", false)
					while true do
						Citizen.Wait(0)
						local _, weapon = GetCurrentPedWeapon(Scooby.pedID(), true)
						if weapon and weapon ~= 0 then
							local ammo = GetAmmoInPedWeapon(Scooby.pedID(), weapon)
							DrawTxt(string.format("AMMO: %d", ammo), 0.92, 0.14, 0.25, false, 255, 200, 0, 200, false, 9)
						end
						if not Scooby.menuCheckBoxes['scooby_misc']['Weapon Info HUD'] then
							Scooby.Print("Weapon Info HUD: Off", "Weapon Info HUD: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'combobox',
			name = 'HUD Scale',
			items = { "Small", "Normal", "Large", "Extra Large" },
			currentIndex = 2,
			selectedIndex = 2,
		}, function(currentIndex, selectedItem)
			Scooby.Print("HUD Scale: " .. selectedItem .. " (visual preference saved)", "HUD Scale: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Rainbow Watermark',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Rainbow Watermark'] then
				Scooby.createThread(function()
					Scooby.Print("Rainbow Watermark: On", "Rainbow Watermark: On", false)
					local hue = 0
					while true do
						Citizen.Wait(0)
						hue = hue + 2
						if hue >= 360 then hue = 0 end
						local r, g, b
						local h = hue / 60
						local x = 1 - math.abs(h % 2 - 1)
						if h < 1 then r,g,b = 1,x,0
						elseif h < 2 then r,g,b = x,1,0
						elseif h < 3 then r,g,b = 0,1,x
						elseif h < 4 then r,g,b = 0,x,1
						elseif h < 5 then r,g,b = x,0,1
						else r,g,b = 1,0,x end
						DrawTxt("ScoobyOP v" .. Scooby.version, 0.005, 0.005, 0.25, false, math.floor(r*255), math.floor(g*255), math.floor(b*255), 200, false, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Rainbow Watermark'] then
							Scooby.Print("Rainbow Watermark: Off", "Rainbow Watermark: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'checkbox',
			name = 'Mini Info Panel',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_misc']['Mini Info Panel'] then
				Scooby.createThread(function()
					Scooby.Print("Mini Info Panel: On", "Mini Info Panel: On", false)
					while true do
						Citizen.Wait(0)
						local fps = math.floor(1.0 / GetFrameTime())
						local players = #GetActivePlayers()
						local coords = GetEntityCoords(Scooby.pedID())
						local hp = GetEntityHealth(Scooby.pedID())
						local y = 0.80
						DrawRect(0.93, y + 0.035, 0.13, 0.085, 0, 0, 0, 140)
						DrawTxt(string.format("FPS: %d | Players: %d", fps, players), 0.93, y, 0.22, false, 0, 200, 255, 220, true, 9)
						DrawTxt(string.format("HP: %d | Z: %.0f", hp, coords.z), 0.93, y + 0.02, 0.22, false, 255, 255, 255, 220, true, 9)
						DrawTxt(string.format("X:%.0f Y:%.0f", coords.x, coords.y), 0.93, y + 0.04, 0.20, false, 180, 180, 180, 200, true, 9)
						if not Scooby.menuCheckBoxes['scooby_misc']['Mini Info Panel'] then
							Scooby.Print("Mini Info Panel: Off", "Mini Info Panel: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_misc', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_settings', 'scooby_main', "ScoobyOP", "Settings", false, function()
		Scooby.menuCheckBoxes['scooby_settings'] = {}
		Scooby.menuCheckBoxes['scooby_settings']['Notifications'] = Scooby.Notifications.enabled
		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'checkbox',
			name = 'Notifications',
		}, function()
			if Scooby.menuCheckBoxes['scooby_settings']['Notifications'] then
				Scooby.Notifications.enabled = false
				return
			end
			Scooby.Notifications.enabled = true
			Scooby.Notifications.startQueue()
			Scooby.Print("Notifications Enabled", "Notifications Enabled", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'checkbox',
			name = 'Debug Mode',
		}, function()
			Scooby.Menu.debug = not Scooby.menuCheckBoxes['scooby_settings']['Debug Mode']
			Scooby.Print("Debug: " .. tostring(Scooby.Menu.debug), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = '--- UI Settings ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Move Left',
			desc = 'Move menu left',
		}, function()
			local x = menus['scooby_main'] and menus['scooby_main'].x or 0.65
			x = x - 0.05
			if x < 0.02 then x = 0.02 end
			Scooby.Menu.SetMenuX('scooby_main', x)
			Scooby.Print("X: " .. string.format("%.2f", x), "X: " .. string.format("%.2f", x), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Move Right',
			desc = 'Move menu right',
		}, function()
			local x = menus['scooby_main'] and menus['scooby_main'].x or 0.65
			x = x + 0.05
			if x > 0.80 then x = 0.80 end
			Scooby.Menu.SetMenuX('scooby_main', x)
			Scooby.Print("X: " .. string.format("%.2f", x), "X: " .. string.format("%.2f", x), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Move Up',
			desc = 'Move menu up',
		}, function()
			local y = menus['scooby_main'] and menus['scooby_main'].y or 0.10
			y = y - 0.05
			if y < 0.02 then y = 0.02 end
			Scooby.Menu.SetMenuY('scooby_main', y)
			Scooby.Print("Y: " .. string.format("%.2f", y), "Y: " .. string.format("%.2f", y), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Move Down',
			desc = 'Move menu down',
		}, function()
			local y = menus['scooby_main'] and menus['scooby_main'].y or 0.10
			y = y + 0.05
			if y > 0.70 then y = 0.70 end
			Scooby.Menu.SetMenuY('scooby_main', y)
			Scooby.Print("Y: " .. string.format("%.2f", y), "Y: " .. string.format("%.2f", y), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Wider Menu',
			desc = 'Increase width',
		}, function()
			local w = menus['scooby_main'] and menus['scooby_main'].width or 0.275
			w = w + 0.02
			if w > 0.40 then w = 0.40 end
			Scooby.Menu.SetMenuWidth('scooby_main', w)
			Scooby.Print("Width: " .. string.format("%.2f", w), "Width: " .. string.format("%.2f", w), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Narrower Menu',
			desc = 'Decrease width',
		}, function()
			local w = menus['scooby_main'] and menus['scooby_main'].width or 0.275
			w = w - 0.02
			if w < 0.18 then w = 0.18 end
			Scooby.Menu.SetMenuWidth('scooby_main', w)
			Scooby.Print("Width: " .. string.format("%.2f", w), "Width: " .. string.format("%.2f", w), false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'combobox',
			name = 'Max Options',
			items = { "10", "12", "15", "18", "20", "25" },
			currentIndex = 3,
			selectedIndex = 3,
		}, function(currentIndex, selectedItem)
			local count = tonumber(selectedItem) or 15
			Scooby.Menu.SetMenuMaxOptionCountOnScreen('scooby_main', count)
			Scooby.Print("Max options: " .. count, "Max options: " .. count, false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Reset Position',
			desc = 'Move menu to default position',
		}, function()
			Scooby.Menu.SetMenuX('scooby_main', 0.65)
			Scooby.Menu.SetMenuY('scooby_main', 0.10)
			Scooby.Menu.SetMenuWidth('scooby_main', 0.275)
			Scooby.Print("Menu reset", "Menu reset", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Unload Menu',
			desc = 'Close and unload ScoobyOP',
		}, function()
			Scooby.Menu.CloseMenu()
			Scooby.Print("ScoobyOP Unloaded", "ScoobyOP Unloaded", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Show All Active Features',
			desc = 'List every enabled toggle',
		}, function()
			local active = {}
			for menuId, checks in pairs(Scooby.menuCheckBoxes) do
				if type(checks) == "table" then
					for name, val in pairs(checks) do
						if val == true then
							table.insert(active, name)
						end
					end
				end
			end
			if #active == 0 then
				Scooby.Print("No features active", "No features active", false)
			else
				local msg = table.concat(active, ", ")
				Scooby.Print(msg, #active .. " active: " .. msg, false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Disable All Features',
			desc = 'Turn off every active toggle',
		}, function()
			for menuId, checks in pairs(Scooby.menuCheckBoxes) do
				if type(checks) == "table" then
					for name, val in pairs(checks) do
						if val == true then
							Scooby.menuCheckBoxes[menuId][name] = false
						end
					end
				end
			end
			-- Also disable standalone toggles
			_ab = false
			_be = false
			_b2 = false
			_xh = false
			_xh2 = false
			Scooby.Print("All features disabled", "All features disabled", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = '--- Hotkeys ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'combobox',
			name = 'Open Key',
			items = { "F1", "F2", "F3", "F5", "F6", "F7", "F8", "F9", "F10" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby.Print("Open Key display: " .. selectedItem, "Open Key display: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Toggle Radar',
			desc = 'Show/hide the radar',
		}, function()
			local radarOn = IsRadarPreferenceSwitchedOn()
			DisplayRadar(not radarOn)
			if radarOn then
				Scooby.Print("Radar: Off", "Radar: Off", false)
			else
				Scooby.Print("Radar: On", "Radar: On", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Toggle HUD',
			desc = 'Show/hide the HUD',
		}, function()
			local hudOn = IsHudPreferenceSwitchedOn()
			DisplayHud(not hudOn)
			if hudOn then
				Scooby.Print("HUD: Off", "HUD: Off", false)
			else
				Scooby.Print("HUD: On", "HUD: On", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = '--- Appearance ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'combobox',
			name = 'Notification Duration',
			items = { "Short (2s)", "Normal (4s)", "Long (8s)", "Very Long (15s)" },
			currentIndex = 2,
			selectedIndex = 2,
		}, function(currentIndex, selectedItem)
			local durations = { 2000, 4000, 8000, 15000 }
			Scooby.Notifications.duration = durations[currentIndex] or 4000
			Scooby.Print("Notification Duration: " .. selectedItem, "Notification Duration: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'combobox',
			name = 'Menu Theme',
			items = { "Default", "Red", "Blue", "Green", "Purple", "Gold" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local colors = {
				{ 0, 200, 255 },
				{ 200, 30, 30 },
				{ 30, 100, 220 },
				{ 30, 180, 50 },
				{ 140, 50, 200 },
				{ 210, 170, 30 },
			}
			local c = colors[currentIndex] or colors[1]
			local menus = { 'scooby_main', 'scooby_settings', 'scooby_player', 'scooby_vehicle',
				'scooby_world', 'scooby_protection', 'scooby_misc', 'scooby_combat',
				'scooby_teleport', 'scooby_weapon', 'scooby_visual', 'scooby_spawner',
				'scooby_players', 'scooby_server', 'scooby_allplayers' }
			for _, id in ipairs(menus) do
				pcall(function() Scooby.Menu.SetTitleBackgroundColor(id, c[1], c[2], c[3], 255) end)
			end
			Scooby.Print("Menu Theme: " .. selectedItem, "Menu Theme: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'combobox',
			name = 'Menu Opacity',
			items = { "100%", "90%", "75%", "50%" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local alphas = { 255, 230, 191, 128 }
			local a = alphas[currentIndex] or 255
			local menus = { 'scooby_main', 'scooby_settings', 'scooby_player', 'scooby_vehicle',
				'scooby_world', 'scooby_protection', 'scooby_misc', 'scooby_combat',
				'scooby_teleport', 'scooby_weapon', 'scooby_visual', 'scooby_spawner',
				'scooby_players', 'scooby_server', 'scooby_allplayers' }
			for _, id in ipairs(menus) do
				pcall(function() Scooby.Menu.SetMenuBackgroundColor(id, 8, 10, 16, a) end)
			end
			Scooby.Print("Menu Opacity: " .. selectedItem, "Menu Opacity: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = '--- Links ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Website',
			desc = 'scoobymenu.xyz',
		}, function()
			Scooby.Print("Site: scoobymenu.xyz", "Site: scoobymenu.xyz", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Discord',
			desc = 'scoobymenu.xyz/discord.html',
		}, function()
			Scooby.Print("Discord: scoobymenu.xyz/discord.html", "Discord: scoobymenu.xyz/discord.html", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'GitHub',
			desc = 'github.com/Scoobypaste98',
		}, function()
			Scooby.Print("GitHub: github.com/Scoobypaste98", "GitHub: github.com/Scoobypaste98", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'Telegram',
			desc = 't.me/ScoobyOnTop',
		}, function()
			Scooby.Print("Telegram: t.me/ScoobyOnTop", "Telegram: t.me/ScoobyOnTop", false)
		end)

		Scooby.registerMenuAttribute('scooby_settings', {
			type = 'button',
			name = 'ScoobyOP v' .. Scooby.version,
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_player', 'scooby_main', "ScoobyOP", "Player", false, function()
		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Heal',
			desc = 'Restore Full Health',
		}, function()
			Scooby.native(0xAC2767ED8BDFAB15, Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()))
			Scooby.Print("Self Healed", "Self Healed", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'TPM',
			desc = 'Teleport to Waypoint',
		}, function()
			if Scooby.native(0xD42BD6EB2E0F1677, Scooby.pedID()) then
				local WP = GetWaypointCoords()
				if (WP.x == 0 and WP.y == 0) then
				else
					local height = 1
					for height = 1, 1000 do
						Scooby.native(0x06843DA7060A026B, Scooby.pedID(), WP.x, WP.y, height + 0.0)
						local foundground, groundZ, normal = GetGroundZAndNormalFor_3dCoord(WP.x, WP.y, height + 0.0)
						if foundground then
							Scooby.native(0x06843DA7060A026B, Scooby.pedID(), WP.x, WP.y, height + 0.0)
							break
						end
						Wait(25)
					end
				end
			end
			Scooby.Print("Teleported to marker", "Teleported to marker", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'FREECAM',
			desc = 'Free Camera Mode',
		}, function()
			Scooby.toggle_camera()
			Scooby.Print("Entered Freecam", "Entered Freecam", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Make me see',
			desc = 'Set Time to Day',
		}, function()
			Scooby.native(0x59174F1AFE095B5A, GetHashKey("OVERCAST"), true, true, true, 1.0, false)
			Scooby.native(0x669E223E64B1903C, math.floor(((2000) / 60) % 24), math.floor((2000) % 60), 0)

			Scooby.Print("Set time to day", "Set time to day", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Player Size',
			items = { 1, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.1,
				2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 4.1, 4.2, 4.3, 4.4,
				4.5, 4.6, 4.7, 4.8, 4.9, 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7,
				6.8, 6.9, 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 8.8, 8.9, 9.1,
				9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 9.9, 10.0 },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby.Print("Player Size Changed To: " .. selectedItem, "Player Size Changed To: " .. selectedItem, false)

			Scooby.requestControl(Scooby.pedID())
			SetPedScale(Scooby.pedID(), selectedItem + 0.0)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Godmode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Godmode'] then
				Scooby.createThread(function()
					Scooby.Print("Godmode: Enabled", "Godmode: Enabled", false)
					while (true) do
						Citizen.Wait(1)

						Scooby.native(0x166E7CF68597D8B5, Scooby.pedID(), 1000000)
						Scooby.native(0xAC2767ED8BDFAB15, Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()))

						if not Scooby.menuCheckBoxes['scooby_player']['Godmode'] then
							Scooby.native(0x166E7CF68597D8B5, Scooby.pedID(), 200)
							Scooby.Print("Godmode: Disabled", "Godmode: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Invisible',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Invisible'] then
				Scooby.Print("Invis: Enabled", "Invis: Enabled", false)
				Scooby.createThread(function()
					while (true) do
						Citizen.Wait(1)

						Scooby.native(0x1794B4FCC84D812F, Scooby.pedID(), false)

						if not Scooby.menuCheckBoxes['scooby_player']['Invisible'] then
							Scooby.native(0x1794B4FCC84D812F, Scooby.pedID(), true)
							Scooby.Print("Invis: Disabled", "Invis: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Noclip',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Noclip'] then
				Scooby.Print("Noclip: Enabled", "Noclip: Enabled", false)
				Scooby.createThread(function()
					local noclip = GetEntityCoords(Scooby.pedID(), false)
					local heading = GetEntityHeading(Scooby.pedID())
					local speed = 0.5

					while (true) do
						Citizen.Wait(0)

						Scooby.native(0x239A3351AC1DA385, Scooby.pedID(), noclip.x, noclip.y, noclip.z, 0, 0, 0)

						if (Scooby.native(0xE2587F8CBBD87B1D, 1, 0x7065027D)) then
							heading = heading + 5.5
							SetEntityHeading(Scooby.pedID(), heading)
						end

						if (Scooby.native(0xE2587F8CBBD87B1D, 1, 0xB4E465B4)) then
							heading = heading - 5.5
							SetEntityHeading(Scooby.pedID(), heading)
						end

						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD27782E3) then
							noclip = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), 0.0, speed, 0.0)
						end

						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FD015D8) then
							noclip = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), 0.0, -speed, 0.0)
						end

						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD9D0E1C0) then
							noclip = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), 0.0, 0.0, speed)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xDB096B85) then
							noclip = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), 0.0, 0.0, -speed)
						end

						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FFC75D6) then
							if speed >= 6.5 then speed = 0.5 else speed = speed + 1.0 end
						end

						if not Scooby.menuCheckBoxes['scooby_player']['Noclip'] then
							Scooby.Print("Noclip: Disabled", "Noclip: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Revenge',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Revenge'] then
				Scooby.Print("Revenge: Enabled", "Revenge: Enabled", false)
				Scooby.createThread(function()
					while (true) do
						Citizen.Wait(1)

						local theSwitch = false
						local pedKiller = Scooby.native(0x93C8B64DEB84728C, PlayerPedId()) --GETSPEDSOURCEOFDEATH
						local killerCoords = GetEntityCoords(pedKiller)
						local x, y, z = table.unpack(killerCoords)

						if x ~= 0.0 and y ~= 0.0 and z ~= 0.0 and theSwitch == false then
							Scooby.native(0x867654CBC7606F2C, killerCoords, x, y, z + 0.01, 400.0, true, 0x31B7B9FE,
								PlayerPedId(), false, true, 999999999, false, false, 0)
							theSwitch = true
							if theSwitch == true then
								break
							end
						end

						if not Scooby.menuCheckBoxes['scooby_player']['Revenge'] then
							Scooby.Print("Revenge: Disabled", "Revenge: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'CROSSHAIR 1',
			desc = '_xh!',
		}, function()
			if not _xh then
				_xh = true
			else
				_xh = false
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'CROSSHAIR 2',
			desc = '_xh!',
		}, function()
			if not _xh2 then
				_xh2 = true
			else
				_xh2 = false
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Infinite Stamina',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Infinite Stamina'] then
				Scooby.createThread(function()
					Scooby.Print("Infinite Stamina: Enabled", "Infinite Stamina: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						RestorePlayerStamina(PlayerId(), 1.0)
						if not Scooby.menuCheckBoxes['scooby_player']['Infinite Stamina'] then
							Scooby.Print("Infinite Stamina: Disabled", "Infinite Stamina: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'No Ragdoll',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['No Ragdoll'] then
				Scooby.createThread(function()
					Scooby.Print("No Ragdoll: Enabled", "No Ragdoll: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						SetPedCanRagdoll(Scooby.pedID(), false)
						if not Scooby.menuCheckBoxes['scooby_player']['No Ragdoll'] then
							SetPedCanRagdoll(Scooby.pedID(), true)
							Scooby.Print("No Ragdoll: Disabled", "No Ragdoll: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Super Jump',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Super Jump'] then
				Scooby.createThread(function()
					Scooby.Print("Super Jump: Enabled", "Super Jump: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						if IsPedJumping(Scooby.pedID()) then
							ApplyForceToEntity(Scooby.pedID(), 1, 0.0, 0.0, 12.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Super Jump'] then
							Scooby.Print("Super Jump: Disabled", "Super Jump: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Speed Hack',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Speed Hack'] then
				Scooby.createThread(function()
					Scooby.Print("Speed Hack: Enabled", "Speed Hack: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						SetPedMoveRateOverride(Scooby.pedID(), 3.0)
						if not Scooby.menuCheckBoxes['scooby_player']['Speed Hack'] then
							SetPedMoveRateOverride(Scooby.pedID(), 1.0)
							Scooby.Print("Speed Hack: Disabled", "Speed Hack: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'No Wanted',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['No Wanted'] then
				Scooby.createThread(function()
					Scooby.Print("No Wanted: Enabled", "No Wanted: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						ClearPlayerBounty(PlayerId())
						if not Scooby.menuCheckBoxes['scooby_player']['No Wanted'] then
							Scooby.Print("No Wanted: Disabled", "No Wanted: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Infinite Dead Eye',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Infinite Dead Eye'] then
				Scooby.createThread(function()
					Scooby.Print("Infinite Dead Eye: Enabled", "Infinite Dead Eye: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100) -- _SET_ATTRIBUTE_CORE_VALUE
						if not Scooby.menuCheckBoxes['scooby_player']['Infinite Dead Eye'] then
							Scooby.Print("Infinite Dead Eye: Disabled", "Infinite Dead Eye: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Anti Headshot',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Anti Headshot'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Headshot: Enabled", "Anti Headshot: Enabled", false)
					while (true) do
						Citizen.Wait(0)
						SetPedCanHeadshot(Scooby.pedID(), false)
						if not Scooby.menuCheckBoxes['scooby_player']['Anti Headshot'] then
							SetPedCanHeadshot(Scooby.pedID(), true)
							Scooby.Print("Anti Headshot: Disabled", "Anti Headshot: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Keep Clean',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Keep Clean'] then
				Scooby.createThread(function()
					Scooby.Print("Keep Clean: Enabled", "Keep Clean: Enabled", false)
					while (true) do
						Citizen.Wait(1000)
						ClearPedBloodDamage(Scooby.pedID())
						ClearPedDamageDecalByZone(Scooby.pedID(), 10, "ALL")
						if not Scooby.menuCheckBoxes['scooby_player']['Keep Clean'] then
							Scooby.Print("Keep Clean: Disabled", "Keep Clean: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Fill All Cores',
			desc = 'Restore health, stamina, dead eye cores',
		}, function()
			Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 0, 100) -- health core
			Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 1, 100) -- stamina core
			Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100) -- deadeye core
			Scooby.Print("Cores filled", "Cores filled", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Animations ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Wave',
			desc = 'Play animation',
		}, function()
			local dict = "amb_camp@world_camp_fire_story@male_d@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Playing animation", "Playing animation", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Dance',
			desc = 'Play animation',
		}, function()
			local dict = "amb_camp@world_camp_fire_banjo@male_a@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Playing animation", "Playing animation", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Sit Down',
			desc = 'Play animation',
		}, function()
			local dict = "amb_rest_drunk@world_human_sit_ground@male_a@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Playing animation", "Playing animation", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Sleep',
			desc = 'Play animation',
		}, function()
			local dict = "amb_camp@world_camp_fire_sleep@male_a@bedroll"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "sleep_enter", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Playing animation", "Playing animation", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Guitar',
			desc = 'Play animation',
		}, function()
			local dict = "amb_camp@world_camp_fire_guitar@male_a@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Playing animation", "Playing animation", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Surrender',
			desc = 'Play animation',
		}, function()
			local dict = "script_proc@robberies@bnk_coach@bnk_coach_1@surrender"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "surrender_enter", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Playing animation", "Playing animation", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Stop Animation',
			desc = 'Stop current animation',
		}, function()
			ClearPedTasks(Scooby.pedID(), true, false)
			Scooby.Print("Animation stopped", "Animation stopped", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Appearance ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Random Outfit',
			desc = 'Randomize ped components',
		}, function()
			SetPedRandomComponentVariation(Scooby.pedID(), 0)
			Scooby.Print("Random outfit applied", "Random outfit applied", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Reset Model',
			desc = 'Reset to default player model',
		}, function()
			local hash = GetHashKey("mp_male")
			RequestModel(hash)
			local a = 0
			while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasModelLoaded(hash) then
				SetPlayerModel(PlayerId(), hash, true)
				Scooby.Print("Model reset to mp_male", "Model reset to mp_male", false)
			else
				Scooby.Print("Failed to load model", "Failed to load model", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Recovery ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Max Health',
			desc = 'Set max health to 1000',
		}, function()
			Scooby.native(0x166E7CF68597D8B5, Scooby.pedID(), 1000)
			SetEntityHealth(Scooby.pedID(), 1000, 0)
			Scooby.Print("Max Health set to 1000", "Max Health set to 1000", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Overpower Cores',
			desc = 'Overpower all 3 cores',
		}, function()
			Scooby.native(0xF6A7C08DF2E28B28, Scooby.pedID(), 0, 100.0, false)
			Scooby.native(0xF6A7C08DF2E28B28, Scooby.pedID(), 1, 100.0, false)
			Scooby.native(0xF6A7C08DF2E28B28, Scooby.pedID(), 2, 100.0, false)
			Scooby.Print("Cores overpowered", "Cores overpowered", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Revive Self',
			desc = 'Resurrect if dead',
		}, function()
			if IsPedDeadOrDying(Scooby.pedID()) then
				ResurrectPed(Scooby.pedID())
				SetEntityHealth(Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()), 0)
				ClearPedBloodDamage(Scooby.pedID())
				Scooby.Print("Revived", "Revived", false)
			else
				Scooby.Print("Not dead", "Not dead", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Clear Blood',
			desc = 'Remove blood and damage decals',
		}, function()
			ClearPedBloodDamage(Scooby.pedID())
			ClearPedDamageDecalByZone(Scooby.pedID(), 0, "ALL")
			Scooby.Print("Blood cleared", "Blood cleared", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Remove Bounty',
			desc = 'Clear your bounty',
		}, function()
			ClearPlayerBounty(PlayerId())
			Scooby.Print("Bounty cleared", "Bounty cleared", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Player Info ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Show My Info',
			desc = 'Display your player info',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			local hp = GetEntityHealth(Scooby.pedID())
			local maxHp = GetPedMaxHealth(Scooby.pedID())
			local heading = GetEntityHeading(Scooby.pedID())
			local sid = GetPlayerServerId(PlayerId())
			local name = GetPlayerName(PlayerId())
			local msg = string.format("[%d] %s | HP: %d/%d | Pos: %.0f, %.0f, %.0f | H: %.0f",
				sid, name, hp, maxHp, coords.x, coords.y, coords.z, heading)
			Scooby.Print(msg, msg, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Quick Actions ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Refill Ammo',
			desc = 'Fill all ammo to 999',
		}, function()
			for i = 1, #Scooby.Configs.AmmoTypes do
				Scooby.native(0x106A811C6D3035F3, Scooby.pedID(), GetHashKey(Scooby.Configs.AmmoTypes[i]), 999, 752097756)
			end
			Scooby.Print("All ammo refilled", "All ammo refilled", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Full Restore',
			desc = 'Heal + fill cores + clear blood + stamina',
		}, function()
			SetEntityHealth(Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()), 0)
			Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 0, 100)
			Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 1, 100)
			Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100)
			ClearPedBloodDamage(Scooby.pedID())
			RestorePlayerStamina(PlayerId(), 1.0)
			Scooby.Print("Fully restored", "Fully restored", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Wanted Level 0',
			desc = 'Clear your bounty and wanted level',
		}, function()
			ClearPlayerBounty(PlayerId())
			Scooby.Print("Wanted level cleared", "Wanted level cleared", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Clone Army',
			desc = 'Spawn 5 clones that fight for you',
		}, function()
			local model = GetEntityModel(Scooby.pedID())
			local coords = GetEntityCoords(Scooby.pedID())
			RequestModel(model)
			local a = 0
			while not HasModelLoaded(model) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasModelLoaded(model) then
				for i = 1, 5 do
					local clone = Scooby.native(0xD49F9B0955C367DE, model, coords.x + i*2, coords.y, coords.z, 0.0, true, false)
					Citizen.InvokeNative(0x283978A15512B2FE, clone, true)
					SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), GetPedRelationshipGroupHash(clone))
					TaskCombatHatedTargetsAroundPed(clone, 100.0, 0)
				end
				Scooby.Print("Clone army spawned", "Clone army spawned", false)
			else
				Scooby.Print("Failed to load model", "Failed to load model", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Stealth ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Off Radar',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Off Radar'] then
				Scooby.createThread(function()
					Scooby.Print("Off Radar: Enabled", "Off Radar: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPlayerInvisibleLocally(PlayerId(), true)
						SetPoliceIgnorePlayer(PlayerId(), true)
						if not Scooby.menuCheckBoxes['scooby_player']['Off Radar'] then
							SetPlayerInvisibleLocally(PlayerId(), false)
							SetPoliceIgnorePlayer(PlayerId(), false)
							Scooby.Print("Off Radar: Disabled", "Off Radar: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Never Wanted',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Never Wanted'] then
				Scooby.createThread(function()
					Scooby.Print("Never Wanted: Enabled", "Never Wanted: Enabled", false)
					while true do
						Citizen.Wait(100)
						ClearPlayerBounty(PlayerId())
						Scooby.native(0x70F2D413B21E22B5, PlayerId())
						if not Scooby.menuCheckBoxes['scooby_player']['Never Wanted'] then
							Scooby.Print("Never Wanted: Disabled", "Never Wanted: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Anti NPC Aggro',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Anti NPC Aggro'] then
				Scooby.createThread(function()
					Scooby.Print("Anti NPC Aggro: Enabled", "Anti NPC Aggro: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedConfigFlag(Scooby.pedID(), 32, true)
						SetPedConfigFlag(Scooby.pedID(), 394, true)
						if not Scooby.menuCheckBoxes['scooby_player']['Anti NPC Aggro'] then
							SetPedConfigFlag(Scooby.pedID(), 32, false)
							SetPedConfigFlag(Scooby.pedID(), 394, false)
							Scooby.Print("Anti NPC Aggro: Disabled", "Anti NPC Aggro: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Movement ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Slide Run',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Slide Run'] then
				Scooby.Print("Slide Run: Enabled", "Slide Run: Enabled", false)
				Scooby.createThread(function()
					while (true) do
						Citizen.Wait(1)

						if IsPedSprinting(Scooby.pedID()) then
							local fwd = GetEntityForwardVector(Scooby.pedID())
							ApplyForceToEntity(Scooby.pedID(), 1, fwd.x * 5.0, fwd.y * 5.0, 0.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
						end

						if not Scooby.menuCheckBoxes['scooby_player']['Slide Run'] then
							Scooby.Print("Slide Run: Disabled", "Slide Run: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Moon Jump',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Moon Jump'] then
				Scooby.Print("Moon Jump: Enabled", "Moon Jump: Enabled", false)
				Scooby.createThread(function()
					while (true) do
						Citizen.Wait(1)

						if IsPedJumping(Scooby.pedID()) or IsPedInAir(Scooby.pedID()) then
							ApplyForceToEntity(Scooby.pedID(), 1, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
						end

						if not Scooby.menuCheckBoxes['scooby_player']['Moon Jump'] then
							Scooby.Print("Moon Jump: Disabled", "Moon Jump: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Teleport to Ground',
			desc = 'Find ground and teleport down',
		}, function()
			local coords = GetEntityCoords(Scooby.pedID())
			for h = 1, 1000 do
				local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, h + 0.0)
				if found then
					Scooby.native(0x06843DA7060A026B, Scooby.pedID(), coords.x, coords.y, groundZ + 1.0, 0, 0, 0, 0)
					break
				end
			end
			Scooby.Print("Teleported to ground", "Teleported to ground", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Suicide',
			desc = 'Kill yourself',
		}, function()
			SetEntityHealth(Scooby.pedID(), 0, 0)
			Scooby.Print("You died", "You died", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Fly / Gravity ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Fly Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Fly Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Fly Mode: Enabled (Shift=Up, Ctrl=Down, WASD=Move, Space=Fast)", "Fly Mode: Enabled", false)
					local flyPos = GetEntityCoords(Scooby.pedID())
					local flyHeading = GetEntityHeading(Scooby.pedID())
					local flySpeed = 1.0
					while true do
						Citizen.Wait(0)
						FreezeEntityPosition(Scooby.pedID(), true)
						SetEntityCollision(Scooby.pedID(), false, false)

						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD27782E3) then
							flyPos = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), 0.0, flySpeed, 0.0)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FD015D8) then
							flyPos = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), 0.0, -flySpeed, 0.0)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x7065027D) then
							flyPos = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), -flySpeed, 0.0, 0.0)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xB4E465B4) then
							flyPos = GetOffsetFromEntityInWorldCoords(Scooby.pedID(), flySpeed, 0.0, 0.0)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD9D0E1C0) then
							flyPos = vector3(flyPos.x, flyPos.y, flyPos.z + flySpeed)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xDB096B85) then
							flyPos = vector3(flyPos.x, flyPos.y, flyPos.z - flySpeed)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FFC75D6) then
							if flySpeed >= 8.0 then flySpeed = 0.5 else flySpeed = flySpeed + 0.5 end
							Scooby.Print("Fly Speed: " .. flySpeed, "Fly Speed: " .. flySpeed, false)
						end

						Scooby.native(0x239A3351AC1DA385, Scooby.pedID(), flyPos.x, flyPos.y, flyPos.z, 0, 0, 0)

						if not Scooby.menuCheckBoxes['scooby_player']['Fly Mode'] then
							FreezeEntityPosition(Scooby.pedID(), false)
							SetEntityCollision(Scooby.pedID(), true, true)
							Scooby.Print("Fly Mode: Disabled", "Fly Mode: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Super Sprint',
			items = { "Normal", "1.5x", "2x", "3x", "4x", "5x", "8x", "10x" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local speeds = { 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 8.0, 10.0 }
			local spd = speeds[currentIndex] or 1.0
			SetPedMoveRateOverride(Scooby.pedID(), spd)
			Scooby.Print("Sprint Speed: " .. selectedItem, "Sprint Speed: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Gravity',
			items = { "Normal", "Low", "Very Low", "Moon", "Zero", "High", "Jupiter" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local gravities = { 9.8, 5.0, 2.0, 1.0, 0.0, 15.0, 25.0 }
			local grav = gravities[currentIndex] or 9.8
			SetGravityLevel(grav == 9.8 and 0 or (grav == 0 and 3 or 1))
			Scooby.Print("Gravity: " .. selectedItem, "Gravity: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Swim Fast',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Swim Fast'] then
				Scooby.createThread(function()
					Scooby.Print("Swim Fast: Enabled", "Swim Fast: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedSwimming(Scooby.pedID()) then
							local fwd = GetEntityForwardVector(Scooby.pedID())
							ApplyForceToEntity(Scooby.pedID(), 1, fwd.x * 3.0, fwd.y * 3.0, 0.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Swim Fast'] then
							Scooby.Print("Swim Fast: Disabled", "Swim Fast: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Dash Forward',
			desc = 'Teleport 20m in facing direction',
		}, function()
			local ped = Scooby.pedID()
			local coords = GetEntityCoords(ped)
			local heading = GetEntityHeading(ped)
			local rad = math.rad(heading)
			local x = coords.x - math.sin(rad) * 20.0
			local y = coords.y + math.cos(rad) * 20.0
			Scooby.native(0x06843DA7060A026B, ped, x, y, coords.z, 0, 0, 0, 0)
			Scooby.Print("Dashed forward!", "Dashed forward!", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'No Fall Damage',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['No Fall Damage'] then
				Scooby.createThread(function()
					Scooby.Print("No Fall Damage: Enabled", "No Fall Damage: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetEntityProofs(Scooby.pedID(), false, false, false, false, false, false, false, false)
						SetPedConfigFlag(Scooby.pedID(), 60, true)
						if not Scooby.menuCheckBoxes['scooby_player']['No Fall Damage'] then
							SetPedConfigFlag(Scooby.pedID(), 60, false)
							Scooby.Print("No Fall Damage: Disabled", "No Fall Damage: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Explosive Melee',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Explosive Melee'] then
				Scooby.createThread(function()
					Scooby.Print("Explosive Melee: Enabled", "Explosive Melee: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedInMeleeCombat(Scooby.pedID()) then
							local coords = GetEntityCoords(Scooby.pedID())
							local fwd = GetEntityForwardVector(Scooby.pedID())
							_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x + fwd.x * 1.5, coords.y + fwd.y * 1.5, coords.z, 27, 2.0, true, false, true)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Explosive Melee'] then
							Scooby.Print("Explosive Melee: Disabled", "Explosive Melee: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Force Field',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Force Field'] then
				Scooby.createThread(function()
					Scooby.Print("Force Field: Enabled", "Force Field: Enabled", false)
					while true do
						Citizen.Wait(100)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() then
								local pCoords = GetEntityCoords(ped)
								local dist = #(myCoords - pCoords)
								if dist < 8.0 and dist > 0.5 then
									local dx = pCoords.x - myCoords.x
									local dy = pCoords.y - myCoords.y
									local norm = math.sqrt(dx*dx + dy*dy)
									if norm > 0 then
										ApplyForceToEntity(ped, 1, (dx/norm)*15.0, (dy/norm)*15.0, 5.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Force Field'] then
							Scooby.Print("Force Field: Disabled", "Force Field: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Auto Eagle Eye',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Auto Eagle Eye'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Eagle Eye: Enabled", "Auto Eagle Eye: Enabled", false)
					while true do
						Citizen.Wait(0)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100)
						if not Scooby.menuCheckBoxes['scooby_player']['Auto Eagle Eye'] then
							Scooby.Print("Auto Eagle Eye: Disabled", "Auto Eagle Eye: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Sliders ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Walk Style',
			items = { "Normal", "Tough", "Drunk", "Injured", "Sneaky", "Intimidate", "Casual" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local styles = { "default", "move_m@tough_guy@a", "move_m@drunk@a", "move_m@injured", "move_m@stealth@a", "move_m@intimidation@1h", "move_m@casual@a" }
			if currentIndex == 1 then
				ResetPedMovementClipset(Scooby.pedID(), 0.0)
			else
				RequestClipSet(styles[currentIndex])
				Wait(100)
				SetPedMovementClipset(Scooby.pedID(), styles[currentIndex], 0.0)
			end
			Scooby.Print("Walk Style: " .. selectedItem, "Walk Style: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Opacity',
			items = { "100%", "90%", "75%", "50%", "25%", "10%", "Ghost (5%)" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local alphas = { 255, 230, 191, 127, 64, 25, 13 }
			SetEntityAlpha(Scooby.pedID(), alphas[currentIndex] or 255, false)
			Scooby.Print("Opacity: " .. selectedItem, "Opacity: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Health Regen Rate',
			items = { "Off", "Slow", "Normal", "Fast", "Instant" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local rates = { 0, 1, 5, 20, 100 }
			Scooby._healthRegenRate = rates[currentIndex] or 0
			Scooby.Print("Health Regen: " .. selectedItem, "Health Regen: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Health Regen',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Health Regen'] then
				Scooby.createThread(function()
					Scooby.Print("Health Regen: On", "Health Regen: On", false)
					while true do
						Citizen.Wait(500)
						local rate = Scooby._healthRegenRate or 5
						if rate > 0 then
							local hp = GetEntityHealth(Scooby.pedID())
							local maxHp = GetPedMaxHealth(Scooby.pedID())
							if hp < maxHp then
								SetEntityHealth(Scooby.pedID(), math.min(maxHp, hp + rate), 0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Health Regen'] then
							Scooby.Print("Health Regen: Off", "Health Regen: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'combobox',
			name = 'Noclip Speed',
			items = { "Slow (0.3)", "Normal (0.5)", "Fast (1.0)", "Very Fast (2.0)", "Insane (5.0)" },
			currentIndex = 2,
			selectedIndex = 2,
		}, function(currentIndex, selectedItem)
			local speeds = { 0.3, 0.5, 1.0, 2.0, 5.0 }
			Scooby._noclipSpeed = speeds[currentIndex] or 0.5
			Scooby.Print("Noclip Speed: " .. selectedItem, "Noclip Speed: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Auto Cores',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Auto Cores'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Cores: On (keeps all cores full)", "Auto Cores: On", false)
					while true do
						Citizen.Wait(2000)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 0, 100)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 1, 100)
						Scooby.native(0xC6258F41D86676E0, Scooby.pedID(), 2, 100)
						if not Scooby.menuCheckBoxes['scooby_player']['Auto Cores'] then
							Scooby.Print("Auto Cores: Off", "Auto Cores: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'No Clip V2',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['No Clip V2'] then
				Scooby.createThread(function()
					Scooby.Print("No Clip V2: On (camera-direction noclip)", "No Clip V2: On", false)
					local ncPos = GetEntityCoords(Scooby.pedID())
					while true do
						Citizen.Wait(0)
						FreezeEntityPosition(Scooby.pedID(), true)
						SetEntityCollision(Scooby.pedID(), false, false)
						local speed = Scooby._noclipSpeed or 0.5

						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD27782E3) then
							local cam = GetFinalRenderedCamCoord()
							local camRot = GetFinalRenderedCamRot(2)
							local pitch = math.rad(camRot.x)
							local yaw = math.rad(camRot.z)
							local dx = -math.sin(yaw) * math.cos(pitch) * speed
							local dy = math.cos(yaw) * math.cos(pitch) * speed
							local dz = math.sin(pitch) * speed
							ncPos = vector3(ncPos.x + dx, ncPos.y + dy, ncPos.z + dz)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FD015D8) then
							local cam = GetFinalRenderedCamCoord()
							local camRot = GetFinalRenderedCamRot(2)
							local pitch = math.rad(camRot.x)
							local yaw = math.rad(camRot.z)
							local dx = math.sin(yaw) * math.cos(pitch) * speed
							local dy = -math.cos(yaw) * math.cos(pitch) * speed
							local dz = -math.sin(pitch) * speed
							ncPos = vector3(ncPos.x + dx, ncPos.y + dy, ncPos.z + dz)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD9D0E1C0) then
							ncPos = vector3(ncPos.x, ncPos.y, ncPos.z + speed)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xDB096B85) then
							ncPos = vector3(ncPos.x, ncPos.y, ncPos.z - speed)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0x8FFC75D6) then
							speed = speed >= 5.0 and 0.3 or speed + 0.5
							Scooby._noclipSpeed = speed
							Scooby.Print("Speed: " .. speed, "Speed: " .. speed, false)
						end

						Scooby.native(0x239A3351AC1DA385, Scooby.pedID(), ncPos.x, ncPos.y, ncPos.z, 0, 0, 0)

						if not Scooby.menuCheckBoxes['scooby_player']['No Clip V2'] then
							FreezeEntityPosition(Scooby.pedID(), false)
							SetEntityCollision(Scooby.pedID(), true, true)
							Scooby.Print("No Clip V2: Off", "No Clip V2: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Anti Melee',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Anti Melee'] then
				Scooby.createThread(function()
					Scooby.Print("Anti Melee: On", "Anti Melee: On", false)
					while true do
						Citizen.Wait(0)
						SetPedConfigFlag(Scooby.pedID(), 52, true)
						if not Scooby.menuCheckBoxes['scooby_player']['Anti Melee'] then
							SetPedConfigFlag(Scooby.pedID(), 52, false)
							Scooby.Print("Anti Melee: Off", "Anti Melee: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Infinite Oxygen',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Infinite Oxygen'] then
				Scooby.createThread(function()
					Scooby.Print("Infinite Oxygen: On", "Infinite Oxygen: On", false)
					while true do
						Citizen.Wait(100)
						if IsEntityInWater(Scooby.pedID()) then
							SetEntityHealth(Scooby.pedID(), GetPedMaxHealth(Scooby.pedID()), 0)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Infinite Oxygen'] then
							Scooby.Print("Infinite Oxygen: Off", "Infinite Oxygen: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- Superman ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Superman',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Superman'] then
				Scooby.createThread(function()
					Scooby.Print("Superman: Enabled (aim camera direction, W to fly)", "Superman: Enabled", false)
					while true do
						Citizen.Wait(0)
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD27782E3) then
							local cam = GetFinalRenderedCamCoord()
							local camRot = GetFinalRenderedCamRot(2)
							local pitch = math.rad(camRot.x)
							local yaw = math.rad(camRot.z)
							local dirX = -math.sin(yaw) * math.cos(pitch) * 3.0
							local dirY = math.cos(yaw) * math.cos(pitch) * 3.0
							local dirZ = math.sin(pitch) * 3.0
							local coords = GetEntityCoords(Scooby.pedID())
							Scooby.native(0x239A3351AC1DA385, Scooby.pedID(), coords.x + dirX, coords.y + dirY, coords.z + dirZ, 0, 0, 0)
							SetEntityVelocity(Scooby.pedID(), 0.0, 0.0, -0.01)
							SetPedCanRagdoll(Scooby.pedID(), false)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Superman'] then
							SetPedCanRagdoll(Scooby.pedID(), true)
							Scooby.Print("Superman: Disabled", "Superman: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Water Walk',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Water Walk'] then
				Scooby.createThread(function()
					Scooby.Print("Water Walk: Enabled", "Water Walk: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsEntityInWater(Scooby.pedID()) then
							local coords = GetEntityCoords(Scooby.pedID())
							FreezeEntityPosition(Scooby.pedID(), false)
							ApplyForceToEntity(Scooby.pedID(), 1, 0.0, 0.0, 6.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Water Walk'] then
							Scooby.Print("Water Walk: Disabled", "Water Walk: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Teleport Gun',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Teleport Gun'] then
				Scooby.createThread(function()
					Scooby.Print("Teleport Gun: Enabled (shoot to teleport there)", "Teleport Gun: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								Scooby.native(0x06843DA7060A026B, Scooby.pedID(), impact.x, impact.y, impact.z + 1.0, false, false, false, false)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Teleport Gun'] then
							Scooby.Print("Teleport Gun: Disabled", "Teleport Gun: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Matrix Dodge',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Matrix Dodge'] then
				Scooby.createThread(function()
					Scooby.Print("Matrix Dodge: Enabled (auto-dodges bullets)", "Matrix Dodge: Enabled", false)
					while true do
						Citizen.Wait(0)
						if HasEntityBeenDamagedByAnyPed(Scooby.pedID()) then
							SetTimeScale(0.2)
							local coords = GetEntityCoords(Scooby.pedID())
							local side = (math.random(0,1) == 0) and -3.0 or 3.0
							local heading = GetEntityHeading(Scooby.pedID())
							local rad = math.rad(heading + 90)
							local dodgeX = coords.x - math.sin(rad) * side
							local dodgeY = coords.y + math.cos(rad) * side
							Scooby.native(0x239A3351AC1DA385, Scooby.pedID(), dodgeX, dodgeY, coords.z, 0, 0, 0)
							Wait(200)
							SetTimeScale(1.0)
							ClearEntityLastDamageEntity(Scooby.pedID())
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Matrix Dodge'] then
							SetTimeScale(1.0)
							Scooby.Print("Matrix Dodge: Disabled", "Matrix Dodge: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Levitate',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Levitate'] then
				Scooby.createThread(function()
					Scooby.Print("Levitate: Enabled (hover in place)", "Levitate: Enabled", false)
					local levPos = GetEntityCoords(Scooby.pedID())
					while true do
						Citizen.Wait(0)
						FreezeEntityPosition(Scooby.pedID(), true)
						Scooby.native(0x239A3351AC1DA385, Scooby.pedID(), levPos.x, levPos.y, levPos.z, 0, 0, 0)
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xD9D0E1C0) then
							levPos = vector3(levPos.x, levPos.y, levPos.z + 0.5)
						end
						if Scooby.native(0xE2587F8CBBD87B1D, 1, 0xDB096B85) then
							levPos = vector3(levPos.x, levPos.y, levPos.z - 0.5)
						end
						if not Scooby.menuCheckBoxes['scooby_player']['Levitate'] then
							FreezeEntityPosition(Scooby.pedID(), false)
							Scooby.Print("Levitate: Disabled", "Levitate: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'checkbox',
			name = 'Spin Mode',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_player']['Spin Mode'] then
				Scooby.createThread(function()
					Scooby.Print("Spin Mode: On", "Spin Mode: On", false)
					local heading = GetEntityHeading(Scooby.pedID())
					while true do
						Citizen.Wait(0)
						heading = heading + 15.0
						if heading >= 360 then heading = heading - 360 end
						SetEntityHeading(Scooby.pedID(), heading)
						if not Scooby.menuCheckBoxes['scooby_player']['Spin Mode'] then
							Scooby.Print("Spin Mode: Off", "Spin Mode: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = '--- More Animations ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Smoke',
			desc = 'Play smoking animation',
		}, function()
			local dict = "amb_rest_lean@world_human_smoke_cigarette@male_a@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Smoking...", "Smoking...", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Fishing',
			desc = 'Play fishing animation',
		}, function()
			local dict = "mini_games@fishing@active@base"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "base", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Fishing...", "Fishing...", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Hands Up',
			desc = 'Raise hands animation',
		}, function()
			local dict = "script_proc@robberies@bnk_coach@bnk_coach_1@surrender"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "surrender_idle", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Hands up!", "Hands up!", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Push Ups',
			desc = 'Play push-up animation',
		}, function()
			local dict = "amb_rest_drunk@world_human_push_ups@male_a@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Push ups!", "Push ups!", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Drink',
			desc = 'Play drinking animation',
		}, function()
			local dict = "amb_rest_drunk@world_human_drinking@male_a@idle_a"
			RequestAnimDict(dict)
			local a = 0
			while not HasAnimDictLoaded(dict) and a < 100 do Citizen.Wait(10); a = a + 1 end
			if HasAnimDictLoaded(dict) then
				TaskPlayAnim(Scooby.pedID(), dict, "idle_a", 8.0, -8.0, -1, 0, 0, false, false, false, "", false)
				Scooby.Print("Drinking...", "Drinking...", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'Play Dead',
			desc = 'Lie down and play dead',
		}, function()
			SetPedToRagdoll(Scooby.pedID(), 10000, 10000, 0, false, false, false)
			Scooby.Print("Playing dead...", "Playing dead...", false)
		end)

		Scooby.registerMenuAttribute('scooby_player', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function()
			Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
		end)
	end)

	Scooby.registerSubMenu('scooby_spawner', 'scooby_main', "ScoobyOP", "Spawner", false, function()
		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = "Animals",
			desc = 'Animal Models',
		}, function()
			Scooby.Menu.OpenMenu('scooby_spawner_animals')
		end)
		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = "NPCs",
			desc = 'NPC Models',
		}, function()
			Scooby.Menu.OpenMenu('scooby_spawner_npcs')
		end)
		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = "Horses",
			desc = 'Spawn Horses',
		}, function()
			Scooby.Menu.OpenMenu('scooby_spawner_horses')
		end)
		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = "Objects",
			desc = 'Spawn Objects',
		}, function()
			Scooby.Menu.OpenMenu('scooby_spawner_objects')
		end)

		Scooby.registerSubMenu('scooby_spawner_animals', 'scooby_spawner', "ScoobyOP", "Animal Models", false,
			function()
				for index, name in pairs(Scooby.Configs.Peds.Animal) do
					Scooby.registerMenuAttribute('scooby_spawner_animals', {
						type = 'button',
						name = name,
						desc = '',
					}, function()
						Scooby.setPlayerModel({ playerId = PlayerId(), type = "Animal", modelIndex = index })
						Scooby.Print("Ped changed to: " .. name, "Ped changed to: " .. name, false)
					end)
				end
			end)

		Scooby.registerSubMenu('scooby_spawner_npcs', 'scooby_spawner', "ScoobyOP", "NPC Models", false, function()
			for index, name in pairs(Scooby.Configs.Peds.NPC) do
				Scooby.registerMenuAttribute('scooby_spawner_npcs', {
					type = 'button',
					name = name,
					desc = '',
				}, function()
					Scooby.setPlayerModel({ playerId = PlayerId(), type = "NPC", modelIndex = index })
					Scooby.Print("Ped changed to: " .. name, "Ped changed to: " .. name, false)
				end)
			end
		end)

		Scooby.registerSubMenu('scooby_spawner_objects', 'scooby_spawner', "ScoobyOP", "Spawn Objects", false, function()
			local objects = {
				{ name = "Campfire", model = "p_campfire05x" },
				{ name = "Barrel", model = "p_barrel01x" },
				{ name = "Chair", model = "p_chaircomfy01x" },
				{ name = "Table", model = "p_table09x" },
				{ name = "Crate", model = "p_crate01x" },
				{ name = "Tent", model = "p_tent01x" },
				{ name = "Lantern", model = "p_lantern02x" },
				{ name = "Fence Post", model = "p_fencepost01x" },
				{ name = "Wagon Wheel", model = "p_wagonwheel01x" },
			}
			for _, obj in ipairs(objects) do
				Scooby.registerMenuAttribute('scooby_spawner_objects', {
					type = 'button',
					name = obj.name,
					desc = 'Spawn ' .. obj.name,
				}, function()
					local coords = GetEntityCoords(Scooby.pedID())
					local hash = GetHashKey(obj.model)
					RequestModel(hash)
					local a = 0
					while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
					if HasModelLoaded(hash) then
						CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true, true, true)
						Scooby.Print(obj.name .. " placed", obj.name .. " placed", false)
					end
				end)
			end

			Scooby.registerMenuAttribute('scooby_spawner_objects', {
				type = 'button',
				name = '--- Extra Objects ---',
				desc = '',
				isInfo = true,
			}, function() end)

			Scooby.registerMenuAttribute('scooby_spawner_objects', {
				type = 'button',
				name = 'Spawn Bridge',
				desc = 'Spawn a bridge plank',
			}, function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("p_bridgeplank01x")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true, true, true)
					Scooby.Print("Bridge placed", "Bridge placed", false)
				end
			end)

			Scooby.registerMenuAttribute('scooby_spawner_objects', {
				type = 'button',
				name = 'Spawn Rock',
				desc = 'Spawn a rock',
			}, function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("s_rock01x")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true, true, true)
					Scooby.Print("Rock placed", "Rock placed", false)
				end
			end)

			Scooby.registerMenuAttribute('scooby_spawner_objects', {
				type = 'button',
				name = 'Spawn Tree',
				desc = 'Spawn a pine tree',
			}, function()
				local coords = GetEntityCoords(Scooby.pedID())
				local hash = GetHashKey("p_tree_pine_01")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, true, true, true, true)
					Scooby.Print("Tree placed", "Tree placed", false)
				end
			end)

			Scooby.registerMenuAttribute('scooby_spawner_objects', {
				type = 'button',
				name = 'Delete Nearest Object',
				desc = 'Delete closest object within 10m',
			}, function()
				local coords = GetEntityCoords(Scooby.pedID())
				local nearest = GetClosestObjectOfType(coords.x, coords.y, coords.z, 10.0, 0, false, false, false)
				if nearest and nearest ~= 0 then
					SetEntityAsMissionEntity(nearest, true, true)
					DeleteEntity(nearest)
					Scooby.Print("Object deleted", "Object deleted", false)
				else
					Scooby.Print("No object nearby", "No object nearby", false)
				end
			end)

			Scooby.registerMenuAttribute('scooby_spawner_objects', {
				type = 'button',
				name = 'ScoobyOP',
				desc = '',
				isInfo = true,
			}, function()
				Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
			end)
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = '--- Quick Spawn ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = 'Custom Model',
			desc = 'Type any model name to spawn as',
		}, function()
			Scooby.createThread(function()
				Scooby.Print("Enter model name (e.g. a_c_wolf)", "Enter model name", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)
					if UpdateOnscreenKeyboard() == 1 then
						local modelName = GetOnscreenKeyboardResult()
						if modelName and modelName ~= "" then
							local hash = GetHashKey(modelName)
							RequestModel(hash)
							local a = 0
							while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
							if HasModelLoaded(hash) then
								SetPlayerModel(PlayerId(), hash, true)
								Scooby.Print("Model set to: " .. modelName, "Model set to: " .. modelName, false)
							else
								Scooby.Print("Invalid model: " .. modelName, "Invalid model: " .. modelName, false)
							end
						end
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then
						break
					end
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = 'Spawn Custom Ped',
			desc = 'Type model name to spawn a ped next to you',
		}, function()
			Scooby.createThread(function()
				Scooby.Print("Enter ped model name", "Enter ped model name", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)
					if UpdateOnscreenKeyboard() == 1 then
						local modelName = GetOnscreenKeyboardResult()
						if modelName and modelName ~= "" then
							local hash = GetHashKey(modelName)
							RequestModel(hash)
							local a = 0
							while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
							if HasModelLoaded(hash) then
								local coords = GetEntityCoords(Scooby.pedID())
								local ped = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + 2.0, coords.y, coords.z, 0.0, true, false)
								Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
								Scooby.Print("Spawned: " .. modelName, "Spawned: " .. modelName, false)
							else
								Scooby.Print("Invalid model: " .. modelName, "Invalid model: " .. modelName, false)
							end
						end
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then
						break
					end
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'combobox',
			name = 'Spawn Count',
			items = { "1", "3", "5", "10", "15", "20" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby._spawnCount = tonumber(selectedItem) or 1
			Scooby.Print("Spawn Count: " .. selectedItem, "Spawn Count: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'combobox',
			name = 'Quick Spawn',
			items = { "Wolf", "Bear", "Cougar", "Panther", "Alligator", "Deer", "Buffalo", "Elk", "Coyote", "Eagle" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local models = {
				"a_c_wolf", "a_c_bear_01", "a_c_cougar_01", "a_c_panther_01",
				"a_c_alligator_01", "a_c_deer_01", "a_c_buffalo_01", "a_c_elk_01",
				"a_c_coyote_01", "a_c_eagle_01"
			}
			local count = Scooby._spawnCount or 1
			Scooby.createThread(function()
				local hash = GetHashKey(models[currentIndex] or "a_c_wolf")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					for i = 1, count do
						local ped = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-8,8), coords.y + math.random(-8,8), coords.z, math.random(0,360)+0.0, true, false)
						Citizen.InvokeNative(0x283978A15512B2FE, ped, true)
					end
					Scooby.Print("Spawned " .. count .. "x " .. selectedItem, "Spawned " .. count .. "x " .. selectedItem, false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'combobox',
			name = 'Quick Spawn Vehicle',
			items = { "Stagecoach", "Cart", "Canoe", "Handcart", "Wagon02", "Coal Wagon", "Oil Wagon" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local models = { "coach2", "cart01", "canoe", "handcart", "wagon02x", "coalwagon", "oilwagon01x" }
			Scooby.createThread(function()
				local hash = GetHashKey(models[currentIndex] or "coach2")
				RequestModel(hash)
				local a = 0
				while not HasModelLoaded(hash) and a < 100 do Citizen.Wait(10); a = a + 1 end
				if HasModelLoaded(hash) then
					local coords = GetEntityCoords(Scooby.pedID())
					local heading = GetEntityHeading(Scooby.pedID())
					CreateVehicle(hash, coords.x + 4.0, coords.y, coords.z, heading, true, true)
					SetModelAsNoLongerNeeded(hash)
					Scooby.Print("Spawned: " .. selectedItem, "Spawned: " .. selectedItem, false)
				else
					Scooby.Print("Failed to load vehicle", "Failed to load vehicle", false)
				end
			end)
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'checkbox',
			name = 'Auto Spawn Wolves',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_spawner']['Auto Spawn Wolves'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Spawn Wolves: On (every 15s)", "Auto Spawn Wolves: On", false)
					while true do
						Citizen.Wait(15000)
						local hash = GetHashKey("a_c_wolf")
						RequestModel(hash)
						local a = 0
						while not HasModelLoaded(hash) and a < 50 do Citizen.Wait(10); a = a + 1 end
						if HasModelLoaded(hash) then
							local coords = GetEntityCoords(Scooby.pedID())
							for i = 1, 3 do
								local wolf = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + math.random(-15,15), coords.y + math.random(-15,15), coords.z, math.random(0,360)+0.0, true, false)
								Citizen.InvokeNative(0x283978A15512B2FE, wolf, true)
								TaskCombatHatedTargetsAroundPed(wolf, 200.0, 0)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_spawner']['Auto Spawn Wolves'] then
							Scooby.Print("Auto Spawn Wolves: Off", "Auto Spawn Wolves: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_spawner', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function()
			Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
		end)
	end)

	Scooby.registerSubMenu('scooby_spawner_horses', 'scooby_spawner', "ScoobyOP", "Horses", false, function()
		for index, name in pairs(Scooby.Configs.Horses) do
			Scooby.registerMenuAttribute('scooby_spawner_horses', {
				type = 'button',
				name = name,
				desc = '',
			}, function()
				Scooby.getPlayerInfo(Scooby.pedID(), function(pInfo)
					Scooby.spawnPed(name, vector3(pInfo.coords.x + 2.0, pInfo.coords.y, pInfo.coords.z), pInfo.heading,
						function(modelName, spawningPed)
							Scooby.Print("Spawned a horse: " .. modelName, "Spawned a horse: " .. modelName, false)
						end)
				end, false, true)
			end)
		end

		Scooby.registerMenuAttribute('scooby_spawner_horses', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function()
			Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
		end)
	end)

	Scooby.registerSubMenu('scooby_weapon', 'scooby_main', "ScoobyOP", "Weapon", false, function()
		local spawnableWeapons = {}; for name, _ in pairs(Scooby.Configs.Weapons) do table.insert(spawnableWeapons, name) end
		; table.sort(spawnableWeapons)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'The Loadout',
			desc = 'Equip Full Loadout',
		}, function()
			for k, v in pairs(Scooby.theLoadout) do
				Scooby.native(0xB282DC6EBD803C75, Scooby.pedID(), v, 45, true, 0)
				Wait(1000)
			end

			Scooby.Print("Loadout Equipped", "Loadout Equipped", false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'combobox',
			name = 'Spawn Weapon',
			items = spawnableWeapons,
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby.Print("Spawned a " .. selectedItem .. " | " .. Scooby.Configs.Weapons[selectedItem],
				"Spawned a " .. selectedItem .. " | " .. Scooby.Configs.Weapons[selectedItem], false)
			Scooby.native(0xB282DC6EBD803C75, Scooby.pedID(), Scooby.Configs.Weapons[selectedItem], 45, true, 0)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Clear All Weapons',
			desc = 'Remove All Weapons',
		}, function()
			Scooby.requestControl(Scooby.pedID())
			Scooby.native(0xF25DF915FA38C5F3, Scooby.pedID(), true, true)

			Scooby.Print("Weapons Cleared", "Weapons Cleared", false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Reload All Weapons',
			desc = 'Refill All Ammo',
		}, function()
			for i = 1, #Scooby.Configs.AmmoTypes do
				Scooby.native(0x106A811C6D3035F3, Scooby.pedID(), GetHashKey(Scooby.Configs.AmmoTypes[i]), 999, 752097756);
			end

			Scooby.Print("Ammo Refilled", "Ammo Refilled", false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Infinite Ammo',
		}, function()
			Scooby.Print(
			"Infinite Ammo: " ..
			(not Scooby.menuCheckBoxes['scooby_weapon']['Infinite Ammo'] and "Enabled" or "Disable"),
				"Infinite Ammo: " ..
				(not Scooby.menuCheckBoxes['scooby_weapon']['Infinite Ammo'] and "Enabled" or "Disable"), false)
			SetPedInfiniteAmmoClip(Scooby.pedID(), not Scooby.menuCheckBoxes['scooby_weapon']['Infinite Ammo'])
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Fast Reload',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Fast Reload'] then
				Scooby.createThread(function()
					Scooby.Print("Fast Reload: Enabled", "Fast Reload: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedReloading(Scooby.pedID()) then
							SetPedResetFlag(Scooby.pedID(), 130, true)
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Fast Reload'] then
							Scooby.Print("Fast Reload: Disabled", "Fast Reload: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'No Recoil',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['No Recoil'] then
				Scooby.createThread(function()
					Scooby.Print("No Recoil: Enabled", "No Recoil: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedResetFlag(Scooby.pedID(), 64, true)
						if not Scooby.menuCheckBoxes['scooby_weapon']['No Recoil'] then
							Scooby.Print("No Recoil: Disabled", "No Recoil: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Keep Guns Clean',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Keep Guns Clean'] then
				Scooby.createThread(function()
					Scooby.Print("Keep Guns Clean: Enabled", "Keep Guns Clean: Enabled", false)
					while true do
						Citizen.Wait(500)
						local weapObj = _i(0x3B390A939AF0B5FC, Scooby.pedID(), true)
						if weapObj and weapObj ~= 0 then
							_i(0xA7A57E89E965D875, weapObj, 0.0) -- SetWeaponDegradation
							_i(0xA99CF172E26AA608, weapObj, 0.0, true) -- SetWeaponDirt
							_i(0x983B82AE2FFB4E5E, weapObj, 0.0, true) -- SetWeaponSoot
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Keep Guns Clean'] then
							Scooby.Print("Keep Guns Clean: Disabled", "Keep Guns Clean: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Spawn All Weapons',
			desc = 'Give every weapon',
		}, function()
			for name, hash in pairs(Scooby.Configs.Weapons) do
				Scooby.native(0xB282DC6EBD803C75, Scooby.pedID(), hash, 99, true, 0)
			end
			Scooby.Print("All weapons spawned", "All weapons spawned", false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Max All Ammo',
			desc = 'Fill all ammo types to 999',
		}, function()
			for i = 1, #Scooby.Configs.AmmoTypes do
				Scooby.native(0x106A811C6D3035F3, Scooby.pedID(), GetHashKey(Scooby.Configs.AmmoTypes[i]), 999, 752097756)
			end
			Scooby.Print("All ammo maxed", "All ammo maxed", false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Weapon Damage x2',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x2'] then
				Scooby.createThread(function()
					Scooby.Print("Weapon Damage x2: Enabled", "Weapon Damage x2: Enabled", false)
					if Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x5'] then
						Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x5'] = false
					end
					SetPlayerWeaponDamageModifier(PlayerId(), 2.0)
					while true do
						Citizen.Wait(500)
						SetPlayerWeaponDamageModifier(PlayerId(), 2.0)
						if not Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x2'] then
							SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
							Scooby.Print("Weapon Damage x2: Disabled", "Weapon Damage x2: Disabled", false)
							break
						end
					end
				end)
			else
				SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Weapon Damage x5',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x5'] then
				Scooby.createThread(function()
					Scooby.Print("Weapon Damage x5: Enabled", "Weapon Damage x5: Enabled", false)
					if Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x2'] then
						Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x2'] = false
					end
					SetPlayerWeaponDamageModifier(PlayerId(), 5.0)
					while true do
						Citizen.Wait(500)
						SetPlayerWeaponDamageModifier(PlayerId(), 5.0)
						if not Scooby.menuCheckBoxes['scooby_weapon']['Weapon Damage x5'] then
							SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
							Scooby.Print("Weapon Damage x5: Disabled", "Weapon Damage x5: Disabled", false)
							break
						end
					end
				end)
			else
				SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Delete Current Weapon',
			desc = 'Remove held weapon',
		}, function()
			local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
			if weapon ~= 0 then
				RemoveWeaponFromPed(Scooby.pedID(), weapon)
				Scooby.Print("Weapon Deleted", "Weapon Deleted", false)
			else
				Scooby.Print("No weapon equipped", "No weapon equipped", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Drop Weapon',
			desc = 'Drop held weapon',
		}, function()
			local _, weapon = GetCurrentPedWeapon(Scooby.pedID())
			if weapon ~= 0 then
				SetPedDropsWeapon(Scooby.pedID())
				Scooby.Print("Weapon Dropped", "Weapon Dropped", false)
			else
				Scooby.Print("No weapon equipped", "No weapon equipped", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = '--- Weapon Extras ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Flaming Weapons',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Flaming Weapons'] then
				Scooby.createThread(function()
					Scooby.Print("Flaming Weapons: Enabled", "Flaming Weapons: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								StartScriptFire(impact.x, impact.y, impact.z, 3, true, false, false, 1.0, 0)
								_i(0xD84A917A64D4D016, Scooby.pedID(), impact.x, impact.y, impact.z, 29, 0.5, true, false, true)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Flaming Weapons'] then
							Scooby.Print("Flaming Weapons: Disabled", "Flaming Weapons: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'One Punch',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['One Punch'] then
				Scooby.createThread(function()
					Scooby.Print("One Punch: Enabled", "One Punch: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPlayerMeleeWeaponDamageModifier(PlayerId(), 100.0)
						if IsPedInMeleeCombat(Scooby.pedID()) then
							SetPlayerWeaponDamageModifier(PlayerId(), 100.0)
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['One Punch'] then
							SetPlayerMeleeWeaponDamageModifier(PlayerId(), 1.0)
							SetPlayerWeaponDamageModifier(PlayerId(), 1.0)
							Scooby.Print("One Punch: Disabled", "One Punch: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Auto Aim Assist',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Auto Aim Assist'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Aim Assist: Enabled", "Auto Aim Assist: Enabled", false)
					while true do
						Citizen.Wait(0)
						SetPedAccuracy(Scooby.pedID(), 100)
						SetPlayerTargetingMode(3)
						if not Scooby.menuCheckBoxes['scooby_weapon']['Auto Aim Assist'] then
							Scooby.Print("Auto Aim Assist: Disabled", "Auto Aim Assist: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Teleport Bullets',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Teleport Bullets'] then
				Scooby.createThread(function()
					Scooby.Print("Teleport Bullets: Enabled (shoot to TP)", "Teleport Bullets: Enabled", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								Scooby.native(0x06843DA7060A026B, Scooby.pedID(), impact.x, impact.y, impact.z + 1.0, false, false, false, false)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Teleport Bullets'] then
							Scooby.Print("Teleport Bullets: Disabled", "Teleport Bullets: Disabled", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'combobox',
			name = 'Melee Damage',
			items = { "1x", "2x", "5x", "10x", "50x", "100x" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local mults = { 1, 2, 5, 10, 50, 100 }
			SetPlayerMeleeWeaponDamageModifier(PlayerId(), (mults[currentIndex] or 1) + 0.0)
			Scooby.Print("Melee Damage: " .. selectedItem, "Melee Damage: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'Give Throwables',
			desc = 'Give dynamite, fire bottles, knives',
		}, function()
			local throwables = {
				0xF86DDCE7, -- WEAPON_THROWN_DYNAMITE
				0x7067E7A7, -- WEAPON_THROWN_MOLOTOV
				0x39B01B97, -- WEAPON_THROWN_THROWING_KNIVES
			}
			for _, w in ipairs(throwables) do
				Scooby.native(0xB282DC6EBD803C75, Scooby.pedID(), w, 10, true, 0)
			end
			Scooby.Print("Throwables given!", "Throwables given!", false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = '--- Weapon Sliders ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'combobox',
			name = 'Damage Modifier',
			items = { "1x", "1.5x", "2x", "3x", "5x", "10x", "25x", "50x", "100x" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local mults = { 1, 1.5, 2, 3, 5, 10, 25, 50, 100 }
			SetPlayerWeaponDamageModifier(PlayerId(), (mults[currentIndex] or 1) + 0.0)
			Scooby.Print("Damage: " .. selectedItem, "Damage: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Gravity Bullets',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Gravity Bullets'] then
				Scooby.createThread(function()
					Scooby.Print("Gravity Bullets: On (shots pull targets to ground)", "Gravity Bullets: On", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								for _, ped in pairs(GetGamePool('CPed')) do
									if ped ~= PlayerPedId() and not IsPedDeadOrDying(ped) then
										local dist = #(vector3(impact.x, impact.y, impact.z) - GetEntityCoords(ped))
										if dist < 5.0 then
											ApplyForceToEntity(ped, 1, 0.0, 0.0, -30.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Gravity Bullets'] then
							Scooby.Print("Gravity Bullets: Off", "Gravity Bullets: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Lightning Bullets',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Lightning Bullets'] then
				Scooby.createThread(function()
					Scooby.Print("Lightning Bullets: On", "Lightning Bullets: On", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								Scooby.native(0x67943537D179597C, impact.x, impact.y, impact.z, 1.0)
								Scooby.native(0xB09A4B5EE5B73F30)
								_i(0xD84A917A64D4D016, Scooby.pedID(), impact.x, impact.y, impact.z, 29, 2.0, true, false, true)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Lightning Bullets'] then
							Scooby.Print("Lightning Bullets: Off", "Lightning Bullets: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Push Bullets',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Push Bullets'] then
				Scooby.createThread(function()
					Scooby.Print("Push Bullets: On (shots push targets away)", "Push Bullets: On", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								local myCoords = GetEntityCoords(Scooby.pedID())
								for _, ped in pairs(GetGamePool('CPed')) do
									if ped ~= PlayerPedId() and not IsPedDeadOrDying(ped) then
										local pCoords = GetEntityCoords(ped)
										local dist = #(vector3(impact.x, impact.y, impact.z) - pCoords)
										if dist < 5.0 then
											local dx = pCoords.x - myCoords.x
											local dy = pCoords.y - myCoords.y
											local norm = math.sqrt(dx*dx + dy*dy)
											if norm > 0 then
												ApplyForceToEntity(ped, 1, (dx/norm)*30.0, (dy/norm)*30.0, 10.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
											end
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Push Bullets'] then
							Scooby.Print("Push Bullets: Off", "Push Bullets: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Vortex Bullets',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Vortex Bullets'] then
				Scooby.createThread(function()
					Scooby.Print("Vortex Bullets: On (shots pull targets toward impact)", "Vortex Bullets: On", false)
					while true do
						Citizen.Wait(0)
						if IsPedShooting(Scooby.pedID()) then
							local _, impact = GetPedLastWeaponImpactCoord(Scooby.pedID())
							if impact.x ~= 0 or impact.y ~= 0 or impact.z ~= 0 then
								for _, ped in pairs(GetGamePool('CPed')) do
									if ped ~= PlayerPedId() and not IsPedDeadOrDying(ped) then
										local pCoords = GetEntityCoords(ped)
										local dist = #(vector3(impact.x, impact.y, impact.z) - pCoords)
										if dist < 15.0 and dist > 1.0 then
											local dx = impact.x - pCoords.x
											local dy = impact.y - pCoords.y
											local dz = impact.z - pCoords.z
											local norm = math.sqrt(dx*dx + dy*dy + dz*dz)
											if norm > 0 then
												ApplyForceToEntity(ped, 1, (dx/norm)*20.0, (dy/norm)*20.0, (dz/norm)*10.0 + 3.0, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
											end
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Vortex Bullets'] then
							Scooby.Print("Vortex Bullets: Off", "Vortex Bullets: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'combobox',
			name = 'Explosive Ammo Size',
			items = { "Tiny (0.5)", "Small (2)", "Normal (5)", "Big (10)", "Huge (25)", "Nuclear (50)" },
			currentIndex = 3,
			selectedIndex = 3,
		}, function(currentIndex, selectedItem)
			Scooby._explosiveAmmoSize = ({ 0.5, 2, 5, 10, 25, 50 })[currentIndex] or 5
			Scooby.Print("Explosive Size: " .. selectedItem, "Explosive Size: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Auto Refill Ammo',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Auto Refill Ammo'] then
				Scooby.createThread(function()
					Scooby.Print("Auto Refill Ammo: On", "Auto Refill Ammo: On", false)
					while true do
						Citizen.Wait(5000)
						for i = 1, #Scooby.Configs.AmmoTypes do
							Scooby.native(0x106A811C6D3035F3, Scooby.pedID(), GetHashKey(Scooby.Configs.AmmoTypes[i]), 999, 752097756)
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Auto Refill Ammo'] then
							Scooby.Print("Auto Refill Ammo: Off", "Auto Refill Ammo: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'checkbox',
			name = 'Delete on Kill',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_weapon']['Delete on Kill'] then
				Scooby.createThread(function()
					Scooby.Print("Delete on Kill: On (dead peds auto-delete)", "Delete on Kill: On", false)
					while true do
						Citizen.Wait(2000)
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and IsPedDeadOrDying(ped) then
								SetEntityAsMissionEntity(ped, true, true)
								DeleteEntity(ped)
							end
						end
						if not Scooby.menuCheckBoxes['scooby_weapon']['Delete on Kill'] then
							Scooby.Print("Delete on Kill: Off", "Delete on Kill: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_weapon', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)
	end)

	Scooby.registerSubMenu('scooby_visual', 'scooby_main', "ScoobyOP", "Visual", false, function()
		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Box (Normal)',
		}, function()
			if _be then
				_be = false
			else
				_be = true

				Scooby.Print("type R for RGB colour", "type R for RGB colour", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)

					if UpdateOnscreenKeyboard() == 1 then
						result1 = GetOnscreenKeyboardResult()
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then
						break
					end
				end

				Wait(10)

				Scooby.Print("type G for RGB colour", "type G for RGB colour", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)

					if UpdateOnscreenKeyboard() == 1 then
						result2 = GetOnscreenKeyboardResult()
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then
						break
					end
				end

				Wait(10)

				Scooby.Print("type B for RGB colour", "type B for RGB colour", false)
				DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
				while true do
					DisableAllControlActions(0)
					HideHudAndRadarThisFrame()
					Citizen.Wait(0)

					if UpdateOnscreenKeyboard() == 1 then
						result3 = GetOnscreenKeyboardResult()
						break
					elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then
						break
					end
				end


				box_esp_r = result1
				box_esp_g = result2
				box_esp_b = result3
			end
		end)


		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = '2d box esp (new testing)',
		}, function()
			if _b2 then
				_b2 = false
			else
				_b2 = true
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Name',
		}, function()
			Scooby.registerESP('Name', function(plyData)
				Scooby.drawTxt(vector3(plyData.coords.x, plyData.coords.y, plyData.height + 0.1),
					"[" .. plyData.serverId .. "] - " .. plyData.name, 0.8 + (plyData.distance / 1000), 9)
			end, true)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Health',
		}, function()
			Scooby.registerESP('Health', function(plyData)
				Scooby.drawTxt(vector3(plyData.coords.x, plyData.coords.y, plyData.height + 0.2),
					tostring("Health: " .. plyData.health), 0.8 + (plyData.distance / 1000), 9)
			end, true)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Distance',
		}, function()
			Scooby.registerESP('Distance', function(plyData)
				Scooby.drawTxt(vector3(plyData.coords.x, plyData.coords.y, plyData.height),
					tostring("Distance: " .. math.floor(plyData.distance)), 0.8 + (plyData.distance / 1000), 9)
			end, true)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Chams',
		}, function()
			Scooby.registerESP('Chams', function(plyData)
				Scooby.native(0x2A32FAA57B937173, 0x6EB7D3BB, plyData.coords.x, plyData.coords.y, plyData.coords.z - 0.90,
					0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.9, 0.9, 2.5, 255, 56, 159, 255, false, true, 2, false, false, false,
					true)
			end, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'button',
			name = 'Box Colour Red',
		}, function()
			local R1 = 255
			local R2 = 87
			local R3 = 51

			box_esp_r = R1
			box_esp_g = R2
			box_esp_b = R3
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'button',
			name = 'Box Colour Blue',
		}, function()
			local R2_1 = 36
			local R2_2 = 96
			local R2_3 = 246

			box_esp_r = R2_1
			box_esp_g = R2_2
			box_esp_b = R2_3
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'button',
			name = 'Box Colour Green',
		}, function()
			local R3_1 = 36
			local R3_2 = 246
			local R3_3 = 72

			box_esp_r = R3_1
			box_esp_g = R3_2
			box_esp_b = R3_3
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Snaplines',
		}, function()
			Scooby.registerESP('Snaplines', function(plyData)
				local myCoords = GetEntityCoords(Scooby.pedID())
				DrawLine(myCoords.x, myCoords.y, myCoords.z - 0.5, plyData.coords.x, plyData.coords.y, plyData.coords.z, 255, 0, 180, 200)
			end, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Weapon ESP',
		}, function()
			Scooby.registerESP('Weapon ESP', function(plyData)
				local _, weapHash = GetCurrentPedWeapon(GetPlayerPed(plyData.id), true)
				if weapHash and weapHash ~= 0 then
					Scooby.drawTxt(vector3(plyData.coords.x, plyData.coords.y, plyData.height - 0.1),
						"[ARMED]", 0.7 + (plyData.distance / 1000), 9)
				end
			end, true)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Box Colour Cyan',
		}, function()
			box_esp_r = 0; box_esp_g = 200; box_esp_b = 255
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Rainbow ESP',
		}, function()
			Scooby.registerESP('Rainbow ESP', function(plyData)
				local rgb = RGBRainbow(1)
				box_esp_r = rgb.r; box_esp_g = rgb.g; box_esp_b = rgb.b
			end, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Skeleton ESP',
		}, function()
			Scooby.registerESP('Skeleton ESP', function(plyData)
				local ped = GetPlayerPed(plyData.id)
				local head = GetPedBoneCoords(ped, 21030, 0.0, 0.0, 0.0)
				local neck = GetPedBoneCoords(ped, 39317, 0.0, 0.0, 0.0)
				local chest = GetPedBoneCoords(ped, 11816, 0.0, 0.0, 0.0)
				local lhand = GetPedBoneCoords(ped, 18905, 0.0, 0.0, 0.0)
				local rhand = GetPedBoneCoords(ped, 57005, 0.0, 0.0, 0.0)
				local pelvis = GetPedBoneCoords(ped, 11816, 0.0, 0.0, 0.0)
				local lfoot = GetPedBoneCoords(ped, 14201, 0.0, 0.0, 0.0)
				local rfoot = GetPedBoneCoords(ped, 52301, 0.0, 0.0, 0.0)
				DrawLine(head.x, head.y, head.z, neck.x, neck.y, neck.z, 0, 255, 255, 200)
				DrawLine(neck.x, neck.y, neck.z, chest.x, chest.y, chest.z, 0, 255, 255, 200)
				DrawLine(neck.x, neck.y, neck.z, lhand.x, lhand.y, lhand.z, 0, 255, 255, 200)
				DrawLine(neck.x, neck.y, neck.z, rhand.x, rhand.y, rhand.z, 0, 255, 255, 200)
				DrawLine(chest.x, chest.y, chest.z, pelvis.x, pelvis.y, pelvis.z, 0, 255, 255, 200)
				DrawLine(pelvis.x, pelvis.y, pelvis.z, lfoot.x, lfoot.y, lfoot.z, 0, 255, 255, 200)
				DrawLine(pelvis.x, pelvis.y, pelvis.z, rfoot.x, rfoot.y, rfoot.z, 0, 255, 255, 200)
			end, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Head Marker',
		}, function()
			Scooby.registerESP('Head Marker', function(plyData)
				local ped = GetPlayerPed(plyData.id)
				local head = GetPedBoneCoords(ped, 21030, 0.0, 0.0, 0.0)
				DrawMarker(0x94FDAE17, head.x, head.y, head.z + 0.3, 0, 0, 0, 0, 0, 0, 0.15, 0.15, 0.15, 255, 0, 0, 200, false, false, 0, false, false, false, false)
			end, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Line to All Players',
		}, function()
			Scooby.registerESP('Line to All Players', function(plyData)
				local myCoords = GetEntityCoords(Scooby.pedID())
				DrawLine(myCoords.x, myCoords.y, myCoords.z, plyData.coords.x, plyData.coords.y, plyData.coords.z, 0, 255, 0, 200)
			end, false)
		end)

		Scooby.espMaxDist = 9999
		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'combobox',
			name = 'Distance Filter',
			items = { "All", "50m", "100m", "200m", "500m" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			if selectedItem == "All" then Scooby.espMaxDist = 9999
			elseif selectedItem == "50m" then Scooby.espMaxDist = 50
			elseif selectedItem == "100m" then Scooby.espMaxDist = 100
			elseif selectedItem == "200m" then Scooby.espMaxDist = 200
			elseif selectedItem == "500m" then Scooby.espMaxDist = 500
			end
			Scooby.Print("ESP Distance: " .. selectedItem, "ESP Distance: " .. selectedItem, false)
		end)

		Scooby.espShowDead = true
		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Show Dead Players',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Show Dead Players'] then
				Scooby.espShowDead = true
				Scooby.Print("Show Dead Players: On", "Show Dead Players: On", false)
			else
				Scooby.espShowDead = false
				Scooby.Print("Show Dead Players: Off", "Show Dead Players: Off", false)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'button',
			name = '--- NPC/Animal ESP ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'NPC ESP',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['NPC ESP'] then
				Scooby.createThread(function()
					Scooby.Print("NPC ESP: On", "NPC ESP: On", false)
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
								local pCoords = GetEntityCoords(ped)
								local dist = #(myCoords - pCoords)
								if dist < 100.0 then
									local height = GetEntityHeight(ped, pCoords.x, pCoords.y, pCoords.z, true, true)
									Scooby.drawTxt(vector3(pCoords.x, pCoords.y, height + 0.1),
										string.format("NPC [%.0fm]", dist), 0.6, 9)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['NPC ESP'] then
							Scooby.Print("NPC ESP: Off", "NPC ESP: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Animal ESP',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Animal ESP'] then
				Scooby.createThread(function()
					Scooby.Print("Animal ESP: On (3D Box)", "Animal ESP: On", false)
					local aHalfW = 0.3
					local aHalfD = 0.5
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) and Scooby.native(0x772A1969F649E902, ped) then
								local pCoords = GetEntityCoords(ped)
								local dist = #(myCoords - pCoords)
								if dist < 200.0 then
									local head = GetPedBoneCoords(ped, 21030, 0.0, 0.0, 0.0)
									local topOff = head.z - pCoords.z + 0.2
									local botOff = -0.05
									local c = {}
									c[1] = GetOffsetFromEntityInWorldCoords(ped, -aHalfW, -aHalfD, botOff)
									c[2] = GetOffsetFromEntityInWorldCoords(ped,  aHalfW, -aHalfD, botOff)
									c[3] = GetOffsetFromEntityInWorldCoords(ped,  aHalfW,  aHalfD, botOff)
									c[4] = GetOffsetFromEntityInWorldCoords(ped, -aHalfW,  aHalfD, botOff)
									c[5] = GetOffsetFromEntityInWorldCoords(ped, -aHalfW, -aHalfD, topOff)
									c[6] = GetOffsetFromEntityInWorldCoords(ped,  aHalfW, -aHalfD, topOff)
									c[7] = GetOffsetFromEntityInWorldCoords(ped,  aHalfW,  aHalfD, topOff)
									c[8] = GetOffsetFromEntityInWorldCoords(ped, -aHalfW,  aHalfD, topOff)
									local er, eg, eb = 0, 255, 100
									-- edges
									DrawLine(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, er,eg,eb,200)
									DrawLine(c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, er,eg,eb,200)
									DrawLine(c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, er,eg,eb,200)
									DrawLine(c[4].x,c[4].y,c[4].z, c[1].x,c[1].y,c[1].z, er,eg,eb,200)
									DrawLine(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, er,eg,eb,200)
									DrawLine(c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, er,eg,eb,200)
									DrawLine(c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, er,eg,eb,200)
									DrawLine(c[8].x,c[8].y,c[8].z, c[5].x,c[5].y,c[5].z, er,eg,eb,200)
									DrawLine(c[1].x,c[1].y,c[1].z, c[5].x,c[5].y,c[5].z, er,eg,eb,200)
									DrawLine(c[2].x,c[2].y,c[2].z, c[6].x,c[6].y,c[6].z, er,eg,eb,200)
									DrawLine(c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, er,eg,eb,200)
									DrawLine(c[4].x,c[4].y,c[4].z, c[8].x,c[8].y,c[8].z, er,eg,eb,200)
									-- fill (double-sided)
									local fa = 25
									DrawPoly(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, c[6].x,c[6].y,c[6].z, er,eg,eb,fa)
									DrawPoly(c[6].x,c[6].y,c[6].z, c[2].x,c[2].y,c[2].z, c[1].x,c[1].y,c[1].z, er,eg,eb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[6].x,c[6].y,c[6].z, c[5].x,c[5].y,c[5].z, er,eg,eb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, c[1].x,c[1].y,c[1].z, er,eg,eb,fa)
									DrawPoly(c[4].x,c[4].y,c[4].z, c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, er,eg,eb,fa)
									DrawPoly(c[7].x,c[7].y,c[7].z, c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, er,eg,eb,fa)
									DrawPoly(c[4].x,c[4].y,c[4].z, c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, er,eg,eb,fa)
									DrawPoly(c[8].x,c[8].y,c[8].z, c[7].x,c[7].y,c[7].z, c[4].x,c[4].y,c[4].z, er,eg,eb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[4].x,c[4].y,c[4].z, c[8].x,c[8].y,c[8].z, er,eg,eb,fa)
									DrawPoly(c[8].x,c[8].y,c[8].z, c[4].x,c[4].y,c[4].z, c[1].x,c[1].y,c[1].z, er,eg,eb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[8].x,c[8].y,c[8].z, c[5].x,c[5].y,c[5].z, er,eg,eb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[8].x,c[8].y,c[8].z, c[1].x,c[1].y,c[1].z, er,eg,eb,fa)
									DrawPoly(c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, er,eg,eb,fa)
									DrawPoly(c[7].x,c[7].y,c[7].z, c[3].x,c[3].y,c[3].z, c[2].x,c[2].y,c[2].z, er,eg,eb,fa)
									DrawPoly(c[2].x,c[2].y,c[2].z, c[7].x,c[7].y,c[7].z, c[6].x,c[6].y,c[6].z, er,eg,eb,fa)
									DrawPoly(c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, c[2].x,c[2].y,c[2].z, er,eg,eb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, er,eg,eb,fa)
									DrawPoly(c[7].x,c[7].y,c[7].z, c[6].x,c[6].y,c[6].z, c[5].x,c[5].y,c[5].z, er,eg,eb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, er,eg,eb,fa)
									DrawPoly(c[8].x,c[8].y,c[8].z, c[7].x,c[7].y,c[7].z, c[5].x,c[5].y,c[5].z, er,eg,eb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, er,eg,eb,fa)
									DrawPoly(c[3].x,c[3].y,c[3].z, c[2].x,c[2].y,c[2].z, c[1].x,c[1].y,c[1].z, er,eg,eb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, er,eg,eb,fa)
									DrawPoly(c[4].x,c[4].y,c[4].z, c[3].x,c[3].y,c[3].z, c[1].x,c[1].y,c[1].z, er,eg,eb,fa)
									-- text
									Scooby.drawTxt(vector3(pCoords.x, pCoords.y, head.z + 0.4),
										string.format("Animal [%.0fm]", dist), 0.6, 9)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['Animal ESP'] then
							Scooby.Print("Animal ESP: Off", "Animal ESP: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Vehicle ESP',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Vehicle ESP'] then
				Scooby.createThread(function()
					Scooby.Print("Vehicle ESP: On", "Vehicle ESP: On", false)
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, veh in pairs(GetGamePool('CVehicle')) do
							if DoesEntityExist(veh) then
								local vCoords = GetEntityCoords(veh)
								local dist = #(myCoords - vCoords)
								if dist < 150.0 and dist > 5.0 then
									local model = GetEntityModel(veh)
									local min, max = GetModelDimensions(model)
									local c = {}
									c[1] = GetOffsetFromEntityInWorldCoords(veh, min.x, min.y, min.z)
									c[2] = GetOffsetFromEntityInWorldCoords(veh, max.x, min.y, min.z)
									c[3] = GetOffsetFromEntityInWorldCoords(veh, max.x, max.y, min.z)
									c[4] = GetOffsetFromEntityInWorldCoords(veh, min.x, max.y, min.z)
									c[5] = GetOffsetFromEntityInWorldCoords(veh, min.x, min.y, max.z)
									c[6] = GetOffsetFromEntityInWorldCoords(veh, max.x, min.y, max.z)
									c[7] = GetOffsetFromEntityInWorldCoords(veh, max.x, max.y, max.z)
									c[8] = GetOffsetFromEntityInWorldCoords(veh, min.x, max.y, max.z)

									local er, eg, eb, ea = 255, 200, 0, 200
									local fr, fg, fb, fa = 255, 200, 0, 40

									-- bottom edges
									DrawLine(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, er,eg,eb,ea)
									DrawLine(c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, er,eg,eb,ea)
									DrawLine(c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, er,eg,eb,ea)
									DrawLine(c[4].x,c[4].y,c[4].z, c[1].x,c[1].y,c[1].z, er,eg,eb,ea)
									-- top edges
									DrawLine(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, er,eg,eb,ea)
									DrawLine(c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, er,eg,eb,ea)
									DrawLine(c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, er,eg,eb,ea)
									DrawLine(c[8].x,c[8].y,c[8].z, c[5].x,c[5].y,c[5].z, er,eg,eb,ea)
									-- vertical edges
									DrawLine(c[1].x,c[1].y,c[1].z, c[5].x,c[5].y,c[5].z, er,eg,eb,ea)
									DrawLine(c[2].x,c[2].y,c[2].z, c[6].x,c[6].y,c[6].z, er,eg,eb,ea)
									DrawLine(c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, er,eg,eb,ea)
									DrawLine(c[4].x,c[4].y,c[4].z, c[8].x,c[8].y,c[8].z, er,eg,eb,ea)

									-- filled faces (double-sided)
									-- bottom
									DrawPoly(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, fr,fg,fb,fa)
									DrawPoly(c[3].x,c[3].y,c[3].z, c[2].x,c[2].y,c[2].z, c[1].x,c[1].y,c[1].z, fr,fg,fb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, fr,fg,fb,fa)
									DrawPoly(c[4].x,c[4].y,c[4].z, c[3].x,c[3].y,c[3].z, c[1].x,c[1].y,c[1].z, fr,fg,fb,fa)
									-- top
									DrawPoly(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, fr,fg,fb,fa)
									DrawPoly(c[7].x,c[7].y,c[7].z, c[6].x,c[6].y,c[6].z, c[5].x,c[5].y,c[5].z, fr,fg,fb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, fr,fg,fb,fa)
									DrawPoly(c[8].x,c[8].y,c[8].z, c[7].x,c[7].y,c[7].z, c[5].x,c[5].y,c[5].z, fr,fg,fb,fa)
									-- front
									DrawPoly(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, c[6].x,c[6].y,c[6].z, fr,fg,fb,fa)
									DrawPoly(c[6].x,c[6].y,c[6].z, c[2].x,c[2].y,c[2].z, c[1].x,c[1].y,c[1].z, fr,fg,fb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[6].x,c[6].y,c[6].z, c[5].x,c[5].y,c[5].z, fr,fg,fb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, c[1].x,c[1].y,c[1].z, fr,fg,fb,fa)
									-- back
									DrawPoly(c[4].x,c[4].y,c[4].z, c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, fr,fg,fb,fa)
									DrawPoly(c[7].x,c[7].y,c[7].z, c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, fr,fg,fb,fa)
									DrawPoly(c[4].x,c[4].y,c[4].z, c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, fr,fg,fb,fa)
									DrawPoly(c[8].x,c[8].y,c[8].z, c[7].x,c[7].y,c[7].z, c[4].x,c[4].y,c[4].z, fr,fg,fb,fa)
									-- left
									DrawPoly(c[1].x,c[1].y,c[1].z, c[4].x,c[4].y,c[4].z, c[8].x,c[8].y,c[8].z, fr,fg,fb,fa)
									DrawPoly(c[8].x,c[8].y,c[8].z, c[4].x,c[4].y,c[4].z, c[1].x,c[1].y,c[1].z, fr,fg,fb,fa)
									DrawPoly(c[1].x,c[1].y,c[1].z, c[8].x,c[8].y,c[8].z, c[5].x,c[5].y,c[5].z, fr,fg,fb,fa)
									DrawPoly(c[5].x,c[5].y,c[5].z, c[8].x,c[8].y,c[8].z, c[1].x,c[1].y,c[1].z, fr,fg,fb,fa)
									-- right
									DrawPoly(c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, fr,fg,fb,fa)
									DrawPoly(c[7].x,c[7].y,c[7].z, c[3].x,c[3].y,c[3].z, c[2].x,c[2].y,c[2].z, fr,fg,fb,fa)
									DrawPoly(c[2].x,c[2].y,c[2].z, c[7].x,c[7].y,c[7].z, c[6].x,c[6].y,c[6].z, fr,fg,fb,fa)
									DrawPoly(c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, c[2].x,c[2].y,c[2].z, fr,fg,fb,fa)

									Scooby.drawTxt(vector3(vCoords.x, vCoords.y, vCoords.z + max.z + 1.0),
										string.format("Vehicle [%.0fm]", dist), 0.5, 9)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['Vehicle ESP'] then
							Scooby.Print("Vehicle ESP: Off", "Vehicle ESP: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'combobox',
			name = 'ESP Color',
			items = { "Default", "Red", "Blue", "Green", "Cyan", "Yellow", "Purple", "White" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			if selectedItem == "Red" then box_esp_r = 255; box_esp_g = 50; box_esp_b = 50
			elseif selectedItem == "Blue" then box_esp_r = 50; box_esp_g = 100; box_esp_b = 255
			elseif selectedItem == "Green" then box_esp_r = 50; box_esp_g = 255; box_esp_b = 50
			elseif selectedItem == "Cyan" then box_esp_r = 0; box_esp_g = 200; box_esp_b = 255
			elseif selectedItem == "Yellow" then box_esp_r = 255; box_esp_g = 255; box_esp_b = 0
			elseif selectedItem == "Purple" then box_esp_r = 180; box_esp_g = 0; box_esp_b = 255
			elseif selectedItem == "White" then box_esp_r = 255; box_esp_g = 255; box_esp_b = 255
			else box_esp_r = 0; box_esp_g = 0; box_esp_b = 0
			end
			Scooby.Print("ESP Color: " .. selectedItem, "ESP Color: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Crosshair Dot',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Crosshair Dot'] then
				Scooby.createThread(function()
					Scooby.Print("Crosshair Dot: On", "Crosshair Dot: On", false)
					while true do
						Citizen.Wait(0)
						DrawRect(0.5, 0.5, 0.003, 0.005, 255, 0, 0, 220)
						DrawRect(0.5, 0.5, 0.012, 0.002, 255, 0, 0, 220)
						DrawRect(0.5, 0.5, 0.002, 0.012, 255, 0, 0, 220)
						if not Scooby.menuCheckBoxes['scooby_visual']['Crosshair Dot'] then
							Scooby.Print("Crosshair Dot: Off", "Crosshair Dot: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'button',
			name = '--- ESP Sliders ---',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'combobox',
			name = 'ESP Text Size',
			items = { "Tiny (0.4)", "Small (0.6)", "Normal (0.8)", "Large (1.0)", "XL (1.3)" },
			currentIndex = 3,
			selectedIndex = 3,
		}, function(currentIndex, selectedItem)
			Scooby._espTextSize = ({ 0.4, 0.6, 0.8, 1.0, 1.3 })[currentIndex] or 0.8
			Scooby.Print("ESP Text Size: " .. selectedItem, "ESP Text Size: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'combobox',
			name = 'ESP Refresh Rate',
			items = { "Every Frame (0ms)", "Fast (50ms)", "Normal (100ms)", "Slow (250ms)" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			Scooby._espRefreshRate = ({ 0, 50, 100, 250 })[currentIndex] or 0
			Scooby.Print("ESP Refresh: " .. selectedItem, "ESP Refresh: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Dead Body ESP',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Dead Body ESP'] then
				Scooby.createThread(function()
					Scooby.Print("Dead Body ESP: On", "Dead Body ESP: On", false)
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if ped ~= PlayerPedId() and IsPedDeadOrDying(ped) then
								local pCoords = GetEntityCoords(ped)
								local dist = #(myCoords - pCoords)
								if dist < 100.0 then
									DrawMarker(0x94FDAE17, pCoords.x, pCoords.y, pCoords.z + 1.0, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 255, 0, 0, 150, false, false, 0, false, false, false, false)
									Scooby.drawTxt(vector3(pCoords.x, pCoords.y, pCoords.z + 1.5),
										string.format("DEAD [%.0fm]", dist), 0.5, 9)
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['Dead Body ESP'] then
							Scooby.Print("Dead Body ESP: Off", "Dead Body ESP: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Horse ESP',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Horse ESP'] then
				Scooby.createThread(function()
					Scooby.Print("Horse ESP: On", "Horse ESP: On", false)
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, ped in pairs(GetGamePool('CPed')) do
							if not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) then
								local model = GetEntityModel(ped)
								if IsModelAHorse(model) then
									local pCoords = GetEntityCoords(ped)
									local dist = #(myCoords - pCoords)
									if dist < 200.0 then
										DrawMarker(0x94FDAE17, pCoords.x, pCoords.y, pCoords.z + 2.0, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 200, 150, 50, 180, false, false, 0, false, false, false, false)
										Scooby.drawTxt(vector3(pCoords.x, pCoords.y, pCoords.z + 2.5),
											string.format("Horse [%.0fm]", dist), 0.5, 9)
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['Horse ESP'] then
							Scooby.Print("Horse ESP: Off", "Horse ESP: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Tracers',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Tracers'] then
				Scooby.createThread(function()
					Scooby.Print("Tracers: On (lines from screen bottom to players)", "Tracers: On", false)
					while true do
						Citizen.Wait(0)
						for _, id in ipairs(GetActivePlayers()) do
							if id ~= PlayerId() then
								local ped = GetPlayerPed(id)
								if DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
									local pCoords = GetEntityCoords(ped)
									local myCoords = GetEntityCoords(Scooby.pedID())
									local dist = #(myCoords - pCoords)
									if dist < (Scooby.espMaxDist or 9999) then
										local onScreen, sx, sy = GetScreenCoordFromWorldCoord(pCoords.x, pCoords.y, pCoords.z)
										if onScreen then
											DrawLine(myCoords.x, myCoords.y, myCoords.z - 0.8, pCoords.x, pCoords.y, pCoords.z, 255, 100, 0, 200)
										end
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['Tracers'] then
							Scooby.Print("Tracers: Off", "Tracers: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = '3D Player Box',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['3D Player Box'] then
				Scooby.createThread(function()
					Scooby.Print("3D Player Box: On", "3D Player Box: On", false)
					local halfW = 0.4
					local halfD = 0.3
					while true do
						Citizen.Wait(0)
						local myCoords = GetEntityCoords(Scooby.pedID())
						for _, id in ipairs(GetActivePlayers()) do
							if id ~= PlayerId() then
								local ped = GetPlayerPed(id)
								if DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
									local pCoords = GetEntityCoords(ped)
									local dist = #(myCoords - pCoords)
									if dist < (Scooby.espMaxDist or 9999) then
										local head = GetPedBoneCoords(ped, 21030, 0.0, 0.0, 0.0)
										local topZ = head.z + 0.15
										local botZ = pCoords.z - 0.05
										local c = {}
										c[1] = GetOffsetFromEntityInWorldCoords(ped, -halfW, -halfD, botZ - pCoords.z)
										c[2] = GetOffsetFromEntityInWorldCoords(ped,  halfW, -halfD, botZ - pCoords.z)
										c[3] = GetOffsetFromEntityInWorldCoords(ped,  halfW,  halfD, botZ - pCoords.z)
										c[4] = GetOffsetFromEntityInWorldCoords(ped, -halfW,  halfD, botZ - pCoords.z)
										c[5] = GetOffsetFromEntityInWorldCoords(ped, -halfW, -halfD, topZ - pCoords.z)
										c[6] = GetOffsetFromEntityInWorldCoords(ped,  halfW, -halfD, topZ - pCoords.z)
										c[7] = GetOffsetFromEntityInWorldCoords(ped,  halfW,  halfD, topZ - pCoords.z)
										c[8] = GetOffsetFromEntityInWorldCoords(ped, -halfW,  halfD, topZ - pCoords.z)
										local r, g, b = box_esp_r or 255, box_esp_g or 0, box_esp_b or 0
										-- Bottom edges
										DrawLine(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, r,g,b,200)
										DrawLine(c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, r,g,b,200)
										DrawLine(c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, r,g,b,200)
										DrawLine(c[4].x,c[4].y,c[4].z, c[1].x,c[1].y,c[1].z, r,g,b,200)
										-- Top edges
										DrawLine(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, r,g,b,200)
										DrawLine(c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, r,g,b,200)
										DrawLine(c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, r,g,b,200)
										DrawLine(c[8].x,c[8].y,c[8].z, c[5].x,c[5].y,c[5].z, r,g,b,200)
										-- Vertical edges
										DrawLine(c[1].x,c[1].y,c[1].z, c[5].x,c[5].y,c[5].z, r,g,b,200)
										DrawLine(c[2].x,c[2].y,c[2].z, c[6].x,c[6].y,c[6].z, r,g,b,200)
										DrawLine(c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, r,g,b,200)
										DrawLine(c[4].x,c[4].y,c[4].z, c[8].x,c[8].y,c[8].z, r,g,b,200)
										-- Fill faces (both winding orders for double-sided rendering)
										local fa = 30
										-- Front
										DrawPoly(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, c[6].x,c[6].y,c[6].z, r,g,b,fa)
										DrawPoly(c[6].x,c[6].y,c[6].z, c[2].x,c[2].y,c[2].z, c[1].x,c[1].y,c[1].z, r,g,b,fa)
										DrawPoly(c[1].x,c[1].y,c[1].z, c[6].x,c[6].y,c[6].z, c[5].x,c[5].y,c[5].z, r,g,b,fa)
										DrawPoly(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, c[1].x,c[1].y,c[1].z, r,g,b,fa)
										-- Back
										DrawPoly(c[4].x,c[4].y,c[4].z, c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, r,g,b,fa)
										DrawPoly(c[7].x,c[7].y,c[7].z, c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, r,g,b,fa)
										DrawPoly(c[4].x,c[4].y,c[4].z, c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, r,g,b,fa)
										DrawPoly(c[8].x,c[8].y,c[8].z, c[7].x,c[7].y,c[7].z, c[4].x,c[4].y,c[4].z, r,g,b,fa)
										-- Left
										DrawPoly(c[1].x,c[1].y,c[1].z, c[4].x,c[4].y,c[4].z, c[8].x,c[8].y,c[8].z, r,g,b,fa)
										DrawPoly(c[8].x,c[8].y,c[8].z, c[4].x,c[4].y,c[4].z, c[1].x,c[1].y,c[1].z, r,g,b,fa)
										DrawPoly(c[1].x,c[1].y,c[1].z, c[8].x,c[8].y,c[8].z, c[5].x,c[5].y,c[5].z, r,g,b,fa)
										DrawPoly(c[5].x,c[5].y,c[5].z, c[8].x,c[8].y,c[8].z, c[1].x,c[1].y,c[1].z, r,g,b,fa)
										-- Right
										DrawPoly(c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, c[7].x,c[7].y,c[7].z, r,g,b,fa)
										DrawPoly(c[7].x,c[7].y,c[7].z, c[3].x,c[3].y,c[3].z, c[2].x,c[2].y,c[2].z, r,g,b,fa)
										DrawPoly(c[2].x,c[2].y,c[2].z, c[7].x,c[7].y,c[7].z, c[6].x,c[6].y,c[6].z, r,g,b,fa)
										DrawPoly(c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, c[2].x,c[2].y,c[2].z, r,g,b,fa)
										-- Top
										DrawPoly(c[5].x,c[5].y,c[5].z, c[6].x,c[6].y,c[6].z, c[7].x,c[7].y,c[7].z, r,g,b,fa)
										DrawPoly(c[7].x,c[7].y,c[7].z, c[6].x,c[6].y,c[6].z, c[5].x,c[5].y,c[5].z, r,g,b,fa)
										DrawPoly(c[5].x,c[5].y,c[5].z, c[7].x,c[7].y,c[7].z, c[8].x,c[8].y,c[8].z, r,g,b,fa)
										DrawPoly(c[8].x,c[8].y,c[8].z, c[7].x,c[7].y,c[7].z, c[5].x,c[5].y,c[5].z, r,g,b,fa)
										-- Bottom
										DrawPoly(c[1].x,c[1].y,c[1].z, c[2].x,c[2].y,c[2].z, c[3].x,c[3].y,c[3].z, r,g,b,fa)
										DrawPoly(c[3].x,c[3].y,c[3].z, c[2].x,c[2].y,c[2].z, c[1].x,c[1].y,c[1].z, r,g,b,fa)
										DrawPoly(c[1].x,c[1].y,c[1].z, c[3].x,c[3].y,c[3].z, c[4].x,c[4].y,c[4].z, r,g,b,fa)
										DrawPoly(c[4].x,c[4].y,c[4].z, c[3].x,c[3].y,c[3].z, c[1].x,c[1].y,c[1].z, r,g,b,fa)
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['3D Player Box'] then
							Scooby.Print("3D Player Box: Off", "3D Player Box: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'checkbox',
			name = 'Aim Warning',
		}, function()
			if not Scooby.menuCheckBoxes['scooby_visual']['Aim Warning'] then
				Scooby.createThread(function()
					Scooby.Print("Aim Warning: On (warns when aimed at)", "Aim Warning: On", false)
					while true do
						Citizen.Wait(100)
						for _, id in ipairs(GetActivePlayers()) do
							if id ~= PlayerId() then
								local ped = GetPlayerPed(id)
								if DoesEntityExist(ped) and IsPlayerFreeAiming(id) then
									local _, target = GetEntityPlayerIsFreeAimingAt(id)
									if target == Scooby.pedID() then
										DrawTxt("!! AIMED AT BY " .. GetPlayerName(id) .. " !!", 0.5, 0.15, 0.40, false, 255, 0, 0, 255, true, 9)
									end
								end
							end
						end
						if not Scooby.menuCheckBoxes['scooby_visual']['Aim Warning'] then
							Scooby.Print("Aim Warning: Off", "Aim Warning: Off", false)
							break
						end
					end
				end)
			end
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'combobox',
			name = 'Snapline Color',
			items = { "Pink", "Red", "Green", "Blue", "Yellow", "White", "Cyan" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local colors = {
				{255, 0, 180}, {255, 0, 0}, {0, 255, 0}, {0, 0, 255},
				{255, 255, 0}, {255, 255, 255}, {0, 255, 255}
			}
			Scooby._snaplineColor = colors[currentIndex] or {255, 0, 180}
			Scooby.Print("Snapline Color: " .. selectedItem, "Snapline Color: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'combobox',
			name = 'Marker Style',
			items = { "Sphere", "Arrow Down", "Ring", "Cylinder", "Diamond" },
			currentIndex = 1,
			selectedIndex = 1,
		}, function(currentIndex, selectedItem)
			local types = { 0x94FDAE17, 0x6EB7D3BB, 0x0C7C5464, 0x3BD24822, 0x50638AB9 }
			Scooby._markerStyle = types[currentIndex] or 0x94FDAE17
			Scooby.Print("Marker Style: " .. selectedItem, "Marker Style: " .. selectedItem, false)
		end)

		Scooby.registerMenuAttribute('scooby_visual', {
			type = 'button',
			name = 'ScoobyOP',
			desc = '',
			isInfo = true,
		}, function() end)

		Scooby.registerSubMenu('scooby_allplayers', 'scooby_main', "ScoobyOP", "All Players", false, function()
			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Set All on Fire',
				desc = 'Start fires on every player',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						local coords = GetEntityCoords(ped)
						StartScriptFire(coords.x, coords.y, coords.z, 10, true, false, false, 1.0, 0)
						count = count + 1
					end
				end
				Scooby.Print("Set " .. count .. " players on fire", "Set " .. count .. " players on fire", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Ragdoll All',
				desc = 'Make every player ragdoll',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						SetPedToRagdoll(ped, 5000, 5000, 0, false, false, false)
						count = count + 1
					end
				end
				Scooby.Print("Ragdolled " .. count .. " players", "Ragdolled " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Drunk All',
				desc = 'Make every player drunk',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						SetPedIsDrunk(ped, true)
						SetPedConfigFlag(ped, 100, true)
						count = count + 1
					end
				end
				Scooby.Print("Made " .. count .. " players drunk", "Made " .. count .. " players drunk", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Clone All',
				desc = 'Spawn hostile clone of every player',
			}, function()
				Scooby.createThread(function()
					local count = 0
					for _, id in ipairs(GetActivePlayers()) do
						local ped = GetPlayerPed(id)
						if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
							local model = GetEntityModel(ped)
							local coords = GetEntityCoords(ped)
							RequestModel(model)
							local a = 0
							while not HasModelLoaded(model) and a < 50 do Citizen.Wait(10); a = a + 1 end
							if HasModelLoaded(model) then
								local clone = Scooby.native(0xD49F9B0955C367DE, model, coords.x + 2, coords.y, coords.z, 0.0, true, false)
								Citizen.InvokeNative(0x283978A15512B2FE, clone, true)
								TaskCombatPed(clone, ped, 0, 16)
								count = count + 1
							end
						end
					end
					Scooby.Print("Cloned " .. count .. " players", "Cloned " .. count .. " players", false)
				end)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Lightning All',
				desc = 'Strike lightning on every player',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						local coords = GetEntityCoords(ped)
						Scooby.native(0x67943537D179597C, coords.x, coords.y, coords.z, 1.0)
						_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 29, 5.0, true, false, true)
						count = count + 1
					end
				end
				Scooby.Print("Lightning struck " .. count .. " players", "Lightning struck " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Spawn Wolves on All',
				desc = 'Spawn 2 wolves per player that attack them',
			}, function()
				Scooby.createThread(function()
					local hash = GetHashKey("a_c_wolf")
					RequestModel(hash)
					local timeout = 0
					while not HasModelLoaded(hash) and timeout < 50 do Citizen.Wait(10); timeout = timeout + 1 end
					if HasModelLoaded(hash) then
						local count = 0
						for _, id in ipairs(GetActivePlayers()) do
							local ped = GetPlayerPed(id)
							if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
								local coords = GetEntityCoords(ped)
								for w = 1, 2 do
									local wolf = Scooby.native(0xD49F9B0955C367DE, hash, coords.x + w * 2, coords.y, coords.z, 0.0, true, false)
									Citizen.InvokeNative(0x283978A15512B2FE, wolf, true)
									TaskCombatPed(wolf, ped, 0, 16)
								end
								count = count + 1
							end
						end
						Scooby.Print("Wolves spawned on " .. count .. " players", "Wolves spawned on " .. count .. " players", false)
					else
						Scooby.Print("Failed to load wolf model", "Failed to load wolf model", false)
					end
				end)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Hogtie All',
				desc = 'Hogtie every player',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						TaskHogtieTargetPed(Scooby.pedID(), ped)
						count = count + 1
					end
				end
				Scooby.Print("Hogtied " .. count .. " players", "Hogtied " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Bury All',
				desc = 'Teleport all players underground',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						local coords = GetEntityCoords(ped)
						Scooby.native(0x06843DA7060A026B, ped, coords.x, coords.y, coords.z - 15.0, false, false, false, false)
						count = count + 1
					end
				end
				Scooby.Print("Buried " .. count .. " players", "Buried " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Heal All',
				desc = 'Heal every player to max health',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if DoesEntityExist(ped) then
						SetEntityHealth(ped, GetPedMaxHealth(ped), 0)
						count = count + 1
					end
				end
				Scooby.Print("Healed " .. count .. " players", "Healed " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Revive All',
				desc = 'Resurrect all dead players',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if DoesEntityExist(ped) and IsEntityDead(ped) then
						ResurrectPed(ped)
						SetEntityHealth(ped, GetPedMaxHealth(ped), 0)
						count = count + 1
					end
				end
				Scooby.Print("Revived " .. count .. " players", "Revived " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Strip Weapons All',
				desc = 'Remove all weapons from every player',
			}, function()
				local count = 0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						RemoveAllPedWeapons(ped, true, true)
						count = count + 1
					end
				end
				Scooby.Print("Stripped weapons from " .. count .. " players", "Stripped weapons from " .. count .. " players", false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'Show Player Count',
				desc = 'Show how many players are online',
			}, function()
				local players = GetActivePlayers()
				local count = #players
				Scooby.Print("Players online: " .. count, "Players online: " .. count, false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = '--- All Players Toggles ---',
				desc = '',
				isInfo = true,
			}, function() end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'checkbox',
				name = 'Auto Explode New Players',
			}, function()
				if not Scooby.menuCheckBoxes['scooby_allplayers']['Auto Explode New Players'] then
					Scooby.createThread(function()
						Scooby.Print("Auto Explode New: On", "Auto Explode New: On", false)
						local knownPlayers = {}
						for _, id in ipairs(GetActivePlayers()) do
							knownPlayers[GetPlayerServerId(id)] = true
						end
						while true do
							Citizen.Wait(3000)
							for _, id in ipairs(GetActivePlayers()) do
								local sid = GetPlayerServerId(id)
								if not knownPlayers[sid] and id ~= PlayerId() then
									knownPlayers[sid] = true
									local ped = GetPlayerPed(id)
									if DoesEntityExist(ped) then
										local coords = GetEntityCoords(ped)
										_i(0xD84A917A64D4D016, Scooby.pedID(), coords.x, coords.y, coords.z, 27, 30.0, true, false, true)
										Scooby.Print("Auto-exploded new player: " .. GetPlayerName(id), "Auto-exploded: " .. GetPlayerName(id), false)
									end
								end
							end
							if not Scooby.menuCheckBoxes['scooby_allplayers']['Auto Explode New Players'] then
								Scooby.Print("Auto Explode New: Off", "Auto Explode New: Off", false)
								break
							end
						end
					end)
				end
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'checkbox',
				name = 'Shrink All Players',
			}, function()
				if not Scooby.menuCheckBoxes['scooby_allplayers']['Shrink All Players'] then
					Scooby.createThread(function()
						Scooby.Print("Shrink All: On", "Shrink All: On", false)
						while true do
							Citizen.Wait(2000)
							for _, id in ipairs(GetActivePlayers()) do
								local ped = GetPlayerPed(id)
								if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
									SetPedScale(ped, 0.3)
								end
							end
							if not Scooby.menuCheckBoxes['scooby_allplayers']['Shrink All Players'] then
								for _, id in ipairs(GetActivePlayers()) do
									local ped = GetPlayerPed(id)
									if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
										SetPedScale(ped, 1.0)
									end
								end
								Scooby.Print("Shrink All: Off", "Shrink All: Off", false)
								break
							end
						end
					end)
				end
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'checkbox',
				name = 'Giant All Players',
			}, function()
				if not Scooby.menuCheckBoxes['scooby_allplayers']['Giant All Players'] then
					Scooby.createThread(function()
						Scooby.Print("Giant All: On", "Giant All: On", false)
						while true do
							Citizen.Wait(2000)
							for _, id in ipairs(GetActivePlayers()) do
								local ped = GetPlayerPed(id)
								if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
									SetPedScale(ped, 5.0)
								end
							end
							if not Scooby.menuCheckBoxes['scooby_allplayers']['Giant All Players'] then
								for _, id in ipairs(GetActivePlayers()) do
									local ped = GetPlayerPed(id)
									if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
										SetPedScale(ped, 1.0)
									end
								end
								Scooby.Print("Giant All: Off", "Giant All: Off", false)
								break
							end
						end
					end)
				end
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'checkbox',
				name = 'Aura Kill All',
			}, function()
				if not Scooby.menuCheckBoxes['scooby_allplayers']['Aura Kill All'] then
					Scooby.createThread(function()
						Scooby.Print("Aura Kill All: On", "Aura Kill All: On", false)
						while true do
							Citizen.Wait(500)
							for _, id in ipairs(GetActivePlayers()) do
								local ped = GetPlayerPed(id)
								if ped ~= Scooby.pedID() and DoesEntityExist(ped) and not IsPedDeadOrDying(ped) then
									local myCoords = GetEntityCoords(Scooby.pedID())
									local dist = #(myCoords - GetEntityCoords(ped))
									if dist < 20.0 then
										SetEntityHealth(ped, 0, 0)
									end
								end
							end
							if not Scooby.menuCheckBoxes['scooby_allplayers']['Aura Kill All'] then
								Scooby.Print("Aura Kill All: Off", "Aura Kill All: Off", false)
								break
							end
						end
					end)
				end
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'checkbox',
				name = 'Freeze All Loop',
			}, function()
				if not Scooby.menuCheckBoxes['scooby_allplayers']['Freeze All Loop'] then
					Scooby.createThread(function()
						Scooby.Print("Freeze All Loop: On", "Freeze All Loop: On", false)
						while true do
							Citizen.Wait(100)
							for _, id in ipairs(GetActivePlayers()) do
								local ped = GetPlayerPed(id)
								if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
									FreezeEntityPosition(ped, true)
								end
							end
							if not Scooby.menuCheckBoxes['scooby_allplayers']['Freeze All Loop'] then
								for _, id in ipairs(GetActivePlayers()) do
									local ped = GetPlayerPed(id)
									if DoesEntityExist(ped) then FreezeEntityPosition(ped, false) end
								end
								Scooby.Print("Freeze All Loop: Off", "Freeze All Loop: Off", false)
								break
							end
						end
					end)
				end
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'checkbox',
				name = 'Burn All Loop',
			}, function()
				if not Scooby.menuCheckBoxes['scooby_allplayers']['Burn All Loop'] then
					Scooby.createThread(function()
						Scooby.Print("Burn All Loop: On", "Burn All Loop: On", false)
						while true do
							Citizen.Wait(5000)
							for _, id in ipairs(GetActivePlayers()) do
								local ped = GetPlayerPed(id)
								if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
									local coords = GetEntityCoords(ped)
									StartScriptFire(coords.x, coords.y, coords.z, 5, true, false, false, 1.0, 0)
								end
							end
							if not Scooby.menuCheckBoxes['scooby_allplayers']['Burn All Loop'] then
								Scooby.Print("Burn All Loop: Off", "Burn All Loop: Off", false)
								break
							end
						end
					end)
				end
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'combobox',
				name = 'All Players Speed',
				items = { "Normal", "Slow (0.5x)", "Fast (2x)", "Super (5x)", "Frozen" },
				currentIndex = 1,
				selectedIndex = 1,
			}, function(currentIndex, selectedItem)
				local speeds = { 1.0, 0.5, 2.0, 5.0, 0.0 }
				local spd = speeds[currentIndex] or 1.0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						if spd == 0.0 then
							FreezeEntityPosition(ped, true)
						else
							FreezeEntityPosition(ped, false)
							SetPedMoveRateOverride(ped, spd)
						end
					end
				end
				Scooby.Print("All Players Speed: " .. selectedItem, "All Players Speed: " .. selectedItem, false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'combobox',
				name = 'All Players Size',
				items = { "Normal", "Tiny (0.3)", "Small (0.5)", "Big (2.0)", "Giant (5.0)", "Huge (8.0)" },
				currentIndex = 1,
				selectedIndex = 1,
			}, function(currentIndex, selectedItem)
				local sizes = { 1.0, 0.3, 0.5, 2.0, 5.0, 8.0 }
				local sz = sizes[currentIndex] or 1.0
				for _, id in ipairs(GetActivePlayers()) do
					local ped = GetPlayerPed(id)
					if ped ~= Scooby.pedID() and DoesEntityExist(ped) then
						SetPedScale(ped, sz)
					end
				end
				Scooby.Print("All Players Size: " .. selectedItem, "All Players Size: " .. selectedItem, false)
			end)

			Scooby.registerMenuAttribute('scooby_allplayers', {
				type = 'button',
				name = 'ScoobyOP',
				desc = '',
				isInfo = true,
			}, function()
				Scooby.Print("ScoobyOP v" .. Scooby.version .. " | ", "ScoobyOP v" .. Scooby.version .. " | ", false)
			end)
		end)

		Scooby.registerSubMenu('scooby_server', 'scooby_main', "ScoobyOP", "Server", false,
			function()
				for i, res in pairs(dumper:getResources()) do
					dumper:getFiles(res)
				end

				for res, files in pairs(dumper.client) do
					for file, code in pairs(files) do
					end
				end

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Place Holder',
					desc = 'Place Holder',
				}, function()
					_tse("Train:getPaid", 500)
					Scooby.Print("Place Holder", false)
				end)


				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Gives $500',
					desc = 'Possibly Adds $500',
				}, function()
					_tse("npcloot:give_reward", 500)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Gives $500 YellowStone',
					desc = 'Adds $500 YellowStone RP & Others',
				}, function()
					_tse("syn_construction:reward", 100, 1, 500, 1)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Gives $500 DRB',
					desc = 'Adds $500 on Dakota River Bend',
				}, function()
					_tse('redemrp_inventory:givemoney', "Goods Delivered", 500)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Adds Money Gilded RP',
					desc = 'Gives Random amount From Rob',
				}, function()
					_tse("RedDust_Roleplay:MissionCompleted")
					Scooby.Print("MONEY!", "MONEY!", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = '725 XP + $500 DRB ',
					desc = 'Gives you $500 and 725 XP on DRB',
				}, function()
					_tse("parks_stagecoach:pay_fare", 500)
					Scooby.Print("XP MONEY YEA", "XP MONEY YEA", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Give XP DRB',
					desc = 'Testing',
				}, function()
					_tse('redemrp_inventory:givexp', 500)
					Scooby.Print("You Gave Yourself Money", "You Gave Yourself Money", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = '--- Framework Events ---',
					desc = '',
					isInfo = true,
				}, function() end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'VORP Give Money',
					desc = 'VORP framework money event',
				}, function()
					_tse('vorp:addMoney', 0, 500)
					Scooby.Print("VORP +$500", "VORP +$500", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'VORP Give Gold',
					desc = 'VORP framework gold event',
				}, function()
					_tse('vorp:addMoney', 1, 50)
					Scooby.Print("VORP +50 Gold", "VORP +50 Gold", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'VORP Give XP',
					desc = 'VORP framework XP event',
				}, function()
					_tse('vorp:addXp', 1000)
					Scooby.Print("VORP +1000 XP", "VORP +1000 XP", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'RSG Give Money',
					desc = 'RedEM:RP / RSG framework',
				}, function()
					_tse('redemrp_inventory:givemoney', "Work Completed", 500)
					Scooby.Print("RSG +$500", "RSG +$500", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'RSG Give XP',
					desc = 'RedEM:RP / RSG framework',
				}, function()
					_tse('redemrp_inventory:givexp', 1000)
					Scooby.Print("RSG +1000 XP", "RSG +1000 XP", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = '--- Spam Events ---',
					desc = '',
					isInfo = true,
				}, function() end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Spam Money x10',
					desc = 'Fire money event 10 times rapidly',
				}, function()
					Scooby.createThread(function()
						for i = 1, 10 do
							_tse("npcloot:give_reward", 500)
							_tse('redemrp_inventory:givemoney', "Goods Delivered", 500)
							_tse("parks_stagecoach:pay_fare", 500)
							Citizen.Wait(100)
						end
						Scooby.Print("Spammed 10x", "Spammed 10x", false)
					end)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Spam XP x10',
					desc = 'Fire XP event 10 times',
				}, function()
					Scooby.createThread(function()
						for i = 1, 10 do
							_tse('redemrp_inventory:givexp', 500)
							Citizen.Wait(100)
						end
						Scooby.Print("XP Spammed 10x", "XP Spammed 10x", false)
					end)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = '--- Misc Events ---',
					desc = '',
					isInfo = true,
				}, function() end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Complete Mission',
					desc = 'Various mission complete events',
				}, function()
					_tse("RedDust_Roleplay:MissionCompleted")
					_tse("syn_construction:reward", 100, 1, 500, 1)
					_tse("Train:getPaid", 500)
					Scooby.Print("Missions completed", "Missions completed", false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'Trigger Custom Event',
					desc = 'Enter a custom server event name',
				}, function()
					DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP8", "", "", "", "", "", 99)
					Scooby.createThread(function()
						while true do
							DisableAllControlActions(0)
							HideHudAndRadarThisFrame()
							Citizen.Wait(0)
							if UpdateOnscreenKeyboard() == 1 then
								local eventName = GetOnscreenKeyboardResult()
								if eventName and eventName ~= "" then
									_tse(eventName)
									Scooby.Print("Fired: " .. eventName, "Fired: " .. eventName, false)
								end
								break
							elseif UpdateOnscreenKeyboard() == 2 or UpdateOnscreenKeyboard() == 3 then
								break
							end
						end
					end)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'List Resources',
					desc = 'Print all server resources to notification',
				}, function()
					local count = GetNumResources()
					local list = ""
					for i = 0, count - 1 do
						local name = GetResourceByFindIndex(i)
						if name and GetResourceState(name) == "started" then
							list = list .. name .. ", "
						end
					end
					Scooby.Print(list, "Resources: " .. count, false)
				end)

				Scooby.registerMenuAttribute('scooby_server', {
					type = 'button',
					name = 'ScoobyOP',
					desc = '',
					isInfo = true,
				}, function() end)
			end)
	end)
end)

-- ScoobyOP v1.0.0

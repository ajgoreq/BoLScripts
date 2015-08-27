
local version = "1.0"


if myHero.charName ~= "Katarina" then return end



local e = {}

lastE = 0
eDelay = 3500 -- 3,5 seconds

local wardNames = {"TrinketTotemLvl1", "TrinketTotemLvl2", "TrinketTotemLvl3", "TrinketTotemLvl3B", "sightward", "VisionWard"}
castAt = 0
local champs = {Katarina = {_E}}
local Wrange = 400
local Erange = 700
local Qrange = 675
local Rrange = 490
local ignite = nil
local iDMG = 0

local ignite, iDMG = nil, 0 
local QREADY, WREADY, EREADY, RREADY = false


function OnLoad()
ForceTarget = nil lastAttack = 0 previousAttackCooldown = 0 previousWindUp = 0 ultOn = 0 
NoxusKiller()
 

IgniteSet()
Variables()

AddMsgCallback(CustomOnWndMsg)
AddDrawCallback(CustomOnDraw)		
AddProcessSpellCallback(CustomOnProcessSpell)
	AddTickCallback(CustomOnTick)
	
for i, enemy in ipairs(GetEnemyHeroes()) do
		table.insert(e, enemy)
	end

 	myChamp = champs[myHero.charName]
	
	minionTable = {}
        for i = 0, objManager.maxObjects do
                local obj = objManager:GetObject(i)
                if obj ~= nil and obj.type ~= nil and obj.type == "obj_AI_Minion" then
                        table.insert(minionTable, obj)
                end
        end
	end
function NoxusKiller()


Config = scriptConfig("Katarina - Noxus Killer", "NoxusKiller")

Config:addSubMenu("Key Settings", "Keys")
Config.Keys:addParam("combokey", "Combo key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config.Keys:addParam("harass", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, 67)
Config.Keys:addParam("farmkey", "Farm On/Off", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("Z"))
Config.Keys:addParam("WardJump", "Ward Jump", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
Config.Keys:addParam("MovetoMouseactive", "Move To Mouse Active", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("B"))


Config:addSubMenu("Combo Settings", "Combo")
Config.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true) 
Config.Combo:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true) 
Config.Combo:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true)
Config.Combo:addParam("UseAA", "Use AutoAttack", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Misc", "Misc")
Config.Misc:addParam("KSIG", "Auto KS using ignite", SCRIPT_PARAM_ONOFF, true)

if VIP_USER then
Config:addSubMenu("Packets", "Packets")
Config.Packets:addParam("QPACK", "Q Packets", SCRIPT_PARAM_ONOFF, false)
Config.Packets:addParam("WPACK", "W Packets", SCRIPT_PARAM_ONOFF, false)
Config.Packets:addParam("EPACK", "E Packets", SCRIPT_PARAM_ONOFF, false)
end
Config:addSubMenu("Drawings", "Draw")
Config.Draw:addParam("drawDD", "Draw Dmg Text", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("DrawQ", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("DrawW", "Draw W range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("DrawE", "Draw E range", SCRIPT_PARAM_ONOFF, true)

Config:addSubMenu("Farm", "farm")
Config.farm:addParam("UseQFarm", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.farm:addParam("UseWFarm", "Use W", SCRIPT_PARAM_ONOFF, false)


Config:addParam("info4", " >> Version ", SCRIPT_PARAM_INFO, "1.0")


ts = TargetSelector(TARGET_LESS_CAST, 700, DAMAGE_MAGICAL, false, true) 
enemyMinions = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
ts.name = "Noxus"
Config:addSubMenu("Target Selector", "TS")
Config.TS:addTS(ts)

end

function OnTick()

if Config.Keys.WardJump and myHero:CanUseSpell(myChamp[1]) == READY then
		local slot = GetWardSlot()
		if slot and os.clock() > castAt + 1 then
			local pos = GetDistance(mousePos) <= 600 and mousePos or GetFurthest()
			CastSpell(slot, pos.x, pos.z)
			castAt = os.clock()
		end
		if myWard then CastSpell(myChamp[1], myWard) myWard = nil end
	end

Checks()
IgniteKS()
Human()

if not ulti then
ts:update()
end
killstring = {}
	-----Combo-----
	if Config.Keys.combokey then
	Combo()
	end
	----Harass-----
	if Config.Keys.harass then
	Harass()
	end
	---Farm-----
	if Config.Keys.farmkey then
	Farm()
	end
mtm()
end



function OnDraw()
if Config.Keys.farmkey then
DrawText("Farm: ON", 18, 100, 100, 0xFFFF0000)
else
DrawText("Farm: OFF", 18, 100, 100, 0xFFFF0000)
end
if Config.Draw.DrawQ and QREADY and not myHero.dead then 
DrawCircle(myHero.x, myHero.y, myHero.z, Qrange, 0x00FF00)
end
if Config.Draw.DrawW and WREADY and not myHero.dead then 
DrawCircle(myHero.x, myHero.y, myHero.z, Wrange, 0x00FF00)
end
if Config.Draw.DrawE and EREADY and not myHero.dead then 
DrawCircle(myHero.x, myHero.y, myHero.z, Erange, 0x00FF00)
	end
	
	 for i,minionObject in ipairs(minionTable) do
                if minionObject.dead == true or minionObject.team == myHero.team then
                        table.remove(minionTable, i)
                        i = i - 1
                elseif minionObject ~= nil and myHero:GetDistance(minionObject) ~= nil and myHero:GetDistance(minionObject) < 1500 and minionObject.health ~= nil and minionObject.health <= myHero:CalcDamage(minionObject, myHero.addDamage+myHero.damage) and minionObject.visible ~= nil and minionObject.visible == true then
                        for g = 0, 6 do
                                DrawCircle(minionObject.x, minionObject.y, minionObject.z,80 + g,255255255)
                        end
        end
    end
end

function Variables()

allyHeroes = GetAllyHeroes()
enemyHeroes = GetEnemyHeroes()
enemyMinions = minionManager(MINION_ENEMY, Erange, player, MINION_SORT_HEALTH_ASC)
allyMinions = minionManager(MINION_ALLY, Erange, player, MINION_SORT_HEALTH_ASC)

end

function Checks()

target = ts.target 
if Forcetarget ~= nil and ValidTarget(Forcetarget, 900) then 
		target = Forcetarget 
	end 

allyMinions:update()

QREADY = (myHero:CanUseSpell(_Q) == READY)
WREADY = (myHero:CanUseSpell(_W) == READY) 
EREADY = (myHero:CanUseSpell(_E) == READY)
RREADY = (myHero:CanUseSpell(_R) == READY)
IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY) 
end

function Combo()

	if ValidTarget(target) then
	
CastQ()
CastE()
CastW()
CastR()
AA()
	end
end

function AA()
if Config.Combo.UseAA then
if target and GetDistance(target) < myHero.range+myHero.boundingRadius+target.boundingRadius+25 and timeToShoot() and not ultOn then 
				myHero:Attack(target) 
			end 
	end 				
end

function CastQ()
				if QREADY and Config.Combo.UseQ then 
		if GetDistance(target) <= Qrange then
	if VIP_USER and Config.Packets.QPACK then
	Packet("S_CAST", {spellId = _Q, targetNetworkId = target.networkID}):send()
	else
	CastSpell(_Q, target) 
			end
		end
	end
end

function CastW()
	if WREADY and Config.Combo.UseW then
	if GetDistance(target) <= Wrange then
	if VIP_USER and Config.Packets.WPACK then
	Packet("S_CAST", {spellId = _W, targetNetworkId = target.networkID}):send()
	else
		CastSpell(_W)
			end
		end
	end
end
function CastE()
			if EREADY and Config.Combo.UseE then
		if GetDistance(target) <= Erange then 
	if VIP_USER and Config.Packets.EPACK then
	Packet("S_CAST", {spellId = _E, targetNetworkId = target.networkID}):send()
	else
	CastSpell(_E, target)
			end
		end
	end
end

function CastR()
		if RREADY and not QREADY and not WREADY and not EREADY and Config.Combo.UseR then
	if GetDistance(target) <= Rrange then
	CastSpell(_R)
		end
	end
end


function AutoIgnite(enemy)
iDmg = ((IREADY and getDmg("IGNITE", enemy, myHero)) or 0)
if enemy.health <= iDmg and GetDistance(enemy) <= 600 and ignite ~= nil then
if IREADY then CastSpell(ignite, enemy) end 
end
end

function IgniteSet()

if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
ignite = SUMMONER_1 
elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then
ignite = SUMMONER_2 
end
end



function IgniteKS()
if ValidTarget(target) then
if not RREADY then
if Config.Misc.KSIG then
AutoIgnite(target)
   end
  end
 end
end



function Harass()

if ValidTarget(target) then
if QREADY and GetDistance(target) < Qrange then
CastSpell(_Q, target)
		end
	end
end

function Farm()
enemyMinions:update()
		for i, minion in ipairs(enemyMinions.objects) do
	if Config.farm.UseQFarm then
	if ValidTarget(minion) and GetDistance(minion) <= Qrange and QREADY and getDmg("Q", minion, myHero) > minion.health then
CastSpell(_Q, minion)
			end
		end
	end
	
	for i, minion in ipairs(enemyMinions.objects) do
if Config.farm.UseWFarm then
if ValidTarget(minion) and GetDistance(minion) <= Wrange and WREADY and getDmg("W", minion, myHero) > minion.health then
CastSpell(_W)
			end
		end
	end
end



function getHitBoxRadius(target)
return GetDistance(target.minBBox, target.maxBBox)/2
end


function Human()

if lastE + eDelay > GetTickCount() then
lastE = GetTickCount()
Combo()
	end
end
	
--ULTI	
function OnAnimation(Unit, Animation)
if Unit.isMe and (Animation == "Spell4" or Animation == "Spell4_Loop") then
ulti = true
AnimTrack = GetTickCount() + 50 + GetLatency()
else
ulti = false
    end
end

 
function OnCreateObj(object)
        if object ~= nil and object.type ~= nil and object.type == "obj_AI_Minion" then table.insert(minionTable, object) end
end

function IsChanneling()
return AnimTrack > GetTickCount()
end
 
 function timeToShoot() 
	return (GetTickCount() + GetLatency()/2 > lastAttack + previousAttackCooldown) and (ultOn < GetInGameTimer() or target.dead) 
end 

function heroCanMove() 
	return (GetTickCount() + GetLatency()/2 > lastAttack + previousWindUp + 50) and (ultOn < GetInGameTimer() or target.dead) 
end 
 
function OnWndMsg(Msg, Key) 
	if Msg == WM_LBUTTONDOWN then 
		local minD = 0 
		local starget = nil 
		for i, enemy in ipairs(GetEnemyHeroes()) do 
			if ValidTarget(enemy) then 
				if GetDistance(enemy, mousePos) <= minD or starget == nil then minD = GetDistance(enemy, mousePos) starget = enemy 
				end 
			end 
		end 
		if starget and minD < 500 then 
			if Forcetarget and starget.charName == Forcetarget.charName then 
				Forcetarget = nil 
			else 
				Forcetarget = starget 
				
			end 
		end 
	end
end

function OnCreateObj(obj)
	if obj.name:lower():find("ward") and obj.team == myHero.team and os.clock() < castAt + 0.5 then	myWard = obj end
end

function GetWardSlot()
	for _, wardName in ipairs(wardNames) do
		for slot = ITEM_1, ITEM_7 do
			if wardName == myHero:GetSpellData(slot).name and myHero:CanUseSpell(slot) == READY then return slot end
		end
	end
end

function GetFurthest()
	MyPos = Vector(myHero.x, myHero.y, myHero.z)
	return MyPos - (MyPos - Vector(mousePos.x, mousePos.y, mousePos.z)):normalized() * 600
end

function mtm()
if Config.Keys.MovetoMouseactive and Config.Keys.combokey and not ulti then
myHero:MoveTo(mousePos.x, mousePos.z)
 end
end
print("<font color=\"#FF0000\">Noxus Killer Katarina Activated.</font>")

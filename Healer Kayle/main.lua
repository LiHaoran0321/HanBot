local version = "1.1"
--[[

  _   _            _             _  __           _      
 | | | | ___  __ _| | ___ _ __  | |/ /__ _ _   _| | ___ 
 | |_| |/ _ \/ _` | |/ _ \ '__| | ' // _` | | | | |/ _ \
 |  _  |  __/ (_| | |  __/ |    | . \ (_| | |_| | |  __/
 |_| |_|\___|\__,_|_|\___|_|    |_|\_\__,_|\__, |_|\___|
                                           |___/        

(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧

version 1.0 - released
1.1 - added jungle and lane clear
]]



local evade = module.seek("evade")


local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerKayle", "common")



local spellQ = {range = 650}

local spellW = {range = 900}

local spellE = {range = 525}

local spellR = {range = 900}


local menu = menu("Kayle", "Healer Kayle")

menu:menu("combo", "Combo Settings")
		
menu.combo:boolean("qcombo", "Use Q", true)
menu.combo:boolean("wcombo", "Use W", true)
menu.combo:boolean("waa", " W only when in AA Range", true)
menu.combo:boolean("ecombo", "Use E", true)

menu:menu("harass", "Harass Settings")

menu.harass:boolean("qharass", "Use Q", true)
menu.harass:boolean("eharass", "Use E", true)


menu:menu("wpriority", "W Healing") -- Credits to Kornis!
menu.wpriority:boolean("enable", "Enable Auto W", true)
menu.wpriority:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if allies.charName == "Kayle" then
		menu.wpriority:slider(allies.charName, "Priority: " .. allies.charName, 5, 0, 5, 1)
		menu.wpriority:slider(allies.charName .. "hp", " ^- Health Percent: ", 50, 1, 100, 1)
	else
		menu.wpriority:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
		menu.wpriority:slider(allies.charName .. "hp", " ^- Health Percent: ", 50, 1, 100, 1)
	end
end

menu:menu("rset", "R Settings")
menu.rset:boolean("r", "Use R", true)
menu.rset:slider("ronx", "R when enemies in Range", 1, 0, 5, 1)
menu.rset:slider("ronhp", "What HP% to Ult", 20, 0, 100, 5)
		
menu.rset:boolean("rally", "Use R for Ally", true)
menu.rset:menu("yikes", "Ally Selection")
		for i = 0, objManager.allies_n - 1 do
			local ally = objManager.allies[i]
			if ally ~= player then
				menu.rset.yikes:boolean(ally.charName, "Use R on: "..ally.charName, false)
			end 
		end
menu.rset:slider("allyhp", "HP% to press R on Ally", 15, 0, 100, 5)


menu:menu("laneclear", "Lane Clear")
menu.laneclear:boolean("lanee", "Use E in Lane Clear", true)


menu:menu("jungleclear", "Jungle Clear")
menu.jungleclear:boolean("usee", "Use E in Jungle Clear", true)



menu:menu("draws", "Draw Settings")
		menu.draws:boolean("q", "Draw Q Range", true)
		menu.draws:boolean("e", "Draw E Range", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

local function PrioritizedAllyW() --Credits to Kornis!
	if menu.wpriority.enable:get() then
		local heroTarget = nil
		for i = 0, objManager.allies_n - 1 do
			local hero = objManager.allies[i]
			if not player.isRecalling then
				if
					hero.team == TEAM_ALLY and not hero.isDead and menu.wpriority[hero.charName]:get() > 0 and
						hero.pos:dist(player.pos) <= spellW.range and
						not hero.isRecalling and
						menu.wpriority[hero.charName .. "hp"]:get() >= (hero.health / hero.maxHealth) * 100
				 then
					if heroTarget == nil then
						heroTarget = hero
					elseif menu.wpriority[hero.charName]:get() < menu.wpriority[heroTarget.charName]:get() then
						heroTarget = hero
					end
				end
			end
		end
		return heroTarget
	end
end



local TargetSelection = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end

local GetTarget = function()
	return TS.get_result(TargetSelection).obj
end
local TargetSelectionFQ = function(res, obj, dist)
	if dist < spellQ.range + 380 then
		res.obj = obj
		return true
	end
end
local GetTargetFQ = function()
	return TS.get_result(TargetSelectionFQ).obj
end

local TargetSelectionE = function(res, obj, dist)
	if dist < spellE.range then
		res.obj = obj
		return true
	end
end
local GetTargetE = function()
	return TS.get_result(TargetSelectionE).obj
end
local TargetSelectionW = function(res, obj, dist)
	if dist < spellW.range then
		res.obj = obj
		return true
	end
end

local GetTargetW = function()
	return TS.get_result(TargetSelectionW).obj
end


local TargetSelectionQ = function(res, obj, dist)
	if dist < spellQ.range then
		res.obj = obj
		return true
	end
end
local GetTargetQ = function()
	return TS.get_result(TargetSelectionQ).obj
end

local TargetSelectionR = function(res, obj, dist)
	if dist < spellR.range then
		res.obj = obj
		return true
	end
end

local GetTargetR = function()
	return TS.get_result(TargetSelectionR).obj
end

local function count_enemies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.enemies_n - 1 do
		local enemy = objManager.enemies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end
local function count_allies_in_range(pos, range)
	local enemies_in_range = {}
	for i = 0, objManager.allies_n - 1 do
		local enemy = objManager.allies[i]
		if pos:dist(enemy.pos) < range and common.IsValidTarget(enemy) then
			enemies_in_range[#enemies_in_range + 1] = enemy
		end
	end
	return enemies_in_range
end

local QLevelDamage = {60, 110, 160, 210, 260}

local function QDamage(target)
  local damage = QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * 0.6)
  local damage2 = (common.GetBonusAD() * 1)
  	return common.CalculatePhysicalDamage(target, damage2) + common.CalculateMagicDamage(target, damage)
end

local EPassiveDamage = {10, 15, 20, 25, 30} --I dont even know with these E damages... i tried making the orbwalker see the damage of e and count that aswell when farming but i must be doing something wrong or im just stupid and theres no way to actually make it work. Either way thanks for reading this dear person, that took their precious time of the day to read my dumb ramble, because im frustruated and i really wanted to make it work but i couldnt... Right now all im doing is listening "Jesus Oh What a Wonderful Child" on repeat by Mariah Carey to calm myself down, nice bop tho, would recommend listening. I like how Mariahs voice is so jazzy in this song and how the choir in the background makes it sound so cool that i cant focus on coding this script... But anyways thanks for your time and good bye!     
function EPasDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (EPassiveDamage[player:spellSlot(2).level] + (common.GetTotalAP() * 0.15)), player)
	end
	return damage + common.CalculateAADamage(target)
end


local ELevelDamage = {20, 30, 40, 50, 60}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 --[[ and common.CheckBuff(player, "JudicatorRighteousFury") ]] then
		damage =
			common.CalculateMagicDamage(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * 0.3)), player)
	end
	return damage + common.CalculateAADamage(target)
end

local function Combo()
	local target = GetTarget()
	if menu.combo.ecombo:get() then
		local target = GetTargetE()
		if common.IsValidTarget(target) and target then
			if target.pos:dist(player.pos) <= 525 then
					player:castSpell("self", 2)
				
			end
		end
	end

	if menu.combo.wcombo:get() then
		local target = GetTargetW()
		if common.IsValidTarget(target) and target then
			if not menu.combo.waa:get() then
				player:castSpell("self", 1)
			end
			if menu.combo.waa:get() then
				if target.pos:dist(player.pos) <= 600 then
					player:castSpell("self", 1)
				end
			end
		end
	end
	if menu.combo.qcombo:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				
					player:castSpell("obj", 0, target)
			end
		end
	end

	
end
local function Harass()
	local target = GetTarget()
	if menu.harass.qharass:get() then
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player) <= spellQ.range) then
				
					player:castSpell("obj", 0, target)
			end
		end
	end
	if menu.harass.eharass:get() then
		local target = GetTargetE()
		if common.IsValidTarget(target) and target then
			if target.pos:dist(player.pos) <= 525 then
					player:castSpell("self", 2)
				
			end
		end
	end
end
local function AutoR() 
	if player:spellSlot(3).state ~= 0 then
	 return 
	end
	if menu.rset.r:get() and #common.GetEnemyHeroesInRange(600) >= menu.rset.ronx:get() and common.GetPercentHealth(player) <= menu.rset.ronhp:get() then
		player:castSpell("obj", 3, player)
	end
end

local function AutoRAlly()
	if menu.rset.rally:get() then
		for i = 0, objManager.allies_n - 1 do
			local ally = objManager.allies[i]
			if player:spellSlot(3).state == 0 and ally and not ally.isDead and not player.isDead and ally.pos:dist(player.pos) <= 900 and common.GetPercentHealth(ally) <= menu.rset.allyhp:get() and #common.GetEnemyHeroesInRange(600, ally.pos) >= 1 then
				if menu.rset.yikes[ally.charName] and menu.rset.yikes[ally.charName]:get() and common.GetPercentHealth(player) > common.GetPercentHealth(ally) then
					player:castSpell("obj", 3, ally)
				end
			end
		end
	end
end

local function JungleClear()
	if menu.jungleclear.usee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				player:castSpell("self", 2)
			end
		end
	end
end

local function LaneClear()
	if menu.laneclear.lanee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_ENEMY] - 1 do
			local minion = objManager.minions[TEAM_ENEMY][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				player:castSpell("self", 2)
			end
		end
	end
end
local function OnTick()
	if PrioritizedAllyW() then
		player:castSpell("obj", 1, PrioritizedAllyW())
	end

	AutoRAlly()
	AutoR()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.clearkey:get() then
		LaneClear()
		JungleClear()
	end
end

local function OnDraw()
	if not player.isDead and player.isOnScreen then
		if menu.draws.q:get() and player:spellSlot(0).state == 0 then
      		graphics.draw_circle(player.pos, 650, 2, graphics.argb(255, 255, 255, 255), 50)
    	end
    	if menu.draws.e:get() then
      		graphics.draw_circle(player.pos, common.GetAARange(player)-80, 2, graphics.argb(255, 255, 255, 255), 50)
    	end
  	end
end


TS.load_to_menu(menu)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
print("-------------------------------------------------")
print("Healer Kayle v"..version..": Loaded!")
print("Check the forums if you have the latest version!")
print("-------------------------------------------------")

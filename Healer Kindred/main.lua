local version = "1.0"
--[[


  _    _            _             _  ___           _              _ 
 | |  | |          | |           | |/ (_)         | |            | |
 | |__| | ___  __ _| | ___ _ __  | ' / _ _ __   __| |_ __ ___  __| |
 |  __  |/ _ \/ _` | |/ _ \ '__| |  < | | '_ \ / _` | '__/ _ \/ _` |
 | |  | |  __/ (_| | |  __/ |    | . \| | | | | (_| | | |  __/ (_| |
 |_|  |_|\___|\__,_|_|\___|_|    |_|\_\_|_| |_|\__,_|_|  \___|\__,_|
                                                                    
                                                                    

(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:


Thanks to Korins for teaching me how to properly add aa resets!

version 1.0 - released
]]



local evade = module.seek("evade")


local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerKindred", "common")



local spellQ = {
	range = 800,
	speed = math.huge,
	width = 45,
	delay = 0,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = false,
		wall = false
	}
}

local spellW = {range = 750}

local spellE = {range = 720}

local spellR = {range = 500}


local menu = menu("Kindred", "Healer Kindred")

menu:menu("combo", "Combo Settings")
		
menu.combo:boolean("qcombo", "Use Q", true)
menu.combo:boolean("wcombo", "Use W", true)
menu.combo:boolean("waa", " W only when in AA Range", true)
menu.combo:boolean("ecombo", "Use E", true)

menu:menu("harass", "Harass Settings")

menu.harass:boolean("qharass", "Use Q", true)
menu.harass:boolean("wharass", "Use W", true)
menu.harass:boolean("hwaa", "W only in AA range", true)
menu.harass:boolean("eharass", "Use E", false)



menu:menu("rset", "R Settings")
menu.rset:boolean("r", "Use R", true)
menu.rset:slider("ronx", "R when enemies in Range", 1, 0, 5, 1)
menu.rset:slider("ronhp", "What HP% to Ult", 20, 0, 100, 5)
		
menu.rset:boolean("rally", "Use R for Ally (not recommended)", false)
menu.rset:menu("yikes", "Ally Selection")
		for i = 0, objManager.allies_n - 1 do
			local ally = objManager.allies[i]
			if ally ~= player then
				menu.rset.yikes:boolean(ally.charName, "Use R on: "..ally.charName, false)
			end 
		end
menu.rset:slider("allyhp", "HP% to press R on Ally", 15, 0, 100, 5)

menu:menu("jungleclear", "Jungle Clear")
menu.jungleclear:boolean("useq", "Use Q in Jungle Clear", true)
menu.jungleclear:boolean("usew", "Use W in Jungle Clear", true)
menu.jungleclear:boolean("usee", "Use E in Jungle Clear", true)

menu:menu("draws", "Draw Settings")
		menu.draws:boolean("q", "Draw Q Range", false)
		menu.draws:boolean("e", "Draw E Range", false)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)



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


orb.combat.register_f_after_attack(
	function()
		if menu.keys.combokey:get() then
			if orb.combat.target then
				if
					menu.combo.qcombo:get() and orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < 800
				 then
					local pos = preds.linear.get_prediction(spellQ, orb.combat.target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
									if player:spellSlot(0).state == 0 then
							player:castSpell("pos", 0, mousePos)
							orb.core.reset()
							orb.combat.set_invoke_after_attack(false)
							return "on_after_attack_hydra"
						end
					end
				end
			end
		end

		if menu.keys.harasskey:get() then
			if orb.combat.target then
				if
					 menu.harass.qharass:get() and orb.combat.target and common.IsValidTarget(orb.combat.target) and
						player.pos:dist(orb.combat.target.pos) < 800
				 then
					local pos = preds.linear.get_prediction(spellQ, orb.combat.target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
									if player:spellSlot(0).state == 0 then
							player:castSpell("pos", 0, mousePos)
							orb.core.reset()
							orb.combat.set_invoke_after_attack(false)
							return "on_after_attack_hydra"
						end
					end
				end
			end
		end




		if menu.keys.clearkey:get() then
			
				if menu.jungleclear.useq:get() and player:spellSlot(0).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]

			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead then
					local pos = preds.linear.get_prediction(spellQ, minion)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								
				
							player:castSpell("pos", 0, mousePos)
							orb.core.reset()
							orb.combat.set_invoke_after_attack(false)
							return "on_after_attack_hydra"
						end
					end
				end
			end
		end
		
	
	orb.combat.set_invoke_after_attack(false)
end
	)
		


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



local function Combo()
	local target = GetTarget()
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
	if menu.combo.ecombo:get() then
		local target = GetTargetE()
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player.pos) <= spellE.range) then
					player:castSpell("obj", 2, target)
				
			end
		end
	end

	
	
end
local function Harass()
	local target = GetTarget()
	if menu.harass.wharass:get() then
		local target = GetTargetW()
		if common.IsValidTarget(target) and target then
			if not menu.harass.hwaa:get() then
				player:castSpell("self", 1)
			end
			if menu.harass.hwaa:get() then
				if target.pos:dist(player.pos) <= 600 then
					player:castSpell("self", 1)
				end
			end
		end
	end
	if menu.harass.eharass:get() then
		local target = GetTargetE()
		if common.IsValidTarget(target) and target then
			if (target.pos:dist(player.pos) <= spellE.range) then
					player:castSpell("obj", 2, target)
				
			end
		end
	end
end
local function AutoR() 
	if player:spellSlot(3).state ~= 0 then
	 return 
	end
	if menu.rset.r:get() and #common.GetEnemyHeroesInRange(700) >= menu.rset.ronx:get() and common.GetPercentHealth(player) <= menu.rset.ronhp:get() then
		player:castSpell("self", 3)
	end
end

local function AutoRAlly()
	if menu.rset.rally:get() then
		for i = 0, objManager.allies_n - 1 do
			local ally = objManager.allies[i]
			if player:spellSlot(3).state == 0 and ally and not ally.isDead and not player.isDead and ally.pos:dist(player.pos) <= 450 and common.GetPercentHealth(ally) <= menu.rset.allyhp:get() and #common.GetEnemyHeroesInRange(600, ally.pos) >= 1 then
				if menu.rset.yikes[ally.charName] and menu.rset.yikes[ally.charName]:get() and common.GetPercentHealth(player) > common.GetPercentHealth(ally) then
					player:castSpell("self", 3)
				end
			end
		end
	end
end

local function JungleClear()
	if menu.jungleclear.usew:get() and player:spellSlot(1).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead then
				if minion.pos:dist(player.pos) < spellW.range then
					player:castSpell("self", 1)
				end
			end
		end
	end

	if menu.jungleclear.usee:get() and player:spellSlot(2).state == 0 then
		for i = 0, objManager.minions.size[TEAM_NEUTRAL] - 1 do
			local minion = objManager.minions[TEAM_NEUTRAL][i]
			if
				minion and minion.isVisible and minion.moveSpeed > 0 and minion.isTargetable and not minion.isDead and
					minion.pos:dist(player.pos) < spellE.range
			 then
				player:castSpell("obj", 2, minion)
			end
		end
	end

	
	
end

local function OnTick()
	

	AutoRAlly()
	AutoR()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
	if menu.keys.clearkey:get() then
		
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
orb.combat.register_f_pre_tick(OnTick)
--cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
print("-------------------------------------------------")
print("Healer Kindred v"..version..": Loaded!")
print("Check the forums if you have the latest version!")
print("-------------------------------------------------")

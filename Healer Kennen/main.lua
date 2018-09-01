
--[[

  _    _            _             _  __                           
 | |  | |          | |           | |/ /                           
 | |__| | ___  __ _| | ___ _ __  | ' / ___ _ __  _ __   ___ _ __  
 |  __  |/ _ \/ _` | |/ _ \ '__| |  < / _ \ '_ \| '_ \ / _ \ '_ \ 
 | |  | |  __/ (_| | |  __/ |    | . \  __/ | | | | | |  __/ | | |
 |_|  |_|\___|\__,_|_|\___|_|    |_|\_\___|_| |_|_| |_|\___|_| |_|
                                                                  
                                                                  
Thanks for Korins for being patient with me (again) 

(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧

]]
local evade = module.seek("evade")
local database = module.load("HealerKennen", "SpellDatabase")

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerKennen", "common")

-- spell data


local spellQ = {
	range = 1050,
	speed = 1650,
	width = 45,
	delay = 0.175,
	boundingRadiusMod = 1,
	collision = {
		hero = true,
		minion = true,
		wall = true
	}
}

local spellW = {
	range = 750
	
}

local spellE = {
	range = 0
}

local spellR = {
	range = 550
	
}

-- ult cancels



-- Menu --




local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}

local menu = menu("HealerKennen", "Healer Kennen");

menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:boolean("rcombo", "Use R in combo", true)
menu.combo:slider("autor", "Use R when enemies = ", 2, 0, 5, 1)

menu:menu("harass", "Harass")

menu.harass:boolean("qharass", "Use Q in Harass", true)
menu.harass:boolean("wharass", "Use W in Harass", false)



menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", false)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)

menu:menu("misc", "Misc.")
menu.misc:boolean("GapAS", "Cast Q on gapcloser?", true)
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")


local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.misc:boolean("autop", "Auto Q", true)
menu.misc:boolean("autow", "Auto W", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)



local function WGapcloser()
	if player:spellSlot(0).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < spellQ.range
				 then
					if menu.misc.blacklist[dasher.charName] and not menu.misc.blacklist[dasher.charName]:get() then
						if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
							local pos = preds.linear.get_prediction(spellQ, dasher)
								if pos and pos.startPos:dist(pos.endPos) < spellQ.range then 
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
	end



local uhh = false
local something = 0

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

--Combo stuff

local function Combo()
	local target = GetTarget()
	if menu.combo.rcombo:get() then
		if common.IsValidTarget(target) and target then
	 		if player:spellSlot(3).state == 0 then
	 			if #count_enemies_in_range(player.pos, 550) >= menu.combo.autor:get() then -- ty Kornis!
			if target.pos:dist(player.pos) < spellR.range then
			
			
					player:castSpell("self", 3, player)

					end
				end
			end
		end
	end
	



	if menu.combo.wcombo:get() then
		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellW.range then
					if common.CheckBuff(target, "kennenmarkofstorm") and player:spellSlot(1).state == 0 then
					player:castSpell("self", 1, player)
						
					end
				end
			end
		end
	end
	if menu.combo.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.combo.qcombo:get() then
					if target.pos:dist(player.pos) < spellQ.range then
						local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									
								end
							end
						
					end
				end
			end
		end
	end
end


--Harass stuff

local function Harass()


	
		if menu.harass.wharass:get() then
		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellW.range then
					if common.CheckBuff(target, "kennenmarkofstorm") and (player:spellSlot(1).state == 0) then
					
						player:castSpell("self", 1, player)
				end
			end
		end
	end
end
	if menu.harass.qharass:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				
					if target.pos:dist(player.pos) < spellQ.range then
						local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									
								end
							end
						
					end
				
			end
		end
	end
end


local function OnTick()


	if menu.misc.autop:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.misc.autop:get() then
					if target.pos:dist(player.pos) < spellQ.range then
						local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									
								end
							end
						
						end
					end
				end
			end
		end

	
		if menu.misc.autow:get() then

		local target = GetTargetW()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.misc.autow:get() then
					if target.pos:dist(player.pos) < spellW.range then
						if common.CheckBuff(target, "kennenmarkofstorm") and player:spellSlot(1).state == 0 then
						
						player:castSpell("self", 1, player)
					end
				end
			end
		end
	end
end

	if common.CheckBuff(player, "KennenLightningRush") then
		orb.core.set_pause_attack(math.huge)
	end
	if not common.CheckBuff(player, "KennenLightningRush") and orb.core.is_attack_paused() then
		orb.core.set_pause_attack(0)
	end



	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
end


local function OnDraw()
	local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
	
	if player.isOnScreen then
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
	end
end
TS.load_to_menu(menu)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)

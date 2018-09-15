local version = "PROTOTYPE"
--[[


  _    _            _             _                
 | |  | |          | |           | |               
 | |__| | ___  __ _| | ___ _ __  | |    _   ___  __
 |  __  |/ _ \/ _` | |/ _ \ '__| | |   | | | \ \/ /
 | |  | |  __/ (_| | |  __/ |    | |___| |_| |>  < 
 |_|  |_|\___|\__,_|_|\___|_|    |______\__,_/_/\_\
                                                   
                                                   
(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧

version PROTOTYPE 
]]



local evade = module.seek("evade")


local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerLux", "common")



local spellQ = {range = 1175, speed = 1200, width = 60, delay = 0.25, boundingRadiusMod = 1, collision = {hero = true, minion = true, wall = true}}

local spellW = {range = 1075, speed = 1400, width = 120, delay = 0.25, boundingRadiusMod = 1, collision = {hero = false, minion = false, wall = false}}

local spellE = {range = 1100, speed = 1300, radius = 310, delay = 0.25, boundingRadiusMod = 1, collision = {hero = false, minion = false, wall = true}}

local spellR = {range = 3340, speed = math.huge, width = 115, delay = 1, boundingRadiusMod = 1, collision = {hero = false, minion = false, wall = false}}


local menu = menu("Lux", "Healer Lux")

menu:menu("combo", "Combo Settings")
		
menu.combo:boolean("qcombo", "Use Q", true)

menu.combo:boolean("ecombo", "Use E", true)




menu:menu("harass", "Harass Settings")

menu.harass:boolean("qharass", "Use Q", true)
menu.harass:boolean("eharass", "Use E", true)


menu:menu("rset", "R Settings")
menu.rset:boolean("r", "Use R when killable in combo", true)
menu.rset:boolean("autor", "Use auto R when killable (KS)", true)
		
menu:menu("misc", "Misc")

menu.misc:boolean("qcc", "Use Q on cc'ed targets", true)
menu.misc:boolean("ecc", "Use E on cc'ed targets", true)
menu.misc:boolean("GapAS", "Use Q on gapclosers", true)
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")
local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end

menu:menu("draws", "Draw Settings")
		menu.draws:boolean("q", "Draw Q Range", true)
		menu.draws:boolean("e", "Draw E Range", true)


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





local RLevelDamage = {300, 400, 500}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage = common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * 0.75)), player)
	end
	return damage
end



local function Combo()
	local target = GetTargetQ()
	if menu.combo.qcombo:get() and common.IsValidTarget(target) then
		local pos = preds.linear.get_prediction(spellQ, target)
   			if pos and pos.startPos:dist(pos.endPos) <= spellQ.range and not preds.collision.get_prediction(spellQ, pos, target) then
      			if target.pos:dist(player.pos) <= spellQ.range then
	    		 	
		    			player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		 				
      			end
   			end	
	end 
if menu.combo.ecombo:get() then
 local target = GetTargetE()
 if target and target.isVisible then
	if common.IsValidTarget(target) then
		local pos = preds.circular.get_prediction(spellE, target)
   			if pos and pos.startPos:dist(pos.endPos) <= spellE.range then
      			if target.pos:dist(player.pos) <= spellE.range then
      				
	    		 	
		    			player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))

		    			
		    		
		 			
      			end
   			end	
   		end
	end 
end

	local target = GetTargetR()
	if menu.rset.r:get() and common.IsValidTarget(target) then
		local target = GetTargetR()
		local pos = preds.linear.get_prediction(spellR, target)
   			if pos and pos.startPos:dist(pos.endPos) <= spellR.range and not preds.collision.get_prediction(spellR, pos, target) then
      			if target.pos:dist(player.pos) <= spellR.range then
      				if (RDamage(target) > target.health) then
	    		 	
		    			player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		 			end
      			end
   			end	
	end
	
end
local function Harass()
	local target = GetTargetE()
	if menu.harass.eharass:get() and common.IsValidTarget(target) then
		local pos = preds.circular.get_prediction(spellE, target)
   			if pos and pos.startPos:dist(pos.endPos) <= spellQ.range then
      			if target.pos:dist(player.pos) <= spellE.range then
      				
		    			player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		 			
      			end
   			end	
	end 
end

local function AutoQE()
	local enemy = common.GetEnemyHeroes()
      for i, enemies in ipairs(enemy) do
	      if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
		     if menu.misc.qcc:get() and player:spellSlot(0).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range then
			 local pos = preds.linear.get_prediction(spellQ, enemies)
			    if common.CheckBuffType(enemies, 11) or 
				   common.CheckBuffType(enemies, 5) or 
				   common.CheckBuffType(enemies, 22) or
				   common.CheckBuffType(enemies, 8) or
				   common.CheckBuffType(enemies, 24) or
				   common.CheckBuffType(enemies, 29) or
				   common.CheckBuffType(enemies, 32) or
				   common.CheckBuffType(enemies, 34) then
				   if pos and pos.startPos:dist(pos.endPos) < spellQ.range and not preds.collision.get_prediction(spellQ, pos, enemies) then
				   player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				   end
				 end
			 end

			  if menu.misc.ecc:get() and player:spellSlot(2).state == 0 and vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range then
			 local pos = preds.circular.get_prediction(spellE, enemies)
			    if common.CheckBuffType(enemies, 11) or 
				   common.CheckBuffType(enemies, 5) or 
				   common.CheckBuffType(enemies, 22) or
				   common.CheckBuffType(enemies, 8) or
				   common.CheckBuffType(enemies, 24) or
				   common.CheckBuffType(enemies, 29) or
				   common.CheckBuffType(enemies, 32) or
				   common.CheckBuffType(enemies, 34) then
				   if pos and pos.startPos:dist(pos.endPos) < spellE.range then
				   player:castSpell("pos", 2, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
				   end
				 end
			 end
			end
		end


end


local function AutoR() 
	local target = GetTargetR()
	if menu.rset.autor:get() and common.IsValidTarget(target) then
		local target = GetTargetR()
		local pos = preds.linear.get_prediction(spellR, target)
   			if pos and pos.startPos:dist(pos.endPos) <= spellR.range then
      			if target.pos:dist(player.pos) <= spellR.range then
      				if (RDamage(target) > target.health) then
	    		 	
		    			player:castSpell("pos", 3, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
		 			end
      			end
   			end	
	end
end


local function OnTick()

	WGapcloser()
	AutoQE()
	AutoR()
	if menu.keys.combokey:get() then
		Combo()
	end
	if menu.keys.harasskey:get() then
		Harass()
	end
end

local function OnDraw()
	--[[local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
	local enemy = common.GetAllyHeroes()
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
	end]]
end


TS.load_to_menu(menu)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
print("-------------------------------------------------")
print("Healer Lux v"..version..": Loaded!")
print("Check the forums if you have the latest version!")
print("-------------------------------------------------")

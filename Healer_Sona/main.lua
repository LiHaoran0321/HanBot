local version = "1.1"
--[[


  _   _            _             ____                    
 | | | | ___  __ _| | ___ _ __  / ___|  ___  _ __   __ _ 
 | |_| |/ _ \/ _` | |/ _ \ '__| \___ \ / _ \| '_ \ / _` |
 |  _  |  __/ (_| | |  __/ |     ___) | (_) | | | | (_| |
 |_| |_|\___|\__,_|_|\___|_|    |____/ \___/|_| |_|\__,_|
                                                         

  Credits to Kornis for helping me along the way on creating my first script EVER! :D
  (also for letting me use Soraka script as a base for this one)

  1.1 = made Auto Q a toggle, cleaned some code, added version.

]]
local evade = module.seek("evade")


local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerSona", "common")

-- spell data


local spellQ = {
	range = 850
}

local spellW = {
	range = 1000
}

local spellE = {
	range = 960
}

local spellR = {
	range = 900,
	speed = 2400,
	width = 140,
	delay = 0.25,
	boundingRadiusMod = 1,
	collision = {
		hero = false,
		minion = false,
		wall = true
	}
}

-- ult cancels

local interruptableSpells = {
	["caitlyn"] = {
		{menuslot = "R", slot = 3, spellname = "caitlynaceinthehole", channelduration = 1}
	},
	["fiddlesticks"] = {
				{menuslot = "W", slot = 1, spellname = "drain", channelduration = 5},
		{menuslot = "R", slot = 3, spellname = "crowstorm", channelduration = 1.5}
	},
	["janna"] = {
		{menuslot = "R", slot = 3, spellname = "reapthewhirlwind", channelduration = 3}
	},
	["karthus"] = {
		{menuslot = "R", slot = 3, spellname = "karthusfallenone", channelduration = 3}
	}, 
	["katarina"] = {
		{menuslot = "R", slot = 3, spellname = "katarinar", channelduration = 2.5}
	},
	["lucian"] = {
		{menuslot = "R", slot = 3, spellname = "lucianr", channelduration = 2}
	},
	["lux"] = {
		{menuslot = "R", slot = 3, spellname = "luxmalicecannon", channelduration = 0.5}
	},
	["malzahar"] = {
		{menuslot = "R", slot = 3, spellname = "malzaharr", channelduration = 2.5}
	},
	["missfortune"] = {
		{menuslot = "R", slot = 3, spellname = "missfortunebullettime", channelduration = 3}
	},
	["nunu"] = {
		{menuslot = "R", slot = 3, spellname = "absolutezero", channelduration = 3}
	},
	
	["pantheon"] = {
		{menuslot = "R", slot = 3, spellname = "pantheonrjump", channelduration = 2}
	},
	["shen"] = {
		{menuslot = "R", slot = 3, spellname = "shenr", channelduration = 3}
	},
	["twistedfate"] = {
		{menuslot = "R", slot = 3, spellname = "gate", channelduration = 1.5}
	},
	["warwick"] = {
		{menuslot = "R", slot = 3, spellname = "warwickr", channelduration = 1.5}
	},
	["xerath"] = {
		{menuslot = "R", slot = 3, spellname = "xerathlocusofpower2", channelduration = 3}
	}
}

-- Menu --




local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}

local menu = menu("healersona", "Healer Sona");

menu:menu("combo", "Combo")

menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("ecombo", "Use E in Combo", true)

menu:menu("harass", "Harass")

menu.harass:boolean("qcombo", "Use Q in Harass", true)
menu.harass:boolean("ecombo", "Use E in Harass", false)

menu:menu("wpriority", "Healing")
menu.wpriority:header("something", " -- W Settings -- ")
menu.wpriority:boolean("enable", "Enable Auto W", true)
menu.wpriority:header("uhhh", "0 - Disabled, 1 - Biggest Priority, 5 - Lowest Priority")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	if allies.charName ~= "Sona" then
		menu.wpriority:slider(allies.charName, "Priority: " .. allies.charName, 1, 0, 5, 1)
		menu.wpriority:slider(allies.charName .. "hp", " ^- Health Percent: ", 50, 1, 100, 1)
	end
end

menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", true)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", false)
menu.draws:color("colore", "  ^- Color", 255, 255, 255, 255)
menu.draws:boolean("drawtoggle", "Draw AutoQ Toggle", true)

menu:menu("misc", "Misc.")
menu.misc:keybind("toggle", "Auto Q Toggle", "Z", nil)
menu.misc:boolean("GapAS", "Ult dashers (gapclosers), not recommended", false)
menu.misc:menu("interrupt", "Interrupt Settings")
menu.misc.interrupt:boolean("intq", "Use R to Interrupt", true)
menu.misc.interrupt:menu("interruptmenur", "Interruptable Spells")

for i = 1, #common.GetEnemyHeroes() do
	local enemy = common.GetEnemyHeroes()[i]
	local name = string.lower(enemy.charName)
	if enemy and interruptableSpells[name] then
		for v = 1, #interruptableSpells[name] do
			local spell = interruptableSpells[name][v]
			menu.misc.interrupt.interruptmenur:boolean(
				string.format(tostring(enemy.charName) .. tostring(spell.menuslot)),
				"Interrupt " .. tostring(enemy.charName) .. " " .. tostring(spell.menuslot),
				true
			)
		end
	end
end

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

--Healing Priority list

local function PrioritizedAllyW()
	if menu.wpriority.enable:get() then
		local heroTarget = nil
		for i = 0, objManager.allies_n - 1 do
			local hero = objManager.allies[i]
			if not player.isRecalling then
				if
					hero.team == TEAM_ALLY and not hero.isDead and hero ~= player and menu.wpriority[hero.charName]:get() > 0 and
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

-- Ult cancels

local function AutoInterrupt(spell)
	if menu.misc.interrupt.intq:get() and player:spellSlot(3).state == 0 then
		if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY then
			local enemyName = string.lower(spell.owner.charName)
			if interruptableSpells[enemyName] then
				for i = 1, #interruptableSpells[enemyName] do
					local spellCheck = interruptableSpells[enemyName][i]
					if
						menu.misc.interrupt.interruptmenur[spell.owner.charName .. spellCheck.menuslot]:get() and
							string.lower(spell.name) == spellCheck.spellname
					 then
						if
							player.pos2D:dist(spell.owner.pos2D) < spellR.range and common.IsValidTarget(spell.owner) and
								player:spellSlot(3).state == 0
						 then
							player:castSpell("pos", 3, spell.owner.pos)
						end
					end
				end
			end
		end
	end
end
local function WGapcloser()
	if player:spellSlot(3).state == 0 and menu.misc.GapAS:get() then
		for i = 0, objManager.enemies_n - 1 do
			local dasher = objManager.enemies[i]
			if dasher.type == TYPE_HERO and dasher.team == TEAM_ENEMY then
				if
					dasher and common.IsValidTarget(dasher) and dasher.path.isActive and dasher.path.isDashing and
						player.pos:dist(dasher.path.point[1]) < spellE.range
				 then
					if player.pos2D:dist(dasher.path.point2D[1]) < player.pos2D:dist(dasher.path.point2D[0]) then
						player:castSpell("pos", 3, dasher.path.point2D[1])
					end
				end
			end
		end
	end
end


local uhh = false
local something = 0
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

local tog = false
local what = 0

local function Toggle()
	if menu.misc.toggle:get() then
		if (tog == false and os.clock() > what) then
			tog = true
			what = os.clock() + 0.3
		end
		if (tog == true and os.clock() > what) then
			tog = false
			what = os.clock() + 0.3
		end
	end
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
	if menu.combo.ecombo:get() then
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellE.range then
					
						player:castSpell("self", 2, player)
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
						player:castSpell("self", 0, player)
						
					end
				end
			end
		end
	end
end

--Harass stuff

local function Harass()
	if menu.harass.ecombo:get() then
		local target = GetTargetE()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if target.pos:dist(player.pos) < spellE.range then
				
						player:castSpell("self", 2, player)
				end
			end
		end
	end
	if menu.harass.qcombo:get() then
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				if menu.harass.qcombo:get() then
					if target.pos:dist(player.pos) < spellQ.range then
						
							player:castSpell("self", 0, player) 
					
					end
				end
			end
		end
	end
end

-- Auto W and Q stuff
local function AutoQ()
	if tog then
		return
	end
		local target = GetTargetQ()
		if target and target.isVisible then
			if common.IsValidTarget(target) then
				
					if target.pos:dist(player.pos) < spellQ.range then
						player:castSpell("self", 0, player)
						
					end
				
			end
		end
	
end

local function OnTick()

if PrioritizedAllyW() then
		player:castSpell("self", 1, PrioritizedAllyW())
	end


	AutoQ()
	Toggle()
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

	if menu.draws.drawtoggle:get() then
		
		if tog == true then
			graphics.draw_text_2D("Auto Q: OFF", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 218, 34, 34))
		else
			graphics.draw_text_2D("Auto Q: ON", 18, pos.x - 20, pos.y + 40, graphics.argb(255, 128, 255, 0))
		end
	end
end
TS.load_to_menu(menu)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
print("-------------------------------------------------")
print("Healer Sona v"..version..": Loaded!")
print("Check the forums if you have the latest version!")
print("-------------------------------------------------")
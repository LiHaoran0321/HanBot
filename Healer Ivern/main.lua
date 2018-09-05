local version = "1.1"
--[[
1.1 added version

  _    _            _             _____                    
 | |  | |          | |           |_   _|                   
 | |__| | ___  __ _| | ___ _ __    | |_   _____ _ __ _ __  
 |  __  |/ _ \/ _` | |/ _ \ '__|   | \ \ / / _ \ '__| '_ \ 
 | |  | |  __/ (_| | |  __/ |     _| |\ V /  __/ |  | | | |
 |_|  |_|\___|\__,_|_|\___|_|    |_____\_/ \___|_|  |_| |_|
                                                           
                                                           

  Credits to Kornis for helping me along the way on creating this script!
  Also for being patient while i tried understanding how to create delays ¯\_(ツ)_/¯

]]
local evade = module.seek("evade")
local database = module.load("HealerIvern", "SpellDatabase")

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerIvern", "common")

-- spell data


local spellQ = {
	range = 1075,
	speed = 1300,
	width = 50,
	delay = 0.25,
	boundingRadiusMod = 1,
	collision = {
	hero = true,
	minion = true,
	wall = true
}
}

local spellW = {
	range = 500
}

local spellE = {
	range = 750
}

local spellR = {
	range = 200,
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



-- Menu --




local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}

local menu = menu("healerivern", "Healer Ivern");

menu:menu("combo", "Combo")

menu.combo:boolean("edelay", "Disable Q pull-in?", true)
menu.combo:boolean("qcombo", "Use Q in Combo", true)
menu.combo:boolean("wcombo", "Use W in Combo", true)
menu.combo:slider("wdelay", "Delay between W (ms)", 1000, 0, 5000, 5)

menu:menu("harass", "Harass")
menu.harass:boolean("edelay", "Disable Q pull-in?", true)
menu.harass:boolean("qharass", "Use Q in Harass", true)
menu.harass:boolean("wharass", "Use W in Harass", false)
menu.harass:slider("wdelay", "Delay between W (ms)", 1000, 0, 5000, 5)

menu:menu("auto", "Auto Q")
menu.auto:boolean("autoq", "Auto Q", true)
menu.auto:boolean("qdelay", "Disable Q pull-in?", true)

menu:menu("misc", "Anti-Gapclose")
menu.misc:menu("blacklist", "Anti-Gapclose Blacklist")


local enemy = common.GetEnemyHeroes()
for i, allies in ipairs(enemy) do
	menu.misc.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.misc:boolean("GapAS", "Use Q for Anti-Gapclose", true)
menu.misc:boolean("qdelay", "Disable Q pull-in?", true)

menu:menu("SpellsMenu", "Shielding")
menu.SpellsMenu:boolean("enable", "Enable Shielding", true)
menu.SpellsMenu:boolean("priority", "Priority Ally", true)
menu.SpellsMenu:menu("blacklist", "Ally Shield Blacklist")
local enemy = common.GetAllyHeroes()
for i, allies in ipairs(enemy) do
	menu.SpellsMenu.blacklist:boolean(allies.charName, "Block: " .. allies.charName, false)
end
menu.SpellsMenu:header("hello", " -- Enemy Skillshots -- ")
for _, i in pairs(database) do
	for l, k in pairs(common.GetEnemyHeroes()) do
		
		if not database[_] then
			return
		end
		if i.charName == k.charName then
			if i.displayname == "" then
				i.displayname = _
			end
			if i.danger == 0 then
				i.danger = 1
			end
			if (menu.SpellsMenu[i.charName] == nil) then
				menu.SpellsMenu:menu(i.charName, i.charName)
			end
			menu.SpellsMenu[i.charName]:menu(_, "" .. i.charName .. " | " .. (str[i.slot] or "?") .. " " .. _)

			menu.SpellsMenu[i.charName][_]:boolean("Dodge", "Enable Block", true)

			menu.SpellsMenu[i.charName][_]:slider("hp", "HP to Dodge", 100, 1, 100, 5)
		end
	end
end

menu.SpellsMenu:header("hello", " -- Misc. -- ")
menu.SpellsMenu:boolean("targeteteteteteed", "Shield on Targeted Spells", true)
menu.SpellsMenu:boolean("cc", "Auto Shield on CC", true)
menu.SpellsMenu:menu("BasicAttack", "Basic Attack Sielding", true)
menu.SpellsMenu.BasicAttack:boolean("aa", "Shield on Basic attack", true)
menu.SpellsMenu.BasicAttack:slider("aahp", " ^- HP to Shield", 100, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("critaa", "Shield on Crit attack", true)
menu.SpellsMenu.BasicAttack:slider("crithp", " ^- HP to Shield", 100, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("minionaa", "Shield on Minion attack", true)
menu.SpellsMenu.BasicAttack:slider("minionhp", " ^- HP to Shield", 10, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("turret", "Shield on Turret attack", true)



menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("draww", "Draw W Range", false)
menu.draws:color("colorw", "  ^- Color", 255, 233, 121, 121)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 233, 121, 121)



menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

local PSpells = {
	"CaitlynHeadshotMissile",
	"RumbleOverheatAttack",
	"JarvanIVMartialCadenceAttack",
	"ShenKiAttack",
	"MasterYiDoubleStrike",
	"sonahymnofvalorattackupgrade",
	"sonaariaofperseveranceupgrade",
	"sonasongofdiscordattackupgrade",
	"NocturneUmbraBladesAttack",
	"NautilusRavageStrikeAttack",
	"ZiggsPassiveAttack",
	"QuinnWEnhanced",
	"LucianPassiveAttack",
	"SkarnerPassiveAttack",
	"KarthusDeathDefiedBuff",
	"GarenQAttack",
	"KennenMegaProc",
	"MordekaiserQAttack",
	"MordekaiserQAttack2",
	"BlueCardPreAttack",
	"RedCardPreAttack",
	"GoldCardPreAttack",
	"XenZhaoThrust",
	"XenZhaoThrust2",
	"XenZhaoThrust3",
	"ViktorQBuff",
	"TrundleQ",
	"RenektonSuperExecute",
	"RenektonExecute",
	"GarenSlash2",
	"frostarrow",
	"SivirWAttack",
	"rengarnewpassivebuffdash",
	"YorickQAttack",
	"ViEAttack",
	"SejuaniBasicAttackW",
	"ShyvanaDoubleAttackHit",
	"ShenQAttack",
	"SonaEAttackUpgrade",
	"SonaWAttackUpgrade",
	"SonaQAttackUpgrade",
	"PoppyPassiveAttack",
	"NidaleeTakedownAttack",
	"NasusQAttack",
	"KindredBasicAttackOverrideLightbombFinal",
	"LeonaShieldOfDaybreakAttack",
	"KassadinBasicAttack3",
	"JhinPassiveAttack",
	"JayceHyperChargeRangedAttack",
	"JaycePassiveRangedAttack",
	"JaycePassiveMeleeAttack",
	"illaoiwattack",
	"hecarimrampattack",
	"DrunkenRage",
	"GalioPassiveAttack",
	"FizzWBasicAttack",
	"FioraEAttack",
	"EkkoEAttack",
	"ekkobasicattackp3",
	"MasochismAttack",
	"DravenSpinningAttack",
	"DianaBasicAttack3",
	"DariusNoxianTacticsONHAttack",
	"CamilleQAttackEmpowered",
	"CamilleQAttack",
	"PowerFistAttack",
	"AsheQAttack",
	"jinxqattack",
	"jinxqattack2",
	"KogMawBioArcaneBarrage"
}

local tyKornis = 0
local function AutoInterrupt(spell)
	
	if spell and spell.owner == player and spell.name == "IvernQ" then
		
		if menu.keys.harasskey:get() and menu.harass.edelay:get() then
			tyKornis = game.time + 5000 / 1000
		end
		if menu.keys.combokey:get() and menu.combo.edelay:get() then
			tyKornis = game.time + 5000 / 1000
		end
		if menu.auto.autoq:get() and menu.auto.qdelay:get() then
			tyKornis = game.time + 5000 / 1000
		end
		if menu.misc.qdelay:get() then
			tyKornis = game.time + 5000 / 1000
		end
	end

	if spell and spell.owner == player and spell.name == "IvernW" then
		
		if menu.keys.harasskey:get() and menu.harass.wharass:get() then
			tyKornis = game.time + menu.harass.wdelay:get() / 1000
		end
		if menu.keys.combokey:get() and menu.combo.wcombo:get() then
			tyKornis = game.time + menu.combo.wdelay:get() / 1000
		end
		
	end

    if menu.SpellsMenu.targeteteteteteed:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if not menu.SpellsMenu.blacklist[ally.charName]:get() then
					if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
						if not spell.name:find("crit") then
							if not spell.name:find("BasicAttack") then
								if menu.SpellsMenu.targeteteteteteed:get() then
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
					end
				end
			end
		end
	end
    if menu.SpellsMenu.BasicAttack.aa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellE.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					for i = 1, #PSpells do
						if spell.name:lower():find(PSpells[i]:lower()) then
							if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
								if not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if ally.pos:dist(player.pos) <= spellE.range then
										player:castSpell("obj", 2, ally)
									end
								end
							end
						end
					end
					if spell.name:find("BasicAttack") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellE.range then
									player:castSpell("obj", 2, ally)
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.critaa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellE.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if spell.name:find("crit") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellE.range then
									player:castSpell("obj", 2, ally)
								end
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.minionaa:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellE.range then
				if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
						if not menu.SpellsMenu.blacklist[ally.charName]:get() then
							if ally.pos:dist(player.pos) <= spellE.range then
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
		end
	end
	if menu.SpellsMenu.BasicAttack.turret:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally and ally.pos:dist(player.pos) <= spellE.range then
				if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if ally.pos:dist(player.pos) <= spellE.range then
							player:castSpell("obj", 2, ally)
						end
					end
				end
			end
		end
	end
end

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
								if pos and pos.startPos:dist(pos.endPos) < spellQ.range and game.time > tyKornis then 
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
				end
			end
		end
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
local TargetSelectionE = function(res, obj, dist)
	if dist < spellQ.range + 150 then
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

	if menu.combo.qcombo:get() then
	local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
		if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range and game.time > tyKornis then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
									
								end
							end
						end
		end
	end
    end


if not common.CheckBuff(player, "ivernwpassive") and (player:spellSlot(1).state == 0) then
    if menu.combo.wcombo:get() then
    
    local target = GetTargetW()
	if target and target.isVisible then
		if common.IsValidTarget(player) then
		if target.pos:dist(player.pos) < spellW.range and game.time > tyKornis then
							player:castSpell("self", 1, player)
				end			
		end
    end
end
end
end


local function Harass()
	if menu.harass.qharass:get() then
		local target = GetTargetQ()
			if target and target.isVisible then
				if common.IsValidTarget(target) then
					if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range and game.time > tyKornis then
								if not preds.collision.get_prediction(spellQ, pos, target) then
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
					end
				end
   			end
	end

	if not common.CheckBuff(player, "ivernwpassive") and (player:spellSlot(1).state == 0) then
    if menu.combo.wcombo:get() then
    
    local target = GetTargetW()
	if target and target.isVisible then
		if common.IsValidTarget(player) then
		if target.pos:dist(player.pos) < spellW.range and game.time > tyKornis then
							player:castSpell("self", 1, player)
				end			
		end
    end
end
end
end


local allow = true
local function OnTick()

	

	if not evade then
		print(" ")
		console.set_color(79)
		print("-----------Healer Ivern--------------")
		print("You need to have 'Evade' enabled for Shielding Champions.")
		print("If you don't want Evade to dodge, disable dodging but keep the Module enabled. ")
		print("------------------------------------")
		console.set_color(12)
	end

	if menu.auto.autoq:get() then
		local target = GetTargetQ()
	if target and target.isVisible then
		if common.IsValidTarget(target) then
		if target.pos:dist(player.pos) < spellQ.range then
							local pos = preds.linear.get_prediction(spellQ, target)
							if pos and pos.startPos:dist(pos.endPos) < spellQ.range then 
								if not preds.collision.get_prediction(spellQ, pos, target) and game.time > tyKornis then 
									player:castSpell("pos", 0, vec3(pos.endPos.x, mousePos.y, pos.endPos.y))
								end
							end
						end
					end
		end
	end

	WGapcloser()
	if menu.keys.combokey:get() then
		Combo()
	end

	if menu.keys.harasskey:get() then
	Harass()
	end 


	if not player.isRecalling then
		if menu.SpellsMenu.cc:get() then
			local allies = common.GetAllyHeroes()
			for z, ally in ipairs(allies) do
				if ally then
					if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if
							(common.CheckBuffType(ally, 5) or common.CheckBuffType(ally, 8) or common.CheckBuffType(ally, 24) or
								common.CheckBuffType(ally, 23) or
								common.CheckBuffType(ally, 11) or
								common.CheckBuffType(ally, 22) or
								common.CheckBuffType(ally, 8) or
								common.CheckBuffType(ally, 21))
						 then
							if ally.pos:dist(player.pos) <= spellE.range then
								player:castSpell("obj", 2, ally)
							end
						end
					end
				end
			end
		end
		if menu.SpellsMenu.enable:get() then
			for i = 1, #evade.core.active_spells do
				local spell = evade.core.active_spells[i]
				if menu.SpellsMenu.priority:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally and ally.pos:dist(player.pos) <= spellE.range and ally ~= player then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if (spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0) then
									allow = false
								else
									allow = true
								end

								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellE.range then
													player:castSpell("obj", 2, ally)
												end
											end
										end
									end
								elseif
									spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
										(not spell.data.collision or #spell.data.collision == 0)
								 then
									for _, k in pairs(database) do
										if menu.SpellsMenu[k.charName] then
											if
												spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
													menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
											 then
												if ally.pos:dist(player.pos) <= spellE.range then
													if ally ~= player then
														if spell.missile then
															if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																if ally.pos:dist(player.pos) <= spellE.range then
																	player:castSpell("obj", 2, ally)
																end
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																if ally.pos:dist(player.pos) <= spellE.range then
																	player:castSpell("obj", 2, ally)
																end
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															if ally.pos:dist(player.pos) <= spellE.range then
																player:castSpell("obj", 2, ally)
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
					for z, ally in ipairs(allies) do
						if ally and ally == player and allow then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellE.range then
													player:castSpell("obj", 2, ally)
												end
											end
										end
									end
								elseif
									spell.polygon and spell.polygon:Contains(player.path.serverPos) ~= 0 and
										(not spell.data.collision or #spell.data.collision == 0)
								 then
									for _, k in pairs(database) do
										if ally == player then
											if menu.SpellsMenu[k.charName] then
												if
													spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
														menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
												 then
													if player.pos:dist(player.pos) <= spellE.range then
														if spell.missile then
															if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																player:castSpell("obj", 2, player)
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																player:castSpell("obj", 2, player)
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															player:castSpell("obj", 2, player)
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end

				if not menu.SpellsMenu.priority:get() then
					local allies = common.GetAllyHeroes()
					for z, ally in ipairs(allies) do
						if ally then
							if menu.SpellsMenu.blacklist[ally.charName] and not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if spell.data.spell_type == "Target" and spell.target == ally and spell.owner.type == TYPE_HERO then
									if not spell.name:find("crit") then
										if not spell.name:find("basicattack") then
											if menu.SpellsMenu.targeteteteteteed:get() then
												if ally.pos:dist(player.pos) <= spellE.range then
													player:castSpell("obj", 2, ally)
												end
											end
										end
									end
								elseif
									spell.polygon and spell.polygon:Contains(ally.path.serverPos) ~= 0 and
										(not spell.data.collision or #spell.data.collision == 0)
								 then
									for _, k in pairs(database) do
										if
											spell.name:find(_:lower()) and menu.SpellsMenu[k.charName] and menu.SpellsMenu[k.charName][_].Dodge:get() and
												menu.SpellsMenu[k.charName][_].hp:get() >= (ally.health / ally.maxHealth) * 100
										 then
											if ally.pos:dist(player.pos) <= spellE.range then
												if spell.missile then
													if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
														if ally.pos:dist(player.pos) <= spellE.range then
															player:castSpell("obj", 2, ally)
														end
													end
												end
												if spell.name:find(_:lower()) then
													if k.speeds == math.huge or spell.data.spell_type == "Circular" then
														if ally.pos:dist(player.pos) <= spellE.range then
															player:castSpell("obj", 2, ally)
														end
													end
												end
												if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
													if ally.pos:dist(player.pos) <= spellE.range then
														player:castSpell("obj", 2, ally)
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end


local function OnDraw()
	if player.isOnScreen then
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.draww:get() then
			graphics.draw_circle(player.pos, spellW.range, 2, menu.draws.colorw:get(), 100)
		end
	end
end


TS.load_to_menu(menu)

cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
print("-------------------------------------------------")
print("Healer Ivern v"..version..": Loaded!")
print("Check the forums if you have the latest version!")
print("-------------------------------------------------")
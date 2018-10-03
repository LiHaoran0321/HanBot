local version = "1.0"
--[[


  _    _            _             _                
 | |  | |          | |           | |               
 | |__| | ___  __ _| | ___ _ __  | |    _   ___  __
 |  __  |/ _ \/ _` | |/ _ \ '__| | |   | | | \ \/ /
 | |  | |  __/ (_| | |  __/ |    | |___| |_| |>  < 
 |_|  |_|\___|\__,_|_|\___|_|    |______\__,_/_/\_\    
                                                   
                                                   
(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧
Big thanks to Kornis for helping me out on creating this script!
(ﾉ◕ヮ◕)ﾉ*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧*:・ﾟ✧


version PROTOTYPE 
version 1.0 released - lots of stuff added since Prototype release
]]
local evade = module.seek("evade")

local preds = module.internal("pred")
local TS = module.internal("TS")
local orb = module.internal("orb")

local common = module.load("HealerLux", "common")
local database = module.load("HealerLux", "SpellDatabase")

local spellQ = {
	range = 1175,
	speed = 1200,
	width = 80,
	delay = 0.25,
	boundingRadiusMod = 1,
	collision = {hero = true, minion = true, wall = true}
}

local spellW = {
	range = 1075,
	speed = 1400,
	width = 120,
	delay = 0.25,
	boundingRadiusMod = 1,
	collision = {hero = false, minion = false, wall = false}
}

local spellE = {
	range = 1100,
	speed = 1100,
	radius = 300,
	delay = 0.25,
	boundingRadiusMod = 0,
	collision = {hero = false, minion = false, wall = true}
}

local spellR = {
	range = 3340,
	speed = math.huge,
	width = 115,
	delay = 1,
	boundingRadiusMod = 0,
	collision = {hero = false, minion = false, wall = false}
}

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
local str = {[-1] = "P", [0] = "Q", [1] = "W", [2] = "E", [3] = "R"}
local menu = menu("Lux", "Healer Lux")

menu:menu("combo", "Combo Settings")

menu.combo:boolean("qcombo", "Use Q", true)
menu.combo:boolean("qslow", "Slow Q prediction", true)

menu.combo:boolean("ecombo", "Use E", true)

menu:menu("SpellsMenu", "Shielding") --Credits to Kornis
menu.SpellsMenu:slider("mana", "Mana Manager", 2, 0, 100, 5)
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
		-- k = myHero
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
menu.SpellsMenu.BasicAttack:slider("aahp", " ^- HP to Shield", 40, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("critaa", "Shield on Crit attack", true)
menu.SpellsMenu.BasicAttack:slider("crithp", " ^- HP to Shield", 40, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("minionaa", "Shield on Minion attack", true)
menu.SpellsMenu.BasicAttack:slider("minionhp", " ^- HP to Shield", 10, 1, 100, 5)
menu.SpellsMenu.BasicAttack:boolean("turret", "Shield on Turret attack", true)

menu:menu("harass", "Harass Settings")

menu.harass:boolean("eharass", "Use E", true)

menu:menu("rset", "R Settings")
menu.rset:boolean("r", "Use R when killable in combo", true)
menu.rset:slider("Rrange", "R range: ", 2800, 0, 3340, 1)
menu.rset:boolean("autor", "Use auto R when killable (KS)", true)
menu.rset:header("dafuq", "Turn off R combo when using AutoR")
menu.rset:boolean("rslow", "Slow R prediction", true)

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
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 153, 153, 255)
menu.draws:boolean("drawe", "Draw E Range", true)
menu.draws:color("colore", "  ^- Color", 255, 153, 153, 255)
menu.draws:boolean("drawr", "Draw R Range", false)
menu.draws:color("colorr", "  ^- Color", 255, 153, 153, 255)
menu.draws:boolean("drawdamage", "Draw R damage, killable or not", true)

menu:menu("keys", "Key Settings")
menu.keys:keybind("combokey", "Combo Key", "Space", nil)
menu.keys:keybind("harasskey", "Harass Key", "C", nil)
menu.keys:keybind("clearkey", "Lane Clear Key", "V", nil)
menu.keys:keybind("lastkey", "Last Hit", "X", nil)

local function AutoInterrupt(spell)
	if menu.SpellsMenu.targeteteteteteed:get() then
		local allies = common.GetAllyHeroes()
		for z, ally in ipairs(allies) do
			if ally then
				if not menu.SpellsMenu.blacklist[ally.charName]:get() then
					if spell and spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
						if not spell.name:find("crit") then
							if not spell.name:find("BasicAttack") then
								if menu.SpellsMenu.targeteteteteteed:get() then
									if ally.pos:dist(player.pos) <= spellW.range then
										local pos = preds.linear.get_prediction(spellW, ally)
										player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					for i = 1, #PSpells do
						if spell.name:lower():find(PSpells[i]:lower()) then
							if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
								if not menu.SpellsMenu.blacklist[ally.charName]:get() then
									if ally.pos:dist(player.pos) <= spellW.range then
										local pos = preds.linear.get_prediction(spellW, ally)
										player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
									end
								end
							end
						end
					end
					if spell.name:find("BasicAttack") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.aahp:get() then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellW.range then
									local pos = preds.linear.get_prediction(spellW, ally)
									player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_HERO and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if spell.name:find("crit") then
						if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.crithp:get() then
							if not menu.SpellsMenu.blacklist[ally.charName]:get() then
								if ally.pos:dist(player.pos) <= spellW.range then
									local pos = preds.linear.get_prediction(spellW, ally)
									player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_MINION and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if (ally.health / ally.maxHealth) * 100 <= menu.SpellsMenu.BasicAttack.minionhp:get() then
						if not menu.SpellsMenu.blacklist[ally.charName]:get() then
							if ally.pos:dist(player.pos) <= spellW.range then
								local pos = preds.linear.get_prediction(spellW, ally)
								player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
			if ally and ally.pos:dist(player.pos) <= spellW.range then
				if spell.owner.type == TYPE_TURRET and spell.owner.team == TEAM_ENEMY and spell.target == ally then
					if not menu.SpellsMenu.blacklist[ally.charName]:get() then
						if ally.pos:dist(player.pos) <= spellW.range then
							local pos = preds.linear.get_prediction(spellW, ally)
							player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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

local PassiveDmg = {20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190}
function PasDmg(target)
	local damage = 0
	if player.levelRef > 0 then
		damage = common.CalculateMagicDamage(target, (PassiveDmg[player.levelRef] + (common.GetTotalAP() * 0.2)), player)
	end
	return damage
end
local QLevelDamage = {70, 115, 160, 205, 250}
function QDamage(target)
	local damage = 0
	if player:spellSlot(0).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (QLevelDamage[player:spellSlot(0).level] + (common.GetTotalAP() * 0.7)), player)
	end
	return damage
end
local ELevelDamage = {60, 105, 150, 195, 240}
function EDamage(target)
	local damage = 0
	if player:spellSlot(2).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (ELevelDamage[player:spellSlot(2).level] + (common.GetTotalAP() * 0.6)), player)
	end
	return damage
end
--[[local RLevelerDamage = {300, 400, 500}
function RpassDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			common.CalculateMagicDamage(
			target,
			(RLevelerDamage[player:spellSlot(3).level] + PasDmg + (common.GetTotalAP() * 0.75)),  
			player
		)
	end
	return damage
end]]
local RLevelDamage = {300, 400, 500}
function RDamage(target)
	local damage = 0
	if player:spellSlot(3).level > 0 then
		damage =
			common.CalculateMagicDamage(target, (RLevelDamage[player:spellSlot(3).level] + (common.GetTotalAP() * 0.75)), player)
	end
	return damage
end
local trace_filter = function(input, segment, target)
	if preds.trace.linear.hardlock(input, segment, target) then
		return true
	end
	if preds.trace.linear.hardlockmove(input, segment, target) then
		return true
	end
	if
		target and common.IsValidTarget(target) and
			(player.pos:dist(target) <= (player.attackRange + player.boundingRadius + target.boundingRadius) or
				(segment.startPos:dist(segment.endPos) <= 625))
	 then
		return true
	end

	if preds.trace.newpath(target, 0.033, 0.5) then
		return true
	end
end
local function Combo()
	local target = GetTargetQ()
	if menu.combo.qcombo:get() and common.IsValidTarget(target) then
		local pos = preds.linear.get_prediction(spellQ, target)
		if pos and pos.startPos:dist(pos.endPos) <= spellQ.range and not preds.collision.get_prediction(spellQ, pos, target) then
			if target.pos:dist(player.pos) <= spellQ.range then
				--player:castSpell("pos", 0, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
				if menu.combo.qslow:get() and trace_filter(spellQ, pos, target) then
					player:castSpell("pos", 0, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
				end
				if not menu.combo.qslow:get() then
					player:castSpell("pos", 0, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
				end
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
						player:castSpell("pos", 2, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
					end
				end
			end
		end
	end

	local target = GetTargetR()
	if menu.rset.r:get() and common.IsValidTarget(target) then
		local target = GetTargetR()
		local pos = preds.linear.get_prediction(spellR, target)
		if
			pos and pos.startPos:dist(pos.endPos) <= menu.rset.Rrange:get() and
				not preds.collision.get_prediction(spellR, pos, target)
		 then
			if target.pos:dist(player.pos) <= menu.rset.Rrange:get() then
				if
					common.CheckBuff(target, "LuxIlluminatingFraulein") and
						target.buff["luxilluminatingfraulein"].endTime - game.time >= 1
				 then
					if (RDamage(target) + PasDmg(target) > target.health) then
						if menu.rset.rslow:get() and trace_filter(spellR, pos, target) then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
						if not menu.rset.rslow:get() then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
					end
				end
				if not common.CheckBuff(target, "LuxIlluminatingFraulein") then
					if (RDamage(target) > target.health) then
						if menu.rset.rslow:get() and trace_filter(spellR, pos, target) then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
						if not menu.rset.rslow:get() then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
					end
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
				player:castSpell("pos", 2, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
			end
		end
	end
end

local function AutoQE()
	local enemy = common.GetEnemyHeroes()
	for i, enemies in ipairs(enemy) do
		if enemies and common.IsValidTarget(enemies) and not common.CheckBuffType(enemies, 17) then
			if
				menu.misc.qcc:get() and player:spellSlot(0).state == 0 and
					vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellQ.range
			 then
				local pos = preds.linear.get_prediction(spellQ, enemies)
				if
					common.CheckBuffType(enemies, 11) or common.CheckBuffType(enemies, 5) or common.CheckBuffType(enemies, 22) or
						common.CheckBuffType(enemies, 8) or
						common.CheckBuffType(enemies, 24) or
						common.CheckBuffType(enemies, 29) or
						common.CheckBuffType(enemies, 32) or
						common.CheckBuffType(enemies, 34)
				 then
					if
						pos and pos.startPos:dist(pos.endPos) < spellQ.range and not preds.collision.get_prediction(spellQ, pos, enemies)
					 then
						player:castSpell("pos", 0, vec3(pos.endPos.x, enemies.pos.y, pos.endPos.y))
					end
				end
			end

			if
				menu.misc.ecc:get() and player:spellSlot(2).state == 0 and
					vec3(enemies.x, enemies.y, enemies.z):dist(player) < spellE.range
			 then
				local pos = preds.circular.get_prediction(spellE, enemies)
				if
					common.CheckBuffType(enemies, 11) or common.CheckBuffType(enemies, 5) or common.CheckBuffType(enemies, 22) or
						common.CheckBuffType(enemies, 8) or
						common.CheckBuffType(enemies, 24) or
						common.CheckBuffType(enemies, 29) or
						common.CheckBuffType(enemies, 32) or
						common.CheckBuffType(enemies, 34)
				 then
					if pos and pos.startPos:dist(pos.endPos) < spellE.range then
						player:castSpell("pos", 2, vec3(pos.endPos.x, enemies.pos.y, pos.endPos.y))
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
		if
			pos and pos.startPos:dist(pos.endPos) <= menu.rset.Rrange:get() and
				not preds.collision.get_prediction(spellR, pos, target)
		 then
			if target.pos:dist(player.pos) <= menu.rset.Rrange:get() then
				if
					common.CheckBuff(target, "LuxIlluminatingFraulein") and
						target.buff["luxilluminatingfraulein"].endTime - game.time >= 1
				 then
					if (RDamage(target) + PasDmg(target) > target.health) then
						if menu.rset.rslow:get() and trace_filter(spellR, pos, target) then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
						if not menu.rset.rslow:get() then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
					end
				end
				if not common.CheckBuff(target, "LuxIlluminatingFraulein") then
					if (RDamage(target) > target.health) then
						if menu.rset.rslow:get() and trace_filter(spellR, pos, target) then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
						if not menu.rset.rslow:get() then
							player:castSpell("pos", 3, vec3(pos.endPos.x, target.pos.y, pos.endPos.y))
						end
					end
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
							if ally.pos:dist(player.pos) <= spellW.range then
								local pos = preds.linear.get_prediction(spellW, ally)
								player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
						if ally and ally.pos:dist(player.pos) <= spellW.range and ally ~= player then
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
												if ally.pos:dist(player.pos) <= spellW.range then
													local pos = preds.linear.get_prediction(spellW, ally)
													player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
												if ally.pos:dist(player.pos) <= spellW.range then
													local pos = preds.linear.get_prediction(spellW, ally)
													if ally ~= player then
														if spell.missile then
															if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																if ally.pos:dist(player.pos) <= spellW.range then
																	local pos = preds.linear.get_prediction(spellW, ally)
																	player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
																end
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																if ally.pos:dist(player.pos) <= spellW.range then
																	local pos = preds.linear.get_prediction(spellW, ally)
																	player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
																end
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															if ally.pos:dist(player.pos) <= spellW.range then
																local pos = preds.linear.get_prediction(spellW, ally)
																player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
												if ally.pos:dist(player.pos) <= spellW.range then
													local pos = preds.linear.get_prediction(spellW, ally)
													player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
													if player.pos:dist(player.pos) <= spellW.range then
														local pos = preds.linear.get_prediction(spellW, ally)
														if spell.missile then
															if (player.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
																player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
															end
														end
														if spell.name:find(_:lower()) then
															if k.speeds == math.huge or spell.data.spell_type == "Circular" then
																local pos = preds.linear.get_prediction(spellW, ally)
																player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
															end
														end
														if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
															local pos = preds.linear.get_prediction(spellW, ally)
															player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
												if ally.pos:dist(player.pos) <= spellW.range then
													local pos = preds.linear.get_prediction(spellW, ally)
													player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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
											if ally.pos:dist(player.pos) <= spellW.range then
												if spell.missile then
													if (ally.pos:dist(spell.missile.pos) / spell.data.speed < network.latency + 0.35) then
														if ally.pos:dist(player.pos) <= spellW.range then
															local pos = preds.linear.get_prediction(spellW, ally)
															player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
														end
													end
												end
												if spell.name:find(_:lower()) then
													if k.speeds == math.huge or spell.data.spell_type == "Circular" then
														if ally.pos:dist(player.pos) <= spellW.range then
															local pos = preds.linear.get_prediction(spellW, ally)
															player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
														end
													end
												end
												if spell.data.speed == math.huge or spell.data.spell_type == "Circular" then
													if ally.pos:dist(player.pos) <= spellW.range then
														local pos = preds.linear.get_prediction(spellW, ally)
														player:castSpell("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))
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

--("pos", 1, vec3(pos.endPos.x, ally.pos.y, pos.endPos.y))

function DrawDamagesE(target)
	if target.isVisible and not target.isDead then
		if common.CheckBuff(target, "LuxIlluminatingFraulein") then
			local pos = graphics.world_to_screen(target.pos)
			if (math.floor((RDamage(target) + PasDmg(target)) / target.health * 100) < 100) then
				graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 50, 200, 255))
				graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 50, 200, 255))
				graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 50, 200, 255))

				graphics.draw_text_2D(
					tostring("P+R: " .. math.floor(RDamage(target) + PasDmg(target))) ..
						" (" .. tostring(math.floor((RDamage(target) + PasDmg(target)) / target.health * 100)) .. "%)" .. "Not Killable",
					20,
					pos.x + 55,
					pos.y - 80,
					graphics.argb(255, 50, 200, 255)
				)
			end
		end
		if not common.CheckBuff(target, "LuxIlluminatingFraulein") then
			local pos = graphics.world_to_screen(target.pos)
			if (math.floor((RDamage(target)) / target.health * 100) < 100) then
				graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 153, 153, 255))
				graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 153, 153, 255))
				graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 153, 153, 255))

				graphics.draw_text_2D(
					tostring("R: " .. math.floor(RDamage(target))) ..
						" (" .. tostring(math.floor((RDamage(target)) / target.health * 100)) .. "%)" .. "Not Killable",
					20,
					pos.x + 55,
					pos.y - 80,
					graphics.argb(255, 153, 153, 255)
				)
			end
		end

		if common.CheckBuff(target, "LuxIlluminatingFraulein") then
			local pos = graphics.world_to_screen(target.pos)

			if (math.floor((RDamage(target) + PasDmg(target)) / target.health * 100) >= 100) then
				graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
				graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
				graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
				graphics.draw_text_2D(
					tostring("P+R: " .. math.floor(RDamage(target) + PasDmg(target))) ..
						" (" .. tostring(math.floor((RDamage(target) + PasDmg(target)) / target.health * 100)) .. "%)" .. "Kilable",
					20,
					pos.x + 55,
					pos.y - 80,
					graphics.argb(255, 150, 255, 200)
				)
			end
		end

		if not common.CheckBuff(target, "LuxIlluminatingFraulein") then
			local pos = graphics.world_to_screen(target.pos)
			if (math.floor((RDamage(target)) / target.health * 100) >= 100) then
				graphics.draw_line_2D(pos.x, pos.y - 30, pos.x + 30, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
				graphics.draw_line_2D(pos.x + 30, pos.y - 80, pos.x + 50, pos.y - 80, 1, graphics.argb(255, 150, 255, 200))
				graphics.draw_line_2D(pos.x + 50, pos.y - 85, pos.x + 50, pos.y - 75, 1, graphics.argb(255, 150, 255, 200))
				graphics.draw_text_2D(
					tostring("R: " .. math.floor(RDamage(target))) ..
						" (" .. tostring(math.floor((RDamage(target)) / target.health * 100)) .. "%)" .. "Kilable",
					20,
					pos.x + 55,
					pos.y - 80,
					graphics.argb(255, 150, 255, 200)
				)
			end
		end
	end
end
local function OnDraw()
	local pos = graphics.world_to_screen(vec3(player.x, player.y, player.z))
	local enemy = common.GetAllyHeroes()
	if player.isOnScreen then
		if menu.draws.drawe:get() then
			graphics.draw_circle(player.pos, spellE.range, 2, menu.draws.colore:get(), 100)
		end
		if menu.draws.drawq:get() then
			graphics.draw_circle(player.pos, spellQ.range, 2, menu.draws.colorq:get(), 100)
		end
	end
	if menu.draws.drawr:get() then
		if game.cameraPos then
			if (game.cameraPos:dist(player) <= spellR.range * 2) then
				graphics.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 80)
			end
		end

		minimap.draw_circle(player.pos, spellR.range, 2, menu.draws.colorr:get(), 30)
	end
	if menu.draws.drawdamage:get() then
		local enemy = common.GetEnemyHeroes()
		for i, enemies in ipairs(enemy) do
			if
				enemies and common.IsValidTarget(enemies) and player.pos:dist(enemies) < 3500 and
					not common.CheckBuffType(enemies, 17)
			 then
				DrawDamagesE(enemies)
			end
		end
	end
end

TS.load_to_menu(menu)
cb.add(cb.tick, OnTick)
cb.add(cb.draw, OnDraw)
cb.add(cb.spell, AutoInterrupt)
print("---------------------------------------------------")
print("Healer Lux v " .. version .. ": Loaded!")
print("Check the forums if you have the latest version!")
print("---------------------------------------------------")

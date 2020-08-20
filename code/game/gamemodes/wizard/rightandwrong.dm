

/mob/proc/rightandwrong(var/summon_type) //0 = Summon Guns, 1 = Summon Magic, 2 = Summon Swords
	to_chat(usr, "<B>You summoned [summon_type]!</B>")
	message_admins("[key_name_admin(usr, 1)] summoned [summon_type]!")
	log_game("[key_name(usr)] summoned [summon_type]!")

	var/datum/role/survivor_type

	switch (summon_type)
		if ("swords")
			survivor_type = /datum/role/survivor/crusader/
		if ("magic")
			survivor_type = /datum/role/wizard/summon_magic/
		if ("potions")
			survivor_type = /datum/role/wizard/summon_potions/
		else
			survivor_type = /datum/role/survivor/

	for(var/mob/living/carbon/human/H in player_list)

		if(H.stat == DEAD || !(H.client) || iswizard(H))
			continue

		if (prob(65))
			H.equip_survivor(survivor_type)
			continue

		var/datum/role/R = new survivor_type()
		H.equip_survivor(R)

		if (!(isrole(R.id, H)))
			R.AssignToRole(H.mind)
			R.Greet()
			R.OnPostSetup()
			R.ForgeObjectives()
			R.AnnounceObjectives()



/mob/living/carbon/human/proc/equip_survivor(var/R)
	var/summon_type
	if(istype(R,/datum/role))
		var/datum/role/surv = R
		summon_type = surv.type
	else if(ispath(R))
		summon_type = R
	else
		return
	switch (summon_type)
		if (/datum/role/survivor/crusader)
			return equip_swords(R)
		if (/datum/role/wizard/summon_magic)
			return equip_magician(R)
		if (/datum/role/wizard/summon_potions)
			return equip_potions(R)
		else
			return equip_guns(R)

/mob/living/carbon/human/proc/equip_guns(var/datum/role/R)
	var/randomizeguns = pick("taser","stunrevolver","egun","laser","retro","laserak","revolver","detective","c20r","nuclear","deagle","gyrojet","pulse","silenced","cannon","doublebarrel","shotgun","combatshotgun","mateba","smg","uzi","microuzi","crossbow","saw","hecate","osipr","gatling","bison","ricochet","spur","mosin","obrez","beegun","beretta","usp","glock","luger","colt","plasmapistol","plasmarifle", "ionpistol", "ioncarbine", "bulletstorm", "combustioncannon", "laserpistol", "siren", "lawgiver", "nt12", "automag")
	switch (randomizeguns)
		if("taser")
			new /obj/item/weapon/gun/energy/taser(get_turf(src))
		if("stunrevolver")
			new /obj/item/weapon/gun/energy/stunrevolver(get_turf(src))
		if("egun")
			new /obj/item/weapon/gun/energy/gun(get_turf(src))
		if("laser")
			new /obj/item/weapon/gun/energy/laser(get_turf(src))
		if("retro")
			new /obj/item/weapon/gun/energy/laser/retro(get_turf(src))
		if("laserak")
			new /obj/item/weapon/gun/energy/laser/LaserAK(get_turf(src))
		if("plasmapistol")
			new /obj/item/weapon/gun/energy/plasma/pistol(get_turf(src))
		if("plasmarifle")
			new /obj/item/weapon/gun/energy/plasma/light(get_turf(src))
		if("revolver")
			new /obj/item/weapon/gun/projectile/revolver(get_turf(src))
		if("detective")
			new /obj/item/weapon/gun/projectile/detective(get_turf(src))
		if("c20r")
			new /obj/item/weapon/gun/projectile/automatic/c20r(get_turf(src))
		if("nuclear")
			new /obj/item/weapon/gun/energy/gun/nuclear(get_turf(src))
		if("deagle")
			new /obj/item/weapon/gun/projectile/deagle/camo(get_turf(src))
		if("gyrojet")
			new /obj/item/weapon/gun/projectile/gyropistol(get_turf(src))
		if("pulse")
			new /obj/item/weapon/gun/energy/pulse_rifle(get_turf(src))
		if("silenced")
			new /obj/item/weapon/gun/projectile/pistol(get_turf(src))
			new /obj/item/gun_part/silencer(get_turf(src))
		if("cannon")
			new /obj/item/weapon/gun/energy/laser/cannon(get_turf(src))
		if("doublebarrel")
			new /obj/item/weapon/gun/projectile/shotgun/pump/(get_turf(src))
		if("shotgun")
			new /obj/item/weapon/gun/projectile/shotgun/pump/(get_turf(src))
		if("combatshotgun")
			new /obj/item/weapon/gun/projectile/shotgun/pump/combat(get_turf(src))
		if("mateba")
			new /obj/item/weapon/gun/projectile/mateba(get_turf(src))
		if("smg")
			new /obj/item/weapon/gun/projectile/automatic(get_turf(src))
		if("uzi")
			new /obj/item/weapon/gun/projectile/automatic/uzi(get_turf(src))
		if("microuzi")
			new /obj/item/weapon/gun/projectile/automatic/microuzi(get_turf(src))
		if("crossbow")
			new /obj/item/weapon/gun/energy/crossbow(get_turf(src))
		if("saw")
			new /obj/item/weapon/gun/projectile/automatic/l6_saw(get_turf(src))
		if("hecate")
			new /obj/item/weapon/gun/projectile/hecate(get_turf(src))
			new /obj/item/ammo_casing/BMG50(get_turf(src))//can't give a full box of such deadly bullets. 3 shots is plenty.
			new /obj/item/ammo_casing/BMG50(get_turf(src))
		if("osipr")
			new /obj/item/weapon/gun/osipr(get_turf(src))
		if("gatling")
			new /obj/item/weapon/gun/gatling(get_turf(src))
		if("bison")
			new /obj/item/weapon/gun/energy/bison(get_turf(src))
		if("ricochet")
			new /obj/item/weapon/gun/energy/ricochet(get_turf(src))
		if("spur")
			new /obj/item/weapon/gun/energy/polarstar(get_turf(src))
			new /obj/item/device/modkit/spur_parts(get_turf(src))
		if("mosin")
			new /obj/item/weapon/gun/projectile/mosin(get_turf(src))
		if("obrez")
			new /obj/item/weapon/gun/projectile/mosin/obrez(get_turf(src))
		if("beegun")
			new /obj/item/weapon/gun/gatling/beegun(get_turf(src))
		if("beretta")
			new /obj/item/weapon/gun/projectile/beretta(get_turf(src))
		if("usp")
			new /obj/item/weapon/gun/projectile/NTUSP/fancy(get_turf(src))
		if("glock")
			new /obj/item/weapon/gun/projectile/glock/fancy(get_turf(src))
		if("luger")
			new /obj/item/weapon/gun/projectile/luger(get_turf(src))
		if("colt")
			new /obj/item/weapon/gun/projectile/colt(get_turf(src))
		if("lawgiver")
			new /obj/item/weapon/gun/lawgiver(get_turf(src))
		if("ionpistol")
			new /obj/item/weapon/gun/energy/ionrifle/ioncarbine/ionpistol(get_turf(src))
		if("ioncarbine")
			new /obj/item/weapon/gun/energy/ionrifle/ioncarbine(get_turf(src))
		if("combustioncannon")
			new /obj/item/weapon/gun/energy/laser/captain/combustion(get_turf(src))
		if("laserpistol")
			new /obj/item/weapon/gun/energy/laser/pistol(get_turf(src))
		if("siren")
			new /obj/item/weapon/gun/siren(get_turf(src))
		if("bulletstorm")
			new /obj/item/weapon/gun/bulletstorm(get_turf(src))
		if("nt12")
			new /obj/item/weapon/gun/projectile/shotgun/nt12(get_turf(src))
		if ("automag")
			new /obj/item/weapon/gun/projectile/automag/prestige(get_turf(src))
	var/datum/role/survivor/S = R
	if(istype(S))
		S.summons_received = randomizeguns
	playsound(src,'sound/effects/summon_guns.ogg', 50, 1)
	score["gunsspawned"]++

/mob/living/carbon/human/proc/equip_swords(var/datum/role/R)
	var/randomizeswords = pick("unlucky", "misc", "throw", "armblade", "pickaxe", "pcutter", "esword", "alt-esword", "machete", "kitchen", "medieval", "katana", "axe", "boot", "saw", "scalpel", "switchtool", "shitcurity")
	var/randomizeknightcolor = pick("green", "yellow", "blue", "red", "templar", "roman")
	switch (randomizeknightcolor) //everyone gets some armor as well
		if("green")
			new /obj/item/clothing/suit/armor/knight(get_turf(src))
			new /obj/item/clothing/head/helmet/knight(get_turf(src))
			if(prob(50)) //chance for a shield
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("yellow")
			new /obj/item/clothing/suit/armor/knight/yellow(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/yellow(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("blue")
			new /obj/item/clothing/suit/armor/knight/blue(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/blue(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("red")
			new /obj/item/clothing/suit/armor/knight/red(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/red(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("templar")
			new /obj/item/clothing/suit/armor/knight/templar(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/templar(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("roman")
			new /obj/item/clothing/under/roman(get_turf(src))
			new /obj/item/clothing/head/helmet/roman(get_turf(src))
			new /obj/item/clothing/shoes/roman(get_turf(src))
			new /obj/item/weapon/shield/riot/roman(get_turf(src)) //guaranteed shield to make up for the lack of armor. Also fits the theme better.

	switch (randomizeswords)
		if("unlucky") //so the chance to get an unlucky item does't clutter the main pool of swords
			var/noluck = pick(/obj/item/weapon/kitchen/utensil/knife/plastic, /obj/item/weapon/screwdriver, /obj/item/weapon/wirecutters, /obj/item/toy/foamblade, /obj/item/toy/sword, /obj/item/weapon/shard, /obj/item/weapon/shard/plasma, /obj/abstract/map/spawner/space/drinks, /obj/item/weapon/sord, /obj/item/weapon/melee/training_sword, /obj/item/weapon/macuahuitl, /obj/item/weapon/gavelhammer, /obj/item/weapon/banhammer, /obj/item/weapon/veilrender/vealrender, /obj/item/weapon/bikehorn/baton)
			new noluck(get_turf(src))
		if("misc")
			var/miscpick = pick(/obj/item/weapon/scythe, /obj/item/weapon/harpoon, /obj/item/weapon/sword, /obj/item/weapon/sword/executioner, /obj/item/weapon/claymore, /obj/item/weapon/melee/cultblade/nocult, /obj/item/weapon/sword/venom)
			new miscpick(get_turf(src))
		if("throw")
			if(prob(20))
				if(prob(50))
					new /obj/item/weapon/kitchen/utensil/knife/nazi(get_turf(src))
				else
					new /obj/item/weapon/gun/hookshot/whip(get_turf(src))
			else
				new /obj/item/weapon/hatchet(get_turf(src))
		if("armblade") // good luck getting it off. Maybe cut your own arm off :^)
			new /obj/item/weapon/armblade(get_turf(src))
		if("pickaxe")
			var/pickedaxe = pick(/obj/item/weapon/pickaxe, /obj/item/weapon/pickaxe/silver, /obj/item/weapon/pickaxe/gold, /obj/item/weapon/pickaxe/diamond)
			new pickedaxe(get_turf(src))
		if("pcutter")
			new /obj/item/weapon/pickaxe/plasmacutter(get_turf(src))
		if("esword")
			new /obj/item/weapon/melee/energy/sword(get_turf(src))
			if(prob(70)) //chance for a second one to make a double esword
				new /obj/item/weapon/melee/energy/sword(get_turf(src))
		if("alt-esword")
			if(prob(75))
				new /obj/item/weapon/melee/energy/sword/pirate(get_turf(src))
				if(prob(70))
					new /obj/item/weapon/melee/energy/sword/pirate(get_turf(src))
			else //hope you're the clown
				new /obj/item/weapon/melee/energy/sword/bsword(get_turf(src))
				if(prob(70))
					new /obj/item/weapon/melee/energy/sword/bsword(get_turf(src))
		if("machete")
			new /obj/item/weapon/melee/energy/hfmachete(get_turf(src))
			if(prob(70))
				new /obj/item/weapon/melee/energy/hfmachete(get_turf(src))
		if("kitchen")
			if(prob(60))
				if(prob(25))
					new /obj/item/weapon/kitchen/utensil/knife/large(get_turf(src))
				else
					new /obj/item/weapon/kitchen/utensil/knife/large/butch(get_turf(src))
			else
				new /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver(get_turf(src))
		if("medieval")
			if(prob(70))
				if(prob(50))
					new /obj/item/weapon/spear/wooden(get_turf(src))
				else
					new /obj/item/weapon/melee/lance(get_turf(src))
			else
				new /obj/item/weapon/melee/morningstar(get_turf(src))
		if("katana")
			new /obj/item/weapon/katana(get_turf(src))
			if(prob(25))
				new /obj/item/clothing/head/kitty(get_turf(src))
					//No fun allowed, maybe nerf later and readd
					/*
					if(prob(5))
						new /obj/item/weapon/katana/hfrequency(get_turf(src))
					else
						new /obj/item/weapon/katana(get_turf(src))
					*/
		if("axe")
			if(prob(50))
				new /obj/item/weapon/melee/energy/axe/rusty(get_turf(src))
			else
				new /obj/item/weapon/fireaxe(get_turf(src))
		if("boot")
			if(prob(50))
				new /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical(get_turf(src))
			else
				new /obj/item/clothing/accessory/holster/knife/boot/preloaded/skinning(get_turf(src))
		if("saw")
			if(prob(40))
				new /obj/item/weapon/circular_saw/plasmasaw(get_turf(src))
			else
				new /obj/item/weapon/circular_saw(get_turf(src))
		if("scalpel")
			if(prob(60))
				if(prob(50))
					new /obj/item/weapon/scalpel/laser(get_turf(src))
				else
					new /obj/item/weapon/scalpel/laser/tier2(get_turf(src))
			else
				new /obj/item/weapon/scalpel(get_turf(src))
		if("switchtool")
			if(prob(40))
				if(prob(50))
					new /obj/item/weapon/switchtool(get_turf(src))
				else
					new /obj/item/weapon/switchtool/surgery(get_turf(src))
			else
				new /obj/item/weapon/switchtool/swiss_army_knife(get_turf(src))
		if("shitcurity") //Might as well give the Redtide a taste of their own medicine.
			var/shitcurity = pick(/obj/item/weapon/melee/telebaton, /obj/item/weapon/melee/classic_baton, /obj/item/weapon/melee/baton/loaded, /obj/item/weapon/melee/baton/cattleprod,/obj/item/weapon/melee/chainofcommand)
			new shitcurity(get_turf(src))
	var/datum/role/survivor/crusader/S = R
	if(istype(S))
		S.summons_received = randomizeswords
	playsound(src,'sound/items/zippo_open.ogg', 50, 1)

/mob/living/carbon/human/proc/equip_magician(var/datum/role/R)
	var/randomizemagic = pick("fireball","smoke","blind","forcewall","knock","horsemask","blink","disorient","clowncurse", "mimecurse", "shoesnatch","emp", "magicmissile", "mutate", "teleport", "jaunt", "buttbot", "lightning", "timestop", "ringoffire", "painmirror", "bound_object", "firebreath", "snakes", "push", "pie")
	var/randomizemagecolor = pick("magician", "magusred", "magusblue", "blue", "red", "necromancer", "clown", "purple", "lich", "skelelich", "marisa", "fake")
	switch (randomizemagecolor) //everyone can put on their robes and their wizard hat
		if("magician")
			new /obj/item/clothing/head/that/magic(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magician(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa/leather(get_turf(src))
		if("magusred")
			new /obj/item/clothing/head/wizard/magus(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magusred(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("magusblue")
			new /obj/item/clothing/head/wizard/magus(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magusblue(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("blue")
			new /obj/item/clothing/head/wizard(get_turf(src))
			new /obj/item/clothing/suit/wizrobe(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("red")
			new /obj/item/clothing/head/wizard/red(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/red(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("necromancer")
			new /obj/item/clothing/head/wizard/necro(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/necro(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("clown")
			new /obj/item/clothing/head/wizard/clown(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/clown(get_turf(src))
			new /obj/item/clothing/mask/gas/clown_hat/wiz(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("purple")
			new /obj/item/clothing/head/wizard/amp(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/psypurple(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa/leather(get_turf(src))
		if("lich")
			new /obj/item/clothing/head/wizard/lich(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/lich(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("skelelich")
			new /obj/item/clothing/head/wizard/skelelich(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/skelelich(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("marisa")
			new /obj/item/clothing/head/wizard/marisa(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/marisa(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa(get_turf(src))
		if("fake")
			new /obj/item/clothing/head/wizard/fake(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/fake(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))

	switch (randomizemagic)
		if("fireball")
			new /obj/item/weapon/spellbook/oneuse/fireball(get_turf(src))
		if("smoke")
			new /obj/item/weapon/spellbook/oneuse/smoke(get_turf(src))
		if("blind")
			new /obj/item/weapon/spellbook/oneuse/blind(get_turf(src))
		if("forcewall")
			new /obj/item/weapon/spellbook/oneuse/forcewall(get_turf(src))
		if("knock")
			new /obj/item/weapon/spellbook/oneuse/knock(get_turf(src))
		if("horsemask")
			new /obj/item/weapon/spellbook/oneuse/horsemask(get_turf(src))
		if("blink")
			new /obj/item/weapon/spellbook/oneuse/teleport/blink(get_turf(src))
		if("disorient")
			new /obj/item/weapon/spellbook/oneuse/disorient(get_turf(src))
		if("clowncurse")
			new /obj/item/weapon/spellbook/oneuse/clown(get_turf(src))
		if("mimecurse")
			new /obj/item/weapon/spellbook/oneuse/mime(get_turf(src))
		if("shoesnatch")
			new /obj/item/weapon/spellbook/oneuse/shoesnatch(get_turf(src))
		if("emp")
			new /obj/item/weapon/spellbook/oneuse/disabletech(get_turf(src))
		if("magicmissile")
			new /obj/item/weapon/spellbook/oneuse/magicmissle(get_turf(src))
		if("mutate")
			new /obj/item/weapon/spellbook/oneuse/mutate(get_turf(src))
		if("teleport")
			new /obj/item/weapon/spellbook/oneuse/teleport(get_turf(src))
		if("jaunt")
			new /obj/item/weapon/spellbook/oneuse/teleport/jaunt(get_turf(src))
		if("buttbot")
			new /obj/item/weapon/spellbook/oneuse/buttbot(get_turf(src))
		if("lightning")
			new /obj/item/weapon/spellbook/oneuse/lightning(get_turf(src))
		if("timestop")
			new /obj/item/weapon/spellbook/oneuse/timestop(get_turf(src))
		if("ringoffire")
			new /obj/item/weapon/spellbook/oneuse/ringoffire(get_turf(src))
		if("painmirror")
			new /obj/item/weapon/spellbook/oneuse/mirror_of_pain(get_turf(src))
		if("bound_object") //at least they can bind the Supermatter.
			new /obj/item/weapon/spellbook/oneuse/bound_object(get_turf(src))
		if("firebreath")
			new /obj/item/weapon/spellbook/oneuse/firebreath(get_turf(src))
		if("snakes")
			new /obj/item/weapon/spellbook/oneuse/snakes(get_turf(src))
		if("push")
			new /obj/item/weapon/spellbook/oneuse/push(get_turf(src))
		if("pie")
			new /obj/item/weapon/spellbook/oneuse/pie(get_turf(src))
		if("ice_barrage")
			new /obj/item/weapon/spellbook/oneuse/ice_barrage(get_turf(src))
	var/datum/role/wizard/summon_magic/S = R
	if(istype(S))
		S.summons_received = randomizemagic

/mob/living/carbon/human/proc/equip_potions(var/datum/role/R)
	var/datum/role/survivor/S = R
	for(var/i=0, i<3, i++)
		var/potion = get_random_potion()
		new potion(get_turf(src))
		if(istype(potion, /obj/item/potion/deception))	//Warn someone if that healing potion they just got is a fake one. If they managed to get a heal potion AND deception potion they're fucked though.
			to_chat(src, "You feel like it's a bad idea to drink [potion.name] yourself...")
		if(istype(S))
			S.summons_received += potion.name
	playsound(src,'sound/effects/summon_guns.ogg', 50, 1)

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
		if ("artifact")
			survivor_type = /datum/role/wizard/summon_magic/artifact/
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

		var/datum/role/R = survivor_type

		if (!(isrole(initial(R.id), H)))
			R = new survivor_type()
			H.equip_survivor(R)
			R.AssignToRole(H.mind)
			R.Greet(GREET_RIGHTANDWRONG)
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
		if (/datum/role/wizard/summon_magic/artifact/)
			return equip_artifact(R)
		if (/datum/role/wizard/summon_potions)
			return equip_potions(R)
		else
			return equip_guns(R)

//Reworked summoning code
//Will now track spawned items so that they show up at the round-end scoreboard
//selected_path: The item to be spawned and the main item which will determine what name and image show up
//override_icon: When you want the image to have a different icon
//override_icon_state: Ditto for icon state
//override_item_name: Can make the item show up with a different name as needed
//Clothes-giving code remains relatively untouched

/mob/living/carbon/human/proc/equip_guns(var/datum/role/R)
	var/randomizeguns = pick("Taser", "Stun Revolver", "Energy Gun", "Laser Gun", "Laser Musket", "Retro Laser Gun",
							"Disintegrator", "Heavy Disintegrator", "Laser AK470", "Plasma Pistol", "Plasma Rifle",
							"Revolver", "Detective's Revolver", "C-20r SMG", "Advanced Energy Gun", "Desert Eagle",
							"Gyrojet Pistol", "Pulse Rifle", "Silenced Pistol", "Laser Cannon", "Double-barreled Shotgun",
							"Shotgun", "Combat Shotgun", "Mateba", "Submachine Gun", "Uzi", "Micro Uzi",
							"Mini Energy-Crossbow", "L6 SAW", "PGM Hécate II", "Overwatch Standard Issue Pulse Rifle",
							"Gatling Gun", "Righteous Bison", "Ricochet Rifle", "Spur", "Mosin Nagant", "Obrez",
							"Bee Gun", "Chillbug Gun", "Hornet Gun", "Beretta 92FS", "NT USP", "NT Glock", "Luger P08",
							"Colt Single Action Army", "Lawgiver", "Ion Pistol", "Ion Carbine", "Combustion Cannon",
							"Laser Pistol", "Siren", "Bullet Storm", "NT-12", "Prestige Automag VI", "Lolly Lobber")
	var/selected_path //Used for determining icon and name so that it shows up at the scoreboard
	var/override_icon //In case an item should look like something else, such as the Spur
	var/override_icon_state
	var/override_item_name //In case you want the randomizeguns to say a different name instead
	switch(randomizeguns)
		if("Taser")
			selected_path = /obj/item/weapon/gun/energy/taser
		if("Stun Revolver")
			selected_path = /obj/item/weapon/gun/energy/stunrevolver
		if("Energy Gun")
			selected_path = /obj/item/weapon/gun/energy/gun
		if("Laser Gun")
			selected_path = /obj/item/weapon/gun/energy/laser
		if("Laser Musket")
			selected_path = /obj/item/weapon/gun/energy/lasmusket/preloaded
		if("Retro Laser Gun")
			selected_path = /obj/item/weapon/gun/energy/laser/retro
		if("Disintegrator")
			selected_path = /obj/item/weapon/gun/energy/smalldisintegrator
		if("Heavy Disintegrator")
			selected_path = /obj/item/weapon/gun/energy/heavydisintegrator
		if("Laser AK470")
			selected_path = /obj/item/weapon/gun/energy/laser/LaserAK
		if("Plasma Pistol")
			selected_path = /obj/item/weapon/gun/energy/plasma/pistol
		if("Plasma Rifle")
			selected_path = /obj/item/weapon/gun/energy/plasma/light
		if("Revolver")
			selected_path = /obj/item/weapon/gun/projectile/revolver
		if("Detective's Revolver")
			selected_path = /obj/item/weapon/gun/projectile/detective
		if("C-20r SMG")
			selected_path = /obj/item/weapon/gun/projectile/automatic/c20r
		if("Advanced Energy Gun")
			selected_path = /obj/item/weapon/gun/energy/gun/nuclear
		if("Desert Eagle")
			selected_path = /obj/item/weapon/gun/projectile/deagle/camo
		if("Gyrojet Pistol")
			selected_path = /obj/item/weapon/gun/projectile/gyropistol
		if("Pulse Rifle")
			selected_path = /obj/item/weapon/gun/energy/pulse_rifle
		if("Silenced Pistol")
			override_item_name = "Silenced Pistol"
			selected_path = /obj/item/weapon/gun/projectile/pistol
			override_icon_state = "pistol-silencer"
			new /obj/item/gun_part/silencer(get_turf(src))
		if("Laser Cannon")
			selected_path = /obj/item/weapon/gun/energy/laser/cannon
		if("Double-barreled Shotgun")
			selected_path = /obj/item/weapon/gun/projectile/shotgun/doublebarrel
		if("Shotgun")
			selected_path = /obj/item/weapon/gun/projectile/shotgun/pump
		if("Combat Shotgun")
			selected_path = /obj/item/weapon/gun/projectile/shotgun/pump/combat
		if("Mateba")
			selected_path = /obj/item/weapon/gun/projectile/mateba
		if("Submachine Gun")
			selected_path = /obj/item/weapon/gun/projectile/automatic
		if("Uzi")
			selected_path = /obj/item/weapon/gun/projectile/automatic/uzi
		if("Micro Uzi")
			selected_path = /obj/item/weapon/gun/projectile/automatic/microuzi
		if("Mini Energy-Crossbow")
			selected_path = /obj/item/weapon/gun/energy/crossbow
		if("L6 SAW")
			selected_path = /obj/item/weapon/gun/projectile/automatic/l6_saw
		if("PGM Hécate II")
			selected_path = /obj/item/weapon/gun/projectile/hecate
			new /obj/item/ammo_casing/BMG50(get_turf(src))//can't give a full box of such deadly bullets. 3 shots is plenty.
			new /obj/item/ammo_casing/BMG50(get_turf(src))
		if("Overwatch Standard Issue Pulse Rifle")
			selected_path = /obj/item/weapon/gun/osipr
		if("Gatling Gun")
			selected_path = /obj/item/weapon/gun/gatling
		if("Righteous Bison")
			selected_path = /obj/item/weapon/gun/energy/bison
		if("Ricochet Rifle")
			selected_path = /obj/item/weapon/gun/energy/ricochet
		if("Spur")
			selected_path = /obj/item/weapon/gun/energy/polarstar
			override_icon_state = "spur"
			override_item_name = "Spur"
			new /obj/item/device/modkit/spur_parts(get_turf(src))
		if("Mosin Nagant")
			selected_path = /obj/item/weapon/gun/projectile/mosin
		if("Obrez")
			selected_path = /obj/item/weapon/gun/projectile/mosin/obrez
		if("Bee Gun")
			selected_path = /obj/item/weapon/gun/gatling/beegun
		if("Chillbug Gun")
			selected_path = /obj/item/weapon/gun/gatling/beegun/chillgun
		if("Hornet Gun")
			selected_path = /obj/item/weapon/gun/gatling/beegun/hornetgun
		if("Beretta 92FS")
			selected_path = /obj/item/weapon/gun/projectile/beretta
		if("NT USP")
			selected_path = /obj/item/weapon/gun/projectile/NTUSP/fancy
		if("NT Glock")
			selected_path = /obj/item/weapon/gun/projectile/glock/fancy
		if("Luger P08")
			selected_path = /obj/item/weapon/gun/projectile/luger
		if("Colt Single Action Army")
			selected_path = /obj/item/weapon/gun/projectile/colt
		if("Lawgiver")
			selected_path = /obj/item/weapon/gun/lawgiver
		if("Ion Pistol")
			selected_path = /obj/item/weapon/gun/energy/ionrifle/ioncarbine/ionpistol
		if("Ion Carbine")
			selected_path = /obj/item/weapon/gun/energy/ionrifle/ioncarbine
		if("Combustion Cannon")
			selected_path = /obj/item/weapon/gun/energy/laser/captain/combustion
		if("Laser Pistol")
			selected_path = /obj/item/weapon/gun/energy/laser/pistol
		if("Siren")
			selected_path = /obj/item/weapon/gun/siren
		if("Bullet Storm")
			selected_path = /obj/item/weapon/gun/bulletstorm
		if("NT-12")
			selected_path = /obj/item/weapon/gun/projectile/shotgun/nt12
		if("Prestige Automag VI")
			selected_path = /obj/item/weapon/gun/projectile/automag/prestige
		if("Lolly Lobber")
			selected_path = /obj/item/weapon/gun/lolly_lobber

	var/atom/spawned_gun = new selected_path(get_turf(src))
	var/datum/role/survivor/S = R
	if(istype(S))
		var/icon_to_use = override_icon ? override_icon : spawned_gun.icon
		var/icon_state_to_use = override_icon_state ? override_icon_state : spawned_gun.icon_state
		var/icon/gun_sprite = icon(icon_to_use, icon_state_to_use)
		var/list/data_list = list(
		"item_name" = "[override_item_name ? override_item_name : capitalize(spawned_gun.name)]",
		"icon" = "<img class='icon' src='data:image/png;base64,[iconsouth2base64(gun_sprite)]'>",
		)
		S.summons_received += list(data_list)
	playsound(src,'sound/effects/summon_guns.ogg', 50, 1)
	score.gunsspawned++

/mob/living/carbon/human/proc/equip_swords(var/datum/role/R)
	var/selected_path
	var/override_icon
	var/override_icon_state
	var/override_item_name
	var/randomizeknightcolor = pick("Green", "Yellow", "Blue", "Red", "Templar", "Roman")
	switch (randomizeknightcolor) //everyone gets some armor as well
		if("Green")
			new /obj/item/clothing/suit/armor/knight(get_turf(src))
			new /obj/item/clothing/head/helmet/knight(get_turf(src))
			if(prob(50)) //chance for a shield
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("Yellow")
			new /obj/item/clothing/suit/armor/knight/yellow(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/yellow(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("Blue")
			new /obj/item/clothing/suit/armor/knight/blue(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/blue(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("Red")
			new /obj/item/clothing/suit/armor/knight/red(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/red(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("Templar")
			new /obj/item/clothing/suit/armor/knight/templar(get_turf(src))
			new /obj/item/clothing/head/helmet/knight/templar(get_turf(src))
			if(prob(50))
				new /obj/item/weapon/shield/riot/buckler(get_turf(src))
		if("Roman")
			new /obj/item/clothing/under/roman(get_turf(src))
			new /obj/item/clothing/head/helmet/roman(get_turf(src))
			new /obj/item/clothing/shoes/roman(get_turf(src))
			new /obj/item/weapon/shield/riot/roman(get_turf(src)) //guaranteed shield to make up for the lack of armor. Also fits the theme better.


	var/randomizeswords = pick("Unlucky", "Miscellaneous", "Throwable", "Armblade", "Pickaxe", "Plasma Cutter",
								"Energy Sword", "Alternate Energy Sword", "Machete", "Kitchen Knife", "Medieval",
								"Katana", "Axe", "Bootknife", "Circular Saw", "Scalpel", "Switchtool", "Shitcurity", "Whip")
	switch (randomizeswords)
		if("Unlucky") //so the chance to get an unlucky item does't clutter the main pool of swords
			var/noluck = pick(/obj/item/weapon/kitchen/utensil/knife/plastic, /obj/item/tool/screwdriver,
								/obj/item/tool/wirecutters, /obj/item/toy/foamblade, /obj/item/toy/sword,
								/obj/item/weapon/shard, /obj/item/weapon/shard/plasma,
								/obj/abstract/map/spawner/space/drinks, /obj/item/weapon/sord,
								/obj/item/weapon/melee/training_sword, /obj/item/weapon/macuahuitl,
								/obj/item/weapon/gavelhammer, /obj/item/weapon/banhammer,
								/obj/item/weapon/veilrender/vealrender, /obj/item/weapon/bikehorn/baton)
			selected_path = noluck
		if("Miscellaneous")
			var/miscpick = pick(/obj/item/weapon/scythe, /obj/item/weapon/harpoon,
								/obj/item/weapon/sword, /obj/item/weapon/sword/executioner,
								/obj/item/weapon/claymore, /obj/item/weapon/melee/cultblade/nocult,
								/obj/item/weapon/sword/venom)
			selected_path = miscpick
		if("Throwable")
			if(prob(20))
				selected_path = /obj/item/weapon/kitchen/utensil/knife/nazi
			else
				selected_path = /obj/item/weapon/hatchet
		if("Armblade") // good luck getting it off. Maybe cut your own arm off :^)
			selected_path = /obj/item/weapon/armblade
		if("Pickaxe")
			var/pickedaxe = pick(/obj/item/weapon/pickaxe, /obj/item/weapon/pickaxe/silver,
								/obj/item/weapon/pickaxe/gold, /obj/item/weapon/pickaxe/diamond)
			selected_path = pickedaxe
		if("Plasma Cutter")
			selected_path = /obj/item/weapon/pickaxe/plasmacutter
		if("Energy Sword")
			selected_path = /obj/item/weapon/melee/energy/sword
			override_icon_state = "swordred"
			if(prob(70)) //chance for a second one to make a double esword
				override_item_name = "Double-bladed Energy Sword"
				override_icon_state = "dualsaberredred"
				new /obj/item/weapon/melee/energy/sword
		if("Alternate Energy Sword")
			if(prob(75))
				selected_path = /obj/item/weapon/melee/energy/sword/pirate
				override_icon_state = "cutlass1"
				if(prob(70))
					override_item_name = "TWO Pirate Cutlasses!"
					new /obj/item/weapon/melee/energy/sword/pirate
			else //hope you're the clown
				selected_path = /obj/item/weapon/melee/energy/sword/bsword
				override_item_name = "Energized Bananium Sword"
				override_icon_state = "bsword1"
				if(prob(70))
					override_icon_state = "bananabunch1"
					override_item_name = "Bunch of Energized Bananium Swords"
					new /obj/item/weapon/melee/energy/sword/bsword
		if("High-Frequency Machete")
			selected_path = /obj/item/weapon/melee/energy/hfmachete
			if(prob(70))
				override_icon_state = "bloodlust0"
				override_item_name = "High-Frequency Pincer Blade \"Bloodlust\""
				new /obj/item/weapon/melee/energy/hfmachete
		if("Kitchen Knife")
			if(prob(60))
				if(prob(25))
					selected_path = /obj/item/weapon/kitchen/utensil/knife/large
				else
					selected_path = /obj/item/weapon/kitchen/utensil/knife/large/butch
			else
				selected_path = /obj/item/weapon/kitchen/utensil/knife/large/butch/meatcleaver
		if("Medieval")
			if(prob(70))
				if(prob(50))
					selected_path = /obj/item/weapon/spear/wooden
				else
					selected_path = /obj/item/weapon/melee/lance
			else
				selected_path = /obj/item/weapon/melee/morningstar
		if("Katana")
			selected_path = /obj/item/weapon/katana
			if(prob(25))
				new /obj/item/clothing/head/kitty(get_turf(src))
					//No fun allowed, maybe nerf later and readd
					/*
					if(prob(5))
						new /obj/item/weapon/katana/hfrequency(get_turf(src))
					else
						new /obj/item/weapon/katana(get_turf(src))
					*/
		if("Axe")
			if(prob(50))
				selected_path = /obj/item/weapon/melee/energy/axe/rusty
				override_icon_state = "axe1"
			else
				selected_path = /obj/item/weapon/fireaxe
		if("Bootknife")
			if(prob(50))
				selected_path = /obj/item/clothing/accessory/holster/knife/boot/preloaded/tactical
				override_icon = 'icons/obj/weapons.dmi'
				override_icon_state = "tacknife"
			else
				selected_path = /obj/item/clothing/accessory/holster/knife/boot/preloaded/skinning
				override_icon = 'icons/obj/weapons.dmi'
				override_icon_state = "skinningknife"

		if("Circular Saw")
			if(prob(40))
				selected_path = /obj/item/tool/circular_saw/plasmasaw
			else
				selected_path = /obj/item/tool/circular_saw
		if("Scalpel")
			if(prob(60))
				if(prob(50))
					selected_path = /obj/item/tool/scalpel/laser
				else
					selected_path = /obj/item/tool/scalpel/laser/tier2
			else
				selected_path = /obj/item/tool/scalpel
		if("Switchtool")
			if(prob(40))
				if(prob(50))
					selected_path = /obj/item/weapon/switchtool
				else
					selected_path = /obj/item/weapon/switchtool/surgery
			else
				selected_path = /obj/item/weapon/switchtool/swiss_army_knife
		if("Shitcurity") //Might as well give the Redtide a taste of their own medicine.
			var/shitcurity = pick(/obj/item/weapon/melee/telebaton, /obj/item/weapon/melee/classic_baton,
								/obj/item/weapon/melee/baton/loaded, /obj/item/weapon/melee/baton/cattleprod,
								/obj/item/weapon/melee/chainofcommand)
			selected_path = shitcurity
		if("Whip")
			if(prob(50))
				selected_path = /obj/item/weapon/gun/hookshot/whip
			else
				selected_path = /obj/item/projectile/hookshot/whip/liquorice

	var/atom/spawned_melee = new selected_path(get_turf(src))
	var/datum/role/survivor/crusader/S = R
	if(istype(S))
		var/icon_to_use = override_icon ? override_icon : spawned_melee.icon
		var/icon_state_to_use = override_icon_state ? override_icon_state : spawned_melee.icon_state
		var/icon/melee_sprite = icon(icon_to_use, icon_state_to_use)
		var/list/data_list = list(
		"item_name" = "[override_item_name ? override_item_name : capitalize(spawned_melee.name)]",
		"icon" = "<img class='icon' src='data:image/png;base64,[iconsouth2base64(melee_sprite)]'>",
		)
		S.summons_received += list(data_list)
	playsound(src,'sound/items/zippo_open.ogg', 50, 1)


/mob/living/carbon/human/proc/equip_magician(var/datum/role/R)
	var/selected_path
	var/override_icon
	var/override_icon_state
	var/override_item_name
	var/randomizemagecolor = pick("Magician", "Red Magus", "Blue Magus", "Blue", "Red", "Necromancer",
								"Clown", "Purple", "Lich", "Skeleton Lich", "Marisa", "Fake")
	switch (randomizemagecolor) //everyone can put on their robes and their wizard hat
		if("Magician")
			new /obj/item/clothing/head/that/magic(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magician(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa/leather(get_turf(src))
		if("Red Magus")
			new /obj/item/clothing/head/wizard/magus(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magusred(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Blue Magus")
			new /obj/item/clothing/head/wizard/magus(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magusblue(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Blue")
			new /obj/item/clothing/head/wizard(get_turf(src))
			new /obj/item/clothing/suit/wizrobe(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Red")
			new /obj/item/clothing/head/wizard/red(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/red(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Necromancer")
			new /obj/item/clothing/suit/wizrobe/necro(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Clown")
			new /obj/item/clothing/head/wizard/clown(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/clown(get_turf(src))
			new /obj/item/clothing/mask/gas/clown_hat/wiz(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Purple")
			new /obj/item/clothing/head/wizard/amp(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/psypurple(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa/leather(get_turf(src))
		if("Lich")
			new /obj/item/clothing/head/wizard/lich(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/lich(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Skeleton Lich")
			new /obj/item/clothing/head/wizard/skelelich(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/skelelich(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Marisa")
			new /obj/item/clothing/head/wizard/marisa(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/marisa(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa(get_turf(src))
		if("Fake")
			new /obj/item/clothing/head/wizard/fake(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/fake(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))

	var/randomizemagic = pick("Fireball","Smoke","Blind","Force Wall","Knock","Horse Mask","Blink","Disorient","Clown Curse",
							"Mime Curse", "Shoe Snatch","EMP", "Magic Missile", "Mutate", "Teleport", "Jaunt", "Buttbot",
							"Lightning", "Time Stop", "Ring of Fire", "Pain Mirror", "Bind Object", "Fire Breath", "Snakes",
							"Push", "Pie", "Ice Barrage", "Alchemy")
	switch (randomizemagic)
		if("Fireball")
			override_item_name = "Fireball"
			selected_path = /obj/item/weapon/spellbook/oneuse/fireball
		if("Smoke")
			override_item_name = "Smoke"
			selected_path = /obj/item/weapon/spellbook/oneuse/smoke
		if("Blind")
			override_item_name = "Blind"
			selected_path = /obj/item/weapon/spellbook/oneuse/blind
		if("Force Wall")
			override_item_name = "Force Wall"
			selected_path = /obj/item/weapon/spellbook/oneuse/forcewall
		if("Knock")
			override_item_name = "Knock"
			selected_path = /obj/item/weapon/spellbook/oneuse/knock
		if("Horse Mask")
			override_item_name = "Curse of the Horseman"
			selected_path = /obj/item/weapon/spellbook/oneuse/horsemask
		if("Blink")
			override_item_name = "Blink"
			selected_path = /obj/item/weapon/spellbook/oneuse/teleport/blink
		if("Disorient")
			override_item_name = "Disorient"
			selected_path = /obj/item/weapon/spellbook/oneuse/disorient
		if("Clown Curse")
			override_item_name = "The Clown Curse"
			selected_path = /obj/item/weapon/spellbook/oneuse/clown
		if("Mime Curse")
			override_item_name = "French Curse"
			selected_path = /obj/item/weapon/spellbook/oneuse/mime
		if("Shoe Snatch")
			override_item_name = "Shoe Snatching Charm"
			selected_path = /obj/item/weapon/spellbook/oneuse/shoesnatch
		if("EMP")
			override_item_name = "Disable Tech"
			selected_path = /obj/item/weapon/spellbook/oneuse/disabletech
		if("Magic Missile")
			override_item_name = "Magic Missile"
			selected_path = /obj/item/weapon/spellbook/oneuse/magicmissle
		if("Mutate")
			override_item_name = "Mutate"
			selected_path = /obj/item/weapon/spellbook/oneuse/mutate
		if("Teleport")
			override_item_name = "Teleport"
			selected_path = /obj/item/weapon/spellbook/oneuse/teleport
		if("Jaunt")
			override_item_name = "Ethereal Jaunt"
			selected_path = /obj/item/weapon/spellbook/oneuse/teleport/jaunt
		if("Buttbot")
			override_item_name = "Butt-Bot's Revenge"
			selected_path = /obj/item/weapon/spellbook/oneuse/buttbot
		if("Lightning")
			override_item_name = "Lightning"
			selected_path = /obj/item/weapon/spellbook/oneuse/lightning
		if("Time Stop")
			override_item_name = "Time Stop"
			selected_path = /obj/item/weapon/spellbook/oneuse/timestop
		if("Ring of Fire")
			override_item_name = "Ring of Fire"
			selected_path = /obj/item/weapon/spellbook/oneuse/ringoffire
		if("Pain Mirror")
			override_item_name = "Pain Mirror"
			selected_path = /obj/item/weapon/spellbook/oneuse/mirror_of_pain
		if("Bind Object") //at least they can bind the Supermatter. //No they can't
			override_item_name = "Bind Object"
			selected_path = /obj/item/weapon/spellbook/oneuse/bound_object
		if("Fire Breath")
			override_item_name = "Fire Breath"
			selected_path = /obj/item/weapon/spellbook/oneuse/firebreath
		if("Snakes")
			override_item_name = "Become Snakes"
			selected_path = /obj/item/weapon/spellbook/oneuse/snakes
		if("Push")
			override_item_name = "Dimensional Push"
			selected_path = /obj/item/weapon/spellbook/oneuse/push
		if("Pie")
			override_item_name = "Projectile Pastry"
			selected_path = /obj/item/weapon/spellbook/oneuse/pie
		if("Ice Barrage")
			override_item_name = "Ice Barrage"
			selected_path = /obj/item/weapon/spellbook/oneuse/ice_barrage
		if("Alchemy")
			override_item_name = "Street Alchemy"
			selected_path = /obj/item/weapon/spellbook/oneuse/alchemy

	var/receive_absorb = !(locate(/spell/targeted/absorb) in spell_list)

	if(receive_absorb)
		add_spell(/spell/targeted/absorb)

	var/atom/spawned_spellbook = new selected_path(get_turf(src))
	var/datum/role/wizard/summon_magic/S = R
	if(istype(S))
		var/icon_to_use = override_icon ? override_icon : spawned_spellbook.icon
		var/icon_state_to_use = override_icon_state ? override_icon_state : spawned_spellbook.icon_state
		var/icon/spellbook_sprite = icon(icon_to_use, icon_state_to_use)
		var/list/data_list = list(
		"item_name" = "[override_item_name ? override_item_name : spawned_spellbook.name]",
		"icon" = "<img class='icon' src='data:image/png;base64,[iconsouth2base64(spellbook_sprite)]'>",
		)
		S.summons_received += list(data_list)
	playsound(src,'sound/effects/summon_guns.ogg', 50, 1)


/mob/living/carbon/human/proc/equip_artifact(var/datum/role/R)
	var/selected_path
	var/override_icon
	var/override_icon_state
	var/override_item_name
	var/randomizemagecolor = pick("Magician", "Red Magus", "Blue Magus", "Blue", "Red", "Necromancer",
								"Clown", "Purple", "Lich", "Skeleton Lich", "Marisa", "Fake")
	switch (randomizemagecolor) //everyone can put on their robes and their wizard hat
		if("Magician")
			new /obj/item/clothing/head/that/magic(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magician(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa/leather(get_turf(src))
		if("Red Magus")
			new /obj/item/clothing/head/wizard/magus(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magusred(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Blue Magus")
			new /obj/item/clothing/head/wizard/magus(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/magusblue(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Blue")
			new /obj/item/clothing/head/wizard(get_turf(src))
			new /obj/item/clothing/suit/wizrobe(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Red")
			new /obj/item/clothing/head/wizard/red(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/red(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Necromancer")
			new /obj/item/clothing/suit/wizrobe/necro(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Clown")
			new /obj/item/clothing/head/wizard/clown(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/clown(get_turf(src))
			new /obj/item/clothing/mask/gas/clown_hat/wiz(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Purple")
			new /obj/item/clothing/head/wizard/amp(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/psypurple(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa/leather(get_turf(src))
		if("Lich")
			new /obj/item/clothing/head/wizard/lich(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/lich(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Skeleton Lich")
			new /obj/item/clothing/head/wizard/skelelich(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/skelelich(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))
		if("Marisa")
			new /obj/item/clothing/head/wizard/marisa(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/marisa(get_turf(src))
			new /obj/item/clothing/shoes/sandal/marisa(get_turf(src))
		if("Fake")
			new /obj/item/clothing/head/wizard/fake(get_turf(src))
			new /obj/item/clothing/suit/wizrobe/fake(get_turf(src))
			new /obj/item/clothing/shoes/sandal(get_turf(src))

	var/randomizeartifact = pick("Staff of Swip-Swap", "Staff of Mental Focus", "Soulstone", "Gem-encrusted Hardsuit",
								"Staff of Animation", "Staff of Necromancy", "Contract of Apprenticeship", "Scrying Orb",
								"Cloak of Cloaking", "Glowing Orb", "Phylactery", "Boots of Blinding Speed")
	switch (randomizeartifact)
//		if("staffchange")
//			new /obj/item/weapon/gun/energy/staff/change(get_turf(src))
		if("Staff of Swip-Swap")
			selected_path = /obj/item/weapon/gun/energy/staff/swapper
		if("Staff of Mental Focus")
			selected_path = /obj/item/weapon/gun/energy/staff/focus
		if("Soulstone")
			selected_path = /obj/item/weapon/storage/belt/soulstone/full
			add_spell(new /spell/aoe_turf/conjure/construct, iswizard = TRUE)
			add_language(LANGUAGE_CULT)
		if("Gem-encrusted Hardsuit")
			selected_path = /obj/item/clothing/suit/space/rig/wizard
			new /obj/item/clothing/shoes/sandal(get_turf(src))
			new /obj/item/clothing/gloves/purple/wizard(get_turf(src))
			new /obj/item/weapon/tank/emergency_oxygen/double/wizard(get_turf(src))
		if("Staff of Animation")
			selected_path = /obj/item/weapon/gun/energy/staff/animate
		if("Staff of Necromancy")
			selected_path = /obj/item/weapon/gun/energy/staff/necro
		if("Contract of Apprenticeship") //lol
			selected_path = /obj/item/wizard_apprentice_contract
		if("Scrying Orb")
			selected_path = /obj/item/weapon/scrying
			mutations.Add(M_XRAY)
			change_sight(adding = SEE_MOBS|SEE_OBJS|SEE_TURFS)
			see_in_dark = 8
			see_invisible = SEE_INVISIBLE_LEVEL_TWO
		if("Cloak of Cloaking")
			selected_path = /obj/item/weapon/cloakingcloak
		if("Glowing Orb")
			selected_path = /obj/item/weapon/glow_orb
			override_item_name = "Glowing Orbs"
			override_icon = 'icons/obj/wizard.dmi'
			override_icon_state = "glow_stone_active"
			new /obj/item/weapon/glow_orb(get_turf(src))
			new /obj/item/weapon/glow_orb(get_turf(src))
//		if("knife")
//			new /obj/item/weapon/butterflyknife/viscerator/magic(get_turf(src))
		if("Phylactery")
			selected_path = /obj/item/phylactery
		if("Boots of Blinding Speed")
			selected_path = /obj/item/clothing/shoes/blindingspeed

	var/atom/spawned_artifact = new selected_path(get_turf(src))
	var/datum/role/wizard/summon_magic/artifact/S = R
	if(istype(S))
		var/icon_to_use = override_icon ? override_icon : spawned_artifact.icon
		var/icon_state_to_use = override_icon_state ? override_icon_state : spawned_artifact.icon_state
		var/icon/artifact_sprite = icon(icon_to_use, icon_state_to_use)
		var/list/data_list = list(
		"item_name" = "[override_item_name ? override_item_name : spawned_artifact.name]",
		"icon" = "<img class='icon' src='data:image/png;base64,[iconsouth2base64(artifact_sprite)]'>",
		)
		S.summons_received += list(data_list)

/mob/living/carbon/human/proc/equip_potions(var/datum/role/R)
	var/datum/role/wizard/summon_potions/S = R
	for(var/i=0, i<3, i++)
		var/obj/item/potion/randompotion = get_random_potion()
		var/obj/item/potion/P = new randompotion(get_turf(src))
		if(istype(S))
			var/icon/potion_sprite = icon(P.icon, P.icon_state)
			var/list/data_list = list(
			"item_name" = "[P.name]",
			"icon" = "<img class='icon' src='data:image/png;base64,[iconsouth2base64(potion_sprite)]'>",
			)
			S.summons_received += list(data_list)
		if(istype(P, /obj/item/potion/deception))	//Warn someone if that healing potion they just got is a fake one.
			to_chat(src, "You feel like it's a bad idea to drink the [P.name] yourself...")

	playsound(src,'sound/effects/summon_guns.ogg', 50, 1)

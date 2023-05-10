/obj/structure/closet/crate/secure/loot/vg_painting/New()
	..()
	new/obj/item/mounted/frame/painting(src)

/obj/structure/closet/crate/secure/loot/vg_oreloader
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_oreloader/New()
	..()
	new/obj/item/weapon/storage/bag/ore/auto(src)

/obj/structure/closet/crate/secure/loot/vg_betterdrill
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_betterdrill/New()
	..()
	new/obj/item/weapon/pickaxe/drill/diamond(src)

/obj/structure/closet/crate/secure/loot/vg_bestdrill
	attempts = 1

/obj/structure/closet/crate/secure/loot/vg_bestdrill/New()
	..()
	new/obj/item/weapon/pickaxe/plasmacutter/accelerator(src)

/obj/structure/closet/crate/secure/loot/vg_phazbananium
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_phazbananium/New()
	..()
	attempts = rand(1,2)
	if(attempts == 2)
		drop_stack(pick(/obj/item/stack/ore/phazon,/obj/item/stack/ore/clown), src, rand(10,20))
	else
		drop_stack(/obj/item/stack/ore/phazon, src, rand(5,10))
		drop_stack(/obj/item/stack/ore/clown, src, rand(5,10))

/obj/structure/closet/crate/secure/loot/vg_cash/New()
	..()
	attempts = pick(1,2,2,3,3,3)
	dispense_cash((10**attempts)*rand(5,20),src) //50-200, 500-2000, 5000-20000

/obj/structure/closet/crate/secure/loot/vg_hivecores
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_hivecores/New()
	..()
	for(var/i in 1 to 3)
		new/obj/item/asteroid/hivelord_core(src)

/obj/structure/closet/crate/secure/loot/vg_hideplates
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_hideplates/New()
	..()
	var/type = pick(/obj/item/asteroid/basilisk_hide,/obj/item/asteroid/goliath_hide)
	new type(src)
	if(prob(25))
		attempts--
		type = pick(/obj/item/asteroid/basilisk_hide,/obj/item/asteroid/goliath_hide)
		new type(src)

/obj/structure/closet/crate/secure/loot/vg_rigstuff
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_rigstuff/New()
	..()
	for(var/i in 1 to rand(2,3))
		var/rigtype = pick(subtypesof(/obj/item/rig_module))
		new rigtype(src)


/obj/structure/closet/crate/secure/loot/vg_stockparts
	var/list/possible_spawns = list(
		/obj/item/weapon/stock_parts/console_screen/reinforced,
		/obj/item/weapon/stock_parts/capacitor/adv,
		/obj/item/weapon/stock_parts/micro_laser/high,
		/obj/item/weapon/stock_parts/manipulator/nano,
		/obj/item/weapon/stock_parts/scanning_module/adv,
		/obj/item/weapon/stock_parts/matter_bin/adv)

/obj/structure/closet/crate/secure/loot/vg_stockparts/New()
	..()
	for(var/i in 1 to rand(3,9))
		var/type = pick(possible_spawns)
		new type(src)

/obj/structure/closet/crate/secure/loot/vg_stockparts/tier3
	attempts = 2
	possible_spawns = list(
			/obj/item/weapon/stock_parts/console_screen/reinforced/plasma,
			/obj/item/weapon/stock_parts/capacitor/adv/super,
			/obj/item/weapon/stock_parts/micro_laser/high/ultra,
			/obj/item/weapon/stock_parts/manipulator/nano/pico,
			/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
			/obj/item/weapon/stock_parts/matter_bin/adv/super)

/obj/structure/closet/crate/secure/loot/vg_stockparts/tier4
	attempts = 3
	possible_spawns = list(
//			/obj/item/weapon/stock_parts/console_screen/reinforced/plasma/rplasma,
			/obj/item/weapon/stock_parts/capacitor/adv/super/ultra,
			/obj/item/weapon/stock_parts/micro_laser/high/ultra/giga,
			/obj/item/weapon/stock_parts/manipulator/nano/pico/femto,
			/obj/item/weapon/stock_parts/scanning_module/adv/phasic/bluespace,
			/obj/item/weapon/stock_parts/matter_bin/adv/super/bluespace)

/obj/structure/closet/crate/secure/loot/vg_lazinjectors/New()
	..()
	for(var/i in 1 to 3)
		new/obj/item/weapon/lazarus_injector(src)

/obj/structure/closet/crate/secure/loot/vg_advlazinjectors
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_advlazinjectors/New()
	..()
	for(var/i in 1 to 3)
		new/obj/item/weapon/lazarus_injector/advanced(src)

/obj/structure/closet/crate/secure/loot/vg_borgupgrades
	var/list/tospawn = list(/obj/item/borg/upgrade/hook,/obj/item/borg/upgrade/portosmelter)

/obj/structure/closet/crate/secure/loot/vg_borgupgrades/New()
	..()
	for(var/i in 1 to max(1,tospawn.len-1))
		var/type = pick_n_take(tospawn)
		new type(src)

/obj/structure/closet/crate/secure/loot/vg_borgupgrades/xenoarch
	attempts = 2
	tospawn = list(/obj/item/borg/upgrade/hook,/obj/item/borg/upgrade/portosmelter,/obj/item/borg/upgrade/xenoarch)

/obj/structure/closet/crate/secure/loot/vg_borgupgrades/xenoarch_adv
	attempts = 1
	tospawn = list(/obj/item/borg/upgrade/hook,/obj/item/borg/upgrade/portosmelter,/obj/item/borg/upgrade/xenoarch_adv)

/obj/structure/closet/crate/secure/loot/vg_seeds
	attempts = 2

/obj/structure/closet/crate/secure/loot/vg_seeds/New()
	..()
	var/list/types = list(
		/obj/item/seeds/goldappleseed,
		/obj/item/seeds/silverpearseed,
		/obj/item/seeds/diamondcarrotseed,
		/obj/item/seeds/plasmacabbageseed,
		/obj/item/seeds/glowberryseed,
		/obj/item/seeds/telriis,
		/obj/item/seeds/vale)
	for(var/i in 1 to 3)
		var/type = pick(types)
		new type(src)
	if(prob(10))
		new /obj/item/seeds/nofruitseed(src)

/obj/structure/closet/crate/secure/loot/vg_bots/New()
	..()
	for(var/i in 1 to 3)
		switch(rand(1,7))
			if(1)
				new /obj/item/weapon/bucket_sensor(src)
				var/robotarm = pick(/obj/item/robot_parts/l_arm,/obj/item/robot_parts/r_arm)
				new robotarm(src)
			if(2)
				new /obj/item/weapon/toolbox_tiles_sensor(src)
				var/robotarm = pick(/obj/item/robot_parts/l_arm,/obj/item/robot_parts/r_arm)
				new robotarm(src)
			if(3)
				new /obj/item/weapon/medbot_cube(src)
			if(4)
				new /obj/item/weapon/secbot_assembly(src)
				var/robotarm = pick(/obj/item/robot_parts/l_arm,/obj/item/robot_parts/r_arm)
				new robotarm(src)
				new /obj/item/device/assembly/prox_sensor(src)
				// go find the baton yourself, better yet in another loot crate
			if(5)
				new /obj/item/clothing/head/cardborg(src)
				new /obj/item/device/assembly/signaler(src)
				new /obj/item/device/assembly/prox_sensor(src)
			if(6)
				new /obj/item/weapon/secbot_assembly/britsky(src)
				var/robotarm = pick(/obj/item/robot_parts/l_arm,/obj/item/robot_parts/r_arm)
				new robotarm(src)
				new /obj/item/device/assembly/prox_sensor(src)
				// good luck finding the classic baton but i'm not including it in a low difficulty crate
			if(7)
				new /obj/item/weapon/mining_drone_cube(src)

/obj/structure/closet/crate/secure/loot/vg_boreregg/New()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/borer_egg(src)

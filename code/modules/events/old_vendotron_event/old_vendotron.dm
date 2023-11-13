/obj/machinery/vending/old_vendotron
	name = "old vendotron"
	desc = "Covered in layers of gunk of varying ages and origins, it's obvious this old vendotron has a history, and wares to match."
	icon_state = "Old_Vendotron"
	icon_vend = "Old_Vendotron-vend"
	unhackable = TRUE
	mech_flags = MECH_SCAN_FAIL
	var/list/commonStock = list(
		/obj/item/pizzabox/meat = 50,
		/obj/item/toy/crayon/rainbow = 15,
		/obj/item/toy/crayon/mime = 15,
		/obj/item/weapon/reagent_containers/food/snacks/egg/parrot = 20,
		/mob/living/simple_animal/crab = 40,
		/mob/living/simple_animal/corgi/puppy = 25,
		/mob/living/simple_animal/hostile/carp/baby = 75,
		/obj/item/weapon/storage/box/autoinjectors = 75,
		/obj/item/weapon/fossil = 50,
		/obj/item/weapon/fossil/egg = 50,
		/obj/item/weapon/fossil/plant = 50,
		/obj/item/weapon/reagent_containers/glass/beaker/vial/mystery = 50,
		/obj/item/clothing/gloves/yellow = 100,
		/obj/item/clothing/gloves/black = 150,	//Same price as pickpocket gloves so you don't know which you're getting
		/obj/item/weapon/reagent_containers/syringe/giant = 50,
		/obj/item/weapon/storage/box/donkpockets = 50,
		/obj/item/weapon/storage/box/snappops = 50,
		/obj/item/weapon/storage/box/actionfigure = 150,
		/obj/item/weapon/storage/box/biscuit = 100,
		/obj/item/device/camera_bug = 25,
		/obj/item/weapon/tank/emergency_oxygen/double = 100,
		/obj/item/weapon/storage/wallet = 40,
		/obj/item/weapon/storage/fancy/donut_box = 75,
		/obj/item/weapon/beach_ball = 50,
		/obj/item/weapon/beartrap = 150,
		/obj/item/device/wormhole_jaunter = 40,
		/obj/item/weapon/soap/ = 25,
		/obj/item/clothing/glasses/monocle = 35,
		/obj/item/clothing/glasses/sunglasses/purple = 35,
		/obj/item/clothing/glasses/sunglasses/star = 35,
		/obj/item/clothing/glasses/sunglasses/rockstar = 35,
		/obj/item/clothing/glasses/sunglasses/big = 35,
		/obj/item/clothing/head/helmet/snail_helm = 50,
		/obj/item/clothing/head/cakehat = 50,
		/obj/item/clothing/head/pumpkinhead = 50,
		/obj/item/clothing/head/tinfoil = 50,
		/obj/item/clothing/mask/horsehead = 150,
		/obj/item/clothing/shoes/leather = 50,
		/obj/item/clothing/shoes/magboots = 75,
		/obj/item/weapon/dnainjector/nofail/randompower = 350,
		/obj/item/weapon/gun/hookshot = 200,
		/obj/item/weapon/gun/siren/supersoaker = 250,
		/obj/item/device/mobcapsule = 75,
		/obj/item/supermatter_shielding = 350,
		/obj/item/weapon/boomerang = 50,
		/obj/item/weapon/melee/lance = 250,
		/obj/item/weapon/storage/pill_bottle/random = 120,
		/obj/item/weapon/reagent_containers/pill/time_release = 120,
		/obj/item/weapon/reagent_containers/pill/random/maintenance = 20,	//Obviously the expensive one is better, right?
		/obj/item/weapon/reagent_containers/pill/random/maintenance = 40,
		/obj/item/weapon/reagent_containers/pill/random/maintenance = 60,
		/obj/item/weapon/reagent_containers/pill/random/maintenance = 80,
		/obj/item/weapon/reagent_containers/pill/random/maintenance = 100,
		/obj/item/weapon/bikehorn/rubberducky = 150,
		/obj/item/weapon/glue/temp_glue = 100,
		/obj/item/weapon/storage/toolbox/syndicate = 150,
		/obj/item/weapon/storage/firstaid/adv = 150,
		/obj/item/weapon/reagent_containers/food/snacks/donut/chaos = 50,
		/obj/item/weapon/stock_parts/micro_laser/high/ultra = 150,
		/obj/item/weapon/stock_parts/manipulator/nano/pico = 150,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic = 150,
		/obj/item/weapon/stock_parts/capacitor/adv/super = 150,
		/obj/item/borg/upgrade/bootyborg = 250,
		/obj/item/slime_extract/grey = 100,
		/obj/item/slime_extract/silver = 130,
		/obj/item/slime_extract/pink = 150,
		/obj/item/slime_extract/bluespace = 200,
		/obj/item/weapon/pickaxe/drill/diamond = 500,
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube/mysterycube = 150,
		/obj/item/weapon/storage/box/large/mystery_material = 150,
		/obj/item/weapon/storage/pill_bottle/mint/homemade = 30
	)

	var/list/uncommonStock = list(
		/mob/living/simple_animal/rabbit = 250,
		/obj/item/potion/healing = 250,
		/obj/item/potion/transform = 300,
		/obj/item/potion/stoneskin = 250,
		/obj/item/potion/random = 150,
		/obj/item/potion/invisibility/major = 350,
		/obj/item/weapon/dice/d20/cursed = 250,
		/obj/item/weapon/implanter/compressed = 400,
		/obj/item/weapon/storage/box/syndie_kit/imp_freedom = 500,
		/obj/item/weapon/reagent_containers/food/snacks/egg/chaos = 50,
		/obj/item/bluespace_crystal = 75,
		/mob/living/simple_animal/hostile/gremlin = 125,
		/mob/living/simple_animal/hostile/wolf/pliable = 200,
		/obj/item/weapon/gun/hookshot/whip = 75,
		/obj/item/clothing/head/leather/deer/horned = 200,
		/obj/item/weapon/reagent_containers/food/snacks/monkeycube/gourmonger = 65,
		/obj/item/weapon/storage/box/monkeycubes/spacecarpcube = 350,
		/obj/item/weapon/storage/belt/leather = 175,
		/obj/item/clothing/suit/armor/ice = 250,
		/obj/item/weapon/butterflyknife/viscerator/bunny = 200,
		/obj/item/weapon/reagent_containers/glass/beaker/large/plasma = 100,
		/obj/item/clothing/gloves/black/thief = 150,
		/obj/item/clothing/gloves/black/thief/storage = 150,
		/obj/item/weapon/grenade/chem_grenade/wind = 75,
		/obj/item/clothing/suit/armor/reactive = 175,
		/obj/item/weapon/storage/box/boxen = 200,
		/obj/item/weapon/tank/emergency_oxygen/double/wizard = 250,
		/obj/item/weapon/gun/projectile/shotgun/doublebarrel = 150,
		/obj/item/weapon/storage/backpack/holding = 250,
		/obj/item/weapon/reagent_containers/glass/bottle/frostoil = 75,
		/obj/item/clothing/accessory/holomap_chip = 250,
		/obj/item/weapon/fireaxe = 150,
		/obj/item/clothing/suit/space/rig/syndicate_elite = 150,
		/obj/item/clothing/shoes/clown_shoes/advanced = 150,
		/obj/item/clothing/back/magiccape = 150,
		/obj/item/clothing/glasses/thermal = 250,
		/obj/item/clothing/glasses/emitter = 250,
		/obj/item/clothing/head/helmet/knight = 200,
		/obj/item/clothing/head/helmet/knight/interrogator = 200,
		/obj/item/clothing/mask/gas/voice = 300,
		/obj/item/clothing/mask/goldface = 200,
		/obj/item/clothing/mask/morphing/amorphous = 300,
		/obj/item/clothing/mask/morphing = 250,
		/obj/item/clothing/under/chameleon = 250,
		/obj/item/clothing/under/contortionist = 600,
		/obj/item/device/modkit/storm_rig = 500,
		/obj/item/device/modkit/fatsec_rig = 450,
		/obj/item/soulstone = 150,
		/obj/item/weapon/gun/energy/taser/ricochet = 350,
		/obj/item/weapon/reagent_containers/food/snacks/meat/wendigo = 400,
		/obj/item/weapon/disk/shuttle_coords/vault/random = 200,
		/obj/item/weapon/glue = 450,
		/obj/item/weapon/shield/energy = 350,
		/obj/item/weapon/storage/pill_bottle/creatine = 300,
		/obj/item/weapon/bikehorn/baton = 300,
		/obj/item/weapon/grenade/flashbang/clusterbang = 300,
		/obj/item/cannonball/bananium = 200,
//		/obj/item/weapon/stock_parts/console_screen/reinforced/plasma/rplasma = 150,
		/obj/item/weapon/stock_parts/micro_laser/high/ultra/giga = 200,
		/obj/item/weapon/stock_parts/capacitor/adv/super/ultra = 250,
		/obj/item/weapon/stock_parts/manipulator/nano/pico/femto = 200,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic/bluespace = 200,
		/obj/item/weapon/storage/lockbox/advanced = 150,
		/obj/item/device/analyzer/scope = 220,
		/obj/item/weapon/circuitboard/mecha/phazon/main = 350,
		/obj/item/mecha_parts/mecha_equipment/teleporter = 300,
		/obj/item/mecha_parts/mecha_equipment/gravcatapult = 300,
		/obj/item/weapon/storage/box/mysterycubes = 250,
		/obj/item/weapon/glow_orb = 200,
		/obj/item/stack/sheet/mineral/phazon = 300,
		/obj/item/weapon/reagent_containers/spray/noreact = 750,	//This isn't nearly as broken as it sounds
		/obj/item/weapon/circuitboard/mind_machine_hub = 400,
		/obj/item/weapon/circuitboard/mind_machine_pod = 250,
	)

	var/list/rareStock = list(
		/obj/item/clothing/suit/armor/rune = 1500,
		/obj/item/clothing/gloves/powerfist = 1800, //I don't even know if these work!
		/obj/item/clothing/head/bearpelt/real/spare = 800,
		/obj/item/clothing/head/celtic = 250,
		/obj/item/weapon/winter_gift/special = 2400,	//Extremely difficult outside of the whole station wanting you to be a vampire
		/obj/item/clothing/mask/morphing/amorphous = 150,	//Cheaper than uncommon
		/obj/item/clothing/shoes/magboots/deathsquad = 500,
		/obj/item/clothing/suit/space/rig/centcomm/old = 500,
		/obj/item/clothing/suit/space/santa = 800,
		/obj/item/clothing/head/helmet/space/santahat = 500,
		/obj/item/clothing/suit/storage/draculacoat = 300,
		/obj/item/clothing/suit/clownpiece/flying = 500,
		/obj/item/clothing/suit/bomber_vest = 600,
		/obj/item/clothing/under/chameleon/all = 1200, //Style ain't cheap
		/obj/item/gingerbread_egg = 750,
		/obj/item/weapon/gun/portalgun = 1100,
		/obj/item/weapon/gun/energy/staff/swapper = 1000,
		/obj/item/bluespace_crystal/flawless = 2400,	//Spessmart has it at 1800 so we're making it pricier
		/obj/item/weapon/cloakingcloak = 1400,
		/obj/structure/bed/chair/vehicle/wheelchair/multi_people = 900,
		/obj/item/weapon/veilrender/vealrender = 50000,	//One day, 30 years from now, someone will win the lottery in a round this is rolled
		/obj/item/phylactery = 750,
		/obj/item/clothing/shoes/blindingspeed = 1800,
	)

/obj/machinery/vending/old_vendotron/New()
	..()
	decideStock()
	build_inventories()

/obj/machinery/vending/old_vendotron/proc/decideStock()
	var/stockAmount = rand(6, 18)
	var/rarerRolls = 1 + round(player_list.len * 0.1, 1) //More players more stock, slightly
	for(var/i = 1 to stockAmount)
		if(prob(70))
			addCommonStock()
		else
			addUncommonStock()
	for(var/u = 1 to rarerRolls)	//Guaranteed uncommon stock, much more likely rare stock
		addUncommonStock()

/obj/machinery/vending/old_vendotron/proc/addCommonStock()
	var/theStock = 0
	theStock = rand(1, commonStock.len)
	var/chosenStock = commonStock[theStock]
	products.Add(chosenStock)
	if(prob(50))		//common items can easily have 2-3 stock
		products[chosenStock] = 2
	else if(prob(25))
		products[chosenStock] = 3
	var/stockPrice = priceRandomizer(commonStock[chosenStock])
	prices.Add(chosenStock)
	prices[chosenStock] = stockPrice

/obj/machinery/vending/old_vendotron/proc/addUncommonStock()
	if(prob(80))
		var/theStock = 0
		theStock = rand(1, uncommonStock.len)
		var/chosenStock = uncommonStock[theStock]
		products.Add(chosenStock)
		if(prob(15))	//Uncommon items A rare double stock
			products[chosenStock] = 2
		var/stockPrice = priceRandomizer(uncommonStock[chosenStock])
		prices.Add(chosenStock)
		prices[chosenStock] = stockPrice
	else
		addRareStock()

/obj/machinery/vending/old_vendotron/proc/addRareStock()
	var/theStock = 0
	theStock = rand(1, rareStock.len)
	var/chosenStock = rareStock[theStock]
	products.Add(chosenStock)
	var/stockPrice = priceRandomizer(rareStock[chosenStock])
	prices.Add(chosenStock)
	prices[chosenStock] = stockPrice

/obj/machinery/vending/old_vendotron/proc/priceRandomizer(var/thePrice = 0)
	thePrice = rand(thePrice * 0.7, thePrice * 1.3)	//30% cheaper or pricier, totally random for SPICE
	return thePrice


//Begin spoilers/////

/obj/machinery/vending/old_vendotron/arcane_act(mob/user)
	user.say("P'Y 'P!")
	neoUltraCapitalismMode(user)

/obj/machinery/vending/old_vendotron/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(prob(50))
			punishCheapskate()
		else
			neoUltraCapitalismMode(user)

/obj/machinery/vending/old_vendotron/emp_act(severity)
	if(severity < 3)
		punishCheapskate()

/obj/machinery/vending/old_vendotron/kick_act(mob/living/carbon/human/user)
	..()
	if(prob(1))	//Let's make it very hard to turn this against the crew without tools
		if(prob(75))
			punishCheapskate()
		else
			neoUltraCapitalismMode(user)

/obj/machinery/vending/old_vendotron/malfunction()
	punishCheapskate()

/obj/machinery/vending/old_vendotron/crowbarDestroy(mob/user, obj/item/tool/crowbar/C)
	user.visible_message(	"[user] struggles to pry out the firmly secured circuitboard from \the [src].",
							"You struggle to pry out the firmly secured circuitboard from \the [src]...")
	if(do_after(user, src, 10 SECONDS))	//This is a strong hint that something may or may not be going on
		user.drop_item(C, get_turf(user), 1)	//Your glue won't help
		C.animationBolt()
		user.visible_message(	"\The [src] begins to pry out the circuitboard from [user].",
								"\The [src] begins to pry out the circuitboard from you.")


/obj/machinery/vending/old_vendotron/proc/punishCheapskate()
	var/ourPunishment = rand(1, 6)
	switch(ourPunishment)
		if(1)
			ahhSpiders()	//I will not be changing these proc names.
		if(2)
			platesPlatesPlates()	//They are perfect the way they are
		if(3)
			broadSideBarrage()	//I mean it, I'm not changing these
		if(4)
			youHaveToEatAllTheEggs()	//Go on, ask me
		if(5)
			ghettoNightmare()	//I will say "No"
		if(6)
			neoUltraCapitalismMode()

/obj/machinery/vending/old_vendotron/proc/ahhSpiders(var/spiderAmount = 20)
	visible_message("<span class='big danger'>Loud chittering can be heard from \the [src]!</span>")
	for(var/i = 1, i < spiderAmount, i++)
		spawn(i+1)
			if(prob(75))
				new /mob/living/simple_animal/hostile/giant_spider/spiderling(get_turf(src))
			else
				new /mob/living/simple_animal/hostile/giant_spider/hunter(get_turf(src))

/obj/machinery/vending/old_vendotron/proc/platesPlatesPlates(var/plateAmount = 50) //This many is necessary, I promise
	visible_message("<span class='big danger'>\The [src] enters dinner mode!</span>")
	for(var/i = 1, i < plateAmount, i++)
		spawn(i+2)
			var/obj/item/trash/plate/thePlate = new /obj/item/trash/plate(get_turf(src))
			var/turf/plateTarg = null
			if(prob(50))
				var/plateDir = pick(alldirs)
				plateTarg = get_edge_target_turf(src, plateDir)
			else
				var/mob/living/t = locate() in view(7, src)	//copy paste of vendor throwing for theming
				plateTarg = t
			if(plateTarg)
				thePlate.throw_at(plateTarg, 10, i)

/obj/machinery/vending/old_vendotron/proc/broadSideBarrage()
	visible_message("<span class='big danger'>\The [src] detects a product piracy attempt!</span>")
	for(var/dir in cardinal)
		var/turf/T = get_turf(get_step(loc, dir))
		var/obj/structure/siege_cannon/sC = new /obj/structure/siege_cannon(T)
		var/obj/item/cannonball/cB = null
		if(prob(25))
			cB = new /obj/item/cannonball/bananium(sC)
			sC.icon_state = "clownnon"
			sC.name = "circus cannon"
			sC.beenClowned = TRUE
		else
			cB = new /obj/item/cannonball/iron(sC)
		sC.loadedItem = cB
		sC.wFuel = 20
		sC.dir = get_dir(src, sC)
		sC.anchored = TRUE
		spawn(1 SECONDS)
			if(!sC.gcDestroyed)
				sC.itemFire()
				animate(src, alpha = 0, time = 1 SECONDS)
		spawn(2 SECONDS)
			if(!sC.gcDestroyed)
				qdel(sC)

/obj/machinery/vending/old_vendotron/proc/youHaveToEatAllTheEggs(var/eggAmount = 8)
	visible_message("<span class='big danger'>\The [src] vends some peculiar eggs!</span>")
	for(var/i = 1 to eggAmount)
		var/turf/eggT = get_turf(pick(orange(5, get_turf(src))))
		new /obj/item/weapon/reagent_containers/food/snacks/egg/chaos/instahatch(eggT)

/obj/machinery/vending/old_vendotron/proc/ghettoNightmare(var/nightmareLevel = 8, mob/user)	//This is a sin
	visible_message("<span class='big danger'>Even \the [src] looks afraid!</span>")
	var/obj/item/weapon/grenade/iedcasing/preassembled/gNightmare = new /obj/item/weapon/grenade/iedcasing/preassembled(get_turf(src))
	gNightmare.det_time = 5 SECONDS
	gNightmare.name = "Improvised Explosive Nightmare"
	for(var/i = 1 to nightmareLevel)
		var/obj/item/anvil/A = new /obj/item/anvil(gNightmare)
		gNightmare.shrapnel_list.Add(A)
		gNightmare.current_shrapnel++
		if(gNightmare.current_shrapnel >= gNightmare.max_shrapnel)
			break //More of a safety, already breaking the laws of IED
	var/turf/gTarg = get_ranged_target_turf(src, dir, 3)
	gNightmare.throw_at(gTarg, 3, 5)
	gNightmare.attack_self(user)
	animate(gNightmare, transform = matrix()*3, time = 5 SECONDS)

/obj/machinery/vending/old_vendotron/proc/neoUltraCapitalismMode(mob/user)
	visible_message("<span class='big danger'>\The [src] engages neo-ultra-capitalism mode!</span>")
	do_flick(src, "Old_Vendotron-transform", 25)
	var/mob/living/simple_animal/hostile/old_vendotron/madVendor = new /mob/living/simple_animal/hostile/old_vendotron(loc)
	madVendor.ourVendor = src
	src.forceMove(madVendor)
	if(user)
		madVendor.GiveTarget(user)

/mob/living/simple_animal/hostile/old_vendotron
	name = "old vendotron"
	desc = "Pay up"
	icon = 'icons/mob/old_vendotron.dmi'
	icon_state = "Old_Vendotron"
	icon_living = "Old_Vendotron"
	maxHealth = 600
	health = 600
	melee_damage_lower = 10
	melee_damage_upper = 30
	attacktext = "vends"
	mob_property_flags = MOB_CONSTRUCT | MOB_ROBOTIC | MOB_NO_PETRIFY | MOB_NO_LAZ
	environment_smash_flags = SMASH_CONTAINERS | SMASH_WALLS | OPEN_DOOR_STRONG
	var/obj/machinery/vending/old_vendotron/ourVendor = null
	var/lastPunish = 0
	var/punishCooldown = 50

/mob/living/simple_animal/hostile/old_vendotron/death(var/gibbed = FALSE)
	if(ourVendor)
		ourVendor.forceMove(loc)
	else
		explosion(loc, 1,2,2, whodunnit = src)
	..(gibbed)
	qdel(src)

/mob/living/simple_animal/hostile/old_vendotron/Life()
	..()
	if(stance == HOSTILE_STANCE_ATTACK || stance == HOSTILE_STANCE_ATTACKING)
		if(punishCommies())
			lastPunish = world.time

/mob/living/simple_animal/hostile/old_vendotron/proc/punishCommies()
	if(lastPunish + punishCooldown <= world.time)
		if(prob(15))
			ourVendor.platesPlatesPlates(30)
			return TRUE
		if(prob(20))
			ourVendor.broadSideBarrage()
			return TRUE
		if(prob(5))
			ourVendor.ghettoNightmare(3)
		if(prob(10))
			ourVendor.youHaveToEatAllTheEggs(3)
			return TRUE
		if(prob(10))
			ourVendor.ahhSpiders(10)
			return TRUE
	return FALSE

var/list/shop_prices = list( //Cost in space credits
//Misc objects
/obj/item/weapon/soap = 20,
/obj/item/weapon/phone = 30,
/obj/item/weapon/mop = 20,
/obj/item/weapon/lipstick/random = 30,
/obj/item/weapon/lazarus_injector = 500,
/obj/item/weapon/kitchen/rollingpin = 20,
/obj/item/weapon/hand_labeler = 10,
/obj/item/weapon/extinguisher = 20,
/obj/item/weapon/crowbar/red = 5,
/obj/item/weapon/bikehorn/rubberducky = 5,
/obj/item/weapon/bikehorn = 5,
/obj/item/weapon/lighter/zippo = 20,
/obj/item/weapon/screwdriver = 3,
/obj/item/weapon/wrench = 3,
/obj/item/queen_bee = 5,
/obj/item/toy/gooncode = 400, //honk
/obj/item/mounted/poster = 20,
/obj/item/candle = 5,


//tools
/obj/item/weapon/surgicaldrill = 100,
/obj/item/weapon/circular_saw = 100,
/obj/item/weapon/scalpel/laser/tier2 = 120,
/obj/item/weapon/scalpel = 70,
/obj/item/weapon/retractor = 30,
/obj/item/weapon/cautery = 30,
/obj/item/weapon/bonegel = 30,
/obj/item/weapon/FixOVein = 30,

/obj/item/weapon/switchtool/surgery = 250,
/obj/item/weapon/switchtool/swiss_army_knife = 500,
/obj/item/weapon/rcl = 100,
/obj/item/weapon/glue = 500,
/obj/item/weapon/chisel = 20,
/obj/item/weapon/scythe = 50,
/obj/item/bluespace_crystal/flawless = 10000,
/obj/item/bluespace_crystal/artificial = 1000,
/obj/item/bluespace_crystal = 750,
/obj/item/device/assembly_frame = 50,
/obj/item/device/camera = 30,
/obj/item/device/flash = 20,
/obj/item/device/robotanalyzer = 5,
/obj/item/device/soundsynth = 20,
/obj/item/device/transfer_valve = 500, //What could go wrong
/obj/item/device/instrument/violin = 80,
/obj/item/device/maracas = 5,
/obj/item/device/aicard = 50,
/obj/item/device/soulstone = 400, //What could go wrong
/obj/item/device/taperecorder = 30,
/obj/item/device/rcd/tile_painter = 30,
/obj/item/device/rcd/matter/engineering = 30,
/obj/item/device/paicard = 10,
/obj/item/device/megaphone = 25,
/obj/item/device/hailer = 10,
/obj/item/broken_device = 1,
/obj/item/toy/balloon = 1,
/obj/item/toy/syndicateballoon = 700,
/obj/item/weapon/am_containment = 60,
/obj/item/weapon/cane = 5,
/obj/item/weapon/legcuffs/beartrap = 100,
/obj/item/weapon/rcd_ammo = 20,
/obj/item/weapon/storage/pneumatic = 40,
/obj/item/weapon/resonator = 100,
/obj/item/weapon/gun/energy/kinetic_accelerator = 80,
/obj/item/device/modkit/aeg_parts = 99,
/obj/item/device/modkit/gold_rig = 50,
/obj/item/device/modkit/storm_rig = 50,
/obj/item/clothing/accessory/medal/gold/captain = 1500,
/obj/item/device/radio/headset/headset_earmuffs = 125,
/obj/item/device/detective_scanner = 200,
/obj/item/device/mass_spectrometer/adv = 150,
/obj/item/device/mass_spectrometer = 100,
/obj/item/device/mining_scanner = 15,
/obj/item/device/mobcapsule = 200,
/obj/item/weapon/solder = 10,


//weapons
/obj/item/weapon/melee/classic_baton = 100,
/obj/item/weapon/melee/lance = 200,
/obj/item/weapon/melee/telebaton = 500,
/obj/item/weapon/claymore = 600,
/obj/item/weapon/fireaxe  = 200,
/obj/item/weapon/spear/wooden = 200,
/obj/item/weapon/spear = 30,
/obj/item/weapon/crossbow = 100,
/obj/item/weapon/hatchet = 20,
/obj/item/weapon/harpoon = 125,
/obj/item/weapon/boomerang/toy = 5,
/obj/item/weapon/boomerang = 30,
/obj/item/weapon/batteringram = 1000,
/obj/item/weapon/shield/riot = 250,

//No guns sorry
)

var/list/circuitboards = existing_typesof(/obj/item/weapon/circuitboard) - /obj/item/weapon/circuitboard/card/centcom //All circuit boards can be bought in Spessmart
var/list/circuitboard_prices = list()	//gets filled on initialize()
var/list/clothing = existing_typesof(/obj/item/clothing) - typesof(/obj/item/clothing/suit/space/ert) - typesof(/obj/item/clothing/head/helmet/space/ert) - list(/obj/item/clothing/suit/space/rig/elite, /obj/item/clothing/suit/space/rig/deathsquad, /obj/item/clothing/suit/space/rig/wizard, /obj/item/clothing/head/helmet/space/bomberman, /obj/item/clothing/suit/space/bomberman, /obj/item/clothing/mask/stone/infinite) //What in the world could go wrong
var/list/clothing_prices = list()	//gets filled on initialize()

/area/vault/supermarket
	name = "Spessmart"
	flags = NO_PORTALS | NO_TELEPORT

/area/vault/supermarket/entrance
	name = "Spessmart Entrance"
	jammed = 1

/area/vault/supermarket/shop
	name = "Spessmart Store"
	jammed = 2
	icon_state = "green"

	var/list/items = list()
	var/lockdown = 0
	var/destination_disks = 1	//number of complimentary Spessmart destination disks left to give
	var/customer_has_entered = FALSE

/area/vault/supermarket/restricted
	name = "Spessmart Maintenance"
	jammed = 2
	icon_state = "red"

/area/vault/supermarket/shop/proc/initialize()
	spawn()
		/*
		looping:
			for(var/obj/item/I in contents)
				for(var/type in shop_prices + circuitboard_prices + clothing_prices)
					if(istype(I, type))
						I.name = "[I.name] ($[shop_prices[type]])"
						I.on_destroyed.Add(src, "item_destroyed") //Only trigger alarm when an item for sale is destroyed

						items[I] = shop_prices[type]

						continue looping
		*/ //This is handled by spawners now

		var/area/vault/supermarket/entrance/E = locate(/area/vault/supermarket/entrance)
		var/list/protected_objects = list(
			/obj/structure/window, //Destroying these objects triggers an alarm
			/turf/simulated/wall,
			/obj/structure,
			/mob/living/simple_animal,
			/obj/machinery,
			)

		for(var/atom/movable/AM in (src.contents + E.contents))

			if(!is_type_in_list(AM, protected_objects)) continue

			if(AM.on_destroyed)
				AM.on_destroyed.Add(src, "item_destroyed")

/area/vault/supermarket/shop/Exited(atom/movable/AM, atom/newloc)
	..()

	if(istype(AM, /mob/dead))
		return

	if(items.Find(AM))
		return on_theft()
	else
		var/list/AM_contents = get_contents_in_object(AM, /obj/item)

		for(var/obj/item/I in AM_contents)
			if(items.Find(I))
				return on_theft()

/area/vault/supermarket/shop/proc/purchased(obj/item/I)
	items.Remove(I)
	I.name = initial(I.name)

/area/vault/supermarket/shop/proc/item_destroyed()
	for(var/obj/item/I in items)
		if(isnull(I.loc) || I.gcDestroyed)
			items.Remove(I)
			message_admins("Spessmart has entered lockdown due to the destruction of \a [I]!")

	if(customer_has_entered)
		on_theft()

/area/vault/supermarket/shop/proc/on_theft()
	if(lockdown)
		return

	lockdown = 1

	var/list/all_contents = src.contents.Copy()
	var/area/entrance = locate(/area/vault/supermarket/entrance)

	all_contents += entrance.contents

	for(var/obj/machinery/door/poddoor/shutters/S in all_contents)
		spawn()
			S.close()

	for(var/mob/living/simple_animal/hostile/spessmart_guardian/C in all_contents)
		C.Retaliate()

	src.firealert()
	entrance.firealert()

///////ROBOTS
/mob/living/simple_animal/robot
	a_intent = I_HURT
	anchored = 1

	unsuitable_atoms_damage = 0
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

/mob/living/simple_animal/robot/New()
	..()

	if(icon == 'icons/mob/robots.dmi')
		overlays.Add(image('icons/mob/robots.dmi', icon_state = "eyes-[src.icon_state]"))

/mob/living/simple_animal/robot/Die()
	..()

	robogibs(get_turf(src))
	qdel(src)

/obj/effect/spessmart_entrance
	name = "Spessmart entrance marker"

	icon = 'icons/obj/weapons.dmi'
	icon_state = "toddler"

	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/spessmart_entrance/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/area/vault/supermarket/shop/A = get_area(src)
		A.customer_has_entered = TRUE
		spawn(1)
			for(var/cdir in alldirs)
				for(var/mob/living/simple_animal/robot/robot_greeter/G in get_step(src, cdir))
					G.greet(AM)

	return ..()

/mob/living/simple_animal/robot/robot_greeter
	name = "WelcomeBot"
	desc = "The light inside is out, but it still works."

	icon = 'icons/mob/robots.dmi'
	icon_state = "Service"

	anchored = 1

	faction = "spessmart"

	var/list/directional_responses = list(
	"1" = "Shop smart, shop Spessmart.",
	"2" = "Thank you for shopping at Spessmart, come again.",
	)

/mob/living/simple_animal/robot/robot_greeter/warner
	name = "WarnBot"
	desc = "Don't say you weren't warned."

	icon_state = "maximillion"

	directional_responses = list(
	"1" = "Please don't attempt to commit any crimes while in Spessmart. Any attempts of theft or vandalism will result in lockdown and termination.",
	"2" = "Are you sure you didn't forget to pay for anything? Possessing a stolen item when leaving Spessmart is grounds for immediate termination.",
	)

/mob/living/simple_animal/robot/robot_greeter/proc/greet(var/atom/movable/AM)
	if(directional_responses.Find("[AM.dir]"))
		say(directional_responses["[AM.dir]"])

/mob/living/simple_animal/robot/robot_greeter/informer
	name = "RulesBot"
	desc = "To tell you the rules."

	directional_responses = list("1" = "New customer! Are you acquainted with Spessmart's rules? Not following them will land you into deep trouble.")

	var/list/rules = list(
	"Breaking any of these rules will result in termination of you and all of your suspected cooperators.",
	"Rule number one: The customer is never right here.",
	"Rule number two: Do not break, eat or otherwise damage any property of Spessmart. Food samples are an exception - eat them all you want.",
	"Rule number three: Do not leave the shopping area with unpaid items, and do not attempt to remove any unpaid item from the shopping area. The only exception is the changing room - you are allowed to bring unpaid clothing into the changing room to try it on.",
	"Rule number four: Do not attempt to access secure areas, unless you are a level 5 Spessmart employee.",
	"That's it! Just remember these four rules, and as long as you don't break any of them, your experience at Spessmart will be top-notch!",
	)

	var/last_rules = 0

/mob/living/simple_animal/robot/robot_greeter/informer/attack_hand(mob/user)
	if((user.a_intent == I_HELP) && world.time > last_rules + ((rules.len+1) SECONDS))
		last_rules = world.time

		spawn()
			for(var/i = 1 to rules.len)
				say(rules[i])
				sleep(10)
	else
		return ..()

/mob/living/simple_animal/robot/robot_cashier
	name = "Cashier"
	desc = "Only accepts cash."

	icon = 'icons/mob/robots.dmi'
	icon_state = "booty-red"

	anchored = 1
	canmove = 0
	intent = I_HURT

	faction = "spessmart"

	var/loaded_cash = 0
	var/help_cd = 0

/mob/living/simple_animal/robot/robot_cashier/Die()
	var/area/vault/supermarket/shop/A = get_area(src)
	if(istype(A))
		A.on_theft()

	return ..()

/mob/living/simple_animal/robot/robot_cashier/attack_hand(mob/user)
	if(user.a_intent == I_HELP)
		if(world.time < help_cd + 0.5 SECONDS)
			return

		spawn(3)
			help_cd = world.time
			var/area/vault/supermarket/shop/shop = get_area(src)
			if(!istype(shop))
				say("ERROR> :$$-UAable to DoAAect to the dostDo maiAframe-%OI51")
				return

			var/turf/input_loc = get_step(get_turf(src), dir)
			var/list/found_items = list()
			var/price = 0

			for(var/obj/item/I in input_loc)
				if(shop.items.Find(I))
					found_items.Add(I)
					price += shop.items[I]

			if(found_items.len > 0)
				if(price > 0)
					if(loaded_cash == 0)
						say("[found_items.len] items, that will be $[price].00 space credits. Please insert cash or a check into the cash slot.")
						visible_message("<span class='info'>\The [src]'s cash slot flashes.</span>")
					else if(loaded_cash < price)
						say("[found_items.len] items, that will be $[price].00 space credits. Currently you only have [loaded_cash] credits inserted. Please insert more money or a check into the cash slot.")
						visible_message("<span class='info'>\The [src]'s cash slot flashes.</span>")
					else
						say("[found_items.len] items for $[price].00 space credits. Change: $[loaded_cash - price].00 space credits. Thank you for shopping at Spessmart!")
						for(var/obj/item/I in found_items)
							shop.purchased(I)
						if(shop.destination_disks > 0)
							say("Please take this complimentary Spessmart shuttle destination disk as well. Shop smart, shop Spessmart!")
							new /obj/item/weapon/disk/shuttle_coords/vault/supermarket(input_loc)
							shop.destination_disks--

						loaded_cash -= price

						if(loaded_cash > 0)
							dispense_cash(loaded_cash, input_loc)
							loaded_cash = 0
				else
					say("[found_items.len] items, free of charge. Thank you for shopping at Spessmart!")
					for(var/obj/item/I in found_items)
						shop.purchased(I)
			else
				if(loaded_cash > 0)
					say("Ejecting $[loaded_cash].00 space credits.")
					dispense_cash(loaded_cash, input_loc)
					loaded_cash = 0
				else
					say("Hello! Please place all items that you wish to purchase on the table in front of me, and activate me again.")

/mob/living/simple_animal/robot/robot_cashier/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/weapon/spacecash))
		var/obj/item/weapon/spacecash/S = I
		var/money_add = S.amount * S.worth

		if(user.drop_item(I))
			qdel(I)

			src.loaded_cash += money_add
			to_chat(user, "<span class='info'>You insert [money_add] space credits into \the [src]. \The [src] now holds [loaded_cash] space credits.</span>")
	else
		return ..()


///FOOD SAMPLES BOT
//Voice-activated, spawns food samples when its name is called


/mob/living/simple_animal/robot/food_samples //A bot that generates 1u nutriment food samples
	name = "Food Sample Bot"

	var/id_tag = "fucktard" //When the robot hears this, it generates a food sample
	var/id_num = 69

	desc = "A robot that creates free food samples. It's voice activated; to receive a sample you must call it by its ID number or tag."
	flags = HEAR_ALWAYS

	icon = 'icons/mob/robots.dmi'
	icon_state = "booty-red"

	var/spawn_sample_on_creation = 1
	var/obj/item/weapon/reagent_containers/food/snacks/food_type = /obj/item/weapon/reagent_containers/food/snacks/faggot //Type of the food
	var/food_vars = list( //Modified vars
		name = "Faggot's Delight",
	)

	var/last_spawned_sample = 0
	var/cooldown_between_samples = 5 SECONDS

/mob/living/simple_animal/robot/food_samples/examine(mob/user)
	..()

	to_chat(user, "Its ID tag is \"[id_tag]\", and its ID number is \"[id_num]\".")

/mob/living/simple_animal/robot/food_samples/New()
	var/list/all_food_types = (existing_typesof(/obj/item/weapon/reagent_containers/food/snacks) - typesof(/obj/item/weapon/reagent_containers/food/snacks/customizable) - typesof(/obj/item/weapon/reagent_containers/food/snacks/sliceable) - /obj/item/weapon/reagent_containers/food/snacks/slimesoup - typesof(/obj/item/weapon/reagent_containers/food/snacks/sweet))
	food_type = pick(all_food_types)

	var/name_preffix = "[random_name(pick(MALE, FEMALE), (prob(30) ? "vox" : "human"))]'s "

	name = "[name_preffix][name]"
	id_tag = pick(first_names_female)
	id_num = rand(1,1000)

	icon_state = "booty-[pick("red","white","green","flower","yellow","blue")]"

	if(prob(50))
		name_preffix = "[name_preffix][pick("delicious", "tasty", "delightful", "appetizing", "mouth-watering", "unique", "authentic", "natural", "real", "satisfactory", "enjoyable", "genuine", "[pick("double", "triple", "quadruple")]-layered")] "

	var/food_color = rgb(255,255,255)
	if(prob(80))
		food_color = rgb(rand(0,255), rand(0,255), rand(0,255))

	var/matrix/M = matrix()

	food_vars = list(
		name = "[name_preffix][initial(food_type.name)] sample",
		desc = "A tiny sample.",
		color = food_color,
		transform = M.Scale(0.75, 0.75)
	)

	if(spawn_sample_on_creation)
		spawn(10)
			spawn_sample(get_step(src, src.dir), 0)

	..()

/mob/living/simple_animal/robot/food_samples/Hear(datum/speech/speech, rendered_speech="")
	..()

	if(speech.speaker != src && (findtext(speech.message, "[id_tag]") || findtext(speech.message, "[id_num]")))
		if(!spawn_sample(get_step(src, src.dir)))
			say("I can't generate a sample right now. Please wait a few seconds, and try again!")

/mob/living/simple_animal/robot/food_samples/proc/spawn_sample(turf/new_loc, be_loud = 1, force = 0)
	if(!(force || (world.time > last_spawned_sample + cooldown_between_samples)))
		return

	var/obj/item/weapon/reagent_containers/food/snacks/S = new food_type(new_loc)

	for(var/D in food_vars)
		S.vars[D] = food_vars[D]

	if(S.reagents)
		S.reagents.remove_any(S.reagents.total_volume * 0.8) //Samples have 20% of actual reagents

	if(!S.reagents.total_volume)	//don't want to spawn samples that can't be eaten
		S.reagents.add_reagent(NUTRIMENT, 1)

	last_spawned_sample = world.time

	if(be_loud)
		say("Enjoy your [S.name]!")

	return 1

/mob/living/simple_animal/hostile/spessmart_guardian
	name = "Spessmart MERC-Bot"
	desc = "Equipped with a ballistic weapon and a melee range shocker that is powerful enough to knock out a mega goliath through three layers of protection, this EMP-proof bot is not to be messed around with."

	icon = 'icons/mob/robots.dmi'
	icon_state = "securitron"

	timestopped = 1
	anchored = 1
	canmove = 0

	melee_damage_lower = 10
	melee_damage_upper = 25

	maxHealth = 200
	health = 200

	attacktext = "electrocutes"
	a_intent = I_HURT

	attack_sound = 'sound/effects/eleczap.ogg'

	ranged = 1
	projectiletype = /obj/item/projectile/bullet
	projectilesound = 'sound/weapons/Gunshot.ogg'
	casingtype = /obj/item/ammo_casing/a357

	unsuitable_atoms_damage = 0
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	faction = "spessmart"

	var/alert_on_movement = 1 //If moved, trigger an alert and become agressive

/mob/living/simple_animal/hostile/spessmart_guardian/New()
	..()

	overlays.Add(image('icons/mob/robots.dmi', icon_state = "eyes-securitron"))

/mob/living/simple_animal/hostile/spessmart_guardian/Die()
	..()

	robogibs(get_turf(src))
	qdel(src)

/mob/living/simple_animal/hostile/spessmart_guardian/Move()
	if(alert_on_movement && !canmove)
		Retaliate()

	..()

/mob/living/simple_animal/hostile/spessmart_guardian/proc/Retaliate()
	if(timestopped)
		spawn(5)
			canmove = 1
			anchored = 0
			timestopped = 0

			visible_message("<span class='userdanger'>\The [src] activates.</span>")

			sleep(rand(1, 30))

			var/phrase = pick("Spessmart law was broken. The punishment is death.", "Spessmart law is above everything. Prepare to die.", "Spessmart law is sacred. Die, heretic.", "Threat to Spessmart detected. Extermination protocol started.")
			say(phrase)

	var/area/vault/supermarket/A = get_area(src)
	if(istype(A))
		var/area/vault/supermarket/shop/AS = locate(/area/vault/supermarket/shop)
		AS.on_theft()

/mob/living/simple_animal/hostile/spessmart_guardian/secure_area/attack_hand(mob/user)
	if(user.a_intent == I_HELP)
		say("[user.gender == FEMALE ? "Miss" : "Sir"], only Spessmart employees with level 5 access may access this area. If you are a Spessmart employee, please show me your ID card.")
	else
		return ..()

///////SPAWNER
/obj/map/spawner/supermarket
	name = "Spessmart spawner"
	amount = 4
	chance = 50
	jiggle = 10

/obj/map/spawner/supermarket/CreateItem(new_item_type)
	var/obj/item/I = ..()

	spawn()
		if(to_spawn[new_item_type])
			var/area/vault/supermarket/shop/S = locate(/area/vault/supermarket/shop)
			var/price = to_spawn[new_item_type]

			I.name = "[I.name] ($[price])"
			I.on_destroyed.Add(S, "item_destroyed") //Only trigger alarm when an item for sale is destroyed

			S.items[I] = price

	return I

/obj/map/spawner/supermarket/tools
	icon_state = "ass_tools"
	amount = 4
	chance = 50
	jiggle = 10

/obj/map/spawner/supermarket/tools/New()
	to_spawn = shop_prices
	return ..()

/obj/map/spawner/supermarket/circuits/New()
	if(!circuitboard_prices.len)
		for(var/C in circuitboards)
			circuitboard_prices[C] = 75
	to_spawn = circuitboard_prices
	return ..()

/obj/map/spawner/supermarket/clothing
	amount = 6

/obj/map/spawner/supermarket/clothing/New()
	if(!clothing_prices.len)
		for(var/C in clothing)
			clothing_prices[C] = 150
	to_spawn = clothing_prices
	return ..()

/obj/item/weapon/disk/shuttle_coords/vault/supermarket
	name = "Spessmart shuttle destination disk"
	desc = "Thank you for shopping at Spessmart, please come again!"
	destination = /obj/docking_port/destination/vault/supermarket

/obj/docking_port/destination/vault/supermarket
	areaname = "Spessmart"
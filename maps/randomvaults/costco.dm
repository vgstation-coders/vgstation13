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
/obj/item/bluespace_crystal/flawless = 300,
/obj/item/bluespace_crystal = 100,
/obj/item/device/assembly_frame = 50,
/obj/item/device/camera = 30,
/obj/item/device/flash = 20,
/obj/item/device/robotanalyzer = 5,
/obj/item/device/soundsynth = 20,
/obj/item/device/transfer_valve = 350, //What could go wrong
/obj/item/device/violin = 200,
/obj/item/device/maracas = 10,
/obj/item/device/aicard = 30,
/obj/item/device/soulstone = 400, //What could go wrong
/obj/item/device/taperecorder = 50,
/obj/item/device/rcd/tile_painter = 30,
/obj/item/device/rcd/matter/engineering = 30,
/obj/item/device/paicard = 10,
/obj/item/device/megaphone = 50,
/obj/item/device/hailer = 10,
/obj/item/broken_device = 1,
/obj/item/toy/balloon = 70,
/obj/item/toy/syndicateballoon = 700,
/obj/item/weapon/am_containment = 60,
/obj/item/weapon/cane = 5,
/obj/item/weapon/legcuffs/beartrap = 100,
/obj/item/weapon/rcd_ammo = 20,
/obj/item/weapon/storage/pneumatic = 40,
/obj/item/weapon/resonator = 100,
/obj/item/weapon/gun/energy/kinetic_accelerator = 80,
/obj/item/device/modkit/aeg_parts = 99,
/obj/item/clothing/accessory/medal/gold/captain = 1500,
/obj/item/device/radio/headset/headset_earmuffs = 125,


//weapons
/obj/item/weapon/melee/classic_baton = 100,
/obj/item/weapon/melee/lance = 200,
/obj/item/weapon/melee/telebaton = 500,
/obj/item/weapon/claymore = 600,
/obj/item/weapon/fireaxe  = 200,
/obj/item/weapon/spear/wooden = 200,
/obj/item/weapon/spear = 30,
/obj/item/weapon/crossbow = 100,
/obj/item/weapon/hatchet = 50,
/obj/item/weapon/harpoon = 125,
/obj/item/weapon/boomerang = 30,
/obj/item/weapon/boomerang/toy = 5,
/obj/item/weapon/batteringram = 1000,
/obj/item/weapon/shield/riot = 250,

//No guns sorry
)

/area/vault/supermarket/entrance
	name = "Costco Entrance"
	jammed = 1

/area/vault/supermarket/shop
	name = "Costco Store"
	jammed = 2
	icon_state = "green"

	var/list/items = list()
	var/lockdown = 0

/area/vault/supermarket/restricted
	name = "Costco Maintenance"
	jammed = 2
	icon_state = "red"

/area/vault/supermarket/shop/proc/initialize()
	spawn()
		for(var/obj/item/I in contents)
			for(var/type in shop_prices)
				if(istype(I, type))
					I.name = "[I.name] ($[shop_prices[type]])"
					I.on_destroyed.Add(src, "update_items")

					items[I] = shop_prices[type]

					continue

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

/area/vault/supermarket/shop/proc/update_items()
	for(var/obj/item/I in items)
		if(isnull(I.loc) || I.gcDestroyed)
			items.Remove(I)

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

	for(var/mob/living/simple_animal/hostile/retaliate/costco_guardian/C in all_contents)
		C.Retaliate()

	src.firealert()
	entrance.firealert()

///////ROBOTS
/mob/living/simple_animal/robot
	unsuitable_atoms_damage = 0

/mob/living/simple_animal/robot/Die()
	..()

	robogibs(get_turf(src))
	qdel(src)

/obj/effect/costco_entrance
	name = "Costco entrance marker"

	icon = 'icons/obj/weapons.dmi'
	icon_state = "toddler"

	invisibility = 0

/obj/effect/costco_entrance/Crossed(atom/movable/AM)
	if(isliving(AM))
		spawn(1)
			for(var/cdir in cardinal)
				for(var/mob/living/simple_animal/robot/robot_greeter/G in get_step(src, cdir))
					G.greet(AM)

	return ..()

/mob/living/simple_animal/robot/robot_greeter
	name = "WelcomeBot"
	desc = "The light inside is out, but it still works."

	icon = 'icons/mob/robots.dmi'
	icon_state = "Service"

	anchored = 1

	faction = "costco"

	var/list/directional_responses = list(
	NORTH = "Welcome to Costco. I love you.",
	SOUTH = "Thank you for shopping at Costco, come again.",
	)

/mob/living/simple_animal/robot/robot_greeter/Die()
	say("Vaae-#@ism is forbieeen at aostAo. Your aAAount will be terminated. Aonnection to aostAo mainframe lost... Self-destructing in 5... 4... 3...")
	say("2... 1...")

	spawn(3)
		..()

/mob/living/simple_animal/robot/robot_greeter/warner
	name = "WarnBot"
	desc = "Don't say you weren't warned."

	directional_responses = list(
	NORTH = "Please don't attempt to commit any crimes while in Costco. Any attempts of theft or vandalism will result in lockdown and termination.",
	SOUTH = "Are you sure you didn't forget to pay for anything? Possessing a stolen item when leaving Costco is grounds for immediate termination.",
	)

/mob/living/simple_animal/robot/robot_greeter/proc/greet(var/atom/movable/AM)
	if(directional_responses.Find(AM.dir))
		say(directional_responses[AM.dir])

/mob/living/simple_animal/robot/robot_cashier
	name = "Cashier"
	desc = "Only accepts cash."

	icon = 'icons/mob/robots.dmi'
	icon_state = "booty-red"

	anchored = 1
	canmove = 0
	intent = I_HURT

	faction = "costco"

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
						say("[found_items.len] items, that will be $[price].00 space credits or [max(rand(0.1,9.9)*rand(0.1,9999.99),1)] bitcoins. Please insert cash or a check into the glowing cash slot.") //hehe
						visible_message("<span class='info'>\The [src]'s cash slot rapidly flashes.</span>")
					else if(loaded_cash < price)
						say("[found_items.len] items, that will be $[price].00 space credits or [max(rand(0.1,9.9)*rand(0.1,9999.99),1)] bitcoins. Currently you only have [loaded_cash] credits inserted. Please insert more cash into the glowing cash slot.")
					else
						say("[found_items.len] items for $[price].00 space credits. Change: $[loaded_cash - price].00 space credits. Thank you for shopping at Costco!")
						for(var/obj/item/I in found_items)
							shop.purchased(I)

						loaded_cash -= price

						if(loaded_cash > 0)
							dispense_cash(loaded_cash - price, input_loc)
							loaded_cash = 0
				else
					say("[found_items.len] items , free of charge. Thank you for shopping at Costco!")
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

/mob/living/simple_animal/hostile/retaliate/costco_guardian
	name = "Costco MERC-Bot"
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

	faction = "costco"

/mob/living/simple_animal/hostile/retaliate/costco_guardian/New()
	..()

	overlays.Add(image('icons/mob/robots.dmi', icon_state = "eyes-securitron"))

/mob/living/simple_animal/hostile/retaliate/costco_guardian/Die()
	..()

	robogibs(get_turf(src))
	qdel(src)

/mob/living/simple_animal/hostile/retaliate/costco_guardian/Retaliate()
	if(timestopped)
		spawn(5)
			canmove = 1
			anchored = 0
			timestopped = 0

			visible_message("<span class='userdanger'>\The [src] activates.</span>")

			sleep(rand(1, 30))

			var/phrase = pick("Costco law was broken. The punishment is death.", "Costco law is above everything. Prepare to die.", "Costco law is sacred. Die, heretic.", "Threat to Costco detected. Extermination protocol started.")
			say(phrase)

	var/area/vault/supermarket/shop/A = get_area(src)
	if(istype(A))
		A.on_theft()

	..()

/mob/living/simple_animal/hostile/retaliate/costco_guardian/attack_hand(mob/user)
	if(user.a_intent == I_HELP)
		if(!enemies.Find(user) && !timestopped)
			spawn(5)
				say("For your safety, this area has been temporarily locked down due to crime. If you are innocent, you have nothing to fear. Please wait until Costco officials arrive.")
			return 1
	else
		return ..()


///////SPAWNER
/obj/map/spawner/supermarket
	name = "Costco spawner"
	icon_state = "ass_tools"
	amount = 4
	chance = 50
	jiggle = 10

/obj/map/spawner/supermarket/New()
	toSpawn = shop_prices
	return ..()
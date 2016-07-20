//Object and area definitions go here
/area/vault //Please make all areas used in vaults a subtype of this!
	name = "mysterious structure"
	requires_power = 0
	icon_state = "firingrange"
	dynamic_lighting = 1

/area/vault/icetruck

/area/vault/asteroid

/area/vault/tommyboyasteroid
	requires_power = 1

/area/vault/satelite

/area/vault/factory

/area/vault/clownbase

/area/vault/gym

/area/vault/oldarmory

/area/vault/rust
	requires_power = 1

/area/vault/dancedance

/area/vault/dancedance/loot
	jammed = 2

/area/vault/spacepond

/area/vault/ioufort

/area/vault/hive_shuttle

/area/vault/listening
	requires_power = 1

/area/vault/biodome
	requires_power = 1

/area/vault/brokeufo
	requires_power = 1

/area/vault/zoo

/mob/living/simple_animal/hostile/monster/cyber_horror/quiet
	speak_chance = 1 //shut the fuck up

/obj/item/weapon/bananapeel/traitorpeel/curse
	name = "cursed banana peel"
	desc = "A peel from a banana, surrounded by an evil aura of trickery and mischief. "

	anchored = 1
	cant_drop = 1

	slip_power = 10

/obj/item/weapon/melee/morningstar/catechizer
	name = "The Catechizer"
	desc = "An unholy weapon forged eons ago by a servant of Nar-Sie."

	force = 37
	throwforce = 30
	throw_speed = 3
	throw_range = 5

/obj/effect/landmark/catechizer_spawn //Multiple of these are put in a single area. One of these landmark will contain a true catachizer, others only mimics
	name = "catechizer spawn"

/obj/effect/landmark/catechizer_spawn/New()
	spawn()
		if(!isturf(loc)) return

		var/list/all_spawns = list()
		for(var/obj/effect/landmark/catechizer_spawn/S in get_area(src))
			all_spawns.Add(S)

		var/obj/effect/true_spawn = pick(all_spawns)
		all_spawns.Remove(true_spawn)

		var/obj/item/weapon/melee/morningstar/catechizer/original = new(get_turf(true_spawn))

		for(var/obj/effect/S in all_spawns)
			new /mob/living/simple_animal/hostile/mimic/crate/item(get_turf(S), original) //Make copies
			qdel(S)

		qdel(src)

/obj/machinery/door/poddoor/vault_rust
	id_tag = "tokamak_yadro_ventilyatsionnyy" // Russian for "tokamak_core_vent"

/obj/machinery/door_control/vault_rust
	name   = "tokamak yadro ventilyatsionnyy"
	id_tag = "tokamak_yadro_ventilyatsionnyy"

/obj/item/weapon/fuel_assembly/trilithium
	name = "trilithium fuel rod assembly"

/obj/item/weapon/fuel_assembly/trilithium/New()
	. = ..()
	rod_quantities["Trilithium"] = 300

/obj/machinery/power/apc/frame/rust_vault
	make_alerts = FALSE

/obj/machinery/power/apc/frame/rust_vault/initialize()
	. = ..()
	name = "regulyator moshchnosti oblast'"

/obj/machinery/power/generator/rust_vault
	name = "termoelektricheskiy generator metki dva"

	thermal_efficiency = 0.90

/obj/machinery/power/battery_port/rust_vault
	name = "raz\"yem pitaniya"

/obj/machinery/power/rust_core/rust_vault
	name = "\improper Razmnozitel' Ustojcivogo Sostojanija Termojadernyj versija sem' tokamak yadro"

/obj/machinery/vending/engineering/rust_vault
	name = "\improper Robco instrumental'shchik"

/obj/item/device/rcd/rpd/rust_vault
	name = "\improper Bystroye Ustroystvo Truboprovodov (BUT)"

/obj/item/device/rcd/matter/engineering/rust_vault
	name = "\improper Bystroye Stroitel'stvo Ustroystv (BSU)"

/obj/item/weapon/paper/tommyboy
	name = "failed message transcript"
	info = {"This is Major Tom to Ground Control<br>
			I'm stepping through the door<br>
			And I'm floating in the most peculiar way<br>
			And the stars look very different today<br>
			For here am I sitting in my tin can<br>
			Far above the world<br>
			Planet Earth is blue<br>
			And there's nothing I can do.
			"}

/obj/machinery/atmospherics/binary/msgs/rust_vault
	name = "\improper Magnitno Priostanovleno Blok Khraneniya Gaza"

/obj/item/weapon/paper/iou
	name = "paper- 'IOU'"
	info = "I owe you a rod of destruction. Redeemable at Milliway's at the end of time."

/obj/machinery/telecomms/relay/preset/vault_listening
	id = "syndicate relay"
	hide = 1
	toggled = 0
	autolinkers = list("hub")

/obj/machinery/power/apc/no_alerts/vault_listening/initialize()
	. = ..()
	name = "\improper Listening Outpost APC."

/obj/machinery/power/battery/smes/vault_listening
	chargelevel = 30000
	chargemode  = TRUE

/obj/machinery/power/solar/control/vault_listening
	track = 2 // Automatic

/obj/machinery/floodlight/on/New()
	..()
	on = 1
	set_light(brightness_on)
	update_icon()

/obj/machinery/floodlight/on/infinite
	cell = /obj/item/weapon/cell/infinite

/obj/machinery/bot/farmbot/duey
	name = "Duey"
	desc = "Looks like a maintenance droid, repurposed for botany management. Seems the years haven't been too kind."
	health = 150
	maxhealth = 150
	icon_state = "duey0"
	icon_initial = "duey"
	Max_Fertilizers = 50

/obj/item/weapon/paper/feeding_schedule
	name = "note"
	info = {"
	<h2><b></b></h2>
	<s>PE</s> PANDA - meat, water daily (large portions)<br>
	Chicken (<b>WHITE</b>) - wheat, water (daily)<br>
	<s>snake chicken - special food (crate</s><br>
	Snake Chicken (<b>PURPLE and green</b>) - greens and water daily. remove eggs every 1000 hours and dispose by protocol. <b>ALWAYS WEAR A BIOSUIT WHEN HANDLING, DO NOT TOUCH OR PROVOKE</b><br>
	scrite - meat, water (large portions every 160 hours) (DANGEROUS use food delivery)<br>
	dog - special food (crate 2) and water <s>every 2</s>daily<br>
	cat - special food (crate 2) and water daily<br>
	crab - special food (crate 3) every 80 hours<br>
	goat - greens and water daily<br>
	<s>mem</s> <s>mimec</s> <s>Mi</s> items in secure crate 5 - moisturize every 500 hours, DO NOT TOUCH (it's alive)<br>
	<br>

	Remember to update computer database after feeding!<br>
	"}

/obj/effect/landmark/stonefier
	name = "STONIFIER"
	desc = "Turns all mobs on this turf into statues forever. Used for map editing!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "statue"

	layer = 100
	plane = 100
	//So that it's more visible in the map editor

/obj/effect/landmark/stonefier/New()
	var/turf/T = get_turf(src)

	spawn()
		for(var/mob/living/L in T)
			L.turn_into_statue(1, 1)

	qdel(src)


/obj/effect/trap/cockatrice_notice //When triggered, cockatrices turn and hiss at you
	name = "cockatrice trigger"

/obj/effect/trap/cockatrice_notice/can_activate(atom/movable/AM)
	if(istype(AM, /mob/living/simple_animal/hostile/retaliate/cockatrice))
		return 0

	return ..()

/obj/effect/trap/cockatrice_notice/activate(atom/movable/AM)
	for(var/mob/living/simple_animal/hostile/retaliate/cockatrice/CO in view(7))
		if(CO.isDead())
			continue

		CO.face_atom(AM)
		CO.visible_message("<span class='notice'>\The [CO] looks at \the [AM] and hisses angrily!</span>")

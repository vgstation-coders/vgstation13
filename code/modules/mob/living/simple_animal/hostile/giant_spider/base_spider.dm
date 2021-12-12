#define SPIDER_MAX_PRESSURE_DIFF 50

#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4

//basic spider mob, these generally guard nests
/mob/living/simple_animal/hostile/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 10
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/spidermeat
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stomps"
	stop_automated_movement_when_pulled = 0
	maxHealth = 200 // Was 75
	health = 200
	melee_damage_lower = 15
	melee_damage_upper = 20
	heat_damage_per_tick = 20
	cold_damage_per_tick = 20
	faction = "spiders"
	pass_flags = PASSTABLE
	move_to_delay = 6
	speed = 4
	attack_sound = 'sound/weapons/spiderlunge.ogg'

	species_type = /mob/living/simple_animal/hostile/giant_spider
	wanted_objects = list(
		/obj/machinery/bot,          // Beepsky and friends
		/obj/machinery/light,        // Bust out lights
	)
	search_objects = 1 // Consider objects when searching.  Set to 0 when attacked
	wander = 1
	ranged = 0
	//minimum_distance = 1
	size = SIZE_SMALL //dog-sized spiders are still big!

	var/icon_aggro = null // for swapping to when we get aggressive
	var/poison_per_bite = 5
	var/poison_type = TOXIN
	var/delimbable_icon = TRUE
	environment_smash_flags = SMASH_LIGHT_STRUCTURES | SMASH_CONTAINERS | OPEN_DOOR_STRONG

	//Spider aren't affected by atmos.
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	held_items = list()

	//keeping this here for later color matrix testing
	var/a_matrix_testing_override = FALSE
	var/a_11 = 1
	var/a_12 = 0
	var/a_13 = 0
	var/a_14 = 0
	var/a_21 = 0
	var/a_22 = 1
	var/a_23 = 0
	var/a_24 = 0
	var/a_31 = 0
	var/a_32 = 0
	var/a_33 = 1
	var/a_34 = 0
	var/a_41 = 0
	var/a_42 = 0
	var/a_43 = 0
	var/a_44 = 1
	var/a_51 = 0
	var/a_52 = 0
	var/a_53 = 0
	var/a_54 = 0

	var/obj/abstract/screen/plane_master/overdark_planemaster/overdark_planemaster
	var/obj/abstract/screen/plane_master/overdark_planemaster_target/overdark_target

/mob/living/simple_animal/hostile/giant_spider/New()
	..()
	overdark_planemaster = new
	overdark_planemaster.render_target = "night vision goggles (\ref[src])"
	overdark_target = new
	overdark_target.render_source = "night vision goggles (\ref[src])"

/mob/living/simple_animal/hostile/giant_spider/Login()
	..()
	client.images += light_source_images
	client.screen |= overdark_planemaster
	client.screen |= overdark_target

/mob/living/simple_animal/hostile/giant_spider/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover, /obj/item/projectile/web))//Queen Spider webs pass through other spiders
		return 1
	return ..()

/mob/living/simple_animal/hostile/giant_spider/update_icons()
	.=..()

	if(stat == DEAD && butchering_drops && delimbable_icon)
		var/datum/butchering_product/spider_legs/our_legs = locate(/datum/butchering_product/spider_legs) in butchering_drops
		if(istype(our_legs))
			icon_state = "[icon_dead][(our_legs.amount<8) ? our_legs.amount : ""]"

// Checks pressure here vs. around us. Intended to make sure the spider doesn't breach to space while comfortable, or breach into a high pressure area
/mob/living/simple_animal/hostile/giant_spider/proc/performPressureCheck(var/turf/curturf)
	if(!istype(curturf))
		return 0
	var/datum/gas_mixture/myenv=curturf.return_air()
	var/pressure=myenv.return_pressure()

	for(var/checkdir in cardinal)
		var/turf/T = get_step(curturf, checkdir)
		if(T && istype(T))
			var/datum/gas_mixture/environment = T.return_air()
			var/pdiff = abs(pressure - environment.return_pressure())
			if(pdiff > SPIDER_MAX_PRESSURE_DIFF)
				return pdiff
	return 0

/mob/living/simple_animal/hostile/giant_spider/UnarmedAttack(var/atom/A, var/proximity_flag, var/params)
	if(istype(A,/obj/structure/window) && proximity_flag && (!target || !ismob(target)) && performPressureCheck(get_turf(A)))
		return
	.=..()

/mob/living/simple_animal/hostile/giant_spider/get_butchering_products()
	return list(/datum/butchering_product/spider_legs)

//Can we actually attack a possible target?
/mob/living/simple_animal/hostile/giant_spider/CanAttack(var/atom/the_target)
	if(istype(the_target,/obj/machinery/light))
		var/obj/machinery/light/L = the_target
		// Not empty or broken
		return L.current_bulb && L.current_bulb.status != LIGHT_BROKEN
	return ..(the_target)

/mob/living/simple_animal/hostile/giant_spider/AttackingTarget()
	..()
	if(isliving(target))
		var/mob/living/L = target
		if(L.reagents)
			if(prob(poison_per_bite))
				src.visible_message("<span class='warning'>\the [src] injects a powerful toxin!</span>")
				L.reagents.add_reagent(poison_type, poison_per_bite)


/mob/living/simple_animal/hostile/giant_spider/Aggro()
	..()
	if(icon_aggro)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/giant_spider/LoseAggro()
	..()
	if(icon_aggro)
		icon_state = icon_living

/mob/living/simple_animal/hostile/giant_spider/Life()
	if(timestopped)
		return 0 //under effects of time magick
	. = ..()

	regular_hud_updates()
	standard_damage_overlay_updates()

/mob/living/simple_animal/hostile/giant_spider/update_perception()
	if(a_matrix_testing_override)	// setting to 1 lets you use spiders as a perception-testing mob
		client.color = list(a_11,a_12,a_13,a_14,
							a_21,a_22,a_23,a_24,
	 						a_31,a_32,a_33,a_34,
		 					a_41,a_42,a_43,a_44,
		 					a_51,a_52,a_53,a_54)
		check_dark_vision()
		return

	if(dark_plane)
		if (master_plane)
			master_plane.blend_mode = BLEND_ADD
		dark_plane.alphas["spider"] = 15 // with the master_plane at BLEND_ADD, shadows appear well lit while actually well lit places appear blinding.
		client.color = list(
					1,0,0,0,
					0,1,0,0,
	 				0,0,1,0,
		 			0,0,-0.1,1,
		 			0,0,0,0)

	check_dark_vision()

/mob/living/simple_animal/hostile/giant_spider/regular_hud_updates()
	if (!client)
		return

	if(fire_alert)
		throw_alert(SCREEN_ALARM_FIRE, /obj/abstract/screen/alert/carbon/burn/fire/spider)
	else
		clear_alert(SCREEN_ALARM_FIRE)
	update_pull_icon()

	if(hud_used && healths)
		if (health >= maxHealth)//I tried using a switch() and BYOND told me to go fuck myself basically so here we go
			healths.icon_state = "health0"
		else if (health >= 3*maxHealth/4)
			healths.icon_state = "health1"
		else if (health >= maxHealth/2)
			healths.icon_state = "health2"
		else if (health >= maxHealth/4)
			healths.icon_state = "health3"
		else if (health > 0)
			healths.icon_state = "health4"
		else
			healths.icon_state = "health5"

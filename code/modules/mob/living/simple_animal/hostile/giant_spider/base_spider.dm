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

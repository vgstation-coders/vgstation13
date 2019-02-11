/mob/living/simple_animal/hostile/creature
	name = "creature"
	desc = "A sanity-destroying otherthing."
	speak_emote = list("gibbers")
	icon_state = "otherthing"
	icon_living = "otherthing"
	icon_dead = "otherthing-dead"
	health = 80
	maxHealth = 80
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "chomps"
	attack_sound = 'sound/weapons/bite.ogg'
	faction = "creature"
	speed = 5
	size = SIZE_BIG

/mob/living/simple_animal/hostile/creature/cult
	faction = "cult"
	var/shuttletarget = null
	var/enroute = 0

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	supernatural = 1
	held_items = list()

/mob/living/simple_animal/hostile/creature/cult/CanAttack(var/atom/the_target)
	//IF WE ARE CULT MONSTERS (those who spawn after Nar-Sie has risen) THEN WE DON'T ATTACK CULTISTS
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/creature/cult/cultify()
	return

/mob/living/simple_animal/hostile/creature/cult/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()
	if(emergency_shuttle.location == 1)
		if(!enroute && !target)	//The shuttle docked, all monsters rush for the escape hallway
			if(!shuttletarget && escape_list.len) //Make sure we didn't already assign it a target, and that there are targets to pick
				shuttletarget = pick(escape_list) //Pick a shuttle target
			enroute = 1
			stop_automated_movement = 1
/*			spawn()
				if(!src.stat)
					horde()*/

		if(get_dist(src, shuttletarget) <= 2) //The monster reached the escape hallway
			enroute = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/creature/cult/proc/horde()
	var/turf/T = get_step_to(src, shuttletarget)
	for(var/atom/A in T)
		if(istype(A,/obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/D = A
			if(D.density && !D.locked && !D.welded)
				D.open()
		else if(istype(A,/obj/machinery/door/mineral))
			var/obj/machinery/door/D = A
			if(D.density)
				D.open()
		else if(istype(A,/obj/structure/cult_legacy/pylon))
			A.attack_animal(src)
		else if(istype(A, /obj/structure/window) || istype(A, /obj/structure/closet) || istype(A, /obj/structure/table) || istype(A, /obj/structure/grille) || istype(A, /obj/structure/rack))
			A.attack_animal(src)
	Move(T)
	var/new_target = FindTarget()
	GiveTarget(new_target)
	if(!target || enroute)
		spawn(10)
			if(!src.stat)
				horde()
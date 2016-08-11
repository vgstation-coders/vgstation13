/mob/living/simple_animal/hostile/necro
	var/mob/creator
/mob/living/simple_animal/hostile/necro/skeleton
	name = "skeleton"
	desc = "Truly the ride never ends."
	icon_state = "skelly"
	icon_living = "skelly"
	icon_dead = "skelly_dead"
	icon_gib = "skelly_dead"
	speak_chance = 0
	turns_per_move = 1
	can_butcher = 0
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 3
	maxHealth = 50
	health = 50

	can_butcher = 0

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	environment_smash = 1
	meat_type = null

#define EVOLVING 1
#define MOVING_TO_TARGET 2
#define EATING 3
#define OPENING_DOOR 4
//#define SMASHING_LIGHT 5

/mob/living/simple_animal/hostile/necro/zombie //Boring ol default zombie
	name = "zombie"
	desc = "A reanimated corpse that looks like it has seen better days."
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	icon_gib = "zombie_dead"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 6
	maxHealth = 100
	health = 100
	canRegenerate = 1
	minRegenTime = 300
	maxRegenTime = 1800


	harm_intent_damage = 15
	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	environment_smash = 1

	var/times_revived //Tracks how many times the zombie has regenerated from death
	var/times_eaten //Tracks how many times the zombie has chewed on a human corpse
	var/can_evolve = 0 //Set to 0 if we don't want it to evolve
	var/busy //If the zombie is busy, and what it's busy doing
	var/break_doors = 0 //If 1, they can attempt to open doors. If 2, they break the door down entirely
	var/health_cap = 250 //Maximum possible health it can have. Because screw having a 1000 health mob

/*	wanted_objects = list(
		/obj/machinery/light,        // Bust out lights
	)
	search_objects = 1

/mob/living/simple_animal/hostile/necro/zombie/CanAttack(var/atom/the_target)
	if(istype(the_target,/obj/machinery/light))
		var/obj/machinery/light/L = the_target
		// Not empty or broken
		return L.status != 1 && L.status != 2
	return ..(the_target)*/ //Too buggy, gets caught on terrain way too much

/mob/living/simple_animal/hostile/necro/New(loc, mob/living/Owner, datum/mind/Controller)
	..()
	if(Owner)
		faction = "\ref[Owner]"
		friends.Add(Owner)
		if(Controller)
			mind = Controller
			ckey = ckey(mind.key)
			to_chat(src, "<big><span class='warning'>You have been risen from the dead by your new master, [Owner]. Do his bidding so long as he lives, for when he falls so do you.</span></big>")
		var/ref = "\ref[Owner.mind]"
		var/list/necromancers
		if(!(Owner.mind in ticker.mode.necromancer))
			ticker.mode:necromancer[ref] = list()
		necromancers = ticker.mode:necromancer[ref]
		necromancers.Add(Controller)
		ticker.mode:necromancer[ref] = necromancers
		ticker.mode.update_necro_icons_added(Owner.mind)
		ticker.mode.update_necro_icons_added(Controller)
		ticker.mode.update_all_necro_icons()
		ticker.mode.risen.Add(Controller)

	if(name == "zombie" || name == "skeleton")
		name += " ([rand(1,1000)])"

/mob/living/simple_animal/hostile/necro/zombie/Life()
	..()
	/*TODO
	First, check if the zombie can potentially evolve
	Have the zombie move to a corpse and start chewing at it
	If neither of these things are applicable, break some lights to set the mood
	Otherwise, start wandering and bust down some doors to find more food
	*/
	if(!stat)
		if(stance == HOSTILE_STANCE_IDLE) //Not doing anything at the time
			var/list/can_see = view(src, vision_range)
			if(!busy)
				if(can_evolve)//Can we evolve, and have we fed
					busy = EVOLVING
					check_evolve()
				if((health < maxHealth) || (maxHealth < health_cap)) //Is there something to eat in range?
					for(var/mob/living/carbon/human/C in can_see) //If so, chow down
						if(C.stat == DEAD && !busy && check_edibility(C))
							Goto(C, move_to_delay)
							busy = MOVING_TO_TARGET
							give_up(C) //If we're not there in 10 seconds, give up

							if(C.Adjacent(src) && busy != EATING) //Once we've finally caught up
								busy = EATING
								eat(C)
				if(!busy && break_doors)//So we don't try to eat and open doors
					/*for(var/obj/machinery/light/L in can_see)
						if(L.status != 1 && L.status !=2)
							Goto(L, move_to_delay)
							busy = MOVING_TO_TARGET
							if(L.Adjacent(src) && busy != SMASHING_LIGHT)
								L.attack_animal(src)*/

					for(var/obj/machinery/door/D in can_see)//Else, let's open some doors and see what's around
						if(can_open_door(D) && !busy)
							Goto(D, move_to_delay)
							busy = MOVING_TO_TARGET
							give_up(D)

							if(D.Adjacent(src) && busy != OPENING_DOOR)
								busy = OPENING_DOOR
								force_door(D)

		else
			busy = 0
			stop_automated_movement = 0


/mob/living/simple_animal/hostile/necro/zombie/proc/give_up(var/C)
	spawn(100)
		if(busy == MOVING_TO_TARGET)
			if(target == C && get_dist(src,target) > 1)
				target = null
			busy = 0
			stop_automated_movement = 0

/mob/living/simple_animal/hostile/necro/zombie/proc/can_open_door(var/obj/machinery/door/D)
	if(istype(D,/obj/machinery/door/poddoor) || istype(D, /obj/machinery/door/airlock/multi_tile/glass) || istype(D, /obj/machinery/door/window))
		return 0

	// Don't fuck with doors that are doing something
	if(D.operating>0)
		return 0

	// Don't open opened doors.
	if(!D.density)
		return 0

	// Can't open bolted/welded doors
	if(istype(D,/obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A=D
		if(A.locked || A.welded || A.jammed)
			if(break_doors == 2)
				return 1
			else
				return 0

	return 1

/mob/living/simple_animal/hostile/necro/zombie/proc/force_door(var/obj/machinery/door/D)
	stop_automated_movement = 1
	D.visible_message("<span class='warning'>\The [D]'s motors whine as something attempts to brute force their way through it!</span>")
	playsound(get_turf(D), 'sound/effects/grillehit.ogg', 50, 1)
	D.shake(1, 8)
	stop_automated_movement = 1
	spawn(100) //Roughly 10 seconds for people on the other side of the door to run the heck away
		if(can_open_door(D))//Let's see if nobody quickly bolted it
			if(istype (src, /mob/living/simple_animal/hostile/necro/zombie/crimson)) //Guaranteed
				D.visible_message("<span class='warning'>\The [D] breaks open under the pressure</span>")
				if(istype(D, /obj/machinery/door/airlock/))
					var/obj/machinery/door/airlock/A = D
					A.locked = 0
					A.welded = 0
					A.jammed = 0
				D.open(1)
			else
				if(prob(15))
					D.visible_message("<span class='warning'>\The [D] creaks open under force, steadily</span>")
					D.open(1)
		busy = 0
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/necro/zombie/proc/check_edibility(var/mob/living/carbon/human/target)
	if(isjusthuman(target)) //Humans are always edible
		return 1
	if(target.health > -400) //So they're not caught eating the same dumb bird all day
		return 1

	return 0

/mob/living/simple_animal/hostile/necro/zombie/proc/eat(var/mob/living/carbon/human/target)
	//Deal a random amount of brute damage to the corpse in question, heal the zombie by the damage dealt halved
	visible_message("<span class='notice'>\the [src] starts to take a bite out of \the [target].</span>")
	spawn(50)
		playsound(get_turf(src), 'sound/weapons/bite.ogg', 50, 1)
		var/damage = rand(melee_damage_lower, melee_damage_upper)
		target.adjustBruteLoss(damage)
		health += (damage/2)
		if(maxHealth < health_cap)
			maxHealth += 5 //A well fed zombie is a scary zombie
		times_eaten += 1
		busy = 0

/mob/living/simple_animal/hostile/necro/zombie/proc/check_evolve()
	if(!can_evolve) //How did you get here if not?
		return

	/*
					Turned (Just reanimated, can be turned back)
										V
				Rotting (If eaten once, or died once, can't be turned back)
				/													\
			Putrid													Crimson
	Eaten too much, died too little								Eaten too little, died too much
	*/
	if(istype(src, /mob/living/simple_animal/hostile/necro/zombie/turned))
		if(times_revived > 0 || times_eaten > 0)
			evolve(/mob/living/simple_animal/hostile/necro/zombie/rotting)

	else if (istype(src, /mob/living/simple_animal/hostile/necro/zombie/rotting))
		if(times_eaten > (1+times_revived)*2) //Have to have eaten at least twice and more than double that of times died
			evolve(/mob/living/simple_animal/hostile/necro/zombie/putrid)
		else if(times_revived > times_eaten+1) //Died at least twice
			evolve(/mob/living/simple_animal/hostile/necro/zombie/crimson)

	busy = 0

/mob/living/simple_animal/hostile/necro/zombie/proc/evolve(var/mob/living/simple_animal/evolve_to)
	if(istype(evolve_to, /mob/living/simple_animal/hostile/necro))
		var/mob/living/evolution = new evolve_to(src.loc,,)
		evolution.name = name //We want to keep the name
		mind.transfer_to(evolution) //Just in the offchance we have a player in control
		qdel(src)
	else
		//Now, how did you get here when this is supposed to be the zombie evolution tree?
		new evolve_to(src.loc)
		qdel(src)

/mob/living/simple_animal/hostile/necro/zombie/proc/drop_host()

/mob/living/simple_animal/hostile/necro/zombie/delayedRegen()
	..()
	times_revived += 1

/mob/living/simple_animal/hostile/necro/zombie/turned //Not very useful
	icon_state = "zombie_turned" //Looks almost not unlike just a naked guy to potentially catch others off guard
	icon_living = "zombie_turned"
	icon_dead = "zombie_turned_dead"
	desc = "A reanimated corpse that looks like it has seen better days. This one still appears quite human."
	maxHealth = 50
	health = 50
	can_evolve = 1
	var/mob/living/carbon/human/host //Whoever the zombie was previously, kept in a reference to potentially bring back

/mob/living/simple_animal/hostile/necro/zombie/turned/drop_host()
	qdel(host) //Bye bye

/mob/living/simple_animal/hostile/necro/zombie/turned/gib()
	..()
	drop_host()

/mob/living/simple_animal/hostile/necro/zombie/turned/dust()
	..()
	drop_host()

/mob/living/simple_animal/hostile/necro/zombie/turned/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(stat == DEAD) //Can only attempt to unzombify if they're dead
		if(istype (W, /obj/item/weapon/storage/bible)) //This calls for divine intervention
			var/obj/item/weapon/storage/bible/bible = W
			visible_message("\The [user] begins whacking at [src] repeatedly with a bible for some reason.")
			to_chat (user, "<span class='notice'>You attempt to invoke the power of [bible.deity_name] to bring this poor soul back from the brink.</span>")

			var/chaplain = 0 //Are we the Chaplain ? Used for simplification
			if(user.mind && (user.mind.assigned_role == "Chaplain"))
				chaplain = 1 //Indeed we are

			spawn(25) //So there's a nice delay
			if(!chaplain)
				if(prob(5)) //Let's be generous, they'll only get one regen for this
					to_chat (user, "<span class='notice'>By [bible.deity_name] it's working!.</span>")
					unzombify()
				else
					to_chat (user, "<span class='notice'>Well, that didn't work.</span>")

			else if(chaplain)
				var/holy_modifier = 1 //How much the potential for reconversion works
				if(user.reagents.reagent_list.len)
					if(WHISKEY in user.reagents.reagent_list || HOLYWATER in user.reagents.reagent_list) //Take a swig, then get to work
						holy_modifier += 1
				var/turf/turf_on = get_turf(src) //See if the dead guy's on holy ground
				if(turf_on.holy) //We're in the chapel
					holy_modifier += 2
				else
					if(turf_on.blessed) //The chaplain's spilt some of his holy water
						holy_modifier += 1

				if(prob(15*holy_modifier)) //Gotta have faith
					to_chat (user, "<span class='notice'>By [bible.deity_name] it's working!.</span>")
					unzombify()
				else
					to_chat (user, "<span class='notice'>Well, that didn't work.</span>")

/mob/living/simple_animal/hostile/necro/zombie/turned/proc/unzombify()
	if(host)
		host.loc = get_turf(src)
		if(!host.mind && src.mind) //This is assuming that, somehow, the host lost their soul, and it ended up in the zombie
			mind.transfer_to(host)
		host.resurrect() //It's a miracle!
		host.revive()
		visible_message("<span class='notice'>\The [src]'s eyes regain focus, the smell of decay vanishing, [host] has come back to their senses!.</span>")
		host = null
		qdel(src)
	else
		visible_message("<span class='notice'>\The [src] grumbles for a moment, then begins to decay at an accelerated rate, seems there was nobody left to save.</span>")
		dust()

/mob/living/simple_animal/hostile/necro/zombie/rotting
	icon_living = "zombie_rotten"
	icon_state = "zombie_rotten"
	icon_dead = "zombie_rotten_dead"
	desc = "A reanimated corpse that looks like it has seen better days. Whoever this was is long gone."
	maxHealth = 100
	health = 100
	can_evolve = 1
	break_doors = 1

/mob/living/simple_animal/hostile/necro/zombie/putrid
	icon_living = "zombie" //The original
	icon_state = "zombie"
	icon_dead = "zombie_dead"
	desc = "A reanimated corpse that looks like it has seen better days. This one appears to be quite gluttenous"
	maxHealth = 150
	health = 150
	can_evolve = 0
	var/zombify_chance = 25 //Down with hardcoding
	break_doors = 1

/mob/living/simple_animal/hostile/necro/zombie/putrid/eat(mob/living/carbon/human/target)
	..()
	if(target.health < -150  && isjusthuman(target)) //Gotta be a bit chewed on
		visible_message("<span class='warning'>\The [target] stirs, as if it's trying to get up.</span>")
		if(prob(zombify_chance))
			zombify(target)

/mob/living/simple_animal/hostile/necro/zombie/putrid/proc/zombify(var/mob/living/carbon/human/target)
	//Make the target drop their stuff, move them into the contents of the zombie so the ghost can at least see how its zombie self is doing
	target.drop_all()
	var/mob/living/simple_animal/hostile/necro/zombie/turned/new_zombie = new /mob/living/simple_animal/hostile/necro/zombie/turned(target.loc)
	new_zombie.name = target.real_name
	new_zombie.host = target
	target.loc = null

/mob/living/simple_animal/hostile/necro/zombie/crimson
	icon_state = "zombie_crimson"
	icon_living = "zombie_crimson"
	icon_dead = "zombie_crimson_dead"
	maxHealth = 150
	health = 150
	melee_damage_lower = 15
	melee_damage_upper = 40 //Those claws are not messing around

	attacktext = "slashes"
	attack_sound = "sound/weapons/bloodyslice.ogg"
	break_doors = 2

/mob/living/simple_animal/hostile/necro/zombie/leatherman
	..()
	name = "leatherman"
	icon_dead = "zombie_leather_dead"
	icon_gib = "zombie_leather_dead"
	icon_state = "zombie_leather"
	icon_living = "zombie_leather"
	desc = "Fuck you!"
	can_evolve = 0

#undef EVOLVING
#undef MOVING_TO_TARGET
#undef EATING
#undef OPENING_DOOR
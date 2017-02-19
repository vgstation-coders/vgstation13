//Gremlins
//Small monsters that don't usually attack humans or other animals. Instead they mess with electronics, computers and machinery

//List of objects that gremlins can't tamper with (because nobody coded an interaction for it)
//List starts out empty. Whenever a gremlin finds a machine that it couldn't tamper with, the machine's type is added here, and all machines of such type are ignored from then on (NOT SUBTYPES)
var/list/bad_gremlin_items = list()

/mob/living/simple_animal/hostile/gremlin
	name = "gremlin"
	desc = "This tiny creature finds great joy in discovering and using technology. Nothing excites it more than pushing random buttons on a computer to see what it might do."
	icon = 'icons/mob/critter.dmi'
	icon_state = "gremlin"
	icon_living = "gremlin"
	icon_dead = "gremlin_dead"

	health = 20
	maxHealth = 20
	size = SIZE_TINY
	search_objects = 3 //Completely ignore mobs

	//Tampering is handled by the 'npc_tamper()' obj proc
	wanted_objects = list(
		/obj/machinery,
	)

	//List of objects that we don't even want to try to tamper with
	//Subtypes of these are calculated too
	var/list/unwanted_objects = list(/obj/machinery/atmospherics/pipe)

	//Amount of ticks spent pathing to the target. If it gets above a certain amount, assume that the target is unreachable and stop
	var/time_chasing_target = 0
	var/max_time_chasing_target = 2

/mob/living/simple_animal/hostile/gremlin/AttackingTarget()
	if(istype(target, /obj/machinery))
		var/obj/machinery/M = target

		if(M.npc_tamper_act(src)) //The proc returns 1 if there's no interaction
			visible_message(pick(
			"<span class='notice'>\The [src] plays around with \the [M], but finds it rather boring.</span>",
			"<span class='notice'>\The [src] tries to think of some more ways to screw \the [M] up, but fails miserably.</span>",
			"<span class='notice'>\The [src] decides to ignore \the [M], and starts looking for something more fun.</span>"))

			bad_gremlin_items.Add(M.type)
		else
			visible_message(pick(
			"<span class='danger'>\The [src]'s eyes light up as \he tampers with \the [M].</span>",
			"<span class='danger'>\The [src] twists some knobs around on \the [M] and bursts into laughter!</span>",
			"<span class='danger'>\The [src] presses a few buttons on \the [M] and giggles mischievously.</span>",
			"<span class='danger'>\The [src] rubs its hands devilishly and starts messing with \the [M].</span>",
			"<span class='danger'>\The [src] turns a small valve on \the [M].</span>"))

		LoseTarget() //Find something new to screw up

/mob/living/simple_animal/hostile/gremlin/CanAttack(atom/new_target)
	if(bad_gremlin_items.Find(new_target.type))
		return FALSE
	if(is_type_in_list(new_target, unwanted_objects))
		return FALSE

	return ..()

/mob/living/simple_animal/hostile/gremlin/Life()
	//Don't try to path to one target for too long. If it takes longer than a certain amount of time, assume it can't be reached and find a new one
	if(!target)
		time_chasing_target = 0
	else
		if(++time_chasing_target > max_time_chasing_target)
			LoseTarget()
			time_chasing_target = 0

	.=..()

//The ultimate in green energy, a treadmill generates very low power each time it is bumped, which also updates its icon
//to move. You can still optimize this, though, by making yourself a workout machine -- be full, have sugar,
//have sports drink, have a high movespeed, have HULK as a mutation.
//Doesn't consume any idle power, you must to_bump() it from its own square. Bump works like a window.
//Using a treadmill uses up hunger faster

#define DEFAULT_BUMP_ENERGY 400

/obj/machinery/power/treadmill
	name = "treadmill generator"
	desc = "A low-power device that generates power based on how quickly someone walks."
	icon_state = "treadmill"
	density = 1
	flow_flags = ON_BORDER
	machine_flags = SCREWTOGGLE | WRENCHMOVE | EMAGGABLE
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 0
	pass_flags_self = PASSGLASS
	var/count_power = 0 //How much power have we produced SO FAR this count?
	var/tick_power = 0 //How much power did we produce last count?
	var/power_efficiency = 1 //Based on parts
	component_parts = newlist(
		/obj/item/weapon/circuitboard/treadmill,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/console_screen
	)

	hack_abilities = list(
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/power/treadmill/New()
	..()
	setup_border_dummy()
	if(anchored)
		connect_to_network()
	RefreshParts()

/obj/machinery/power/treadmill/RefreshParts()
	var/calc = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			calc+=SP.rating
	power_efficiency = calc/4 //Possible results 1, 2, and 3 -- basically, what tier we have

/obj/machinery/power/treadmill/examine(mob/user as mob)
	..()
	to_chat(user, "<span class='info'>During the last cycle, it produced [tick_power] watts.</span>")

/obj/machinery/power/treadmill/process()
	tick_power = count_power
	count_power = 0
	add_avail(tick_power)

/obj/machinery/power/treadmill/proc/powerwalk(atom/movable/AM as mob)
	if(!ismob(AM))
		return //Can't walk on a treadmill if you aren't animated
	if(get_turf(AM) != loc)
		return //Can't bump from the outside
	var/mob/living/runner = AM
	var/cached_temp = runner.bodytemperature
	if(runner.burn_calories(HUNGER_FACTOR*2))
		flick("treadmill-running", src)
		playsound(src, 'sound/machines/click.ogg', 50, 1)
		var/calc = DEFAULT_BUMP_ENERGY * power_efficiency * runner.treadmill_speed
		if(runner.reagents) //Sanity
			calc *= runner.reagents.get_sportiness()
		if(M_HULK in runner.mutations)
			calc *= 5
		count_power += calc
		if(emagged && ishuman(runner))
			runner.bodytemperature += 1
			if(runner.bodytemperature > T0C + 100)
				switch(rand(1,100))
					if(1 to 5)
						runner.emote("collapse")
					if(5 to 10)
						to_chat(runner,"<span class='warning'>You really should take a rest!</span>")
					if(10 to 20)
						to_chat(runner,"<span class='warning'>Your legs really hurt!</span>")
						runner.apply_damage(5, BRUTE, LIMB_LEFT_LEG)
						runner.apply_damage(5, BRUTE, LIMB_RIGHT_LEG)
					else
						//do nothing
				runner.bodytemperature = max(T0C + 100,cached_temp)
	else
		to_chat(runner,"<span class='warning'>You're exhausted! You can't run anymore!</span>")

/obj/machinery/power/treadmill/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(pass_flags_self))
		return TRUE
	if(!density)
		return TRUE
	if(locate(/obj/effect/unwall_field) in loc) //Annoying workaround for this -kanef
		return TRUE
	if(istype(mover))
		return bounds_dist(border_dummy, mover) >= 0
	else if(get_dir(loc, target) == dir)
		return FALSE
	return TRUE

/obj/machinery/power/treadmill/Bumped(atom/movable/AM)
	if(AM.loc == loc)
		powerwalk(AM)

/obj/machinery/power/treadmill/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(anchored)
		connect_to_network()
	else
		disconnect_from_network()

/obj/machinery/power/treadmill/emag_act()
	..()
	emagged = 1
	name = "\improper DREADMILL"
	desc = "FEEL THE BURN"

/obj/machinery/power/treadmill/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Treadmill (Clockwise)"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained()  || anchored)
		return

	change_dir(turn(src.dir, -90))

/obj/machinery/power/treadmill/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Treadmill (Counterclockwise)"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained()  || anchored)
		to_chat(usr, "It is fastened to the floor!")
		return

	change_dir(turn(src.dir, 90))

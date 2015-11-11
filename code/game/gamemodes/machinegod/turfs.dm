/turf/simulated/floor/clockcult
	name			= "clockwork floor"
	desc			= "It's filled with rotating and moving clockwork components."

	icon			= 'icons/turf/clockwork.dmi'
	icon_state		= "floor"

/turf/simulated/floor/clockcult/airless
	oxygen = 0.01
	nitrogen = 0.01

/turf/simulated/floor/clockcult/Entered(var/atom/movable/Obj, var/atom/OldLoc)
	if(isliving(Obj))
		var/mob/living/M = Obj
		if(!iscult(M))
			return

		// Burn them, no message though because spam.
		M.apply_damage(1.5, BURN)

	return ..()

/turf/simulated/floor/clockcult/New()
	. = ..()

	global.clockcult_TC++

/turf/simulated/floor/clockcult/Del() // Sadly turfs only hard del.
	. = ..()

	global.clockcult_TC--

/turf/simulated/wall/clockcult
	name			= "clockwork wall"
	desc			= "It's filled with rotating and moving clockwork components."

	icon			= 'icons/turf/clockwork.dmi'
	icon_state		= "wall"

/turf/simulated/wall/clockcult/New()
	. = ..()

	global.clockcult_TC++

/turf/simulated/wall/clockcult/Del()
	. = ..()

	global.clockcult_TC--

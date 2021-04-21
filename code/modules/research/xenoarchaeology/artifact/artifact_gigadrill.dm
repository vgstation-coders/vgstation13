
/obj/machinery/giga_drill
	name = "alien drill"
	desc = "A giant, alien drill mounted on long treads."
	icon = 'icons/obj/mining.dmi'
	icon_state = "gigadrill"
	var/active = 0
	var/drill_time = 10
	var/turf/drilling_turf
	density = 1
	layer = ABOVE_OBJ_LAYER

/obj/machinery/giga_drill/Destroy()
	new /datum/artifact_postmortem_data(src)
	..()

/obj/machinery/giga_drill/attack_hand(mob/user as mob)
	if(active)
		active = 0
		icon_state = "gigadrill"
		to_chat(user, "<span class='notice'>You press a button and [src] slowly spins down.</span>")
	else
		active = 1
		icon_state = "gigadrill_mov"
		to_chat(user, "<span class='notice'>You press a button and [src] shudders to life.</span>")

/obj/machinery/giga_drill/to_bump(atom/A)
	if(active && !drilling_turf)
		if(istype(A,/turf/unsimulated/mineral))
			var/turf/unsimulated/mineral/M = A
			if(M.mining_difficulty >= MINE_DIFFICULTY_DENSE)
				return
			drilling_turf = get_turf(src)
			src.visible_message("<span class='danger'>[src] begins to drill into [M]!</span>")
			anchored = 1
			spawn(drill_time)
				if(get_turf(src) == drilling_turf && active)
					M.GetDrilled()
					src.forceMove(M)
				drilling_turf = null
				anchored = 0

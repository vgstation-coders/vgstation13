
/obj/effect/rooting_trap
	name = "trap"
	desc = "How did you get trapped in that? Try resisting."
	mouse_opacity = 1
	icon_state = "energynet"
	w_type=NOT_RECYCLABLE
	anchored = 1
	density = 0
	plane = ABOVE_HUMAN_PLANE
	layer = CLOSED_CURTAIN_LAYER
	var/atom/stuck_to = null
	var/duration = 10 SECONDS

/obj/effect/rooting_trap/cultify()
	return

/obj/effect/rooting_trap/singularity_act()
	return

/obj/effect/rooting_trap/singularity_pull()
	return

/obj/effect/rooting_trap/blob_act()
	return


/obj/effect/rooting_trap/Destroy()
	if(stuck_to)
		unlock_atom(stuck_to)
	stuck_to = null
	..()

/obj/effect/rooting_trap/proc/stick_to(var/atom/A, var/side = null)
	var/turf/T = get_turf(A)
	if(isspace(T)) //can't nail people down unless there's a turf to nail them to.
		return FALSE
	if(!isliving(A))
		return FALSE
	var/mob/living/M = A
	if(M.stat < 2)
		stuck_to = A
		lock_atom(A, /datum/locking_category/buckle)

		spawn(duration)
			qdel(src)

		return TRUE
	return FALSE

/obj/effect/rooting_trap/attack_hand(var/mob/user)
	unstick_attempt(user)

/obj/effect/rooting_trap/proc/unstick_attempt(var/mob/user)
	if (do_after(user,src,1.5 SECONDS))
		unstick()

/obj/effect/rooting_trap/proc/unstick()
	if(stuck_to)
		unlock_atom(stuck_to)
	qdel(src)

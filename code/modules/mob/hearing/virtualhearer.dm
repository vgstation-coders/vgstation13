var/global/list/mob/virtualhearer/virtualhearers = list()
var/global/list/mob/virtualhearer/movable_hearers = list()
var/global/list/mob/virtualhearer/mob_hearers = list()
//To improve the performance of the virtualhearers loop, we do not need to
//locate the virtualhearers of these stationary objects, as they should not move
//and if they do move (singuloth), the virtualhearer should be moving with them
var/list/stationary_hearers = list(	/obj/item/device/radio/intercom,
									/obj/machinery/camera,
									/obj/machinery/hologram/holopad)

/mob/virtualhearer
	name = ""
	see_in_dark = 8
	icon = null
	icon_state = null
	var/atom/movable/attached = null
	anchored = 1
	density = 0
	invisibility = INVISIBILITY_MAXIMUM
	flags = INVULNERABLE
	status_flags = GODMODE
	alpha = 0
	animate_movement = 0
	ignoreinvert = 1

/mob/virtualhearer/New(atom/attachedto)
	virtualhearers += src
	loc = get_turf(attachedto)
	attached = attachedto

	var/mob/M = attachedto
	if(istype(M))
		sight = M.sight
		see_invisible = M.see_invisible
		mob_hearers[attachedto] = src

	if(!is_type_in_list(attachedto,stationary_hearers))
		movable_hearers += src

/mob/virtualhearer/Destroy()
	..()
	virtualhearers -= src
	movable_hearers -= src
	mob_hearers -= attached
	attached = null

// NOTE: Almost nothing actually uses this proc.
// Most forms of speech, such as get_hearers_in_view(), simply call Hear() directly in our attached atom.
// If you want to actually override this proc somewhere... you're screwed lol
/mob/virtualhearer/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(attached)
		attached.Hear(arglist(args))
	else
		qdel(src)

/mob/virtualhearer/ex_act()
	return

/mob/virtualhearer/singularity_act()
	return

/mob/virtualhearer/cultify()
	return

/mob/virtualhearer/singularity_pull()
	return

/mob/virtualhearer/blob_act()
	return

/mob/virtualhearer/update_canmove()
	return 1 // the default canmove value of virtualhearers

/mob/proc/change_sight(adding, removing, copying)
	var/oldsight = sight
	if(copying)
		sight = copying
	if(removing)
		sight &= ~removing
	if(adding)
		sight |= adding
	if(sight != oldsight)
		if(sight & (SEE_TURFS | SEE_MOBS | SEE_OBJS))
			sight &= ~SEE_BLACKNESS
		else
			sight |= SEE_BLACKNESS

		var/mob/virtualhearer/VH = mob_hearers[src]
		if(VH)
			VH.sight = sight

// This subtype does nothing by itself. Since overriding Hear() in a virtualhearer subtype is impossible (see comment above),
// the only reason this subtype exists is so other procs can explicitly check its type and know to delete it themselves.
// Currently, this type is given by /datum/reagent/temp_hearer/on_introduced() and removed by /obj/item/weapon/reagent_containers/Hear().
/mob/virtualhearer/one_time

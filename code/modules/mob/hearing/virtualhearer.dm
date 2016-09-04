var/global/list/mob/virtualhearer/virtualhearers = list()
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
	//This can be expanded with vision flags to make a device to hear through walls for example
	var/attached_type = null
	var/attached_ref = null

/mob/virtualhearer/New(atom/attachedto)
	AddToProfiler()
	virtualhearers += src
	loc = get_turf(attachedto)
	attached = attachedto

	var/mob/M = attachedto
	if(istype(M))
		sight = M.sight
		see_invisible = M.see_invisible

/* An equally nonsense and good idea, keep stationary hearers from moving, but without a second list
track virtualhearers how are you going to REMOVE virtualhearers
	if(is_type_in_list(attachedto,stationary_hearers))
		virtualhearers -= src
*/
/mob/virtualhearer/Destroy()
	..()
	virtualhearers -= src
	attached = null

/mob/virtualhearer/resetVariables()
	return

/mob/virtualhearer/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(attached)
		attached.Hear(args)
	else
		returnToPool(src)

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

/mob/proc/change_sight(adding, removing, copying)
	var/oldsight = sight
	if(copying)
		sight = copying
	if(adding)
		sight |= adding
	if(removing)
		sight &= ~removing
	if(sight != oldsight)
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				VH.sight = sight
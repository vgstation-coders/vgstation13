//

#define CAN_SEE			1
#define CANT_SEE		0

#define SEE_IN_MECH		1
#define IS_ANTAG_HUD	2


/obj/screen/plane_master/data_hud/New(var/hud_plane,var/visible)
	plane = hud_plane
	if(visible)
		alpha = 255
	else
		alpha = 0

/obj/screen/plane_master/data_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	appearance_flags = 0
	alpha = 0

/obj/screen/plane_master/data_dummy/New(var/hud_plane)
	plane = hud_plane

/datum/data_hud
	var/name
	var/plane
	var/flags
	var/obj/screen/plane_master/data_hud/visible
	var/obj/screen/plane_master/data_hud/invisible
	var/obj/screen/plane_master/data_dummy/dummy

/datum/data_hud/New()
	if(!name || master_controller.active_data_huds[name])
		qdel(src)
	else
		master_controller.active_data_huds[name] = src
		visible = new /obj/screen/plane_master/data_hud(plane,CAN_SEE)
		invisible = new /obj/screen/plane_master/data_hud(plane,CANT_SEE)
		dummy = new /obj/screen/plane_master/data_dummy(plane)

/datum/data_hud/proc/update_invisibility(var/client/C)
	if(!C)
		return

	var/list/S = C.screen

	if(!S || !S.len)
		return

	if(can_be_seen_by(C.mob))
		S -= invisible
		S |= visible
	else
		S |= invisible
		S -= visible

/datum/data_hud/proc/update_hud(var/mob/user)
	remove_hud(user)
	if(!check(user))
		return

	var/image/data_hud = to_add(user)

	if(!data_hud || !istype(data_hud))
		return

	//var/imageloc = user

	if(flags & SEE_IN_MECH)
		if(istype(user.loc,/obj/mecha))
			var/obj/mecha/mech = user.loc
			mech.underlays += data_hud
			mech.data_huds[name] = data_hud
			return

	user.underlays += data_hud
	user.data_huds[name] = data_hud

//	var/image/dhud = image(loc = imageloc)
//	dhud.appearance = data_hud.appearance
//	user.data_huds[name]


/datum/data_hud/proc/update_mob(var/mob/user)
	if(!user)
		return
	update_hud(user)
	if(user.client)
		update_invisibility(user.client)

/datum/data_hud/proc/remove_hud(var/mob/user)
	if(!user)
		return
	if(user.data_huds[name])
		user.underlays -= user.data_huds[name]
		user.data_huds -= name

		//var/image/dhud = user.data_huds[name]
		//dhud.loc = null
		//user.data_huds[name] = null
		//qdel(dhud)

/datum/data_hud/proc/to_add(var/mob/user)
	return

/datum/data_hud/proc/check(var/mob/user)
	return

/datum/data_hud/proc/can_be_seen_by(var/mob/user)
	return

/mob/proc/handle_data_huds_on_login()
	if(!src)
		return
	if(!client)
		return

	for(var/D in master_controller.active_data_huds)
		if(istype(master_controller.active_data_huds[D],/datum/data_hud))
			var/datum/data_hud/dhud = master_controller.active_data_huds[D]
			dhud.update_invisibility(client)
			client.screen |= dhud.dummy
	dummy_hud.update_hud(src)

/mob/proc/update_data_huds()
	for(var/D in master_controller.active_data_huds)
		if(istype(master_controller.active_data_huds[D],/datum/data_hud))
			var/datum/data_hud/dhud = master_controller.active_data_huds[D]
			dhud.update_hud(src)

/datum/data_hud/dummy	// prevents people from right clicking mobs to see things they shouldn't.
	name = "dummy"
	plane = DUMMY_HUD_PLANE
	var/image/dummy_image
	flags = SEE_IN_MECH

/datum/data_hud/dummy/New()
	..()
	dummy_image = image('icons/mob/mob.dmi', icon_state = "white")
	dummy_image.alpha = 0
	dummy_image.layer = REALLY_LOW_LAYER
	dummy_image.plane = plane

/datum/data_hud/dummy/check(var/mob/user)
	return ismob(user)

/datum/data_hud/dummy/to_add(var/mob/user)
	return dummy_image

/datum/data_hud/dummy/can_be_seen_by(var/mob/user)
	return

var/global/datum/data_hud/dummy/dummy_hud = new /datum/data_hud/dummy()
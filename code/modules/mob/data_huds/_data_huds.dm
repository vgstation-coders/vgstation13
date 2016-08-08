//

#define CAN_SEE			1
#define CANT_SEE		0

#define SEE_IN_MECH		1
#define IS_ANTAG_HUD	2

var/list/invisible_matrix = list(1,0,0,0,
								 0,1,0,0,
								 0,0,1,0,
								 0,0,0,0,
								 0,0,0,0)


var/list/visible_matrix   = list(1,0,0,0,
								 0,1,0,0,
								 0,0,1,0,
								 0,0,0,0,
								 0,0,0,1)


/obj/screen/plane_master/data_hud/New(var/hud_plane)
	plane = hud_plane

/obj/screen/plane_master/data_dummy
	// this avoids a bug which means plane masters which have nothing to control get angry and mess with the other plane masters out of spite
	appearance_flags = 0
	alpha = 0

/obj/screen/plane_master/data_dummy/New(var/hud_plane,var/visible)
	plane = hud_plane
	/*if(visible)
		color = visible_matrix
	else
		color = invisible_matrix */

/datum/data_hud
	var/name
	var/plane
	var/flags
	var/obj/screen/plane_master/data_hud/visible
	var/obj/screen/plane_master/data_hud/invisible
	var/obj/screen/plane_master/data_dummy/dummy

/datum/data_hud/New()
	visible = new /obj/screen/plane_master/data_hud(plane,CAN_SEE)
	invisible = new /obj/screen/plane_master/data_hud(plane,CANT_SEE)
	dummy = new /obj/screen/plane_master/data_dummy(plane)
	if(!name || master_controller.active_data_huds[name])
		qdel(src)
	else
		master_controller.active_data_huds[name] = src

/datum/data_hud/proc/update_invisibility(var/client/C)
	var/S = C.screen
	if(!C || !S)
		return

	if(can_be_seen_by(src))
		S -= invisible
		S |= visible
	else
		S |= invisible
		S -= visible

/datum/data_hud/proc/update_hud(var/mob/user)
	if(!check(user))
		remove_hud(user)
		return

	var/image/data_hud = to_add(user)

	if(!data_hud || !istype(data_hud))
		return

	var/obj/mecha/mech = user.loc
	if(istype(mech) && (flags & SEE_IN_MECH))
		mech.overlays += data_hud
		mech.data_huds[name] = data_hud
	else
		user.data_huds[name] = data_hud
		user.overlays += data_hud
		user.update_icon()

/datum/data_hud/proc/remove_hud(var/mob/user)
	users.overlays -= user.data_huds[name]
	user.data_huds[name] = null

/datum/data_hud/proc/to_add(var/mob/user)
	return

/datum/data_hud/proc/check(var/mob/user)
	return

/datum/data_hud/proc/can_be_seen_by(var/mob/user)
	return

/mob/proc/toggle_see_hud(var/datum/data_hud/data_hud,var/visibility)
	data_hud.update_hud(src)
	toggle_hud(data_hud,visibility)

/mob/proc/toggle_hud(var/datum/data_hud/data_hud,var/visibility)
	if(!src)
		return
	if(!client)
		return

	data_hud.update_invisibility(client)

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

/mob/proc/handle_data_hud(var/datum/data_hud/data_hud,var/update_all)
	if(update_all)
		for(var/D in master_controller.active_data_huds)
			if(istype(master_controller.active_data_huds[D],/datum/data_hud))
				var/datum/data_hud/dhud = master_controller.active_data_huds[D]
				dhud.update_hud(src)
	else if(data_hud.check(src))
		data_hud.update_hud(src)
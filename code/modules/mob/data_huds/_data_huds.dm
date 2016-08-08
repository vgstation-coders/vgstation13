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


/obj/screen/plane_master/data_hud
	var/visibility

/obj/screen/plane_master/data_hud/New(var/hud_plane,var/visible)
	plane = hud_plane
	change_visibility(visible)

/obj/screen/plane_master/data_hud/proc/change_visibility(var/visible)
	if(visible)
		color = visible_matrix
		visibility = HUD_ON
	else
		color = invisible_matrix
		visibility = HUD_OFF

var/global/list/active_data_huds

/datum/data_hud
	var/name
	var/plane
	var/flags

/datum/data_hud/proc/update_hud(var/mob/user)
	if(!check(user))
		remove_hud(user)
		return

	var/image/data_hud = to_add(user)

	if(!data_hud || !istype(data_hud))
		return

	var/obj/mecha/mech = user.loc
	if(istype(mech) && (flags & SEE_IN_MECH))
		mech.data_huds[name] = data_hud
		mech.update_icon()
	else
		user.data_huds[name] = data_hud
		user.update_icon()

/datum/data_hud/proc/remove_hud(var/mob/user)
	user.data_huds[name] = null
	user.update_icon()

/datum/data_hud/New()
	if(!name || active_data_huds[name])
		qdel(src)
	else
		active_data_huds[name] = src

/datum/data_hud/proc/to_add(var/mob/user)
	return

/datum/data_hud/proc/check(var/mob/user)
	return

/datum/data_hud/proc/can_be_seen_by(var/mob/user)
	return

/mob/proc/toggle_see_hud(var/datum/data_hud/data_hud,var/visibility)
	data_hud.remove_hud(src)
	toggle_hud(data_hud,visibility)

/mob/proc/toggle_hud(var/datum/data_hud/data_hud,var/visibility)
	if(!src)
		return
	if(!client)
		return

	for(var/obj/screen/plane_master/data_hud/hud in client.images)
		if(hud.plane == data_hud.plane)
			if(visibility = hud.visibility)
				return // that's not how toggling works.
			client.images -= hud
			hud.change_visibility(visibility)
			client.images += hud
			return // no, this is not a trailing return, don't remove this.

/mob/proc/handle_data_huds_on_login()
	if(!src)
		return
	if(!client)
		return

	for(var/datum/data_hud/data_hud in active_data_huds)
		var/visibility_plane_master
		visibility_plane_master = new /obj/screen/plane_master/data_hud(data_hud.plane,data_hud.can_be_seen_by(src))
		client.images += visibility_plane_master

/mob/proc/handle_data_hud(var/datum/data_hud/data_hud,var/update_all)
	if(update_all)
		for(var/datum/data_hud/dhud in active_data_huds)
			dhud.update_hud(src)
	else if(data_hud.check(src))
		data_hud.update_hud(src)
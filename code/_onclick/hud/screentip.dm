/**
 * Screentip - displays the name of whatever the player is hovering over
 * Ported from TGStation
 */

/obj/abstract/screen/screentip
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "TOP,LEFT"
	maptext_height = 480
	maptext_width = 480
	maptext = ""
	var/datum/hud/hud

/obj/abstract/screen/screentip/New(loc, datum/hud/_hud)
	..()
	hud = _hud
	update_view()

/obj/abstract/screen/screentip/Destroy()
	hud = null
	return ..()

/obj/abstract/screen/screentip/proc/update_view()
	if(!hud?.mymob?.client)
		return
	var/view = hud.mymob.client.view
	if(!view)
		return
	var/list/viewlist = getviewsize(view)
	maptext_width = viewlist[1] * world.icon_size

/obj/abstract/screen/screentip/proc/get_size(size_setting)
	switch(size_setting)
		if(SCREENTIP_SIZE_SMALL)
			return "8px"
		if(SCREENTIP_SIZE_MEDIUM)
			return "10px"
		if(SCREENTIP_SIZE_LARGE)
			return "12px"
	return "10px"

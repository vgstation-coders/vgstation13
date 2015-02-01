#define LP_UP "up"
#define LP_DOWN "down"
#define LP_REVERSE "reverse"

/obj/item/line_painter
	name = "line painter"
	desc = "A rotating wheel attached to a white paint feed. Used by slackjawed lackeys for marking paths through areas."
	var/deploy_state = LP_UP
	icon = 'icons/obj/line_painter.dmi'
	icon_state = "painter_up"
	var/turf/last_painted
	var/marker_type = /obj/effect/nmpi/general

/obj/item/line_painter/update_icon()
	icon_state = "painter_[deploy_state]"

/obj/item/line_painter/attack_self(mob/user)
	if(deploy_state == LP_UP)
		user << "You deploy [src]."
		deploy_state = LP_DOWN
		update_icon()
		return

	if(get_dist(user, last_painted) > 1 || !(get_dir(user, last_painted) in cardinal)) //if we're too far away, or not in a direct line
		last_painted = null

	var/paint_dir
	if(!last_painted)
		paint_dir = user.dir
	else
		if(user.dir == get_dir(get_turf(user), last_painted)) //facing back the way we came
			paint_dir = user.dir
		else
			paint_dir = user.dir | get_dir(last_painted, get_turf(user))
			if(user.dir in list(EAST, WEST))
				paint_dir = turn(paint_dir, 180)

	switch(deploy_state)
		if(LP_DOWN)
			for(var/obj/effect/nmpi/marker in get_turf(user))
				if(marker.dir == paint_dir)
					user << "There is already a marker here."
					return
			var/obj/effect/newmarker = new marker_type(get_turf(src))
			newmarker.dir = paint_dir
			last_painted = get_turf(user)
		if(LP_REVERSE)
			for(var/obj/effect/nmpi/marker in get_turf(user))
				if(marker.dir == paint_dir)
					qdel(marker)
					return
				if(marker.dir & paint_dir)
					qdel(marker)
					return
			user << "There is no marker here."
			last_painted = get_turf(user)
			return

/obj/item/line_painter/attack_hand(mob/user)
	if(user.get_inactive_hand() == src) //in our offhand
		switch(deploy_state)
			if(LP_UP)
				deploy_state = LP_DOWN
				user << "You deploy [src]."
			if(LP_DOWN)
				deploy_state = LP_REVERSE
				user << "You activate [src]'s cleaner."
			if(LP_REVERSE)
				deploy_state = LP_UP
				user << "You lift [src]."
		update_icon()
	else
		..()

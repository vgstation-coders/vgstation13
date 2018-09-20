//The cyborg-friendly version and shameless copypaste of binoculars.
/obj/item/cyborglens
	name = "long-range zoom camera lens"
	icon_state = "binoculars"
	var/zoom = FALSE
	var/event_key = null

/obj/item/cyborglens/attack_self(mob/user)
	zoom = !zoom
	update_zoom(user)

/obj/item/cyborglens/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(zoom)
		zoom = FALSE
		update_zoom(holder)

/obj/item/cyborglens/proc/update_zoom(var/mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R =user
		if(R.client)
			var/client/C = R.client
			var/list/view = view_to_array(C.view)
			var/widescreen = view[3]
			if(!widescreen)
				view[1] = ((view[1] * 2) + 1)
				view[2] = ((view[2] * 2) + 1)

			if(zoom && R.is_component_functioning("camera"))
				event_key = R.on_moved.Add(src, "mob_moved")
				R.visible_message("[R]'s camera lens focuses loudly.","Your camera lens focuses loudly.")
				R.regenerate_icons()
				C.changeView("[view[1]+8]x[view[2]+8]")
			else
				R.on_moved.Remove(event_key)
				R.regenerate_icons()
				C.changeView("[view[1]-8]x[view[2]-8]")
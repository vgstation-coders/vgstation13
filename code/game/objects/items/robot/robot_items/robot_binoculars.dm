//The cyborg-friendly version and shameless copypaste of binoculars.
/obj/item/cyborglens
	name = "long-range zoom camera lens"
	icon_state = "binoculars"
	var/zoom = FALSE

/obj/item/cyborglens/attack_self(mob/user)
	zoom = !zoom
	update_zoom(user)

/obj/item/cyborglens/proc/mob_moved(atom/movable/mover)
	if(zoom)
		zoom = FALSE
		update_zoom(mover)

/obj/item/cyborglens/proc/update_zoom(var/mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R =user
		if(R.client)
			var/client/C = R.client
			if(zoom && R.is_component_functioning("camera"))
				R.register_event(/event/moved, src, nameof(src::mob_moved()))
				R.visible_message("[R]'s camera lens focuses loudly.","Your camera lens focuses loudly.")
				R.regenerate_icons()
				C.changeView(C.view + 4)
			else
				R.unregister_event(/event/moved, src, nameof(src::moved()))
				R.regenerate_icons()
				C.changeView(C.view - 4)

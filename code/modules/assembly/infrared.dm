/obj/item/device/assembly/infra
	name = "infrared emitter"
	short_name = "IR emitter"

	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	starting_materials = list(MAT_IRON = 1000, MAT_GLASS = 500)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=2"

	wires = WIRE_PULSE

	secured = TRUE

	var/on = FALSE
	var/visible = TRUE
	var/obj/effect/beam/infrared/beam = null

	accessible_values = list(
		"Visible" = "visible;number",\
		"On" = "on;number"
	)

/obj/item/device/assembly/infra/New(var/turf/loc)
	..()
	update_icon()

/obj/item/device/assembly/infra/Destroy(var/turf/loc)
	processing_objects.Remove(src)
	if (beam)
		QDEL_NULL(beam)
	..()

/obj/item/device/assembly/infra/examine(var/mob/user)
	..()
	to_chat(user, "<span class='notice'>The trigger is [on?"on":"off"].</span>")
	to_chat(user, "<span class='notice'>The lens is facing [dir2text(dir)].</span>")

/obj/item/device/assembly/infra/activate()
	if(!..())
		return 0//Cooldown check
	on = !on
	var/turf/T = get_turf(src)
	if (T)
		playsound(T,'sound/misc/click.ogg',30,0,-5)

	if (on)
		processing_objects.Add(src)
		playsound(T,'sound/weapons/egun_toggle_laser.ogg',70,0,-5)
		process()
	else
		if (beam)
			QDEL_NULL(beam)
		processing_objects.Remove(src)
		playsound(T,'sound/weapons/egun_toggle_taser.ogg',70,0,-5)
	update_icon()
	return 1

/obj/item/device/assembly/infra/toggle_secure()
	secured = !secured
	if(!secured)
		on = FALSE
		if(beam)
			QDEL_NULL(beam)
		processing_objects.Remove(src)
	update_icon()
	return secured

/obj/item/device/assembly/infra/update_icon()
	overlays.len = 0
	attached_overlays = list()
	attached_overlays["infrared_aim"] = image(icon = icon, icon_state = "infrared_aim", dir = dir)
	overlays += attached_overlays["infrared_aim"]

	if(on && visible)
		var/image/I = image(icon = icon, icon_state = "infrared_on", dir = dir)
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = ABOVE_LIGHTING_PLANE
		attached_overlays["infrared_on"] = I
		overlays += attached_overlays["infrared_on"]

	if(holder)
		holder.update_icon()

/obj/item/device/assembly/infra/process()
	if(!on)
		if (beam)
			QDEL_NULL(beam)
		return
	if(beam || !secured)
		return
	var/turf/T = null
	if(isturf(loc))//is it on the floor?
		T = get_turf(src)
	else if (holder)
		if (istype(holder.loc,/turf))//or in an assembly that's on the floor?
			T = holder.loc
		else if (holder.master && isturf(holder.loc.loc)) //or in an assembly rigging something that's on the floor?
			T = holder.loc.loc
	else if(isobj(loc) && isturf(loc.loc)) // or in a grenade on the floor/wired item? (can it even activate grenades without igniters?)
		T = loc.loc
	if(T)
		if(!beam)
			beam = new /obj/effect/beam/infrared(T)
		beam.visible=visible
		beam.dir = dir
		beam.assembly = src
		beam.emit(src)


/obj/item/device/assembly/infra/attack_hand()
	if (beam)
		QDEL_NULL(beam)
	..()


/obj/item/device/assembly/infra/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	var/t = dir
	..()
	dir = t
	if (beam)
		QDEL_NULL(beam)


/obj/item/device/assembly/infra/holder_movement()
	if(!holder)
		return 0
	dir = holder.dir
	holder.update_icon()
	if (beam)
		QDEL_NULL(beam)
	return 1


/obj/item/device/assembly/infra/proc/trigger_beam()
	if((!secured)||(!on)||(cooldown > 0))
		return 0
	pulse(0)
	if(!holder)
		visible_message("[bicon(src)] *beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()


/obj/item/device/assembly/infra/interact(mob/user as mob)//TODO: change this this to the wire control panel
	if(!secured)
		return
	user.set_machine(src)
	var/dat = text("<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>", (on ? text("<A href='?src=\ref[];state=0'>ON</A>", src) : text("<A href='?src=\ref[];state=1'>OFF</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>visible</A>", src) : text("<A href='?src=\ref[];visible=1'>infrared</A>", src)))

	dat += {"<B>Direction</B>: <A href='?src=\ref[src];direction=1'>[dir2text(dir)]</A><BR>"}
	dat += {"<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>
		<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"}
	user << browse("<TITLE>Infrared Laser</TITLE><HR>[dat]", "window=infra")
	onclose(user, "infra")


/obj/item/device/assembly/infra/Topic(href, href_list)
	..()
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return

	if(href_list["state"])
		activate()

	if(href_list["visible"])
		visible = !(visible)

		if(beam)
			beam.set_visible(visible)
		update_icon()

	if(href_list["close"])
		usr << browse(null, "window=infra")
		return

	if(href_list["direction"])
		var/choice = input("What direction will you aim the laser toward?","Infrared Laser") as null|anything in list("NORTH", "EAST", "SOUTH", "WEST")
		if (choice)
			dir = text2dir(choice)
			update_icon()
			if (beam)
				QDEL_NULL(beam)
			process()

	if(usr)
		attack_self(usr)


/***************************IBeam*********************************/

/obj/effect/beam/infrared
	name = "i beam"
	icon = 'icons/effects/beam.dmi'
	icon_state = "infrared"
	var/limit = null
	var/visible = TRUE
	var/left = null
	anchored = TRUE
	flags = 0

	var/obj/item/device/assembly/infra/assembly
	var/puffed = 0

	var/static/list/smokes_n_mists = list(
		/obj/effect/decal/chemical_puff,
		/obj/effect/smoke,
		/obj/effect/water,
		/obj/effect/foam,
		/obj/effect/steam,
		/obj/effect/mist,
		)

/obj/effect/beam/infrared/Destroy()
	assembly = null
	..()

/obj/effect/beam/infrared/get_damage()
	return 0

/obj/effect/beam/infrared/update_icon()
	puffed = 0
	if (!master)
		invisibility = INVISIBILITY_MAXIMUM
	else if (visible)
		invisibility = 0
		alpha = OPAQUE
	else
		invisibility = INVISIBILITY_LEVEL_ONE
		alpha = SEMI_TRANSPARENT

/obj/effect/beam/infrared/spawn_child()
	var/obj/effect/beam/infrared/B = ..()
	if (!B)
		return null
	B.visible=visible
	B.assembly=assembly
	return B

/obj/effect/beam/infrared/proc/set_visible(v)
	visible = v
	if (master)
		if (visible)
			invisibility = 0
			alpha = OPAQUE
		else
			invisibility = INVISIBILITY_LEVEL_ONE
			alpha = SEMI_TRANSPARENT
	if(next)
		var/obj/effect/beam/infrared/B=next
		B.set_visible(v)

/obj/effect/beam/infrared/proc/hit()
	if(assembly && stepped)//by checking for stepped we ensure the hit won't be triggered while the beam is still deploying
		assembly.trigger_beam()

////////////////////////////////////Entering the beam triggers the emitter//////////////////////
/obj/effect/beam/infrared/Crossed(var/atom/movable/AM)
	if(!master || !AM)
		return
	if(is_type_in_list(AM,smokes_n_mists))
		puffed++
		invisibility = 0
		var/turf/T = loc
		spawn(10)
			if (!gcDestroyed && T == loc)
				puffed--
				if (puffed <= 0)
					update_icon()
		return
	if(istype(AM, /obj/effect/beam) || (!AM.density && !istype(AM, /obj/effect/blob)))
		return
	if (!ismob(AM) && AM.Cross(src))
		return
	hit()
	..()

/obj/effect/beam/infrared/Bumped(var/atom/movable/AM)
	if(!master || !AM)
		return
	if(istype(AM, /obj/effect/beam) || !AM.density)
		return
	hit()
	..()

////////////////////////////////////Leaving the beam triggers the emitter//////////////////////
/obj/effect/beam/infrared/target_moved(atom/movable/mover)
	hit()
	..()

/obj/effect/beam/infrared/target_density_change(atom/atom)
	hit()
	..()

/obj/effect/beam/infrared/target_destroyed(datum/thing)
	hit()
	..()

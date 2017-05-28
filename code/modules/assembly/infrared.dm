

/obj/item/device/assembly/infra
	name = "infrared emitter"
	short_name = "IR emitter"

	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared"
	starting_materials = list(MAT_IRON = 1000, MAT_GLASS = 500)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=2"

	wires = WIRE_PULSE

	secured = 0

	var/on = 0
	var/visible = 0
	var/obj/effect/beam/infrared/beam = null

	accessible_values = list(
		"Visible" = "visible;number",\
		"On" = "on;number"
	)

	New()
		qdel(src) // Why is this even


///obj/item/device/assembly/infra/describe()
//	return "The infrared trigger is [on?"on":"off"]."

/obj/item/device/assembly/infra/activate()
	if(!..())
		return 0//Cooldown check
	on = !on
	update_icon()
	return 1


/obj/item/device/assembly/infra/toggle_secure()
	secured = !secured
	if(secured)
		processing_objects.Add(src)
	else
		on = 0
		if(beam)
			qdel(beam)
		processing_objects.Remove(src)
	update_icon()
	return secured


/obj/item/device/assembly/infra/update_icon()
	overlays.len = 0
	attached_overlays = list()
	if(on)
		attached_overlays += "infrared_on"
		overlays += image(icon = icon, icon_state = "infrared_on")

	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/infra/process()//Old code
	if(1)
		return PROCESS_KILL
	if(!on && beam)
		qdel(beam)
		return
	if(beam || !secured)
		return
	var/turf/T = null
	if(isturf(loc))
		T = get_turf(src)
	else if (holder)
		if (istype(holder.loc,/turf))
			T = holder.loc
		else if (isturf(holder.loc.loc)) //for onetankbombs and other tertiary builds with assemblies
			T = holder.loc.loc
	else if(istype(loc,/obj/item/weapon/grenade) && isturf(loc.loc))
		T = loc.loc
	if(T)
		if(!beam)
			beam = new /obj/effect/beam/infrared(T)
		beam.visible=visible
		beam.emit(src)
	return


/obj/item/device/assembly/infra/attack_hand()
	qdel(beam)
	..()
	return


/obj/item/device/assembly/infra/Move()
	var/t = dir
	..()
	dir = t
	qdel(beam)
	return


/obj/item/device/assembly/infra/holder_movement()
	if(!holder)
		return 0
//		dir = holder.dir
	qdel(beam)
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
	return


/obj/item/device/assembly/infra/interact(mob/user as mob)//TODO: change this this to the wire control panel
	if(!secured)
		return
	user.set_machine(src)
	var/dat = text("<TT><B>Infrared Laser</B>\n<B>Status</B>: []<BR>\n<B>Visibility</B>: []<BR>\n</TT>", (on ? text("<A href='?src=\ref[];state=0'>On</A>", src) : text("<A href='?src=\ref[];state=1'>Off</A>", src)), (src.visible ? text("<A href='?src=\ref[];visible=0'>Visible</A>", src) : text("<A href='?src=\ref[];visible=1'>Invisible</A>", src)))

	dat += {"<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>
		<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"}
	user << browse(dat, "window=infra")
	onclose(user, "infra")
	return


/obj/item/device/assembly/infra/Topic(href, href_list)
	..()
	if(!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr << browse(null, "window=infra")
		onclose(usr, "infra")
		return

	if(href_list["state"])
		on = !(on)
		update_icon()

	if(href_list["visible"])
		visible = !(visible)

		if(beam)
			beam.set_visible(visible)

	if(href_list["close"])
		usr << browse(null, "window=infra")
		return

	if(usr)
		attack_self(usr)

	return


/obj/item/device/assembly/infra/verb/rotate()//This could likely be better
	set name = "Rotate Infrared Laser"
	set category = "Object"
	set src in usr

	dir = turn(dir, 90)
	return

/***************************IBeam*********************************/

/obj/effect/beam/infrared
	name = "i beam"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "ibeam"
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags = 0


	var/obj/item/device/assembly/infra/assembly

/obj/effect/beam/infrared/proc/hit()
	if(assembly)
		assembly.trigger_beam()

/obj/effect/beam/infrared/Crossed(atom/movable/O)
	..(O)
	if(O && O.density && !istype(O, /obj/effect/beam))
		hit()

/obj/effect/beam/infrared/proc/set_visible(v)
	visible = v
	if(next)
		var/obj/effect/beam/infrared/B=next
		B.set_visible(v)

/obj/effect/beam/infrared/Bumped()
	hit()
	..()

/obj/effect/beam/infrared/spawn_child()
	var/obj/effect/beam/infrared/B = ..()
	if(!B)
		return null
	B.visible=visible
	return B

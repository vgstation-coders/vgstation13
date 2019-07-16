///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

#define CABLE_PINK "#CA00B6"
#define CABLE_ORANGE "#CA6900"


/obj/structure/cable
	level = LEVEL_BELOW_FLOOR
	anchored =1
	var/datum/powernet/powernet
	name = "power cable"
	desc = "A flexible superconducting cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond_white.dmi'
	icon_state = "0-1"
	var/d1 = 0								// cable direction 1 (see above)
	var/d2 = 1								// cable direction 2 (see above)
	plane = ABOVE_PLATING_PLANE
	layer = WIRE_LAYER
	var/obj/item/device/powersink/attached	// holding this here for qdel
	var/_color = "red"
	color = "red"

	//For rebuilding powernets from scratch
	var/build_status = 0 //1 means it needs rebuilding during the next tick or on usage
	var/oldavail = 0
	var/oldnewavail = 0
	var/oldload = 0

/obj/structure/cable/supports_holomap()
	return TRUE

/obj/structure/cable/yellow
	_color = "yellow"
	color = "yellow"

/obj/structure/cable/green
	_color = "green"
	color = "green"

/obj/structure/cable/blue
	_color = "blue"
	color = "blue"

/obj/structure/cable/pink
	_color = "pink"
	color = CABLE_PINK

/obj/structure/cable/orange
	_color = "orange"
	color = CABLE_ORANGE

/obj/structure/cable/cyan
	_color = "cyan"
	color = "cyan"

/obj/structure/cable/white
	_color = "white"
	color = "white"

// the power cable object
/obj/structure/cable/New(loc)
	..(loc)

	cableColor(_color)

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext(icon_state, 1, dash))
	d2 = text2num(copytext(icon_state, dash + 1))

	var/turf/T = src.loc	// hide if turf is not intact
	var/obj/structure/catwalk/Catwalk = (locate(/obj/structure/catwalk) in get_turf(T))
	if(!istype(T))
		if(!Catwalk)
			return //It's just space, abort
	if(level == LEVEL_BELOW_FLOOR)
		hide(T.intact)

	addNode(/datum/net_node/power/cable, d1, d2)

/obj/structure/cable/initialize()
	..()
	add_self_to_holomap()

/obj/structure/cable/Destroy()			// called when a cable is deleted
	if(istype(attached))
		attached.set_light(0)
		attached.icon_state = "powersink0"
		attached.mode = 0
		processing_objects.Remove(attached)
		attached.anchored = 0
		attached.attached = null

	attached = null
	..()								// then go ahead and delete the cable

/obj/structure/cable/forceMove(atom/destination, no_tp=0, harderforce = FALSE, glide_size_override = 0)
	.=..()

	var/datum/net_node/power/node = get_power_node()
	node.rebuild_connections()
	node.connections_changed()

/obj/structure/cable/shuttle_rotate(angle)
	if(d1)
		d1 = turn(d1, -angle)
	if(d2)
		d2 = turn(d2, -angle)

	if(d1 > d2) //Cable icon states start with the lesser number. For example, there's no "8-4" icon state, but there is a "4-8".
		var/oldD2 = d2
		d2 = d1
		d1 = oldD2

	update_icon()

///////////////////////////////////
// General procedures
///////////////////////////////////

// if underfloor, hide the cable
/obj/structure/cable/hide(i)
	if(level == LEVEL_BELOW_FLOOR && isturf(loc))
		invisibility = i ? 101 : 0

	update_icon()

/obj/structure/cable/update_icon()
	if(invisibility)
		icon_state = "[d1]-[d2]-f"
	else
		icon_state = "[d1]-[d2]"

/obj/structure/cable/t_scanner_expose()
	if (level != LEVEL_BELOW_FLOOR)
		return

	invisibility = 0
	plane = ABOVE_TURF_PLANE

	spawn(1 SECONDS)
		var/turf/U = loc
		if(istype(U) && U.intact)
			invisibility = 101
			plane = initial(plane)

// telekinesis has no effect on a cable
/obj/structure/cable/attack_tk(mob/user)
	return

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
/obj/structure/cable/attackby(obj/item/W, mob/user)
	var/turf/T = src.loc

	if(T.intact)
		return

	if(W.sharpness >= 1)
		if(shock(user, 50, W.siemens_coefficient))
			return
		cut(user, T)
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		coil.cable_join(src, user)
	else if(istype(W, /obj/item/weapon/rcl))
		var/obj/item/weapon/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty()
	else if(istype(W, /obj/item/device/multitool))
		if(avail() > 0)		// is it powered?
			to_chat(user, "<SPAN CLASS='warning'>Power network status report - Load: [format_watts(load())] - Available: [format_watts(avail())].</SPAN>")
		else
			to_chat(user, "<SPAN CLASS='notice'>The cable is not powered.</SPAN>")

		shock(user, 5, 0.2)
	else
		if(src.d1 && W.is_conductor()) // d1 determines if this is a cable end
			shock(user, 50, W.siemens_coefficient)

	src.add_fingerprint(user)

/obj/structure/cable/attack_animal(mob/M)
	if(isanimal(M))
		if(ismouse(M))
			var/mob/living/simple_animal/mouse/N = M
			M.delayNextAttack(10)
			M.visible_message("<span class='danger'>[M] bites \the [src]!</span>", "<span class='userdanger'>You bite \the [src]!</span>")
			flick(N.icon_eat, N)
			shock(M, 50)
			if(prob(5) && N.can_chew_wires)
				var/turf/T = src.loc
				cut(N, T)

/obj/structure/cable/bite_act(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] bites \the [src]!</span>", "<span class='userdanger'>You bite \the [src]!</span></span>")

	shock(H, 100, 2.0)

/obj/structure/cable/proc/cut(mob/user, var/turf/T)
	if(src.d1)	// 0-X cables are 1 unit, X-X cables are 2 units long
		getFromPool(/obj/item/stack/cable_coil, T, 2, light_color)
	else
		getFromPool(/obj/item/stack/cable_coil, T, 1, light_color)

	user.visible_message("<span class='warning'>[user] cuts the cable.</span>", "<span class='info'>You cut the cable.</span>")

	//investigate_log("was cut by [key_name(usr, usr.client)] in [user.loc.loc]","wires")

	var/message = "A wire has been cut "
	var/atom/A = user

	if(A)
		var/turf/Z = get_turf(A)
		var/area/my_area = get_area(Z)

		message += {"in [my_area.name]. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</A>) (<A HREF='?_src_=vars;Vars=\ref[A]'>VV</A>)"}

		var/mob/M = get_holder_of_type(A, /mob) //Why is this here? The use already IS a mob...

		if(M)
			message += " - Cut By: [M.real_name] ([M.key]) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"
			log_game("[M.real_name] ([M.key]) cut a wire in [my_area.name] ([T.x],[T.y],[T.z])")

	message_admins(message, 0, 1)

	returnToPool(src)

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1.0)
	if(avail() > 1000)
		if(!prob(prb))
			return 0

		if(electrocute_mob(user, get_powernet(), src, siemens_coeff))
			spark(src, 5)
			return 1

	return 0

// explosion handling
/obj/structure/cable/ex_act(severity)
	switch(severity)
		if(1.0)
			returnToPool(src)
		if(2.0)
			if(prob(50))
				getFromPool(/obj/item/stack/cable_coil,  src.loc, src.d1 ? 2 : 1, light_color)
				returnToPool(src)

		if(3.0)
			if(prob(25))
				getFromPool(/obj/item/stack/cable_coil, src.loc, src.d1 ? 2 : 1, light_color)
				returnToPool(src)
	return

/obj/structure/cable/proc/cableColor(var/colorC = "red")
	light_color = colorC
	switch(colorC)
		if("pink")
			color = CABLE_PINK
		if("orange")
			color = CABLE_ORANGE
		else
			color = colorC

/obj/structure/cable/proc/setDirs(dir1, dir2)
	var/datum/net_node/power/cable/node = C.getNode(/datum/net_node/power/cable)
	node.setDirs(dir1, dir2)
	if(dir1 > dir2)
		d1 = dir2
		d2 = dir1
	else
		d1 = dir1
		d2 = dir2
	update_icon()

////////////////////////////////////////////
// Power related
///////////////////////////////////////////
/obj/structure/cable/proc/add_avail(var/amount)
	var/datum/net_node/power/machinery/node = get_power_node()
	if(istype(node))
		node.powerNeeded += amount

/obj/structure/cable/proc/add_load(var/amount)
	var/datum/net_node/power/machinery/node = get_power_node()
	if(istype(node))
		node.powerNeeded -= amount

/obj/structure/cable/proc/surplus()
	var/datum/net/power/net = get_powernet()
	if(!istype(net))
		return 0
	
	return net.excess

/obj/structure/cable/proc/avail()
	var/datum/net/power/net = get_powernet()
	if(!istype(net))
		return 0
	
	return net.avail

/obj/structure/cable/proc/load()
	var/datum/net/power/net = get_powernet()
	if(!istype(net))
		return 0
	
	return net.load

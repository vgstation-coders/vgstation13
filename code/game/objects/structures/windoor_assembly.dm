/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add plasteel to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Screwdriver the door to complete
 */

/obj/structure/windoor_assembly
	name = "window door assembly"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "l_windoor_assembly01"
	anchored = FALSE
	density = FALSE
	dir = NORTH

	var/ini_dir
	var/obj/item/weapon/circuitboard/airlock/electronics = null
	var/windoor_type = /obj/machinery/door/window
	var/secure_type = /obj/machinery/door/window/brigdoor

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = FALSE	//Whether or not this creates a secure windoor
	var/reinforce_material = /obj/item/stack/sheet/plasteel
	var/wired = FALSE	//How hard was to make a fucking var to check this jesus christ old coders.
	var/glass_type = /obj/item/stack/sheet/glass/rglass

/obj/structure/windoor_assembly/proc/update_name()
	name = "[secure ? "secure ":""][anchored ? "anchored ":""][anchored && wired ? "and ":""][wired ? "wired ":""][initial(name)]"
	if(anchored && wired && electronics) //We're almost there bros
		name = "near finished [secure ? "secure ":""][initial(name)]"

/obj/structure/windoor_assembly/New(dir=NORTH)
	..()
	ini_dir = dir
	update_nearby_tiles()

obj/structure/windoor_assembly/Destroy()
	setDensity(FALSE)
	update_nearby_tiles()
	..()

/obj/structure/windoor_assembly/update_icon()
	icon_state = "[facing]_[secure ? "secure_":""]windoor_assembly[wired ? "02":"01"]"

/obj/structure/windoor_assembly/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover) && (mover.checkpass(PASSDOOR|PASSGLASS)))
		return TRUE
	if(get_dir(target, mover) == dir) //Make sure looking at appropriate border
		if(air_group)
			return FALSE
		return !density
	else
		return TRUE

/obj/structure/windoor_assembly/Uncross(atom/movable/mover, turf/target)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return TRUE
	if(flow_flags & ON_BORDER)
		if(target) //Are we doing a manual check to see
			if(get_dir(loc, target) == dir)
				return !density
		else if(mover.dir == dir) //Or are we using move code
			if(density)
				mover.to_bump(src)
			return !density
	return TRUE

/obj/structure/windoor_assembly/proc/make_windoor(var/mob/user)
	var/spawn_type = secure ? secure_type : windoor_type
	var/obj/machinery/door/window/windoor = new spawn_type(loc)
	windoor.dir = dir
	windoor.base_state = (facing == "l" ? "left" : "right")
	windoor.icon_state = windoor.base_state
	transfer_fingerprints_to(windoor)
	set_windoor_electronics(windoor)
	return windoor

/obj/structure/windoor_assembly/proc/set_windoor_electronics(var/obj/machinery/door/window/windoor)
	if(electronics)
		if(electronics.one_access)
			windoor.req_access = null
			windoor.req_one_access = electronics.conf_access
		else
			windoor.req_access = electronics.conf_access
		windoor.set_electronics()
		qdel(electronics)
		electronics = null


/obj/structure/windoor_assembly/attackby(obj/item/W, mob/user)
	if(iswelder(W) && (!anchored && !wired && !electronics))
		var/obj/item/weapon/weldingtool/WT = W
		user.visible_message("[user] dissassembles [src].", "You start to dissassemble [src].")
		if(WT.do_weld(user, src, 40, 0))
			if(gcDestroyed)
				return
			to_chat(user, "<span class='notice'>You dissasembled [src]!</span>")
			if(glass_type)
				getFromPool(glass_type,loc,5)
			if(secure)
				getFromPool(reinforce_material,loc,2)
			qdel(src)
		else
			to_chat(user, "<span class='rose'>You need more welding fuel to dissassemble [src].</span>")
			return

	//Adding plasteel makes the assembly a secure windoor assembly. Step 2 (optional) complete.
	if(reinforce_material && istype(W, reinforce_material) && (anchored && !secure))
		var/obj/item/stack/sheet/S = W
		if(S.amount < 2)
			to_chat(user, "<span class='rose'>You need more [W.name] to do this.</span>")
			return
		to_chat(user, "<span class='notice'>You start to reinforce [src] with [W.name].</span>")

		if(do_after(user, src,40))
			if(gcDestroyed)
				return
			if(S.use(2))
				to_chat(user, "<span class='notice'>You reinforced [src].</span>")
				secure = TRUE
				update_name()

	//Wrenching an un/secure assembly un/anchors it in place. Step 4 complete/undone
	if(iswrench(W))
		playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
		user.visible_message("[user] is [anchored ? "un":""]securing [src] [anchored ? "from" : "to"] the floor.", "You start to [anchored ? "un":""]secure [src] to the floor.")

		if(do_after(user, src, 40))
			if(gcDestroyed)
				return
			to_chat(user, "<span class='notice'>You've [anchored ? "un":""]secured [src]!</span>")
			anchored = !anchored
			update_name()

	//Adding cable to the assembly. Step 5 complete.
	if(istype(W, /obj/item/stack/cable_coil) && (anchored && !wired))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 2)
			to_chat(user, "<span class='rose'>You need more wire for this!</span>")
			return
		user.visible_message("[user] is wiring [src].", "You start to wire [src].")

		if(do_after(user, src, 40))
			if(gcDestroyed)
				return
			if(CC.use(2))
				to_chat(user, "<span class='notice'>You wired [src]!</span>")
				wired = TRUE
				update_name()

	//Removing wire from the assembly. Step 5 undone.
	if(iswirecutter(W) && (anchored && wired))
		playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
		user.visible_message("[user] is cutting the wires from [src].", "You start to cut the wires from [src].")

		if(do_after(user, src, 40))
			if(gcDestroyed)
				return
			to_chat(user, "<span class='notice'>You cut \the [name] wires!</span>")
			new /obj/item/stack/cable_coil(get_turf(user), 1)
			wired = FALSE
			update_name()


	//Adding airlock electronics for access. Step 6 complete.
	if(istype(W, /obj/item/weapon/circuitboard/airlock) && anchored)
		var/obj/item/weapon/circuitboard/airlock/AE = W
		if(AE.icon_state =="door_electronics_smoked")
			to_chat(user, "<span class='notice'>\The [AE.name] is too damaged to work.</span>")
			return

		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] installs [AE] into [src].", "You start to install [AE] into [src].")

		if(do_after(user, src, 40))
			if(gcDestroyed)
				return
			to_chat(user, "<span class='notice'>You've installed [AE]!</span>")
			electronics = AE
			electronics.installed = TRUE
			update_name()
			user.drop_item(AE, src, force_drop = 1)

	//Screwdriver to remove airlock electronics. Step 6 undone.
	if(W.is_screwdriver(user) && (anchored && electronics))
		playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
		user.visible_message("[user] removes the [electronics] from [src].", "You start to uninstall [electronics] from [src].")

		if(do_after(user, src, 40))
			if(gcDestroyed)
				return
			to_chat(user, "<span class='notice'>You've removed [electronics]!</span>")
			var/obj/item/weapon/circuitboard/airlock/ae
			ae = electronics
			ae.installed = FALSE
			electronics = null
			ae.forceMove(loc)
			update_name()


	//Crowbar to complete the assembly, Step 7 complete.
	if(iscrowbar(W) && anchored)
		if(!wired)
			to_chat(usr, "<span class='rose'>\The [name] is missing wires.</span>")
			return
		if(!electronics)
			to_chat(usr, "<span class='rose'>\The [name] is missing electronics.</span>")
			return
		usr << browse(null, "window=windoor_access")
		playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message("[user] is prying [src] into the frame.", "You start prying [src] into the frame.")

		if(do_after(user, src, 40))
			if(gcDestroyed)
				return
			var/obj/machinery/door/window/windoor = make_windoor()
			to_chat(user, "<span class='notice'>You finish the [windoor.name]!</span>")
			qdel(src)

	else
		..()

	//Update to reflect changes(if applicable)
	update_icon()

//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate window door assembly"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "It is fastened to the floor; therefore, you can't rotate it!")
		return FALSE
	dir = turn(dir, 270)
	update_nearby_tiles()
	ini_dir = dir
	update_icon()

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip window door assembly"
	set category = "Object"
	set src in oview(1)

	facing = facing == "l" ? "r":"l"
	to_chat(usr, "The windoor will now slide to the [facing == "l" ? "left":"right"].")
	update_icon()


/obj/structure/windoor_assembly/proc/update_nearby_tiles()
	if(!SS_READY(SSair))
		return FALSE
	var/T = loc
	if (isturf(T))
		SSair.mark_for_update(T)
	return TRUE

/obj/structure/windoor_assembly/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/structure/windoor_assembly/clockwork, BRASS_WINDOOR_GLOW)

/obj/structure/windoor_assembly/secure
	name = "secure window door assembly"
	secure = TRUE

/obj/structure/windoor_assembly/plasma
	name = "plasma window door assembly"
	icon = 'icons/obj/doors/plasmawindoor.dmi'
	windoor_type = /obj/machinery/door/window/plasma
	secure_type = /obj/machinery/door/window/plasma/secure
	glass_type = /obj/item/stack/sheet/glass/plasmarglass

/obj/structure/windoor_assembly/plasma/secure
	name = "secure plasma window door assembly"
	icon = 'icons/obj/doors/plasmawindoor.dmi'
	secure = TRUE

/obj/structure/windoor_assembly/clockwork
	name = "brass window door assembly"
	icon_state = "clockworkassembly"
	glass_type = /obj/item/stack/sheet/brass
	windoor_type = /obj/machinery/door/window/clockwork
	secure_type = null
	reinforce_material = null //We can't be reinforced.

/obj/structure/windoor_assembly/clockwork/update_icon()
	icon_state = "[initial(icon_state)][wired ? "02":"01"]"

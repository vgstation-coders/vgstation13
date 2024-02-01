/obj/item/weapon/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables."
	icon = 'icons/obj/power.dmi'
	icon_state = "rcl"
	item_state = "rcl-0"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/electronics.dmi', "right_hand" = 'icons/mob/in-hand/right/electronics.dmi')
	flags = FPRINT
	siemens_coefficient = 1 //Not quite as conductive as working with cables themselves
	force = 5.0 //Plastic is soft
	throwforce = 5.0
	throw_speed = 1
	throw_range = 10
	w_class = W_CLASS_MEDIUM
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_PLASTIC
	autoignition_temperature = AUTOIGNITION_PLASTIC
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_MATERIALS + "=4"

	var/max_amount = 90
	var/active = FALSE
	var/obj/item/stack/cable_coil/loaded = null
	var/placed_stub = FALSE

	var/turf/before
	var/turf/after


/obj/item/weapon/rcl/examine(mob/user)
	..()
	if(loaded)
		to_chat(user, "<span class='info'>It contains [loaded.amount]/[max_amount] cables.</span>")


/obj/item/weapon/rcl/Destroy()
	QDEL_NULL(loaded)
	active = FALSE
	set_move_event()
	..()

/obj/item/weapon/rcl/attackby(obj/item/weapon/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		if(!loaded)
			if(user.drop_item(W,src))
				add_cable(W,user)
		else
			add_cable(W,user)
	else if(W.is_screwdriver(user))
		if(!loaded)
			to_chat(user, "<span class='warning'>There are no wires to remove.</span>")
			return
		to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
		W.playtoolsound(src, 50)
		while(loaded.amount>30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
			var/diff = loaded.amount % 30
			if(diff)
				loaded.use(diff)
				new /obj/item/stack/cable_coil(user.loc, diff)
			else
				loaded.use(30)
				new /obj/item/stack/cable_coil(user.loc, 30)
		loaded.max_amount = initial(loaded.max_amount)
		loaded.forceMove(user.loc)
		user.put_in_hands(loaded)
		loaded = null
		update_icon()
	else
		..()

/obj/item/weapon/rcl/proc/add_cable(var/obj/item/stack/cable_coil/cable, var/mob/user)
	if (!loaded)
		loaded = cable
		loaded.max_amount = max_amount //We store a lot.
		loaded.forceMove(src)
	else if (loaded.amount >= max_amount)
		to_chat(user, "\The [src] cannot hold any further length of cable.")
		return FALSE
	else
		loaded.preattack(cable,user,1)
	update_icon()
	playsound(loc, 'sound/items/zip.ogg', 20, 1)
	to_chat(user, "<span class='notice'>You add the cables to the [src]. It now contains [loaded.amount].</span>")
	return TRUE

/obj/item/weapon/rcl/update_icon()
	overlays.len = 0
	if(!loaded)
		item_state = "rcl-0"
		dynamic_overlay.len = 0
		color = null
		if (ismob(loc))
			var/mob/M = loc
			M.update_inv_hands()
		return
	color = loaded.color
	var/amount = clamp(round(loaded.amount / (max_amount/12)) + 1, 1, 12)
	overlays += "rcl-[amount]"
	var/image/I = image(icon,src,"rcl-lights")
	I.appearance_flags = RESET_COLOR
	overlays += I
	if (active)
		overlays += "rcl-wire"
		item_state = "rcl-1"
	else
		item_state = "rcl"
	var/image/M = image(icon,src, "rcl-cover")
	M.appearance_flags = RESET_COLOR
	overlays += M
	if (ismob(loc))
		var/mob/O = loc
		O.update_inv_hands()

	//dynamic in-hand overlay
	var/image/rclleft = image(inhand_states["left_hand"], src, "rcl-cover")
	var/image/rclright = image(inhand_states["right_hand"], src, "rcl-cover")
	rclleft.appearance_flags = RESET_COLOR
	rclright.appearance_flags = RESET_COLOR
	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = rclleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = rclright


/obj/item/weapon/rcl/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag == 0) // not adjacent
		return
	if (isshelf(target))//placing on table, rack, closet, or in a backpack etc
		return
	if(!loaded || !loaded.amount)
		to_chat(user, "<span class='warning'>There isn't any cable left inside.</span>")
		return
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	placed_stub = FALSE
	if (connect_two_floors(user, T, U, TRUE))
		playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
		active = TRUE
		set_move_event(user)
		update_icon()

/obj/item/weapon/rcl/AltFrom(var/atom/A,var/mob/user, var/proximity_flag, var/click_parameters)//Returning null so we can also check tile content
	var/target_floor = get_turf(A)
	if(proximity_flag == 0) // not adjacent
		return
	for (var/obj/item/stack/cable_coil/cable in target_floor)
		if (!add_cable(cable,user))
			return
	to_chat(user, "<span class='warning'>No loose cables to collect on that tile.</span>")
	return


/obj/item/weapon/rcl/proc/connect_two_floors(var/mob/user, var/turf/first_floor, var/turf/second_floor, var/clicked = FALSE)
	if (!first_floor || !second_floor)
		return
	if(!first_floor.can_place_cables(TRUE) && !second_floor.can_place_cables(TRUE))
		if (user)
			to_chat(user, "<span class='warning'>You can't place cables between here and there.</span>")
			if (active)
				playsound(loc, 'sound/machines/click.ogg', 50, 1)
				active = FALSE
				set_move_event(user)
			update_icon()
		return

	var/used = max(connect_toward(user, second_floor, first_floor, clicked), connect_toward(user, first_floor, second_floor, clicked))

	if(loaded && !loaded.amount)
		to_chat(user, "<span class='warning'>The last of the cables unreel from \the [src].</span>")
		QDEL_NULL(loaded)
		active = FALSE

	if (used)
		playsound(loc, 'sound/items/crank.ogg', 10, 1)
	update_icon()

	return used

/obj/item/weapon/rcl/proc/connect_toward(var/mob/user, var/turf/start_floor, var/turf/target_floor, var/new_stubs = FALSE)
	if (!start_floor.can_place_cables(TRUE))
		return
	if(!loaded || !loaded.amount)
		return FALSE
	//first we search for a node on that tile
	var/target_dir = get_dir(start_floor, target_floor)
	var/obj/structure/cable/valid_node
	var/obj/structure/cable/wire_stub
	var/allow_stubs_unclicked = TRUE
	var/list/possible_nodes = list()
	var/list/full_wires = list()
	for (var/obj/structure/cable/C in start_floor)
		if (!C.d1)
			if (C.d2 == target_dir)
				//that node goes toward our target tile already.
				wire_stub = C
			else
				possible_nodes += C
		else
			full_wires += C
			if ((C.d1 == target_dir) || (C.d2 == target_dir))
				allow_stubs_unclicked = FALSE
	if (possible_nodes.len > 0)
		for (var/obj/structure/cable/C in possible_nodes)
			var/valid = TRUE
			for (var/obj/structure/cable/A in full_wires)
				if (((C.d2 == A.d1) && (target_dir == A.d2)) || ((C.d2 == A.d2) && (target_dir == A.d1)))
					//there's already a full wire that covers that path
					valid = FALSE
					break
			if (valid)
				//alright we got our valid node
				valid_node = C
				break

	if (valid_node)
		//we found a node that could come toward the other tile, let's do that and call it a day
		var/nd1 = valid_node.d2
		var/nd2 = target_dir

		if(nd1 > nd2)
			nd1 = target_dir
			nd2 = valid_node.d2

		valid_node.color = color

		valid_node.d1 = nd1
		valid_node.d2 = nd2

		valid_node.update_icon()

		valid_node.mergeConnectedNetworks(valid_node.d1) //Merge the powernets
		valid_node.mergeConnectedNetworks(valid_node.d2) //In the two new cable directions
		valid_node.mergeConnectedNetworksOnTurf()

		if(valid_node.d1 & (valid_node.d1 - 1)) //If the cable is layed diagonally, check the others 2 possible directions
			valid_node.mergeDiagonalsNetworks(valid_node.d1)

		if(valid_node.d2 & (valid_node.d2 - 1)) //If the cable is layed diagonally, check the others 2 possible directions
			valid_node.mergeDiagonalsNetworks(valid_node.d2)

		placed_stub = TRUE//we didn't place a stub but we did connect with one, so we don't want the other tile to make a stub toward us if they already have a full wire toward us

		loaded.use(1)
		return TRUE

	else if (!wire_stub && (allow_stubs_unclicked || new_stubs))
		//else let's add a new stub if we clicked (but only one per click, not two, and in priority on the tile we clicked at)
		if (placed_stub && !allow_stubs_unclicked)
			return FALSE
		placed_stub = TRUE
		var/obj/structure/cable/C = new /obj/structure/cable(start_floor)
		C.color = color
		C.d1 = 0 //It's a O-X node cable
		C.d2 = target_dir
		C.update_icon()

		var/datum/powernet/PN = new /datum/powernet
		PN.add_cable(C)


		C.mergeConnectedNetworks(C.d2)   //Merge the powernet with adjacents powernets
		C.mergeConnectedNetworksOnTurf() //Merge the powernet with on turf powernets

		if(C.d2 & (C.d2 - 1)) //If the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		loaded.use(1)
		return TRUE
	return FALSE

/obj/item/weapon/rcl/attack_self(var/mob/user)
	active = !active
	if (active)
		playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
	else
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You turn \the [src] [active ? "on" : "off"].<span>")
	set_move_event(user)
	update_icon()

/obj/item/weapon/rcl/pickup(var/mob/user)
	..()
	if(active)
		user.register_event(/event/before_move, src, /obj/item/weapon/rcl/proc/turf_before)
		user.register_event(/event/after_move, src, /obj/item/weapon/rcl/proc/turf_after)

/obj/item/weapon/rcl/dropped(var/mob/user)
	..()
	user.unregister_event(/event/before_move, src, /obj/item/weapon/rcl/proc/turf_before)
	user.unregister_event(/event/after_move, src, /obj/item/weapon/rcl/proc/turf_after)

/obj/item/weapon/rcl/proc/set_move_event(mob/user)
	if(user)
		if(active)
			user.register_event(/event/before_move, src, /obj/item/weapon/rcl/proc/turf_before)
			user.register_event(/event/after_move, src, /obj/item/weapon/rcl/proc/turf_after)
			return
		user.unregister_event(/event/before_move, src, /obj/item/weapon/rcl/proc/turf_before)
		user.unregister_event(/event/after_move, src, /obj/item/weapon/rcl/proc/turf_after)

/obj/item/weapon/rcl/proc/turf_before()
	before = get_turf(src)

/obj/item/weapon/rcl/proc/turf_after()
	after = get_turf(src)
	if (before && (before != after))
		if (before.Adjacent(after))
			var/mob/M = null
			if (ismob(loc))
				M = loc
			connect_two_floors(M, before, after)
			before = null
			after = null

//-----------------------------------------------------------------------------------------

/obj/item/weapon/rcl/pre_loaded
	var/cable_type = /obj/item/stack/cable_coil

/obj/item/weapon/rcl/pre_loaded/New() //Comes preloaded with cable, for testing stuff
	..()
	loaded = new cable_type()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon()

/obj/item/weapon/rcl/pre_loaded/yellow
	cable_type = /obj/item/stack/cable_coil/yellow

/obj/item/weapon/rcl/pre_loaded/blue
	cable_type = /obj/item/stack/cable_coil/blue

/obj/item/weapon/rcl/pre_loaded/green
	cable_type = /obj/item/stack/cable_coil/green

/obj/item/weapon/rcl/pre_loaded/pink
	cable_type = /obj/item/stack/cable_coil/pink

/obj/item/weapon/rcl/pre_loaded/orange
	cable_type = /obj/item/stack/cable_coil/orange

/obj/item/weapon/rcl/pre_loaded/cyan
	cable_type = /obj/item/stack/cable_coil/cyan

/obj/item/weapon/rcl/pre_loaded/white
	cable_type = /obj/item/stack/cable_coil/white

/obj/item/weapon/rcl/pre_loaded/random
	cable_type = /obj/item/stack/cable_coil/random

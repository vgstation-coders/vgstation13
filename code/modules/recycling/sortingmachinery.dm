//Default list destination taggers and such can use.

/obj/item/device/destTagger
	name = "destination tagger"
	desc = "Used to set the destination of properly wrapped packages."
	icon_state = "dest_tagger"
	starting_materials = list(MAT_IRON = 300)
	w_type = RECYK_METAL

	var/panel = 0 //If the panel is open.
	var/mode  = 0 //If the tagger is "hacked" so you can add extra tags.

	var/currTag = 0
	var/list/destinations  = list()

	w_class = W_CLASS_TINY
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT

/obj/item/device/destTagger/panel
	panel = 1

/obj/item/device/destTagger/panel/New()
	. = ..()
	update_icon()

/obj/item/device/destTagger/New()
	. = ..()

	// Make sure to not copy any null ones, null is for map overrides to remove.
	for(var/dest in map.default_tagger_locations)
		if(dest)
			destinations += dest

/obj/item/device/destTagger/interact(mob/user as mob)

	var/dat = "<table style='width:100%; padding:4px;'><tr>"

	for (var/i = 1, i <= destinations.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[destinations[i]]</a>[mode ? "<a href='?src=\ref[src];remove_dest=[i]' class='linkDanger'>\[X\]</a>" : ""]</td>"

		if (i % 4 == 0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? destinations[currTag] : "None"].<hr><br>"

	if(mode)
		dat += "<a href='?src=\ref[src];new_dest=1'>Add destination</a>"

	var/datum/browser/popup = new(user, "destTagger", name, 380, 350, src)
	popup.add_stylesheet("shared", 'nano/css/shared.css')
	popup.set_content(dat)
	popup.open()

/obj/item/device/destTagger/attack_self(mob/user as mob)
	interact(user)

/obj/item/device/destTagger/attackby(obj/item/W, mob/user)
	if(W.is_screwdriver(user))
		panel = !panel
		to_chat(user, "<span class='notify'>You [panel ? "open" : "close"] the panel on \the [src].</span>")
		W.playtoolsound(src, 50)
		update_icon()
		return 1

	if(W.is_multitool(user) && panel)
		mode = !mode
		to_chat(user, "<span class='notify'>You [mode ? "disable" : "enable"] the lock on \the [src].</span>")
		return 1

	. = ..()

/obj/item/device/destTagger/update_icon()
	if(panel)
		icon_state = "dest_tagger_p"
		desc += "\nThe panel appears to be open."
	else
		icon_state = "dest_tagger"
		desc = initial(desc)

/obj/item/device/destTagger/Topic(href, href_list)
	. = ..()
	if(.)
		return

	add_fingerprint(usr)

	if(href_list["nextTag"])
		currTag = clamp(text2num(href_list["nextTag"]), 0, destinations.len)
		interact(usr)
		return 1

	if(href_list["remove_dest"] && mode)
		var/idx = clamp(text2num(href_list["remove_dest"]), 1, destinations.len)
		if(currTag == destinations[idx])
			currTag = 0 // In case the index was at the end of the list
		destinations -= destinations[idx]
		interact(usr)
		return 1

	if(href_list["new_dest"] && mode)
		var/newtag = uppertext(copytext(sanitize(input(usr, "Destination ID?","Add Destination") as text), 1, MAX_NAME_LEN))
		destinations |= newtag
		interact(usr)
		return 1

/obj/item/device/destTagger/cyborg
	name = "cyborg destination tagger"
	mode = TRUE

/obj/machinery/disposal/deliveryChute
	name = "Delivery chute"
	desc = "A chute for big and small packages alike!"
	density = 1
	icon_state = "intake"
	plane = ABOVE_HUMAN_PLANE
	layer = DISPOSALS_CHUTE_LAYER
	var/c_mode = 0
	var/doFlushIn=0
	var/num_contents=0

/obj/machinery/disposal/deliveryChute/no_deconstruct
	deconstructable = FALSE

/obj/machinery/disposal/deliveryChute/New()
	..()
	processing_objects.Remove(src)
	spawn(5)
		trunk = locate() in src.loc
		if(trunk)
			trunk.linked = src	// link the pipe trunk to self

/obj/machinery/disposal/deliveryChute/ui_interact()
	return

/obj/machinery/disposal/deliveryChute/update_icon()
	return

/obj/machinery/disposal/deliveryChute/Bumped(var/atom/movable/AM) //Go straight into the chute
	if(AM.anchored)
		return

	if(istype(AM, /obj/item/projectile) || istype(AM, /obj/item/weapon/dummy))
		return

	if(dir != get_dir(src, AM))
		return

	//testing("[src] FUCKING BUMPED BY \a [AM]")

	if(istype(AM, /obj))
		receive_atom(AM)
	else if(istype(AM, /mob))
		receive_atom(AM)


/obj/machinery/disposal/deliveryChute/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(istype(AM,/obj/item))
		if(stat & BROKEN || !AM || mode <=0 || !deconstructable)
			return FALSE
		receive_atom(AM)
		return TRUE
	return FALSE


/obj/machinery/disposal/deliveryChute/proc/receive_atom(var/atom/movable/AM)
	AM.forceMove(src.loc) // To make it look like it's moving into it better
	spawn(1)
		AM.forceMove(src)
		doFlushIn = 5
		num_contents++


/obj/machinery/disposal/deliveryChute/flush()
	flushing = 1
	flick("intake-closing", src)
	var/deliveryCheck = 0
	var/obj/structure/disposalholder/H = new()	// virtual holder object which actually
												// travels through the pipes.
	for(var/obj/item/delivery/large/O in src)
		deliveryCheck = 1
		if(O.sortTag == 0)
			O.sortTag = "DISPOSALS"
	for(var/obj/item/delivery/O in src)
		deliveryCheck = 1
		if (O.sortTag == 0)
			O.sortTag = "DISPOSALS"
	if(deliveryCheck == 0)
		H.destinationTag = "DISPOSALS"

	air_contents = new()		// new empty gas resv.

	sleep(10)
	playsound(src, 'sound/machines/disposalflush.ogg', 50, 0, 0)
	sleep(5) // wait for animation to finish

	H.init(src)	// copy the contents of disposer to holder
	num_contents=0
	doFlushIn=0

	H.start(src) // start the holder processing movement
	flushing = 0
	// now reset disposal state
	flush = 0
	if(mode == 2)	// if was ready,
		mode = 1	// switch to charging
	update_icon()
	return

/obj/machinery/disposal/deliveryChute/attackby(var/obj/item/I, var/mob/user)
	if(!I || !user)
		return

	if(I.is_screwdriver(user))
		if(c_mode==0)
			c_mode=1
			I.playtoolsound(src, 50)
			to_chat(user, "You remove the screws around the power connection.")
			return
		else if(c_mode==1)
			c_mode=0
			I.playtoolsound(src, 50)
			to_chat(user, "You attach the screws around the power connection.")
			return
	else if(iswelder(I) && c_mode==1)
		var/obj/item/tool/weldingtool/W = I
		to_chat(user, "You start slicing the floorweld off the delivery chute.")
		if(W.do_weld(user, src,20, 0))
			if(gcDestroyed)
				return
			to_chat(user, "You sliced the floorweld off the delivery chute.")
			var/obj/structure/disposalconstruct/C = new (src.loc)
			C.ptype = 8 // 8 =  Delivery chute
			C.update()
			C.anchored = 1
			C.setDensity(TRUE)
			qdel(src)



/obj/machinery/disposal/deliveryChute/process()
	if(doFlushIn>0)
		if(doFlushIn==1 || num_contents>=50)
			//testing("[src] FLUSHING")
			spawn(0)
				src.flush()
		doFlushIn--

//Base framework for sorting machines.
/obj/machinery/sorting_machine
	name = "Sorting Machine"
	desc = "Sorts stuff."
	density = 1
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-b1"
	anchored = 1

	machine_flags = SCREWTOGGLE | CROWDESTROY | MULTITOOL_MENU

	idle_power_usage = 100 //No active power usage because this thing passively uses 100, always. Don't ask me why N3X15 coded it like this.

	var/atom/movable/mover //Virtual atom used to check passing ability on the out turf.

	output_dir = WEST
	var/input_dir = EAST
	var/filter_dir = SOUTH

	var/max_items_moved = 100

/obj/machinery/sorting_machine/New()
	. = ..()

	mover = new

/obj/machinery/sorting_machine/Destroy()
	. = ..()

	QDEL_NULL(mover)

/obj/machinery/sorting_machine/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/bin in component_parts)
		T += bin.rating//intentionally not doing '- 1' here, for the math below
	max_items_moved = initial(max_items_moved) * (T / 3) //Usefull upgrade/10, that's an increase from 10 (base matter bins) to 30 (super matter bins)

	T = 0//reusing T here because muh RAM
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating - 1
	idle_power_usage = initial(idle_power_usage) - (T * (initial(idle_power_usage) / 4))//25% power usage reduction for an advanced capacitor, 50% for a super one.

/obj/machinery/sorting_machine/process()
	if(stat & (BROKEN | NOPOWER | FORCEDISABLE))
		return

	var/turf/in_T = get_step(src, input_dir)
	var/turf/out_T = get_step(src, output_dir)
	var/turf/filter_T = get_step(src, filter_dir)

	if(!out_T.Enter(mover, mover.loc, TRUE) || !filter_T.Enter(mover, mover.loc, TRUE))
		return

	var/affecting = in_T.contents
	var/items_moved = 0

	for(var/atom/movable/A in affecting)
		if(items_moved >= max_items_moved)
			break

		if(A.anchored)
			continue

		if(sort(A))
			A.forceMove(filter_T)
		else
			A.forceMove(out_T)

		items_moved++

/obj/machinery/sorting_machine/attack_hand(mob/user)
	interact(user)

/obj/machinery/sorting_machine/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1

	src.add_fingerprint(usr)//After close, else it wouldn't make sense.

/obj/machinery/sorting_machine/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li><b>Sorting directions:</b></li>
			<li><b>Input: </b><a href='?src=\ref[src];changedir=1'>[capitalize(dir2text(input_dir))]</a></li>
			<li><b>Output: </b><a href='?src=\ref[src];changedir=2'>[capitalize(dir2text(output_dir))]</a></li>
			<li><b>Selected: </b><a href='?src=\ref[src];changedir=3'>[capitalize(dir2text(filter_dir))]</a></li>
		</ul>
	"}

//Handles changing of the IO dirs, 'ID's: 1 is input, 2 is output, and 3 is filter, in this proc.

/obj/machinery/sorting_machine/multitool_topic(var/mob/user, var/list/href_list, var/obj/item/device/multitool/P)
	. = ..()
	if(.)
		return .

	if("changedir" in href_list)
		var/changingdir = text2num(href_list["changedir"])
		changingdir = clamp(changingdir, 1, 3)//No runtimes from HREF exploits.

		var/newdir = input("Select the new direction", "MinerX SortMaster 5000", "North") as null|anything in list("North", "South", "East", "West")
		if(!newdir)
			return 1
		newdir = text2dir(newdir)

		var/list/dirlist = list(input_dir, output_dir, filter_dir)//Behold the idea I got on how to do this.
		var/olddir = dirlist[changingdir]//Store this for future reference before wiping it next line
		dirlist[changingdir] = -1//Make the dir that's being changed -1 so it doesn't see itself.

		var/conflictingdir = dirlist.Find(newdir)//Check if the dir is conflicting with another one
		if(conflictingdir)//Welp, it is.
			dirlist[conflictingdir] = olddir//Set it to the olddir of the dir we're changing

		dirlist[changingdir] = newdir//Set the changindir to the selected dir

		input_dir = dirlist[1]
		output_dir = dirlist[2]
		filter_dir = dirlist[3]

		return MT_UPDATE
		//Honestly I didn't expect that to fit in, what, 10 lines of code?

//Return 1 if the atom is to be filtered off the line.
/obj/machinery/sorting_machine/proc/sort(var/atom/movable/A)
	return prob(50) //Henk because the base sorting machine shouldn't ever exist anyways.

//RECYCLING SORTING MACHINE.
//AKA the old sorting machine until I decided to use the sorting machines in an OOP way for BELT HELL!
/obj/machinery/sorting_machine/recycling
	name = "Recycling Sorting Machine"

	var/list/selected_types = list("Glasses", "Metals/Minerals", "Electronics", "Plastic", "Fabric")
	var/list/types[8]

/obj/machinery/sorting_machine/recycling/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/sorting_machine/recycling,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

	// Set up types. BYOND is the dumb and won't let me do this in the var def.
	types[RECYK_BIOLOGICAL] = "Biological"
	types[RECYK_WOOD]		= "Wooden"
	types[RECYK_ELECTRONIC] = "Electronics"
	types[RECYK_GLASS]      = "Glasses"
	types[RECYK_METAL]      = "Metals/Minerals"
	types[RECYK_PLASTIC]    = "Plastic"
	types[RECYK_FABRIC]     = "Fabric"
	types[RECYK_MISC]       = "Miscellaneous"

/obj/machinery/sorting_machine/recycling/process()
	//Before sorting, we'll try and open any box and crate we find
	if(stat & (BROKEN | NOPOWER))
		return

	var/turf/in_T = get_step(src, input_dir)
	var/items_moved = 0

	//Open any closets/crates
	for(var/obj/structure/closet/C in in_T.contents)
		//Only open a limited number of closets
		if(items_moved >= max_items_moved)
			break

		if(C.open())
			C.dump_contents()
			items_moved++

	//Open any storage items (including those that were in closets/cages)
	for(var/obj/item/weapon/storage/S in in_T.contents)
		//Only open a limited number of boxes
		if(items_moved >= max_items_moved)
			break

		if(S.contents.len > 0)
			var/S_old_contents = S.contents.len
			S.mass_remove(in_T)

			//If you just can't empty it out, treat it as normal rubbish
			if(S.contents.len < S_old_contents)
				items_moved++

	//We can't start sorting items until we've made sure we've emptied every box and closet
	if(items_moved == 0)
		..()

/obj/machinery/sorting_machine/recycling/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["toggle_types"])
		var/typeID = text2num(href_list["toggle_types"])

		typeID = clamp(typeID, 1, types.len)//No HREF exploits causing runtimes.

		if(types[typeID] in selected_types)//Toggle these
			selected_types -= types[typeID]
		else
			selected_types += types[typeID]

		updateUsrDialog()
		return 1

/obj/machinery/sorting_machine/recycling/sort(atom/movable/A)
	// A closet or crate that can't be opened can't be recycled, regardless of recycle type and selected types
	if (istype(A, /obj/structure/closet))
		var/obj/structure/closet/C = A
		if (!C.can_open())
			return FALSE

	// Check atom recycle type is in selected types
	return A.w_type && (types[A.w_type] in selected_types)

/obj/machinery/sorting_machine/recycling/interact(mob/user)
	if(stat & (BROKEN | NOPOWER | FORCEDISABLE))
		if(user.machine == src)
			usr.unset_machine()
		return

	user.set_machine(src)

	var/dat = "Select the desired items to sort from the line.<br>"

	for (var/i = 1, i <= types.len, i++)
		var/selected = (types[i] in selected_types)
		var/cssclass = selected ? "linkOn" : "linkDanger"//Fancy coloured buttons

		dat += "<a href='?src=\ref[src];toggle_types=[i]' class='[cssclass]'>[types[i]]</a><br>"

	var/datum/browser/popup = new(user, "recycksortingmachine", name, 320, 200, src)
	popup.add_stylesheet("shared", 'nano/css/shared.css')
	popup.set_content(dat)
	popup.open()

//Essentially a standalone version of disposals sorting pipes.
/obj/machinery/sorting_machine/destination
	name = "Destination Sorting Machine"
	desc = "Like those disposals pipes sorting machines, except not in a pipe."

	var/list/destinations
	var/list/sorting[0]
	var/unwrapped = 0 //Whatever unwrapped packages should be picked from the line.

/obj/machinery/sorting_machine/destination/New()
	. = ..()

	destinations = map.default_tagger_locations.Copy() //Here because BYOND.

	for(var/i = 1, i <= destinations.len, i++)
		destinations[i] = uppertext(destinations[i])

	component_parts = newlist(
		/obj/item/weapon/circuitboard/sorting_machine/destination,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/sorting_machine/destination/interact(mob/user)
	if(stat & (BROKEN | NOPOWER | FORCEDISABLE))
		if(user.machine == src)
			usr.unset_machine()
		return

	user.set_machine(src)

	var/dat = "Select the desired items to sort from the line.<br>"

	for (var/i = 1, i <= destinations.len, i++)
		var/selected = (destinations[i] in sorting)
		var/cssclass = selected ? "linkOn" : "linkDanger" //Fancy coloured buttons

		dat += "<a href='?src=\ref[src];toggle_dest=[i]' class='[cssclass]'>[destinations[i]]</a> <a href='?src=\ref[src];remove_dest=[i]' class='linkDanger'>\[X\]</a><br>"

	dat += "<a href='?src=\ref[src];add_dest=1'>Add a new destination</a> <hr><br>"

	dat += "<a href='?src=\ref[src];toggle_wrapped=1' class='[unwrapped ? "linkOn" : "LinkDanger"]'>Filter unwrapped packages</a>"

	var/datum/browser/popup = new(user, "destsortingmachine", name, 320, 200, src)
	popup.add_stylesheet("shared", 'nano/css/shared.css')
	popup.set_content(dat)
	popup.open()

/obj/machinery/sorting_machine/destination/sort(atom/movable/A)
	if(istype(A, /obj/item/delivery/large))
		var/obj/item/delivery/large/B = A
		return B.sortTag in sorting

	if(istype(A, /obj/item/delivery))
		var/obj/item/delivery/B = A
		return B.sortTag in sorting

	return unwrapped

/obj/machinery/sorting_machine/destination/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["toggle_dest"])
		var/idx = clamp(text2num(href_list["toggle_dest"]), 0, destinations.len)
		if(destinations[idx] in sorting)
			sorting -= destinations[idx]
		else
			sorting += destinations[idx]
		updateUsrDialog()
		return 1

	if(href_list["remove_dest"])
		var/idx = clamp(text2num(href_list["remove_dest"]), 0, destinations.len)
		sorting -= destinations[idx]
		destinations -= destinations[idx]
		updateUsrDialog()
		return 1

	if(href_list["add_dest"])
		var/newtag = uppertext(copytext(sanitize(input(usr, "Destination ID?","Add Destination") as text), 1, MAX_NAME_LEN))
		destinations |= newtag
		updateUsrDialog()
		return 1

	if(href_list["toggle_wrapped"])
		unwrapped = !unwrapped
		updateUsrDialog()
		return 1

/obj/machinery/sorting_machine/destination/unwrapped
	unwrapped = 1


//Same as above but filtering by item.
/obj/machinery/sorting_machine/item
	name = "Item Sorting Machine"
	desc = "Sort specific items off a conveyor belt."
	var/obj/item/sort_item = null

/obj/machinery/sorting_machine/item/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/sorting_machine/item,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/sorting_machine/item/attackby(var/obj/item/O, mob/user)
	. = ..()
	if(.)
		return .
	else
		sort_item = O
		to_chat(user, "<span class='notice'>Filtering item set to [O].</span>")

/obj/machinery/sorting_machine/item/sort(atom/movable/A)
	if(istype(A,sort_item))
		return(1)

//Machines for working with crates prior to shipping
/obj/machinery/logistics_machine
	layer = ABOVE_TILE_LAYER
	plane = ABOVE_TURF_PLANE
	anchored = 1
	density = 0
	use_power = 1
	idle_power_usage = 0
	active_power_usage = 50
	power_channel = EQUIP
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE
	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0
	var/next_sound = 0
	var/sound_delay = 20

/obj/machinery/logistics_machine/crate_opener
	name = "crate opener"
	desc = "Magnetically opens crates provided the proper access has been swiped on the machine."
	icon = 'icons/obj/machines/logistics.dmi'
	icon_state = "inactive"
	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | EMAGGABLE
	var/list/access = list()

/obj/machinery/logistics_machine/crate_opener/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/crate_opener,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
	)

	RefreshParts()

/obj/machinery/logistics_machine/crate_opener/attackby(var/obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		playsound(src, get_sfx("card_swipe"), 60, 1, -5)
		for(var/mob/M in hearers(src))
			M.show_message("<b>[src]</b> announces, \"Successfully copied access from \the [I].\"")
		access |= I.access
	else
		return ..()

/obj/machinery/logistics_machine/crate_opener/Crossed(atom/movable/A)
	if(istype(A,/obj/structure/closet/crate))
		icon_state = "active"
		if(istype(A,/obj/structure/closet/crate/secure))
			var/obj/structure/closet/crate/secure/S = A
			if(!src.emagged)
				if(!S.togglelock(src))
					if (world.time > next_sound)
						playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
						next_sound = world.time + sound_delay
				else
					S.open()
			else
				S.overlays.len = 0
				S.overlays += S.emag
				S.overlays += S.sparks
				spawn(6) S.overlays -= S.sparks //Tried lots of stuff but nothing works right. so i have to use this *sadface*
				playsound(S, "sparks", 60, 1)
				S.locked = 0
				S.broken = 1
				S.open()
		else
			var/obj/structure/closet/crate/C = A
			if(!C.opened)
				C.open()

/obj/machinery/logistics_machine/crate_opener/Uncrossed(atom/movable/A)
	if(istype(A,/obj/structure/closet/crate))
		icon_state = "inactive"

/obj/machinery/logistics_machine/crate_opener/emag_act(var/mob/user, var/obj/item/weapon/card/emag/E)
	if(!src.emagged)
		spark(src, 1)
		src.emagged = 1
		if(user)
			to_chat(user, "<span class = 'warning'>You overload the ID scanner on [src].</span>")
		return 1
	return 0

/obj/item/weapon/circuitboard/crate_opener
	name = "Circuit Board (Crate Opener)"
	desc = "A circuit board used to run a crate opening machine."
	build_path = /obj/machinery/logistics_machine/crate_opener
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_MAGNETS + "=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
						)

/obj/machinery/logistics_machine/crate_closer
	name = "crate closer"
	desc = "Magnetically closes crates."
	icon = 'icons/obj/machines/logistics.dmi'
	icon_state = "inactive"
	var/list/access = list()

/obj/machinery/logistics_machine/crate_closer/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/crate_closer,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator,
	)

	RefreshParts()

/obj/machinery/logistics_machine/crate_closer/Crossed(atom/movable/A)
	if(istype(A,/obj/structure/closet/crate))
		icon_state = "active"
		var/obj/structure/closet/crate/C = A
		if(C.opened)
			sleep(2) //allows stuff in crates to move to the same tile
			C.close()

/obj/machinery/logistics_machine/crate_closer/Uncrossed(atom/movable/A)
	if(istype(A,/obj/structure/closet/crate))
		icon_state = "inactive"

/obj/item/weapon/circuitboard/crate_closer
	name = "Circuit Board (Crate Closer)"
	desc = "A circuit board used to run a crate closing machine."
	build_path = /obj/machinery/logistics_machine/crate_closer
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_MAGNETS + "=2"
	req_components = list(
							/obj/item/weapon/stock_parts/manipulator = 2,
						)

/obj/machinery/autoprocessor
	name = "autoprocessor"
	desc = "Automatically processes things."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "wrapper-4"
	density = 1
	anchored = 1
	idle_power_usage = 100 //No active power usage because this thing passively uses 100, always. Don't ask me why N3X15 coded it like this.
	plane = ABOVE_HUMAN_PLANE
	var/circuitpath = /obj/item/weapon/circuitboard/autoprocessor

	var/atom/movable/mover //Virtual atom used to check passing ability on the out turf.

	var/next_sound = 0
	var/sound_delay = 20

	output_dir = 8 //WEST
	var/input_dir = 4 //EAST

	var/max_items_moved = 100

/obj/machinery/autoprocessor/New()
	. = ..()
	component_parts = newlist(
		circuitpath,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/capacitor
	)
	mover = new

/obj/machinery/autoprocessor/Destroy()
	. = ..()

	QDEL_NULL(mover)

/obj/machinery/autoprocessor/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/bin in component_parts)
		T += bin.rating//intentionally not doing '- 1' here, for the math below
	max_items_moved = initial(max_items_moved) * (T / 3) //Usefull upgrade/10, that's an increase from 10 (base matter bins) to 30 (super matter bins)

	T = 0//reusing T here because muh RAM
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		T += C.rating - 1
	idle_power_usage = initial(idle_power_usage) - (T * (initial(idle_power_usage) / 4))//25% power usage reduction for an advanced capacitor, 50% for a super one.

/obj/machinery/autoprocessor/process()
	if(stat & (BROKEN | NOPOWER | FORCEDISABLE))
		return
	if(!isturf(loc)) //If it's inside a flatpack, for instance
		return

	var/turf/in_T = get_step(src, input_dir)
	var/turf/out_T = get_step(src, output_dir)

	if(!out_T.Enter(mover, mover.loc, TRUE))
		return

	var/affecting = in_T.contents
	var/items_moved = 0

	for(var/atom/movable/A in affecting)

		if(items_moved >= max_items_moved)
			break

		if(A.anchored)
			continue

		A.forceMove(get_turf(src))
		if(process_affecting(A))
			items_moved++
			return
		A.forceMove(out_T)

/obj/machinery/autoprocessor/proc/process_affecting(var/atom/movable/target)
	return

/obj/machinery/autoprocessor/attackby(var/obj/item/O, mob/user)
	. = ..()
	if(O.is_multitool(user))
		setOutput(user)

/obj/machinery/autoprocessor/proc/setOutput(user)
	if(alert(user,"Set your location as output?","Output selection","Yes","No") == "Yes")
		if(!Adjacent(user))
			to_chat(user, "<span class='warning'>Cannot set this as the output location; You're not adjacent to it!</span>")
			return 1
		output_dir = get_dir(src, user)
		input_dir = opposite_dirs[output_dir]
		if(!cardinal.Find(output_dir))
			to_chat(user, "<span class='warning'>Cannot set this as the output location; cardinal directions only!</span>")
			return 1
		icon_state = "wrapper-[input_dir]"
		update_icon()
		to_chat(user, "<span class='notice'>Output set.</span>")
		return 1

/obj/machinery/autoprocessor/wrapping
	name = "wrapping machine"
	desc = "Wraps and tags items."
	machine_flags = SCREWTOGGLE | CROWDESTROY
	idle_power_usage = 100 //No active power usage because this thing passively uses 100, always. Don't ask me why N3X15 coded it like this.
	circuitpath = /obj/item/weapon/circuitboard/autoprocessor/wrapping

	var/packagewrap = 0
	var/syndiewrap = 0

	var/mode  = 0 //If the tagger is "hacked" so you can add extra tags.

	var/currTag = 0
	var/list/destinations  = list()

	var/smallpath = /obj/item/delivery //We use this for items
	var/bigpath = /obj/item/delivery/large //We use this for structures (crates, closets, recharge packs, etc.)
	var/manpath = /obj/item/delivery/large //We use this for people.
	var/list/cannot_wrap = list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/item/delivery,
		/obj/item/weapon/gift,
		/obj/item/weapon/winter_gift,
		/obj/item/weapon/storage/evidencebag,
		/obj/item/weapon/storage/backpack/holding,
		/obj/item/weapon/legcuffs/bolas,
		/mob/living/simple_animal/hostile/mimic/crate/item
		)

	var/list/wrappable_big_stuff = list(
		/mob/living/simple_animal/hostile/mimic/crate,
		/obj/structure/closet,
		/obj/structure/vendomatpack,
		/obj/structure/stackopacks
		)

/obj/machinery/autoprocessor/wrapping/New()
	. = ..()

	for(var/dest in map.default_tagger_locations)
		if(dest)
			destinations += dest

/obj/machinery/autoprocessor/wrapping/process_affecting(var/atom/movable/target)
	if(is_type_in_list(target, cannot_wrap))
		return 0
	if(istype(target, /obj/item) && smallpath)
		if (packagewrap >= 1)
			var/obj/item/I = target
			var/obj/item/P = new smallpath(get_step(src, output_dir),target,round(I.w_class))
			target.forceMove(P)
			packagewrap += -1
			if(syndiewrap)
				syndiewrap += -1
			tag_item(P)
			return 1
		else
			if(world.time > next_sound)
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
				next_sound = world.time + sound_delay
				for(var/mob/M in hearers(src))
					M.show_message("<b>[src]</b> announces, \"Please insert additional sheets of package wrap into \the [src].\"")
			return 0
	else if(is_type_in_list(target,wrappable_big_stuff) && bigpath)
		if(istype(target,/obj/structure/closet))
			var/obj/structure/closet/C = target
			if(C.opened)
				return 0
		if(istype(target, /mob/living/simple_animal/hostile/mimic/crate))
			var/mob/living/simple_animal/hostile/mimic/crate/MC = target
			if(MC.angry)
				return 0
		if(packagewrap >= 3)
			var/obj/item/P = new bigpath(get_step(src, output_dir),target)
			target.forceMove(P)
			packagewrap += -3
			if(syndiewrap)
				syndiewrap += -3
			tag_item(P)
			return 1
		else
			if(world.time > next_sound)
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
				next_sound = world.time + sound_delay
				for(var/mob/M in hearers(src))
					M.show_message("<b>[src]</b> announces, \"Please insert additional sheets of package wrap into \the [src].\"")
			return 0
	else if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		if(syndiewrap >= 2)
			syndiewrap += -2
			packagewrap += -2
			var/obj/present = new /obj/item/delivery/large(get_step(src, output_dir),H)
			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present
			H.visible_message("<span class='warning'>\The [src] wraps [H]!</span>")
			H.forceMove(present)
			return 1
		else
			if(world.time > next_sound)
				playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
				next_sound = world.time + sound_delay
			for(var/mob/M in hearers(src))
				M.show_message("<b>[src]</b> announces, \"Standard package wrap is not strong enough to wrap living creatures.\"")
			return 0
	else
		if(world.time > next_sound)
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			next_sound = world.time + sound_delay
		return 0

/obj/machinery/autoprocessor/wrapping/proc/tag_item(var/atom/movable/target)
	if(istype(target,/obj/item/delivery))
		var/obj/item/delivery/D = target
		var/image/tag_overlay = image('icons/obj/storage/storage.dmi', D, "deliverytag")
		if(D.sortTag != src.currTag)
			if(!src.currTag)
				return
			var/tag = uppertext(src.destinations[src.currTag])
			D.sortTag = tag
			playsound(src, 'sound/machines/twobeep.ogg', 100, 1)
			D.overlays = 0
			D.overlays += tag_overlay
			D.desc = "A small wrapped package. It has a label reading [tag]"

/obj/machinery/autoprocessor/wrapping/attackby(var/obj/item/O, mob/user)
	. = ..()
	if(istype(O,/obj/item/stack/package_wrap))
		var/obj/item/stack/package_wrap/P = O
		if(istype(P,/obj/item/stack/package_wrap/syndie))
			syndiewrap += P.amount
		packagewrap += P.amount
		to_chat(user, "<span class='notice'>You add [P.amount] sheets of [O] to \the [src].</span>")
		P.use(P.amount)

/obj/machinery/autoprocessor/wrapping/attack_hand(mob/user)
	interact(user)

/obj/machinery/autoprocessor/wrapping/interact(mob/user as mob)

	var/dat = "<table style='width:100%; padding:4px;'><tr>"

	for (var/i = 1, i <= destinations.len, i++)
		dat += "<td><a href='?src=\ref[src];nextTag=[i]'>[destinations[i]]</a>[mode ? "<a href='?src=\ref[src];remove_dest=[i]' class='linkDanger'>\[X\]</a>" : ""]</td>"

		if (i % 4 == 0)
			dat += "</tr><tr>"

	dat += "</tr></table><br>Current Selection: [currTag ? destinations[currTag] : "None"].<hr><br>"

	if(mode)
		dat += "<a href='?src=\ref[src];new_dest=1'>Add destination</a>"

	var/datum/browser/popup = new(user, "destTagger", name, 380, 350, src)
	popup.add_stylesheet("shared", 'nano/css/shared.css')
	popup.set_content(dat)
	popup.open()

/obj/machinery/autoprocessor/wrapping/Topic(href, href_list)
	. = ..()
	if(.)
		return

	add_fingerprint(usr)

	if(href_list["nextTag"])
		currTag = clamp(text2num(href_list["nextTag"]), 0, destinations.len)
		interact(usr)
		return 1

	if(href_list["remove_dest"] && mode)
		var/idx = clamp(text2num(href_list["remove_dest"]), 1, destinations.len)
		if(currTag == destinations[idx])
			currTag = 0 // In case the index was at the end of the list
		destinations -= destinations[idx]
		interact(usr)
		return 1

	if(href_list["new_dest"] && mode)
		var/newtag = uppertext(copytext(sanitize(input(usr, "Destination ID?","Add Destination") as text), 1, MAX_NAME_LEN))
		destinations |= newtag
		interact(usr)
		return 1

/obj/machinery/autoprocessor/clothing
	name = "autoclother"
	desc = "Automatically swaps clothes of people inside. Use machine with an empty hand to retrieve clothing, or with held clothing to place it inside."
	machine_flags = SCREWTOGGLE | CROWDESTROY | EMAGGABLE
	idle_power_usage = 100 //No active power usage because this thing passively uses 100, always. Don't ask me why N3X15 coded it like this.
	circuitpath = /obj/item/weapon/circuitboard/autoprocessor/clothing

	var/list/obj/item/held_clothing = list()
	var/strip_items = FALSE

/obj/machinery/autoprocessor/clothing/attack_hand(mob/user)
	for(var/obj/item/I in held_clothing)
		user.put_in_hands(I)
		held_clothing -= I
	to_chat(user, "<span class='notice'>You retrieve some clothing from \the [src].</span>")

/obj/machinery/autoprocessor/clothing/attackby(var/obj/item/O, mob/user)
	. = ..()
	if(isitem(O) && !O.is_multitool(user))
		held_clothing += O
		user.drop_item(O,src)
		to_chat(user, "<span class='notice'>You add \the [O] to \the [src].</span>")

/obj/machinery/autoprocessor/clothing/process_affecting(var/atom/movable/target)
	if(!isliving(target))
		if(world.time > next_sound)
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			next_sound = world.time + sound_delay
			visible_message("<span class='warning'>[src] buzzes: Can only apply or remove items from living beings.</span>")
		return 0
	var/mob/living/L = target
	var/items_equipped = 0
	for(var/slot in slot_equipment_priority)
		if(emagged || strip_items)
			var/obj/item/strip = L.get_item_by_slot(slot)
			if(emagged && istype(strip,/obj/item/weapon/storage))
				var/obj/item/weapon/storage/S = strip
				for(var/obj/item/I3 in held_clothing)
					if(S.can_be_inserted(I3,1))
						S.handle_item_insertion(I3,1)
						held_clothing -= I3
						items_equipped++
			else if(strip)
				L.u_equip(strip)
				strip.forceMove(src)
				held_clothing += strip
		for(var/obj/item/I in held_clothing)
			if(I.mob_can_equip(L,slot))
				var/obj/item/I2 = L.get_item_by_slot(slot)
				if(I2)
					L.u_equip(I2)
					I2.forceMove(src)
					held_clothing += I2
				L.equip_to_slot(I,slot)
				held_clothing -= I
				items_equipped++
	if(items_equipped && world.time > next_sound)
		playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 1)
		next_sound = world.time + sound_delay
		visible_message("<span class='notice'>[src] beeps: [items_equipped] article\s of clothing applied successfully.</span>")

/obj/machinery/autoprocessor/outfit
	name = "auto outfitter"
	desc = "Automatically applies an outfit to people inside."
	circuitpath = /obj/item/weapon/circuitboard/autoprocessor/outfit

	var/outfit_type = /datum/outfit/assistant
	var/datum/outfit/outfit_datum

/obj/machinery/autoprocessor/outfit/New()
	..()
	outfit_datum = new outfit_type()

/obj/machinery/autoprocessor/outfit/Destroy()
	QDEL_NULL(outfit_datum)
	..()

/obj/machinery/autoprocessor/outfit/process_affecting(var/atom/movable/target)
	if(!isliving(target))
		if(world.time > next_sound)
			playsound(get_turf(src), 'sound/machines/buzz-sigh.ogg', 50, 1)
			next_sound = world.time + sound_delay
			visible_message("<span class='warning'>[src] buzzes: Can only apply or remove items from living beings.</span>")
		return 0
	var/mob/living/L = target
	outfit_datum.equip(L, TRUE, strip = TRUE)
	if(world.time > next_sound)
		playsound(get_turf(src), 'sound/machines/twobeep.ogg', 50, 1)
		next_sound = world.time + sound_delay
		visible_message("<span class='notice'>[src] beeps: [outfit_datum.outfit_name] outfit applied successfully.</span>")

/obj/machinery/autoprocessor/outfit/prisoner
	name = "prisoner outfitter"
	desc = "Automatically applies prisoner clothes to people inside."
	circuitpath = /obj/item/weapon/circuitboard/autoprocessor/outfit/prisoner
	outfit_type = /datum/outfit/special/prisoner

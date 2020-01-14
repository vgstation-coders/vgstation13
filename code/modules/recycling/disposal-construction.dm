// Disposal pipe construction
// This is the pipe that you drag around, not the attached ones.

/obj/structure/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'icons/obj/pipes/disposal.dmi'
	icon_state = "conpipe-s"
	anchored = 0
	density = 0
	pressure_resistance = 5*ONE_ATMOSPHERE
	starting_materials = list(MAT_IRON = 1850)
	w_type = RECYK_METAL
	level = 2
	var/ptype = 0
	// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk, 6=disposal bin, 7=outlet, 8=inlet

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"

/obj/structure/disposalconstruct/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "<span class='info'>It's bolted down to the floor plating.</span>")
	else
		to_chat(user, "<span class='info'>It's currently detached from the floor plating.</span>")

// update iconstate and dpdir due to dir and type
/obj/structure/disposalconstruct/proc/update()
	var/flip = turn(dir, 180)
	var/left = turn(dir, 90)
	var/right = turn(dir, -90)

	switch(ptype)
		if(0)
			base_state = "pipe-s"
			dpdir = dir | flip
		if(1)
			base_state = "pipe-c"
			dpdir = dir | right
		if(2)
			base_state = "pipe-j1"
			dpdir = dir | right | flip
		if(3)
			base_state = "pipe-j2"
			dpdir = dir | left | flip
		if(4)
			base_state = "pipe-y"
			dpdir = dir | left | right
		if(5)
			base_state = "pipe-t"
			dpdir = dir
		 // disposal bin has only one dir, thus we don't need to care about setting it
		if(6)
			if(anchored)
				base_state = "disposal"
			else
				base_state = "condisposal"

		if(7)
			base_state = "outlet"
			dpdir = dir

		if(8)
			base_state = "intake"
			dpdir = dir

		if(9, 11)
			base_state = "pipe-j1s"
			dpdir = dir | right | flip

		if(10, 12)
			base_state = "pipe-j2s"
			dpdir = dir | left | flip

	if(ptype<6 || ptype>8)
		icon_state = "con[base_state]"
	else
		icon_state = base_state

	if(invisibility)				// if invisible, fade icon
		icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
/obj/structure/disposalconstruct/hide(var/intact)
	invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
	update()


	// flip and rotate verbs
/obj/structure/disposalconstruct/verb/rotate()
	set name = "Rotate Pipe"
	set category = "Object"
	set src in view(1)

	if(usr.isUnconscious())
		return

	if(anchored)
		to_chat(usr, "You must unfasten the pipe before rotating it.")
		return

	dir = turn(dir, -90)
	update()

/obj/structure/disposalconstruct/verb/flip()
	set name = "Flip Pipe"
	set category = "Object"
	set src in view(1)
	if(usr.isUnconscious())
		return

	if(anchored)
		to_chat(usr, "You must unfasten the pipe before flipping it.")
		return

	dir = turn(dir, 180)
	switch(ptype)
		if(2)
			ptype = 3
		if(3)
			ptype = 2
		if(9)
			ptype = 10
		if(10)
			ptype = 9
		if(11)
			ptype = 12
		if(12)
			ptype = 11

	update()

	// returns the type path of disposalpipe corresponding to this item dtype
/obj/structure/disposalconstruct/proc/dpipetype()
	switch(ptype)
		if(0,1)
			return /obj/structure/disposalpipe/segment
		if(2,3,4)
			return /obj/structure/disposalpipe/junction
		if(5)
			return /obj/structure/disposalpipe/trunk
		if(6)
			return /obj/machinery/disposal
		if(7)
			return /obj/structure/disposaloutlet
		if(8)
			return /obj/machinery/disposal/deliveryChute
		if(9,10)
			return /obj/structure/disposalpipe/sortjunction
		if(11, 12)
			return /obj/structure/disposalpipe/wrapsortjunction

/obj/structure/disposalconstruct/proc/is_disposal_or_outlet()
	return ptype>=6 && ptype <= 8

/obj/structure/disposalconstruct/proc/lacks_trunk()
	if(is_disposal_or_outlet())
		if(locate(/obj/structure/disposalpipe/trunk/) in loc)
			return FALSE
		else
			return TRUE

/obj/structure/disposalconstruct/proc/competing_pipe()
	if(!is_disposal_or_outlet())
		for(var/obj/structure/disposalpipe/CP in loc)
			update()
			var/pdir = CP.dpdir
			if(istype(CP, /obj/structure/disposalpipe/broken))
				pdir = CP.dir
			if(pdir & dpdir)
				return TRUE

/obj/structure/disposalconstruct/proc/is_under_floorplating()
	var/turf/T = src.loc
	if(istype(T) && T.intact) //t-ray scanner or bins/chutes lets people bonk these through the floor tiling
		return TRUE

// attackby item
// wrench: (un)anchor
// weldingtool: convert to real pipe
/obj/structure/disposalconstruct/attackby(var/obj/item/I, var/mob/user)
	var/nicetype = "pipe"
	var/ispipe = 0 // Indicates if we should change the level of this pipe
	src.add_fingerprint(user)
	switch(ptype)
		if(6)
			nicetype = "disposal bin"
		if(7)
			nicetype = "disposal outlet"
		if(8)
			nicetype = "delivery chute"
		if(9, 10)
			nicetype = "sorting pipe"
			ispipe = 1
		if(11, 12)
			nicetype = "wrap sorting pipe"
			ispipe = 1
		else
			nicetype = "pipe"
			ispipe = 1

	if(I.is_wrench(user))
		if(anchored) //This the only part where we're DETACHING the pipe, so it doesn't really need to check anything.
			anchored = 0
			if(ispipe)
				level = 2
				setDensity(FALSE)
			else
				setDensity(TRUE)
			to_chat(user, "You detach the [nicetype] from the underfloor.")
			playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
			update()
			return
		else
			if(is_under_floorplating())
				to_chat(user, "You can only bolt down the [nicetype] if the floor tiling is removed.")
				return
			if(lacks_trunk())
				to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
				return
			if(competing_pipe())
				to_chat(user, "There is already a [nicetype] at that location.")
				return
			anchored = 1
			if(ispipe)
				level = 1 // We don't want disposal bins to disappear under the floors
				setDensity(FALSE)
			else
				setDensity(TRUE) // We don't want disposal bins or outlets to go density 0
			to_chat(user, "You attach the [nicetype] to the underfloor.")
			playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
			update()

	else if(iswelder(I))
		if(!anchored)
			to_chat(user, "You need to attach it to the plating first!")
			return
		else
			if(is_under_floorplating())
				to_chat(user, "You can't weld the [nicetype] in place with the tiling in the way.")
				return
			if(lacks_trunk())
				to_chat(user, "The [nicetype] requires a trunk underneath it in order to work.")
				return
			if(competing_pipe())
				to_chat(user, "There is already a [nicetype] at that location.")
				return
			var/obj/item/weapon/weldingtool/W = I
			to_chat(user, "Welding the [nicetype] in place.")
			if(W.do_weld(user,src,20,0))
				if(gcDestroyed || !W.isOn())
					return
				to_chat(user, "The [nicetype] has been welded in place!")
				update() // TODO: Make this neat
				if(ispipe) // Pipe

					var/pipetype = dpipetype()
					var/obj/structure/disposalpipe/P = new pipetype(src.loc)
					src.transfer_fingerprints_to(P)
					P.base_icon_state = base_state
					P.dir = dir
					P.dpdir = dpdir
					P.updateicon()

					//Needs some special treatment ;)
					switch(ptype)
						if(9, 10)
							var/obj/structure/disposalpipe/sortjunction/SortP = P
							SortP.updatedir()
						if(11, 12)
							var/obj/structure/disposalpipe/wrapsortjunction/sort_P = P
							sort_P.update_dir()

				else if(ptype==6) // Disposal bin
					var/obj/machinery/disposal/P = new /obj/machinery/disposal(src.loc)
					src.transfer_fingerprints_to(P)
					P.mode = 0 // start with pump off

				else if(ptype==7) // Disposal outlet

					var/obj/structure/disposaloutlet/P = new /obj/structure/disposaloutlet(src.loc)
					src.transfer_fingerprints_to(P)
					P.dir = dir
					var/obj/structure/disposalpipe/trunk/Trunk = locate() in loc
					Trunk.linked = P

				else if(ptype==8) // Disposal outlet

					var/obj/machinery/disposal/deliveryChute/P = new /obj/machinery/disposal/deliveryChute(src.loc)
					src.transfer_fingerprints_to(P)
					P.dir = dir

				qdel(src)
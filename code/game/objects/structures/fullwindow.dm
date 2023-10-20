#define WINDOWLOOSE 0
#define WINDOWLOOSEFRAME 1
#define WINDOWUNSECUREFRAME 2
#define WINDOWSECURE 3

/obj/structure/window/full
	name = "window"
	icon_state = "fwindow0" //Specifically for the map
	base_state = "fwindow"
	sheetamount = 2
	mouse_opacity = 2 // Complete opacity //What in the name of everything is this variable ?
	layer = FULL_WINDOW_LAYER
	penetration_dampening = 1
	cracked_base = "fcrack"
	is_fulltile = TRUE
	disperse_coeff = 0.95
	pass_flags_self = PASSGLASS
	bordersmooth_override = 1

/obj/structure/window/full/New(loc)

	..(loc)
	flow_flags |= ON_BORDER

/obj/structure/window/full/canSmoothWith()
	var/static/list/smoothables = list(/obj/structure/window/full)
	return smoothables

/obj/structure/window/full/cannotSmoothWith()
	return

/obj/structure/window/full/setup_border_dummy()
	return

/obj/structure/window/full/Cross(atom/movable/mover, turf/target, height = 1.5, air_group = 0)
	if(istype(mover) && mover.checkpass(pass_flags_self))
		dim_beam(mover)
		return TRUE
	return !density

/obj/structure/window/full/can_be_reached(mob/user)

	return 1 //That about it Captain

/obj/structure/window/full/verb/set_direction() //Full windows get this because it's possible for them to face diagonally
	set name = "Set Window Direction"			//Diagonal facing matters in the use of one-way windows
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return 0

	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	var/direction_list = list("north","south","east","west","northeast","southeast","southwest","northwest")
	var/N = input("Which direction do you want \the [src] to face?","[src]") as null|anything in direction_list
	if(N)
		update_nearby_tiles() //Compel updates before
		switch(N)
			if("north")
				dir = NORTH
			if("south")
				dir = SOUTH
			if("east")
				dir = EAST
			if("west")
				dir = WEST
			if("northeast")
				dir = NORTHEAST
			if("southeast")
				dir = SOUTHEAST
			if("southwest")
				dir = SOUTHWEST
			if("northwest")
				dir = NORTHWEST
		update_nearby_tiles()


/obj/structure/window/full/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/structure/window/full/reinforced/clockwork, BRASS_FULL_WINDOW_GLOW)

/obj/structure/window/full/loose
	anchored = 0
	d_state = 0

/obj/structure/window/full/reinforced
	name = "reinforced window"
	desc = "A window with a rod matrix. It looks more solid than the average window."
	icon_state = "frwindow0"
	base_state = "frwindow"
	sheet_type = /obj/item/stack/sheet/glass/rglass
	health = 40
	penetration_dampening = 3
	d_state = WINDOWSECURE
	reinforced = 1
	disperse_coeff = 0.8
	dmg_threshold = 5

/obj/structure/window/full/reinforced/loose
	anchored = 0
	d_state = 0

/obj/structure/window/full/plasma

	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "fplasmawindow0"
	base_state = "fplasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheet_type = /obj/item/stack/sheet/glass/plasmaglass
	health = 120
	penetration_dampening = 5
	disperse_coeff = 0.75
	dmg_threshold = 10

	fire_temp_threshold = 32000
	fire_volume_mod = 1000

/obj/structure/window/full/plasma/loose
	anchored = 0
	d_state = 0


/obj/structure/window/full/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "fplasmarwindow0"
	base_state = "fplasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheet_type = /obj/item/stack/sheet/glass/plasmarglass
	health = 160
	penetration_dampening = 7
	disperse_coeff = 0.6
	dmg_threshold = 15

/obj/structure/window/full/reinforced/plasma/loose
	anchored = 0
	d_state = 0


/obj/structure/window/full/reinforced/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/full/reinforced/tinted

	name = "tinted window"
	desc = "A window with a rod matrix. Its surface is completely tinted, making it opaque. Why not a wall?"
	icon_state = "ftwindow0"
	base_state = "ftwindow"
	opacity = 1
	sheet_type = /obj/item/stack/sheet/glass/rglass //A glass type for this window doesn't seem to exist, so here's to you

/obj/structure/window/full/reinforced/tinted/frosted

	name = "frosted window"
	desc = "A window with a rod matrix. Its surface is completely tinted, making it opaque, and it's frosty. Why not an ice wall?"
	icon_state = "frwindow0"
	base_state = "frwindow"
	health = 30
	sheet_type = /obj/item/stack/sheet/glass/rglass //Ditto above

/obj/structure/window/full/reinforced/clockwork
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass."
	icon_state = "fclockworkwindow0"
	base_state = "fclockworkwindow"
	shardtype = null
	sheet_type = /obj/item/stack/sheet/brass
	reinforcetype = /obj/item/stack/sheet/ralloy
	sheetamount = 4
	health = 80

/obj/structure/window/full/reinforced/clockwork/relativewall()
	// Ignores adjacent anchored window tiles for "merging", since there's only a single brass window sprite
	// Remove this whenever someone sprites all the required icon states
	return

/obj/structure/window/full/reinforced/clockwork/loose
	anchored = 0
	d_state = 0

/obj/structure/window/full/reinforced/clockwork/cultify()
	return

/obj/structure/window/full/reinforced/clockwork/clockworkify()
	return

#undef WINDOWLOOSE
#undef WINDOWLOOSEFRAME
#undef WINDOWUNSECUREFRAME
#undef WINDOWSECURE

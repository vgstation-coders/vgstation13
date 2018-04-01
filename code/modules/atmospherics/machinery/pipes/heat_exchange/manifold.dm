//3-way manifold
/obj/machinery/atmospherics/pipe/heat_exchanging/manifold
	icon_state = "manifold"

	name = "pipe manifold"
	desc = "A manifold composed of regular pipes."

	dir = SOUTH
	initialize_directions_he = EAST|NORTH|WEST

	device_type = TRINARY

	construction_type = /obj/item/pipe/trinary
	pipe_state = "he_manifold"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/SetInitDirections()
	switch(dir)
		if(NORTH)
			initialize_directions_he = EAST|SOUTH|WEST
		if(SOUTH)
			initialize_directions_he = WEST|NORTH|EAST
		if(EAST)
			initialize_directions_he = SOUTH|WEST|NORTH
		if(WEST)
			initialize_directions_he = NORTH|EAST|SOUTH

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold_center[invis]"

	cut_overlays()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			add_overlay(getpipeimage('icons/obj/atmospherics/pipes/heat.dmi', "manifold_intact[invis]", get_dir(src, nodes[i])))

//4-way manifold
/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w
	icon_state = "manifold4w"

	name = "4-way pipe manifold"
	desc = "A manifold composed of heat-exchanging pipes."

	initialize_directions_he = NORTH|SOUTH|EAST|WEST

	device_type = QUATERNARY

	construction_type = /obj/item/pipe/quaternary
	pipe_state = "he_manifold4w"

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/SetInitDirections()
	initialize_directions_he = initial(initialize_directions_he)

/obj/machinery/atmospherics/pipe/heat_exchanging/manifold4w/update_icon()
	var/invis = invisibility ? "-f" : ""

	icon_state = "manifold4w_center[invis]"

	cut_overlays()

	//Add non-broken pieces
	for(var/i in 1 to device_type)
		if(nodes[i])
			add_overlay(getpipeimage('icons/obj/atmospherics/pipes/heat.dmi', "manifold_intact[invis]", get_dir(src, nodes[i])))

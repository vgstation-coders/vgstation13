
/obj/machinery/atmospherics/unary/cap
	name = "pipe endcap"
	desc = "An endcap for pipes."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "cap"
	level = 2
	layer = PIPE_LAYER
	can_be_coloured = 1
	dir = SOUTH
	initialize_directions = SOUTH
	color = "#B4B4B4"
	update_icon_ready = 1


/obj/machinery/atmospherics/unary/cap/hide(var/i)
	if(level == 1 && istype(loc, /turf/simulated))
		invisibility = i ? 101 : 0
	update_icon()

/obj/machinery/atmospherics/unary/cap/update_icon()
	overlays = 0
	alpha = invisibility ? 128 : 255
	icon_state = "cap"

	if (node1)
		color = node1.color

/obj/machinery/atmospherics/unary/cap/visible
	level = 2
	icon_state = "cap"

/obj/machinery/atmospherics/unary/cap/visible/scrubbers
	name = "Scrubbers cap"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/unary/cap/visible/supply
	name = "Air supply cap"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/unary/cap/visible/supplymain
	name = "Main air supply cap"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/unary/cap/visible/general
	name = "Air supply cap"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/unary/cap/visible/yellow
	name = "Air supply cap"
	color=PIPE_COLOR_ORANGE
/obj/machinery/atmospherics/unary/cap/visible/filtering
	name = "Air filtering cap"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/unary/cap/visible/cyan
	name = "Air supply cap"
	color=PIPE_COLOR_CYAN

/obj/machinery/atmospherics/unary/cap/hidden
	level = 1
	alpha=128

/obj/machinery/atmospherics/unary/cap/hidden/scrubbers
	name = "Scrubbers cap"
	color=PIPE_COLOR_RED
/obj/machinery/atmospherics/unary/cap/hidden/supply
	name = "Air supply cap"
	color=PIPE_COLOR_BLUE
/obj/machinery/atmospherics/unary/cap/hidden/supplymain
	name = "Main air supply cap"
	color=PIPE_COLOR_PURPLE
/obj/machinery/atmospherics/unary/cap/hidden/general
	name = "Air supply cap"
	color=PIPE_COLOR_GREY
/obj/machinery/atmospherics/unary/cap/hidden/yellow
	name = "Air supply cap"
	color=PIPE_COLOR_ORANGE
/obj/machinery/atmospherics/unary/cap/hidden/filtering
	name = "Air filtering cap"
	color=PIPE_COLOR_GREEN
/obj/machinery/atmospherics/unary/cap/hidden/cyan
	name = "Air supply cap"
	color=PIPE_COLOR_CYAN

/obj/machinery/atmospherics/unary/cap/heat
	name = "pipe endcap"
	desc = "An endcap for pipes."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "he_cap"

	can_be_coloured = 0

/obj/machinery/atmospherics/unary/cap/heat/New()
	..()
	initialize_directions_he = initialize_directions

/obj/machinery/atmospherics/unary/cap/heat/update_icon()
	overlays = 0
	alpha = invisibility ? 128 : 255
	icon_state = "he_cap"

/obj/machinery/atmospherics/unary/cap/heat/buildFrom(var/mob/usr,var/obj/item/pipe/pipe)
	dir = pipe.dir
	initialize_directions = 0
	initialize_directions_he = pipe.get_hdir()
	var/turf/T = loc
	level = T.intact ? LEVEL_ABOVE_FLOOR : LEVEL_BELOW_FLOOR
	update_planes_and_layers()
	initialize()
	build_network()
	if (node1)
		node1.initialize()
		node1.build_network()
	return 1


/obj/machinery/atmospherics/unary/cap/heat/process()
	. = ..()
	if(node1)
		animate(src, color = node1.color, time = 2 SECONDS, easing = SINE_EASING)
	else if (color != "#B4B4B4")
		animate(src, color = "#B4B4B4", time = 2 SECONDS, easing = SINE_EASING)

/obj/machinery/atmospherics/unary/cap/heat/getNodeType(var/node_id)
	return PIPE_TYPE_HE

/obj/machinery/atmospherics/unary/cap/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if(istype(W, /obj/item/device/rcd/rpd) || istype(W, /obj/item/device/pipe_painter))
		return // Coloring pipes.

	return ..()

/obj/machinery/atmospherics/unary/cap/bluespace
	name = "bluespace pipe endcap"
	desc = "A bluespace endcap for pipes."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "bscap"
	can_be_coloured = 0
	level = LEVEL_ABOVE_FLOOR
	var/network_color = "#b4b4b4"    // default grey color that all pipes have
	var/global/list/obj/machinery/atmospherics/bspipe_list = list()
	
	var/color_r = 255
	var/color_g = 255
	var/color_b = 255

	var/image/color_overlay
	
	var/list/pipe_colors = list(
		"custom", \
		"grey" = rgb(180,180,180), \
		"blue" = rgb(0,0,183), \
		"cyan" = rgb(0,184,184), \
		"green" = rgb(0,185,0), \
		"pink" = rgb(255,102,204), \
		"purple" = rgb(128,0,128), \
		"red" = rgb(183,0,0), \
		"orange" = rgb(183,121,0), \
		"white" = rgb(255,255,255), \
	)
	
/obj/machinery/atmospherics/unary/cap/bluespace/update_icon()
	overlays = 0
	alpha = invisibility ? 128 : 255
	icon_state = "bscap"
	
	color_overlay = image('icons/obj/pipes.dmi', icon_state = "bscap-overlay")
	color_overlay.color = rgb(color_r,color_g,color_b)
	overlays += color_overlay
	
	
/obj/machinery/atmospherics/unary/cap/bluespace/New()
	..()
	bspipe_list.Add(src)
	
/obj/machinery/atmospherics/unary/cap/bluespace/Destroy()
	bspipe_list.Remove(src)
	..()
	
	
/obj/machinery/atmospherics/unary/cap/bluespace/proc/merge_all()
	var/datum/pipe_network/main_network
	for(var/obj/machinery/atmospherics/unary/cap/bluespace/bscap in bspipe_list)
		if(!bscap.network)
			continue
		if(src.network_color != bscap.network_color)
			continue
		if(!main_network)
			main_network = bscap.network
			continue
		else
			main_network.merge(bscap.network)
				
/obj/machinery/atmospherics/unary/cap/bluespace/build_network()
	if(!network && node1)
		network = new /datum/pipe_network
		network.normal_members += src
		network.build_network(node1, src)
		merge_all()
		
		
/obj/machinery/atmospherics/unary/cap/bluespace/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/device/multitool))
		var/list/choice_list = pipe_colors

		var/choice = input(user,"Select a colour to set [src] to.","[src]") in choice_list
		if(!Adjacent(user))
			return

		var/new_color
		if(choice == "custom")
			new_color = input("Please select a color for the tile.", "[src]",rgb(color_r,color_g,color_b)) as color
			if(new_color)
				color_r = hex2num(copytext(new_color, 2, 4))
				color_g = hex2num(copytext(new_color, 4, 6))
				color_b = hex2num(copytext(new_color, 6, 8))
		else
			new_color = choice_list[choice]
			color_r = hex2num(copytext(new_color, 2, 4))
			color_g = hex2num(copytext(new_color, 4, 6))
			color_b = hex2num(copytext(new_color, 6, 8))
			
		update_icon()
		
		network_color = new_color
		qdel(network)
		merge_all()
	return ..()
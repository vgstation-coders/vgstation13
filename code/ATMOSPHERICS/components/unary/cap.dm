
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

	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/red))
		src.color = PIPE_COLOR_RED
		to_chat(user, "<span class='warning'>You paint the pipe red.</span>")
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/blue))
		src.color = PIPE_COLOR_BLUE
		to_chat(user, "<span class='warning'>You paint the pipe blue.</span>")
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/green))
		src.color = PIPE_COLOR_GREEN
		to_chat(user, "<span class='warning'>You paint the pipe green.</span>")
		update_icon()
		return 1
	if(istype(W, /obj/item/weapon/reagent_containers/glass/paint/yellow))
		src.color = PIPE_COLOR_ORANGE
		to_chat(user, "<span class='warning'>You paint the pipe yellow.</span>")
		update_icon()
		return 1

	return ..()

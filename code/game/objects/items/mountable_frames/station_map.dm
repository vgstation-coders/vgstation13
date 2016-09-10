/obj/item/mounted/frame/station_map
	name = "station holomap frame"
	desc = "A virtual map of the station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map_frame0"
	flags = FPRINT
	mount_reqs = list("nospace")

/obj/item/mounted/frame/station_map/do_build(turf/on_wall, mob/user)
	new /obj/machinery/station_map_frame(get_turf(src), get_dir(user, on_wall))
	qdel(src)

/obj/machinery/station_map_frame
	name = "station holomap frame"
	desc = "A virtual map of the station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map_frame0"
	anchored = 1
	density = 0

	var/datum/construction/construct

/obj/machinery/station_map_frame/attackby(var/obj/item/W, var/mob/user)
	if(!construct || !construct.action(W, user))
		..()

/obj/machinery/station_map_frame/New(turf/loc, var/ndir)
	..()
	dir = ndir
	switch(ndir)
		if(NORTH)
			pixel_x = 0
			pixel_y = WORLD_ICON_SIZE
		if(SOUTH)
			pixel_x = 0
			pixel_y = -1*WORLD_ICON_SIZE
		if(EAST)
			pixel_x = WORLD_ICON_SIZE
			pixel_y = 0
		if(WEST)
			pixel_x = -1*WORLD_ICON_SIZE
			pixel_y = 0

	construct = new /datum/construction/reversible/station_map(src)
	/*
/obj/machinery/station_map_frame/update_icon()
	icon_state = "station_map_frame[build]"
	*/
/datum/construction/reversible/station_map
	result = /obj/machinery/station_map
	var/base_icon = "station_map_frame"

	steps = list(
					//1
					 list(Co_DESC="The glass screen is in place.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} close{s} the panel."),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} the glass screen from {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} removing the glass screen...",
					 		Co_DELAY = 30,)
					 	),
					 //2
					 list(Co_DESC="The wiring is added.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/sheet/glass/glass,
					 		Co_AMOUNT = 1,
					 		Co_VIS_MSG = "{USER} install{s} the glass screen to {HOLDER}.",
					 		Co_START_MSG = "{USER} begin{s} installing the glass screen...",
					 		Co_DELAY = 30),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/wirecutters,
					 		Co_VIS_MSG = "{USER} remove{s} the wiring from {HOLDER}.")
					 	),
					 //3
					 list(Co_DESC="The circuitboard is installed",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/stack/cable_coil,
					 		Co_AMOUNT = 5,
					 		Co_VIS_MSG = "{USER} add{s} the wiring to {HOLDER}.",
					 		Co_DELAY = 20),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/crowbar,
					 		Co_VIS_MSG = "{USER} prie{s} the glass screen from {HOLDER}.")
					 	),
					 //4
					 list(Co_DESC="The frame is on the wall.",
					 	Co_NEXTSTEP = list(Co_KEY=/obj/item/weapon/circuitboard/station_map,
					 		Co_VIS_MSG = "{USER} install{s} the circuitboard into {HOLDER}.",
					 		Co_AMOUNT = 1),
					 	Co_BACKSTEP = list(Co_KEY=/obj/item/weapon/screwdriver,
					 		Co_VIS_MSG = "{USER} unfasten{s} {HOLDER} from the wall.",
					 		Co_START_MSG = "{USER} begin{s} removing {HOLDER}'s screws...",
					 		Co_DELAY = 30)
					 	)
					)

/datum/construction/reversible/station_map/custom_action(index, diff, atom/used_atom, mob/user)
	if(!..())
		return 0

	holder.icon_state = "[base_icon][steps.len - index - diff]"
	return 1

/datum/construction/reversible/station_map/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/reversible/station_map/spawn_result(mob/user as mob)
	if(result)
		testing("[user] finished a [result]!")

		var/obj/machinery/station_map/S = new result(get_turf(holder))
		S.dir = holder.dir
		S.update_icon()

		qdel (holder)
		holder = null

	feedback_inc("station_map_created",1)

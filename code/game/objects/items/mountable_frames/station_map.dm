/obj/item/mounted/frame/station_map
	name = "station holomap frame"
	desc = "A virtual map of the station."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "station_map_frame0"
	flags = FPRINT
	mount_reqs = list("simfloor", "nospace")

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

	var/build = 0        // Build state
	var/boardtype=/obj/item/weapon/circuitboard/station_map
	var/obj/item/weapon/circuitboard/_circuitboard

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

/obj/machinery/station_map_frame/update_icon()
	icon_state = "station_map_frame[build]"

/obj/machinery/station_map_frame/attackby(var/obj/item/W as obj, var/mob/user as mob)
	switch(build)
		if(0) // Empty hull
			if(isscrewdriver(W))
				to_chat(usr, "You begin removing screws from \the [src] backplate...")
				if(do_after(user, src, 50))
					to_chat(usr, "<span class='notice'>You unscrew \the [src] from the wall.</span>")
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
					new /obj/item/mounted/frame/station_map(get_turf(src))
					qdel(src)
				return 1
			if(istype(W, /obj/item/weapon/circuitboard))
				var/obj/item/weapon/circuitboard/C=W
				if(!(istype(C,/obj/item/weapon/circuitboard/station_map)))
					to_chat(user, "<span class='warning'>You cannot install this type of board into a [src].</span>")
					return
				to_chat(usr, "You begin to insert \the [C] into \the [src].")
				if(do_after(user, src, 10))
					if(user.drop_item(C, src))
						to_chat(usr, "<span class='notice'>You secure \the [C]!</span>")
						_circuitboard=C
						playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
						build++
						update_icon()
				return 1
		if(1) // Circuitboard installed
			if(iscrowbar(W))
				to_chat(usr, "You begin to pry out \the [W] into \the [src].")
				if(do_after(user, src, 10))
					playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0)
					build--
					update_icon()
					var/obj/item/weapon/circuitboard/C
					if(_circuitboard)
						_circuitboard.forceMove(get_turf(src))
						C=_circuitboard
						_circuitboard=null
					else
						C=new boardtype(get_turf(src))
					user.visible_message(\
						"<span class='warning'>[user.name] has removed \the [C]!</span>",\
						"You remove \the [C].")
				return 1
			if(istype(W, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C=W
				to_chat(user, "You start adding cables to \the [src]...")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 20) && C.amount >= 5)
					C.use(5)
					build++
					update_icon()
					user.visible_message(\
						"<span class='warning'>[user.name] has added cables to \the [src]!</span>",\
						"You add cables to \the [src].")
		if(2) // Circuitboard installed, wired.
			if(iswirecutter(W))
				to_chat(usr, "You begin to remove the wiring from \the [src].")
				if(do_after(user, src, 50))
					new /obj/item/stack/cable_coil(loc,5)
					user.visible_message(\
						"<span class='warning'>[user.name] cut the cables.</span>",\
						"You cut the cables.")
					build--
					update_icon()
				return 1
			if(istype(W, /obj/item/stack/sheet/glass/glass))
				var/obj/item/stack/sheet/glass/G=W
				to_chat(user, "You begin to complete \the [src]...")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 20) && G.amount >= 1)
					if(!_circuitboard)
						_circuitboard=new boardtype(src)
					G.use(1)
					build++
					update_icon()
					user.visible_message(\
						"<span class='warning'>[user.name] has added a glass screen to \the [src]!</span>",\
						"You add a glass screen to \the [src].")
				return 1
		if(3) // Screen in place
			if(iscrowbar(W))
				to_chat(user, "You begin to pry off the glass screen...")
				playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 1)
				if(do_after(user, src, 30)).
					new /obj/item/stack/sheet/glass/glass(loc,1)
					user.visible_message(\
						"<span class='warning'>[user.name] pried off the glass screen.</span>",\
						"You pry off the glass screen.")
					build--
					update_icon()
				return 1
			if(isscrewdriver(W))
				to_chat(usr, "You finish up \the [src]...")
				if(do_after(user, src, 50))
					to_chat(usr, "<span class='notice'>You finish up \the [src].</span>")
					playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
					var/obj/machinery/station_map/S = new(loc)
					S.dir = dir
					S.update_icon()
					qdel(src)
				return 1
	..()

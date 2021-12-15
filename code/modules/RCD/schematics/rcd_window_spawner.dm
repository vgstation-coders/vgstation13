/obj/effect/spawner/window
	name = "window spawner"
	var/full = FALSE
	var/list/dirs = list(NORTH,WEST,SOUTH,EAST)

/obj/effect/spawner/window/New()
	..()
	spawn_window()

/obj/effect/spawner/window/proc/spawn_window()
	var/turf/T = get_turf(src)
	if(T && !istype(T,/turf/simulated/wall) && !istype(T,/turf/unsimulated/wall))
		if(!locate(/obj/structure/grille) in loc)
			new /obj/structure/grille(T)
		for(var/direction in dirs)
			var/windowhere = FALSE
			for(var/obj/structure/window/reinforced/R in loc)
				if(R.dir == direction)
					windowhere = TRUE
			if(windowhere)
				continue
			var/obj/structure/window/reinforced/new_window = new /obj/structure/window/reinforced(loc)
			new_window.change_dir(direction)
			new_window.update_nearby_tiles()
		if(full && !locate(/obj/structure/window/full/reinforced) in loc)
			var/obj/structure/window/reinforced/new_fullwindow = new /obj/structure/window/full/reinforced(loc)
			new_fullwindow.update_nearby_tiles()
	qdel(src)

/obj/effect/spawner/window/northend
	dirs = list(NORTH)

/obj/effect/spawner/window/westend
	dirs = list(WEST)

/obj/effect/spawner/window/southend
	dirs = list(SOUTH)

/obj/effect/spawner/window/eastend
	dirs = list(EAST)

/obj/effect/spawner/window/horizontal
	dirs = list(NORTH,SOUTH)

/obj/effect/spawner/window/vertical
	dirs = list(WEST,EAST)

/obj/effect/spawner/window/nwcorner
	dirs = list(NORTH,WEST)

/obj/effect/spawner/window/swcorner
	dirs = list(SOUTH,WEST)

/obj/effect/spawner/window/secorner
	dirs = list(SOUTH,EAST)

/obj/effect/spawner/window/necorner
	dirs = list(NORTH,EAST)

/obj/effect/spawner/window/northcap
	dirs = list(NORTH,EAST,WEST)

/obj/effect/spawner/window/westcap
	dirs = list(WEST,NORTH,SOUTH)

/obj/effect/spawner/window/southcap
	dirs = list(SOUTH,EAST,WEST)

/obj/effect/spawner/window/eastcap
	dirs = list(EAST,NORTH,SOUTH)

/obj/effect/spawner/window/full
	full = TRUE

/obj/effect/spawner/window/full/northend
	dirs = list(NORTH)

/obj/effect/spawner/window/full/westend
	dirs = list(WEST)

/obj/effect/spawner/window/full/southend
	dirs = list(SOUTH)

/obj/effect/spawner/window/full/eastend
	dirs = list(EAST)

/obj/effect/spawner/window/full/horizontal
	dirs = list(NORTH,SOUTH)

/obj/effect/spawner/window/full/vertical
	dirs = list(WEST,EAST)

/obj/effect/spawner/window/full/nwcorner
	dirs = list(NORTH,WEST)

/obj/effect/spawner/window/full/swcorner
	dirs = list(SOUTH,WEST)

/obj/effect/spawner/window/full/secorner
	dirs = list(SOUTH,EAST)

/obj/effect/spawner/window/full/necorner
	dirs = list(NORTH,EAST)

/obj/effect/spawner/window/full/northcap
	dirs = list(NORTH,EAST,WEST)

/obj/effect/spawner/window/full/westcap
	dirs = list(WEST,NORTH,SOUTH)

/obj/effect/spawner/window/full/southcap
	dirs = list(SOUTH,EAST,WEST)

/obj/effect/spawner/window/full/eastcap
	dirs = list(EAST,NORTH,SOUTH)

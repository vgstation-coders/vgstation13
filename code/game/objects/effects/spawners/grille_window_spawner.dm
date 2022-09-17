/obj/window_grille_spawner
	name = "window grille spawner"
	icon = 'icons/obj/window_grille_spawner.dmi'
	icon_state = "window_grille"
	var/obj/structure/window/window_path = /obj/structure/window
	var/obj/structure/grille/grille_path = /obj/structure/grille
	var/activated = FALSE

/obj/window_grille_spawner/initialize()
	. = ..()
	activate()
	qdel(src)

/obj/window_grille_spawner/proc/activate()
	if(activated)
		return
	activated = TRUE

	if(locate(grille_path) in loc)
		CRASH("A grille already exists here")

	new grille_path(loc)

	if(locate(window_path) in loc)
		CRASH("A window already exists here")

	if(initial(window_path.is_fulltile))
		new window_path(loc)
		return

	var/list/neighbours = list()
	for(var/direction in cardinal)
		var/turf/there = get_step(src, direction)
		var/obj/window_grille_spawner/other = locate(type) in there
		if(other)
			neighbours += other
			continue
		var/found_connection = FALSE
		if(locate(grille_path) in there)
			for(var/obj/structure/window/window_there in there)
				if(window_there.type == window_path && window_there.dir == get_dir(there, src))
					found_connection = TRUE
					break
		if(!found_connection)
			var/obj/structure/window/new_window = new window_path(loc)
			new_window.change_dir(direction)
			new_window.update_nearby_tiles()

	for(var/obj/window_grille_spawner/other in neighbours)
		other.activate()

/obj/window_grille_spawner/full
	window_path = /obj/structure/window/full

/obj/window_grille_spawner/reinforced
	icon_state = "reinforced_window_grille"
	window_path = /obj/structure/window/reinforced

/obj/window_grille_spawner/reinforced/full
	window_path = /obj/structure/window/full/reinforced

/obj/window_grille_spawner/plasma
	icon_state = "reinforced_plasma_window_grille"
	window_path = /obj/structure/window/plasma

/obj/window_grille_spawner/plasma/full
	window_path = /obj/structure/window/full/plasma

/obj/window_grille_spawner/reinforced_plasma
	icon_state = "reinforced_plasma_window_grille"
	window_path = /obj/structure/window/reinforced/plasma

/obj/window_grille_spawner/reinforced_plasma/full
	window_path = /obj/structure/window/full/reinforced/plasma

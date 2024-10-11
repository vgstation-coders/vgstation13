/obj/structure/grille/window_spawner
	icon = 'icons/obj/window_grille_spawner.dmi'
	icon_state = "windowgrille"
	var/window_path = /obj/structure/window
	var/full_path

/obj/structure/grille/window_spawner/initialize()
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille0"
	. = ..()
	if(full_path)
		new full_path(loc)

	for(var/direction in cardinal)
		var/turf/there = get_step(src, direction)
		if(get_area(src) == get_area(there) && (locate(/obj/structure/grille) in there))
			continue
		var/obj/structure/window/new_window = new window_path(loc)
		new_window.dir = direction

/obj/structure/grille/window_spawner/full
	icon_state = "windowgrille_full"
	full_path = /obj/structure/window/full

/obj/structure/grille/window_spawner/reinforced
	icon_state = "rwindowgrille"
	window_path = /obj/structure/window/reinforced

/obj/structure/grille/window_spawner/reinforced/tinted
	window_path = /obj/structure/window/reinforced/tinted

/obj/structure/grille/window_spawner/reinforced/full
	icon_state = "rwindowgrille_full"
	full_path = /obj/structure/window/full/reinforced

/obj/structure/grille/window_spawner/plasma
	icon_state = "pwindowgrille"
	window_path = /obj/structure/window/plasma

/obj/structure/grille/window_spawner/plasma/full
	icon_state = "pwindowgrille_full"
	full_path = /obj/structure/window/full/plasma

/obj/structure/grille/window_spawner/reinforced_plasma
	icon_state = "rpwindowgrille"
	window_path = /obj/structure/window/reinforced/plasma

/obj/structure/grille/window_spawner/reinforced_plasma/full
	icon_state = "rpwindowgrille_full"
	full_path = /obj/structure/window/full/reinforced/plasma

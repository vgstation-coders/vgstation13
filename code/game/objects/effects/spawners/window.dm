/obj/effect/window_spawner
	icon			= 'icons/obj/window_spawner.dmi'
	icon_state		= "normal"

	var/full_type	= /obj/structure/window/full
	var/dir_type	= /obj/structure/window

/obj/effect/window_spawner/initialize()
	new/obj/structure/grille(loc)
	if(full_type)
		new full_type(loc)

	for(var/dir in cardinal)
		if(locate(/obj/effect/window_spawner) in get_step(src, dir))
			continue

		var/obj/structure/window/W = new dir_type(loc)
		W.dir = dir

	spawn(100)
		qdel(src)

/obj/effect/window_spawner/plasma
	icon_state	= "plasma"
	full_type	= /obj/structure/window/full/plasma
	dir_type	= /obj/structure/window/plasma

/obj/effect/window_spawner/reinforced
	icon_state	= "reinforced"
	full_type	= /obj/structure/window/full/reinforced
	dir_type	= /obj/structure/window/reinforced

/obj/effect/window_spawner/reinforced/plasma
	icon_state	= "plasma_reinforced"
	full_type	= /obj/structure/window/full/reinforced/plasma
	dir_type	= /obj/structure/window/reinforced/plasma
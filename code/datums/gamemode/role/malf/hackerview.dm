
/obj/structure
	var/image/hackview_image
	var/hackview_icon
	var/hackview_icon_state
	var/hackview_layer = HACKVIEW_STRUCTURE_LAYER

/turf
	var/image/hackview_image
	var/hackview_icon
	var/hackview_icon_state
	var/hackview_layer = HACKVIEW_TURF_LAYER

/turf/proc/initialize_hackview_image()
	hackview_image = image(hackview_icon, src, hackview_icon_state, hackview_layer)
	hackview_image.override = TRUE
	hackview_image.plane = HACKVIEW_PLANE
	overlays += hackview_image

/obj/structure/proc/initialize_hackview_image()
	hackview_image = image(hackview_icon, src, hackview_icon_state, hackview_layer)
	hackview_image.override = TRUE
	hackview_image.plane = HACKVIEW_PLANE
	overlays += hackview_image

//////////////////////////

/turf/simulated/floor
	hackview_icon = 'icons/turf/floors.dmi'
	hackview_icon_state = "malfview"

/turf/simulated/wall
	hackview_icon = 'icons/turf/walls.dmi'
	hackview_icon_state = "malfview"

/turf/simulated/wall/initialize_hackview_image()
	var/image/hackview_image = image(hackview_icon, src, "[hackview_icon_state][src.junction]", HACKVIEW_TURF_LAYER)
	hackview_image.override = 1
	hackview_image.plane = HACKVIEW_PLANE
	overlays += hackview_image

/obj/structure/grille
	hackview_icon = 'icons/obj/structures.dmi'
	hackview_icon_state = "grille_malfview"
	hackview_layer = HACKVIEW_GRILLE_LAYER

/obj/structure/window
	hackview_icon = 'icons/obj/structures.dmi'
	hackview_icon_state = "window_malfview"

/obj/structure/window/reinforced
	hackview_icon_state = "rwindow_malfview"

/obj/structure/window/full
	hackview_icon_state = "window0_malfview"

/obj/structure/window/full/reinforced
	hackview_icon_state = "rwindow0_malfview"


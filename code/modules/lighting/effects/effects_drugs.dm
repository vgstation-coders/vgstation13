/obj/screen/plane/drugs
	icon = 'icons/effects/256x256.dmi'
	plane = EFFECTS_PLANE
	blend_mode = BLEND_MULTIPLY
	alpha = 80
	mouse_opacity = 0
	var/severity // runtime avoidance

/obj/screen/plane/drugs/rainbow
	icon_state = "cloud"

/obj/screen/plane/drugs/rainbow/New()
	..()
	processing_objects += src
	var/matrix/M = matrix()
	M.Scale(2)
	M.Translate(-128, -128)
	transform = M

/obj/screen/plane/drugs/rainbow/Destroy()
	processing_objects -= src
	. = ..()

/obj/screen/plane/drugs/rainbow/process()
	animate(src, color = get_random_colour(1), time = 15)

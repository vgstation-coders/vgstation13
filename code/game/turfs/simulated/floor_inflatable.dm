/turf/simulated/floor/inflatable
	name = "inflatable floor"
	desc = "A floor made up of an inflated membrane. Try not to wear anything too sharp while walking on it."
	icon = 'icons/obj/inflatable.dmi'
	icon_state = "floor"
	intact = 0
	plane = PLATING_PLANE
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TCMB

/turf/simulated/floor/inflatable/attackby(obj/item/I, mob/user)
	if(I.sharpness && I.sharpness_flags & SHARP_BLADE)
		user.visible_message("<span class = 'warning'>\The [user] is popping \the [src]!</span>")
		if(do_after(user, src, 3 SECONDS))
			pop(user)
	else
		user.visible_message("<span class = 'warning'>\The [user] bounces \the [I] off of \the [src].</span>")

/turf/simulated/floor/inflatable/proc/pop(mob/user)
	ChangeTurf(get_base_turf(z))
	playsound(loc, 'sound/machines/hiss.ogg', 75, 1)
	new /obj/item/inflatable/torn(src)


/turf/simulated/floor/inflatable/air
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	temperature = T20C
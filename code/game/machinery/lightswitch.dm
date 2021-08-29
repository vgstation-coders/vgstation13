// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/buildstage = 2
	var/on = 0
	var/image/overlay

	moody_light_type = /atom/movable/light/moody/light_switch
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_RED
	lighting_flags = FOLLOW_PIXEL_OFFSET | NO_LUMINOSITY

/obj/machinery/light_switch/supports_holomap()
	return TRUE

/obj/machinery/light_switch/initialize()
	add_self_to_holomap()
	if (!map.lights_always_ok)
		var/area/A = get_area(src)
		if (!A.lights_always_start_on)
			toggle_switch(newstate = 0)

/obj/machinery/light_switch/New(var/loc, var/ndir, var/building = 2)
	var/area/this_area = get_area(src)
	name = "[this_area.name] light switch"
	buildstage = building
	if(buildstage)
		on = this_area.lightswitch
	else
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER) : 0
		dir = ndir
	updateicon()
	..()

/obj/machinery/light_switch/proc/updateicon()
	if(!overlay)
		overlay = image(icon, "light1-overlay")
		overlay.plane = ABOVE_LIGHTING_PLANE
		overlay.layer = ABOVE_LIGHTING_LAYER

	overlays.Cut()
	if((stat & NOPOWER) || buildstage != 2)
		icon_state = "light-p"
		kill_light()
	else
		icon_state = on ? "light1" : "light0"
		overlay.icon_state = "[icon_state]-overlay"
		overlays += overlay
		// Now can be a nice and soft one-tile light again.
		light_color = on  ? LIGHT_COLOR_GREEN : LIGHT_COLOR_RED
		if (light_obj)
			light_obj.cast_light(TRUE)

/obj/machinery/light_switch/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It is [on? "on" : "off"].</span>")

/obj/machinery/light_switch/attackby(obj/item/W as obj, mob/user as mob)
	switch(buildstage)
		if(2)
			if(W.is_screwdriver(user))
				to_chat(user, "You begin unscrewing \the [src].")
				W.playtoolsound(src, 50)
				if(do_after(user, src,10) && buildstage == 2)
					to_chat(user, "<span class='notice'>You unscrew the cover blocking the inner wiring of \the [src].</span>")
					buildstage = 1
					var/area/this_area = get_area(src)
					on = this_area.lightswitch
			return
		if(1)
			if(W.is_screwdriver(user))
				to_chat(user, "You begin screwing closed \the [src].")
				W.playtoolsound(src, 50)
				if(do_after(user, src,10) && buildstage == 1)
					to_chat(user, "<span class='notice'>You tightly screw closed the cover of \the [src].</span>")
					buildstage = 2
					power_change()
				return
			if(W.is_wirecutter(user))
				to_chat(user, "You begin cutting the wiring from \the [src].")
				W.playtoolsound(src, 50)
				if(do_after(user, src,10) && buildstage == 1)
					to_chat(user, "<span class='notice'>You cut the wiring to the lighting power line.</span>")
					new /obj/item/stack/cable_coil(get_turf(src),3)
					buildstage = 0
				return
		if(0)
			if(iscablecoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 3)
					to_chat(user, "<span class='warning'>You need at least two wire pieces for this!</span>")
					return
				to_chat(user, "You begin wiring \the [src].")
				if(do_after(user, src,10) && buildstage == 0)
					to_chat(user, "<span class='notice'>You wire \the [src]!.</span>")
					coil.use(3)
					buildstage = 1
				return
			if(iscrowbar(W))
				to_chat(user, "You begin prying \the [src] off the wall.")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src,10) && buildstage == 0)
					to_chat(user, "<span class='notice'>You pry the frame off of the wall.</span>")
					new /obj/item/mounted/frame/light_switch(get_turf(user))
					qdel(src)
				return
	return ..()

/obj/machinery/light_switch/attack_paw(mob/user)
	toggle_switch()

/obj/machinery/light_switch/attack_ghost(var/mob/dead/observer/ghost)
	if(!can_spook())
		return FALSE
	if(!ghost.can_poltergeist())
		to_chat(ghost, "Your poltergeist abilities are still cooling down.")
		return FALSE
	investigation_log(I_GHOST, "|| was switched [on ? "off" : "on"] by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
	return ..()

/obj/machinery/light_switch/attack_hand(mob/user)
	toggle_switch()

/obj/machinery/light_switch/proc/toggle_switch(var/newstate = null)
	if(!isnull(newstate) && on == newstate)
		return
	if(buildstage != 2)
		return
	on = !on
	playsound(src,'sound/misc/click.ogg',30,0,-1)
	var/area/this_area = get_area(src)
	this_area.lightswitch = on
	this_area.updateicon()

	for(var/obj/machinery/light_switch/L in this_area)
		L.on = on
		L.updateicon()

	this_area.power_change()

/obj/machinery/light_switch/power_change()
	if(powered(LIGHT))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	power_change()
	..(severity)

/obj/machinery/light_switch/npc_tamper_act(mob/living/L)
	attack_hand(L)

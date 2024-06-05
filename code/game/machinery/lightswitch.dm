// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var

var/list/obj/machinery/light_switch/lightswitches = list()

/obj/machinery/light_switch
	name = "light switch"
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/buildstage = 2
	var/on = 0
	var/image/overlay
	var/area/controlled_area

/obj/machinery/light_switch/supports_holomap()
	return TRUE

/obj/machinery/light_switch/New(var/loc, var/ndir, var/building = 2)
	..()
	controlled_area = get_area(src)
	name = "[controlled_area.name] light switch"
	buildstage = building
	controlled_area.haslightswitch = TRUE
	lightswitches += src
	controlled_area.lightswitches += src
	if(!buildstage)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER) : 0
		dir = ndir
	updateicon()
	update_moody_light('icons/lighting/moody_lights.dmi', "overlay_lightswitch")
	add_self_to_holomap()

/obj/machinery/light_switch/Destroy()
	lightswitches -= src
	controlled_area.lightswitches -= src
	..()

/obj/machinery/light_switch/proc/updateicon()
	if((stat & (FORCEDISABLE|NOPOWER)) || buildstage != 2)
		icon_state = "light-p"
		set_light(0)
	else
		icon_state = on ? "light1" : "light0"

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

/obj/machinery/light_switch/proc/toggle_switch(var/newstate = null, var/playsound = TRUE, var/non_instant = TRUE)
	if(on == newstate)
		return
	if(isnull(newstate))
		on = !on
	else
		on = newstate

	if(buildstage != 2)
		return

	if(playsound)
		playsound(src,'sound/misc/click.ogg',30,0,-1)

	if(controlled_area)
		controlled_area.lightswitches -= src
	controlled_area = get_area(src)
	controlled_area.lightswitches |= src
	controlled_area.updateicon()

	for(var/obj/machinery/light_switch/L in controlled_area.lightswitches)
		L.on = on
		L.updateicon()

	for(var/obj/machinery/L2 in controlled_area.lights)
		L2.power_change(non_instant)

/obj/machinery/light_switch/power_change()
	if(powered(LIGHT))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

	updateicon()

/obj/machinery/light_switch/emp_act(severity)
	if(stat & (BROKEN|FORCEDISABLE))
		..(severity)
		return
	power_change()
	..(severity)

/obj/machinery/light_switch/npc_tamper_act(mob/living/L)
	attack_hand(L)

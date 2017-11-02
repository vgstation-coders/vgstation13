// the light switch
// can have multiple per area
// can also operate on non-loc area through "otherarea" var
/obj/machinery/light_switch
	desc = "It turns lights on and off. What are you, simple?"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	anchored = 1.0
	var/buildstage = 2
	var/on = 0
	//	luminosity = 1

	holomap = TRUE
	auto_holomap = TRUE

/obj/machinery/light_switch/New(var/loc, var/ndir, var/building = 2)
	..()
	name = "[areaMaster.name] light switch"
	buildstage = building
	if(buildstage)
		on = areaMaster.lightswitch
	else
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER) : 0
		dir = ndir
	updateicon()

/obj/machinery/light_switch/proc/updateicon()
	if ((stat & NOPOWER) || buildstage != 2)
		icon_state = "light-p"
	else
		icon_state = on ? "light1" : "light0"

/obj/machinery/light_switch/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It is [on? "on" : "off"].</span>")

/obj/machinery/light_switch/attackby(obj/item/W as obj, mob/user as mob)
	switch(buildstage)
		if(2)
			if(isscrewdriver(W))
				to_chat(user, "You begin unscrewing \the [src].")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src,10) && buildstage == 2)
					to_chat(user, "<span class='notice'>You unscrew the cover blocking the inner wiring of \the [src].</span>")
					buildstage = 1
					on = areaMaster.lightswitch
			return
		if(1)
			if(isscrewdriver(W))
				to_chat(user, "You begin screwing closed \the [src].")
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src,10) && buildstage == 1)
					to_chat(user, "<span class='notice'>You tightly screw closed the cover of \the [src].</span>")
					buildstage = 2
					power_change()
				return
			if(iswirecutter(W))
				to_chat(user, "You begin cutting the wiring from \the [src].")
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
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
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src,10) && buildstage == 0)
					to_chat(user, "<span class='notice'>You pry the frame off of the wall.</span>")
					new /obj/item/mounted/frame/light_switch(get_turf(user))
					qdel(src)
				return
	return ..()

/obj/machinery/light_switch/attack_paw(mob/user)
	src.attack_hand(user)

/obj/machinery/light_switch/attack_ghost(var/mob/dead/observer/ghost)
	if(!can_spook())
		return FALSE
	if(!ghost.can_poltergeist())
		to_chat(ghost, "Your poltergeist abilities are still cooling down.")
		return FALSE
	investigation_log(I_GHOST, "|| was switched [on ? "off" : "on"] by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
	return ..()

/obj/machinery/light_switch/attack_hand(mob/user)
	if(buildstage != 2)
		return
	on = !on

	areaMaster.lightswitch = on
	areaMaster.updateicon()

	for(var/obj/machinery/light_switch/L in areaMaster)
		L.on = on
		L.updateicon()

	areaMaster.power_change()

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

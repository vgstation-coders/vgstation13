////////////////////HOLOSIGN///////////////////////////////////////
var/list/obj/machinery/holosign/holosigns = list()

/obj/machinery/holosign
	anchored = 1
	name = "holosign"
	desc = "Small wall-mounted holographic projector."
	icon = 'icons/obj/holosign.dmi'
	icon_state = "base"
	layer = ABOVE_DOOR_LAYER
	power_channel = LIGHT
	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0
	var/lit = 0
	var/on_icon = ""
	var/image/overlay

	light_color = "#6496FA"

/obj/machinery/holosign/New()
	..()
	holosigns += src
	update_icon()

/obj/machinery/holosign/Destroy()
	if (overlay)
		qdel(overlay)
		overlay = null
	..()

/obj/machinery/holosign/proc/toggle(var/active)
	if (stat & (BROKEN|NOPOWER))
		return
	lit = active
	update_icon()

/obj/machinery/holosign/update_icon()
	overlays.len = 0
	if(!lit || (stat & (NOPOWER|BROKEN)))
		kill_light()
		return
	if(!overlay)
		overlay = image(icon, on_icon)
		overlay.plane = ABOVE_LIGHTING_PLANE
		overlay.layer = ABOVE_LIGHTING_LAYER
	overlay.icon_state = on_icon
	overlays += overlay
	set_light(2,2)

/obj/machinery/holosign/power_change()
	..()
	update_icon()

/obj/machinery/holosign/Destroy()
	..()
	holosigns -= src

/obj/machinery/holosign/surgery
	name = "surgery holosign"
	desc = "Small wall-mounted holographic projector. This one reads SURGERY."
	on_icon = "surgery"
	id_tag = "surgery"

/obj/machinery/holosign/virology
	name = "virology holosign"
	desc = "Small wall-mounted holographic projector. This one reads BIOHAZARD."
	on_icon = "virology"
	id_tag = "virology"
	light_color = "#59FF79"

/obj/machinery/holosign/morgue
	name = "morgue holosign"
	desc = "Small wall-mounted holographic projector. This one reads MORGUE."
	on_icon = "morgue"
	id_tag = "morgue"
	var/should_update = FALSE

/obj/machinery/holosign/morgue/process()
	var/area/this_area = get_area(src)
	for(var/obj/structure/morgue in morgue_list)
		var/area/morgue_area = get_area(morgue)
		if(morgue_area != this_area)
			continue
		var/morgue_has_revivable_dude = (morgue.icon_state == "morgue4")
		if(morgue_has_revivable_dude)
			toggle(TRUE)
			should_update = FALSE
			return PROCESS_KILL
	toggle(FALSE)
	should_update = FALSE
	return PROCESS_KILL

////////////////////SWITCH///////////////////////////////////////

/obj/machinery/holosign_switch
	name = "holosign switch"
	icon = 'icons/obj/holosign.dmi'
	icon_state = "light0"
	desc = "A remote control switch for holosign."
	var/active = 0
	var/image/overlay
	anchored = 1.0
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/holosign_switch/New(var/turf/loc)
	..()
	update_icon()

/obj/machinery/holosign_switch/Destroy()
	if (overlay)
		qdel(overlay)
		overlay = null
	..()

/obj/machinery/holosign_switch/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/holosign_switch/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/holosign_switch/attackby(obj/item/weapon/W, mob/user as mob)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/holosign_switch/attack_hand(mob/user as mob)
	playsound(src,'sound/misc/click.ogg',30,0,-1)
	src.add_fingerprint(usr)
	if(stat & (NOPOWER|BROKEN))
		return
	add_fingerprint(user)

	use_power(5)

	active = !active

	update_icon()

	for(var/obj/machinery/holosign/M in holosigns)
		if (M.id_tag == src.id_tag)
			M.toggle(active)

/obj/machinery/holosign_switch/attack_ghost(var/mob/dead/observer/ghost)
	if(!can_spook())
		return FALSE
	if(!ghost.can_poltergeist())
		to_chat(ghost, "Your poltergeist abilities are still cooling down.")
		return FALSE
	investigation_log(I_GHOST, "|| was switched [active ? "off" : "on"] by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
	return ..()

/obj/machinery/holosign_switch/power_change()
	..()
	update_icon()

/obj/machinery/holosign_switch/update_icon()
	overlays.len = 0
	if(stat & (NOPOWER|BROKEN))
		icon_state = "light-p"
	else
		icon_state = active ? "light1" : "light0"
		if(!overlay)
			overlay = image(icon, "[icon_state]-overlay")
			overlay.plane = ABOVE_LIGHTING_PLANE
			overlay.layer = ABOVE_LIGHTING_LAYER
		overlay.icon_state = "[icon_state]-overlay"
		overlays += overlay

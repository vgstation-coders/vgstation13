/var/list/obj/machinery/telepad_cargo/cargo_telepads = list()

//CARGO TELEPAD//
/obj/machinery/telepad_cargo
	name = "cargo telepad"
	desc = "A telepad used by the Rapid Crate Sender."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "pad-idle"
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 20
	active_power_usage = 500
	var/stage = 0

/obj/machinery/telepad_cargo/New()
	global.cargo_telepads += src
	..()

/obj/machinery/telepad_cargo/Destroy()
	global.cargo_telepads -= src
	return ..()

/obj/machinery/telepad_cargo/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(W.is_wrench(user))
		W.playtoolsound(src, 50)
		anchored = !anchored
		to_chat(user, "<span class='caution'>\The [src] [anchored ? "is now secured" : "can now be moved"] .</span>")
	if(W.is_screwdriver(user))
		if(stage == 0)
			W.playtoolsound(src, 50)
			to_chat(user, "<span class = 'caution'>You unscrew the telepad's tracking beacon.</span>")
			stage = 1
		else if(stage == 1)
			W.playtoolsound(src, 50)
			to_chat(user, "<span class = 'caution'>You screw in the telepad's tracking beacon.</span>")
			stage = 0
	if(iswelder(W) && stage == 1)
		W.playtoolsound(src, 50)
		to_chat(user, "<span class = 'caution'>You disassemble the telepad.</span>")
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal(get_turf(src))
		M.amount = 1
		new /obj/item/stack/sheet/glass/glass(get_turf(src))
		qdel(src)

///TELEPAD CALLER///
/obj/item/device/telepad_beacon
	name = "telepad kit"
	desc = "Use to build a cargo telepad."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"
	origin_tech = Tc_BLUESPACE + "=3"

/obj/item/device/telepad_beacon/attack_self(mob/user as mob)
	if(user)
		to_chat(user, "<span class = 'caution'> Locked In</span>")
		new /obj/machinery/telepad_cargo(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

#define MODE_NORMAL 0
#define MODE_RANDOM 1

///HANDHELD TELEPAD USER///
/obj/item/weapon/rcs
	name = "rapid-crate-sender (RCS)"
	desc = "Use this to send crates to cargo telepads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "rcs"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	flags = FPRINT
	siemens_coefficient = 1
	force = 10
	throwforce  = 10
	throw_speed = 1
	throw_range = 5
	var/obj/item/weapon/cell/high/cell = null
	var/mode    = MODE_NORMAL
	var/send_cost = 1500
	var/send_note = FALSE
	var/no_station = FALSE
	var/tmp/teleporting = FALSE
	starting_materials	= list(MAT_IRON = 50000)

/obj/item/weapon/rcs/get_cell()
	return cell

/obj/item/weapon/rcs/New()
	..()
	cell = new (src)

/obj/item/weapon/rcs/examine(mob/user)
	..()
	if(send_cost > 0)
		to_chat(user, "<span class='info'>There are [round(cell.charge / send_cost)] charges left in the powercell.</span>")

/obj/item/weapon/rcs/Destroy()
	if (cell)
		QDEL_NULL(cell)
	..()

/obj/item/weapon/rcs/attack_self(mob/user)
	if(emagged)
		mode = !mode
		playsound(src, 'sound/effects/pop.ogg', 50, 0)
		if(mode == MODE_NORMAL)
			to_chat(user, "<span class = 'caution'>You calibrate the telepad locator.</span>")
		else
			to_chat(user, "<span class = 'caution'> The telepad locator has become uncalibrated.</span>")

/obj/item/weapon/rcs/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		spark(src, 5)
		to_chat(user, "<span class = 'caution'>You emag the RCS. Click on it to toggle between modes.</span>")

/obj/item/weapon/rcs/attackby(var/obj/item/W, var/mob/user)
	if(emag_check(W,user))
		return
	else if(W.is_screwdriver(user))
		if(cell)
			cell.updateicon()
			cell.forceMove(get_turf(loc))
			user.put_in_hands(cell)
			cell = null
			to_chat(user, "<span class='notice'>You remove the cell from the [src].</span>")
			playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
			update_icon()
	else if(ispowercell(W))
		if(!cell)
			if(user.drop_item(W, src))
				cell = W
				to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
				update_icon()
				playsound(src, 'sound/items/Screwdriver2.ogg', 50, 1)
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")

/obj/item/weapon/rcs/preattack(var/obj/structure/closet/crate/target, var/mob/user, var/proximity_flag, var/click_parameters)
	if (!istype(target) || target.opened || !proximity_flag || !cell || teleporting)
		return

	if (no_station && user.z == map.zMainStation)
		to_chat(user, "<span class='warning'>The safety prevents the sending of crates from the vicinity of Nanotrasen Station.</span>")
		return

	if (cell.charge < send_cost)
		to_chat(user, "<span class='warning'>Out of charges.</span>")
		return 1

	// Get location to teleport to.
	var/turf/teleport_target
	if (mode == MODE_NORMAL)
		var/list/obj/machinery/telepad_cargo/input_list = list()
		var/list/area_index = list()
		for (var/obj/machinery/telepad_cargo/telepad in cargo_telepads)
			var/turf/T = get_turf(telepad)
			if (!T)
				continue

			var/area_name = T.loc.name
			if (area_index[area_name])
				area_name = "[area_name] ([++area_index[area_name]])"
			else
				area_index[area_name] = 1

			input_list[area_name] = telepad

		var/inputted = input("Which telepad to teleport to?", "RCS") as null | anything in input_list
		if (!inputted || !user || user.isUnconscious() || !target || !user.Adjacent(target) || teleporting || cell.charge < send_cost)
			return 1

		var/obj/machinery/telepad_cargo/telepad = input_list[inputted]
		if (!telepad || !telepad.loc)
			return 1

		teleport_target = get_turf(telepad)

	else if (mode == MODE_RANDOM)
		teleport_target = locate(rand(50, 450), rand(50, 450), 6)

	var/obj/item/weapon/paper/P

	if(send_note)
		var/note = copytext(sanitize(input("Would you like to attach a note?", "Autoletter") as null|text),1,MAX_MESSAGE_LEN)
		if(note)
			P = new(null) //This will be deleted if the teleport doesn't complete. Avoids generating extra notes.
			P.name = "letter from [user]"
			P.info = note

	//After inputs to prevent process-pause exploitation
	var/area/A = get_area(target)
	if(A.jammed || A.flags & (NO_TELEPORT|NO_PORTALS))
		to_chat(user, "<span class='warning'>You can not teleport \the [target] from here, due to bluespace interference.</span>")
		return

	playsound(src, 'sound/machines/click.ogg', 50, 1)
	to_chat(user, "<span class='notice'>Teleporting \the [target]...</span>")
	teleporting = TRUE
	if (!do_after(user, target, 50))
		teleporting = FALSE
		if(P)
			qdel(P)
		return 1

	teleporting = FALSE
	do_teleport(target, teleport_target)
	if(P)
		P.forceMove(target)
	/*spark(src, 5)*/
	cell.use(send_cost)
	to_chat(user, "<span class='notice'>Teleport successful. [send_cost ? "[round(cell.charge / send_cost)] charge\s left." : "Caw."]</span>")
	return 1

/obj/item/weapon/rcs/salvage
	name = "salvage-crate-sender (SCS)"
	desc = "An old RCS model that has been modified for longterm use."
	icon = 'icons/obj/device.dmi'
	icon_state = "dest_tagger_p"
	send_cost = 0
	send_note = TRUE
	no_station = TRUE

/obj/item/weapon/rcs/salvage/syndicate
	desc = "An old RCS model that has been modified for longterm use. Upon closer inspection, it appears that the safety features on this device are disabled."
	no_station = FALSE
	emagged = 1

#undef MODE_NORMAL
#undef MODE_RANDOM

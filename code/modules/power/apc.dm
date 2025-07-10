#define APC_WIRE_IDSCAN 1
#define APC_WIRE_MAIN_POWER1 2
#define APC_WIRE_MAIN_POWER2 3
#define APC_WIRE_AI_CONTROL 4

//update_state
#define UPSTATE_CELL_IN 1
#define UPSTATE_OPENED1 2
#define UPSTATE_OPENED2 4
#define UPSTATE_MAINT 8
#define UPSTATE_BROKE 16
#define UPSTATE_BLUESCREEN 32
#define UPSTATE_WIREEXP 64
#define UPSTATE_ALLGOOD 128
#define UPSTATE_SHUNT 256

//update_overlay
#define APC_UPOVERLAY_CHARGEING0 1
#define APC_UPOVERLAY_CHARGEING1 2
#define APC_UPOVERLAY_CHARGEING2 4
#define APC_UPOVERLAY_EQUIPMENT0 8
#define APC_UPOVERLAY_EQUIPMENT1 16
#define APC_UPOVERLAY_EQUIPMENT2 32
#define APC_UPOVERLAY_LIGHTING0 64
#define APC_UPOVERLAY_LIGHTING1 128
#define APC_UPOVERLAY_LIGHTING2 256
#define APC_UPOVERLAY_ENVIRON0 512
#define APC_UPOVERLAY_ENVIRON1 1024
#define APC_UPOVERLAY_ENVIRON2 2048
#define APC_UPOVERLAY_LOCKED 4096
#define APC_UPOVERLAY_OPERATING 8192

#define APC_UPDATE_ICON_COOLDOWN 100 // 10 seconds

#define APC_CHANNEL_STATUS_OFF 		0
#define APC_CHANNEL_STATUS_AUTO_OFF 1
#define APC_CHANNEL_STATUS_ON 		2
#define APC_CHANNEL_STATUS_AUTO_ON 	3


// the Area Power Controller (APC), formerly Power Distribution Unit (PDU)
// one per area, needs wire conection to power network through a terminal

// controls power to devices in that area
// may be opened to change power cell
// three different channels (lighting/equipment/environ) - may each be set to on, off, or auto


//NOTE: STUFF STOLEN FROM AIRLOCK.DM thx


/obj/machinery/power/apc
	desc = "A control terminal for the area's electrical systems."
	icon_state = "apc0"
	anchored = 1
	use_power = MACHINE_POWER_USE_NONE
	req_access = list(access_engine_minor)
	var/spooky=0
	var/pulsecompromising=0
	var/obj/item/weapon/cell/cell
	var/start_charge = 90				// initial cell charge %
	var/old_charge = 0					// how much charge did this thing have before a random event knocked it out
	var/cell_type = 2500				// 0=no cell, 1=regular, 2=high-cap (x5) <- old, now it's just 0=no cell, otherwise dictate cellcapacity by changing this value. 1 used to be 1000, 2 was 2500
	var/cell_type_path = /obj/item/weapon/cell
	var/opened = 0                      //0=closed, 1=opened, 2=cover removed
	var/shorted = 0
	var/lighting = 3
	var/equipment = 3
	var/environ = 3
	var/operating = 1
	var/charging = 0
	var/charge_diff = 0 				// How much charge we've gained or lost this tick (an APC can be charging and still be losing charge depending on priorities and statisfaction)
	var/chargemode = 1
	var/chargecount = 0
	var/locked = 1
	var/coverlocked = 1
	var/tdir = null
	var/lastused_light = 0
	var/lastused_equip = 0
	var/lastused_environ = 0
	var/lastused_total = 0
	var/main_status = 0
	var/wiresexposed = 0
	powernet = 0		// set so that APCs aren't found as powernet nodes //Hackish, Horrible, was like this before I changed it :(
	var/malfhack = 0 //New var for my changes to AI malf. --NeoFite
	var/mob/living/silicon/ai/malfai = null //See above --NeoFite
	var/mob/living/silicon/ai/currently_hacking_ai = null
	var/malflocked = 0 //used for malfs locking down APCs
//	luminosity = 1
	var/has_electronics = 0 // 0 - none, 1 - plugged in, 2 - secured by screwdriver
	var/beenhit = 0 // used for counting how many times it has been hit, used for Aliens at the moment
	var/mob/living/silicon/ai/occupant = null
	var/longtermpower = 10
	var/update_state = -1
	var/update_overlay = -1
	var/global/status_overlays = 0
	var/updating_icon = 0
	var/datum/wires/apc/wires = null
	var/global/list/status_overlays_lock
	var/global/list/status_overlays_charging
	var/global/list/status_overlays_equipment
	var/global/list/status_overlays_lighting
	var/global/list/status_overlays_environ

	var/is_critical = 0 // Endgame scenarios will not destroy this APC.

	var/make_alerts = TRUE // Should this APC make power alerts to the area?
	var/atom/movable/fake_camera_image/malfimage

	machine_flags = WIREJACK

	plane = OBJ_PLANE

	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_APC_RED

	power_priority = POWER_PRIORITY_APC
	var/power_recharge_priority = POWER_PRIORITY_APC_RECHARGE // Should always be at least one level lower than power_priority
	monitoring_enabled = TRUE

	var/recharge_load = 0 // How much power we've requested for recharging purposes

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/power/apc/supports_holomap()
	return TRUE

/obj/machinery/power/apc/no_alerts
	make_alerts = FALSE

// Frame only.
/obj/machinery/power/apc/frame
	icon_state = "apcmaint"
	light_range = 0
	light_power = 0

/obj/machinery/power/apc/frame/New()
	return ..(loc, dir, 1)

/obj/machinery/power/apc/New(loc, var/ndir, var/building=0)
	..(loc)

	wires = new(src)
	// offset 24 pixels in direction of dir
	// this allows the APC to be embedded in a wall, yet still inside an area
	if (building)
		dir = ndir
	src.tdir = dir		// to fix Vars bug
	dir = SOUTH

	if(src.tdir & 3)
		pixel_x = 0
		pixel_y = (src.tdir == 1 ? 24 * PIXEL_MULTIPLIER: -24 * PIXEL_MULTIPLIER)
	else
		pixel_x = (src.tdir == 4 ? 24 * PIXEL_MULTIPLIER: -24 * PIXEL_MULTIPLIER)
		pixel_y = 0

	if (building==0)
		init()
	else
		opened = 1
		operating = 0
		stat |= MAINT

	if(ticker && ticker.current_state == GAME_STATE_PLAYING)
		initialize()
		update()

/obj/machinery/power/apc/proc/init()
	has_electronics = 2 //installed and secured
	// is starting with a power cell installed, create it and set its charge level
	if(cell_type)
		src.cell = new cell_type_path(src)
		cell.maxcharge = cell_type	// cell_type is maximum charge (old default was 1000 or 2500 (values one and two respectively)
		cell.charge = start_charge * cell.maxcharge / 100.0 		// (convert percentage to actual value)

	finalise_terminal() //creates the terminal itself

/obj/machinery/power/apc/finalise_terminal()
	// create a terminal object at the same position as original turf loc
	// wires will attach to this
	terminal = new/obj/machinery/power/terminal(src.loc)
	terminal.dir = tdir
	terminal.master = src
	terminal.add_self_to_holomap()

/obj/machinery/power/apc/initialize()
	..()
	var/area/this_area = get_area(src)
	if(this_area.areaapc || this_area.forbid_apc)
		var/turf/T = get_turf(src)
		world.log << "[this_area.forbid_apc ? "Forbidden" : "Second"] APC detected in area: [this_area.name] [T.x], [T.y], [T.z]. Deleting the second APC."
		qdel(src)
		return

	name = "[this_area.name] APC"

	this_area.set_apc(src)

	update_icon()
	add_self_to_holomap()

/obj/machinery/power/apc/examine(mob/user)
	..()
	if(stat & BROKEN)
		to_chat(user, "Looks broken.")
		return
	if(opened)
		if(has_electronics && terminal)
			to_chat(user, "The cover is [opened==2?"removed":"open"] and the power cell is [ cell ? "installed" : "missing"].")
		else if (!has_electronics && terminal)
			to_chat(user, "There are some wires but no any electronics.")
		else if (has_electronics && !terminal)
			to_chat(user, "Electronics installed but not wired.")
		else /* if (!has_electronics && !terminal) */
			to_chat(user, "There is no electronics nor connected wires.")
	else
		if (stat & MAINT)
			to_chat(user, "The cover is closed. Something wrong with it: it doesn't work.")
		else if (malfhack)
			to_chat(user, "The cover is broken. It may be hard to force it open.")
		else
			to_chat(user, "The cover is closed.")

/obj/machinery/power/apc/update_icon()
	if (!status_overlays)
		status_overlays = 1
		status_overlays_lock = new
		status_overlays_charging = new
		status_overlays_equipment = new
		status_overlays_lighting = new
		status_overlays_environ = new

		status_overlays_lock.len = 2
		status_overlays_charging.len = 3
		status_overlays_equipment.len = 4
		status_overlays_lighting.len = 4
		status_overlays_environ.len = 4

		status_overlays_lock[1] = image(icon, "apcox-0")    // 0=blue 1=red
		status_overlays_lock[2] = image(icon, "apcox-1")

		status_overlays_charging[1] = image(icon, "apco3-0")
		status_overlays_charging[2] = image(icon, "apco3-1")
		status_overlays_charging[3] = image(icon, "apco3-2")

		status_overlays_equipment[1] = image(icon, "apco0-0") // 0=red, 1=green, 2=blue
		status_overlays_equipment[2] = image(icon, "apco0-1")
		status_overlays_equipment[3] = image(icon, "apco0-2")
		status_overlays_equipment[4] = image(icon, "apco0-3")

		status_overlays_lighting[1] = image(icon, "apco1-0")
		status_overlays_lighting[2] = image(icon, "apco1-1")
		status_overlays_lighting[3] = image(icon, "apco1-2")
		status_overlays_lighting[4] = image(icon, "apco1-3")

		status_overlays_environ[1] = image(icon, "apco2-0")
		status_overlays_environ[2] = image(icon, "apco2-1")
		status_overlays_environ[3] = image(icon, "apco2-2")
		status_overlays_environ[4] = image(icon, "apco2-3")



	var/update = check_updates() 		//returns 0 if no need to update icons.
						// 1 if we need to update the icon_state
						// 2 if we need to update the overlays
	if(!update)
		return

	if(update & 1) // Updating the icon state
		if(update_state & UPSTATE_ALLGOOD)
			icon_state = "apc0"
			light_range = 1
			light_power = 1
		else if(update_state & (UPSTATE_OPENED1|UPSTATE_OPENED2))
			var/basestate = "apc[ cell ? "2" : "1" ]"
			light_range = 0
			light_power = 0
			if(update_state & UPSTATE_OPENED1)
				if(update_state & (UPSTATE_MAINT|UPSTATE_BROKE))
					icon_state = "apcmaint" //disabled APC cannot hold cell
				else
					icon_state = basestate
			else if(update_state & UPSTATE_OPENED2)
				icon_state = "[basestate]-nocover"
		else if(update_state & UPSTATE_BROKE)
			icon_state = "apc-b"
			light_range = 0
			light_power = 0
		else if(update_state & UPSTATE_SHUNT)
			light_range = 1
			light_power = 1
			icon_state = "apcshunt"
		else if(update_state & UPSTATE_BLUESCREEN)
			icon_state = "apcemag"
			light_range = 1
			light_power = 1
		else if(update_state & UPSTATE_WIREEXP)
			icon_state = "apcewires"
			light_range = 0
			light_power = 0

	if (!(stat & (BROKEN|MAINT)))
		if(update_state & UPSTATE_SHUNT)
			light_color = LIGHT_COLOR_APC_SHUNT
		else if (update_state & UPSTATE_BLUESCREEN)
			light_color = LIGHT_COLOR_APC_BLUE
		else
			switch (charging)
				if (0)
					light_color = LIGHT_COLOR_APC_RED
				if (1)
					light_color = LIGHT_COLOR_APC_YELLOW
				if (2)
					light_color = LIGHT_COLOR_APC_GREEN

	if(!(update_state & UPSTATE_ALLGOOD))
		if(overlays.len)
			overlays = 0
			if (!(stat & (BROKEN|MAINT)) && light_range)
				update_moody_light('icons/lighting/moody_lights.dmi', "overlay_apc", 255, light_color)
			return
	if(update & 2)

		if(overlays.len)
			overlays = 0

		if(!(stat & (BROKEN|MAINT)) && update_state & UPSTATE_ALLGOOD)
			overlays += status_overlays_lock[locked+1]
			overlays += status_overlays_charging[charging+1]
			if(operating)
				overlays += status_overlays_equipment[equipment+1]
				overlays += status_overlays_lighting[lighting+1]
				overlays += status_overlays_environ[environ+1]

	if (!(stat & (BROKEN|MAINT)) && light_range)
		update_moody_light('icons/lighting/moody_lights.dmi', "overlay_apc", 255, light_color)


/obj/machinery/power/apc/proc/check_updates()


	var/last_update_state = update_state
	var/last_update_overlay = update_overlay
	update_state = 0
	update_overlay = 0

	if(cell)
		update_state |= UPSTATE_CELL_IN
	if(stat & BROKEN)
		update_state |= UPSTATE_BROKE
	if(stat & MAINT)
		update_state |= UPSTATE_MAINT
	if(opened)
		if(opened==1)
			update_state |= UPSTATE_OPENED1
		if(opened==2)
			update_state |= UPSTATE_OPENED2
	else if(malfai && occupant)
		update_state |= UPSTATE_SHUNT
	else if(emagged || malfai || spooky || pulsecompromising)
		update_state |= UPSTATE_BLUESCREEN
	else if(wiresexposed)
		update_state |= UPSTATE_WIREEXP
	if(update_state <= 1)
		update_state |= UPSTATE_ALLGOOD

	if(operating)
		update_overlay |= APC_UPOVERLAY_OPERATING

	if(update_state & UPSTATE_ALLGOOD)
		if(locked)
			update_overlay |= APC_UPOVERLAY_LOCKED

		if(!charging)
			update_overlay |= APC_UPOVERLAY_CHARGEING0
		else if(charging == 1)
			update_overlay |= APC_UPOVERLAY_CHARGEING1
		else if(charging == 2)
			update_overlay |= APC_UPOVERLAY_CHARGEING2

		if (!equipment)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT0
		else if(equipment == 1)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT1
		else if(equipment == 2)
			update_overlay |= APC_UPOVERLAY_EQUIPMENT2

		if(!lighting)
			update_overlay |= APC_UPOVERLAY_LIGHTING0
		else if(lighting == 1)
			update_overlay |= APC_UPOVERLAY_LIGHTING1
		else if(lighting == 2)
			update_overlay |= APC_UPOVERLAY_LIGHTING2

		if(!environ)
			update_overlay |= APC_UPOVERLAY_ENVIRON0
		else if(environ==1)
			update_overlay |= APC_UPOVERLAY_ENVIRON1
		else if(environ==2)
			update_overlay |= APC_UPOVERLAY_ENVIRON2

	var/results = 0
	if(last_update_state == update_state && last_update_overlay == update_overlay)
		return 0
	if(last_update_state != update_state)
		results += 1
	if(last_update_overlay != update_overlay && update_overlay != 0)
		results += 2
	return results




// Used in process so it doesn't update the icon too much
/obj/machinery/power/apc/proc/queue_icon_update()


	if(!updating_icon)
		updating_icon = 1
		// Start the update
		spawn(APC_UPDATE_ICON_COOLDOWN)
			update_icon()
			updating_icon = 0

/obj/machinery/power/apc/spook(mob/dead/observer/ghost)
	if(spooky)
		return // Fuck you we're already spooky
	if(!..(ghost, TRUE))
		return //If blessed, return

	spooky=1
	update_icon()
	spawn(10)
		spooky=0
		update_icon()

//attack with an item - open/close cover, insert cell, or (un)lock interface
/obj/machinery/power/apc/attackby(obj/item/W, mob/living/user)

	src.add_fingerprint(user)

	if (iswiretool(W) && wiresexposed)
		wires.Interact(user)
		return

	if (istype(user, /mob/living/silicon) && get_dist(src,user)>1)
		return src.attack_hand(user)

	if (iscrowbar(W) && opened)
		if (has_electronics==1)
			if (terminal)
				to_chat(user, "<span class='warning'>Disconnect wires first.</span>")
				return
			W.playtoolsound(src, 50)
			to_chat(user, "You are trying to remove the power control board...")//lpeters - fixed grammar issues

			if (do_after(user, src, 50) && opened && !terminal && has_electronics == 1)
				has_electronics = 0
				if ((stat & BROKEN) || malfhack)
					user.visible_message(\
						"<span class='warning'>[user.name] has broken the power control board inside [src.name]!</span>",\
						"You broke the charred power control board and remove the remains.",
						"You hear a crack!")
					//ticker.mode:apcs-- //XSI said no and I agreed. -rastaf0
				else
					user.visible_message(\
						"<span class='warning'>[user.name] has removed the power control board from [src.name]!</span>",\
						"You remove the power control board.")
					new /obj/item/weapon/circuitboard/power_control(loc)
		else if (opened!=2) //cover isn't removed
			opened = 0
			update_icon()
	else if (iscrowbar(W) && !((stat & BROKEN) || malfhack) )
		if(coverlocked && !(stat & MAINT))
			to_chat(user, "<span class='warning'>The cover is locked and cannot be opened.</span>")
			return
		else if (wiresexposed)
			to_chat(user, "<span class='warning'>Unexpose the wires first!</span>")
		else
			opened = 1
			update_icon()
	else if	(istype(W, /obj/item/weapon/cell) && opened)	// trying to put a cell inside
		if(cell)

			if(user.drop_item(W, src))
				to_chat(user, "You swap the power cell within with the new cell in your hand.")
				var/obj/item/weapon/oldpowercell = cell
				cell = W
				if(cell.occupant && !pulsecompromised)
					cell.occupant.forceMove(src)
					cell.occupant.hijackAPC(src)
					cell.occupant.current_power = src
				chargecount = 0
				update_icon()
				user.put_in_hands(oldpowercell)
				return

		else
			if (stat & MAINT)
				to_chat(user, "<span class='warning'>There is no connector for your power cell.</span>")
				return
			if(user.drop_item(W, src))
				cell = W
				if(cell.occupant && !pulsecompromised)
					cell.occupant.forceMove(src)
					cell.occupant.hijackAPC(src)
					cell.occupant.current_power = src
				user.visible_message(\
					"<span class='warning'>[user.name] has inserted the power cell to [src.name]!</span>",\
					"You insert the power cell.")
				chargecount = 0
				update_icon()
	else if	(W.is_screwdriver(user))	// haxing
		if(opened)
			if (cell)
				to_chat(user, "<span class='warning'>Close the APC first.</span>")//Less hints more mystery!

				return
			else
				if (has_electronics==1 && terminal)
					has_electronics = 2
					stat &= ~MAINT
					W.playtoolsound(src, 50)
					to_chat(user, "You screw the circuit electronics into place.")
				else if (has_electronics==2)
					has_electronics = 1
					stat |= MAINT
					W.playtoolsound(src, 50)
					to_chat(user, "You unfasten the electronics.")
				else /* has_electronics==0 */
					to_chat(user, "<span class='warning'>There is nothing to secure.</span>")
					return
				update_icon()
		else
			if(has_electronics == 2 && !(stat & BROKEN))
				wiresexposed = !wiresexposed
				to_chat(user, "The wires have been [wiresexposed ? "exposed" : "unexposed"].")
				W.playtoolsound(src, 25, extrarange = -6)
				update_icon()
			else
				to_chat(user, "<span class='warning'>You open the panel and find nothing inside.</span>")
				return

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))			// trying to unlock the interface with an ID card
		if(emagged)
			to_chat(user, "The lock seems broken.")
		else if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			if(src.allowed(usr) && !isWireCut(APC_WIRE_IDSCAN))
				locked = !locked
				to_chat(user, "You [ locked ? "lock" : "unlock"] the APC interface.")
				update_icon()
				nanomanager.update_uis(src)
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else if (isEmag(W) && !(emagged || malfhack))		// trying to unlock with an emag card
		if(opened)
			to_chat(user, "You must close the cover to swipe an ID card.")
		else if(wiresexposed)
			to_chat(user, "You must close the panel first")
		else if(stat & (BROKEN|MAINT))
			to_chat(user, "Nothing happens.")
		else
			flick("apc-spark", src)
			if (do_after(user, src, 6) && !opened && !wiresexposed && !(stat & (BROKEN|MAINT)) && !emagged)
				if(prob(50))
					emagged = 1
					locked = 0
					to_chat(user, "You emag the APC interface.")
					update_icon()
					nanomanager.update_uis(src)
				else
					to_chat(user, "You fail to [ locked ? "unlock" : "lock"] the APC interface.")
	else if (istype(W, /obj/item/stack/cable_coil) && !terminal && opened && has_electronics != 2)
		var/obj/item/stack/cable_coil/C = W
		if(C.amount < 10)
			to_chat(user, "<span class='warning'>You need more wires.</span>")
			return

		if(make_terminal(user))
			C.use(10)
			terminal.connect_to_network()

	else if (W.is_wirecutter(user) && opened && terminal && has_electronics!=2)
		var/turf/T = get_turf(src)
		if (T.intact)
			to_chat(user, "<span class='warning'>You must remove the floor plating in front of the APC first.</span>")
			return
		to_chat(user, "You begin to cut the cables...")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if (do_after(user, src, 50) && opened && terminal && has_electronics != 2 && !T.intact)
			if (prob(50) && electrocute_mob(usr, terminal.get_powernet(), terminal))
				spark(src, 5)
				return
			new /obj/item/stack/cable_coil(get_turf(user), 10)
			user.visible_message(\
				"<span class='warning'>[user.name] cut the cables and dismantled the power terminal.</span>",\
				"You cut the cables and dismantle the power terminal.")
			QDEL_NULL(terminal)
	else if (istype(W, /obj/item/weapon/circuitboard/power_control) && opened && has_electronics==0 && !((stat & BROKEN) || malfhack))
		to_chat(user, "You begin to insert the power control board into the frame...")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if (do_after(user, src, 10) && opened && has_electronics == 0 && !((stat & BROKEN) || malfhack))
			has_electronics = 1
			to_chat(user, "You place the power control board inside the frame.")
			QDEL_NULL(W)
	else if (istype(W, /obj/item/weapon/circuitboard/power_control) && opened && has_electronics==0 && ((stat & BROKEN) || malfhack))
		to_chat(user, "<span class='warning'>You cannot put the board inside, the frame is damaged.</span>")
		return
	else if (iswelder(W) && opened && has_electronics==0 && !terminal)
		var/obj/item/tool/weldingtool/WT = W
		to_chat(user, "You start welding the APC frame...")
		if (WT.do_weld(user, src, 50, 3))
			if (emagged || malfhack || (stat & BROKEN) || opened==2)
				new /obj/item/stack/sheet/metal(get_turf(src), 1)
				user.visible_message(\
					"<span class='warning'>[src] has been cut apart by [user.name] with the weldingtool.</span>",\
					"You disassembled the broken APC frame.",\
					"<span class='warning'>You hear welding.</span>")
			else
				new /obj/item/mounted/frame/apc_frame(loc)
				user.visible_message(\
					"<span class='warning'>[src] has been cut from the wall by [user.name] with the weldingtool.</span>",\
					"You cut the APC frame from the wall.",\
					"<span class='warning'>You hear welding.</span>")
			if(cell)
				cell.forceMove(loc)
				cell = null
			qdel(src)
			return
	else if (istype(W, /obj/item/mounted/frame/apc_frame) && opened && emagged)
		emagged = 0
		if (opened==2)
			opened = 1
		user.visible_message(\
			"<span class='warning'>[user.name] has replaced the damaged APC frontal panel with a new one.</span>",\
			"You replace the damaged APC frontal panel with a new one.")
		QDEL_NULL(W)
		update_icon()
	else if (istype(W, /obj/item/mounted/frame/apc_frame) && opened && ((stat & BROKEN) || malfhack))
		if (has_electronics)
			to_chat(user, "You cannot repair this APC until you remove the electronics still inside.")
			return
		to_chat(user, "You begin to replace the damaged APC frame...")
		if(do_after(user, src, 50))
			user.visible_message(\
				"<span class='warning'>[user.name] has replaced the damaged APC frame with new one.</span>",\
				"You replace the damaged APC frame with new one.")
			QDEL_NULL(W)
			stat &= ~BROKEN
			if(malfai)
				var/datum/role/malfAI/M = malfai.mind.GetRole(MALF)
				M.apcs -= src
				malfai = null
				malfhack = 0
			if (opened==2)
				opened = 1
			update_icon()
	else if(istype(W, /obj/item/weapon/kitchen/utensil/fork) && opened) // Sticking fork in open APC shocks you
		to_chat(user, "<span class='warning'>That was really, really dumb of you.</span>") // Why would you even do this
		shock(user, 75, W.siemens_coefficient)
	else if (istype(W, /obj/item/weapon/storage/bag/gadgets/part_replacer))
		exchange_parts(user, W)
	else
		// The extra crowbar thing fixes MoMMIs not being able to remove APCs.
		// They can just pop them off with a crowbar.
		if (((stat & BROKEN) || malfhack) && !opened && ((W.force >= 5 && W.w_class >= W_CLASS_MEDIUM) || istype(W,/obj/item/tool/crowbar)))
			user.do_attack_animation(src, W)
			playsound(src, 'sound/items/metal_impact.ogg', 75, 1)
			shake(1, 3)
			user.delayNextAttack(8)
			if (prob(20))
				opened = 2
				wiresexposed = 0 //The cover is gone
				user.visible_message("<span class='warning'>The APC cover was knocked down with the [W.name] by [user.name]!</span>", \
					"<span class='warning'>You knock down the APC cover with your [W.name]!</span>", \
					"You hear something metallic being hit, and falling on the floor.")
				update_icon()
			else
				user.visible_message("<span class='warning'>\The [user.name] hits the broken APC's cover with \a [W.name]!</span>", \
					"<span class='warning'>You hit the APC's cover with your [W.name]!</span>", \
					"You hear something metallic being hit.")

		else
			if (istype(user, /mob/living/silicon))
				return src.attack_hand(user)
			/*user.visible_message("<span class='warning'>The [src.name] has been hit with the [W.name] by [user.name]!</span>", \
				"<span class='warning'>You hit the [src.name] with your [W.name]!</span>", \
				"You hear bang")*/
			..() //Sanity

/obj/machinery/power/apc/exchange_parts(mob/user, obj/item/weapon/storage/bag/gadgets/part_replacer/W)
	if (W.bluespace || wiresexposed || opened)
		var/obj/item/weapon/cell/max_cell
		for(var/obj/item/weapon/cell/component in W.contents)
			if (!max_cell || (max_cell.rating < component.rating))
				max_cell = component


		if (max_cell && max_cell.rating > cell.rating)
			W.remove_from_storage(max_cell, src)
			W.handle_item_insertion(cell, 1)
			to_chat(user, "<span class='notice'>[cell.name] replaced with [max_cell.name].</span>")
			cell = max_cell
			cell_type = max_cell.maxcharge
			max_cell.forceMove(null)
			W.play_rped_sound()
		else
			to_chat(user, "<span class='notice'>No power cell of higher grade detected.</span>")

// attack with hand - remove cell (if cover open) or interact with the APC

/obj/machinery/power/apc/attack_hand(mob/user)
	if (!can_use(user))
		return
	if(!isobserver(user))
		src.add_fingerprint(user)
		if(usr == user && opened)
			if(cell && Adjacent(user))
				if(isAI(user))
					interact(user)
					return
				else if(issilicon(user) && !isMoMMI(user)) // MoMMIs can hold one item in their tool slot.
					cell.forceMove(src.loc) // Drop it, whoops.
				else
					user.put_in_hands(cell)

				cell.add_fingerprint(user)
				cell.updateicon()

				src.cell = null
				user.visible_message("<span class='warning'>[user.name] removes the power cell from [src.name]!</span>", "You remove the power cell.")
//				to_chat(user, "You remove the power cell.")
				charging = 0
				src.update_icon()
			return
		if(stat & (BROKEN|MAINT))
			return

	src.interact(user)

/obj/machinery/power/apc/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(!user)
		return
	user.do_attack_animation(src, user)
	user.delayNextAttack(8)
	user.visible_message("<span class='warning'>[user.name] slashes at the [src.name]!</span>", "<span class='notice'>You slash at the [src.name]!</span>")
	playsound(src, 'sound/weapons/slash.ogg', 100, 1)

	var/allcut = wires.IsAllCut()

	if(beenhit >= pick(3, 4) && (!wiresexposed && !opened))
		beenhit = 0
		wiresexposed = 1
		src.update_icon()
		src.visible_message("<span class='warning'>The [src.name]'s cover flies open, exposing the wires!</span>")

	else if((wiresexposed || opened) && allcut == 0)
		wires.CutAll()
		src.update_icon()
		src.visible_message("<span class='warning'>The [src.name]'s wires are shredded!</span>")
	else
		beenhit += 1
	return


/obj/machinery/power/apc/updateDialog()
	if(in_use)
		var/list/nearby = viewers(1, src)
		var/is_in_use = 0
		for(var/mob/M in _using)
			if (!M || !M.client || M.machine != src)
				_using.Remove(M)
				continue
			if(!isAI(M) && !isrobot(M) && !(M in nearby))
				_using.Remove(M)
				continue
			is_in_use = 1
			if (wiresexposed)
				wires.Interact(M)
			else
				interact(M)
		in_use = is_in_use

/obj/machinery/power/apc/interact(mob/user)
	if (!user)
		return

	if (stat & (BROKEN | MAINT | EMPED))
		return

	ui_interact(user)

/obj/machinery/power/apc/proc/get_malf_status(var/mob/living/silicon/ai/user)
	var/datum/role/malfAI/M = user.mind.GetRole(MALF)
	if(!istype(M))
		return 0 // 0 = User is not a Malf AI
	if(src in M.currently_hacking_apcs)
		return 5 		//5 - currently being hacked
	if (istype(user) && M)
		if (malfai == (user.parent ? user.parent : user))
			if (occupant == user)
				return 3 // 3 = User is shunted in this APC
			else if (istype(user.loc, /obj/machinery/power/apc))
				return 4 // 4 = User is shunted in another APC
			else
				return 2 // 2 = APC hacked by user, and user is in its core.
		else
			return 1 // 1 = APC not hacked.
	else
		return 0 // 0 = User is not a Malf AI

/obj/machinery/power/apc/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	if(!user)
		return

	var/list/data = list(
		"locked" = locked,
		"isOperating" = operating,
		"externalPower" = main_status,
		"powerCellStatus" = cell ? cell.percent() : null,
		"powerCellCharge" = cell ? round(cell.charge) : null,
		"powerCellMaxCharge" = cell ? cell.maxcharge : null,
		"chargeMode" = chargemode,
		"chargingStatus" = charging,
		"totalLoad" = lastused_equip + lastused_light + lastused_environ,
		"coverLocked" = coverlocked,
		"siliconUser" = istype(user, /mob/living/silicon) || isAdminGhost(user) || OMNI_LINK(user,src), // Allow aghosts to fuck with APCs
		"malfLocked"= malflocked,
		"malfStatus" = get_malf_status(user),

		"powerChannels" = list(
			list(
				"title" = "Equipment",
				"powerLoad" = lastused_equip,
				"status" = equipment,
				"topicParams" = list(
					"auto" = list("eqp" = 3),
					"on"   = list("eqp" = 2),
					"off"  = list("eqp" = 1)
				)
			),
			list(
				"title" = "Lighting",
				"powerLoad" = lastused_light,
				"status" = lighting,
				"topicParams" = list(
					"auto" = list("lgt" = 3),
					"on"   = list("lgt" = 2),
					"off"  = list("lgt" = 1)
				)
			),
			list(
				"title" = "Environment",
				"powerLoad" = lastused_environ,
				"status" = environ,
				"topicParams" = list(
					"auto" = list("env" = 3),
					"on"   = list("env" = 2),
					"off"  = list("env" = 1)
				)
			)
		)
	)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		// the ui does not exist, so we'll create a new one
        // for a list of parameters and their descriptions see the code docs in \code\\modules\nano\nanoui.dm
		var/area/this_area = get_area(src)
		ui = new(user, src, ui_key, "apc.tmpl", "[this_area.name] - APC", 520, data["siliconUser"] ? 465 : 440)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/apc/proc/report()
	var/area/this_area = get_area(src)
	return "[this_area.name] : [equipment]/[lighting]/[environ] ([lastused_equip+lastused_light+lastused_environ]) : [cell? cell.percent() : "N/C"] ([charging])"

/obj/machinery/power/apc/proc/update()
	var/area/this_area = get_area(src)
	if(!this_area)
		return
	if(operating && !shorted)
		this_area.power_light = (lighting > 1)
		this_area.power_equip = (equipment > 1)
		this_area.power_environ = (environ > 1)
	else
		this_area.power_light = 0
		this_area.power_equip = 0
		this_area.power_environ = 0
	this_area.power_change()

/obj/machinery/power/apc/proc/isWireCut(var/wireIndex)
	return wires.IsIndexCut(wireIndex)


/obj/machinery/power/apc/proc/can_use(mob/user as mob, var/loud = 0) //used by attack_hand() and Topic()
	if(!user)
		return 0
	if (user.stat && !isobserver(user))
		to_chat(user, "<span class='warning'>You must be conscious to use this [src]!</span>")
		return 0
	if(!user.client)
		return 0
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use this [src]!</span>")
		nanomanager.close_user_uis(user, src)

		return 0
	if(user.restrained())
		to_chat(user, "<span class='warning'>You must have free hands to use this [src]</span>")
		return 0
	if(user.lying)
		to_chat(user, "<span class='warning'>You must stand to use this [src]!</span>")
		return 0
	if (istype(user, /mob/living/silicon))
		var/mob/living/silicon/ai/AI = user
		var/mob/living/silicon/robot/robot = user
		if((src.stat & NOAICONTROL) || malfhack && istype(malfai) && ((istype(AI) && (malfai!=AI && malfai != AI.parent)) || (istype(robot) && (robot in malfai.connected_robots))))
			if(!loud)
				to_chat(user, "<span class='warning'>\The [src] have AI control disabled!</span>")
				nanomanager.close_user_uis(user, src)

			return 0
	else
		if ((!is_in_range(user) || !istype(src.loc, /turf)))
			nanomanager.close_user_uis(user, src)

		if (wiresexposed)
			to_chat(user, "<span class='warning'>Unexpose the wires first!</span>")
			nanomanager.close_user_uis(user, src)

			return 0

	var/mob/living/carbon/human/H = user
	if (istype(H))
		if(H.getBrainLoss() >= 60)
			for(var/mob/M in viewers(src, null))
				to_chat(M, "<span class='warning'>[H] stares cluelessly at [src] and drools.</span>")
			return 0
		else if(prob(H.getBrainLoss()))
			to_chat(user, "<span class='warning'>You momentarily forget how to use [src].</span>")
			return 0
	return 1

/obj/machinery/power/apc/is_in_range(var/mob/user)
	if(!..())
		return OMNI_LINK(user,src)
	return TRUE

/obj/machinery/power/apc/Topic(href, href_list)
	if(..())
		return 0
	if(href_list["close"])
		if(usr.machine == src)
			usr.unset_machine()
		return 1
	if(!isobserver(usr))
		if(!(stat & NOAICONTROL) && malflocked && (usr != malfai && usr.loc != src)) //exclusive control enabled
			to_chat(usr, "Access refused.")
			return 0
	if(!can_use(usr, 1))
		return 0
	if(!(istype(usr, /mob/living/silicon) || isAdminGhost(usr) || OMNI_LINK(usr, src)) && locked)
	// Shouldn't happen, this is here to prevent href exploits
		to_chat(usr, "You must unlock the panel to use this!")
		return 1
	if (href_list["lock"])
		coverlocked = !coverlocked

	else if (href_list["breaker"])
		toggle_breaker()

	else if (href_list["cmode"])
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
			update_icon()

	else if (href_list["eqp"])
		var/val = text2num(href_list["eqp"])
		equipment = setsubsystem(val)
		update_icon()
		update()

	else if (href_list["lgt"])
		var/val = text2num(href_list["lgt"])
		lighting = setsubsystem(val)
		update_icon()
		update()

	else if (href_list["env"])
		var/val = text2num(href_list["env"])
		environ = setsubsystem(val)
		update_icon()
		update()

	else if(href_list["occupyapc"])
		var/datum/malfhack_ability/shunt/S = locate(/datum/malfhack_ability/shunt) in hack_abilities
		var/mob/living/silicon/ai/A = usr
		if(istype(S) && istype(A))
			if(S.check_available(A))
				S.activate(A)

	else if (href_list["overload"])
		if(istype(usr, /mob/living/silicon) || isAdminGhost(usr))
			src.overload_lighting()

	else if (href_list["toggleaccess"])
		if(istype(usr, /mob/living/silicon))
			if(emagged || (stat & (BROKEN|MAINT)))
				to_chat(usr, "The APC does not respond to the command.")
			else
				locked = !locked
				update_icon()

	return 1

/obj/machinery/power/apc/change_priority(value, id)
	. = ..()
	if(.)
		return

	if (id == "\ref[src]_b")
		power_recharge_priority = value

/obj/machinery/power/apc/proc/toggle_breaker()
	operating = !operating
	src.update()
	update_icon()

/*
	if(istype(malf.loc, /obj/machinery/power/apc)) // Already in an APC
		to_chat(malf, "<span class='warning'>You must evacuate your current apc first.</span>")
		return
	if(!malf.can_shunt)
		to_chat(malf, "<span class='warning'>You cannot shunt.</span>")
		return
	if(map.zMainStation != z)
		return
	src.occupant = new /mob/living/silicon/ai(src,malf.laws,null,1)
	src.occupant.adjustOxyLoss(malf.getOxyLoss())
	if(!findtext(src.occupant.name,"APC Copy"))
		src.occupant.name = "[malf.name] APC Copy"
	if(malf.parent)
		src.occupant.parent = malf.parent
	else
		src.occupant.parent = malf
	malf.mind.transfer_to(src.occupant)
	src.occupant.eyeobj.name = "[src.occupant.name] (AI Eye)"
	if(malf.parent)
		QDEL_NULL(malf)
	src.occupant.add_spell(new /spell/aoe_turf/corereturn, "malf_spell_ready",/obj/abstract/screen/movable/spell_master/malf)
	src.occupant.cancel_camera()
	if (seclevel2num(get_security_level()) == SEC_LEVEL_DELTA)
		for(var/obj/item/weapon/pinpointer/point in pinpointer_list)
			point.target = src //the pinpointer will detect the shunted AI

	// record that the malf shunted, for statistics
	if(istype(malf.mind) && istype(malf.mind.faction, /datum/faction/malf))
		var/datum/faction/malf/mf = malf.mind.faction
		if(istype(mf.stat_datum, /datum/stat/faction/malf))
			var/datum/stat/faction/malf/MS = mf.stat_datum
			MS.shunted = TRUE
*/

/obj/machinery/power/apc/proc/malfvacate(var/forced)
	if(!src.occupant)
		return
	if(src.occupant.parent && src.occupant.parent.stat != 2)
		src.occupant.parent.adjustOxyLoss(src.occupant.getOxyLoss())
		src.occupant.parent.cancel_camera()
		if (seclevel2num(get_security_level()) == SEC_LEVEL_DELTA)
			for(var/obj/item/weapon/pinpointer/point in pinpointer_list)
				var/mob/living/silicon/ai/A = occupant.parent // the current mob the mind owns
				if(A.stat != DEAD)
					point.target = A //The pinpointer tracks the AI back into its core.
		new /obj/effect/malf_jaunt(loc, occupant, occupant.parent, TRUE)
		src.occupant = null
		update_icon()
	else
		if(forced)
			src.occupant.forceMove(src.loc)
			src.occupant.death()
			src.occupant.gib()
			for(var/obj/item/weapon/pinpointer/point in pinpointer_list)
				point.target = null //the pinpointer will go back to pointing at the nuke disc.
		else
			to_chat(src.occupant, "<span class='warning'>Primary core damaged, unable to return core processes.</span>")

/obj/machinery/power/apc/can_overload()
	return 1

/obj/machinery/power/apc/proc/ion_act()
	//intended to be exactly the same as an AI malf attack
	if(!src.malfhack && map.zMainStation == z)
		if(prob(3))
			src.locked = 1
			if (src.cell.charge > 0)
//				to_chat(world, "<span class='warning'>blew APC in [src.loc.loc]</span>")
				src.cell.charge = 0
				cell.corrupt()
				src.malfhack = 1
				update_icon()
				var/datum/effect/system/smoke_spread/smoke = new /datum/effect/system/smoke_spread()
				smoke.set_up(3, 0, src.loc)
				smoke.attach(src)
				smoke.start()
				spark(src)
				for(var/mob/M in viewers(src))
					M.show_message("<span class='warning'>The [src.name] suddenly lets out a blast of smoke and some sparks!</span>", 1, "<span class='warning'>You hear sizzling electronics.</span>", 2)

/obj/machinery/power/apc/can_attach_terminal(mob/user)
	return user.loc == src.loc && has_electronics != 2 && !terminal

/obj/machinery/power/apc/surplus()
	if(terminal)
		return terminal.surplus()
	else
		return 0

/obj/machinery/power/apc/add_load(var/amount, var/priority = power_priority)
	if(terminal && terminal.get_powernet())
		terminal.powernet.add_load(amount, priority)

/obj/machinery/power/apc/get_satisfaction(var/priority = power_priority)
	if(terminal && terminal.get_powernet())
		return terminal.get_satisfaction(priority)
	else
		return 0

/obj/machinery/power/apc/avail()
	if(terminal)
		return terminal.avail()
	else
		return 0

/obj/machinery/power/apc/process()

	if(stat & (BROKEN|MAINT|FORCEDISABLE))
		return
	var/area/this_area = get_area(src)
	if(!this_area.requires_power)
		return

	// Store states to update icon if any change
	var/last_lt = lighting
	var/last_eq = equipment
	var/last_en = environ
	var/last_ch = charging

	// Set power availability rating for UI
	if(get_satisfaction() == 0.0)
		main_status = 0 // "None"
	else if(get_satisfaction() < 1.0)
		main_status = 1 // "Low"
	else
		main_status = 2 // "Good"

	if(cell && !shorted)
		var/tmpcharge = cell.charge

		// Attempt to recharge the cell. Better do it now so there's something to drain later
		recharge_cell()

		// Use the power we requested last tick to run the area's lights and machinery, and use cell power if we didn't get enough
		drain_cell()

		// Set power channels on or off depending on how much charge we have left
		process_autoset(this_area)

		// Turn charging on or off as needed
		process_chargemode()

		charge_diff = cell.charge - tmpcharge

	else // No cell, switch everything off
		turn_charging_off()
		charge_diff = 0
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		if(!make_alerts)
			this_area.poweralert(0, src)

	// Calculate how much power is needed, and request it for next tick
	lastused_light = 0
	if (lighting != APC_CHANNEL_STATUS_OFF && lighting != APC_CHANNEL_STATUS_AUTO_OFF)
		lastused_light += this_area.usage(LIGHT)
		lastused_light += this_area.usage(STATIC_LIGHT)

	lastused_equip = 0
	if (equipment != APC_CHANNEL_STATUS_OFF && equipment != APC_CHANNEL_STATUS_AUTO_OFF)
		lastused_equip += this_area.usage(EQUIP)
		lastused_equip += this_area.usage(STATIC_EQUIP)

	lastused_environ = 0
	if (environ != APC_CHANNEL_STATUS_OFF && environ != APC_CHANNEL_STATUS_AUTO_OFF)
		lastused_environ += this_area.usage(ENVIRON)
		lastused_environ += this_area.usage(STATIC_ENVIRON)

	this_area.clear_usage()

	lastused_total = lastused_light + lastused_equip + lastused_environ
	add_load(lastused_total)

	// update icon & area power if anything changed
	if(last_lt != lighting || last_eq != equipment || last_en != environ)
		queue_icon_update()
		update()
	else if (last_ch != charging)
		queue_icon_update()

/obj/machinery/power/apc/proc/recharge_cell()
	if(chargemode && charging && operating)
		// If there's any power to recharge whith at the recharge priority level, suck it in and request more for later
		if (get_satisfaction(power_recharge_priority))
			var/recharge_power = recharge_load * get_satisfaction(power_recharge_priority)
			cell.give(recharge_power * CELLRATE)

			recharge_load = min(cell.maxcharge - cell.charge, cell.maxcharge * CHARGELEVEL) / CELLRATE
			add_load(recharge_load, power_recharge_priority)

		// If there's no power at all to recharge with, stop
		else
			turn_charging_off()

/obj/machinery/power/apc/proc/drain_cell()
	var/power_debt = lastused_total * (1 - get_satisfaction())
	if (cell.charge / CELLRATE >= power_debt)
		cell.use(power_debt * CELLRATE)

	else // There's not enough charge in the cell to cover power debt! Shut it down
		turn_charging_off()
		cell.use(cell.charge)
		// This turns everything off in the case that there is still a charge left on the battery, just not enough to run the room.
		lighting = autoset(lighting, 0)
		equipment = autoset(equipment, 0)
		environ = autoset(environ, 0)

/obj/machinery/power/apc/proc/process_chargemode()
	// show cell as fully charged if so
	if(cell.charge >= cell.maxcharge)
		cell.charge = cell.maxcharge
		charging = 2

	if(chargemode)
		if(!charging)
			if(get_satisfaction(power_recharge_priority) > 0)
				chargecount++
			else
				turn_charging_off()

			if(chargecount == 10)
				chargecount = 0
				charging = TRUE

	else // chargemode off
		turn_charging_off()

/obj/machinery/power/apc/proc/turn_charging_off()
	charging = FALSE
	chargecount = 0
	recharge_load = 0

/obj/machinery/power/apc/proc/process_autoset(var/area/this_area )
	// Allow the APC to operate as normal if the cell can charge
	if(charging && longtermpower < 10)
		longtermpower += 1
	else if(longtermpower > -10)
		longtermpower -= 2

	if(cell.charge <= 0)								// zero charge, turn all off
		equipment = autoset(equipment, 0)
		lighting = autoset(lighting, 0)
		environ = autoset(environ, 0)
		if(this_area.poweralm && make_alerts)
			this_area.poweralert(0, src)

	else if(cell.percent() < 15 && longtermpower < 0)	// <15%, turn off lighting & equipment
		equipment = autoset(equipment, 2)
		lighting = autoset(lighting, 2)
		environ = autoset(environ, 1)
		if(this_area.poweralm && make_alerts)
			this_area.poweralert(0, src)

	else if(cell.percent() < 30 && longtermpower < 0)	// <30%, turn off equipment
		equipment = autoset(equipment, 2)
		lighting = autoset(lighting, 1)
		environ = autoset(environ, 1)
		if(this_area.poweralm && make_alerts)
			this_area.poweralert(0, src)

	else												// otherwise all can be on
		equipment = autoset(equipment, 1)
		lighting = autoset(lighting, 1)
		environ = autoset(environ, 1)
		if(cell.percent() > 35 && !this_area.poweralm && make_alerts) // 35% to prevent spamming alerts if it fluctuates
			this_area.poweralert(1, src)

// val 0=off, 1=off(auto) 2=on 3=on(auto)
// on 0=off, 1=on, 2=autooff
/obj/machinery/power/apc/proc/autoset(var/val, var/on)
	switch (on)
		if (0)
			if(val==APC_CHANNEL_STATUS_ON || val==APC_CHANNEL_STATUS_AUTO_ON)	// if on or auto-on, return auto-off
				return APC_CHANNEL_STATUS_AUTO_OFF
		if (1)
			if(val==APC_CHANNEL_STATUS_AUTO_OFF)								// if auto-off, return auto-on
				return APC_CHANNEL_STATUS_AUTO_ON
		if (2)
			if(val==APC_CHANNEL_STATUS_AUTO_ON)									// if auto-on, return auto-off
				return APC_CHANNEL_STATUS_AUTO_OFF
	return val

/obj/machinery/power/apc/get_monitor_status()
	if (stat & (BROKEN|MAINT|FORCEDISABLE) || !monitoring_enabled)
		return null

	var/list/data = list()

	// Base APC data
	var/list/base = get_monitor_status_template()
	base["name"] = "APC"
	base["demand"] = lastused_total

	data["\ref[src]"] = base

	// Charger data
	if (cell && !shorted)
		var/list/battery = get_monitor_status_template()
		battery["name"] = "APC battery"
		battery["priority"] = power_recharge_priority
		battery["demand"] = recharge_load
		battery["isbattery"] = TRUE
		battery["charge"] = cell ? cell.percent() : 0

		if (charge_diff > 0)
			battery["charging"] = MONITOR_STATUS_BATTERY_CHARGING
		else if (charge_diff < 0)
			battery["charging"] = MONITOR_STATUS_BATTERY_DISCHARGING

		data["\ref[src]_b"] = battery

	return data

// damage and destruction acts

/obj/machinery/power/apc/emp_act(severity)
	flick("apc-spark", src)
	if(cell)
		cell.emp_act(severity)
	if(occupant)
		occupant.emp_act(severity)
	lighting = 0
	equipment = 0
	environ = 0
	update()
	spawn(600/severity)
		lighting = 3
		equipment = 3
		environ = 3
		update()
	..()

/obj/machinery/power/apc/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(50))
				set_broken()
				if(cell && prob(50))
					cell.ex_act(2)
					if(cell && cell.gcDestroyed)
						cell = null
		if(3)
			if(prob(25))
				set_broken()
				if (cell && prob(25))
					cell.ex_act(3)
					if(cell && cell.gcDestroyed)
						cell = null

/obj/machinery/power/apc/blob_act()
	if (prob(75))
		set_broken()
		if (cell && prob(5))
			cell.blob_act()

/obj/machinery/power/apc/proc/set_broken()
	if(malfai && operating)
		var/datum/role/malfAI/M = malfai.mind?.GetRole(MALF)
		if(M && (src in M.apcs))
			M.apcs -= src
	stat |= BROKEN
	operating = 0
	wiresexposed = 0
	opened = 0
	if(occupant)
		malfvacate(1)
	update_icon()
	update()

// overload all the lights in this APC area

/obj/machinery/power/apc/proc/overload_lighting()
	if(/* !get_connection() || */ !operating || shorted)
		return
	if( cell && cell.charge>=20)
		cell.use(20);
		spawn(0)
			var/area/this_area = get_area(src)
			for(var/obj/machinery/light/L in this_area)
				L.on = 1
				L.broken()
				sleep(1)

/obj/machinery/power/apc/Destroy()
	var/area/this_area = get_area(src)
	if(this_area.areaapc == src)
		this_area.remove_apc(src)
		clear_malf()
		this_area.power_light = 0
		this_area.power_equip = 0
		this_area.power_environ = 0
		this_area.power_change()

	if(occupant)
		malfvacate(1)

	if(cell)
		QDEL_NULL(cell)

	if(wires)
		QDEL_NULL(wires)

	if(malfimage)
		qdel(malfimage)

	..()

/obj/machinery/power/apc/proc/setsubsystem(val)
	if(cell && cell.charge > 0)
		return (val==1) ? 0 : val
	else if(val == 3)
		return 1
	else
		return 0

/obj/machinery/power/apc/cultify()
	if(src.invisibility != INVISIBILITY_MAXIMUM)
		src.invisibility = INVISIBILITY_MAXIMUM

/obj/machinery/power/apc/wirejack(var/mob/living/silicon/pai/P)
	if(..())
		locked = !locked
		update_icon()
		return 1
	return 0

//We kinda do things our own way and don't really use NOPOWER or such, so we need different sanity
/obj/machinery/power/apc/shock(mob/user, prb, var/siemenspassed = -1)
	if(shorted || (!cell && !charging))
		return FALSE
	if(siemenspassed == -1) //this means it hasn't been set by proc arguments, so we can set it ourselves safely
		siemenspassed = 0.7
	//Process the shocking via powernet
	if(terminal)
		if(electrocute_mob(user, terminal.get_powernet(), terminal, siemenspassed))
			spark(src)
			return TRUE
		else
			return FALSE
	return ..()

/obj/machinery/power/apc/npc_tamper_act(mob/living/L)
	if(!panel_open)
		togglePanelOpen(null, L)
	if(wires)
		wires.npc_tamper(L)

/obj/machinery/power/apc/AltClick(mob/user)
	if(!user.incapacitated() && Adjacent(user) && user.dexterity_check() && allowed(user))
		locked = !locked
		to_chat(user, "You [locked ? "" : "un"]lock \the [src] interface.")
		update_icon()
	return ..()



#undef APC_UPDATE_ICON_COOLDOWN

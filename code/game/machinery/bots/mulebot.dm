//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA

#define MODE_IDLE 0
#define MODE_LOADING 1
#define MODE_MOVING 2
#define MODE_RETURNING 3
#define MODE_BLOCKED 4
#define MODE_COMPUTING 5
#define MODE_WAITING 6
#define MODE_NOROUTE 7

var/global/mulebot_count = 0

/datum/locking_category/mulebot

/obj/machinery/bot/mulebot
	name = "\improper MULEbot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	icon_initial = "mulebot"
	density = 1
	anchored = 1
	animate_movement=1
	health = 150 //yeah, it's tougher than ed209 because it is a big metal box with wheels --rastaf0
	maxhealth = 150
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
	can_take_pai = TRUE
	beacon_freq = 1400
	control_freq = 1447
	control_filter = RADIO_MULEBOT
	bot_flags = BOT_DENSE|BOT_NOT_CHASING|BOT_CONTROL|BOT_BEACON
	suffix = ""

	var/loaddir = 0				// this the direction to unload onto/load from
	var/home_destination = "" 	// tag of home beacon
	req_access = list(access_cargo) // added robotics access so assembly line drop-off works properly -veyveyr //I don't think so, Tim. You need to add it to the MULE's hidden robot ID card. -NEO
	var/mode = MODE_IDLE		//0 = idle/ready
						//1 = loading/unloading
						//2 = moving to deliver
						//3 = returning to home
						//4 = blocked
						//5 = computing navigation
						//6 = waiting for nav computation
						//7 = no destination beacon found (or no route)

	var/refresh = 1		// true to refresh dialogue
	var/auto_return = 1	// true if auto return to home beacon after unload
	var/auto_pickup = 1 // true if auto-pickup at beacon

	var/obj/item/weapon/cell/cell
	var/datum/wires/mulebot/wires = null
						// the installed power cell

	// constants for internal wiring bitflags
	/*

	var/wires = 1023		// all flags on

	var/list/wire_text	// list of wire colours
	var/list/wire_order	// order of wire indices
	*/

	var/list/can_load = list()

	var/bloodiness = 0		// count of bloodiness
	var/currentBloodColor = DEFAULT_BLOOD
	var/run_over_cooldown = 3 SECONDS	//how often a pAI-controlled MULEbot can damage a mob by running over them
	var/coolingdown = FALSE

	commanding_radio = /obj/item/radio/integrated/signal/bot/mule

/obj/machinery/bot/mulebot/get_cell()
	return cell


/obj/machinery/bot/mulebot/New()
	. = ..()
	wires = new(src)
	botcard = new(src)
	var/datum/job/cargo_tech/J = new/datum/job/cargo_tech
	botcard.access = J.get_access()
	cell = new(src)
	cell.charge = 2000
	cell.maxcharge = 2000

/obj/machinery/bot/mulebot/initialize()
	. = ..()
	mulebot_count += 1
	if(!suffix)
		suffix = "#[mulebot_count]"
	name = "\improper Mulebot ([suffix])"
	can_load = list(
		/obj/structure/closet/crate,
		/obj/structure/vendomatpack,
		/obj/structure/stackopacks,
		/obj/item/weapon/gift,
		)

/obj/machinery/bot/mulebot/Destroy()
	if(radio_controller)
		radio_controller.remove_object(src, control_freq)
		radio_controller.remove_object(src, beacon_freq)
	if(wires)
		qdel(wires)
		wires = null
	if(cell)
		qdel(cell)
		cell = null

	..()

// attack by item
// emag : lock/unlock,
// screwdriver: open/close hatch
// cell: insert it
// other: chance to knock rider off bot
/obj/machinery/bot/mulebot/attackby(obj/item/I, mob/user)
	user.delayNextAttack(I.attack_delay)
	if(istype(I,/obj/item/weapon/card/emag))
		toggle_lock(user, TRUE)
		to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] [src]'s controls!</span>")
		flick("[icon_initial]-emagged", src)
		playsound(src, 'sound/effects/sparks1.ogg', 100, 0)
	else if(istype(I, /obj/item/weapon/card/id))
		if(toggle_lock(user))
			to_chat(user, "<span class='notice'>Controls [(locked ? "locked" : "unlocked")].</span>")

	else if(istype(I,/obj/item/weapon/cell) && open && !cell && user.a_intent != I_HURT)
		var/obj/item/weapon/cell/C = I
		if(user.drop_item(C, src))
			cell = C
			updateDialog()
	else if((istype(I,/obj/item/tool/wirecutters)||istype(I,/obj/item/device/multitool)) && user.a_intent != I_HURT)
		attack_hand(user)
	else if(I.is_screwdriver(user) && user.a_intent != I_HURT)
		if(locked)
			to_chat(user, "<span class='notice'>The maintenance hatch cannot be opened or closed while the controls are locked.</span>")
			return
		I.playtoolsound(src, 25, extrarange = -6)
		open = !open
		if(open)
			src.visible_message("[user] opens the maintenance hatch of [src]", "<span class='notice'>You open [src]'s maintenance hatch.</span>")
			on = 0
			icon_state="[icon_initial]-hatch"
		else
			src.visible_message("[user] closes the maintenance hatch of [src]", "<span class='notice'>You close [src]'s maintenance hatch.</span>")
			icon_state = "[icon_initial]0"

		updateDialog()
	else if (I.is_wrench(user) && user.a_intent != I_HURT)
		if (src.health < maxhealth)
			src.health = min(maxhealth, src.health+25)
			user.visible_message(
				"<span class='warning'>[user] repairs [src]!</span>",
				"<span class='notice'>You repair [src]!</span>"
			)
		else
			to_chat(user, "<span class='notice'>[src] does not need a repair!</span>")
	else
		var/atom/movable/load = is_locking(/datum/locking_category/mulebot) && get_locked(/datum/locking_category/mulebot)[1]
		if(ismob(load) && prob(1+I.force * 2)) // chance to knock off rider
			unload(0)
			var/mob/living/rider = load
			rider.Knockdown(2)
			rider.Stun(2)
			playsound(rider, "sound/effects/bodyfall.ogg", 50, 1)
			user.visible_message("<span class='warning'>[user] knocks [load] off [src] with \the [I]!</span>", "<span class='warning'>You knock [load] off [src] with \the [I]!</span>")
		. = ..()


/obj/machinery/bot/mulebot/ex_act(var/severity)
	unload(0)
	switch(severity)
		if(2)
			for(var/i = 1; i < 3; i++)
				wires.RandomCut()
		if(3)
			wires.RandomCut()
	..()
	return

/obj/machinery/bot/mulebot/bullet_act()
	if(prob(50) && is_locking(/datum/locking_category/mulebot))
		unload(0)
	if(prob(25))
		src.visible_message("<span class='warning'>Something shorts out inside [src]!</span>")
		wires.RandomCut()
	return ..()


/obj/machinery/bot/mulebot/attack_ai(var/mob/user)
	src.add_hiddenprint(user)
	user.set_machine(src)
	interact(user, 1)

/obj/machinery/bot/mulebot/attack_hand(var/mob/user)
	. = ..()
	if (.)
		return
	user.set_machine(src)
	interact(user, 0)

/obj/machinery/bot/mulebot/interact(var/mob/user, var/ai=0)
	var/dat
	dat += "<TT><B>Multiple Utility Load Effector Mk. III</B></TT><BR><BR>"
	dat += "ID: [suffix]<BR>"
	dat += "Power: [on ? "On" : "Off"]<BR>"

	if(!open)

		dat += "Status: "
		switch(mode)
			if(MODE_IDLE)
				dat += "Ready"
			if(MODE_LOADING)
				dat += "Loading/Unloading"
			if(MODE_MOVING)
				dat += "Navigating to Delivery Location"
			if(MODE_RETURNING)
				dat += "Navigating to Home"
			if(MODE_BLOCKED)
				dat += "Waiting for clear path"
			if(MODE_COMPUTING, MODE_WAITING)
				dat += "Calculating navigation path"
			if(MODE_NOROUTE)
				dat += "Unable to reach destination"

		var/atom/movable/load = is_locking(/datum/locking_category/mulebot) && get_locked(/datum/locking_category/mulebot)[1]
		dat += "<BR>Current Load: [load ? load.name : "<i>none</i>"]<BR>"
		dat += "Destination: [!destination ? "<i>none</i>" : destination]<BR>"
		dat += "Power level: [cell ? cell.percent() : 0]%<BR>"

		if(locked && !ai)
			dat += "<HR>Controls are locked <A href='byond://?src=\ref[src];op=unlock'><I>(unlock)</I></A>"
		else
			dat += "<HR>Controls are unlocked <A href='byond://?src=\ref[src];op=lock'><I>(lock)</I></A><BR><BR>"

			dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
			dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
			dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"

			if(load)
				dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
			dat += "<HR>The maintenance hatch is closed.<BR>"

	else
		if(!ai)
			dat += "The maintenance hatch is open.<BR><BR>"
			dat += "Power cell: "
			if(cell)
				dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
			else
				dat += "<A href='byond://?src=\ref[src];op=cellinsert'>Removed</A><BR>"

			dat += wires()
		else
			dat += "The bot is in maintenance mode and cannot be controlled.<BR>"

	user << browse("<HEAD><TITLE>Mulebot [suffix ? "([suffix])" : ""]</TITLE></HEAD>[dat]", "window=mulebot;size=350x500")
	onclose(user, "mulebot")
	return

/obj/machinery/bot/mulebot/return_status()
	switch(mode)
		if(MODE_IDLE)
			return "Ready"
		if(MODE_LOADING)
			return "Loading/Unloading"
		if(MODE_MOVING)
			return "Navigating to Delivery Location"
		if(MODE_RETURNING)
			return "Navigating to Home"
		if(MODE_BLOCKED)
			return "Waiting for clear path"
		if(MODE_COMPUTING, MODE_WAITING)
			return "Calculating navigation path"
		if(MODE_NOROUTE)
			return "Unable to reach destination"
	return ..()

/obj/machinery/bot/mulebot/execute_signal_command(var/datum/signal/signal, var/command)
	if (..())
		return
	switch (command)
		if ("return_home")
			start_home()
		else // It's a new destination !
			set_destination(command)

// returns the wire panel text
/obj/machinery/bot/mulebot/proc/wires()
	return wires.GetInteractWindow()

/obj/machinery/bot/mulebot/Topic(href, href_list)
	if(..())
		return
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		switch(href_list["op"])
			if("lock", "unlock")
				toggle_lock(usr)

			if("power")
				if (src.on)
					turn_off()
				else if (cell && !open)
					if (!turn_on())
						to_chat(usr, "<span class='warning'>You can't switch on [src].</span>")
						return
				else
					return
				visible_message("[usr] switches [on ? "on" : "off"] [src].")
				updateDialog()


			if("cellremove")
				if(open && cell && !usr.get_active_hand())
					cell.updateicon()
					usr.put_in_active_hand(cell)
					cell.add_fingerprint(usr)
					cell = null

					usr.visible_message("<span class='notice'>[usr] removes the power cell from [src].</span>", "<span class='notice'>You remove the power cell from [src].</span>")
					updateDialog()

			if("cellinsert")
				if(open && !cell)
					var/obj/item/weapon/cell/C = usr.get_active_hand()
					if(istype(C))
						if(usr.drop_item(C, src))
							cell = C
							C.add_fingerprint(usr)

							usr.visible_message("<span class='notice'>[usr] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
							updateDialog()


			if("stop")
				if(mode != MODE_LOADING || mode != MODE_IDLE)
					mode = MODE_IDLE
					updateDialog()

			if("go")
				start()
				updateDialog()

			if("home")
				start_home()
				updateDialog()

			if("destination")
				refresh=0
				var/new_dest = input("Enter new destination tag", "Mulebot [suffix ? "([suffix])" : ""]", destination) as text|null
				refresh=1
				if(new_dest && Adjacent(usr) && !usr.stat)
					set_destination(new_dest)

			if("setid")
				refresh=0
				var/new_id = copytext(sanitize(input("Enter new bot ID", "Mulebot [suffix ? "([suffix])" : ""]", suffix) as text|null),1,MAX_NAME_LEN)
				refresh=1
				if(new_id && Adjacent(usr) && !usr.stat)
					suffix = new_id
					name = "\improper Mulebot ([suffix])"
					updateDialog()

			if("sethome")
				refresh=0
				var/new_home = input("Enter new home tag", "Mulebot [suffix ? "([suffix])" : ""]", home_destination) as text|null
				refresh=1
				if(new_home && Adjacent(usr) && !usr.stat)
					home_destination = new_home
					updateDialog()

			if("unload")
				var/atom/movable/load = is_locking(/datum/locking_category/mulebot) && get_locked(/datum/locking_category/mulebot)[1]
				if(load && mode != MODE_LOADING)
					if(loc == target)
						unload(loaddir)
					else
						unload(0)

			if("autoret")
				auto_return = !auto_return

			if("autopick")
				auto_pickup = !auto_pickup

			if("close")
				usr.unset_machine()
				usr << browse(null,"window=mulebot")

		updateDialog()
		//src.updateUsrDialog()
	else
		usr << browse(null, "window=mulebot")
		usr.unset_machine()
	return



// returns true if the bot has power
/obj/machinery/bot/mulebot/proc/has_power()
	return !open && cell && cell.charge > 0 && wires.HasPower()

/obj/machinery/bot/mulebot/proc/toggle_lock(mob/user, ignore_access = FALSE)
	if(allowed(user) || ignore_access)
		locked = !locked
		updateDialog()
		return 1
	else
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return 0

// mousedrop a crate to load the bot
// can load anything if emagged

/obj/machinery/bot/mulebot/MouseDropTo(var/atom/movable/C, mob/user)
	if(!istype(C))
		return

	if(user.stat)
		to_chat(user, "<span class='warning'>Not while you're unconscious.</span>")
		return

	if(!on)
		to_chat(user, "<span class='warning'>\The [src] is off, turn it on first.</span>")
		return

	if(C.anchored)
		to_chat(user, "<span class='warning'>\The [C] is stuck to the floor!</span>")
		return

	if(get_dist(user, src) > 1)
		to_chat(user, "<span class='warning'>You're too far away.</span>")
		return

	if (get_dist(src, C) > 1)
		to_chat(user, "<span class='warning'>\The [C] is too far away.</span>")
		return

	if(is_locking(/datum/locking_category/mulebot))
		to_chat(user, "<span class='warning'>\The [src] is already full.</span>")
		return

	load(C)

/obj/machinery/bot/mulebot/lock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return
	AM.layer = layer + 0.1
	AM.plane = plane
	AM.pixel_y += 9 * PIXEL_MULTIPLIER

/obj/machinery/bot/mulebot/unlock_atom(var/atom/movable/AM)
	. = ..()
	if(!.)
		return
	AM.reset_plane_and_layer()
	AM.pixel_y = initial(AM.pixel_y)

// called to load a crate
/obj/machinery/bot/mulebot/proc/load(var/atom/movable/C)
	if(wires.LoadCheck() && !is_type_in_list(C,can_load))
		src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, 0)
		return		// if not emagged, only allow crates to be loaded

	//I'm sure someone will come along and ask why this is here... well people were dragging screen items onto the mule, and that was not cool.
	//So this is a simple fix that only allows a selection of item types to be considered. Further narrowing-down is below.
	if(!istype(C,/obj/item) && !istype(C,/obj/machinery) && !istype(C,/obj/structure) && !ismob(C))
		return
	if(!isturf(C.loc)) //To prevent the loading from stuff from someone's inventory, which wouldn't get handled properly.
		return
	if(C.locked_to || C.is_locking())
		return
	if(get_dist(C, src) > 1 || is_locking(/datum/locking_category/mulebot) || !on)
		return
	for(var/obj/structure/plasticflaps/P in src.loc)//Takes flaps into account
		if(!Cross(C,P))
			return
	mode = MODE_LOADING

	// if a crate, close before loading
	var/obj/structure/closet/crate/crate = C
	if(istype(crate))
		crate.close()

	lock_atom(C, /datum/locking_category/mulebot)

// called to unload the bot
// argument is optional direction to unload
// if zero, unload at bot's location
/obj/machinery/bot/mulebot/proc/unload(var/dirn = 0)
	if(!is_locking(/datum/locking_category/mulebot))
		return

	mode = MODE_LOADING
	overlays.len = 0
	if(integratedpai)
		overlays += image('icons/obj/aibots.dmi', "mulebot1_pai")
	var/atom/movable/load = get_locked(/datum/locking_category/mulebot)[1]
	unlock_atom(load)

	if(dirn)
		var/turf/T = src.loc
		T = get_step(T,dirn)
		if(Cross(load,T))//Can't get off onto anything that wouldn't let you pass normally
			step(load, dirn)
		else
			load.forceMove(src.loc)//Drops you right there, so you shouldn't be able to get yourself stuck

	// in case non-load items end up in contents, dump every else too
	// this seems to happen sometimes due to race conditions //There are no race conditions in BYOND. It's single-threaded.
	// with items dropping as mobs are loaded

	for(var/atom/movable/AM in src)
		if(AM == cell || AM == botcard || AM == integratedpai)
			continue

		AM.forceMove(src.loc)
	mode = MODE_IDLE

/obj/machinery/bot/mulebot/process_bot()
	if(!has_power())
		on = 0
		return
	steps_per = 2 + (wires.Motor1() ? 1 : 0) + (wires.Motor2() ? 2 : 0) // The more motor wires active, the faster we go

/obj/machinery/bot/mulebot/on_path_step(var/turf/simulated/next)
	if (istype(next))
		var/goingdir=0
		var/newdir = get_dir(next, loc)
		if(newdir == dir)
			goingdir = newdir
		else
			newdir = newdir | dir
			if(newdir == (NORTH + SOUTH))
				newdir = NORTH
			else if(newdir == (EAST + WEST))
				newdir = EAST
			goingdir = newdir
		next.AddTracks(/obj/effect/decal/cleanable/blood/tracks/wheels,list(),0,goingdir,currentBloodColor)

// starts bot moving to current destination
/obj/machinery/bot/mulebot/proc/start()
	if(destination == home_destination)
		mode = MODE_RETURNING
	else
		mode = MODE_MOVING
	icon_state = "[icon_initial][(wires.MobAvoid() != 0)]"

/obj/machinery/bot/mulebot/set_destination(var/new_dest)
	log_astar_beacon("new_destination [new_dest]")
	new_destination = new_dest
	request_path(new_dest)

/obj/machinery/bot/mulebot/proc/request_path(var/new_dest)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(beacon_freq)
	var/datum/signal/signal = new /datum/signal
	signal.source = src
	signal.transmission_method = 1
	var/list/keyval = list(
		"findbeacon" = new_dest
	)
	signal.data = keyval
	frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)

/obj/machinery/bot/mulebot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	if(recv && recv == new_destination)	// if the recvd beacon location matches the set destination, then we will navigate there
		log_astar_beacon("new destination chosen, [recv]")
		destination = new_destination
		new_destination = ""
		target = signal.source.loc
		awaiting_beacon = 0
		return 1
	// -- Command signals --
	var/target_bot = signal.data["target"]
	if (target_bot != "\ref[src]")
		return
	var/command = signal.data["command"]
	execute_signal_command(signal, command)

// starts bot moving to home
// sends a beacon query to find
/obj/machinery/bot/mulebot/proc/start_home()
	spawn(0)
		set_destination(home_destination)
	icon_state = "[icon_initial][(wires.MobAvoid() != 0)]"


/obj/machinery/bot/mulebot/proc/RunOverCreature(var/mob/living/H,var/bloodcolor)
	if(integratedpai && coolingdown)
		return
	src.visible_message("<span class='warning'>[src] drives over [H]!</span>")
	playsound(src, 'sound/effects/splat.ogg', 50, 1)
	var/damage = rand(5,15)
	if(integratedpai)
		damage = round(damage/3.33)
	H.apply_damage(2*damage, BRUTE, LIMB_HEAD)
	H.apply_damage(2*damage, BRUTE, LIMB_CHEST)
	H.apply_damage(0.5*damage, BRUTE, LIMB_LEFT_LEG)
	H.apply_damage(0.5*damage, BRUTE, LIMB_RIGHT_LEG)
	H.apply_damage(0.5*damage, BRUTE, LIMB_LEFT_ARM)
	H.apply_damage(0.5*damage, BRUTE, LIMB_RIGHT_ARM)
	bloodiness += 4
	currentBloodColor=bloodcolor // For if species get different blood colors.
	if(run_over_cooldown)
		run_over_coolingdown()

/obj/machinery/bot/mulebot/proc/run_over_coolingdown()
	coolingdown = TRUE
	spawn(run_over_cooldown)
		coolingdown = FALSE

/obj/machinery/bot/mulebot/at_path_target()
	src.visible_message("[src] makes a chiming sound!", "You hear a chime.")
	playsound(src, 'sound/machines/chime.ogg', 50, 0)

	if(is_locking(/datum/locking_category/mulebot))		// if loaded, unload at target
		unload(loaddir)
	else
		// not loaded
		if(auto_pickup)		// find a crate
			var/atom/movable/AM
			if(!wires.LoadCheck())		// if emagged, load first unanchored thing we find
				for(var/atom/movable/A in get_step(loc, loaddir))
					if(!A.anchored)
						AM = A
						break
			else			// otherwise, look for crates only
				for(var/i=1,i<=can_load.len,i++)
					var/loadin_type = can_load[i]
					AM = locate(loadin_type) in get_step(loc,loaddir)
					if(AM)
						load(AM)
						break

		// whatever happened, check to see if we return home

	if(auto_return && destination != home_destination)
		// auto return set and not at home already
		start_home()
	else
		mode = MODE_IDLE	// otherwise go idle
	return ..()

// called when bot bumps into anything
/obj/machinery/bot/mulebot/to_bump(var/atom/obs)
	if(!wires.MobAvoid())		//usually just bumps, but if avoidance disabled knock over mobs
		var/mob/M = obs
		if(ismob(M))
			if(istype(M,/mob/living/silicon/robot))
				src.visible_message("<span class='warning'>[src] bumps into [M]!</span>")
			else
				src.visible_message("<span class='warning'>[src] knocks over [M]!</span>")
				M.stop_pulling()
				if(integratedpai)
					M.Stun(1)
					M.Knockdown(1)
				else
					M.Stun(8)
					M.Knockdown(5)
				M.lying = 1
	..()


// player INSIDE mulebot attempted to move
/obj/machinery/bot/mulebot/relaymove(var/mob/user)
	unload()

// receive a radio signal
// used for control and beacon reception

/obj/machinery/bot/mulebot/install_pai(obj/item/device/paicard/P)
	..()
	overlays += image('icons/obj/aibots.dmi', "mulebot1_pai")

/obj/machinery/bot/mulebot/eject_integratedpai_if_present()
	if(..())
		overlays -= image('icons/obj/aibots.dmi', "mulebot1_pai")

/obj/machinery/bot/mulebot/getpAIMovementDelay()
	return ((wires.Motor1() ? 1 : 0) + (wires.Motor2() ? 2 : 0) - 1) * 2

/obj/machinery/bot/mulebot/pAImove(mob/living/silicon/pai/user, dir)
	if(getpAIMovementDelay() < 0)
		to_chat(user, "There seems to be something wrong with the motor. Have a technician check the wires.")
		return
	if(!..())
		return
	if(!on)
		to_chat(user, "You can't move \the [src] while it's turned off.")
		return
	var/turf/T = loc
	if(!T.has_gravity())
		return
	step(src, dir)

/obj/machinery/bot/mulebot/on_integrated_pai_click(mob/living/silicon/pai/user, var/atom/movable/A)
	if(!istype(A) || !Adjacent(A) || A.anchored)
		return
	load(A)
	if(is_locking(/datum/locking_category/mulebot))
		to_chat(user, "You load \the [A] onto \the [src].")

/obj/machinery/bot/mulebot/attack_integrated_pai(mob/living/silicon/pai/user)
	var/atom/movable/load = is_locking(/datum/locking_category/mulebot) && get_locked(/datum/locking_category/mulebot)[1]
	if(load)
		to_chat(user, "You unload \the [load].")
		unload()

/obj/machinery/bot/mulebot/npc_tamper_act(mob/living/L)
	if(L.loc == src) //Gremlins on the mule get out if the mule has stopped
		if(mode == MODE_NOROUTE || !wires.RemoteRX() || !wires.HasPower() || !(wires.Motor1() || wires.Motor2())) //Jump ship if the MULE is broken
			unload()

		return NPC_TAMPER_ACT_NOMSG

	if(prob(80)) //80% chance to RIDE THE MULE
		//If the MULE hasn't been modified to accept non-orthodox cargo, do it now
		if(!wires)
			return
		if(!wires.IsIndexCut(WIRE_LOADCHECK))
			wires.CutWireIndex(WIRE_LOADCHECK)

		//Turn the MULE ON
		if(!on && !turn_on())
			return

		//Mount the MULE
		load(L)

		var/list/possible_destinations = list()
		for(var/obj/machinery/navbeacon/N in navbeacons)
			if(!N.location || !isturf(N.loc))
				continue
			if(N.freq != src.beacon_freq) //If the navbeacon is on a different frequency, the mulebot can't navigate to it
				continue
			possible_destinations.Add(N)

		//Type in a destination for the MULE
		var/obj/machinery/navbeacon/new_destination = pick(possible_destinations)
		set_destination(new_destination.location)

		//GO!
		start()

		message_admins("[key_name(L)] has mounted \the [src] and is riding it to [new_destination.location] ([formatJumpTo(new_destination)])! [formatJumpTo(src)]")
	else
		if(!panel_open)
			togglePanelOpen(null, L)
		if(wires)
			wires.npc_tamper(L)

/obj/machinery/bot/mulebot/emp_act(severity)
	if (cell)
		cell.emp_act(severity)
	..()

/obj/machinery/bot/mulebot/explode()
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/rods(Tsec)
	new /obj/item/stack/cable_coil/cut(Tsec)
	if (cell)
		cell.forceMove(Tsec)
		cell.update_icon()
		cell = null

	spark(src)

	new /obj/effect/decal/cleanable/blood/oil(src.loc)
	unload(0)
	qdel(src)

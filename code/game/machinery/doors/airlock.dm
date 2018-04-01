/*
	New methods:
	pulse - sends a pulse into a wire for hacking purposes
	cut - cuts a wire and makes any necessary state changes
	mend - mends a wire and makes any necessary state changes
	canAIControl - 1 if the AI can control the airlock, 0 if not (then check canAIHack to see if it can hack in)
	canAIHack - 1 if the AI can hack into the airlock to recover control, 0 if not. Also returns 0 if the AI does not *need* to hack it.
	hasPower - 1 if the main or backup power are functioning, 0 if not.
	requiresIDs - 1 if the airlock is requiring IDs, 0 if not
	isAllPowerCut - 1 if the main and backup power both have cut wires.
	regainMainPower - handles the effect of main power coming back on.
	loseMainPower - handles the effect of main power going offline. Usually (if one isn't already running) spawn a thread to count down how long it will be offline - counting down won't happen if main power was completely cut along with backup power, though, the thread will just sleep.
	loseBackupPower - handles the effect of backup power going offline.
	regainBackupPower - handles the effect of main power coming back on.
	shock - has a chance of electrocuting its target.
*/

// Wires for the airlock are located in the datum folder, inside the wires datum folder.

#define AIRLOCK_CLOSED	1
#define AIRLOCK_CLOSING	2
#define AIRLOCK_OPEN	3
#define AIRLOCK_OPENING	4
#define AIRLOCK_DENY	5
#define AIRLOCK_EMAG	6

#define AIRLOCK_SECURITY_NONE			0 //Normal airlock				//Wires are not secured
#define AIRLOCK_SECURITY_METAL			1 //Medium security airlock		//There is a simple metal over wires (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_I_S	2 								//Sliced inner plating (use crowbar), jumps to 0
#define AIRLOCK_SECURITY_PLASTEEL_I		3 								//Removed outer plating, second layer here (use welder)
#define AIRLOCK_SECURITY_PLASTEEL_O_S	4 								//Sliced outer plating (use crowbar)
#define AIRLOCK_SECURITY_PLASTEEL_O		5 								//There is first layer of plasteel (use welder)
#define AIRLOCK_SECURITY_PLASTEEL		6 //Max security airlock		//Fully secured wires (use wirecutters to remove grille, that is electrified)

#define AIRLOCK_INTEGRITY_N			 300 // Normal airlock integrity
#define AIRLOCK_INTEGRITY_MULTIPLIER 1.5 // How much reinforced doors health increases
#define AIRLOCK_DAMAGE_DEFLECTION_N  21  // Normal airlock damage deflection
#define AIRLOCK_DAMAGE_DEFLECTION_R  30  // Reinforced airlock damage deflection

#define NOT_ELECTRIFIED 0
#define ELECTRIFIED_PERMANENT -1
#define AI_ELECTRIFY_DOOR_TIME 30

/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "closed"
	max_integrity = 300
	var/normal_integrity = AIRLOCK_INTEGRITY_N
	integrity_failure = 70
	damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
	autoclose = TRUE
	secondsElectrified = 0 //How many seconds remain until the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	assemblytype = /obj/structure/door_assembly
	normalspeed = 1
	explosion_block = 1
	hud_possible = list(DIAG_AIRLOCK_HUD)

	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN

	var/security_level = 0 //How much are wires secured
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = FALSE // if true, this door can't be hacked by the AI
	var/secondsMainPowerLost = 0 //The number of seconds until power is restored.
	var/secondsBackupPowerLost = 0 //The number of seconds until power is restored.
	var/spawnPowerRestoreRunning = FALSE
	var/lights = TRUE // bolt lights show by default
	var/aiDisabledIdScanner = FALSE
	var/aiHacking = FALSE
	var/closeOtherId //Cyclelinking for airlocks that aren't on the same x or y coord as the target.
	var/obj/machinery/door/airlock/closeOther
	var/justzap = FALSE
	var/obj/item/electronics/airlock/electronics
	var/shockCooldown = FALSE //Prevents multiple shocks from happening
	var/obj/item/device/doorCharge/charge //If applied, causes an explosion upon opening the door
	var/obj/item/note //Any papers pinned to the airlock
	var/detonated = FALSE
	var/abandoned = FALSE
	var/doorOpen = 'sound/machines/airlock.ogg'
	var/doorClose = 'sound/machines/airlockclose.ogg'
	var/doorDeni = 'sound/machines/deniedbeep.ogg' // i'm thinkin' Deni's
	var/boltUp = 'sound/machines/boltsup.ogg'
	var/boltDown = 'sound/machines/boltsdown.ogg'
	var/noPower = 'sound/machines/doorclick.ogg'
	var/previous_airlock = /obj/structure/door_assembly //what airlock assembly mineral plating was applied to
	var/airlock_material //material of inner filling; if its an airlock with glass, this should be set to "glass"
	var/overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
	var/note_overlay_file = 'icons/obj/doors/airlocks/station/overlays.dmi' //Used for papers and photos pinned to the airlock

	var/cyclelinkeddir = 0
	var/obj/machinery/door/airlock/cyclelinkedairlock
	var/shuttledocked = 0
	var/delayed_close_requested = FALSE // TRUE means the door will automatically close the next time it's opened.

	var/air_tight = FALSE	//TRUE means density will be set as soon as the door begins to close
	var/prying_so_hard = FALSE

	var/static/list/airlock_overlays = list()

/obj/machinery/door/airlock/Initialize()
	. = ..()
	wires = new /datum/wires/airlock(src)
	if(frequency)
		set_frequency(frequency)

	if(closeOtherId != null)
		addtimer(CALLBACK(.proc/update_other_id), 5)
	if(glass)
		airlock_material = "glass"
	if(security_level > AIRLOCK_SECURITY_METAL)
		obj_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
		max_integrity = normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER
	else
		obj_integrity = normal_integrity
		max_integrity = normal_integrity
	if(damage_deflection == AIRLOCK_DAMAGE_DEFLECTION_N && security_level > AIRLOCK_SECURITY_METAL)
		damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_electrified()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/door/airlock/LateInitialize()
	. = ..()
	if (cyclelinkeddir)
		cyclelinkairlock()
	if(abandoned)
		var/outcome = rand(1,100)
		switch(outcome)
			if(1 to 9)
				var/turf/here = get_turf(src)
				for(var/turf/closed/T in range(2, src))
					here.PlaceOnTop(T.type)
					qdel(src)
					return
				here.PlaceOnTop(/turf/closed/wall)
				qdel(src)
				return
			if(9 to 11)
				lights = FALSE
				locked = TRUE
			if(12 to 15)
				locked = TRUE
			if(16 to 23)
				welded = TRUE
			if(24 to 30)
				panel_open = TRUE

	update_icon()

/obj/machinery/door/airlock/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/ntnet_interface)
	AddComponent(/datum/component/rad_insulation, RAD_MEDIUM_INSULATION)

/obj/machinery/door/airlock/proc/update_other_id()
	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.closeOtherId == closeOtherId && A != src)
			closeOther = A
			break

/obj/machinery/door/airlock/proc/cyclelinkairlock()
	if (cyclelinkedairlock)
		cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if (!cyclelinkeddir)
		return
	var/limit = world.view
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/FoundDoor
	do
		T = get_step(T, cyclelinkeddir)
		FoundDoor = locate() in T
		if (FoundDoor && FoundDoor.cyclelinkeddir != get_dir(FoundDoor, src))
			FoundDoor = null
		limit--
	while(!FoundDoor && limit)
	if (!FoundDoor)
		log_world("### MAP WARNING, [src] at [get_area_name(src, TRUE)] [COORD(src)] failed to find a valid airlock to cyclelink with!")
		return
	FoundDoor.cyclelinkedairlock = src
	cyclelinkedairlock = FoundDoor

/obj/machinery/door/airlock/vv_edit_var(var_name)
	. = ..()
	switch (var_name)
		if ("cyclelinkeddir")
			cyclelinkairlock()

/obj/machinery/door/airlock/check_access_ntnet(datum/netdata/data)
	return !requiresID() || ..()

/obj/machinery/door/airlock/ntnet_recieve(datum/netdata/data)
	// Check if the airlock is powered and can accept control packets.
	if(!hasPower() || !canAIControl())
		return

	// Check packet access level.
	if(!check_access_ntnet(data))
		return

	// Handle recieved packet.
	var/command = lowertext(data.plaintext_data)
	var/command_value = lowertext(data.plaintext_data_secondary)
	switch(command)
		if("open")
			if(command_value == "on" && !density)
				return

			if(command_value == "off" && density)
				return

			if(density)
				INVOKE_ASYNC(src, .proc/open)
			else
				INVOKE_ASYNC(src, .proc/close)

		if("bolt")
			if(command_value == "on" && locked)
				return

			if(command_value == "off" && !locked)
				return

			if(locked)
				unbolt()
			else
				bolt()

		if("emergency")
			if(command_value == "on" && emergency)
				return

			if(command_value == "off" && !emergency)
				return

			emergency = !emergency
			update_icon()

/obj/machinery/door/airlock/lock()
	bolt()

/obj/machinery/door/airlock/proc/bolt()
	if(locked)
		return
	locked = TRUE
	playsound(src,boltDown,30,0,3)
	audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
	update_icon()

/obj/machinery/door/airlock/unlock()
	unbolt()

/obj/machinery/door/airlock/proc/unbolt()
	if(!locked)
		return
	locked = FALSE
	playsound(src,boltUp,30,0,3)
	audible_message("<span class='italics'>You hear a click from the bottom of the door.</span>", null,  1)
	update_icon()

/obj/machinery/door/airlock/narsie_act()
	var/turf/T = get_turf(src)
	var/obj/machinery/door/airlock/cult/A
	if(GLOB.cult_narsie)
		var/runed = prob(20)
		if(glass)
			if(runed)
				A = new/obj/machinery/door/airlock/cult/glass(T)
			else
				A = new/obj/machinery/door/airlock/cult/unruned/glass(T)
		else
			if(runed)
				A = new/obj/machinery/door/airlock/cult(T)
			else
				A = new/obj/machinery/door/airlock/cult/unruned(T)
		A.name = name
	else
		A = new /obj/machinery/door/airlock/cult/weak(T)
	qdel(src)

/obj/machinery/door/airlock/ratvar_act() //Airlocks become pinion airlocks that only allow servants
	var/obj/machinery/door/airlock/clockwork/A
	if(glass)
		A = new/obj/machinery/door/airlock/clockwork/brass(get_turf(src))
	else
		A = new/obj/machinery/door/airlock/clockwork(get_turf(src))
	A.name = name
	qdel(src)

/obj/machinery/door/airlock/Destroy()
	QDEL_NULL(wires)
	if(charge)
		qdel(charge)
		charge = null
	QDEL_NULL(electronics)
	if (cyclelinkedairlock)
		if (cyclelinkedairlock.cyclelinkedairlock == src)
			cyclelinkedairlock.cyclelinkedairlock = null
		cyclelinkedairlock = null
	if(id_tag)
		for(var/obj/machinery/doorButtons/D in GLOB.machines)
			D.removeMe(src)
	qdel(note)
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.remove_from_hud(src)
	return ..()

/obj/machinery/door/airlock/handle_atom_del(atom/A)
	if(A == note)
		note = null
		update_icon()

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(isElectrified())
			if(!justzap)
				if(shock(user, 100))
					justzap = TRUE
					addtimer(VARSET_CALLBACK(src, justzap, FALSE) , 10)
					return
			else
				return
		else if(user.hallucinating() && ishuman(user) && prob(4) && !operating)
			var/mob/living/carbon/human/H = user
			if(H.gloves)
				var/obj/item/clothing/gloves/G = H.gloves
				if(G.siemens_coefficient)//not insulated
					hallucinate_shock(H)
					return
	if (cyclelinkedairlock)
		if (!shuttledocked && !emergency && !cyclelinkedairlock.shuttledocked && !cyclelinkedairlock.emergency && allowed(user))
			if(cyclelinkedairlock.operating)
				cyclelinkedairlock.delayed_close_requested = TRUE
			else
				addtimer(CALLBACK(cyclelinkedairlock, .proc/close), 2)
	..()

/obj/machinery/door/airlock/proc/hallucinate_shock(mob/living/user)
	var/image/shock_image = image(user, user, dir = user.dir)
	var/image/electrocution_skeleton_anim = image('icons/mob/human.dmi', user, icon_state = "electrocuted_base", layer=ABOVE_MOB_LAYER)
	shock_image.color = rgb(0,0,0)
	shock_image.override = TRUE
	electrocution_skeleton_anim.appearance_flags |= RESET_COLOR|KEEP_APART

	to_chat(user, "<span class='userdanger'>You feel a powerful shock course through your body!</span>")
	if(user.client)
		user.client.images |= shock_image
		user.client.images |= electrocution_skeleton_anim
	addtimer(CALLBACK(src, .proc/reset_hallucinate_shock_animation, user, shock_image, electrocution_skeleton_anim), 40)
	user.playsound_local(get_turf(src), "sparks", 100, 1)
	user.staminaloss += 50
	user.Stun(40)
	user.jitteriness += 1000
	user.do_jitter_animation(user.jitteriness)
	addtimer(CALLBACK(src, .proc/hallucinate_shock_drop, user), 20)

/obj/machinery/door/airlock/proc/reset_hallucinate_shock_animation(mob/living/user, shock_image, electrocution_skeleton_anim)
	if(user.client)
		user.client.images.Remove(shock_image)
		user.client.images.Remove(electrocution_skeleton_anim)

/obj/machinery/door/airlock/proc/hallucinate_shock_drop(mob/living/user)
	user.jitteriness = max(user.jitteriness - 990, 10) //Still jittery, but vastly less
	user.Knockdown(60)

/obj/machinery/door/airlock/proc/isElectrified()
	if(src.secondsElectrified != NOT_ELECTRIFIED)
		return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/canAIControl(mob/user)
	return ((aiControlDisabled != 1) && !isAllPowerCut())

/obj/machinery/door/airlock/proc/canAIHack()
	return ((aiControlDisabled==1) && (!hackProof) && (!isAllPowerCut()));

/obj/machinery/door/airlock/hasPower()
	return ((!secondsMainPowerLost || !secondsBackupPowerLost) && !(stat & NOPOWER))

/obj/machinery/door/airlock/requiresID()
	return !(wires.is_cut(WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerCut()
	if((wires.is_cut(WIRE_POWER1) || wires.is_cut(WIRE_POWER2)) && (wires.is_cut(WIRE_BACKUP1) || wires.is_cut(WIRE_BACKUP2)))
		return TRUE

/obj/machinery/door/airlock/proc/regainMainPower()
	if(src.secondsMainPowerLost > 0)
		src.secondsMainPowerLost = 0

/obj/machinery/door/airlock/proc/handlePowerRestore()
	var/cont = TRUE
	while (cont)
		sleep(10)
		if(QDELETED(src))
			return
		cont = FALSE
		if(secondsMainPowerLost>0)
			if(!wires.is_cut(WIRE_POWER1) && !wires.is_cut(WIRE_POWER2))
				secondsMainPowerLost -= 1
				updateDialog()
			cont = TRUE
		if(secondsBackupPowerLost>0)
			if(!wires.is_cut(WIRE_BACKUP1) && !wires.is_cut(WIRE_BACKUP2))
				secondsBackupPowerLost -= 1
				updateDialog()
			cont = TRUE
	spawnPowerRestoreRunning = FALSE
	updateDialog()

/obj/machinery/door/airlock/proc/loseMainPower()
	if(secondsMainPowerLost <= 0)
		secondsMainPowerLost = 60
		if(secondsBackupPowerLost < 10)
			secondsBackupPowerLost = 10
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, .proc/handlePowerRestore)

/obj/machinery/door/airlock/proc/loseBackupPower()
	if(src.secondsBackupPowerLost < 60)
		src.secondsBackupPowerLost = 60
	if(!spawnPowerRestoreRunning)
		spawnPowerRestoreRunning = TRUE
	INVOKE_ASYNC(src, .proc/handlePowerRestore)

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(src.secondsBackupPowerLost > 0)
		src.secondsBackupPowerLost = 0

// shock user with probability prb (if all connections & power are working)
// returns TRUE if shocked, FALSE otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/proc/shock(mob/user, prb)
	if(!hasPower())		// unpowered, no shock
		return FALSE
	if(shockCooldown > world.time)
		return FALSE	//Already shocked someone recently?
	if(!prob(prb))
		return FALSE //you lucked out, no shock for you
	do_sparks(5, TRUE, src)
	var/tmp/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 1, check_range))
		shockCooldown = world.time + 10
		return TRUE
	else
		return FALSE

/obj/machinery/door/airlock/update_icon(state=0, override=0)
	if(operating && !override)
		return
	switch(state)
		if(0)
			if(density)
				state = AIRLOCK_CLOSED
			else
				state = AIRLOCK_OPEN
			icon_state = ""
		if(AIRLOCK_OPEN, AIRLOCK_CLOSED)
			icon_state = ""
		if(AIRLOCK_DENY, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_EMAG)
			icon_state = "nonexistenticonstate" //MADNESS
	set_airlock_overlays(state)

/obj/machinery/door/airlock/proc/set_airlock_overlays(state)
	var/mutable_appearance/frame_overlay
	var/mutable_appearance/filling_overlay
	var/mutable_appearance/lights_overlay
	var/mutable_appearance/panel_overlay
	var/mutable_appearance/weld_overlay
	var/mutable_appearance/damag_overlay
	var/mutable_appearance/sparks_overlay
	var/mutable_appearance/note_overlay
	var/notetype = note_type()

	switch(state)
		if(AIRLOCK_CLOSED)
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(lights && hasPower())
				if(locked)
					lights_overlay = get_airlock_overlay("lights_bolts", overlays_file)
				else if(emergency)
					lights_overlay = get_airlock_overlay("lights_emergency", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_DENY)
			if(!hasPower())
				return
			frame_overlay = get_airlock_overlay("closed", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			lights_overlay = get_airlock_overlay("lights_denied", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_EMAG)
			frame_overlay = get_airlock_overlay("closed", icon)
			sparks_overlay = get_airlock_overlay("sparks", overlays_file)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closed", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closed", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closed_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closed", overlays_file)
			if(obj_integrity <integrity_failure)
				damag_overlay = get_airlock_overlay("sparks_broken", overlays_file)
			else if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_damaged", overlays_file)
			if(welded)
				weld_overlay = get_airlock_overlay("welded", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay(notetype, note_overlay_file)

		if(AIRLOCK_CLOSING)
			frame_overlay = get_airlock_overlay("closing", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_closing", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_closing", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_closing", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_closing_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_closing", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_closing", note_overlay_file)

		if(AIRLOCK_OPEN)
			frame_overlay = get_airlock_overlay("open", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_open", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_open", icon)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_open_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_open", overlays_file)
			if(obj_integrity < (0.75 * max_integrity))
				damag_overlay = get_airlock_overlay("sparks_open", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_open", note_overlay_file)

		if(AIRLOCK_OPENING)
			frame_overlay = get_airlock_overlay("opening", icon)
			if(airlock_material)
				filling_overlay = get_airlock_overlay("[airlock_material]_opening", overlays_file)
			else
				filling_overlay = get_airlock_overlay("fill_opening", icon)
			if(lights && hasPower())
				lights_overlay = get_airlock_overlay("lights_opening", overlays_file)
			if(panel_open)
				if(security_level)
					panel_overlay = get_airlock_overlay("panel_opening_protected", overlays_file)
				else
					panel_overlay = get_airlock_overlay("panel_opening", overlays_file)
			if(note)
				note_overlay = get_airlock_overlay("[notetype]_opening", note_overlay_file)

	cut_overlays()
	add_overlay(frame_overlay)
	add_overlay(filling_overlay)
	add_overlay(lights_overlay)
	add_overlay(panel_overlay)
	add_overlay(weld_overlay)
	add_overlay(sparks_overlay)
	add_overlay(damag_overlay)
	add_overlay(note_overlay)

/proc/get_airlock_overlay(icon_state, icon_file)
	var/obj/machinery/door/airlock/A
	pass(A)	//suppress unused warning
	var/list/airlock_overlays = A.airlock_overlays
	var/iconkey = "[icon_state][icon_file]"
	if((!(. = airlock_overlays[iconkey])))
		. = airlock_overlays[iconkey] = mutable_appearance(icon_file, icon_state)

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			update_icon(AIRLOCK_OPENING)
		if("closing")
			update_icon(AIRLOCK_CLOSING)
		if("deny")
			if(!stat)
				update_icon(AIRLOCK_DENY)
				playsound(src,doorDeni,50,0,3)
				sleep(6)
				update_icon(AIRLOCK_CLOSED)

/obj/machinery/door/airlock/examine(mob/user)
	..()
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Its access panel is smoking slightly.</span>")
	if(charge && !panel_open && in_range(user, src))
		to_chat(user, "<span class='warning'>The maintenance panel seems haphazardly fastened.</span>")
	if(charge && panel_open)
		to_chat(user, "<span class='warning'>Something is wired up to the airlock's electronics!</span>")
	if(note)
		if(!in_range(user, src))
			to_chat(user, "There's a [note.name] pinned to the front. You can't read it from here.")
		else
			to_chat(user, "There's a [note.name] pinned to the front...")
			note.examine(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				to_chat(user, "Its wires are exposed!")
			if(AIRLOCK_SECURITY_METAL)
				to_chat(user, "Its wires are hidden behind a welded metal cover.")
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				to_chat(user, "There is some shredded plasteel inside.")
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				to_chat(user, "Its wires are behind an inner layer of plasteel.")
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				to_chat(user, "There is some shredded plasteel inside.")
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				to_chat(user, "There is a welded plasteel cover hiding its wires.")
			if(AIRLOCK_SECURITY_PLASTEEL)
				to_chat(user, "There is a protective grille over its panel.")
	else if(security_level)
		if(security_level == AIRLOCK_SECURITY_METAL)
			to_chat(user, "It looks a bit stronger.")
		else
			to_chat(user, "It looks very robust.")

/obj/machinery/door/airlock/attack_ai(mob/user)
	if(!src.canAIControl(user))
		if(src.canAIHack())
			src.hack(user)
			return
		else
			to_chat(user, "<span class='warning'>Airlock AI control has been blocked with a firewall. Unable to hack.</span>")
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>Unable to interface: Airlock is unresponsive.</span>")
		return
	if(detonated)
		to_chat(user, "<span class='warning'>Unable to interface. Airlock control panel damaged.</span>")
		return

	ui_interact(user)

/obj/machinery/door/airlock/proc/hack(mob/user)
	set waitfor = 0
	if(!aiHacking)
		aiHacking = TRUE
		to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
		sleep(50)
		if(src.canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!src.canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
		sleep(20)
		to_chat(user, "Attempting to hack into airlock. This may take some time.")
		sleep(200)
		if(src.canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!src.canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
		sleep(170)
		if(src.canAIControl(user))
			to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
			aiHacking = FALSE
			return
		else if(!src.canAIHack())
			to_chat(user, "Connection lost! Unable to hack airlock.")
			aiHacking = FALSE
			return
		to_chat(user, "Transfer complete. Forcing airlock to execute program.")
		sleep(50)
		//disable blocked control
		src.aiControlDisabled = 2
		to_chat(user, "Receiving control information from airlock.")
		sleep(10)
		//bring up airlock dialog
		aiHacking = FALSE
		if(user)
			src.attack_ai(user)

/obj/machinery/door/airlock/attack_animal(mob/user)
	. = ..()
	if(isElectrified())
		shock(user, 100)

/obj/machinery/door/airlock/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/door/airlock/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(!(issilicon(user) || IsAdminGhost(user)))
		if(src.isElectrified())
			if(src.shock(user, 100))
				return

	if(ishuman(user) && prob(40) && src.density)
		var/mob/living/carbon/human/H = user
		if((H.has_trait(TRAIT_DUMB)) && Adjacent(user))
			playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
			if(!istype(H.head, /obj/item/clothing/head/helmet))
				H.visible_message("<span class='danger'>[user] headbutts the airlock.</span>", \
									"<span class='userdanger'>You headbutt the airlock!</span>")
				H.Knockdown(100)
				H.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
			else
				visible_message("<span class='danger'>[user] headbutts the airlock. Good thing [user.p_theyre()] wearing a helmet.</span>")

/obj/machinery/door/airlock/attempt_wire_interaction(mob/user)
	if(security_level)
		to_chat(user, "<span class='warning'>Wires are protected!</span>")
		return WIRE_INTERACTION_FAIL
	return ..()

/obj/machinery/door/airlock/proc/electrified_loop()
	while (secondsElectrified > 0)
		sleep(10)
		if(QDELETED(src))
			return

		secondsElectrified -= 1
		updateDialog()
	// This is to protect against changing to permanent, mid loop.
	if(secondsElectrified==0)
		set_electrified(NOT_ELECTRIFIED)
	else
		set_electrified(ELECTRIFIED_PERMANENT)
	updateDialog()

/obj/machinery/door/airlock/Topic(href, href_list, var/nowindow = 0)
	// If you add an if(..()) check you must first remove the var/nowindow parameter.
	// Otherwise it will runtime with this kind of error: null.Topic()
	if(!nowindow)
		..()
	if(!usr.canUseTopic(src) && !IsAdminGhost(usr))
		return
	add_fingerprint(usr)

	if((in_range(src, usr) && isturf(loc)) && panel_open)
		usr.set_machine(src)

	add_fingerprint(usr)
	if(!nowindow)
		updateUsrDialog()
	else
		updateDialog()


/obj/machinery/door/airlock/attackby(obj/item/C, mob/user, params)
	if(!issilicon(user) && !IsAdminGhost(user))
		if(src.isElectrified())
			if(src.shock(user, 75))
				return
	add_fingerprint(user)

	if(panel_open)
		switch(security_level)
			if(AIRLOCK_SECURITY_NONE)
				if(istype(C, /obj/item/stack/sheet/metal))
					var/obj/item/stack/sheet/metal/S = C
					if(S.get_amount() < 2)
						to_chat(user, "<span class='warning'>You need at least 2 metal sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src].</span>")
					if(do_after(user, 20, 1, target = src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforce \the [src] with metal.</span>",
											"<span class='notice'>You reinforce \the [src] with metal.</span>")
						security_level = AIRLOCK_SECURITY_METAL
						update_icon()
					return
				else if(istype(C, /obj/item/stack/sheet/plasteel))
					var/obj/item/stack/sheet/plasteel/S = C
					if(S.get_amount() < 2)
						to_chat(user, "<span class='warning'>You need at least 2 plasteel sheets to reinforce [src].</span>")
						return
					to_chat(user, "<span class='notice'>You start reinforcing [src].</span>")
					if(do_after(user, 20, 1, target = src))
						if(!panel_open || !S.use(2))
							return
						user.visible_message("<span class='notice'>[user] reinforce \the [src] with plasteel.</span>",
											"<span class='notice'>You reinforce \the [src] with plasteel.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL
						modify_max_integrity(normal_integrity * AIRLOCK_INTEGRITY_MULTIPLIER)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_R
						update_icon()
					return
			if(AIRLOCK_SECURITY_METAL)
				if(istype(C, /obj/item/weldingtool))
					if(!C.tool_start_check(user, amount=2))
						return
					to_chat(user, "<span class='notice'>You begin cutting the panel's shielding...</span>")
					if(C.use_tool(src, user, 40, volume=50, amount = 2))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_NONE
						spawn_atom_to_turf(/obj/item/stack/sheet/metal, user.loc, 2)
						update_icon()
					return
			if(AIRLOCK_SECURITY_PLASTEEL_I_S)
				if(istype(C, /obj/item/crowbar))
					var/obj/item/crowbar/W = C
					to_chat(user, "<span class='notice'>You start removing the inner layer of shielding...</span>")
					if(W.use_tool(src, user, 40, volume=100))
						if(!panel_open)
							return
						if(security_level != AIRLOCK_SECURITY_PLASTEEL_I_S)
							return
						user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
											"<span class='notice'>You remove \the [src]'s inner shielding.</span>")
						security_level = AIRLOCK_SECURITY_NONE
						modify_max_integrity(normal_integrity)
						damage_deflection = AIRLOCK_DAMAGE_DEFLECTION_N
						spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
						update_icon()
					return
			if(AIRLOCK_SECURITY_PLASTEEL_I)
				if(istype(C, /obj/item/weldingtool))
					if(!C.tool_start_check(user, amount=2))
						return
					to_chat(user, "<span class='notice'>You begin cutting the inner layer of shielding...</span>")
					if(C.use_tool(src, user, 40, volume=50, amount=2))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_I_S
					return
			if(AIRLOCK_SECURITY_PLASTEEL_O_S)
				if(istype(C, /obj/item/crowbar))
					to_chat(user, "<span class='notice'>You start removing outer layer of shielding...</span>")
					if(C.use_tool(src, user, 40, volume=100))
						if(!panel_open)
							return
						if(security_level != AIRLOCK_SECURITY_PLASTEEL_O_S)
							return
						user.visible_message("<span class='notice'>[user] remove \the [src]'s shielding.</span>",
											"<span class='notice'>You remove \the [src]'s shielding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_I
						spawn_atom_to_turf(/obj/item/stack/sheet/plasteel, user.loc, 1)
					return
			if(AIRLOCK_SECURITY_PLASTEEL_O)
				if(istype(C, /obj/item/weldingtool))
					if(!C.tool_start_check(user, amount=2))
						return
					to_chat(user, "<span class='notice'>You begin cutting the outer layer of shielding...</span>")
					if(C.use_tool(src, user, 40, volume=50, amount=2))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cuts through \the [src]'s shielding.</span>",
										"<span class='notice'>You cut through \the [src]'s shielding.</span>",
										"<span class='italics'>You hear welding.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_O_S
					return
			if(AIRLOCK_SECURITY_PLASTEEL)
				if(istype(C, /obj/item/wirecutters))
					if(src.hasPower() && src.shock(user, 60)) // Protective grille of wiring is electrified
						return
					to_chat(user, "<span class='notice'>You start cutting through the outer grille.</span>")
					if(C.use_tool(src, user, 10, volume=100))
						if(!panel_open)
							return
						user.visible_message("<span class='notice'>[user] cut through \the [src]'s outer grille.</span>",
											"<span class='notice'>You cut through \the [src]'s outer grille.</span>")
						security_level = AIRLOCK_SECURITY_PLASTEEL_O
					return
	if(istype(C, /obj/item/screwdriver))
		if(panel_open && detonated)
			to_chat(user, "<span class='warning'>[src] has no maintenance panel!</span>")
			return
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open":"close"] the maintenance panel of the airlock.</span>")
		C.play_tool_sound(src)
		src.update_icon()
	else if(istype(C, /obj/item/wirecutters) && note)
		user.visible_message("<span class='notice'>[user] cuts down [note] from [src].</span>", "<span class='notice'>You remove [note] from [src].</span>")
		C.play_tool_sound(src)
		note.forceMove(get_turf(user))
		note = null
		update_icon()
	else if(is_wire_tool(C) && panel_open)
		attempt_wire_interaction(user)
		return
	else if(istype(C, /obj/item/pai_cable))
		var/obj/item/pai_cable/cable = C
		cable.plugin(src, user)
	else if(istype(C, /obj/item/airlock_painter))
		change_paintjob(C, user)
	else if(istype(C, /obj/item/device/doorCharge))
		if(!panel_open || security_level)
			to_chat(user, "<span class='warning'>The maintenance panel must be open to apply [C]!</span>")
			return
		if(obj_flags & EMAGGED)
			return
		if(charge && !detonated)
			to_chat(user, "<span class='warning'>There's already a charge hooked up to this door!</span>")
			return
		if(detonated)
			to_chat(user, "<span class='warning'>The maintenance panel is destroyed!</span>")
			return
		to_chat(user, "<span class='warning'>You apply [C]. Next time someone opens the door, it will explode.</span>")
		panel_open = FALSE
		update_icon()
		user.transferItemToLoc(C, src, TRUE)
		charge = C
	else if(istype(C, /obj/item/paper) || istype(C, /obj/item/photo))
		if(note)
			to_chat(user, "<span class='warning'>There's already something pinned to this airlock! Use wirecutters to remove it.</span>")
			return
		if(!user.transferItemToLoc(C, src))
			to_chat(user, "<span class='warning'>For some reason, you can't attach [C]!</span>")
			return
		user.visible_message("<span class='notice'>[user] pins [C] to [src].</span>", "<span class='notice'>You pin [C] to [src].</span>")
		note = C
		update_icon()
	else
		return ..()


/obj/machinery/door/airlock/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!operating && density)
		if(user.a_intent != INTENT_HELP)
			if(!W.tool_start_check(user, amount=0))
				return
			user.visible_message("[user] is [welded ? "unwelding":"welding"] the airlock.", \
							"<span class='notice'>You begin [welded ? "unwelding":"welding"] the airlock...</span>", \
							"<span class='italics'>You hear welding.</span>")
			if(W.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, .proc/weld_checks, W, user)))
				welded = !welded
				user.visible_message("[user.name] has [welded? "welded shut":"unwelded"] [src].", \
									"<span class='notice'>You [welded ? "weld the airlock shut":"unweld the airlock"].</span>")
				update_icon()
		else
			if(obj_integrity < max_integrity)
				if(!W.tool_start_check(user, amount=0))
					return
				user.visible_message("[user] is welding the airlock.", \
								"<span class='notice'>You begin repairing the airlock...</span>", \
								"<span class='italics'>You hear welding.</span>")
				if(W.use_tool(src, user, 40, volume=50, extra_checks = CALLBACK(src, .proc/weld_checks, W, user)))
					obj_integrity = max_integrity
					stat &= ~BROKEN
					user.visible_message("[user.name] has repaired [src].", \
										"<span class='notice'>You finish repairing the airlock.</span>")
					update_icon()
			else
				to_chat(user, "<span class='notice'>The airlock doesn't need repairing.</span>")

/obj/machinery/door/airlock/proc/weld_checks(obj/item/weldingtool/W, mob/user)
	return !operating && density

/obj/machinery/door/airlock/try_to_crowbar(obj/item/I, mob/living/user)
	var/beingcrowbarred = null
	if(istype(I, /obj/item/crowbar) )
		beingcrowbarred = 1
	else
		beingcrowbarred = 0
	if(panel_open && charge)
		to_chat(user, "<span class='notice'>You carefully start removing [charge] from [src]...</span>")
		if(!I.use_tool(src, user, 150, volume=50))
			to_chat(user, "<span class='warning'>You slip and [charge] detonates!</span>")
			charge.ex_act(EXPLODE_DEVASTATE)
			user.Knockdown(60)
			return
		user.visible_message("<span class='notice'>[user] removes [charge] from [src].</span>", \
							 "<span class='notice'>You gently pry out [charge] from [src] and unhook its wires.</span>")
		charge.forceMove(get_turf(user))
		charge = null
		return
	if(beingcrowbarred && panel_open && ((obj_flags & EMAGGED) || (density && welded && !operating && !hasPower() && !locked)))
		user.visible_message("[user] removes the electronics from the airlock assembly.", \
							 "<span class='notice'>You start to remove electronics from the airlock assembly...</span>")
		if(I.use_tool(src, user, 40, volume=100))
			deconstruct(TRUE, user)
			return
	else if(hasPower())
		to_chat(user, "<span class='warning'>The airlock's motors resist your efforts to force it!</span>")
	else if(locked)
		to_chat(user, "<span class='warning'>The airlock's bolts prevent it from being forced!</span>")
	else if( !welded && !operating)
		if(!beingcrowbarred) //being fireaxe'd
			var/obj/item/twohanded/fireaxe/F = I
			if(F.wielded)
				INVOKE_ASYNC(src, (density ? .proc/open : .proc/close), 2)
			else
				to_chat(user, "<span class='warning'>You need to be wielding the fire axe to do that!</span>")
		else
			INVOKE_ASYNC(src, (density ? .proc/open : .proc/close), 2)

	if(istype(I, /obj/item/crowbar/power))
		if(isElectrified())
			shock(user,100)//it's like sticking a forck in a power socket
			return

		if(!density)//already open
			return

		if(locked)
			to_chat(user, "<span class='warning'>The bolts are down, it won't budge!</span>")
			return

		if(welded)
			to_chat(user, "<span class='warning'>It's welded, it won't budge!</span>")
			return

		var/time_to_open = 5
		if(hasPower() && !prying_so_hard)
			time_to_open = 50
			playsound(src, 'sound/machines/airlock_alien_prying.ogg',100,1) //is it aliens or just the CE being a dick?
			prying_so_hard = TRUE
			var/result = do_after(user, time_to_open,target = src)
			prying_so_hard = FALSE
			if(result)
				open(2)
				if(density && !open(2))
					to_chat(user, "<span class='warning'>Despite your attempts, [src] refuses to open.</span>")

/obj/machinery/door/airlock/open(forced=0)
	if( operating || welded || locked )
		return FALSE
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_OPEN))
			return FALSE
	if(charge && !detonated)
		panel_open = TRUE
		update_icon(AIRLOCK_OPENING)
		visible_message("<span class='warning'>[src]'s panel is blown off in a spray of deadly shrapnel!</span>")
		charge.forceMove(drop_location())
		charge.ex_act(EXPLODE_DEVASTATE)
		detonated = 1
		charge = null
		for(var/mob/living/carbon/human/H in orange(2,src))
			H.Unconscious(160)
			H.adjust_fire_stacks(20)
			H.IgniteMob() //Guaranteed knockout and ignition for nearby people
			H.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
		return
	if(forced < 2)
		if(obj_flags & EMAGGED)
			return FALSE
		use_power(50)
		playsound(src, doorOpen, 30, 1)
		if(src.closeOther != null && istype(src.closeOther, /obj/machinery/door/airlock/) && !src.closeOther.density)
			src.closeOther.close()
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	if(autoclose && normalspeed)
		addtimer(CALLBACK(src, .proc/autoclose), 150)
	else if(autoclose && !normalspeed)
		addtimer(CALLBACK(src, .proc/autoclose), 15)

	if(!density)
		return TRUE
	operating = TRUE
	update_icon(AIRLOCK_OPENING, 1)
	sleep(1)
	set_opacity(0)
	update_freelook_sight()
	sleep(4)
	density = FALSE
	air_update_turf(1)
	sleep(1)
	layer = OPEN_DOOR_LAYER
	update_icon(AIRLOCK_OPEN, 1)
	operating = FALSE
	if(delayed_close_requested)
		delayed_close_requested = FALSE
		addtimer(CALLBACK(src, .proc/close), 1)
	return TRUE


/obj/machinery/door/airlock/close(forced=0)
	if(operating || welded || locked)
		return
	if(density)
		return TRUE
	if(!forced)
		if(!hasPower() || wires.is_cut(WIRE_BOLTS))
			return
	if(safe)
		for(var/atom/movable/M in get_turf(src))
			if(M.density && M != src) //something is blocking the door
				addtimer(CALLBACK(src, .proc/autoclose), 60)
				return

	if(forced < 2)
		if(obj_flags & EMAGGED)
			return
		use_power(50)
		playsound(src.loc, doorClose, 30, 1)
	else
		playsound(src.loc, 'sound/machines/airlockforced.ogg', 30, 1)

	var/obj/structure/window/killthis = (locate(/obj/structure/window) in get_turf(src))
	if(killthis)
		killthis.ex_act(EXPLODE_HEAVY)//Smashin windows

	operating = TRUE
	update_icon(AIRLOCK_CLOSING, 1)
	layer = CLOSED_DOOR_LAYER
	if(air_tight)
		density = TRUE
		air_update_turf(1)
	sleep(1)
	if(!air_tight)
		density = TRUE
		air_update_turf(1)
	sleep(4)
	if(!safe)
		crush()
	if(visible && !glass)
		set_opacity(1)
	update_freelook_sight()
	sleep(1)
	update_icon(AIRLOCK_CLOSED, 1)
	operating = FALSE
	delayed_close_requested = FALSE
	if(safe)
		CheckForMobs()
	return TRUE

/obj/machinery/door/airlock/proc/prison_open()
	if(obj_flags & EMAGGED)
		return
	locked = FALSE
	src.open()
	locked = TRUE
	return


/obj/machinery/door/airlock/proc/change_paintjob(obj/item/airlock_painter/W, mob/user)
	if(!W.can_use(user))
		return

	var/list/optionlist
	if(airlock_material == "glass")
		optionlist = list("Standard", "Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Science", "Virology", "Mining", "Maintenance", "External", "External Maintenance")
	else
		optionlist = list("Standard", "Public", "Engineering", "Atmospherics", "Security", "Command", "Medical", "Research", "Freezer", "Science", "Virology", "Mining", "Maintenance", "External", "External Maintenance")

	var/paintjob = input(user, "Please select a paintjob for this airlock.") in optionlist
	if((!in_range(src, usr) && src.loc != usr) || !W.use(user))
		return
	switch(paintjob)
		if("Standard")
			icon = 'icons/obj/doors/airlocks/station/public.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly
		if("Public")
			icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_public
		if("Engineering")
			icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_eng
		if("Atmospherics")
			icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_atmo
		if("Security")
			icon = 'icons/obj/doors/airlocks/station/security.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_sec
		if("Command")
			icon = 'icons/obj/doors/airlocks/station/command.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_com
		if("Medical")
			icon = 'icons/obj/doors/airlocks/station/medical.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_med
		if("Research")
			icon = 'icons/obj/doors/airlocks/station/research.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_research
		if("Freezer")
			icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_fre
		if("Science")
			icon = 'icons/obj/doors/airlocks/station/science.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_science
		if("Virology")
			icon = 'icons/obj/doors/airlocks/station/virology.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_viro
		if("Mining")
			icon = 'icons/obj/doors/airlocks/station/mining.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_min
		if("Maintenance")
			icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_mai
		if("External")
			icon = 'icons/obj/doors/airlocks/external/external.dmi'
			overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_ext
		if("External Maintenance")
			icon = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi'
			overlays_file = 'icons/obj/doors/airlocks/station/overlays.dmi'
			assemblytype = /obj/structure/door_assembly/door_assembly_extmai
	update_icon()

/obj/machinery/door/airlock/CanAStarPass(obj/item/card/id/ID)
//Airlock is passable if it is open (!density), bot has access, and is not bolted shut or powered off)
	return !density || (check_access(ID) && !locked && hasPower())

/obj/machinery/door/airlock/emag_act(mob/user)
	if(!operating && density && hasPower() && !(obj_flags & EMAGGED))
		operating = TRUE
		update_icon(AIRLOCK_EMAG, 1)
		sleep(6)
		if(QDELETED(src))
			return
		operating = FALSE
		if(!open())
			update_icon(AIRLOCK_CLOSED, 1)
		obj_flags |= EMAGGED
		lights = FALSE
		locked = TRUE
		loseMainPower()
		loseBackupPower()

/obj/machinery/door/airlock/attack_alien(mob/living/carbon/alien/humanoid/user)
	add_fingerprint(user)
	if(isElectrified())
		shock(user, 100) //Mmm, fried xeno!
		return
	if(!density) //Already open
		return
	if(locked || welded) //Extremely generic, as aliens only understand the basics of how airlocks work.
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	user.visible_message("<span class='warning'>[user] begins prying open [src].</span>",\
						"<span class='noticealien'>You begin digging your claws into [src] with all your might!</span>",\
						"<span class='warning'>You hear groaning metal...</span>")
	var/time_to_open = 5
	if(hasPower())
		time_to_open = 50 //Powered airlocks take longer to open, and are loud.
		playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, 1)


	if(do_after(user, time_to_open, target = src))
		if(density && !open(2)) //The airlock is still closed, but something prevented it opening. (Another player noticed and bolted/welded the airlock in time!)
			to_chat(user, "<span class='warning'>Despite your efforts, [src] managed to resist your attempts to open it!</span>")

/obj/machinery/door/airlock/hostile_lockdown(mob/origin)
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		locked = FALSE //For airlocks that were bolted open.
		safe = FALSE //DOOR CRUSH
		close()
		bolt() //Bolt it!
		set_electrified(ELECTRIFIED_PERMANENT)  //Shock it!
		if(origin)
			shockedby += "\[[time_stamp()]\][origin](ckey:[origin.ckey])"


/obj/machinery/door/airlock/disable_lockdown()
	// Must be powered and have working AI wire.
	if(canAIControl(src) && !stat)
		unbolt()
		set_electrified(NOT_ELECTRIFIED)
		open()
		safe = TRUE


/obj/machinery/door/airlock/obj_break(damage_flag)
	if(!(flags_1 & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN
		if(!panel_open)
			panel_open = TRUE
		wires.cut_all()
		update_icon()

/obj/machinery/door/airlock/proc/set_electrified(seconds)
	secondsElectrified = seconds
	diag_hud_set_electrified()
	if(secondsElectrified > 0)
		INVOKE_ASYNC(src, .proc/electrified_loop)

/obj/machinery/door/airlock/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(obj_integrity < (0.75 * max_integrity))
		update_icon()


/obj/machinery/door/airlock/deconstruct(disassembled = TRUE, mob/user)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/door_assembly/A
		if(assemblytype)
			A = new assemblytype(src.loc)
		else
			A = new /obj/structure/door_assembly(loc)
			//If you come across a null assemblytype, it will produce the default assembly instead of disintegrating.
		A.heat_proof_finished = src.heat_proof //tracks whether there's rglass in
		A.anchored = TRUE
		A.glass = src.glass
		A.state = AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS
		A.created_name = name
		A.previous_assembly = previous_airlock
		A.update_name()
		A.update_icon()

		if(!disassembled)
			if(A)
				A.obj_integrity = A.max_integrity * 0.5
		else if(obj_flags & EMAGGED)
			if(user)
				to_chat(user, "<span class='warning'>You discard the damaged electronics.</span>")
		else
			if(user)
				to_chat(user, "<span class='notice'>You remove the airlock electronics.</span>")

			var/obj/item/electronics/airlock/ae
			if(!electronics)
				ae = new/obj/item/electronics/airlock( src.loc )
				gen_access()
				if(req_one_access.len)
					ae.one_access = 1
					ae.accesses = src.req_one_access
				else
					ae.accesses = src.req_access
			else
				ae = electronics
				electronics = null
				ae.forceMove(drop_location())
	qdel(src)

/obj/machinery/door/airlock/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 32)
	return FALSE

/obj/machinery/door/airlock/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct the airlock.</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/machinery/door/airlock/proc/note_type() //Returns a string representing the type of note pinned to this airlock
	if(!note)
		return
	else if(istype(note, /obj/item/paper))
		return "note"
	else if(istype(note, /obj/item/photo))
		return "photo"

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
													datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ai_airlock", name, 550, 456, master_ui, state)
		ui.open()
	return TRUE

/obj/machinery/door/airlock/ui_data()
	var/list/data = list()

	var/list/power = list()
	power["main"] = src.secondsMainPowerLost ? 0 : 2 // boolean
	power["main_timeleft"] = src.secondsMainPowerLost
	power["backup"] = src.secondsBackupPowerLost ? 0 : 2 // boolean
	power["backup_timeleft"] = src.secondsBackupPowerLost
	data["power"] = power

	data["shock"] = secondsElectrified == 0 ? 2 : 0
	data["shock_timeleft"] = secondsElectrified
	data["id_scanner"] = !aiDisabledIdScanner
	data["emergency"] = emergency // access
	data["locked"] = locked // bolted
	data["lights"] = lights // bolt lights
	data["safe"] = safe // safeties
	data["speed"] = normalspeed // safe speed
	data["welded"] = welded // welded
	data["opened"] = !density // opened

	var/list/wire = list()
	wire["main_1"] = !wires.is_cut(WIRE_POWER1)
	wire["main_2"] = !wires.is_cut(WIRE_POWER2)
	wire["backup_1"] = !wires.is_cut(WIRE_BACKUP1)
	wire["backup_2"] = !wires.is_cut(WIRE_BACKUP2)
	wire["shock"] = !wires.is_cut(WIRE_SHOCK)
	wire["id_scanner"] = !wires.is_cut(WIRE_IDSCAN)
	wire["bolts"] = !wires.is_cut(WIRE_BOLTS)
	wire["lights"] = !wires.is_cut(WIRE_LIGHT)
	wire["safe"] = !wires.is_cut(WIRE_SAFETY)
	wire["timing"] = !wires.is_cut(WIRE_TIMING)

	data["wires"] = wire
	return data

/obj/machinery/door/airlock/ui_act(action, params)
	if(..())
		return
	if(!user_allowed(usr))
		return
	switch(action)
		if("disrupt-main")
			if(!secondsMainPowerLost)
				loseMainPower()
				update_icon()
			else
				to_chat(usr, "Main power is already offline.")
			. = TRUE
		if("disrupt-backup")
			if(!secondsBackupPowerLost)
				loseBackupPower()
				update_icon()
			else
				to_chat(usr, "Backup power is already offline.")
			. = TRUE
		if("shock-restore")
			shock_restore(usr)
			. = TRUE
		if("shock-temp")
			shock_temp(usr)
			. = TRUE
		if("shock-perm")
			shock_perm(usr)
			. = TRUE
		if("idscan-on")
			if(wires.is_cut(WIRE_IDSCAN))
				to_chat(usr, "You can't enable IdScan - The IdScan wire has been cut.")
			else if(src.aiDisabledIdScanner)
				aiDisabledIdScanner = FALSE
			else
				to_chat(usr, "The IdScan feature is not disabled.")
			. = TRUE
		if("idscan-off")
			if(wires.is_cut(WIRE_IDSCAN))
				to_chat(usr, "The IdScan wire has been cut - So, you can't disable it, but it is already disabled anyways.")
			else if(aiDisabledIdScanner)
				to_chat(usr, "You've already disabled the IdScan feature.")
			else
				aiDisabledIdScanner = TRUE
			. = TRUE
		if("emergency-on")
			emergency_on(usr)
			. = TRUE
		if("emergency-off")
			emergency_off(usr)
			. = TRUE
		if("bolt-raise")
			bolt_raise(usr)
			. = TRUE
		if("bolt-drop")
			bolt_drop(usr)
			. = TRUE
		if("light-on")
			if(wires.is_cut(WIRE_LIGHT))
				to_chat(usr, "Control to door bolt lights has been severed.")
			else if (!src.lights)
				lights = TRUE
				update_icon()
			else
				to_chat(usr, text("Door bolt lights are already enabled!"))
			. = TRUE
		if("light-off")
			if(wires.is_cut(WIRE_LIGHT))
				to_chat(usr, "Control to door bolt lights has been severed.")
			else if (lights)
				lights = FALSE
				update_icon()
			else
				to_chat(usr, "Door bolt lights are already disabled!")
			. = TRUE
		if("safe-on")
			if(wires.is_cut(WIRE_SAFETY))
				to_chat(usr, "Control to door sensors is disabled.")
			else if (!src.safe)
				safe = TRUE
			else
				to_chat(usr, "Firmware reports safeties already in place.")
			. = TRUE
		if("safe-off")
			if(wires.is_cut(WIRE_SAFETY))
				to_chat(usr, "Control to door sensors is disabled.")
			else if (safe)
				safe = FALSE
			else
				to_chat(usr, "Firmware reports safeties already overriden.")
			. = TRUE
		if("speed-on")
			if(wires.is_cut(WIRE_TIMING))
				to_chat(usr, "Control to door timing circuitry has been severed.")
			else if (!src.normalspeed)
				normalspeed = 1
			else
				to_chat(usr,"Door timing circuitry currently operating normally.")
			. = TRUE
		if("speed-off")
			if(wires.is_cut(WIRE_TIMING))
				to_chat(usr, "Control to door timing circuitry has been severed.")
			else if (normalspeed)
				normalspeed = 0
			else
				to_chat(usr, "Door timing circuitry already accelerated.")

			. = TRUE
		if("open-close")
			user_toggle_open(usr)
			. = TRUE

/obj/machinery/door/airlock/proc/user_allowed(mob/user)
	return (issilicon(user) && canAIControl(user)) || IsAdminGhost(user)

/obj/machinery/door/airlock/proc/shock_restore(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "Can't un-electrify the airlock - The electrification wire is cut.")
	else if(isElectrified())
		set_electrified(0)

/obj/machinery/door/airlock/proc/shock_temp(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "The electrification wire has been cut")
	else
		shockedby += "\[[time_stamp()]\][user](ckey:[user.ckey])"
		add_logs(user, src, "electrified")
		set_electrified(AI_ELECTRIFY_DOOR_TIME)

/obj/machinery/door/airlock/proc/shock_perm(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_SHOCK))
		to_chat(user, "The electrification wire has been cut")
	else
		shockedby += text("\[[time_stamp()]\][user](ckey:[user.ckey])")
		add_logs(user, src, "electrified")
		set_electrified(ELECTRIFIED_PERMANENT)

/obj/machinery/door/airlock/proc/emergency_on(mob/user)
	if(!user_allowed(user))
		return
	if (!emergency)
		emergency = TRUE
		update_icon()
	else
		to_chat(user, "Emergency access is already enabled!")

/obj/machinery/door/airlock/proc/emergency_off(mob/user)
	if(!user_allowed(user))
		return
	if (emergency)
		emergency = FALSE
		update_icon()
	else
		to_chat(user, "Emergency access is already disabled!")

/obj/machinery/door/airlock/proc/bolt_raise(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_BOLTS))
		to_chat(user, "The door bolt drop wire is cut - you can't raise the door bolts")
	else if(!src.locked)
		to_chat(user, "The door bolts are already up")
	else
		if(src.hasPower())
			unbolt()
		else
			to_chat(user, "Cannot raise door bolts due to power failure")

/obj/machinery/door/airlock/proc/bolt_drop(mob/user)
	if(!user_allowed(user))
		return
	if(wires.is_cut(WIRE_BOLTS))
		to_chat(user, "You can't drop the door bolts - The door bolt dropping wire has been cut.")
	else
		bolt()

/obj/machinery/door/airlock/proc/user_toggle_open(mob/user)
	if(!user_allowed(user))
		return
	if(welded)
		to_chat(user, text("The airlock has been welded shut!"))
	else if(locked)
		to_chat(user, text("The door bolts are down!"))
	else if(!density)
		close()
	else
		open()

#undef AIRLOCK_CLOSED
#undef AIRLOCK_CLOSING
#undef AIRLOCK_OPEN
#undef AIRLOCK_OPENING
#undef AIRLOCK_DENY
#undef AIRLOCK_EMAG

#undef AIRLOCK_SECURITY_NONE
#undef AIRLOCK_SECURITY_METAL
#undef AIRLOCK_SECURITY_PLASTEEL_I_S
#undef AIRLOCK_SECURITY_PLASTEEL_I
#undef AIRLOCK_SECURITY_PLASTEEL_O_S
#undef AIRLOCK_SECURITY_PLASTEEL_O
#undef AIRLOCK_SECURITY_PLASTEEL

#undef AIRLOCK_INTEGRITY_N
#undef AIRLOCK_INTEGRITY_MULTIPLIER
#undef AIRLOCK_DAMAGE_DEFLECTION_N
#undef AIRLOCK_DAMAGE_DEFLECTION_R

#undef NOT_ELECTRIFIED
#undef ELECTRIFIED_PERMANENT
#undef AI_ELECTRIFY_DOOR_TIME

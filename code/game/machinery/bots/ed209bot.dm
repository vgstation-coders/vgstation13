/obj/machinery/bot/ed209
	name = "ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed2090"
	icon_initial = "ed209"
	density = 1
	anchored = 0
//	weight = 1.0E7
	req_one_access = list(access_security, access_forensics_lockers)
	health = 100
	maxhealth = 100
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5

	var/lastfired = 0
	var/shot_delay = 3 //.3 seconds between shots
	var/lasercolor = null
	var/disabled = 0//A holder for if it needs to be disabled, if true it will not seach for targets, shoot at targets, or move, currently only used for lasertag

	//var/lasers = 0

	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
//var/emagged = 0 //Emagged Secbots view everyone as a criminal
	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff

	var/projectile = /obj/item/projectile/energy/electrode

	var/mode = 0
	bot_type = SEC_BOT
#define SECBOT_IDLE 		0		// idle
#define SECBOT_HUNT 		1		// found target, hunting
#define SECBOT_PREP_ARREST 	2		// at target, preparing to arrest
#define SECBOT_ARREST		3		// arresting target
#define SECBOT_START_PATROL	4		// start patrol
#define SECBOT_PATROL		5		// patrolling
#define SECBOT_SUMMON		6		// summoned by PDA

	var/auto_patrol = 0		// set to make bot automatically patrol

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency


	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route
	var/list/path = new				// list of path turfs

	var/blockcount = 0		//number of times retried a blocked path
	var/awaiting_beacon	= 0	// count of pticks awaiting a beacon response

	var/nearest_beacon			// the nearest beacon's tag
	var/turf/nearest_beacon_loc	// the nearest beacon's location
	var/declare_arrests = 1 //When making an arrest, should it notify everyone wearing sechuds?
	var/idcheck = 1 //If true, arrest people with no IDs
	var/weaponscheck = 1 //If true, arrest people for weapons if they don't have access

	//List of weapons that secbots will not arrest for, also copypasted in secbot.dm and metaldetector.dm
	var/safe_weapons = list(
		/obj/item/weapon/gun/energy/tag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/gun/energy/floragun,
		/obj/item/weapon/melee/defibrillator
		)


/obj/item/weapon/ed209_assembly
	name = "ED-209 assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "ed209_frame"
	item_state = "ed209_frame"
	var/build_step = 0
	var/created_name = "ED-209 Security Robot" //To preserve the name if it's a unique securitron I guess
	var/lasercolor = null

/obj/machinery/bot/ed209/bluetag
	lasercolor = "b"
	projectile = /obj/item/projectile/beam/lasertag/blue

/obj/machinery/bot/ed209/redtag
	lasercolor = "r"
	projectile = /obj/item/projectile/beam/lasertag/red

/obj/machinery/bot/ed209/New(loc,created_name,created_lasercolor)
	..()
	if(created_name)
		name = created_name
	if(created_lasercolor)
		lasercolor = created_lasercolor
	src.icon_state = "[lasercolor][icon_initial][src.on]"
	spawn(3)
		src.botcard = new /obj/item/weapon/card/id(src)
		var/datum/job/detective/J = new/datum/job/detective
		src.botcard.access = J.get_access()

		if(radio_controller)
			radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
			radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
		if(lasercolor)
			shot_delay = 6//Longer shot delay because JESUS CHRIST
			check_records = 0//Don't actively target people set to arrest
			arrest_type = 1//Don't even try to cuff
			req_access = list(access_maint_tunnels)
			if((lasercolor == "b") && (name == "ED-209 Security Robot"))//Picks a name if there isn't already a custom one
				name = pick("BLUE BALLER","SANIC","BLUE KILLDEATH MURDERBOT")
			if((lasercolor == "r") && (name == "ED-209 Security Robot"))
				name = pick("RED RAMPAGE","RED ROVER","RED KILLDEATH MURDERBOT")

/obj/machinery/bot/ed209/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	if(istype(mover,/obj/machinery/bot/ed209))
		return 1
	else
		return ..()

/obj/machinery/bot/ed209/turn_on()
	. = ..()
	src.icon_state = "[lasercolor][icon_initial][src.on]"
	src.mode = SECBOT_IDLE
	src.updateUsrDialog()

/obj/machinery/bot/ed209/turn_off()
	..()
	src.target = null
	src.oldtarget_name = null
	src.anchored = 0
	src.mode = SECBOT_IDLE
	walk_to(src,0)
	src.icon_state = "[lasercolor][icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/ed209/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v2.5</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [src.open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked || issilicon(user))
		if(!lasercolor)
			dat += text({"<BR>
Arrest for No ID: [] <BR>
Arrest for Unauthorized Weapons: [] <BR>
Arrest for Warrant: [] <BR>
<BR>
Operating Mode: []<BR>
Report Arrests: []<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=idcheck'>[src.idcheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=weaponscheck'>[weaponscheck ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=ignorerec'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=switchmode'>[src.arrest_type ? "Detain" : "Arrest"]</A>",
"<A href='?src=\ref[src];operation=declarearrests'>[src.declare_arrests ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )
		else
			dat += text({"<BR>
Auto Patrol: []"},

"<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "On" : "Off"]</A>" )


	user << browse("<HEAD><TITLE>Securitron v2.5 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/ed209/Topic(href, href_list)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(lasercolor && (istype(usr,/mob/living/carbon/human)))
		var/mob/living/carbon/human/H = usr
		if((lasercolor == "b") && iswearingredtag(H))//Opposing team cannot operate it
			return
		else if((lasercolor == "r") && iswearingbluetag(H))
			return
	if ((href_list["power"]) && (src.allowed(usr)))
		if (src.on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if ("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			updateUsrDialog()
		if ("ignorerec")
			src.check_records = !src.check_records
			src.updateUsrDialog()
		if ("switchmode")
			src.arrest_type = !src.arrest_type
			src.updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
			updateUsrDialog()
		if("declarearrests")
			src.declare_arrests = !src.declare_arrests
			src.updateUsrDialog()

/obj/machinery/bot/ed209/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (src.allowed(user) && !open && !emagged)
			src.locked = !src.locked
			to_chat(user, "<span class='notice'>Controls are now [src.locked ? "locked" : "unlocked"].</span>")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='notice'>Access denied.</span>")
	else
		..()
		if (!isscrewdriver(W) && (!src.target))
			if(hasvar(W,"force") && W.force)//If force is defined and non-zero
				threatlevel = user.assess_threat(src)
				threatlevel += PERP_LEVEL_ARREST_MORE
				if(threatlevel > 0)
					src.target = user
					src.shootAt(user)
					src.mode = SECBOT_HUNT

/obj/machinery/bot/ed209/kick_act(mob/living/H)
	..()

	threatlevel = H.assess_threat(src)
	threatlevel += PERP_LEVEL_ARREST_MORE

	if(threatlevel > 0)
		src.target = H
		src.shootAt(H)
		src.mode = SECBOT_HUNT

/obj/machinery/bot/ed209/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user)
			to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits.</span>")
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		src.target = null
		if(user)
			src.oldtarget_name = user.name
		src.last_found = world.time
		src.anchored = 0
		src.emagged = 2
		src.on = 1
		src.icon_state = "[lasercolor][icon_initial][src.on]"
		if(lasercolor)
			projectile = /obj/item/projectile/beam/lasertag/omni
		else
			projectile = /obj/item/projectile/beam
		mode = SECBOT_IDLE
		src.shot_delay = 6//Longer shot delay because JESUS CHRIST
		src.check_records = 0//Don't actively target people set to arrest
		src.arrest_type = 1//Don't even try to cuff
		src.declare_arrests = 0

/obj/machinery/bot/ed209/process()
	//set background = 1

	if (!src.on)
		return
	var/list/targets = list()
	for (var/mob/living/carbon/C in view(12,src)) //Let's find us a target
		var/threatlevel = 0
		if ((C.stat) || (C.lying))
			continue
		if (istype(C, /mob/living/carbon/human))
			threatlevel = C.assess_threat(src,lasercolor)
		else if ((istype(C, /mob/living/carbon/monkey)) && (C.client) && (ticker.mode.name == "monkey"))
			threatlevel = PERP_LEVEL_ARREST
		//src.speak(C.real_name + text(": threat: []", threatlevel))
		if (threatlevel < PERP_LEVEL_ARREST )
			continue

		var/dst = get_dist(src, C)
		if ( dst < 1 || dst > 12)
			continue

		targets += C
	if (targets.len>0)
		var/mob/t = pick(targets)
		if (t.stat != 2 && !t.lying)
			shootAt(t)

	switch(mode)

		if(SECBOT_IDLE)		// idle
			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp
			if(src.lasercolor)//Lasertag bots do not tase or arrest anyone, just patrol and shoot and whatnot
				mode = SECBOT_IDLE
				return
			// if can't reach perp for long enough, go idle
			if (src.frustration >= 8)
		//		for(var/mob/O in hearers(src, null))
//					to_chat(O, "<span class='game say'><span class='name'>[src]</span> beeps, \"Backup requested! Suspect has evaded arrest.\"")
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.mode = 0
				walk_to(src,0)

			if (target)		// make sure target exists
				if(!istype(target.loc, /turf))
					return
				if (Adjacent(target))		// if right next to perp
					playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)
					src.icon_state = "[lasercolor][icon_initial]-c"
					spawn(2)
						src.icon_state = "[lasercolor][icon_initial][src.on]"
					var/mob/living/carbon/M = src.target
					var/maxstuns = 4
					if (istype(M, /mob/living/carbon/human))
						if (M.stuttering < 10 && (!(M_HULK in M.mutations))  /*&& (!istype(M:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
							M.stuttering = 10
						M.Stun(10)
						M.Knockdown(10)
					else
						M.Knockdown(10)
						M.stuttering = 10
						M.Stun(10)
					maxstuns--
					if (maxstuns <= 0)
						target = null

					if(declare_arrests)
						var/area/location = get_area(src)
						broadcast_security_hud_message("[src.name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] suspect <b>[target]</b> in <b>[location]</b>", src)
					visible_message("<span class='danger'>[src.target] has been stunned by [src]!</span>")

					mode = SECBOT_PREP_ARREST
					src.anchored = 1
					src.target_lastloc = M.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, src.target)
					walk_to(src, src.target,1,4)
					shootAt(target)
					if ((get_dist(src, src.target)) >= (olddist))
						src.frustration++
					else
						src.frustration = 0

		if(SECBOT_PREP_ARREST)		// preparing to arrest target
			if(src.lasercolor)
				mode = SECBOT_IDLE
				return
			if (!target)
				mode = SECBOT_IDLE
				src.anchored = 0
				return
			// see if he got away
			if ((!Adjacent(target)) || ((src.target:loc != src.target_lastloc) && src.target:knockdown < 2))
				src.anchored = 0
				mode = SECBOT_HUNT
				return

			if(istype(src.target,/mob/living/carbon))
				if (!src.target.handcuffed && !src.arrest_type)
					playsound(src, 'sound/weapons/handcuffs.ogg', 30, 1, -2)
					mode = SECBOT_ARREST
					visible_message("<span class='danger'>[src] is trying to put handcuffs on [src.target]!</span>")

					spawn(60)
						if (Adjacent(target))
							if (src.target.handcuffed)
								return

							if(istype(src.target,/mob/living/carbon))
								src.target.handcuffed = new /obj/item/weapon/handcuffs(src.target)
								target.update_inv_handcuffed()	//update handcuff overlays

							mode = SECBOT_IDLE
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0

		//					playsound(src, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
		//					var/arrest_message = pick("Have a secure day!","I AM THE LAW.", "God made tomorrow for the crooks we don't catch today.","You can't outrun a radio.")
		//					src.speak(arrest_message)
			else
				mode = SECBOT_IDLE
				src.target = null
				src.anchored = 0
				src.last_found = world.time
				src.frustration = 0

		if(SECBOT_ARREST)		// arresting
			if(src.lasercolor)
				mode = SECBOT_IDLE
				return
			// see if he got away
			if (!target || src.target.handcuffed || !Adjacent(target))
				src.anchored = 0
				mode = SECBOT_IDLE
				return


		if(SECBOT_START_PATROL)	// start a patrol
			if(!path || !istype(path))
				path = list()
			if(path.len > 0 && patrol_target)	// have a valid path, so just resume
				mode = SECBOT_PATROL
				return

			else if(patrol_target)		// has patrol target already
				spawn(0)
					calc_path()		// so just find a route to it
					if(path.len == 0)
						patrol_target = 0
						return
					mode = SECBOT_PATROL


			else					// no patrol target, so need a new one
				find_patrol_target()
				speak("Engaging patrol mode.")


		if(SECBOT_PATROL)		// patrol mode
			patrol_step()
			spawn(5)
				if(mode == SECBOT_PATROL)
					patrol_step()

		if(SECBOT_SUMMON)		// summoned to PDA
			patrol_step()
			spawn(4)
				if(mode == SECBOT_SUMMON)
					patrol_step()
					sleep(4)
					patrol_step()

	return


// perform a single patrol step

/obj/machinery/bot/ed209/proc/patrol_step()


	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return
	if(!path || !istype(path))
		path = list()
	else if(path.len > 0 && patrol_target)		// valid path

		var/turf/next = path[1]
		if(next == loc)
			path -= next
			return


		if(istype( next, /turf/simulated))

			var/moved = step_towards(src, next)	// attempt to move
			if(moved)	// successful move
				blockcount = 0
				path -= loc

				look_for_perp()
				if(lasercolor)
					sleep(20)
			else		// failed to move

				blockcount++

				if(blockcount > 5)	// attempt 5 times before recomputing
					// find new path excluding blocked turf

					spawn(2)
						calc_path(next)
						if(path.len == 0)
							find_patrol_target()
						else
							blockcount = 0

					return

				return

		else	// not a valid turf
			mode = SECBOT_IDLE
			return

	else	// no path, so calculate new one
		mode = SECBOT_START_PATROL


// finds a new patrol target
/obj/machinery/bot/ed209/proc/find_patrol_target()
	send_status()
	if(awaiting_beacon)			// awaiting beacon response
		awaiting_beacon++
		if(awaiting_beacon > 5)	// wait 5 secs for beacon response
			find_nearest_beacon()	// then go to nearest instead
		return

	if(next_destination)
		set_destination(next_destination)
	else
		find_nearest_beacon()
	return


// finds the nearest beacon to self
// signals all beacons matching the patrol code
/obj/machinery/bot/ed209/proc/find_nearest_beacon()
	nearest_beacon = null
	new_destination = "__nearest__"
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	spawn(10)
		awaiting_beacon = 0
		if(nearest_beacon)
			set_destination(nearest_beacon)
		else
			auto_patrol = 0
			mode = SECBOT_IDLE
			speak("Disengaging patrol mode.")
			send_status()


/obj/machinery/bot/ed209/proc/at_patrol_target()
	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/ed209/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/ed209/receive_signal(datum/signal/signal)

	if(!on)
		return

	/*
	to_chat(world, "rec signal: [signal.source]")
	for(var/x in signal.data)
		to_chat(world, "* [x] = [signal.data[x]]")
	*/

	var/recv = signal.data["command"]
	// process all-bot input
	if(recv=="bot_status")
		send_status()

	// check to see if we are the commanded bot
	if(signal.data["active"] == src)
	// process control input
		switch(recv)
			if("stop")
				mode = SECBOT_IDLE
				auto_patrol = 0
				return

			if("go")
				mode = SECBOT_IDLE
				auto_patrol = 1
				return

			if("summon")
				patrol_target = signal.data["target"]
				next_destination = destination
				destination = null
				awaiting_beacon = 0
				mode = SECBOT_SUMMON
				calc_path()
				speak("Responding.")

				return



	// receive response from beacon
	recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	if(recv == new_destination)	// if the recvd beacon location matches the set destination
								// the we will navigate there
		destination = new_destination
		patrol_target = signal.source.loc
		next_destination = signal.data["next_patrol"]
		awaiting_beacon = 0

	// if looking for nearest beacon
	else if(new_destination == "__nearest__")
		var/dist = get_dist(src,signal.source.loc)
		if(nearest_beacon)

			// note we ignore the beacon we are located at
			if(dist > 1 && dist < get_dist(src,nearest_beacon_loc))
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
				return
			else
				return
		else if(dist > 1)
			nearest_beacon = recv
			nearest_beacon_loc = signal.source.loc
	return


// send a radio signal with a single data key/value pair
/obj/machinery/bot/ed209/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/ed209/proc/post_signal_multiple(var/freq, var/list/keyval)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency)
		return

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
//		to_chat(world, "sent [key],[keyval[key]] on [freq]")
	signal.data = keyval
	if (signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if (signal.data["type"] == "secbot")
		frequency.post_signal(src, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/ed209/proc/send_status()
	var/list/kv = list(
		"type" = "secbot",
		"name" = name,
		"loca" = loc.loc,	// area
		"mode" = mode,
	)
	post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/ed209/proc/calc_path(var/turf/avoid = null)
	src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance, 0, 120, id=botcard, exclude=avoid)
	if (!src.path)
		src.path = list()


// look for a criminal in view of the bot

/obj/machinery/bot/ed209/proc/look_for_perp()
	if(src.disabled)
		return
	src.anchored = 0
	src.threatlevel = 0
	for (var/mob/living/carbon/C in view(12,src)) //Let's find us a criminal
		if ((C.stat) || (C.handcuffed))
			continue

		if((src.lasercolor) && (C.lying))
			continue//Does not shoot at people lyind down when in lasertag mode, because it's just annoying, and they can fire once they get up.

		if ((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
			continue

		if (istype(C, /mob/living/carbon/human))
			src.threatlevel = src.assess_perp(C)
		else if ((istype(C, /mob/living/carbon/monkey)) && (C.client) && (ticker.mode.name == "monkey"))
			src.threatlevel = PERP_LEVEL_ARREST

		if (!src.threatlevel)
			continue

		else if (src.threatlevel >= PERP_LEVEL_ARREST)
			src.target = C
			src.oldtarget_name = C.name
			src.speak("Level [src.threatlevel] infraction alert!")
			if(!src.lasercolor)
				playsound(src, pick('sound/voice/ed209_20sec.ogg', 'sound/voice/EDPlaceholder.ogg'), 50, 0)
			src.visible_message("<b>[src]</b> points at [C.name]!")
			mode = SECBOT_HUNT
			spawn(0)
				process()	// ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
//THIS CODE IS COPYPASTED IN secbot.dm AND metaldetector.dm, with slight variations
/obj/machinery/bot/ed209/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 //If threat >= PERP_LEVEL_ARREST at the end, they get arrested

	if(src.emagged == 2)
		return PERP_LEVEL_ARREST + rand(PERP_LEVEL_ARREST, PERP_LEVEL_ARREST*5) //Everyone is a criminal!

	if(!src.allowed(perp)) //cops can do no wrong, unless set to arrest.

		if(weaponscheck && !wpermit(perp))
			for(var/obj/item/W in perp.held_items)
				if(check_for_weapons(W))
					threatcount += PERP_LEVEL_ARREST

			if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
				if(!(perp.belt.type in safe_weapons))
					threatcount += PERP_LEVEL_ARREST/2

		if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += PERP_LEVEL_ARREST/2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += PERP_LEVEL_ARREST/2
		var/visible_id = perp.get_visible_id()
		if(!visible_id)
			if(idcheck)
				threatcount += PERP_LEVEL_ARREST
			else
				threatcount += PERP_LEVEL_ARREST/2

		//Agent cards lower threatlevel.
		if(istype(visible_id, /obj/item/weapon/card/id/syndicate))
			threatcount -= PERP_LEVEL_ARREST/2

	if(src.lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
		threatcount = 0//They will not, however shoot at people who have guns, because it gets really fucking annoying
		if(iswearingredtag(perp))
			threatcount += PERP_LEVEL_ARREST
		if(perp.find_held_item_by_type(/obj/item/weapon/gun/energy/tag/red))
			threatcount += PERP_LEVEL_ARREST
		if(istype(perp.belt, /obj/item/weapon/gun/energy/tag/red))
			threatcount += PERP_LEVEL_ARREST/2

	if(src.lasercolor == "r")
		threatcount = 0
		if(iswearingbluetag(perp))
			threatcount += PERP_LEVEL_ARREST
		if(perp.find_held_item_by_type(/obj/item/weapon/gun/energy/tag/blue))
			threatcount += PERP_LEVEL_ARREST
		if(istype(perp.belt, /obj/item/weapon/gun/energy/tag/blue))
			threatcount += PERP_LEVEL_ARREST/2

	if(src.check_records)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			var/obj/item/weapon/card/id/id = perp.get_visible_id()
			if(id)
				perpname = id.registered_name

			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = PERP_LEVEL_ARREST
						break

	return threatcount

/obj/machinery/bot/ed209/to_bump(M as mob|obj) //Leave no door unopened!
	if ((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if (!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
			src.frustration = 0
	else if ((istype(M, /mob/living/)) && (!src.anchored))
		src.forceMove(M:loc)
		src.frustration = 0
	return

/* terrible
/obj/machinery/bot/ed209/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if (M)
			var/turf/T = get_turf(src)
			M:forceMove(T)
*/

/obj/machinery/bot/ed209/proc/speak(var/message)
	visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",\
		drugged_message="<span class='game say'><span class='name'>[src]</span> beeps, \"[pick("I-It's not like I like you or anything... baka!","You're s-so silly!","I-I'm only doing this because you asked me nicely, baka...","S-stop that!","Y-you're embarassing me!")]\"")
	return

/obj/machinery/bot/ed209/explode()
	walk_to(src,0)
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/ed209_assembly/Sa = new /obj/item/weapon/ed209_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = src.name
	new /obj/item/device/assembly/prox_sensor(Tsec)

	if(!lasercolor)
		var/obj/item/weapon/gun/energy/taser/G = new /obj/item/weapon/gun/energy/taser(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "b")
		var/obj/item/weapon/gun/energy/tag/blue/G = new /obj/item/weapon/gun/energy/tag/blue(Tsec)
		G.power_supply.charge = 0
	else if(lasercolor == "r")
		var/obj/item/weapon/gun/energy/tag/red/G = new /obj/item/weapon/gun/energy/tag/red(Tsec)
		G.power_supply.charge = 0

	if (prob(50))
		new /obj/item/robot_parts/l_leg(Tsec)
		if (prob(25))
			new /obj/item/robot_parts/r_leg(Tsec)
	if (prob(25))//50% chance for a helmet OR vest
		if (prob(50))
			new /obj/item/clothing/head/helmet/tactical/sec(Tsec)
		else
			if(!lasercolor)
				new /obj/item/clothing/suit/armor/vest(Tsec)
			if(lasercolor == "b")
				new /obj/item/clothing/suit/tag/bluetag(Tsec)
			if(lasercolor == "r")
				new /obj/item/clothing/suit/tag/redtag(Tsec)

	spark(src)

	var/obj/effect/decal/cleanable/blood/oil/gib = getFromPool(/obj/effect/decal/cleanable/blood/oil, src.loc)
	gib.New(gib.loc)
	qdel(src)


/obj/machinery/bot/ed209/proc/shootAt(var/mob/target)
	if(!projectile)
		return
	if(lastfired && world.time - lastfired < shot_delay)
		return
	lastfired = world.time
	var/turf/T = loc
	var/atom/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return

	//if(lastfired && world.time - lastfired < 100)
	//	playsound(src, 'ed209_shoot.ogg', 50, 0)

	if (!( istype(U, /turf) ))
		return
	var/obj/item/projectile/A = new projectile (loc)
	A.original = target
	A.target = target
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn()
		A.OnFired()
		A.process()
		return
	return

/obj/machinery/bot/ed209/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if (!isalien(target))
		src.target = user
		src.mode = SECBOT_HUNT


/obj/machinery/bot/ed209/emp_act(severity)

	if(severity==2 && prob(70))
		..(severity-1)
	else
		var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
		pulse2.icon = 'icons/effects/effects.dmi'
		pulse2.icon_state = "empdisable"
		pulse2.name = "emp sparks"
		pulse2.anchored = 1
		pulse2.dir = pick(cardinal)
		spawn(10)
			qdel(pulse2)
		var/list/mob/living/carbon/targets = new
		for (var/mob/living/carbon/C in view(12,src))
			if (C.stat==2)
				continue
			targets += C
		if(targets.len)
			if(prob(50))
				var/mob/toshoot = pick(targets)
				if (toshoot)
					targets-=toshoot
					if (prob(50) && emagged < 2)
						emagged = 2
						shootAt(toshoot)
						emagged = 0
					else
						shootAt(toshoot)
			else if(prob(50))
				if(targets.len)
					var/mob/toarrest = pick(targets)
					if (toarrest)
						src.target = toarrest
						src.mode = SECBOT_HUNT



/obj/item/weapon/ed209_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		created_name = t
		return

	switch(build_step)
		if(0,1)
			if( istype(W, /obj/item/robot_parts/l_leg) || istype(W, /obj/item/robot_parts/r_leg) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the robot leg to [src].</span>")
					name = "legs/frame assembly"
					if(build_step == 1)
						item_state = "ed209_leg"
						icon_state = "ed209_leg"
					else
						item_state = "ed209_legs"
						icon_state = "ed209_legs"

		if(2)
			if( istype(W, /obj/item/clothing/suit/tag/redtag) )
				lasercolor = "r"
			else if( istype(W, /obj/item/clothing/suit/tag/bluetag) )
				lasercolor = "b"
			if( lasercolor || istype(W, /obj/item/clothing/suit/armor/vest) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the armor to [src].</span>")
					name = "vest/legs/frame assembly"
					item_state = "[lasercolor]ed209_shell"
					icon_state = "[lasercolor]ed209_shell"

		if(3)
			if( istype(W, /obj/item/weapon/weldingtool) )
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0,user))
					build_step++
					name = "shielded frame assembly"
					to_chat(user, "<span class='notice'>You welded the vest to [src].</span>")
		if(4)
			if( istype(W, /obj/item/clothing/head/helmet/tactical/sec) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the helmet to [src].</span>")
					name = "covered and shielded frame assembly"
					item_state = "[lasercolor]ed209_hat"
					icon_state = "[lasercolor]ed209_hat"

		if(5)
			if( isprox(W) )
				if(user.drop_item(W))
					qdel(W)
					build_step++
					to_chat(user, "<span class='notice'>You add the prox sensor to [src].</span>")
					name = "covered, shielded and sensored frame assembly"
					item_state = "[lasercolor]ed209_prox"
					icon_state = "[lasercolor]ed209_prox"

		if(6)
			if( istype(W, /obj/item/stack/cable_coil) )
				var/obj/item/stack/cable_coil/coil = W
				var/turf/T = get_turf(user)
				to_chat(user, "<span class='notice'>You start to wire [src]...</span>")
				sleep(40)
				if(get_turf(user) == T)
					coil.use(1)
					build_step++
					to_chat(user, "<span class='notice'>You wire the ED-209 assembly.</span>")
					name = "wired ED-209 assembly"

		if(7)
			if(!user.drop_item(W))
				return

			switch(lasercolor)
				if("b")
					if( !istype(W, /obj/item/weapon/gun/energy/tag/blue) )
						return
					name = "bluetag ED-209 assembly"
				if("r")
					if( !istype(W, /obj/item/weapon/gun/energy/tag/red) )
						return
					name = "redtag ED-209 assembly"
				if(null)
					if( !istype(W, /obj/item/weapon/gun/energy/taser) )
						return
					name = "taser ED-209 assembly"
				else
					return
			build_step++
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			src.item_state = "[lasercolor]ed209_taser"
			src.icon_state = "[lasercolor]ed209_taser"
			qdel(W)

		if(8)
			if( isscrewdriver(W) )
				playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
				var/turf/T = get_turf(user)
				to_chat(user, "<span class='notice'>Now attaching the gun to the frame...</span>")
				sleep(40)
				if(get_turf(user) == T)
					build_step++
					name = "armed [name]"
					to_chat(user, "<span class='notice'>Taser gun attached.</span>")

		if(9)
			if( istype(W, /obj/item/weapon/cell) )
				if(!user.drop_item(W))
					return

				build_step++
				to_chat(user, "<span class='notice'>You complete the ED-209.</span>")
				var/turf/T = get_turf(src)
				new /obj/machinery/bot/ed209(T,created_name,lasercolor)
				qdel(W)
				user.drop_from_inventory(src)
				qdel(src)


/obj/machinery/bot/ed209/bullet_act(var/obj/item/projectile/Proj)
	if((src.lasercolor == "b") && (src.disabled == 0))
		if(istype(Proj, /obj/item/projectile/beam/lasertag/red))
			src.disabled = 1
			//del (Proj)
			returnToPool(Proj)
			sleep(100)
			src.disabled = 0
		else
			..()
	else if((src.lasercolor == "r") && (src.disabled == 0))
		if(istype(Proj, /obj/item/projectile/beam/lasertag/blue))
			src.disabled = 1
			//del (Proj)
			returnToPool(Proj)
			sleep(100)
			src.disabled = 0
		else
			..()
	else
		..()

/obj/machinery/bot/ed209/proc/check_for_weapons(var/obj/item/slot_item) //Unused anywhere, copypasted in secbot.dm
	if(istype(slot_item, /obj/item/weapon/gun) || istype(slot_item, /obj/item/weapon/melee))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0

/obj/machinery/bot/ed209/declare()
	var/area/location = get_area(src)
	declare_message = "<span class='info'>[bicon(src)] [name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] scumbag <b>[target]</b> in <b>[location]</b></span>"
	..()

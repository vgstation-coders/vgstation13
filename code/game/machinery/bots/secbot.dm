/obj/machinery/bot/secbot
	name = "Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	icon_initial = "secbot"
	layer = 5.0
	density = 0
	anchored = 0
	health = 25
	maxhealth = 25
	fire_dam_coeff = 0.7
	brute_dam_coeff = 0.5
//	weight = 1.0E7
	req_one_access = list(access_security, access_forensics_lockers)
	var/mob/target
	var/oldtarget_name
	var/threatlevel = 0
	var/target_lastloc //Loc of target when arrested.
	var/last_found //There's a delay
	var/frustration = 0
	var/check_records = 1
//	var/emagged = 0 //Emagged Secbots view everyone as a criminal

	var/idcheck = 0 //If true, arrest people with no IDs
	var/weaponscheck = 0 //If true, arrest people for weapons if they lack access	var/check_records = 1 //Does it check security records?
	var/arrest_type = 0 //If true, don't handcuff
	var/declare_arrests = 0 //When making an arrest, should it notify everyone wearing sechuds?
	var/next_harm_time = 0

	var/mode = 0
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

	//List of weapons that secbots will not arrest for, also copypasted in ed209.dm and metaldetector.dm
	var/list/safe_weapons = list(
		/obj/item/weapon/gun/energy/laser/bluetag,
		/obj/item/weapon/gun/energy/laser/redtag,
		/obj/item/weapon/gun/energy/laser/practice,
		/obj/item/weapon/gun/hookshot,
		/obj/item/weapon/gun/energy/floragun,
		/obj/item/weapon/melee/defibrillator
		)

	light_color = LIGHT_COLOR_RED
	power_change()
		..()
		if(src.on)
			set_light(2)
		else
			set_light(0)


/obj/machinery/bot/secbot/beepsky
	name = "Officer Beep O'sky"
	desc = "It's Officer Beep O'sky! Powered by a potato and a shot of whiskey."
	auto_patrol = 1
	declare_arrests = 1

/obj/item/weapon/secbot_assembly
	name = "helmet/signaler assembly"
	desc = "Some sort of bizarre assembly."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "helmet_signaler"
	item_state = "helmet"
	var/build_step = 0
	var/created_name = "Securitron" //To preserve the name if it's a unique securitron I guess

/obj/machinery/bot/secbot/New()
	..()
	src.icon_state = "[src.icon_initial][src.on]"
	spawn(3)
		src.botcard = new /obj/item/weapon/card/id(src)
		var/datum/job/detective/J = new/datum/job/detective
		src.botcard.access = J.get_access()
		if(radio_controller)
			radio_controller.add_object(src, control_freq, filter = RADIO_SECBOT)
			radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)


/obj/machinery/bot/secbot/turn_on()
	..()
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/secbot/turn_off()
	..()
	src.target = null
	src.oldtarget_name = null
	src.anchored = 0
	src.mode = SECBOT_IDLE
	walk_to(src,0)
	src.icon_state = "[src.icon_initial][src.on]"
	src.updateUsrDialog()

/obj/machinery/bot/secbot/attack_hand(mob/user as mob)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/secbot/interact(mob/user as mob)
	var/dat

	dat += text({"
<TT><B>Automatic Security Unit v1.3</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [src.open ? "opened" : "closed"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked || issilicon(user))
		dat += text({"<BR>
Arrest for No ID: [] <BR>
Arrest for Unauthorized Weapons: []<BR>
Arrest for Warrant: []<BR>
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


	user << browse("<HEAD><TITLE>Securitron v1.3 controls</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/bot/secbot/Topic(href, href_list)
	if(..()) return 1
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if((href_list["power"]) && (src.allowed(usr)))
		if(src.on)
			turn_off()
		else
			turn_on()
		return

	switch(href_list["operation"])
		if("idcheck")
			src.idcheck = !src.idcheck
			src.updateUsrDialog()
		if("weaponscheck")
			weaponscheck = !weaponscheck
			updateUsrDialog()
		if("ignorerec")
			src.check_records = !src.check_records
			src.updateUsrDialog()
		if("switchmode")
			src.arrest_type = !src.arrest_type
			src.updateUsrDialog()
		if("patrol")
			auto_patrol = !auto_patrol
			mode = SECBOT_IDLE
			updateUsrDialog()
		if("declarearrests")
			src.declare_arrests = !src.declare_arrests
			src.updateUsrDialog()

/obj/machinery/bot/secbot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(src.allowed(user) && !open && !emagged)
			src.locked = !src.locked
			to_chat(user, "Controls are now [src.locked ? "locked." : "unlocked."]")
		else
			if(emagged)
				to_chat(user, "<span class='warning'>ERROR</span>")
			if(open)
				to_chat(user, "<span class='warning'>Please close the access panel before locking it.</span>")
			else
				to_chat(user, "<span class='warning'>Access denied.</span>")
	else
		..()
	if(istype(W, /obj/item/weapon/weldingtool) && user.a_intent != "harm") // Any intent but harm will heal, so we shouldn't get angry.
		return
	if(!isscrewdriver(W) && (W.force) && (!target) ) // Added check for welding tool to fix #2432. Welding tool behavior is handled in superclass.
		threatlevel = user.assess_threat(src)
		threatlevel += 6
		if(threatlevel > 0)
			target = user
			mode = SECBOT_HUNT

/obj/machinery/bot/secbot/kick_act(mob/living/H)
	..()

	threatlevel = H.assess_threat(src)
	threatlevel += 6

	if(threatlevel > 0)
		src.target = H
		src.mode = SECBOT_HUNT

/obj/machinery/bot/secbot/Emag(mob/user as mob)
	..()
	if(open && !locked)
		if(user) to_chat(user, "<span class='warning'>You short out [src]'s target assessment circuits.</span>")
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("<span class='danger'>[src] buzzes oddly!</span>", 1)
		src.target = null
		if(user) src.oldtarget_name = user.name
		src.last_found = world.time
		src.anchored = 0
		src.emagged = 2
		src.on = 1
		src.icon_state = "[src.icon_initial][src.on]"
		mode = SECBOT_IDLE

/obj/machinery/bot/secbot/process()
	//set background = 1

	if(!src.on)
		return

	switch(mode)

		if(SECBOT_IDLE)		// idle

			walk_to(src,0)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = SECBOT_START_PATROL	// switch to patrol mode

		if(SECBOT_HUNT)		// hunting for perp

			// if can't reach perp for long enough, go idle
			if(src.frustration >= 8)
		//		for(var/mob/O in hearers(src, null))
//					to_chat(O, "<span class='game say'><span class='name'>[src]</span> beeps, \"Backup requested! Suspect has evaded arrest.\"")
				src.target = null
				src.last_found = world.time
				src.frustration = 0
				src.mode = SECBOT_IDLE
				walk_to(src,0)

			if(target)		// make sure target exists
				if(!istype(target.loc, /turf))
					return
				if(get_dist(src, src.target) <= 1)		// if right next to perp
					if(istype(src.target,/mob/living/carbon))
						playsound(get_turf(src), 'sound/weapons/Egloves.ogg', 50, 1, -1)
						src.icon_state = "[src.icon_initial]-c"
						spawn(2)
							src.icon_state = "[icon_initial][src.on]"
						var/mob/living/carbon/M = src.target
						var/maxstuns = 4
						if(istype(M, /mob/living/carbon/human))
							if(M.stuttering < 10 && (!(M_HULK in M.mutations)))
								M.stuttering = 10
							M.Stun(10)
							M.Weaken(10)
						else
							M.Weaken(10)
							M.stuttering = 10
							M.Stun(10)
						if(declare_arrests)
							declare()
						target.visible_message("<span class='danger'>[target] has been stunned by [src]!</span>",\
						"<span class='userdanger'>You have been stunned by [src]!</span>")
						maxstuns--
						if(maxstuns <= 0)
							target = null

						if(declare_arrests)
							var/area/location = get_area(src)
							broadcast_security_hud_message("[src.name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] suspect <b>[target]</b> in <b>[location]</b>", src)
						//visible_message("<span class='danger'>[src.target] has been stunned by [src]!</span>")

						mode = SECBOT_PREP_ARREST
						src.anchored = 1
						src.target_lastloc = M.loc
						return
					else if(istype(src.target,/mob/living/simple_animal))
						//just harmbaton them until dead
						if(world.time > next_harm_time)
							next_harm_time = world.time + 15
							playsound(get_turf(src), 'sound/weapons/Egloves.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[src] beats [src.target] with the stun baton!</span>")
							src.icon_state = "[src.icon_initial]-c"
							spawn(2)
								src.icon_state = "[src.icon_initial][src.on]"

							var/mob/living/simple_animal/S = src.target
							if(S && istype(S))
								S.AdjustStunned(10)
								S.adjustBruteLoss(15)
								if(S.stat)
									src.frustration = 8
									playsound(get_turf(src), pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/bcreep.ogg'), 50, 0)

				else								// not next to perp
					var/turf/olddist = get_dist(src, src.target)
					walk_to(src, src.target,1,4)
					if((get_dist(src, src.target)) >= (olddist))
						src.frustration++
					else
						src.frustration = 0
			else
				src.frustration = 8

		if(SECBOT_PREP_ARREST)		// preparing to arrest target

			// see if he got away
			if((get_dist(src, src.target) > 1) || ((src.target:loc != src.target_lastloc) && src.target:weakened < 2))
				src.anchored = 0
				mode = SECBOT_HUNT
				return

			if(istype(src.target,/mob/living/carbon) && !isalien(target))
				var/mob/living/carbon/C = target
				if(!C.handcuffed && !src.arrest_type)
					playsound(get_turf(src), 'sound/weapons/handcuffs.ogg', 30, 1, -2)
					mode = SECBOT_ARREST
					visible_message("<span class='danger'>[src] is trying to put handcuffs on [src.target]!</span>",\
						"<span class='danger'>[src] is trying to cut [src.target]'s hands off!</span>")

					spawn(60)
						if(Adjacent(target))
							/*if(src.target.handcuffed)
								return*/

							if(istype(src.target,/mob/living/carbon) && !isalien(target))
								C = target
								if(!C.handcuffed)
									C.handcuffed = new /obj/item/weapon/handcuffs(target)
									C.update_inv_handcuffed()	//update the handcuffs overlay

							mode = SECBOT_IDLE
							src.target = null
							src.anchored = 0
							src.last_found = world.time
							src.frustration = 0

							playsound(get_turf(src), pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
		//					var/arrest_message = pick("Have a secure day!","I AM THE LAW.", "God made tomorrow for the crooks we don't catch today.","You can't outrun a radio.")
		//					src.speak(arrest_message)

			else
				mode = SECBOT_IDLE
				src.target = null
				src.anchored = 0
				src.last_found = world.time
				src.frustration = 0

		if(SECBOT_ARREST)		// arresting

			if(!target || !istype(target, /mob/living/carbon))
				src.anchored = 0
				mode = SECBOT_IDLE
				return
			else
				var/mob/living/carbon/C = target
				if(!C.handcuffed)
					src.anchored = 0
					mode = SECBOT_IDLE
					return


		if(SECBOT_START_PATROL)	// start a patrol
			if(path != null)
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

/obj/machinery/bot/secbot/proc/patrol_step()


	if(loc == patrol_target)		// reached target
		at_patrol_target()
		return

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
/obj/machinery/bot/secbot/proc/find_patrol_target()
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
/obj/machinery/bot/secbot/proc/find_nearest_beacon()
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


/obj/machinery/bot/secbot/proc/at_patrol_target()
	find_patrol_target()
	return


// sets the current destination
// signals all beacons matching the patrol code
// beacons will return a signal giving their locations
/obj/machinery/bot/secbot/proc/set_destination(var/new_dest)
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1


// receive a radio signal
// used for beacon reception

/obj/machinery/bot/secbot/receive_signal(datum/signal/signal)
	//log_admin("DEBUG \[[world.timeofday]\]: /obj/machinery/bot/secbot/receive_signal([signal.debug_print()])")
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
			if(dist>1 && dist<get_dist(src,nearest_beacon_loc))
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
/obj/machinery/bot/secbot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

// send a radio signal with multiple data key/values
/obj/machinery/bot/secbot/proc/post_signal_multiple(var/freq, var/list/keyval)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency) return

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.source = src
	signal.transmission_method = 1
	//for(var/key in keyval)
	//	signal.data[key] = keyval[key]
	signal.data = keyval
//		to_chat(world, "sent [key],[keyval[key]] on [freq]")
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else if(signal.data["type"] == "secbot")
		frequency.post_signal(src, signal, filter = RADIO_SECBOT)
	else
		frequency.post_signal(src, signal)

// signals bot status etc. to controller
/obj/machinery/bot/secbot/proc/send_status()
	var/list/kv = list(
	"type" = "secbot",
	"name" = name,
	"loca" = loc.loc,	// area
	"mode" = mode
	)
	post_signal_multiple(control_freq, kv)



// calculates a path to the current destination
// given an optional turf to avoid
/obj/machinery/bot/secbot/proc/calc_path(var/turf/avoid = null)
	src.path = AStar(src.loc, patrol_target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 120, id=botcard, exclude=avoid)
	if(!src.path)
		src.path = list()


// look for a criminal in view of the bot

/obj/machinery/bot/secbot/proc/look_for_perp()
	src.anchored = 0
	for (var/mob/living/M in view(7,src)) //Let's find us a criminal
		if(istype(M, /mob/living/carbon))
			var/mob/living/carbon/C = M
			if((C.stat) || (C.handcuffed))
				continue

			if((C.name == src.oldtarget_name) && (world.time < src.last_found + 100))
				continue

			if(ishuman(C))
				src.threatlevel = src.assess_perp(C)
			else if(ismonkey(C) && isbadmonkey(C)) //Beepsky can detect jungle fever monkeys
				src.threatlevel = 666
			else
				continue
		else
			continue
		/*
		else if(istype(M, /mob/living/simple_animal/hostile))
			if(M.stat == DEAD)
				continue
			// Ignore lazarus-injected mobs.
			if(dd_hasprefix(C.faction, "lazarus"))
				continue
			// Minebots only, I hope.
			if(M.faction == "neutral")
				continue
			src.threatlevel = 4
		*/

		if(!src.threatlevel)
			continue

		else if(src.threatlevel >= 4)
			src.target = M
			src.oldtarget_name = M.name
			src.speak("Level [src.threatlevel] infraction alert!")
			playsound(get_turf(src), pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			src.visible_message("<b>[src]</b> points at [M.name]!")
			mode = SECBOT_HUNT
			spawn(0)
				process()	// ensure bot quickly responds to a perp
			break
		else
			continue


//If the security records say to arrest them, arrest them
//Or if they have weapons and aren't security, arrest them.
//THIS CODE IS COPYPASTED IN ed209bot.dm AND metaldetector.dm, with slight variations
/obj/machinery/bot/secbot/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 //If threat >= 4 at the end, they get arrested

	if(src.emagged == 2) return 10 //Everyone is a criminal!

	if(!src.allowed(perp)) //cops can do no wrong, unless set to arrest.

		if(weaponscheck && !wpermit(perp))
			for(var/obj/item/I in perp.held_items)
				if(check_for_weapons(I))
					threatcount += 4

			if(istype(perp.belt, /obj/item/weapon/gun) || istype(perp.belt, /obj/item/weapon/melee))
				if(!(perp.belt.type in safe_weapons))
					threatcount += 2

		if(istype(perp.wear_suit, /obj/item/clothing/suit/wizrobe))
			threatcount += 2

		if(perp.dna && perp.dna.mutantrace && perp.dna.mutantrace != "none")
			threatcount += 2

		if(!perp.wear_id)
			if(idcheck)
				threatcount += 4
			else
				threatcount += 2

		//Agent cards lower threatlevel.
		if(perp.wear_id && istype(perp.wear_id.GetID(), /obj/item/weapon/card/id/syndicate))
			threatcount -= 2

	if(src.check_records)
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			if(perp.wear_id)
				var/obj/item/weapon/card/id/id = perp.wear_id.GetID()
				if(id)
					perpname = id.registered_name

			if(E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = 4
						break

	return threatcount

/obj/machinery/bot/secbot/Bump(M as mob|obj) //Leave no door unopened!
	if((istype(M, /obj/machinery/door)) && (!isnull(src.botcard)))
		var/obj/machinery/door/D = M
		if(!istype(D, /obj/machinery/door/firedoor) && D.check_access(src.botcard))
			D.open()
			src.frustration = 0
	else if((istype(M, /mob/living/)) && (!src.anchored))
		src.loc = M:loc
		src.frustration = 0
	return

/* terrible
/obj/machinery/bot/secbot/Bumped(atom/movable/M as mob|obj)
	spawn(0)
		if(M)
			var/turf/T = get_turf(src)
			M:loc = T
*/

/obj/machinery/bot/secbot/proc/speak(var/message)
	visible_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",\
		drugged_message="<span class='game say'><span class='name'>[src]</span> beeps, \"[pick("Wait! Let's be friends!","Wait for me!","You're so cool!","Who's your favourite pony?","I-It's not like I like you or anything...","Wanna see a magic trick?","Let's go have fun, assistant-kun~")]\"")
	return


/obj/machinery/bot/secbot/explode()

	walk_to(src,0)
	src.visible_message("<span class='danger'>[src] blows apart!</span>", 1)
	var/turf/Tsec = get_turf(src)

	var/obj/item/weapon/secbot_assembly/Sa = new /obj/item/weapon/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.overlays += image('icons/obj/aibots.dmi', "hs_hole")
	Sa.created_name = src.name
	new /obj/item/device/assembly/prox_sensor(Tsec)
	new /obj/item/weapon/melee/baton/loaded(Tsec)

	if(prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	var/obj/effect/decal/cleanable/blood/oil/O = getFromPool(/obj/effect/decal/cleanable/blood/oil, src.loc)
	O.New(O.loc)
	qdel(src)

/obj/machinery/bot/secbot/attack_alien(var/mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		src.target = user
		src.mode = SECBOT_HUNT

//Secbot Construction

/obj/item/clothing/head/helmet/tactical/sec/attackby(var/obj/item/device/assembly/signaler/S, mob/user as mob)
	..()
	if(!issignaler(S))
		..()
		return

	if(S.secured)
		qdel(S)
		var/obj/item/weapon/secbot_assembly/A = new /obj/item/weapon/secbot_assembly
		user.put_in_hands(A)
		to_chat(user, "You add the signaler to the helmet.")
		user.drop_from_inventory(src)
		qdel(src)
	else
		return

/obj/item/weapon/secbot_assembly/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if((istype(W, /obj/item/weapon/weldingtool)) && (!src.build_step))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0,user))
			src.build_step++
			src.overlays += image('icons/obj/aibots.dmi', "hs_hole")
			to_chat(user, "You weld a hole in [src]!")

	else if(isprox(W) && (src.build_step == 1))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You add the prox sensor to [src]!")
			src.overlays += image('icons/obj/aibots.dmi', "hs_eye")
			src.name = "helmet/signaler/prox sensor assembly"
			qdel(W)

	else if(((istype(W, /obj/item/robot_parts/l_arm)) || (istype(W, /obj/item/robot_parts/r_arm))) && (src.build_step == 2))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You add the robot arm to [src]!")
			src.name = "helmet/signaler/prox sensor/robot arm assembly"
			src.overlays += image('icons/obj/aibots.dmi', "hs_arm")
			qdel(W)

	else if((istype(W, /obj/item/weapon/melee/baton)) && (src.build_step >= 3))
		if(user.drop_item(W))
			src.build_step++
			to_chat(user, "You complete the Securitron! Beep boop.")
			var/obj/machinery/bot/secbot/S = new /obj/machinery/bot/secbot
			S.loc = get_turf(src)
			S.name = src.created_name
			qdel(W)
			qdel(src)

	else if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", src.name, src.created_name),1,MAX_NAME_LEN)
		if(!t)
			return
		if(!in_range(src, usr) && src.loc != usr)
			return
		src.created_name = t

/obj/machinery/bot/secbot/declare()
	var/area/location = get_area(src)
	declare_message = "<span class='info'>[bicon(src)] [name] is [arrest_type ? "detaining" : "arresting"] level [threatlevel] scumbag <b>[target]</b> in <b>[location]</b></span>"
	..()

/obj/machinery/bot/secbot/proc/check_for_weapons(var/obj/item/slot_item) //Unused anywhere, copypasted in ed209bot.dm
	if(istype(slot_item, /obj/item/weapon/gun) || istype(slot_item, /obj/item/weapon/melee))
		if(!(slot_item.type in safe_weapons))
			return 1
	return 0

/**
	Time agent

	You've got 5 minutes of playtime to do something weird

	If you succeed, the stations threat level is escalated

	If you fail, something weird happens.

	Are you a bad enough dude to make sure a corgi, a rubber duck, and a bucket are in the same place at the same time?

**/

/datum/role/time_agent
	name = TIMEAGENT
	id = TIMEAGENT
	required_pref = TIMEAGENT
	logo_state = "time-logo"
	var/list/objects_to_delete = list()
	var/time_elapsed = -59
	var/action_timer = 60
	var/datum/recruiter/eviltwinrecruiter = null
	var/is_twin = FALSE

/datum/role/time_agent/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id, var/override = FALSE)
	var/datum/faction/time_agent/timeagent_fac
	if(!fac)
		timeagent_fac = new
		timeagent_fac.addPrimary(src)
	else if (istype(fac, /datum/faction/time_agent))
		timeagent_fac = fac
		timeagent_fac.addEvilTwin(src)
	wikiroute = role_wiki[TIMEAGENT]

/datum/role/time_agent/Greet(var/greeting,var/custom)
	if(!greeting)
		return

	var/icon/logo = icon('icons/logos.dmi', logo_state)
	switch(greeting)
		if (GREET_CUSTOM)
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>[custom]</span>")
		else
			to_chat(antag.current, "<img src='data:image/png;base64,[icon2base64(logo)]' style='position: relative; top: 10;'/> <span class='danger'>You are a Time Agent.<br>Specifically you are a scientist by the name of John Beckett, having discovered a method to travel through time, and becoming lost to it. <br>\
			Now, you are forced to take responsibility for maintaining the time stream by the mysterious 'Time Agency'.<br>\
			You only have a limited amount of time before this timeline is deemed lost, in which case you will be forcibly extracted and the mission considered a failure.<br>\
			Locate certain time-sensitive objects scattered around the station, so as to locate the time anomaly and use it for extraction.<br>\
			This may not be the first time you visit this timeline, and it may not be the last.</span>")

	to_chat(antag.current, "<span class='danger'>Remember that the items you are provided with are largely non-expendable. Try not to lose them, especially the jump charge, as it is your ticket home.</span>")


/datum/role/time_agent/ForgeObjectives()
	AppendObjective(/datum/objective/target/locate)
	if(prob(30))
		AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/freeform/aid)


/datum/role/time_agent/process()
	// var/list/datum/objective/jecties = objectives.GetObjectives()
	// if(!jecties.len || locate(/datum/objective/time_agent_extract) in objectives.GetObjectives())
	// 	return //Not set up yet
	// var/finished = TRUE
	// for(var/datum/objective/O in objectives.GetObjectives())
	// 	if(O.IsFulfilled())
	// 		if(faction)
	// 			var/datum/faction/time_agent/agency = faction
	// 			agency.stage(FACTION_ACTIVE)
	// 		break
	// if(finished)
	// 	to_chat(antag.current, "<span class = 'notice'>Objectives complete. Triangulating anomaly location.</span>")
	// 	AppendObjective(/datum/objective/time_agent_extract)

	time_elapsed++
	if(time_elapsed % action_timer == 0)
		timer_action(time_elapsed / action_timer)
	if (antag && antag.current.hud_used)
		if(antag.current.hud_used.countdown_display)
			antag.current.hud_used.countdown_display.overlays.len = 0
			var/time_until_next_action = action_timer - (time_elapsed % action_timer)
			var/first = round(time_until_next_action/10)
			var/second = time_until_next_action % 10
			var/image/I1 = new('icons/obj/centcomm_stuff.dmi',src,"[first]",30)
			var/image/I2 = new('icons/obj/centcomm_stuff.dmi',src,"[second]",30)
			I1.pixel_x += 10 * PIXEL_MULTIPLIER
			I2.pixel_x += 17 * PIXEL_MULTIPLIER
			I1.pixel_y -= 11 * PIXEL_MULTIPLIER
			I2.pixel_y -= 11 * PIXEL_MULTIPLIER
			antag.current.hud_used.countdown_display.overlays += I1
			antag.current.hud_used.countdown_display.overlays += I2
		else
			antag.current.hud_used.countdown_hud()

/datum/role/time_agent/proc/timer_action(severity)
	var/mob/living/carbon/human/H = antag.current
	switch(severity)
		if(0)
			spawn_rand_maintenance(H)
			spawn()
				showrift(H,1)
		if(1)
			// send the time agent specifically to the past, future, and stop time on him for 30 sec or so
			return
		if(2)
			switch(pick(list(1,2)))
				if(1)
					wormhole_event()
					H.teleportitis += 30
				if(2)
					// what could possibly go wrong
					generate_ion_law()
					generate_ion_law()
					generate_ion_law()
					command_alert(/datum/command_alert/ion_storm)
					// also maybe make the AI actively malicious to time travellers
		if(3)
			eviltwinrecruiter = new(src)
			eviltwinrecruiter.display_name = "time agent twin"
			eviltwinrecruiter.role = TIMEAGENT
			eviltwinrecruiter.jobban_roles = list("syndicate")
			eviltwinrecruiter.logging = TRUE

			// A player has their role set to Yes or Always
			eviltwinrecruiter.player_volunteering.Add(src, "recruiter_recruiting")
			// ", but No or Never
			eviltwinrecruiter.player_not_volunteering.Add(src, "recruiter_not_recruiting")

			eviltwinrecruiter.recruited.Add(src, "recruiter_recruited")

			eviltwinrecruiter.request_player()
		if(4 to INFINITY)
			return

/datum/role/time_agent/proc/recruiter_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class=\"recruit\">You are a possible candidate for \a [src]'s evil twin. Get ready. ([controls])</span>")

/datum/role/time_agent/proc/recruiter_not_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	if(O.client && get_role_desire_str(O.client.prefs.roles[TIMEAGENT]) != "Never")
		to_chat(O, "<span class=\"recruit\">\a [src] is going to get shot by his evil twin. ([controls])</span>")


/datum/role/time_agent/proc/recruiter_recruited(var/list/args)
	var/mob/dead/observer/O = args["player"]
	if(O)
		qdel(eviltwinrecruiter)
		eviltwinrecruiter = null
		var/mob/living/carbon/human/H = new /mob/living/carbon/human
		H.ckey = O.ckey
		H.client.changeView()
		var/datum/role/time_agent/eviltwin/twin = new /datum/role/time_agent/eviltwin(H.mind)
		twin.erase_target = src
		twin.OnPostSetup()
		twin.Greet(GREET_DEFAULT)
	else
		eviltwinrecruiter.request_player()

/datum/role/time_agent/OnPostSetup()
	.=..()
	var/mob/living/carbon/human/H = antag.current
	equip_time_agent(H, src, is_twin)
	H.forceMove(pick(timeagentstart))


/datum/role/time_agent/proc/extract()
	var/mob/living/carbon/human/H = antag.current
	H.drop_all()
	showrift(H,1)
	qdel(H)
	for(var/i in objects_to_delete)
		objects_to_delete.Remove(i)
		qdel(i)
	increment_threat(rand(5,10))

/obj/item/device/chronocapture
	name = "chronocapture device"
	desc = "Used to confirm that everything is where it should be."
	icon = 'icons/obj/items.dmi'
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = W_CLASS_SMALL
	var/triggered = FALSE

/obj/item/device/chronocapture/afterattack(atom/target, mob/user)
	var/datum/role/R = user.mind.GetRole(TIMEAGENT)
	if(triggered || !istype(R))
		return
	triggered = TRUE
	playsound(loc, "polaroid", 75, 1, -3)
	spawn(3 SECONDS)
		triggered = FALSE
	var/datum/objective/target/locate/L = locate() in R.objectives.GetObjectives()
	if(L)
		L.check(view(target,2))

/obj/item/weapon/gun/projectile/automatic/rewind
	name = "rewind rifle"
	desc = "Don't need to reload if you just rewind the bullets back into the gun."
	icon_state = "xcomlasergun"
	ammo_type = "/obj/item/ammo_casing/a12mm"
	caliber = list(MM12 = 1)

/obj/item/weapon/gun/projectile/automatic/rewind/send_to_past(var/duration)
	..()
	if(istype(loc, /mob))
		var/mob/owner = loc
		spawn(duration)
			owner.put_in_hands(src)

/obj/item/weapon/gun/projectile/automatic/rewind/special_check(var/mob/M)
	return istimeagent(M)

/obj/item/weapon/gun/projectile/automatic/rewind/process_chambered()
	attempt_past_send(rand(10,15) SECONDS)
	return ..()

/obj/item/weapon/gun/projectile/automatic/rewind/update_icon()
	icon_state = initial(icon_state)

/obj/item/device/jump_charge
	name = "jump charge"
	desc = "A strange button."
	icon_state = "jump_charge"
	w_class = W_CLASS_SMALL
	var/triggered = FALSE

/obj/item/device/jump_charge/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(istimeagent(user) && istype(target, /obj/effect/time_anomaly))
		var/datum/role/time_agent/R = user.mind.GetRole(TIMEAGENT)
		if(R)
			var/datum/objective/time_agent_extract/TAE = locate() in R.objectives.GetObjectives()
			if(TAE && target == TAE.anomaly)
				to_chat(user, "<span class = 'notice'>New anomaly discovered. Welcome back, [user.real_name]. Moving to new co-ordinates.</span>")
				R.extract()
				TAE.anomaly = null
				qdel(target)
		return
	if(proximity_flag && !triggered)
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		icon_state = "jump_charge_firing"
		to_chat(user, "<span class = 'notice'>Jump charge armed. Firing in 3 seconds.</span>")
		triggered = TRUE
		spawn(3 SECONDS)
			icon_state = "jump_no_charge"
			future_rift(target, 10 SECONDS, 1)
			spawn(10 SECONDS)
				icon_state = initial(icon_state)
				triggered = FALSE

/obj/item/weapon/storage/belt/grenade
	storage_slots = 6
	can_only_hold = list("/obj/item/weapon/grenade")

/obj/item/weapon/storage/belt/grenade/chrono/New()
	..()
	new /obj/item/weapon/grenade/chronogrenade(src)
	new /obj/item/weapon/grenade/chronogrenade(src)
	new /obj/item/weapon/grenade/chronogrenade/future(src)
	new /obj/item/weapon/grenade/chronogrenade/future(src)
	new /obj/item/weapon/grenade/smokebomb(src)
	new /obj/item/weapon/grenade/empgrenade(src)

/obj/item/device/timeline_eraser
	name = "timeline eraser"
	desc = "Erase someone from the timeline. It has an unusual affinity against time travellers..."
	icon_state = "jump_charge"
	w_class = W_CLASS_SMALL
	var/channeling = FALSE



/obj/item/device/timeline_eraser/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	var/duration = 100
	// TODO: Make the timestop, properly stop when the process is done
	if(istype(target, /mob))
		var/mob/M = target
		if(istimeagent(M))
			duration = 0

	if(proximity_flag && !(target.flags & TIMELESS))
		channeling = TRUE
		spawn()
			while(channeling)
				//make the process obvious, but don't impede people interfering with it too much
				timestop(src, 30, 7, 0, /mob/living/carbon/)
				sleep(60)
		if(do_after(user, target, duration))
			delete_from_timeline(target, user)
		channeling = FALSE
	if(target.flags & TIMELESS)
		to_chat(user, "<span class = 'warning'>The target is currently immune to temporal meddling.</span>")

/obj/item/device/timeline_eraser/proc/delete_from_timeline(atom/target, mob/user)
	if(istimeagent(user))
		var/datum/role/R = user.mind.GetRole(TIMEAGENT)
		if(R)
			var/datum/objective/target/assassinate/erase/E = locate() in R.objectives.GetObjectives()
			if(E)
				E.check(target)
	if(istype(target, /mob))
		var/mob/M = target
		var/name = M.mind.name
		for (var/list/L in list(data_core.general, data_core.medical, data_core.security,data_core.locked))
			if (L)
				var/datum/data/record/R = find_record("name", name, L)
				qdel(R)
				R = null
		for(var/obj/machinery/telecomms/server/S in telecomms_list)
			for(var/datum/comm_log_entry/C in S.log_entries)
				if(C.parameters["realname"] == name)
					S.log_entries.Remove(C)
					qdel(C)
					C = null
		for(var/obj/machinery/message_server/S in message_servers)
			for(var/datum/data_pda_msg/P in S.pda_msgs)
				if((P.sender == name) || (P.recipient == name))
					S.pda_msgs.Remove(P)
					qdel(P)
					P = null
	qdel(target)

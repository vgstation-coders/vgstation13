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
	wikiroute = TIMEAGENT
	logo_state = "time-logo"
	default_admin_voice = "The Agency"
	admin_voice_style = "notice"
	disallow_job = TRUE
	var/list/objects_to_delete = list()
	var/time_elapsed = 0
	var/action_timer = 60
	var/datum/recruiter/eviltwinrecruiter = null
	var/is_twin = FALSE

/datum/role/time_agent/New(var/datum/mind/M, var/datum/faction/fac=null, var/new_id, var/override = FALSE)
	..()
	var/datum/faction/time_agent/timeagent_fac
	if(!fac)
		timeagent_fac = new
		timeagent_fac.primary_agent = src
	else if (istype(fac, /datum/faction/time_agent))
		timeagent_fac = fac
		if(timeagent_fac.primary_agent)
			timeagent_fac.eviltwins += src
		else
			timeagent_fac.primary_agent = src
	wikiroute = role_wiki[TIMEAGENT]

/datum/role/time_agent/add_to_faction
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
			This may not be the first time you visit this timeline, and it may not be the last.</span>")

	to_chat(antag.current, "<span class='danger'>Remember that the items you are provided with are largely non-expendable. Try not to lose them, especially the jump charge, as it is your ticket home.</span>")
	to_chat(antag.current, "<span class='info'><a HREF='?src=\ref[antag.current];getwiki=[wikiroute]'>(Wiki Guide)</a></span>")


/datum/role/time_agent/ForgeObjectives()
	AppendObjective(/datum/objective/target/locate)
	if(prob(30))
		AppendObjective(/datum/objective/target/locate/rearrange)
	if(prob(30))
		AppendObjective(/datum/objective/target/assassinate)
	AppendObjective(/datum/objective/freeform/aid)


/datum/role/time_agent/process()

	if (antag && antag.current)
		time_elapsed++
		if(time_elapsed % action_timer == 0)
			timer_action(time_elapsed / action_timer)
		if (antag.current.hud_used)
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
				antag.current.hud_used.countdown_time_agent()

/datum/role/time_agent/proc/timer_action(severity)
	if(antag && antag.current)
		var/mob/living/carbon/human/H = antag.current
		switch(severity)
			if(1)
				spawn_rand_maintenance(H)
				spawn()
					showrift(H,1)
			if(2)
				// send the time agent specifically to the past, future, and stop time on him for 30 sec or so
				H.timeslip += 30
			if(3)
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
						empulse(H.loc, 4, 10)
						// also maybe make the AI actively malicious to time travellers
			if(4)
				if(!H.stat)
					eviltwinrecruiter = new(src)
					eviltwinrecruiter.display_name = "time agent twin"
					eviltwinrecruiter.role = TIMEAGENT
					eviltwinrecruiter.jobban_roles = list("syndicate")
					eviltwinrecruiter.logging = TRUE

					// A player has their role set to Yes or Always
					eviltwinrecruiter.player_volunteering = new /callback(src, .proc/recruiter_recruiting)
					// ", but No or Never
					eviltwinrecruiter.player_not_volunteering = new /callback(src, .proc/recruiter_not_recruiting)

					eviltwinrecruiter.recruited = new /callback(src, .proc/recruiter_recruited)

					eviltwinrecruiter.request_player()
			if(5 to INFINITY)
				// time_elapsed += 30
				// var/datum/organ/internal/teleorgan = pick(H.internal_organs)
				return

/datum/role/time_agent/proc/recruiter_recruiting(mob/dead/observer/player, controls)
	to_chat(player, "<span class=\"recruit\">You are a possible candidate for \a [src]'s evil twin. Get ready. ([controls])</span>")

/datum/role/time_agent/proc/recruiter_not_recruiting(mob/dead/observer/player, controls)
	if(player.client && get_role_desire_str(player.client.prefs.roles[TIMEAGENT]) != "Never")
		to_chat(player, "<span class=\"recruit\">A [src] is being targeted by his evil twin. ([controls])</span>")

// For compatiability with the recruiter function callbacks, stops a runtime.
/datum/role/time_agent/proc/investigation_log(var/subject, var/message)
	antag.current.investigation_log(subject,message)

/datum/role/time_agent/proc/recruiter_recruited(mob/dead/observer/player)
	if(antag && antag.current && !antag.current.stat)
		if(player)
			qdel(eviltwinrecruiter)
			eviltwinrecruiter = null
			var/mob/living/carbon/human/H = new /mob/living/carbon/human(pick(timeagentstart))
			H.ckey = player.ckey
			H.client.changeView()
			var/datum/role/time_agent/eviltwin/twin = new /datum/role/time_agent/eviltwin(H.mind, fac = src.faction)
			twin.erase_target = src
			twin.Greet(GREET_DEFAULT)
			twin.ForgeObjectives()
			twin.OnPostSetup()
			twin.AnnounceObjectives()
		else
			eviltwinrecruiter.request_player()

/datum/role/time_agent/OnPostSetup()
	.=..()
	if(!.)
		return
	if(ishuman(antag.current))
		var/mob/living/carbon/human/H = antag.current
		equip_time_agent(H, src, is_twin)

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
		var/datum/faction/time_agent/F = user.mind.GetFactionFromRole(TIMEAGENT) || user.mind.GetFactionFromRole(TIMEAGENTTWIN)
		if(F)
			var/datum/objective/time_agent_extract/TAE = locate() in F.objective_holder.GetObjectives()
			if(TAE && target == TAE.anomaly)
				to_chat(user, "<span class = 'notice'>New anomaly discovered. Welcome back, [user.real_name]. Moving to new co-ordinates.</span>")
				var/datum/role/time_agent/R = user.mind.GetRole(TIMEAGENT) || user.mind.GetRole(TIMEAGENTTWIN)
				R.extract()
				TAE.extracted = TRUE
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

/obj/item/weapon/pinpointer/advpinpointer/time_agent
	mode = 2

/obj/item/weapon/pinpointer/advpinpointer/time_agent/New()
	item_paths["Jump Charge"] = /obj/item/device/jump_charge
	item_paths["Time Anomaly"] = /obj/effect/time_anomaly
	target = locate(/obj/item/device/jump_charge)
	for(var/path in potential_locate_objects)
		var/obj/dpath = new path
		item_paths[dpath.name] = path
		qdel(dpath)
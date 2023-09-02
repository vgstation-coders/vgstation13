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
					eviltwinrecruiter.player_volunteering = new /callback(src, nameof(src::recruiter_recruiting()))
					// ", but No or Never
					eviltwinrecruiter.player_not_volunteering = new /callback(src, nameof(src::recruiter_not_recruiting()))

					eviltwinrecruiter.recruited = new /callback(src, nameof(src::recruiter_recruited()))

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
			QDEL_NULL(eviltwinrecruiter)
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
	if(H.mind.GetRole(TIMEAGENT)) //The Time Agent is successful
		decrement_threat(25)
	else if(H.mind.GetRole(TIMEAGENTTWIN)) //The evil twin destabilizes the timestream
		increment_threat(25)

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
	var/logo

/obj/item/weapon/gun/projectile/automatic/rewind/New()
	..()
	logo = "<img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "time-logo"))]'/>"

/obj/item/weapon/gun/projectile/automatic/rewind/examine(mob/user)
	..()
	if(istimeagent(user))
		to_chat(user, "[logo] <span class='info'>This state-of-the-art rewind rifle engages its rewind mechanism only when firing, which takes between 10 and 15 seconds to finalize. When it rewinds it will end up in your possession if you held it at the time of firing.")

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
	flags = TIMELESS
	var/triggered = FALSE
	var/disarmed = FALSE //If toggled on, will delete itself without respawning
	var/times_respawned = 0 //A metric for how many times it respawned. You know, for fun.
	var/logo

/obj/item/device/jump_charge/examine(mob/user, size, show_name)
	..()
	if(istimeagent(user))
		to_chat(user, "[logo] <span class='info'>As a time agent, you know that you need this in order to go back through the time anomaly. Its extremely advanced technology allows it to regenerate in case of destruction, and in a pinch you can use it to send anything into the future after 3 seconds.</span>")
		if(triggered)
			to_chat(user, "<span class='warning'>It is still recharging.</span>")
		switch(times_respawned)
			if(-INFINITY to -1) //Not that it would happen outside of bus shenanigans, but who knows?
				to_chat(user, "<span class='sinister'>Somehow this device feels off, likely due to the tamperings of Bluespace Technicians.</span>")
			if(0)
				to_chat(user, "<span class='info'>This device is as pristine as it was in the day it was made.</span>")
			if(1)
				to_chat(user, "<span class='info'>This device looks a bit roughed up, likely as a result of undergoing temporal regeneration. You might want to keep it more safe.</span>")
			if(2 to 4)
				to_chat(user, "<span class='info'>This device has seen some better days. It has already undergone temporal regeneration several times, likely as a result of careless destruction. The Time Agency might make you go through Jump Charge Usage Orientation again...</span>")
			if(5 to 10)
				to_chat(user, "<span class='info'>This device is in a seriously rough shape. It has been destroyed enough times that the button feels sticky and you're worried about its internal components. At this point it is more likely that it was deliberately destroyed repeatedly rather than out of accident. The Time Agency might ask you a few questions about this.</span>")
			if(11 to INFINITY)
				to_chat(user, "<span class='info'>This device has been destroyed many, many times and it shows. Through sheer luck or just extremely advanced technology it still thankfully works as intended, but such damage will raise a brow or two, or three, or the entirety of the Time Agency's.</span>")
//Behavior shamelessly stolen from nuclear disks

/obj/item/device/jump_charge/New()
	..()
	logo = "<img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "time-logo"))]'/>"
	processing_objects.Add(src)

/obj/item/device/jump_charge/Destroy()
	processing_objects.Remove(src)
	replace_jump_charge()
	..()

/obj/item/device/jump_charge/Del()
	processing_objects.Remove(src)
	replace_jump_charge()
	..()

/obj/item/device/jump_charge/proc/replace_jump_charge()
	if(blobstart.len > 0 && !disarmed) //Does it really have to be blobstart? Feel free to replace with a more sane "anywhere on the station" list
		var/picked_turf = get_turf(pick(blobstart))
		var/obj/item/device/jump_charge/J = new(picked_turf)
		J.times_respawned = times_respawned + 1
		disarmed = TRUE
		qdel(src)

/obj/item/device/jump_charge/process()
	var/turf/T = get_turf(src)
	if(!T)
		qdel(src)

/obj/item/device/jump_charge/preattack(atom/target, mob/user, proximity_flag)
	if(!istimeagent(user)) //Non-time agents have no idea how to use this.
		return ..()
	. = 1
	if(!proximity_flag)
		return
	if(istype(target, /obj/effect/time_anomaly))
		var/datum/faction/time_agent/F = user.mind.GetFactionFromRole(TIMEAGENT) || user.mind.GetFactionFromRole(TIMEAGENTTWIN)
		if(F)
			var/datum/objective/time_agent_extract/TAE = locate() in F.objective_holder.GetObjectives()
			if(TAE && target == TAE.anomaly)
				var/time_agency_panic = FALSE
				if(times_respawned > 10)
					time_agency_panic = TRUE
				if(user.mind.GetRole(TIMEAGENT))
					to_chat(user, "<span class = 'notice'>New anomaly discovered. Welcome back, [user.real_name]. Moving to ne[time_agency_panic ? "-WHAT THE HELL HAPPENED TO THE JUMP CHARGE?!" : "w co-ordinates."]</span>")
				if(user.mind.GetRole(TIMEAGENTTWIN))
					to_chat(user, "<span class='notice'>As the time anomaly sizzles and refracts, you wonder what awaits you now as a fugitive from the Time Agency. One thing is for certain, you are going to cause chaos.")
				var/datum/role/time_agent/R = user.mind.GetRole(TIMEAGENT) || user.mind.GetRole(TIMEAGENTTWIN)
				R.extract()
				TAE.extracted = TRUE
				TAE.anomaly = null
				disarmed = TRUE
				qdel(src)
				qdel(target)
			else
				to_chat(user, "<span class='warning'>Your work is not over yet!</span>")
		return
	if(triggered)
		to_chat(user, "<span class='warning'>It is still recharging!</span>")
		return
	if(!triggered)
		playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
		icon_state = "jump_charge_firing"
		to_chat(user, "<span class = 'warning'>Jump charge armed and calibrated onto \the [target]. Firing in 3 seconds.</span>")
		triggered = TRUE
		spawn(3 SECONDS)
			icon_state = "jump_no_charge"
			future_rift(target, 10 SECONDS, 1)
			add_logs(user, target, "sent to the future", object=src.name)
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
	desc = "A strange button."
	icon_state = "jump_charge"
	w_class = W_CLASS_SMALL
	flags = TIMELESS
	var/in_process = FALSE
	var/charge = 5 //Will set to 0 and gradually increment to from 0 to 5 (10 seconds total), after which it can be used again
	var/logo

/obj/item/device/timeline_eraser/examine(mob/user, size, show_name)
	..()
	if(istimeagent(user))
		to_chat(user, "[logo] <span class='info'>As a time agent, you know that this device can erase nearly anything from reality. Erasing entities will take 10 seconds, erasing objects will take 5 seconds and erasing other time agents will take no time at all. People with temporal suits are protected from its effects.</span>")
		if(charge < 5)
			to_chat(user, "<span class='warning'>It is still recharging.</span>")

/obj/item/device/timeline_eraser/New()
	..()
	logo = "<img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "time-logo"))]'/>"

/obj/item/device/timeline_eraser/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/device/timeline_eraser/process()
	charge++
	if(charge >= 5)
		icon_state = "jump_charge"
		processing_objects.Remove(src)

/obj/item/device/timeline_eraser/preattack(atom/target, mob/user, proximity_flag)
	if(!istimeagent(user))
		return ..()
	if(!proximity_flag)
		return
	if(in_process)
		to_chat(user, "<span class='warning'>\The [src] is already erasing someone from reality!</span>")
		return
	if(charge < 5)
		to_chat(user, "<span class='warning'>\The [src] is still recharging!</span>")
		return
	if(istype(target, /obj/item/device/jump_charge)) //It is already unaffected but leaving a message here for trying to soft-lock is funny
		to_chat(user, "<span class='warning'>Are you insane? You can't just erase such an important device!</span>")
		return
	if(target.flags & TIMELESS)
		to_chat(user, "<span class = 'warning'>The target is currently immune to temporal meddling.</span>")
		return
	. = 1
	var/duration = 10 SECONDS
	// TODO: Make the timestop, properly stop when the process is done
	if(istype(target, /mob))
		var/mob/M = target
		if(istimeagent(M))
			duration = 0
	if(istype(target, /obj))
		duration = 5 SECONDS
	to_chat(user, "<span class='warning'>You start erasing \the [target] from existence...</span>")
	in_process = TRUE
	icon_state = "jump_charge_firing"
	timestop(src, 50, 7, 0, /mob/living/carbon/)
	if(do_after(user, target, duration))
		delete_from_timeline(target, user)
		charge = 0
		icon_state = "jump_no_charge"
		processing_objects.Add(src)
	else
		to_chat(user, "<span class-'warning'>Erasing \the [target] has been aborted.</span>")
		icon_state = "jump_charge"
	in_process = FALSE

/obj/item/device/timeline_eraser/proc/delete_from_timeline(atom/target, mob/user)
	if(istimeagent(user))
		var/datum/role/R = user.mind.GetRole(TIMEAGENT)
		if(R)
			var/datum/objective/target/assassinate/erase/E = locate() in R.objectives.GetObjectives()
			if(E)
				E.check(target)
	if(istype(target, /mob))
		var/mob/M = target
		if(M.mind)
			var/name = M.mind.name
			for (var/list/L in list(data_core.general, data_core.medical, data_core.security,data_core.locked))
				if (L)
					var/datum/data/record/R = find_record("name", name, L)
					QDEL_NULL(R)
			for(var/obj/machinery/telecomms/server/S in telecomms_list)
				for(var/datum/comm_log_entry/C in S.log_entries)
					if(C.parameters["realname"] == name)
						S.log_entries.Remove(C)
						QDEL_NULL(C)
			for(var/obj/machinery/message_server/S in message_servers)
				for(var/datum/data_pda_msg/P in S.pda_msgs)
					if((P.sender == name) || (P.recipient == name))
						S.pda_msgs.Remove(P)
						QDEL_NULL(P)
		M.drop_all()
	var/target_location = get_turf(target)
	message_admins("[user] ([user.ckey]) has ERASED [target] from existence at [formatJumpTo(target_location)]!")
	qdel(target)
	to_chat(user, "<span class='warning'>You erase \the [target] from existence.</span>")

/obj/item/weapon/pinpointer/advpinpointer/time_agent
	mode = 2
	var/logo

/obj/item/weapon/pinpointer/advpinpointer/time_agent/New()
	..()
	logo = "<img src='data:image/png;base64,[icon2base64(icon('icons/logos.dmi', "time-logo"))]'/>"

/obj/item/weapon/pinpointer/advpinpointer/time_agent/examine(mob/user)
	..()
	if(istimeagent(user))
		to_chat(user, "[logo] <span class='info'>This allows you to search for the jump charge and the time anomaly when set.</span>")

/obj/item/weapon/pinpointer/advpinpointer/time_agent/New()
	item_paths["Jump Charge"] = /obj/item/device/jump_charge
	item_paths["Time Anomaly"] = /obj/effect/time_anomaly
	target = locate(/obj/item/device/jump_charge)
	for(var/path in potential_locate_objects)
		var/obj/dpath = new path
		item_paths[dpath.name] = path
		qdel(dpath)

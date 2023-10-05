var/list/event_last_fired = list()

//Always triggers an event when called, dynamically chooses events based on job population
/proc/spawn_dynamic_event()
	if(!config.allow_random_events || map && map.dorf)
		return

	var/minutes_passed = world.time/600
	var/roundstart_delay = 15

	if (admin_disable_events)
		message_admins("A random event was prevented from firing by admins.")
		log_admin("A random event was prevented from firing by admins.")
		return

	if(minutes_passed < roundstart_delay) //No events near roundstart
		message_admins("Too early to trigger random event, aborting.")
		return

	if(universe.name != "Normal")
		message_admins("Universe isn't normal, aborting random event spawn.")
		return
	if(player_list.len < 1) //minimum pop of 1 to trigger events
		message_admins("Too few players to trigger random event, aborting.")
		return
	var/list/active_with_role = number_active_with_role()

	// Maps event names to event chances
	// For each chance, 100 represents "normal likelihood", anything below 100 is "reduced likelihood", anything above 100 is "increased likelihood"
	// Events have to be manually added to this proc to happen
	var/list/possibleEvents = list()

	//see:
	// code\modules\Economy\Economy_Events.dm
	// code\modules\Economy\Economy_Events_Mundane.dm
	//Commented out for now. Let's be honest, a string of text on PDA is not worth a meteor shower or ion storm
	//Will be re-implemented in the near future, its chance to proc will be independant from the other random events
	//possibleEvents[/datum/event/news_event] = 100//
	//possibleEvents[/datum/event/trivial_news] = 150//Gibson Gazette, taken from config/trivial.txt
	//possibleEvents[/datum/event/mundane_news] = 100//Tau Ceti Daily

	//It is this coder's thought that weighting events on job counts is dumb and predictable as hell. 10 Engies ? Hope you like Meteors
	//Instead, weighting goes from 100 (boring and common) to 10 (exceptional)
	for(var/type in subtypesof(/datum/event))
		if((map.event_blacklist.len && map.event_blacklist.Find(type)) || (map.event_whitelist.len && !map.event_whitelist.Find(type)))
			possibleEvents[type] = 0
			continue
		var/datum/event/E = new type(FALSE)
		var/value = E.can_start(active_with_role)
		if(value > 0)
			possibleEvents[type] = value
		qdel(E)

	for(var/event_type in event_last_fired)
		if(possibleEvents[event_type])
			var/time_passed = world.time - event_last_fired[event_type]
			var/full_recharge_after = 60 * 60 * 10 // Was 3 hours, changed to 1 hour since rounds rarely last that long anyways
			var/weight_modifier = max(0, (full_recharge_after - time_passed) / 300)

			possibleEvents[event_type] = max(possibleEvents[event_type] - weight_modifier, 0)

	var/picked_event = pickweight(possibleEvents)
	event_last_fired[picked_event] = world.time

	// Debug code below here, very useful for testing so don't delete please.
	var/debug_message = "Firing random event. "
	for(var/V in active_with_role)
		debug_message += "#[V]:[active_with_role[V]] "
	debug_message += "||| "
	for(var/V in possibleEvents)
		debug_message += "[V]:[possibleEvents[V]]"
	debug_message += "|||Picked:[picked_event]"
	log_debug(debug_message)

	if(!picked_event)
		return

	//The event will add itself to the MC's event list
	//and start working via the constructor.
	new picked_event

	score.eventsendured++

	message_admins("[picked_event] firing. Time to have fun.")

	return 1

// Returns how many characters are currently active(not logged out, not AFK for more than 10 minutes)
// with a specific role.
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
/proc/number_active_with_role(role)
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Botanist"] = 0

	for(var/mob/M in player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		if(isrobot(M))
			var/mob/living/silicon/robot/tincan = M
			if(tincan.module)
				switch(tincan.module.name)
					if("engineering robot module")
						active_with_role["Engineer"]++
					if("medical robot module")
						active_with_role["Medical"]++
					if("security robot module")
						active_with_role["Security"]++

		if((M.mind.assigned_role in engineering_positions) && M.mind.assigned_role != "Mechanic")
			active_with_role["Engineer"]++

		if(M.mind.assigned_role in medical_positions)
			active_with_role["Medical"]++

		if(M.mind.assigned_role in security_positions)
			active_with_role["Security"]++

		if(M.mind.assigned_role in science_positions)
			active_with_role["Scientist"]++

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++

		if(M.mind.assigned_role == "Cyborg")
			active_with_role["Cyborg"]++

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++

		if(M.mind.assigned_role == "Botanist")
			active_with_role["Botanist"]++

	return active_with_role

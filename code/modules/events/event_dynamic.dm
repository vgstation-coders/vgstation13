var/list/possibleEvents = list()
//A list of events and their weights. These range from quite uncommon like a rod (15) to very common like carp (40)

//Always triggers an event when called, dynamically chooses events based on job population
/proc/spawn_dynamic_event(var/forced=FALSE)
	if(!forced)
		if(!config.allow_random_events || (map && map.dorf))
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


	//Scraped PDA text events (like random news events) can be found in
	// code\modules\Economy\Economy_Events.dm
	// code\modules\Economy\Economy_Events_Mundane.dm
	if(!possibleEvents.len)
		for(var/type in subtypesof(/datum/event))
			if((map.event_blacklist.len && map.event_blacklist.Find(type)) || (map.event_whitelist.len && !map.event_whitelist.Find(type)))
				continue //Blacklisted, don't even create them
			var/datum/event/E = new type(FALSE)
			possibleEvents += E

	var/list/drawing = list()
	for(var/datum/event/E in possibleEvents)
		drawing[E] = max(0,E.can_start(active_with_role) - E.recency_weight()) //Reminder: never have negatives when using pickweight

	var/datum/event/picked_event = pickweight(drawing)
	if(!picked_event)
		return
	message_admins("EVENT: [picked_event] started with [drawing[picked_event]] weight.")
	possibleEvents -= picked_event
	if(!picked_event.oneShot)
		var/newtype = picked_event.type
		var/datum/event/to_add = new newtype(FALSE)
		to_add.last_fired = world.time
		possibleEvents += to_add //Replace with a new datum if it's not oneshot

	// Debug code below here, very useful for testing so don't delete please.
	var/debug_message = "Firing random event. "
	for(var/V in active_with_role)
		debug_message += "#[V]:[active_with_role[V]] "
	debug_message += "||| "
	for(var/V in possibleEvents)
		debug_message += "[V]:[possibleEvents[V]]"
	debug_message += "|||Picked:[picked_event]"
	log_debug(debug_message)

	picked_event.setup()
	events.Add(picked_event)

	score.eventsendured++

	return 1

// Returns a list of how many characters are currently active with a specific role
// see: (not logged out, not AFK for more than 10 minutes)
// Note that this isn't sorted by department, because e.g. having a roboticist shouldn't make meteors spawn.
// Minor roles have lesser influence on events, Any just cares about active players at all
/proc/number_active_with_role()
	var/list/active_with_role = list()
	active_with_role["Engineer"] = 0
	active_with_role["Medical"] = 0
	active_with_role["Security"] = 0
	active_with_role["Scientist"] = 0
	active_with_role["AI"] = 0
	active_with_role["Cyborg"] = 0
	active_with_role["Janitor"] = 0
	active_with_role["Botanist"] = 0
	active_with_role["Minor"] = 0
	active_with_role["Any"] = 0

	for(var/mob/M in player_list)
		if(!M.mind || !M.client || M.client.inactivity > 10 * 10 * 60) // longer than 10 minutes AFK counts them as inactive
			continue

		active_with_role["Any"]++

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
					if("combat robot module")
						active_with_role["Security"]++
					if("janitorial robot module")
						active_with_role["Janitor"]++
					else
						active_with_role["Minor"]++

		if((M.mind.assigned_role in engineering_positions) && M.mind.assigned_role != "Mechanic")
			active_with_role["Engineer"]++
			continue

		if(M.mind.assigned_role in medical_positions)
			active_with_role["Medical"]++
			continue

		if(M.mind.assigned_role in security_positions)
			active_with_role["Security"]++
			continue

		if(M.mind.assigned_role in science_positions)
			active_with_role["Scientist"]++
			continue

		if(M.mind.assigned_role == "AI")
			active_with_role["AI"]++
			continue

		if(M.mind.assigned_role == "Cyborg")
			active_with_role["Cyborg"]++
			continue

		if(M.mind.assigned_role == "Janitor")
			active_with_role["Janitor"]++
			continue

		if(M.mind.assigned_role == "Botanist")
			active_with_role["Botanist"]++
			continue

		active_with_role["Minor"]++

	return active_with_role

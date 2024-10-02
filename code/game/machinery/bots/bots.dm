#define MAX_PATHING_ATTEMPTS 15
#define BEACON_TIMEOUT 15 // Process calls

#define SEC_BOT 1 // Secutritrons (Beepsky) and ED-209s
#define MULE_BOT 2 // MULEbots
#define FLOOR_BOT 3 // Floorbots
#define CLEAN_BOT 4 // Cleanbots
#define MED_BOT 5 // Medibots

#define BOT_OLDTARGET_FORGET_DEFAULT 100 //100*WaitMachinery

#if ASTAR_DEBUG == 1
#define log_astar_bot(text) visible_message("[src] : [text]")
#define log_astar_beacon(text) //to_chat(world, "[src] : [text]")
#define log_astar_command(text) to_chat(world, "[src] : [text]")
#else
#define log_astar_bot(text)
#define log_astar_beacon(text)
#define log_astar_command(text)
#endif

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	plane = MOB_PLANE
	luminosity = 3
	use_power = MACHINE_POWER_USE_NONE
	pAImovement_delay = 1
	machine_flags = EMAGGABLE
	var/icon_initial //To get around all that pesky hardcoding of icon states, don't put modifiers on this one
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/mob/living/simple_animal/hostile/pulse_demon/PD_occupant // for when they take over them
	var/on = 1
	health = 0 //do not forget to set health for your bot!
	maxHealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	var/bot_type // For HuD users.
	var/declare_message = "" //What the bot will display to the HUD user.
	var/bot_flags

	var/frustration

	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route

	var/steps_per = 1 //How many steps we take per process
	var/initial_steps_per = 1 // What should we go back to when we are done chasing a target ?

	var/atom/target 				//The target of our path, could be a turf, could be a person, could be mess
	var/list/old_targets = list()			//Our previous targets, so we don't get caught constantly going to the same spot. Order as pointer => int (Time to forget)
	var/list/path = list() //Our regular path

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency
	var/control_filter = null

	var/awaiting_beacon //If we've sent out a signal to get a beacon
	var/total_awaiting_beacon // How long have we been waiting for?
	var/nearest_beacon //What our nearest beacon is
	var/turf/nearest_beacon_loc //The turf of our nearest beacon

	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/auto_patrol = 0		// set to make bot automatically patrol
	var/waiting_for_patrol = FALSE // Are we waiting for a beacon to give us a clear path? (in order to avoid calling for a path more than once)
	var/waiting_for_path = FALSE
	var/list/patrol_path = list() //Our patroling path

	var/current_pathing = 0 // Safety check for recursive movement
	var/look_for_target = FALSE // Are we currently calculating a path to a target?
	var/target_chasing_distance = 7 // Default view

	var/summoned = FALSE // Were they summoned?

	var/commanding_radios = list(/obj/item/radio/integrated/signal/bot)

	// Queue of directions. Just like shift-clicking on age of empires 2. It'll go to the next direction after it's finished with this one
	// It's a list of lists. These lists are coordinates
	// Mulebots contain an extra fourth parameter used to load/unload at that position.
	var/list/destinations_queue = list()
	var/MAX_QUEUE_LENGTH = 15 // Maximum length of our queue

// Adding the bots to global lists; initialize if not.
/obj/machinery/bot/New()
	. = ..()
	for(var/datum/event/ionstorm/I in events)
		if(istype(I) && I.active)
			I.bots += src
	bots_list += src
	machines -= src // We have our own subsystem.
	if(bot_flags & BOT_CONTROL)
		radio_controller.add_object(src, control_freq, filter = control_filter)
	if(bot_flags & BOT_BEACON)
		radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)

/obj/machinery/bot/Destroy()
	. = ..()
	if(botcard)
		QDEL_NULL(botcard)
	if (waiting_for_patrol || waiting_for_path)
		for (var/datum/path_maker/PM in pathmakers)
			if (PM.owner == src)
				qdel(PM)
	bots_list -= src
	nearest_beacon_loc = null
	patrol_target = null
	nearest_beacon = null
	patrol_path.Cut()
	path.Cut()
	if(bot_flags & BOT_CONTROL)
		radio_controller.remove_object(src, control_freq)
	if(bot_flags & BOT_BEACON)
		radio_controller.remove_object(src, beacon_freq)

// Reset the safety counter, look or move along a path, and then do bot things.
/obj/machinery/bot/process()
	current_pathing = 0
	if(!src.on)
		return
	if (src.integratedpai)
		return
	if (src.PD_occupant)
		return
	else
		total_awaiting_beacon = 0
	process_pathing()
	process_bot()

/obj/machinery/bot/relaymove(var/mob/user, direction)
	if(ispulsedemon(user))
		return pAImove(user,direction)
	return FALSE

/obj/machinery/bot/pAImove(mob/living/user, dir)
	if(!on)
		return FALSE
	if(!..())
		return FALSE
	if(!isturf(loc))
		return FALSE
	step(src, dir)
	return TRUE

// Makes the bot busy while it looks for a target.
/obj/machinery/bot/proc/find_target()
	// Let us hurry home to our master.
	if (summoned)
		return FALSE

	look_for_target = TRUE
	target_selection()
	look_for_target = FALSE

// Concrete logic of selecting a target, depending on each bot.
/obj/machinery/bot/proc/target_selection()

// Will we continue chasing our target or not?
/obj/machinery/bot/proc/can_abandon_target()
	return (!target || target.gcDestroyed || get_dist(src, target) > target_chasing_distance) && !look_for_target &&!summoned

//Set time_to_forget to -1 to never forget it
/obj/machinery/bot/proc/add_oldtarget(var/old_target, var/time_to_forget = BOT_OLDTARGET_FORGET_DEFAULT)
	old_targets[old_target] = time_to_forget
	log_astar_bot("[old_target] = [old_targets[old_target]]")

// Remove an old target. Override for more complicated logic.
/obj/machinery/bot/proc/remove_oldtarget(var/old_target)
	old_targets.Remove(old_target)

/obj/machinery/bot/proc/decay_oldtargets()
	for(var/i in old_targets)
		log_astar_bot("old target: [i] [old_targets[i]]")
		if(--old_targets[i] <= 0)
			remove_oldtarget(i)

// Can we move to the next tile or not ?
/obj/machinery/bot/proc/can_path()
	return TRUE

// If we get a path through process_path(), which means we have a target, and we're not set to autopatrol, we get a patrol path.
/obj/machinery/bot/proc/process_pathing()
	if(!process_path() && (bot_flags & BOT_PATROL) && auto_patrol)
		process_patrol()

//misc stuff our bot may be doing (looking for people to heal, or hurt, or tile)
/obj/machinery/bot/proc/process_bot()

/*** Regular Pathing Section ***/
// If we don't have a path, we get a path
// If we have a path, we step.
// Speed of the bot is controlled through steps_per.
// return true to avoid calling process_patrol
// Move "recursively" in order to respect the subsystem's waitfor = FALSE.
/obj/machinery/bot/proc/process_path(var/remaining_steps = steps_per)
	current_pathing++
	if (current_pathing > MAX_PATHING_ATTEMPTS)
		CRASH("maximum pathing reached")
	if (remaining_steps <= 0)
		return
	if (!isturf(src.loc))
		return // Stay in the closet, little bot. The world isn't ready to accept you yet ;_;
	if (!can_path()) // We're busy.
		return
	var/turf/T = get_turf(src)
	set_glide_size(DELAY2GLIDESIZE(SS_WAIT_BOTS/steps_per))
	if(!length(path)) //It is assumed we gain a path through process_bot()
		if(target)
			if (waiting_for_path)
				return 1
			calc_path(target, new /callback(src, nameof(src::get_path())))
			if (path && length(path))
				process_path()
			return 1
		return  0

	patrol_path = list() //Kill any patrols we're using

	log_astar_bot("Step [remaining_steps] of [steps_per]")
	if(loc == get_turf(target))
		return at_path_target()
	var/turf/next = path[1]
	if(istype(next, /turf/simulated) || (bot_flags & BOT_SPACEWORTHY))
		step_to(src, next)
		if(get_turf(src) == next)
			path -= next
			frustration = 0
			on_path_step(next)
		else
			frustration++
			on_path_step_fail(next)
		spawn(SS_WAIT_BOTS/steps_per)
			process_path(remaining_steps - 1)
	return T == get_turf(src)

// What happens when the bot cannot go to the next turf.
// Most bots will just try to open the door.
/obj/machinery/bot/proc/on_path_step_fail(var/turf/next) // No door shall be left unopened
	for (var/obj/machinery/door/D in next)
		if (istype(D, /obj/machinery/door/firedoor))
			continue
		if (istype(D, /obj/machinery/door/poddoor))
			continue
		if (D.check_access(botcard) && !D.operating && D.SpecialAccess(src))
			D.open()
			frustration = 0
			return TRUE
	if(frustration > 5)
		summoned = FALSE // Let's not try again.
		if (target && !target.gcDestroyed)
			calc_path(target, new /callback(src, nameof(src::get_path())), next)
		else
			target = null
			path = list()
	return

/obj/machinery/bot/to_bump(var/M) //Leave no man un-phased through!
	if((istype(M, /mob/living/)) && (!src.anchored) && !(bot_flags & BOT_DENSE))
		src.forceMove(M:loc)
		src.frustration = 0
	..()
// Proc called on a regular patrol step.
/obj/machinery/bot/proc/on_path_step(var/turf/next)

// Proc called when heave reached our target. We can then fix the hole, heal the guy, etc.
/obj/machinery/bot/proc/at_path_target()
	summoned = FALSE
	target = null
	return TRUE

/obj/machinery/bot/proc/can_patrol()
	return can_path()

/*** Patrol Pathing Section ***/
// Same as process_path. If we don't have a path, we get a path.
// If we have a path, we take a step on that path
// It is very important to exit this proc when you don't have a path.
/obj/machinery/bot/proc/process_patrol(var/remaining_steps = steps_per)
	if (!can_patrol())
		return
	astar_debug("process patrol called [src] [patrol_path.len]")
	current_pathing++
	if (current_pathing > MAX_PATHING_ATTEMPTS)
		CRASH("maximum pathing reached")
	set_glide_size(DELAY2GLIDESIZE(SS_WAIT_BOTS/steps_per))
	if(!patrol_path.len)
		return find_patrol_path()
	if(remaining_steps <= 0)
		return
	if(!can_path())
		return
	log_astar_bot("Step [remaining_steps] of [steps_per]")
	if(loc == patrol_target)
		patrol_path = list()
		return at_patrol_target()
	var/turf/next = patrol_path[1]
	if(istype(next, /turf/simulated) || (bot_flags & BOT_SPACEWORTHY))
		step_to(src, next)
		if(get_turf(src) == next)
			frustration = 0
			patrol_path -= next
			on_patrol_step(next)
		else
			frustration++
			on_patrol_step_fail(next)
		sleep(SS_WAIT_BOTS/steps_per)
		process_patrol(remaining_steps - 1)
	return TRUE

// This proc is called when the bot has no patrol path, no regular path, and is on autopatrol.
// First, we check if we are not already waiting for a signal and a location to path to.
// Then, we stay at our patrol post for some time.
// After that, we signal the beacon where we are and they transmit a location.
// The closet location is picked, and a path is calculated.
/obj/machinery/bot/proc/find_patrol_path()
	if (summoned)
		return
	if(waiting_for_patrol)
		return
	if(awaiting_beacon++)
		log_astar_beacon("awaiting beacon:[awaiting_beacon]")
		if(awaiting_beacon > 5)
			awaiting_beacon = 0
			find_nearest_beacon()
		return
	if(next_destination)
		log_astar_beacon("onwards to [new_destination]")
		set_destination(next_destination)

	if(patrol_target)
		waiting_for_patrol = TRUE
		calc_patrol_path(patrol_target, new /callback(src, nameof(src::get_patrol_path())))
// This proc send out a singal to every beacon listening to the "beacon_freq" variable.
// The signal says, "i'm a bot looking for a beacon to patrol to."
// Every beacon with the flag "patrol" responds by trasmitting its location.
// The bot calculates the nearest one and then calculates a path.
/obj/machinery/bot/proc/find_nearest_beacon(var/post_signal = TRUE)
	log_astar_beacon("find_nearest_beacon called")
	if(awaiting_beacon)
		return
	if (post_signal)
		nearest_beacon = null
		new_destination = "__nearest__"
		post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1
	spawn(10)
		awaiting_beacon = 0
		if(nearest_beacon)
			total_awaiting_beacon = 0
			log_astar_beacon("nearest_beacon was found and is [nearest_beacon]")
			set_destination(nearest_beacon)
		else
			total_awaiting_beacon++
			if (total_awaiting_beacon >= MAX_PATHING_ATTEMPTS)
				total_awaiting_beacon = 0
				auto_patrol = 0
			else
				find_nearest_beacon(FALSE) // Let's try again...

// This proc is different from the other one.
// It still transmits for every beacon listening to the frequency.
// However, it just says, "i'm a bot looking for a beacon named [new_dest]"
// Only [new_dest], if it exist, replies with its location.
/obj/machinery/bot/proc/set_destination(var/new_dest)
	if (new_dest)
		log_astar_beacon("new_destination [new_dest]")
		new_destination = new_dest
		post_signal(beacon_freq, "findbeacon", "patrol")
		awaiting_beacon = 1

// Proc called when we reached our patrol destination.
// Normal behaviour is to null the current target and find a new one.
/obj/machinery/bot/proc/at_patrol_target()
	patrol_target = null
	find_patrol_path()

// Proc called on a regular patrol step.
/obj/machinery/bot/proc/on_patrol_step(var/turf/next)
	return TRUE

// What happens when the bot cannot go to the next turf during a patrol.
// Most bots will just try to open the door.
/obj/machinery/bot/proc/on_patrol_step_fail(var/turf/next) // No door shall be left unopened
	for (var/obj/machinery/door/D in next)
		if (istype(D, /obj/machinery/door/firedoor))
			continue
		if (istype(D, /obj/machinery/door/poddoor))
			continue
		if (D.check_access(botcard) && !D.operating && D.SpecialAccess(src))
			D.open()
			frustration = 0
			return TRUE
	if(frustration > 5)
		if (target && !target.gcDestroyed)
			calc_path(target, new /callback(src, nameof(src::get_path())), next)
		else
			target = null
			patrol_path = list()

// --- SIGNAL CODE ---

// send a radio signal with a single data key/value pair
/obj/machinery/bot/proc/post_signal(var/freq, var/key, var/value)
	log_astar_beacon("posted signal [key] = [value] on freq [freq].")
	post_signal_multiple(freq, list("[key]" = value))

// send a complex radio signal with an associative list of value in keyval.
// this is how bots communicate with beacons by requesting locations.
/obj/machinery/bot/proc/post_signal_multiple(var/freq, var/list/keyval)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)
	if(!frequency)
		return

	var/datum/signal/signal = new /datum/signal
	signal.source = src
	signal.transmission_method = 1
	signal.data = keyval
	if(signal.data["findbeacon"])
		log_astar_beacon("singal sent via navbeacons")
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else
		frequency.post_signal(src, signal)

// Checks if the bot can receive the signal or not.
/obj/machinery/bot/proc/is_valid_signal(var/datum/signal/signal)
	return signal.data["command"] || signal.data["patrol"] // Most bots wait for a patrol signal

// This proc is called when we get a singal from beacons.
// Either we are looking for the nearest beacon, and in this case we compare each signal we get to get the closest one.
// Or we are looking for one beacon in particular, and will only set our target if what we receive is the new destination we are supposed to go to.
// After receiving a valid signal, we'll set it as our CURRENT destination.
/obj/machinery/bot/receive_signal(var/datum/signal/signal)
	var/valid = is_valid_signal(signal)
	if(!valid)
		return 0

	// -- Patrol signal --
	var/recv = signal.data["beacon"]
	if (recv)
		log_astar_beacon("received patrol signal : [recv]")
		if(recv == new_destination)	// if the recvd beacon location matches the set destination, then we will navigate there
			handle_received_destination(signal, recv)
			return 1
		// if looking for nearest beacon
		if(new_destination == "__nearest__")
			log_astar_beacon("calculating nearest beacon")
			var/dist = get_dist(src,signal.source.loc)
			if(nearest_beacon)
				// note we ignore the beacon we are located at
				if(dist>1 && dist<get_dist(src, nearest_beacon_loc))
					log_astar_beacon("replacing nearest_beacon [nearest_beacon] with [recv] as it is closer. [get_dist(src, nearest_beacon_loc)] [dist]")
					nearest_beacon = recv
					nearest_beacon_loc = signal.source.loc
				return
			else if(dist > 1) //We don't have a nearest beacon to compare to, so we're going to accept the first one we find that isn't on the same turf as us
				log_astar_beacon("new nearest_beacon is [recv]")
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
			return 1
	// -- Command signals --
	var/target_bot = signal.data["target"]
	var/command = signal.data["command"]
	log_astar_command("received signal [command] for [target_bot]")
	if (target_bot != "\ref[src]")
		return
	execute_signal_command(signal, command)

// -- We got a new destination, how do we go there?
// Most bots will patrol to the target.
/obj/machinery/bot/proc/handle_received_destination(var/datum/signal/signal, var/recv)
	log_astar_beacon("[src] : new destination chosen, [recv]")
	destination = new_destination
	patrol_target = signal.source.loc
	next_destination = signal.data["next_patrol"]
	awaiting_beacon = 0

// -- Received an order via signal. This proc assumes the bot is the correct one to get the command.
/obj/machinery/bot/proc/execute_signal_command(var/datum/signal/signal, var/command)
	log_astar_command("recieved command [command]")
	if (!is_type_in_list(signal.source, commanding_radios))
		log_astar_command("refused command [command], wrong radio type. Expected [english_list(commanding_radios, and_text = " or ")] got [signal.source.type]")
		return TRUE
	switch (command)
		if ("auto_patrol")
			auto_patrol = !auto_patrol
			return 1
		if ("summon")
			if (summoned)
				summoned  = FALSE
				destination = ""
				target = null
			else
				summoned = TRUE
				destination = get_turf(signal.source)
				target = get_turf(signal.source)
			path = list()
			patrol_path = list()
			destinations_queue = list()
			return 1
		if ("switch_power")
			if (on)
				turn_off()
			else
				turn_on()
			return 1
		if ("go_to")
			handle_goto_command(signal)
			return TRUE

/datum/bot/order
	var/turf/destination

/datum/bot/order/New(var/turf/place_to_go)
	destination = place_to_go

/datum/bot/order/mule
	var/atom/thing_to_load = null
	var/unload_here = FALSE
	var/unload_dir = 0
	var/loc_description = ""
	var/returning = FALSE

/datum/bot/order/mule/New(var/turf/place_to_go, var/atom/thing = null, _unload_here = FALSE, var/unload_direction = 0, var/text_desc = "Unknown")
	destination = place_to_go
	thing_to_load = thing
	unload_here = _unload_here
	unload_dir = unload_direction
	loc_description = text_desc
	astar_debug_mulebots("Order up! [destination] [loc_description] [thing_to_load] [unload_here] [unload_dir]!")

/datum/bot/order/mule/unload

/obj/machinery/bot/proc/handle_goto_command(var/datum/signal/signal)
	var/turf/location = locate(text2num(signal.data["x"]), text2num(signal.data["y"]), text2num(signal.data["z"]))
	if(!location)
		return FALSE
	var/datum/bot/order/order = new /datum/bot/order(location)
	queue_destination(order)

/obj/machinery/bot/proc/queue_destination(coordinates)
	if(destinations_queue.len > MAX_QUEUE_LENGTH)
		return FALSE
	destinations_queue += coordinates
	return TRUE

/obj/machinery/bot/proc/return_status()
	return "Idle"

// Caluculate a path between the bot and the target.
// Target is the target to go to.
// callback gets called by the pathmaker once it's done its work and wishes to return a path.
// avoid is a turf the path should NOT go through. (a previous obstacle.) This info is then given to the pathmaker.
// Fast bots use quick_AStar method to direcly calculate a path and move on it.
/obj/machinery/bot/proc/calc_path(var/target, var/callback, var/turf/avoid = null)
	ASSERT(target && callback)
	var/cardinal_proc = bot_flags & BOT_SPACEWORTHY ? /turf/proc/AdjacentTurfsSpace : /turf/proc/CardinalTurfsWithAccess
	if (((get_dist(src, target) < 13) && !(bot_flags & BOT_NOT_CHASING)) || (get_dist(src, target) < 6)) // For beepers and ED209
		// IMPORTANT: Quick AStar only takes TURFS as arguments.
		log_astar_bot("quick astar path calculation...")
		path = quick_AStar(src.loc, get_turf(target), cardinal_proc, /turf/proc/Distance_cardinal, 0, max(10,get_dist(src,target)*3), id=botcard, exclude=avoid, reference="\ref[src]")
		log_astar_bot("path is [path.len]")
		return TRUE
	waiting_for_path = 1
	. = AStar(src, callback, src.loc, target, cardinal_proc, /turf/proc/Distance_cardinal, 0, max(10,get_dist(src,target)*3), id=botcard, exclude=avoid)
	if (!.)
		waiting_for_path = 0

/obj/machinery/bot/proc/calc_patrol_path(var/target, var/callback, var/turf/avoid = null)
	ASSERT(target && callback)
	log_astar_beacon("[new_destination]")
	var/cardinal_proc = bot_flags & BOT_SPACEWORTHY ? /turf/proc/AdjacentTurfsSpace : /turf/proc/CardinalTurfsWithAccess
	if ((get_dist(src, target) < 13) && !(bot_flags & BOT_NOT_CHASING)) // For beepers and ED209
		// IMPORTANT: Quick AStar only takes TURFS as arguments.
		waiting_for_patrol = FALSE // Case we are calculating a quick path for a patrol.
		patrol_path = quick_AStar(src.loc, get_turf(target), cardinal_proc, /turf/proc/Distance_cardinal, 0, max(10,get_dist(src,target)*3), id=botcard, exclude=avoid, reference="\ref[src]")
		return TRUE
	return AStar(src, callback, src.loc, target, cardinal_proc, /turf/proc/Distance_cardinal, 0, max(10,get_dist(src,target)*3), id=botcard, exclude=avoid)


// This proc is called by the path maker once it has calculated a path.
/obj/machinery/bot/proc/get_path(var/list/L, var/target)
	waiting_for_path = 0
	if(islist(L))
		path = L
		if (bot_flags & BOT_NOT_CHASING) // Chasing bots are obstinate and will not forget their target so easily.
			target = null
			add_oldtarget(target)
		return TRUE
	return FALSE

// This proc is called by the path maker once it has calculated a path for the patrol.
// It sets waiting_for_patrol to FALSE to let us caculate paths for patrols again.
/obj/machinery/bot/proc/get_patrol_path(var/list/L, var/target)
	waiting_for_patrol = FALSE
	if(islist(L))
		patrol_path = L
		return TRUE
	auto_patrol = FALSE // Failed to get a patrol path
	return FALSE

// -- These other procs are self-explanatory and related to regular updates and interactions with the bots.

/obj/machinery/bot/proc/turn_on()
	if(stat)
		return 0
	on = 1
	set_light(initial(luminosity))
	waiting_for_patrol = FALSE
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	set_light(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/emag_act(mob/user)
	if(locked)
		locked = 0
		emagged = 1
		if(user)
			to_chat(user, "<span class='warning'>You remove [src]'s control restrictions. Opening up its maintenance panel and swiping again will cause [src] to malfunction.</span>")
	if(!locked && open)
		emagged = 2
		if(user)
			to_chat(user, "<span class='warning'>You cause a malfunction in [src]'s behavioral matrix.</span>")

/obj/machinery/bot/emag_ai(mob/living/silicon/ai/A)
	locked = 0
	open = 1
	emag_act(A)

/obj/machinery/bot/npc_tamper_act(mob/living/L)
	if(on)
		turn_off()
	else
		turn_on()

/obj/machinery/bot/examine(mob/user)
	..()
	if (src.health < maxHealth)
		if (src.health > maxHealth/3)
			to_chat(user, "<span class='warning'>[src]'s parts look loose.</span>")
		else
			to_chat(user, "<span class='danger'>[src]'s parts look very loose!</span>")

/obj/machinery/bot/attack_alien(var/mob/living/carbon/alien/user as mob)
	if(flags & INVULNERABLE)
		return
	user.do_attack_animation(src, user)
	src.health -= rand(15,30)*brute_dam_coeff
	src.visible_message("<span class='danger'>[user] has slashed [src]!</span>")
	playsound(src, 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)

	healthcheck()


/obj/machinery/bot/attack_animal(var/mob/living/simple_animal/M as mob)
	if(flags & INVULNERABLE)
		return
	if(M.melee_damage_upper == 0)
		return
	M.do_attack_animation(src, M)
	src.health -= M.melee_damage_upper
	src.visible_message("<span class='danger'>[M] [M.attacktext] [src]!</span>")
	add_logs(M, src, "attacked", admin=0)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/machinery/bot/proc/declare() //Signals a medical or security HUD user to a relevant bot's activity.
	var/hud_user_list = list() //Determines which userlist to use.
	switch(bot_type) //Made into a switch so more HUDs can be added easily.
		if(SEC_BOT) //Securitrons and ED-209
			hud_user_list = sec_hud_users
		if(MED_BOT) //Medibots
			hud_user_list = med_hud_users
	var/area/myturf = get_turf(src)
	for(var/mob/huduser in hud_user_list)
		if(!huduser.loc)
			continue

		var/turf/mobturf = get_turf(huduser)
		if(mobturf.z == myturf.z)
			huduser.show_message(declare_message,1)


/obj/machinery/bot/attackby(obj/item/weapon/W, mob/living/user)
	if(flags & INVULNERABLE)
		return
	user.delayNextAttack(W.attack_delay)
	if((W.is_screwdriver(user) || iscrowbar(W)) && user.a_intent != I_HURT)
		if(locked)
			to_chat(user, "<span class='notice'>[src]'s maintenance panel is locked tight.</span>")
		else
			open = !open
			to_chat(user, "<span class='notice'>Maintenance panel is now [open ? "opened" : "closed"].</span>")
			updateUsrDialog()
	else if(iswelder(W) && user.a_intent != I_HURT)
		if(health < maxHealth)
			if(open)
				var/obj/item/tool/weldingtool/WT = W
				if(WT.remove_fuel(0))
					health = min(maxHealth, health+10)
					user.visible_message("<span class='danger'>[user] repairs [src]!</span>","<span class='notice'>You repair [src]!</span>")
			else
				to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
		else
			to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
	else if (emagged < 2)
		emag_check(W,user)
	else
		if(isobj(W))
			W.on_attack(src, user)
			visible_message("<span class='danger'>[src] has been hit by [user] with [W].</span>")
			switch(W.damtype)
				if("fire")
					src.health -= W.force * fire_dam_coeff
				if("brute")
					src.health -= W.force * brute_dam_coeff
			..()
			healthcheck()
			return W.force
		else
			..()

/obj/machinery/bot/kick_act(mob/living/H)
	..()

	if(flags & INVULNERABLE)
		return

	health -= rand(1,8) * brute_dam_coeff
	healthcheck()

/obj/machinery/bot/bullet_act(var/obj/item/projectile/Proj)
	if(flags & INVULNERABLE)
		return
	health -= Proj.damage
	. = ..()
	healthcheck()

/obj/machinery/bot/blob_act()
	if(flags & INVULNERABLE)
		return
	src.health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/machinery/bot/ex_act(severity)
	if(flags & INVULNERABLE)
		return
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= rand(5,10)*fire_dam_coeff
			src.health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				src.health -= rand(1,5)*fire_dam_coeff
				src.health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	for(var/mob/living/simple_animal/hostile/pulse_demon/PD in contents)
		PD.emp_act(severity) // Not inheriting so do it here too
	if(flags & INVULNERABLE)
		return
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		qdel(pulse2)
	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()



/obj/machinery/bot/cultify()
	if(src.flags & INVULNERABLE)
		return
	else
		qdel(src)

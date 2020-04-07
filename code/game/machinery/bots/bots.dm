// AI (i.e. game AI, not the AI player) controlled bots
#define BOT_PATROL 1
#define BOT_BEACON 2
#define BOT_CONTROL 4

#define SEC_BOT 1 // Secutritrons (Beepsky) and ED-209s
#define MULE_BOT 2 // MULEbots
#define FLOOR_BOT 3 // Floorbots
#define CLEAN_BOT 4 // Cleanbots
#define MED_BOT 5 // Medibots

#define BOT_OLDTARGET_FORGET_DEFAULT 100 //100*WaitMachinery

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	plane = MOB_PLANE
	luminosity = 3
	use_power = 0
	var/icon_initial //To get around all that pesky hardcoding of icon states, don't put modifiers on this one
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	var/bot_type
	var/declare_message = "" //What the bot will display to the HUD user.
	var/bot_flags

	var/frustration

	var/new_destination		// pending new destination (waiting for beacon response)
	var/destination			// destination description tag
	var/next_destination	// the next destination in the patrol route

	var/steps_per = 2 //How many steps we take per process

	var/atom/target 				//The target of our path, could be a turf, could be a person, could be mess
	var/list/old_targets = list()			//Our previous targets, so we don't get caught constantly going to the same spot. Order as pointer => int (Time to forget)
	var/list/path = list() //Our regular path

	var/beacon_freq = 1445		// navigation beacon frequency
	var/control_freq = 1447		// bot control frequency
	var/control_filter = RADIO_SECBOT

	var/awaiting_beacon //If we've sent out a signal to get a beacon
	var/nearest_beacon //What our nearest beacon is
	var/turf/nearest_beacon_loc //The turf of our nearest beacon

	var/type_for_sig = "secbot"
	var/turf/patrol_target	// this is turf to navigate to (location of beacon)
	var/auto_patrol = 0		// set to make bot automatically patrol
	var/waiting_for_patrol = FALSE
	var/list/patrol_path = list() //Our patroling path


/obj/machinery/bot/New()
	for(var/datum/event/ionstorm/I in events)
		if(istype(I) && I.active)
			I.bots += src
	bots_list += src
	if(radio_controller)
		if(bot_flags & BOT_CONTROL)
			radio_controller.add_object(src, control_freq, filter = control_filter)
		if(bot_flags & BOT_BEACON)
			radio_controller.add_object(src, beacon_freq, filter = RADIO_NAVBEACONS)
	..()

/obj/machinery/bot/Destroy()
	. = ..()
	if(botcard)
		qdel(botcard)
		botcard = null
	bots_list -= src
	nearest_beacon_loc = null
	patrol_target = null
	nearest_beacon = null
	patrol_path.Cut()
	path.Cut()

/obj/machinery/bot/process()
	if(!src.on)
		return
	process_pathing()
	process_bot()

/obj/machinery/bot/proc/find_target()

//Set time_to_forget to -1 to never forget it
/obj/machinery/bot/proc/add_oldtarget(var/old_target, var/time_to_forget = BOT_OLDTARGET_FORGET_DEFAULT)
	old_targets[old_target] = time_to_forget
	to_chat(world, "[old_target] = [old_targets[old_target]]")

/obj/machinery/bot/proc/remove_oldtarget(var/old_target)
	old_targets.Remove(old_target)

/obj/machinery/bot/proc/decay_oldtargets()
	for(var/i in old_targets)
		to_chat(world, "[i] [old_targets[i]]")
		if(--old_targets[i] == 0)
			remove_oldtarget(i)

//Regular path takes priority over the patrol path
/obj/machinery/bot/proc/process_pathing()
	if(!process_path() && (bot_flags & BOT_PATROL) && auto_patrol)
		process_patrol()

//misc stuff our bot may be doing (looking for people to heal, or hurt, or tile)
/obj/machinery/bot/proc/process_bot()

/*** Regular Pathing Section ***/
//If we don't have a path, we get a path
//If we have a path, we step
//return true to avoid calling process_patrol
/obj/machinery/bot/proc/process_path()
	set_glide_size(DELAY2GLIDESIZE((SS_WAIT_MACHINERY/steps_per)-1))
	var/turf/T = get_turf(src)
	for(var/i = 1 to steps_per)
		if(!path.len) //It is assumed we gain a path through process_bot()
			if(target)
				calc_path(target, .proc/get_path)
				return 1
			return 0
		patrol_path = list() //Kill any patrols we're using
		if(loc == get_turf(target))
			return at_path_target()

		var/turf/next = path[1]
		if(istype(next, /turf/simulated))
			step_to(src, next)
			if(get_turf(src) == next)
				frustration = 0
				path -= next
				if(on_path_step(next))
					return TRUE
			frustration++
			return on_path_step_fail(next)
		sleep((SS_WAIT_MACHINERY/steps_per)-1)
	return T == get_turf(src)

/obj/machinery/bot/proc/on_path_step(var/turf/next)

/obj/machinery/bot/proc/on_path_step_fail(var/turf/next)
	if(frustration > 5)
		calc_path(target, .proc/get_path, next)
	return TRUE

/obj/machinery/bot/proc/at_path_target()
	return TRUE

/*** Patrol Pathing Section ***/
//Same as process_path. If we don't have a path, we get a path.
//If we have a path, we take a step on that path
/obj/machinery/bot/proc/process_patrol()
	to_chat(world, "process patrol called [src] [patrol_path.len]")
	set_glide_size(DELAY2GLIDESIZE((SS_WAIT_MACHINERY/steps_per)-1))
	for(var/i = 1 to steps_per)
		if(!patrol_path.len)
			return find_patrol_path()
		to_chat(world, "Step [i] of [steps_per]")
		if(loc == patrol_target)
			patrol_path = list()
			return at_patrol_target()

		var/turf/next = patrol_path[1]
		if(istype(next, /turf/simulated))
			step_to(src, next)
			if(get_turf(src) == next)
				frustration = 0
				patrol_path -= next
				if(on_patrol_step(next))
					return TRUE
			frustration++
			on_patrol_step_fail(next)
		sleep((SS_WAIT_MACHINERY/steps_per)-1)
	return TRUE

/obj/machinery/bot/proc/find_patrol_path()
	if(waiting_for_patrol)
		return
	if(awaiting_beacon++)
		to_chat(world, "awaiting beacon:[awaiting_beacon]")
		if(awaiting_beacon > 5)
			awaiting_beacon = 0
			find_nearest_beacon()
		return
	if(next_destination)
		set_destination(next_destination)

	if(patrol_target)
		waiting_for_patrol = TRUE
		calc_path(patrol_target, .proc/get_patrol_path)

/obj/machinery/bot/proc/find_nearest_beacon()
	to_chat(world, "find_nearest_beacon called")
	if(awaiting_beacon)
		return
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

/obj/machinery/bot/proc/set_destination(var/new_dest)
	to_chat(world, "new_destination [new_dest]")
	new_destination = new_dest
	post_signal(beacon_freq, "findbeacon", "patrol")
	awaiting_beacon = 1

/obj/machinery/bot/proc/at_patrol_target()
	patrol_target = null
	find_patrol_path()

/obj/machinery/bot/proc/on_patrol_step(var/turf/next)

/obj/machinery/bot/proc/on_patrol_step_fail(next)
	if(frustration > 5)
		calc_path(patrol_target, .proc/get_patrol_path, next)


// send a radio signal with a single data key/value pair
/obj/machinery/bot/proc/post_signal(var/freq, var/key, var/value)
	post_signal_multiple(freq, list("[key]" = value) )

/obj/machinery/bot/proc/post_signal_multiple(var/freq, var/list/keyval)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(freq)

	if(!frequency)
		return

	var/datum/signal/signal = getFromPool(/datum/signal)
	signal.source = src
	signal.transmission_method = 1
	signal.data = keyval
	if(signal.data["findbeacon"])
		frequency.post_signal(src, signal, filter = RADIO_NAVBEACONS)
	else
		frequency.post_signal(src, signal)

/obj/machinery/bot/receive_signal(datum/signal/signal)
	// receive response from beacon
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return 0
	//to_chat(world, "recv:[recv]. valid:[valid]. new_destination:[new_destination]. nearest_beacon: [nearest_beacon]. Next Dest: [signal.data["next_patrol"]]")
	if(recv == new_destination)	// if the recvd beacon location matches the set destination, then we will navigate there
		to_chat(world, "new destination chosen")
		destination = new_destination
		patrol_target = signal.source.loc
		next_destination = signal.data["next_patrol"]
		awaiting_beacon = 0
		return 1
	// if looking for nearest beacon
	if(new_destination == "__nearest__")
		var/dist = get_dist(src,signal.source.loc)
		if(nearest_beacon)
			// note we ignore the beacon we are located at
			if(dist>1 && dist<get_dist(src, nearest_beacon_loc))
				to_chat(world, "replacing nearest_beacon [nearest_beacon] with [recv] as it is closer. [get_dist(src, nearest_beacon_loc)] [dist]")
				nearest_beacon = recv
				nearest_beacon_loc = signal.source.loc
			return
		else if(dist > 1) //We don't have a nearest beacon to compare to, so we're going to accept the first one we find that isn't on the same turf as us
			to_chat(world, "new nearest_beacon is [recv]")
			nearest_beacon = recv
			nearest_beacon_loc = signal.source.loc
		return 1

/obj/machinery/bot/proc/calc_path(var/target, var/proc_to_call, var/turf/avoid = null)
	ASSERT(target && proc_to_call)
	to_chat(world, "[new_destination]")
	return AStar(src, proc_to_call, src.loc, target, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, max(10,get_dist(src,target)*3), id=botcard, exclude=avoid)

/obj/machinery/bot/proc/get_path(var/list/L, var/target)
	if(islist(L))
		path = L
		return TRUE
	target = null
	add_oldtarget(target)
	return FALSE

/obj/machinery/bot/proc/get_patrol_path(var/list/L, var/target)
	waiting_for_patrol = FALSE
	if(islist(L))
		patrol_path = L
		return TRUE
	return FALSE

/obj/machinery/bot/proc/turn_on()
	if(stat)
		return 0
	on = 1
	set_light(initial(luminosity))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	set_light(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/proc/Emag(mob/user)
	if(locked)
		locked = 0
		emagged = 1
		if(user)
			to_chat(user, "<span class='warning'>You remove [src]'s control restrictions. Opening up its maintenance panel and swiping again will cause [src] to malfunction.</span>")
	if(!locked && open)
		emagged = 2
		if(user)
			to_chat(user, "<span class='warning'>You cause a malfunction in [src]'s behavioral matrix.</span>")

/obj/machinery/bot/npc_tamper_act(mob/living/L)
	if(on)
		turn_off()
	else
		turn_on()

/obj/machinery/bot/examine(mob/user)
	..()
	if (src.health < maxhealth)
		if (src.health > maxhealth/3)
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
		//new /obj/effect/decal/cleanable/blood/oil(src.loc)
		var/obj/effect/decal/cleanable/blood/oil/O = getFromPool(/obj/effect/decal/cleanable/blood/oil, src.loc)
		O.New(O.loc)
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
		//new /obj/effect/decal/cleanable/blood/oil(src.loc)
		var/obj/effect/decal/cleanable/blood/oil/O = getFromPool(/obj/effect/decal/cleanable/blood/oil, src.loc)
		O.New(O.loc)
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
		if(health < maxhealth)
			if(open)
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0))
					health = min(maxhealth, health+10)
					user.visible_message("<span class='danger'>[user] repairs [src]!</span>","<span class='notice'>You repair [src]!</span>")
			else
				to_chat(user, "<span class='notice'>Unable to repair with the maintenance panel closed.</span>")
		else
			to_chat(user, "<span class='notice'>[src] does not need a repair.</span>")
	else if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)
		Emag(user)
	else
		if(hasvar(W,"force") && hasvar(W,"damtype"))
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
	..()
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


/obj/machinery/bot/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	src.attack_hand(user)


/obj/machinery/bot/cultify()
	if(src.flags & INVULNERABLE)
		return
	else
		qdel(src)

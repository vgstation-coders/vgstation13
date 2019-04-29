/datum/tether
	var/atom/movable/master		//Used only to reference the actual, original master
	var/atom/movable/effective_master	//Used to reference either the actual master or its holder at turf level
	var/atom/movable/slave		//Used only to reference the actual, original slave
	var/atom/movable/effective_slave	//Used to reference either the actual slave or its holder at turf level
	var/event_key_master
	var/event_key_effective_master	//Used only on holders of the master, never the master itself
	var/event_key_slave
	var/event_key_effective_slave	//Used only on holders of the slave, never the slave itself
	var/tether_distance			//On a master-slave tether, how far apart the two can be before the slave is either prohibited from moving or pulled by the master.
								//On an equal tether, how far apart the two can be before whichever one that moves pulls the other.
/datum/tether/proc/break_tether()
	master.on_tether_broken(slave)
	slave.on_tether_broken(master)
	qdel(src)

/datum/tether/proc/make_tether(atom/movable/M, atom/movable/S, var/distance)
	tether_distance = distance
	master = M
	effective_master = master
	slave = S
	effective_slave = slave
	event_key_master = master.on_moved.Add(src, "master_moved")
	event_key_slave = slave.on_moved.Add(src, "slave_moved")
	if(!master.current_tethers)
		master.current_tethers = list()
	master.current_tethers.Add(src)
	if(!slave.current_tethers)
		slave.current_tethers = list()
	slave.current_tethers.Add(src)

/datum/tether/Destroy()
	if(effective_master != master)
		effective_master.on_moved.Remove(event_key_effective_master)
		effective_master.current_tethers.Remove(src)
		effective_master = null
		event_key_effective_master = null
	master.on_moved.Remove(event_key_master)
	master.current_tethers.Remove(src)
	master = null
	event_key_master = null
	if(effective_slave != slave)
		effective_slave.on_moved.Remove(event_key_effective_slave)
		effective_slave.current_tethers.Remove(src)
		effective_slave = null
		event_key_effective_slave = null
	slave.on_moved.Remove(event_key_slave)
	slave.current_tethers.Remove(src)
	slave = null
	event_key_slave = null
	..()

/datum/tether/proc/check_distance()
	if(get_exact_dist(effective_master, effective_slave) > tether_distance)
		return 0
	return 1

/datum/tether/proc/check_breakage_distance()
	if(get_exact_dist(effective_master, effective_slave) > tether_distance+5)	//A small buffer is added to account for the master moving before the slave catches up and such.
		return 0
	return 1

/datum/tether/proc/master_moved()
	if(effective_master != master)
		if(!isturf(effective_master.loc) || isturf(master.loc))
			effective_master.on_moved.Remove(event_key_effective_master)
			effective_master.current_tethers.Remove(src)
			effective_master = master
	if(!isturf(master.loc) && effective_master == master)
		effective_master = get_holder_at_turf_level(master)
		event_key_effective_master = effective_master.on_moved.Add(src, "master_moved")
		if(!effective_master.current_tethers)
			effective_master.current_tethers = list()
		effective_master.current_tethers.Add(src)
	if(!check_breakage_distance())
		break_tether()

	rein_in_slave()

/datum/tether/proc/slave_moved()
	if(effective_slave != slave)
		if(!isturf(effective_slave.loc) || isturf(slave.loc))
			effective_slave.on_moved.Remove(event_key_effective_slave)
			effective_slave.current_tethers.Remove(src)
			effective_slave = slave
	if(!isturf(slave.loc) && effective_slave == slave)
		effective_slave = get_holder_at_turf_level(slave)
		event_key_effective_slave = effective_slave.on_moved.Add(src, "slave_moved")
		if(!effective_slave.current_tethers)
			effective_slave.current_tethers = list()
		effective_slave.current_tethers.Add(src)
	if(!check_breakage_distance())
		break_tether()

/datum/tether/proc/rein_in_slave()
	while(!check_distance())
		if(!step_to(effective_slave,effective_master))
			break_tether()
			break

/datum/tether/master_slave/make_tether(atom/movable/M, atom/movable/S, var/distance)	//With a master-slave tether, the slave is incapable of moving or being moved farther from its master than the tether allows.
	S.tether_master = M																	//If its master moves out of range, the slave is pulled along.
	if(!M.tether_slaves)
		M.tether_slaves = list()
	M.tether_slaves.Add(S)
	..()

/datum/tether/master_slave/Destroy()
	slave.tether_master = null
	master.tether_slaves.Remove(slave)
	..()

/datum/tether/equal/make_tether(atom/movable/M, atom/movable/S, var/distance)	//An equal tether functions like a master-slave tether, however both the master and slave are capable of pulling each other.
	M.tether_master = S
	S.tether_master = M
	..()

/datum/tether/equal/slave_moved()
	..()
	rein_in_master()

/datum/tether/equal/proc/rein_in_master()
	while(!check_distance())
		if(!step_to(effective_master,effective_slave))
			break_tether()
			break

/datum/tether/equal/Destroy()
	master.tether_master = null
	slave.tether_master = null
	..()

/datum/tether/equal/restrictive	//A restrictive equal tether disallows pulling from either side. If either the master or slave attempts to exceed the tether's distance, they simply fail.

proc/tether_equal(atom/movable/first, atom/movable/second, var/distance, var/restrictive = FALSE)
	if(!istype(first) || !istype(second) || !distance)
		return FALSE
	if(first.tether_master || second.tether_master)	//an atom can only have a single master or equal tether
		return FALSE
	var/datum/tether/equal/E
	if(restrictive)
		E = new /datum/tether/equal/restrictive()
	else
		E = new()
	E.make_tether(first,second,distance)
	return TRUE

proc/tether_equal_restrictive(atom/movable/first, atom/movable/second, var/distance)
	return tether_equal(first, second, distance, TRUE)

proc/tether_master_slave(atom/movable/M, atom/movable/S, var/distance)
	if(!istype(M) || !istype(S) || !distance)
		return FALSE
	if(S.tether_master)	//an atom can only have a single master or equal tether
		return FALSE
	var/datum/tether/master_slave/T = new()
	T.make_tether(M,S,distance)
	return TRUE

//Uncomment for easy testing of tethers.
/*
/obj/item/tether_maker
	name = "tether maker"
	icon_state = "spacecash20"
	var/mode = 0

/obj/item/tether_maker/attack_self(mob/user)
	mode++
	if(mode > 4)
		mode = 0
	if(mode == 0)
		to_chat(user, "Will now break tethers.")
	if(mode == 1)
		to_chat(user, "Will now create equal tethers.")
	if(mode == 2)
		to_chat(user, "Will now create restrictive equal tethers.")
	if(mode == 3)
		to_chat(user, "Will now create master-slave tethers.")
	if(mode == 4)
		to_chat(user, "Will now create slave-master tethers.")

/obj/item/tether_maker/afterattack(atom/movable/A, mob/living/user)
	if(!istype(A))
		return
	if(mode == 0)
		A.break_all_tethers()
		to_chat(user, "All \the [A]'s tethers are now broken.")
	if(mode == 1)
		tether_equal(user, A, 7)
		to_chat(user, "You and \the [A] are now tethered.")
	if(mode == 2)
		tether_equal_restrictive(user, A, 7)
		to_chat(user, "You and \the [A] are now restrictively tethered.")
	if(mode == 3)
		tether_master_slave(user, A, 7)
		to_chat(user, "\The [A] is now tethered to you.")
	if(mode == 4)
		tether_master_slave(A, user, 7)
		to_chat(user, "You are now tethered to \the [A].")
*/

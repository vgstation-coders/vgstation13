/spell/targeted/push
	name = "Dimensional Push"
	desc = "This spell takes the thing you're touching, and pushes it somewhere else."
	abbreviation = "DP"
	user_type = USER_TYPE_WIZARD
	specialization = SSOFFENSIVE

	school = "evocation"
	charge_max = 300
	spell_flags = Z2NOCAST | WAIT_FOR_CLICK
	invocation = "P'SH IT RE'L GUD"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 10
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 4)
	sparks_spread = 1
	sparks_amt = 4

	hud_state = "wiz_push"

/spell/targeted/push/before_cast(list/targets, user, bypass_range = 0)
	var/list/valid_targets = list()
	var/list/options = ..()
	for(var/atom/movable/target in options)
		if(target == holder.locked_to)
			to_chat(holder, "<span class='warning'>You can't push something away if you're attached to it.</span>")
			valid_targets = list()
			break
		valid_targets += target
	if(!holder.z)
		to_chat(holder, "<span class='warning'>You can't seem to get enough leverage for a push from here.</span>")
		valid_targets = list()
	return valid_targets

/spell/targeted/push/cast(var/list/targets)
	..()
	for(var/atom/movable/target in targets)
		if(target.dimensional_push(holder))
			score.dimensionalpushes++

/spell/targeted/push/get_upgrade_price(upgrade_type)
	return price / 2

/atom/movable/proc/dimensional_push(var/mob/user)
	. = 0
	var/area/thearea
	var/list/areas_to_check = areas.Copy() //Should gradually narrow down the list of areas to get to all the good areas
	var/area/prospective
	while(!thearea)
		if(!areas_to_check.len) //If everything fails, don't crash the server
			to_chat(user, "The spell matrix was unable to locate a suitable area for an unknown reason. Sorry.")
			return
		prospective = pick(areas_to_check)
		if(prospective.type != /area)
			var/list/prospective_turfs = get_area_turfs(prospective.type)
			if(!prospective_turfs.len) //An in-game area somehow lost its turfs, search for another one
				areas_to_check -= prospective
				continue
			var/turf/T = pick(prospective_turfs)
			if(T.z != src.z) //Selected turf is not in the same z-level
				areas_to_check -= prospective
				continue
			thearea = prospective //We found it
			break
		else //We selected space, don't do this
			areas_to_check -= prospective
			continue
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && T.z != src.z) //In case an area somehow shows up in multiple z-levels
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		if(user)
			to_chat(user, "The spell matrix was unable to locate a suitable destination for an unknown reason. Sorry.")
		return 0

	var/list/backup_L = L.Copy()
	unlock_from()
	var/attempt = null
	var/success = 0
	while(L.len)
		attempt = pick(L)
		success = Move(attempt)
		if(!success)
			L.Remove(attempt)
		else
			score.dimensionalpushes++
			break
	if(!success)
		L.Remove(attempt)
	else
		return 1
	if(!success)
		forceMove(pick(backup_L))
	return 0
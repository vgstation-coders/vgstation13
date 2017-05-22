/spell/targeted/push
	name = "Dimensional Push"
	desc = "This spell takes the thing you're touching, and pushes it somewhere else."
	abbreviation = "DP"

	school = "evocation"
	charge_max = 300
	spell_flags = WAIT_FOR_CLICK
	invocation = "P'SH IT RE'L GUD"
	invocation_type = SpI_SHOUT
	range = 1
	cooldown_min = 10
	level_max = list(Sp_TOTAL = 4, Sp_SPEED = 4)
	sparks_spread = 1
	sparks_amt = 4

	hud_state = "wiz_push"

/spell/targeted/push/before_cast(list/targets, user)
	var/list/valid_targets = list()
	var/list/options = ..()
	for(var/atom/movable/target in options)
		valid_targets += target
	return valid_targets

/spell/targeted/push/cast(var/list/targets)
	..()
	var/area/thearea
	var/area/prospective = pick(areas)
	while(!thearea)
		if(prospective.type != /area)
			var/turf/T = pick(get_area_turfs(prospective.type))
			if(T.z == holder.z)
				thearea = prospective
				break
		prospective = pick(areas)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L+=T
	if(!L.len)
		to_chat(holder, "The spell matrix was unable to locate a suitable destination for an unknown reason. Sorry.")
		return

	for(var/atom/movable/target in targets)
		target.unlock_from()
		var/attempt = null
		var/success = 0
		while(L.len)
			attempt = pick(L)
			success = target.Move(attempt)
			if(!success)
				L.Remove(attempt)
			else
				break
		if(!success)
			target.forceMove(pick(L))

/spell/targeted/push/get_upgrade_price(upgrade_type)
	return price / 2
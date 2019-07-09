/spell/targeted/push
	name = "Dimensional Push"
	desc = "This spell takes the thing you're touching, and pushes it somewhere else."
	abbreviation = "DP"
	user_type = USER_TYPE_WIZARD
	specialization = OFFENSIVE

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

/spell/targeted/push/before_cast(list/targets, user)
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

	var/list/backup_L = L
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
				score["dimensionalpushes"]++
				break
		if(!success)
			target.forceMove(pick(backup_L))

/spell/targeted/push/get_upgrade_price(upgrade_type)
	return price / 2

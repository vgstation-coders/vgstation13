/spell/aoe_turf/conjure/bats
	name = "Bats (50)"
	desc = "You summon a trio of space bats who attack nearby targets until they or their target is dead. (50)"
	user_type = USER_TYPE_VAMPIRE

	summon_type = list(/mob/living/simple_animal/hostile/scarybat)
	summon_amt = 3

	charge_max = 2 MINUTES
	cooldown_min = 2 MINUTES
	invocation = ""
	invocation_type = SpI_NONE
	
	override_base = "vamp"

	hud_state = "vampire_bats"

	var/blood_cost = 50

/spell/aoe_turf/conjure/bats/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.)
		to_chat(world, "failed super()")
	if (!user.vampire_power(blood_cost, 0))
		to_chat(world, "failed vampire_power")
		return FALSE

/spell/aoe_turf/conjure/bats/choose_targets(var/mob/user = usr)
	
	var/list/turf/locs = new

	to_chat(world, "Choosing targets")

	for(var/direction in alldirs) //looking for bat spawns
		if(locs.len >= 3) //we found 3 locations and thats all we need
			break
		var/turf/T = get_step(user, direction) //getting a loc in that direction
		if(AStar(user.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1)) // if a path exists, so no dense objects in the way its valid salid
			locs += T
	
	if(locs.len < 3) //if we only found one location, spawn more on top of our tile so we dont get stacked bats
		locs += user.loc
	
	if (!locs)
		to_chat(world, "no locs")

	return locs
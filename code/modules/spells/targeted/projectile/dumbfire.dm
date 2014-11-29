/atom/movable/spell/targeted/projectile/dumbfire
	name = "dumbfire spell"

/atom/movable/spell/targeted/projectile/dumbfire/choose_targets(mob/user = usr)
	var/list/targets = list()

	var/starting_dir = user.dir //where are we facing at the time of casting?
	var/turf/starting_turf = get_turf(user)
	var/current_turf = starting_turf
	for(var/i = 1; i <= src.range; i++)
		current_turf = get_step(current_turf, starting_dir)

	var/atom/movable/AM = new(current_turf)
	targets += get_turf(AM)
	qdel(AM)
	return targets
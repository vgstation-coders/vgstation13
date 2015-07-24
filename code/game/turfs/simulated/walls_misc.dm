/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"

/turf/simulated/wall/cult/cultify()
	return

/turf/simulated/wall/cult/attack_construct(mob/user as mob)
	if(istype(user,/mob/living/simple_animal/construct/builder) && user.Adjacent(src, MAX_ITEM_DEPTH))
		dismantle_wall(1)
		return 1
	return 0

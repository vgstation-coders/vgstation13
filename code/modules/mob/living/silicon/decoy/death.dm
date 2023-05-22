/mob/living/silicon/decoy/death(gibbed)
	if((status_flags & BUDDHAMODE) || stat == DEAD)
		return
	stat = DEAD
	icon_state = "ai-crash"
	spawn(10)
		explosion(loc, 3, 6, 12, 15, whodunnit = src)
		gib()

	return ..(gibbed)

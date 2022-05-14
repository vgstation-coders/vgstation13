/spell/aoe_turf/necro/zombie/evolve
	desc = "Decay further into undead"
	user_type = USER_TYPE_ZOMBIE
	insufficient_holder_msg = "<span class='notice'>You are not dead enough.</span>"

	holder_var_type = "death"


/spell/aoe_turf/necro/zombie/evolve/cast_check(skipcharge = FALSE, mob/living/simple_animal/hostile/necro/zombie/user)
	. = ..()
	if (!.)
		return FALSE
	if(!user.can_evolve)
		to_chat(insufficient_holder_msg)
		return
	return ..()

/spell/aoe_turf/necro/zombie/evolve/cast(list/targets, mob/living/simple_animal/hostile/necro/zombie/user)
	user.check_evolve()
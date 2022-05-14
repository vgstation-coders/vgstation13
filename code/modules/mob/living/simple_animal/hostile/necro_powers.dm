/spell/aoe_turf/necro/zombie/evolve
	name = "Evolve"
	desc = "Decay further into undead"
	user_type = USER_TYPE_ZOMBIE
	insufficient_holder_msg = "<span class='notice'>You are not dead enough.</span>"
	charge_max = 0

	holder_var_type = "death"
	overlay_icon = 'icons/mob/hud.dmi'
	//override_base = "zombie"
	//overlay_icon_state = "hudundead"
	hud_state = "hudundead"

/spell/aoe_turf/necro/zombie/evolve/cast_check(skipcharge = FALSE, mob/living/simple_animal/hostile/necro/zombie/user)
	. = ..()
	if (!.)
		return FALSE
	if(!user.can_evolve)
		return
	return ..()

/spell/aoe_turf/necro/zombie/evolve/cast(list/targets, mob/living/simple_animal/hostile/necro/zombie/user)
	user.check_evolve()
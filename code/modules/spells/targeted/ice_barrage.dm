/spell/targeted/ice_barrage
	name = "Ice Barrage"
	desc = "Freezes the target in a block of ice. Also inflicts psychological damage."
	user_type = USER_TYPE_ARTIFACT

	school = "abjuration"
	charge_max = 300
	spell_flags = NEEDSCLOTHES | WAIT_FOR_CLICK
	range = 7
	max_targets = 1

	amt_stunned = 5
	cooldown_min = 30

	hud_state = "ice_barrage"

/spell/targeted/ice_barrage/cast(var/list/targets, mob/user)
	..()
	for(var/mob/living/L in targets)
		playsound(L, 'sound/effects/ice_barrage.ogg', 50, 100, extrarange = 3, gas_modified = 0)
		new /obj/structure/ice_block(L.loc, L, 10 SECONDS)
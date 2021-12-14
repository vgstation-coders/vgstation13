
/spell/targeted/genetic/invert_eyes
	name = "Invert eyesight"
	desc = "Inverts the colour spectrum you see, letting you see clearly in the dark, but not in the light."
	panel = "Mutant Powers"
	user_type = USER_TYPE_GENETIC
	range = SELFCAST

	charge_type = Sp_RECHARGE

	spell_flags = INCLUDEUSER

	invocation_type = SpI_NONE

	override_base = "genetic"
	hud_state = "wiz_sleepold"


/spell/targeted/genetic/invert_eyes/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/M in targets)
		var/datum/organ/internal/eyes/mushroom/E = M.internal_organs_by_name["eyes"]
		if(istype(E))
			E.dark_mode = !E.dark_mode

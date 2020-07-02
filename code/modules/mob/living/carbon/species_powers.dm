#define INVERT_ANIM_TIME 50

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
	var/toggle = TRUE


/spell/targeted/genetic/invert_eyes/cast(list/targets, mob/user)
	var/list/colourmatrix = list()
	if(toggle)
		colourmatrix = list(-1, 0, 0,
						 0,-1, 0,
						 0, 0,-1,
						 1, 1, 1)
	else
		colourmatrix = default_colour_matrix
	for(var/mob/living/carbon/human/M in targets)
		M.update_colour(INVERT_ANIM_TIME, colourmatrix)
	toggle = !toggle
#undef INVERT_ANIM_TIME

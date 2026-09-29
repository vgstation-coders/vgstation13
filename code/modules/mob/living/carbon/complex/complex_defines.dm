/mob/living/carbon/complex
	var/icon_state_standing
	var/icon_state_lying
	var/icon_state_dead
	var/flag = 0
	base_insulation = 0.5

/mob/living/carbon/complex/New()
	create_reagents(200)
	..()

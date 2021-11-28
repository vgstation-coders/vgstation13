//there is no real system for hyperthermia and I don't have any plans to make one, this is just a stub so I can check if someone is too hot from /mob/living/, might be better placed in handle_hypothermia or something
/mob/living/proc/undergoing_hyperthermia()
	return FALSE
/mob/living/carbon/human/undergoing_hyperthermia()
	return bodytemperature > species.heat_level_1

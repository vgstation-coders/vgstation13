/mob/living/carbon/human/tajaran/New(var/new_loc)
	h_style = "Tajaran Ears"
	..(new_loc, "Tajaran")
	add_language(LANGUAGE_MOUSE)

/mob/living/carbon/human/tajaran/IsAdvancedToolUser()
	return 0

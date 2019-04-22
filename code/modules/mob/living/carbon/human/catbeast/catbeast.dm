/mob/living/carbon/human/tajaran/New(var/new_loc)
	my_appearance.h_style = "Tajaran Ears"
	..(new_loc, "Tajaran")

/mob/living/carbon/human/tajaran/IsAdvancedToolUser()
	return 0

/mob/living/carbon/human/tajaran/New(var/new_loc)
	..(new_loc, "Tajaran")
	my_appearance.h_style = "Tajaran Ears"
	regenerate_icons()

/mob/living/carbon/human/tajaran/IsAdvancedToolUser()
	return 0

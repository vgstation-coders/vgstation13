/mob/living/carbon/martian/Life()
	set invisibility = 0

	if(timestopped)
		return 0 //under effects of time magick

	..()

	var/datum/gas_mixture/environment // Added to prevent null location errors-- TLE
	if(loc)
		environment = loc.return_air()

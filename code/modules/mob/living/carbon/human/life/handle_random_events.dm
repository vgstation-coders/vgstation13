//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_random_events()
	//Puke if toxloss is too high
	if(!stat)
		if(getToxLoss() >= 45 && nutrition > 20)
			vomit()

		//No hair for radroaches
		if((radiation >= 50) && !(species.anatomy_flags & NO_BALD))
			var/update_needed = FALSE
			if(my_appearance.h_style != "Bald")
				my_appearance.h_style = "Bald"
				update_needed = TRUE
			if(my_appearance.f_style != "Shaved")
				my_appearance.f_style = "Shaved"
				update_needed = TRUE
			if(update_needed)
				update_hair()

	//0.1% chance of playing a scary sound to someone who's in complete darkness
	if(isturf(loc) && rand(1,1000) == 1)
		var/turf/T = get_turf(src)
		if(!T.get_lumcount())
			playsound_local(src,pick(scarySounds), 50, 1, -1)

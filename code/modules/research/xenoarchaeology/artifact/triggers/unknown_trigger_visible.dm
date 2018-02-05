/datum/artifact_trigger/notvisible
	triggertype = TRIGGER_NOT_VISIBLE
	scanned_trigger = SCAN_OCULAR
	var/visible = 0
	var/dir_trigger = 0

/datum/artifact_trigger/notvisible/New()
	..()
	dir_trigger = prob(40)

/datum/artifact_trigger/notvisible/CheckTrigger()

	visible = FALSE
	for (var/mob/living/M in viewers(my_artifact))
		if(!M.isUnconscious() && !is_blind(M))
			if(dir_trigger && (M.dir == get_cardinal_dir(M, my_artifact)))
				visible = TRUE
			else if(!dir_trigger)
				visible = TRUE
			break

	if(!my_effect.activated && !visible)
		Triggered(0, "NOTVISIBLE", 0)
	else if(my_effect.activated && visible)
		Triggered(0, "VISIBLE", 0)


/datum/artifact_trigger/notvisible/Destroy()
	..()
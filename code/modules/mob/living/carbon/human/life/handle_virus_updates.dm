//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_virus_updates()
	if(status_flags & GODMODE)
		return 0 //Godmode

	src.find_nearby_disease()

	if (virus2.len)
		var/active_disease = pick(virus2)//only one disease will activate its effects at a time.
		for(var/ID in virus2)
			var/datum/disease2/disease/V = virus2[ID]
			if(istype(V))
				V.activate(src, active_disease != ID)


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

				if (prob(radiation))//radiation turns your body into an inefficient pathogenic incubator.
					V.incubate(src,rad_tick/10)
					//effect mutations won't occur unless the mob also has ingested mutagen
					//and even if they occur, the new effect will have a badness similar to the old one, so helpful pathogen won't instantly become deadly ones.


/datum/disease/japanesefever
	name = "Japanese Fever"
	max_stages = 5
	spread = "On contact"
	spread_type = CONTACT_GENERAL
	cure = "Flushing the body with the most powerful cleaning solvent."
	cure_id = BLEACH
	agent = "Unknown"
	affected_species = list("Human")
	permeability_mod = 1

/datum/disease/japanesefever/stage_act()
	..()
	switch(stage)
		if(1)
			if(affected_mob.ckey == "rosham")
				src.cure()
		if(2)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(45))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
			if(prob(1))
				to_chat(affected_mob, "<span class='warning'>You feel strange...</span>")
		if(3)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(5))
				to_chat(affected_mob, "<span class='warning'>You feel the urge to dance...</span>")
			else if(prob(5))
				affected_mob.emote("gasp", null, null, TRUE)
			else if(prob(10))
				to_chat(affected_mob, "<span class='warning'>You feel the need to chick chicky boom...</span>")
		if(4)
			if(affected_mob.ckey == "rosham")
				src.cure()
			if(prob(10))
				affected_mob.emote("gasp", null, null, TRUE)
				to_chat(affected_mob, "<span class='warning'>You feel a burning beat inside...</span>")
			if(prob(20))
				affected_mob.adjustToxLoss(5)
				affected_mob.updatehealth()
		if(5)
			if(affected_mob.ckey == "rosham")
				src.cure()
			to_chat(affected_mob, "<span class='warning'>Your body is unable to contain the Rhumba Beat...</span>")
			if(prob(50))
				affected_mob.gib()
		else
<<<<<<< HEAD
			return
=======
			return 
>>>>>>> glasseclipse-temp

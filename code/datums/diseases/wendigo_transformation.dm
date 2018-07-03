/datum/disease/wendigo_transformation
	name = "Unknown"
	max_stages = 5
	spread = "Unknown"
	spread_type = SPECIAL
	curable = 0
	agent = "Unknown"
	affected_species = list("Human")

/datum/disease/wendigo_transformation/stage_act()
	..()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		switch(stage)
			if(2)
				if (prob(8))
					to_chat(H, "<span class = 'warning'>Your stomach grumbles.</span>")
				if (prob(8))
					to_chat(H, "<span class = 'notice'>You feel peckish.</span>")
			if(3)
				if(prob(12))
					to_chat(H, "<span class = 'warning'>So hungry.</span>")
					H.burn_calories(20)
				if(prob(7))
					to_chat(H, "<span class = 'notice'>Your stomach feels empty.</span>")
					H.vomit()
			if(4)
				if(prob(25))
					to_chat(H, "<span class = 'warning'>Hunger...</span>")
					H.burn_calories(100)
				if(prob(15))
					to_chat(H, "<span class = 'warning'>Who are we?</span>")
					H.hallucination += 10
			if(5)
				if(prob(50))
					to_chat(H, "<span class = 'warning'>Our mind hurts.</span>")
					H.adjustBrainLoss(25)
					H.hallucination += 20
				if(prob(15))
					var/mob/living/simple_animal/hostile/wendigo/human/W = new/mob/living/simple_animal/hostile/wendigo/human(H.loc)
					W.names += H.real_name
					H.drop_all()
					qdel(H)
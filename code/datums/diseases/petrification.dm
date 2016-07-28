/datum/disease/petrification
	name = "Rapid Petrification"
	desc = "An extremely dangerous virus which rapidly spreads through any living tissue. A few seconds after initial contact, it starts petrifying the victim, turning their skin, muscle and organs into stone."
	max_stages = 4
	spread = "Non contagious"
	spread_type = NON_CONTAGIOUS
	cure = "Unknown"
	cure_list = list(SACID, PACID, ACIDSPIT, ACIDTEA) //ssh don't spoil
	cure_chance = 40
	agent = "rapid petrification virus 11Y-ASD"
	longevity = 1

	stage_prob = 100 //Advance to next stage every tick

/datum/disease/petrification/stage_act()
	..()
	if(!affected_mob)
		return cure()

	switch(stage)
		if(2)
			var/mob/living/carbon/human/H = affected_mob
			//Second message is shown to hallucinating mobs
			H.simple_message("<span class='userdanger'>You are slowing down. Moving is extremely painful to you.</span>",\
			"<span class='danger'>You feel like Michelangelo di Lodovico Buonarroti Simoni trapped in \a [istype(H) ? "[H.species.name]" : "foreign"] body.</span>")
			H.shock_stage = 300
			H.Stun(5)
		if(3)
			affected_mob.simple_message("<span class='userdanger'>Your skin starts losing color and cracking. Your body becomes numb.</span>",\
			"<span class='danger'>You decide to channel your inner Italian sculptor to create a beautiful statue.</span>")
		if(4)
			if(affected_mob.turn_into_statue(1))
				affected_mob.simple_message("<span class='userdanger'>Your body turns to stone.</span>",\
				"<span class='danger'>You've created a masterwork statue of David!</span>")

			cure(bad = 1)

/datum/disease/petrification/cure(bad = 0)
	if(!bad && affected_mob)
		affected_mob.simple_message("<span class='info'>Somehow, you feel better.</span>",\
		"<span class='userdanger'>You feel like a total failure.</span>")

	..(0) //Don't develop resistance!

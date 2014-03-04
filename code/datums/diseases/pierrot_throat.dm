/datum/disease/pierrot_throat
	name = "Pierrot's Throat"
	max_stages = 4
	spread = "Airborne"
	cure = "A whole banana."
	cure_id = "banana"
	cure_chance = 75
	curable=1
	agent = "H0NI<42 Virus"
	affected_species = list("Human")
	permeability_mod = 0.75
	desc = "If left untreated the subject will probably drive others to insanity."
	severity = "Medium"
	longevity = 400

/datum/disease/pierrot_throat/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10)) affected_mob << "<span class=\"rose\">You feel a little silly.</span>"
		if(2)
			if(prob(10)) affected_mob << "<span class=\"rose\">You start seeing rainbows.</span>"
		if(3)
			if(prob(10)) affected_mob << "<span class=\"rose\">Your thoughts are interrupted by a loud <span class=\"danger\">HONK!</span></span>"
		if(4)
			if(prob(5)) affected_mob.say( pick( list("HONK!", "Honk!", "Honk.", "Honk?", "Honk!!", "Honk?!", "Honk...") ) )
/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel" //The alien sentinel, not Alien Sentinel
	caste = "s"
	maxHealth = 175
	health = 125
	phoron = 100
	max_phoron = 250
	icon_state = "aliens_s"
	phoron_rate = 10

//As far as movement goes, Sentinels are average

/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]

/mob/living/carbon/alien/humanoid/sentinel/add_spells_and_verbs()
	..()
	add_spell(new /spell/targeted/projectile/alienneurotoxin, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/alienacid, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)

/mob/living/carbon/alien/humanoid/sentinel


	handle_regular_hud_updates()

		..() //-Yvarov

		if(healths)
			if(stat != 2)
				switch(health)
					if(175 to INFINITY)
						healths.icon_state = "health0"
					if(125 to 175)
						healths.icon_state = "health1"
					if(75 to 125)
						healths.icon_state = "health2"
					if(25 to 75)
						healths.icon_state = "health3"
					if(0 to 25)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"

/mob/living/carbon/alien/humanoid/drone
	name = "alien drone" //The alien drone, not Alien Drone
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"
	plasma_rate = 15

/mob/living/carbon/alien/humanoid/drone/movement_delay()
	var/tally = 2 + move_delay_add + config.alien_delay //Drones are slow

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

	return tally

/mob/living/carbon/alien/humanoid/drone/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]

/mob/living/carbon/alien/humanoid/drone/add_spells_and_verbs()
	..()
	add_spell(new /spell/aoe_turf/conjure/choice/alienresin, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/alienacid, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/evolve/drone, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)

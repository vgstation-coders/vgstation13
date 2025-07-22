/mob/living/carbon/alien/humanoid/drone
	name = "alien drone" //The alien drone, not Alien Drone
	caste = "d"
	maxHealth = 100
	health = 100
	icon_state = "aliend_s"
	plasma_rate = 15

/mob/living/carbon/alien/humanoid/drone/movement_tally_multiplier()
	. = ..()
	. *= 2 // Drones are slow

/mob/living/carbon/alien/humanoid/drone/New()
	create_reagents(100)
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	..()

/mob/living/carbon/alien/humanoid/drone/add_spells_and_verbs()
	..()
	add_spell(new /spell/aoe_turf/conjure/choice/alienresin, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/corrosive_acid, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/evolve/drone, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)

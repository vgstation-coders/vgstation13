/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel" //The alien sentinel, not Alien Sentinel
	caste = "s"
	maxHealth = 175
	health = 125
	plasma = 100
	max_plasma = 250
	icon_state = "aliens_s"
	plasma_rate = 10

//As far as movement goes, Sentinels are average

/mob/living/carbon/alien/humanoid/sentinel/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	..()

/mob/living/carbon/alien/humanoid/sentinel/add_spells_and_verbs()
	..()
	add_spell(new /spell/targeted/projectile/alienneurotoxin, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/corrosive_acid, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
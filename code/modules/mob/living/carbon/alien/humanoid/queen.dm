/mob/living/carbon/alien/humanoid/queen
	name = "alien queen" //The alien queen, not Alien Queen. Even if there's only one at a time
	caste = "q"
	maxHealth = 300
	health = 300
	icon_state = "alienq_s"
	status_flags = CANPARALYSE
	heal_rate = 5
	plasma_rate = 20

/mob/living/carbon/alien/humanoid/queen/movement_delay()
	var/tally = 5 + move_delay_add + config.alien_delay //Queens are slow as fuck

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

	return tally

/mob/living/carbon/alien/humanoid/queen/New()
	create_reagents(100)

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)
			continue
		if(Q.stat == DEAD)
			continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]

/mob/living/carbon/alien/humanoid/queen/add_spells_and_verbs()
	..()
	add_spell(new /spell/aoe_turf/conjure/alienegg, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/alienacid, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/targeted/projectile/alienneurotoxin, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/conjure/choice/alienresin, "alien_spell_ready", /obj/screen/movable/spell_master/alien)
	verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid)

/mob/living/carbon/alien/humanoid/queen

	handle_regular_hud_updates()

		..() //-Yvarov

		if(src.healths)
			if(src.stat != 2)
				switch(health)
					if(300 to INFINITY)
						src.healths.icon_state = "health0"
					if(200 to 300)
						src.healths.icon_state = "health1"
					if(125 to 200)
						src.healths.icon_state = "health2"
					if(75 to 125)
						src.healths.icon_state = "health3"
					if(0 to 75)
						src.healths.icon_state = "health4"
					else
						src.healths.icon_state = "health5"
			else
				src.healths.icon_state = "health6"

/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/giantmobs.dmi'
	icon_state = "queen_s"
	pixel_x = -16 * PIXEL_MULTIPLIER

/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.len = 0
	if(lying)
		if(resting)
			icon_state = "queen_sleep"
		else						icon_state = "queen_l"
		for(var/image/I in overlays_lying)
			overlays += I
	else
		icon_state = "queen_s"
		for(var/image/I in overlays_standing)
			overlays += I
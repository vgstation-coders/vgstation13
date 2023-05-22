/mob/living/carbon/alien/humanoid/queen
	name = "alien queen" //The alien queen, not Alien Queen. Even if there's only one at a time
	caste = "q"
	maxHealth = 300
	health = 300
	icon_state = "alienq_s"
	status_flags = CANPARALYSE|UNPACIFIABLE
	heal_rate = 5
	plasma_rate = 20

/mob/living/carbon/alien/humanoid/queen/movement_tally_multiplier()
	. = ..()
	. *= 5 // Queens are slow as fuck

/mob/living/carbon/alien/humanoid/queen/feels_pain()
	return FALSE // Queens are slow enough as they are

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

/mob/living/carbon/alien/humanoid/queen/add_spells_and_verbs()
	..()
	add_spell(new /spell/aoe_turf/conjure/alienegg, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/corrosive_acid, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/targeted/projectile/alienneurotoxin, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	add_spell(new /spell/aoe_turf/conjure/choice/alienresin, "alien_spell_ready", /obj/abstract/screen/movable/spell_master/alien)
	verbs -= /mob/living/carbon/alien/verb/ventcrawl

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

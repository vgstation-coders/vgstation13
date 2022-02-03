/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter" //The alien hunter, not Alien Hunter
	caste = "h"
	maxHealth = 250
	health = 250
	plasma = 100
	max_plasma = 150
	icon_state = "alienh_s"
	plasma_rate = 5

/mob/living/carbon/alien/humanoid/hunter/movement_tally_multiplier()
	return ..() * 0.9 // Hunters are fast.

/mob/living/carbon/alien/humanoid/hunter/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	..()

/mob/living/carbon/alien/humanoid/hunter/handle_environment()
	if(m_intent == "run" || resting)
		..()
	else
		AdjustPlasma(-heal_rate)


//Hunter verbs
//This ought to be fixed, maybe not now though
/*
/mob/living/carbon/alien/humanoid/hunter/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 15 seconds"
	set category = "Alien"

	if(alien_invis)
		update_icons()
	else
		if(powerc(50))
			AdjustPlasma(-50)
			alien_invis = 1.0
			update_icons()
			to_chat(src, "<span class='good'>You are now invisible.</span>")
			visible_message("<span class='danger'>\The [src] fades into the surroundings!</span>", "<span class='alien'>You are now invisible</span>")
			spawn(250)
				if(!isnull(src)) //Don't want the game to runtime error when the mob no-longer exists.
					alien_invis = 0.0
					update_icons()
					to_chat(src, "<span class='alien'>You are no longer invisible.</span>")
	return
*/

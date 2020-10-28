/spell/changeling/rapidregen
	name = "Rapid Regeneration (30)"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	abbreviation = "RR"
	hud_state = "rapidregen"

	spell_flags = NEEDSHUMAN

	chemcost = 30

/spell/changeling/rapidregen/cast(var/list/targets, var/mob/living/carbon/human/user)

	var/mob/living/carbon/human/C = user
	..()

	for(var/i = 0, i<10,i++)
		if(C)
			C.adjustBruteLoss(-10)
			C.adjustToxLoss(-10)
			C.adjustOxyLoss(-10)
			C.adjustFireLoss(-10)
			sleep(10)

	feedback_add_details("changeling_powers","RR")

	

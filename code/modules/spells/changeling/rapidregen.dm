/spell/changeling/rapidregen
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	abbreviation = "RR"

	spell_flags = NEEDSHUMAN

	chemcost = 30

/spell/changeling/rapidregen/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return 0

	var/mob/living/carbon/human/C = user

    for(var/i = 0, i<10,i++)
        if(C)
            C.adjustBruteLoss(-10)
            C.adjustToxLoss(-10)
            C.adjustOxyLoss(-10)
            C.adjustFireLoss(-10)
            sleep(10)

	feedback_add_details("changeling_powers","RR")

	..()

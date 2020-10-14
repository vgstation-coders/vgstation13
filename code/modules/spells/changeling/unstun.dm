/spell/changeling/unstun
	name = "Epinephrine Sacs"
	desc = "We evolve additional sacs of adrenaline throughout our body."
	abbreviation = "ES"

	spell_flags = NEEDSHUMAN

	chemcost = 45

//Recover from stuns.
/spell/changeling/unstun/cast(var/list/targets, var/mob/living/carbon/human/user)
	if(!changeling)
		return 0

	var/mob/living/carbon/human/C = user

	C.stat = 0
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetKnockdown(0)
	C.lying = 0
	C.update_canmove()

	feedback_add_details("changeling_powers","UNS")

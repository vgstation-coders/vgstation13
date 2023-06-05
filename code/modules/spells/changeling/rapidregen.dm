/spell/changeling/rapidregen
	name = "Rapid Regeneration (40)"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	abbreviation = "RR"
	hud_state = "rapidregen"

	spell_flags = NEEDSHUMAN | STATALLOWED

	charge_max = 100 SECONDS
	cooldown_min = 100 SECONDS

	chemcost = 40

/spell/changeling/rapidregen/cast_check(skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.)
		return FALSE
//	if(user.mind && user.mind.suiciding)			//no reviving from suicides
//		to_chat(user, "<span class='warning'>Why would we wish to regenerate if we have already committed suicide?</span>")
//		return FALSE
	if(M_HUSK in user.mutations)
		to_chat(user, "<span class='warning'>We can not regenerate from this. There is not enough left to regenerate.</span>")
		return FALSE
	if(inuse)
		return FALSE
	if(!istype(usr, /mob/living/carbon/))
		return

/spell/changeling/rapidregen/cast(var/list/targets, var/mob/living/carbon/C)
	for(var/i = 0, i<10,i++)
		if(C)
			C.adjustBruteLoss(-5)
			C.adjustToxLoss(-5)
			C.adjustOxyLoss(-5)
			C.adjustFireLoss(-5)
			sleep(10)
	C.mind.suiciding = 0
	C.rejuvenate(0)
	feedback_add_details("changeling_powers","RR")
	..()



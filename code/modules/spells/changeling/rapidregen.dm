/spell/changeling/rapidregen
	name = "Rapid Regeneration (40)"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	abbreviation = "RR"
	hud_state = "rapidregen"

	spell_flags = NEEDSHUMAN | STATALLOWED

	charge_max = 1 MINUTES
	cooldown_min = 1 MINUTES

	chemcost = 40

/spell/changeling/rapidregen/cast_check(skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.)
		return FALSE
	if(user.mind && user.mind.suiciding)			//no reviving from suicides
		to_chat(user, "<span class='warning'>Why would we wish to regenerate if we have already committed suicide?</span>")
		return FALSE
	if(M_HUSK in user.mutations)
		to_chat(user, "<span class='warning'>We can not regenerate from this. There is not enough left to regenerate.</span>")
		return FALSE
	if(inuse)
		return FALSE
	if(!istype(usr, /mob/living/carbon/))
		return

/spell/changeling/rapidregen/cast(var/list/targets, var/mob/living/carbon/C)
	C.rejuvenate(0)
	feedback_add_details("changeling_powers","RR")
	..()

	

/spell/changeling/unstun
	name = "Epinephrine Sacs"
	desc = "We extract extra adrenaline from epinephrine sacs within our body, instantly recovering us from stuns."
	abbreviation = "ES"
	hud_state = "unstun"

	spell_flags = NEEDSHUMAN

	charge_max = 1 MINUTES
	cooldown_min = 1 MINUTES

//Recover from stuns.
/spell/changeling/unstun/cast(var/list/targets, var/mob/living/carbon/human/user)

	var/mob/living/carbon/human/C = user

	C.stat = 0
	C.SetParalysis(0)
	C.SetStunned(0)
	C.SetKnockdown(0)
	C.lying = 0
	C.update_canmove()

	feedback_add_details("changeling_powers","UNS")

	..()

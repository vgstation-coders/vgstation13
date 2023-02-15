/spell/changeling/regenerate
	name = "Regenerative Stasis (20)"
	desc = "We become weakened to a death-like state, where we will rise again from death. This will take 2 minutes."
	abbreviation = "RS"
	hud_state = "regenstasis"

	spell_flags = NEEDSHUMAN | STATALLOWED
	charge_max = 8 MINUTES
	cooldown_min = 8 MINUTES
	horrorallowed = 0
	chemcost = 20

/spell/changeling/regenerate/cast_check(skipcharge = 0, var/mob/user = usr)
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

/spell/changeling/regenerate/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/mob/living/carbon/C = user
	var/delay = 0 SECONDS
	inuse = TRUE

	if(C.stat != DEAD)
		C.status_flags |= FAKEDEATH		//play dead
		C.update_canmove()
		C.emote("deathgasp", message = TRUE)
		C.tod = worldtime2text()
		delay = 120 SECONDS
	else
		delay = rand(80 SECONDS, 120 SECONDS)
	to_chat(C, "<span class='warning'>We are now in stasis. You must wait [delay/10] seconds.</span>")
	sleep(delay)
	//if we didn't get revived/smitted in the meantime already
	if(C.stat == DEAD || C.status_flags & FAKEDEATH)
		to_chat(C, "<span class='warning'>We are now ready to awaken from stasis.</span>")
		to_chat(C, "<span class = 'notice'>Click the action button to revive.</span>")
		var/datum/action/lingrevive/revive_action = new()
		revive_action.Grant(C)

	feedback_add_details("changeling_powers","FD")

	..()

/datum/action/lingrevive
	name = "Return to Life"
	desc = "Regenerate your body and continue to spread."
	icon_icon = 'icons/mob/screen_spells.dmi'
	button_icon_state = "ling-open"

/datum/action/lingrevive/Trigger()
	var/datum/role/changeling/changeling = owner.mind.GetRole(CHANGELING)
	var/mob/living/carbon/C = owner

	C.mind.suiciding = 0
	C.rejuvenate(0)
	C.visible_message("<span class='warning'>[owner] appears to wake from the dead, having healed all wounds.</span>")
	if(M_HUSK in C.mutations) //Yes you can regenerate from being husked if you played dead beforehand, but unless you find a new body, you can not regenerate again.
		to_chat(C, "<span class='notice'>This host body has become corrupted, either through a mishap, or betrayal by a member of the hivemind. We must find a new form, lest we lose ourselves to the void and become dust.</span>")
		if(C.dna in changeling.absorbed_dna)
			changeling.absorbed_dna.Remove(C.dna)
	feedback_add_details("changeling_powers","RJ")
	Remove(owner)

/spell/changeling/regenerate/after_cast(list/targets,var/mob/living/carbon/human/user)
	inuse = FALSE

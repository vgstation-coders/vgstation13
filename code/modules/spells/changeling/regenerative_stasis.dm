/spell/changeling/regenerate
	name = "Regenerative Stasis (20)"
	desc = "We become weakened to a death-like state, where we will rise again from death."
	abbreviation = "RS"
	hud_state = "regenstasis"

	spell_flags = NEEDSHUMAN | STATALLOWED

	chemcost = 20
	required_dna = 1

/spell/changeling/regenerate/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)

	if(changeling.isreviving)
		to_chat(changeling.antag.current, "<span class='warning'>We are already regenerating!</span>")
		return

	var/mob/living/carbon/C = user

	if(C.mind && C.mind.suiciding)			//no reviving from suicides
		to_chat(C, "<span class='warning'>Why would we wish to regenerate if we have already committed suicide?")
		return

	if(user.stat != DEAD)
		if(M_HUSK in C.mutations)
			to_chat(C, "<span class='warning'>We can not regenerate from this. There is not enough left to regenerate.</span>")
			return
		if(!C.stat && alert("Are we sure we wish to fake our death?",,"Yes","No") == "No")//Confirmation for living changelings if they want to fake their death
			return

		to_chat(C, "<span class='notice'>We will attempt to regenerate our form.</span>")

		C.status_flags |= FAKEDEATH		//play dead
		C.update_canmove()
		changeling.isreviving = TRUE

		C.emote("deathgasp", message = TRUE)
		C.tod = worldtime2text()
		var/time_to_take = rand(800, 1200)
		to_chat(C, "<span class='notice'>This will take [round((time_to_take/10))] seconds.</span>")
		sleep(time_to_take)
		to_chat(C, "<span class='warning'>We are now ready to regenerate.</span>")

		feedback_add_details("changeling_powers","FD")
	else
		var/time_to_take = 1200
		to_chat(C, "<span class='notice'>We begin to regenerate. This will take [round((time_to_take/10))] seconds.</span>")
		changeling.isreviving = TRUE
		sleep(time_to_take)
		to_chat(C, "<span class='warning'>We are now ready to regenerate.</span>")

	if(C.client && cast_check())
		to_chat(C, "<span class='sinister'>Your corpse twitches slightly. It's safe to assume nobody noticed.</span>")
		to_chat(C, "<span class = 'notice'>Click the action button to revive.</span>")
		var/datum/action/lingrevive/revive_action = new()
		revive_action.Grant(C)

	..()

/datum/action/lingrevive
	name = "Return to Life"
	desc = "Regenerate your body and continue to spread."
	icon_icon = 'icons/mob/screen_spells.dmi'
	button_icon_state = "ling-open"

/datum/action/lingrevive/Trigger()
	var/datum/role/changeling/changeling = owner.mind.GetRole(CHANGELING)
	var/mob/living/carbon/C = owner
	dead_mob_list -= C
	living_mob_list |= list(C)
	C.stat = CONSCIOUS
	C.tod = null
	C.revive(0)
	to_chat(C, "<span class='notice'>We have regenerated.</span>")
	C.visible_message("<span class='warning'>[owner] appears to wake from the dead, having healed all wounds.</span>")
	C.status_flags &= ~(FAKEDEATH)
	C.update_canmove()
	if(M_HUSK in C.mutations) //Yes you can regenerate from being husked if you played dead beforehand, but unless you find a new body, you can not regenerate again.
		to_chat(C, "<span class='notice'>This host body has become corrupted, either through a mishap, or betrayal by a member of the hivemind. We must find a new form, lest we lose ourselves to the void and become dust.</span>")
		if(C.dna in changeling.absorbed_dna)
			changeling.absorbed_dna.Remove(C.dna)
	C.regenerate_icons()
	feedback_add_details("changeling_powers","RJ")
	changeling.isreviving = FALSE
	Remove(owner)

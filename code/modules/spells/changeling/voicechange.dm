/spell/changeling/voicechange
	name = "Mimic Voice (10)"
	desc = "We shape our vocal glands to sound like a desired voice."
	abbreviation = "VC"
	hud_state = "mimicvoice"

	spell_flags = NEEDSHUMAN

	chemcost = 10
	required_dna = 1

/spell/changeling/voicechange/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	
	if(changeling.mimicing)
		changeling.mimicing = ""
		to_chat(user, "<span class='notice'>We return our vocal cords to their original positions.</span>")
		return

	var/mimic_voice = stripped_input(user, "Enter a name to mimic.", "Mimic Voice", null, MAX_NAME_LEN)
	if(!mimic_voice)
		return

	changeling.mimicing = mimic_voice
	to_chat(user, "<span class='notice'>We shape our vocal cords to take the voice of <b>[mimic_voice]</b>.</span>")


	feedback_add_details("changeling_powers","MV")


	..()

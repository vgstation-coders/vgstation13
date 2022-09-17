/spell/changeling/transform
	name = "Transform (5)"
	desc = "We take on the appearance and voice of the DNA we have collected."
	abbreviation = "TF"
	hud_state = "transform"

	spell_flags = NEEDSHUMAN

	chemcost = 5
	horrorallowed = 0
	max_genedamage = 0

/spell/changeling/transform/cast_check(skipcharge = 0,mob/user = usr, var/list/targets)
	. = ..()
	if (!.)
		return FALSE

/spell/changeling/transform/cast(var/list/targets, var/mob/living/carbon/human/user)

	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	
	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		if(DNA == user.dna)
			continue
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	user.visible_message("<span class='danger'>[user] transforms!</span>")
	playsound(user, 'sound/effects/flesh_squelch.ogg', 30, 1)
	changeling.geneticdamage = 30
	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	user.flavor_text = chosen_dna.flavor_text
	user.set_species(user.dna.species, 1)
	user.UpdateAppearance()

	domutcheck(user, null)
	feedback_add_details("changeling_powers","TR")

	..()



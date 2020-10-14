/spell/changeling/transform
	name = "Transform"
	desc = "We take on the apperance and voice of one we have absorbed."
	abbreviation = "TF"

	spell_flags = NEEDSHUMAN

	chemcost = 5
	required_dna = 1
	horrorallowed = 0
	max_genedamage = 0

/spell/changeling/transform/cast(var/list/targets, var/mob/living/carbon/human/user)

	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)
	if(!changeling)
		return

	var/list/names = list()
	for(var/datum/dna/DNA in changeling.absorbed_dna)
		names += "[DNA.real_name]"

	var/S = input("Select the target DNA: ", "Target DNA", null) as null|anything in names
	if(!S)
		return

	var/datum/dna/chosen_dna = changeling.GetDNA(S)
	if(!chosen_dna)
		return

	user.visible_message("<span class='danger'>[user] transforms!</span>")
	changeling.geneticdamage = 30
	var/oldspecies = user.dna.species
	user.dna = chosen_dna.Clone()
	user.real_name = chosen_dna.real_name
	user.flavor_text = chosen_dna.flavor_text
	user.UpdateAppearance()
	if(oldspecies != user.dna.species)
		user.set_species(user.dna.species, 0)
	domutcheck(user, null)
	feedback_add_details("changeling_powers","TR")

	..()



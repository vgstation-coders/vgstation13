/spell/changeling/changespecies
	name = "Change Species (5)"
	desc = "We take on the apperance of a species that we have absorbed."
	abbreviation = "CS"
	hud_state = "changespecies"

	spell_flags = NEEDSHUMAN

	chemcost = 5
	required_dna = 1
	max_genedamage = 0
	horrorallowed = 0

/spell/changeling/changespecies/cast(var/list/targets, var/mob/living/carbon/human/user)
	var/datum/role/changeling/changeling = user.mind.GetRole(CHANGELING)

	if(changeling.absorbed_species.len < 2)
		to_chat(user, "<span class='warning'>We do not know of any other species genomes to use.</span>")
		return

	var/S = input("Select the target species: ", "Target Species", null) as null|anything in changeling.absorbed_species
	if(!S)
		return

	domutcheck(user, null)

	changeling.geneticdamage = 30

	user.visible_message("<span class='danger'>[user] transforms!</span>")

	user.set_species(S,1) //Until someone moves body colour into DNA, they're going to have to use the default.

	user.regenerate_icons()
	user.updateChangelingHUD()
	user.changeling_update_languages(changeling.absorbed_languages)
	feedback_add_details("changeling_powers","TR")

	..()


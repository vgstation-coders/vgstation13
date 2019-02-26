/datum/objective/investigate
	explanation_text = "Bring peace to the spirits of the dead by identifying one dangerous killer. Set your crystal necklace to the identity of the one responsible."
	name = "Investigate Killing"

/datum/objective/investigate/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current)
		return FALSE
	var/obj/item/clothing/mask/necklace/crystal/C = owner.current.search_contents_for(/obj/item/clothing/mask/necklace/crystal)
	if(!C || !C.suspect)
		return FALSE
	if(C.suspect.mind.antag_roles.len)
		return TRUE
	else
		return FALSE
/datum/objective/investigate
	explanation_text = "Bring peace to the spirits of the dead by identifying one dangerous killer."
	name = "Investigate Killing"

/datum/objective/investigate/IsFulfilled()
	if (..())
		return TRUE
	if(!owner.current)
		return FALSE
	var/mob/living/rambler = owner.current
	var/obj/item/clothing/mask/necklace/crystal/C = pick(rambler.search_contents_for(/obj/item/clothing/mask/necklace/crystal))
	if(!C || !C.suspect)
		return FALSE
	if(C.suspect.antag_roles.len)
		return TRUE
	else
		return FALSE
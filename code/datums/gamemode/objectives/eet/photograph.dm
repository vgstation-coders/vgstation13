/datum/objective/eet/photograph
	explanation_text = "Preserve in the archives photographs containing examples of 10 unique species."
	name = "Photograph Unique Species (EET)"
	var/amount = 10
	var/last_reported_count = 0

/datum/objective/eet/photograph/PostAppend()
	amount = rand(8,12)
	explanation_text = "Preserve in the archives photographs containing examples of [amount] unique species."
	return TRUE

/datum/objective/eet/photograph/IsFulfilled()
	if(!eet_arch)
		return FALSE
	var/list/species = list()
	for(var/obj/item/weapon/photo/P in eet_arch.contents)
		for(var/mob/M in P.mobs)
			species = TryInsert(species,M)
	last_reported_count = species.len
	return species.len >= amount

/datum/objective/eet/photograph/proc/TryInsert(var/list/L, var/mob/M)
	var/output_list = unique_type_insert(L,M)
	if(output_list)
		return output_list
	if(ishuman(M))
		var/mob/living/carbon/human/target = M
		for(var/mob/living/carbon/human/H in L)
			if(target.species == H.species)
				return L //Already have this species, give up
		return (L+M) //add new species

/datum/objective/eet/photograph/DatacoreQuery()
	IsFulfilled()
	return ..() + "; [last_reported_count]/[amount]"
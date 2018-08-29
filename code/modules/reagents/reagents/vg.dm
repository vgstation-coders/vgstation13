var/global/list/charcoal_doesnt_remove=list(
	CHARCOAL,
	BLOOD
)

/datum/reagent/proc/reagent_deleted()
	return

/datum/reagent/charcoal
	//data must contain virus type
	name = "Activated Charcoal"
	id = CHARCOAL
	reagent_state = LIQUID
	color = "#333333" // rgb: 51, 51, 51
	custom_metabolism = 0.06
	digestion_rate = 0 // will not transfer from stomach to body

/datum/reagent/charcoal/digest(var/mob/living/carbon/human/M)
	var/datum/organ/internal/stomach/S = M.get_stomach()
	if(!S)
		return

	if(prob(5))
		M.vomit()
	var/found_any = FALSE
	for(var/datum/reagent/reagent in holder.reagent_list)
		if(reagent.id in charcoal_doesnt_remove)
			continue
		holder.remove_reagent(reagent.id, 15*REM)
		found_any = TRUE

	if (!found_any)
		holder.remove_reagent(CHARCOAL, volume)

	M.adjustToxLoss(-2*REM)
	..()

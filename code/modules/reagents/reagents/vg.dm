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
	digestion_rate = 0.1 // Slow to move into the blood stream so stomach contents can actually be processed through.

/datum/reagent/charcoal/digest(var/mob/living/carbon/human/M)
	var/datum/organ/internal/stomach/S = M.get_stomach()
	if(prob(5))
		M.vomit()
		return
	purge_from_reagent_source(S.get_reagents())
	return ..(M)

/datum/reagent/charcoal/proc/purge_from_reagent_source(var/datum/reagents/R)
	if(!R)
		return
	var/found_any = FALSE
	for(var/datum/reagent/reagent in R.reagent_list)
		if(reagent.id in charcoal_doesnt_remove)
			continue
		R.remove_reagent(reagent.id, 15*REM)
		found_any = TRUE

	if (!found_any)
		R.remove_reagent(CHARCOAL, volume)

/datum/reagent/charcoal/on_mob_life(var/mob/living/M)
	purge_from_reagent_source(M.reagents)
	M.adjustToxLoss(-2*REM)
	..()

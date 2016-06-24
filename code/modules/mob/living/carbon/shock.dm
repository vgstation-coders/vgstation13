/mob/living/var/traumatic_shock = 0
/mob/living/carbon/var/shock_stage = 0

// proc to find out in how much pain the mob is at the moment
/mob/living/carbon/proc/updateshock()
	traumatic_shock = 			\
	1	* getOxyLoss() + 		\
	0.7	* getToxLoss() + 		\
	1.5	* getFireLoss() + 		\
	1.2	* getBruteLoss() + 		\
	1.7	* getCloneLoss() + 		\
	2	* halloss

	if(reagents.has_reagent(ALKYSINE))
		traumatic_shock -= 10
	if(reagents.has_reagent(INAPROVALINE))
		traumatic_shock -= 25
	if(reagents.has_reagent(SYNAPTIZINE))
		traumatic_shock -= 40
	if(reagents.has_reagent(PARACETAMOL))
		traumatic_shock -= 50
	if(reagents.has_reagent(TRAMADOL))
		traumatic_shock -= 80 // make synaptizine function as good painkiller
	if(reagents.has_reagent(OXYCODONE))
		traumatic_shock -= 200 // make synaptizine function as good painkiller
	if(slurring)
		traumatic_shock -= 20
	if(analgesic)
		traumatic_shock = 0

	// broken or ripped off organs will add quite a bit of pain
	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/M = src
		for(var/datum/organ/external/organ in M.organs)
			if (!organ)
				continue
			if((organ.status & ORGAN_DESTROYED) && !organ.amputated)
				traumatic_shock += 60
			else if(organ.status & ORGAN_BROKEN || organ.open)
				traumatic_shock += 30
				if(organ.status & ORGAN_SPLINTED)
					traumatic_shock -= 25

	if(traumatic_shock < 0)
		traumatic_shock = 0

	return traumatic_shock


/mob/living/carbon/proc/handle_shock()
	updateshock()

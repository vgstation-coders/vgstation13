var/image/contamination_overlay = image('icons/effects/contamination.dmi')

/pl_control
	var/PLASMA_DMG = 3
	var/PLASMA_DMG_NAME = "Plasma Damage Amount"
	var/PLASMA_DMG_DESC = "Self Descriptive"

	var/CLOTH_CONTAMINATION = 1
	var/CLOTH_CONTAMINATION_NAME = "Cloth Contamination"
	var/CLOTH_CONTAMINATION_DESC = "If this is on, plasma does damage by getting into cloth."

	var/PLASMAGUARD_ONLY = 0
	var/PLASMAGUARD_ONLY_NAME = "\"PlasmaGuard Only\""
	var/PLASMAGUARD_ONLY_DESC = "If this is on, only biosuits and spacesuits protect against contamination and ill effects."

	var/GENETIC_CORRUPTION = 0
	var/GENETIC_CORRUPTION_NAME = "Genetic Corruption Chance"
	var/GENETIC_CORRUPTION_DESC = "Chance of genetic corruption as well as toxic damage, X in 10,000."

	var/SKIN_BURNS = 0
	var/SKIN_BURNS_DESC = "Plasma has an effect similar to mustard gas on the un-suited."
	var/SKIN_BURNS_NAME = "Skin Burns"

	var/EYE_BURNS = 1
	var/EYE_BURNS_NAME = "Eye Burns"
	var/EYE_BURNS_DESC = "Plasma burns the eyes of anyone not wearing eye protection."

	var/CONTAMINATION_LOSS = 0.02
	var/CONTAMINATION_LOSS_NAME = "Contamination Loss"
	var/CONTAMINATION_LOSS_DESC = "How much toxin damage is dealt from contaminated clothing" //Per tick?  ASK ARYN

	var/PLASMA_HALLUCINATION = 0
	var/PLASMA_HALLUCINATION_NAME = "Plasma Hallucination"
	var/PLASMA_HALLUCINATION_DESC = "Does being in plasma cause you to hallucinate?"

	var/N2O_HALLUCINATION = 1
	var/N2O_HALLUCINATION_NAME = "N2O Hallucination"
	var/N2O_HALLUCINATION_DESC = "Does being in sleeping gas cause you to hallucinate?"


obj/var/contaminated = 0


/obj/item/proc/can_contaminate()
	//Clothing and backpacks can be contaminated.
	if(flags & PLASMAGUARD)
		return 0

/obj/item/weapon/storage/backpack/can_contaminate()
	return 0

/obj/item/clothing/can_contaminate()
	return 1

/obj/item/proc/contaminate()
	//Do a contamination overlay? Temporary measure to keep contamination less deadly than it was.
	if(!contaminated)
		contaminated = 1
		overlays += contamination_overlay

/obj/item/proc/decontaminate()
	contaminated = 0
	overlays -= contamination_overlay

/mob/proc/contaminate()

/mob/living/carbon/human/contaminate()
	//See if anything can be contaminated.

	if(!pl_suit_protected())
		suit_contamination()

	if(!pl_head_protected())
		if(prob(1))
			suit_contamination() //Plasma can sometimes get through such an open suit.

//Cannot wash backpacks currently.
//	if(istype(back,/obj/item/weapon/storage/backpack))
//		back.contaminate()

/mob/proc/pl_effects()

/mob/living/carbon/human/pl_effects()
	//Handles all the bad things plasma can do.

	if(flags & INVULNERABLE)
		return

	//Contamination
	if(zas_settings.Get(/datum/ZAS_Setting/CLOTH_CONTAMINATION))
		contaminate()

	//Anything else requires them to not be dead.
	if(isDead())
		return

	if(species.breath_type == "plasma")
		return

	//Burn skin if exposed.
	if(zas_settings.Get(/datum/ZAS_Setting/SKIN_BURNS))
		if(!pl_head_protected() || !pl_suit_protected())
			burn_skin(0.75)
			if(prob(20))
				to_chat(src, "<span class='warning'>Your skin burns!</span>")
			updatehealth()

	//Burn eyes if exposed.
	if(zas_settings.Get(/datum/ZAS_Setting/EYE_BURNS))
		var/eye_protection = get_body_part_coverage(EYES)
		if(!eye_protection)
			burn_eyes()

	//Genetic Corruption
	if(zas_settings.Get(/datum/ZAS_Setting/GENETIC_CORRUPTION))
		if(rand(1,10000) < zas_settings.Get(/datum/ZAS_Setting/GENETIC_CORRUPTION))
			randmutb(src)
			to_chat(src, "<span class='warning'>High levels of toxins cause you to spontaneously mutate.</span>")
			domutcheck(src,null)


/mob/living/carbon/human/proc/burn_eyes()
	//The proc that handles eye burning.
	if(!species.has_organ["eyes"])
		return
	var/datum/organ/internal/eyes/E = internal_organs_by_name["eyes"]
	if(E)
		if(prob(20))
			to_chat(src, "<span class='warning'>Your eyes burn!</span>")
		E.damage += 2.5
		eye_blurry = min(eye_blurry+1.5,50)
		if (prob(max(0,E.damage - 15) + 1) && !eye_blind)
			to_chat(src, "<span class='warning'>You are blinded!</span>")
			eye_blind += 20


/mob/living/carbon/human/proc/pl_head_protected()
	//Checks if the head is adequately sealed.
	if(head)
		if(zas_settings.Get(/datum/ZAS_Setting/PLASMAGUARD_ONLY))
			if(head.flags & PLASMAGUARD)
				return 1
		else if(check_body_part_coverage(EYES))
			return 1
	return 0

/mob/living/carbon/human/proc/pl_suit_protected()
	//Checks if the suit is adequately sealed.
	if(wear_suit)
		if(zas_settings.Get(/datum/ZAS_Setting/PLASMAGUARD_ONLY))
			if(wear_suit.flags & PLASMAGUARD)
				return 1
		else
			if(is_slot_hidden(wear_suit.body_parts_covered,HIDEJUMPSUIT))
				return 1
	return 0

/mob/living/carbon/human/proc/suit_contamination()
	//Runs over the things that can be contaminated and does so.
	if(w_uniform) w_uniform.contaminate()
	if(shoes) shoes.contaminate()
	if(gloves) gloves.contaminate()

/* We hate this
turf/Entered(obj/item/I)
	. = ..()
	//Items that are in plasma, but not on a mob, can still be contaminated.
	if(istype(I) && zas_settings.Get(/datum/ZAS_Setting/CLOTH_CONTAMINATION) && I.can_contaminate())
		var/datum/gas_mixture/env = return_air(1)
		if(!env)
			return
		for(var/g in env.gas)
			if(gas_data.flags[g] & XGM_GAS_CONTAMINANT && env.gas[g] > gas_data.overlay_limit[g] + 1)
				I.contaminate()
				break
*/

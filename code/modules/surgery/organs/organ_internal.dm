/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/zone = BODY_ZONE_CHEST
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/vital = 0
	//Was this organ implanted/inserted/etc, if true will not be removed during species change.
	var/external = FALSE
	var/synthetic = FALSE // To distinguish between organic and synthetic organs


/obj/item/organ/proc/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(M))
		else
			qdel(replaced)

	owner = M
	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	moveToNullspace()
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)

//Special is for instant replacement like autosurgeons
/obj/item/organ/proc/Remove(mob/living/carbon/M, special = 0)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
		if(vital && !special && !(M.status_flags & GODMODE))
			M.death()
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)


/obj/item/organ/proc/on_find(mob/living/finder)
	return

/obj/item/organ/proc/on_life()
	return

/obj/item/organ/examine(mob/user)
	..()
	if(status == ORGAN_ROBOTIC && crit_fail)
		to_chat(user, "<span class='warning'>[src] seems to be broken!</span>")


/obj/item/organ/proc/prepare_eat()
	var/obj/item/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.w_class = w_class

	return S

/obj/item/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'
	list_reagents = list("nutriment" = 5)
	foodtype = RAW | MEAT | GROSS


/obj/item/organ/Destroy()
	if(owner)
		// The special flag is important, because otherwise mobs can die
		// while undergoing transformation into different mobs.
		Remove(owner, special=TRUE)
	return ..()

/obj/item/organ/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(status == ORGAN_ORGANIC)
			var/obj/item/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				qdel(src)
				if(H.put_in_active_hand(S))
					S.attack(H, H)
	else
		..()

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return 0

/mob/living/carbon/regenerate_organs()
	var/breathes = TRUE
	var/blooded = TRUE
	if(dna && dna.species)
		if(has_trait(TRAIT_NOBREATH, SPECIES_TRAIT))
			breathes = FALSE
		if(NOBLOOD in dna.species.species_traits)
			blooded = FALSE
		var/has_liver = (!(NOLIVER in dna.species.species_traits))
		var/has_stomach = (!(NOSTOMACH in dna.species.species_traits))

		if(has_liver && !getorganslot(ORGAN_SLOT_LIVER))
			var/obj/item/organ/liver/LI

			if(dna.species.mutantliver)
				LI = new dna.species.mutantliver()
			else
				LI = new()
			LI.Insert(src)

		if(has_stomach && !getorganslot(ORGAN_SLOT_STOMACH))
			var/obj/item/organ/stomach/S

			if(dna.species.mutantstomach)
				S = new dna.species.mutantstomach()
			else
				S = new()
			S.Insert(src)

	if(breathes && !getorganslot(ORGAN_SLOT_LUNGS))
		var/obj/item/organ/lungs/L = new()
		L.Insert(src)

	if(blooded && !getorganslot(ORGAN_SLOT_HEART))
		var/obj/item/organ/heart/H = new()
		H.Insert(src)

	if(!getorganslot(ORGAN_SLOT_TONGUE))
		var/obj/item/organ/tongue/T

		if(dna && dna.species && dna.species.mutanttongue)
			T = new dna.species.mutanttongue()
		else
			T = new()

		// if they have no mutant tongues, give them a regular one
		T.Insert(src)

	if(!getorganslot(ORGAN_SLOT_EYES))
		var/obj/item/organ/eyes/E

		if(dna && dna.species && dna.species.mutanteyes)
			E = new dna.species.mutanteyes()

		else
			E = new()
		E.Insert(src)

	if(!getorganslot(ORGAN_SLOT_EARS))
		var/obj/item/organ/ears/ears
		if(dna && dna.species && dna.species.mutantears)
			ears = new dna.species.mutantears
		else
			ears = new

		ears.Insert(src)

	if(!getorganslot(ORGAN_SLOT_TAIL))
		var/obj/item/organ/tail/tail
		if(dna && dna.species && dna.species.mutanttail)
			tail = new dna.species.mutanttail
			tail.Insert(src)

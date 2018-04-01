/obj/item/organ/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	zone = BODY_ZONE_CHEST
	slot = "parasite_egg"

/obj/item/organ/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, "<span class='warning'>You found an unknown alien organism in [owner]'s [zone]!</span>")

/obj/item/organ/body_egg/New(loc)
	if(iscarbon(loc))
		src.Insert(loc)
	return ..()

/obj/item/organ/body_egg/Insert(var/mob/living/carbon/M, special = 0)
	..()
	owner.add_trait(TRAIT_XENO_HOST, TRAIT_GENERIC)
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, .proc/AddInfectionImages, owner)

/obj/item/organ/body_egg/Remove(var/mob/living/carbon/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	if(owner)
		owner.remove_trait(TRAIT_XENO_HOST, TRAIT_GENERIC)
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, .proc/RemoveInfectionImages, owner)
	..()

/obj/item/organ/body_egg/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		Remove(owner)
		return
	egg_process()

/obj/item/organ/body_egg/proc/egg_process()
	return

/obj/item/organ/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/body_egg/proc/RemoveInfectionImages()
	return

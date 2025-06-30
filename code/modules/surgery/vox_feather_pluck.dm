//////////////////////////////////////////////////////////////////
//                  VOX FEATHER PLUCKING SURGERY                //
//////////////////////////////////////////////////////////////////

/datum/surgery_step/feather_pluck
	priority = 5
	can_infect = 0

/datum/surgery_step/feather_pluck/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	// Vox only: check species
	if (!istype(target.species, /datum/species/vox))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (!affected)
		return 0
	// Assume feathers are on the chest (adjust if needed)
	return target_zone == LIMB_CHEST

/datum/surgery_step/feather_pluck/pluck_feather
	allowed_tools = list(
		/obj/item/tool/hemostat = 100,
		/obj/item/tool/wirecutters = 75,
	)
	duration = 5 SECONDS

/datum/surgery_step/feather_pluck/pluck_feather/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/has_feathers
	var/datum/butchering_product/feathers/F = locate(/datum/butchering_product/feathers) in target.butchering_drops
	if(!istype(F))
		return 0
	if(F.amount > 0)
		has_feathers = 1
	else
		to_chat(user, "<span class='warning'>[target] has no feathers left to pluck.</span>")
		return 0
	return ..() && has_feathers

/datum/surgery_step/feather_pluck/pluck_feather/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts plucking a feather from [target] with [tool].", \
	"You start plucking a feather from [target] with [tool].")
	target.custom_pain("You feel a sharp pain as a feather is ripped out!", 1, scream=TRUE)
	..()

/datum/surgery_step/feather_pluck/pluck_feather/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] plucks a feather from [target] with [tool].</span>", \
	"<span class='notice'>You pluck a feather from [target] with [tool].</span>")
	var/datum/butchering_product/feathers/F = locate(/datum/butchering_product/feathers) in target.butchering_drops
	if(istype(F) && F.amount > 0)
		F.spawn_result(get_turf(target), target, 1)
	if(istype(F) && F.amount == 0)
		target.update_icons()
		// Vox plucking: update to plucked icon (surgery)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			if(istype(H.species, /datum/species/vox))
				H.set_vox_plucked_appearance()
				if(H.radiation >= 30)
					H.start_feather_regeneration()
				else
					H.check_vox_feather_regen_ready()

/datum/surgery_step/feather_pluck/pluck_feather/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, painfully yanking at [target]'s feathers with \\the [tool]!</span>", \
	"<span class='warning'>Your hand slips, painfully yanking at [user]'s feathers with [tool]!</span>")
	target.apply_damage(5, BRUTE, affected)


//////////////////////////////////////////////////////////////////
//						PLUCKING SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/pluck
	priority = 10
	can_infect = 0
	allowed_tools = list(
		/obj/item/tool/hemostat = 100,
		/obj/item/tool/wirecutters = 75,
	)
	duration = 10 SECONDS

/datum/surgery_step/pluck/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	// Only Vox, only chest
	var/datum/butchering_product/feathers/vox/F = locate(/datum/butchering_product/feathers/vox) in target.butchering_drops
	if(!isvox(target) || F.amount == 0) return 0
	return target_zone == LIMB_CHEST

/datum/surgery_step/pluck/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] starts plucking feathers from [target]'s chest with \the [tool].</span>", \
	"You start plucking feathers from [target]'s chest with \the [tool].")
	..()

/datum/surgery_step/pluck/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] plucks feathers from [target]'s chest!</span>", \
	"<span class='notice'>You pluck feathers from [target]'s chest!</span>")
	var/datum/butchering_product/feathers/vox/F = locate(/datum/butchering_product/feathers/vox) in target.butchering_drops
	if(F)
		while (F.amount > 0)
			F.spawn_result(get_turf(target), target)

/datum/surgery_step/pluck/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, painfully yanking [target]'s plumage!</span>", \
	"<span class='warning'>Your hand slips, painfully yanking [target]'s plumage!</span>")
	target.apply_damage(5, BRUTE, target_zone)


//////PREPARE GENITALS///////
/datum/surgery_step/prepare_genitals
	allowed_tools = list(
		/obj/item/tool/retractor = 100,
		/obj/item/tool/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50,
		)

	priority = 1
	duration = 4 SECONDS

/datum/surgery_step/prepare_genitals/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(target.species.anatomy_flags & NO_SKIN)
		to_chat(user, "<span class='warning'>[target] has no genitalia to prepare.</span>")
		return 0
	return target_zone == LIMB_GROIN && hasorgans(target) && affected.open >= 2 && affected.stage == 0

/datum/surgery_step/prepare_genitals/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] prepares [target]'s genitals for reshaping.</span>")

/datum/surgery_step/prepare_genitals/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pulls [target]'s genitals into place for reshaping!</span>")
	target.op_stage.genitals = 1
	return 1

/datum/surgery_step/prepare_genitals/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	//H.gender_ambiguous = 1
	user.visible_message("<span class='warning'>[user] accidentally tears [target]'s genitals!</span>")
	target.apply_damage(10, BRUTE, LIMB_GROIN, 1)
	return 1



//////RESHAPE GENITALS//////
/datum/surgery_step/reshape_genitals/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/reshape_genitals
	allowed_tools = list(
		/obj/item/tool/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/hatchet = 50,
		"wirecutter" = 35,
		)

	priority = 10 //Fuck sakes
	duration = 8 SECONDS
	blood_level = 2 //Icky

/datum/surgery_step/reshape_genitals/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return target_zone == LIMB_GROIN && hasorgans(target) && target.op_stage.genitals == 1

/datum/surgery_step/reshape_genitals/begin_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(target.gender == FEMALE)
		user.visible_message("<span class='notice'>[user] begins to reshape [target]'s genitals to look more masculine.</span>")
	else
		user.visible_message("<span class='notice'>[user] begins to reshape [target]'s genitals to look more feminine.</span>")

/datum/surgery_step/reshape_genitals/end_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	//H.gender_ambiguous = 0
	if(target.gender == FEMALE)
		user.visible_message("<span class='notice'>[user] has made a man out of [target]!</span>")
		target.setGender(MALE)
	else
		user.visible_message("<span class='notice'>[user] has made a woman out of [target]!</span>")
		target.setGender(FEMALE)
	target.regenerate_icons()
	target.op_stage.genitals = 0
	return 1

/datum/surgery_step/reshape_genitals/fail_step(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	//H.gender_ambiguous = 1
	user.visible_message("<span class='warning'>[user] mutilates [target]'s genitals beyond recognition!</span>")
	target.apply_damage(50, BRUTE, LIMB_GROIN, 1)
	target.audible_scream()
	target.setGender(pick(MALE, FEMALE))
	target.regenerate_icons()
	return 1

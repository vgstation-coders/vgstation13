//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/glue_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && affected.stage == 0

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.stage == 0)
			user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool]." , \
			"You start applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] applies some [tool] to [target]'s bone in [affected.display_name]</span>", \
			"<span class=\"notice\">You apply some [tool] to [target]'s bone in [affected.display_name] with \the [tool].</span>")
		affected.stage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
		"<span class=\"rose\">Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")

/datum/surgery_step/set_bone
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.name != "head" && affected.open == 2 && affected.stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool]." , \
			"You are beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool].")
		target.custom_pain("The pain in your [affected.display_name] is going to make you pass out!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected.status & ORGAN_BROKEN)
			user.visible_message("<span class=\"notice\">[user] sets the bone in [target]'s [affected.display_name] in place with \the [tool].</span>", \
				"<span class=\"notice\">You set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>")
			affected.stage = 2
		else
			user.visible_message("<span class=\"notice\">[user] sets the bone in [target]'s [affected.display_name]</span><span class=\"rose\"> in the WRONG place with \the [tool].</span>", \
				"<span class=\"notice\">You set the bone in [target]'s [affected.display_name]</span><span class=\"rose\"> in the WRONG place with \the [tool].</span>")
			affected.fracture()

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>" , \
			"<span class=\"rose\">Your hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
		affected.createwound(BRUISE, 5)

/datum/surgery_step/mend_skull
	allowed_tools = list(
	/obj/item/weapon/bonesetter = 100,	\
	/obj/item/weapon/wrench = 75		\
	)

	min_duration = 60
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.name == "head" && affected.open == 2 && affected.stage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] is beginning piece together [target]'s skull with \the [tool]."  , \
			"You are beginning piece together [target]'s skull with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] sets [target]'s skull with \the [tool].</span>" , \
			"<span class=\"notice\">You set [target]'s skull with \the [tool].</span>")
		affected.stage = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
			"<span class=\"rose\">Your hand slips, damaging [target]'s face with \the [tool]!</span>")
		var/datum/organ/external/head/h = affected
		h.createwound(BRUISE, 10)
		h.disfigured = 1

/datum/surgery_step/finish_bone
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)
	can_infect = 1
	blood_level = 1

	min_duration = 50
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 2 && affected.stage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [affected.display_name] with \the [tool].", \
		"You start to finish mending the damaged bones in [target]'s [affected.display_name] with \the [tool].")
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] has mended the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>"  , \
			"<span class=\"notice\">You have mended the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>" )
		affected.status &= ~ORGAN_BROKEN
		affected.status &= ~ORGAN_SPLINTED
		affected.stage = 0
		affected.perma_injury = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
		"<span class=\"rose\">Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")
//Procedures in this file: Fracture repair surgery
//////////////////////////////////////////////////////////////////
//						BONE SURGERY							//
//////////////////////////////////////////////////////////////////


//////GLUE BONE////////
/datum/surgery_step/glue_bone
	allowed_tools = list(
		/obj/item/tool/bonegel = 100,
		"screwdriver" = 75,
		)
	can_infect = 1
	blood_level = 1

	priority = 0

	duration = 5 SECONDS

/datum/surgery_step/glue_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return (affected.open >= 2 || (target.species.anatomy_flags & NO_SKIN)) && affected.stage == 0 && affected.status & ORGAN_BROKEN

/datum/surgery_step/glue_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.stage == 0)
		user.visible_message("[user] starts applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool]." , \
		"You start applying medication to the damaged bones in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!",1, scream=TRUE)
	..()

/datum/surgery_step/glue_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] applies some of \the [tool] to the bones in [target]'s [affected.display_name]</span>", \
		"<span class='notice'>You apply some of \the [tool] to the bones in [target]'s [affected.display_name].</span>")
	affected.stage = 1

/datum/surgery_step/glue_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")



///////SET BONE/////////
/datum/surgery_step/set_bone
	allowed_tools = list(
		/obj/item/tool/bonesetter = 100,
		"wrench" = 75,
		)

	duration = 6 SECONDS

/datum/surgery_step/set_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return affected.name != LIMB_HEAD && (affected.open >= 2 || (target.species.anatomy_flags & NO_SKIN)) && affected.stage == 1

/datum/surgery_step/set_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool]." , \
		"You are beginning to set the bone in [target]'s [affected.display_name] in place with \the [tool].")
	target.custom_pain("The pain in your [affected.display_name] is going to make you pass out!",1, scream=TRUE)
	..()

/datum/surgery_step/set_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.status & ORGAN_BROKEN)
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [affected.display_name] in place with \the [tool].</span>", \
			"<span class='notice'>You set the bone in [target]'s [affected.display_name] in place with \the [tool].</span>")
		affected.stage = 2
	else
		user.visible_message("<span class='notice'>[user] sets the bone in [target]'s [affected.display_name] <span class='warning'>in the WRONG place with \the [tool].</span>", \
			"<span class='notice'>You set the bone in [target]'s [affected.display_name] <span class='warning'>in the WRONG place with \the [tool].</span>")
		affected.fracture()

/datum/surgery_step/set_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, damaging the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 5)



///////MEND SKULL///////
/datum/surgery_step/mend_skull
	allowed_tools = list(
		/obj/item/tool/bonesetter = 100,
		"wrench"= 75,
		)

	duration = 6 SECONDS

/datum/surgery_step/mend_skull/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return affected.name == LIMB_HEAD && (affected.open >= 2 || (target.species.anatomy_flags & NO_SKIN))&& affected.stage == 1

/datum/surgery_step/mend_skull/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning piece together [target]'s skull with \the [tool]."  , \
		"You are beginning piece together [target]'s skull with \the [tool].")
	..()

/datum/surgery_step/mend_skull/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] sets [target]'s skull with \the [tool].</span>" , \
		"<span class='notice'>You set [target]'s skull with \the [tool].</span>")
	affected.stage = 2

/datum/surgery_step/mend_skull/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging [target]'s face with \the [tool]!</span>"  , \
		"<span class='warning'>Your hand slips, damaging [target]'s face with \the [tool]!</span>")
	var/datum/organ/external/head/h = affected
	h.createwound(BRUISE, 10)
	h.disfigure("brute")



//////FINISH BONE/////////
/datum/surgery_step/finish_bone
	allowed_tools = list(
		/obj/item/tool/bonegel = 100,
		"screwdriver" = 75,
		)

	can_infect = 1
	blood_level = 1

	duration = 5 SECONDS

/datum/surgery_step/finish_bone/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return (affected.open >= 2 || (target.species.anatomy_flags & NO_SKIN)) && affected.stage == 2

/datum/surgery_step/finish_bone/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to finish mending the damaged bones in [target]'s [affected.display_name] with \the [tool].", \
	"You start to finish mending the damaged bones in [target]'s [affected.display_name] with \the [tool].")
	..()

/datum/surgery_step/finish_bone/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has mended the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>"  , \
		"<span class='notice'>You have mended the damaged bones in [target]'s [affected.display_name] with \the [tool].</span>" )
	affected.status &= ~ORGAN_BROKEN
	affected.status &= ~ORGAN_SPLINTED
	affected.stage = 0
	affected.perma_injury = 0
	if(affected.brute_dam >= affected.min_broken_damage * config.organ_health_multiplier)
		affected.heal_damage(affected.brute_dam - (affected.min_broken_damage - rand(3,5)) * config.organ_health_multiplier) //Put the limb's brute damage just under the bone breaking threshold, to prevent it from instabreaking again.

/datum/surgery_step/finish_bone/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")



//////BONE MENDER/////////
/datum/surgery_step/bone_mender
	allowed_tools = list(
		/obj/item/tool/bonesetter/bone_mender = 100,
		)

	priority = 0.1 //so it tries to do this before /glue_bone

	duration = 8 SECONDS

/datum/surgery_step/bone_mender/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return (affected.open >= 2 || (target.species.anatomy_flags & NO_SKIN)) && affected.stage <= 5 && affected.status & ORGAN_BROKEN

/datum/surgery_step/bone_mender/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected.stage <= 5)
		user.visible_message("[user] starts grasping the damaged bone edges in [target]'s [affected.display_name] with \the [tool]." , \
		"You start grasping the bone edges and fusing them in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!", 1, scream=TRUE)
	..()

/datum/surgery_step/bone_mender/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] fuses [target]'s [affected.display_name] bone with \the [tool].</span>"  , \
		"<span class='notice'>You fuse the bone in [target]'s [affected.display_name] with \the [tool].</span>" )
	affected.status &= ~ORGAN_BROKEN
	affected.status &= ~ORGAN_SPLINTED
	affected.stage = 0
	affected.perma_injury = 0
	if(affected.brute_dam >= affected.min_broken_damage * config.organ_health_multiplier)
		affected.heal_damage(affected.brute_dam - (affected.min_broken_damage - rand(3,5)) * config.organ_health_multiplier)
		//Put the limb's brute damage just under the bone breaking threshold, to prevent it from instabreaking again.

/datum/surgery_step/bone_mender/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>\The [tool] in [user]'s hand skips, jabbing the bone edges into the sides of [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand jolts and \the [tool] skips, jabbing the bone edges into [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 10)

// Internal surgeries.
/datum/surgery_step/internal
	priority = 2
	can_infect = 1
	blood_level = 1

/datum/surgery_step/internal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)
	return affected.open == (affected.encased ? 3 : 2)

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/remove_embryo
	allowed_tools = list(
		/obj/item/weapon/hemostat = 100,
		/obj/item/weapon/wirecutters = 75,
		/obj/item/weapon/kitchen/utensil/fork = 20,
		)
	blood_level = 2

	min_duration = 80
	max_duration = 100

/datum/surgery_step/internal/remove_embryo/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/embryo = 0
	for(var/obj/item/alien_embryo/A in target)
		embryo = 1
		break

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && embryo && affected.open == 3 && target_zone == LIMB_CHEST

/datum/surgery_step/internal/remove_embryo/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
	var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("Something hurts horribly in your chest!",1)
	..()

/datum/surgery_step/internal/remove_embryo/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user] rips the larva out of [target]'s ribcage!</span>",
						 "You rip the larva out of [target]'s ribcage!")

	for(var/obj/item/alien_embryo/A in target)
		A.forceMove(A.loc.loc)


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/internal/fix_organ
	allowed_tools = list(
		/obj/item/stack/medical/advanced/bruise_pack= 100,
		/obj/item/stack/medical/bruise_pack = 50,
		/obj/item/stack/medical/bruise_pack/tajaran = 75,
		)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/internal/fix_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/has_damaged_organic_organ = 0
	var/has_damaged_robot_organ = 0
	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I.damage > 0)
			if(I.robotic >= 2)
				has_damaged_robot_organ = 1
			else
				has_damaged_organic_organ = 1
			break
	if(..())
		if(!has_damaged_organic_organ && has_damaged_robot_organ)
			to_chat(user, "<span class='warning'>You cannot fix robotic organs with this tool.</span>")
			return
		return has_damaged_organic_organ

/datum/surgery_step/internal/fix_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "the regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic < 2)
				user.visible_message("[user] starts treating damage to [target]'s [I.name] with [tool_name].", \
				"You start treating damage to [target]'s [I.name] with [tool_name]." )

	target.custom_pain("The pain in your [affected.display_name] is living hell!",1)
	..()

/datum/surgery_step/internal/fix_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/tool_name = "\the [tool]"
	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		tool_name = "the regenerative membrane"
	if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			tool_name = "the poultice"
		else
			tool_name = "the bandaid"

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic < 2)
				user.visible_message("<span class='notice'>[user] treats damage to [target]'s [I.name] with [tool_name].</span>", \
				"<span class='notice'>You treat damage to [target]'s [I.name] with [tool_name].</span>" )
				I.damage = 0
		if(I)
			I.status &= ~ORGAN_BROKEN
			I.status &= ~ORGAN_SPLINTED

/datum/surgery_step/internal/fix_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>")
	var/dam_amt = 2

	if (istype(tool, /obj/item/stack/medical/advanced/bruise_pack))
		target.adjustToxLoss(5)

	else if (istype(tool, /obj/item/stack/medical/bruise_pack))
		if (istype(tool, /obj/item/stack/medical/bruise_pack/tajaran))
			target.adjustToxLoss(7)
		else
			dam_amt = 5
			target.adjustToxLoss(10)
			affected.createwound(CUT, 5)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I && I.damage > 0)
			I.take_damage(dam_amt,0)

/*
//////FIX ORGAN CANCER////
/datum/surgery_step/internal/fix_organ_cancer
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		)

	priority = 4 //Maximum priority, even higher than fixing brain hematomas
	min_duration = 90
	max_duration = 110
	blood_level = 1

/datum/surgery_step/internal/fix_organ_cancer/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/cancer_found = 0
	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I.cancer_stage >= 1)
			cancer_found = 1
			break
	return ..() && cancer_found

/datum/surgery_step/internal/fix_organ_cancer/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I && I.cancer_stage >= 1)
			user.visible_message("[user] starts carefully removing the cancerous growths in [target]'s [I.name] with \the [tool].", \
			"You start carefully removing the cancerous growths in [target]'s [I.name] with \the [tool]." )

	target.custom_pain("The pain in your [affected.display_name] is living hell!", 1)
	..()

/datum/surgery_step/internal/fix_organ_cancer/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I && I.cancer_stage >= 1)
			user.visible_message("[user] carefully removes and mends the area around the cancerous growths in [target]'s [I.name] with \the [tool].", \
			"You carefully remove and mends the area around the cancerous growths in [target]'s [I.name] with \the [tool]." )
			I.cancer_stage = 0

/datum/surgery_step/internal/fix_organ_cancer/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, getting mess on and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, getting mess on and tearing the inside of [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 10)
*/

//////FIX ORGAN ROBOTIC/////
/datum/surgery_step/internal/fix_organ_robotic //For artificial organs
	allowed_tools = list(
		/obj/item/stack/nanopaste = 100,
		/obj/item/weapon/bonegel = 30,
		/obj/item/weapon/screwdriver = 70,
		)

	min_duration = 70
	max_duration = 90

/datum/surgery_step/internal/fix_organ_robotic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/has_damaged_organic_organ = 0
	var/has_damaged_robot_organ = 0
	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I.damage > 0)
			if(I.robotic >= 2)
				has_damaged_robot_organ = 1
			else
				has_damaged_organic_organ = 1
			break
	if(..())
		if(!has_damaged_robot_organ && has_damaged_organic_organ)
			to_chat(user, "<span class='warning'>You cannot fix organic organs with this tool.</span>")
			return
		return has_damaged_robot_organ

/datum/surgery_step/internal/fix_organ_robotic/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I && I.damage > 0)
			if(I.robotic >= 2)
				user.visible_message("[user] starts mending the damage to [target]'s [I.name]'s mechanisms.", \
				"You start mending the damage to [target]'s [I.name]'s mechanisms." )

	target.custom_pain("The pain in your [affected.display_name] is living hell!",1)
	..()

/datum/surgery_step/internal/fix_organ_robotic/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	for(var/datum/organ/internal/I in affected.internal_organs)

		if(I && I.damage > 0)
			if(I.robotic >= 2)
				user.visible_message("<span class='notice'>[user] repairs [target]'s [I.name] with [tool].</span>", \
				"<span class='notice'>You repair [target]'s [I.name] with [tool].</span>" )
				I.damage = 0
		if(I)
			I.status &= ~ORGAN_BROKEN
			I.status &= ~ORGAN_SPLINTED

/datum/surgery_step/internal/fix_organ_robotic/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!hasorgans(target))
		return
	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("<span class='warning'>[user]'s hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, gumming up the mechanisms inside of [target]'s [affected.display_name] with \the [tool]!</span>")

	target.adjustToxLoss(5)
	affected.createwound(CUT, 5)

	for(var/datum/organ/internal/I in affected.internal_organs)
		if(I)
			I.take_damage(rand(3,5),0)



//////DETACH ORGAN////
/datum/surgery_step/internal/detatch_organ/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/internal/detatch_organ
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	min_duration = 90
	max_duration = 110

/datum/surgery_step/internal/detatch_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!..())
		return 0

	target.op_stage.current_organ = null

	var/list/attached_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/datum/organ/internal/I = target.internal_organs_by_name[organ]
		if(!I.status && I.parent_organ == target_zone)
			attached_organs |= organ

	var/organ_to_remove = input(user, "Which organ do you want to prepare for removal?") as null|anything in attached_organs
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove

	var/datum/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
	return ..() && organ_to_remove && I && istype(I) && I.CanRemove(target, user)

/datum/surgery_step/internal/detatch_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/datum/organ/external/affected = target.get_organ(target_zone)

	user.visible_message("[user] starts to separate [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start to separate [target]'s [target.op_stage.current_organ] with \the [tool]." )
	target.custom_pain("The pain in your [affected.display_name] is living hell!",1)
	..()

/datum/surgery_step/internal/detatch_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has separated [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have separated [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/datum/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I) && I.CanRemove(target, user, quiet=1))
		I.Remove(target, user)
		I.status |= ORGAN_CUT_AWAY

/datum/surgery_step/internal/detatch_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, rand(30,50), 1)



//////REMOVE ORGAN//////
/datum/surgery_step/internal/remove_organ

	allowed_tools = list(
		/obj/item/weapon/hemostat = 100,
		/obj/item/weapon/wirecutters = 75,
		/obj/item/weapon/kitchen/utensil/fork = 20,
		)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/remove_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!..())
		return 0

	target.op_stage.current_organ = null

	var/list/removable_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/datum/organ/internal/I = target.internal_organs_by_name[organ]
		if(I.status & ORGAN_CUT_AWAY && I.parent_organ == target_zone)
			removable_organs |= organ

	var/organ_to_remove = input(user, "Which organ do you want to remove?") as null|anything in removable_organs
	if(!organ_to_remove)
		return 0

	target.op_stage.current_organ = organ_to_remove
	return ..()

/datum/surgery_step/internal/remove_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts removing [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start removing [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("Someone's ripping out your [target.op_stage.current_organ]!",1)
	..()

/datum/surgery_step/internal/remove_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>", \
	"<span class='notice'>You have removed [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	// Extract the organ!
	if(target.op_stage.current_organ)
		var/datum/organ/external/affectedarea = target.get_organ(target_zone)
		var/datum/organ/internal/targetorgan = target.internal_organs_by_name[target.op_stage.current_organ]

		target.remove_internal_organ(user, targetorgan, affectedarea)

		target.op_stage.current_organ = null

/datum/surgery_step/internal/remove_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 20)



/////REPLACE ORGAN//////
/datum/surgery_step/internal/replace_organ
	allowed_tools = list(
		/obj/item/organ/internal = 100,
		)

	min_duration = 60
	max_duration = 80

/datum/surgery_step/internal/replace_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/obj/item/organ/internal/O = tool
	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/organ_compatible
	var/organ_missing

	if(!istype(O))
		return 0

	if(!target.species)
		to_chat(user, "<span class='warning'>You have no idea what species this person is. Report this on the bug tracker.</span>")
		return 0

	var/o_is = (O.gender == PLURAL) ? "are" : "is"
	var/o_a =  (O.gender == PLURAL) ? "" : " a"
	var/o_do = (O.gender == PLURAL) ? "don't" : "doesn't"

	if(target.species.has_organ[O.organ_tag])

		if(!O.health)
			to_chat(user, "<span class='warning'>\The [O.organ_tag] [o_is] in no state to be transplanted.</span>")
			return 0

		if(!target.internal_organs_by_name[O.organ_tag])
			organ_missing = 1
		else
			to_chat(user, "<span class='warning'>\The [target] already has [o_a][O.organ_tag].</span>")
			return 0

		if(O.organ_data && affected.name == O.organ_data.parent_organ)
			organ_compatible = 1
		else
			to_chat(user, "<span class='warning'>\The [O.organ_tag] [o_do] normally go in \the [affected.display_name].</span>")
			return 0
	else
		to_chat(user, "<span class='warning'>\A [target.species.name] doesn't normally have [o_a][O.organ_tag].</span>")
		return 0

	return ..() && organ_missing && organ_compatible

/datum/surgery_step/internal/replace_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts transplanting \the [tool] into [target]'s [affected.display_name].", \
	"You start transplanting \the [tool] into [target]'s [affected.display_name].")
	target.custom_pain("Someone's rooting around in your [affected.display_name]!",1)
	..()

/datum/surgery_step/internal/replace_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has transplanted \the [tool] into [target]'s [affected.display_name].</span>", \
	"<span class='notice'>You have transplanted \the [tool] into [target]'s [affected.display_name].</span>")
	user.drop_item()
	var/obj/item/organ/internal/O = tool

	if(istype(O))

		var/datum/reagent/blood/transplant_blood = O.reagents.reagent_list[BLOOD]
		if(!transplant_blood)
			O.organ_data.transplant_data = list()
			O.organ_data.transplant_data["species"] =    target.species.name
			O.organ_data.transplant_data["blood_type"] = target.dna.b_type
			O.organ_data.transplant_data["blood_DNA"] =  target.dna.unique_enzymes
		else
			O.organ_data.transplant_data = list()
			O.organ_data.transplant_data["species"] =    transplant_blood.data["species"]
			O.organ_data.transplant_data["blood_type"] = transplant_blood.data["blood_type"]
			O.organ_data.transplant_data["blood_DNA"] =  transplant_blood.data["blood_DNA"]

		O.organ_data.organ_holder = null
		O.organ_data.owner = target
		target.internal_organs |= O.organ_data
		affected.internal_organs |= O.organ_data
		target.internal_organs_by_name[O.organ_tag] = O.organ_data
		O.organ_data.status |= ORGAN_CUT_AWAY
		O.replaced(target)
	var/datum/organ/internal/I = target.internal_organs_by_name[O.organ_tag]
	I.removed_type = O
	O.stabilized = TRUE
	O.loc = null
	O = null

/datum/surgery_step/internal/replace_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging \the [tool]!</span>")
	var/obj/item/organ/internal/I = tool
	if(istype(I))
		I.organ_data.take_damage(rand(3,5),0)




////ATTACH ORGAN//////
/datum/surgery_step/internal/attach_organ
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		)

	min_duration = 100
	max_duration = 120

/datum/surgery_step/internal/attach_organ/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	if (!..())
		return 0

	target.op_stage.current_organ = null

	var/list/removable_organs = list()
	for(var/organ in target.internal_organs_by_name)
		var/datum/organ/internal/I = target.internal_organs_by_name[organ]
		if(I.status & ORGAN_CUT_AWAY && I.parent_organ == target_zone)
			removable_organs |= organ

	var/organ_to_replace = input(user, "Which organ do you want to reattach?") as null|anything in removable_organs
	if(!organ_to_replace)
		return 0

	target.op_stage.current_organ = organ_to_replace
	return ..()

/datum/surgery_step/internal/attach_organ/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins reattaching [target]'s [target.op_stage.current_organ] with \the [tool].", \
	"You start reattaching [target]'s [target.op_stage.current_organ] with \the [tool].")
	target.custom_pain("Someone's digging needles into your [target.op_stage.current_organ]!",1)
	..()

/datum/surgery_step/internal/attach_organ/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>" , \
	"<span class='notice'>You have reattached [target]'s [target.op_stage.current_organ] with \the [tool].</span>")

	var/datum/organ/internal/I = target.internal_organs_by_name[target.op_stage.current_organ]
	if(I && istype(I))
		I.status &= ~ORGAN_CUT_AWAY

/datum/surgery_step/internal/attach_organ/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, damaging the flesh in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(BRUISE, 20)

//////////////////////////////////////////////////////////////////
//						HEART SURGERY							//
//////////////////////////////////////////////////////////////////
// To be finished after some tests.
// /datum/surgery_step/ribcage/heart/cut
//	allowed_tools = list(
//	/obj/item/weapon/scalpel = 100,		\
//	/obj/item/weapon/kitchen/utensil/knife/large = 75,	\
//	/obj/item/weapon/shard = 50, 		\
//	)

//	min_duration = 30
//	max_duration = 40

//	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
//		return ..() && target.op_stage.ribcage == 2

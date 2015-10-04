//Procedures in this file: Generic ribcage opening steps, Removing alien embryo, Fixing internal organs.
//////////////////////////////////////////////////////////////////
//				GENERIC	RIBCAGE SURGERY							//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage
	priority = 2
	can_infect = 1
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == "chest"

/datum/surgery_step/ribcage/saw_ribcage
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 50
	max_duration = 70

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (!istype(target))
			return
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && target.op_stage.ribcage == 0 && (affected.open >= 2 || (target.species.flags & NO_SKIN))

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("[user] begins to cut through [target]'s ribcage with \the [tool].", \
		"You begin to cut through [target]'s ribcage with \the [tool].")
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='notice'>[user] has cut through [target]'s ribcage open with \the [tool].</span>",		\
		"<span class='notice'>You have cut through [target]'s ribcage open with \the [tool].</span>")
		target.op_stage.ribcage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s ribcage with \the [tool]!</span>" , \
		"<span class='warning'>Your hand slips, cracking [target]'s ribcage with \the [tool]!</span>" )
		var/datum/organ/external/affected = target.get_organ(target_zone)
		affected.createwound(CUT, 20)
		affected.fracture()


/datum/surgery_step/ribcage/retract_ribcage
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)

	min_duration = 30
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.ribcage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts to force open the ribcage in [target]'s torso with \the [tool]."
		var/self_msg = "You start to force open the ribcage in [target]'s torso with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "<span class='notice'>[user] forces open [target]'s ribcage with \the [tool].</span>"
		var/self_msg = "<span class='notice'>You force open [target]'s ribcage with \the [tool].</span>"
		user.visible_message(msg, self_msg)
		target.op_stage.ribcage = 2

		// Whoops!
		if(prob(10))
			var/datum/organ/external/affected = target.get_organ(target_zone)
			affected.fracture()

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "<span class='warning'>[user]'s hand slips, breaking [target]'s ribcage!</span>"
		var/self_msg = "<span class='warning'>Your hand slips, breaking [target]'s ribcage!</span>"
		user.visible_message(msg, self_msg)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		affected.createwound(BRUISE, 20)
		affected.fracture()

/datum/surgery_step/ribcage/close_ribcage
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)


	min_duration = 20
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.ribcage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts bending [target]'s ribcage back into place with \the [tool]."
		var/self_msg = "You start bending [target]'s ribcage back into place with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "<span class='notice'>[user] bends [target]'s ribcage back into place with \the [tool].</span>"
		var/self_msg = "<span class='notice'>You bend [target]'s ribcage back into place with \the [tool].</span>"
		user.visible_message(msg, self_msg)

		target.op_stage.ribcage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "<span class='warning'>[user]'s hand slips, bending [target]'s ribcage in a wrong shape!</span>"
		var/self_msg = "<span class='warning'>Your hand slips, bending [target]'s ribcage in a wrong shape!</span>"
		user.visible_message(msg, self_msg)
		var/datum/organ/external/chest/affected = target.get_organ("chest")
		affected.createwound(BRUISE, 20)
		affected.fracture()
		if (prob(40))
			user.visible_message("<span class='warning'>Rib pierces the lung!</span>")
			target.rupture_lung()

/datum/surgery_step/ribcage/mend_ribcage
	allowed_tools = list(
	/obj/item/weapon/bonegel = 100,	\
	/obj/item/weapon/screwdriver = 75
	)

	min_duration = 20
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return ..() && target.op_stage.ribcage == 1

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts applying \the [tool] to [target]'s ribcage."
		var/self_msg = "You start applying \the [tool] to [target]'s ribcage."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "<span class='notice'>[user] applied \the [tool] to [target]'s ribcage.</span>"
		var/self_msg = "<span class='notice'>You applied \the [tool] to [target]'s ribcage.</span>"
		user.visible_message(msg, self_msg)

		target.op_stage.ribcage = 0

//////////////////////////////////////////////////////////////////
//					ALIEN EMBRYO SURGERY						//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage/remove_embryo
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/wirecutters = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 20
	)
	blood_level = 2

	min_duration = 80
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/embryo = 0
		for(var/obj/item/alien_embryo/A in target)
			embryo = 1
			break
		return ..() && embryo && target.op_stage.ribcage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/msg = "[user] starts to pull something out from [target]'s ribcage with \the [tool]."
		var/self_msg = "You start to pull something out from [target]'s ribcage with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("Something hurts horribly in your chest!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		user.visible_message("<span class='warning'>[user] rips the larva out of [target]'s ribcage!</span>",
							 "You rip the larva out of [target]'s ribcage!")

		for(var/obj/item/alien_embryo/A in target)
			A.loc = A.loc.loc


//////////////////////////////////////////////////////////////////
//				CHEST INTERNAL ORGAN SURGERY					//
//////////////////////////////////////////////////////////////////
/datum/surgery_step/ribcage/fix_chest_internal/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/ribcage/fix_chest_internal
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 70
	max_duration = 90

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/is_chest_organ_damaged = 0
		var/datum/organ/external/chest/chest = target.get_organ("chest")
		for(var/datum/organ/internal/I in chest.internal_organs) if(I.damage > 0)
			is_chest_organ_damaged = 1
			break
		return ..() && is_chest_organ_damaged && target.op_stage.ribcage == 2

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/internal/heart/heart = target.internal_organs_by_name["heart"]
		var/datum/organ/internal/lungs/lungs = target.internal_organs_by_name["lungs"]
		var/datum/organ/internal/liver/liver = target.internal_organs_by_name["liver"]
		var/datum/organ/internal/liver/kidney = target.internal_organs_by_name["kidney"]

		if(lungs.damage > 0)
			user.visible_message("[user] starts mending the rupture in [target]'s lungs with \the [tool].", \
			"You start mending the rupture in [target]'s lungs with \the [tool]." )
		if(heart.damage > 0)
			user.visible_message("[user] starts mending the bruises on [target]'s heart with \the [tool].", \
			"You start mending the bruises on [target]'s heart with \the [tool]." )
		if(liver.damage > 0)
			user.visible_message("[user] starts mending the bruises on [target]'s liver with \the [tool].", \
			"You start mending the bruises on [target]'s liver with \the [tool]." )
		if(kidney.damage > 0)
			user.visible_message("[user] starts mending the bruises on [target]'s kidney with \the [tool].", \
			"You start mending the bruises on [target]'s kidney with \the [tool]." )
		target.custom_pain("The pain in your chest is living hell!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/internal/heart/heart = target.internal_organs["heart"]
		var/datum/organ/internal/lungs/lungs = target.internal_organs["lungs"]
		var/datum/organ/internal/liver/liver = target.internal_organs["liver"]
		var/datum/organ/internal/liver/kidney = target.internal_organs["kidney"]

		if(lungs.damage > 0)
			user.visible_message("<span class='notice'>[user] mends the rupture in [target]'s lungs with \the [tool].</span>", \
			"<span class='notice'>You mend the rupture in [target]'s lungs with \the [tool].</span>" )
			lungs.damage = 0

		if(heart.damage > 0)
			user.visible_message("<span class='notice'>[user] treats the bruises on [target]'s heart with \the [tool].</span>", \
			"<span class='notice'>You treats the bruises on [target]'s heart with \the [tool].</span>" )
			heart.damage = 0

		if(liver.damage > 0)
			user.visible_message("<span class='notice'>[user] treats the bruises on [target]'s liver with \the [tool].</span>", \
			"<span class='notice'>You treats the bruises on [target]'s liver with \the [tool].</span>" )
			liver.damage = 0

		if(kidney.damage > 0)
			user.visible_message("<span class='notice'>[user] treats the bruises on [target]'s kidney with \the [tool].</span>", \
			"<span class='notice'>You treats the bruises on [target]'s kidney with \the [tool].</span>" )
			kidney.damage = 0

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/chest/affected = target.get_organ("chest")
		user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s chest with \the [tool]!</span>", \
		"<span class='warning'>Your hand slips, slicing an artery inside [target]'s chest with \the [tool]!</span>")
		affected.createwound(CUT, 20)

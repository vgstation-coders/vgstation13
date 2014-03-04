//Procedures in this file: Gneric surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1
	var/painful=1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone == "eyes")	//there are specific steps for eye surgery
			return 0
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		if (affected.status & ORGAN_DESTROYED)
			return 0
		if (affected.status & ORGAN_ROBOT)
			return 0
		if (affected.status & ORGAN_PEG)
			return 0
		// N3X:  Patient must be sleeping, dead, or unconscious.
		if(!check_anesthesia(target) && painful)
			return 0
		return 1

/datum/surgery_step/generic/cut_open
	allowed_tools = list(
	/obj/item/weapon/scalpel = 100,		\
	/obj/item/weapon/kitchenknife = 75,	\
	/obj/item/weapon/shard = 50, 		\
	)

	min_duration = 90
	max_duration = 110

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 0 && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts the incision on [target]'s [affected.display_name] with \the [tool].", \
		"You start the incision on [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.display_name]!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] has made an incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class=\"notice\">You have made an incision on [target]'s [affected.display_name] with \the [tool].</span>",)
		affected.open = 1
		affected.status |= ORGAN_BLEEDING
		affected.createwound(CUT, 1)
		if (target_zone == "head")
			target.brain_op_stage = 1

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, slicing open [target]'s [affected.display_name] in a wrong spot with \the [tool]!</span>", \
		"<span class=\"rose\">Your hand slips, slicing open [target]'s [affected.display_name] in a wrong spot with \the [tool]!</span>")
		affected.createwound(CUT, 10)

/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
	/obj/item/weapon/hemostat = 100,	\
	/obj/item/weapon/cable_coil = 75, 	\
	/obj/item/device/assembly/mousetrap = 20
	)

	min_duration = 40
	max_duration = 60

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open && (affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool].", \
		"You start clamping bleeders in [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("The pain in your [affected.display_name] is maddening!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] clamps bleeders in [target]'s [affected.display_name] with \the [tool].</span>",	\
		"<span class=\"notice\">You clamp bleeders in [target]'s [affected.display_name] with \the [tool].</span>")
		affected.clamp()
		spread_germs_to_organ(affected, user)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",	\
		"<span class=\"rose\">Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",)
		affected.createwound(CUT, 10)

/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
	/obj/item/weapon/retractor = 100, 	\
	/obj/item/weapon/crowbar = 75,	\
	/obj/item/weapon/kitchen/utensil/fork = 50
	)

	min_duration = 30
	max_duration = 40

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open == 1 && !(affected.status & ORGAN_BLEEDING)

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/msg = "[user] starts to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
		var/self_msg = "You start to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
		if (target_zone == "chest")
			msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
			self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		if (target_zone == "groin")
			msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
			self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		user.visible_message(msg, self_msg)
		target.custom_pain("It feels like the skin on your [affected.display_name] is on fire!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/msg = "<span class=\"notice\">[user] keeps the incision open on [target]'s [affected.display_name] with \the [tool].</span>"
		var/self_msg = "<span class=\"notice\">You keep the incision open on [target]'s [affected.display_name] with \the [tool].</span>"
		if (target_zone == "chest")
			msg = "<span class=\"notice\">[user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
			self_msg = "<span class=\"notice\">You keep the ribcage open on [target]'s torso with \the [tool].</span>"
		if (target_zone == "groin")
			msg = "<span class=\"notice\">[user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
			self_msg = "<span class=\"notice\">You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
		user.visible_message(msg, self_msg)
		affected.open = 2

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		var/msg = "<span class=\"rose\">[user]'s hand slips, tearing the edges of incision on [target]'s [affected.display_name] with \the [tool]!</span>"
		var/self_msg = "<span class=\"rose\">Your hand slips, tearing the edges of incision on [target]'s [affected.display_name] with \the [tool]!</span>"
		if (target_zone == "chest")
			msg = "<span class=\"rose\">[user]'s hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
			self_msg = "<span class=\"rose\">Your hand slips, damaging several organs [target]'s torso with \the [tool]!</span>"
		if (target_zone == "groin")
			msg = "<span class=\"rose\">[user]'s hand slips, damaging several organs [target]'s lower abdomen with \the [tool]</span>"
			self_msg = "<span class=\"rose\">Your hand slips, damaging several organs [target]'s lower abdomen with \the [tool]!</span>"
		user.visible_message(msg, self_msg)
		target.apply_damage(12, BRUTE, affected)

/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/weapon/cautery = 100,			\
	/obj/item/clothing/mask/cigarette = 75,	\
	/obj/item/weapon/lighter = 50,			\
	/obj/item/weapon/weldingtool = 25
	)

	min_duration = 70
	max_duration = 100

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return ..() && affected.open && target_zone != "mouth"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool]." , \
		"You are beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Your [affected.display_name] is being burned!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] cauterizes the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class=\"notice\">You cauterize the incision on [target]'s [affected.display_name] with \the [tool].</span>")
		affected.open = 0
		affected.germ_level = 0
		affected.status &= ~ORGAN_BLEEDING

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>", \
		"<span class=\"rose\">Your hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>")
		target.apply_damage(3, BURN, affected)

/datum/surgery_step/generic/cut_limb
	allowed_tools = list(
	/obj/item/weapon/circular_saw = 100, \
	/obj/item/weapon/hatchet = 75
	)

	min_duration = 110
	max_duration = 160

	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		if (target_zone == "eyes")	//there are specific steps for eye surgery
			return 0
		if (!hasorgans(target))
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		if (affected == null)
			return 0
		if (affected.status & ORGAN_DESTROYED)
			return 0
		return target_zone != "chest" && target_zone != "groin" && target_zone != "head"

	begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("[user] is beginning to cut off [target]'s [affected.display_name] with \the [tool]." , \
		"You are beginning to cut off [target]'s [affected.display_name] with \the [tool].")
		target.custom_pain("Your [affected.display_name] is being ripped apart!",1)
		..()

	end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"notice\">[user] cuts off [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class=\"notice\">You cut off [target]'s [affected.display_name] with \the [tool].</span>")
		affected.droplimb(1,0)

	fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		user.visible_message("<span class=\"rose\">[user]'s hand slips, sawwing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>", \
		"<span class=\"rose\">Your hand slips, sawwing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
		affected.createwound(CUT, 30)
		affected.fracture()
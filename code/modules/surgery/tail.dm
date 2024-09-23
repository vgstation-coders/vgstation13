/datum/surgery_step/tail
	var/tail_present = TRUE

/datum/surgery_step/tail/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/tail/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	var/datum/organ/external/groin/groin = target.get_organ(LIMB_GROIN)
	if(target_zone != LIMB_GROIN)
		return FALSE
	if(!tail)
		return FALSE
	if(tail_present && (tail.status & ORGAN_DESTROYED))
		return FALSE
	if(!tail_present && !(tail.status & ORGAN_DESTROYED))
		return FALSE
	if(!groin || (groin.status & ORGAN_DESTROYED))
		return FALSE
	if(!check_anesthesia(target))
		return -1
	return TRUE

/datum/surgery_step/tail/clamp_vessels
	allowed_tools = list(
		/obj/item/tool/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/weapon/talisman = 70,
		/obj/item/device/assembly/mousetrap = 20,
		)
	duration = 3 SECONDS

/datum/surgery_step/tail/clamp_vessels/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message("[user] starts [tail.open == 0 ? "" : "un"]clamping vessels in [target]'s [tail.display_name] with \the [tool].", \
	"You start [tail.open == 0 ? "" : "un"]clamping vessels in [target]'s [tail.display_name] with \the [tool].")
	target.custom_pain("The pain in your [tail.display_name] is maddening!", 1, scream=TRUE)

/datum/surgery_step/tail/clamp_vessels/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message(span_notice("[user] [tail.open == 0 ? "" : "un"]clamps vessels in [target]'s [tail.display_name] with \the [tool]."),	\
	span_notice("You [tail.open == 0 ? "" : "un"]clamp vessels in [target]'s [tail.display_name] with \the [tool]."))
	tail.open = !tail.open

/datum/surgery_step/tail/clamp_vessels/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(LIMB_GROIN)
	user.visible_message(span_notice("[user]'s hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!"),	\
	span_warning("Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!"),)
	affected.createwound(CUT, 10)

/datum/surgery_step/tail/amputate
	allowed_tools = list(
		/obj/item/tool/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
		/obj/item/weapon/hatchet = 75,
		)
	duration = 11 SECONDS
	priority = 2

/datum/surgery_step/tail/amputate/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/datum/organ/external/tail/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	if(!(tail.open == 1))
		return FALSE
	return TRUE

/datum/surgery_step/tail/amputate/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message("[user] is beginning to cut off [target]'s [tail.display_name] with \the [tool]." , \
	"You are beginning to cut off [target]'s [tail.display_name] with \the [tool].")
	target.custom_pain("Your [tail.display_name] is being ripped apart!",1, scream=TRUE)

/datum/surgery_step/tail/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message(span_notice("[user] cuts off [target]'s [tail.display_name] with \the [tool]."), \
	span_notice("You cut off [target]'s [tail.display_name] with \the [tool]."))
	tail.open = 0 //Resets surgery status on limb, should prevent conflicting/phantom surgery
	tail.droplimb(TRUE, FALSE)

/datum/surgery_step/tail/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(LIMB_GROIN)
	user.visible_message(span_warning("[user]'s hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!"), \
	span_warning("Your hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!"))
	affected.createwound(CUT, 30)
	affected.fracture()

/datum/surgery_step/tail/prepare_attach
	tail_present = FALSE
	allowed_tools = list(
		/obj/item/tool/retractor = 100,
		/obj/item/tool/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50,
		)
	duration = 8 SECONDS

/datum/surgery_step/tail/prepare_attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/datum/organ/external/groin/groin = target.get_organ(LIMB_GROIN)
	if(!(groin.open == 0))
		return FALSE
	return TRUE

/datum/surgery_step/tail/prepare_attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message("[user] is beginning to reposition flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].", \
	"You start repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool].")

/datum/surgery_step/tail/prepare_attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message(span_notice("[user] has finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool]."),	\
	span_notice("You have finished repositioning flesh and nerve endings where [target]'s [affected.display_name] used to be with [tool]."))
	affected.status |= ORGAN_ATTACHABLE

/datum/surgery_step/tail/prepare_attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	if(affected.parent)
		affected = affected.parent
		user.visible_message(span_warning("[user]'s hand slips, tearing flesh on [target]'s [affected.display_name]!"), \
		span_warning("Your hand slips, tearing flesh on [target]'s [affected.display_name]!"))
		target.apply_damage(10, BRUTE, affected)

/datum/surgery_step/tail/attach
	allowed_tools = list(
		/obj/item/robot_parts/tail = 100,
		/obj/item/organ/external/tail = 100,
		)
	duration = 8 SECONDS
	tail_present = FALSE

/datum/surgery_step/tail/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!..())
		return FALSE
	var/datum/organ/external/tail/tail = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	if(!(tail.status & ORGAN_ATTACHABLE))
		return FALSE
	return TRUE

/datum/surgery_step/tail/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message("[user] starts attaching [tool] where [target]'s [affected.display_name] used to be.", \
	"You start attaching [tool] where [target]'s [affected.display_name] used to be.")

/datum/surgery_step/tail/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_cosmetic_organ(COSMETIC_ORGAN_TAIL)
	user.visible_message(span_notice("[user] has attached [tool] where [target]'s [affected.display_name] used to be."),	\
	span_notice("You have attached [tool] where [target]'s [affected.display_name] used to be."))
	affected.attach(tool)

/datum/surgery_step/tail/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(LIMB_GROIN)
	user.visible_message(span_warning("[user]'s hand slips, damaging connectors on [target]'s [affected.display_name]!"), \
	span_warning("Your hand slips, damaging connectors on [target]'s [affected.display_name]!"))
	target.apply_damage(10, BRUTE, affected)

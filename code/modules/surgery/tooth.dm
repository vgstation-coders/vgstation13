//Procedures in this file: Tooth replacement surgery, Tooth extraction surgery
//////////////////////////////////////////////////////////////////
//						TOOTH REPLACEMENT SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/tooth_replace
	priority = 10
	can_infect = 0

/datum/surgery_step/tooth_replace/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (!affected)
		return 0
	return target_zone == TARGET_MOUTH


///////MEND ROOTS///////
/datum/surgery_step/tooth_replace/mend_roots
	allowed_tools = list(
		/obj/item/tool/FixOVein = 100,
		/obj/item/stack/cable_coil = 50,
		)

	duration = 10 SECONDS

/datum/surgery_step/tooth_replace/mend_roots/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.face == 1


/datum/surgery_step/tooth_replace/mend_roots/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts mending the blood vessels and nerves in the empty sockets of [target]'s jaw with \the [tool].", \
	"You start mending the blood vessels and nerves in the sockets of [target]'s jaw with \the [tool].")
	..()

/datum/surgery_step/tooth_replace/mend_roots/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] mends the sockets of [target]'s jaw with \the [tool].</span>", \
	"<span class='notice'>You mend [target]'s dental sockets with \the [tool].</span>")
	target.op_stage.tooth_replace = 1

/datum/surgery_step/tooth_replace/mend_roots/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, ripping a bare nerve out of [target]'s jaw with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, ripping a bare nerve out of [user]'s jaw with \the [tool]!</span>")
	target.apply_damage(5, BRUTE, affected)



////////ADD NEW TEETH//////
/datum/surgery_step/tooth_replace/new_teeth
	allowed_tools = list(
		/obj/item/stack/teeth = 100,
		)

	duration = 6 SECONDS

/datum/surgery_step/tooth_replace/new_teeth/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/teeth_missing

	var/datum/butchering_product/teeth/J = locate(/datum/butchering_product/teeth) in target.butchering_drops
	if(!istype(J))
		return 0
	if(J.amount < J.initial_amount)
		teeth_missing = 1
	else
		to_chat(user, "<span class='warning'>\The [target] already has a full mouth of teeth.</span>")
		return 0

	return ..() && target.op_stage.tooth_replace == 1 && teeth_missing

/datum/surgery_step/tooth_replace/new_teeth/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts carefully planting \a [tool] in [target]'s jaw.", \
	"You start carefully planting \a [tool] in [target]'s jaw.")
	..()

/datum/surgery_step/tooth_replace/new_teeth/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished planting \a [tool] in [target]'s jaw.</span>",	\
	"<span class='notice'>You have finished planting \a [tool] in [target]'s jaw.</span>")
	var/obj/item/stack/teeth/T = tool
	var/datum/butchering_product/teeth/J = locate(/datum/butchering_product/teeth) in target.butchering_drops
	J.amount += 1
	T.amount -= 1
	if(T.amount <= 0)
		user.before_take_item(T)


/datum/surgery_step/tooth_replace/new_teeth/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s gums with \a [tool]!</span>", \
	"<span class='warning'>Your hand slips, cutting [target]'s gums with \a [tool]!</span>")
	target.apply_damage(5, BRUTE, affected)


//////////////////////////////////////////////////////////////////
//						TOOTH EXTRACTION SURGERY							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/tooth_extract
	priority = 5
	can_infect = 0

/datum/surgery_step/tooth_extract/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (!affected)
		return 0
	return target_zone == TARGET_MOUTH


///////SET JAWS///////
/datum/surgery_step/tooth_extract/set_jaws
	allowed_tools = list(
		/obj/item/tool/bonesetter = 100,
		"wrench" = 75,
		)

	duration = 6 SECONDS

/datum/surgery_step/tooth_extract/set_jaws/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..()


/datum/surgery_step/tooth_extract/set_jaws/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts setting [target]'s jaw in place with \the [tool] to prepare for tooth extraction", \
	"You start setting [target]'s jaw in place with \the [tool] to prepare for tooth extraction.")
	..()

/datum/surgery_step/tooth_extract/set_jaws/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] locks [target]'s jaw in place with \the [tool].</span>", \
	"<span class='notice'>You lock [target]'s jaw in place with \the [tool].</span>")
	target.op_stage.tooth_extract = 1

/datum/surgery_step/tooth_extract/set_jaws/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, painfully popping [target]'s jaw with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, painfully popping [user]'s jaw with \the [tool]!</span>")
	target.apply_damage(5, BRUTE, affected)




	///////EXTRACT TOOTH///////
/datum/surgery_step/tooth_extract/pull_tooth
	allowed_tools = list(
		/obj/item/tool/hemostat = 100,
		"wirecutter" = 50,
		/obj/item/device/assembly/mousetrap = 10,	//I don't know. Don't ask me. But I'm leaving it because hilarity.
		)

	duration = 10 SECONDS

/datum/surgery_step/tooth_extract/pull_tooth/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)

	var/has_teeth

	var/datum/butchering_product/teeth/J = locate(/datum/butchering_product/teeth) in target.butchering_drops
	if(!istype(J))
		return 0
	if(J.amount > 0)
		has_teeth = 1
	else
		to_chat(user, "<span class='warning'>\The [target] doesn't have any teeth to pull.</span>")
		return 0

	return ..() && target.op_stage.tooth_extract == 1 && has_teeth


/datum/surgery_step/tooth_extract/pull_tooth/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts pulling one of [target]'s teeth out with \the [tool].", \
	"You start pulling one of [target]'s teeth out with \the [tool].")
	..()

/datum/surgery_step/tooth_extract/pull_tooth/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] pulls out one of [target]'s teeth with \the [tool].</span>", \
	"<span class='notice'>You pull out one of [target]'s teeth with \the [tool].</span>")

	var/datum/butchering_product/teeth/T = locate(/datum/butchering_product/teeth) in target.butchering_drops
	if(!istype(T) || T.amount == 0)
		return
	T.spawn_result(get_turf(target), target, 1)


/datum/surgery_step/tooth_extract/pull_tooth/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, dropping the tooth and scraping the gums of [target] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, dropping the tooth and scraping the gums of [user] with \the [tool]!</span>")
	target.apply_damage(5, BRUTE, affected)




///////RESET JAWS///////
/datum/surgery_step/tooth_extract/reset
	allowed_tools = list(
		/obj/item/tool/bonesetter = 100,
		"wrench" = 75,
		)

	duration = 6 SECONDS

/datum/surgery_step/tooth_extract/reset/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.tooth_extract == 1


/datum/surgery_step/tooth_extract/reset/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts putting [target]'s jaw back into place with \the [tool].", \
	"You start putting [target]'s jaw back into place with \the [tool].")
	..()

/datum/surgery_step/tooth_extract/reset/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] unlocks [target]'s jaw with \the [tool].</span>", \
	"<span class='notice'>You unlock [target]'s jaw with \the [tool].</span>")
	target.op_stage.tooth_extract = 0

/datum/surgery_step/tooth_extract/reset/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, painfully popping [target]'s jaw with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, painfully popping [user]'s jaw with \the [tool]!</span>")
	target.apply_damage(5, BRUTE, affected)

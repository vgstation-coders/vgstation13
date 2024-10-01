//The proceeding is a minor surgery for anal cheek removal.
///////////////////////////////////////////////////////////
////                                      BUTT REMOVAL ////
///////////////////////////////////////////////////////////

/datum/surgery_step/butt
	priority = 1 //this is more important than anything else!
	can_infect = 0
	blood_level = 1
/datum/surgery_step/butt/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return target_zone == LIMB_GROIN && hasorgans(target)


//And thus begins the madness.

/////SLICE CHEEK////////
/datum/surgery_step/butt/slice_cheek
	allowed_tools = list(
		/obj/item/tool/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75, \
		/obj/item/weapon/hatchet = 75,
		)

	duration = 5 SECONDS

/datum/surgery_step/butt/slice_cheek/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == SURGERY_HAS_A_BUTT && istype(target)


/datum/surgery_step/butt/slice_cheek/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to slice [target]'s ass cheek with \the [tool].", \
	"You begin to slice [target]'s ass cheek with \the [tool].")
	target.custom_pain("You haven't felt a pain like this since college!",1, scream=TRUE)
	..()


/datum/surgery_step/butt/slice_cheek/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has sliced through [target]'s ass cheek with \the [tool].</span>",		\
	"<span class='notice'>You have sliced through [target]'s ass cheek with \the [tool].</span>")
	target.op_stage.butt = SURGERY_BUTT_CUT



/datum/surgery_step/butt/slice_cheek/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting [target]'s ass with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cutting [target]'s ass with \the [tool]!</span>" )
	target.apply_damage(max(10, tool.force), BRUTE, LIMB_GROIN)



///////sepARATE ANUS///////
/datum/surgery_step/butt/seperate_anus/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/butt/seperate_anus
	allowed_tools = list(
		/obj/item/tool/scalpel = 100,
		/obj/item/weapon/melee/blood_dagger = 90,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		/obj/item/soulstone/gem = 0,
		/obj/item/soulstone = 50,
		)

	duration = 8 SECONDS

/datum/surgery_step/butt/seperate_anus/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.butt == SURGERY_BUTT_CUT


/datum/surgery_step/butt/seperate_anus/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts shortening the end of [target]'s anus with \the [tool].", \
	"You start shortening the end of [target]'s anus with \the [tool].")
	target.custom_pain("It feels like that hamster is chewing its way out!",1, scream=TRUE)
	..()


/datum/surgery_step/butt/seperate_anus/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] shortens the end of [target]'s anus with \the [tool].</span>",	\
	"<span class='notice'>You shorten [target]'s anus with \the [tool].</span>")
	target.op_stage.butt = SURGERY_SEPARATE_ANUS


/datum/surgery_step/butt/seperate_anus/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, cutting a vein in [target]'s anus with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, cutting a vein in [target]'s anus with \the [tool]!</span>")
	target.apply_damage(50, BRUTE, LIMB_GROIN, 1)



//////SAW HIP///////
/datum/surgery_step/butt/saw_hip
	allowed_tools = list(
		/obj/item/tool/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
		/obj/item/weapon/hatchet = 75,
		)

	duration = 5 SECONDS

/datum/surgery_step/butt/saw_hip/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == SURGERY_SEPARATE_ANUS

/datum/surgery_step/butt/saw_hip/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cut off ends of [target]'s hip with \the [tool].", \
	"You begin to cut off ends of [target]'s hip with \the [tool].")
	target.custom_pain("THE PAIN!",1, scream=TRUE)
	..()

/datum/surgery_step/butt/saw_hip/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finishes cutting [target]'s hip with \the [tool].</span>",		\
	"<span class='notice'>You have cut [target]'s hip with \the [tool].</span>")
	target.op_stage.butt = SURGERY_SAW_HIP

/datum/surgery_step/butt/saw_hip/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, cracking [target]'s hip with \the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, cracking [target]'s hip with \the [tool]!</span>" )
	target.apply_damage(max(10, tool.force), BRUTE, LIMB_GROIN)



///////CAUTERIZE BUTT/////////
/datum/surgery_step/butt/cauterize_butt/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_hot())
		return 0

/datum/surgery_step/butt/cauterize_butt
	allowed_tools = list(
		/obj/item/tool/cautery = 100,
		/obj/item/tool/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/tool/weldingtool = 25,
		)

	duration = 5 SECONDS

/datum/surgery_step/butt/cauterize_butt/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == SURGERY_SAW_HIP

/datum/surgery_step/butt/cauterize_butt/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cauterize [target]'s ass with \the [tool].", \
	"You begin to cauterize [target]'s ass with \the [tool].")
	target.custom_pain("IT BUUURNS!",1, scream=TRUE)
	..()

/datum/surgery_step/butt/cauterize_butt/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finishes cauterizing [target]'s ass with \the [tool].</span>",		\
	"<span class='notice'>You have cauterized [target]'s ass with \the [tool].</span>")
	var/obj/item/clothing/head/butt/B = new(target.loc)
	B.transfer_buttdentity(target)
	target.op_stage.butt = SURGERY_NO_BUTT

/datum/surgery_step/butt/cauterize_butt/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[target] lets out a small fart, which gets set alight with [user]'s [tool]!</span>" , \
	"<span class='warning'>[target] farts into the open flame, burning his anus!</span>" )
	target.apply_damage(max(10, tool.force), BURN, LIMB_GROIN)
	playsound(target, 'sound/effects/holler.ogg', 50, 1)


//////////////////////////////////////////////////////////////////
//						BUTT REPLACE							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/butt_replace
	priority = 2 //this is more important than anything else!
	can_infect = 0

/datum/surgery_step/butt_replace/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return target_zone == LIMB_GROIN && hasorgans(target)


/////PULL FLESH////////
/datum/surgery_step/butt_replace/peel
	allowed_tools = list(
		/obj/item/tool/retractor = 100,
		/obj/item/tool/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50,
		)

	duration = 8 SECONDS

/datum/surgery_step/butt_replace/peel/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.butt_replace == SURGERY_BEGIN_BUTT_REPLACE && target.op_stage.butt == SURGERY_NO_BUTT && istype(target)


/datum/surgery_step/butt_replace/peel/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] peels back tattered flesh where [target]'s butt used to be with \the [tool].", \
	"You start peeling back tattered flesh where [target]'s butt used to be with \the [tool].")
	..()

/datum/surgery_step/butt_replace/peel/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] peels back tattered flesh where [target]'s butt used to be with \the [tool].</span>",		\
	"<span class='notice'>You peel back tattered flesh where [target]'s butt used to be with \the [tool].</span>")
	target.op_stage.butt_replace = SURGERY_BUTT_PEEL

/datum/surgery_step/butt_replace/peel/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, ripping [target]'s [affected.display_name] open!</span>", \
	"<span class='warning'>Your hand slips,  ripping [target]'s [affected.display_name] open!</span>")
	target.apply_damage(10, BRUTE, affected)

//////REPAIR HIPS///////
/datum/surgery_step/butt_replace/hips
	allowed_tools = list(
		/obj/item/tool/bonegel = 100,
		/obj/item/tool/bonesetter/bone_mender = 100,
		"screwdriver" = 75,
		)

	duration = 5 SECONDS

/datum/surgery_step/butt_replace/hips/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.butt_replace == SURGERY_BUTT_PEEL && istype(target)


/datum/surgery_step/butt_replace/hips/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts to mend [target]'s shortened hip bones with \the [tool].", \
	"You start to mend [target]'s shortened hip bones with with \the [tool].")
	..()

/datum/surgery_step/butt_replace/hips/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has restored [target]'s hip bones to their original state with \the [tool].</span>",	\
	"<span class='notice'>You have restored [target]'s hip bones to their original state with \the [tool].</span>")
	target.op_stage.butt_replace = SURGERY_REPLACE_HIP

/datum/surgery_step/bbutt_replace/hips/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] on the delicate tissues in [target]'s hindquarters!</span>", \
	"<span class='warning'>Your hand slips, smearing [tool] on the delicate tissues in [target]'s hindquarters!</span>")
	target.apply_damage(10, BRUTE, affected)


//////SHAPE///////
/datum/surgery_step/butt_replace/shape
	allowed_tools = list(
		/obj/item/tool/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 10,	//ok chinsky
		)

	duration = 8 SECONDS

/datum/surgery_step/butt_replace/shape/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt_replace == SURGERY_REPLACE_HIP && istype(target)


/datum/surgery_step/butt_replace/shape/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] is beginning to reshape [target]'s anus and gluteal tendons with \the [tool].", \
	"You start to reshape [target]'s anus and gluteal tendons with \the [tool].")
	..()

/datum/surgery_step/butt_replace/shape/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has finished repositioning flesh and tissue to something anatomically recognizable where [target]'s butt used to be with \the [tool].</span>",	\
	"<span class='notice'>You have finished repositioning flesh and tissue to something anatomically recognizable where [target]'s butt used to be with \the [tool].</span>")
	target.op_stage.butt_replace = SURGERY_BUTT_SHAPE

/datum/surgery_step/butt_replace/shape/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, further rending flesh on [target]'s backside!</span>", \
	"<span class='warning'>Your hand slips, further rending flesh on [target]'s backside!</span>")
	target.apply_damage(10, BRUTE, affected)

//////ATTACH//////
/datum/surgery_step/butt_replace/attach
	allowed_tools = list(
		/obj/item/clothing/head/butt = 100,
		)

	duration = 8 SECONDS

/datum/surgery_step/butt_replace/attach/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target.op_stage.butt_replace == SURGERY_BUTT_SHAPE && istype(target)

/datum/surgery_step/butt_replace/attach/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts attaching [tool] to [target]'s reshaped backside.", \
	"You start attaching [tool] to [target]'s reshaped backside.")

/datum/surgery_step/butt_replace/attach/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has attached [target]'s new butt to the body.</span>",	\
	"<span class='notice'>You have attached [target]'s new butt to the body.</span>")

	target.op_stage.butt = SURGERY_SAW_HIP
	target.op_stage.butt_replace = SURGERY_END_BUTT_REPLACE
	affected.open = 1
	affected.status |= ORGAN_BLEEDING

	var/obj/item/clothing/head/butt/B = tool
	user.u_equip(B,1)
	qdel(B)


/datum/surgery_step/butt_replace/attach/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, damaging connectors on [target]'s backside!</span>", \
	"<span class='warning'>Your hand slips, damaging connectors on [target]'s backside!</span>")
	target.apply_damage(10, BRUTE, affected)


///////CAUTERIZE NEW BUTT/////////
/datum/surgery_step/butt_replace/cauterize/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_hot())
		return 0

/datum/surgery_step/butt_replace/cauterize
	allowed_tools = list(
		/obj/item/tool/cautery = 100,
		/obj/item/tool/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/tool/weldingtool = 25,
		)

	duration = 5 SECONDS

/datum/surgery_step/butt_replace/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == SURGERY_SAW_HIP && target.op_stage.butt_replace

/datum/surgery_step/butt_replace/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cauterize [target]'s ass with \the [tool].", \
	"You begin to cauterize [target]'s ass with \the [tool].")
	..()

/datum/surgery_step/butt_replace/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] finishes cauterizing [target]'s ass with \the [tool].</span>",		\
	"<span class='notice'>You have cauterized [target]'s ass with \the [tool].</span>")
	target.op_stage.butt_replace = SURGERY_HAS_A_BUTT
	affected.open = 0
	affected.clamp_wounds()

/datum/surgery_step/butt_replace/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, burning the flesh around [target]'s butt with /the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, burning the flesh around [target]'s butt with /the [tool]!</span>" )
	target.apply_damage(max(10, tool.force), BURN, LIMB_GROIN)


//why god. //I know right.

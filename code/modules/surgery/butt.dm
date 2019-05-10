//The proceeding is a minor surgery for anal cheek removal.
///////////////////////////////////////////////////////////
////                                      BUTT REMOVAL ////
///////////////////////////////////////////////////////////

/datum/surgery_step/butt
	priority = 1 //this is more important than anything else!
	can_infect = 0
	blood_level = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == LIMB_GROIN && hasorgans(target)


//And thus begins the madness.

/////SLICE CHEEK////////
/datum/surgery_step/butt/slice_cheek
	allowed_tools = list(
		/obj/item/weapon/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75, \
		/obj/item/weapon/hatchet = 75,
		)

	min_duration = 50
	max_duration = 70

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
/datum/surgery_step/butt/seperate_anus/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/butt/seperate_anus
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	min_duration = 80
	max_duration = 100

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
		/obj/item/weapon/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
		/obj/item/weapon/hatchet = 75,
		)

	min_duration = 50
	max_duration = 70

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
/datum/surgery_step/butt/cauterize_butt/tool_quality(obj/item/tool)
	if(tool.is_hot())
		for (var/T in allowed_tools)
			if (istype(tool,T))
				return allowed_tools[T]
	return 0
/datum/surgery_step/butt/cauterize_butt
	allowed_tools = list(
		/obj/item/weapon/cautery = 100,
		/obj/item/weapon/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/weapon/weldingtool = 25,
		)

	min_duration = 50
	max_duration = 70

/datum/surgery_step/butt/cauterize_butt/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == SURGERY_SAW_HIP

/datum/surgery_step/butt/cauterize_butt/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cauterize [target]'s ass with \the [tool].", \
	"You begin to cauterize [target]'s ass with \the [tool].")
	target.custom_pain("IT BUURNS!",1, scream=TRUE)
	..()

/datum/surgery_step/butt/cauterize_butt/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finishes cauterizing [target]'s ass with \the [tool].</span>",		\
	"<span class='notice'>You have cauterized [target]'s ass with \the [tool].</span>")
	var/obj/item/clothing/head/butt/B = new(target.loc)
	B.transfer_buttdentity(target)
	target.op_stage.butt = 4

/datum/surgery_step/butt/cauterize_butt/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[target] lets out a small fart, which gets set alight with [user]'s [tool]!</span>" , \
	"<span class='warning'>[target] farts into the open flame, burning his anus!</span>" )
	target.apply_damage(max(10, tool.force), BURN, LIMB_GROIN)
	playsound(target, 'sound/effects/holler.ogg', 50, 1)


//////////////////////////////////////////////////////////////////
//						BUTT REPLACE							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/butt_replace
	/datum/surgery_step/butt_replace/priority = 2 //this is more important than anything else!
	/datum/surgery_step/butt_replace/can_infect = 0
	/datum/surgery_step/butt_replace/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		return target_zone == LIMB_GROIN && hasorgans(target)


/////PULL FLESH////////
/datum/surgery_step/butt_replace/peel
	allowed_tools = list(
		/obj/item/weapon/retractor = 100,
		/obj/item/weapon/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50,
		)

	min_duration = 80
	max_duration = 100

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
		/obj/item/weapon/bonegel = 100,
		/obj/item/weapon/bonesetter/bone_mender = 100,
		/obj/item/weapon/screwdriver = 75,
		)

	min_duration = 50
	max_duration = 60

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
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/device/assembly/mousetrap = 10,	//ok chinsky
		)

	min_duration = 80
	max_duration = 100

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

	min_duration = 80
	max_duration = 100

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
/datum/surgery_step/butt_replace/cauterize/tool_quality(obj/item/tool)
	if(tool.is_hot())
		for (var/T in allowed_tools)
			if (istype(tool,T))
				return allowed_tools[T]
	return 0
/datum/surgery_step/butt_replace/cauterize
	allowed_tools = list(
		/obj/item/weapon/cautery = 100,
		/obj/item/weapon/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/weapon/weldingtool = 25,
		)

	min_duration = 50
	max_duration = 70

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
	affected.clamp()

/datum/surgery_step/butt_replace/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='warning'>[user]'s hand slips, burning the flesh around [target]'s butt with /the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, burning the flesh around [target]'s butt with /the [tool]!</span>" )
	target.apply_damage(max(10, tool.force), BURN, LIMB_GROIN)


//why god. //I know right.

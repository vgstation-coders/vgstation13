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
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == 0 && istype(target)


/datum/surgery_step/butt/slice_cheek/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to slice [target]'s ass cheek with \the [tool].", \
	"You begin to slice [target]'s ass cheek with \the [tool].")
	target.custom_pain("You haven't felt a pain like this since college!",1)
	..()


/datum/surgery_step/butt/slice_cheek/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] has sliced through [target]'s ass cheek with \the [tool].</span>",		\
	"<span class='notice'>You have sliced through [target]'s ass cheek with \the [tool].</span>")
	target.op_stage.butt = 1



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
	return ..() && target.op_stage.butt == 1


/datum/surgery_step/butt/seperate_anus/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] starts shortening the end of [target]'s anus with \the [tool].", \
	"You start shortening the end of [target]'s anus with \the [tool].")
	target.custom_pain("It feels like that hamster is chewing its way out!",1)
	..()


/datum/surgery_step/butt/seperate_anus/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] shortens the end of [target]'s anus with \the [tool].</span>",	\
	"<span class='notice'>You shorten [target]'s anus with \the [tool].</span>")
	target.op_stage.butt = 2


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
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == 2

/datum/surgery_step/butt/saw_hip/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cut off ends of [target]'s hip with \the [tool].", \
	"You begin to cut off ends of [target]'s hip with \the [tool].")
	target.custom_pain("THE PAIN!",1)
	..()

/datum/surgery_step/butt/saw_hip/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("<span class='notice'>[user] finishes cutting [target]'s hip with \the [tool].</span>",		\
	"<span class='notice'>You have cut [target]'s hip with \the [tool].</span>")
	target.op_stage.butt = 3

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
	return ..() && target_zone == LIMB_GROIN && target.op_stage.butt == 3

/datum/surgery_step/butt/cauterize_butt/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	user.visible_message("[user] begins to cauterize [target]'s ass with \the [tool].", \
	"You begin to cauterize [target]'s ass with \the [tool].")
	target.custom_pain("IT BUURNS!",1)
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
	playsound(get_turf(src), 'sound/effects/holler.ogg', 50, 1)



//why god. //I know right.

//Procedures in this file: Putting items in body cavity. Implant removal. Items removal.

//////////////////////////////////////////////////////////////////
//					ITEM PLACEMENT SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity
	priority = 1
	can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return (affected.open == (affected.encased ? 3 : 2) || (!affected.encased ? (target.species.anatomy_flags & NO_SKIN) : 0)) && !(affected.status & ORGAN_BLEEDING)

/datum/surgery_step/cavity/proc/get_max_wclass(datum/organ/external/affected)
	switch (affected.name)
		if (LIMB_HEAD)
			return 1
		if (LIMB_CHEST)
			return 3
		if (LIMB_GROIN)
			return 2
	return 0

/datum/surgery_step/cavity/proc/get_cavity(datum/organ/external/affected)
	switch (affected.name)
		if (LIMB_HEAD)
			return "cranial"
		if (LIMB_CHEST)
			return "thoracic"
		if (LIMB_GROIN)
			return "abdominal"
	return ""



//////MAKE SPACE//////
/datum/surgery_step/cavity/make_space
	allowed_tools = list(
		/obj/item/weapon/surgicaldrill = 100,
		/obj/item/weapon/pen = 75,
		/obj/item/stack/rods = 50,
		)

	duration = 6 SECONDS

/datum/surgery_step/cavity/make_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!istype(target))
		to_chat(user, "<span class='warning'>This isn't a human!.</span>")
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && !affected.cavity && !affected.hidden

/datum/surgery_step/cavity/make_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].",
	"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1, scream=TRUE)
	affected.cavity = 1
	..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>",
	"<span class='notice'>You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].</span>" )

/datum/surgery_step/cavity/make_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)



///////CLOSE SPACE/////
/datum/surgery_step/cavity/close_space/tool_quality(obj/item/tool)
	if(tool.is_hot())
		for (var/T in allowed_tools)
			if (istype(tool,T))
				return allowed_tools[T]
	return 0
/datum/surgery_step/cavity/close_space
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/cautery = 100,
		/obj/item/weapon/scalpel/laser = 100,
		/obj/item/clothing/mask/cigarette = 75,
		/obj/item/weapon/lighter = 50,
		/obj/item/weapon/weldingtool = 25,
		)

	duration = 6 SECONDS

/datum/surgery_step/cavity/close_space/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && affected.cavity

/datum/surgery_step/cavity/close_space/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].",
	"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1, scream=TRUE)
	affected.cavity = 0
	..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>",
	"<span class='notice'>You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool].</span>" )

/datum/surgery_step/cavity/close_space/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)



/////PLACE ITEM//////
/datum/surgery_step/cavity/place_item
	priority = 0
	allowed_tools = list(
		/obj/item = 100,
		)

	duration = 8 SECONDS

/datum/surgery_step/cavity/place_item/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!istype(target))
		to_chat(user, "<span class='warning'>This isn't a human!.</span>")
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/can_fit = !affected.hidden && affected.cavity && tool.w_class <= get_max_wclass(affected)
	return ..() && can_fit

/datum/surgery_step/cavity/place_item/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.",
	"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity." )
	target.custom_pain("The pain in your chest is living hell!",1, scream=TRUE)
	..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)

	user.visible_message("<span class='notice'>[user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>",
	"<span class='notice'>You put \the [tool] inside [target]'s [get_cavity(affected)] cavity.</span>" )
	if (tool.w_class > get_max_wclass(affected)/2 && prob(50))
		to_chat(user, "<span class='warning'>You tear some vessels trying to fit such big object in this cavity.")
		var/datum/wound/internal_bleeding/I = new (15)
		affected.wounds += I
		affected.owner.custom_pain("You feel something rip in your [affected.display_name]!", 1, scream=TRUE)
	user.drop_item()
	affected.hidden = tool
	tool.forceMove(target)

	if(istype(tool, /obj/item/weapon/implant))
		var/obj/item/weapon/implant/timp = tool
		timp.part = affected
		affected.implants += timp
		if(timp.implanted(target, user))
			timp.forceMove(target)
			timp.imp_in = target
			timp.implanted = 1
			timp.part = affected
	affected.cavity = 0

/datum/surgery_step/cavity/place_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>",
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)

//////////////////////////////////////////////////////////////////
//					IMPLANT/ITEM REMOVAL SURGERY						//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/cavity/implant_removal
	allowed_tools = list(
		/obj/item/weapon/hemostat = 100,
		/obj/item/weapon/wirecutters = 75,
		/obj/item/weapon/talisman = 70,
		/obj/item/weapon/kitchen/utensil/fork = 20,
		)

	duration = 2 SECONDS

/datum/surgery_step/cavity/implant_removal/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/internal/brain/sponge = target.internal_organs_by_name["brain"]
	var/datum/organ/external/affected = target.get_organ(target_zone)
	return ..() && !(affected.status & ORGAN_CUT_AWAY) && (!sponge || !sponge.damage)

/datum/surgery_step/cavity/implant_removal/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts poking around inside the incision on [target]'s [affected.display_name] with \the [tool].",
	"You start poking around inside the incision on [target]'s [affected.display_name] with \the [tool]." )
	target.custom_pain("The pain in your chest is living hell!",1, scream=TRUE)
	..()

/datum/surgery_step/cavity/implant_removal/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)

	if (affected.implants.len)
		var/obj/item/obj = affected.implants[affected.implants.len]
		user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You take [obj] out of incision on [target]'s [affected.display_name]s with \the [tool].</span>" )
		affected.implants -= obj

		//Handle possessive brain borers.
		if(istype(obj,/mob/living/simple_animal/borer))
			var/mob/living/simple_animal/borer/worm = obj
			if(worm.controlling)
				target.release_control()
			worm.detach()

		obj.forceMove(get_turf(target))
		if(istype(obj,/obj/item/weapon/implant))
			var/obj/item/weapon/implant/imp = obj
			imp.handle_removal(user)
			imp.imp_in = null
			imp.implanted = 0
			affected.implants -= imp
			target.contents -= imp
	else if (affected.hidden)
		user.visible_message("<span class='notice'>[user] takes something out of incision on [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You take something out of incision on [target]'s [affected.display_name]s with \the [tool].</span>" )
		affected.hidden.forceMove(get_turf(target))
		if(!affected.hidden.blood_DNA)
			affected.hidden.blood_DNA = list()
		affected.hidden.blood_DNA[target.dna.unique_enzymes] = target.dna.b_type
		affected.hidden.update_icon()
		affected.hidden = null

	else
		user.visible_message("<span class='notice'>[user] could not find anything inside [target]'s [affected.display_name], and pulls \the [tool] out.</span>", \
		"<span class='notice'>You could not find anything inside [target]'s [affected.display_name].</span>" )

/datum/surgery_step/cavity/implant_removal/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, scraping tissue inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	if (affected.implants.len)
		var/fail_prob = 10
		fail_prob += 100 - tool_quality(tool)
		if (prob(fail_prob))
			var/obj/item/weapon/implant/imp = affected.implants[1]
			user.visible_message("<span class='warning'>Something beeps inside [target]'s [affected.display_name]!</span>")
			playsound(imp.loc, 'sound/items/countdown.ogg', 75, 1, -3)
			spawn(25)
				imp.activate()

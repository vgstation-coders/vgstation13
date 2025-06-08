//Procedures in this file: Generic surgery steps
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////

/datum/surgery_step/generic/
	can_infect = 1
	var/painful=1

/datum/surgery_step/generic/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (isslime(target))
		return 0
	if (target_zone == "eyes")	//there are specific steps for eye surgery
		return 0
	if (!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.status & ORGAN_DESTROYED)
		return 0
	if (affected.status & ORGAN_PEG)
		return 0
	// N3X:  Patient must be sleeping, dead, or unconscious.
	if(!check_anesthesia(target) && painful)
		return -1
	return 1


//////CUT WITH LASER(cut+clamp)//////////
/datum/surgery_step/generic/cut_with_laser/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/generic/cut_with_laser
	allowed_tools = list(
		/obj/item/tool/scalpel/laser = 100,
		/obj/item/weapon/melee/energy/sword = 5 //haha, oh god what
		)

	priority = 0.1 //so the tool checks for this step before /generic/cut_open
	duration = 4 SECONDS

/datum/surgery_step/generic/cut_with_laser/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.anatomy_flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0
		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 0 && target_zone != "mouth"

/datum/surgery_step/generic/cut_with_laser/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the bloodless incision on [target]'s [affected.display_name] with \the [tool].", \
	"You start the bloodless incision on [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [affected.display_name]!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/cut_with_laser/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made a bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have made a bloodless incision on [target]'s [affected.display_name] with \the [tool].</span>",)
	//Could be cleaner ...
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	affected.createwound(CUT, 1)
	affected.clamp_wounds()
	//spread_germs_to_organ(affected, user) //a laser scalpel shouldn't spread germs.

/datum/surgery_step/generic/cut_with_laser/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips as the blade sputters, searing a long gash in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips as the blade sputters, searing a long gash in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 7.5)
	affected.createwound(BURN, 12.5)
	if(istype(tool,/obj/item/tool/scalpel))
		var/obj/item/tool/scalpel/S = tool
		S.icon_state = "[initial(S.icon_state)]_off"



//////INCISION MANAGER(cut+clamp+retract)//////////
/datum/surgery_step/generic/incision_manager
	allowed_tools = list(
		/obj/item/tool/retractor/manager = 100
		)

	priority = 0.1 //so the tool checks for this step before /generic/cut_open
	duration = 8 SECONDS

/datum/surgery_step/generic/incision_manager/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.anatomy_flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 0 && target_zone != "mouth"

/datum/surgery_step/generic/incision_manager/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts to construct a prepared incision on and within [target]'s [affected.display_name] with \the [tool].", \
	"You start to construct a prepared incision on and within [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("You feel a horrible, searing pain in your [affected.display_name] as it is pushed apart!",1, scream=TRUE)
	tool.icon_state = "[initial(tool.icon_state)]_on"
	spawn(duration)//in case the player doesn't go all the way through the step (if he moves away, puts the tool away,...)
		tool.icon_state = "[initial(tool.icon_state)]_off"
	..()

/datum/surgery_step/generic/incision_manager/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has constructed a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have constructed a prepared incision on and within [target]'s [affected.display_name] with \the [tool].</span>",)
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	affected.createwound(CUT, 1)
	affected.clamp_wounds()
	affected.open = 2
	tool.icon_state = "[initial(tool.icon_state)]_off"

/datum/surgery_step/generic/incision_manager/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand jolts as the system sparks, ripping a gruesome hole in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20)
	affected.createwound(BURN, 15)
	tool.icon_state = "[initial(tool.icon_state)]_off"



////////CUT OPEN/////////
/datum/surgery_step/generic/cut_open/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/generic/cut_open
	allowed_tools = list(
		/obj/item/tool/scalpel = 100,
		/obj/item/weapon/melee/blood_dagger = 90,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		/obj/item/soulstone/gem = 0,
		/obj/item/soulstone = 50,
		)

	priority = 0
	duration = 4 SECONDS

/datum/surgery_step/generic/cut_open/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	. = ..()
	if(target.species && (target.species.anatomy_flags & NO_SKIN))
		to_chat(user, "<span class='info'>[target] has no skin!</span>")
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(. && !affected.open && target_zone != "mouth")
		return .
	return 0

/datum/surgery_step/generic/cut_open/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts the incision on [target]'s [affected.display_name] with \the [tool].", \
	"You start the incision on [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("You feel a horrible pain as if from a sharp knife in your [affected.display_name]!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/cut_open/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has made an incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You have made an incision on [target]'s [affected.display_name] with \the [tool].</span>",)
	affected.open = 1
	affected.status |= ORGAN_BLEEDING
	affected.createwound(CUT, 1)

/datum/surgery_step/generic/cut_open/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing open [target]'s [affected.display_name] in the wrong place with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing open [target]'s [affected.display_name] in the wrong place with \the [tool]!</span>")
	affected.createwound(CUT, 10)



///////CLAMP BLEEDERS/////
/datum/surgery_step/generic/clamp_bleeders
	allowed_tools = list(
		/obj/item/tool/hemostat = 100,
		/obj/item/stack/cable_coil = 75,
		/obj/item/weapon/talisman = 70,
		/obj/item/device/assembly/mousetrap = 20,
		)
	duration = 3 SECONDS

/datum/surgery_step/generic/clamp_bleeders/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.anatomy_flags & NO_BLOOD))
			to_chat(user, "<span class='info'>[target] has no vessels to clamp!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open && (affected.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/clamp_bleeders/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts clamping bleeders in [target]'s [affected.display_name] with \the [tool].", \
	"You start clamping bleeders in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("The pain in your [affected.display_name] is maddening!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/clamp_bleeders/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] clamps bleeders in [target]'s [affected.display_name] with \the [tool].</span>",	\
	"<span class='notice'>You clamp bleeders in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.clamp_wounds()
	spread_germs_to_organ(affected, user)

/datum/surgery_step/generic/clamp_bleeders/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing blood vessals and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",	\
	"<span class='warning'>Your hand slips, tearing blood vessels and causing massive bleeding in [target]'s [affected.display_name] with \the [tool]!</span>",)
	affected.createwound(CUT, 10)



////////RETRACT SKIN//////
/datum/surgery_step/generic/retract_skin
	allowed_tools = list(
		/obj/item/tool/retractor = 100,
		/obj/item/tool/crowbar = 75,
		/obj/item/weapon/kitchen/utensil/fork = 50
		)
	duration = 3 SECONDS

/datum/surgery_step/generic/retract_skin/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.anatomy_flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open == 1 //&& !(affected.status & ORGAN_BLEEDING)

/datum/surgery_step/generic/retract_skin/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/msg = "[user] starts to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
	var/self_msg = "You start to pry open the incision on [target]'s [affected.display_name] with \the [tool]."
	if (target_zone == LIMB_CHEST)
		msg = "[user] starts to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
		self_msg = "You start to separate the ribcage and rearrange the organs in [target]'s torso with \the [tool]."
	if (target_zone == LIMB_GROIN)
		msg = "[user] starts to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
		self_msg = "You start to pry open the incision and rearrange the organs in [target]'s lower abdomen with \the [tool]."
	user.visible_message(msg, self_msg)
	target.custom_pain("It feels like the skin on your [affected.display_name] is on fire!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/retract_skin/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='notice'>[user] keeps the incision open on [target]'s [affected.display_name] with \the [tool].</span>"
	var/self_msg = "<span class='notice'>You keep the incision open on [target]'s [affected.display_name] with \the [tool].</span>"
	if (target_zone == LIMB_CHEST)
		msg = "<span class='notice'>[user] keeps the ribcage open on [target]'s torso with \the [tool].</span>"
		self_msg = "<span class='notice'>You keep the ribcage open on [target]'s torso with \the [tool].</span>"
	if (target_zone == LIMB_GROIN)
		msg = "<span class='notice'>[user] keeps the incision open on [target]'s lower abdomen with \the [tool].</span>"
		self_msg = "<span class='notice'>You keep the incision open on [target]'s lower abdomen with \the [tool].</span>"
	user.visible_message(msg, self_msg)
	affected.open = 2

/datum/surgery_step/generic/retract_skin/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/msg = "<span class='warning'>[user]'s hand slips, tearing the edges of the incision on [target]'s [affected.display_name] with \the [tool]!</span>"
	var/self_msg = "<span class='warning'>Your hand slips, tearing the edges of the incision on [target]'s [affected.display_name] with \the [tool]!</span>"
	if (target_zone == LIMB_CHEST)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [target]'s torso with \the [tool]!</span>"
	if (target_zone == LIMB_GROIN)
		msg = "<span class='warning'>[user]'s hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]</span>"
		self_msg = "<span class='warning'>Your hand slips, damaging several organs in [target]'s lower abdomen with \the [tool]!</span>"
	user.visible_message(msg, self_msg)
	target.apply_damage(12, BRUTE, affected, sharp=1)



/////////CAUTERIZE///////
/datum/surgery_step/generic/cauterize/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_hot())
		return 0

/datum/surgery_step/generic/cauterize
	allowed_tools = list(
	/obj/item/tool/cautery = 100,
	/obj/item/tool/scalpel/laser = 100,
	/obj/item/clothing/mask/cigarette = 75,
	/obj/item/weapon/lighter = 50,
	/obj/item/tool/weldingtool = 25,
	)
	duration = 3 SECONDS

/datum/surgery_step/generic/cauterize/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.anatomy_flags & NO_SKIN))
			to_chat(user, "<span class='info'>[target] has no skin!</span>")
			return 0

		var/datum/organ/external/affected = target.get_organ(target_zone)
		return affected.open && target_zone != "mouth"

/datum/surgery_step/generic/cauterize/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool]." , \
	"You are beginning to cauterize the incision on [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Your [affected.display_name] is being burned!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/cauterize/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cauterizes the incision on [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You cauterize the incision on [target]'s [affected.display_name] with \the [tool].</span>")
	affected.open = 0
	affected.germ_level = 0
	affected.status &= ~ORGAN_BLEEDING

/datum/surgery_step/generic/cauterize/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, leaving a small burn on [target]'s [affected.display_name] with \the [tool]!</span>")
	target.apply_damage(3, BURN, affected)



////////CUT LIMB/////////
/datum/surgery_step/generic/cut_limb
	allowed_tools = list(
		/obj/item/tool/circular_saw = 100,
		/obj/item/weapon/kitchen/utensil/knife/large/butch = 75,
		/obj/item/weapon/hatchet = 75,
		)
	duration = 11 SECONDS

/datum/surgery_step/generic/cut_limb/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (target_zone == "eyes")	//there are specific steps for eye surgery
		return 0
	if (!hasorgans(target))
		return 0
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if (affected == null)
		return 0
	if (affected.status & ORGAN_DESTROYED)
		return 0
	if(isslimeperson(target) && istype(affected, /datum/organ/external/head))
		return 0
	return target_zone != LIMB_CHEST && target_zone != LIMB_GROIN && target_zone != LIMB_HEAD

/datum/surgery_step/generic/cut_limb/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] is beginning to cut off [target]'s [affected.display_name] with \the [tool]." , \
	"You are beginning to cut off [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Your [affected.display_name] is being ripped apart!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/cut_limb/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] cuts off [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You cut off [target]'s [affected.display_name] with \the [tool].</span>")
	affected.open = 0 //Resets surgery status on limb, should prevent conflicting/phantom surgery
	affected.droplimb(1,0)

/datum/surgery_step/generic/cut_limb/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, sawing through the bone in [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 30)
	affected.fracture()



/////////BIOFOAM INJECTION///////
/datum/surgery_step/generic/injectfoam/tool_quality(obj/item/tool, mob/living/user)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/generic/injectfoam
	allowed_tools = list(
	/obj/item/tool/FixOVein/clot = 100,
	)

	priority = 0.1 //Tries to inject biofoam before other steps
	duration = 1 SECONDS

/datum/surgery_step/generic/injectfoam/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(..())
		if(target.species && (target.species.anatomy_flags & NO_BLOOD))
			to_chat(user, "<span class='info'>[target] has nothing to inject biofoam into!</span>")
			return 0
//		var/datum/organ/external/affected = target.get_organ(target_zone)
		return 1 //You can inject biofoam at any time.

/datum/surgery_step/generic/injectfoam/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] begins to inject [target] with \the [tool]'s biofoam injector." , \
	"You begin to inject [target] with \the [tool]'s biofoam injector.")
	target.custom_pain("You feel a tiny prick in your [affected.display_name]!",1, scream=TRUE)
	..()

/datum/surgery_step/generic/injectfoam/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool/FixOVein/clot/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	var/amount = tool.foam
	user.visible_message("<span class='notice'>[user] injects biofoam into [target]'s [affected.display_name] with \the [tool].</span>", \
	"<span class='notice'>You inject biofoam in [target] with \the [tool].</span>")
	target.reagents.add_reagent(BIOFOAM, amount)
	playsound(target, 'sound/items/hypospray.ogg', 50, 1)
	tool.attack_self(user)
	tool.foam = 0

/datum/surgery_step/generic/injectfoam/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, tearing \the [tool]'s needle out of [target]'s [affected.display_name]!</span>", \
	"<span class='warning'>Your hand slips, tearing \the [tool]'s needle out of [target]'s [affected.display_name]!</span>")
	affected.createwound(CUT, 5)

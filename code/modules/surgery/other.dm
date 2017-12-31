//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////


//////FIX VEIN///////
/datum/surgery_step/fix_vein
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/FixOVein = 100,
		/obj/item/stack/cable_coil = 75,
		)

	can_infect = 1
	blood_level = 1

	min_duration = 70
	max_duration = 90

/datum/surgery_step/fix_vein/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)

	var/internal_bleeding = 0
	for(var/datum/wound/W in affected.wounds) if(W.internal)
		internal_bleeding = 1
		break

	return affected.open >= 2 && internal_bleeding

/datum/surgery_step/fix_vein/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts patching the damaged vein in [target]'s [affected.display_name] with \the [tool]." , \
	"You start patching the damaged vein in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
	..()

/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has patched the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You have patched the damaged vein in [target]'s [affected.display_name] with \the [tool].</span>")

	for(var/datum/wound/W in affected.wounds) if(W.internal)
		affected.wounds -= W
		affected.update_damages()
	if (ishuman(user) && prob(40))
		user:bloody_hands(target, 0)

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>" , \
	"<span class='warning'>Your hand slips, smearing [tool] in the incision in [target]'s [affected.display_name]!</span>")
	affected.take_damage(5, 0)



//////FIX DEAD TISSUE/////
/datum/surgery_step/fix_dead_tissue/tool_quality(obj/item/tool)
	. = ..()
	if(!tool.is_sharp())
		return 0

/datum/surgery_step/fix_dead_tissue		//Debridement
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/scalpel = 100,
		/obj/item/weapon/kitchen/utensil/knife/large = 75,
		/obj/item/weapon/shard = 50,
		)

	can_infect = 1
	blood_level = 1

	min_duration = 110
	max_duration = 160

/datum/surgery_step/fix_dead_tissue/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if(!hasorgans(target))
		return 0

	if (target_zone == "mouth" || target_zone == "eyes")
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)

	return affected.open >= 2 && (affected.status & ORGAN_DEAD)

/datum/surgery_step/fix_dead_tissue/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool]." , \
	"You start cutting away necrotic tissue in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("The pain in [affected.display_name] is unbearable!",1)
	..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='notice'>[user] has cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool].</span>", \
		"<span class='notice'>You have cut away necrotic tissue in [target]'s [affected.display_name] with \the [tool].</span>")
	affected.open = 3

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>[user]'s hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>", \
	"<span class='warning'>Your hand slips, slicing an artery inside [target]'s [affected.display_name] with \the [tool]!</span>")
	affected.createwound(CUT, 20, 1)



////TREAT NECROSIS//////
/datum/surgery_step/treat_necrosis
	priority = 2
	allowed_tools = list(
		/obj/item/weapon/reagent_containers/dropper = 100,
		/obj/item/weapon/reagent_containers/glass/bottle = 75,
		/obj/item/weapon/reagent_containers/glass/beaker = 75,
		/obj/item/weapon/reagent_containers/spray = 50,
		/obj/item/weapon/reagent_containers/glass/bucket = 50,
		)

	can_infect = 0
	blood_level = 0

	min_duration = 50
	max_duration = 60

/datum/surgery_step/treat_necrosis/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return 0

	var/obj/item/weapon/reagent_containers/container = tool
	if(!container.reagents.has_reagent(PERIDAXON))
		return 0

	if(!hasorgans(target))
		return 0

	if (target_zone == "mouth" || target_zone == "eyes")
		return 0

	var/datum/organ/external/affected = target.get_organ(target_zone)
	return affected.open == 3 && (affected.status & ORGAN_DEAD)

/datum/surgery_step/treat_necrosis/begin_step(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("[user] starts applying medication to the affected tissue in [target]'s [affected.display_name] with \the [tool]." , \
	"You start applying medication to the affected tissue in [target]'s [affected.display_name] with \the [tool].")
	target.custom_pain("Something in your [affected.display_name] is causing you a lot of pain!",1)
	..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if (trans > 0)
		container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(container.reagents.has_reagent(PERIDAXON))
			affected.status &= ~ORGAN_DEAD

		user.visible_message("<span class='notice'>[user] applies [trans] units of the solution to affected tissue in [target]'s [affected.display_name]</span>", \
			"<span class='notice'>You apply [trans] units of the solution to affected tissue in [target]'s [affected.display_name] with \the [tool].</span>")

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)

	if (!istype(tool, /obj/item/weapon/reagent_containers))
		return

	var/obj/item/weapon/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message("<span class='warning'>[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.display_name] with the [tool]!</span>" , \
	"<span class='warning'>Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.display_name] with the [tool]!</span>")

	//no damage or anything, just wastes medicine

//AUTOPSY
/datum/surgery_step/autopsy
	painful = FALSE
	allowed_tools = list(
		/obj/item/weapon/autopsy_scanner = 100
		)

	min_duration = 10
	max_duration = 20

/datum/surgery_step/autopsy/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/S = target.get_organ(target_zone)
	if(!S)
		to_chat(user, "<b>You can't scan this body part.</b>")
		return 0
	if(!S.open)
		to_chat(user, "<b>You have to cut the limb open first!</b>")
		return 0

	return 1

/datum/surgery_step/autopsy/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/weapon/autopsy_scanner/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	if(tool.target_name != target.name)
		tool.target_name = target.name
		tool.wdata = list()
		tool.chemtraces = list()
		tool.timeofdeath = null
		to_chat(user, "<span class='warning'>A new patient has been registered. Purging data for previous patient.</span>")

	tool.timeofdeath = target.timeofdeath
	tool.add_data(affected)
	user.visible_message("<span class='notice'>\The [user] scans the wounds on [target]'s [affected.display_name].</span>", "<span class='notice'>You scan the wounds on [target]'s [affected.display_name].</span>", "You hear a beep.")

/datum/surgery_step/autopsy/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/datum/organ/external/affected = target.get_organ(target_zone)
	user.visible_message("<span class='warning'>\The [user] could not keep a steady hand, failing to scan the wounds on [target]'s [affected.display_name].</span>", "<span class='warning'>You could not keep a steady hand, failing to scan the wounds on [target]'s [affected.display_name].</span>", "You hear a buzz.")
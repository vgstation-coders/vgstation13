/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = 0
	origin_tech = Tc_MAGNETS + "=3;" + Tc_BIOTECH + "=2"
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
	var/list/stored_huds = list() // Stores a hud datum instance to apply to a mob
	var/list/hud_types = list() // What HUD the glasses provides, if any

/obj/item/clothing/glasses/hud/New()
	..()
	if(hud_types.len)
		for(var/H in hud_types)
			if(ispath(H))
				stored_huds += new H

/obj/item/clothing/glasses/hud/proc/add_new_hud_by_type(type)
	if(!ispath(type, /datum/visioneffect))
		return
	hud_types += type
	stored_huds += new type

/obj/item/clothing/glasses/hud/equipped(mob/M, slot)
	if(slot == slot_glasses && stored_huds.len)
		for(var/datum/visioneffect/H in stored_huds)
			M.apply_hud(H)
	..()

/obj/item/clothing/glasses/hud/unequipped(mob/M, slot)
	if(slot == slot_glasses && stored_huds.len)
		for(var/datum/visioneffect/H in stored_huds)
			M.remove_hud(H)
	//the parent calls for a full redraw of the hud
	..()

//This is for harm labels blocking your vision. It also will stop most huds...
//Though, some are overridden for reality (labels won't stop your thermals, but you will be blind otherwise)
/obj/item/clothing/glasses/hud/harm_label_update()
	..()
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		if(M.glasses == src)
			if(harm_labeled >= min_harm_label)
				for(var/datum/visioneffect/H in stored_huds)
					M.remove_hud(H)
			else
				if(!stored_huds.len)
					for(var/H in hud_types)
						if(ispath(H))
							stored_huds += new H
							M.apply_hud(H)
	if(harm_labeled >= min_harm_label)
		stored_huds = list()
	else
		if(!stored_huds.len)
			for(var/H in hud_types)
				if(ispath(H))
					stored_huds += new H

/*
	MEDICAL HUDS
*/

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status."
	icon_state = "healthhud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	prescription_type = /obj/item/clothing/glasses/hud/health/prescription
	hud_types = list(/datum/visioneffect/medical)

/obj/item/clothing/glasses/hud/health/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/glasses/hud/security/scouter))
		var/worn = FALSE
		if(user.is_wearing_item(src, slot_glasses))
			worn = TRUE
		if(do_after(user, src, 1 SECONDS))
			user.drop_item(src)
			if(!user.drop_item(W))
				to_chat(user, "<span class='warning'>You can't let go of \the [W].</span>")
				return
			var/obj/item/clothing/glasses/hud/combinedsecmed/I = new /obj/item/clothing/glasses/hud/combinedsecmed(hhud = src, shud = W)
			W.transfer_fingerprints_to(I)
			I.base_health = src
			I.base_sec = W
			W.forceMove(I)
			src.forceMove(I)
			var/mob/living/carbon/human/H = user
			if(worn && istype(H))
				H.equip_to_slot_if_possible(I,slot_glasses,EQUIP_FAILACTION_DROP)
			else
				user.put_in_hands(I)
			to_chat(user, "<span class='notice'>You synchronize \the [W] with \the [src].</span>")

/obj/item/clothing/glasses/hud/health/cmo
	name = "advanced health scanner HUD"
	nearsighted_modifier = -3
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status as well as reveals pathogens in sight. The tinted glass protects the wearer from bright flashes of light."
	icon_state = "cmohud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	eyeprot = 1
	mech_flags = MECH_SCAN_ILLEGAL
	actions_types = list(/datum/action/item_action/toggle_goggles)
	prescription_type = null
	var/on = FALSE
	var/datum/visioneffect/pathogen/stored_pathogen_hud = null

/obj/item/clothing/glasses/hud/health/cmo/New()
	..()
	stored_pathogen_hud = new /datum/visioneffect/pathogen

/obj/item/clothing/glasses/hud/health/cmo/attack_self(mob/user)
	toggle(user)

/obj/item/clothing/glasses/hud/health/cmo/proc/toggle(mob/user)
	if (user.incapacitated())
		return

	playsound(user,'sound/misc/click.ogg',30,0,-5)
	if (on)
		on = FALSE
		to_chat(user, "You turn the pathogen scanner off.")
		disable(user)
	else
		on = TRUE
		to_chat(user, "You turn the pathogen scanner on.")
		enable(user)
	user.handle_regular_hud_updates()

/obj/item/clothing/glasses/hud/health/cmo/equipped(mob/M, slot)
	if(slot == slot_glasses)
		if (on)
			enable(M)
	..()

/obj/item/clothing/glasses/hud/health/cmo/unequipped(mob/M, from_slot)
	if(from_slot == slot_glasses)
		disable(M)
	..()

/obj/item/clothing/glasses/hud/health/cmo/proc/enable(mob/M)
	var/toggle = 0
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (H.glasses == src)
			toggle = 1
	if (ismonkey(M))
		var/mob/living/carbon/monkey/H = M
		if (H.glasses == src)
			toggle = 1
	if (toggle)
		M.apply_hud(stored_pathogen_hud)

/obj/item/clothing/glasses/hud/health/cmo/proc/disable(mob/M)
	M.remove_hud(stored_pathogen_hud)

/*
	SECURITY HUDS
*/

/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	hud_types = list(/datum/visioneffect/security/arrest,
					/datum/visioneffect/job,
					/datum/visioneffect/implant)

//Special brig medic edition
/obj/item/clothing/glasses/hud/security/scouter
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records. Lacks modern arrest encryption."
	hud_types = list(/datum/visioneffect/security,
					/datum/visioneffect/job,
					/datum/visioneffect/implant)
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/glasses/hud/security/scouter/attackby(obj/item/weapon/W, mob/user)
	..()
	if(istype(W, /obj/item/clothing/glasses/hud/health))
		var/worn = FALSE
		if(user.is_wearing_item(src, slot_glasses))
			worn = TRUE
		if(do_after(user, src, 1 SECONDS))
			user.drop_item(src)
			if(!user.drop_item(W))
				to_chat(user, "<span class='warning'>You can't let go of \the [W].</span>")
				return
			var/obj/item/clothing/glasses/hud/combinedsecmed/I = new /obj/item/clothing/glasses/hud/combinedsecmed(hhud = W, shud = src)
			W.transfer_fingerprints_to(I)
			I.base_health = W
			I.base_sec = src
			W.forceMove(I)
			src.forceMove(I)
			var/mob/living/carbon/human/H = user
			if(worn && istype(H))
				H.equip_to_slot_if_possible(I,slot_glasses,EQUIP_FAILACTION_DROP)
			else
				user.put_in_hands(I)
			to_chat(user, "<span class='notice'>You synchronize \the [W] with \the [src].</span>")


/obj/item/clothing/glasses/hud/security/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	species_fit = list(GREY_SHAPED)
	min_harm_label = 12
	vision_flags = SEE_MOBS
	invisa_view = 2
	eyeprot = 1

/obj/item/clothing/glasses/hud/security/jensenshades/harm_label_update()
	if(harm_labeled >= min_harm_label)
		vision_flags |= BLIND
	else
		vision_flags &= ~BLIND

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "\improper HUDSunglasses"
	desc = "Sunglasses with a HUD."
	icon_state = "sunhud"
	item_state = "sunglasses"
	origin_tech = Tc_COMBAT + "=2"
	darkness_view = -1
	eyeprot = 1
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	prescription_type = /obj/item/clothing/glasses/hud/security/sunglasses/prescription

/obj/item/clothing/glasses/hud/security/sunglasses/become_defective()
	if(!defective)
		..()
		if(prob(15))
			new /obj/item/weapon/shard(loc)
			playsound(src, "shatter", 50, 1)
			qdel(src)
			return
		if(prob(15))
			new/obj/item/clothing/glasses/sunglasses(get_turf(src))
			playsound(src, 'sound/effects/glass_step.ogg', 50, 1)
			qdel(src)
			return
		if(prob(55))
			eyeprot = 0
		if(prob(55))
			if(istype(src.loc, /mob/living/carbon/human))
				var/mob/living/carbon/human/M = src.loc
				if(M.glasses == src)
					for(var/datum/visioneffect/H in stored_huds)
						M.remove_hud(H)
			hud_types = null
			stored_huds = null

/obj/item/clothing/glasses/hud/security/sunglasses/syndishades
	name = "sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Enhanced shielding blocks many flashes."
	icon_state = "sun"
	item_state = "sunglasses"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	darkness_view = 0 //Subtly better than normal shades
	origin_tech = Tc_SYNDICATE + "=3"
	actions_types = list(/datum/action/item_action/change_appearance_shades)
	var/static/list/clothing_choices = null
	var/full_access = FALSE

/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/New()
	..()
	if(!clothing_choices)
		clothing_choices = list()
		for(var/Type in existing_typesof(/obj/item/clothing/glasses) - /obj/item/clothing/glasses - typesof(/obj/item/clothing/glasses/hud/security/sunglasses/syndishades))
			var/obj/glass = Type
			clothing_choices[initial(glass.name)] = glass

/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/clothing/glasses/hud/security/sunglasses) || istype(I, /obj/item/clothing/glasses/hud/security))
		var/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/S = I
		if(istype(S) && !S.full_access)
			return
		if(full_access)
			to_chat(user, "<span class='warning'>\The [src] already has those access codes.</span>")
			return
		else
			to_chat(user, "<span class='notice'>You transfer the security access codes from \the [I] to \the [src].</span>")
			full_access = TRUE

/datum/action/item_action/change_appearance_shades
	name = "Change Shades Appearance"

/datum/action/item_action/change_appearance_shades/Trigger()
	var/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/T = target
	if(!istype(T))
		return
	T.change()

/obj/item/clothing/glasses/hud/security/sunglasses/syndishades/proc/change()
	var/choice = input("Select style to change it to", "Style Selector") as null|anything in clothing_choices
	if(src.gcDestroyed || !choice || usr.incapacitated() || !Adjacent(usr))
		return
	var/obj/item/clothing/glasses/glass_type = clothing_choices[choice]
	desc = initial(glass_type.desc)
	name = initial(glass_type.name)
	icon_state = initial(glass_type.icon_state)
	item_state = initial(glass_type.item_state)
	_color = initial(glass_type._color)
	usr.update_inv_glasses()

/obj/item/clothing/glasses/hud/tracking
	name = "eye tracking glasses"
	desc = "Eye tracking glasses which allow the wearer to see what others are looking at."
	icon_state = "tracking"
	item_state = "tracking"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/glasses/hud/tracking/detective
	name = "investigation glasses"
	desc = "A SecurityHUD with built-in eye tracking glasses which allow the wearer to see what others are looking at."
	icon_state = "investigation"
	item_state = "investigation"
	darkness_view = -1
	eyeprot = 1
	nearsighted_modifier = -3
	hud_types = list(/datum/visioneffect/security/arrest,
					/datum/visioneffect/job,
					/datum/visioneffect/implant)
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/*
	DIAGNOSTIC HUD
*/

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	icon_state = "diagnostichud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	desc = "A heads-up display that displays diagnostic information for compatible cyborgs and exosuits."
	prescription_type = /obj/item/clothing/glasses/hud/diagnostic/prescription
	hud_types = list(/datum/visioneffect/diagnostic)

/obj/item/clothing/glasses/hud/diagnostic/prescription
	name = "prescription diagnostic HUD"
	nearsighted_modifier = -3

/*
	SPECIAL VISION HUDS
*/
/obj/item/clothing/glasses/hud/combinedsecmed
	name = "combined health and security HUD"
	desc = "Two scanners synced up and able to provide both health and security information at once."
	icon_state = "combinedsecmed"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	mech_flags = MECH_SCAN_ILLEGAL
	hud_types = list(/datum/visioneffect/medical,
					/datum/visioneffect/security,
					/datum/visioneffect/job,
					/datum/visioneffect/implant)
	var/obj/item/clothing/glasses/hud/health/base_health = null
	var/obj/item/clothing/glasses/hud/security/scouter/base_sec = null

/obj/item/clothing/glasses/hud/combinedsecmed/New(var/turf/location = null,
												var/obj/item/clothing/glasses/hud/health/hhud = null,
												var/obj/item/clothing/glasses/hud/security/scouter/shud = null)
	..()
	if(istype(hhud))
		base_health = hhud
	else
		base_health = new /obj/item/clothing/glasses/hud/health
	if(istype(shud))
		base_sec = shud
	else
		base_sec = new /obj/item/clothing/glasses/hud/security/scouter

/obj/item/clothing/glasses/hud/combinedsecmed/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You de-sync \the [src], splitting apart the two scanners.</span>")
	user.u_equip(src,0)
	user.put_in_hands(src.base_health)
	user.put_in_hands(src.base_sec)
	qdel(src)

/obj/item/clothing/glasses/hud/wage
	name = "wage HUD"
	desc = "A heads-up display that scans IDs to determine what a person's wage and employment records are."
	icon_state = "wagemonocle"
	species_fit = list(VOX_SHAPED)
	mech_flags = MECH_SCAN_ILLEGAL
	nearsighted_modifier = -3
	hud_types = list(/datum/visioneffect/accountdb/wage,
					/datum/visioneffect/job)

/obj/item/clothing/glasses/hud/wage/attack_self(mob/user)
	if(isemptylist(stored_huds))
		to_chat(user, "HUD Error.")
		return
	for(var/datum/visioneffect/accountdb/W in stored_huds)
		if(!W.linked_db)
			to_chat(user, "No DB found. Trying to reconnect!")
			if(W.reconnect_db())
				to_chat(user, "Successfully reconnected to the DB.")
			else
				to_chat(user, "Error: Unable to locate DB.")
		else
			to_chat(user, "DB connection nominal.")

/obj/item/clothing/glasses/hud/wage/cash
	name = "money HUD"
	desc = "A heads-up display that shows you how much dosh someone's got in their bank account."
	icon_state = "wagemonocle"
	hud_types = list(/datum/visioneffect/accountdb/balance)

/obj/item/clothing/glasses/hud/gold_aviators
	name = "golden aviators"
	desc = "A heads-up display that shows the job of the person you're looking at. Stylish."
	icon_state = "aviators_gold"
	darkness_view = -1
	eyeprot = 1
	nearsighted_modifier = -3
	hud_types = list(/datum/visioneffect/job)

/*
	THERMAL GLASSES
*/
/obj/item/clothing/glasses/hud/thermal
	name = "optical thermal scanner"
	desc = "Thermals in the shape of glasses."
	icon_state = "thermal"
	item_state = "glasses"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	origin_tech = Tc_MAGNETS + "=3"
	glasses_fit = TRUE
	stored_huds = list() // Stores a hud datum instance to apply to a mob
	hud_types = list(/datum/visioneffect/thermal) // What HUD the glasses provides, if any

/obj/item/clothing/glasses/hud/thermal/emp_act(severity)
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = src.loc
		to_chat(M, "<span class='warning'>\The [src] overloads and blinds you!</span>")
		if(M.glasses == src)
			M.eye_blind = 3
			M.eye_blurry = 5
			M.disabilities |= NEARSIGHTED
			spawn(100)
				M.disabilities &= ~NEARSIGHTED
	..()

/obj/item/clothing/glasses/hud/thermal/harm_label_update()
	//Thermals aren't blocked by labels, but you'll still be blind!
	if(harm_labeled >= min_harm_label)
		vision_flags |= BLIND
	else
		vision_flags &= ~BLIND

/obj/item/clothing/glasses/hud/thermal/syndi	//These are now a traitor item, concealed as mesons.	-Pete
	name = "optical meson scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = Tc_MAGNETS + "=3;" + Tc_SYNDICATE + "=4"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)

/obj/item/clothing/glasses/hud/thermal/monocle
	name = "thermonocle"
	desc = "A monocle thermal."
	icon_state = "thermoncle"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)
	flags = 0 //doesn't protect eyes because it's a monocle, duh
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")

/obj/item/clothing/glasses/hud/thermal/monocle/harm_label_update()
	//Thermals aren't blocked by labels, and covering one eye doesn't fully blind you!
	return

/obj/item/clothing/glasses/hud/thermal/eyepatch
	name = "optical thermal eyepatch"
	desc = "An eyepatch with built-in thermal optics."
	icon_state = "eyepatch0"
	item_state = "eyepatch0"
	species_fit = list(GREY_SHAPED)
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")

/obj/item/clothing/glasses/hud/thermal/eyepatch/harm_label_update()
	//Thermals aren't blocked by labels, and covering one eye doesn't fully blind you!
	return

/obj/item/clothing/glasses/hud/thermal/jensen
	name = "optical thermal implants"
	desc = "A set of implantable lenses designed to augment your vision."
	icon_state = "thermalimplants"
	item_state = "syringe_kit"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

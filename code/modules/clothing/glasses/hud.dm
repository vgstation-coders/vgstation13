/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = 0 //doesn't protect eyes because it's a monocle, duh
	origin_tech = Tc_MAGNETS + "=3;" + Tc_BIOTECH + "=2"
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
	var/list/icon/current = list() //the current hud icons
	var/list/stored_huds = list() // Stores a hud datum instance to apply to a mob
	var/list/hud_types = list() // What HUD the glasses provides, if any

/obj/item/clothing/glasses/hud/New()
	..()
	if(hud_types.len)
		for(var/H in hud_types)
			if(ispath(H))
				stored_huds += new H

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

/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status."
	icon_state = "healthhud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	prescription_type = /obj/item/clothing/glasses/hud/health/prescription
	hud_types = list(/datum/visioneffect/medical)

/obj/item/clothing/glasses/hud/curseddoublehud
	name = "cursed health scanner HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status."
	icon_state = "curseddoublehud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	hud_types = list(/datum/visioneffect/medical, /datum/visioneffect/nullrod, /datum/visioneffect/security)

/obj/item/clothing/glasses/hud/health/cmo
	name = "advanced health scanner HUD"
	nearsighted_modifier = -3
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status as well as reveals pathogens in sight. The tinted glass protects the wearer from bright flashes of light."
	icon_state = "suncmo"
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



/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	hud_types = list(/datum/visioneffect/security)

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


/obj/item/clothing/glasses/hud/wage
	name = "wage HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "wagemonocle"
	species_fit = list(VOX_SHAPED)
	hud_types = list(/datum/visioneffect/accountdb/wage)

/obj/item/clothing/glasses/hud/wage/attack_self(mob/user)
	if(isemptylist(stored_huds))
		to_chat(user, "HUD Error.")
		return
	for(var/datum/visioneffect/accountdb/W in stored_huds)
		if(!W.linked_db)
			to_chat(user, "No DB found. Trying reconnect.")
			W.reconnect_db()
		else
			to_chat(user, "DB looks OK!")

/obj/item/clothing/glasses/hud/wage/cash
	name = "money HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	darkness_view = 0
	eyeprot = 0
	hud_types = list(/datum/visioneffect/accountdb/balance)

/obj/item/clothing/glasses/hud/omni
	name = "omniHUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "aviators_gold"
	darkness_view = -1
	eyeprot = 1
	hud_types = list(/datum/visioneffect/medical, /datum/visioneffect/security, /datum/visioneffect/accountdb/wage)

/obj/item/clothing/glasses/hud/vampire
	name = "vampireHUD"
	desc = "Ever wanted to see a null rod?"
	icon_state = "aviators_gold"
	darkness_view = -1
	eyeprot = 1
	hud_types = list(/datum/visioneffect/nullrod)

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

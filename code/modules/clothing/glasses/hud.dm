/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = 0 //doesn't protect eyes because it's a monocle, duh
	origin_tech = Tc_MAGNETS + "=3;" + Tc_BIOTECH + "=2"
	min_harm_label = 3
	harm_label_examine = list("<span class='info'>A tiny label is on the lens.</span>","<span class='warning'>A label covers the lens!</span>")
	var/list/icon/current = list() //the current hud icons

/obj/item/clothing/glasses/hud/proc/process_hud(var/mob/M)
	return

/obj/item/clothing/glasses/hud/harm_label_update()
	return


/obj/item/clothing/glasses/hud/health
	name = "health scanner HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status."
	icon_state = "healthhud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	prescription_type = /obj/item/clothing/glasses/hud/health/prescription

/obj/item/clothing/glasses/hud/health/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_med_hud(M)


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

/obj/item/clothing/glasses/hud/health/cmo/attack_self(mob/user)
	toggle(user)

/obj/item/clothing/glasses/hud/health/cmo/proc/toggle(mob/user)
	if (user.incapacitated())
		return
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
	..()
	if (!M.client)
		return
	if(slot == slot_glasses)
		if (on)
			enable(M)

/obj/item/clothing/glasses/hud/health/cmo/unequipped(mob/M, from_slot)
	..()
	if (!M.client)
		return
	if(from_slot == slot_glasses)
		disable(M)

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
		playsound(M,'sound/misc/click.ogg',30,0,-5)
		science_goggles_wearers.Add(M)
		for (var/obj/item/I in infected_items)
			if (I.pathogen)
				M.client.images |= I.pathogen
		for (var/mob/living/L in infected_contact_mobs)
			if (L.pathogen)
				M.client.images |= L.pathogen
		for (var/obj/effect/pathogen_cloud/C in pathogen_clouds)
			if (C.pathogen)
				M.client.images |= C.pathogen
		for (var/obj/effect/decal/cleanable/C in infected_cleanables)
			if (C.pathogen)
				M.client.images |= C.pathogen

/obj/item/clothing/glasses/hud/health/cmo/proc/disable(mob/M)
	playsound(M,'sound/misc/click.ogg',30,0,-5)
	science_goggles_wearers.Remove(M)
	for (var/obj/item/I in infected_items)
		M.client.images -= I.pathogen
	for (var/mob/living/L in infected_contact_mobs)
		M.client.images -= L.pathogen
	for (var/obj/effect/pathogen_cloud/C in pathogen_clouds)
		M.client.images -= C.pathogen
	for (var/obj/effect/decal/cleanable/C in infected_cleanables)
		M.client.images -= C.pathogen



/obj/item/clothing/glasses/hud/security
	name = "security HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"

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

/obj/item/clothing/glasses/hud/security/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_sec_hud(M,1)

/obj/item/clothing/glasses/hud/diagnostic
	name = "diagnostic HUD"
	icon_state = "diagnostichud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED, INSECT_SHAPED)
	desc = "A heads-up display that displays diagnostic information for compatible cyborgs and exosuits."
	prescription_type = /obj/item/clothing/glasses/hud/diagnostic/prescription

/obj/item/clothing/glasses/hud/diagnostic/prescription
	name = "prescription diagnostic HUD"
	nearsighted_modifier = -3

/obj/item/clothing/glasses/hud/diagnostic/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_diagnostic_hud(M)

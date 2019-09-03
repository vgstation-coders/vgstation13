/obj/item/clothing/glasses/hud
	name = "HUD"
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
	name = "Health Scanner HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their health status."
	icon_state = "healthhud"
	species_fit = list(VOX_SHAPED, GREY_SHAPED)

/obj/item/clothing/glasses/hud/health/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_med_hud(M)


/obj/item/clothing/glasses/hud/security
	name = "Security HUD"
	desc = "A heads-up display that scans the humanoid carbon lifeforms in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"

/obj/item/clothing/glasses/hud/security/jensenshades
	name = "Augmented shades"
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
	species_fit = list(GREY_SHAPED)
	desc = "A heads-up display that displays diagnostic information for compatible cyborgs and exosuits."

/obj/item/clothing/glasses/hud/diagnostic/prescription
	prescription = TRUE

/obj/item/clothing/glasses/hud/diagnostic/process_hud(var/mob/M)
	if(harm_labeled < min_harm_label)
		process_diagnostic_hud(M)
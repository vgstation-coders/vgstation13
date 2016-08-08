/datum/data_hud/antag
	var/icon_state
	var/image/hud_image
	flags = SEE_IN_MECH|IS_ANTAG_HUD

/datum/data_hud/antag/New()
	..()
	hud_image = image('icons/mob/mob.dmi', icon_state = "[icon_state]")
	hud_image.plane = plane

/datum/data_hud/antag/proc/is_antag_type(var/mob/living/user)
	if(istype(user))
		return 1

/datum/data_hud/antag/to_add(var/mob/user)
	return hud_image

/datum/data_hud/antag/remove_hud(var/mob/user)
	..()
	user.overlays -= user.overlays[name]

/datum/data_hud/antag/can_be_seen_by(var/mob/user)
	..()
	if(is_antag_type(user))
		return CAN_SEE

/datum/data_hud/antag/check(var/mob/user)
	return is_antag_type(user)

// CULTISTS

/datum/data_hud/antag/cult
	name = "cult"
	plane = CULT_ANTAG_HUD_PLANE
	icon_state = "cult"

/datum/data_hud/antag/cult/is_antag_type(var/mob/living/user)
	return iscultist(user)

var/global/cult_hud = new /datum/data_hud/antag/cult()

// WIZARDS

/datum/data_hud/antag/wiz
	name = "wiz"
	plane = WIZ_ANTAG_HUD_PLANE
	icon_state = "wizard"

/datum/data_hud/antag/wiz/is_antag_type(var/mob/living/user)
	if(!..())
		return
	return iswizard(user)

var/global/wiz_hud = new /datum/data_hud/antag/wiz()

// SYNDIES

/datum/data_hud/antag/syndie
	name = "syndie"
	plane = SYNDIE_ANTAG_HUD_PLANE
	icon_state = "synd"

/datum/data_hud/antag/syndie/is_antag_type(var/mob/living/user)
	if(!..())
		return
	return isnukeop(user)

var/global/syndie_hud = new /datum/data_hud/antag/syndie()

// REVS

/datum/data_hud/antag/rev
	name = "rev"
	plane = REV_ANTAG_HUD_PLANE

/datum/data_hud/antag/rev/is_antag_type(var/mob/living/user)
	if(!..())
		return
	if(isrev(user) || isrevhead(user))
		return HUD_ON

/datum/data_hud/antag/rev/to_add(var/mob/user)
	if(isrevhead(user))
		icon_state = "rev_head"
	else
		icon_state = "rev"
	..()


var/global/rev_hud = new /datum/data_hud/antag/rev()

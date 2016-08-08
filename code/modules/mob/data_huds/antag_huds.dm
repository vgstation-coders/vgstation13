/datum/hud/antag
	var/icon_state
	var/image/hud_image
	flags = SEE_IN_MECH|IS_ANTAG_HUD

/datum/hud/antag/New()
	..()
	hud_image = image('icons/mob/mob.dmi', icon_state = "[icon_state]")
	hud_image.plane = plane

/datum/hud/antag/proc/is_antag_type(var/mob/user)
	return

/datum/hud/antag/to_add(var/mob/user)
	return hud_image

/datum/hud/antag/remove_hud(var/mob/user)
	..()
	user.overlays -= hud_image

/datum/hud/antag/can_be_seen_by(var/mob/user)
	..()
	if(is_antag_type(user))
		return CAN_SEE

/datum/hud/antag/check(var/mob/user)
	return is_antag_type(user)

// CULTISTS

/datum/hud/antag/cult
	name = "cult"
	plane = CULT_ANTAG_HUD_PLANE
	icon_state = "cult"

/datum/hud/antag/cult/is_antag_type(var/mob/user)
	return iscultist(user)

var/global/cult_hud = new /datum/hud/antag/cult()

// WIZARDS

/datum/hud/antag/wiz
	name = "wiz"
	plane = WIZ_ANTAG_HUD_PLANE
	icon_state = "wizard"

/datum/hud/antag/wiz/is_antag_type(var/mob/user)
	return iswizard(user)

var/global/wiz_hud = new /datum/hud/antag/wiz()

// SYNDIES

/datum/hud/antag/syndie
	name = "syndie"
	plane = SYNDIE_ANTAG_HUD_PLANE
	icon_state = "synd"

/datum/hud/antag/syndie/is_antag_type(var/mob/user)
	return isnukeop(user)

var/global/syndie_hud = new /datum/hud/antag/syndie()

// REVS

/datum/hud/antag/rev
	name = "rev"
	plane = REV_ANTAG_HUD_PLANE

/datum/hud/antag/rev/is_antag_type(var/mob/user)
	if(isrev(user) || isrevhead(user))
		return HUD_ON

/datum/hud/antag/rev/to_add(var/mob/user)
	if(isrevhead(user))
		icon_state = "rev_head"
	else
		icon_state = "rev"
	..()

var/global/rev_hud = new /datum/hud/antag/rev()

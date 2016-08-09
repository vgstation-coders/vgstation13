/datum/data_hud/antag
	var/image/hud_image
	flags = SEE_IN_MECH|IS_ANTAG_HUD

/datum/data_hud/antag/New()
	..()
	hud_image = image('icons/mob/mob.dmi', icon_state = "[name]")
	hud_image.plane = plane
	hud_image.layer = EVEN_LOWER_LAYER

/datum/data_hud/antag/proc/is_antag_type(var/mob/living/user)
	if(istype(user))
		return 1

/datum/data_hud/antag/to_add(var/mob/user)
	return hud_image

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

/datum/data_hud/antag/cult/is_antag_type(var/mob/living/user)
	return iscultist(user)

var/global/datum/data_hud/antag/cult/cult_hud = new /datum/data_hud/antag/cult()

// WIZARDS

/datum/data_hud/antag/wiz
	name = "wizard"
	plane = WIZ_ANTAG_HUD_PLANE

/datum/data_hud/antag/wiz/is_antag_type(var/mob/living/user)
	if(!..())
		return
	return iswizard(user)

var/global/datum/data_hud/antag/wiz/wiz_hud = new /datum/data_hud/antag/wiz()

// SYNDIES

/datum/data_hud/antag/syndie
	name = "synd"
	plane = SYNDIE_ANTAG_HUD_PLANE

/datum/data_hud/antag/syndie/is_antag_type(var/mob/living/user)
	if(!..())
		return
	return isnukeop(user)

var/global/datum/data_hud/antag/syndie/syndie_hud = new /datum/data_hud/antag/syndie()

// REVS

/datum/data_hud/antag/rev
	name = "rev"
	plane = REV_ANTAG_HUD_PLANE
	var/image/headrev_image

/datum/data_hud/antag/rev/New()
	..()
	headrev_image = image('icons/mob/mob.dmi', icon_state = "rev_head")
	headrev_image.layer = EVEN_LOWER_LAYER
	headrev_image.plane = plane


/datum/data_hud/antag/rev/is_antag_type(var/mob/living/user)
	if(!..())
		return
	if(isrev(user) || isrevhead(user))
		return HUD_ON

/datum/data_hud/antag/rev/to_add(var/mob/user)
	if(isrevhead(user))
		return headrev_image
	..()


var/global/datum/data_hud/antag/rev/rev_hud = new /datum/data_hud/antag/rev()
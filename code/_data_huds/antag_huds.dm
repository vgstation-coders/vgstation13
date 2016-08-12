/datum/data_hud/antag
	var/image/hud_image
	var/image/leader_hud_image
	var/leader_icon_state
	var/icon_state
	flags = SEE_IN_MECH|IS_ANTAG_HUD

/datum/data_hud/antag/New()
	..()
	if(icon_state)
		hud_image = image('icons/mob/mob.dmi', icon_state = icon_state)
		hud_image.plane = plane
		hud_image.layer = EVEN_LOWER_LAYER
	if(leader_icon_state)
		leader_hud_image = image('icons/mob/mob.dmi', icon_state = leader_icon_state)
		leader_hud_image.plane = plane
		leader_hud_image.layer = EVEN_LOWER_LAYER

/datum/data_hud/antag/proc/is_antag_type(var/mob/living/user)
	if(istype(user))
		return 1

/datum/data_hud/antag/proc/is_leader(var/mob/user)
	return

/datum/data_hud/antag/to_add(var/mob/user)
	if(is_leader(user))
		return leader_hud_image
	else
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
	icon_state = "cult"
	plane = CULT_ANTAG_HUD_PLANE

/datum/data_hud/antag/cult/is_antag_type(var/mob/living/user)
	return iscultist(user)

var/global/datum/data_hud/antag/cult/cult_hud = new /datum/data_hud/antag/cult()

// WIZARDS

/datum/data_hud/antag/wiz
	name = "wizard"
	icon_state = "dunce"
	leader_icon_state = "wizard"
	plane = WIZ_ANTAG_HUD_PLANE

/datum/data_hud/antag/wiz/is_antag_type(var/mob/living/user)
	if(!..())
		return
	return (iswizard(user)||isapprentice(user))

/datum/data_hud/antag/wiz/is_leader(var/mob/user)
	return iswizard(user)

var/global/datum/data_hud/antag/wiz/wiz_hud = new /datum/data_hud/antag/wiz()

// SYNDIES

/datum/data_hud/antag/syndie
	name = "synd"
	icon_state = "synd"
	plane = SYNDIE_ANTAG_HUD_PLANE

/datum/data_hud/antag/syndie/is_antag_type(var/mob/living/user)
	if(!..())
		return
	return isnukeop(user)

var/global/datum/data_hud/antag/syndie/syndie_hud = new /datum/data_hud/antag/syndie()

// REVS

/datum/data_hud/antag/rev
	name = "rev"
	icon_state = "rev"
	leader_icon_state = "rev_head"
	plane = REV_ANTAG_HUD_PLANE

/datum/data_hud/antag/rev/is_antag_type(var/mob/living/user)
	if(!..())
		return
	if(isrev(user) || isrevhead(user))
		return HUD_ON

/datum/data_hud/antag/rev/is_leader(var/mob/user)
	if(isrevhead(user))
		return HUD_ON

var/global/datum/data_hud/antag/rev/rev_hud = new /datum/data_hud/antag/rev()

/datum/data_hud/antag/dummy	// prevents people from right clicking mobs to see things they shouldn't.
	name = "dummy"
	plane = DUMMY_HUD_PLANE
	flags = SEE_IN_MECH
	icon_state = "white"

/datum/data_hud/antag/dummy/New()
	..()
	hud_image.alpha = 0
	hud_image.layer = REALLY_LOW_LAYER

/datum/data_hud/antag/dummy/check(var/mob/user)
	return ismob(user)

var/global/datum/data_hud/antag/dummy/dummy_hud = new /datum/data_hud/antag/dummy()
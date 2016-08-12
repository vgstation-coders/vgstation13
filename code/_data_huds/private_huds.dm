/proc/find_private_hud_slot()
	for(var/i = CUSTOM_HUD_PLANE_START to CUSTOM_HUD_PLANE_END)
		var/priv_hud = master_controller.active_data_huds["private_hud[i]"]
		if(priv_hud)
			var/datum/data_hud/antag/private/potential_slot = priv_hud
			if(!(potential_slot.minds.len||potential_slot.leader))
				return potential_slot

/datum/mind/proc/get_private_hud(var/hud_type)
	for(var/datum/data_hud/antag/private/dhud in dhuds)
		if(istype(dhud,hud_type))
			return dhud
	var/slot = find_private_hud_slot()
	if(slot)
		return new hud_type(slot)
	else
		error("RAN OUT OF PRIVATE HUD SLOTS, PANIC.")

/datum/mind/proc/create_priv_hud(var/hud_type,var/mob/follower)
	var/datum/data_hud/antag/private/phud = get_private_hud(hud_type)
	dhuds += phud
	phud.leader = src
	phud.minds += list(src,follower.mind)
	phud.update_mob(current)
	phud.update_mob(follower)
	follower.mind.dhuds += phud

/datum/mind/proc/remove_priv_hud(var/hud_type)
	for(var/datum/data_hud/antag/private/dhud in dhuds)
		if(istype(dhud,hud_type))
			dhud.remove_hud(current)
			dhuds -= dhud
			return

/datum/data_hud/antag/private
	var/datum/mind/leader
	var/list/minds = list()
	flags = SEE_IN_MECH|IS_ANTAG_HUD|IGNORE_BASE_NEW

/datum/data_hud/antag/private/is_leader(var/mob/user)
	if(user.mind == leader)
		return HUD_ON

/datum/data_hud/antag/private/is_antag_type(var/mob/user)
	if(!..())
		return
	if(user.mind in minds)
		return HUD_ON

/datum/data_hud/antag/private/New(var/datum/data_hud/antag/private/old_hud,var/number = 0)
	if(number)
		name = "private_hud[number]"
		plane = number
		flags &= ~IGNORE_BASE_NEW
		..()
	if(old_hud)
		master_controller.active_data_huds[old_hud.name] = src
		visible = old_hud.visible
		invisible = old_hud.invisible
		plane = old_hud.plane
		dummy = old_hud.dummy
		..()

/datum/data_hud/antag/private/remove_hud(var/mob/user)
	minds -= user.mind
	..()

/datum/data_hud/antag/private/vampire
	name = "vampire"
	icon_state = "vampthrall"
	leader_icon_state = "vampire"

var/global/VAMP_HUD = /datum/data_hud/antag/private/vampire

/datum/data_hud/antag/private/greytide
	name = "greytide"
	icon_state = "greytide"
	leader_icon_state = "greytide_head"

var/global/GREYTIDE_HUD = /datum/data_hud/antag/private/greytide

/datum/data_hud/antag/private/necro
	name = "necromancer"
	icon_state = "minion"
	leader_icon_state = "necromancer"

var/global/NECRO_HUD = /datum/data_hud/antag/private/necro
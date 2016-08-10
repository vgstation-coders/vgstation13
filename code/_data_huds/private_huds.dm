proc/find_private_hud_slot()
	for(var/i = CUSTOM_HUD_PLANE_START to CUSTOM_HUD_PLANE_END)
		if(master_controller.active_data_huds["private_hud[i]"]
			var/datum/data_hud/antag/private/potential_slot
			if(!(potential_slot.minds.len))
				return potential_slot.plane

/datum/data_hud/antag/private
	var/list/minds = list()
	flags = SEE_IN_MECH|IS_ANTAG_HUD

/datum/data_hud/antag/private/New(var/datum/data_hud/antag/private/old_hud,var/number = 0)
	if(number)
		name = "private_hud[number]"
	else
		master_controller.active_data_huds[old_hud.name] = src
		old_hud.

/datum/data_hud/antag/private/is_antag_type(var/mob/user)
	return (minds[user.mind])

/datum/data_hud/antag/private

for(var/i = CUSTOM_HUD_PLANE_START to CUSTOM_HUD_PLANE_END)
	master_controller.active_data_huds["private_hud[i]"] = new /datum/data_hud/antag/private(number = i)
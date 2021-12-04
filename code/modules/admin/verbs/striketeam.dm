
/datum/admins/proc/custom_strike_team(var/mob/user)
	var/outfit_type = select_loadout()
	var/datum/striketeam/custom/team = new /datum/striketeam/custom()
	if(outfit_type && ispath(outfit_type))
		team.outfit_datum = outfit_type
	team.trigger_strike(user)

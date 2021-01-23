
/datum/admins/proc/custom_strike_team(var/mob/user)

	var/list/outfits = (typesof(/datum/outfit/) - /datum/outfit/ - /datum/outfit/striketeam/)
	var/outfit_type = input(user,"Outfit Type","Equip Outfit","") as null|anything in outfits
	var/datum/striketeam/custom/team = new /datum/striketeam/custom()
	team.outfit_datum = outfit_type
	team.trigger_strike(user)

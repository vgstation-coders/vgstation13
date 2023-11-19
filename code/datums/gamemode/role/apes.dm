/datum/role/apes
	name = "Apes"
	id = THE_APES
	special_role = THE_APES
	logo_state = "monkey-logo"
	greets = null
	default_admin_voice = "Ape King"
	admin_voice_style = "rough"

/datum/role/apes/OnPostSetup(var/laterole = TRUE)
	if(faction)
		return
	var/datum/faction/F = find_active_faction_by_type(/datum/faction/apes)
	if(!F)
		F = ticker.mode.CreateFaction(/datum/faction/apes, null, 1)
	F.HandleRecruitedRole(src)
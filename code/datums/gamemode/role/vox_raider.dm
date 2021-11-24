/datum/role/vox_raider
	name = VOXRAIDER
	id = VOXRAIDER
	special_role = VOXRAIDER
	required_pref = VOXRAIDER
	disallow_job = TRUE
	logo_state = "vox-logo"
	default_admin_voice = "Vox Shoal"
	admin_voice_style = "vox"

/datum/role/vox_raider/OnPostSetup()
	.=..()
	if(!.)
		return
	antag.current.forceMove(pick(voxstart))
	equip_raider(antag.current)
	equip_vox_raider(antag.current)

/datum/role/vox_raider/chief_vox
	logo_state = "vox-logo"

/datum/role/vox_raider/StatPanel()
	var/datum/faction/vox_shoal/vox = faction
	if (!istype(vox))
		return
	var/minutes = round(vox.time_left / (2*60), 1)
	var/seconds = add_zero("[vox.time_left / 2 % 60]", 2)
	return "Raid time left: [minutes]:[seconds] minutes."

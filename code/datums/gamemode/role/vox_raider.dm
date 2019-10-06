/datum/role/vox_raider
	name = VOXRAIDER
	id = VOXRAIDER
	special_role = VOXRAIDER
	required_pref = VOXRAIDER
	disallow_job = TRUE
	logo_state = "vox-logo"

/datum/role/vox_raider/chief_vox
	logo_state = "vox-logo"

/datum/role/vox_raider/StatPanel()
	var/datum/faction/vox_shoal/vox = faction
	if (!istype(vox))
		return
	var/dat = "Raid time left: <b>[num2text((vox.time_left /(2*60)))]:[add_zero(num2text(vox.time_left/2 % 60), 2)]</b>"
	return dat
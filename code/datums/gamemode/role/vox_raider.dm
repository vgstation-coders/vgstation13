/datum/role/vox_raider
	name = VOXRAIDER
	id = VOXRAIDER
	special_role = VOXRAIDER
	required_pref = VOXRAIDER
	disallow_job = TRUE
	logo_state = "vox-logo"

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
	var/dat = "Raid time left: [num2text((vox.time_left /(2*60)))]:[add_zero(num2text(vox.time_left/2 % 60), 2)] minutes."
	return dat
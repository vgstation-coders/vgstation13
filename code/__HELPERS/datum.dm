/datum
	var/list/datum_components
	var/list/active_timers
	var/list/open_uis

/**
 * Called on all objects at round start when the Objects subsystem loads after the map and vaults are loaded in.
 *
 * Vital notes:
 * When using this proc, set flags |= ATOM_INITIALIZED or call the /atom/ level parent somehow. Otherwise, things may get initialized twice in vaults.
 * This proc is called only by the objects subsystem itself (during pregame), unless manually called (by New() usually).
 * If you include this in New(), check for SSobj && SSobj.initialized so that you don't initialize whatever you're spawning in twice.
 * if(ticker) isn't good enough, vaults can spawn in after the ticker is started but before the Objects subsystem is started.
 */
/datum/proc/initialize()
	return TRUE

//Called when a variable is edited by admin powers
//Return 1 to block the varedit!
/datum/proc/variable_edited(variable_name, old_value, new_value)
	return

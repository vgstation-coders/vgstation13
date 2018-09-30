/var/datum/xgm_data/XGM = new()

/datum/xgm_data
	// List of ID = gas datum.
	var/list/gases = list()
	// The friendly, human-readable name for the gas.
	var/list/name = list()
	// Shorter and HTML formatted names, falls back to regular name if no short name is given.
	var/list/short_name = list()
	// Specific heat of the gas. Used for calculating heat capacity.
	var/list/specific_heat = list()
	// Molar mass of the gas. Used for calculating specific entropy.
	var/list/molar_mass = list()
	// Tile overlays. /images, created from references to 'icons/effects/tile_effects.dmi'
	var/list/tile_overlay = list()
	// Overlay limits. There must be at least this many moles for the overlay to appear.
	var/list/overlay_limit = list()
	// Flags.
	var/list/flags = list()

/datum/xgm_data/New()
	for(var/p in subtypesof(/datum/gas))
		var/datum/gas/gas = new p()

		if(!add(gas))
			stack_trace("Duplicate gas id '[gas.id]' in from typepath '[p]'")

/datum/xgm_data/proc/add(var/datum/gas/gas)
	if(gases[gas.id])
		return FALSE
	return update(gas)

/datum/xgm_data/proc/update(var/datum/gas/gas)
	gases[gas.id] = gas
	name[gas.id] = gas.name
	short_name[gas.id] = gas.short_name || gas.name
	specific_heat[gas.id] = gas.specific_heat
	molar_mass[gas.id] = gas.molar_mass
	flags[gas.id] = gas.flags
	if(gas.tile_overlay)
		tile_overlay[gas.id] = image('icons/effects/tile_effects.dmi', gas.tile_overlay, FLY_LAYER)
	if(gas.overlay_limit)
		overlay_limit[gas.id] = gas.overlay_limit
	return TRUE

/datum/xgm_data/proc/update_id(var/id)
	if(gases[id])
		return update(gases[id])
	return FALSE

/datum/xgm_data/proc/update_all()
	for(var/id in gases)
		update_id(id)

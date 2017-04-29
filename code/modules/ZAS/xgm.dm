/var/datum/xgm_data/XGM = new

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

/hook_handler/xgm/proc/OnStartup(var/list/args)
	XGM = new
	for (var/p in subtypesof(/datum/gas))
		var/datum/gas/gas = new p

		if (gas.id in XGM.gases)
			stack_trace("Duplicate gas id '[gas.id]' in from typepath '[p]'")
			continue

		XGM.gases[gas.id] = gas
		XGM.name[gas.id] = gas.name
		XGM.short_name[gas.id] = gas.short_name || gas.name
		XGM.specific_heat[gas.id] = gas.specific_heat
		XGM.molar_mass[gas.id] = gas.molar_mass
		XGM.flags[gas.id] = gas.flags
		if (gas.tile_overlay)
			XGM.tile_overlay[gas.id] = image('icons/effects/tile_effects.dmi', gas.tile_overlay, FLY_LAYER)
		if (gas.overlay_limit)
			XGM.overlay_limit[gas.id] = gas.overlay_limit

	return 1
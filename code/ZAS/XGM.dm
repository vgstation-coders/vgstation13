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
	// Tile overlays.
	var/list/tile_overlay = list()
	// Overlay limits. There must be strictly more than this many moles per liter for the overlay to appear.
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
		tile_overlay[gas.id] = gas.tile_overlay
	if(isnum(gas.overlay_limit))
		overlay_limit[gas.id] = gas.overlay_limit
	return TRUE

/datum/xgm_data/proc/update_id(var/id)
	if(gases[id])
		return update(gases[id])
	return FALSE

/datum/xgm_data/proc/update_all()
	for(var/id in gases)
		update_id(id)


/datum/xgm_data/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = NANOUI_FOCUS)
	var/list/data = list()
	var/list/data_gases = list()
	for(var/g in gases)
		var/list/L = list()
		L["id"] = g
		L["name"] = name[g]
		data_gases[++data_gases.len] = L //We have to use this syntax because += will concatenate the lists instead.
	data["gases"] = data_gases

	//Everything below this point is taken directly from an example implementation, other than the args to create the new UI.
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		// The ui does not exist, so we'll create a new one.
		ui = new(user, src, ui_key, "XGM_data.tmpl", "XGM Panel", 550, 410, ignore_distance = TRUE)
		// When the UI is first opened this is the data it will use.
		ui.set_initial_data(data)
		// Open the new ui window.
		ui.open()
		// Auto update every Master Controller tick.
		ui.set_auto_update(1)

/datum/xgm_data/Topic(href, href_list)
	if(..())
		return TRUE
	if(!check_rights(R_VAREDIT)) //Can't do anything useful with this without +VAREDIT anyway
		return FALSE

	if(href_list["edit"])
		usr.client.debug_variables(gases[href_list["edit"]])
		return TRUE

	if(href_list["update"])
		update_id(href_list["update"])
		return TRUE

	if(href_list["create"])
		var/id = input("Enter new gasid") as text|null
		if(!isnull(id))
			if(gases[id])
				alert("That gasid is already used.", "Duplicate gasid")
			else
				var/datum/gas/G = new()
				G.id = id
				add(G)
		return TRUE

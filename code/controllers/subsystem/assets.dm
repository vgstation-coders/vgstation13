var/datum/subsystem/assets/SSassets

/datum/subsystem/assets
	name = "Assets"
	flags = SS_NO_FIRE
	var/list/datum/asset_cache_item/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/subsystem/assets/New()
	NEW_SS_GLOBAL(SSassets)

/datum/subsystem/assets/Initialize()

	// -- FIXME ASSETS:.
	// -- Old, crusty /vg/ style of populating assets (relying on 'global cache.dm')
	// TOFIX asap!!! Having two concurrent, parralel & independant asset delivery system is BAD
	populate_asset_cache()

	var/newtransporttype = /datum/asset_transport
	switch (config.tg_asset_transport)
		if ("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if (newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype ()
	if (newtransport.validate_config())
		transport = newtransport
	transport.Load()

	for(var/type in typesof(/datum/tg_asset))
		var/datum/tg_asset/A = type
		if (type != initial(A._abstract))
			load_asset_datum(type)

	transport.Initialize(cache)

/datum/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload

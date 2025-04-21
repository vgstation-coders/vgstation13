//These datums are used to populate the asset cache, the proc "register()" does this.
//Place any asset datums you create in asset_list_items.dm

//all of our asset datums, used for referring to these later
var/list/tg_asset_datums = list()

//get an assetdatum or make a new one
//does NOT ensure it's filled, if you want that use get_tg_asset_datum()
/proc/load_asset_datum(type)
	return global.tg_asset_datums[type] || new type()

/proc/get_tg_asset_datum(type)
	var/datum/tg_asset/loaded_asset = global.tg_asset_datums[type] || new type()
	return loaded_asset.ensure_ready()

/datum/tg_asset
	var/_abstract = /datum/tg_asset
	var/cached_serialized_url_mappings
	var/cached_serialized_url_mappings_transport_type

	/// Whether or not this asset should be loaded in the "early assets" SS
	var/early = FALSE

	/// Whether or not this asset can be cached across rounds of the same commit under the `CACHE_ASSETS` config.
	/// This is not a *guarantee* the asset will be cached. Not all asset subtypes respect this field, and the
	/// config can, of course, be disabled.
	/// Disable this if your asset can change between rounds on the same exact version of the code.
	var/cross_round_cachable = FALSE

/datum/tg_asset/New()
	global.tg_asset_datums[type] = src
	register()

/// Stub that allows us to react to something trying to get us
/// Not useful here, more handy for sprite sheets
/datum/tg_asset/proc/ensure_ready()
	return src

/// Stub to hook into if your asset is having its generation queued by SSasset_loading
/datum/tg_asset/proc/queued_generation()
	CRASH("[type] inserted into SSasset_loading despite not implementing /proc/queued_generation")

/datum/tg_asset/proc/get_url_mappings()
	return list()

/// Returns a cached tgui message of URL mappings
/datum/tg_asset/proc/get_serialized_url_mappings()
	if (isnull(cached_serialized_url_mappings) || cached_serialized_url_mappings_transport_type != SSassets.transport.type)
		cached_serialized_url_mappings = TGUI_CREATE_MESSAGE("asset/mappings", get_url_mappings())
		cached_serialized_url_mappings_transport_type = SSassets.transport.type

	return cached_serialized_url_mappings

/datum/tg_asset/proc/register()
	return

/datum/tg_asset/proc/send(client)
	return

/// Returns whether or not the asset should attempt to read from cache
/datum/tg_asset/proc/should_refresh()
	return !cross_round_cachable || !config.cache_assets

/// Immediately regenerate the asset, overwriting any cache.
/datum/tg_asset/proc/regenerate()
	unregister()
	cached_serialized_url_mappings = null
	cached_serialized_url_mappings_transport_type = null
	register()

/// Unregisters any assets from the transport.
/datum/tg_asset/proc/unregister()
	CRASH("unregister() not implemented for asset [type]!")

/// Simply takes any generated file and saves it to the round-specific /logs folder. Useful for debugging potential issues with spritesheet generation/display.
/// Only called when the SAVE_SPRITESHEETS config option is uncommented.
/datum/tg_asset/proc/save_to_logs(file_name, file_location)
	var/asset_path = "data/logs/[date_string]/generated_assets/[file_name]"
	fdel(asset_path) // just in case, sadly we can't use rust_g stuff here.
	fcopy(file_location, asset_path)

/// If you don't need anything complicated.
/datum/tg_asset/simple
	_abstract = /datum/tg_asset/simple
	/// list of assets for this datum in the form of:
	/// asset_filename = asset_file. At runtime the asset_file will be
	/// converted into a asset_cache datum.
	var/assets = list()
	/// Set to true to have this asset also be sent via the legacy browse_rsc
	/// system when cdn transports are enabled?
	var/legacy = FALSE
	/// TRUE for keeping local asset names when browse_rsc backend is used
	var/keep_local_name = FALSE

/datum/tg_asset/simple/register()
	for(var/asset_name in assets)
		var/datum/asset_cache_item/ACI = SSassets.transport.register_asset(asset_name, assets[asset_name])
		if (!ACI)
			log_debug("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		if (legacy)
			ACI.legacy = legacy
		if (keep_local_name)
			ACI.keep_local_name = keep_local_name
		assets[asset_name] = ACI

/datum/tg_asset/simple/send(client)
	. = SSassets.transport.send_assets(client, assets)

/datum/tg_asset/simple/get_url_mappings()
	. = list()
	for (var/asset_name in assets)
		.[asset_name] = SSassets.transport.get_asset_url(asset_name, assets[asset_name])

/datum/tg_asset/simple/unregister()
	for (var/asset_name in assets)
		SSassets.transport.unregister_asset(asset_name)

// For registering or sending multiple others at once
/datum/tg_asset/group
	_abstract = /datum/tg_asset/group
	var/list/children

/datum/tg_asset/group/register()
	for(var/type in children)
		load_asset_datum(type)

/datum/tg_asset/group/send(client/C)
	for(var/type in children)
		var/datum/tg_asset/A = get_tg_asset_datum(type)
		. = A.send(C) || .

/datum/tg_asset/group/get_url_mappings()
	. = list()
	for(var/type in children)
		var/datum/tg_asset/A = get_tg_asset_datum(type)
		. += A.get_url_mappings()

/datum/tg_asset/group/unregister()
	for (var/type in children)
		var/datum/tg_asset/A = get_tg_asset_datum(type)
		A.unregister()

// -- IMPLEMENTABLE : tg_asset for changelog items

//Generates assets based on iconstates of a single icon
// -- IMPLEMENTABLE : tg_asset for icon_states


/// Namespace'ed assets (for static css and html files)
/// When sent over a cdn transport, all assets in the same asset datum will exist in the same folder, as their plain names.
/// Used to ensure css files can reference files by url() without having to generate the css at runtime, both the css file and the files it depends on must exist in the same namespace asset datum. (Also works for html)
/// For example `blah.css` with asset `blah.png` will get loaded as `namespaces/a3d..14f/f12..d3c.css` and `namespaces/a3d..14f/blah.png`. allowing the css file to load `blah.png` by a relative url rather then compute the generated url with get_url_mappings().
/// The namespace folder's name will change if any of the assets change. (excluding parent assets)
/datum/tg_asset/simple/namespaced
	_abstract = /datum/tg_asset/simple/namespaced
	/// parents - list of the parent asset or assets (in name = file assoicated format) for this namespace.
	/// parent assets must be referenced by their generated url, but if an update changes a parent asset, it won't change the namespace's identity.
	var/list/parents = list()

/datum/tg_asset/simple/namespaced/register()
	if (legacy)
		assets |= parents
	var/list/hashlist = list()
	var/list/sorted_assets = sortList(assets)

	for (var/asset_name in sorted_assets)
		var/datum/asset_cache_item/ACI = new(asset_name, sorted_assets[asset_name])
		if (!ACI?.hash)
			log_debug("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		hashlist += ACI.hash
		sorted_assets[asset_name] = ACI
	var/namespace = md5(hashlist.Join())

	for (var/asset_name in parents)
		var/datum/asset_cache_item/ACI = new(asset_name, parents[asset_name])
		if (!ACI?.hash)
			log_debug("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.namespace_parent = TRUE
		sorted_assets[asset_name] = ACI

	for (var/asset_name in sorted_assets)
		var/datum/asset_cache_item/ACI = sorted_assets[asset_name]
		if (!ACI?.hash)
			log_debug("ERROR: Invalid asset: [type]:[asset_name]:[ACI]")
			continue
		ACI.namespace = namespace

	assets = sorted_assets
	..()

/// Get a html string that will load a html asset.
/// Needed because byond doesn't allow you to browse() to a url.
/datum/tg_asset/simple/namespaced/proc/get_htmlloader(filename)
	return url2htmlloader(SSassets.transport.get_asset_url(filename, assets[filename]))

/// A subtype to generate a JSON file from a list
/datum/tg_asset/json
	_abstract = /datum/tg_asset/json
	/// The filename, will be suffixed with ".json"
	var/name

/datum/tg_asset/json/send(client)
	return SSassets.transport.send_assets(client, "[name].json")

/datum/tg_asset/json/get_url_mappings()
	return list(
		"[name].json" = SSassets.transport.get_asset_url("[name].json"),
	)

/datum/tg_asset/json/register()
	var/filename = "data/[name].json"
	fdel(filename)
	rustg_file_write(json_encode(generate()), filename)
	SSassets.transport.register_asset("[name].json", fcopy_rsc(filename))
	fdel(filename)

/// Returns the data that will be JSON encoded
/datum/tg_asset/json/proc/generate()
	CRASH("generate() not implemented for [type]!")

/datum/tg_asset/json/unregister()
	SSassets.transport.unregister_asset("[name].json")

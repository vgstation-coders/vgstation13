/datum/config_flag/numerical/tgui_max_chunk_count
	text_name = "tgui_max_chunk_count"
	value = 32

/datum/config_flag/tg_asset_transport
	text_name = "tg_asset_transport"
	value = "simple"

//Disabled during dev, enabled during prod
/datum/config_flag/toggle/cache_assets
	text_name = "cache_assets"
	value = 1

/datum/config_flag/toggle/smart_cache_assets
	text_name = "smart_cache_assets"
	value = 1

//Disabled by default.
/datum/config_flag/toggle/save_spritesheets
	text_name = "save_spritesheets"
	value = 0

//Disabled by default
/datum/config_flag/toggle/asset_simple_preload
	text_name = "asset_simple_preload"
	value = 0

//Currently unused
/datum/config_flag/asset_cdn_webroot
	text_name = "asset_cdn_webroot"
	value = ""

/datum/config_flag/asset_cdn_url
	text_name = "asset_cdn_url"
	value = ""

var/datum/subsystem/assets/SSassets


/datum/subsystem/assets
	name       = "Asset Cache"
	init_order = SS_INIT_ASSETS
	flags      = SS_NO_FIRE


/datum/subsystem/assets/New()
	NEW_SS_GLOBAL(SSassets)


/datum/subsystem/assets/Initialize(timeofday)
	populate_asset_cache()
	..()

#define ASSET_CACHE_SEND_TIMEOUT 2.5 SECONDS // Amount of time MAX to send an asset, if this get exceeded we cancel the sleeping.

//List of ALL assets for the above, format is list(filename = asset).
/var/list/asset_cache      = list()
/var/asset_cache_populated = FALSE

/// Associative list of type path -> instance of type path
var/list/asset_datums = list()

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
/proc/send_asset(var/client/client, var/asset_name, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	while(!global.asset_cache_populated)
		sleep(5)

	if(!asset_cache.Find(asset_name))
		CRASH("Attempted to send nonexistant asset [asset_name] to [client.key]!")

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(asset_cache[asset_name], asset_name)
	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
			return 0

		client.cache += asset_name
		return 1

	if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
		return 0

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

/proc/send_asset_list(var/client/client, var/list/asset_list, var/verify = TRUE)
	if(!istype(client))
		if(ismob(client))
			var/mob/M = client
			if(M.client)
				client = M.client

			else
				return 0

		else
			return 0

	var/list/unreceived = asset_list - (client.cache + client.sending)
	if(!unreceived || !unreceived.len)
		return 0

	for(var/asset in unreceived)
		client << browse_rsc(asset_cache[asset], asset)

	if(!verify || !winexists(client, "asset_cache_browser")) // Can't access the asset cache browser, rip.
		if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
			return 0

		client.cache += unreceived
		return 1

	if(!client) // winexist() waits for a response from the client, so we need to make sure the client still exists.
		return 0

	client.sending |= unreceived
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = ASSET_CACHE_SEND_TIMEOUT * client.sending.len
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		sleep(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	asset_cache |= asset_name
	asset_cache[asset_name] = asset


/proc/get_asset_datum(path)
	return asset_datums[path]

//From here on out it's populating the asset cache.

/proc/populate_asset_cache()
	for(var/type in typesof(/datum/asset) - list(/datum/asset, /datum/asset/simple, /datum/asset/spritesheet))
		var/datum/asset/A = new type()
		asset_datums += type
		asset_datums[type] = A
		A.register()

	global.asset_cache_populated = TRUE

//These datums are used to populate the asset cache, the proc "register()" does this.
/datum/asset/proc/register()
	return

/datum/asset/proc/send()
	return

// TG uses this to allow hosting files on external URLs and have pages load from there rather than the BYOND cache.
// We don't do that so this is just here to facilitate porting tgui, and always returns the filename of the asset instead of a url.
/datum/asset/proc/get_url_mappings()
	CRASH("not implemented")

//If you don't need anything complicated.
/datum/asset/simple
	var/list/assets = list()

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])

/datum/asset/simple/get_url_mappings()
	. = list()
	for(var/asset_name in assets)
		.[asset_name] = asset_name

/datum/asset/simple/send(client)
	send_asset_list(client, assets)

//DEFINITIONS FOR ASSET DATUMS START HERE.


/datum/asset/simple/pda
	assets = list(
		"pda.css"		= 'html/browser/pda.css'
	)

/datum/asset/simple/pda_stationmap
	assets = list(
		"pda_minimap_box.png"	= 'icons/pda_icons/pda_minimap_box.png',
		"pda_minimap_bg_notfound.png"	= 'icons/pda_icons/pda_minimap_bg_notfound.png',
		"pda_minimap_deff.png"					= 'icons/pda_icons/pda_minimap_deff.png',
		"pda_minimap_meta.png"				= 'icons/pda_icons/pda_minimap_meta.png',
		"pda_minimap_loc.gif"					= 'icons/pda_icons/pda_minimap_loc.gif',
		"pda_minimap_mkr.gif"					= 'icons/pda_icons/pda_minimap_mkr.gif'
	)

/datum/asset/simple/pda_snake
	assets = list(
		"snake_background.png"		= 'icons/pda_icons/snake_icons/snake_background.png',
		"snake_highscore.png"			= 'icons/pda_icons/snake_icons/snake_highscore.png',
		"snake_newgame.png"			= 'icons/pda_icons/snake_icons/snake_newgame.png',
		"snake_station.png"				= 'icons/pda_icons/snake_icons/snake_station.png',
		"snake_pause.png"				= 'icons/pda_icons/snake_icons/snake_pause.png',
		"snake_maze1.png"				= 'icons/pda_icons/snake_icons/snake_maze1.png',
		"snake_maze2.png"				= 'icons/pda_icons/snake_icons/snake_maze2.png',
		"snake_maze3.png"				= 'icons/pda_icons/snake_icons/snake_maze3.png',
		"snake_maze4.png"				= 'icons/pda_icons/snake_icons/snake_maze4.png',
		"snake_maze5.png"				= 'icons/pda_icons/snake_icons/snake_maze5.png',
		"snake_maze6.png"				= 'icons/pda_icons/snake_icons/snake_maze6.png',
		"snake_maze7.png"				= 'icons/pda_icons/snake_icons/snake_maze7.png',
		"pda_snake_arrow_north.png"	= 'icons/pda_icons/snake_icons/arrows/pda_snake_arrow_north.png',
		"pda_snake_arrow_east.png"		= 'icons/pda_icons/snake_icons/arrows/pda_snake_arrow_east.png',
		"pda_snake_arrow_west.png"		= 'icons/pda_icons/snake_icons/arrows/pda_snake_arrow_west.png',
		"pda_snake_arrow_south.png"	='icons/pda_icons/snake_icons/arrows/pda_snake_arrow_south.png',
		"snake_0.png"						= 'icons/pda_icons/snake_icons/numbers/snake_0.png',
		"snake_1.png"						= 'icons/pda_icons/snake_icons/numbers/snake_1.png',
		"snake_2.png"						= 'icons/pda_icons/snake_icons/numbers/snake_2.png',
		"snake_3.png"						= 'icons/pda_icons/snake_icons/numbers/snake_3.png',
		"snake_4.png"						= 'icons/pda_icons/snake_icons/numbers/snake_4.png',
		"snake_5.png"						= 'icons/pda_icons/snake_icons/numbers/snake_5.png',
		"snake_6.png"						= 'icons/pda_icons/snake_icons/numbers/snake_6.png',
		"snake_7.png"						= 'icons/pda_icons/snake_icons/numbers/snake_7.png',
		"snake_8.png"						= 'icons/pda_icons/snake_icons/numbers/snake_8.png',
		"snake_9.png"						= 'icons/pda_icons/snake_icons/numbers/snake_9.png',
		"pda_snake_body_east.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_east.png',
		"pda_snake_body_east_full.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_body_east_full.png',
		"pda_snake_body_west.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_west.png',
		"pda_snake_body_west_full.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_body_west_full.png',
		"pda_snake_body_north.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_north.png',
		"pda_snake_body_north_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_body_north_full.png',
		"pda_snake_body_south.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_body_south.png',
		"pda_snake_body_south_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_body_south_full.png',
		"pda_snake_bodycorner_eastnorth.png" 			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth.png',
		"pda_snake_bodycorner_eastnorth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth_full.png',
		"pda_snake_bodycorner_eastsouth.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth.png',
		"pda_snake_bodycorner_eastsouth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth_full.png',
		"pda_snake_bodycorner_westnorth.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth.png',
		"pda_snake_bodycorner_westnorth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth_full.png',
		"pda_snake_bodycorner_westsouth.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth.png',
		"pda_snake_bodycorner_westsouth_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth_full.png',
		"pda_snake_bodycorner_eastnorth2.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth2.png',
		"pda_snake_bodycorner_eastnorth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastnorth2_full.png',
		"pda_snake_bodycorner_eastsouth2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth2.png',
		"pda_snake_bodycorner_eastsouth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_eastsouth2_full.png',
		"pda_snake_bodycorner_westnorth2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth2.png',
		"pda_snake_bodycorner_westnorth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westnorth2_full.png',
		"pda_snake_bodycorner_westsouth2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth2.png',
		"pda_snake_bodycorner_westsouth2_full.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_bodycorner_westsouth2_full.png',
		"pda_snake_bodytail_east.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_east.png',
		"pda_snake_bodytail_north.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_north.png',
		"pda_snake_bodytail_south.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_south.png',
		"pda_snake_bodytail_west.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bodytail_west.png',
		"pda_snake_bonus1.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus1.png',
		"pda_snake_bones2.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus2.png',
		"pda_snake_bonus3.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus3.png',
		"pda_snake_bonus4.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus4.png',
		"pda_snake_bonus5.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus5.png',
		"pda_snake_bonus6.png"		= 'icons/pda_icons/snake_icons/elements/pda_snake_bonus6.png',
		"pda_snake_egg.png"				= 'icons/pda_icons/snake_icons/elements/pda_snake_egg.png',
		"pda_snake_head_east.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_east.png',
		"pda_snake_head_east_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_east_open.png',
		"pda_snake_head_west.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_west.png',
		"pda_snake_head_west_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_west_open.png',
		"pda_snake_head_north.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_north.png',
		"pda_snake_head_north_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_north_open.png',
		"pda_snake_head_south.png"			= 'icons/pda_icons/snake_icons/elements/pda_snake_head_south.png',
		"pda_snake_head_south_open.png"	= 'icons/pda_icons/snake_icons/elements/pda_snake_head_south_open.png',
		"snake_volume0.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume0.png',
		"snake_volume1.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume1.png',
		"snake_volume2.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume2.png',
		"snake_volume3.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume3.png',
		"snake_volume4.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume4.png',
		"snake_volume5.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume5.png',
		"snake_volume6.png"		= 'icons/pda_icons/snake_icons/volume/snake_volume6.png'
	)

/datum/asset/simple/pda_mine
	assets = list(
		"minesweeper_counter_0.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_0.png',
		"minesweeper_counter_1.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_1.png',
		"minesweeper_counter_2.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_2.png',
		"minesweeper_counter_3.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_3.png',
		"minesweeper_counter_4.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_4.png',
		"minesweeper_counter_5.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_5.png',
		"minesweeper_counter_6.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_6.png',
		"minesweeper_counter_7.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_7.png',
		"minesweeper_counter_8.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_8.png',
		"minesweeper_counter_9.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_counter_9.png',
		"minesweeper_tile_1.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_1.png',
		"minesweeper_tile_1_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_1_selected.png',
		"minesweeper_tile_2.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_2.png',
		"minesweeper_tile_2_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_2_selected.png',
		"minesweeper_tile_3.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_3.png',
		"minesweeper_tile_3_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_3_selected.png',
		"minesweeper_tile_4.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_4.png',
		"minesweeper_tile_4_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_4_selected.png',
		"minesweeper_tile_5.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_5.png',
		"minesweeper_tile_5_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_5_selected.png',
		"minesweeper_tile_6.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_6.png',
		"minesweeper_tile_6_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_6_selected.png',
		"minesweeper_tile_7.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_7.png',
		"minesweeper_tile_7_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_7_selected.png',
		"minesweeper_tile_8.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_8.png',
		"minesweeper_tile_8_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_8_selected.png',
		"minesweeper_tile_empty.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_empty.png',
		"minesweeper_tile_empty_selected.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_empty_selected.png',
		"minesweeper_tile_full.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_full.png',
		"minesweeper_tile_full_selected.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_full_selected.png',
		"minesweeper_tile_question.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_question.png',
		"minesweeper_tile_question_selected.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_question_selected.png',
		"minesweeper_tile_flag.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_flag.png',
		"minesweeper_tile_flag_selected.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_flag_selected.png',
		"minesweeper_tile_mine_unsplode.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_mine_unsplode.png',
		"minesweeper_tile_mine_splode.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_mine_splode.png',
		"minesweeper_tile_mine_wrong.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_tile_mine_wrong.png',
		"minesweeper_frame_counter.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_frame_counter.png',
		"minesweeper_frame_smiley.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_frame_smiley.png',
		"minesweeper_border_bot.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_bot.png',
		"minesweeper_border_top.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_top.png',
		"minesweeper_border_right.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_right.png',
		"minesweeper_border_left.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_border_left.png',
		"minesweeper_border_cornertopleft.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornertopleft.png',
		"minesweeper_border_cornertopright.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornertopright.png',
		"minesweeper_border_cornerbotleft.png"		= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornerbotleft.png',
		"minesweeper_border_cornerbotright.png"	= 'icons/pda_icons/minesweeper_icons/minesweeper_border_cornerbotright.png',
		"minesweeper_bg_beginner.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_beginner.png',
		"minesweeper_bg_intermediate.png"			= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_intermediate.png',
		"minesweeper_bg_expert.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_expert.png',
		"minesweeper_bg_custom.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_bg_custom.png',
		"minesweeper_flag.png"								= 'icons/pda_icons/minesweeper_icons/minesweeper_flag.png',
		"minesweeper_question.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_question.png',
		"minesweeper_settings.png"						= 'icons/pda_icons/minesweeper_icons/minesweeper_settings.png',
		"minesweeper_smiley_normal.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_normal.png',
		"minesweeper_smiley_press.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_press.png',
		"minesweeper_smiley_fear.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_fear.png',
		"minesweeper_smiley_dead.png"				= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_dead.png',
		"minesweeper_smiley_win.png"					= 'icons/pda_icons/minesweeper_icons/minesweeper_smiley_win.png'
	)

/datum/asset/simple/pda_spesspets
	assets = list(
		"spesspets_bg.png"			=	'icons/pda_icons/spesspets_icons/spesspets_bg.png',
		"spesspets_egg0.png"		=	'icons/pda_icons/spesspets_icons/spesspets_egg0.png',
		"spesspets_egg1.png"		=	'icons/pda_icons/spesspets_icons/spesspets_egg1.png',
		"spesspets_egg2.png"		=	'icons/pda_icons/spesspets_icons/spesspets_egg2.png',
		"spesspets_egg3.png"		=	'icons/pda_icons/spesspets_icons/spesspets_egg3.png',
		"spesspets_hatch.png"		=	'icons/pda_icons/spesspets_icons/spesspets_hatch.png',
		"spesspets_talk.png"		=	'icons/pda_icons/spesspets_icons/spesspets_talk.png',
		"spesspets_walk.png"		=	'icons/pda_icons/spesspets_icons/spesspets_walk.png',
		"spesspets_feed.png"		=	'icons/pda_icons/spesspets_icons/spesspets_feed.png',
		"spesspets_clean.png"		=	'icons/pda_icons/spesspets_icons/spesspets_clean.png',
		"spesspets_heal.png"		=	'icons/pda_icons/spesspets_icons/spesspets_heal.png',
		"spesspets_fight.png"		=	'icons/pda_icons/spesspets_icons/spesspets_fight.png',
		"spesspets_visit.png"		=	'icons/pda_icons/spesspets_icons/spesspets_visit.png',
		"spesspets_work.png"		=	'icons/pda_icons/spesspets_icons/spesspets_work.png',
		"spesspets_cash.png"		=	'icons/pda_icons/spesspets_icons/spesspets_cash.png',
		"spesspets_rate.png"		=	'icons/pda_icons/spesspets_icons/spesspets_rate.png',
		"spesspets_Corgegg.png"		=	'icons/pda_icons/spesspets_icons/spesspets_Corgegg.png',
		"spesspets_Chimpegg.png"	=	'icons/pda_icons/spesspets_icons/spesspets_Chimpegg.png',
		"spesspets_Borgegg.png"		=	'icons/pda_icons/spesspets_icons/spesspets_Borgegg.png',
		"spesspets_Syndegg.png"		=	'icons/pda_icons/spesspets_icons/spesspets_Syndegg.png',
		"spesspets_hunger.png"		=	'icons/pda_icons/spesspets_icons/spesspets_hunger.png',
		"spesspets_dirty.png"		=	'icons/pda_icons/spesspets_icons/spesspets_dirty.png',
		"spesspets_hurt.png"		=	'icons/pda_icons/spesspets_icons/spesspets_hurt.png',
		"spesspets_mine.png"		=	'icons/pda_icons/spesspets_icons/spesspets_mine.png',
		"spesspets_sleep.png"		=	'icons/pda_icons/spesspets_icons/spesspets_sleep.png',
		"spesspets_arrow_right.png"	=	'icons/pda_icons/spesspets_icons/spesspets_arrow_right.png',
		"spesspets_arrow_left.png"	=	'icons/pda_icons/spesspets_icons/spesspets_arrow_left.png'
	)

/datum/asset/simple/cmc_css_icons
	assets = list(
		//"cmc.css" = 'html/browser/cmc.css',
		"cmc_background.png" = 'icons/cmc/css_icons/background.png',
		"cmc_0.png" = 'icons/cmc/css_icons/0.png',
		"cmc_1.png" = 'icons/cmc/css_icons/1.png',
		"cmc_2.png" = 'icons/cmc/css_icons/2.png',
		"cmc_3.png" = 'icons/cmc/css_icons/3.png',
		"cmc_4.png" = 'icons/cmc/css_icons/4.png',
		"cmc_5.png" = 'icons/cmc/css_icons/5.png',
		"cmc_6.png" = 'icons/cmc/css_icons/6.png',
		"cmc_7.png" = 'icons/cmc/css_icons/7.png'
	)
/*
/datum/asset/simple/nanoui_maps/New()
	for(var/z in 1 to world.maxz)
		if(z == map.zCentcomm)
			continue
		assets["[map.nameShort][z].png"] = file("[getMinimapFile(z)].png")
*/

//Registers HTML I assets.
/datum/asset/HTML_interface/register()
	for(var/path in typesof(/datum/html_interface))
		var/datum/html_interface/hi = new path()
		hi.registerResources()

/datum/asset/simple/chartJS
	assets = list("Chart.js" = 'code/modules/html_interface/Chart.js')

/datum/asset/simple/power_chart
	assets = list("powerChart.js" = 'code/modules/power/powerChart.js')

/datum/asset/simple/paint_tool
	assets = list(
		"paintTool.js" = 'code/modules/html_interface/paintTool/paintTool.js',
		"canvas.js" =  'code/modules/html_interface/paintTool/canvas.js',
		"canvas.css" =  'code/modules/html_interface/paintTool/canvas.css',
		"checkerboard.png" =  'code/modules/html_interface/paintTool/checkerboard.png'
	)

/datum/asset/simple/util
	assets = list(
		"href_multipart_handler.js" =  'code/modules/html_interface/href_multipart_handler.js'
	)

/datum/asset/simple/emoji_list
	assets = list(
		"emoji-happy.png"		=	'icons/pda_icons/emoji/happy.png',
		"emoji-sad.png"		=	'icons/pda_icons/emoji/sad.png',
		"emoji-angry.png"		=	'icons/pda_icons/emoji/angry.png',
		"emoji-confused.png"		=	'icons/pda_icons/emoji/confused.png',
		"emoji-pensive.png"		=	'icons/pda_icons/emoji/pensive.png',
		"emoji-rolling_eyes.png"		=	'icons/pda_icons/emoji/rolling_eyes.png',
		"emoji-noface.png"		=	'icons/pda_icons/emoji/noface.png',
		"emoji-joy.png"		=	'icons/pda_icons/emoji/joy.png',
		"emoji-gun.png"		=	'icons/pda_icons/emoji/gun.png',
		"emoji-ok_hand.png"		=	'icons/pda_icons/emoji/ok_hand.png',
		"emoji-middle_finger.png"		=	'icons/pda_icons/emoji/middle_finger.png',
		"emoji-thinking.png"		=	'icons/pda_icons/emoji/thinking.png',
		"emoji-thumbs_up.png"		=	'icons/pda_icons/emoji/thumbs_up.png',
		"emoji-thumbs_down.png"		=	'icons/pda_icons/emoji/thumbs_down.png',
		"emoji-rocket_ship.png"		=	'icons/pda_icons/emoji/rocket_ship.png',
		"emoji-tada.png"		=	'icons/pda_icons/emoji/tada.png',
		"emoji-heart.png"		=	'icons/pda_icons/emoji/heart.png',
		"emoji-carp.png"		=	'icons/pda_icons/emoji/carp.png',
		"emoji-clown.png"		=	'icons/pda_icons/emoji/clown.png',
		"emoji-prohibited.png"		=	'icons/pda_icons/emoji/prohibited.png',
		"emoji-sunglasses.png"		=	'icons/pda_icons/emoji/sunglasses.png'
	)

/datum/asset/simple/fontawesome
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

/datum/asset/simple/tgui
	assets = list(
		"tgui.bundle.js" = file("tgui/public/tgui.bundle.js"),
		"tgui.bundle.css" = file("tgui/public/tgui.bundle.css"),
	)

/datum/asset/simple/tgfont
	assets = list(
		"tgfont.eot" = file("tgui/packages/tgfont/static/tgfont.eot"),
		"tgfont.woff2" = file("tgui/packages/tgfont/static/tgfont.woff2"),
		"tgfont.css" = file("tgui/packages/tgfont/static/tgfont.css"),
	)

/datum/asset/simple/other_fonts
	assets = list(
		"BLOODY.TTF"  = 'html/fonts/BLOODY.TTF',
		"CRAYON.TTF"  = 'html/fonts/CRAYON.TTF',
	)

// spritesheet implementation - coalesces various icons into a single .png file
// and uses CSS to select icons out of that file - saves on transferring some
// 1400-odd individual PNG files
#define SPR_SIZE 1
#define SPR_IDX 2
#define SPRSZ_COUNT 1
#define SPRSZ_ICON 2
#define SPRSZ_STRIPPED 3

/datum/asset/spritesheet
	var/name
	var/list/sizes = list()    // "32x32" -> list(10, icon/normal, icon/stripped)
	var/list/sprites = list()  // "foo_bar" -> list("32x32", 5)

/datum/asset/spritesheet/register()
	if (!name)
		return
	ensure_stripped()
	for(var/size_id in sizes)
		var/size = sizes[size_id]
		register_asset("[name]_[size_id].png", size[SPRSZ_STRIPPED])
	var/res_name = "spritesheet_[name].css"
	var/fname = "data/spritesheets/[res_name]"
	fdel(fname)
	text2file(generate_css(), fname)
	register_asset(res_name, fcopy_rsc(fname))
	fdel(fname)

/datum/asset/spritesheet/send(client/C)
	if (!name)
		return
	var/all = list("spritesheet_[name].css")
	for(var/size_id in sizes)
		all += "[name]_[size_id].png"
	send_asset_list(C, all)

/datum/asset/spritesheet/get_url_mappings()
	if (!name)
		return
	. = list("spritesheet_[name].css" = url_encode("spritesheet_[name].css"))
	for(var/size_id in sizes)
		.["[name]_[size_id].png"] = url_encode("[name]_[size_id].png")



/datum/asset/spritesheet/proc/ensure_stripped(sizes_to_strip = sizes)
	for(var/size_id in sizes_to_strip)
		var/size = sizes[size_id]
		if (size[SPRSZ_STRIPPED])
			continue

		// save flattened version
		var/fname = "data/spritesheets/[name]_[size_id].png"
		fcopy(size[SPRSZ_ICON], fname)
		var/error = rustg_dmi_strip_metadata(fname)
		if(length(error))
			stack_trace("Failed to strip [name]_[size_id].png: [error]")
		size[SPRSZ_STRIPPED] = icon(fname)
		fdel(fname)

/datum/asset/spritesheet/proc/generate_css()
	var/list/out = list()

	for (var/size_id in sizes)
		var/size = sizes[size_id]
		var/icon/tiny = size[SPRSZ_ICON]
		out += ".[name][size_id]{display:inline-block;width:[tiny.Width()]px;height:[tiny.Height()]px;background:url('[url_encode("[name]_[size_id].png")]') no-repeat;}"

	for (var/sprite_id in sprites)
		var/sprite = sprites[sprite_id]
		var/size_id = sprite[SPR_SIZE]
		var/idx = sprite[SPR_IDX]
		var/size = sizes[size_id]

		var/icon/tiny = size[SPRSZ_ICON]
		var/icon/big = size[SPRSZ_STRIPPED]
		var/per_line = big.Width() / tiny.Width()
		var/x = (idx % per_line) * tiny.Width()
		var/y = round(idx / per_line) * tiny.Height()

		out += ".[name][size_id].[sprite_id]{background-position:-[x]px -[y]px;}"

	return out.Join("\n")

/datum/asset/spritesheet/proc/Insert(sprite_name, icon/I, icon_state="", dir=SOUTH, frame=1, moving=FALSE)
	I = icon(I, icon_state=icon_state, dir=dir, frame=frame, moving=moving)
	if (!I || !length(icon_states(I)))  // that direction or state doesn't exist
		return
	//any sprite modifications we want to do (aka, coloring a greyscaled asset)
	I = ModifyInserted(I)
	var/size_id = "[I.Width()]x[I.Height()]"
	var/size = sizes[size_id]

	if (sprites[sprite_name])
		CRASH("duplicate sprite \"[sprite_name]\" in sheet [name] ([type])")

	if (size)
		var/position = size[SPRSZ_COUNT]++
		var/icon/sheet = size[SPRSZ_ICON]
		size[SPRSZ_STRIPPED] = null
		sheet.Insert(I, icon_state=sprite_name)
		sprites[sprite_name] = list(size_id, position)
	else
		sizes[size_id] = size = list(1, I, null)
		sprites[sprite_name] = list(size_id, 0)

/**
 * A simple proc handing the Icon for you to modify before it gets turned into an asset.
 *
 * Arguments:
 * * I: icon being turned into an asset
 */
/datum/asset/spritesheet/proc/ModifyInserted(icon/pre_asset)
	return pre_asset

/datum/asset/spritesheet/proc/InsertAll(prefix, icon/I, list/directions)
	if (length(prefix))
		prefix = "[prefix]-"

	if (!directions)
		directions = list(SOUTH)

	for (var/icon_state_name in icon_states(I))
		for (var/direction in directions)
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]-" : ""
			Insert("[prefix][prefix2][icon_state_name]", I, icon_state=icon_state_name, dir=direction)

/datum/asset/spritesheet/proc/css_tag()
	return {"<link rel="stylesheet" href="[css_filename()]" />"}

/datum/asset/spritesheet/proc/css_filename()
	return url_encode("spritesheet_[name].css")

/datum/asset/spritesheet/proc/icon_tag(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"<span class="[name][size_id] [sprite_name]"></span>"}

/datum/asset/spritesheet/proc/icon_class_name(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return {"[name][size_id] [sprite_name]"}

/**
 * Returns the size class (ex design32x32) for a given sprite's icon
 *
 * Arguments:
 * * sprite_name - The sprite to get the size of
 */
/datum/asset/spritesheet/proc/icon_size_id(sprite_name)
	var/sprite = sprites[sprite_name]
	if (!sprite)
		return null
	var/size_id = sprite[SPR_SIZE]
	return "[name][size_id]"

#undef SPR_SIZE
#undef SPR_IDX
#undef SPRSZ_COUNT
#undef SPRSZ_ICON
#undef SPRSZ_STRIPPED

/datum/asset/spritesheet/merch
	name = "merch"

/datum/asset/spritesheet/merch/register()
	for (var/category in centcomm_store.items)
		var/list/category_items = centcomm_store.items[category]
		for(var/datum/storeitem/k in category_items)
			var/atom/item = initial(k.typepath)
			if (!ispath(item, /atom))
				continue

			var/icon_file = initial(item.icon)
			var/icon_state = initial(item.icon_state)
			var/icon/I

			var/icon_states_list = icon_states(icon_file)
			if(icon_state in icon_states_list)
				I = icon(icon_file, icon_state, SOUTH)
				var/c = initial(item.color)
				if (!isnull(c) && c != "#FFFFFF")
					I.Blend(c, ICON_MULTIPLY)
			else
				var/icon_states_string
				for (var/an_icon_state in icon_states_list)
					if (!icon_states_string)
						icon_states_string = "[json_encode(an_icon_state)](\ref[an_icon_state])"
					else
						icon_states_string += ", [json_encode(an_icon_state)](\ref[an_icon_state])"
				stack_trace("[item] does not have a valid icon state, icon=[icon_file], icon_state=[json_encode(icon_state)](\ref[icon_state]), icon_states=[icon_states_string]")
				I = icon('icons/turf/floors.dmi', "", SOUTH)

			var/imgid = replacetext(replacetext("[item]", "/obj/item/", ""), "/", "-")

			Insert(imgid, I)
	return ..()

/datum/asset/spritesheet/bible
	name = "bible"

/datum/asset/spritesheet/bible/register()
	var/const/icon_file = 'icons/obj/storage/bibles.dmi'
	var/list/bible_icon_states = icon_states(icon_file)

	for(var/name in all_bible_styles)
		var/list/data = all_bible_styles[name]

		var/icon_state
		if(islist(data))
			icon_state = data["icon"]
		else
			icon_state = data

		var/icon/I
		if(icon_state in bible_icon_states)
			I = icon(icon_file, icon_state, SOUTH)
		else
			stack_trace("[icon_state] is not a valid icon state, icon=[icon_file], icon_states=[bible_icon_states]")
			I = icon('icons/turf/floors.dmi', "", SOUTH)

		Insert(icon_state, I)
	return ..()

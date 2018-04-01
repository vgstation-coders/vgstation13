/*
Asset cache quick users guide:

Make a datum at the bottom of this file with your assets for your thing.
The simple subsystem will most like be of use for most cases.
Then call get_asset_datum() with the type of the datum you created and store the return
Then call .send(client) on that stored return value.

You can set verify to TRUE if you want send() to sleep until the client has the assets.
*/


// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
// This is doubled for the first asset, then added per asset after
#define ASSET_CACHE_SEND_TIMEOUT 7

//When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8

//When passively preloading assets, how many to send at once? Too high creates noticable lag where as too low can flood the client's cache with "verify" files
#define ASSET_CACHE_PRELOAD_CONCURRENT 3

/client
	var/list/cache = list() // List of all assets sent to this client by the asset cache.
	var/list/completed_asset_jobs = list() // List of all completed jobs, awaiting acknowledgement.
	var/list/sending = list()
	var/last_asset_job = 0 // Last job done.

//This proc sends the asset to the client, but only if it needs it.
//This proc blocks(sleeps) unless verify is set to false
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

	if(client.cache.Find(asset_name) || client.sending.Find(asset_name))
		return 0

	client << browse_rsc(SSassets.cache[asset_name], asset_name)
	if(!verify)
		client.cache += asset_name
		return 1

	client.sending |= asset_name
	var/job = ++client.last_asset_job

	client << browse({"
	<script>
		window.location.href="?asset_cache_confirm_arrival=[job]"
	</script>
	"}, "window=asset_cache_browser")

	var/t = 0
	var/timeout_time = (ASSET_CACHE_SEND_TIMEOUT * client.sending.len) + ASSET_CACHE_SEND_TIMEOUT
	while(client && !client.completed_asset_jobs.Find(job) && t < timeout_time) // Reception is handled in Topic()
		stoplag(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= asset_name
		client.cache |= asset_name
		client.completed_asset_jobs -= job

	return 1

//This proc blocks(sleeps) unless verify is set to false
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
	if (unreceived.len >= ASSET_CACHE_TELL_CLIENT_AMOUNT)
		to_chat(client, "Sending Resources...")
	for(var/asset in unreceived)
		if (asset in SSassets.cache)
			client << browse_rsc(SSassets.cache[asset], asset)

	if(!verify) // Can't access the asset cache browser, rip.
		client.cache += unreceived
		return 1

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
		stoplag(1) // Lock up the caller until this is received.
		t++

	if(client)
		client.sending -= unreceived
		client.cache |= unreceived
		client.completed_asset_jobs -= job

	return 1

//This proc will download the files without clogging up the browse() queue, used for passively sending files on connection start.
//The proc calls procs that sleep for long times.
/proc/getFilesSlow(var/client/client, var/list/files, var/register_asset = TRUE)
	var/concurrent_tracker = 1
	for(var/file in files)
		if (!client)
			break
		if (register_asset)
			register_asset(file, files[file])
		if (concurrent_tracker >= ASSET_CACHE_PRELOAD_CONCURRENT)
			concurrent_tracker = 1
			send_asset(client, file)
		else
			concurrent_tracker++
			send_asset(client, file, verify=FALSE)

		stoplag(0) //queuing calls like this too quickly can cause issues in some client versions

//This proc "registers" an asset, it adds it to the cache for further use, you cannot touch it from this point on or you'll fuck things up.
//if it's an icon or something be careful, you'll have to copy it before further use.
/proc/register_asset(var/asset_name, var/asset)
	SSassets.cache[asset_name] = asset

//Generated names do not include file extention.
//Used mainly for code that deals with assets in a generic way
//The same asset will always lead to the same asset name
/proc/generate_asset_name(var/file)
	return "asset.[md5(fcopy_rsc(file))]"


//These datums are used to populate the asset cache, the proc "register()" does this.

//all of our asset datums, used for referring to these later
GLOBAL_LIST_EMPTY(asset_datums)

//get an assetdatum or make a new one
/proc/get_asset_datum(var/type)
	if (!(type in GLOB.asset_datums))
		return new type()
	return GLOB.asset_datums[type]

/datum/asset/New()
	GLOB.asset_datums[type] = src

/datum/asset/proc/register()
	return

/datum/asset/proc/send(client)
	return

//If you don't need anything complicated.
/datum/asset/simple
	var/assets = list()
	var/verify = FALSE

/datum/asset/simple/register()
	for(var/asset_name in assets)
		register_asset(asset_name, assets[asset_name])
/datum/asset/simple/send(client)
	send_asset_list(client,assets,verify)


//Generates assets based on iconstates of a single icon
/datum/asset/simple/icon_states
	var/icon
	var/list/directions = list(SOUTH)
	var/frame = 1
	var/movement_states = FALSE

	var/prefix = "default" //asset_name = "[prefix].[icon_state_name].png"
	var/generic_icon_names = FALSE //generate icon filenames using generate_asset_name() instead the above format

	verify = FALSE

/datum/asset/simple/icon_states/register(_icon = icon)
	for(var/icon_state_name in icon_states(_icon))
		for(var/direction in directions)
			var/asset = icon(_icon, icon_state_name, direction, frame, movement_states)
			if (!asset)
				continue
			asset = fcopy_rsc(asset) //dedupe
			var/prefix2 = (directions.len > 1) ? "[dir2text(direction)]." : ""
			var/asset_name = sanitize_filename("[prefix].[prefix2][icon_state_name].png")
			if (generic_icon_names)
				asset_name = "[generate_asset_name(asset)].png"

			register_asset(asset_name, asset)

/datum/asset/simple/icon_states/multiple_icons
	var/list/icons

/datum/asset/simple/icon_states/multiple_icons/register()
	for(var/i in icons)
		..(i)


//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/simple/tgui
	assets = list(
		"tgui.css"	= 'tgui/assets/tgui.css',
		"tgui.js"	= 'tgui/assets/tgui.js',
		"font-awesome.min.css" = 'tgui/assets/font-awesome.min.css',
		"fontawesome-webfont.eot" = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.woff2" = 'tgui/assets/fonts/fontawesome-webfont.woff2',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"fontawesome-webfont.ttf" = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.svg" = 'tgui/assets/fonts/fontawesome-webfont.svg'
	)

/datum/asset/simple/headers
	assets = list(
		"alarm_green.gif" 			= 'icons/program_icons/alarm_green.gif',
		"alarm_red.gif" 			= 'icons/program_icons/alarm_red.gif',
		"batt_5.gif" 				= 'icons/program_icons/batt_5.gif',
		"batt_20.gif" 				= 'icons/program_icons/batt_20.gif',
		"batt_40.gif" 				= 'icons/program_icons/batt_40.gif',
		"batt_60.gif" 				= 'icons/program_icons/batt_60.gif',
		"batt_80.gif" 				= 'icons/program_icons/batt_80.gif',
		"batt_100.gif" 				= 'icons/program_icons/batt_100.gif',
		"charging.gif" 				= 'icons/program_icons/charging.gif',
		"downloader_finished.gif" 	= 'icons/program_icons/downloader_finished.gif',
		"downloader_running.gif" 	= 'icons/program_icons/downloader_running.gif',
		"ntnrc_idle.gif"			= 'icons/program_icons/ntnrc_idle.gif',
		"ntnrc_new.gif"				= 'icons/program_icons/ntnrc_new.gif',
		"power_norm.gif"			= 'icons/program_icons/power_norm.gif',
		"power_warn.gif"			= 'icons/program_icons/power_warn.gif',
		"sig_high.gif" 				= 'icons/program_icons/sig_high.gif',
		"sig_low.gif" 				= 'icons/program_icons/sig_low.gif',
		"sig_lan.gif" 				= 'icons/program_icons/sig_lan.gif',
		"sig_none.gif" 				= 'icons/program_icons/sig_none.gif',
		"smmon_0.gif" 				= 'icons/program_icons/smmon_0.gif',
		"smmon_1.gif" 				= 'icons/program_icons/smmon_1.gif',
		"smmon_2.gif" 				= 'icons/program_icons/smmon_2.gif',
		"smmon_3.gif" 				= 'icons/program_icons/smmon_3.gif',
		"smmon_4.gif" 				= 'icons/program_icons/smmon_4.gif',
		"smmon_5.gif" 				= 'icons/program_icons/smmon_5.gif',
		"smmon_6.gif" 				= 'icons/program_icons/smmon_6.gif'
	)

/datum/asset/simple/pda
	assets = list(
		"pda_atmos.png"			= 'icons/pda_icons/pda_atmos.png',
		"pda_back.png"			= 'icons/pda_icons/pda_back.png',
		"pda_bell.png"			= 'icons/pda_icons/pda_bell.png',
		"pda_blank.png"			= 'icons/pda_icons/pda_blank.png',
		"pda_boom.png"			= 'icons/pda_icons/pda_boom.png',
		"pda_bucket.png"		= 'icons/pda_icons/pda_bucket.png',
		"pda_medbot.png"		= 'icons/pda_icons/pda_medbot.png',
		"pda_floorbot.png"		= 'icons/pda_icons/pda_floorbot.png',
		"pda_cleanbot.png"		= 'icons/pda_icons/pda_cleanbot.png',
		"pda_crate.png"			= 'icons/pda_icons/pda_crate.png',
		"pda_cuffs.png"			= 'icons/pda_icons/pda_cuffs.png',
		"pda_eject.png"			= 'icons/pda_icons/pda_eject.png',
		"pda_flashlight.png"	= 'icons/pda_icons/pda_flashlight.png',
		"pda_honk.png"			= 'icons/pda_icons/pda_honk.png',
		"pda_mail.png"			= 'icons/pda_icons/pda_mail.png',
		"pda_medical.png"		= 'icons/pda_icons/pda_medical.png',
		"pda_menu.png"			= 'icons/pda_icons/pda_menu.png',
		"pda_mule.png"			= 'icons/pda_icons/pda_mule.png',
		"pda_notes.png"			= 'icons/pda_icons/pda_notes.png',
		"pda_power.png"			= 'icons/pda_icons/pda_power.png',
		"pda_rdoor.png"			= 'icons/pda_icons/pda_rdoor.png',
		"pda_reagent.png"		= 'icons/pda_icons/pda_reagent.png',
		"pda_refresh.png"		= 'icons/pda_icons/pda_refresh.png',
		"pda_scanner.png"		= 'icons/pda_icons/pda_scanner.png',
		"pda_signaler.png"		= 'icons/pda_icons/pda_signaler.png',
		"pda_status.png"		= 'icons/pda_icons/pda_status.png',
		"pda_dronephone.png"	= 'icons/pda_icons/pda_dronephone.png'
	)

/datum/asset/simple/paper
	assets = list(
		"large_stamp-clown.png" = 'icons/stamp_icons/large_stamp-clown.png',
		"large_stamp-deny.png" = 'icons/stamp_icons/large_stamp-deny.png',
		"large_stamp-ok.png" = 'icons/stamp_icons/large_stamp-ok.png',
		"large_stamp-hop.png" = 'icons/stamp_icons/large_stamp-hop.png',
		"large_stamp-cmo.png" = 'icons/stamp_icons/large_stamp-cmo.png',
		"large_stamp-ce.png" = 'icons/stamp_icons/large_stamp-ce.png',
		"large_stamp-hos.png" = 'icons/stamp_icons/large_stamp-hos.png',
		"large_stamp-rd.png" = 'icons/stamp_icons/large_stamp-rd.png',
		"large_stamp-cap.png" = 'icons/stamp_icons/large_stamp-cap.png',
		"large_stamp-qm.png" = 'icons/stamp_icons/large_stamp-qm.png',
		"large_stamp-law.png" = 'icons/stamp_icons/large_stamp-law.png'
	)

/datum/asset/simple/IRV
	assets = list(
		"jquery-ui.custom-core-widgit-mouse-sortable-min.js" = 'html/IRV/jquery-ui.custom-core-widgit-mouse-sortable-min.js',
		"jquery-1.10.2.min.js" = 'html/IRV/jquery-1.10.2.min.js'
	)

/datum/asset/simple/changelog
	assets = list(
		"88x31.png" = 'html/88x31.png',
		"bug-minus.png" = 'html/bug-minus.png',
		"cross-circle.png" = 'html/cross-circle.png',
		"hard-hat-exclamation.png" = 'html/hard-hat-exclamation.png',
		"image-minus.png" = 'html/image-minus.png',
		"image-plus.png" = 'html/image-plus.png',
		"music-minus.png" = 'html/music-minus.png',
		"music-plus.png" = 'html/music-plus.png',
		"tick-circle.png" = 'html/tick-circle.png',
		"wrench-screwdriver.png" = 'html/wrench-screwdriver.png',
		"spell-check.png" = 'html/spell-check.png',
		"burn-exclamation.png" = 'html/burn-exclamation.png',
		"chevron.png" = 'html/chevron.png',
		"chevron-expand.png" = 'html/chevron-expand.png',
		"scales.png" = 'html/scales.png',
		"coding.png" = 'html/coding.png',
		"ban.png" = 'html/ban.png',
		"chrome-wrench.png" = 'html/chrome-wrench.png',
		"changelog.css" = 'html/changelog.css'
	)

/datum/asset/simple/goonchat
	verify = FALSE
	assets = list(
		"jquery.min.js"            = 'code/modules/goonchat/browserassets/js/jquery.min.js',
		"json2.min.js"             = 'code/modules/goonchat/browserassets/js/json2.min.js',
		"errorHandler.js"          = 'code/modules/goonchat/browserassets/js/errorHandler.js',
		"browserOutput.js"         = 'code/modules/goonchat/browserassets/js/browserOutput.js',
		"fontawesome-webfont.eot"  = 'tgui/assets/fonts/fontawesome-webfont.eot',
		"fontawesome-webfont.svg"  = 'tgui/assets/fonts/fontawesome-webfont.svg',
		"fontawesome-webfont.ttf"  = 'tgui/assets/fonts/fontawesome-webfont.ttf',
		"fontawesome-webfont.woff" = 'tgui/assets/fonts/fontawesome-webfont.woff',
		"font-awesome.css"	       = 'code/modules/goonchat/browserassets/css/font-awesome.css',
		"browserOutput.css"	       = 'code/modules/goonchat/browserassets/css/browserOutput.css',
	)

/datum/asset/simple/permissions
	assets = list(
		"padlock.png"	= 'html/padlock.png'
	)

//this exists purely to avoid meta by pre-loading all language icons.
/datum/asset/language/register()
	for(var/path in typesof(/datum/language))
		set waitfor = FALSE
		var/datum/language/L = new path ()
		L.get_icon()

/datum/asset/simple/icon_states/emojis
	icon = 'icons/emoji.dmi'
	generic_icon_names = TRUE

/datum/asset/simple/icon_states/multiple_icons/pipes
	icons = list('icons/obj/atmospherics/pipes/pipe_item.dmi', 'icons/obj/atmospherics/pipes/disposal.dmi', 'icons/obj/atmospherics/pipes/transit_tube.dmi')
	prefix = "pipe"

/datum/asset/simple/icon_states/multiple_icons/pipes/New()
	directions = GLOB.alldirs
	..()

/datum/asset/simple/icon_states/multiple_icons/pipes/register()
	..()
	var/meter = icon('icons/obj/atmospherics/pipes/simple.dmi', "meterX", SOUTH, frame, movement_states)
	if(meter)
		register_asset(sanitize_filename("[prefix].south.meterX.png"), fcopy_rsc(meter))

// Representative icons for each research design
/datum/asset/simple/research_designs/register()
	for (var/path in subtypesof(/datum/design))
		var/datum/design/D = path

		// construct the icon and slap it into the resource cache
		var/atom/item = initial(D.build_path)
		if (!ispath(item, /atom))
			// biogenerator outputs to beakers by default
			if (initial(D.build_type) & BIOGENERATOR)
				item = /obj/item/reagent_containers/glass/beaker/large
			else
				continue  // shouldn't happen, but just in case

		// circuit boards become their resulting machines or computers
		if (ispath(item, /obj/item/circuitboard))
			var/obj/item/circuitboard/C = item
			var/machine = initial(C.build_path)
			if (machine)
				item = machine
		var/icon_file = initial(item.icon)
		var/all_states = icon_states(icon_file)
		var/icon/I = icon(icon_file, initial(item.icon_state), SOUTH)

		// computers (and snowflakes) get their screen and keyboard sprites
		if (ispath(item, /obj/machinery/computer) || ispath(item, /obj/machinery/power/solar_control))
			var/obj/machinery/computer/C = item
			var/screen = initial(C.icon_screen)
			var/keyboard = initial(C.icon_keyboard)
			if (screen && (screen in all_states))
				I.Blend(icon(icon_file, screen, SOUTH), ICON_OVERLAY)
			if (keyboard && (keyboard in all_states))
				I.Blend(icon(icon_file, keyboard, SOUTH), ICON_OVERLAY)

		assets["design_[initial(D.id)].png"] = I
	return ..()

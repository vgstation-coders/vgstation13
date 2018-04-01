/datum/hud/proc/adminbus_hud()
	mymob.gui_icons.adminbus_bg = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_bg.icon = 'icons/adminbus/fullscreen.dmi'
	mymob.gui_icons.adminbus_bg.icon_state = "HUD"
	mymob.gui_icons.adminbus_bg.name = "HUD"
	mymob.gui_icons.adminbus_bg.layer = HUD_BASE_LAYER
	mymob.gui_icons.adminbus_bg.screen_loc = ui_adminbus_bg

	mymob.gui_icons.adminbus_delete = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_delete.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_delete.icon_state = "icon_delete"
	mymob.gui_icons.adminbus_delete.name = "Delete Bus"
	mymob.gui_icons.adminbus_delete.screen_loc = ui_adminbus_delete

	mymob.gui_icons.adminbus_delmobs = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_delmobs.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_delmobs.icon_state = "icon_delmobs"
	mymob.gui_icons.adminbus_delmobs.name = "Delete Mobs"
	mymob.gui_icons.adminbus_delmobs.screen_loc = ui_adminbus_delmobs

	mymob.gui_icons.adminbus_spclowns = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_spclowns.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_spclowns.icon_state = "icon_spclown"
	mymob.gui_icons.adminbus_spclowns.name = "Spawn Clowns"
	mymob.gui_icons.adminbus_spclowns.screen_loc = ui_adminbus_spclowns

	mymob.gui_icons.adminbus_spcarps = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_spcarps.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_spcarps.icon_state = "icon_spcarp"
	mymob.gui_icons.adminbus_spcarps.name = "Spawn Carps"
	mymob.gui_icons.adminbus_spcarps.screen_loc = ui_adminbus_spcarps

	mymob.gui_icons.adminbus_spbears = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_spbears.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_spbears.icon_state = "icon_spbear"
	mymob.gui_icons.adminbus_spbears.name = "Spawn Bears"
	mymob.gui_icons.adminbus_spbears.screen_loc = ui_adminbus_spbears

	mymob.gui_icons.adminbus_sptrees = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_sptrees.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_sptrees.icon_state = "icon_sptree"
	mymob.gui_icons.adminbus_sptrees.name = "Spawn Trees"
	mymob.gui_icons.adminbus_sptrees.screen_loc = ui_adminbus_sptrees

	mymob.gui_icons.adminbus_spspiders = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_spspiders.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_spspiders.icon_state = "icon_spspider"
	mymob.gui_icons.adminbus_spspiders.name = "Spawn Spiders"
	mymob.gui_icons.adminbus_spspiders.screen_loc = ui_adminbus_spspiders

	mymob.gui_icons.adminbus_spalien = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_spalien.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_spalien.icon_state = "icon_spalien"
	mymob.gui_icons.adminbus_spalien.name = "Spawn Large Alien Queen"
	mymob.gui_icons.adminbus_spalien.screen_loc = ui_adminbus_spalien

	mymob.gui_icons.adminbus_loadsids = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_loadsids.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_loadsids.icon_state = "icon_loadsids"
	mymob.gui_icons.adminbus_loadsids.name = "Spawn Loads of Captain Spare IDs"
	mymob.gui_icons.adminbus_loadsids.screen_loc = ui_adminbus_loadsids

	mymob.gui_icons.adminbus_loadsmoney = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_loadsmoney.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_loadsmoney.icon_state = "icon_loadsmone"
	mymob.gui_icons.adminbus_loadsmoney.name = "Spawn Loads of Money"
	mymob.gui_icons.adminbus_loadsmoney.screen_loc = ui_adminbus_loadsmone

	mymob.gui_icons.adminbus_massrepair = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_massrepair.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_massrepair.icon_state = "icon_massrepair"
	mymob.gui_icons.adminbus_massrepair.name = "Repair Surroundings"
	mymob.gui_icons.adminbus_massrepair.screen_loc = ui_adminbus_massrepair

	mymob.gui_icons.adminbus_massrejuv = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_massrejuv.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_massrejuv.icon_state = "icon_massrejuv"
	mymob.gui_icons.adminbus_massrejuv.name = "Mass Rejuvination"
	mymob.gui_icons.adminbus_massrejuv.screen_loc = ui_adminbus_massrejuv

	mymob.gui_icons.adminbus_hook = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_hook.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_hook.icon_state = "icon_hook"
	mymob.gui_icons.adminbus_hook.name = "Singularity Hook"
	mymob.gui_icons.adminbus_hook.screen_loc = ui_adminbus_hook

	mymob.gui_icons.adminbus_juke = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_juke.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_juke.icon_state = "icon_jukebox"
	mymob.gui_icons.adminbus_juke.name = "Adminbus-mounted Jukebox"
	mymob.gui_icons.adminbus_juke.screen_loc = ui_adminbus_juke

	mymob.gui_icons.adminbus_tele = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_tele.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_tele.icon_state = "icon_teleport"
	mymob.gui_icons.adminbus_tele.name = "Teleportation"
	mymob.gui_icons.adminbus_tele.screen_loc = ui_adminbus_tele

	mymob.gui_icons.adminbus_bumpers_1 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_bumpers_1.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_bumpers_1.icon_state = "icon_bumpers_1-on"
	mymob.gui_icons.adminbus_bumpers_1.name = "Capture Mobs"
	mymob.gui_icons.adminbus_bumpers_1.screen_loc = ui_adminbus_bumpers_1

	mymob.gui_icons.adminbus_bumpers_2 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_bumpers_2.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_bumpers_2.icon_state = "icon_bumpers_2-off"
	mymob.gui_icons.adminbus_bumpers_2.name = "Hit Mobs"
	mymob.gui_icons.adminbus_bumpers_2.screen_loc = ui_adminbus_bumpers_2

	mymob.gui_icons.adminbus_bumpers_3 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_bumpers_3.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_bumpers_3.icon_state = "icon_bumpers_3-off"
	mymob.gui_icons.adminbus_bumpers_3.name = "Gib Mobs"
	mymob.gui_icons.adminbus_bumpers_3.screen_loc = ui_adminbus_bumpers_3

	mymob.gui_icons.adminbus_door_0 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_door_0.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_door_0.icon_state = "icon_door_0-on"
	mymob.gui_icons.adminbus_door_0.name = "Close Door"
	mymob.gui_icons.adminbus_door_0.screen_loc = ui_adminbus_door_0

	mymob.gui_icons.adminbus_door_1 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_door_1.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_door_1.icon_state = "icon_door_1-off"
	mymob.gui_icons.adminbus_door_1.name = "Open Door"
	mymob.gui_icons.adminbus_door_1.screen_loc = ui_adminbus_door_1

	mymob.gui_icons.adminbus_roadlights_0 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_roadlights_0.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_roadlights_0.icon_state = "icon_lights_0-on"
	mymob.gui_icons.adminbus_roadlights_0.name = "Turn Off Headlights"
	mymob.gui_icons.adminbus_roadlights_0.screen_loc = ui_adminbus_roadlights_0

	mymob.gui_icons.adminbus_roadlights_1 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_roadlights_1.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_roadlights_1.icon_state = "icon_lights_1-off"
	mymob.gui_icons.adminbus_roadlights_1.name = "Dipped Headlights"
	mymob.gui_icons.adminbus_roadlights_1.screen_loc = ui_adminbus_roadlights_1

	mymob.gui_icons.adminbus_roadlights_2 = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_roadlights_2.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_roadlights_2.icon_state = "icon_lights_2-off"
	mymob.gui_icons.adminbus_roadlights_2.name = "Main Headlights"
	mymob.gui_icons.adminbus_roadlights_2.screen_loc = ui_adminbus_roadlights_2

	mymob.gui_icons.adminbus_free = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_free.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_free.icon_state = "icon_free"
	mymob.gui_icons.adminbus_free.name = "Release Passengers"
	mymob.gui_icons.adminbus_free.screen_loc = ui_adminbus_free

	mymob.gui_icons.adminbus_home = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_home.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_home.icon_state = "icon_home"
	mymob.gui_icons.adminbus_home.name = "Send Passengers Back Home"
	mymob.gui_icons.adminbus_home.screen_loc = ui_adminbus_home

	mymob.gui_icons.adminbus_antag = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_antag.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_antag.icon_state = "icon_antag"
	mymob.gui_icons.adminbus_antag.name = "Antag Madness!"
	mymob.gui_icons.adminbus_antag.screen_loc = ui_adminbus_antag

	mymob.gui_icons.adminbus_dellasers = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_dellasers.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_dellasers.icon_state = "icon_delgiven"
	mymob.gui_icons.adminbus_dellasers.name = "Delete the given Infinite Laser Guns"
	mymob.gui_icons.adminbus_dellasers.screen_loc = ui_adminbus_dellasers

	mymob.gui_icons.adminbus_givelasers = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_givelasers.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_givelasers.icon_state = "icon_givelasers"
	mymob.gui_icons.adminbus_givelasers.name = "Give Infinite Laser Guns to the Passengers"
	mymob.gui_icons.adminbus_givelasers.screen_loc = ui_adminbus_givelasers

	mymob.gui_icons.adminbus_delbombs = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_delbombs.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_delbombs.icon_state = "icon_delgiven"
	mymob.gui_icons.adminbus_delbombs.name = "Delete the given Fuse-Bombs"
	mymob.gui_icons.adminbus_delbombs.screen_loc = ui_adminbus_delbombs

	mymob.gui_icons.adminbus_givebombs = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_givebombs.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_givebombs.icon_state = "icon_givebombs"
	mymob.gui_icons.adminbus_givebombs.name = "Give Fuse-Bombs to the Passengers"
	mymob.gui_icons.adminbus_givebombs.screen_loc = ui_adminbus_givebombs

	mymob.gui_icons.adminbus_tdred = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_tdred.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_tdred.icon_state = "icon_tdred"
	mymob.gui_icons.adminbus_tdred.name = "Send Passengers to the Thunderdome's Red Team"
	mymob.gui_icons.adminbus_tdred.screen_loc = ui_adminbus_tdred

	mymob.gui_icons.adminbus_tdarena = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_tdarena.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_tdarena.icon_state = "icon_tdarena"
	mymob.gui_icons.adminbus_tdarena.name = "Split the Passengers between the two Thunderdome Teams"
	mymob.gui_icons.adminbus_tdarena.screen_loc = ui_adminbus_tdarena

	mymob.gui_icons.adminbus_tdgreen = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_tdgreen.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_tdgreen.icon_state = "icon_tdgreen"
	mymob.gui_icons.adminbus_tdgreen.name = "Send Passengers to the Thunderdome's Green Team"
	mymob.gui_icons.adminbus_tdgreen.screen_loc = ui_adminbus_tdgreen

	mymob.gui_icons.adminbus_tdobs = getFromPool(/obj/abstract/screen/adminbus)
	mymob.gui_icons.adminbus_tdobs.icon = 'icons/adminbus/32x32.dmi'
	mymob.gui_icons.adminbus_tdobs.icon_state = "icon_tdobs"
	mymob.gui_icons.adminbus_tdobs.name = "Send Passengers to the Thunderdome's Observers' Lodge"
	mymob.gui_icons.adminbus_tdobs.screen_loc = ui_adminbus_tdobs

	mymob.client.screen += list(
		mymob.gui_icons.adminbus_bg,
		mymob.gui_icons.adminbus_delete,
		mymob.gui_icons.adminbus_delmobs,
		mymob.gui_icons.adminbus_spclowns,
		mymob.gui_icons.adminbus_spcarps,
		mymob.gui_icons.adminbus_spbears,
		mymob.gui_icons.adminbus_sptrees,
		mymob.gui_icons.adminbus_spspiders,
		mymob.gui_icons.adminbus_spalien,
		mymob.gui_icons.adminbus_loadsids,
		mymob.gui_icons.adminbus_loadsmoney,
		mymob.gui_icons.adminbus_massrepair,
		mymob.gui_icons.adminbus_massrejuv,
		mymob.gui_icons.adminbus_hook,
		mymob.gui_icons.adminbus_juke,
		mymob.gui_icons.adminbus_tele,
		mymob.gui_icons.adminbus_bumpers_1,
		mymob.gui_icons.adminbus_bumpers_2,
		mymob.gui_icons.adminbus_bumpers_3,
		mymob.gui_icons.adminbus_door_0,
		mymob.gui_icons.adminbus_door_1,
		mymob.gui_icons.adminbus_roadlights_0,
		mymob.gui_icons.adminbus_roadlights_1,
		mymob.gui_icons.adminbus_roadlights_2,
		mymob.gui_icons.adminbus_free,
		mymob.gui_icons.adminbus_home,
		mymob.gui_icons.adminbus_antag,
		mymob.gui_icons.adminbus_dellasers,
		mymob.gui_icons.adminbus_givelasers,
		mymob.gui_icons.adminbus_delbombs,
		mymob.gui_icons.adminbus_givebombs,
		mymob.gui_icons.adminbus_tdred,
		mymob.gui_icons.adminbus_tdarena,
		mymob.gui_icons.adminbus_tdgreen,
		mymob.gui_icons.adminbus_tdobs,
		)

	for(var/i=1;i<=16;i++)
		var/obj/abstract/screen/adminbus/S = getFromPool(/obj/abstract/screen/adminbus)
		S.icon = 'icons/adminbus/32x32.dmi'
		S.icon_state = ""
		S.screen_loc = "[12-round(i/2)]:[WORLD_ICON_SIZE/2*((i-1)%2)],14:[WORLD_ICON_SIZE/2]"
		mymob.gui_icons.rearviews[i] = S

	for(var/i=1;i<=16;i++)
		mymob.client.screen += mymob.gui_icons.rearviews[i]


/datum/hud/proc/remove_adminbus_hud()
	for(var/i=1;i<=16;i++)
		mymob.client.screen -= mymob.gui_icons.rearviews[i]

	mymob.client.screen -= list(
		mymob.gui_icons.adminbus_bg,
		mymob.gui_icons.adminbus_delete,
		mymob.gui_icons.adminbus_delmobs,
		mymob.gui_icons.adminbus_spclowns,
		mymob.gui_icons.adminbus_spcarps,
		mymob.gui_icons.adminbus_spbears,
		mymob.gui_icons.adminbus_sptrees,
		mymob.gui_icons.adminbus_spspiders,
		mymob.gui_icons.adminbus_spalien,
		mymob.gui_icons.adminbus_loadsids,
		mymob.gui_icons.adminbus_loadsmoney,
		mymob.gui_icons.adminbus_massrepair,
		mymob.gui_icons.adminbus_massrejuv,
		mymob.gui_icons.adminbus_hook,
		mymob.gui_icons.adminbus_juke,
		mymob.gui_icons.adminbus_tele,
		mymob.gui_icons.adminbus_bumpers_1,
		mymob.gui_icons.adminbus_bumpers_2,
		mymob.gui_icons.adminbus_bumpers_3,
		mymob.gui_icons.adminbus_door_0,
		mymob.gui_icons.adminbus_door_1,
		mymob.gui_icons.adminbus_roadlights_0,
		mymob.gui_icons.adminbus_roadlights_1,
		mymob.gui_icons.adminbus_roadlights_2,
		mymob.gui_icons.adminbus_free,
		mymob.gui_icons.adminbus_home,
		mymob.gui_icons.adminbus_antag,
		mymob.gui_icons.adminbus_dellasers,
		mymob.gui_icons.adminbus_givelasers,
		mymob.gui_icons.adminbus_delbombs,
		mymob.gui_icons.adminbus_givebombs,
		mymob.gui_icons.adminbus_tdred,
		mymob.gui_icons.adminbus_tdarena,
		mymob.gui_icons.adminbus_tdgreen,
		mymob.gui_icons.adminbus_tdobs,
		)

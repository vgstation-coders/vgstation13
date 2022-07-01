
/datum/mind_ui/adminbus
	uniqueID = "Adminbus"
	sub_uis_to_spawn = list(
		/datum/mind_ui/adminbus_top_panel,
		/datum/mind_ui/adminbus_left_panel,
		/datum/mind_ui/adminbus_bottom_panel,
		)

/datum/mind_ui/adminbus/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		return TRUE
	return FALSE

////////////////////////////////////////////////////////////////////
//																  //
//							 TOP PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/adminbus_top_panel
	uniqueID = "Adminbus Top Panel"
	y = "TOP"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/adminbus_top_panel,
		/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_split,
		/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_red,
		/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_green,
		/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_obs,
		/obj/abstract/mind_ui_element/hoverable/adminbus_give_bombs,
		/obj/abstract/mind_ui_element/hoverable/adminbus_delete_bombs,
		/obj/abstract/mind_ui_element/hoverable/adminbus_give_guns,
		/obj/abstract/mind_ui_element/hoverable/adminbus_delete_guns,
		/obj/abstract/mind_ui_element/adminbus_release,
		/obj/abstract/mind_ui_element/adminbus_send_home,
		/obj/abstract/mind_ui_element/adminbus_antag_madness,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_top_panel
	icon = 'icons/ui/adminbus/top_panel/background.dmi'
	icon_state = "panel"
	layer = MIND_UI_BACK
	offset_x = -221
	offset_y = 0

/obj/abstract/mind_ui_element/adminbus_top_panel/UpdateIcon()
	overlays.len = 0
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		for(var/i = 1 to ADMINBUS_MAX_CAPACITY)
			var/image/I = image('icons/ui/32x32.dmi',src,"blank")
			I.pixel_x = 365 - (16 * i)
			I.pixel_y = 38
			I.dir = SOUTH
			if(i <= A.passengers.len)
				I.overlays += getFlatIcon(A.passengers[i],SOUTH,0)
			overlays += I

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_split
	name = "Split the Passengers between the two Thunderdome Teams"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_tdarena"
	layer = MIND_UI_BUTTON
	offset_x = -188
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_split/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Sendto_Thunderdome_Arena(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_red
	name = "Send Passengers to the Thunderdome's Red Team"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_tdred"
	layer = MIND_UI_BUTTON
	offset_x = -206
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_red/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Sendto_Thunderdome_Arena_Red(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_green
	name = "Send Passengers to the Thunderdome's Green Team"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_tdgreen"
	layer = MIND_UI_BUTTON
	offset_x = -154
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_green/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Sendto_Thunderdome_Arena_Green(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_obs
	name = "Send Passengers to the Thunderdome's Observers' Lodge"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_tdobs"
	layer = MIND_UI_BUTTON
	offset_x = -188
	offset_y = -4

/obj/abstract/mind_ui_element/hoverable/adminbus_thunderdome_obs/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Sendto_Thunderdome_Obs(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_give_bombs
	name = "Give Fuse-Bombs to the Passengers"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_givebombs"
	layer = MIND_UI_BUTTON
	offset_x = 66
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_give_bombs/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.give_bombs(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_delete_bombs
	name = "Delete the given Fuse-Bombs"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_delgiven"
	layer = MIND_UI_BUTTON
	offset_x = 50
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_delete_bombs/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.delete_bombs(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_give_guns
	name = "Give Infinite Laser Guns to the Passengers"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_givelasers"
	layer = MIND_UI_BUTTON
	offset_x = -35
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_give_guns/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.give_lasers(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_delete_guns
	name = "Delete the given Infinite Laser Guns"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_delgiven"
	layer = MIND_UI_BUTTON
	offset_x = -51
	offset_y = -38

/obj/abstract/mind_ui_element/hoverable/adminbus_delete_guns/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.delete_lasers(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_release
	name = "Release Passengers"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_free"
	layer = MIND_UI_BUTTON
	offset_x = 169
	offset_y = -12

/obj/abstract/mind_ui_element/adminbus_release/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.release_passengers(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_send_home
	name = "Send Passengers Back Home"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_home"
	layer = MIND_UI_BUTTON
	offset_x = 198
	offset_y = -12

/obj/abstract/mind_ui_element/adminbus_send_home/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Send_Home(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_antag_madness
	name = "Antag Madness!"
	icon = 'icons/ui/adminbus/top_panel/buttons.dmi'
	icon_state = "icon_antag"
	layer = MIND_UI_BUTTON
	offset_x = 227
	offset_y = -12

/obj/abstract/mind_ui_element/adminbus_antag_madness/Click()
	flick("[base_icon_state]-push",src)

	alert(usr, "This button still hasn't been updated to use Role Datums. Sorry.")


////////////////////////////////////////////////////////////////////
//																  //
//							 LEFT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/adminbus_left_panel
	uniqueID = "Adminbus Left Panel"
	x = "LEFT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/adminbus_left_panel,
		/obj/abstract/mind_ui_element/hoverable/adminbus_delete_mobs,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_clowns,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_carps,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_bears,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_trees,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_spiders,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_alien,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_left_panel
	icon = 'icons/ui/adminbus/left_panel/background.dmi'
	icon_state = "panel"
	layer = MIND_UI_BACK
	offset_x = 0
	offset_y = -82

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_delete_mobs
	name = "Delete all mobs spawned by the Adminbus"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_delmobs"
	layer = MIND_UI_BUTTON
	offset_x = 6
	offset_y = -82

/obj/abstract/mind_ui_element/hoverable/adminbus_delete_mobs/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.remove_mobs(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_clowns
	name = "Spawn 5 Clowns"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_spclown"
	layer = MIND_UI_BUTTON
	offset_x = 8
	offset_y = -50

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_clowns/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.spawn_mob(M,1,5)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_carps
	name = "Spawn 5 Carps"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_spcarp"
	layer = MIND_UI_BUTTON
	offset_x = 8
	offset_y = -22

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_carps/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.spawn_mob(M,2,5)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_bears
	name = "Spawn 5 Bears"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_spbear"
	layer = MIND_UI_BUTTON
	offset_x = 8
	offset_y = 6

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_bears/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.spawn_mob(M,3,5)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_trees
	name = "Spawn 5 Trees"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_sptree"
	layer = MIND_UI_BUTTON
	offset_x = 8
	offset_y = 34

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_trees/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.spawn_mob(M,4,5)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_spiders
	name = "Spawn 5 Giant Spiders"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_spspider"
	layer = MIND_UI_BUTTON
	offset_x = 8
	offset_y = 62

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_spiders/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.spawn_mob(M,5,5)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_alien
	name = "Spawn a Large Alien Queen"
	icon = 'icons/ui/adminbus/left_panel/buttons.dmi'
	icon_state = "icon_spalien"
	layer = MIND_UI_BUTTON
	offset_x = 7
	offset_y = 90

/obj/abstract/mind_ui_element/hoverable/adminbus_spawn_alien/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.spawn_mob(M,6,1)

////////////////////////////////////////////////////////////////////
//																  //
//						   BOTTOM PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/adminbus_bottom_panel
	uniqueID = "Adminbus Bottom Panel"
	y = "BOTTOM"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/adminbus_bottom_panel,
		/obj/abstract/mind_ui_element/hoverable/adminbus_money,
		/obj/abstract/mind_ui_element/hoverable/adminbus_spares,
		/obj/abstract/mind_ui_element/hoverable/adminbus_healing,
		/obj/abstract/mind_ui_element/hoverable/adminbus_repair,
		/obj/abstract/mind_ui_element/hoverable/adminbus_hook,
		/obj/abstract/mind_ui_element/hoverable/adminbus_jukebox,
		/obj/abstract/mind_ui_element/hoverable/adminbus_teleport,
		/obj/abstract/mind_ui_element/adminbus_bumpers_low,
		/obj/abstract/mind_ui_element/adminbus_bumpers_mid,
		/obj/abstract/mind_ui_element/adminbus_bumpers_high,
		/obj/abstract/mind_ui_element/adminbus_door_closed,
		/obj/abstract/mind_ui_element/adminbus_door_open,
		/obj/abstract/mind_ui_element/adminbus_roadlights_low,
		/obj/abstract/mind_ui_element/adminbus_roadlights_mid,
		/obj/abstract/mind_ui_element/adminbus_roadlights_high,
		/obj/abstract/mind_ui_element/hoverable/adminbus_delete,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_bottom_panel
	icon = 'icons/ui/adminbus/bottom_panel/background.dmi'
	icon_state = "panel"
	layer = MIND_UI_BACK
	offset_x = -96
	offset_y = 0

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_money
	name = "Spawn Loads of Money"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_loadsmone"
	layer = MIND_UI_BUTTON
	offset_x = -96
	offset_y = 69

/obj/abstract/mind_ui_element/hoverable/adminbus_money/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.loadsa_goodies(M,2)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_spares
	name = "Spawn Loads of Captain Spare IDs"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_loadsids"
	layer = MIND_UI_BUTTON
	offset_x = -96
	offset_y = 41

/obj/abstract/mind_ui_element/hoverable/adminbus_spares/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.loadsa_goodies(M,1)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_healing
	name = "Mass Rejuvination"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_massrejuv"
	layer = MIND_UI_BUTTON
	offset_x = -61
	offset_y = 69

/obj/abstract/mind_ui_element/hoverable/adminbus_healing/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.mass_rejuvenate(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_repair
	name = "Repair Surroundings"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_massrepair"
	layer = MIND_UI_BUTTON
	offset_x = -61
	offset_y = 41

/obj/abstract/mind_ui_element/hoverable/adminbus_repair/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Mass_Repair(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_hook
	name = "Singularity Hook"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_hook"
	layer = MIND_UI_BUTTON
	offset_x = 64
	offset_y = 71

/obj/abstract/mind_ui_element/hoverable/adminbus_hook/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if(!A.hook && !A.singulo)
			icon_state = "icon_hook-push"
			base_icon_state = "icon_hook-push"
		else if (A.singulo)
			icon_state = "icon_singulo"
			base_icon_state = "icon_singulo"
		else
			icon_state = "icon_hook"
			base_icon_state = "icon_hook"

/obj/abstract/mind_ui_element/hoverable/adminbus_hook/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.throw_hookshot(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_jukebox
	name = "Adminbus-mounted Jukebox"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_jukebox"
	layer = MIND_UI_BUTTON
	offset_x = 107
	offset_y = 71

/obj/abstract/mind_ui_element/hoverable/adminbus_jukebox/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Mounted_Jukebox(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_teleport
	name = "Teleportation"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_teleport"
	layer = MIND_UI_BUTTON
	offset_x = 150
	offset_y = 71

/obj/abstract/mind_ui_element/hoverable/adminbus_teleport/Click()
	flick("[base_icon_state]-push",src)

	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Teleportation(M)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_bumpers_low
	name = "Capture Mobs"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_bumpers_1-on"
	layer = MIND_UI_BUTTON
	offset_x = 53
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_bumpers_low/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.bumpers == 1)
			icon_state = "icon_bumpers_1-on"
			base_icon_state = "icon_bumpers_1-on"
		else
			icon_state = "icon_bumpers_1-off"
			base_icon_state = "icon_bumpers_1-off"

/obj/abstract/mind_ui_element/adminbus_bumpers_low/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_bumpers(M,1)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_bumpers_mid
	name = "Hit Mobs"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_bumpers_2-off"
	layer = MIND_UI_BUTTON
	offset_x = 69
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_bumpers_mid/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.bumpers == 2)
			icon_state = "icon_bumpers_2-on"
			base_icon_state = "icon_bumpers_2-on"
		else
			icon_state = "icon_bumpers_2-off"
			base_icon_state = "icon_bumpers_2-off"

/obj/abstract/mind_ui_element/adminbus_bumpers_mid/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_bumpers(M,2)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_bumpers_high
	name = "Gib Mobs"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_bumpers_3-off"
	layer = MIND_UI_BUTTON
	offset_x = 85
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_bumpers_high/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.bumpers == 3)
			icon_state = "icon_bumpers_3-on"
			base_icon_state = "icon_bumpers_3-on"
		else
			icon_state = "icon_bumpers_3-off"
			base_icon_state = "icon_bumpers_3-off"

/obj/abstract/mind_ui_element/adminbus_bumpers_high/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_bumpers(M,3)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_door_closed
	name = "Close Door"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_door_0-on"
	layer = MIND_UI_BUTTON
	offset_x = 107
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_door_closed/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.door_mode == 0)
			icon_state = "icon_door_0-on"
			base_icon_state = "icon_door_0-on"
		else
			icon_state = "icon_door_0-off"
			base_icon_state = "icon_door_0-off"

/obj/abstract/mind_ui_element/adminbus_door_closed/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_door(M,0)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_door_open
	name = "Open Door"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_door_1-off"
	layer = MIND_UI_BUTTON
	offset_x = 123
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_door_open/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.door_mode == 1)
			icon_state = "icon_door_1-on"
			base_icon_state = "icon_door_1-on"
		else
			icon_state = "icon_door_1-off"
			base_icon_state = "icon_door_1-off"

/obj/abstract/mind_ui_element/adminbus_door_open/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_door(M,1)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_roadlights_low
	name = "Turn Off Headlights"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_lights_0-on"
	layer = MIND_UI_BUTTON
	offset_x = 145
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_roadlights_low/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.roadlights == 0)
			icon_state = "icon_lights_0-on"
			base_icon_state = "icon_lights_0-on"
		else
			icon_state = "icon_lights_0-off"
			base_icon_state = "icon_lights_0-off"

/obj/abstract/mind_ui_element/adminbus_roadlights_low/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_lights(M,0)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_roadlights_mid
	name = "Dipped Headlights"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_lights_1-off"
	layer = MIND_UI_BUTTON
	offset_x = 161
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_roadlights_mid/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.roadlights == 1)
			icon_state = "icon_lights_1-on"
			base_icon_state = "icon_lights_1-on"
		else
			icon_state = "icon_lights_1-off"
			base_icon_state = "icon_lights_1-off"

/obj/abstract/mind_ui_element/adminbus_roadlights_mid/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_lights(M,1)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/adminbus_roadlights_high
	name = "Main Headlights"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_lights_2-off"
	layer = MIND_UI_BUTTON
	offset_x = 177
	offset_y = 46

/obj/abstract/mind_ui_element/adminbus_roadlights_high/UpdateIcon()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		if (A.roadlights == 2)
			icon_state = "icon_lights_2-on"
			base_icon_state = "icon_lights_2-on"
		else
			icon_state = "icon_lights_2-off"
			base_icon_state = "icon_lights_2-off"

/obj/abstract/mind_ui_element/adminbus_roadlights_high/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.toggle_lights(M,2)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/adminbus_delete
	name = "Delete Bus"
	icon = 'icons/ui/adminbus/bottom_panel/buttons.dmi'
	icon_state = "icon_delete"
	layer = MIND_UI_BUTTON
	offset_x = 127
	offset_y = 6

/obj/abstract/mind_ui_element/hoverable/adminbus_delete/Click()
	var/mob/M = GetUser()
	if (M && istype(M.locked_to, /obj/structure/bed/chair/vehicle/adminbus))
		var/obj/structure/bed/chair/vehicle/adminbus/A = M.locked_to
		A.Adminbus_Deletion(M)

//------------------------------------------------------------

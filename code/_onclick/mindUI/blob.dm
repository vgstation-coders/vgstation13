
// Blob powers' buttons become grayscale when there's not enough points available

/obj/abstract/mind_ui_element/hoverable/blob_power
	icon = 'icons/ui/blob/32x32.dmi'
	layer = MIND_UI_BUTTON
	var/required_points = 0
	var/initial_name

/obj/abstract/mind_ui_element/hoverable/blob_power/New()
	..()
	initial_name = name

/obj/abstract/mind_ui_element/hoverable/blob_power/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	if (M.blob_points >= required_points)
		color = null
	else
		color = grayscale
	name = "[initial_name] (cost = [required_points] points)"

/obj/abstract/mind_ui_element/hoverable/blob_power/StartHovering()
	if (color == null)
		..()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini

//------------------------------------------------------------

/datum/mind_ui/blob
	uniqueID = "Blob"
	sub_uis_to_spawn = list(
		/datum/mind_ui/blob_top_panel,
		/datum/mind_ui/blob_left_panel,
		/datum/mind_ui/blob_right_panel,
		)

/datum/mind_ui/blob/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(isovermind(M))
		return TRUE
	return FALSE

////////////////////////////////////////////////////////////////////
//																  //
//							 TOP PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/blob_top_panel
	uniqueID = "Blob Top Panel"
	x = "LEFT"
	y = "TOP"
	display_with_parent = TRUE

/datum/mind_ui/blob_top_panel/SpawnElements()
	for (var/i = 1 to 24)
		elements += new /obj/abstract/mind_ui_element/hoverable/blob_thumbnail_shortcut(null, src)

/datum/mind_ui/blob_top_panel/Display() // Callin mob.DisplayUI("Blob Top Panel") or just mob.DisplayUI("Blob") will update the shortcut buttons
	..()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	var/i = 1
	for (var/obj/abstract/mind_ui_element/hoverable/blob_thumbnail_shortcut/smallblob in elements)
		smallblob.invisibility = 101
		var/obj/effect/blob/B = null
		if(i<=M.special_blobs.len)
			B = M.special_blobs[i]
			switch(B.type)
				if(/obj/effect/blob/core)
					smallblob.icon_state = "smallcore"
				if(/obj/effect/blob/resource)
					smallblob.icon_state = "smallresource"
				if(/obj/effect/blob/factory)
					smallblob.icon_state = "smallfactory"
				if(/obj/effect/blob/node)
					smallblob.icon_state = "smallnode"
			smallblob.name = "Jump to [B.name]"
			smallblob.base_icon_state = smallblob.icon_state
			smallblob.offset_x = ((i - 1) * 20) + 4
			smallblob.UpdateUIScreenLoc()
			smallblob.blob_weakref = makeweakref(B)
			smallblob.Appear()
		i++


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_thumbnail_shortcut
	name = "Jump to Blob"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "smallcore"
	layer = MIND_UI_BUTTON
	offset_x = 4

	var/datum/weakref/blob_weakref

/obj/abstract/mind_ui_element/hoverable/blob_thumbnail_shortcut/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M) || !blob_weakref)
		return
	var/obj/effect/blob/B = blob_weakref.get()
	if (B)
		M.forceMove(B.loc)


////////////////////////////////////////////////////////////////////
//																  //
//						   LEFT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/blob_left_panel
	uniqueID = "Blob Left Panel"
	x = "LEFT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/blob_point_gauge,
		/obj/abstract/mind_ui_element/blob_points_count,
		/obj/abstract/mind_ui_element/blob_mini/normal,
		/obj/abstract/mind_ui_element/blob_mini/strong,
		/obj/abstract/mind_ui_element/blob_mini/res,
		/obj/abstract/mind_ui_element/blob_mini/fact,
		/obj/abstract/mind_ui_element/blob_mini/node,
		/obj/abstract/mind_ui_element/blob_mini/core,
		/obj/abstract/mind_ui_element/blob_mini/rally,
		/obj/abstract/mind_ui_element/blob_mini/taunt,
		/obj/abstract/mind_ui_element/hoverable/blob_toggle_restraint,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_strong,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_resource,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_factory,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_node,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_core,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_point_gauge
	name = "Points"
	icon = 'icons/ui/blob/21x242.dmi'
	icon_state = "backgroundLEFT"
	layer = MIND_UI_BACK
	offset_y = -117
	var/list/grad_images_small = list() // we keep those alive so we don't have to create new images every times
	var/list/grad_images_large = list()

/obj/abstract/mind_ui_element/blob_point_gauge/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	overlays.len = 0

	// gauge

	var/image/gauge = image('icons/ui/blob/18x200.dmi', src, "points")
	var/matrix/gauge_matrix = matrix()
	gauge_matrix.Scale(1,M.blob_points/M.max_blob_points)
	gauge.transform = gauge_matrix
	gauge.layer = MIND_UI_BUTTON
	gauge.pixel_y = round(-79 + 100 * (M.blob_points/M.max_blob_points))
	overlays += gauge

	// graduations

	var/list/small_grads = list()
	small_grads |= grad_images_small
	var/list/large_grads = list()
	large_grads |= grad_images_large

	for (var/i = 0, i < M.max_blob_points, i += 5) // a small 1px stripe every 5 points
		if (small_grads.len)
			var/image/I = pick(small_grads)
			I.pixel_y = round(21 + (i * 200 / M.max_blob_points))
			overlays += I
			small_grads -= I
		else
			var/image/grad = image('icons/ui/blob/32x32.dmi', src, "grad_small")
			grad.pixel_y = round(21 + (i * 200 / M.max_blob_points))
			grad.layer = MIND_UI_BUTTON + 0.5
			overlays += grad
			grad_images_small += grad

	for (var/i = 0, i < M.max_blob_points, i += BLOBATTCOST) // a small 1px stripe every 15 points (or however much it costs to expand)
		if (large_grads.len)
			var/image/I = pick(large_grads)
			I.pixel_y = round(21 + (i * 200 / M.max_blob_points))
			overlays += I
			large_grads -= I
		else
			var/image/grad = image('icons/ui/blob/32x32.dmi', src, "grad_big")
			grad.pixel_y = round(21 + (i * 200 / M.max_blob_points))
			grad.layer = MIND_UI_BUTTON + 0.5
			overlays += grad
			grad_images_large += grad

	// cover

	var/image/cover = image(icon, src, "coverLEFT")
	cover.layer = MIND_UI_FRONT
	overlays += cover

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_points_count
	icon = 'icons/ui/blob/21x242.dmi'
	icon_state = ""
	layer = MIND_UI_FRONT+1
	mouse_opacity = 0

/obj/abstract/mind_ui_element/blob_points_count/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	overlays.len = 0
	overlays += String2Image("[M.blob_points]")
	if(M.blob_points >= 100)
		offset_x = 0
	else if(M.blob_points >= 10)
		offset_x = 3
	else
		offset_x = 6
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/normal
	name = "Points Needed to Manually Expand Blob"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "miniblob"
	layer = MIND_UI_FRONT+1
	offset_x = 0
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/normal/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBATTCOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/strong
	name = "Points Needed to Spawn Strong Blob"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "ministronk"
	layer = MIND_UI_FRONT+1
	offset_x = 3
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/strong/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBSHICOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/res
	name = "Points Needed to Spawn Resource Blob"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "minires"
	layer = MIND_UI_FRONT+1
	offset_x = 6
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/res/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBRESCOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/fact
	name = "Points Needed to Spawn Factory Blob"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "minifact"
	layer = MIND_UI_FRONT+1
	offset_x = 6
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/fact/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBFACCOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/node
	name = "Points Needed to Spawn Blob Node"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "mininode"
	layer = MIND_UI_FRONT+1
	offset_x = 6
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/node/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBNODCOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/core
	name = "Points Needed to Spawn Blob Core"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "minicore"
	layer = MIND_UI_FRONT+1
	offset_x = 6
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/core/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M) || !M.blob_core)
		return
	var/required_points = BLOBCOREBASECOST + (BLOBCORECOSTINC * (blob_cores.len - 1))
	if (M.max_blob_points < required_points || M.blob_core.creator)
		Hide()
		return
	offset_y = round(-96 + (required_points * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/rally
	name = "Points Needed to Rally Spores"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "minirally"
	layer = MIND_UI_FRONT+1
	offset_x = 9
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/rally/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBRALCOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_mini/taunt
	name = "Points Needed to Send a Psionic Message"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "minitaunt"
	layer = MIND_UI_FRONT+1
	offset_x = 12
	offset_y = -96

/obj/abstract/mind_ui_element/blob_mini/taunt/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	offset_y = round(-96 + (BLOBTAUNTCOST * 200 / M.max_blob_points))
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_toggle_restraint
	name = "Toggle Automatic Expansion Restraint"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "blob"
	offset_x = 18
	offset_y = -102

/obj/abstract/mind_ui_element/hoverable/blob_toggle_restraint/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	overlays.len = 0
	var/image/I = image(icon, src, "restraint-off")
	if (M.restrain_blob)
		I.icon_state = "restraint-on"
	I.layer = MIND_UI_FRONT
	overlays += I

/obj/abstract/mind_ui_element/hoverable/blob_toggle_restraint/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.restrain_blob()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_strong
	name = "Spawn Strong Blob"
	icon_state = "strong"
	offset_x = 18
	offset_y = -66
	required_points = BLOBSHICOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_strong/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.create_shield_power()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_resource
	name = "Spawn Resource Blob"
	icon_state = "resource"
	offset_x = 18
	offset_y = -30
	required_points = BLOBRESCOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_resource/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.create_resource()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_factory
	name = "Spawn Factory Blob"
	icon_state = "factory"
	offset_x = 18
	offset_y = 5
	required_points = BLOBFACCOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_factory/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.create_factory()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_node
	name = "Spawn Blob Node"
	icon_state = "node"
	offset_x = 18
	offset_y = 42
	required_points = BLOBNODCOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_node/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.create_node()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_core
	name = "Spawn Blob Core"
	icon_state = "core"
	offset_x = 18
	offset_y = 78
	required_points = BLOBCOREBASECOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_core/UpdateIcon()
	required_points = BLOBCOREBASECOST + (BLOBCORECOSTINC * (blob_cores.len - 1))
	..()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M) || !M.blob_core)
		return
	if (M.blob_core.creator)
		Hide()
		return
	overlays.len = 0
	if (M.max_blob_points < required_points)
		var/image/I = image(icon, src, "needmorenodes")
		I.layer = MIND_UI_FRONT
		overlays += I

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_spawn_core/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.create_core()

////////////////////////////////////////////////////////////////////
//																  //
//						   RIGHT PANEL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/blob_right_panel
	uniqueID = "Blob Right Panel"
	x = "RIGHT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/blob_health_gauge,
		/obj/abstract/mind_ui_element/blob_health_count,
		/obj/abstract/mind_ui_element/blob_goal_gauge,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_psionic,
		/obj/abstract/mind_ui_element/hoverable/blob_power/blob_rally,
		/obj/abstract/mind_ui_element/hoverable/blob_call,
		/obj/abstract/mind_ui_element/hoverable/blob_remove,
		/obj/abstract/mind_ui_element/hoverable/blob_help,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/blob_help_tooltip,
		)
	display_with_parent = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_health_gauge
	name = "Main Core Health"
	icon = 'icons/ui/blob/21x242.dmi'
	icon_state = "backgroundRIGHT"
	layer = MIND_UI_BACK
	offset_y = -117

/obj/abstract/mind_ui_element/blob_health_gauge/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M) || !M.blob_core)
		return
	overlays.len = 0

	var/gauge_state = "health"
	if (round(M.blob_core.health) <= 66)
		gauge_state = "healthcrit"
	var/image/gauge = image('icons/ui/blob/18x200.dmi', src, gauge_state)
	var/matrix/gauge_matrix = matrix()
	gauge_matrix.Scale(1,M.blob_core.health/M.blob_core.maxHealth)
	gauge.transform = gauge_matrix
	gauge.layer = MIND_UI_BUTTON
	gauge.pixel_x = 3
	gauge.pixel_y = round(-79 + 100 * (M.blob_core.health/M.blob_core.maxHealth))
	overlays += gauge

	var/image/cover = image(icon, src, "coverRIGHT")
	cover.layer = MIND_UI_FRONT
	overlays += cover

/obj/abstract/mind_ui_element/blob_health_gauge/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	if (M.blob_core)
		M.forceMove(M.blob_core.loc)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_health_count
	icon = 'icons/ui/blob/21x242.dmi'
	icon_state = ""
	layer = MIND_UI_FRONT+1
	mouse_opacity = 0

/obj/abstract/mind_ui_element/blob_health_count/UpdateIcon()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M) || !M.blob_core)
		return
	overlays.len = 0
	overlays += String2Image("[M.blob_core.health]")
	if(M.blob_core.health >= 100)
		offset_x = 3
	else if(M.blob_core.health >= 10)
		offset_x = 6
	else
		offset_x = 9
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_goal_gauge
	name = "Goal Progression"
	icon = 'icons/ui/blob/21x242.dmi'
	icon_state = ""
	layer = MIND_UI_BACK
	offset_y = -117

/obj/abstract/mind_ui_element/blob_goal_gauge/UpdateIcon()
	overlays.len = 0
	var/datum/faction/blob_conglomerate/conglomerate = find_active_faction_by_type(/datum/faction/blob_conglomerate)
	if (conglomerate)
		var/image/goal = image('icons/ui/blob/18x200.dmi', src, "goal")
		var/matrix/goal_matrix = matrix()
		goal_matrix.Scale(1,blobs.len/conglomerate.blobwincount)
		goal.transform = goal_matrix
		goal.layer = MIND_UI_BUTTON
		goal.pixel_y = round(-79 + 100 * (blobs.len/conglomerate.blobwincount))
		overlays += goal
		name = "Goal Progression = [round(1000*blobs.len/conglomerate.blobwincount)/10]%"


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_psionic
	name = "Send Psionic Message to the Crew"
	icon_state = "taunt"
	offset_x = -8
	offset_y = 189
	required_points = BLOBTAUNTCOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_psionic/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	var/message = copytext(sanitize(input(M,"Send a message to the crew.","Psionic Message") as null|text),1,MAX_MESSAGE_LEN)
	if(message)
		M.telepathy(message)

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_rally
	name = "Rally Spores to your Location"
	icon_state = "rally"
	offset_x = -8
	offset_y = 153
	required_points = BLOBATTCOST

/obj/abstract/mind_ui_element/hoverable/blob_power/blob_rally/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.rally_spores_power()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_call
	name = "Call other Overminds to your Location"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "ping"
	offset_x = -8
	offset_y = 117

/obj/abstract/mind_ui_element/hoverable/blob_call/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.callblobs()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_remove
	name = "Remove blob at your Location"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "remove"
	offset_x = -8
	offset_y = -141

/obj/abstract/mind_ui_element/hoverable/blob_remove/Click()
	var/mob/camera/blob/M = GetUser()
	if(!istype(M))
		return
	M.revert()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_help
	name = "Check Keyboard Shortcuts"
	icon = 'icons/ui/blob/32x32.dmi'
	icon_state = "help"
	offset_x = -8
	offset_y = -177

/obj/abstract/mind_ui_element/hoverable/blob_help/Click()
	var/datum/mind_ui/blob_help_tooltip/tooltip = locate() in parent.subUIs
	if(tooltip)
		tooltip.Display()

////////////////////////////////////////////////////////////////////
//																  //
//						   HELP TOOLTIP							  //
//																  //
////////////////////////////////////////////////////////////////////


/datum/mind_ui/blob_help_tooltip
	uniqueID = "Blob Help Tooltip"
	x = "RIGHT"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/blob_help_tooltip,
		/obj/abstract/mind_ui_element/hoverable/blob_help_close,
		)
	display_with_parent = FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/blob_help_tooltip
	name = "Blob Help Tooltip"
	icon = 'icons/ui/192x192.dmi'
	icon_state = "blob_help"
	offset_x = -42
	offset_y = -177
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/blob_help_tooltip/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/blob_help_close
	name = "Blob Help Tooltip"
	icon = 'icons/ui/16x16.dmi'
	icon_state = "close"
	offset_x = -42
	offset_y = -65
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/blob_help_close/Click()
	parent.Hide()

//------------------------------------------------------------

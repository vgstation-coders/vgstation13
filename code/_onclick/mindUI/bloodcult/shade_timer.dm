
////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - SHADE TIMER						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_shade_timer
	uniqueID = "Shade Timer"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/shade_timer_count,
		/obj/abstract/mind_ui_element/hoverable/shade_timer_gauge,
		/obj/abstract/mind_ui_element/shade_timer_front,
		)
	display_with_parent = TRUE

/datum/mind_ui/bloodcult_shade_timer/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if (M.stat != DEAD)
		return FALSE
	if(!iscultist(M))
		return FALSE
	if(!(ishuman(M) || isconstruct(M) || isbrain(M) || istype(M, /mob/living/carbon/complex/gondola)))
		return FALSE
	var/timetocheck = M.timeofdeath
	if (isbrain(M))
		var/mob/living/carbon/brain/brainmob = M
		timetocheck = brainmob.timeofhostdeath
	if ((timetocheck == 0) || (timetocheck >= (world.time - DEATH_SHADEOUT_TIMER)))
		return TRUE
	return FALSE


//------------------------------------------------------------

/obj/abstract/mind_ui_element/shade_timer_count
	name = "Time left to turn into a Shade"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "blank"
	offset_x = -13
	offset_y = 88
	layer = MIND_UI_FRONT
	element_flags = MINDUI_FLAG_PROCESSING
	mouse_opacity = 0
	var/red_blink = FALSE
	var/timeleft = 60

/obj/abstract/mind_ui_element/shade_timer_count/process()
	if (invisibility == 101)
		return

	var/mob/M = GetUser()
	var/timetocheck = M.timeofdeath
	if (isbrain(M))
		var/mob/living/carbon/brain/brainmob = M
		timetocheck = brainmob.timeofhostdeath

	timeleft = floor((timetocheck - (world.time - DEATH_SHADEOUT_TIMER)) / 10) + 1
	if (timeleft <= 0)
		parent.Hide()
	else
		UpdateIcon()

/obj/abstract/mind_ui_element/shade_timer_count/UpdateIcon()
	overlays.len = 0
	offset_x = -16

	var/timestring = num2text(timeleft)

	if (timeleft < 10)
		red_blink = !red_blink
		timestring = "0[timestring]"

	if (red_blink)
		overlays += String2Image("  [timestring]",10,'icons/ui/font_16x16.dmi',"#FF0000")
	else
		overlays += String2Image("  [timestring]",10,'icons/ui/font_16x16.dmi',"#FFFFFF")

	UpdateUIScreenLoc()

/obj/abstract/mind_ui_element/shade_timer_count/Click()
	var/mob/living/L = GetUser()
	if (istype(L))
		L.ghost()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/shade_timer_gauge
	name = "Time left to turn into a Shade"
	icon = 'icons/ui/bloodcult/288x16.dmi'
	icon_state = "shade_gauge"
	layer = MIND_UI_BUTTON
	offset_x = -128
	offset_y = 86
	element_flags = MINDUI_FLAG_PROCESSING

	hover_state = FALSE
	element_flags = MINDUI_FLAG_TOOLTIP|MINDUI_FLAG_PROCESSING
	tooltip_title = "Shade Timer"
	tooltip_content = "For up to one minute following the time of death, cultists can channel one last time the dark energies in their bodies to manifest as a Shade instead of turning into a Ghost.<br><br>Shades are very fragile but they can crawl through vents, and if you reach your fellow cultists they may help you regain a body.<br><br>\[Click to begin the process\]."
	tooltip_theme = "radial-cult"

	var/image/mask
	var/image/shade

/obj/abstract/mind_ui_element/hoverable/shade_timer_gauge/New()
	..()
	appearance_flags |= KEEP_TOGETHER
	mask = image(icon, src, "shade_gauge_bg")
	mask.blend_mode = BLEND_INSET_OVERLAY
	shade = image('icons/mob/mob.dmi', src, "shade")
	add_particles(PS_CULT_GAUGE)

/obj/abstract/mind_ui_element/hoverable/shade_timer_gauge/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/shade_timer_gauge/UpdateIcon()
	var/mob/M = GetUser()
	var/timetocheck = M.timeofdeath
	if (isbrain(M))
		var/mob/living/carbon/brain/brainmob = M
		timetocheck = brainmob.timeofhostdeath

	var/timeleft = (timetocheck - (world.time - DEATH_SHADEOUT_TIMER)) / DEATH_SHADEOUT_TIMER

	mask.pixel_x = max(0, 288 * timeleft)

	if (timeleft <= 0)
		adjust_particles(PVAR_SPAWNING, 0)
	else
		adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16,-1), list(mask.pixel_x-16,-14)))
		adjust_particles(PVAR_VELOCITY, list((288-mask.pixel_x)/40, 0))
	overlays.len = 0
	overlays += mask

	shade.pixel_x = mask.pixel_x - 16

	overlays += shade

/obj/abstract/mind_ui_element/hoverable/shade_timer_gauge/Click()
	var/mob/living/L = GetUser()
	if (istype(L))
		L.ghost()


//------------------------------------------------------------

/obj/abstract/mind_ui_element/shade_timer_front
	name = "Time left to turn into a Shade"
	icon = 'icons/ui/bloodcult/362x229.dmi'
	icon_state = "foreground_shade"
	offset_x = -165
	offset_y = -93
	alpha = 255
	layer = MIND_UI_FRONT
	mouse_opacity = 0

/obj/abstract/mind_ui_element/shade_timer_front/Click()
	var/mob/living/L = GetUser()
	if (istype(L))
		L.ghost()

//------------------------------------------------------------

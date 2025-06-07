/mob
	var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/abstract/screen/fullscreen/screen = screens[category]
	if(!screen || screen.type != type)
		clear_fullscreen(category, FALSE)
		screen = new type
	else if(screen.clear_after_length)
		screen = new type
	else if(!severity || severity == screen.severity)
		return null

	screen.severity = severity
	screens[category] = screen
	screen.icon_state = "[initial(screen.icon_state)][severity]"

	if(client)
		if(screen.anim_state)
			flick("[screen.anim_state][severity]",screen)
		client.screen += screen
		if (screen.screen_loc == "CENTER-7,CENTER-7" && screen.view != client.view && screen.scaling)
			var/scale = (1 + 2 * client.view) / 15
			screen.view = client.view
			screen.transform = matrix(scale, 0, 0, 0, scale, 0)
		if(screen.clear_after_length)
			spawn(screen.clear_after_length)
				clear_fullscreen(category, animate = 0)
	return screen

/mob/proc/update_fullscreen_alpha(category, a = 255, t = 10)
	var/obj/abstract/screen/fullscreen/screen = screens[category]
	if(!screen)
		screens -= category
		return
	if (client)
		client.screen -= screen
		animate(screen, alpha = a, time = t)
		client.screen += screen

/mob/proc/clear_fullscreen(category, animate = 10)
	set waitfor = 0
	var/obj/abstract/screen/fullscreen/screen = screens[category]
	if(!screen)
		screens -= category
		return

	if(animate)
		animate(screen, alpha = 0, time = animate)
		sleep(animate)

	screens[category] = null
	screens -= category
	if(client)
		client.screen -= screen
	qdel(screen)

/mob/proc/clear_fullscreens(var/dead_mob = FALSE, var/animate = 10)
	for(var/category in screens)
		if (!dead_mob || ((category != "brute") && (category != "oxy")))
			clear_fullscreen(category, animate)

/datum/hud/proc/reload_fullscreen()
	if(mymob && mymob.client && mymob.stat != DEAD)
		var/list/screens = mymob.screens
		for(var/category in screens)
			var/obj/A = screens[category]
			if(!A)
				log_debug("screens\[[category]\] is null on [mymob]")
				continue
			if(istype(A, /atom))
				if(!istype(A, /obj/abstract/screen))
					log_debug("Wrong type of object in screens, type [A.type] [mymob]")
					continue
			else // not even an atom, shouldnt go in list anyway
				log_debug("screens\[[category]\] is a non-atom, WHY IS THIS IN SCREENS [mymob]")
				continue
			mymob.client.screen |= A

/obj/abstract/screen/fullscreen
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = 0
	var/view = 7
	var/severity = 0
	var/anim_state
	var/clear_after_length // also doubles as the length of the animation
	var/scaling = 1

/obj/abstract/screen/fullscreen/Destroy()
	severity = 0
	..()

/obj/abstract/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/numb
	icon_state = "numboverlay"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/obj/abstract/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/obj/abstract/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/obj/abstract/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/obj/abstract/screen/fullscreen/nearsighted
	icon = 'icons/mob/screen1_blindness.dmi'
	icon_state = "eye"

/obj/abstract/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blank"
	anim_state = "flash"
	clear_after_length = 27

/obj/abstract/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blank"
	anim_state = "noise"

/obj/abstract/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

/obj/abstract/screen/fullscreen/high/red
	color = "red"
	alpha = 150
	blend_mode = 4

/obj/abstract/screen/fullscreen/hackview_border
	icon_state = "malfview"
	layer = HALLUCINATION_LAYER
	alpha = 255

/obj/abstract/screen/fullscreen/conversion_border
	icon_state = "conversionoverlay"
	layer = HALLUCINATION_LAYER
	alpha = 0

/obj/abstract/screen/fullscreen/confusion_border
	icon_state = "conversionoverlay"
	layer = HALLUCINATION_LAYER
	alpha = 0

/obj/abstract/screen/fullscreen/deafmute_border
	icon_state = "conversionoverlay"
	layer = HALLUCINATION_LAYER
	alpha = 0

/obj/abstract/screen/fullscreen/astral_border
	icon_state = "astraloverlay"
	layer = HALLUCINATION_LAYER
	alpha = 0

/obj/abstract/screen/fullscreen/conversion_red
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "redoverlay"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/black
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "black"
	layer = BLIND_LAYER
	alpha = 0

/obj/abstract/screen/fullscreen/white
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "white"
	layer = BLIND_LAYER
	alpha = 0

/obj/abstract/screen/fullscreen/science
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "science"

/obj/abstract/screen/fullscreen/snowfall_blizzard
	icon_state = "oxydamageoverlay7"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/snowfall_hard
	icon_state = "oxydamageoverlay5"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/snowfall_average
	icon_state = "oxydamageoverlay2"
	layer = DAMAGE_HUD_LAYER

/obj/abstract/screen/fullscreen/client_fadein
	layer = BLIND_LAYER
	scaling = 0

/obj/abstract/screen/fullscreen/client_fadein/New()
	. = ..()
	icon = current_round_splashscreen

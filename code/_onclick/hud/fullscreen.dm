/mob
	var/list/screens = list()

/mob/proc/overlay_fullscreen(category, type, severity)
	var/obj/screen/fullscreen/screen
	if(screens[category])
		screen = screens[category]
		if(screen.type != type)
			clear_fullscreen(category, FALSE)
			return
		else if(screen.clear_after_length)
			screen = getFromPool(type)
		else if(!severity || severity == screen.severity)
			return null
	else
		screen = getFromPool(type)

	screen.severity = severity
	if(screen.anim_state)
		flick("[screen.anim_state][severity]",screen)
		if(client)
			client.screen += screen
		if(screen.clear_after_length)
			spawn(screen.clear_after_length)
				if(client)
					client.screen -= screen
				qdel(screen)
	else
		screen.icon_state = "[initial(screen.icon_state)][severity]"
	if(screen.clear_after_length)
		return 1
	screens[category] = screen
	if(client)
		client.screen += screen
	return screen

/mob/proc/clear_fullscreen(category, animate = 10)
	set waitfor = 0
	var/obj/screen/fullscreen/screen = screens[category]
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

/mob/proc/clear_fullscreens()
	for(var/category in screens)
		clear_fullscreen(category)

/datum/hud/proc/reload_fullscreen()
	if(mymob && mymob.client && mymob.stat != DEAD)
		var/list/screens = mymob.screens
		for(var/category in screens)
			var/obj/A = screens[category]
			if(!A)
				log_debug("screens\[[category]\] is null on [mymob]")
				continue
			if(istype(A, /atom))
				if(!istype(A, /obj/screen))
					log_debug("Wrong type of object in screens, type [A.type] [mymob]")
					continue
			else // not even an atom, shouldnt go in list anyway
				log_debug("screens\[[category]\] is a non-atom, WHY IS THIS IN SCREENS [mymob]")
				continue
			mymob.client.screen |= A

/obj/screen/fullscreen
	icon = 'icons/mob/screen1_full.dmi'
	icon_state = "default"
	screen_loc = "CENTER-7,CENTER-7"
	layer = FULLSCREEN_LAYER
	plane = FULLSCREEN_PLANE
	mouse_opacity = 0
	var/severity = 0
	var/anim_state
	var/clear_after_length // also doubles as the length of the animation

/obj/screen/fullscreen/Destroy()
	severity = 0
	..()

/obj/screen/fullscreen/brute
	icon_state = "brutedamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/oxy
	icon_state = "oxydamageoverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/numb
	icon_state = "numboverlay"
	layer = DAMAGE_LAYER

/obj/screen/fullscreen/crit
	icon_state = "passage"
	layer = CRIT_LAYER

/obj/screen/fullscreen/blind
	icon_state = "blackimageoverlay"
	layer = BLIND_LAYER

/obj/screen/fullscreen/impaired
	icon_state = "impairedoverlay"
	layer = IMPAIRED_LAYER

/obj/screen/fullscreen/blurry
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blurry"

/obj/screen/fullscreen/flash
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blank"
	anim_state = "flash"
	clear_after_length = 27

/obj/screen/fullscreen/flash/noise
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "blank"
	anim_state = "noise"

/obj/screen/fullscreen/high
	icon = 'icons/mob/screen1.dmi'
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	icon_state = "druggy"

//Gravpults 2.0 - by Deity Link
//Because getting to use those is one of the coolest things about piloting a Marauder
//Those things look like Mass Drivers but work sensibly differently
//They only work if placed directly to the right of a Pod Door
//They throw at a relatively low speed, so place a few Kinetic Accelerators afterwards
//Players in Mechs that walk on top get an holomap-like interface that lets them pick a landing altitude (y axis) and launch themselves

//https://www.youtube.com/watch?v=mCrZZAZr5S8

var/list/gravpults = list()

/obj/structure/deathsquad_gravpult
	name = "Gravpult"
	density = 0
	anchored = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mass_driver"
	var/portal_dist = 21		//how far the portal will open from the launch pad.
	var/aim = 244				//where on the Y axis will the mech be launched, the user can use an interface to set it
	var/mob/living/user = null	//the pilot currently in the mech
	var/obj/mecha/mech = null	//the mech on the launch pad
	var/image/station_map		//the holominimap map of the station
	var/image/background		//a reddish background similar to station maps'. IMPORTANT as it detects the users' clicks.
	var/image/target			//the red line that indicates your destination
	var/list/targets = list()	//the red lines of the other gravpults (only visible if people are using them right now)
	var/ID = 1						//this gravpult's ID, number them 1, 2, 3, 4, etc
	var/list/holomap_images = list()//storing the images used by the interface for easy adding/removing/updating
	var/obj/abstract/screen/interface/button_launch = null	//an ephemeral HUD element, click it to trigger the gravpult's launch sequence

/obj/structure/deathsquad_gravpult/New()
	..()
	gravpults += src
	station_holomaps += src
	aim -= ID*2
	if(ticker && holomaps_initialized)
		initialize_holomaps()

/obj/structure/deathsquad_gravpult/Destroy()
	station_holomaps -= src
	gravpults -= src
	..()

/obj/structure/deathsquad_gravpult/proc/initialize_holomaps()
	background = image('icons/480x480.dmi', "stationmap_red")
	background.plane = HUD_PLANE
	background.layer = UNDER_HUD_LAYER

	station_map = image(holoMiniMaps[map.zMainStation])
	station_map.color = "#660000"
	station_map.plane = HUD_PLANE
	station_map.layer = HUD_BASE_LAYER
	holomap_images += background
	holomap_images += station_map

	for(var/obj/structure/deathsquad_gravpult/G in gravpults)
		if (G == src) continue
		targets += G

		var/image/I = image('icons/effects/256x256.dmi', "gravtarget_[G.ID]")
		I.alpha = 0
		I.color = "#999999"
		I.plane = HUD_PLANE
		I.layer = HUD_ITEM_LAYER
		I.pixel_x = 150
		I.pixel_y = G.aim
		holomap_images += I
		targets[G] = I

/obj/structure/deathsquad_gravpult/Crossed(var/atom/movable/AM)
	if (!user && istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if (M.occupant)
			mech = M
			user = M.occupant
			setup(user)
	..()

/obj/structure/deathsquad_gravpult/Uncrossed(var/atom/movable/AM)
	if (AM == mech)
		hud_off()
		mech = null
	..()

/obj/structure/deathsquad_gravpult/proc/setup(var/mob/living/M)

	if(user && user.client && user.hud_used && user.hud_used.holomap_obj)
		playsound(src, 'sound/machines/alert.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)
		if (!target)
			target = image('icons/effects/256x256.dmi', "gravtarget_[ID]")
		target.pixel_x = 150
		target.pixel_y = aim
		target.plane = HUD_PLANE
		target.layer = HUD_ABOVE_ITEM_LAYER
		background.loc = user.hud_used.holomap_obj
		station_map.loc = user.hud_used.holomap_obj
		target.loc = user.hud_used.holomap_obj
		user.hud_used.holomap_obj.mouse_opacity = 1
		background.alpha = 0
		station_map.alpha = 0
		target.alpha = 0
		animate(background, alpha = 255, time = 5, easing = LINEAR_EASING)
		animate(station_map, alpha = 255, time = 5, easing = LINEAR_EASING)
		animate(target, alpha = 255, time = 5, easing = LINEAR_EASING)
		holomap_images += target

		for(var/obj/structure/deathsquad_gravpult/G in gravpults)
			if (G == src) continue
			if (G.mech)
				var/image/I = targets[G]
				I.loc = user.hud_used.holomap_obj
				I.alpha = 0
				I.pixel_x = 150
				I.pixel_y = G.aim
				animate(I, alpha = 255, time = 5, easing = LINEAR_EASING)

		user.client.images |= holomap_images



		button_launch = new (user.hud_used.holomap_obj,user,src,"launch",'icons/effects/64x32.dmi',"launch",l="CENTER,CENTER-4")
		button_launch.name = "Launch"
		button_launch.alpha = 0
		animate(button_launch, alpha = 255, time = 5, easing = LINEAR_EASING)
		user.client.screen += button_launch

/obj/structure/deathsquad_gravpult/proc/update_aim()
	if (!user) return

	user.playsound_local(src, 'sound/misc/click.ogg', 50, 0, 0, 0, 0)
	user.client.images -= holomap_images
	target.pixel_y = aim
	user.client.images |= holomap_images

	for(var/obj/structure/deathsquad_gravpult/G in gravpults)
		if (G == src) continue
		if(G.user && G.user.client)
			G.user.client.images -= G.holomap_images
			var/image/I = G.targets[src]
			I.pixel_y = aim
			G.user.client.images |= G.holomap_images

/obj/structure/deathsquad_gravpult/interface_act(var/mob/i_user,var/action)
	switch(action)
		if("launch")
			i_user.playsound_local(src, 'sound/misc/click.ogg', 50, 0, 0, 0, 0)
			launch()

/obj/structure/deathsquad_gravpult/proc/launch()
	if (!mech)
		return
	var/obj/machinery/door/poddoor/D = locate() in get_step(loc,WEST)
	if (!D)
		return

	if (istype(mech,/obj/mecha/combat/marauder))
		mech.icon_state = mech.initial_icon + "-dash"

	//turning off the mech's controls temporarily so the user can't mess up the launch, voluntarily or not
	mech.set_control_lock(1)
	mech.set_control_lock(0,50)

	hud_off()
	//opening the portal
	new /obj/effect/overlay/mechaportal(locate(x-portal_dist,y,z),world.maxx - TRANSITIONEDGE - rand(10,20),aim+1,map.zMainStation)
	sleep(10)
	playsound(src, 'sound/machines/Gravpult.ogg', 75, 0, null, FALLOFF_SOUNDS, 0)
	sleep(10)
	//opening the blast door
	D.open()
	sleep(5)
	//sending mecha
	mech.throw_at(locate(1,y,z), 50, 0.25)
	playsound(src, 'sound/weapons/rocket.ogg', 50, 0, null, FALLOFF_SOUNDS, 0)
	mech = null
	flick("mass_driver1", src)
	sleep(7)
	//closing the blast door
	D.close()

/obj/structure/deathsquad_gravpult/proc/hud_off()
	if (user)
		qdel(button_launch)
		button_launch = null
		user.client.screen -= button_launch
		user.hud_used.holomap_obj.mouse_opacity = 0
		user.client.images -= holomap_images
		user = null


/obj/structure/deathsquad_tele
	name = "Mech Teleporter"
	density = 0
	anchored = 1
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "broadcast receiver"

/obj/effect/overlay/mechaportal
	name = "Mech Portal"
	icon = 'icons/effects/effects.dmi'
	icon_state = "mechaportal"
	density = 0
	anchored = 1
	var/obj/effect/overlay/mechaportal/target = null

/obj/effect/overlay/mechaportal/New(turf/loc,var/targetX,var/targetY,var/targetZ)
	..()
	if (targetX&&targetY&&targetZ)
		var/turf/T = locate(targetX,targetY,targetZ)
		if (T)
			target = new /obj/effect/overlay/mechaportal(T)
	spawn(200)
		if (src)
			breakdown()

/obj/effect/overlay/mechaportal/Crossed(var/atom/movable/AM)
	if (target && istype(AM,/obj/mecha))
		teleport(AM)

/obj/effect/overlay/mechaportal/proc/teleport(var/obj/mecha/M)
	if (!target)
		return
	if (istype(M))
		do_teleport(M, target, 0, 1, 1, 1, null, null)
		spawn(1)
			target.breakdown()
		breakdown()

/obj/effect/overlay/mechaportal/proc/breakdown()
	if (src && loc)
		playsound(src, 'sound/weapons/wave.ogg', 100, 0, null, FALLOFF_SOUNDS, 0)
		icon_state = "nothing"
		flick("mechaportal_break2",src)
		spawn(10)
			if (src)
				qdel(src)

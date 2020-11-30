var/datum/subsystem/daynightcycle/SSDayNight

#define TOD_MORNING 	1
#define TOD_SUNRISE 	2
#define TOD_DAYTIME 	3
#define TOD_AFTERNOON 	4
#define TOD_SUNSET 		5
#define TOD_NIGHTTIME 	6

/datum/subsystem/daynightcycle
	name          = "Day Night Cycle"
	init_order    = SS_INIT_DAYNIGHT
	display_order = SS_DISPLAY_DAYNIGHT
	priority      = SS_PRIORITY_DAYNIGHT
	wait          = 20 MINUTES
	flags         = SS_BACKGROUND|SS_FIRE_IN_LOBBY

	var/current_color = "#4d3d66"
	var/timeOfDay = TOD_MORNING
	var/asspower = 10
	var/assrange = 1

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	var/list/timestwopick = list(TOD_MORNING,
								TOD_SUNRISE,
								TOD_DAYTIME,
								TOD_AFTERNOON,
								TOD_SUNSET,
								TOD_NIGHTTIME)
	timeOfDay = pick(timestwopick)
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(!map.daynight_cycle)
		flags |= SS_NO_FIRE
		pause()
	else
		switch(timeOfDay)
			if(TOD_MORNING)
				current_color = "#4d6f86"
				timeOfDay = TOD_SUNRISE
			if(TOD_SUNRISE)
				current_color = "#fdc5a0"
				timeOfDay = TOD_DAYTIME
			if(TOD_DAYTIME)
				current_color = "#FFFFFF"
				timeOfDay = TOD_AFTERNOON
			if(TOD_AFTERNOON)
				current_color = "#ffeedf"
				timeOfDay = TOD_SUNSET
			if(TOD_SUNSET)
				current_color = "#75497e"
				timeOfDay = TOD_NIGHTTIME
			if(TOD_NIGHTTIME)
				current_color = "#002235"
				timeOfDay = TOD_MORNING
		
		time2fire()

/datum/subsystem/daynightcycle/proc/time2fire()
	for(var/turf/T in block(locate(1, 1, 1), locate(world.maxx, world.maxy, 1)))
		if(IsEven(T.x)) //If we are also even.
			if(IsEven(T.y)) //If we are also even.
				if(istype(T, /turf/unsimulated/floor/snow)) //If we are outside.
					T.set_light(assrange,asspower,current_color)
				else //If We aren't we need to make sure we handle the outside segment
					for(var/cdir in cardinal)//Ironically, this part didn't work correctly but....
						var/turf/TITTIES = get_step(T,cdir)// It also ironically produced better looking day/night lighting
						if(istype(TITTIES, /turf/unsimulated/floor/snow)) //If we are outside.
							TITTIES.set_light(assrange,asspower,current_color) //Set it, starlighto scanno
							break
							
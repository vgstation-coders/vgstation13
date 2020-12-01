var/datum/subsystem/daynightcycle/SSDayNight
								//Ticker:2 MINUTES - 1 TICK
#define TOD_MORNING 	"#4d6f86" //  2 minutes  - 1 ticks
#define TOD_SUNRISE 	"#fdc5a0" //  2 minutes  - 1 ticks
#define TOD_DAYTIME 	"#FFFFFF" //  16 minutes - 8 ticks
#define TOD_AFTERNOON 	"#ffeedf" //  16 minutes - 8 ticks
#define TOD_SUNSET 		"#75497e" //  2 minutes  - 1 ticks
#define TOD_NIGHTTIME 	"#001522" //  36 minutes - 18 ticks
								//Total 92 Minutes

/datum/subsystem/daynightcycle
	name          = "Day Night Cycle"
	init_order    = SS_INIT_DAYNIGHT
	display_order = SS_DISPLAY_DAYNIGHT
	priority      = SS_PRIORITY_DAYNIGHT
	wait          = 2 MINUTES
	flags         = SS_BACKGROUND|SS_FIRE_IN_LOBBY

	//The initial values don't matter, it just needs to fire initially, then set itself into the cycle.
	var/two_minute_ticker = 6669
	var/next_firetime = 420 
	
	var/current_timeOfDay = TOD_DAYTIME //We start tickers maxed out, and start on afternoon
	var/next_light_power = 10
	var/next_light_range = 1

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(!map.daynight_cycle)
		flags |= SS_NO_FIRE
		pause()
	else
		two_minute_ticker++
	
		if(two_minute_ticker >= next_firetime)	
			switch(current_timeOfDay) //Then set the next segment up.
				if(TOD_MORNING)
					current_timeOfDay = TOD_SUNRISE
					next_firetime = 1
					play_globalsound()
				if(TOD_SUNRISE)
					current_timeOfDay = TOD_DAYTIME
					next_firetime = 8
				if(TOD_DAYTIME)
					current_timeOfDay = TOD_AFTERNOON
					next_firetime = 8
				if(TOD_AFTERNOON)
					current_timeOfDay = TOD_SUNSET
					next_firetime = 1
				if(TOD_SUNSET)
					current_timeOfDay = TOD_NIGHTTIME
					next_firetime = 18
					play_globalsound()
				if(TOD_NIGHTTIME)
					current_timeOfDay = TOD_MORNING
					next_firetime = 1

			time2fire() //We fire
			two_minute_ticker = 0
		
/datum/subsystem/daynightcycle/proc/play_globalsound()
	for(var/mob/M in player_list)
		if(!M.client)
			continue
		else
			switch(current_timeOfDay)
				if(TOD_SUNRISE)
					M << 'sound/misc/6amRooster.wav'
				if(TOD_NIGHTTIME)
					M << 'sound/misc/6pmWolf.wav'

/datum/subsystem/daynightcycle/proc/time2fire()
	for(var/turf/T in block(locate(1, 1, map.daynight_cycle), locate(world.maxx, world.maxy, map.daynight_cycle)))
		if(IsEven(T.x)) //If we are also even.
			if(IsEven(T.y)) //If we are also even.
				var/area/A = get_area(T)
				if(istype(A, /area/surface)) //If we are outside.
					T.set_light(next_light_range,next_light_power,current_timeOfDay)
				else //If We aren't we need to make sure we handle the outside segment
					for(var/cdir in cardinal)//Ironically, this part didn't work correctly but....
						var/turf/T1 = get_step(T,cdir)// It also ironically produced better looking day/night lighting
						var/area/A1 = get_area(T1)
						if(istype(A1, /area/surface)) //If we are outside.
							T1.set_light(next_light_range,next_light_power,current_timeOfDay) //Set it, starlighto scanno
							break
							
var/datum/subsystem/daynightcycle/SSDayNight
var/list/daynight_turfs = list()
/* Original Plan
Ticker:   2 MINUTES - 1 TICK
Morning	  - 2 Mins - 1 Ticks
Sunrise   - 2 Mins - 1 Ticks
Daytime   - 16 Minutes - 8 Ticks
Afternoon - 16 Minutes - 8 Ticks
Sunset    - 2 Minutes - 1 Ticks
Nighttime - 16 Minutes - 18 Ticks
Total: 92 Minutes
*/
					
#define TOD_MORNING 	"#4d6f86" 
#define TOD_SUNRISE 	"#fdc5a0"
#define TOD_DAYTIME 	"#FFFFFF"
#define TOD_AFTERNOON 	"#ffeedf"
#define TOD_SUNSET 		"#75497e"
#define TOD_NIGHTTIME 	"#001522"

/datum/subsystem/daynightcycle
	name          = "Day Night Cycle"
	init_order    = SS_INIT_DAYNIGHT
	display_order = SS_DISPLAY_DAYNIGHT
	priority      = SS_PRIORITY_DAYNIGHT
	wait          = 1 MINUTES
	flags         = SS_FIRE_IN_LOBBY

	var/current_timeOfDay = TOD_DAYTIME //We start tickers maxed out, and start on afternoon
	var/next_light_power = 10
	var/next_light_range = 1

	//The initial values don't matter, it just needs to fire initially, then set itself into the cycle.
	var/next_firetime = 0
	var/list/currentrun

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	get_turflist()
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(!map.daynight_cycle)
		flags |= SS_NO_FIRE
		pause()
	else

		if(world.time >= next_firetime)
			switch(current_timeOfDay) //Then set the next segment up.
				if(TOD_MORNING)
					current_timeOfDay = TOD_SUNRISE
					next_firetime = world.time + 2 MINUTES
					play_globalsound()
				if(TOD_SUNRISE)
					current_timeOfDay = TOD_DAYTIME
					next_firetime = world.time + 8 MINUTES
				if(TOD_DAYTIME)
					current_timeOfDay = TOD_AFTERNOON
					next_firetime = world.time + 8 MINUTES
				if(TOD_AFTERNOON)
					current_timeOfDay = TOD_SUNSET
					next_firetime = world.time + 2 MINUTES
				if(TOD_SUNSET)
					current_timeOfDay = TOD_NIGHTTIME
					next_firetime = world.time + 16 MINUTES
					play_globalsound()
				if(TOD_NIGHTTIME)
					current_timeOfDay = TOD_MORNING
					next_firetime = world.time + 2 MINUTES
				
		if(!resumed)
			currentrun = daynight_turfs.Copy()

		while(currentrun.len)
			var/turf/T = currentrun[currentrun.len]
			currentrun.len--

			if(!T || T.gcDestroyed)
				continue

			T.set_light(next_light_range,next_light_power,current_timeOfDay)

			if(MC_TICK_CHECK)
				return

/datum/subsystem/daynightcycle/proc/get_turflist()
	if(map.daynight_cycle)
		for(var/turf/T in block(locate(1, 1, map.daynight_cycle), locate(world.maxx, world.maxy, map.daynight_cycle)))
			if(IsEven(T.x)) //If we are also even.
				if(IsEven(T.y)) //If we are also even.
					var/area/A = get_area(T)
					if(istype(A, /area/surface)) //If we are outside.
						daynight_turfs += T
					else //If We aren't we need to make sure we handle the outside segment
						for(var/cdir in cardinal)//Ironically, this part didn't work correctly but....
							var/turf/T1 = get_step(T,cdir)// It also ironically produced better looking day/night lighting
							var/area/A1 = get_area(T1)
							if(istype(A1, /area/surface)) //If we are outside.
								daynight_turfs += T

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

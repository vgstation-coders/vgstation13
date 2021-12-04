var/datum/subsystem/daynightcycle/SSDayNight
var/list/daynight_turfs = list()
/* Original Plan
Morning	  - 2 Mins
Sunrise   - 2 Mins
Daytime   - 16 Minutes
Afternoon - 16 Minutes
Sunset    - 2 Minutes
Nighttime - 36 Minutes
*/
					
#define TOD_MORNING 	"#4d6f86" 
#define TOD_SUNRISE 	"#fdc5a0"
#define TOD_DAYTIME 	"#FFFFFF"
#define TOD_AFTERNOON 	"#ffeedf"
#define TOD_SUNSET 		"#75497e"
#define TOD_NIGHTTIME 	"#000b11"

/datum/subsystem/daynightcycle
	name          = "Day Night Cycle"
	init_order    = SS_INIT_DAYNIGHT
	display_order = SS_DISPLAY_DAYNIGHT
	priority      = SS_PRIORITY_DAYNIGHT
	wait          = 1 MINUTES
/*
On the map dm file, append the following to activate day/night lighting.
Basically, you are going to overwrite the flags.

/datum/subsystem/daynightcycle
	flags = SS_FIRE_IN_LOBBY       This is basically how you want it to run.
	daynight_z_lvl = 1   This basically is the z level it will be on. Defaults to main station unless specified here.

	See: Both of them right here!
*/
	flags 		  = SS_NO_FIRE | SS_NO_INIT
	var/daynight_z_lvl = FALSE

	var/current_timeOfDay = TOD_DAYTIME //This is more or less the color and duration since its in a switch.
	var/next_light_power = 10 // As much as you would want to change these for cool factor.
	var/next_light_range = 1 //	They basically are at the maximum values to not have overlapping light. 
							// Along with mesh evenly that is, the dir scan handles missed diagonals stylishly.

	//The initial values don't matter, it just needs to fire initially, then set itself into the cycle.
	var/next_firetime = 0 //In essence this is world.time + the time you want. Ex: world.time + 3 MINUTES
	var/list/currentrun

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	if(!daynight_z_lvl)
		daynight_z_lvl = map.zMainStation
	get_turflist()
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(world.time >= next_firetime)
		switch(current_timeOfDay) //Then set the next segment up.
			if(TOD_MORNING)
				current_timeOfDay = TOD_SUNRISE
				next_firetime = world.time + 3 MINUTES
				play_globalsound()
			if(TOD_SUNRISE)
				current_timeOfDay = TOD_DAYTIME
				next_firetime = world.time + 14 MINUTES
			if(TOD_DAYTIME)
				current_timeOfDay = TOD_AFTERNOON
				next_firetime = world.time + 15 MINUTES
			if(TOD_AFTERNOON)
				current_timeOfDay = TOD_SUNSET
				next_firetime = world.time + 3 MINUTES
			if(TOD_SUNSET)
				current_timeOfDay = TOD_NIGHTTIME
				next_light_power = 3
				next_firetime = world.time + 36 MINUTES
				play_globalsound()
			if(TOD_NIGHTTIME)
				current_timeOfDay = TOD_MORNING
				next_light_power = 10
				next_firetime = world.time + 5 MINUTES
			
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
	for(var/turf/T in block(locate(1, 1, daynight_z_lvl), locate(world.maxx, world.maxy, daynight_z_lvl)))
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

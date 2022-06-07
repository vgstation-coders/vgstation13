var/datum/subsystem/daynightcycle/SSDayNight
var/list/daynight_turfs = list()
var/daily_events = list() //List that you can add /datum/timely_event entries to for some action specific to a time of day
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

	var/datum/timeofday/current_timeOfDay //timeofday datum, our current one; if unspecified defaults to first in...
	var/list/all_times_in_cycle = list() //if empty, defaults to normal snaxi settings; assemble before initializing


	var/next_light_range = 1 //	They basically are at the maximum values to not have overlapping light.
							// Along with mesh evenly that is, the dir scan handles missed diagonals stylishly.

	//The initial values don't matter, it just needs to fire initially, then set itself into the cycle.
	var/next_firetime = 0 //In essence this is world.time + the time you want. Ex: world.time + 3 MINUTES
	var/force_time_forward = FALSE //for adminbus, set to TRUE to immediately advance the time
	var/list/currentrun
	var/completed_cycles = 0

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	if(!daynight_z_lvl)
		daynight_z_lvl = map.zMainStation
	if(!all_times_in_cycle.len)
		all_times_in_cycle = list(new /datum/timeofday/daytime, new /datum/timeofday/afternoon, new /datum/timeofday/sunset,
		new /datum/timeofday/nighttime, new /datum/timeofday/morning, new /datum/timeofday/sunrise)

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(!current_timeOfDay && all_times_in_cycle.len) //Don't have a time of day but we do have a cycle list
		current_timeOfDay = all_times_in_cycle[1]
	if(world.time >= next_firetime || force_time_forward)
		force_time_forward = FALSE
		var/index_time = all_times_in_cycle.Find(current_timeOfDay)
		if(index_time == all_times_in_cycle.len || !index_time)
			current_timeOfDay = all_times_in_cycle[1]
			completed_cycles++
		else
			current_timeOfDay = all_times_in_cycle[index_time+1]
		next_firetime = current_timeOfDay.duration

		for(var/datum/timely_event/TE in daily_events)
			TE.time_changed(current_timeOfDay, completed_cycles)

		if(current_timeOfDay.triggersound)
			play_globalsound()

		if(!resumed)
			currentrun = daynight_turfs.Copy()

	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--

		if(!T || T.gcDestroyed)
			continue

		T.set_light(next_light_range,current_timeOfDay.lightpower,current_timeOfDay.name)

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
		if(M.z != daynight_z_lvl)
			continue
		M << current_timeOfDay.triggersound

/datum/timeofday
	var/name //name doubles as color!
	var/duration
	var/lightpower = 10
	var/triggersound

/datum/timeofday/morning
	name = TOD_MORNING
	duration = 5 MINUTES

/datum/timeofday/sunrise
	name = TOD_SUNRISE
	duration = 3 MINUTES
	triggersound = 'sound/misc/6amRooster.wav'

/datum/timeofday/daytime
	name = TOD_DAYTIME
	duration = 14 MINUTES

/datum/timeofday/daytime/short
	duration = 5 MINUTES

/datum/timeofday/afternoon
	name = TOD_AFTERNOON
	duration = 15 MINUTES

/datum/timeofday/afternoon/short
	duration = 5 MINUTES

/datum/timeofday/sunset
	name = TOD_SUNSET
	duration = 3 MINUTES

/datum/timeofday/nighttime
	name = TOD_NIGHTTIME
	duration = 36 MINUTES
	lightpower = 3
	triggersound = 'sound/misc/6pmWolf.wav'

/datum/timeofday/nighttime/short
	duration = 5 MINUTES

/datum/timely_event/proc/time_changed(datum/timeofday/ctod, cycles)
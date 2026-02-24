var/datum/subsystem/daynightcycle/SSDayNight

var/list/daynight_v_lvls = list()
/* Default Timing
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
On the map dm file, redefine the following:
	- 'daynight_z_lvls' to change the zLevels that the day/night cycle applies to. Do not redefine if you want this subsystem disabled.
	- 'advance_time()' to change the lighting scheme - supports both global and per-planet cycles.
	- 'play_globalsound()' to change or disable the sound played at sunrise and sunset (only for global cycle).
*/
	flags = SS_FIRE_IN_LOBBY

	var/current_timeOfDay = TOD_DAYTIME //This is more or less the color and duration since its in a switch.
	var/next_light_power = 10 // As much as you would want to change these for cool factor.
	var/next_light_range = 1 //	They basically are at the maximum values to not have overlapping light.
							// Along with mesh evenly that is, the dir scan handles missed diagonals stylishly.

	//The initial values don't matter, it just needs to fire initially, then set itself into the cycle.
	var/next_firetime = 0 //In essence this is world.time + the time you want. Ex: world.time + 3 MINUTES
	var/list/currentrun

	var/overwrite_solars=FALSE //if true, the solars will run off of the day/night cycle to determine light power.
	var/nearest_star_angle=0.0 //the angle of the star that the solars will use.
	var/nearest_star_power=1.0 //how much power does the star give the solars? multiplier to base solar generation.
	var/solar_orbit_period=60 //less than 0 = CCW (east to west), CW (west to east) is more than one. in minutes. doesn't really matter that much, it's just for text mostly.

	var/weather_mod = 1 //weather light modifier

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	if(!daynight_v_lvls.len)
		flags = SS_NO_INIT | SS_NO_FIRE
	else
		get_turflist()
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	for(var/datum/virtual_z/vz in daynight_v_lvls)
		if(!vz.active)
			continue

		if(!vz.daynight_turfs.len)
			continue

		if(world.time >= vz.next_firetime)
			advance_time(vz)
			update_lighting(vz, immediate = FALSE)

		if(MC_TICK_CHECK)
			return

/datum/subsystem/daynightcycle/proc/get_turflist()
	for(var/datum/virtual_z/v in daynight_v_lvls)
		if(!istype(v))
			continue

		for(var/turf/T in v.get_turfs())
			if(IsEven(T.x) && IsEven(T.y))
				var/area/A = get_area(T)
				if(isopensurface(A))
					v.daynight_turfs += T
				else
					for(var/cdir in cardinal)
						var/turf/T1 = get_step(T, cdir)
						var/area/A1 = get_area(T1)
						if(istype(A1, /area/surface))
							v.daynight_turfs += T
							break

/datum/subsystem/daynightcycle/proc/play_globalsound() //override in map files
	return


// Advances the time of day for a given virtual_z
/datum/subsystem/daynightcycle/proc/advance_time(var/datum/virtual_z/vz = null)
	if(!vz)
		return
	var/new_time
	var/duration
	switch(vz.current_timeOfDay)
		if(TOD_MORNING)
			new_time = TOD_SUNRISE
			duration = 3 MINUTES
			play_globalsound()
		if(TOD_SUNRISE)
			new_time = TOD_DAYTIME
			duration = 14 MINUTES
		if(TOD_DAYTIME)
			new_time = TOD_AFTERNOON
			duration = 15 MINUTES
		if(TOD_AFTERNOON)
			new_time = TOD_SUNSET
			duration = 3 MINUTES
		if(TOD_SUNSET)
			new_time = TOD_NIGHTTIME
			duration = 36 MINUTES
			play_globalsound()
		if(TOD_NIGHTTIME)
			new_time = TOD_MORNING
			duration = 5 MINUTES
	vz.current_timeOfDay = new_time
	vz.next_firetime = world.time + duration


// Updates lighting on each virtual_z
/datum/subsystem/daynightcycle/proc/update_lighting(var/datum/virtual_z/vz, var/immediate = TRUE)
	if(!vz?.daynight_turfs)
		return

	// Use the same light power calculation as global cycle
	vz.current_light_power = (vz.current_timeOfDay == TOD_NIGHTTIME) ? 3 : 10
	vz.current_light_power *= vz.weather_mod // Apply planet-specific weather modifier
	var/light_power = vz.current_light_power
	var/lowpriority = !immediate

	for(var/turf/T in vz.daynight_turfs)
		if(QDELETED(T))
			continue
		T.set_light(next_light_range, light_power, vz.current_timeOfDay, lowpriority)

// Force lighting change on a list of turfs (used mainly for when shuttles leave)
/datum/subsystem/daynightcycle/proc/update_turf_lighting(var/list/turf/turfs, var/datum/virtual_z/vz = null)
	if(!turfs.len || !vz)
		return

	var/timeOfDay = vz.current_timeOfDay
	var/light_power = vz.current_light_power

	for(var/turf/T in turfs)
		T.set_light(next_light_range, light_power, timeOfDay, lowpriority = FALSE)

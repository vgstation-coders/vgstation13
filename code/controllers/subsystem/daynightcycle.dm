var/datum/subsystem/daynightcycle/SSDayNight

var/list/daynight_turfs = list()
var/list/daynight_z_lvls = list()
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
	  The global cycle applies to all z-levels in this list EXCEPT map.zProcGen (planets have individual cycles).
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
	daynight_z_lvls += map.zProcGen
	if(!daynight_z_lvls.len)
		flags = SS_NO_INIT | SS_NO_FIRE
	get_turflist()
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	// Process global cycle (applies to all z-levels in daynight_z_lvls except zProcGen)
	if(world.time >= next_firetime)
		advance_time()
		update_global_lighting()

	// Process each planet's independent cycle
	for(var/datum/planet_type/planet in SSmapping.planets)
		if(!planet.daynight_turfs || !planet.daynight_turfs.len)
			continue

		if(world.time >= planet.next_firetime)
			advance_time(planet)
			update_planet_lighting(planet, immediate = FALSE)

		if(MC_TICK_CHECK)
			return

/**
 * Builds the global daynight_turfs list
 *
 * Scans all z-levels in daynight_z_lvls EXCEPT for map.zProcGen (which has planets with individual cycles)
 * and identifies turfs that should receive the global day/night cycle lighting.
 */
/datum/subsystem/daynightcycle/proc/get_turflist()
	for(var/z in daynight_z_lvls)
		// Skip the procgen z-level - planets have their own independent cycles
		if(z == map.zProcGen)
			continue

		for(var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(IsEven(T.x) && IsEven(T.y))
				var/area/A = get_area(T)
				if(isopensurface(A))
					daynight_turfs += T
				else
					for(var/cdir in cardinal)
						var/turf/T1 = get_step(T, cdir)
						var/area/A1 = get_area(T1)
						if(istype(A1, /area/surface))
							daynight_turfs += T
							break

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


/**
 * Advances time of day to the next phase
 *
 * If planet is provided, advances that planet's time. Otherwise, advances the global cycle.
 * The global cycle applies to all z-levels in daynight_z_lvls EXCEPT map.zProcGen.
 * Global sounds (rooster/wolf) only play when advancing the global cycle, not individual planets.
 * This function can be overridden in map.dm files for custom lighting schemes (like junglestation).
 *
 * Arguments:
 * * planet - Optional: The planet to advance time for. If null, advances the global cycle.
 */
/datum/subsystem/daynightcycle/proc/advance_time(var/datum/planet_type/planet = null)
	var/is_global = !planet
	var/old_time = is_global ? current_timeOfDay : planet.current_timeOfDay
	var/new_time
	var/duration
	switch(old_time)
		if(TOD_MORNING)
			new_time = TOD_SUNRISE
			duration = 3 MINUTES
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
		if(TOD_NIGHTTIME)
			new_time = TOD_MORNING
			duration = 5 MINUTES

	if(!planet)
		current_timeOfDay = new_time
		next_firetime = world.time + duration
		next_light_power = (new_time == TOD_NIGHTTIME) ? 3 : 10
		if(new_time == TOD_SUNRISE || new_time == TOD_NIGHTTIME)
			play_globalsound()
	else
		planet.current_timeOfDay = new_time
		planet.next_firetime = world.time + duration

/**
 * Updates lighting for all turfs in the global cycle
 *
 * Applies the current global time of day to all turfs in daynight_turfs
 * (all z-levels except zProcGen, which has planets with individual cycles).
 */
/datum/subsystem/daynightcycle/proc/update_global_lighting()
	if(!daynight_turfs || !daynight_turfs.len)
		return

	var/lowpriority = TRUE // Use low priority for regular cycle updates
	for(var/turf/T in daynight_turfs)
		if(!T || T.gcDestroyed)
			continue
		var/power = next_light_power * weather_mod
		T.set_light(next_light_range, power, current_timeOfDay, lowpriority)

/**
 * Forces an immediate lighting update for a specific planet
 *
 * Arguments:
 * * planet - The planet to update lighting for
 * * immediate - If TRUE, applies lighting immediately instead of queueing (default TRUE for instant updates)
 */
/datum/subsystem/daynightcycle/proc/update_planet_lighting(var/datum/planet_type/planet, var/immediate = TRUE)
	if(!planet || !planet.daynight_turfs)
		return

	// Use the same light power calculation as global cycle
	var/light_power = (planet.current_timeOfDay == TOD_NIGHTTIME) ? 3 : 10
	light_power *= planet.weather_mod // Apply planet-specific weather modifier
	var/lowpriority = !immediate

	for(var/turf/T in planet.daynight_turfs)
		if(!T || T.gcDestroyed)
			continue
		T.set_light(next_light_range, light_power, planet.current_timeOfDay, lowpriority)

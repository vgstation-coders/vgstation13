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

var/atom/movable/amblight_square/AMB_SQUARE = new()
/atom/movable/amblight_square
	icon = null
	color = "#FFFFFF"
	appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_LAYER|VIS_UNDERLAY
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	screen_loc = "1,1"

/atom/movable/amblight_overlay
	name = "white square of ambiance"
	icon = 'icons/effects/32x32.dmi'
	icon_state = "white"
	plane = MAP_EFX_PLANE
	appearance_flags = PIXEL_SCALE | TILE_BOUND | RESET_ALPHA | RESET_COLOR
	mouse_opacity = 0
/turf
	var/atom/movable/amblight_overlay/amblight_overlay

/datum/subsystem/daynightcycle
	name          = "Day Night Cycle"
	init_order    = SS_INIT_DAYNIGHT
	display_order = SS_DISPLAY_DAYNIGHT
	priority      = SS_PRIORITY_DAYNIGHT
	wait          = 2 SECONDS
/*
On the map dm file, redefine the following:
	- 'daynight_z_lvls' to change the zLevels that the day/night cycle applies to. Do not redefine if you want this subsystem disabled.
	- 'process_lighting()' to change the lighting scheme.
	- 'play_globalsound()' to change or disable the sound played at sunrise and sunset (if process_lighting() is unchanged).
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

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	if(!daynight_z_lvls.len)
		flags = SS_NO_INIT | SS_NO_FIRE
	AMB_SQUARE.filters += filter(type="layer", render_source=AMBLIGHT_RENDER_TARGET)
	get_turflist()
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(world.time >= next_firetime)
		process_ass()
		animate(AMB_SQUARE, color = current_timeOfDay, time = 2 SECONDS)


/datum/subsystem/daynightcycle/proc/get_turflist()
	for(var/z in daynight_z_lvls)
		for(var/turf/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			var/area/A = get_area(T)
			if(istype(A, /area/surface)) //If we are outside.
				daynight_turfs += T
				T.amblight_overlay = new()
				T.overlays += T.amblight_overlay

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


//Default lighting scheme; intitially purpose-built for Snaxi. Overwrite this proc in your map.dm file if you want to change the lighting scheme. See junglestation.dm for an example.
/datum/subsystem/daynightcycle/proc/process_ass()
	switch(current_timeOfDay) //Then set the next segment up.
		if(TOD_MORNING)
			current_timeOfDay = TOD_SUNRISE
			next_firetime = world.time + 2 SECONDS
			play_globalsound()
		if(TOD_SUNRISE)
			current_timeOfDay = TOD_DAYTIME
			next_firetime = world.time + 2 SECONDS
		if(TOD_DAYTIME)
			current_timeOfDay = TOD_AFTERNOON
			next_firetime = world.time + 2 SECONDS
		if(TOD_AFTERNOON)
			current_timeOfDay = TOD_SUNSET
			next_firetime = world.time + 2 SECONDS
		if(TOD_SUNSET)
			current_timeOfDay = TOD_NIGHTTIME
			next_light_power = 3
			next_firetime = world.time + 2 SECONDS
			play_globalsound()
		if(TOD_NIGHTTIME)
			current_timeOfDay = TOD_MORNING
			next_light_power = 10
			next_firetime = world.time + 2 SECONDS

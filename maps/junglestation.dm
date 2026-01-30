#ifndef MAP_OVERRIDE
//**************************************************************
// Map Datum -- Junglestation
//**************************************************************

/datum/map/active
	nameShort = "Jungle"
	nameLong = "Jungle Station"
	map_dir = "junglestation"

	zMainStation = 1
	zAdditionalStationZlevel = 2
	zCentcomm = 3
	zAsteroid = 4
	zDerelict = 5
	var/zSecondunderground=6

	zDeepSpace = -1
	zTCommSat = -1

	zLevels = list(
		/datum/zLevel/junglesurface,
		/datum/zLevel/jungleunderground,
		/datum/zLevel/centcomm,
		/datum/zLevel/junglesurface/mining,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		/datum/zLevel/jungleunderground,
		)
	enabled_jobs = list(/datum/job/trader)
	event_blacklist = list(/datum/event/radiation_storm,/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)
	load_map_elements = list(
	)

	skip_hobo_shack=TRUE
	can_enlarge=FALSE

	holomap_offset_x = list(80,80,0,86,4,0,0,)
	holomap_offset_y = list(50,50,0,94,10,0,0,)

	center_x = 182
	center_y = 163

/datum/map/active/New()
	..()
	//linking roid and station
	zLevels[zMainStation].transition_crosswrap_z=list(zAsteroid,zAsteroid,zAsteroid,zAsteroid)
	zLevels[zAsteroid].transition_crosswrap_z=list(zMainStation,zMainStation,zMainStation,zMainStation)
	//linking roid underground layer and station
	zLevels[zAdditionalStationZlevel].transition_crosswrap_z=list(zSecondunderground,zSecondunderground,zSecondunderground,zSecondunderground)
	zLevels[zSecondunderground].transition_crosswrap_z=list(zAdditionalStationZlevel,zAdditionalStationZlevel,zAdditionalStationZlevel,zAdditionalStationZlevel)
	world.name = "NT Colony Gamma-8"
	station_name="NT Colony Gamma-8"
	daynight_z_lvls=list(1,4)


/datum/map/active/map_specific_init()
	generate_mapvaults()
	//replace all the asteroid turfs that are generated randomly with the tunnel generation (i don't even know where) with the proper tiles.
	var/num_ass_replacments=0
	for(var/area/surface/jungle/mining/unexplored/A in areas)
		for(var/turf/unsimulated/floor/asteroid/T in A.contents)
			new /turf/unsimulated/floor/planetary/path/jungle(T)
			num_ass_replacments++
	world.log << "replaced [num_ass_replacments] asteroid tiles to be jungle."

//partially stolen from snaxi
/datum/map/active/generate_mapvaults()
	var/list/list_of_vaults = get_ruin_list(whitelist = RUIN_TYPE_JUNGLE)
	var/budget = RUIN_BUDGET_JUNGLE

	var/area/surface/jungle/roid/vaults/VAULT_AREA=locate(/area/surface/jungle/roid/vaults)
	if(!VAULT_AREA)
		message_admins("<span class='info'>Unable to find a suitable area to spawn vaults in, skipping surface vault generation!</span>")
		return 0

	var/placed_rand = populate_area_with_vaults(VAULT_AREA, list_of_vaults, -1, 1, filter_function=/proc/jungle_filter, overwrites=TRUE)
	message_admins("<span class='info'>placed [placed_rand] vaults in [VAULT_AREA]</span>")

	return placed_rand

/proc/jungle_filter(var/datum/map_element/E, var/turf/start_turf)
	var/list/dimensions = E.get_dimensions()
	var/result = check_surface_placement(start_turf,dimensions[1], dimensions[2])
	return result

/proc/check_surface_placement(var/turf/T,var/size_x,var/size_y,var/ignore_walls=0)
	var/list/surroundings = list()

	surroundings |= range(7, locate(T.x,T.y,T.z))
	surroundings |= range(7, locate(T.x+size_x,T.y,T.z))
	surroundings |= range(7, locate(T.x,T.y+size_y,T.z))
	surroundings |= range(7, locate(T.x+size_x,T.y+size_y,T.z))

	for(var/area/A in surroundings)
		if(!istype(A,/area/surface/jungle/roid/vaults))
			return 0
	for(var/turf/S in surroundings) //avoid nearby locations.
		if(S.type!=/turf/unsimulated/floor/planetary/grass/jungle)
			return 0
	return 1


/****************************
**	Day and Night Lighting **
**	See: daynightcycle.dm  **
****************************/

/datum/subsystem/daynightcycle
	overwrite_solars=TRUE
	solar_orbit_period=163.2948
	wait = 30 SECONDS
	var/solartime=0 //start at 0. set not like that for debugging. or manually set next_firetime with varedit.


/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(world.time >= next_firetime)
		if(lighting_update_lights_lowpriority.len) //prevent overwriting current lighting changes by not updating lighting until we're done.
			message_admins("day/night subsystem was fired, when there are still [lighting_update_lights_lowpriority.len] unprocessed lighting updates remaining. Is the server lagging, or was it force-fired? Delaying fire for 15 seconds...")
			next_firetime=world.time + 15 SECONDS
			return

		advance_time()
		if(!resumed)
			currentrun = daynight_turfs.Copy()

	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--

		if(!T || T.gcDestroyed)
			continue

		T.set_light(next_light_range,next_light_power,current_timeOfDay,TRUE)

		if(MC_TICK_CHECK)
			return

		if(!resumed)
			currentrun = daynight_turfs.Copy()


/datum/subsystem/daynightcycle/advance_time()
	flags&= ~SS_FIRE_IN_LOBBY //we don't want this one firing in lobby constantly, as we've tweaked the lighting to be just right on startup. we still want it to fire once though.
	// YCbCr is a superior colorspace. fight me.
	var/luma=0.0
	var/chroma_b=0.0
	var/chroma_r=0.0

	//orbit 1: fast, red dwarf:: roughly 33 minutes, red-orange colors.
	//this is the primary star we are orbiting, so it's fairly simple
	var/power_star_a=0.0 //these vars are for the solar panels to work properly
	var/angle_star_a=solartime*32.4-12.5
	var/power=((sin(angle_star_a)+1)/2)**2.25
	power_star_a=0.64*power
	//what the math is: makes a sine function that goes from 0-1 instead of -1 to 1. avoid max() because that creates hard cutoffs which don't look too good. we take it to the 2.25th power to make the transitions between day and night sharper, and to reduce the overall amount of daylight since we have 2 stars.
	luma+=0.64*power //red dwarves are weak stars.
	chroma_r+=0.70*power //they also would give off fuckhuge solar flares.
	chroma_b-=0.40*power // but that's a problem for silicons to deal with.

	//long-wave atmospheric absorption when the star is at a sharper angle (this is why sunsets are red)
	chroma_r+=0.2*(1-power)*power
	chroma_b-=0.3*(1-power)*power
	//what the math is: inverts the power first, because less power also means a sharper angle. then, multiply by power again, because we should only adjust it by the amount of light being given off.

	//orbit 2: slow, blue giant. more distant, but more power. i hope you brought sunscreen.
	var/power_star_b=0.0
	var/angle_star_b=solartime*11.023+6.918
	power=((sin(angle_star_b)+1)/2)**2.25 // about 117 minutes. a bit of offset, too.
	power_star_b=power
	luma+=power
	chroma_r-=0.20*power
	chroma_b+=0.70*power

	chroma_r+=0.2*(1-power)*power
	chroma_b-=0.3*(1-power)*power


	luma+=0.02 // minimum light level so it's not pitch black everywhere. atmospheric scattering would cause this.
	chroma_b-=0.1
	chroma_r+=0.04 // chroma shift so light appears a bit green to account for shortwave atmospheric absorption.


	//all numbers above this are completely arbitrary and are there to insure that the day/night cycle looks as cool as possible, meaning we have a lot of color variety and a satisfying progression between light and dark, and that it changes not too fast and not too slow. change them however you want.

	luma=luma**(1/2.2) //apply standard gamma correction

	//constants defined by ITU-R BT.2020
	var/r = luma + 1.659 * chroma_r
	var/g = luma - (0.396 * chroma_b) - (0.775 * chroma_r)
	var/b = luma + 2.034 * chroma_b

	/*
	why do this? because it makes brighter colors look better.
	Also, because it simulates bright light desaturating colors
	muh immulsions.
	*/
	for(var/n=0,n<3,n++) //3 smoothing passes seems good. This isn't particularly heavy math, anyways.
		if (r>1)
			var/redist=(r-1)
			redist*=0.1 //increasing this will make bright colors more washed out, lowering it makes the brightness more selective towards each color channel. that 255, 0, 0 light goes hard.
			r-=2*redist/3
			g+=redist/3
			b+=redist/3
		if (g>1)
			var/redist=(g-1)
			redist*=0.1
			g-=2*redist/3
			r+=redist/3
			b+=redist/3
		if (b>1)
			var/redist=(b-1)
			redist*=0.1
			b-=2*redist/3
			g+=redist/3
			r+=redist/3


	//clip to bounds
	r=min(r,1)
	g=min(g,1)
	b=min(b,1)

	//convert from 0-1 to 0-255
	r=floor(r*255)
	g=floor(g*255)
	b=floor(b*255)


	next_light_power=luma*7.5

	message_admins("Jungle day/night system beginning new phase at [world.time], cycle #[solartime], with light stats of [luma] [chroma_b] [chroma_r] -> [next_light_power] [r],[g],[b]")

	current_timeOfDay=rgb(r,g,b)

	//solar panel tracking code
	//now, to be frank, i have no fucking idea how to derive the proper angle, but i messed around in a graphing calculator, and this solution was not totally terrible.
	var/ad= (angle_star_a-angle_star_b+180)
	var/difference_between_star_angles=(ad-360*floor(ad/360)) -180 //equievent to modulo. but we can't use byond's modulo because it keeps the sign, but we don't want that.
	var/list/angle_choices=list( //this is not a good solution
		angle_star_a,
		angle_star_b,
		angle_star_a+(difference_between_star_angles/2),
		angle_star_a-(difference_between_star_angles/2),
		angle_star_b+(difference_between_star_angles/2),
		angle_star_b-(difference_between_star_angles/2),
	)
	var/bestangle=0.0 //fallback angle
	var/bestpower=0.0
	for(var/angle in angle_choices) //but it works. kinda. if you're better at math please make it better.
		var/pow=power_star_a*max(0,cos(angle_star_a-angle)-0.075)**1.5+power_star_b*max(0,cos(angle_star_b-angle)-0.075)**1.5
		if (pow>bestpower)
			bestpower=pow*1.25
			bestangle=angle-90 //offset by 90. we start at 0, which makes it start at -90 (270), making it to that the stars "rise" in the west, then set in the east.
	nearest_star_angle=bestangle%%360
	nearest_star_power=bestpower


	next_firetime=world.time + 5 MINUTES
	solartime++

/datum/subsystem/daynightcycle/play_globalsound()
	return


////////////////////////////////////////////////////////////////
#include "junglestation.dmm"
#endif

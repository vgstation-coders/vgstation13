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

	zDeepSpace = -1
	zTCommSat = -1

	zLevels = list(
		/datum/zLevel/junglesurface,
		/datum/zLevel/jungleunderground,
		/datum/zLevel/centcomm,
		/datum/zLevel/mining,
		/datum/zLevel/space{
			name = "derelict" ;
			},
		)
	enabled_jobs = list(/datum/job/trader)
	event_blacklist = list(/datum/event/radiation_storm,/datum/event/carp_migration,/datum/event/rogue_drone,/datum/event/immovable_rod,
						/datum/event/meteor_wave,/datum/event/meteor_shower,/datum/event/thing_storm/meaty_gore,/datum/event/thing_storm/blob_shower,
						/datum/event/thing_storm/blob_storm,/datum/event/thing_storm/fireworks)
	load_map_elements = list(
	)

	skip_hobo_shack=TRUE
	can_enlarge=FALSE

	holomap_offset_x = list(0,0,0,86,4,0,0,)
	holomap_offset_y = list(0,0,0,94,10,0,0,)

	center_x = 182
	center_y = 163

/datum/map/active/New()
	world.name = "NT Colony Gamma-8"
	station_name="NT Colony Gamma-8"

	daynight_z_lvls = list(zMainStation)

/****************************
**	Day and Night Lighting **
**	See: daynightcycle.dm  **
****************************/
/datum/subsystem/daynightcycle
	var/solartime=0 //start at 0. set not like that for debugging.

/datum/subsystem/daynightcycle/process_lighting()
	// YCbCr is a superior colorspace. fight me.
	var/luma=0.0
	var/chroma_b=0.0
	var/chroma_r=0.0

	//orbit 1: fast, red dwarf:: roughly 33 minutes, red-orange colors.
	//this is the primary star we are orbiting, so it's fairly simple
	var/power=max(0.0,sin(solartime*27.0))

	luma+=0.8*power //red dwarves are weak stars.
	chroma_r+=0.60*power //they also would give off fuckhuge solar flares.
	chroma_b-=0.25*power // but that's a problem for silicons to deal with.


	//orbit 2: slow, blue giant. more distant, but more power. i hope you brought sunscreen.
	power=max(0.0,sin(solartime*9.186+12.423)) // about 90 minutes. a bit of offset, too.
	luma+=1.25*power
	chroma_r-=0.20*power
	chroma_b+=0.75*power


	luma+=0.02 // minimum light level so it's not pitch black everywhere. atmospheric scattering would cause this.
	chroma_b-=0.05
	chroma_r+=0.04 // chroma shift so light appears a bit green to account for shortwave atmospheric absorption.


	luma=luma**(1/2.2) //apply gamma correction

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
			redist*=0.1
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

	r=min(r,1)
	g=min(g,1)
	b=min(b,1)

	//convert from 0-1 to 0-255
	r=floor(r*255)
	g=floor(g*255)
	b=floor(b*255)


	next_light_power=luma*7.5

	message_admins("Jungle day/night system beginning new phase at [world.time], cycle #[solartime], with light stats of [next_light_power]-[r],[g],[b]")

	current_timeOfDay=rgb(r,g,b)


	next_firetime=world.time + 5 MINUTES //station is too big to tick at 2 minutes. not without severe sever raep, at least.
	solartime++

/datum/subsystem/daynightcycle/play_globalsound()
	return

////////////////////////////////////////////////////////////////
#include "junglestation.dmm"
#endif

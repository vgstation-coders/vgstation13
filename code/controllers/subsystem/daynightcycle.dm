var/datum/subsystem/daynightcycle/SSDayNight
var/datum/subsystem/daynightcycle/SSDayNightJungle

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



//junglestation uses a different system, to simulate being nearby multiple stars.
/datum/subsystem/daynightcycle/jungle
	name          = "Jungle Day Night Cycle"
	var/solartime=0 //start at 0. set not like that for debugging.
	
/datum/subsystem/daynightcycle/jungle/New()
	NEW_SS_GLOBAL(SSDayNightJungle)	
	//solartime=rand(0,30) //add some variance

/datum/subsystem/daynightcycle/jungle/fire(resumed = FALSE)
	if(world.time >= next_firetime)
	
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
			
		if(!resumed)
			currentrun = daynight_turfs.Copy()

	while(currentrun.len)
		var/turf/T = currentrun[currentrun.len]
		currentrun.len--

		if(!T || T.gcDestroyed)
			continue

		T.set_light(next_light_range,next_light_power,current_timeOfDay,TRUE)

// MC_TICK_CHECK uses this (defined in __DEFINES/MC.dm):
// ( ( world.tick_usage > CURRENT_TICKLIMIT || src.state != SS_RUNNING ) ? pause() : 0 )
// now, the main issue is that if we use the tick limit, the server will stop executing things
// so, the solution is to create our own check, which gives leeway.
		if(MC_TICK_CHECK)
			return	

/datum/subsystem/daynightcycle/jungle/play_globalsound()
	return


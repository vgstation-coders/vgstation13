var/datum/subsystem/daynightcycle/SSDayNight

//#define TOD_MORNING 	"#4d6f86" Old Aesthetic Value
#define TOD_MORNING 	"#202e36"
//#define TOD_SUNRISE 	"#fdc5a0" Pretty but unneeded
#define TOD_DAYTIME 	"#FFFFFF"
#define TOD_AFTERNOON 	"#ffeedf"
//#define TOD_SUNSET 		"#75497e" Pretty but unneeded
#define TOD_NIGHTTIME	"#001927"
//#define TOD_NIGHTTIME 	"#002235" Old Aesthetic Value

/datum/subsystem/daynightcycle
	name          = "Day Night Cycle"
	init_order    = SS_INIT_DAYNIGHT
	display_order = SS_DISPLAY_DAYNIGHT
	priority      = SS_PRIORITY_DAYNIGHT
	wait          = 10 MINUTES
	flags         = SS_BACKGROUND|SS_FIRE_IN_LOBBY

	var/next_timeOfday = TOD_AFTERNOON
	var/next_light_power = 10
	var/next_light_range = 1

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	/*var/list/timestwopick = list(TOD_MORNING,
								TOD_SUNRISE,
								TOD_DAYTIME,
								TOD_AFTERNOON,
								TOD_SUNSET,
								TOD_NIGHTTIME)
	next_timeOfday = pick(timestwopick) RNG starter unneeded*/
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(!map.daynight_cycle)
		flags |= SS_NO_FIRE
		pause()
	else
		
		time2fire()
		
		switch(next_timeOfday)
			if(TOD_MORNING)
				next_light_power = 10
				next_light_power = 1
				next_timeOfday = TOD_DAYTIME
			if(TOD_DAYTIME)
				next_timeOfday = TOD_AFTERNOON
			if(TOD_AFTERNOON)
				next_light_power = 0
				next_light_range = 0
				next_timeOfday = TOD_NIGHTTIME
			if(TOD_NIGHTTIME)
				next_timeOfday = TOD_MORNING
		
/datum/subsystem/daynightcycle/proc/time2fire()
	if(next_light_power >= 1) //Theres no point to set lights if power isn't above a 0
		for(var/turf/T in block(locate(1, 1, map.daynight_cycle), locate(world.maxx, world.maxy, map.daynight_cycle)))
			if(IsEven(T.x)) //If we are also even.
				if(IsEven(T.y)) //If we are also even.
					var/area/A = get_area(T)
					if(istype(A, /area/surface)) //If we are outside.
						T.set_light(next_light_range,next_light_power,next_timeOfday)
					else //If We aren't we need to make sure we handle the outside segment
						for(var/cdir in cardinal)//Ironically, this part didn't work correctly but....
							var/turf/T1 = get_step(T,cdir)// It also ironically produced better looking day/night lighting
							var/area/A1 = get_area(T1)
							if(istype(A1, /area/surface)) //If we are outside.
								T1.set_light(next_light_range,next_light_power,next_timeOfday) //Set it, starlighto scanno
								break
							
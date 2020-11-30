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

	var/timeOfDay = TOD_AFTERNOON
	var/outside_light_power = 10
	var/outside_light_range = 1

/datum/subsystem/daynightcycle/New()
	NEW_SS_GLOBAL(SSDayNight)

/datum/subsystem/daynightcycle/Initialize()
	/*var/list/timestwopick = list(TOD_MORNING,
								TOD_SUNRISE,
								TOD_DAYTIME,
								TOD_AFTERNOON,
								TOD_SUNSET,
								TOD_NIGHTTIME)
	timeOfDay = pick(timestwopick) RNG starter unneeded*/
	..()

/datum/subsystem/daynightcycle/fire(resumed = FALSE)
	if(flags & SS_NO_FIRE)
		return
	if(!map.daynight_cycle)
		flags |= SS_NO_FIRE
		pause()
	else
		switch(timeOfDay)
			if(TOD_MORNING)
				timeOfDay = TOD_DAYTIME
			if(TOD_DAYTIME)
				timeOfDay = TOD_AFTERNOON
			if(TOD_AFTERNOON)
				timeOfDay = TOD_NIGHTTIME
			if(TOD_NIGHTTIME)
				timeOfDay = TOD_MORNING
		time2fire()

/datum/subsystem/daynightcycle/proc/time2fire()
	for(var/turf/T in block(locate(1, 1, 1), locate(world.maxx, world.maxy, 1)))
		if(IsEven(T.x)) //If we are also even.
			if(IsEven(T.y)) //If we are also even.
				if(istype(T, /turf/unsimulated/floor/snow)) //If we are outside.
					T.set_light(outside_light_range,outside_light_power,timeOfDay)
				else //If We aren't we need to make sure we handle the outside segment
					for(var/cdir in cardinal)//Ironically, this part didn't work correctly but....
						var/turf/T1 = get_step(T,cdir)// It also ironically produced better looking day/night lighting
						if(istype(T1, /turf/unsimulated/floor/snow)) //If we are outside.
							T1.set_light(outside_light_range,outside_light_power,timeOfDay) //Set it, starlighto scanno
							break
							
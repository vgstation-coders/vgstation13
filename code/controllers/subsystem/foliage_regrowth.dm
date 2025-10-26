var/datum/subsystem/foliage_regrow/SSFoliageRegrow

var/global/list/turf/turfs_to_regrow=null //set this to list() to make it start working

/datum/subsystem/foliage_regrow
	name          = "Foliage"
	init_order    = SS_INIT_FOLIAGE_REGROW
	display_order = SS_DISPLAY_FOLIAGE_REGROW
	priority      = SS_PRIORITY_FOLIAGE_REGROW
	wait          = 2 MINUTES
	var/next_firetime=0
	var/growth_chance=100 //percentage probability


/datum/subsystem/foliage_regrow/New()
	..()
	NEW_SS_GLOBAL(SSFoliageRegrow)

/datum/subsystem/foliage_regrow/Initialize()
	if(!turfs_to_regrow)
		flags = SS_NO_INIT | SS_NO_FIRE
	..()

//this is the meat and potatoes of the logic.
/datum/subsystem/foliage_regrow/proc/regrow_turf(var/turf/T)
	return TRUE
	
/datum/subsystem/foliage_regrow/fire(resumed = FALSE)
	if(world.time < next_firetime)
		return
	var/i=0

	while(i<turfs_to_regrow.len)
		if(MC_TICK_CHECK)
			break
		i++
		var/turf/T=turfs_to_regrow[i]//first in, last out
		if( prob(growth_chance))
			regrow_turf(T)
		else
			turfs_to_regrow+=T
	if(turfs_to_regrow.len && i)
		if (i==1 && turfs_to_regrow.len==1) //BYOND... for whatever reason, if there is 1 last member in the list, the list does not clear the element, and it keeps regrowing the same tile. this is unlikely to be noticed in a real game due to it being slow, but it's better to be safe.
			turfs_to_regrow.Cut(1,0)
		else
			turfs_to_regrow.Cut(1,i) 
	next_firetime=world.time +	wait



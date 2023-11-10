var/datum/subsystem/burnable/SSburnable
var/list/atom/burnableatoms = list()

/datum/subsystem/burnable
	name          = "Burnable"
	wait          = SS_WAIT_BURNABLE
	flags         = SS_KEEP_TIMING
	priority      = SS_PRIORITY_BURNABLE
	display_order = SS_DISPLAY_BURNABLE

	var/list/atom/currentrun
	var/currentrun_index

/datum/subsystem/burnable/New()
	NEW_SS_GLOBAL(SSburnable)
	currentrun = list()

/datum/subsystem/burnable/stat_entry(var/msg)
	if (msg)
		return ..()
	..("M:[burnableatoms.len]")

/datum/subsystem/burnable/stat_entry()
	..("P:[burnableatoms.len]")

/datum/subsystem/burnable/fire(var/resumed = FALSE)

	if(!resumed)
		currentrun_index = burnableatoms.len
		currentrun = burnableatoms.Copy()
	var/c = currentrun_index
	while(c)
		currentrun[c]?.checkburn()
		c--
		if (MC_TICK_CHECK)
			break
	currentrun_index = c

#define MINOXY2BURN (1 / CELL_VOLUME)
/atom/proc/checkburn()
	if(on_fire)
		var/datum/gas_mixture/G = return_air()
		if(!G || G.molar_density(GAS_OXYGEN) < MINOXY2BURN) //no oxygen so it goes out
			extinguish()
	else if(autoignition_temperature && isturf(loc))
		var/datum/gas_mixture/G = return_air()
		if(G && G.temperature >= autoignition_temperature && G.molar_density(GAS_OXYGEN) >= MINOXY2BURN)
			ignite()
#undef MINOXY2BURN
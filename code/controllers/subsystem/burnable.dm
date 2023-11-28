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

/atom/proc/checkburn()
	if(!on_fire && autoignition_temperature && (isturf(src) || isturf(loc)))
		if(can_ignite())
			var/datum/gas_mixture/G = return_air()
			if(air_based_ignitability_check(src, G))
				spawn((SS_WAIT_BURNABLE / 2) * rand()) //stagger it a bit so everything doesnt all burst into flames at once
					if(src && can_ignite() && !on_fire && air_based_ignitability_check(src, G))
						ignite()

#define MINOXY2BURN 0.2 * (MOLES_O2STANDARD / CELL_VOLUME) //1/5th of normal oxygen conditions

/proc/oxyscaled_ait(ait, omd) //oxygen-scaled autoignition temperature
	//returns approximately the value of the autoignition_temperature var at normal atmospheric conditions
	//but decreases (more readily combustible) with increased oxygen
	//arguments:
		//ait: base autoignition temperature (at standard station atmosphere)
		//omd: oxygen molar density

	//autoignition temperature scales inversely with molar oxygen content, up to halving at double the default oxygen content
		//based on doi: 10.1016/j.jlp.2019.103971

	if(omd < MINOXY2BURN)
		return INFINITY
	return ait / clamp(omd / (MOLES_O2STANDARD / CELL_VOLUME), 0.5, 2)

#undef MINOXY2BURN

/proc/air_based_ignitability_check(atom/A, datum/gas_mixture/G)
	if(G && G.temperature >= oxyscaled_ait(A.autoignition_temperature, G.molar_density(GAS_OXYGEN)))
		return TRUE


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

#define STD_OXY (MOLES_O2STANDARD / CELL_VOLUME)

/proc/oxyscaled_ait(ait, omd) //oxygen-scaled autoignition temperature
	//returns the value of the autoignition_temperature var at standard atmospheric conditions
	//but decreases (more readily ignitable) with increased oxygen
	//arguments:
		//ait: base autoignition temperature (in standard station atmosphere)
		//omd: oxygen molar density

	//autoignition temperature decreases with increasing molar oxygen content, at a 30% decrease in autoignition temperature at double the standard oxygen content, beyond which the effect is capped
		//based on doi: 10.1016/j.jlp.2019.103971

	if(omd < 0.2 * STD_OXY) //doesn't autoignite below 1/5th of standard oxygen conditions
		return INFINITY
	if(ait)
		return ait * (1 - (0.3 * min(1, (min(2, (1 / STD_OXY) * omd) - 1))))

#undef STD_OXY

/proc/air_based_ignitability_check(atom/A, datum/gas_mixture/G)
	if(G && G.temperature >= oxyscaled_ait(A.autoignition_temperature, G.molar_density(GAS_OXYGEN)))
		return TRUE


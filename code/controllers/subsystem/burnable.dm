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
	if(on_fire) //if an object is burning, spawn a fire effect on the tile
		var/in_fire = FALSE
		for(var/obj/effect/fire/F in loc)
			in_fire = TRUE
			break
		if(!in_fire)
			burnSolidFuel()
	else if(flammable) //if an object is not on fire, is flammable, and is in an environment with temperature above its autoignition temp & sufficient oxygen, ignite it
		if(thermal_mass <= 0)
			return
		var/datum/gas_mixture/G = return_air()
		if(G && (G.temperature >= autoignition_temperature) && ((G.molar_ratio(GAS_OXYGEN)) >= MINOXY2BURN))
			if(prob(50))
				ignite()

/obj/item/checkburn()
	if(!istype(loc, /turf)) //Prevent things from burning if worn, held, or inside something else. Storage containers will eject their contents when ignited, allowing for burning of the contents.
		return
	if(flammable && !on_fire)
		var/datum/gas_mixture/G = return_air()
		add_particles(PS_SMOKE)
		if(G && (G.temperature >= (autoignition_temperature * 0.75)))
			var/rate = clamp(lerp(G.temperature,autoignition_temperature * 0.75,autoignition_temperature,0.1,1),0.1,1)
			adjust_particles(PVAR_SPAWNING,rate,PS_SMOKE)
		else
			remove_particles(PS_SMOKE)
	..()

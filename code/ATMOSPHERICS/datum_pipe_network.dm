/datum/pipe_network
	var/list/datum/gas_mixture/gases = list() //All of the gas_mixtures continuously connected in this network

	var/list/obj/machinery/atmospherics/normal_members = list()
	var/list/datum/pipeline/line_members = list()
		//membership roster to go through for updates and what not

	var/update = 1
	var/datum/gas_mixture/air_transient = null
	var/datum/gas_mixture/radiate = null

/datum/pipe_network/New()

	air_transient = new()

	..()

/datum/pipeline/Del()
	pipe_networks -= src
	..()

/datum/pipe_network/Destroy()
	for(var/datum/pipeline/pipeline in line_members) //This will remove the pipeline references for us
		pipeline.network = null
	for(var/obj/machinery/atmospherics/objects in normal_members) //Procs for the different bases will remove the references
		objects.unassign_network(src)

/datum/pipe_network/resetVariables()
	..("gases", "normal_members", "line_members")
	gases = list()
	normal_members = list()
	line_members = list()

/datum/pipe_network/proc/process()
	//Equalize gases amongst pipe if called for
	if(update)
		update = 0
		reconcile_air() //equalize_gases(gases)
		radiate = null //Reset our last ticks calculation for the post-radiate() gases inside a thermal plate

#ifdef ATMOS_PIPELINE_PROCESSING
	//Give pipelines their process call for pressure checking and what not. Have to remove pressure checks for the time being as pipes dont radiate heat - Mport
	for(var/datum/pipeline/line_member in line_members)
		line_member.process()
#endif

/datum/pipe_network/proc/build_network(obj/machinery/atmospherics/start_normal, obj/machinery/atmospherics/reference)
	//Purpose: Generate membership roster
	//Notes: Assuming that members will add themselves to appropriate roster in network_expandz()

	if(!start_normal)
		returnToPool(src)
		return

	start_normal.network_expand(src, reference)

	update_network_gases()

	if((normal_members.len>0)||(line_members.len>0))
		pipe_networks |= src
	else
		returnToPool(src)
		return
	return 1

/datum/pipe_network/proc/merge(datum/pipe_network/giver)
	if(giver==src) return 0

	normal_members |= giver.normal_members

	line_members |= giver.line_members

	for(var/obj/machinery/atmospherics/normal_member in giver.normal_members)
		normal_member.reassign_network(giver, src)

	for(var/datum/pipeline/line_member in giver.line_members)
		line_member.network = src


	update_network_gases()
	return 1

/datum/pipe_network/proc/update_network_gases()
	//Go through membership roster and make sure gases is up to date

	gases = list()

	for(var/obj/machinery/atmospherics/normal_member in normal_members)
		var/result = normal_member.return_network_air(src)
		if(result) gases += result

	for(var/datum/pipeline/line_member in line_members)
		gases += line_member.air

/datum/pipe_network/proc/reconcile_air()
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	//air_transient.volume = 0
	var/air_transient_volume = 0

	air_transient.oxygen = 0
	air_transient.nitrogen = 0
	air_transient.toxins = 0
	air_transient.carbon_dioxide = 0


	air_transient.trace_gases = list()

	for(var/datum/gas_mixture/gas in gases)
		air_transient_volume += gas.volume
		var/temp_heatcap = gas.heat_capacity()
		total_thermal_energy += gas.temperature*temp_heatcap
		total_heat_capacity += temp_heatcap

		air_transient.oxygen += gas.oxygen
		air_transient.nitrogen += gas.nitrogen
		air_transient.toxins += gas.toxins
		air_transient.carbon_dioxide += gas.carbon_dioxide

		if(gas.trace_gases.len)
			for(var/datum/gas/trace_gas in gas.trace_gases)
				var/datum/gas/corresponding = locate(trace_gas.type) in air_transient.trace_gases
				if(!corresponding)
					corresponding = new trace_gas.type()
					air_transient.trace_gases += corresponding

				corresponding.moles += trace_gas.moles

	air_transient.volume = air_transient_volume

	if(air_transient_volume > 0)

		if(total_heat_capacity > 0)
			air_transient.temperature = total_thermal_energy/total_heat_capacity

			//Allow air mixture to react
			if(air_transient.react())
				update = 1

		else
			air_transient.temperature = 0

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas in gases)
			var/volume_ratio = gas.volume / air_transient.volume

			gas.oxygen = air_transient.oxygen * volume_ratio
			gas.nitrogen = air_transient.nitrogen * volume_ratio
			gas.toxins = air_transient.toxins * volume_ratio
			gas.carbon_dioxide = air_transient.carbon_dioxide * volume_ratio

			gas.temperature = air_transient.temperature

			if(air_transient.trace_gases.len)
				for(var/datum/gas/trace_gas in air_transient.trace_gases)
					var/datum/gas/corresponding = locate(trace_gas.type) in gas.trace_gases

					if(!corresponding)
						corresponding = new trace_gas.type()
						gas.trace_gases += corresponding

					corresponding.moles = trace_gas.moles * volume_ratio

			gas.update_values()

	air_transient.update_values()
	return 1

proc/equalize_gases(datum/gas_mixture/list/gases)
	//Perfectly equalize all gases members instantly

	//Calculate totals from individual components
	var/total_volume = 0
	var/total_thermal_energy = 0
	var/total_heat_capacity = 0

	var/total_oxygen = 0
	var/total_nitrogen = 0
	var/total_toxins = 0
	var/total_carbon_dioxide = 0

	var/list/total_trace_gases = list()

	for(var/datum/gas_mixture/gas in gases)
		total_volume += gas.volume
		var/temp_heatcap = gas.heat_capacity()
		total_thermal_energy += gas.temperature*temp_heatcap
		total_heat_capacity += temp_heatcap

		total_oxygen += gas.oxygen
		total_nitrogen += gas.nitrogen
		total_toxins += gas.toxins
		total_carbon_dioxide += gas.carbon_dioxide

		if(gas.trace_gases.len)
			for(var/datum/gas/trace_gas in gas.trace_gases)
				var/datum/gas/corresponding = locate(trace_gas.type) in total_trace_gases
				if(!corresponding)
					corresponding = new trace_gas.type()
					total_trace_gases += corresponding

				corresponding.moles += trace_gas.moles

	if(total_volume > 0)

		//Calculate temperature
		var/temperature = 0

		if(total_heat_capacity > 0)
			temperature = total_thermal_energy/total_heat_capacity

		//Update individual gas_mixtures by volume ratio
		for(var/datum/gas_mixture/gas in gases)
			gas.oxygen = total_oxygen*gas.volume/total_volume
			gas.nitrogen = total_nitrogen*gas.volume/total_volume
			gas.toxins = total_toxins*gas.volume/total_volume
			gas.carbon_dioxide = total_carbon_dioxide*gas.volume/total_volume

			gas.temperature = temperature

			if(total_trace_gases.len)
				for(var/datum/gas/trace_gas in total_trace_gases)
					var/datum/gas/corresponding = locate(trace_gas.type) in gas.trace_gases
					if(!corresponding)
						corresponding = new trace_gas.type()
						gas.trace_gases += corresponding

					corresponding.moles = trace_gas.moles*gas.volume/total_volume
			gas.update_values()

	return 1
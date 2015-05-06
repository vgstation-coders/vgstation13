/*

Overview:
	These are what handle gas transfers between zones and into space.
	They are found in a zone's edges list and in air_master.edges.
	Each edge updates every air tick due to their role in gas transfer.
	They come in two flavors, /connection_edge/zone and /connection_edge/unsimulated.
	As the type names might suggest, they handle inter-zone and spacelike connections respectively.

Class Vars:

	A - This always holds a zone. In unsimulated edges, it holds the only zone.

	connecting_turfs - This holds a list of connected turfs, mainly for the sake of airflow.

	coefficent - This is a marker for how many connections are on this edge. Used to determine the ratio of flow.

	connection_edge/zone

		B - This holds the second zone with which the first zone equalizes.

		direct - This counts the number of direct (i.e. with no doors) connections on this edge.
		         Any value of this is sufficient to make the zones mergeable.

	connection_edge/unsimulated

		B - This holds an unsimulated turf which has the gas values this edge is mimicing.

		air - Retrieved from B on creation and used as an argument for the legacy ShareSpace() proc.

Class Procs:

	add_connection(connection/c)
		Adds a connection to this edge. Usually increments the coefficient and adds a turf to connecting_turfs.

	remove_connection(connection/c)
		Removes a connection from this edge. This works even if c is not in the edge, so be careful.
		If the coefficient reaches zero as a result, the edge is erased.

	contains_zone(zone/Z)
		Returns true if either A or B is equal to Z. Unsimulated connections return true only on A.

	erase()
		Removes this connection from processing and zone edge lists.

	tick()
		Called every air tick on edges in the processing list. Equalizes gas.

	flow(list/movable, differential, repelled)
		Airflow proc causing all objects in movable to be checked against a pressure differential.
		If repelled is true, the objects move away from any turf in connecting_turfs, otherwise they approach.
		A check against vsc.lightest_airflow_pressure should generally be performed before calling this.

	get_connected_zone(zone/from)
		Helper proc that allows getting the other zone of an edge given one of them.
		Only on /connection_edge/zone, otherwise use A.

*/


/connection_edge/var/zone/A

/connection_edge/var/list/connecting_turfs = list()

/connection_edge/var/coefficient = 0

/connection_edge/New()
	CRASH("Cannot make connection edge without specifications.")

/connection_edge/proc/add_connection(connection/c)
	coefficient++
	//world << "Connection added: [type] Coefficient: [coefficient]"

/connection_edge/proc/remove_connection(connection/c)
	//world << "Connection removed: [type] Coefficient: [coefficient-1]"
	coefficient--
	if(coefficient <= 0)
		erase()

/connection_edge/proc/contains_zone(zone/Z)

/connection_edge/proc/erase()
	air_master.remove_edge(src)
	//world << "[type] Erased."

/connection_edge/proc/tick()

/connection_edge/proc/flow(list/movable, differential, repelled, flipped = 0)
	//Flipped tells us if we are going from A to B or from B to A.
	if(!zas_settings.Get(/datum/ZAS_Setting/airflow_push))
		return
	for(var/atom/movable/M in movable)
		if(!M.AirflowCanPush())
			continue
		//If they're already being tossed, don't do it again.
		if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay))
			continue
		if(M.airflow_speed)
			continue

		//Check for knocking people over
		if(ismob(M) && differential > zas_settings.Get(/datum/ZAS_Setting/airflow_stun_pressure))
			if(M:status_flags & GODMODE) continue
			M:airflow_stun()

		if(M.check_airflow_movable(differential))
			//Check for things that are in range of the midpoint turfs.
			var/list/close_turfs = list()
			for(var/turf/U in connecting_turfs)
				if(get_dist(M,U) < world.view)
					close_turfs += U
			if(!close_turfs.len)
				continue

			M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.

			if(M)
				if(repelled)
					if(flipped)
						if(!(M.loc in src:A.contents))
							continue
					else if(!(M.loc in src:B.contents))
						continue
					M.RepelAirflowDest(differential/5)
				else
					if(flipped)
						if(!(M.loc in src:B.contents))
							continue
					else if(!(M.loc in src:A.contents))
						continue
						M.GotoAirflowDest(differential/10)




/connection_edge/zone/var/zone/B
/connection_edge/zone/var/direct = 0

/connection_edge/zone/New(zone/A, zone/B)

	src.A = A
	src.B = B
	A.edges.Add(src)
	B.edges.Add(src)
	//id = edge_id(A,B)
	//world << "New edge between [A] and [B]"

/connection_edge/zone/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.A)
	if(c.direct()) direct++

/connection_edge/zone/remove_connection(connection/c)
	connecting_turfs.Remove(c.A)
	if(c.direct()) direct--
	. = ..()

/connection_edge/zone/contains_zone(zone/Z)
	return A == Z || B == Z

/connection_edge/zone/erase()
	A.edges.Remove(src)
	B.edges.Remove(src)
	. = ..()

/connection_edge/zone/tick()
	if(A.invalid || B.invalid)
		erase()
		return
	//world << "[id]: Tick [air_master.current_cycle]: \..."
	if(direct)
		if(air_master.equivalent_pressure(A, B))
			//world << "merged."
			erase()
			air_master.merge(A, B)
			//world << "zones merged."
			return

	//air_master.equalize(A, B)
	ShareRatio(A.air,B.air,coefficient)
	air_master.mark_zone_update(A)
	air_master.mark_zone_update(B)
	//world << "equalized."

	var/differential = A.air.pressure - B.air.pressure
	if(abs(differential) < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return

	var/list/attracted
	var/list/repelled
	var/flipped = 0
	if(differential > 0)
		attracted = A.movables()
		repelled = B.movables()
	else
		flipped = 1
		attracted = B.movables()
		repelled = A.movables()

	flow(attracted, abs(differential), 0, flipped)
	flow(repelled, abs(differential), 1, flipped)

//Helper proc to get connections for a zone.
/connection_edge/zone/proc/get_connected_zone(zone/from)
	if(A == from) return B
	else return A

/connection_edge/unsimulated/var/turf/B
/connection_edge/unsimulated/var/datum/gas_mixture/air

/connection_edge/unsimulated/New(zone/A, turf/B)
	src.A = A
	src.B = B
	A.edges.Add(src)
	air = B.return_air()
	//id = 52*A.id
	//world << "New edge from [A] to [B]."

/connection_edge/unsimulated/add_connection(connection/c)
	. = ..()
	connecting_turfs.Add(c.B)
	air.group_multiplier = coefficient

/connection_edge/unsimulated/remove_connection(connection/c)
	connecting_turfs.Remove(c.B)
	air.group_multiplier = coefficient
	. = ..()

/connection_edge/unsimulated/erase()
	A.edges.Remove(src)
	. = ..()

/connection_edge/unsimulated/contains_zone(zone/Z)
	return A == Z

/connection_edge/unsimulated/tick()
	if(A.invalid)
		erase()
		return
	//world << "[id]: Tick [air_master.current_cycle]: To [B]!"
	//A.air.mimic(B, coefficient)
	ShareSpace(A.air,air,dbg_out)
	air_master.mark_zone_update(A)

	var/differential = A.air.pressure - air.pressure
	if(abs(differential) < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return

	var/list/attracted = A.movables()
	flow(attracted, abs(differential), differential < 0)

var/list/sharing_lookup_table = list(0.30, 0.40, 0.48, 0.54, 0.60, 0.66)

proc/ShareRatio(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//Shares a specific ratio of gas between mixtures using simple weighted averages.

		//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD
	var/ratio = sharing_lookup_table[6]
		//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD

	var/A_full_heat_capacity = A.heat_capacity * A.group_multiplier

	var/B_full_heat_capacity = B.heat_capacity * B.group_multiplier

	var/temp_avg = (A.temperature * A_full_heat_capacity + B.temperature * B_full_heat_capacity) / (A_full_heat_capacity + B_full_heat_capacity)

	//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD
	if(sharing_lookup_table.len >= connecting_tiles) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[connecting_tiles]
	//WOOT WOOT TOUCH THIS AND YOU ARE A RETARD

	A.set_temperature((A.temperature - temp_avg) * (1-ratio) + temp_avg)

	B.set_temperature((B.temperature - temp_avg) * (1-ratio) + temp_avg)

	for(var/gasid in A.gases)
		var/A_moles = A.gases[gasid]
		var/B_moles = B.gases[gasid]
		var/avg_gas = (A_moles * A.group_multiplier + B_moles * B.group_multiplier) / (A.group_multiplier + B.group_multiplier)

		A.set_gas(gasid, avg_gas + ((A_moles - avg_gas) * (1 - ratio))) //we don't use adjust_gas because it interferes with the group multiplier
		B.set_gas(gasid, avg_gas + ((B_moles - avg_gas) * (1 - ratio)))

	return A.compare(B)

proc/ShareSpace(datum/gas_mixture/A, list/unsimulated_tiles, dbg_output)
	//A modified version of ShareRatio for spacing gas at the same rate as if it were going into a large airless room.
	if(!unsimulated_tiles)
		return 0

	var/datum/gas_mixture/unsim_mix = new

	var/tileslen
	var/size = A.group_multiplier
	var/share_size

	if(istype(unsimulated_tiles, /datum/gas_mixture))
		var/datum/gas_mixture/avg_unsim = unsimulated_tiles
		unsim_mix.copy_from(avg_unsim)
		share_size = max(1, max(size + 3, 1) + avg_unsim.group_multiplier)
		tileslen = avg_unsim.group_multiplier

		if(dbg_output)
			world << "O2: [unsim_mix.gases[OXYGEN]] N2: [unsim_mix.gases[NITROGEN]] Size: [share_size] Tiles: [tileslen]"

	else if(istype(unsimulated_tiles, /list))
		if(!unsimulated_tiles.len)
			return 0
		// We use the same size for the potentially single space tile
		// as we use for the entire room. Why is this?
		// Short answer: We do not want larger rooms to depressurize more
		// slowly than small rooms, preserving our good old "hollywood-style"
		// oh-shit effect when large rooms get breached, but still having small
		// rooms remain pressurized for long enough to make escape possible.
		share_size = max(1, max(size + 3, 1) + unsimulated_tiles.len)
		var/correction_ratio = share_size / unsimulated_tiles.len

		for(var/turf/T in unsimulated_tiles)
			unsim_mix.add(T.return_air())

		//These values require adjustment in order to properly represent a room of the specified size.
		unsim_mix.multiply(correction_ratio)
		tileslen = unsimulated_tiles.len

	else //invalid input type
		return 0

	var/ratio = sharing_lookup_table[6]

	var/old_pressure = A.pressure

	var/full_heat_capacity = A.heat_capacity * A.group_multiplier

	var/temp_avg = 0

	if((full_heat_capacity + unsim_mix.heat_capacity) > 0)
		temp_avg = (A.temperature * full_heat_capacity + unsim_mix.temperature * unsim_mix.heat_capacity) / (full_heat_capacity + unsim_mix.heat_capacity)

	if(sharing_lookup_table.len >= tileslen) //6 or more interconnecting tiles will max at 42% of air moved per tick.
		ratio = sharing_lookup_table[tileslen]

	if(dbg_output)
		world << "Ratio: [ratio]"
		//world << "Avg O2: [oxy_avg] N2: [nit_avg]"

	A.set_temperature(max(TCMB, (A.temperature - temp_avg) * (1 - ratio) + temp_avg ))

	for(var/gasid in A.gases)
		var/gas_moles = A.gases[gasid]
		var/avg_gas = (gas_moles + unsim_mix.gases[gasid]*share_size) / (size + share_size)
		A.set_gas(gasid, (gas_moles - avg_gas) * (1 - ratio) + avg_gas, 0 )

	if(dbg_output) world << "Result: [abs(old_pressure - A.pressure)] kPa"

	return abs(old_pressure - A.pressure)


proc/ShareHeat(datum/gas_mixture/A, datum/gas_mixture/B, connecting_tiles)
	//This implements a simplistic version of the Stefan-Boltzmann law.
	var/energy_delta = ((A.temperature - B.temperature) ** 4) * 5.6704e-8 * connecting_tiles * 2.5
	var/maximum_energy_delta = max(0, min(A.temperature * A.heat_capacity * A.group_multiplier, B.temperature * B.heat_capacity * B.group_multiplier))
	if(maximum_energy_delta > abs(energy_delta))
		if(energy_delta < 0)
			maximum_energy_delta *= -1
		energy_delta = maximum_energy_delta

	A.temperature -= energy_delta / (A.heat_capacity * A.group_multiplier)
	B.temperature += energy_delta / (B.heat_capacity * B.group_multiplier)
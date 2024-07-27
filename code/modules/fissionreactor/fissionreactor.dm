

/datum/fission_reactor_holder
	var/fuel_rods=list() //phase 0 vars, set upon construction
	var/control_rods=list()
	var/coolant_ports=list()
	var/heat_capacity=0
	var/fuel_reactivity=1
	var/fuel_rods_affected_by_rods=0
	
	var/coolantport_counter=0 // this varible exists to ensure that all coolant ports get treated equally, because if we didn't it would have a flow prefrence towards the ports with lower indexes.
	var/control_rod_insertion=1  //phase 1 vars. modified during runtime
	var/temp=0 //this is set last
	
	var/datum/gas_mixture/coolant

	
	var/zlevel=0 //positional varibles
	var/origin_x=0
	var/origin_y=0
	var/corner_x=0 //uses corner calculations. this is for the sake of being easier to calculate.
	var/corner_y=0
	var/datum/fission_fuel/fuel=null

	
/datum/fission_reactor_holder/New()
	..()
	update_dir()
	air_contents = new
	air_contents.temperature = T20C //vaguely room temp.
	air_contents.volume = 2500

/datum/fission_reactor_holder/proc/init_resize(var/turf/origin) //code responsible for setting up the parameters of the reactor.
	if(!origin) //something has gone wrong.
		return
	
	var/turf/wall_up=locate(origin.x,origin.y+1,origin.z)
	var/turf/wall_down=locate(origin.x,origin.y-1,origin.z)
	var/turf/wall_left=locate(origin.x-1,origin.y,origin.z)
	var/turf/wall_right=locate(origin.x+1,origin.y,origin.z)
	
	
	
/datum/fission_reactor_holder/proc/fissioncycle() //what makes the heat.
	if(!fuel)
		return
	var/totalpowerfactor=(reactivity*fuel_rods.len)-(reactivity*fuel_rods_affected_by_rods*control_rod_insertion) //multiplier for power output
	var/speedofuse=fuel_rods.len-(1.0-control_rod_insertion)*fuel_rods_affected_by_rods
	
	coolant.temperature+=totalpowerfactor*fuel.wattage/coolant.heat_capacity()
	if (fuel.lifetime>0) //god forbid we divide by 0.
		fuel.life-= (fuel.lifetime-speedofuse)/fuel.lifetime
		fuel.life=max(0,fuel.life)
	else
		fuel.life=0

/datum/fission_fuel
	var/datum/reagents/fuel= null
	var/life=1.0 //1.0 is full life, 0 is depleted. MAKE SURE it is always 0-1 or shit WILL go wrong.
	
	var/lifetime=0 //these are rederived when making a new one, so these can be whatever.
	var/wattage=0

/datum/fission_fuel/New()
	var/datum/reagents/fuel= new /datum/reagents //this probably isn't the best way to do things, but that's a problem for future me (someone else) to deal with.
	fuel.maximum_volume=150
	
/datum/fission_fuel/rederive_stats() //should be called whenever you change the materials
	if(!fuel)
		lifetime=0
		wattage=0
		return	
	var/thislifetime=0
	var/thiswattage=0	
	
	for(var/A in fuel)
		var/datum/reagent/R = A
		if (R.fission_time != null)
			thislifetime+=R.fission_time* (fuel.amount_cache[R.id] + 0)/(fuel.total_volume) //fuel time is a weighted average
		thiswattage+=fission_power

	lifetime=max(thislifetime,0)
	wattage=max(thiswattage,0)
	
/datum/fission_fuel/get_products()	//fission products.
	var/datum/reagents/products = new /datum/reagents
	products.maximum_volume=150
	if(!fuel)
		return products
	
	for(var/A in fuel)
		var/datum/reagent/R = A
		var/reagamt=fuel.amount_cache[R.id] //reagent amount.
		if (reagamt<=0) //skip reagents we don't have.
			continue
		var/fissionprods=R.irradiate()
		for(var/RID in fissionprods) //associative lists hurt my brain. don't think too hard about how they work, ok?
			var/RCT=fissionprods[RID]
			products.add_reagent(RID, reagamt*RCT*(1.0-fuel.life)) // we multiply the proportion of outputs by the amount of that fuel type, by the amount we actually processed.
		products.add_reagent(R.id, fuel.life*reagamt ) //add unspent fuel back.
			
	
	return products
	
	
	
/obj/machinery/atmospherics/unary/fissionreactor_coolantport
	name="fission reactor coolant port"
	var/datum/fission_reactor_holder/associated_reactor=null
	use_power = MACHINE_POWER_USE_NONE
	idle_power_usage = 0
	active_power_usage = 0

/obj/machinery/atmospherics/unary/fissionreactor_coolantport/proc/transfer_reactor() //transfer coolant from/to the reactor
	if(!associated_reactor)
		return
	var/pressure_coolant=air_contents.pressure
	var/pressure_reactor=associated_reactor.coolant.pressure
	
	var/pdiff=pressure_reactor-pressure_coolant
	if (pdiff<0) //flowing external->reactor
		pdiff*=-1 
		var/molestotransfer=  pdiff*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
		var/datum/gas_mixture/nu_mix=air_contents.remove(molestotransfer *.5) //we multiply by 1/2 because if we transfer the whole difference, then it'll just swap between the 2 bodies forever.
		associated_reactor.coolant.merge(nu_mix) 
	else //flowing reactor->external
		var/molestotransfer=  pdiff*associated_reactor.coolant.volume/(R_IDEAL_GAS_EQUATION*associated_reactor.coolant.temperature)
		var/datum/gas_mixture/nu_mix=associated_reactor.coolant.remove(molestotransfer *.5)
		air_contents.merge(nu_mix)
		
		
/obj/machinery/fissionreactor
	var/datum/fission_reactor_holder/associated_reactor=null
	name="fission reactor part"
	
/obj/machinery/fissionreactor/fissionreactor_controlrod
	name="fission reactor control rod assembly"
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod
	name="fission reactor control fuel assembly"	

/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_reactivity()
	var/adjacency_reactivity_bonus=1.0 //addative per neighbor. max of 4x this number.
	var/num_adjacent_fuel_rods=0
	
	return 1.0+num_adjacent_fuel_rods*adjacency_reactivity_bonus

/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_iscontrolled()
	return FALSE
	

/obj/structure/fission_reactor_case
	name="fission reactor casing"
	
	
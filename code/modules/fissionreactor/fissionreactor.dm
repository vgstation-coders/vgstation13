

/datum/fission_reactor_holder
	var/list/fuel_rods=list() //phase 0 vars, set upon construction
	var/list/control_rods=list()
	var/list/coolant_ports=list()
	var/list/casing_parts=list()
	var/heat_capacity=0
	var/fuel_reactivity=1
	var/fuel_rods_affected_by_rods=0
	
	var/coolantport_counter=0 // this varible exists to ensure that all coolant ports get treated equally, because if we didn't it would have a flow prefrence towards the ports with lower indexes.
	var/control_rod_insertion=1  //phase 1 vars. modified during runtime
	var/temperature=0 //this is set last
	
	var/datum/gas_mixture/coolant

	
	var/zlevel=0 //positional varibles
	var/origin_x=0
	var/origin_y=0
	var/corner_x=0 //uses corner calculations. this is for the sake of being easier to calculate.
	var/corner_y=0
	var/datum/fission_fuel/fuel=null

	
/datum/fission_reactor_holder/New()
	..()
	coolant = new /datum/gas_mixture
	coolant.temperature = T20C //vaguely room temp.
	coolant.volume = 2500

/datum/fission_reactor_holder/proc/init_resize(var/turf/origin) //code responsible for setting up the parameters of the reactor.
	if(!origin) //something has gone wrong.
		return
	
	var/turf/wall_up=locate(origin.x,origin.y+1,origin.z)
	var/turf/wall_down=locate(origin.x,origin.y-1,origin.z)
	var/turf/wall_left=locate(origin.x-1,origin.y,origin.z)
	var/turf/wall_right=locate(origin.x+1,origin.y,origin.z)
	
	var/directions=0
	
	//copy
	var/list/wc = wall_up.contents
	for (var/i=1,i<wc.len,i++)
		if(istype(wc[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
			directions|=NORTH
			break

	wc = wall_down.contents
	for (var/i=1,i<wc.len,i++)
		if(istype(wc[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
			directions|=SOUTH
			break

	wc = wall_left.contents
	for (var/i=1,i<wc.len,i++)
		if(istype(wc[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
			directions|=WEST
			break

	wc = wall_right.contents
	for (var/i=1,i<wc.len,i++)
		if(istype(wc[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
			directions|=EAST
			break
	//paste
	
	//abort if we have an invalid placment (not at a corner)
	if ( (directions & NORTH && directions & SOUTH) || (directions & EAST && directions & WEST)) //if there are walls on north+south/east+west, it is not in the right spot
		return
	if ( !(directions & (NORTH | SOUTH) ) || !(directions & (EAST | WEST) ) ) //if there is not a wall at north/south + east/west, it is not in the right spot
		return
		
	var/xs=0
	var/ys=0
	
	//get the lengths of the reactor.
	if(directions&WEST) //x-
		xs=-1
		while(TRUE) //it'll be fiiiiiiiine.	
			var/turf/turftosearch=locate(origin.x+xs-1,origin.y,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					xs--
					goto searchforanotherW
			break
			searchforanotherW: //i'm using goto because it's cool. and it helps avoid the use of a pointless flag var.
	if(directions&EAST) //x+
		xs=1
		while(TRUE)
			var/turf/turftosearch=locate(origin.x+xs+1,origin.y,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					xs++
					goto searchforanotherE
			break
			searchforanotherE: 
	if(directions&NORTH)//y+
		ys=1
		while(TRUE)
			var/turf/turftosearch=locate(origin.x,origin.y+ys+1,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					ys++
					goto searchforanotherN
			break
			searchforanotherN: 
	if(directions&SOUTH)//y-
		ys=-1
		while(TRUE)
			var/turf/turftosearch=locate(origin.x,origin.y+ys-1,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					ys--
					goto searchforanotherS
			break
			searchforanotherS: 
	
	//now we have to close the corners into a box.
	//we have this:
	// O
	// O
	// O
	// O
	// XOOOOO
	//but need to make it this
	// OOOOOO
	// O    O
	// O    O
	// O    O
	// XOOOOO
	
	if(directions&WEST)
		for (var/searchx=0,searchx>xs,searchx--) //hey at least this one isn't an infinite loop :)
			var/turf/turftosearch=locate(origin.x+searchx,origin.y+ys,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					goto correctobjW
			return  //return because the setup is invalid.
			correctobjW: //unless it's fine, in which case skip the return.
	if(directions&EAST)
		for (var/searchx=0,searchx<xs,searchx++)
			var/turf/turftosearch=locate(origin.x+searchx,origin.y+ys,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					goto correctobjE
			return
			correctobjE:
	if(directions&SOUTH)
		for (var/searchy=0,searchy>ys,searchy--)
			var/turf/turftosearch=locate(origin.x+xs,origin.y+searchy,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					goto correctobjS
			return
			correctobjS:
	if(directions&NORTH)
		for (var/searchy=0,searchy<ys,searchy++)
			var/turf/turftosearch=locate(origin.x+xs,origin.y+searchy,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
				if(istype(contents[i],/obj/machinery/fissionreactor) || /obj/machinery/atmospherics/unary/fissionreactor_coolantport )
					goto correctobjN
			return
			correctobjN:
	
	//horray, we have verified the case makes a box!
	
	origin_x=origin.x
	origin_y=origin.y
	zlevel=origin.z
	corner_x=origin.x+xs
	corner_y=origin.y+ys

	var/sizex=abs(corner_x-origin_x)
	var/sizey=abs(corner_y-origin_y)

	coolant.volume=2500* (sizex-2)*(sizey-2) //sub 2 to make sure there's no casing involved in the internal volume.
	coolant.volume=max(coolant.volume,1) //atmos code will probably shit itself if this is 0.

	heat_capacity=sizex*sizey*1000 // this scales with area as well.
	
/datum/fission_reactor_holder/proc/clear_parts() 
	for (var/i=1,i<casing_parts.len,i++)
		casing_parts[i].associated_reactor=null
	casing_parts=list()
	
	for (var/i=1,i<coolant_ports.len,i++)
		coolant_ports[i].associated_reactor=null
	coolant_ports=list()
	
	for (var/i=1,i<control_rods.len,i++)
		control_rods[i].associated_reactor=null
	control_rods=list()
	
	for (var/i=1,i<fuel_rods.len,i++)
		fuel_rods[i].associated_reactor=null
	fuel_rods=list()
	
	fuel_reactivity=0
	fuel_rods_affected_by_rods=0

/datum/fission_reactor_holder/proc/init_parts() //this assigns the reactor to the parts and vice versa
	clear_parts()
	for (var/y=min(origin_y,corner_y), y<max(origin_y,corner_y),y++ )
		for (var/x=min(origin_x,corner_x), x<max(origin_x,corner_x),x++ )
			var/turf/turftosearch=locate(origin_x+x,origin_y+y,zlevel)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<contents.len,i++)
					
				if(istype(contents[i], /obj/machinery/fissionreactor )) //look, i don't like all the copy paste either.
					var/obj/machinery/fissionreactor/this_thing=contents[i]
					this_thing.associated_reactor=src
					casing_parts.Add(this_thing)
					break
				if(istype(contents[i], /obj/machinery/atmospherics/unary/fissionreactor_coolantport )) //but these are different subtypes
					var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/this_thing=contents[i]
					this_thing.associated_reactor=src
					coolant_ports.Add(this_thing)
					break
				if(istype(contents[i], /obj/machinery/fissionreactor/fissionreactor_controlrod )) //so we kind of have to snowflake it to hell
					var/obj/machinery/fissionreactor/fissionreactor_controlrod/this_thing=contents[i]
					this_thing.associated_reactor=src
					control_rods.Add(this_thing)
					break
				if(istype(contents[i], /obj/machinery/fissionreactor/fissionreactor_fuelrod ))
					var/obj/machinery/fissionreactor/fissionreactor_fuelrod/this_thing=contents[i]
					this_thing.associated_reactor=src
					fuel_rods.Add(this_thing)
					break
	
	for (var/i=1,i<fuel_rods.len,i++)
		fuel_reactivity+=fuel_rods[i].get_reactivity()
		fuel_rods_affected_by_rods+=fuel_rods[i].get_iscontrolled() ? 1 : 0
	fuel_reactivity/=fuel_rods.len //average them out.
	
/datum/fission_reactor_holder/proc/fissioncycle() //what makes the heat.
	if(!fuel)
		return
	var/totalpowerfactor=(fuel_reactivity*fuel_rods.len)-(fuel_reactivity*fuel_rods_affected_by_rods*control_rod_insertion) //multiplier for power output
	var/speedofuse=fuel_rods.len-(1.0-control_rod_insertion)*fuel_rods_affected_by_rods
	
	temperature+=totalpowerfactor*fuel.wattage/heat_capacity
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
	
/datum/fission_fuel/proc/rederive_stats() //should be called whenever you change the materials
	if(!fuel)
		lifetime=0
		wattage=0
		return	
	var/thislifetime=0
	var/thiswattage=0	
	
	for(var/datum/reagent/R in fuel.reagent_list)
		if (R.fission_time != null)
			thislifetime+=R.fission_time* (fuel.amount_cache[R.id] + 0)/(fuel.total_volume) //fuel time is a weighted average
		thiswattage+=R.fission_power

	lifetime=max(thislifetime,0)
	wattage=max(thiswattage,0)
	
/datum/fission_fuel/proc/get_products()	//fission products.
	var/datum/reagents/products = new /datum/reagents
	products.maximum_volume=150
	if(!fuel)
		return products
	
	for(var/datum/reagent/R in fuel.reagent_list)
		var/reagamt=fuel.amount_cache[R.id] //reagent amount.
		if (reagamt<=0) //skip reagents we don't have.
			continue
		var/fissionprods=R.irradiate()
		for(var/RID in fissionprods) //associative lists hurt my brain. don't think too hard about how they work, ok?
			var/RCT=fissionprods[RID]
			products.add_reagent(RID, reagamt*RCT*(1.0-life)) // we multiply the proportion of outputs by the amount of that fuel type, by the amount we actually processed.
		products.add_reagent(R.id, life*reagamt ) //add unspent fuel back.
			
	
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
		var/datum/gas_mixture/nu_mix=air_contents.remove(molestotransfer *0.5) //we multiply by 1/2 because if we transfer the whole difference, then it'll just swap between the 2 bodies forever.
		associated_reactor.coolant.merge(nu_mix) 
	else //flowing reactor->external
		var/molestotransfer=  pdiff*associated_reactor.coolant.volume/(R_IDEAL_GAS_EQUATION*associated_reactor.coolant.temperature)
		var/datum/gas_mixture/nu_mix=associated_reactor.coolant.remove(molestotransfer *0.5)
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
	var/list/lofrds=associated_reactor.fuel_rods
	for (var/i=1,i<lofrds.len,i++) //probably not the most efficent way... but it works well enough
		if (lofrds[i].loc.y==src.loc.y)
			if (lofrds[i].loc.y==src.loc.y+1 || lofrds[i].loc.y==src.loc.y-1)
				num_adjacent_fuel_rods++
		if (lofrds[i].loc.x==src.loc.x)
			if (lofrds[i].loc.x==src.loc.x+1 || lofrds[i].loc.x==src.loc.x-1)
				num_adjacent_fuel_rods++
	
	return 1.0+num_adjacent_fuel_rods*adjacency_reactivity_bonus

/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_iscontrolled()
	var/list/lofrds=associated_reactor.control_rods
	for (var/i=1,i<lofrds.len,i++)
		if ((lofrds[i].loc.x-src.loc.x)^2<=1 &&  (lofrds[i].loc.y-src.loc.y)^2<=1  ) //ensure it's within 1 tile
			return TRUE
	return FALSE
	

/obj/structure/fission_reactor_case
	var/datum/fission_reactor_holder/associated_reactor=null
	name="fission reactor casing"
	


//because radon is a gas, we need to interface with gasses. yeah, this kind of sucks, but what are you gonna do? (inb4 make better code lol)
/obj/machinery/atmospherics/unary/fissionfuelmaker
	name="isotopic separational combiner." //just about the most technobable you could get.
	var/datum/reagents/held_elements=new /datum/reagents
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 25
	active_power_usage = 100

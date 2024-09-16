/*
IN THIS FILE:
datums for the fission reactor, which includes the fuel and reactor
*/
#define FISSIONREACTOR_MELTDOWNTEMP 5500 //temp when shit goes wrong
#define FISSIONREACTOR_DANGERTEMP 4500 //temp to start warning you and to SCRAM

/datum/fission_reactor_holder
	var/list/fuel_rods=list() //phase 0 vars, set upon construction
	var/list/control_rods=list()
	var/list/coolant_ports=list()
	var/list/casing_parts=list()
	var/heat_capacity=0
	var/fuel_reactivity=1
	var/fuel_reactivity_with_rods=0
	var/fuel_rods_affected_by_rods=0
	
	var/coolantport_counter=0 // this varible exists to ensure that all coolant ports get treated equally, because if we didn't it would have a flow prefrence towards the ports with lower indexes.
	var/control_rod_insertion=1  //phase 1 vars. modified during runtime
	var/SCRAM=FALSE //all caps because AAAAAAAAAAAAAAAAAAA EVERYBODY PANIC WE'RE ALL GONNA DIE.
	var/temperature=T20C //this is set last
	
	var/datum/gas_mixture/coolant

	var/graceperiodtick=FALSE // set to true when we hit meltdown temp. gives you a bit of time to GTFO or save it. this will result in peak kino (i hope)
	
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

/datum/fission_reactor_holder/proc/considered_on()
	if(!fuel) //no fuel? not on.
		return FALSE
	if(fuel.life<=0.0) //depleted? not on.
		return FALSE
	if(control_rod_insertion>=1.0 && fuel_rods_affected_by_rods==fuel_rods.len ) //if the reaction is halted, it's not on.
		return FALSE
	return TRUE //otherwise, it is.

/datum/fission_reactor_holder/proc/init_resize(var/turf/origin) //code responsible for setting up the parameters of the reactor.
	if(!origin) //something has gone wrong.
		return "unable to locate self"
	
	var/turf/wall_up=get_step(origin,NORTH) //locate(origin.x,origin.y+1,origin.z)
	var/turf/wall_down=get_step(origin,SOUTH)
	var/turf/wall_left=get_step(origin,WEST)
	var/turf/wall_right=get_step(origin,EAST)
	
	var/directions=0
	
	//copy
	world.log << "checking..."
	var/list/wc = wall_up.contents
	for (var/i=1,i<=wc.len,i++)
		world.log << "N - [wc[i]]"
		if(istype(wc[i],/obj/structure/fission_reactor_case) || istype(wc[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
			directions|=NORTH
			world.log << "found N"
			break

	wc = wall_down.contents
	for (var/i=1,i<=wc.len,i++)
		if(istype(wc[i],/obj/structure/fission_reactor_case) || istype(wc[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
			directions|=SOUTH
			world.log << "found S"
			break

	wc = wall_left.contents
	for (var/i=1,i<=wc.len,i++)
		if(istype(wc[i],/obj/structure/fission_reactor_case) || istype(wc[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
			directions|=WEST
			world.log << "found W"
			break

	wc = wall_right.contents
	for (var/i=1,i<=wc.len,i++)
		if(istype(wc[i],/obj/structure/fission_reactor_case) || istype(wc[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
			directions|=EAST
			world.log << "found E"
			break
	//paste
	
	//abort if we have an invalid placment (not at a corner)
	if ( ((directions & NORTH) && (directions & SOUTH)) || ((directions & EAST) && (directions & WEST))) //if there are walls on north+south/east+west, it is not in the right spot
		return "reactor controller should be placed in a corner, not a side."
	if ( !(directions & (NORTH | SOUTH) ) || !(directions & (EAST | WEST) ) ) //if there is not a wall at north/south + east/west, it is not in the right spot
		return "reactor controller should be placed in a corner, not on an edge."
		
	var/xs=0
	var/ys=0
	
	//get the lengths of the reactor.
	if(directions&WEST) //x-
		xs=-1
		while(TRUE) //it'll be fiiiiiiiine.	
			var/turf/turftosearch=locate(origin.x+xs-1,origin.y,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					xs--
					goto searchforanotherW
			break
			searchforanotherW: //i'm using goto because it's cool. and it helps avoid the use of a pointless flag var.
	if(directions&EAST) //x+
		xs=1
		while(TRUE)
			var/turf/turftosearch=locate(origin.x+xs+1,origin.y,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					xs++
					goto searchforanotherE
			break
			searchforanotherE: 
	if(directions&NORTH)//y+
		ys=1
		while(TRUE)
			var/turf/turftosearch=locate(origin.x,origin.y+ys+1,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					ys++
					goto searchforanotherN
			break
			searchforanotherN: 
	if(directions&SOUTH)//y-
		ys=-1
		while(TRUE)
			var/turf/turftosearch=locate(origin.x,origin.y+ys-1,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
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
		for (var/searchx=0,searchx>=xs,searchx--) //hey at least this one isn't an infinite loop :)
			var/turf/turftosearch=locate(origin.x+searchx,origin.y+ys,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					goto correctobjW
			return  "failed to find casing at offset [searchx],[ys]" //return because the setup is invalid.
			correctobjW: //unless it's fine, in which case skip the return.
	if(directions&EAST)
		for (var/searchx=0,searchx<=xs,searchx++)
			var/turf/turftosearch=locate(origin.x+searchx,origin.y+ys,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					goto correctobjE
			return "failed to find casing at offset [searchx],[ys]"
			correctobjE:
	if(directions&SOUTH)
		for (var/searchy=0,searchy>=ys,searchy--)
			var/turf/turftosearch=locate(origin.x+xs,origin.y+searchy,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					goto correctobjS
			return "failed to find casing at offset [xs],[searchy]"
			correctobjS:
	if(directions&NORTH)
		for (var/searchy=0,searchy<=ys,searchy++)
			var/turf/turftosearch=locate(origin.x+xs,origin.y+searchy,origin.z)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
				if(istype(contents[i],/obj/structure/fission_reactor_case) || istype(contents[i],/obj/machinery/atmospherics/unary/fissionreactor_coolantport) )
					goto correctobjN
			return "failed to find casing at offset [xs],[searchy]"
			correctobjN:
	
	//horray, we have verified the case makes a box!
	
	origin_x=origin.x
	origin_y=origin.y
	zlevel=origin.z
	corner_x=origin.x+xs
	corner_y=origin.y+ys

	var/sizex=abs(corner_x-origin_x)+1
	var/sizey=abs(corner_y-origin_y)+1

	coolant.volume=2500* (sizex-2)*(sizey-2) //sub 2 to make sure there's no casing involved in the internal volume.
	coolant.volume=max(coolant.volume,1) //atmos code will probably shit itself if this is 0.

	heat_capacity=sizex*sizey*1000 // this scales with area as well.
	return null
	
/datum/fission_reactor_holder/proc/clear_parts() 
	for (var/i=1,i<=casing_parts.len,i++)
		casing_parts[i].associated_reactor=null
	casing_parts=list()
	
	for (var/i=1,i<=coolant_ports.len,i++)
		coolant_ports[i].associated_reactor=null
	coolant_ports=list()
	
	for (var/i=1,i<=control_rods.len,i++)
		control_rods[i].associated_reactor=null
	control_rods=list()
	
	for (var/i=1,i<=fuel_rods.len,i++)
		fuel_rods[i].associated_reactor=null
	fuel_rods=list()
	
	fuel_reactivity=0
	fuel_rods_affected_by_rods=0
	fuel_reactivity_with_rods=0

/datum/fission_reactor_holder/proc/init_parts() //this assigns the reactor to the parts and vice versa
	clear_parts()
	for (var/y=min(origin_y,corner_y), y<=max(origin_y,corner_y),y++ )
		for (var/x=min(origin_x,corner_x), x<=max(origin_x,corner_x),x++ )
			var/turf/turftosearch=locate(x,y,zlevel)//locate(origin_x+x,origin_y+y,zlevel)
			var/list/contents = turftosearch.contents
			for (var/i=1,i<=contents.len,i++)
					
				if(istype(contents[i], /obj/structure/fission_reactor_case )) //look, i don't like all the copy paste either.
					var/obj/structure/fission_reactor_case/this_thing=contents[i]
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
	
	for (var/i=1,i<=control_rods.len,i++)
		control_rods[i].update_icon()

	for (var/i=1,i<=fuel_rods.len,i++)
		fuel_rods[i].update_icon()
		fuel_reactivity+=fuel_rods[i].get_reactivity()
		fuel_reactivity_with_rods+=fuel_rods[i].get_iscontrolled() ? fuel_rods[i].get_reactivity() : 0
		fuel_rods_affected_by_rods+=fuel_rods[i].get_iscontrolled() ? 1 : 0
	fuel_reactivity/=fuel_rods.len //average them out.
	fuel_reactivity_with_rods/=fuel_rods.len
	
	
/datum/fission_reactor_holder/proc/update_all_icos()
	for (var/i=1,i<=control_rods.len,i++)
		control_rods[i].update_icon()
		
	for (var/i=1,i<=fuel_rods.len,i++)
		fuel_rods[i].update_icon()
	
/datum/fission_reactor_holder/proc/fissioncycle() //what makes the heat.

	if(!fuel)
		return
	if(fuel.life<=0)
		return
	if(fuel.wattage<=0)
		return
		
	var/speedfactor=fuel_rods.len - (fuel_rods_affected_by_rods*control_rod_insertion)
	var/powerfactor=(fuel_reactivity*fuel_rods.len) - (fuel_reactivity_with_rods*control_rod_insertion)
	

	var/totalpowertodump=0
	if(fuel.wattage < fuel.absorbance) //slow down the reaction if there's not enuff powah
		totalpowertodump=0
		speedfactor*=(fuel.absorbance-fuel.wattage)/fuel.wattage
	else
		totalpowertodump=fuel.wattage-fuel.absorbance
	

	if (fuel.lifetime>0)
		fuel.life-= (2*speedfactor)/fuel.lifetime //multiply this by 2 because it ticks every 2 seconds
		fuel.life=max(0,fuel.life)
	else
		fuel.life=0
		return
	
	temperature+=totalpowertodump*powerfactor/heat_capacity
	

	
	if(temperature>=FISSIONREACTOR_MELTDOWNTEMP)
		if(graceperiodtick)
			//TODO: FSU when it gets too hot
			world.log << "kabooom!"
		graceperiodtick=TRUE
	else
		graceperiodtick=FALSE
	
	
/datum/fission_reactor_holder/proc/coolantcycle()
	for(var/i=1, i<=coolant_ports.len,i++)
		var/real_index= ((i+coolantport_counter)%coolant_ports.len)+1 //this way we spread out any first index prefrence.
		var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/coolant_port=coolant_ports[real_index]
		coolant_port.transfer_reactor()
		
	coolantport_counter++
	coolantport_counter=(coolantport_counter%coolant_ports.len)+1 //shift it around.	
	
	var/chp=coolant.heat_capacity()
	
	//unrealistically, the heat transfer is 100% between the 2 sources.
	//too bad.
	var/newtemp=(chp*coolant.temperature + heat_capacity*temperature)/(chp+heat_capacity)
	coolant.temperature=newtemp
	temperature=newtemp
	
	
	
	
	

/datum/fission_fuel
	var/datum/reagents/fuel= null
	var/life=1.0 //1.0 is full life, 0 is depleted. MAKE SURE it is always 0-1 or shit WILL go wrong.
	
	//these are rederived when making a new one, so these can be whatever.
	var/lifetime=0  //time in seconds that the fuel will burn for at base.
	var/wattage=0 // heat which will be added.
	var/absorbance=0 //subtraced from above to get total emission.

/datum/fission_fuel/New()
	var/datum/reagents/fuel= new /datum/reagents //this probably isn't the best way to do things, but that's a problem for future me (someone else) to deal with.
	fuel.maximum_volume=150
	
/datum/fission_fuel/proc/rederive_stats() //should be called whenever you change the materials
	if(!fuel)
		lifetime=0
		wattage=0
		absorbance=0
		return	
	var/thislifetime=0
	var/thiswattage=0	
	var/thisabsorbance=0
	
	for(var/datum/reagent/R in fuel.reagent_list)
		if (R.fission_time != null)
			thislifetime+=R.fission_time* (fuel.amount_cache[R.id] + 0)/(fuel.total_volume) //fuel time is a weighted average
		thiswattage+=R.fission_power
		thisabsorbance+=R.fission_absorbtion

	lifetime=max(thislifetime,0)
	wattage=max(thiswattage,0)
	absorbance=max(thisabsorbance,0)
	
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

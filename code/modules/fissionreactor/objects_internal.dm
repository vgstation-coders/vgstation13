/*
IN THIS FILE:
objects that make up the interior (inside) of the reactor.
included:
	control rods
	fuel rods (machine)
*/

/obj/machinery/fissionreactor
	var/datum/fission_reactor_holder/associated_reactor=null
	name="fission reactor part"
	
/obj/machinery/fissionreactor/fissionreactor_controlrod
	name="fission reactor control rod assembly"
	
/obj/machinery/fissionreactor/fissionreactor_fuelrod
	name="fission reactor fuel rod assembly"	

/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_reactivity()
	var/adjacency_reactivity_bonus=1.0 //addative per neighbor. max of 4x this number.
	var/num_adjacent_fuel_rods=0
	var/list/lofrds=associated_reactor.fuel_rods
	for (var/obj/machinery/fissionreactor/fissionreactor_fuelrod/fuel_rod in lofrds) //probably not the most efficent way... but it works well enough
		if (fuel_rod.loc.y==src.loc.y)
			if (fuel_rod.loc.y==src.loc.y+1 || fuel_rod.loc.y==src.loc.y-1)
				num_adjacent_fuel_rods++
		if (fuel_rod.loc.x==src.loc.x)
			if (fuel_rod.loc.x==src.loc.x+1 || fuel_rod.loc.x==src.loc.x-1)
				num_adjacent_fuel_rods++
	
	return 1.0+num_adjacent_fuel_rods*adjacency_reactivity_bonus

/obj/machinery/fissionreactor/fissionreactor_fuelrod/proc/get_iscontrolled()
	var/list/lofrds=associated_reactor.control_rods
	for (var/obj/machinery/fissionreactor/fissionreactor_controlrod/control_rod in  lofrds)
		if ((control_rod.loc.x-src.loc.x)**2<=1 &&  (control_rod.loc.y-src.loc.y)**2<=1  ) //ensure it's within 1 tile
			return TRUE
	return FALSE
	
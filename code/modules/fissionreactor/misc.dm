/*
in this file:
boxes used for cargo orders to make my life easier.
other cargo stuff related to reactors
*/



/obj/item/weapon/storage/box/fissionsupply_controller
	name="fission reactor controller parts"
	desc="Contains all the materials needed to assemble a fission reactor controller."

/obj/item/weapon/storage/box/fissionsupply_controller/attack_self(mob/user)
	for(var/obj/O in contents)
		O.forceMove(user.loc)
	contents=null
	..()
	
/obj/item/weapon/storage/box/fissionsupply_controller/New()
	..()
	new /obj/item/weapon/circuitboard/fission_reactor(src)
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/manipulator(src)
	new /obj/item/weapon/stock_parts/console_screen(src)
	new /obj/item/stack/rods(src,2)//2 rods
	new /obj/item/stack/sheet/plasteel(src,5)//5 plasteel
	new /obj/item/stack/cable_coil(src,5)//5 wire


/obj/item/weapon/storage/box/fissionsupply_genericassembly //include seperate boards
	name="fission reactor assembly parts"
	desc="Contains all the materials needed to assemble a fission assembly, minus the appropriate circuit board."

/obj/item/weapon/storage/box/fissionsupply_genericassembly/attack_self(mob/user)
	for(var/obj/O in contents)
		O.forceMove(user.loc)
	contents=null
	..()
	
/obj/item/weapon/storage/box/fissionsupply_genericassembly/New()
	..()
	new /obj/item/stack/sheet/plasteel(src,5)//5 plasteel
	new /obj/item/stack/rods(src,2)//2 rods
	new /obj/item/stack/cable_coil(src,5)//5 wire

	new /obj/item/weapon/stock_parts/manipulator(src)	 //1 scanning module OR 1 micro-manipulator
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)	 // 1 matter bin

/obj/item/weapon/storage/box/fissionsupply_casing
	name="fission reactor casing parts"
	desc="Contains all the materials needed to assemble a single fission reactor casing."

/obj/item/weapon/storage/box/fissionsupply_casing/attack_self(mob/user)
	for(var/obj/O in contents)
		O.forceMove(user.loc)
	contents=null
	..()
	
	
/obj/item/weapon/storage/box/fissionsupply_casing/New()
	..()
	new /obj/item/stack/sheet/plasteel(src,6)//6 plasteel
	new /obj/item/stack/rods(src,4) //4 rods
	new /obj/item/pipe(src,0) //1 pipe (optional)
	 
/obj/item/weapon/storage/box/fissionsupply_fuelmaker
	name="separational isotopic combiner parts"
	desc="Contains all the materials needed to assemble a separational isotopic combiner."

/obj/item/weapon/storage/box/fissionsupply_fuelmaker/attack_self(mob/user)
	for(var/obj/O in contents)
		O.forceMove(user.loc)
	contents=null
	..()
	
/obj/item/weapon/storage/box/fissionsupply_fuelmaker/New()
	..()
	new /obj/item/weapon/circuitboard/fission_fuelmaker(src)
	new /obj/item/stack/sheet/metal(src,5)//5 metal
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/manipulator(src)
	new /obj/item/weapon/stock_parts/console_screen(src)
	new /obj/item/stack/cable_coil(src,5)//5 wire
		
/obj/item/weapon/fuelrod/small/starter
	icon_state="i_fuelrod_s"

/obj/item/weapon/fuelrod/small/starter/New()
	..()
	fueldata.add_shit_to(URANIUM,units_of_storage,fueldata.fuel)
	fueldata.rederive_stats()
	fueldata.life=1


/obj/item/weapon/fuelrod/randomized
	icon_state="i_fuelrod"

/obj/item/weapon/fuelrod/randomized/New()
	..()	
	var/list/mats_std	=	list(URANIUM,THORIUM) //conventional nuclear fuel
	var/list/mats_uncommon=	list(PLUTONIUM,RADIUM) // exotic fuels or nuclear things
	var/list/mats_rare	=	list(RADON) // reactor adjacent things or stuff notable to engineering
	var/list/mats_exotic=	list(TRICORDRAZINE,DEGENERATECALCIUM) // for experimentation and learning
	
	var/current_units=fueldata.fuel.total_volume
	while (current_units<units_of_storage)
		var/r=rand()
		var/material=null
		var/amount_to_add=rand(1, ceil((units_of_storage-current_units)*0.8) )
		if(amount_to_add>units_of_storage/6) //if we are adding a large amount, skew the randomness so that we don't give a huge amount of rare stuff. with current vars, max 15 units of rare things per roll.
			r+=0.25
		if(r<0.05)		//  5%  skewed 0%
			material=pick(mats_exotic)
		else if(r<0.20)	// 15%  skewed 0%
			material=pick(mats_rare)
		else if(r<0.50)	// 30%  skewed 25%
			material=pick(mats_uncommon)
		else			// 50%  skewed 75%
			material=pick(mats_std)				

		//add a random amount of the chosen material, between 1 and 80% the remaining volume (rounded up)
		//if we roll the highest number always, this gives us 3 calls (with 90 units)
		fueldata.add_shit_to(material,amount_to_add,fueldata.fuel)
		current_units=fueldata.fuel.total_volume
	fueldata.rederive_stats()
	fueldata.life=1



/obj/structure/closet/crate/flatpack/fission_controller
	name = "flatpack (fission reactor controller)"
	override_icon_state=TRUE

/obj/structure/closet/crate/flatpack/fission_controller/New()
	..()
	icon_state = "flatpackeng"
	machine = new /obj/machinery/fissioncontroller(src)

/obj/structure/closet/crate/flatpack/fission_controller/after_machine_placed()
	machine.update_icon()
	..()
	for(var/obj/structure/fission_reactor_case/part in range(machine,1) )
		part.update_icon()
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(machine,1) )
		part.update_icon()	


/obj/structure/closet/crate/flatpack/configurable/fission_exterior
	name = "configurable flatpack (fission reactor casing part)"
	override_icon_state=TRUE
	var/intact = TRUE //atmospherics code. oof.

/obj/structure/closet/crate/flatpack/configurable/fission_exterior/New()
	..()
	icon_state = "flatpackeng"

/obj/structure/closet/crate/flatpack/configurable/fission_exterior/after_machine_placed()
	..()
	machine.update_icon()

	for(var/obj/structure/fission_reactor_case/part in range(machine,1) )
		part.update_icon()
	for(var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/part in range(machine,1) )
		part.update_icon()
	for(var/obj/structure/closet/crate/flatpack/fission_controller/part in range(machine,1) )
		part.update_icon()
	if(istype(machine,/obj/machinery/atmospherics/unary/fissionreactor_coolantport))
		var/obj/machinery/atmospherics/unary/fissionreactor_coolantport/C=machine
		C.initialize_directions=machine_options["direction"]
		C.buildFrom(usr,C)


/obj/structure/closet/crate/flatpack/configurable/fission_exterior/configure(var/mob/user)
	..()
	var/choice=input(user,"Select a schematic",name) in list("Reactor casing","Coolant port")
	if(choice=="Reactor casing")
		machine = new/obj/structure/fission_reactor_case(src)
	else if(choice=="Coolant port")
		var/des_dir=input(user,"Select port direction",name) in list("NORTH","SOUTH","EAST","WEST")
		switch(des_dir)
			if("NORTH")
				machine_options["direction"]=NORTH
			if("SOUTH")
				machine_options["direction"]=SOUTH
			if("EAST")
				machine_options["direction"]=EAST
			if("WEST")
				machine_options["direction"]=WEST
			else
				return
		machine = new/obj/machinery/atmospherics/unary/fissionreactor_coolantport(src)
		machine.dir=machine_options["direction"]

/obj/structure/closet/crate/flatpack/configurable/fission_interior
	name = "configurable flatpack (fission reactor internal assembly)"
	override_icon_state=TRUE

/obj/structure/closet/crate/flatpack/configurable/fission_interior/New()
	..()
	icon_state = "flatpackeng"

/obj/structure/closet/crate/flatpack/configurable/fission_interior/after_machine_placed()
	..()
	machine.update_icon()
	
/obj/structure/closet/crate/flatpack/configurable/fission_interior/configure(var/mob/user)
	..()
	var/choice=input(user,"Select a schematic",name) in list("Control rod","Fuel rod assembly","Fuel rod assembly (shielded)")
	switch(choice)
		if("Control rod")
			machine = new/obj/machinery/fissionreactor/fissionreactor_controlrod(src)
		if("Fuel rod assembly")
			machine = new/obj/machinery/fissionreactor/fissionreactor_fuelrod(src)
		if("Fuel rod assembly (shielded)")
			machine = new/obj/machinery/fissionreactor/fissionreactor_fuelrod/inert(src)



/obj/item/weapon/fuelrod/challenge
	name="ancient fuel reservoir"
	desc="The labeling is faded and torn, and is mostly illegible. All that remains is a pictogram with a radiation symbol, a skull, and a man running."
	icon='icons/obj/fissionreactor/items.dmi'
	icon_state="challenge_fuelrod"
	units_of_storage=100

/obj/item/weapon/fuelrod/challenge/update_icon()
	..()
	icon_state="challenge_fuelrod"

/obj/item/weapon/fuelrod/challenge/New()
	..()
	fueldata.add_shit_to(AGENT_W,units_of_storage,fueldata.fuel)
	fueldata.rederive_stats()
	fueldata.life=1

/obj/structure/closet/crate/secure/loot/ultramegameltdown_reactor_fuel
	name = "abandoned crate"
	desc = "The exterior is adorned in tiny spikes and is engraved with text in multiple languages as well as several pictograms with various lifeforms, some of which appear dead, alongside multiple warning symbols.\n\n Whatever it is that's inside, it must be quite honorable."
	icon_state = "ayysecurecrate"
	icon_opened = "ayysecurecrateopen"
	icon_closed = "ayysecurecrate"
	locked = 0
	
/obj/structure/closet/crate/secure/loot/ultramegameltdown_reactor_fuel/New()
	..()
	icon_state = "ayysecurecrate"
	icon_opened = "ayysecurecrateopen"
	icon_closed = "ayysecurecrate"
	new/obj/item/weapon/fuelrod/challenge(src)



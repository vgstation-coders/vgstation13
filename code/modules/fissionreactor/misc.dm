/*
in this file:
boxes used for cargo orders to make my life easier.
*/



/obj/item/weapon/storage/box/fissionsupply_controller
	name="fission reactor controller parts"
	desc="Contains all the materials needed to assemble a fission reactor controller."

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
	
/obj/item/weapon/storage/box/fissionsupply_casing/New()
	..()
	new /obj/item/stack/sheet/plasteel(src,6)//6 plasteel
	new /obj/item/stack/rods(src,4) //4 rods
	new /obj/item/pipe(src,0) //1 pipe (optional)
	 
/obj/item/weapon/storage/box/fissionsupply_fuelmaker
	name="seperational isotopic combiner parts"
	desc="Contains all the materials needed to assemble a seperational isotopic combiner."
	
/obj/item/weapon/storage/box/fissionsupply_fuelmaker/New()
	..()
	new /obj/item/weapon/circuitboard/fission_fuelmaker()
	new /obj/item/stack/sheet/metal(src,5)//5 metal
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/manipulator(src)
	new /obj/item/weapon/stock_parts/console_screen(src)
	new /obj/item/stack/cable_coil(src,5)//5 wire
		
/obj/item/weapon/fuelrod/starter
	icon_state="i_fuelrod"

/obj/item/weapon/fuelrod/starter/New()
	..()
	//fueldata.fuel.add_reagent(URANIUM,150)
	fueldata.add_shit_to(URANIUM,150,fueldata.fuel)
	fueldata.rederive_stats()
	fueldata.life=1
	
	
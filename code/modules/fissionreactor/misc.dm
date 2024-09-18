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
	var/obj/item/stack/rods/newrods= new /obj/item/stack/rods(src)//2 rods
	newrods.amount=2
	var/obj/item/stack/sheet/plasteel/plasteelsheet= new /obj/item/stack/sheet/plasteel(src)//5 plasteel
	plasteelsheet.amount=5
	var/obj/item/stack/cable_coil/cables= new /obj/item/stack/cable_coil(src)//5 wire
	cables.amount=5


/obj/item/weapon/storage/box/fissionsupply_genericassembly //include seperate boards
	name="fission reactor assembly parts"
	desc="Contains all the materials needed to assemble a fission assembly, minus the appropriate circuit board."

/obj/item/weapon/storage/box/fissionsupply_genericassembly/New()
	..()
	var/obj/item/stack/sheet/plasteel/plasteelsheet= new /obj/item/stack/sheet/plasteel(src)//5 plasteel
	plasteelsheet.amount=5
	var/obj/item/stack/rods/newrods= new /obj/item/stack/rods(src)//2 rods
	newrods.amount=2
	var/obj/item/stack/cable_coil/cables= new /obj/item/stack/cable_coil(src)//5 wire
	cables.amount=5
 
	new /obj/item/weapon/stock_parts/manipulator(src)	 //1 scanning module OR 1 micro-manipulator
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)	 // 1 matter bin

/obj/item/weapon/storage/box/fissionsupply_casing
	name="fission reactor casing parts"
	desc="Contains all the materials needed to assemble a single fission reactor casing."
	
/obj/item/weapon/storage/box/fissionsupply_casing/New()
	..()
	var/obj/item/stack/sheet/plasteel/plasteelsheet= new /obj/item/stack/sheet/plasteel(src)//6 plasteel
	plasteelsheet.amount=6
	var/obj/item/stack/rods/newrods= new /obj/item/stack/rods(src) //4 rods
	newrods.amount=4
	var/obj/item/pipe/pip = new /obj/item/pipe(src) //1 pipe (optional)
	pip.pipe_type=0
	 
/obj/item/weapon/storage/box/fissionsupply_fuelmaker
	name="seperational isotopic combiner parts"
	desc="Contains all the materials needed to assemble a seperational isotopic combiner."
	
/obj/item/weapon/storage/box/fissionsupply_fuelmaker/New()
	..()
	new /obj/item/weapon/circuitboard/fission_fuelmaker()
	var/obj/item/stack/sheet/metal/metalsheet= new /obj/item/stack/sheet/metal(src)//5 metal
	metalsheet.amount=5
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/scanning_module(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/matter_bin(src)
	new /obj/item/weapon/stock_parts/manipulator(src)
	new /obj/item/weapon/stock_parts/console_screen(src)
	var/obj/item/stack/cable_coil/cables= new /obj/item/stack/cable_coil(src)//5 wire
	cables.amount=5	
		
/obj/item/weapon/fuelrod/starter
	icon_state="i_fuelrod"

/obj/item/weapon/fuelrod/starter/New()
	..()
	fueldata.fuel.add_reagent(URANIUM,150)
	fueldata.rederive_stats()
	fueldata.life=1
	
	
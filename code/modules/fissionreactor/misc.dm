/*
in this file:
boxes used for cargo orders to make my life easier.
*/



/obj/item/weapon/storage/box/fissionsupply_controller
	name="fission reactor controller parts"
	desc="Contains all the materials needed to assemble a fission reactor controller."

/obj/item/weapon/storage/box/fissionsupply_controller/New()
	..()
	


/obj/item/weapon/storage/box/fissionsupply_genericassembly //include seperate boards
	name="fission reactor assembly parts"
	desc="Contains all the materials needed to assemble a fission assembly, minus the appropriate circuit board."

/obj/item/weapon/storage/box/fissionsupply_genericassembly/New()
	..()
	 

/obj/item/weapon/storage/box/fissionsupply_casing
	name="fission reactor casing parts"
	desc="Contains all the materials needed to assemble a single fission reactor casing."
	
/obj/item/weapon/storage/box/fissionsupply_casing/New()
	..()
	 
	 
/obj/item/weapon/storage/box/fissionsupply_fuelmaker
	name="seperational isotopic combiner parts"
	desc="Contains all the materials needed to assemble a seperational isotopic combiner."
	
/obj/item/weapon/storage/box/fissionsupply_casing/New()
	..()
	 	
		
/obj/item/weapon/fuelrod/starter
	icon_state="i_fuelrod"

/obj/item/weapon/fuelrod/starter/New()
	..()
	fueldata.fuel.add_reagent(URANIUM,150)
	fueldata.rederive_stats()
	fueldata.life=1
	
	
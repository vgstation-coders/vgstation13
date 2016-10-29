/*
 *	Here are defined the boxes contained in the trader vending machine.
 *	Feel free to add stuff.
*/

/obj/item/weapon/storage/marauder
	name = "Box of Marauder circuits"
	desc = "All in one box!"
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/marauder/New() //Because we're good jews, they won't be able to finish the marauder. The box is missing a circuit.
	..()
	new /obj/item/weapon/circuitboard/mecha/marauder(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/peripherals(src)
	//new /obj/item/weapon/circuitboard/mecha/marauder/targeting(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/main(src)

/obj/item/weapon/storage/bluespace_crystal
	name = "Bluespace crystals box"
	desc = "Hmmm... it smells like tomato"
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/bluespace_crystal/New()
	..()
	for(var/amount = 1 to 6)
		new /obj/item/bluespace_crystal/artificial(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato(src)

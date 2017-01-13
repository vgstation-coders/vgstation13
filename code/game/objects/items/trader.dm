/*
 *	Here defined the boxes contained in the trader vending machine.
 *	Feel free to add stuff. Don't forget to add them to the vmachine afterwards.
*/

/obj/item/weapon/coin/trader
	material=MAT_GOLD
	name = "trader coin"
	icon_state = "coin_mythril"

/obj/item/weapon/storage/trader_marauder
	name = "box of Marauder circuits"
	desc = "All in one box!"
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/trader_marauder/New() //Because we're good jews, they won't be able to finish the marauder. The box is missing a circuit.
	..()
	new /obj/item/weapon/circuitboard/mecha/marauder(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/peripherals(src)
	//new /obj/item/weapon/circuitboard/mecha/marauder/targeting(src)
	new /obj/item/weapon/circuitboard/mecha/marauder/main(src)

/obj/item/weapon/storage/bluespace_crystal
	name = "natural bluespace crystals box"
	desc = "Hmmm... it smells like tomato"
	icon = 'icons/obj/storage/smallboxes.dmi'
	icon_state = "box_of_doom"
	item_state = "box_of_doom"

/obj/item/weapon/storage/bluespace_crystal/New()
	..()
	for(var/amount = 1 to 6)
		new /obj/item/bluespace_crystal(src)
	new /obj/item/weapon/reagent_containers/food/snacks/grown/bluespacetomato(src)

/*/obj/structure/cage/with_random_slime
	..()

	add_mob

/mob/living/carbon/slime/proc/randomSlime()
*/


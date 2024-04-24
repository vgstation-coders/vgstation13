

/obj/item/weapon/reagent_containers/food/snacks/fries
	name = "Space Fries"
	desc = "AKA: French Fries, Freedom Fries, etc."
	icon_state = "fries"
	plate_offset_y = -2
	filling_color = "#FFCF62"
	reagents_to_add = list(NUTRIMENT = 4)
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/fries/processed/New()
	reagents_to_add = null
	..()

/obj/item/weapon/reagent_containers/food/snacks/fries/cone
	name = "cone of Space Fries"
	icon_state = "fries_cone"
	trash = /obj/item/trash/fries_cone

/obj/item/weapon/reagent_containers/food/snacks/fries/cone/on_vending_machine_spawn()//Fast-Food Menu
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/fries/poutine
	name = "poutine"
	desc = "Fries, cheese & gravy. Your arteries will hate you for this."
	icon_state = "poutine"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	filling_color = "#FFFFFF"
	plate_offset_y = -3
	reagents_to_add = list(NUTRIMENT = 8)

/obj/item/weapon/reagent_containers/food/snacks/fries/poutine/dangerous
	name = "dangerously cheesy poutine"
	desc = "Fries, cheese, gravy & more cheese. Be careful with this, it's dangerous!"
	icon_state = "poutinedangerous"
	plate_offset_y = 0
	reagents_to_add = list(CHEESYGLOOP = 3) //need 2+ wheels to reach overdose, which will stop the heart until all is removed
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/fries/poutine/dangerous/barrel
	name = "dangerously cheesy poutine barrel"
	desc = "Four cheese wheels full of gravy, fries and cheese curds, arranged like a barrel. This is degeneracy, Canadian style."
	icon_state = "poutinebarrel"
	reagents_to_add = list(CHEESYGLOOP = 5)
	bitesize = 4

/obj/item/weapon/reagent_containers/food/snacks/fries/poutine/syrup
	name = "maple syrup poutine"
	desc = "French fries lathered with Canadian maple syrup and cheese curds. Delightful, eh?"
	icon_state = "poutinesyrup"
	reagents_to_add = list(NUTRIMENT = 5, MAPLESYRUP = 5)

/obj/item/weapon/reagent_containers/food/snacks/fries/cheesy
	name = "Cheesy Fries"
	desc = "Fries. Covered in cheese. Duh."
	icon_state = "cheesyfries"
	food_flags = FOOD_ANIMAL | FOOD_LACTOSE //cheese
	plate_offset_y = -3
	filling_color = "#FFEB3B"
	reagents_to_add = list(NUTRIMENT = 6)

/obj/item/weapon/reagent_containers/food/snacks/fries/cheesy/punnet
	name = "punnet of Cheesy Fries"
	icon_state = "cheesyfries_punnet"
	trash = /obj/item/trash/fries_punet

/obj/item/weapon/reagent_containers/food/snacks/fries/cheesy/punnet/on_vending_machine_spawn()//Fast-Food Menu XL
	reagents.chem_temp = COOKTEMP_READY

/obj/item/weapon/reagent_containers/food/snacks/fries/carrot
	name = "Carrot Fries"
	desc = "Tasty fries from fresh carrots."
	icon_state = "carrotfries"
	filling_color =  "#FFFFFF"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 3, IMIDAZOLINE = 3)

/obj/item/weapon/reagent_containers/food/snacks/fries/carrot/processed/New()
	..()
	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/food/snacks/fries/diamond
	name = "Diamond Fries"
	desc = "Surprisingly juicy and crunchy."
	icon_state = "diamondfries"
	filling_color = "#95FFFF"
	base_crumb_chance = 0
	reagents_to_add = list(NUTRIMENT = 10)

/obj/item/weapon/reagent_containers/food/snacks/fries/diamond/processed
	reagents_to_add = null

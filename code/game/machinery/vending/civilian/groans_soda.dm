/obj/machinery/vending/groans
	name = "Groans Soda"
	desc = "A soda machine owned by the infamous 'Groans' franchise."
	product_slogans = "Groans: Drink up!;Sponsored by Discount Dan!;Take a sip!;Just one sip, do it!"
	product_ads = "Try our new 'Double Dan' flavor!"
	vend_reply = "No refunds."
	icon_state = "groans"
	products = list(/obj/item/weapon/reagent_containers/food/drinks/groans = 10,/obj/item/weapon/reagent_containers/food/drinks/filk = 10,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 10,/obj/item/weapon/reagent_containers/food/drinks/mannsdrink = 10)
	prices = list(/obj/item/weapon/reagent_containers/food/drinks/groans = 20,/obj/item/weapon/reagent_containers/food/drinks/filk = 20,/obj/item/weapon/reagent_containers/food/drinks/soda_cans/grifeo = 30,/obj/item/weapon/reagent_containers/food/drinks/mannsdrink = 10,/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 50)
	contraband = list(/obj/item/weapon/reagent_containers/food/drinks/groansbanned = 10)

	pack = /obj/structure/vendomatpack/groans
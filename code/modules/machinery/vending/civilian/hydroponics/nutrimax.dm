/obj/machinery/vending/hydronutrients
	name = "NutriMax"
	desc = "A plant nutrients vendor"
	product_slogans = "Aren't you glad you don't have to fertilize the natural way?;Now with 50% less stink!;Plants are people too!"
	product_ads = "We like plants!;Don't you want some?;The greenest thumbs ever.;We like big plants.;Soft soil..."
	icon_state = "nutri"
	icon_deny = "nutri-deny"
	products = list(/obj/item/beezeez = 45,/obj/item/weapon/reagent_containers/glass/fertilizer/ez = 35,/obj/item/weapon/reagent_containers/glass/fertilizer/l4z = 25,/obj/item/weapon/reagent_containers/glass/fertilizer/rh = 15,/obj/item/weapon/plantspray/pests = 20,
					/obj/item/weapon/reagent_containers/syringe = 5,/obj/item/weapon/storage/bag/plants = 5)
	contraband = list(/obj/item/weapon/reagent_containers/glass/bottle/ammonia = 10,/obj/item/weapon/reagent_containers/glass/bottle/diethylamine = 5)

	pack = /obj/structure/vendomatpack/hydronutrients
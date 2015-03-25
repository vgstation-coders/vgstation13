/obj/machinery/vending/medical
	name = "NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "5"
	products = list(
		/obj/item/weapon/reagent_containers/glass/bottle/antitoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/inaprovaline = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/stoxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/toxin = 4,
		/obj/item/weapon/reagent_containers/glass/bottle/charcoal = 4,
		/obj/item/weapon/reagent_containers/syringe/antiviral = 4,
		/obj/item/weapon/reagent_containers/syringe = 12,
		/obj/item/device/healthanalyzer = 5,
		/obj/item/weapon/reagent_containers/glass/beaker = 4,
		/obj/item/weapon/reagent_containers/dropper = 2)
	contraband = list(/obj/item/weapon/reagent_containers/pill/tox = 3,/obj/item/weapon/reagent_containers/pill/stox = 4,/obj/item/weapon/reagent_containers/pill/antitox = 6)

	pack = /obj/structure/vendomatpack/medical
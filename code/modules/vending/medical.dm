/obj/machinery/vending/medical
	name = "\improper NanoMed Plus"
	desc = "Medical drug dispenser."
	icon_state = "med"
	icon_deny = "med-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;Natural chemicals!;This stuff saves lives.;Don't you want some?;Ping!"
	req_access_txt = "5"
	products = list(/obj/item/reagent_containers/syringe = 12, 
					/obj/item/reagent_containers/dropper = 3, 
					/obj/item/device/healthanalyzer = 4, 
					/obj/item/device/sensor_device = 2, 
					/obj/item/pinpointer/crew = 2,
					/obj/item/reagent_containers/medspray/sterilizine = 1,
					/obj/item/stack/medical/gauze = 8, 
					/obj/item/reagent_containers/pill/patch/styptic = 5, 
					/obj/item/reagent_containers/medspray/styptic = 2, 
					/obj/item/reagent_containers/pill/patch/silver_sulf = 5, 
					/obj/item/reagent_containers/medspray/silver_sulf = 2,
					/obj/item/reagent_containers/pill/insulin = 10,
					/obj/item/reagent_containers/pill/salbutamol = 2, 
					/obj/item/reagent_containers/glass/bottle/charcoal = 4, 
					/obj/item/reagent_containers/glass/bottle/epinephrine = 4, 
					/obj/item/reagent_containers/glass/bottle/salglu_solution = 3,
					/obj/item/reagent_containers/glass/bottle/morphine = 4, 
					/obj/item/reagent_containers/glass/bottle/toxin = 3, 
					/obj/item/reagent_containers/syringe/antiviral = 6)
	contraband = list(/obj/item/reagent_containers/pill/tox = 3,
		              /obj/item/reagent_containers/pill/morphine = 4,
		              /obj/item/reagent_containers/pill/charcoal = 6)
	premium = list(/obj/item/storage/box/hug/medical = 1,
		           /obj/item/reagent_containers/hypospray/medipen = 3,
		           /obj/item/storage/belt/medical = 3,
		           /obj/item/wrench/medical = 1)
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/medical

/obj/item/vending_refill/medical
	machine_name = "NanoMed"
	icon_state = "refill_medical"
	charges = list(26, 5, 3)// of 76 standard, 13 contraband, 8 premium
	init_charges = list(26, 5, 3)

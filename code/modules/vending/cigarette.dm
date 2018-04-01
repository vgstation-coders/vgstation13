/obj/machinery/vending/cigarette
	name = "\improper ShadyCigs Deluxe"
	desc = "If you want to get cancer, might as well do it in style."
	product_slogans = "Space cigs taste good like a cigarette should.;I'd rather toolbox than switch.;Smoke!;Don't believe the reports - smoke today!"
	product_ads = "Probably not bad for you!;Don't believe the scientists!;It's good for you!;Don't quit, buy more!;Smoke!;Nicotine heaven.;Best cigarettes since 2150.;Award-winning cigs."
	icon_state = "cigs"
	products = list(/obj/item/storage/fancy/cigarettes = 5,
					/obj/item/storage/fancy/cigarettes/cigpack_uplift = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_robust = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_carp = 3,
					/obj/item/storage/fancy/cigarettes/cigpack_midori = 3,
					/obj/item/storage/box/matches = 10,
					/obj/item/lighter/greyscale = 4,
					/obj/item/storage/fancy/rollingpapers = 5)
	contraband = list(/obj/item/lighter = 3,
		              /obj/item/clothing/mask/vape = 5)
	premium = list(/obj/item/storage/fancy/cigarettes/cigpack_robustgold = 3,
		           /obj/item/storage/fancy/cigarettes/cigars = 1,
		           /obj/item/storage/fancy/cigarettes/cigars/havana = 1,
		           /obj/item/storage/fancy/cigarettes/cigars/cohiba = 1)
	refill_canister = /obj/item/vending_refill/cigarette

/obj/item/vending_refill/cigarette
	machine_name = "ShadyCigs Deluxe"
	icon_state = "refill_smoke"
	charges = list(12, 3, 2)// of 36 standard, 9 contraband, 6 premium
	init_charges = list(12, 3, 2)

/obj/machinery/vending/cigarette/pre_throw(obj/item/I)
	if(istype(I, /obj/item/lighter))
		var/obj/item/lighter/L = I
		L.set_lit(TRUE)

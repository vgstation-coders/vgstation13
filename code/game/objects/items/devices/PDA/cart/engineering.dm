/obj/item/weapon/cartridge/engineering
	name = "\improper Power-ON Cartridge"
	icon_state = "cart-e"
	access_engine = 1
	radio_type = /obj/item/radio/integrated/signal/bot/floorbot

/obj/item/weapon/cartridge/atmos
	name = "\improper BreatheDeep Cartridge"
	icon_state = "cart-a"
	access_atmos = 1

/obj/item/weapon/cartridge/mechanic
	name = "\improper Screw-E Cartridge"
	icon_state = "cart-mech"
	access_engine = 1 //for the power monitor, but may remove later
	starting_apps = list(/datum/pda_app/cart/scanner/mechanic)

/datum/pda_app/cart/scanner/mechanic
    base_name = "Device Analyzer"
    desc = "Use a built in device analyzer."
    category = "Mechanic Functions"
    icon = "pda_scanner"
    app_scanmode = SCANMODE_DEVICE
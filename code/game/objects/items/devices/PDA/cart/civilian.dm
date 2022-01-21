/obj/item/weapon/cartridge/chef
	name = "\improper ChefBuddy Cartridge"
	icon_state = "cart-chef"
	starting_apps = list(/datum/pda_app/cart/scanner/reagent)

/obj/item/weapon/cartridge/janitor
	name = "\improper CustodiPRO Cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1
	radio_type = /obj/item/radio/integrated/signal/bot/janitor

/obj/item/weapon/cartridge/clown
	name = "\improper Honkworks 5.0"
	icon_state = "cart-clown"
	access_clown = 1
	var/honk_charges = 5

/obj/item/weapon/cartridge/mime
	name = "\improper Gestur-O 1000"
	icon_state = "cart-mi"
	access_mime = 1
	var/mime_charges = 5
/*
/obj/item/weapon/cartridge/botanist
	name = "\improper Green Thumb v4.20"
	icon_state = "cart-b"
	access_flora = 1
*/
/obj/item/weapon/cartridge/quartermaster
	name = "\improper Space Parts & Space Vendors Cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1
	radio_type = /obj/item/radio/integrated/signal/bot/mule
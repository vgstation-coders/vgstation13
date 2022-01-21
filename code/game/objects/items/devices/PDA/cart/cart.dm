/obj/item/weapon/cartridge
	name = "\improper Generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	origin_tech = Tc_PROGRAMMING + "=2"
	w_class = W_CLASS_TINY

	// -- What we use to communicate with bots
	var/obj/item/radio/integrated/radio = null
	var/radio_type = null
	
	// -- For the IAA and etc
	var/fax_pings = FALSE

	var/list/datum/pda_app/applications = list()
	var/list/starting_apps = list()

	//var/list/stored_data = list()

	// Bot destination
	var/saved_destination = "No destination"

/obj/item/weapon/cartridge/New()
	. = ..()
	for(var/type in starting_apps)
		var/datum/pda_app/app = new type()
		if(istype(app) && isPDA(loc))
			var/obj/item/device/pda/P = loc
			if(istype(app,/datum/pda_app/cart))
				var/datum/pda_app/cart/cart_app = app
				cart_app.onInstall(P,src)
			else
				app.onInstall(P)
	if (radio_type)
		radio = new radio_type(src)
		if(isPDA(loc))
			var/obj/item/device/pda/P = loc
			radio.hostpda = P
		if(ticker && ticker.current_state == GAME_STATE_PLAYING)
			radio.initialize()

/obj/item/weapon/cartridge/initialize()
	. = ..()
	if (radio)
		radio.initialize()

/obj/item/weapon/cartridge/Destroy()
	if(radio)
		qdel(radio)
		radio = null
	//stored_data = null
	..()

/datum/pda_app/cart
	can_purchase = FALSE
	price = 0
	var/obj/item/weapon/cartridge/cart_device = null

/datum/pda_app/cart/onInstall(var/obj/item/device/pda/device,var/obj/item/weapon/cartridge/device2)
	..(device)
	if(device2)
		cart_device = device2
		cart_device.applications += src

/datum/pda_app/cart/onUninstall()
	if(cart_device)
		cart_device.applications.Remove(src)
		cart_device = null
	..()

/datum/pda_app/cart/scanner
	var/base_name = "Scanner"
	has_screen = FALSE
	var/app_scanmode = SCANMODE_NONE

/datum/pda_app/cart/scanner/onInstall(var/obj/item/device/pda/device,var/obj/item/weapon/cartridge/device2)
	..(device,device2)
	name = "[pda_device.scanmode == app_scanmode ? "Disable" : "Enable" ] [base_name]"

/datum/pda_app/cart/scanner/on_select(var/mob/user)
	if(pda_device.scanmode == app_scanmode)
		pda_device.scanmode = SCANMODE_NONE
	else
		pda_device.scanmode = app_scanmode
	name = "[pda_device.scanmode == app_scanmode ? "Disable" : "Enable" ] [base_name]"
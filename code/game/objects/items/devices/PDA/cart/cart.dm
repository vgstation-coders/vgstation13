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

	// -- For scanners
	var/obj/item/device/analyzer/atmos_analys = new
	var/obj/item/device/robotanalyzer/robo_analys = new
	var/obj/item/device/hailer/integ_hailer = new
	var/obj/item/device/device_analyser/dev_analys = new

	var/list/datum/pda_app/applications = list()
	var/list/starting_apps = list()

	// Bot destination
	var/saved_destination = "No destination"

/obj/item/weapon/cartridge/New()
	. = ..()
	for(var/type in starting_apps)
		var/datum/pda_app/app = new type()
		applications += app
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
		QDEL_NULL(radio)

	if(atmos_analys)
		QDEL_NULL(atmos_analys)

	if(robo_analys)
		QDEL_NULL(robo_analys)

	if(dev_analys)
		QDEL_NULL(dev_analys)

	if(integ_hailer)
		QDEL_NULL(integ_hailer)
	..()

/datum/pda_app/cart
	can_purchase = FALSE
	price = 0
	var/obj/item/weapon/cartridge/cart_device = null

/datum/pda_app/cart/onInstall(var/obj/item/device/pda/device,var/obj/item/weapon/cartridge/device2)
	..(device)
	if(device2)
		cart_device = device2

/datum/pda_app/cart/onUninstall()
	if(cart_device)
		cart_device = null
	..()

/datum/pda_app/cart/scanner
	var/base_name = "Scanner"
	has_screen = FALSE

/datum/pda_app/cart/scanner/onInstall(var/obj/item/device/pda/device,var/obj/item/weapon/cartridge/device2)
	..(device,device2)
	update_name()

/datum/pda_app/cart/scanner/on_select(var/mob/user)
	if(pda_device)
		if(pda_device.scanning_app == src)
			pda_device.scanning_app = null
		else
			pda_device.scanning_app = src
		update_name() // To be extra sure
		for(var/datum/pda_app/cart/scanner/SC in pda_device.applications)
			SC.update_name()

/datum/pda_app/cart/scanner/proc/update_name()
	name = "[pda_device.scanning_app == src ? "Disable" : "Enable" ] [base_name]"

/datum/pda_app/cart/scanner/proc/preattack(atom/A as mob|obj|turf|area, mob/user as mob)
	return

/datum/pda_app/cart/scanner/proc/attack(mob/living/carbon/C, mob/living/user as mob)
	return

/datum/pda_app/cart/scanner/proc/afterattack(atom/A, mob/user, proximity_flag)
	return

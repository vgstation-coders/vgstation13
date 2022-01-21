// -- This file is the worst file you'll ever have to work with in your entire life coding for ss13.
// Enjoy.

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

	// -- Various "access" crap
	var/access_clown = 0
	var/access_mime = 0
	var/access_hydroponics = 0
	var/access_trader = 0
	var/access_robotics = 0
	var/access_camera = 0
	var/fax_pings = FALSE

	var/list/datum/pda_app/applications = list()
	var/list/starting_apps = list()

	// -- Crime against OOP variable (controls what is shown on PDA call to cartridge)
	var/mode = null
	var/menu

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

/datum/pda_app/cart/scanner/New()
	..()
	name = "[pda_device.scanmode == app_scanmode ? "Disable" : "Enable" ] [base_name]"

/datum/pda_app/cart/scanner/on_select(var/mob/user)
	if(pda_device.scanmode == app_scanmode)
		pda_device.scanmode = SCANMODE_NONE
	else
		pda_device.scanmode = app_scanmode
	name = "[pda_device.scanmode == app_scanmode ? "Disable" : "Enable" ] [base_name]"

/obj/item/weapon/cartridge/proc/unlock()
	if (!istype(loc, /obj/item/device/pda))
		return

	generate_menu()
	print_to_host(menu)
	return

/obj/item/weapon/cartridge/proc/print_to_host(var/text)
	if (!istype(loc, /obj/item/device/pda))
		return

	var/obj/item/device/pda/pda_device = loc

	pda_device.cart = text

	for (var/mob/M in viewers(1, pda_device.loc))
		if (M.client && M.machine == pda_device)
			pda_device.attack_self(M)

	return

/obj/item/weapon/cartridge/proc/generate_menu()
	switch(mode)
		if(40) //signaller
			menu = "<h4><span class='pda_icon pda_signaler'></span> Remote Signaling System</h4>"

			menu += {"
<a href='byond://?src=\ref[src];choice=Send Signal'>Send Signal</A><BR>
Frequency:
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=-10'>-</a>
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=-2'>-</a>
[format_frequency(radio:frequency)]
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=2'>+</a>
<a href='byond://?src=\ref[src];choice=Signal Frequency;sfreq=10'>+</a><br>
<br>
Code:
<a href='byond://?src=\ref[src];choice=Signal Code;scode=-5'>-</a>
<a href='byond://?src=\ref[src];choice=Signal Code;scode=-1'>-</a>
[radio:code]
<a href='byond://?src=\ref[src];choice=Signal Code;scode=1'>+</a>
<a href='byond://?src=\ref[src];choice=Signal Code;scode=5'>+</a><br>"}

/obj/item/weapon/cartridge/Topic(href, href_list)
	if (..())
		return

	if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr.unset_machine()
		usr << browse(null, "window=pda")
		return

	switch(href_list["choice"])
		if("Send Signal")
			spawn( 0 )
				radio:send_signal("ACTIVATE")
				return

		if("Signal Frequency")
			var/new_frequency = sanitize_frequency(radio:frequency + text2num(href_list["sfreq"]))
			radio:set_frequency(new_frequency)

		if("Signal Code")
			radio:code += text2num(href_list["scode"])
			radio:code = round(radio:code)
			radio:code = min(100, radio:code)
			radio:code = max(1, radio:code)

	generate_menu()
	print_to_host(menu)

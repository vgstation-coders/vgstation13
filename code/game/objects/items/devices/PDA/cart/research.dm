/obj/item/weapon/cartridge/robotics
	name = "\improper R.O.B.U.T.T. Cartridge"
	desc = "Allows you to use your pda as a cyborg analyzer."
	icon_state = "cart-robo"
	starting_apps = list(/datum/pda_app/cart/scanner/robotics)

/datum/pda_app/cart/scanner/robotics
    base_name = "Cyborg analyzer"
    desc = "Use a built in cyborg analyzer."
    category = "Utilities"
    icon = "pda_medical"

/datum/pda_app/cart/scanner/robotics/afterattack(atom/A, mob/user, proximity_flag)
    if(!cart_device.robo_analys || !proximity_flag)
        return
    cart_device.robo_analys.cant_drop = 1
    if(!A.attackby(cart_device.robo_analys, user))
        cart_device.robo_analys.afterattack(A, user, 1)

/obj/item/weapon/cartridge/signal
    name = "\improper Generic signaler cartridge"
    desc = "A data cartridge with an integrated radio signaler module."
    radio_type = /obj/item/radio/integrated/signal
    starting_apps = list(/datum/pda_app/cart/signaler)

/datum/pda_app/cart/signaler
	name = "Signaler System"
	desc = "Used to send a signal of a certain frequency."
	category = "Utilities"
	icon = "pda_signaler"

/datum/pda_app/cart/signaler/get_dat(var/mob/user)
    menu = {"<h4><span class='pda_icon pda_signaler'></span> Remote Signaling System</h4>"}
    if (!cart_device || !istype(cart_device.radio, /obj/item/radio/integrated/signal))
        menu += "<span class='pda_icon pda_signaler'></span> Could not find radio peripheral connection <br/>"
    else
        menu += {"
            <a href='byond://?src=\ref[src];Send Signal=1'>Send Signal</A><BR>
            Frequency:
            <a href='byond://?src=\ref[src];Signal Frequency=-10'>-</a>
            <a href='byond://?src=\ref[src];Signal Frequency=-2'>-</a>
            [format_frequency(cart_device.radio:frequency)]
            <a href='byond://?src=\ref[src];Signal Frequency=2'>+</a>
            <a href='byond://?src=\ref[src];Signal Frequency=10'>+</a><br>
            <br>
            Code:
            <a href='byond://?src=\ref[src];Signal Code=-5'>-</a>
            <a href='byond://?src=\ref[src];Signal Code=-1'>-</a>
            [cart_device.radio:code]
            <a href='byond://?src=\ref[src];Signal Code=1'>+</a>
            <a href='byond://?src=\ref[src];Signal Code=5'>+</a><br>"}
    return menu

/datum/pda_app/cart/signaler/Topic(href, href_list)
    if(..() || !cart_device)
        return
    if(href_list["Send Signal"])
        spawn( 0 )
            cart_device.radio:send_signal("ACTIVATE")
            return

    if(href_list["Signal Frequency"])
        var/new_frequency = sanitize_frequency(cart_device.radio:frequency + text2num(href_list["Signal Frequency"]))
        cart_device.radio:set_frequency(new_frequency)

    if(href_list["Signal Code"])
        cart_device.radio:code += text2num(href_list["Signal Code"])
        cart_device.radio:code = round(cart_device.radio:code)
        cart_device.radio:code = min(100, cart_device.radio:code)
        cart_device.radio:code = max(1, cart_device.radio:code)
    refresh_pda()

/obj/item/weapon/cartridge/signal/toxins
    name = "\improper Signal Ace 2"
    desc = "Complete with integrated radio signaler!"
    icon_state = "cart-tox"
    starting_apps = list(
        /datum/pda_app/cart/signaler,
        /datum/pda_app/cart/scanner/atmos,
    )
    radio_type = /obj/item/radio/integrated/signal
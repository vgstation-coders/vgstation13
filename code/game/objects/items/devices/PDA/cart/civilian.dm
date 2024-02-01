/obj/item/weapon/cartridge/chef
	name = "\improper ChefBuddy Cartridge"
	icon_state = "cart-chef"
	starting_apps = list(/datum/pda_app/cart/scanner/reagent)

/obj/item/weapon/cartridge/janitor
    name = "\improper CustodiPRO Cartridge"
    desc = "The ultimate in clean-room design."
    icon_state = "cart-j"
    starting_apps = list(
        /datum/pda_app/cart/custodial_locator,
        /datum/pda_app/cart/janibot,
    )
    radio_type = /obj/item/radio/integrated/signal/bot/janitor

/datum/pda_app/cart/custodial_locator
    name = "Custodial Locator"
    desc = "Locates janitor items."
    category = "Utilities"
    icon = "pda_bucket"

/datum/pda_app/cart/custodial_locator/get_dat(var/mob/user)
    var/menu = "<h4><span class='pda_icon pda_bucket'></span> Persistent Custodial Object Locator</h4>"
    var/turf/cl = get_turf(pda_device)
    if (!cl)
        menu += "ERROR: Unable to determine current location."
    else
        menu += "Current Orbital Location: <b>\[[cl.x-WORLD_X_OFFSET[cl.z]], [cl.y-WORLD_Y_OFFSET[cl.z]]\]</b>"
        menu += "<h4>Located Mops:</h4>"
        var/ldat
        for (var/obj/item/weapon/mop/M in mop_list)
            var/turf/ml = get_turf(M)
            if(ml)
                if (ml.z != cl.z)
                    continue
                var/direction = get_dir(cl, M)
                ldat += "Mop - <b>\[[ml.x-WORLD_X_OFFSET[ml.z]], [ml.y-WORLD_Y_OFFSET[ml.z]] ([uppertext(dir2text_short(direction))])\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"
        if (!ldat)
            menu += "None"
        else
            menu += "[ldat]"
        menu += "<h4>Located Mop Buckets:</h4>"
        ldat = null
        for (var/obj/structure/mopbucket/B in mopbucket_list)
            var/turf/bl = get_turf(B)
            if(bl)
                if (bl.z != cl.z)
                    continue
                var/direction = get_dir(cl, B)
                ldat += "Bucket - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]], [bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text_short(direction))])\]</b> - Water level: [B.reagents.total_volume]/100<br>"
        if (!ldat)
            menu += "None"
        else
            menu += "[ldat]"
        menu += "<h4>Located Cleanbots:</h4>"
        ldat = null
        for (var/obj/machinery/bot/cleanbot/B in cleanbot_list)
            var/turf/bl = get_turf(B)
            if(bl)
                if (bl.z != cl.z)
                    continue
                var/direction = get_dir(cl, B)
                ldat += "Cleanbot - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]], [bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text_short(direction))])\]</b> - [B.on ? "Online" : "Offline"]<br>"
        if (!ldat)
            menu += "None"
        else
            menu += "[ldat]"
        menu += "<h4>Located Jani-Carts:</h4>"
        ldat = null
        for (var/obj/structure/bed/chair/vehicle/janicart/J in janicart_list)
            var/turf/bl = get_turf(J)
            if(bl)
                if (bl.z != cl.z)
                    continue
                var/direction = get_dir(cl, J)
                ldat += "Jani-Cart - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]], [bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text_short(direction))])\]</b> - [J.upgraded ? "Upgraded" : "Unupgraded"]<br>"
        if (!ldat)
            menu += "None"
        else
            menu += "[ldat]"
        ldat = null
        for (var/obj/item/key/janicart/K in janikeys_list)
            var/turf/bl = get_turf(K)
            if(bl)
                if (bl.z != cl.z)
                    continue
                var/direction = get_dir(cl, K)
                ldat += "Keys - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]], [bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text_short(direction))])\]</b><br>"
        if (!ldat)
            menu += "None"
        else
            menu += "[ldat]"
    return menu

/datum/pda_app/cart/janibot
	name = "Cleaner Bot Access"
	desc = "Used to control a cleanbot."
	category = "Utilities"
	icon = "pda_bucket"

/datum/pda_app/cart/janibot/get_dat(var/mob/user)
    var/dat = ""
    if (!cart_device)
        dat += {"<span class='pda_icon pda_bucket'></span> Could not find radio peripheral connection <br/>"}
        return
    if (!istype(cart_device.radio, /obj/item/radio/integrated/signal/bot/janitor))
        dat += {"<span class='pda_icon pda_bucket'></span>Commlink bot error <br/>"}
        return
    dat += {"<span class='pda_icon pda_bucket'></span><b>C.L.E.A.N bot Interlink V1.0</b> <br/>"}
    dat += "<ul>"
    for (var/obj/machinery/bot/cleanbot/clean in bots_list)
        if (clean.z != user.z)
            continue
        dat += {"<li>
                <i>[clean]</i>: [clean.return_status()] in [get_area_name(clean)] <br/>
                <a href='?src=\ref[cart_device.radio];bot=\ref[clean];command=summon;user=\ref[user]'>[clean.summoned ? "Halt" : "Summon"]</a> <br/>
                <a href='?src=\ref[cart_device.radio];bot=\ref[clean];command=switch_power;user=\ref[user]'>Turn [clean.on ? "off" : "on"]</a> <br/>
                Auto-patrol: <a href='?src=\ref[cart_device.radio];bot=\ref[clean];command=auto_patrol;user=\ref[user]'>[clean.auto_patrol ? "Enabled" : "Disabled"]</a><br/>
                </li>"}
    dat += "</ul>"
    return dat

/obj/item/weapon/cartridge/clown
    name = "\improper Honkworks 5.0"
    icon_state = "cart-clown"
    starting_apps = list(
        /datum/pda_app/cart/honk,
        /datum/pda_app/cart/virus/honk,
    )

/datum/pda_app/cart/honk
    name = "Honk Synthesizer"
    desc = "HONK!"
    has_screen = FALSE
    icon = "pda_honk"
    var/last_honk //No honk spamming

/datum/pda_app/cart/honk/on_select(var/mob/user)
    if (!(last_honk && world.time < last_honk + 20))
        playsound(get_turf(pda_device), 'sound/items/bikehorn.ogg', 50, 1)
        last_honk = world.time

/datum/pda_app/cart/virus/honk
    desc = "HONK!"
    icon = "pda_honk"

/datum/pda_app/cart/virus/honk/infect(var/obj/item/device/pda/P,var/mob/U)
    charges--
    U.show_message("<span class='notice'>Virus sent!</span>", 1)
    P.honkamt = (rand(15,20))

/obj/item/weapon/cartridge/mime
    name = "\improper Gestur-O 1000"
    icon_state = "cart-mi"
    starting_apps = list(/datum/pda_app/cart/virus/silent)

/datum/pda_app/cart/virus/silent
    desc = "..."

/datum/pda_app/cart/virus/silent/infect(var/obj/item/device/pda/P,var/mob/U)
    charges--
    U.show_message("<span class='notice'>Virus sent!</span>", 1)
    var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in P.applications
    if(app)
        app.silent = 1
        app.ttone = "silence"

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
    starting_apps = list(
        /datum/pda_app/cart/supply_records,
        /datum/pda_app/cart/mulebot,
    )
    radio_type = /obj/item/radio/integrated/signal/bot/mule

/datum/pda_app/cart/supply_records
    name = "Supply Records"
    desc = "Shows a list of supplies requested and on shuttle."
    category = "Quartermaster Functions"
    icon = "pda_crate"

/datum/pda_app/cart/supply_records/get_dat(var/mob/user)
    var/menu = {"<h4><span class='pda_icon pda_crate'></span> Supply Record Interlink</h4>
        <BR><B>Supply shuttle</B><BR>
        Location: [SSsupply_shuttle.moving ? "Moving to station ([SSsupply_shuttle.eta] Mins.)":SSsupply_shuttle.at_station ? "Station":"Dock"]<BR>
        Current approved orders: <BR><ol>"}
    for(var/S in SSsupply_shuttle.shoppinglist)
        var/datum/supply_order/SO = S
        menu += "<li>#[SO.ordernum] - [SO.object.name] approved by [SO.orderedby] [SO.comment ? "([SO.comment])":""]</li>"

    menu += {"</ol>
        Current requests: <BR><ol>"}
    for(var/S in SSsupply_shuttle.requestlist)
        var/datum/supply_order/SO = S
        menu += "<li>#[SO.ordernum] - [SO.object.name] requested by [SO.orderedby]</li>"
    menu += "</ol><font size=\"-3\">Upgrade NOW to Space Parts & Space Vendors PLUS for full remote order control and inventory management."
    return menu

/datum/pda_app/cart/mulebot
	name = "Delivery Bot Control"
	desc = "Used to control a MULE delivery bot."
	category = "Quartermaster Functions"
	icon = "pda_mule"

/datum/pda_app/cart/mulebot/get_dat(var/mob/user)
	var/dat = ""
	if (!cart_device)
		dat += {"<span class='pda_icon pda_mule'></span> Could not find radio peripheral connection <br/>"}
		return
	if (!istype(cart_device.radio, /obj/item/radio/integrated/signal/bot/mule))
		dat += {"<span class='pda_icon pda_mule'></span>Commlink bot error <br/>"}
		return
	// Building the data in the list
	dat += {"<span class='pda_icon pda_mule'></span><b>M.U.L.E. bot Interlink V1.0</h4> </b><br/>"}
	dat += "<ul>"
	for (var/obj/machinery/bot/mulebot/mule in bots_list)
		if (mule.z != user.z)
			continue
		dat += {"<li>
				<i>[mule]</i> - Charge: [mule.cell ? mule.cell.percent() : 0]%<br/>
				[mule.return_status()] in [get_area_name(mule)]<br/>"}
		var/atom/load = mule.return_load()
		if(load)
			dat += {"Loaded: [load.name] <br/>"}
		var/i = 1
		if(mule.current_order)
			dat += {"<b>Current</b>: [mule.destination] <br/>"}
			i++
		if(mule.destinations_queue.len)
			for(var/datum/bot/order/mule/order in mule.destinations_queue)
				dat += {"<b>&#35;[i]</b>: [order.loc_description] <br/>"}
				i++
		if(mule.destinations_queue.len || mule.current_order)
			if(!mule.destinations_queue.len)
				if(mule.current_order.returning)
					dat += {"<b>Auto</b>: Return Home</br>"}
			else
				var/datum/bot/order/mule/order = mule.destinations_queue[mule.destinations_queue.len]
				if(order?.returning)
					dat += {"<b>Auto</b>: Return Home</br>"}
		dat += {"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=switch_power;user=\ref[user]'>Turn [mule.on ? "off" : "on"]</a> <br/>"}
		if(mule.on)
			dat +=	{"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=summon;user=\ref[user]'>Summon Here </a><br/>"}
			dat +=	{"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=pause;user=\ref[user]'>[mule.mode == 6 ? "Unpause" : "Pause"] </a><br/>"}
			dat +=	{"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=clear_queue;user=\ref[user]'>Purge Queue </a><br/>"}
			dat += {"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=return_home;user=\ref[user]'>Send home</a> <br/>"}
			dat += {"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=honk;user=\ref[user]'>Honk</a> <br/>"}
			dat += {"<a href='?src=\ref[cart_device.radio];bot=\ref[mule];command=send_to;place=\ref[cart_device.saved_destination];user=\ref[user]'>Send to: [cart_device.saved_destination]</a> - <a href='?src=\ref[src];change_destination=1'>EDIT</a> <br/>
			</li>"}
		dat += {"<br/>"}
	dat += "</ul>"
	return dat

/datum/pda_app/cart/mulebot/Topic(href, href_list)
	if (..())
		return
	if (href_list["change_destination"])
		var/list/foundbeacons = list()
		for (var/obj/machinery/navbeacon/found in navbeacons)
			if(!found.location || !isturf(found.loc))
				continue
			if(found.freq == 1400)
				foundbeacons.Add(found.location)
		var/new_dest = input(usr, "Set the new destination", "New mulebot destination") as null|anything in foundbeacons
		if (new_dest)
			cart_device.saved_destination = new_dest
	refresh_pda()

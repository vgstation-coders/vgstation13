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

/datum/pda_app/cart/custodial_locator/get_dat()
    var/menu = "<h4><span class='pda_icon pda_bucket'></span> Persistent Custodial Object Locator</h4>"
    var/turf/cl = get_turf(src)
    if (!cl)
        menu += "ERROR: Unable to determine current location."
    else
        menu += "Current Orbital Location: <b>\[[cl.x-WORLD_X_OFFSET[cl.z]],[cl.y-WORLD_Y_OFFSET[cl.z]]\]</b>"
        menu += "<br><A href='byond://?src=\ref[src];choice=49'>(Refresh Coordinates)</a><br>"
        menu += "<h4>Located Mops:</h4>"
        var/ldat
        for (var/obj/item/weapon/mop/M in mop_list)
            var/turf/ml = get_turf(M)
            if(ml)
                if (ml.z != cl.z)
                    continue
                var/direction = get_dir(src, M)
                ldat += "Mop - <b>\[[ml.x-WORLD_X_OFFSET[ml.z]],[ml.y-WORLD_Y_OFFSET[ml.z]] ([uppertext(dir2text(direction))])\]</b> - [M.reagents.total_volume ? "Wet" : "Dry"]<br>"
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
                var/direction = get_dir(src, B)
                ldat += "Bucket - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]],[bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text(direction))])\]</b> - Water level: [B.reagents.total_volume]/100<br>"
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
                var/direction = get_dir(src, B)
                ldat += "Cleanbot - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]],[bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text(direction))])\]</b> - [B.on ? "Online" : "Offline"]<br>"
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
                var/direction = get_dir(src, J)
                ldat += "Jani-Cart - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]],[bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text(direction))])\]</b> - [J.upgraded ? "Upgraded" : "Unupgraded"]<br>"
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
                var/direction = get_dir(src, K)
                ldat += "Keys - <b>\[[bl.x-WORLD_X_OFFSET[bl.z]],[bl.y-WORLD_Y_OFFSET[bl.z]] ([uppertext(dir2text(direction))])\]</b><br>"
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
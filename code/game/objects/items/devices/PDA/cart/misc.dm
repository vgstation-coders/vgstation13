/obj/item/weapon/cartridge/syndicate
	name = "\improper Detomatix Cartridge"
	icon_state = "cart"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_SYNDICATE + "=2"
	mech_flags = MECH_SCAN_ILLEGAL
	var/shock_charges = 4

/datum/pda_app/cart/virus
    name = "Virus"
    desc = "Sends to 5 PDAs"
    menu = FALSE //Shows up elsewhere
    var/charges = 5

/datum/pda_app/cart/virus/Topic(href, href_list)
    if(..())
        return
    var/mob/living/U = usr
    if(href_list["target"])
        var/obj/item/device/pda/P = locate(href_list["target"])//Leaving it alone in case it may do something useful, I guess.
        if(!isnull(P))
            var/pass = FALSE
            for (var/obj/machinery/message_server/MS in message_servers)
                if(MS.is_functioning())
                    pass = TRUE
                    break
            var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in P.applications
            if(!pass)
                to_chat(U, "<span class='notice'>ERROR: Messaging server is not responding.</span>")
            else if (!app.toff && charges > 0)
                infect(P,U)
        else
            to_chat(U, "PDA not found.")
    refresh_pda()

/datum/pda_app/cart/virus/proc/infect(var/obj/item/device/pda/P,var/mob/U)
    return

/datum/pda_app/cart/virus/detonate
    name = "Detonate PDA"
    desc = "And maybe a leg too in the process"
    icon = "pda_boom"

/datum/pda_app/cart/virus/detonate/infect(var/obj/item/device/pda/P,var/mob/U)
    var/difficulty = 0

    if(locate(/datum/pda_app/cart/medical_records) in P.cartridge.applications)
        difficulty += 1
    if(locate(/datum/pda_app/cart/security_records) in P.cartridge.applications)
        difficulty += 1
    if(locate(/datum/pda_app/cart/power_monitor) in P.cartridge.applications)
        difficulty += 1
    if(locate(/datum/pda_app/cart/honk) in P.cartridge.applications)
        difficulty += 1
    if(locate(/datum/pda_app/cart/custodial_locator) in P.cartridge.applications)
        difficulty += 1
    difficulty += 2

    if(P.get_component(/datum/component/uplink))
        U.show_message("<span class='warning'>An error flashes on your [src]; [pick(syndicate_code_response)]</span>", 1)
        U << browse(null, "window=pda")
        var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in P.applications
        if(app)
            app.create_message(null, P, null, null, pick(syndicate_code_phrase)) //friendly fire
        log_admin("[key_name(U)] attempted to blow up syndicate [P] with the Detomatix cartridge but failed")
        message_admins("[key_name_admin(U)] attempted to blow up syndicate [P] with the Detomatix cartridge but failed", 1)
        charges--
    else if (!P.detonate || prob(difficulty * 2))
        U.show_message("<span class='warning'>An error flashes on your [src]; [pick("Encryption","Connection","Verification","Handshake","Detonation","Injection")] error!</span>", 1)
        U << browse(null, "window=pda")
        var/list/garble = list()
        var/randomword
        for(garble = list(), garble.len<10,garble.Add(randomword))
            randomword = pick("stack.Insert","KillProcess(","-DROP TABLE","kernel = "," / 0",";",";;","{","(","((","<"," ","-", "null", " * 1.#INF")
        var/message = english_list(garble, "", "", "", "")
        var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in P.applications
        if(app)
            app.create_message(null, P, null, null, message) //the jig is up
        log_admin("[key_name(U)] attempted to blow up [P] with the Detomatix cartridge but failed")
        message_admins("[key_name_admin(U)] attempted to blow up [P] with the Detomatix cartridge but failed", 1)
        charges--
    else
        U.show_message("<span class='notice'>Success!</span>", 1)
        log_admin("[key_name(U)] attempted to blow up [P] with the Detomatix cartridge and succeeded")
        message_admins("[key_name_admin(U)] attempted to blow up [P] with the Detomatix cartridge and succeeded", 1)
        charges--
        P.explode(U)

/obj/item/weapon/cartridge/syndicatedoor
	name = "\improper Doorman Cartridge"
	starting_apps = list(/datum/pda_app/cart/remote_door)

/datum/pda_app/cart/remote_door
    name = "Toggle Remote Door"
    desc = "Toggles a remote pod door somewhere, preferably on a tightly secure shuttle of sorts."
    category = "Utilities"
    has_screen = FALSE
    icon = "pda_rdoor"
    var/remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!

/datum/pda_app/cart/remote_door/on_select(var/mob/user)
	for(var/obj/machinery/door/poddoor/M in poddoors)
		if(M.id_tag == remote_door_id)
			if(M.density)
				M.open()
				to_chat(user, "<span class='notice'>The shuttle's outer airlock is now open!</span>")
			else
				M.close()
				to_chat(user, "<span class='notice'>The shuttle's outer airlock is now closed!</span>")

/obj/item/weapon/cartridge/trader
    name = "\improper Trader Cartridge"
    icon_state = "cart-vox"
    starting_apps = list(/datum/pda_app/cart/send_shuttle)

/datum/pda_app/cart/send_shuttle
    name = "Send Trader Shuttle"
    desc = "Sends a shuttle to either your outpost or the station."
    category = "Utilities"
    has_screen = FALSE
    icon = "pda_rdoor"

/datum/pda_app/cart/send_shuttle/on_select(var/mob/user)
    if(pda_device && pda_device.id && can_access(pda_device.id.access,list(access_trade)))
        var/obj/machinery/computer/shuttle_control/C = global.trade_shuttle.control_consoles[1] //There should be exactly one
        if(C) //Just send it; this has all relevant checks
            global.trade_shuttle.travel_to(pick(global.trade_shuttle.docking_ports - global.trade_shuttle.current_port),C,user)

/obj/item/weapon/cartridge/camera
    name = "\improper Camera Cartridge"
    icon_state = "cart-gbcam"
    starting_apps = list(
        /datum/pda_app/cart/scanner/camera,
        /datum/pda_app/cart/show_photos,
    )
    var/obj/item/device/camera/cartridge/cart_cam = null
    var/list/obj/item/weapon/photo/stored_photos = list()

/obj/item/weapon/cartridge/camera/New()
	..()
	cart_cam = new /obj/item/device/camera/cartridge(src)
	
/obj/item/weapon/cartridge/camera/Destroy()
	qdel(cart_cam)
	cart_cam = null
	for(var/obj/item/weapon/photo/PH in stored_photos)
		qdel(PH)
	stored_photos = list()
	..()

/datum/pda_app/cart/scanner/camera
    base_name = "Camera"
    desc = "Used to take pictures with a camera."
    category = "Utilities"
    app_scanmode = SCANMODE_CAMERA

/datum/pda_app/cart/scanner/camera/on_select(var/mob/user)
    ..(user)
    if(cart_device)
        cart_device.update_icon() //To make it look the part

/datum/pda_app/cart/show_photos
    name = "Show Photos"
    desc = "Used to show photos taken with a camera."
    category = "Utilities"

/datum/pda_app/cart/show_photos/get_dat(var/mob/user)
    var/dat = {"<h4>View Photos</h4>"}
    if(!cart_device || !istype(cart_device,/obj/item/weapon/cartridge/camera))
        dat += {"No camera found!"}
    else
        dat += {"<a href='byond://?src=\ref[src];Clear Photos=1'>Delete All Photos</a><hr>"}
        var/obj/item/weapon/cartridge/camera/CM = cart_device
        if(!CM.stored_photos.len)
            dat += {"None found."}
        else
            var/i = 0
            for(var/obj/item/weapon/photo/PH in CM.stored_photos)
                user << browse_rsc(PH.img, "tmp_photo_gallery_[i].png")
                var/displaylength = 192
                switch(PH.photo_size)
                    if(5)
                        displaylength = 320
                    if(7)
                        displaylength = 448

                dat += {"<img src='tmp_photo_gallery_[i].png' width='[displaylength]' style='-ms-interpolation-mode:nearest-neighbor' /><hr>"}
                i++
    return dat

/datum/pda_app/cart/show_photos/Topic(href, href_list)
    if(..() || !cart_device)
        return
    if(href_list["Clear Photos"])
        if(cart_device && istype(cart_device, /obj/item/weapon/cartridge/camera))
            var/obj/item/weapon/cartridge/camera/CM = cart_device
            for(var/obj/item/weapon/photo/PH in CM.stored_photos)
                qdel(PH)
            CM.stored_photos = list()
    refresh_pda()
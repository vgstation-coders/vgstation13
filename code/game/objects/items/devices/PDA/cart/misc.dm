/obj/item/weapon/cartridge/syndicate
	name = "\improper Detomatix Cartridge"
	icon_state = "cart"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_SYNDICATE + "=2"
	mech_flags = MECH_SCAN_ILLEGAL
	var/shock_charges = 4

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
	access_camera = 1
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
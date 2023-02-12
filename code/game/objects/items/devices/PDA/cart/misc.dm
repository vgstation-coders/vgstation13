/obj/item/weapon/cartridge/syndicate
	name = "\improper Detomatix Cartridge"
	icon_state = "cart"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_SYNDICATE + "=2"
	mech_flags = MECH_SCAN_ILLEGAL
	starting_apps = list(/datum/pda_app/cart/virus/detonate)

/datum/pda_app/cart/virus
	name = "Send Virus"
	desc = "Sends to 5 PDAs"
	menu = FALSE //Shows up elsewhere
	var/charges = 5
	var/virus_type = "viral files"

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
	name = "Detonate"
	desc = "And maybe a leg too in the process"
	icon = "pda_boom"
	virus_type = "detonation charges"

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
	else if (!(src.type in P.accepted_viruses) || prob(difficulty * 2))
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

/obj/item/weapon/cartridge/syndifake
	name = "\improper F.R.A.M.E. Cartridge"
	icon_state = "cart"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_SYNDICATE + "=2"
	mech_flags = MECH_SCAN_ILLEGAL
	starting_apps = list(/datum/pda_app/cart/virus/fake_uplink)
	var/uses = 0

/obj/item/weapon/cartridge/syndifake/attackby(var/obj/item/W, var/mob/user)
	if(..())
		return
	if(istype(W, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/crystals = W
		uses += crystals.amount
		to_chat(user, "<span class='notice'>You insert [crystals.amount] telecrystal[crystals.amount > 1 ? "s" : ""] into the cartridge.</span>")
		crystals.use(crystals.amount)

/obj/item/weapon/cartridge/syndifake/attack_self(var/mob/user)
	if(..())
		return
	if(uses)
		var/obj/item/stack/telecrystal/crystals = new(user.loc, uses)
		to_chat(user, "<span class='notice'>You remove [crystals.amount] telecrystal[crystals.amount > 1 ? "s" : ""] from the cartridge.</span>")
		uses = 0
		user.put_in_hands(crystals)

/datum/pda_app/cart/virus/fake_uplink
	name = "Send Uplink"
	desc = "Frame someone as a tator"
	icon = "pda_boom"
	virus_type = "fake uplinks"

/datum/pda_app/cart/virus/fake_uplink/infect(var/obj/item/device/pda/P,var/mob/U)
	if(P.get_component(/datum/component/uplink))
		U.show_message("<span class='warning'>An error flashes on your [src]; [pick(syndicate_code_response)]</span>", 1)
		U << browse(null, "window=pda")
		var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in P.applications
		if(app)
			app.create_message(null, P, null, null, pick(syndicate_code_phrase)) //friendly fire
		charges--
	else
		var/datum/component/uplink/new_uplink = P.add_component(/datum/component/uplink)
		if(istype(cart_device,/obj/item/weapon/cartridge/syndifake))
			var/obj/item/weapon/cartridge/syndifake/SF = cart_device
			new_uplink.telecrystals = SF.uses
		else
			new_uplink.telecrystals = 0
		var/datum/component/uplink/our_uplink = pda_device.get_component(/datum/component/uplink)
		if(!our_uplink && U.mind)
			our_uplink = U.mind.find_syndicate_uplink()
		if(our_uplink)
			new_uplink.unlock_code = our_uplink.unlock_code
		new_uplink.locked = FALSE
		U.show_message("<span class='notice'>Success! Unlock the PDA by entering [new_uplink.unlock_code] into it.</span>", 1)
		if(U.mind)
			U.mind.store_memory("<B>Uplink Passcode:</B> [new_uplink.unlock_code] ([P.name]).")

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
			C.try_move()

/obj/item/weapon/cartridge/camera
	name = "\improper Camera Cartridge"
	icon_state = "cart-gbcam"
	starting_apps = list(
		/datum/pda_app/cart/scanner/camera,
		/datum/pda_app/cart/show_photos,
	)
	var/obj/item/device/camera/cartridge/cart_cam = null
	var/list/obj/item/weapon/photo/stored_photos = list()
	var/photo_number = 0

/obj/item/weapon/cartridge/camera/New()
	..()
	cart_cam = new /obj/item/device/camera/cartridge(src)

/obj/item/weapon/cartridge/camera/Destroy()
	QDEL_NULL(cart_cam)
	for(var/obj/item/weapon/photo/PH in stored_photos)
		qdel(PH)
	stored_photos = list()
	..()

/datum/pda_app/cart/scanner/camera
	base_name = "Camera"
	desc = "Used to take pictures with a camera."
	category = "Utilities"

/datum/pda_app/cart/scanner/camera/on_select(var/mob/user)
	..(user)
	if(pda_device)
		pda_device.update_icon() //To make it look the part

/datum/pda_app/cart/scanner/camera/afterattack(atom/A, mob/user, proximity_flag)
	if (cart_device && istype(cart_device, /obj/item/weapon/cartridge/camera))
		var/obj/item/weapon/cartridge/camera/CM = cart_device
		if(!CM.cart_cam)
			return
		CM.cart_cam.captureimage(A, user, proximity_flag)
		to_chat(user, "<span class='notice'>New photo added to camera.</span>")
		playsound(pda_device.loc, "polaroid", 75, 1, -3)

/datum/pda_app/cart/show_photos
	name = "Show Photos"
	desc = "Used to show photos taken with a camera."
	category = "Utilities"

/datum/pda_app/cart/show_photos/get_dat(var/mob/user)
	var/dat = {"<h4>View Photos</h4>"}
	if(!cart_device || !istype(cart_device,/obj/item/weapon/cartridge/camera))
		dat += {"No camera found!"}
	else
		dat += {"<a href='byond://?src=\ref[src];Clear Photos=1'>Delete All Photos</a><br><br>"}
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

				dat += {"<div style='float: left'> <img src='tmp_photo_gallery_[i].png' width='[displaylength]' style='-ms-interpolation-mode:nearest-neighbor' /> </div>"}
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
			CM.photo_number = 0
	refresh_pda()

#define MAX_DESIGNS 10

#define SCANMODE_NONE		0
#define SCANMODE_MEDICAL	1
#define SCANMODE_FORENSIC	2
#define SCANMODE_REAGENT	3
#define SCANMODE_HALOGEN	4
#define SCANMODE_ATMOS		5
#define SCANMODE_DEVICE		6
#define SCANMODE_ROBOTICS	7
#define SCANMODE_HAILER		8
#define SCANMODE_CAMERA		9

#define PDA_MINIMAP_WIDTH	256
#define PDA_MINIMAP_OFFSET_X	8
#define PDA_MINIMAP_OFFSET_Y	233

//The advanced pea-green monochrome lcd of tomorrow.

var/global/list/obj/item/device/pda/PDAs = list()
var/global/msg_id = 0

/obj/item/device/pda
	name = "\improper PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. Functionality determined by a pre-programmed ROM cartridge. Can download additional applications from PDA terminals."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_ID | SLOT_BELT

	//Main variables
	var/owner = null
	var/default_cartridge = 0 // Access level defined by cartridge
	var/obj/item/weapon/cartridge/cartridge = null //current cartridge
	var/mode = 0 //Controls what menu the PDA will display. 0 is hub; the rest are either built in or based on cartridge.

	//Secondary variables
	var/scanmode = SCANMODE_NONE //used for various PDA scanning functions
	var/lock_code = "" // Lockcode to unlock uplink
	var/honkamt = 0 //How many honks left when infected with honk.exe
	var/mimeamt = 0 //How many silence left when infected with mime.exe
	var/detonate = 1 // Can the PDA be blown up?
	var/hidden = 0 // Is the PDA hidden from the PDA list?
	var/show_overlays = TRUE

	var/obj/item/weapon/card/id/id = null //Making it possible to slot an ID card into the PDA so it can function as both.
	var/ownjob = null //related to above

	var/obj/item/device/paicard/pai = null	// A slot for a personal AI device
	var/obj/item/weapon/photo/photo = null	// A slot for a photo
	var/obj/item/device/analyzer/atmos_analys = new
	var/obj/item/device/robotanalyzer/robo_analys = new
	var/obj/item/device/hailer/integ_hailer = new
	var/obj/item/device/device_analyser/dev_analys = null

	var/MM = null
	var/DD = null

	//All applications in this PDA
	var/list/datum/pda_app/applications = list()
	//Associative list with header to file under and list of apps underneath, built from header defined in app.
	var/list/categorised_applications = list("General Functions" = list())
	var/list/starting_apps = list(
		/datum/pda_app/alarm,
		/datum/pda_app/notekeeper,
		/datum/pda_app/messenger,
		/datum/pda_app/multimessage,
		/datum/pda_app/events,
		/datum/pda_app/manifest,
		/datum/pda_app/balance_check,
		/datum/pda_app/atmos_scan,
		/datum/pda_app/light,
	)
	var/datum/pda_app/current_app = null
	var/datum/asset/simple/assets_to_send = null

/obj/item/device/pda/New()
	..()
	for(var/app_type in starting_apps)
		var/datum/pda_app/app = new app_type()
		app.onInstall(src)

	PDAs += src
	if(default_cartridge)
		cartridge = new default_cartridge(src)
		// PDA being given out to people during the cuck cube
		if(ticker && ticker.current_state >= GAME_STATE_SETTING_UP)
			cartridge.initialize()
	new /obj/item/weapon/pen(src)
	MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	DD = text2num(time2text(world.timeofday, "DD")) 	// get the day

/obj/item/device/pda/initialize()
	. = ..()
	if (cartridge)
		cartridge.initialize()

/obj/item/device/pda/update_icon()
	underlays.Cut()
	underlays = list()
	if (istype(cartridge,/obj/item/weapon/cartridge/camera))
		var/image/cam_under
		if(scanmode == SCANMODE_CAMERA)
			cam_under = image("icon" = "icons/obj/pda.mi", "icon_state" = "cart-gbcam2")
		else
			cam_under = image("icon" = "icons/obj/pda.mi", "icon_state" = "cart-gbcam")
		cam_under.pixel_y = 8
		underlays += cam_under

/obj/item/device/pda/proc/can_use(mob/user)
	if(user && ismob(user))
		if(user.incapacitated())
			return 0
		if(loc == user)
			return 1
	return 0

/obj/item/device/pda/GetAccess()
	if(id)
		return id.GetAccess()
	else
		return ..()

/obj/item/device/pda/GetID()
	return id

/obj/item/device/pda/get_owner_name_from_ID()
	return owner

/obj/item/device/pda/MouseDropFrom(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if((!istype(over_object, /obj/abstract/screen)) && can_use(M))
		return attack_self(M)
	return ..()

//NOTE: graphic resources are loaded on client login
/obj/item/device/pda/attack_self(mob/user as mob)

	user.set_machine(src)

	var/datum/pda_app/station_map/map_app = locate(/datum/pda_app/station_map) in applications
	if (map_app && map_app.holomap)
		map_app.holomap.stopWatching()

	. = ..()
	if(.)
		return

	if(user.client)
		var/datum/asset/simple/C = new/datum/asset/simple/pda()
		send_asset_list(user.client, C.assets)

	var/dat = list()
	dat += {"
	<html>
	<head><title>Personal Data Assistant</title></head>
	<body>
	<link rel="stylesheet" type="text/css" href="pda.css"/> <!--This stylesheet contains all the PDA icons in base 64!-->
	"}
	if ((!isnull(cartridge)) && (mode == 0))
		dat += "<a href='byond://?src=\ref[src];choice=Eject'><span class='pda_icon pda_eject'></span> Eject [cartridge]</a> | "
	if (mode)
		dat += "<a href='byond://?src=\ref[src];choice=Return'><span class='pda_icon pda_menu'></span> Return</a> | "

	dat += {"<a href='byond://?src=\ref[src];choice=Refresh'><span class='pda_icon pda_refresh'></span> Refresh</a>
		<br>"}
	if (!owner)

		dat += {"Warning: No owner information entered.  Please swipe card.<br><br>
			<a href='byond://?src=\ref[src];choice=Refresh'><span class='pda_icon pda_refresh'></span> Retry</a>"}
	else
		switch (mode)
			if (0)
				dat += {"<h2>PERSONAL DATA ASSISTANT v.1.4</h2>
					Owner: [owner], [ownjob]<br>"}
				dat += text("ID: <A href='?src=\ref[src];choice=Authenticate'>[id ? "[id.registered_name], [id.assignment]" : "----------"]")
				dat += text("<br><A href='?src=\ref[src];choice=UpdateInfo'>[id ? "Update PDA Info" : ""]</A><br><br>")


				dat += "Station Time: [worldtime2text()]"
				var/datum/pda_app/alarm/alarm_app = locate(/datum/pda_app/alarm) in applications
				if(alarm_app)
					dat +=  "<a href='byond://?src=\ref[src];choice=appMode;appChoice=\ref[alarm_app]'><span class='pda_icon pda_clock'></span> Set Alarm</a>"
				dat += "<br><br><ul><li><a href='byond://?src=\ref[src];choice=2'><span class='pda_icon pda_mail'></span> Messenger</a></li></ul>"

				if (pai)
					if(pai.loc != src)
						pai = null
					else
						dat += {"<ul><li><a href='byond://?src=\ref[src];choice=pai;option=1'>pAI Device Configuration</a></li>
							<li><a href='byond://?src=\ref[src];choice=pai;option=2'>Eject pAI Device</a></li></ul>"}

				if(applications.len == 0)
					dat += {"<h4>No application currently installed.</h4>"}
				else if(categorised_applications.len == 0)
					dat += {"<h4>Unsorted Applications</h4>"}
					dat += {"<ul>"}
					for(var/datum/pda_app/app in applications)
						if(app.menu)
							dat += {"<li><a href='byond://?src=\ref[src];choice=appMode;appChoice=\ref[app]'>[app.icon ? "<span class='pda_icon [app.icon]'></span> " : ""][app.name]</a></li>"}
					dat += {"</ul>"}
				else
					for(var/category_title in categorised_applications)
						dat += {"<h4>[category_title]</h4>"}
						dat += {"<ul>"}
						for(var/datum/pda_app/app in categorised_applications[category_title])
							if(app.menu)
								dat += {"<li><a href='byond://?src=\ref[src];choice=appMode;appChoice=\ref[app]'>[app.icon ? "<span class='pda_icon [app.icon]'></span> " : ""][app.name]</a></li>"}
						dat += {"</ul>"}

			//(1) is for the app screen, and not here

	if(assets_to_send && user.client) //If we have a client to send to, in reality none of this proc is needed in that case but eh I don't care.
		send_asset_list(user.client, assets_to_send.assets)

	if(current_app)
		if(current_app.pda_device) // Taking it from a PDA app instead
			dat += current_app.get_dat(user)
		else if(!current_app.pda_device)
			dat += "<br><h4>ERROR #0x327AA0EF: App failed to start. Please report this issue to your vendor of purchase.</h4>"

	dat += "</body></html>"
	dat = jointext(dat,"") //Optimize BYOND's shittiness by making "dat" actually a list of strings and join it all together afterwards! Yes, I'm serious, this is actually a big deal

	user << browse(dat, "window=pda;size=400x444;border=1;can_resize=1;can_minimize=0")
	onclose(user, "pda", src)

/obj/item/device/pda/Topic(href, href_list)
	if(..())
		return
	var/mob/living/U = usr

	if (href_list["close"])
		if (U.machine == src)
			U.unset_machine()

		return

	//Looking for master was kind of pointless since PDAs don't appear to have one.
	//if ((src in U.contents) || ( istype(loc, /turf) && in_range(src, U) ) )
	var/no_refresh = FALSE
	if ((href_list["choice"] != "1") || (href_list["choice"] == "1" && !istype(href_list["appChoice"],/datum/pda_app/station_map)))//The holomap app
		var/datum/pda_app/station_map/map_app = locate(/datum/pda_app/station_map) in applications
		if (map_app && map_app.holomap)
			map_app.holomap.stopWatching()

	if (!can_use(U)) //Why reinvent the wheel? There's a proc that does exactly that.
		U.unset_machine()
		U << browse(null, "window=pda")
		return

	add_fingerprint(U)
	U.set_machine(src)
	var/datum/pda_app/old_app = current_app
	var/datum/asset/simple/old_assets = assets_to_send
	current_app = null // Reset to make it something else
	assets_to_send = null // Reset to make it something else

	switch(href_list["choice"])

//BASIC FUNCTIONS===================================
		if("Refresh")//Refresh, goes to the end of the proc.
			current_app = old_app //To keep it around afterwards.
			assets_to_send = old_assets //Same here.
		if("Return")//Return
			mode = 0
		if ("Authenticate")//Checks for ID
			id_check(U, 1)
		if("UpdateInfo")
			ownjob = id.assignment
			name = "PDA-[owner] ([ownjob])"
		if("Eject")//Ejects the cart, only done from hub.
			if (!isnull(cartridge))
				for(var/datum/pda_app/app in cartridge.applications)
					app.onUninstall()
				var/turf/T = loc
				if(ismob(T))
					T = T.loc
				U.put_in_hands(cartridge)
				scanmode = SCANMODE_NONE
				if (cartridge.radio)
					cartridge.radio.hostpda = null
				cartridge = null
				update_icon()
		if("Eject Photo")
			if(photo)
				U.put_in_hands(photo)
				photo = null

//APPLICATIONS FUNCTIONS===========================
		if("appMode")
			current_app = locate(href_list["appChoice"]) in applications
			current_app.on_select(U)
			no_refresh = current_app.no_refresh //If set in on_select
			current_app.no_refresh = FALSE //Resets for next time
			if(current_app.has_screen)
				mode = 1

			if(current_app.assets_type && usr.client)
				assets_to_send = new current_app.assets_type()

//pAI FUNCTIONS===================================
		if("pai")
			switch(href_list["option"])
				if("1")		// Configure pAI device
					pai.attack_self(U)
				if("2")		// Eject pAI device
					U.put_in_hands(pai)

//EXTRA FUNCTIONS===================================

	if (mode == 2||mode == 3)//To clear message overlays.
		overlays.len = 0

	if ((honkamt > 0) && (prob(60)))//For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, 1)

	if (!no_refresh)
		if(U.machine == src && href_list["skiprefresh"]!="1")//Final safety.
			attack_self(U)//It auto-closes the menu prior if the user is not in range and so on.
		else
			U.unset_machine()
			U << browse(null, "window=pda")

/obj/item/device/pda/proc/remove_id()
	if (id)
		if (ismob(loc))
			var/mob/M = loc
			M.put_in_hands(id)
			to_chat(usr, "<span class='notice'>You remove \the [id] from the [name].</span>")
		else
			id.forceMove(get_turf(src))
		id = null

/obj/item/device/pda/verb/verb_remove_id()
	set category = "Object"
	set name = "Remove id"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		if(id)
			remove_id()
		else
			to_chat(usr, "<span class='notice'>This PDA does not have an ID in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/pda/CtrlClick()
	if ( can_use(usr) ) // Checks that the PDA is in our inventory. This will be checked by the proc anyways, but we don't want to generate an error message if not.
		verb_remove_pen(usr)
		return
	return ..()

/obj/item/device/pda/verb/verb_remove_pen()
	set category = "Object"
	set name = "Remove pen"
	set src in usr

	if(issilicon(usr))
		return

	if ( can_use(usr) )
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			if (istype(loc, /mob))
				var/mob/M = loc
				if(M.get_active_hand() == null)
					M.put_in_hands(O)
					to_chat(usr, "<span class='notice'>You remove \the [O] from \the [src].</span>")
					return
			O.forceMove(get_turf(src))
		else
			to_chat(usr, "<span class='notice'>This PDA does not have a pen in it.</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while restrained.</span>")

/obj/item/device/pda/AltClick()
	if ( can_use(usr) ) // Checks that the PDA is in our inventory. This will be checked by the proc anyways, but we don't want to generate an error message if not.
		verb_remove_id(usr)
		return
	return ..()

/obj/item/device/pda/proc/id_check(mob/user as mob, choice as num)//To check for IDs; 1 for in-pda use, 2 for out of pda use.
	if(choice == 1)
		if (id)
			remove_id()
		else
			var/obj/item/I = user.get_active_hand()
			if (istype(I, /obj/item/weapon/card/id))
				if(user.drop_item(I, src))
					id = I
	else
		var/obj/item/weapon/card/I = user.get_active_hand()
		if (istype(I, /obj/item/weapon/card/id) && I:registered_name)
			var/obj/old_id = id
			if(user.drop_item(I, src))
				id = I
				user.put_in_hands(old_id)
	var/datum/pda_app/messenger/message_app = locate(/datum/pda_app/messenger) in applications
	if(message_app && id && message_app.incoming_transactions.len)
		message_app.receive_incoming_transactions(id)
	return

// access to status display signals
/obj/item/device/pda/attackby(obj/item/C as obj, mob/user as mob)
	. = ..()
	if(.)
		return
	if(istype(C, /obj/item/weapon/cartridge) && !cartridge)
		if(user.drop_item(C, src))
			cartridge = C
			to_chat(user, "<span class='notice'>You insert [cartridge] into [src].</span>")
			update_icon()
			if(cartridge.radio)
				cartridge.radio.hostpda = src
			for(var/datum/pda_app/app in cartridge.applications)
				if(istype(app,/datum/pda_app/cart))
					var/datum/pda_app/cart/cart_app = app
					cart_app.onInstall(src,cartridge)
				else
					app.onInstall(src)

	else if(istype(C, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/idcard = C
		if(!idcard.registered_name)
			to_chat(user, "<span class='notice'>\The [src] rejects the ID.</span>")
			return
		if(!owner)
			owner = idcard.registered_name
			ownjob = idcard.assignment
			name = "PDA-[owner] ([ownjob])"
			to_chat(user, "<span class='notice'>Card scanned.</span>")
		else
			//Basic safety check. If either both objects are held by user or PDA is on ground and card is in hand.
			if(((src in user.contents) && (C in user.contents)) || (istype(loc, /turf) && in_range(src, user) && (C in user.contents)) )
				if( can_use(user) )//If they can still act.
					id_check(user, 2)
					to_chat(user, "<span class='notice'>You put \the [C] into \the [src]'s slot.</span>")
					var/datum/pda_app/messenger/message_app = locate(/datum/pda_app/messenger) in applications
					if(message_app && message_app.incoming_transactions.len)
						message_app.receive_incoming_transactions(id)
					updateSelfDialog()//Update self dialog on success.
			return	//Return in case of failed check or when successful.
		updateSelfDialog()//For the non-input related code.
	else if(istype(C, /obj/item/device/paicard) && !src.pai)
		if(user.drop_item(C, src))
			pai = C
			to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
			updateUsrDialog()
	else if(istype(C, /obj/item/weapon/photo) && !src.photo)
		if(user.drop_item(C, src))
			photo = C
			to_chat(user, "<span class='notice'>You slot \the [C] into [src].</span>")
			updateUsrDialog()
	else if(istype(C, /obj/item/weapon/pen))
		var/obj/item/weapon/pen/O = locate() in src
		if(O)
			to_chat(user, "<span class='notice'>There is already a pen in \the [src].</span>")
		else
			if(user.drop_item(C, src))
				to_chat(user, "<span class='notice'>You slide \the [C] into \the [src].</span>")
	else if(istype(C,/obj/item/weapon/spacecash))
		if(!id)
			to_chat(user, "[bicon(src)]<span class='warning'>There is no ID in the PDA!</span>")
			return
		var/obj/item/weapon/spacecash/dosh = C
		if(add_to_virtual_wallet(dosh.worth * dosh.amount, user))
			to_chat(user, "<span class='info'>You insert [dosh.worth * dosh.amount] credit\s into the PDA.</span>")
			qdel(dosh)
		updateDialog()

/obj/item/device/pda/proc/add_to_virtual_wallet(var/amount, var/mob/user, var/atom/giver)
	if(!id)
		return 0
	if(id.add_to_virtual_wallet(amount, user, giver))
		if(prob(50))
			playsound(loc, 'sound/items/polaroid1.ogg', 50, 1)
		else
			playsound(loc, 'sound/items/polaroid2.ogg', 50, 1)
		return 1
	return 0

/obj/item/device/pda/attack(mob/living/carbon/C, mob/living/user as mob)
	if(istype(C))
		switch(scanmode)

			if(SCANMODE_MEDICAL)
				healthanalyze(C,user,1)

			if(SCANMODE_FORENSIC)
				if (!istype(C:dna, /datum/dna))
					to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else if(!istype(C, /mob/living/carbon/monkey))
					if(!isnull(C:gloves))
						to_chat(user, "<span class='notice'>No fingerprints found on [C]</span>")
				else
					to_chat(user, text("<span class='notice'>[C]'s Fingerprints: [md5(C.dna.uni_identity)]</span>"))
				if ( !(C:blood_DNA) )
					to_chat(user, "<span class='notice'>No blood found on [C]</span>")
					if(C:blood_DNA)
						qdel(C:blood_DNA)
						C:blood_DNA = null
				else
					to_chat(user, "<span class='notice'>Blood found on [C]. Analysing...</span>")
					spawn(15)
						for(var/blood in C:blood_DNA)
							to_chat(user, "<span class='notice'>Blood type: [C:blood_DNA[blood]]\nDNA: [blood]</span>")

			if(SCANMODE_HALOGEN)
				for (var/mob/O in viewers(C, null))
					O.show_message("<span class='warning'>[user] has analyzed [C]'s radiation levels!</span>", 1)

				user.show_message("<span class='notice'>Analyzing Results for [C]:</span>")
				if(C.radiation)
					user.show_message("<span class='good'>Radiation Level: </span>[C.radiation]")
				else
					user.show_message("<span class='notice'>No radiation detected.</span>")

/obj/item/device/pda/afterattack(atom/A, mob/user, proximity_flag)
	if(scanmode == SCANMODE_ATMOS)
		if(!atmos_analys || !proximity_flag)
			return
		atmos_analys.cant_drop = 1
		if(!A.attackby(atmos_analys, user))
			atmos_analys.afterattack(A, user, 1)

	else if(scanmode == SCANMODE_ROBOTICS)
		if(!robo_analys || !proximity_flag)
			return
		robo_analys.cant_drop = 1
		if(!A.attackby(robo_analys, user))
			robo_analys.afterattack(A, user, 1)

	else if(scanmode == SCANMODE_HAILER)
		if(!integ_hailer)
			return
		integ_hailer.cant_drop = 1
		integ_hailer.afterattack(A, user, proximity_flag)

	else if (scanmode == SCANMODE_CAMERA && cartridge && istype(cartridge, /obj/item/weapon/cartridge/camera))
		var/obj/item/weapon/cartridge/camera/CM = cartridge
		if(!CM.cart_cam)
			return
		CM.cart_cam.captureimage(A, user, proximity_flag)
		to_chat(user, "<span class='notice'>New photo added to camera.</span>")
		playsound(loc, "polaroid", 75, 1, -3)

	else if (!scanmode && istype(A, /obj/item/weapon/paper) && owner)
		var/datum/pda_app/notekeeper/app = locate(/datum/pda_app/notekeeper) in applications
		if(app)
			app.note = A:info
			to_chat(user, "<span class='notice'>Paper scanned.</span>")//concept of scanning paper copyright brainoblivion 2009

/obj/item/device/pda/preattack(atom/A as mob|obj|turf|area, mob/user as mob)
	switch(scanmode)
		if(SCANMODE_REAGENT)
			if(!A.Adjacent(user))
				return
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					to_chat(user, "<span class='notice'>[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found.</span>")
					for (var/datum/reagent/re in A.reagents.reagent_list)
						to_chat(user, "<span class='notice'>\t [re]: [re.volume] units</span>")
				else
					to_chat(user, "<span class='notice'>No active chemical agents found in [A].</span>")
			else
				to_chat(user, "<span class='notice'>No significant chemical agents found in [A].</span>")
			. = 1

		if (SCANMODE_DEVICE)
			if(dev_analys) //let's use this instead. Much neater
				dev_analys.cant_drop = 1
				dev_analys.max_designs = 5
				if(A.Adjacent(user))
					return dev_analys.preattack(A, user, 1)

/obj/item/device/pda/proc/explode(var/mob/user) //This needs tuning.
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("<span class='warning'>Your [src] explodes!</span>", 1)

	if(T)
		T.hotspot_expose(700,125,surfaces=istype(loc,/turf))

		explosion(T, -1, -1, 2, 3, whodunnit = user)

	qdel(src)
	return

/obj/item/device/pda/Destroy()
	PDAs -= src

	if (src.id)
		src.id.forceMove(get_turf(src.loc))
		id = null

	if(src.pai)
		src.pai.forceMove(get_turf(src.loc))
		pai = null

	if(cartridge)
		if (cartridge.radio)
			cartridge.radio.hostpda = null
		qdel(cartridge)
		cartridge = null

	if(atmos_analys)
		qdel(atmos_analys)
		atmos_analys = null

	if(robo_analys)
		qdel(robo_analys)
		robo_analys = null

	if(dev_analys)
		qdel(dev_analys)
		dev_analys = null

	for(var/A in applications)
		qdel(A)

	..()

/obj/item/device/pda/Del()
	var/loop_count = 0
	while(null in PDAs)
		PDAs.Remove(null)
		if(loop_count > 10)
			break
		loop_count++
	PDAs -= src
	..()

/obj/item/device/pda/dropped(var/mob/user)
	var/datum/pda_app/station_map/map_app = locate(/datum/pda_app/station_map) in applications
	if (map_app && map_app.holomap)
		map_app.holomap.stopWatching()

/obj/item/device/pda/clown/Crossed(AM as mob|obj) //Clown PDA is slippery.
	if (istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if (M.Slip(8, 5, 1))
			to_chat(M, "<span class='notice'>You slipped on the PDA!</span>")

			if (istype(M, /mob/living/carbon/human) && M.real_name != src.owner)
				var/datum/pda_app/cart/virus/honk/HV = locate(/datum/pda_app/cart/virus/honk) in applications
				if (HV && HV.charges < 5)
					HV.charges++

/obj/item/device/pda/proc/available_pdas()
	var/list/names = list()
	var/list/plist = list()
	var/list/namecounts = list()

	var/datum/pda_app/messenger/message_app = locate(/datum/pda_app/messenger) in applications
	if (!message_app || message_app.toff)
		to_chat(usr, "Turn on your receiver in order to send messages.")
		return

	for (var/obj/item/device/pda/P in PDAs)
		if (!P.owner)
			continue
		else if(P.hidden)
			continue
		else if (P == src)
			continue
		else
			var/datum/pda_app/messenger/other_messenger = locate(/datum/pda_app/messenger) in P.applications
			if(other_messenger.toff)
				continue

		var/name = P.owner
		if (name in names)
			namecounts[name]++
			name = text("[name] ([namecounts[name]])")
		else
			names.Add(name)
			namecounts[name] = 1

		plist[text("[name]")] = P
	return plist


//Some spare PDAs in a box
/obj/item/weapon/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "pdabox"

/obj/item/weapon/storage/box/PDAs/New()
	..()
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/device/pda(src)
	new /obj/item/weapon/cartridge/head(src)

	var/newcart = pick(	/obj/item/weapon/cartridge/engineering,
						/obj/item/weapon/cartridge/security,
						/obj/item/weapon/cartridge/medical,
						/obj/item/weapon/cartridge/signal/toxins,
						/obj/item/weapon/cartridge/quartermaster)
	new newcart(src)

// Pass along the pulse to atoms in contents, largely added so pAIs are vulnerable to EMP
/obj/item/device/pda/emp_act(severity)
	for(var/atom/A in src)
		A.emp_act(severity)

/proc/get_viewable_pdas()
	. = list()
	// Returns a list of PDAs which can be viewed from another PDA/message monitor.
	for(var/obj/item/device/pda/P in PDAs)
		var/datum/pda_app/messenger/app = locate(/datum/pda_app/messenger) in P.applications
		if(!P.owner || !app || app.toff || P.hidden)
			continue
		. += P
	return .

#undef PDA_MINIMAP_WIDTH

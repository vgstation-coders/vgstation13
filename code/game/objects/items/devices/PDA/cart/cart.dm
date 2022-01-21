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
	var/access_security = 0
	var/access_engine = 0
	var/access_atmos = 0
	var/access_medical = 0
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
	var/access_quartermaster = 0
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

	// -- Various crimes against object oriented programming
	var/obj/machinery/computer/powermonitor/powmonitor = null // Power Monitor
	var/list/powermonitors = list()
	var/obj/machinery/computer/station_alert/alertmonitor = null // Alert Monitor
	var/list/alertmonitors = list()
	var/list/stored_data = list()

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

	powmonitor = null
	powermonitors = null
	alertmonitor = null
	alertmonitors = null
	stored_data = null

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

		if (43) //Muskets' and Rockdtben's power monitor :D
			menu = "<h4><span class='pda_icon pda_power'></span> Please select a Power Monitoring Computer</h4><BR>No Power Monitoring Computer detected in the vicinity.<BR>"
			var/powercount = 0
			var/found = 0

			for(var/obj/machinery/computer/powermonitor/pMon in power_machines)
				if(!(pMon.stat & (NOPOWER|BROKEN)))
					var/turf/T = get_turf(src)
					if(T.z == pMon.z)//the application may only detect power monitoring computers on its Z-level.
						if(!found)
							menu = "<h4><span class='pda_icon pda_power'></span> Please select a Power Monitoring Computer</h4><BR>"
							found = 1
							menu += "<FONT SIZE=-1>"
						powercount++
						menu += "<a href='byond://?src=\ref[src];choice=Power Select;target=[powercount]'> [pMon] </a><BR>"
						powermonitors += "\ref[pMon]"
			if(found)
				menu += "</FONT>"

		if (433) //Muskets' and Rockdtben's power monitor :D
			if(!powmonitor)
				menu = "<h4><span class='pda_icon pda_power'></span> Power Monitor </h4><BR>"
				menu += "No connection<BR>"
			else
				menu = "<h4><span class='pda_icon pda_power'></span> [powmonitor] </h4><BR>"
				var/list/L = list()
				for(var/obj/machinery/power/terminal/term in powmonitor.connected_powernet.nodes)
					if(istype(term.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = term.master
						L += A


				menu += {"<PRE>Total power: [powmonitor.connected_powernet.avail] W<BR>Total load:  [num2text(powmonitor.connected_powernet.viewload,10)] W<BR>
					<FONT SIZE=-1>"}
				if(L.len > 0)
					menu += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

					var/list/S = list(" Off","AOff","  On", " AOn")
					var/list/chg = list("N","C","F")

					for(var/obj/machinery/power/apc/A in L)
						var/area/APC_area = get_area(A)
						menu += copytext(add_tspace(APC_area.name, 30), 1, 30)
						menu += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

				menu += "</FONT></PRE>"

		if (53)
			menu = "<h4><span class='pda_icon pda_alert'></span> Please select an Alert Computer</h4><BR>No Alert Computer detected in the vicinity.<BR>"
			alertmonitor = null
			alertmonitors = list()

			var/alertcount = 0
			var/found = 0

			for(var/obj/machinery/computer/station_alert/aMon in machines)
				if(!(aMon.stat & (NOPOWER|BROKEN)))
					var/turf/T = get_turf(src)
					if(T.z == aMon.z)//the application may only detect station alert computers on its Z-level.
						if(!found)
							menu = "<h4><span class='pda_icon pda_alert'></span> Please select an Alert Computer</h4><BR>"
							found = 1
							menu += "<FONT SIZE=-1>"
						alertcount++
						menu += "<a href='byond://?src=\ref[src];choice=Alert Select;target=[alertcount]'> [aMon] </a><BR>"
						alertmonitors += "\ref[aMon]"
			if(found)
				menu += "</FONT>"

		if (533)
			if(!alertmonitor)
				menu = "<h4><span class='pda_icon pda_alert'></span> Alert Monitor </h4><BR>"
				menu += "No connection<BR>"
			else
				menu = "<h4><span class='pda_icon pda_alert'></span> [alertmonitor] </h4><BR>"
				for (var/cat in alertmonitor.alarms)
					menu += text("<B>[]</B><BR>\n", cat)
					var/list/L = alertmonitor.alarms[cat]
					if (L.len)
						for (var/alarm in L)
							var/list/alm = L[alarm]
							var/area/A = alm[1]
							var/list/sources = alm[3]

							menu += {"<NOBR>
								&bull;
								[A.name]"}

							if (sources.len > 1)
								menu += text(" - [] sources", sources.len)
							menu += "</NOBR><BR>\n"
					else
						menu += "-- All Systems Nominal<BR>\n"
					menu += "<BR>\n"

				menu += "</FONT></PRE>"

		if (47) //quartermaster order records

			menu = {"<h4><span class='pda_icon pda_crate'></span> Supply Record Interlink</h4>
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
		if (49) //janitorial locator
			menu = "<h4><span class='pda_icon pda_bucket'></span> Persistent Custodial Object Locator</h4>"

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



/obj/item/weapon/cartridge/Topic(href, href_list)
	if (..())
		return

	if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr.unset_machine()
		usr << browse(null, "window=pda")
		return

	if (href_list["change_destination"])
		var/new_dest = stripped_input(usr, "Set the new destination", "New mulebot destination")
		if (!new_dest)
			return
		saved_destination = new_dest
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

		if("Power Select")
			var/pnum = text2num(href_list["target"])
			powmonitor = locate(powermonitors[pnum])
			if(istype(powmonitor))
				loc:mode = 433
				mode = 433

		if("Alert Select")
			var/pnum = text2num(href_list["target"])
			alertmonitor = locate(alertmonitors[pnum])
			if(istype(alertmonitor))
				loc:mode = 533
				mode = 533

	generate_menu()
	print_to_host(menu)

/obj/item/weapon/cartridge
	name = "\improper Generic cartridge"
	desc = "A data cartridge for portable microcomputers."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	item_state = "electronic"
	origin_tech = Tc_PROGRAMMING + "=2"
	w_class = W_CLASS_TINY

	var/obj/item/radio/integrated/radio = null
	var/access_security = 0
	var/access_engine = 0
	var/access_atmos = 0
	var/access_mechanic = 0
	var/access_medical = 0
	var/access_manifest = 1 // Make all jobs able to access the manifest
	var/access_clown = 0
	var/access_mime = 0
	var/access_janitor = 0
//	var/access_flora = 0
	var/access_reagent_scanner = 0
	var/access_remote_door = 0 //Control some blast doors remotely!!
	var/remote_door_id = ""
	var/access_status_display = 0
	var/access_quartermaster = 0
	var/access_hydroponics = 0
	var/access_trader = 0
	var/access_robotics = 0
	var/fax_pings = FALSE
	var/mode = null
	var/menu
	var/datum/data/record/active1 = null //General
	var/datum/data/record/active2 = null //Medical
	var/datum/data/record/active3 = null //Security
	var/obj/machinery/power/monitor/powmonitor = null // Power Monitor
	var/list/powermonitors = list()
	var/obj/machinery/computer/station_alert/alertmonitor = null // Alert Monitor
	var/list/alertmonitors = list()
	var/message1	// used for status_displays
	var/message2
	var/list/stored_data = list()

/obj/item/weapon/cartridge/Destroy()
	if(radio)
		qdel(radio)
		radio = null

	active1 = null
	active2 = null
	active3 = null
	powmonitor = null
	powermonitors = null
	alertmonitor = null
	alertmonitors = null
	stored_data = null

	..()

/obj/item/weapon/cartridge/engineering
	name = "\improper Power-ON Cartridge"
	icon_state = "cart-e"
	access_engine = 1

/obj/item/weapon/cartridge/atmos
	name = "\improper BreatheDeep Cartridge"
	icon_state = "cart-a"
	access_atmos = 1

/obj/item/weapon/cartridge/mechanic
	name = "\improper Screw-E Cartridge"
	icon_state = "cart-mech"
	access_mechanic = 1
	access_engine = 1 //for the power monitor, but may remove later

/obj/item/weapon/cartridge/medical
	name = "\improper Med-U Cartridge"
	icon_state = "cart-m"
	access_medical = 1

/obj/item/weapon/cartridge/chemistry
	name = "\improper ChemWhiz Cartridge"
	icon_state = "cart-chem"
	access_reagent_scanner = 1

/obj/item/weapon/cartridge/chef
	name = "\improper ChefBuddy Cartridge"
	icon_state = "cart-chef"
	access_reagent_scanner = 1

/obj/item/weapon/cartridge/security
	name = "\improper R.O.B.U.S.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1

/obj/item/weapon/cartridge/security/New()
	..()
	spawn(5)//giving time for the radio_controller to initialize
		radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/detective
	name = "\improper D.E.T.E.C.T. Cartridge"
	icon_state = "cart-s"
	access_security = 1
	access_medical = 1
	access_manifest = 1


/obj/item/weapon/cartridge/janitor
	name = "\improper CustodiPRO Cartridge"
	desc = "The ultimate in clean-room design."
	icon_state = "cart-j"
	access_janitor = 1

/obj/item/weapon/cartridge/lawyer
	name = "\improper P.R.O.V.E. Cartridge"
	icon_state = "cart-s"
	access_security = 1
	fax_pings = TRUE

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
/obj/item/weapon/cartridge/robotics
	name = "\improper R.O.B.U.T.T. Cartridge"
	desc = "Allows you to use your pda as a cyborg analyzer"
	icon_state = "cart-robo"
	access_robotics = 1

/obj/item/weapon/cartridge/signal
	name = "\improper Generic signaler cartridge"
	desc = "A data cartridge with an integrated radio signaler module."

/obj/item/weapon/cartridge/signal/toxins
	name = "\improper Signal Ace 2"
	desc = "Complete with integrated radio signaler!"
	icon_state = "cart-tox"
	access_atmos = 1

/obj/item/weapon/cartridge/signal/New()
	..()
	spawn(5)//giving time for the radio_controller to initialize
		radio = new /obj/item/radio/integrated/signal(src)

/obj/item/weapon/cartridge/quartermaster
	name = "\improper Space Parts & Space Vendors Cartridge"
	desc = "Perfect for the Quartermaster on the go!"
	icon_state = "cart-q"
	access_quartermaster = 1

/obj/item/weapon/cartridge/quartermaster/New()
	..()
	spawn(5)//giving time for the radio_controller to initialize
		radio = new /obj/item/radio/integrated/mule(src)

/obj/item/weapon/cartridge/head
	name = "\improper Easy-Record DELUXE"
	icon_state = "cart-h"
	access_manifest = 1
	access_status_display = 1

/obj/item/weapon/cartridge/hop
	name = "\improper HumanResources9001"
	icon_state = "cart-h"
	access_manifest = 1
	access_status_display = 1
	access_quartermaster = 1
	access_janitor = 1
	access_security = 1
	fax_pings = TRUE

/obj/item/weapon/cartridge/hop/New()
	..()
	spawn(5)//giving time for the radio_controller to initialize
		radio = new /obj/item/radio/integrated/mule(src)

/obj/item/weapon/cartridge/hos
	name = "\improper R.O.B.U.S.T. DELUXE"
	icon_state = "cart-hos"
	access_manifest = 1
	access_status_display = 1
	access_security = 1

/obj/item/weapon/cartridge/hos/New()
	..()
	spawn(5)//giving time for the radio_controller to initialize
		radio = new /obj/item/radio/integrated/beepsky(src)

/obj/item/weapon/cartridge/ce
	name = "\improper Power-On DELUXE"
	icon_state = "cart-ce"
	access_manifest = 1
	access_mechanic = 1
	access_status_display = 1
	access_engine = 1
	access_atmos = 1

/obj/item/weapon/cartridge/cmo
	name = "\improper Med-U DELUXE"
	icon_state = "cart-cmo"
	access_manifest = 1
	access_status_display = 1
	access_reagent_scanner = 1
	access_medical = 1

/obj/item/weapon/cartridge/rd
	name = "\improper Signal Ace DELUXE"
	icon_state = "cart-rd"
	access_manifest = 1
	access_status_display = 1
	access_robotics = 1
	access_atmos = 1

/obj/item/weapon/cartridge/rd/New()
	..()
	spawn(5)//giving time for the radio_controller to initialize
		radio = new /obj/item/radio/integrated/signal(src)

/obj/item/weapon/cartridge/captain
	name = "\improper Value-PAK Cartridge"
	desc = "Now with 200% more value!"
	icon_state = "cart-c"
	access_manifest = 1
	access_engine = 1
	access_mechanic = 1
	access_security = 1
	access_medical = 1
	access_reagent_scanner = 1
	access_status_display = 1
	access_atmos = 1
	fax_pings = TRUE

/obj/item/weapon/cartridge/syndicate
	name = "\improper Detomatix Cartridge"
	icon_state = "cart"
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_SYNDICATE + "=2"
	mech_flags = MECH_SCAN_ILLEGAL
	var/shock_charges = 4

/obj/item/weapon/cartridge/syndicatedoor
	name = "\improper Doorman Cartridge"
	access_remote_door = 1
	remote_door_id = "smindicate" //Make sure this matches the syndicate shuttle's shield/door id!!

/obj/item/weapon/cartridge/trader
	name = "\improper Trader Cartridge"
	icon_state = "cart-vox"
	access_trader = 1

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

/obj/item/weapon/cartridge/proc/post_status(var/command, var/data1, var/data2)


	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = getFromPool(/datum/signal)
	status_signal.source = src
	status_signal.transmission_method = 1
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			if(loc)
				var/obj/item/PDA = loc
				var/mob/user = PDA.fingerprintslast
				if(istype(PDA.loc,/mob/living))
					name = PDA.loc
				log_admin("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
				message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")

		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(src, status_signal)

/obj/item/weapon/cartridge/proc/generate_menu()
	switch(mode)
		if(40) //signaller
			menu = "<h4><img src=pda_signaler.png> Remote Signaling System</h4>"

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
		/*if (41) //crew manifest


			menu = {"<h4><img src=pda_notes.png> Crew Manifest</h4>
				Entries cannot be modified from this terminal.<br><br>"}
			if(data_core)
				menu += data_core.get_manifest(1) // make it monochrome
			menu += "<br>"*/


		if (42) //status displays

			menu = {"<h4><img src=pda_status.png> Station Status Display Interlink</h4>
				\[ <A HREF='?src=\ref[src];choice=Status;statdisp=blank'>Clear</A> \]<BR>
				\[ <A HREF='?src=\ref[src];choice=Status;statdisp=shuttle'>Shuttle ETA</A> \]<BR>
				\[ <A HREF='?src=\ref[src];choice=Status;statdisp=message'>Message</A> \]
				<ul><li> Line 1: <A HREF='?src=\ref[src];choice=Status;statdisp=setmsg1'>[ message1 ? message1 : "(none)"]</A>
				<li> Line 2: <A HREF='?src=\ref[src];choice=Status;statdisp=setmsg2'>[ message2 ? message2 : "(none)"]</A></ul><br>
				\[ Alert: <A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=default'>None</A> |
				<A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=redalert'>Red Alert</A> |
				<A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=lockdown'>Lockdown</A> |
				<A HREF='?src=\ref[src];choice=Status;statdisp=alert;alert=biohazard'>Biohazard</A> \]<BR>"}
		if (43) //Muskets' and Rockdtben's power monitor :D
			menu = "<h4><img src=pda_power.png> Please select a Power Monitoring Computer</h4><BR>No Power Monitoring Computer detected in the vicinity.<BR>"
			var/powercount = 0
			var/found = 0

			for(var/obj/machinery/power/monitor/pMon in power_machines)
				if(!(pMon.stat & (NOPOWER|BROKEN)))
					var/turf/T = get_turf(src)
					if(T.z == pMon.z)//the application may only detect power monitoring computers on its Z-level.
						if(!found)
							menu = "<h4><img src=pda_power.png> Please select a Power Monitoring Computer</h4><BR>"
							found = 1
							menu += "<FONT SIZE=-1>"
						powercount++
						menu += "<a href='byond://?src=\ref[src];choice=Power Select;target=[powercount]'> [pMon] </a><BR>"
						powermonitors += "\ref[pMon]"
			if(found)
				menu += "</FONT>"

		if (433) //Muskets' and Rockdtben's power monitor :D
			if(!powmonitor)
				menu = "<h4><img src=pda_power.png> Power Monitor </h4><BR>"
				menu += "No connection<BR>"
			else
				menu = "<h4><img src=pda_power.png> [powmonitor] </h4><BR>"
				var/list/L = list()
				for(var/obj/machinery/power/terminal/term in powmonitor.powernet.nodes)
					if(istype(term.master, /obj/machinery/power/apc))
						var/obj/machinery/power/apc/A = term.master
						L += A


				menu += {"<PRE>Total power: [powmonitor.powernet.avail] W<BR>Total load:  [num2text(powmonitor.powernet.viewload,10)] W<BR>
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
			menu = "<h4><img src=pda_alert.png> Please select an Alert Computer</h4><BR>No Alert Computer detected in the vicinity.<BR>"
			alertmonitor = null
			alertmonitors = list()

			var/alertcount = 0
			var/found = 0

			for(var/obj/machinery/computer/station_alert/aMon in machines)
				if(!(aMon.stat & (NOPOWER|BROKEN)))
					var/turf/T = get_turf(src)
					if(T.z == aMon.z)//the application may only detect station alert computers on its Z-level.
						if(!found)
							menu = "<h4><img src=pda_alert.png> Please select an Alert Computer</h4><BR>"
							found = 1
							menu += "<FONT SIZE=-1>"
						alertcount++
						menu += "<a href='byond://?src=\ref[src];choice=Alert Select;target=[alertcount]'> [aMon] </a><BR>"
						alertmonitors += "\ref[aMon]"
			if(found)
				menu += "</FONT>"

		if (533)
			if(!alertmonitor)
				menu = "<h4><img src=pda_alert.png> Alert Monitor </h4><BR>"
				menu += "No connection<BR>"
			else
				menu = "<h4><img src=pda_alert.png> [alertmonitor] </h4><BR>"
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

		if (44) //medical records //This thing only displays a single screen so it's hard to really get the sub-menu stuff working.
			menu = "<h4><img src=pda_medical.png> Medical Record List</h4>"
			if(!isnull(data_core.general))
				for (var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];choice=Medical Records;target=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"
			menu += "<br>"
		if(441)
			menu = "<h4><img src=pda_medical.png> Medical Record</h4>"

			if (istype(active1, /datum/data/record) && (active1 in data_core.general))

				menu += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>
					Sex: [active1.fields["sex"]]<br>
					Age: [active1.fields["age"]]<br>
					Rank: [active1.fields["rank"]]<br>
					Fingerprint: [active1.fields["fingerprint"]]<br>
					Physical Status: [active1.fields["p_stat"]]<br>
					Mental Status: [active1.fields["m_stat"]]<br>"}
			else
				menu += "<b>Record Lost!</b><br>"


			menu += {"<br>
				<h4><img src=pda_medical.png> Medical Data</h4>"}
			if (istype(active2, /datum/data/record) && (active2 in data_core.medical))

				menu += {"Blood Type: [active2.fields["b_type"]]<br><br>
					Minor Disabilities: [active2.fields["mi_dis"]]<br>
					Details: [active2.fields["mi_dis_d"]]<br><br>
					Major Disabilities: [active2.fields["ma_dis"]]<br>
					Details: [active2.fields["ma_dis_d"]]<br><br>
					Allergies: [active2.fields["alg"]]<br>
					Details: [active2.fields["alg_d"]]<br><br>
					Current Diseases: [active2.fields["cdi"]]<br>
					Details: [active2.fields["cdi_d"]]<br><br>
					Important Notes: [active2.fields["notes"]]<br>"}
			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"
		if (45) //security records
			menu = "<h4><img src=pda_cuffs.png> Security Record List</h4>"
			if(!isnull(data_core.general))
				for (var/datum/data/record/R in sortRecord(data_core.general))
					menu += "<a href='byond://?src=\ref[src];choice=Security Records;target=\ref[R]'>[R.fields["id"]]: [R.fields["name"]]<br>"

			menu += "<br>"
		if(451)
			menu = "<h4><img src=pda_cuffs.png> Security Record</h4>"

			if (istype(active1, /datum/data/record) && (active1 in data_core.general))

				menu += {"Name: [active1.fields["name"]] ID: [active1.fields["id"]]<br>
					Sex: [active1.fields["sex"]]<br>
					Age: [active1.fields["age"]]<br>
					Rank: [active1.fields["rank"]]<br>
					Fingerprint: [active1.fields["fingerprint"]]<br>
					Physical Status: [active1.fields["p_stat"]]<br>
					Mental Status: [active1.fields["m_stat"]]<br>"}
			else
				menu += "<b>Record Lost!</b><br>"


			menu += {"<br>
				<h4><img src=pda_cuffs.png> Security Data</h4>"}
			if (istype(active3, /datum/data/record) && (active3 in data_core.security))

				menu += {"Criminal Status: [active3.fields["criminal"]]<br>
					Important Notes:<br>
					[active3.fields["notes"]]
					Comments/Log:<br>"}
				var/counter = 1
				while(active3.fields["com_[counter]"])
					menu += "[active3.fields["com_[counter]"]]<BR>"
					counter++

			else
				menu += "<b>Record Lost!</b><br>"

			menu += "<br>"
		if (46) //beepsky control
			var/obj/item/radio/integrated/beepsky/SC = radio
			if(!SC)
				menu = "Interlink Error - Please reinsert cartridge."
				return

			menu = "<h4><img src=pda_cuffs.png> Securitron Interlink</h4>"

			if(!SC.active)
				// list of bots
				if(!SC.botlist || (SC.botlist && SC.botlist.len==0))
					menu += "No bots found.<BR>"

				else
					for(var/obj/machinery/bot/B in SC.botlist)
						if (B)
							menu += "<A href='byond://?src=\ref[SC];op=control;bot=\ref[B]'>[B] at [B.loc.loc]</A><BR>"

				menu += "<BR><A href='byond://?src=\ref[SC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

			else	// bot selected, control it

				menu += "<B>[SC.active]</B><BR> Status: (<A href='byond://?src=\ref[SC];op=control;bot=\ref[SC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

				if(!SC.botstatus)
					menu += "Waiting for response...<BR>"
				else


					menu += {"Location: [SC.botstatus["loca"] ]<BR>
						Mode: "}
					switch(SC.botstatus["mode"])
						if(0)
							menu += "Ready"
						if(1)
							menu += "Apprehending target"
						if(2,3)
							menu += "Arresting target"
						if(4)
							menu += "Starting patrol"
						if(5)
							menu += "On patrol"
						if(6)
							menu += "Responding to summons"


					menu += {"<BR>\[<A href='byond://?src=\ref[SC];op=stop'>Stop Patrol</A>\]
						\[<A href='byond://?src=\ref[SC];op=go'>Start Patrol</A>\]
						\[<A href='byond://?src=\ref[SC];op=summon'>Summon Bot</A>\]<BR>
						<HR><A href='byond://?src=\ref[SC];op=botlist'><img src=pda_back.png>Return to bot list</A>"}
		if (47) //quartermaster order records

			menu = {"<h4><img src=pda_crate.png> Supply Record Interlink</h4>
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

		if (48) //mulebot control
			var/obj/item/radio/integrated/mule/QC = radio
			if(!QC)
				menu = "Interlink Error - Please reinsert cartridge."
				return

			menu = "<h4><img src=pda_mule.png> M.U.L.E. bot Interlink V0.8</h4>"

			if(!QC.active)
				// list of bots
				if(!QC.botlist || (QC.botlist && QC.botlist.len==0))
					menu += "No bots found.<BR>"

				else
					for(var/obj/machinery/bot/mulebot/B in QC.botlist)
						menu += "<A href='byond://?src=\ref[QC];op=control;bot=\ref[B]'>[B] at [get_area(B)]</A><BR>"
				menu += "<BR><A href='byond://?src=\ref[QC];op=scanbots'><img src=pda_scanner.png> Scan for active bots</A><BR>"

			else	// bot selected, control it

				menu += "<B>[QC.active]</B><BR> Status: (<A href='byond://?src=\ref[QC];op=control;bot=\ref[QC.active]'><img src=pda_refresh.png><i>refresh</i></A>)<BR>"

				if(!QC.botstatus)
					menu += "Waiting for response...<BR>"
				else


					menu += {"Location: [QC.botstatus["loca"] ]<BR>
						Mode: "}
					switch(QC.botstatus["mode"])
						if(0)
							menu += "Ready"
						if(1)
							menu += "Loading/Unloading"
						if(2)
							menu += "Navigating to Delivery Location"
						if(3)
							menu += "Navigating to Home"
						if(4)
							menu += "Waiting for clear path"
						if(5,6)
							menu += "Calculating navigation path"
						if(7)
							menu += "Unable to locate destination"
					var/obj/structure/closet/crate/C = QC.botstatus["load"]

					menu += {"<BR>Current Load: [ !C ? "<i>none</i>" : "[C.name] (<A href='byond://?src=\ref[QC];op=unload'><i>unload</i></A>)" ]<BR>
						Destination: [!QC.botstatus["dest"] ? "<i>none</i>" : QC.botstatus["dest"] ] (<A href='byond://?src=\ref[QC];op=setdest'><i>set</i></A>)<BR>
						Power: [QC.botstatus["powr"]]%<BR>
						Home: [!QC.botstatus["home"] ? "<i>none</i>" : QC.botstatus["home"] ]<BR>
						Auto Return Home: [QC.botstatus["retn"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=retoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=reton'><i>On</i></A>) <B>Off</B>"]<BR>
						Auto Pickup Crate: [QC.botstatus["pick"] ? "<B>On</B> <A href='byond://?src=\ref[QC];op=pickoff'>Off</A>" : "(<A href='byond://?src=\ref[QC];op=pickon'><i>On</i></A>) <B>Off</B>"]<BR><BR>
						\[<A href='byond://?src=\ref[QC];op=stop'>Stop</A>\]
						\[<A href='byond://?src=\ref[QC];op=go'>Proceed</A>\]
						\[<A href='byond://?src=\ref[QC];op=home'>Return Home</A>\]<BR>
						<HR><A href='byond://?src=\ref[QC];op=botlist'><img src=pda_back.png>Return to bot list</A>"}
		if (49) //janitorial locator
			menu = "<h4><img src=pda_bucket.png> Persistent Custodial Object Locator</h4>"

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
	..()

	if (!usr.canmove || usr.stat || usr.restrained() || !in_range(loc, usr))
		usr.unset_machine()
		usr << browse(null, "window=pda")
		return

	switch(href_list["choice"])
		if("Medical Records")
			var/datum/data/record/R = locate(href_list["target"])
			var/datum/data/record/M = locate(href_list["target"])
			loc:mode = 441
			mode = 441
			if (R in data_core.general)
				for (var/datum/data/record/E in data_core.medical)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						M = E
						break
				active1 = R
				active2 = M

		if("Security Records")
			var/datum/data/record/R = locate(href_list["target"])
			var/datum/data/record/S = locate(href_list["target"])
			loc:mode = 451
			mode = 451
			if (R in data_core.general)
				for (var/datum/data/record/E in data_core.security)
					if ((E.fields["name"] == R.fields["name"] || E.fields["id"] == R.fields["id"]))
						S = E
						break
				active1 = R
				active3 = S

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

		if("Status")
			switch(href_list["statdisp"])
				if("message")
					post_status("message", message1, message2)
				if("alert")
					post_status("alert", href_list["alert"])
				if("setmsg1")
					message1 = reject_bad_text(trim(copytext(sanitize(input("Line 1", "Enter Message Text", message1) as text|null), 1, 40)), 40)
					updateSelfDialog()
				if("setmsg2")
					message2 = reject_bad_text(trim(copytext(sanitize(input("Line 2", "Enter Message Text", message2) as text|null), 1, 40)), 40)
					updateSelfDialog()
				else
					post_status(href_list["statdisp"])
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

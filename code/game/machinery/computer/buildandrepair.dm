//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define COMPUTERLOOSE 0
#define COMPUTERSECURED 1
#define COMPUTERCIRCUITSECURED 2 //Circuit added and secured on the same step
#define COMPUTERWIRED 3
#define COMPUTERSCREENUNSECURED 4

/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "Computer Frame"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = 2.0
	name = "Circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "circuitboard"
	origin_tech = "programming=2"
	g_amt = 2000 // Recycle glass only
	w_type = RECYK_ELECTRONIC

	var/id_tag = null
	var/frequency = null
	var/build_path = null
	var/board_type = "computer"
	var/list/req_components = null
	var/powernet = null
	var/list/records = null
	var/frame_desc = null
	var/contain_parts = 1


/obj/item/weapon/circuitboard/message_monitor
	name = "Circuit board (Message Monitor)"
	build_path = "/obj/machinery/computer/message_monitor"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/security
	name = "Circuit board (Security)"
	build_path = "/obj/machinery/computer/security"
/obj/item/weapon/circuitboard/security/engineering
	name = "Circuit board (Engineering)"
	build_path = "/obj/machinery/computer/security/engineering"
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI core)"
	origin_tech = "programming=4;biotech=2"
	board_type = "other"
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	build_path = "/obj/machinery/computer/aiupload"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/borgupload
	name = "Circuit board (Cyborg Upload)"
	build_path = "/obj/machinery/computer/borgupload"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	build_path = "/obj/machinery/computer/med_data"
/obj/item/weapon/circuitboard/pandemic
	name = "Circuit board (PanD.E.M.I.C. 2200)"
	build_path = "/obj/machinery/computer/pandemic"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	build_path = "/obj/machinery/computer/scan_consolenew"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications)"
	build_path = "/obj/machinery/computer/communications"
	origin_tech = "programming=2;magnets=2"
/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	build_path = "/obj/machinery/computer/card"
/obj/item/weapon/circuitboard/card/centcom
	name = "Circuit board (CentCom ID Computer)"
	build_path = "/obj/machinery/computer/card/centcom"
//obj/item/weapon/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	build_path = "/obj/machinery/computer/stationshield"
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	build_path = "/obj/machinery/computer/teleporter"
	origin_tech = "programming=2;bluespace=2"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	build_path = "/obj/machinery/computer/secure_data"
/obj/item/weapon/circuitboard/stationalert
	name = "Circuit board (Station Alerts)"
	build_path = "/obj/machinery/computer/station_alert"
/obj/item/weapon/circuitboard/atmospheresiphonswitch
	name = "Circuit board (Atmosphere siphon control)"
	build_path = "/obj/machinery/computer/atmosphere/siphonswitch"
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric General Monitor)"
	build_path = "/obj/machinery/computer/general_air_control"
/obj/item/weapon/circuitboard/atmos_automation
	name = "Circuit board (Atmospherics Automation)"
	build_path = "/obj/machinery/computer/general_air_control/atmos_automation"
/obj/item/weapon/circuitboard/large_tank_control
	name = "Circuit board (Atmospheric Tank Control)"
	build_path = "/obj/machinery/computer/general_air_control/large_tank_control"
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	build_path = "/obj/machinery/computer/general_air_control/fuel_injection"
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	build_path = "/obj/machinery/computer/atmos_alert"
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	build_path = "/obj/machinery/computer/pod"
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	build_path = "/obj/machinery/computer/robotics"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning)"
	build_path = "/obj/machinery/computer/cloning"
	origin_tech = "programming=3;biotech=3"
/obj/item/weapon/circuitboard/arcade
	name = "Circuit board (Arcade)"
	build_path = "/obj/machinery/computer/arcade"
	origin_tech = "programming=1"
/obj/item/weapon/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	build_path = "/obj/machinery/computer/turbine_computer"
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"  //name fixed 250810
	build_path = "/obj/machinery/power/solar/control"
	origin_tech = "programming=2;powerstorage=2"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"  //name fixed 250810
	build_path = "/obj/machinery/power/monitor"
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	build_path = "/obj/machinery/computer/pod/old"
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	build_path = "/obj/machinery/computer/pod/old/syndicate"
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	build_path = "/obj/machinery/computer/pod/old/swf"
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	build_path = "/obj/machinery/computer/prisoner"

/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/core"
/obj/item/weapon/circuitboard/rdconsole/mommi
	name = "Circuit Board (MoMMI R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/mommi"
/obj/item/weapon/circuitboard/rdconsole/robotics
	name = "Circuit Board (Robotics R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/robotics"
/obj/item/weapon/circuitboard/rdconsole/mechanic
	name = "Circuit Board (Mechanic R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/mechanic"
/obj/item/weapon/circuitboard/rdconsole/pod
	name = "Circuit Board (Pod Bay R&D Console)"
	build_path = "/obj/machinery/computer/rdconsole/pod"

/obj/item/weapon/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	build_path = "/obj/machinery/computer/mecha"
/obj/item/weapon/circuitboard/rdservercontrol
	name = "Circuit Board (R&D Server Control)"
	build_path = "/obj/machinery/computer/rdservercontrol"
/obj/item/weapon/circuitboard/crew
	name = "Circuit board (Crew monitoring computer)"
	build_path = "/obj/machinery/computer/crew"
	origin_tech = "programming=3;biotech=2;magnets=2"
/obj/item/weapon/circuitboard/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	build_path = "/obj/machinery/computer/mech_bay_power_console"
	origin_tech = "programming=2;powerstorage=3"
/obj/item/weapon/circuitboard/ordercomp
	name = "Circuit board (Supply ordering console)"
	build_path = "/obj/machinery/computer/ordercomp"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/supplycomp
	name = "Circuit board (Supply shuttle console)"
	build_path = "/obj/machinery/computer/supplycomp"
	origin_tech = "programming=3"
	var/contraband_enabled = 0
/obj/item/weapon/circuitboard/research_shuttle
	name = "Circuit board (Research Shuttle)"
	build_path = "/obj/machinery/computer/research_shuttle"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	build_path = "/obj/machinery/computer/operating"
	origin_tech = "programming=2;biotech=2"
/obj/item/weapon/circuitboard/mining
	name = "Circuit board (Outpost Status Display)"
	build_path = "/obj/machinery/computer/security/mining"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	build_path = "/obj/machinery/computer/telecomms/monitor"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	build_path = "/obj/machinery/computer/telecomms/server"
	origin_tech = "programming=3"
/obj/item/weapon/circuitboard/comm_traffic
	name = "Circuitboard (Telecommunications Traffic Control)"
	build_path = "/obj/machinery/computer/telecomms/traffic"
	origin_tech = "programming=3"

/obj/item/weapon/circuitboard/curefab
	name = "Circuit board (Cure fab)"
	build_path = "/obj/machinery/computer/curer"
/obj/item/weapon/circuitboard/splicer
	name = "Circuit board (Disease Splicer)"
	build_path = "/obj/machinery/computer/diseasesplicer"
	origin_tech = "programming=3;biotech=4"
/obj/item/weapon/circuitboard/centrifuge
	name = "Circuit board (Disease Splicer)"
	build_path = "/obj/machinery/computer/centrifuge"
	origin_tech = "programming=3;biotech=3"

/obj/item/weapon/circuitboard/mining_shuttle
	name = "Circuit board (Mining Shuttle)"
	build_path = "/obj/machinery/computer/mining_shuttle"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/research_shuttle
	name = "Circuit board (Research Shuttle)"
	build_path = "/obj/machinery/computer/research_shuttle"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/HolodeckControl // Not going to let people get this, but it's just here for future
	name = "Circuit board (Holodeck Control)"
	build_path = "/obj/machinery/computer/HolodeckControl"
	origin_tech = "programming=4"
/obj/item/weapon/circuitboard/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	build_path = "/obj/machinery/computer/aifixer"
	origin_tech = "programming=3;biotech=2"
/obj/item/weapon/circuitboard/area_atmos
	name = "Circuit board (Area Air Control)"
	build_path = "/obj/machinery/computer/area_atmos"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/prison_shuttle
	name = "Circuit board (Prison Shuttle)"
	build_path = "/obj/machinery/computer/prison_shuttle"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/bhangmeter
	name = "Circuit board (Bhangmeter)"
	build_path = "/obj/machinery/computer/bhangmeter"
	origin_tech = "programming=2"
/obj/item/weapon/circuitboard/pda_terminal
	name = "Circuit board (PDA Terminal)"
	build_path = "/obj/machinery/computer/pda_terminal"
	origin_tech = "programming=2"


/obj/item/weapon/circuitboard/supplycomp/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I,/obj/item/device/multitool))
		var/catastasis = src.contraband_enabled
		var/opposite_catastasis
		if(catastasis)
			opposite_catastasis = "STANDARD"
			catastasis = "BROAD"
		else
			opposite_catastasis = "BROAD"
			catastasis = "STANDARD"

		switch(alert("Current receiver spectrum is set to: [catastasis]","Multitool-Circuitboard interface", "Switch to [opposite_catastasis]","Cancel"))

			if("Switch to STANDARD", "Switch to BROAD")
				contraband_enabled = !contraband_enabled
			if("Cancel")
				return
	return

/obj/structure/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(COMPUTERLOOSE)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] starts anchoring \the [src].</span>", \
				"<span class='notice'>You start anchoring \the [src].</span>")
				if(do_after(user, 20) && COMPUTERLOOSE)
					user.visible_message("<span class='notice'>[user] anchors \the [src].</span>", \
					"<span class='notice'>You anchor \the [src].</span>")
					anchored = 1
					state = COMPUTERSECURED
				return 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(WT.remove_fuel(0))
					playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
					user.visible_message("<span class='warning'>[user] starts dismantling \the [src].</span>", \
					"<span class='notice'>You start dismantling \the [src].</span>")
					if(do_after(user, 40))
						user.visible_message("<span class='warning'>[user] dismantles \the [src].</span>", \
						"<span class='notice'>You dismantle \the [src].</span>")
						getFromPool(/obj/item/stack/sheet/metal, get_turf(src), 5)
						returnToPool(src)
				else
					user << "<span class='notice'>You need more welding fuel to complete this task.</span>"
				return 1
		if(COMPUTERSECURED)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] starts unanchoring \the [src].</span>", \
				"<span class='notice'>You start unanchoring \the [src].</span>")
				if(do_after(user, 20) && COMPUTERSECURED)
					user.visible_message("<span class='warning'>[user] unanchors \the [src].</span>", \
					"<span class='notice'>You unanchor \the [src].</span>")
					anchored = 0
					state = COMPUTERLOOSE
				return 1
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == "computer")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					user.visible_message("<span class='notice'>[user] adds \a [B]  to \the [src].</span>", \
					"<span class='notice'>You add \a [B] to \the [src].</span>")
					icon_state = "1"
					user.drop_item(src)
					circuit = P
				else
					user << "<span class='warning'>This frame does not accept circuit boards of this type!</span>"
				return 1
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] secures \the [src]'s circuit board.</span>", \
				"<span class='notice'>You secure \the [src]'s circuit board.</span>")
				state = COMPUTERCIRCUITSECURED
				icon_state = "2"
				return 1
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] removes \the [src]'s circuit board.</span>", \
				"<span class='notice'>You remove \the [src]'s circuit board.</span>")
				state = COMPUTERSECURED
				icon_state = "0"
				circuit.loc = src.loc
				circuit = null
				return 1
		if(COMPUTERCIRCUITSECURED)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] unsecures \the [src]'s circuit board.</span>", \
				"<span class='notice'>You unsecure \the [src]'s circuit board.</span>")
				state = COMPUTERSECURED
				icon_state = "1"
				return 1
			if(istype(P, /obj/item/stack/cable_coil))
				if(P:amount >= 5)
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20) && COMPUTERCIRCUITSECURED)
						if(P)
							P:amount -= 5
							if(!P:amount)
								del(P)
							user.visible_message("<span class='notice'>[user] adds wiring to \the [src].</span>", \
							"<span class='notice'>You add wiring to \the [src].</span>")
							state = COMPUTERWIRED
							icon_state = "3"
				return 1
		if(COMPUTERWIRED)
			if(istype(P, /obj/item/weapon/wirecutters))
				playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] removes \the [src]'s wiring.</span>", \
				"<span class='notice'>You remove \the [src]'s wiring.</span>")
				state = COMPUTERCIRCUITSECURED
				icon_state = "2"
				var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil(get_turf(src))
				A.amount = 5
				return 1

			if(istype(P, /obj/item/stack/sheet/glass/glass))
				if(P:amount >= 2)
					user.visible_message("<span class='notice'>[user] starts adding \a [P] to \the [src].</span>", \
					"<span class='notice'>You start adding \a [P] to \the [src].</span>")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20) && COMPUTERWIRED)
						if(P)
							P:use(2)
							user.visible_message("<span class='notice'>[user] adds \a [P] to \the [src].</span>", \
							"<span class='notice'>You add \a [P] to \the [src].</span>")
							state = COMPUTERSCREENUNSECURED
							icon_state = "4"
				return 1
		if(COMPUTERSCREENUNSECURED)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				user.visible_message("<span class='warning'>[user] removes \the [src]'s monitor.</span>", \
				"<span class='notice'>You remove \the [src]'s monitor.</span>")
				state = COMPUTERWIRED
				icon_state = "3"
				new /obj/item/stack/sheet/glass/glass(src.loc, 2)
				return 1
			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] connects \the [src]'s monitor.</span>", \
				"<span class='notice'>You connect \the [src]'s monitor.</span>")

				var/B = new circuit.build_path(src.loc)
				//Snowflake dump
				if(circuit.powernet)
					B:powernet = circuit.powernet
				if(circuit.id_tag)
					B:id_tag = circuit.id_tag
				if(circuit.records)
					B:records = circuit.records
				if(circuit.frequency)
					B:frequency = circuit.frequency
				if(istype(circuit,/obj/item/weapon/circuitboard/supplycomp))
					var/obj/machinery/computer/supplycomp/SC = B
					var/obj/item/weapon/circuitboard/supplycomp/C = circuit
					SC.can_order_contraband = C.contraband_enabled
				del(src)
				return 1
	return 0

#undef COMPUTERLOOSE
#undef COMPUTERSECURED
#undef COMPUTERCIRCUITSECURED
#undef COMPUTERWIRED
#undef COMPUTERSCREENUNSECURED

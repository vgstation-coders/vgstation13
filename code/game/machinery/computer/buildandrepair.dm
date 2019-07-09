//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/obj/structure/computerframe
	density = 1
	anchored = 0
	name = "computer frame"
	desc = "A metal frame ready to recieve a circuit board, wires and a glass panel."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "0"
	var/state = 0
	var/obj/item/weapon/circuitboard/circuit = null
//	weight = 1.0E8

/obj/structure/computerframe/Destroy()
	..()
	qdel(circuit)
	circuit = null

/obj/item/weapon/circuitboard
	density = 0
	anchored = 0
	w_class = W_CLASS_SMALL
	name = "circuit board"
	desc = "A circuit board with no markings and barely any imprinting. Likely worn or broken."
	icon = 'icons/obj/module.dmi'
	icon_state = "id_mod"
	item_state = "circuitboard"
	origin_tech = Tc_PROGRAMMING + "=2"
	starting_materials = list(MAT_GLASS = 2000) // Recycle glass only
	w_type = RECYK_ELECTRONIC

	var/id_tag = null
	var/frequency = null
	var/build_path = null
	var/board_type = COMPUTER
	var/list/req_components = null
	var/powernet = null
	var/list/records = null
	var/contain_parts = 1

/obj/item/weapon/circuitboard/message_monitor
	name = "Circuit board (Message Monitor)"
	desc = "A circuit board for running a computer used for telecommunications monitoring."
	build_path = /obj/machinery/computer/message_monitor
	origin_tech = Tc_PROGRAMMING + "=3"
/obj/item/weapon/circuitboard/security
	name = "Circuit board (Security Cameras)"
	desc = "A circuit board for running a computer used for viewing security cameras."
	build_path = /obj/machinery/computer/security
/obj/item/weapon/circuitboard/security/wooden_tv
	name = "Circuit board (Security Cameras TV)"
	build_path = /obj/machinery/computer/security/wooden_tv
/obj/item/weapon/circuitboard/security/engineering
	name = "Circuit board (Engineering Cameras)"
	desc = "A circuit board for running a computer used for viewing engineering cameras."
	build_path = /obj/machinery/computer/security/engineering
/obj/item/weapon/circuitboard/aicore
	name = "Circuit board (AI core)"
	desc = "A circuit board that allows the intelligence in an AI core to interface with the world around it."
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_BIOTECH + "=2"
	board_type = OTHER
/obj/item/weapon/circuitboard/aiupload
	name = "Circuit board (AI Upload)"
	desc = "A circuit board for running a computer used for modifying AI laws."
	build_path = /obj/machinery/computer/aiupload
	origin_tech = Tc_PROGRAMMING + "=4"
/obj/item/weapon/circuitboard/aiupload/longrange
	name = "Circuit board (Long Range AI Upload)"
	desc = "A circuit board for running a computer used for modifying AI laws."
	build_path = /obj/machinery/computer/aiupload/longrange
	origin_tech = Tc_PROGRAMMING + "=4" + Tc_MATERIALS + "=9" + Tc_BLUESPACE + "=3" + Tc_MAGNETS + "=5"
/obj/item/weapon/circuitboard/borgupload
	name = "Circuit board (Cyborg Upload)"
	desc = "A circuit board for running a computer used for modifying cyborg laws."
	build_path = /obj/machinery/computer/borgupload
	origin_tech = Tc_PROGRAMMING + "=4"
/obj/item/weapon/circuitboard/med_data
	name = "Circuit board (Medical Records)"
	desc = "A circuit board for running a computer used for viewing medical records."
	build_path = /obj/machinery/computer/med_data
///obj/item/weapon/circuitboard/pandemic
//	name = "Circuit board (PanD.E.M.I.C. 2200)"
//	desc = "A circuit board for running a computer used in Virology."
//	build_path = /obj/machinery/computer/pandemic
//	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_BIOTECH + "=2"
/obj/item/weapon/circuitboard/scan_consolenew
	name = "Circuit board (DNA Machine)"
	desc = "A circuit board for running a computer used in Genetics."
	build_path = /obj/machinery/computer/scan_consolenew
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_BIOTECH + "=2"
/obj/item/weapon/circuitboard/communications
	name = "Circuit board (Communications)"
	desc = "A circuit board for running a computer used to communicate with Central Command."
	build_path = /obj/machinery/computer/communications
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MAGNETS + "=2"
/obj/item/weapon/circuitboard/card
	name = "Circuit board (ID Computer)"
	desc = "A circuit board for running a computer used for modifying access on ID cards."
	build_path = /obj/machinery/computer/card
/obj/item/weapon/circuitboard/card/centcom
	name = "Circuit board (CentCom ID Computer)"
	desc = "A circuit board for running a computer used for granting access to areas at Central Command.."
	build_path = /obj/machinery/computer/card/centcom
//obj/item/weapon/circuitboard/shield
//	name = "Circuit board (Shield Control)"
//	build_path = /obj/machinery/computer/stationshield
/obj/item/weapon/circuitboard/teleporter
	name = "Circuit board (Teleporter)"
	build_path = /obj/machinery/computer/teleporter
	desc = "A circuit board for running a computer used for selecting teleporter locations."
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_BLUESPACE + "=2"
/obj/item/weapon/circuitboard/secure_data
	name = "Circuit board (Security Records)"
	desc = "A circuit board for running a computer used for viewing security records."
	build_path = /obj/machinery/computer/secure_data
/obj/item/weapon/circuitboard/stationalert
	name = "Circuit board (Station Alerts)"
	desc = "A circuit board for running a computer used for viewing station alerts."
	build_path = /obj/machinery/computer/station_alert
/*/obj/item/weapon/circuitboard/atmospheresiphonswitch
	name = "Circuit board (Atmosphere siphon control)"
	build_path = /obj/machinery/computer/atmosphere/siphonswitch*/
/obj/item/weapon/circuitboard/air_management
	name = "Circuit board (Atmospheric General Monitor)"
	desc = "A circuit board for running a computer used for monitoring amospherical sensor inputs."
	build_path = /obj/machinery/computer/general_air_control
/obj/item/weapon/circuitboard/atmos_automation
	name = "Circuit board (Atmospherics Automation)"
	desc = "A circuit board for running a computer used for automating atmospherical devices, such as valves."
	build_path = /obj/machinery/computer/general_air_control/atmos_automation
/obj/item/weapon/circuitboard/large_tank_control
	name = "Circuit board (Atmospheric Tank Control)"
	desc = "A circuit board for running a computer used for monitoring atmosphere in the gas tank chambers."
	build_path = /obj/machinery/computer/general_air_control/large_tank_control
/obj/item/weapon/circuitboard/injector_control
	name = "Circuit board (Injector control)"
	desc = "A circuit board for running an obsolete computer used for injecting fuel."
	build_path = /obj/machinery/computer/general_air_control/fuel_injection
/obj/item/weapon/circuitboard/atmos_alert
	name = "Circuit board (Atmospheric Alert)"
	desc = "A circuit board for running a computer used for viewing air alarm alerts."
	build_path = /obj/machinery/computer/atmos_alert
/obj/item/weapon/circuitboard/supermatter
	name = "Circuit board (Supermatter Monitor)"
	desc = "A circuit board for the supermatter monitoring computer."
	build_path = /obj/machinery/computer/supermatter
/obj/item/weapon/circuitboard/pod
	name = "Circuit board (Massdriver control)"
	desc = "A circuit board for running a computer used for controlling mass drivers and blast doors."
	build_path = /obj/machinery/computer/pod
/obj/item/weapon/circuitboard/robotics
	name = "Circuit board (Robotics Control)"
	desc = "A circuit board for running a computer used for monitoring and locking or destroying cyborgs."
	build_path = /obj/machinery/computer/robotics
	origin_tech = Tc_PROGRAMMING + "=3"
/obj/item/weapon/circuitboard/cloning
	name = "Circuit board (Cloning Console)"
	desc = "A circuit board for running a computer used for saving and applying cloning records."
	build_path = /obj/machinery/computer/cloning
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=3"
/obj/item/weapon/circuitboard/arcade
	name = "Circuit board (Arcade)"
	desc = "A circuit board for running a computer used for the popular 'Random Encounter!' series videogames."
	build_path = /obj/machinery/computer/arcade
	origin_tech = Tc_PROGRAMMING + "=1"
	var/list/game_data = list()
/obj/item/weapon/circuitboard/turbine_control
	name = "Circuit board (Turbine control)"
	desc = "A circuit board for running an obsolete computer used for controlling a gas turbine."
	build_path = /obj/machinery/computer/turbine_computer
/obj/item/weapon/circuitboard/solar_control
	name = "Circuit board (Solar Control)"  //name fixed 250810
	desc = "A circuit board for running a computer used for monitoring solar panel rotation and output."
	build_path = /obj/machinery/power/solar/control
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_POWERSTORAGE + "=2"
/obj/item/weapon/circuitboard/powermonitor
	name = "Circuit board (Power Monitor)"  //name fixed 250810
	desc = "A circuit board for running a computer used for monitoring power generation, load and demand."
	build_path = /obj/machinery/power/monitor
/obj/item/weapon/circuitboard/olddoor
	name = "Circuit board (DoorMex)"
	desc = "A circuit board for running a very outdated computer used for opening doors."
	build_path = /obj/machinery/computer/pod/old
/obj/item/weapon/circuitboard/syndicatedoor
	name = "Circuit board (ProComp Executive)"
	desc = "A circuit board for running a very outdated computer used for opening doors. A tag on it says \"Property of Cybersun Industries\"."
	build_path = /obj/machinery/computer/pod/old/syndicate
/obj/item/weapon/circuitboard/swfdoor
	name = "Circuit board (Magix)"
	desc = "A circuit board for running a very outdated computer used for opening doors. A tag on it says \"Federation Use Only\"."
	build_path = /obj/machinery/computer/pod/old/swf
/obj/item/weapon/circuitboard/prisoner
	name = "Circuit board (Prisoner Management)"
	desc = "A circuit board for running a computer used for monitoring and manipulating prisoner implants."
	build_path = /obj/machinery/computer/prisoner
/obj/item/weapon/circuitboard/labor
	name = "Circuit board (Labor Administration)"
	desc = "A circuit board for running a computer used for administrating station jobs."
	build_path = /obj/machinery/computer/labor

/obj/item/weapon/circuitboard/rdconsole
	name = "Circuit Board (R&D Console)"
	desc = "A circuit board for running the core computer used in Research and Development."
	build_path = /obj/machinery/computer/rdconsole/core
/obj/item/weapon/circuitboard/rdconsole/mommi
	name = "Circuit Board (MoMMI R&D Console)"
	desc = "A circuit board for running a R&D console for Mobile MMIs."
	build_path = /obj/machinery/computer/rdconsole/mommi
/obj/item/weapon/circuitboard/rdconsole/robotics
	name = "Circuit Board (Robotics R&D Console)"
	desc = "A circuit board for running a R&D console for Robotics."
	build_path = /obj/machinery/computer/rdconsole/robotics
/obj/item/weapon/circuitboard/rdconsole/mechanic
	name = "Circuit Board (Mechanic R&D Console)"
	desc = "A circuit board for running a R&D console for Mechanics."
	build_path = /obj/machinery/computer/rdconsole/mechanic
/obj/item/weapon/circuitboard/rdconsole/pod
	name = "Circuit Board (Pod Bay R&D Console)"
	desc = "A circuit board for running a R&D console for the Pod Bay."
	build_path = /obj/machinery/computer/rdconsole/pod

/obj/item/weapon/circuitboard/mecha_control
	name = "Circuit Board (Exosuit Control Console)"
	desc = "A circuit board for running a computer used to monitor and remotely lock exosuits."
	build_path = /obj/machinery/computer/mecha
/obj/item/weapon/circuitboard/rdservercontrol
	name = "Circuit Board (R&D Server Control)"
	desc = "A circuit board for running a computer used to monitor and delete research data."
	build_path = /obj/machinery/computer/rdservercontrol
/obj/item/weapon/circuitboard/crew
	name = "Circuit board (Crew monitoring computer)"
	desc = "A circuit board for running a computer used to monitor suit sensor data."
	build_path = /obj/machinery/computer/crew
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=2;" + Tc_MAGNETS + "=2"
/obj/item/weapon/circuitboard/mech_bay_power_console
	name = "Circuit board (Mech Bay Power Control Console)"
	desc = "A circuit board for running a computer used to monitor exosuit cell charging."
	build_path = /obj/machinery/computer/mech_bay_power_console
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_POWERSTORAGE + "=3"
/obj/item/weapon/circuitboard/ordercomp
	name = "Circuit board (Supply ordering console)"
	desc = "A circuit board for running a computer used to order items from Cargo."
	build_path = /obj/machinery/computer/ordercomp
	origin_tech = Tc_PROGRAMMING + "=2"
/obj/item/weapon/circuitboard/supplycomp
	name = "Circuit board (Supply shuttle console)"
	desc = "A circuit board for running a computer used by Cargo to order items and call the Supply Shuttle."
	build_path = /obj/machinery/computer/supplycomp
	origin_tech = Tc_PROGRAMMING + "=3"
	var/contraband_enabled = 0
/obj/item/weapon/circuitboard/operating
	name = "Circuit board (Operating Computer)"
	desc = "A circuit board for running a computer used to monitor patients during surgery."
	build_path = /obj/machinery/computer/operating
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_BIOTECH + "=2"
/obj/item/weapon/circuitboard/mining
	name = "Circuit board (Mining Outpost Cameras)"
	desc = "A circuit board for running a computer used to view Mining Outpost cameras."
	build_path = /obj/machinery/computer/security/mining
	origin_tech = Tc_PROGRAMMING + "=2"
/obj/item/weapon/circuitboard/comm_monitor
	name = "Circuit board (Telecommunications Monitor)"
	desc = "A circuit board for running a computer used to view the entities and links between entities in a telecommunications network."
	build_path = /obj/machinery/computer/telecomms/monitor
	origin_tech = Tc_PROGRAMMING + "=3"
/obj/item/weapon/circuitboard/comm_server
	name = "Circuit board (Telecommunications Server Monitor)"
	desc = "A circuit board for running a computer used to view active telecommunications servers and their message logs."
	build_path = /obj/machinery/computer/telecomms/server
	origin_tech = Tc_PROGRAMMING + "=3"
/obj/item/weapon/circuitboard/comm_traffic
	name = "Circuitboard (Telecommunications Traffic Control)"
	desc = "A circuit board for running a computer used to manipulate telecommunications traffic."
	build_path = /obj/machinery/computer/telecomms/traffic
	origin_tech = Tc_PROGRAMMING + "=3"
/*/obj/item/weapon/circuitboard/curefab
	name = "Circuit board (Cure fab)"
	desc = "A circuit board for running a computer used to fabricate cures for virusses."
	build_path = /obj/machinery/computer/curer*/
/obj/item/weapon/circuitboard/splicer
	name = "Circuit board (Disease Splicer)"
	desc = "A circuit board for running a computer used to splice DNA strands in virusses."
	build_path = /obj/machinery/computer/diseasesplicer
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=4"

/obj/item/weapon/circuitboard/shuttle_control
	name = "Circuit board (Shuttle Control)"
	desc = "A circuit board for running a computer used to control space shuttles."
	build_path = /obj/machinery/computer/shuttle_control
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2"

/obj/item/weapon/circuitboard/HolodeckControl // Not going to let people get this, but it's just here for future
	name = "Circuit board (Holodeck Control)"
	desc = "A circuit board for running a computer used to control the holodeck."
	build_path = /obj/machinery/computer/HolodeckControl
	origin_tech = Tc_PROGRAMMING + "=4"
/obj/item/weapon/circuitboard/aifixer
	name = "Circuit board (AI Integrity Restorer)"
	desc = "A circuit board for running a computer used to restore the integrity of a destroyed AI."
	build_path = /obj/machinery/computer/aifixer
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=2"
/obj/item/weapon/circuitboard/area_atmos
	name = "Circuit board (Area Air Control)"
	desc = "A circuit board for running a computer used to operate large scrubbers in the vicinity."
	build_path = /obj/machinery/computer/area_atmos
	origin_tech = Tc_PROGRAMMING + "=2"
/obj/item/weapon/circuitboard/prison_shuttle
	name = "Circuit board (Prison Shuttle)"
	desc = "A circuit board for running an obsolete computer used to control the prison shuttle on an ancient station."
	build_path = /obj/machinery/computer/prison_shuttle
	origin_tech = Tc_PROGRAMMING + "=2"
/obj/item/weapon/circuitboard/bhangmeter
	name = "Circuit board (Bhangmeter)"
	desc = "A circuit board for running a computer used to monitor the locations and intensity of explosions."
	build_path = /obj/machinery/computer/bhangmeter
	origin_tech = Tc_PROGRAMMING + "=2"
/obj/item/weapon/circuitboard/telesci_computer
	name = "Circuit board (Telepad Control Console)"
	desc = "A circuit board for running a computer used to operate the Telescience Telepad."
	build_path = /obj/machinery/computer/telescience
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BLUESPACE + "=2"
/obj/item/weapon/circuitboard/forensic_computer
	name = "Circuit board (Forensics Console)"
	desc = "A circuit board for running a computer used to scan objects and view data from portable scanners."
	build_path = /obj/machinery/computer/forensic_scanning
	origin_tech = Tc_PROGRAMMING + "=2"
/obj/item/weapon/circuitboard/pda_terminal
	name = "Circuit board (PDA Terminal)"
	desc = "A circuit board for running a computer used to download applications to PDAs."
	build_path = /obj/machinery/computer/pda_terminal
	origin_tech = Tc_PROGRAMMING + "=2"

/obj/item/weapon/circuitboard/smeltcomp
	name = "Circuit board (Ore Processing Console)"
	desc = "A circuit board for running a computer used to operate ore smelting machines."
	build_path = /obj/machinery/computer/smelting
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2"

/obj/item/weapon/circuitboard/stacking_machine_console
	name = "Circuit board (Stacking Machine Console)"
	desc = "A circuit board for running a computer used to operate stacking machines."
	build_path = /obj/machinery/computer/stacking_unit
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_MATERIALS + "=2"

/obj/item/weapon/circuitboard/attackby(obj/item/I as obj, mob/user as mob)
	if(issolder(I))
		var/obj/item/weapon/solder/S = I
		if(S.remove_fuel(2,user))
			solder_improve(user)
	else if(iswelder(I))
		var/obj/item/weapon/weldingtool/WT = I
		if(WT.remove_fuel(1,user))
			var/obj/item/weapon/circuitboard/blank/B = new /obj/item/weapon/circuitboard/blank(src.loc)
			to_chat(user, "<span class='notice'>You melt away the circuitry, leaving behind a blank.</span>")
			playsound(B.loc, 'sound/items/Welder.ogg', 30, 1)
			if(user.get_inactive_hand() == src)
				user.before_take_item(src)
				user.put_in_hands(B)
			qdel(src)
			return
	return

/obj/item/weapon/circuitboard/proc/solder_improve(mob/user as mob)
	to_chat(user, "<span class='warning'>You fiddle with a few random fuses but can't find a routing that doesn't short the board.</span>")
	return

/obj/item/weapon/circuitboard/supplycomp/solder_improve(mob/user as mob)
	to_chat(user, "<span class='notice'>You [contraband_enabled ? "" : "un"]connect the mysterious fuse.</span>")
	contraband_enabled = !contraband_enabled
	return

/obj/item/weapon/circuitboard/security/solder_improve(mob/user as mob)
	if(istype(src,/obj/item/weapon/circuitboard/security/advanced))
		return ..()
	if(istype(src,/obj/item/weapon/circuitboard/security/engineering))
		return ..()
	else
		to_chat(user, "<span class='notice'>You locate a short that makes the feed circuitry more elegant.</span>")
		var/obj/item/weapon/circuitboard/security/advanced/A = new /obj/item/weapon/circuitboard/security/advanced(src.loc)
		user.put_in_hands(A)
		qdel(src)
		return

/obj/structure/computerframe/attackby(obj/item/P as obj, mob/user as mob)
	switch(state)
		if(0)
			if(iswrench(P) && wrenchAnchor(user))
				src.state = 1
				return 1
			if(iswelder(P))
				var/obj/item/weapon/weldingtool/WT = P
				to_chat(user, "<span class='notice'>You start welding the frame back into metal.</span>")
				if(WT.do_weld(user, src, 10, 0) && state == 0)
					if(gcDestroyed)
						return
					playsound(src, 'sound/items/Welder.ogg', 50, 1)
					user.visible_message("[user] welds the frame back into metal.", "You weld the frame back into metal.", "You hear welding.")
					drop_stack(sheet_type, loc, 5, user)
					state = -1
					qdel(src)
				return 1
		if(1)
			if(iswrench(P) && wrenchAnchor(user))
				src.state = 0
				return 1
			if(istype(P, /obj/item/weapon/circuitboard) && !circuit)
				var/obj/item/weapon/circuitboard/B = P
				if(B.board_type == COMPUTER)
					if(!user.drop_item(B, src))
						return

					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
					user.visible_message("[user] places \the [B] inside the frame.", "You place \the [B] inside the frame.", "You hear metallic sounds.")
					src.icon_state = "1"
					src.circuit = P
				else
					to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				return 1
			if(P.is_screwdriver(user) && circuit)
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("[user] screws the circuit board into place.", "You screw the circuit board into place.", "You hear metallic sounds.")
				src.state = 2
				src.icon_state = "2"
				return 1
			if(iscrowbar(P) && circuit)
				playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
				user.visible_message("[user] removes the circuit board.", "You remove the circuit board", "You hear metallic sounds.")
				src.state = 1
				src.icon_state = "0"
				circuit.forceMove(src.loc)
				src.circuit = null
				return 1
		if(2)
			if(P.is_screwdriver(user) && circuit)
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				user.visible_message("[user] unfastens the circuit board.", "You unfasten the circuit board.", "You hear metallic sounds.")
				src.state = 1
				src.icon_state = "1"
				return 1
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if (C.amount < 5)
					to_chat(user, "<span class='warning'>You need at least 5 lengths of cable coil for this!</span>")
					return 1
				to_chat(user, "You begin to install wires into the frame.")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if (do_after(user, src, 20) && state == 2 && C.amount >= 5)
					C.use(5)
					user.visible_message("[user] installs wires into the frame.", "You install wires into the frame.", "You hear metallic sounds.")
					src.state = 3
					src.icon_state = "3"

				return 1
		if(3)
			if(iswirecutter(P))
				playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
				user.visible_message("[user] unplugs the wires from the frame.", "You unplug the wires from the frame.", "You hear metallic sounds.")
				src.state = 2
				src.icon_state = "2"
				new /obj/item/stack/cable_coil(get_turf(src), 5)
				return 1

			if(istype(P, /obj/item/stack/sheet/glass/glass))
				var/obj/item/stack/sheet/glass/glass/G = P
				if (G.amount < 2)
					to_chat(user, "<span class='warning'>You need at least 2 sheets of glass for this!</span>")
					return 1
				to_chat(user, "<span class='notice'>You start installing the glass panel onto the frame.")
				if(do_after(user, src, 20) && state == 3 && G.amount >= 2)
					playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
					G.use(2)
					user.visible_message("[user] installs the glass panel onto the frame.", "You install the glass panel onto the frame.", "You hear metallic sounds.")
					src.state = 4
					src.icon_state = "4"

				return 1
		if(4)
			if(iscrowbar(P))
				playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
				user.visible_message("[user] removes the glass panel from the frame.", "You remove the glass panel from the frame.", "You hear metallic sounds.")
				src.state = 3
				src.icon_state = "3"
				new /obj/item/stack/sheet/glass/glass( src.loc, 2 )
				return 1
			if(P.is_screwdriver(user))
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				if(!circuit.build_path) // the board has been soldered away!
					to_chat(user, "<span class='warning'>You connect the monitor, but nothing turns on!</span>")
					return
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				var/B = new src.circuit.build_path ( src.loc )
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
				else if(istype(circuit,/obj/item/weapon/circuitboard/arcade))
					var/obj/machinery/computer/arcade/arcade = B
					var/obj/item/weapon/circuitboard/arcade/C = circuit
					arcade.import_game_data(C)
				var/obj/machinery/MA = B
				if(istype(MA))
					MA.power_change()
				qdel(src)
				return 1
	return 0

/obj/structure/computerframe/can_wrench_shuttle()
	return 1

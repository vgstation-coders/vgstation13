//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
#define MACHINE "machine"
#define COMPUTER "computer"
#define EMBEDDED_CONTROLLER "embedded controller"
#define OTHER "other"
/obj/machinery/constructable_frame //Made into a seperate type to make future revisions easier.
	name = "machine frame"
	desc = "A metal frame ready to recieve wires, a circuit board and parts."
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "box_0"
	density = 1
	anchored = 1
	use_power = 0
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/components = null
	var/list/req_components = null
	var/list/req_component_names = null
	var/list/components_in_use = null
	var/build_state = 1

	// For pods
	var/list/connected_parts = list()
	var/pattern_idx=0
	machine_flags = WRENCHMOVE | FIXED2WORK

/obj/machinery/constructable_frame/proc/update_desc()
	var/D
	if(req_components)
		D = "Requires "
		var/first = 1
		for(var/I in req_components)
			if(req_components[I] > 0)
				D += "[first?"":", "][num2text(req_components[I])] [req_component_names[I]]"
				first = 0
		if(first) // nothing needs to be added, then
			D += "nothing"
		D += "."
	desc = D

/obj/machinery/constructable_frame/proc/get_req_components_amt()
	var/amt = 0
	for(var/path in req_components)
		amt += req_components[path]
	return amt

/obj/machinery/constructable_frame/machine_frame/attackby(obj/item/P as obj, mob/user as mob)
	if(P.crit_fail)
		to_chat(user, "<span class='warning'>This part is faulty, you cannot add this to the machine!</span>")
		return
	switch(build_state)
		if(1)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.amount >= 5)
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame.</span>")
					if(do_after(user, src, 20))
						if(C && C.amount >= 5) // Check again
							C.use(5)
							to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
							set_build_state(2)
			else if(istype(P, /obj/item/stack/sheet/glass/glass))
				var/obj/item/stack/sheet/glass/glass/G=P
				if(G.amount<1)
					to_chat(user, "<span class='warning'>How...?</span>")
					return
				G.use(1)
				to_chat(user, "<span class='notice'>You add the glass to the frame.</span>")
				playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
				new /obj/structure/displaycase_frame(src.loc)
				qdel(src)
				return
			else
				if(iswrench(P))
					playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
					to_chat(user, "<span class='notice'>You dismantle the frame.</span>")
					//new /obj/item/stack/sheet/metal(src.loc, 5)
					var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, src.loc)
					M.amount = 5
					qdel(src)
		if(2)
			if(!..())
				if(istype(P, /obj/item/weapon/circuitboard))
					var/obj/item/weapon/circuitboard/B = P
					if(B.board_type == MACHINE)
						if(!user.drop_item(B, src))
							user << "<span class='warning'>You can't let go of \the [B]!</span>"
							return

						playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You add the circuit board to the frame.</span>")
						circuit = P
						set_build_state(3)
						components = list()
						req_components = circuit.req_components.Copy()
						for(var/A in circuit.req_components)
							req_components[A] = circuit.req_components[A]
						req_component_names = circuit.req_components.Copy()
						/* Are you fucking kidding me
						for(var/A in req_components)
							var/cp = text2path(A)
							var/obj/ct = new cp() // have to quickly instantiate it get name
							req_component_names[A] = ct.name
							del(ct)*/
						for(var/A in req_components)
							var/atom/path = text2path(A)
							req_component_names[A] = initial(path.name)
						update_desc() // sets the description based on req_components
						to_chat(user, desc)
					else
						to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
				else
					if(iswirecutter(P))
						playsound(get_turf(src), 'sound/items/Wirecutter.ogg', 50, 1)
						to_chat(user, "<span class='notice'>You remove the cables.</span>")
						set_build_state(1)
						var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( src.loc )
						A.amount = 5

		if(3)
			if(!..())
				if(iscrowbar(P))
					playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
					set_build_state(2)
					circuit.forceMove(src.loc)
					circuit = null
					if(components.len == 0)
						to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
					else
						to_chat(user, "<span class='notice'>You remove the circuit board and other components.</span>")
						for(var/obj/item/weapon/W in components)
							W.forceMove(src.loc)
					desc = initial(desc)
					req_components = null
					components = null
				else
					if(isscrewdriver(P))
						var/component_check = 1
						for(var/R in req_components)
							if(req_components[R] > 0)
								component_check = 0
								break
						if(component_check)
							playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
							var/obj/machinery/new_machine = new src.circuit.build_path(src.loc)
							for(var/obj/O in new_machine.component_parts)
								returnToPool(O)
							new_machine.component_parts = list()
							for(var/obj/O in src)
								if(circuit.contain_parts) // things like disposal don't want their parts in them
									O.forceMove(components_in_use)
								else
									O.forceMove(null)
								new_machine.component_parts += O
							if(circuit.contain_parts)
								circuit.forceMove(components_in_use)
							else
								circuit.forceMove(null)
							new_machine.RefreshParts()
							circuit.finish_building(new_machine, user)
							components = null
							qdel(src)
					else
						if(istype(P, /obj/item/weapon/storage/bag/gadgets/part_replacer) && P.contents.len && get_req_components_amt())
							var/obj/item/weapon/storage/bag/gadgets/part_replacer/replacer = P
							var/list/added_components = list()
							var/list/part_list = replacer.contents.Copy()

							//Sort the parts. This ensures that higher tier items are applied first.
							part_list = sortTim(part_list, /proc/cmp_rped_sort)

							for(var/path in req_components)
								while(req_components[path] > 0 && (locate(text2path(path)) in part_list))
									var/obj/item/part = (locate(text2path(path)) in part_list)
									if(!part.crit_fail)
										added_components[part] = path
										replacer.remove_from_storage(part, src)
										req_components[path]--
										part_list -= part

							for(var/obj/item/weapon/stock_parts/part in added_components)
								components += part
								to_chat(user, "<span class='notice'>[part.name] applied.</span>")
							replacer.play_rped_sound()

							update_desc()

						else
							if(istype(P, /obj/item/weapon) || istype(P, /obj/item/stack))
								for(var/I in req_components)
									if(istype(P, text2path(I)) && (req_components[I] > 0))
										playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
										if(istype(P, /obj/item/stack))
											var/obj/item/stack/CP = P
											if(CP.amount >= req_components[I])
												var/camt = min(CP.amount, req_components[I]) // amount of the stack to take, idealy amount required, but limited by amount provided
												var/obj/item/stack/CC = getFromPool(text2path(I), src)
												CC.amount = camt
												CC.update_icon()
												CP.use(camt)
												components += CC
												req_components[I] -= camt
												update_desc()
												break
											else
												to_chat(user, "<span class='warning'>You do not have enough [P]!</span>")

										if(user.drop_item(P, src))
											components += P
											req_components[I]--
											update_desc()
											break
								to_chat(user, desc)

								if(P && P.loc != src && !istype(P, /obj/item/stack/cable_coil))
									to_chat(user, "<span class='warning'>You cannot add that component to the machine!</span>")

/obj/machinery/constructable_frame/machine_frame/proc/set_build_state(var/state)
	build_state = state
	switch(state)
		if(1)
			icon_state = "box_0"
		if(2)
			icon_state = "box_1"
		if(3)
			icon_state = "box_2"

/obj/item/weapon/circuitboard/proc/finish_building(var/obj/machinery/new_machine, var/mob/user) //Something that will get done after the last step of construction. Currently unused.
	return

//Machine Frame Circuit Boards
/*Common Parts: Parts List: Igniter, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
Note: Once everything is added to the public areas, will add m_amt and g_amt to circuit boards since autolathe won't be able
to destroy them and players will be able to make replacements.
*/

/obj/item/weapon/circuitboard/blank
	name = "unprinted circuitboard"
	desc = "A blank circuitboard ready for design."
	icon = 'icons/obj/module.dmi'
	icon_state = "blank_mod"
	//var/datum/circuits/local_fuses = null
	var/list/allowed_boards = list("autolathe"=/obj/item/weapon/circuitboard/autolathe,"intercom"=/obj/item/weapon/intercom_electronics,"air alarm"=/obj/item/weapon/circuitboard/air_alarm,"fire alarm"=/obj/item/weapon/circuitboard/fire_alarm,"airlock"=/obj/item/weapon/circuitboard/airlock,"APC"=/obj/item/weapon/circuitboard/power_control,"vendomat"=/obj/item/weapon/circuitboard/vendomat,"microwave"=/obj/item/weapon/circuitboard/microwave,"station map"=/obj/item/weapon/circuitboard/station_map)
	var/soldering = 0 //Busy check

/obj/item/weapon/circuitboard/blank/New()
	..()
	//local_fuses = new(src)

/obj/item/weapon/circuitboard/blank/attackby(obj/item/O as obj, mob/user as mob)
	/*if(ismultitool(O))
		var/boardType = local_fuses.assigned_boards["[local_fuses.localbit]"] //Localbit is an int, but this is an associative list organized by strings
		if(boardType)
			if(ispath(boardType))
				to_chat(user, "<span class='notice'>The multitool pings softly.</span>")
				new boardType(get_turf(src))
				qdel(src)
				return
			else
				to_chat(user, "<span class='warning'>A fatal error with the board type occurred. Report this message.</span>")
		else
			to_chat(user, "<span class='warning'>The multitool flashes red briefly.</span>")
	else
		*/if(!soldering&&issolder(O))
		//local_fuses.Interact(user)
		var/t = input(user, "Which board should be designed?") as null|anything in allowed_boards
		if(!t)
			return
		var/obj/item/weapon/solder/S = O
		if(!S.remove_fuel(4,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 50, 1)
		soldering = 1
		if(do_after(user, src,40))
			var/boardType = allowed_boards[t]
			var/obj/item/I = new boardType(get_turf(user))
			to_chat(user, "<span class='notice'>You fashion a crude [I] from the blank circuitboard.</span>")
			qdel(src)
			user.put_in_hands(I)
		soldering = 0
	else if(iswelder(O))
		var/obj/item/weapon/weldingtool/WT = O
		if(WT.remove_fuel(1,user))
			var/obj/item/stack/sheet/glass/glass/new_item = new()
			new_item.forceMove(src.loc) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
			returnToPool(src)
			return
	else
		return ..()

/obj/item/weapon/circuitboard/destructive_analyzer
	name = "Circuit board (Destructive Analyzer)"
	desc = "A circuit board used to run a machine that destroys objects to extract structural information for research."
	build_path = "/obj/machinery/r_n_d/destructive_analyzer"
	board_type = MACHINE
	origin_tech = Tc_MAGNETS + "=2;" + Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/obj/item/weapon/circuitboard/autolathe
	name = "Circuit board (Autolathe)"
	desc = "A circuit board used to run a machine that fabricates various general-purpose gadgets and tools."
	build_path = "/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/protolathe
	name = "Circuit board (Protolathe)"
	desc = "A circuit board used to run a machine that fabricates various cutting-edge gadgets and tools."
	build_path = "/obj/machinery/r_n_d/fabricator/protolathe"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/circuit_imprinter
	name = "Circuit board (Circuit Imprinter)"
	desc = "A circuit board used to run a machine that fabricates circuit boards. How recursive."
	build_path = "/obj/machinery/r_n_d/fabricator/circuit_imprinter"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2)

/obj/item/weapon/circuitboard/pacman
	name = "Circuit Board (PACMAN-type Generator)"
	desc = "A circuit board used to run a machine that converts plasma into electricity."
	build_path = "/obj/machinery/power/port_gen/pacman"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_POWERSTORAGE + "=3;" + Tc_PLASMATECH + "=3;" + Tc_ENGINEERING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/pacman/super
	name = "Circuit Board (SUPERPACMAN-type Generator)"
	desc = "A circuit board used to run a machine that converts uranium into electricity."
	build_path = "/obj/machinery/power/port_gen/pacman/super"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_POWERSTORAGE + "=4;" + Tc_ENGINEERING + "=4"

/obj/item/weapon/circuitboard/pacman/mrs
	name = "Circuit Board (MRSPACMAN-type Generator)"
	desc = "A circuit board used to run a machine that converts diamonds into electricity."
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_POWERSTORAGE + "=5;" + Tc_ENGINEERING + "=5"

/obj/item/weapon/circuitboard/air_alarm
	name = "Circuit board (Air Alarm)"
	desc = "A circuit board used to run an air alarm."
	board_type= OTHER
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	//origin_tech = Tc_PROGRAMMING + "=2"

/obj/item/weapon/circuitboard/fire_alarm
	name = "Circuit board (Fire Alarm)"
	desc = "A circuit board used to run a fire alarm."
	board_type= OTHER
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	//origin_tech = Tc_PROGRAMMING + "=2"

/obj/item/weapon/circuitboard/airlock
	name = "Circuit board (Airlock)"
	desc = "A circuit board used to operate airlocks and their access controls."
	board_type= OTHER
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	//origin_tech = Tc_PROGRAMMING + "=2"

obj/item/weapon/circuitboard/rdserver
	name = "Circuit Board (R&D Server)"
	desc = "A circuit board used to run a R&D server."
	build_path = "/obj/machinery/r_n_d/server"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/mechfab
	name = "Circuit board (Exosuit Fabricator)"
	desc = "A circuit board used to run a robotics fabricator."
	build_path = "/obj/machinery/r_n_d/fabricator/mech"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/podfab
	name = "Circuit board (Spacepod Fabricator)"
	desc = "A circuit board used to run a spacepod fabricator."
	build_path = "/obj/machinery/r_n_d/fabricator/pod"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2)

/obj/item/weapon/circuitboard/defib_recharger
	name = "Circuit Board (Defib Recharger)"
	desc = "A circuit board used to run a defibrillator recharger."
	build_path = "/obj/machinery/recharger/defibcharger/wallcharger"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=4;" + Tc_ENGINEERING + "=2;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/smes
	name = "Circuit Board (SMES)"
	desc = "A circuit board used to run a gas freezer."
	build_path = "/obj/machinery/power/battery/smes"
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_ENGINEERING + "=4;" + Tc_PROGRAMMING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 4,
							"/obj/item/weapon/stock_parts/micro_laser" = 4,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/port_smes
	name = "Circuit Board (Portable SMES)"
	desc = "A circuit board used to run a giant portable battery."
	build_path = "/obj/machinery/power/battery/portable"
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=5;" + Tc_ENGINEERING + "=4;" + Tc_PROGRAMMING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 4,
							"/obj/item/weapon/stock_parts/micro_laser" = 4,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/battery_port
	name = "Circuit Board (SMES Port)"
	desc = "A circuit board used to run the base station for a giant portable battery."
	build_path = "/obj/machinery/power/battery_port"
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=5;" + Tc_ENGINEERING + "=4;" + Tc_PROGRAMMING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/capacitor" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/treadmill
	name = "Circuit Board (Treadmill Generator)"
	desc = "A circuit board used to run a machine that converts kinetic energy into power."
	build_path = "/obj/machinery/power/treadmill"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_POWERSTORAGE + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/capacitor" = 4,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/chem_dispenser
	name = "Circuit Board (Chemistry Dispenser)"
	desc = "A circuit board used to run a reagent dispensing machine."
	build_path = "/obj/machinery/chem_dispenser"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=5;" + Tc_ENGINEERING + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/chem_dispenser/brewer
	name = "Circuit Board (Brewer)"
	desc = "A circuit board used to run a coffee and tea dispensing machine."
	build_path = "/obj/machinery/chem_dispenser/brewer"

/obj/item/weapon/circuitboard/chem_dispenser/soda_dispenser
	name = "Circuit Board (Soda Dispenser)"
	desc = "A circuit board used to run a soda dispensing machine."
	build_path = "/obj/machinery/chem_dispenser/soda_dispenser"

/obj/item/weapon/circuitboard/chem_dispenser/booze_dispenser
	name = "Circuit Board (Booze Dispenser)"
	desc = "A circuit board used to run an advanced bartending machine."
	build_path = "/obj/machinery/chem_dispenser/booze_dispenser"

/obj/item/weapon/circuitboard/chemmaster3000
	name = "Circuit Board (ChemMaster 3000)"
	desc = "A circuit board used to run a reagent pill and bottle making machine."
	build_path = "/obj/machinery/chem_master"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/condimaster
	name = "Circuit Board (CondiMaster)"
	desc = "A circuit board used to run a condiment bottle making machine."
	build_path = "/obj/machinery/chem_master/condimaster"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 3,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/snackbar_machine
	name = "Circuit Board (SnackBar Machine)"
	desc = "A circuit board used to run a snackbar making machine."
	build_path = "/obj/machinery/chem_master/snackbar_machine"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2)

/obj/item/weapon/circuitboard/recharge_station
	name = "Circuit Board (Cyborg Recharging Station)"
	desc = "A circuit board used to run a cyborg recharging station."
	build_path = "/obj/machinery/recharge_station"
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=4;" + Tc_PROGRAMMING + "=3"
	req_components = list (
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/matter_bin" = 1)

/obj/item/weapon/circuitboard/heater
	name = "Circuit Board (Heater)"
	desc = "A circuit board used to run a gas heater."
	build_path = "/obj/machinery/atmospherics/unary/heat_reservoir/heater"
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=3;" + Tc_ENGINEERING + "=5;" + Tc_BIOTECH + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/freezer
	name = "Circuit Board (Freezer)"
	desc = "A circuit board used to run a gas freezer."
	build_path = "/obj/machinery/atmospherics/unary/cold_sink/freezer"
	board_type = MACHINE
	origin_tech = Tc_POWERSTORAGE + "=3;" + Tc_ENGINEERING + "=4;" + Tc_BIOTECH + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/photocopier
	name = "Circuit Board (Photocopier)"
	desc = "A circuit board used to run a photocopier."
	build_path = "/obj/machinery/photocopier"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=2"
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 2,)

/obj/item/weapon/circuitboard/cryo
	name = "Circuit Board (Cryo)"
	desc = "A circuit board used to run a medical cryogenics cell."
	build_path = "/obj/machinery/atmospherics/unary/cryo_cell"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=3;" + Tc_ENGINEERING + "=2"
	req_components = list (
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 3,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/clonepod
	name = "Circuit board (Clone Pod)"
	desc = "A circuit board used to run a medical cloning pod."
	build_path = "/obj/machinery/cloning/clonepod"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/clonescanner
	name = "Circuit board (Cloning Scanner)"
	desc = "A circuit board used to run a medical cloning scanner."
	build_path = "/obj/machinery/dna_scannernew"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_BIOTECH + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/fullbodyscanner
	name = "Circuit board (Full Body Scanner)"
	build_path = "/obj/machinery/bodyscanner"
	desc = "A circuit board used to run a medical bodyscanner."
	board_type = MACHINE
	origin_tech = Tc_BIOTECH + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 3)

/obj/item/weapon/circuitboard/sleeper
	name = "Circuit board (Sleeper)"
	desc = "A circuit board used to run a medical sleeper."
	build_path = "/obj/machinery/sleeper"
	board_type = MACHINE
	origin_tech = Tc_BIOTECH + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/sleeper/mancrowave
	name = "Circuit board (Thermal Homeostasis Regulator)"
	desc = "A circuit board used to run a general purpose kit- err, a medical re-heating apparatus."
	build_path = "/obj/machinery/sleeper/mancrowave"

/obj/item/weapon/circuitboard/biogenerator
	name = "Circuit Board (Biogenerator)"
	desc = "A circuit board used to run a machine that converts biomatter into various useful items."
	build_path = "/obj/machinery/biogenerator"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker/large" = 1)

/obj/item/weapon/circuitboard/seed_extractor
	name = "Circuit Board (Seed Extractor)"
	desc = "A circuit board used to run a machine that extracts and packets seeds from plants."
	build_path = "/obj/machinery/seed_extractor"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_BIOTECH + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/microwave
	name = "Circuit Board (Microwave)"
	desc = "A circuit board used to run a general purpose kitchen appliance."
	build_path = "/obj/machinery/microwave"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_ENGINEERING + "=2;" + Tc_MAGNETS + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/reagentgrinder
	name = "Circuit Board (All-In-One Grinder)"
	desc = "A circuit board used to run a machine that grinds or juices solid items.."
	build_path = "/obj/machinery/reagentgrinder"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker/large" = 1)

/obj/item/weapon/circuitboard/smartfridge
	name = "Circuit Board (SmartFridge)"
	desc = "A circuit board used to run a machine that will hold grown plants, seeds, meat, and eggs."
	build_path = "/obj/machinery/smartfridge"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 4,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 2)



/obj/item/weapon/circuitboard/smartfridge/attackby(var/obj/item/weapon/G, var/mob/user)
	if(issolder(G))
		var/obj/item/weapon/solder/S = G
		var/list/static/smartfridge_choices = list(
			"Food smartfridge" = /obj/item/weapon/circuitboard/smartfridge/,
			"Secure chemistry smartfridge" = /obj/item/weapon/circuitboard/smartfridge/medbay,
			"Chemistry smartfridge" = /obj/item/weapon/circuitboard/smartfridge/chemistry,
			"Slime extract smartfridge" = /obj/item/weapon/circuitboard/smartfridge/extract,
			"Seed smartfridge" = /obj/item/weapon/circuitboard/smartfridge/seeds,
			"Drinks smartfridge" = /obj/item/weapon/circuitboard/smartfridge/drinks,
		)

		var/choice = input(usr, "Which configuration would you like to set this board?", "According to the manual, if I disconnect this node, and connect this node...") in smartfridge_choices
		if(choice)
			var/obj/item/weapon/circuitboard/smartfridge/to_spawn = smartfridge_choices[choice]
			if(istype(src, to_spawn))
				to_chat(user, "<span class = 'notice'>This board is already this type</span>")
				return
			if(do_after(user, src, 25))
				if(S.remove_fuel(1,user))
					playsound(user.loc, 'sound/items/Welder.ogg', 25, 1)
					visible_message("<span class = 'notice'>\The [user] refashions \the [src] into \the [to_spawn]</span>")
					build_path = initial(to_spawn.build_path)
					name = initial(to_spawn.name)
					return
	..()
/obj/item/weapon/circuitboard/smartfridge/medbay
	name = "Circuit Board (Medbay SmartFridge)"
	desc = "A circuit board used to run a machine that will hold beakers, pills and pill bottles."
	build_path = "/obj/machinery/smartfridge/secure/medbay"

/obj/item/weapon/circuitboard/smartfridge/chemistry
	name = "Circuit Board (Chemical SmartFridge)"
	desc = "A circuit board used to run a machine that will hold beakers and pill bottles."
	build_path = "/obj/machinery/smartfridge/chemistry"

/obj/item/weapon/circuitboard/smartfridge/extract
	name = "Circuit Board (Extract SmartFridge)"
	desc = "A circuit board used to run a machine that will hold slime extracts."
	build_path = "/obj/machinery/smartfridge/extract"

/obj/item/weapon/circuitboard/smartfridge/seeds
	name = "Circuit Board (Megaseed Servitor)"
	desc = "A circuit board used to run a machine that will hold seed packets."
	build_path = "/obj/machinery/smartfridge/seeds"

/obj/item/weapon/circuitboard/smartfridge/drinks
	name = "Circuit Board (Drinks Showcase)"
	desc = "A circuit board used to run a machine that will hold glasses, drinks and condiments."
	build_path = "/obj/machinery/smartfridge/drinks"

/obj/item/weapon/circuitboard/hydroponics
	name = "Circuit Board (Hydroponics Tray)"
	desc = "A circuit board used to run a machine that holds and nurtures plants."
	build_path = "/obj/machinery/portable_atmospherics/hydroponics"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/gibber
	name = "Circuit Board (Gibber)"
	desc = "A circuit board used to run a machine that turns live humanoids into pieces of meat."
	build_path = "/obj/machinery/gibber"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 4,
							"/obj/item/weapon/stock_parts/micro_laser/high" = 4)

/obj/item/weapon/circuitboard/processor
	name = "Circuit Board (Food Processor)"
	desc = "A circuit board used to run a machine that improves and converts food ingredients."
	build_path = "/obj/machinery/processor"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/egg_incubator
	name = "Circuit Board (Egg Incubator)"
	desc = "A circuit board used to run a machine that incubates eggs."
	build_path = "/obj/machinery/egg_incubator"
	board_type = MACHINE
	origin_tech = Tc_BIOTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/box_cloner
	name = "Circuit Board (Box Cloner)"
	build_path = "/obj/machinery/egg_incubator/box_cloner"
	desc = "A circuit board used to run a machine that clones Boxen for meat and pet use."
	origin_tech = Tc_SYNDICATE + "=3"
	board_type = MACHINE
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/monkey_recycler
	name = "Circuit Board (Monkey Recycler)"
	desc = "A circuit board used to run a machine that turns dead monkeys into monkey cubes."
	build_path = "/obj/machinery/monkey_recycler"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/*
/obj/item/weapon/circuitboard/hydroseeds
	name = "Circuit Board (MegaSeed Servitor)"
	build_path = "/obj/machinery/vending/hydroseeds"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/hydronutrients
	name = "Circuit Board (Nutrimax)"
	build_path = "/obj/machinery/vending/hydronutrients"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)
*/

/obj/item/weapon/circuitboard/pipedispenser
	name = "Circuit Board (Pipe Dispenser)"
	desc = "A circuit board used to run a machine that fabricates atmospherical pipes and devices."
	build_path = "/obj/machinery/pipedispenser"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/pipedispenser/disposal
	name = "Circuit Board (Disposal Pipe Dispenser)"
	desc = "A circuit board used to run a machine that fabricates disposals pipes and devices."
	build_path = "/obj/machinery/pipedispenser/disposal"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3;" + Tc_POWERSTORAGE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 2)




//Teleporter
/obj/item/weapon/circuitboard/telehub
	name = "Circuit Board (Teleporter Hub)"
	desc = "A circuit board used to run a machine that works as the base for a teleporter."
	build_path = "/obj/machinery/teleport/hub"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=3;" + Tc_BLUESPACE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module/adv/phasic" = 2,
							"/obj/item/weapon/stock_parts/capacitor/adv/super" = 3,
							"/obj/item/weapon/stock_parts/subspace/ansible" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 2,
							"/obj/item/weapon/stock_parts/subspace/treatment" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 2,
							"/obj/item/weapon/stock_parts/subspace/transmitter" = 4)

/obj/item/weapon/circuitboard/telestation
	name = "Circuit Board (Teleporter Station)"
	desc = "A circuit board used to run a machine that generates an active teleportation field."
	build_path = "/obj/machinery/teleport/station"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=3;" + Tc_BLUESPACE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module/adv/phasic" = 2,
							"/obj/item/weapon/stock_parts/capacitor/adv/super" = 2,
							"/obj/item/weapon/stock_parts/subspace/ansible" = 2,
							"/obj/item/weapon/stock_parts/subspace/analyzer" = 4)

// Telecomms circuit boards:

/obj/item/weapon/circuitboard/telecomms/receiver
	name = "Circuit Board (Subspace Receiver)"
	desc = "A circuit board used to run a machine that recieves subspace transmissions in telecommunications systems."
	build_path = "/obj/machinery/telecomms/receiver"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=3;" + Tc_BLUESPACE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/subspace/ansible" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 1)

/obj/item/weapon/circuitboard/telecomms/hub
	name = "Circuit Board (Hub Mainframe)"
	desc = "A circuit board used to run a machine that works as a hub for a telecommunications system."
	build_path = "/obj/machinery/telecomms/hub"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 2)

/obj/item/weapon/circuitboard/telecomms/relay
	name = "Circuit Board (Relay Mainframe)"
	desc = "A circuit board used to run a machine that works as a relay for a telecommunications system."
	build_path = "/obj/machinery/telecomms/relay"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=4;" + Tc_BLUESPACE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/subspace/filter" = 2)

/obj/item/weapon/circuitboard/telecomms/bus
	name = "Circuit Board (Bus Mainframe)"
	desc = "A circuit board used to run a machine that works as a bus for a telecommunications system."
	build_path = "/obj/machinery/telecomms/bus"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1)

/obj/item/weapon/circuitboard/telecomms/processor
	name = "Circuit Board (Processor Unit)"
	desc = "A circuit board used to run a machine that works as a processing unit for a telecommunications system."
	build_path = "/obj/machinery/telecomms/processor"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 3,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/subspace/treatment" = 2,
							"/obj/item/weapon/stock_parts/subspace/analyzer" = 1,
							"/obj/item/stack/cable_coil" = 2,
							"/obj/item/weapon/stock_parts/subspace/amplifier" = 1)

/obj/item/weapon/circuitboard/telecomms/server
	name = "Circuit Board (Telecommunication Server)"
	desc = "A circuit board used to run a machine that works as a frequency server for a telecommunications system."
	build_path = "/obj/machinery/telecomms/server"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1)

/obj/item/weapon/circuitboard/telecomms/broadcaster
	name = "Circuit Board (Subspace Broadcaster)"
	desc = "A circuit board used to run a machine that sends subspace transmissions in telecommunications systems."
	build_path = "/obj/machinery/telecomms/broadcaster"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=4;" + Tc_BLUESPACE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/stack/cable_coil" = 1,
							"/obj/item/weapon/stock_parts/subspace/filter" = 1,
							"/obj/item/weapon/stock_parts/subspace/crystal" = 1,
							"/obj/item/weapon/stock_parts/micro_laser/high" = 2)

/obj/item/weapon/circuitboard/bioprinter
	name = "Circuit Board (Bioprinter)"
	desc = "A circuit board used to run a machine that fabricates live organs."
	build_path = "/obj/machinery/bioprinter"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=2;" + Tc_BIOTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 3,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/reverse_engine
	name = "Circuit Board (Reverse Engine)"
	desc = "A circuit board used to run a machine that analyzes designs from a device analyzer."
	build_path = "/obj/machinery/r_n_d/reverse_engine"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=6;" + Tc_PROGRAMMING + "=4;" + Tc_ENGINEERING + "=3;" + Tc_BLUESPACE + "=3;" + Tc_POWERSTORAGE + "=4"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/capacitor" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/generalfab
	name = "Circuit Board (General Fabricator)"
	desc = "A circuit board used to run a machine that loads blueprints to fabricate items."
	build_path = "/obj/machinery/r_n_d/fabricator/mechanic_fab"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2)

/obj/item/weapon/circuitboard/flatpacker
	name = "Circuit Board (Flatpack Fabricator)"
	desc = "A circuit board used to run a machine that loads blueprints to fabricate machines."
	build_path = "/obj/machinery/r_n_d/fabricator/mechanic_fab/flatpacker"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=5;" + Tc_ENGINEERING + "=4;" + Tc_POWERSTORAGE + "=3;" + Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 1)

/obj/item/weapon/circuitboard/blueprinter
	name = "Circuit Board (Blueprint Printer)"
	desc = "A circuit board used to run a machine that prints blueprints for the general and flatpack fabricators."
	build_path = "/obj/machinery/r_n_d/blueprinter"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/vendomat
	name = "Circuit Board (Vending Machine)"
	desc = "A circuit board used to run a machine that vends items."
	build_path = "/obj/machinery/vending"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1;" + Tc_POWERSTORAGE + "=1"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/obj/item/weapon/circuitboard/pdapainter
	name = "Circuit Board (PDA Painter)"
	desc = "A circuit board used to run a machine that fabricates and re-colors PDAs."
	build_path = "/obj/machinery/pdapainter"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=2;" + Tc_ENGINEERING + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/incubator
	name = "Circuit Board (Pathogenic Incubator)"
	desc = "A circuit board used to run a machine that incubates viruses."
	build_path = "/obj/machinery/disease2/incubator"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=4;" + Tc_BIOTECH + "=5;" + Tc_MAGNETS + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/reagent_containers/glass/beaker" = 1)

/obj/item/weapon/circuitboard/diseaseanalyser
	name = "Circuit Board (Disease Analyser)"
	desc = "A circuit board used to run a machine that analyzes diseases."
	build_path = "/obj/machinery/disease2/diseaseanalyser"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=3;" + Tc_PROGRAMMING + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/micro_laser" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 3)

/obj/item/weapon/circuitboard/centrifuge
	name = "Circuit Board (Isolation Centrifuge)"
	desc = "A circuit board used to run a machine that isolates pathogens and antibodies."
	build_path = "/obj/machinery/centrifuge"
	board_type = MACHINE
	origin_tech = Tc_BIOTECH + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/manipulator" = 2)

/obj/item/weapon/circuitboard/mech_bay_power_port
	name = "Circuit Board (Power Port)"
	desc = "A circuit board used to run a machine that supplies power to a recharge station."
	build_path = "/obj/machinery/mech_bay_recharge_port"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=2;" + Tc_POWERSTORAGE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1)

/obj/item/weapon/circuitboard/mech_bay_recharge_station
	name = "Circuit Board (Recharge Station)"
	desc = "A circuit board used to run a machine that charges exosuit power cells."
	build_path = "/obj/machinery/mech_bay_recharge_floor"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=2;" + Tc_POWERSTORAGE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/prism
	name = "Circuit Board (Prism)"
	desc = "A circuit board used to run a piece of glass."
	build_path = "/obj/machinery/prism"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=3;" + Tc_ENGINEERING + "=3;" + Tc_POWERSTORAGE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/micro_laser/high" = 3,
							"/obj/item/weapon/stock_parts/capacitor" = 6)

/obj/item/weapon/circuitboard/cell_charger
	name = "Circuit Board (Cell Charger)"
	desc = "A circuit board used to run a small device that recharges power cells."
	build_path = "/obj/machinery/cell_charger"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2;" + Tc_POWERSTORAGE + "=3"
	req_components = list(
							"/obj/item/weapon/stock_parts/scanning_module" = 1,
							"/obj/item/weapon/stock_parts/capacitor" = 2)

/obj/item/weapon/circuitboard/washing_machine
	name = "Circuit Board (Washing Machine)"
	desc = "A circuit board used to run a machine that cleans clothing and kills pets."
	build_path = "/obj/machinery/washing_machine"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=1"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 1,
							"/obj/item/weapon/stock_parts/manipulator" = 1)

/obj/item/weapon/circuitboard/sorting_machine
	name = "Circuit Board (Sorting Machine)"
	desc = "A circuit board used to run a machine that sorts input into two outputs from pre-programmed settings."
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=3"
	req_components = list(  //Matter bins because it's moving matter, I guess, and a capacitor because else the recipe is boring.
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/sorting_machine/recycling
	name = "Circuit Board (Recycling Sorting Machine)"
	desc = "A circuit board used to run a machine that sorts input into two outputs from pre-programmed settings. This one is programmed for recycling."
	build_path = "/obj/machinery/sorting_machine/recycling"

/obj/item/weapon/circuitboard/sorting_machine/destination
	name = "Circuit Board (Destinations Sorting Machine)"
	desc = "A circuit board used to run a machine that sorts input into two outputs from pre-programmed settings. This one is programmed for mail."
	build_path = "/obj/machinery/sorting_machine/destination"

/obj/item/weapon/circuitboard/processing_unit
	name = "Circuit Board (Ore Processor)"
	desc = "A circuit board used to run a machine that smelts mineral ores into sheets."
	build_path = "/obj/machinery/mineral/processing_unit"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/matter_bin" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2)

/obj/item/weapon/circuitboard/processing_unit/recycling
	name = "Circuit Board (Recycling Furnace)"
	desc = "A circuit board used to run a machine that smelts items into mineral sheets."
	build_path = "/obj/machinery/mineral/processing_unit/recycle"

/obj/item/weapon/circuitboard/stacking_unit
	name = "Circuit Board (Stacking Machine)"
	desc = "A circuit board used to run a machine that stacks mineral sheets."
	build_path = "/obj/machinery/mineral/stacking_machine"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=3;" + Tc_ENGINEERING + "=2;" + Tc_PROGRAMMING + "=2"
	req_components = list(  //Matter bins because it's moving matter, I guess, and a capacitor because else the recipe is boring.
							"/obj/item/weapon/stock_parts/matter_bin" = 3,
							"/obj/item/weapon/stock_parts/capacitor" = 1)

/obj/item/weapon/circuitboard/fax
	name = "Circuit Board (Fax Machine)"
	desc = "A circuit board used to run a machine that sends pieces of paper through bluespace."
	build_path = "/obj/machinery/faxmachine"
	board_type = MACHINE
	origin_tech = Tc_MATERIALS + "=2;" + Tc_BLUESPACE + "=2"
	req_components = list(
							"/obj/item/weapon/stock_parts/subspace/ansible" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 1)

/*
 * Xenobotany
*/

/obj/item/weapon/circuitboard/botany_centrifuge
	name = "Circuit Board (Lysis-Isolation Centrifuge)"
	desc = "A circuit board used to run a machine that isolates aspects of plants."
	build_path = "/obj/machinery/botany/extractor"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=3"
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 2,
							"/obj/item/weapon/stock_parts/matter_bin" = 1)

/obj/item/weapon/circuitboard/botany_bioballistic
	name = "Circuit Board (Bioballistic Delivery System)"
	desc = "A circuit board used to run a machine that can modify plants."
	build_path = "/obj/machinery/botany/editor"
	board_type = MACHINE
	origin_tech = Tc_ENGINEERING + "=3;" + Tc_BIOTECH + "=3"
	req_components = list (
							"/obj/item/weapon/stock_parts/manipulator" = 1,
							"/obj/item/weapon/stock_parts/scanning_module" = 2,
							"/obj/item/weapon/stock_parts/micro_laser" = 2,
							"/obj/item/weapon/stock_parts/console_screen" = 1,)
/*
 * Xenoarcheology
*/

/obj/item/weapon/circuitboard/anom
	name = "Circuit Board (Fourier Transform Spectroscope)"
	desc = "A circuit board used to run a machine used in xenoarcheology."
	build_path = "/obj/machinery/anomaly/fourier_transform"
	board_type = MACHINE
	origin_tech = Tc_PROGRAMMING + "=4"
	req_components = list (
							"/obj/item/weapon/stock_parts/scanning_module" = 3)

/obj/item/weapon/circuitboard/anom/accelerator
	name = "Circuit Board (Accelerator Spectrometer)"
	desc = "A circuit board used to run a machine used in xenoarcheology."
	build_path = "/obj/machinery/anomaly/accelerator"

/obj/item/weapon/circuitboard/anom/gas
	name = "Circuit Board (Gas Chromatography Spectrometer)"
	desc = "A circuit board used to run a machine used in xenoarcheology."
	build_path = "/obj/machinery/anomaly/gas_chromatography"

/obj/item/weapon/circuitboard/anom/hyper
	name = "Circuit Board (Hyperspectral Imager)"
	desc = "A circuit board used to run a machine used in xenoarcheology."
	build_path = "/obj/machinery/anomaly/hyperspectral"

/obj/item/weapon/circuitboard/anom/ion
	name = "Circuit Board (Ion Mobility Spectrometer)"
	desc = "A circuit board used to run a machine used in xenoarcheology."
	build_path = "/obj/machinery/anomaly/ion_mobility"

/obj/item/weapon/circuitboard/anom/iso
	name = "Circuit Board (Isotope Ratio Spectrometer)"
	desc = "A circuit board used to run a machine used in xenoarcheology."
	build_path = "/obj/machinery/anomaly/isotope_ratio"

/obj/machinery/mech_bay_recharge_floor
	name = "Mech Bay Recharge Station"
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_floor"
	var/obj/machinery/mech_bay_recharge_port/recharge_port
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/obj/recharging_mecha = null
	var/capacitor_max = 0 //How much can be stored
	var/capacitor_stored = 0 //How much is presently stored
	layer = ABOVE_TILE_LAYER
	plane = ABOVE_TURF_PLANE
	anchored = 1
	density = 0

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/mech_bay_recharge_floor/New()
	..()
	component_parts = newlist(/obj/item/weapon/circuitboard/mech_bay_recharge_station,
								/obj/item/weapon/stock_parts/scanning_module,
								/obj/item/weapon/stock_parts/capacitor,
								/obj/item/weapon/stock_parts/capacitor)

/obj/machinery/mech_bay_recharge_floor/RefreshParts()
	var/capcount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			capcount += SP.rating-1
	capacitor_max = initial(capacitor_max)+(capcount * 750)

/obj/machinery/mech_bay_recharge_floor/process()
	..()
	if(recharging_mecha&&capacitor_stored)
		var/obj/item/weapon/cell/C = recharging_mecha.get_cell()
		C.give(capacitor_stored)
		capacitor_stored = 0
	else if(capacitor_stored<capacitor_max && recharge_port && !recharging_mecha)
		var/delta = min(recharge_port.pr_recharger.max_charge,capacitor_max-capacitor_stored)
		use_power(delta*150)
		capacitor_stored += delta

/obj/machinery/mech_bay_recharge_floor/Crossed(var/atom/A)
	. = ..()
	var/obj/O
	if(istype(A, /obj/mecha))
		O = A
	else if(ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.head && istype(H.head,/obj/item/clothing/head/helmet/stun))
			O = H.head
	if(!O)
		return

	to_mech(O,"<b>Initializing power control devices.</b>")
	init_devices()
	if(recharge_console && recharge_port)
		recharging_mecha = O
		recharge_console.mecha_in(O)
		return
	else if(!recharge_console)
		to_mech(O,"<span class='rose'>Control console not found. Terminating.</span>")
	else if(!recharge_port)
		to_mech(O,"<span class='rose'>Power port not found. Terminating.</span>")

/obj/machinery/mech_bay_recharge_floor/Uncrossed(atom)
	. = ..()
	if(atom == recharging_mecha)
		recharging_mecha = null
		if(recharge_console)
			recharge_console.mecha_out()
	else if(ishuman(atom))
		var/mob/living/carbon/human/C = atom
		if(C.head == recharging_mecha)
			recharging_mecha = null
			if(recharge_console)
				recharge_console.mecha_out()

/obj/machinery/mech_bay_recharge_floor/proc/init_devices()
	recharge_console = locate() in range(1,src)
	recharge_port = locate(/obj/machinery/mech_bay_recharge_port, get_step(src, WEST))
	if(recharge_console)
		recharge_console.recharge_floor = src
		if(recharge_port)
			recharge_console.recharge_port = recharge_port
	if(recharge_port)
		recharge_port.recharge_floor = src
		if(recharge_console)
			recharge_port.recharge_console = recharge_console
	return


/obj/machinery/mech_bay_recharge_port
	name = "Mech Bay Power Port"
	density = 1
	anchored = 1
	icon = 'icons/mecha/mech_bay.dmi'
	icon_state = "recharge_port"
	var/obj/machinery/mech_bay_recharge_floor/recharge_floor
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/datum/global_iterator/mech_bay_recharger/pr_recharger

	machine_flags = SCREWTOGGLE | CROWDESTROY

/obj/machinery/mech_bay_recharge_port/New()
	..()

	component_parts = newlist(/obj/item/weapon/circuitboard/mech_bay_power_port,
								/obj/item/weapon/stock_parts/micro_laser,
								/obj/item/weapon/stock_parts/micro_laser,
								/obj/item/weapon/stock_parts/console_screen)

	pr_recharger = new /datum/global_iterator/mech_bay_recharger(null,0)

	RefreshParts()
	return

/obj/machinery/mech_bay_recharge_port/RefreshParts()
	var/lasercount = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/micro_laser))
			lasercount += SP.rating-1
	set_voltage(450+lasercount*100)

/obj/machinery/mech_bay_recharge_port/proc/start_charge(var/obj/recharging_mecha)
	if(stat&(NOPOWER|BROKEN))
		to_mech(recharging_mecha,"<span class='rose'>Power port not responding. Terminating.</span>")
		return 0
	else
		var/obj/item/weapon/cell/C = recharging_mecha.get_cell()
		if(C)
			to_mech(recharging_mecha,"Now charging...")
			pr_recharger.start(list(src, recharging_mecha))
			return 1
		else
			return 0

/obj/machinery/mech_bay_recharge_port/proc/stop_charge()
	if(recharge_console && !recharge_console.stat)
		recharge_console.icon_state = initial(recharge_console.icon_state)
	pr_recharger.stop()
	return

/obj/machinery/mech_bay_recharge_port/proc/active()
	if(pr_recharger.active())
		return 1
	else
		return 0

/obj/machinery/mech_bay_recharge_port/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
			pr_recharger.stop()
	return

/obj/machinery/mech_bay_recharge_port/proc/set_voltage(new_voltage)
	if(new_voltage && isnum(new_voltage))
		pr_recharger.max_charge = new_voltage
		return 1
	else
		return 0


/datum/global_iterator/mech_bay_recharger
	delay = 20
	var/max_charge = 450
	check_for_null = 0 //since port.stop_charge() must be called. The checks are made in process()

/datum/global_iterator/mech_bay_recharger/process(var/obj/machinery/mech_bay_recharge_port/port, var/obj/O)
	if(!port)
		return 0
	if(O && (port.recharge_floor in get_turf(O)))
		var/obj/item/weapon/cell/C = O.get_cell()
		if(!C)
			return
		var/delta = min(max_charge, C.maxcharge - C.charge)
		if(delta>0)
			C.give(delta)
			port.use_power(delta*150)
		else
			to_mech(O,"<span class='notice'><b>Fully charged.</b></span>")
			port.stop_charge()
	else
		port.stop_charge()


/proc/to_mech(var/obj/O, var/chat)
	if(istype(O, /obj/mecha))
		var/obj/mecha/M = O
		M.occupant_message(chat)
	else if(isliving(O.loc))
		to_chat(O.loc,chat)

/obj/machinery/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console"
	density = 1
	anchored = 1
	icon = 'icons/obj/computer.dmi'
	icon_state = "recharge_comp"
	circuit = "/obj/item/weapon/circuitboard/mech_bay_power_console"
	var/autostart = 1
	var/voltage = 45
	var/obj/machinery/mech_bay_recharge_floor/recharge_floor
	var/obj/machinery/mech_bay_recharge_port/recharge_port

	light_color = LIGHT_COLOR_PINK

/obj/machinery/computer/mech_bay_power_console/proc/mecha_in(var/obj/O)
	if(stat&(NOPOWER|BROKEN))
		to_mech(O,"<span class='rose'>Control console not responding. Terminating...</span>")
		return
	if(recharge_port && autostart)
		var/answer = recharge_port.start_charge(O)
		if(answer)
			icon_state = initial(src.icon_state)+"_on"

/obj/machinery/computer/mech_bay_power_console/proc/mecha_out()
	if(recharge_port)
		recharge_port.stop_charge()

/obj/machinery/computer/mech_bay_power_console/power_change()
	if(stat & BROKEN)
		icon_state = initial(icon_state) +"_broken"
		if(recharge_port)
			recharge_port.stop_charge()
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			icon_state = initial(icon_state)+"_nopower"
			stat |= NOPOWER
			if(recharge_port)
				recharge_port.stop_charge()

/obj/machinery/computer/mech_bay_power_console/set_broken()
	icon_state = initial(icon_state)+"_broken"
	stat |= BROKEN
	if(recharge_port)
		recharge_port.stop_charge()

/obj/machinery/computer/mech_bay_power_console/attack_hand(mob/user as mob)
	if(..())
		return
	if(!stat && Adjacent(user) || istype(user, /mob/living/silicon))
		return interact(user)

/obj/machinery/computer/mech_bay_power_console/interact(mob/user as mob)
	user.set_machine(src)
	var/output = "<html><head><title>[src.name]</title></head><body>"
	if(!recharge_floor)
		output += "<span class='rose'>Mech Bay Recharge Station not initialized.</span><br>"
	else
		output += {"<b>Mech Bay Recharge Station Data:</b><div style='margin-left: 15px;'>
						<b>Mecha: </b>[recharge_floor.recharging_mecha||"None"]<br>"}
		if(recharge_floor.recharging_mecha)
			var/obj/item/weapon/cell/C = recharge_floor.recharging_mecha.get_cell()
			output += "<b>Cell charge: </b>[isnull(C)?"No powercell found":"[C.charge]/[C.maxcharge]"]<br>"
		output += "</div>"
	if(!recharge_port)
		output += "<span class='rose'>Mech Bay Power Port not initialized.</span><br>"
	else
		output += "<b>Mech Bay Power Port Status: </b>[recharge_port.active()?"Now charging":"On hold"]<br>"

	output += "</ body></html>"
	user << browse(output, "window=mech_bay_console")
	onclose(user, "mech_bay_console")

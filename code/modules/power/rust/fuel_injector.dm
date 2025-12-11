
/obj/machinery/power/rust_fuel_injector
	name = "\improper R-UST fuel injector"
	desc = "A bulky machine featuring a slot for the insertion of a fuel rod coupled with a small screen on the back and a huge cannon-shaped structure on the front."
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "injector0"

	density = 1
	anchored = 0
	var/locked = FALSE
	req_access = list(access_engine_major)

	var/obj/item/weapon/fuel_assembly/cur_assembly
	var/fuel_usage = 0.0001			//percentage of available fuel to use per cycle

	var/injecting = FALSE
	var/attempt_activate = FALSE

	use_power = MACHINE_POWER_USE_NONE
	power_priority = POWER_PRIORITY_POWER_EQUIPMENT
	idle_power_usage = 10
	active_power_usage = 500
	verb_rotates = TRUE
	alt_click_rotates = TRUE
	var/remote_access_enabled = TRUE
	var/emergency_insert_ready = FALSE
	var/last_power_request = 0

	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK | EJECTNOTDEL | WELD_FIXED

/obj/machinery/power/rust_fuel_injector/initialize()
	if(!id_tag)
		assign_uid()
		id_tag = uid

	. = ..()

/obj/machinery/power/rust_fuel_injector/New()
	. = ..()

	component_parts = newlist(
		/obj/item/weapon/circuitboard/rust_injector,
		/obj/item/weapon/stock_parts/manipulator/nano/pico,
		/obj/item/weapon/stock_parts/manipulator/nano/pico,
		/obj/item/weapon/stock_parts/scanning_module/adv/phasic,
		/obj/item/weapon/stock_parts/matter_bin/adv/super,
		/obj/item/weapon/stock_parts/console_screen,
	)

	if(ticker)
		initialize()

/obj/machinery/power/rust_fuel_injector/examine(var/mob/user)
	..()
	var/out = list()
	out += "Its interface "
	if(emagged)
		out += "has been shorted.<br>"
	else
		out += "is [locked ? "locked" : "unlocked"].<br>"
	if(stat & (FORCEDISABLE|NOPOWER) || state != 2)
		out += "It seems to be powered down.<br>"
	else if(injecting)
		out += "It's actively injecting fuel.<br>"
	if(cur_assembly)
		out += "A fuel rod assembly is inserted into it."
	else if(emergency_insert_ready)
		out += "The fuel rod slot cover is open."
	to_chat(user, jointext(out, ""))

/obj/machinery/power/rust_fuel_injector/process()

	if(stat & (BROKEN|NOPOWER|FORCEDISABLE) || state != 2 || (!powernet && active_power_usage))
		deactivate()
		return
	var/cur_satisfaction = get_satisfaction()
	add_load((attempt_activate || injecting) ? active_power_usage : idle_power_usage)
	var/power_received = cur_satisfaction * last_power_request
	if(attempt_activate)
		if(!injecting && power_received >= active_power_usage)
			begin_injecting()
	if(injecting)
		if(power_received < active_power_usage)
			deactivate()
		else
			inject()

	last_power_request = (injecting || attempt_activate) ? active_power_usage : idle_power_usage

/obj/machinery/power/rust_fuel_injector/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(injecting)
		to_chat(user, "Turn off \the [src] first.")
		return FALSE
	. =  ..()

/obj/machinery/power/rust_fuel_injector/weldToFloor(var/obj/item/tool/weldingtool/WT, var/mob/user)
	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1

/obj/machinery/power/rust_fuel_injector/emag_act(var/mob/user)
	if(!emagged)
		locked = FALSE
		emagged = TRUE
		if(user)
			user.visible_message("\The [user] shorts out the lock on the interface on \the [src].","<span class='warning'>You short out the lock.</span>")

/obj/machinery/power/rust_fuel_injector/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(istype(AM,/obj/item/weapon/fuel_assembly) && !cur_assembly)
		if(emergency_insert_ready)
			cur_assembly = AM
			AM.forceMove(src)
			emergency_insert_ready = FALSE
			nanomanager.update_uis(src)
			return TRUE
		return FALSE
	return FALSE

/obj/machinery/power/rust_fuel_injector/attackby(var/obj/item/W, var/mob/user)
	if(..())
		return 1

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock seems to be broken.</span>")
			return
		if(allowed(user))
			locked = !locked
			to_chat(user, "The controls are now [locked ? "locked." : "unlocked."]")
			nanomanager.update_uis(src)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	if(istype(W, /obj/item/weapon/fuel_assembly) && !cur_assembly)
		if(emergency_insert_ready)
			if(user.drop_item(W, src))
				cur_assembly = W
				emergency_insert_ready = FALSE
				nanomanager.update_uis(src)

/obj/machinery/power/rust_fuel_injector/attack_hand(var/mob/user)
	. = ..()
	if(.)
		return
	if(stat & (FORCEDISABLE|NOPOWER) || state != 2)
		to_chat(user, "<span class='warning'>It's completely unresponsive.</span>")
		return
	ui_interact(user)

/obj/machinery/power/rust_fuel_injector/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	data["locked"] = locked && !issilicon(user) && !isAdminGhost(user)
	data["id_tag"] = id_tag
	data["injecting"] = (attempt_activate || injecting)
	data["fuel_usage"] = fuel_usage * 100 // Rounded client-side
	data["has_assembly"] = !!cur_assembly
	data["emergency_insert_ready"] = emergency_insert_ready
	data["power_status_class"] = "good"
	if(round(last_power_request * get_satisfaction()) < (attempt_activate ? active_power_usage : idle_power_usage))
		data["power_status_class"] = "bad"
	data["active_power_usage"] = attempt_activate ? active_power_usage : idle_power_usage
	data["power_received"] = round(last_power_request * get_satisfaction())
	data["remote_access_enabled"] = remote_access_enabled

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "r-ust_fuel_injector.tmpl", name, 500, 360)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/power/rust_fuel_injector/Topic(href, href_list)
	if(..())
		return 1

	if (stat & (FORCEDISABLE|NOPOWER) || locked || state != 2)
		return 1

	if(href_list["modify_tag"])
		var/new_id = reject_bad_text(input("Enter new ID tag:", name) as text|null, MAX_NAME_LEN)
		if(!new_id)
			return
		id_tag = new_id
		return 1

	if(href_list["fuel_assembly"])
		attempt_fuel_swap()
		return 1

	if(href_list["emergency_fuel_assembly"])
		if(cur_assembly)
			cur_assembly.forceMove(src.loc)
			cur_assembly = null
		else
			emergency_insert_ready = !emergency_insert_ready
		return 1

	if(href_list["toggle_injecting"])
		if(attempt_activate)
			deactivate()
		else
			activate()
		return 1

	if(href_list["toggle_remote"])
		remote_access_enabled = !remote_access_enabled
		return 1

	if(href_list["fuel_usage"])
		var/new_usage = text2num(input("Enter new fuel usage (0.01% - 100%):", name, fuel_usage * 100))
		if(!new_usage)
			to_chat(usr, "<span class='warning'>That's not a valid number.</span>")
			return
		new_usage = max(new_usage, 0.01)
		new_usage = min(new_usage, 100)
		fuel_usage = new_usage / 100
		active_power_usage = 500 + 1000 * fuel_usage
		return 1

	if(href_list["update_extern"])
		var/obj/machinery/computer/rust_fuel_control/C = locate(href_list["update_extern"])
		if(C)
			C.updateDialog()
		return 1

	if(href_list["close"])
		usr.unset_machine()

/obj/machinery/power/rust_fuel_injector/update_icon()
	icon_state = injecting ? "injector1" : "injector0"

/obj/machinery/power/rust_fuel_injector/proc/activate()
	attempt_activate = TRUE

/obj/machinery/power/rust_fuel_injector/proc/deactivate()
	attempt_activate = FALSE
	stop_injecting()


/obj/machinery/power/rust_fuel_injector/proc/begin_injecting()
	if(!injecting && cur_assembly)
		injecting = TRUE
		update_icon()

/obj/machinery/power/rust_fuel_injector/proc/stop_injecting()
	if(injecting)
		injecting = FALSE
		update_icon()

/obj/machinery/power/rust_fuel_injector/proc/inject()
	if(!injecting)
		return
	if(cur_assembly)
		var/amount_left = 0
		var/max_amount = 0
		for(var/reagent in cur_assembly.rod_current_quantities)
//			to_chat(world, "checking [reagent]")
			max_amount += cur_assembly.rod_starting_quantities[reagent]
			if(cur_assembly.rod_current_quantities[reagent] > 0)
//					to_chat(world, "	rods left: [cur_assembly.rod_quantities[reagent]]")
				var/amount = cur_assembly.rod_starting_quantities[reagent] * fuel_usage
				amount = min(amount, cur_assembly.rod_current_quantities[reagent])
				var/numparticles = round(amount * 1000)
				if(numparticles < 1)
					numparticles = 1
//					to_chat(world, "	amount: [amount]")
//					to_chat(world, "	numparticles: [numparticles]")
				//

				var/obj/effect/accelerated_particle/A = new/obj/effect/accelerated_particle(get_turf(src), dir)
				A.particle_type = reagent
				A.additional_particles = numparticles - 1
				//A.target = target_field
				A.startMove(1)

				cur_assembly.rod_current_quantities[reagent] -= amount
				amount_left += cur_assembly.rod_current_quantities[reagent]
		cur_assembly.percent_depleted = (max_amount - amount_left) / 300
		if(cur_assembly.percent_depleted == 1)
			qdel(cur_assembly)
			cur_assembly = null
	else
		deactivate()

/obj/machinery/power/rust_fuel_injector/proc/attempt_fuel_swap()

	var/success = 0
	var/adjacent_dir = dir
	outerloop: // a bit complicated so let's go step by step
		for(var/i = 0, i < 3, i++)
			adjacent_dir = counterclockwise_perpendicular_dirs[adjacent_dir] //for each adjacent turf to the injector (except in front of it)
			var/turf/adjacent_wall = get_step(get_turf(src), adjacent_dir) //find the wall
			if(!istype(adjacent_wall, /turf/simulated/wall)) // check if it's a wall, if not, it can't have anything attached to it, duh
				continue // if it's not a wall, check the next adjacent turf
			var/dir_of_check = opposite_dirs[adjacent_dir]
			for(var/j = 0, j < 3, j++) //now since the fuel port is like an APC, it is actually on the floor and only looks like it's in a wall, so you need to check all adjacent turfs of the wall if they have a port
				dir_of_check = counterclockwise_perpendicular_dirs[dir_of_check]
				var/turf_to_check = get_step(adjacent_wall, dir_of_check)
				for(var/obj/machinery/rust_fuel_assembly_port/check_port in turf_to_check)
					if(check_port.dir != opposite_dirs[dir_of_check]) // the fuel port actually needs to face the wall to be attached to it, if it isn't, it's on another wall
						continue
					if(cur_assembly)
						if(!check_port.cur_assembly)
							check_port.cur_assembly = cur_assembly
							cur_assembly.forceMove(check_port)
							cur_assembly = null
							check_port.icon_state = "port1"
							success = 1
							break outerloop //we break on the first valid find for simplicity
					else
						if(check_port.cur_assembly)
							cur_assembly = check_port.cur_assembly
							cur_assembly.forceMove(src)
							check_port.cur_assembly = null
							check_port.icon_state = "port0"
							success = 1
							break outerloop
	if(success)
		visible_message("<span class='notice'>[bicon(src)] A green light flashes on \the [src].</span>")
		updateDialog()
	else
		visible_message("<span class='warning'>[bicon(src)] A red light flashes on \the [src].</span>")

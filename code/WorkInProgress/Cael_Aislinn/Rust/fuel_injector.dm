
/obj/machinery/power/rust_fuel_injector
	name = "\improper R-UST fuel injector"
	desc = "A bulky machine featuring a slot for the insertion of a fuel rod coupled with a small screen on the back and a huge cannon-shaped structure on the front."
	icon = 'code/WorkInProgress/Cael_Aislinn/Rust/rust.dmi'
	icon_state = "injector0"

	density = 1
	anchored = 0
	var/locked = FALSE
	req_access = list(access_engine)

	var/obj/item/weapon/fuel_assembly/cur_assembly
	var/fuel_usage = 0.0001			//percentage of available fuel to use per cycle
	var/id_tag
	var/injecting = FALSE

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 500
	var/remote_access_enabled = TRUE
	var/cached_power_avail = 0
	var/emergency_insert_ready = FALSE

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
	if(stat & NOPOWER || state != 2)
		out += "It seems to be powered down.<br>"
	else if(injecting)
		out += "It's actively injecting fuel.<br>"
	if(cur_assembly)
		out += "A fuel rod assembly is inserted into it."
	else if(emergency_insert_ready)
		out += "The fuel rod slot cover is open."
	to_chat(user, jointext(out, ""))

/obj/machinery/power/rust_fuel_injector/process()
	if(injecting)
		if(stat & (BROKEN|NOPOWER))
			stop_injecting()
		else
			inject()

	cached_power_avail = avail()

/obj/machinery/power/rust_fuel_injector/wrenchAnchor(var/mob/user)
	if(injecting)
		to_chat(user, "Turn off \the [src] first.")
		return FALSE
	. =  ..()

/obj/machinery/power/rust_fuel_injector/weldToFloor(var/obj/item/weapon/weldingtool/WT, var/mob/user)
	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1

/obj/machinery/power/rust_fuel_injector/emag(var/mob/user)
	if(!emagged)
		locked = FALSE
		emagged = TRUE
		if(user)
			user.visible_message("\The [user] shorts out the lock on the interface on \the [src].","<span class='warning'>You short out the lock.</span>")

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
	if(stat & NOPOWER || state != 2)
		to_chat(user, "<span class='warning'>It's completely unresponsive.</span>")
		return
	ui_interact(user)

/obj/machinery/power/rust_fuel_injector/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open=NANOUI_FOCUS)
	var/data[0]
	data["locked"] = locked && !issilicon(user) && !isAdminGhost(user)
	data["id_tag"] = id_tag
	data["injecting"] = injecting
	data["fuel_usage"] = fuel_usage * 100 // Rounded client-side
	data["has_assembly"] = !!cur_assembly
	data["emergency_insert_ready"] = emergency_insert_ready
	data["power_status_class"] = "good"
	if(cached_power_avail < active_power_usage)
		data["power_status_class"] = "bad"
	else if(cached_power_avail < active_power_usage * 2)
		data["power_status_class"] = "average"
	data["active_power_usage"] = round(active_power_usage)
	data["cached_power_avail"] = round(cached_power_avail)
	data["remote_access_enabled"] = remote_access_enabled

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "r-ust_fuel_injector.tmpl", name, 500, 360)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/power/rust_fuel_injector/Topic(href, href_list)
	if(..())
		return 1

	if (stat & NOPOWER || locked || state != 2)
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
		if(injecting)
			stop_injecting()
		else
			begin_injecting()
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

/obj/machinery/power/rust_fuel_injector/proc/begin_injecting()
	if(!injecting && cur_assembly)
		injecting = TRUE
		use_power = 1
		update_icon()

/obj/machinery/power/rust_fuel_injector/proc/stop_injecting()
	if(injecting)
		injecting = FALSE
		icon_state = "injector0"
		use_power = 0
		update_icon()

/obj/machinery/power/rust_fuel_injector/proc/inject()
	if(!injecting)
		return
	if(cur_assembly)
		var/amount_left = 0
		for(var/reagent in cur_assembly.rod_quantities)
//			to_chat(world, "checking [reagent]")
			if(cur_assembly.rod_quantities[reagent] > 0)
//					to_chat(world, "	rods left: [cur_assembly.rod_quantities[reagent]]")
				var/amount = cur_assembly.rod_quantities[reagent] * fuel_usage
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

				cur_assembly.rod_quantities[reagent] -= amount
				amount_left += cur_assembly.rod_quantities[reagent]
		cur_assembly.percent_depleted = amount_left / 300
		flick("injector-emitting",src)
	else
		stop_injecting()

/obj/machinery/power/rust_fuel_injector/proc/attempt_fuel_swap()
	var/rev_dir = reverse_direction(dir)
	var/turf/mid = get_step(src, rev_dir)
	var/success = 0
	for(var/obj/machinery/rust_fuel_assembly_port/check_port in get_step(mid, rev_dir))
		if(cur_assembly)
			if(!check_port.cur_assembly)
				check_port.cur_assembly = cur_assembly
				cur_assembly.forceMove(check_port)
				cur_assembly = null
				check_port.icon_state = "port1"
				success = 1
		else
			if(check_port.cur_assembly)
				cur_assembly = check_port.cur_assembly
				cur_assembly.forceMove(src)
				check_port.cur_assembly = null
				check_port.icon_state = "port0"
				success = 1

		break
	if(success)
		visible_message("<span class='notice'>[bicon(src)] A green light flashes on \the [src].</span>")
		updateDialog()
	else
		visible_message("<span class='warning'>[bicon(src)] A red light flashes on \the [src].</span>")

/obj/machinery/power/rust_fuel_injector/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate injector (Clockwise)"
	set src in view(1)

	if (anchored || usr.incapacitated())
		return

	src.dir = turn(src.dir, -90)

/obj/machinery/power/rust_fuel_injector/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate injector (Counter-clockwise)"
	set src in view(1)

	if (anchored || usr.incapacitated())
		return

	src.dir = turn(src.dir, 90)

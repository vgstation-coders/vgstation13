

/obj/machinery/rust_fuel_assembly_port
	name = "Fuel Assembly Port"
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "port2"
	density = FALSE
	var/obj/item/weapon/fuel_assembly/cur_assembly
	var/busy = 0
	anchored = 1
	ghost_read = 0

	var/opened = 1 //0=closed, 1=opened
	var/has_electronics = 0 // 0 - none, bit 1 - circuitboard, bit 2 - wires

/obj/machinery/rust_fuel_assembly_port/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(istype(AM,/obj/item/weapon/fuel_assembly) && !opened)
		if(cur_assembly)
			return FALSE
		else
			var/obj/item/weapon/fuel_assembly/FA = AM
			cur_assembly = FA
			FA.forceMove(src)
			icon_state = "port1"
			return TRUE
	return FALSE

/obj/machinery/rust_fuel_assembly_port/attackby(var/obj/item/I, var/mob/user)
	if(istype(I,/obj/item/weapon/fuel_assembly) && !opened)
		if(cur_assembly)
			to_chat(user, "<span class='warning'>There is already a fuel rod assembly in there!</span>")
		else
			if(user.drop_item(I, src))
				cur_assembly = I
				icon_state = "port1"
				to_chat(user, "<span class='notice'>You insert [I] into [src]. Touch the panel again to insert [I] into the injector.</span>")

/obj/machinery/rust_fuel_assembly_port/attack_hand(mob/user)
	if(..())
		return
	if(opened)
		return

	if(cur_assembly)
		if(try_insert_assembly())
			to_chat(user, "<span class='notice'>[bicon(src)] [src] inserts it's fuel rod assembly into an injector.</span>")
		else
			if(eject_assembly())
				to_chat(user, "<span class='warning'>[bicon(src)] [src] ejects it's fuel assembly. Check the fuel injector status.</span>")
			else if(try_draw_assembly())
				to_chat(user, "<span class='notice'>[bicon(src)] [src] draws a fuel rod assembly from an injector.</span>")
	else if(try_draw_assembly())
		to_chat(user, "<span class='notice'>[bicon(src)] [src] draws a fuel rod assembly from an injector.</span>")
	else
		to_chat(user, "<span class='warning'>[bicon(src)] [src] was unable to draw a fuel rod assembly from an injector.</span>")

/obj/machinery/rust_fuel_assembly_port/proc/try_insert_assembly()
	var/success = 0
	if(cur_assembly)
		var/turf/check_turf = get_step(get_turf(src), src.dir)
		check_turf = get_step(check_turf, src.dir)
		for(var/obj/machinery/power/rust_fuel_injector/I in check_turf)
			if(I.stat & (BROKEN|NOPOWER|FORCEDISABLE))
				break
			if(I.cur_assembly)
				break
			if(I.state != 2)
				break

			I.cur_assembly = cur_assembly
			cur_assembly.forceMove(I)
			cur_assembly = null
			icon_state = "port0"
			success = 1

	return success

/obj/machinery/rust_fuel_assembly_port/proc/eject_assembly()
	if(cur_assembly)
		cur_assembly.forceMove(src.loc)//get_step(get_turf(src), src.dir)
		cur_assembly = null
		icon_state = "port0"
		return 1

/obj/machinery/rust_fuel_assembly_port/proc/try_draw_assembly()
	var/success = 0
	if(!cur_assembly)
		var/turf/check_turf = get_step(get_turf(src), src.dir)
		check_turf = get_step(check_turf, src.dir)
		for(var/obj/machinery/power/rust_fuel_injector/I in check_turf)
			if(I.stat & (BROKEN|NOPOWER|FORCEDISABLE))
				break
			if(!I.cur_assembly)
				break
			if(I.injecting)
				break
			if(I.state != 2)
				break

			cur_assembly = I.cur_assembly
			cur_assembly.forceMove(src)
			I.cur_assembly = null
			icon_state = "port1"
			success = 1
			break

	return success

/obj/machinery/rust_fuel_assembly_port/verb/eject_assembly_verb()
	set name = "Eject assembly from port"
	set category = "Object"
	set src in oview(1)
	if(!usr.incapacitated())
		eject_assembly()

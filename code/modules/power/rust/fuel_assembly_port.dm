

/obj/machinery/rust_fuel_assembly_port
	name = "Fuel Assembly Port"
	icon = 'icons/obj/machines/rust.dmi'
	desc = "A machine that accepts compressed fuel assemblies and inserts them into a fuel injector."
	icon_state = "port2"
	density = FALSE
	var/obj/item/weapon/fuel_assembly/cur_assembly
	var/busy = 0
	anchored = 1
	ghost_read = 0
	var/construct_progress = 0 // 3 is fully built

/obj/machinery/rust_fuel_assembly_port/examine(mob/user)
	..()
	if(stat & BROKEN)
		to_chat(user, "Looks broken.")
		return
	switch(construct_progress)
		if (3)
			to_chat(user, "The cover is closed.")
		if (2)
			to_chat(user, "The cover is open and the wiring is exposed.")
		if (1)
			to_chat(user, "The cover is open and you can see unwired electronics inside.")
		else
			to_chat(user, "The cover is open and shows an empty slot for a circuit board.")

/obj/machinery/rust_fuel_assembly_port/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	if(istype(AM,/obj/item/weapon/fuel_assembly) && construct_progress == 3)
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
	if(istype(I,/obj/item/weapon/fuel_assembly) && construct_progress == 3)
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
	if(construct_progress < 3)
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
	if(cur_assembly)
		var/turf/turf_were_on = get_step(get_turf(src), src.dir)
		var/dir_of_check = opposite_dirs[src.dir]
		for(var/i = 0, i < 3, i++)
			dir_of_check = counterclockwise_perpendicular_dirs[dir_of_check]
			var/turf_to_check = get_step(turf_were_on, dir_of_check)
			for(var/obj/machinery/power/rust_fuel_injector/I in turf_to_check)
				if(I.stat & (BROKEN|NOPOWER|FORCEDISABLE))
					continue
				if(I.cur_assembly)
					continue
				if(I.state != 2)
					continue

				I.cur_assembly = cur_assembly
				cur_assembly.forceMove(I)
				cur_assembly = null
				icon_state = "port0"
				return 1
	return 0

/obj/machinery/rust_fuel_assembly_port/proc/eject_assembly()
	if(cur_assembly)
		cur_assembly.forceMove(src.loc)//get_step(get_turf(src), src.dir)
		cur_assembly = null
		icon_state = "port0"
		return 1

/obj/machinery/rust_fuel_assembly_port/proc/try_draw_assembly()
	if(!cur_assembly)
		var/turf/turf_were_on = get_step(get_turf(src), src.dir)
		var/dir_of_check = opposite_dirs[src.dir]
		for(var/i = 0, i < 3, i++)
			dir_of_check = counterclockwise_perpendicular_dirs[dir_of_check]
			var/turf_to_check = get_step(turf_were_on, dir_of_check)
			for(var/obj/machinery/power/rust_fuel_injector/I in turf_to_check)
				if(I.stat & (BROKEN|NOPOWER|FORCEDISABLE))
					continue
				if(!I.cur_assembly)
					continue
				if(I.state != 2)
					continue

				cur_assembly = I.cur_assembly
				cur_assembly.forceMove(src)
				I.cur_assembly = null
				icon_state = "port1"
				return 1
	return 0

/obj/machinery/rust_fuel_assembly_port/verb/eject_assembly_verb()
	set name = "Eject assembly from port"
	set category = "Object"
	set src in oview(1)
	if(!usr.incapacitated())
		eject_assembly()

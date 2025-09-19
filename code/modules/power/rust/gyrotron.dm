/obj/machinery/power/gyrotron
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "emitter-off"
	name = "gyrotron"
	anchored = 0
	state = 0
	density = 1
	plane = ABOVE_HUMAN_PLANE
	machine_flags = MULTITOOL_MENU | WRENCHMOVE | WELD_FIXED | FIXED2WORK

	var/frequency = MIN_GYRO_FREQ
	var/emitting = FALSE
	var/mega_energy = MIN_MEGA_ENERGY
	var/targeted_mega_energy = MIN_MEGA_ENERGY
	var/attempt_activate = FALSE
	var/last_power_request = 0
	var/last_mega_energy = MIN_MEGA_ENERGY
	var/powered = 0
	var/last_power_received

	req_access = list(access_engine_major)

	use_power = MACHINE_POWER_USE_NONE
	power_priority = POWER_PRIORITY_POWER_EQUIPMENT
	idle_power_usage = 10
	active_power_usage = GYRO_MEGA_COST * MIN_MEGA_ENERGY
	verb_rotates = TRUE
	alt_click_rotates = TRUE

/obj/machinery/power/gyrotron/initialize()
	if(!id_tag)
		assign_uid()
		id_tag = uid

	. = ..()

/obj/machinery/power/gyrotron/New()
	. = ..()

	if(ticker)
		initialize()

/obj/machinery/power/gyrotron/proc/stop_emitting()
	if(!emitting)
		return
	emitting = 0
	update_icon()

/obj/machinery/power/gyrotron/proc/start_emitting()
	if(stat & (FORCEDISABLE | NOPOWER | BROKEN) || (emitting && state == 2)) //Sanity.
		return
	emitting = 1
	update_icon()

/obj/machinery/power/gyrotron/proc/activate()
	attempt_activate = TRUE

/obj/machinery/power/gyrotron/proc/deactivate()
	attempt_activate = FALSE
	stop_emitting()

/obj/machinery/power/gyrotron/process()
	if(stat & BROKEN || state != 2 || (!powernet && active_power_usage))
		powered = 0
		stop_emitting()
		return
	var/cur_satisfaction = get_satisfaction()
	var/power_received = cur_satisfaction * last_power_request
	add_load((emitting || attempt_activate) ? active_power_usage : idle_power_usage)
	powered = power_received >= idle_power_usage
	if(!powered)
		stop_emitting()
	if(emitting)
		if(power_received < MIN_MEGA_ENERGY * GYRO_MEGA_COST || !attempt_activate)
			stop_emitting()
		else
			mega_energy = cur_satisfaction * last_mega_energy
			spawn(rand(0,3))
				emit()
	else if(attempt_activate)
		if(power_received >= GYRO_MEGA_COST * MIN_MEGA_ENERGY)
			start_emitting()

	last_power_request = (emitting || attempt_activate) ? active_power_usage : idle_power_usage
	last_power_received = power_received
	last_mega_energy = targeted_mega_energy


/obj/machinery/power/gyrotron/proc/emit()

	var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter(loc)
	A.frequency = frequency
	A.damage = mega_energy * 1500

	playsound(src, 'sound/weapons/emitter.ogg', 25, 1)

	A.dir = dir
	A.dumbfire()

	flick("emitter-active", src)

/obj/machinery/power/gyrotron/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	return {"
		<ul>
			<li>[format_tag("ID Tag","id_tag")]</li>
		</ul>
	"}

/obj/machinery/power/gyrotron/canLink(var/obj/machinery/computer/rust_gyrotron_controller/object, var/list/context)
	return istype(object) && get_dist(src, object) < RUST_GYROTRON_RANGE

/obj/machinery/power/gyrotron/isLinkedWith(var/obj/machinery/computer/rust_gyrotron_controller/object)
	return istype(object) && (src in object.linked_gyrotrons)

/obj/machinery/power/gyrotron/linkWith(var/mob/user, var/obj/machinery/computer/rust_gyrotron_controller/buffered, var/list/context)
	buffered.linked_gyrotrons += src
	return 1

/obj/machinery/power/gyrotron/power_change()
	. =..()
	if(stat & (FORCEDISABLE | NOPOWER | BROKEN))
		stop_emitting()

	update_icon()

/obj/machinery/power/gyrotron/update_icon()
	if(!(stat & (FORCEDISABLE | NOPOWER | BROKEN)) && emitting)
		icon_state = "emitter-on"
	else
		icon_state = "emitter-off"

/obj/machinery/power/gyrotron/weldToFloor(var/obj/item/tool/weldingtool/WT, var/mob/user)
	if(emitting)
		to_chat(user, "<span class='warning'>Turn \the [src] off first!</span>")
		return -1
	if(..() == 1)
		switch(state)
			if(1)
				disconnect_from_network()
			if(2)
				connect_to_network()
		return 1
	return -1

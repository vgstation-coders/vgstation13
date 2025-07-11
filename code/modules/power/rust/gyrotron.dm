#define MIN_MEGA_ENERGY 0.001
#define MAX_MEGA_ENERGY 0.01
#define MAX_GYRO_FREQ 1000
#define MIN_GYRO_FREQ 1
#define GYRO_MEGA_COST 100000000 //Yes, original code made it that big


/obj/machinery/power/gyrotron
	icon = 'icons/obj/machines/rust.dmi'
	icon_state = "emitter-off"
	name = "gyrotron"
	anchored = 0
	state = 0
	density = 1
	plane = ABOVE_HUMAN_PLANE
	machine_flags = MULTITOOL_MENU | WRENCHMOVE | WELD_FIXED | FIXED2WORK

	var/frequency = 1
	var/emitting = 0
	var/rate = 10
	var/mega_energy = 0.001

	req_access = list(access_engine_major)

	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = GYRO_MEGA_COST * MIN_MEGA_ENERGY

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
	emitting = 0
	use_power = MACHINE_POWER_USE_IDLE
	update_icon()

/obj/machinery/power/gyrotron/proc/start_emitting()
	if(stat & (FORCEDISABLE | NOPOWER | BROKEN) || emitting && state == 2) //Sanity.
		return

	emitting = 1
	use_power = MACHINE_POWER_USE_ACTIVE

	update_icon()

	spawn()
		while(emitting)
			emit()
			sleep(rate)

/obj/machinery/rust/gyrotron/proc/emit()
	var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter(loc)
	A.frequency = frequency
	A.damage = mega_energy * 1500

	playsound(src, 'sound/weapons/emitter.ogg', 25, 1)
	use_power(100 * mega_energy + 500)

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
	. = ..()

/obj/machinery/power/gyrotron/verb/rotate_cw()
	set name = "Rotate (Clockwise)"
	set src in oview(1)
	set category = "Object"

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(anchored)
		to_chat(usr, "<span class='notify'>\The [src] is anchored to the floor!</span>")
		return

	dir = turn(dir, -90)

/obj/machinery/power/gyrotron/verb/rotate_ccw()
	set name = "Rotate (Counter-Clockwise)"
	set src in oview(1)
	set category = "Object"

	if(usr.incapacitated() || !Adjacent(usr))
		return

	if(anchored)
		to_chat(usr, "<span class='notify'>\The [src] is anchored to the floor!</span>")
		return

	dir = turn(dir, 90)

/obj/machinery/power/gyrotron/AltClick(mob/user)
	if(user.incapacitated() || !Adjacent(user))
		return
	rotate_cw()

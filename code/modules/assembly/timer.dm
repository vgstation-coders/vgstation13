#define VALUE_REMAINING_TIME "Remaining time"
#define VALUE_DEFAULT_TIME "Default time"
#define VALUE_TIMING "Timing"

/obj/item/device/assembly/timer
	name = "timer"
	desc = "Used to time things. Works well with contraptions which have to count down. Tick tock."
	icon_state = "timer"
	starting_materials = list(MAT_IRON = 500, MAT_GLASS = 50)
	w_type = RECYK_ELECTRONIC
	origin_tech = Tc_MAGNETS + "=1"

	wires = WIRE_PULSE | WIRE_RECEIVE

	secured = 0

	var/timing = 0
	var/time = 10

	var/default_time = 10

	accessible_values = list(\
		VALUE_REMAINING_TIME = "time;"+VT_NUMBER,\
		VALUE_DEFAULT_TIME = "default_time;"+VT_NUMBER,\
		VALUE_TIMING = "timing;"+VT_NUMBER)

/obj/item/device/assembly/timer/activate()
	if(!..())
		return 0//Cooldown check

	timing = !timing

	update_icon()
	return 0

/obj/item/device/assembly/timer/toggle_secure()
	secured = !secured
	if(secured)
		processing_objects.Add(src)
	else
		timing = 0
		processing_objects.Remove(src)
	update_icon()
	return secured

/obj/item/device/assembly/timer/proc/timer_end()
	if(!secured)
		return 0
	pulse(0)
	if(!holder)
		visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	cooldown = 2
	spawn(10)
		process_cooldown()
	return

/obj/item/device/assembly/timer/process()
	if(timing && (time > 0))
		time--
	if(timing && time <= 0)
		timing = 0
		timer_end()
		time = default_time
	return


/obj/item/device/assembly/timer/update_icon()
	overlays.len = 0
	attached_overlays = list()
	if(timing)
		attached_overlays += "timer_timing"
		overlays += image(icon = icon, icon_state = "timer_timing")
	if(holder)
		holder.update_icon()
	return


/obj/item/device/assembly/timer/interact(mob/user as mob)//TODO: Have this use the wires
	if(!secured)
		user.show_message("<span class='warning'>The [name] is unsecured!</span>")
		return 0
	var/second = time % 60
	var/minute = (time - second) / 60
	var/dat = text("<TT><B>Timing Unit</B>\n[] []:[]\n<A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT>", (timing ? text("<A href='?src=\ref[];time=0'>Timing</A>", src) : text("<A href='?src=\ref[];time=1'>Not Timing</A>", src)), minute, second, src, src, src, src)

	dat += "<BR><BR><A href='?src=\ref[src];set_default_time=1'>After countdown, reset time to [(default_time - default_time%60)/60]:[(default_time % 60)]</A>"
	dat += {"<BR><BR><A href='?src=\ref[src];refresh=1'>Refresh</A>
		<BR><BR><A href='?src=\ref[src];close=1'>Close</A>"}
	user << browse(dat, "window=timer")
	onclose(user, "timer")
	return


/obj/item/device/assembly/timer/Topic(href, href_list)
	..()
	if(usr.stat || usr.restrained() || !in_range(loc, usr) || (!usr.canmove && !usr.locked_to))
		//If the user is handcuffed or out of range, or if they're unable to move,
		//but NOT if they're unable to move as a result of being buckled into something, they're unable to use the device.
		usr << browse(null, "window=timer")
		onclose(usr, "timer")
		return

	if(href_list["time"])
		timing = text2num(href_list["time"])
		message_admins("[key_name_admin(usr)] [timing ? "started" : "stopped"] a timer at [formatJumpTo(src)]")
		update_icon()

	if(href_list["tp"])
		var/tp = text2num(href_list["tp"])
		time += tp
		time = min(max(round(time), 0), 600)

	if(href_list["close"])
		usr << browse(null, "window=timer")
		return

	if(href_list["set_default_time"])
		default_time = time

	if(usr)
		attack_self(usr)

	return

/obj/item/device/assembly/timer/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"timing",
		"time")

	reset_vars_after_duration(resettable_vars, duration)

#undef VALUE_REMAINING_TIME
#undef VALUE_DEFAULT_TIME
#undef VALUE_TIMING

/obj/machinery/computer/rust_gyrotron_controller
	name = "Gyrotron Remote Controller"
	icon_state = "engine"
	circuit = /obj/item/weapon/circuitboard/rust_gyrotron_control
	light_color = LIGHT_COLOR_BLUE
	var/list/linked_gyrotrons[0] //List of linked gyrotrons.

/obj/machinery/computer/rust_gyrotron_controller/initialize()
	if(!id_tag)
		assign_uid()
		id_tag = uid

	. = ..()

/obj/machinery/computer/rust_gyrotron_controller/New()
	. = ..()

	if(ticker)
		initialize()


/obj/machinery/computer/rust_gyrotron_controller/attack_hand(mob/user)
	. = ..()
	if(.)
		if(user.machine == src)
			user.unset_machine(src)
		return

	interact(user)

/obj/machinery/computer/rust_gyrotron_controller/wrenchAnchor(var/mob/user, var/obj/item/I)
	. = ..()
	if(!.)
		return
	if(state) //We're set to anchored again.
		for(var/obj/machinery/power/gyrotron/gyro in linked_gyrotrons)
			if(get_dist(src, gyro) > RUST_GYROTRON_RANGE) //We've been moved so far we're out of range.
				linked_gyrotrons -= gyro

/obj/machinery/computer/rust_gyrotron_controller/interact(mob/user)
	var/dat = {"
		Linked gyrotrons:
		<hr>
		<table>
			<tr>
				<th>ID tag</th>
				<th>Status</th>
				<th>Mode</th>
				<th>Beam Output (TJ)</th>
				<th>Frequency (GHz)</th>
			</tr>
	"}
	for(var/obj/machinery/power/gyrotron/gyro in linked_gyrotrons)
		//These vars are here because muh readable HTML code.
		var/gyro_id = linked_gyrotrons.Find(gyro)
		var/status
		if(gyro.state != 2 || gyro.stat & (FORCEDISABLE | NOPOWER | BROKEN))
			status = "<span style='color: red'>Unresponsive</span>"
		else if(gyro.targeted_mega_energy > gyro.last_mega_energy || gyro.last_power_request > gyro.last_power_received)
			status = "<span style='color: orange'>Underpowered</span>"
		else if(gyro.attempt_activate && !gyro.emitting)
			status = "<span style ='color: green'>Booting up</span>"
		else if(gyro.emitting)
			status = "<span style='color: green'>Emitting</span>"
		else
			status = "<span style='color: green'>Operational</span>"
		dat += {"
			</tr>
				<td>[gyro.id_tag]</td>
				<td>[status]</td>
		"}
		if(gyro.state != 2 || gyro.stat & (FORCEDISABLE | NOPOWER | BROKEN)) //Error data not found.
			dat += {"
				<td><span style='color: red'>ERROR</span></td>
				<td><span style='color: red'>ERROR</span></td>
				<td><span style='color: red'>ERROR</span></td>
			"}
		else
			var/mode = (gyro.attempt_activate ? "<a href='?src=\ref[src];deactivate=1;gyro=[gyro_id]'>Enabled</a>" : "<a href='?src=\ref[src];activate=1;gyro=[gyro_id]'>Stand-By</a>")//See how long this is?
			dat += {"
				<td>[mode]</td>
				<td><a href='?src=\ref[src];modifypower=1;gyro=[gyro_id]'>[gyro.targeted_mega_energy]</a></td>
				<td><a href='?src=\ref[src];modifyfreq=1;gyro=[gyro_id]'>[gyro.frequency]</a></td>
			"}
		dat += "</tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "gyrotron_controller", "Gyrotron Remote Control Console", 500, 400, src)
	popup.set_content(dat)
	popup.open()
	user.set_machine(src)

/obj/machinery/computer/rust_gyrotron_controller/Topic(var/href, var/list/href_list)
	. = ..()
	if(.)
		return

	if(!href_list["gyro"])
		return

	var/idx = clamp(text2num(href_list["gyro"]), 1, linked_gyrotrons.len)
	var/obj/machinery/power/gyrotron/gyro = linked_gyrotrons[idx]

	if(!gyro || gyro.stat & (FORCEDISABLE | NOPOWER | BROKEN))
		return

	if(href_list["modifypower"])
		var/new_val = input("Enter new emission power level (0.001 - 0.01)", "Modifying power level (TJ)", gyro.mega_energy) as num
		if(!new_val)
			to_chat(usr, "<span class='warning'>That's not a valid number.</span>")
			return 1

		gyro.targeted_mega_energy = clamp(new_val, 0.001, 0.01)
		gyro.active_power_usage = gyro.targeted_mega_energy * GYRO_MEGA_COST

		updateUsrDialog()
		return 1
	if(href_list["modifyfreq"])
		var/new_val = input("Enter new emission frequency (1 - 50000)", "Modifying emission frequency (GHz)", gyro.frequency) as num
		if(!new_val)
			to_chat(usr, "<span class='warning'>That's not a valid number.</span>")
			return 1

		gyro.frequency = clamp(new_val, MIN_GYRO_FREQ, 50000)

		updateUsrDialog()
		return 1

	if(href_list["activate"])
		gyro.activate()

		updateUsrDialog()
		return 1

	if(href_list["deactivate"])
		gyro.deactivate()

		updateUsrDialog()
		return 1

//Multitool menu shit starts here.
//It's all . because . is faster than return, thanks BYOND.
/obj/machinery/computer/rust_gyrotron_controller/multitool_menu(var/mob/user, var/obj/item/device/multitool/P)
	. = "Linked gyrotrons:<br><lu>"

	for(var/obj/machinery/power/gyrotron/G in linked_gyrotrons)
		. += "<li><b>[G.id_tag]</b> <a href='?src=\ref[src];unlink=[linked_gyrotrons.Find(G)]'>\[X\]</a></li>"
	. += "</ul>"

/obj/machinery/computer/rust_gyrotron_controller/linkMenu(var/obj/machinery/power/gyrotron/O)
	if(istype(O))
		. = "<a href='?src=\ref[src];link=1'>\[LINK\]</a> "

/obj/machinery/computer/rust_gyrotron_controller/canLink(var/obj/machinery/power/gyrotron/O, var/list/context)
	. = (istype(O) && get_dist(src, O) < RUST_GYROTRON_RANGE)

/obj/machinery/computer/rust_gyrotron_controller/isLinkedWith(var/obj/O)
	. = (O in linked_gyrotrons)

/obj/machinery/computer/rust_gyrotron_controller/linkWith(var/mob/user, var/obj/machinery/power/gyrotron/O, var/list/context)
	linked_gyrotrons += O
	. = 1

/obj/machinery/computer/rust_gyrotron_controller/getLink(var/idx)
	if(idx <= linked_gyrotrons.len)
		. = linked_gyrotrons[idx]

/obj/machinery/computer/rust_gyrotron_controller/unlinkFrom(var/mob/user, var/obj/buffer)
	linked_gyrotrons -= buffer
	. = 1

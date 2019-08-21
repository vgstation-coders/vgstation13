/obj/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer."
	name = "Clarke"
	icon_state = "clarke"
	initial_icon = "clarke"
	step_in = 1
	step_energy_drain = 2
	max_temperature = 100000
	health = 100
	wreckage = /obj/effect/decal/mecha_wreckage/clarke
	max_equip = 4
	cargo_capacity = 20
	rad_protection = 100
	var/image/thruster_overlay
	var/overlay_applied = FALSE
	var/obj/machinery/portable_atmospherics/scrubber/mech/scrubber
	var/obj/machinery/atmospherics/unary/portables_connector/scrubber_port = null

/obj/mecha/working/clarke/New()
	..()
	thruster_overlay = image('icons/mecha/mecha.dmi', src, "[initial_icon]-thruster_overlay")
	scrubber = new(src)

/obj/mecha/working/clarke/Destroy()
	qdel(scrubber)
	scrubber = null
	..()

/obj/mecha/working/clarke/check_for_support()
	return 1

/obj/mecha/working/clarke/relaymove()
	if(scrubber_port)
		occupant_message("Unable to move while connected to the air system port.", TRUE)
		return 0
	..()

/obj/mecha/working/clarke/mechturn(direction)
	dir = direction
	playsound(src,'sound/mecha/mechmove01.ogg',40,1)
	return 1

/obj/mecha/working/clarke/mechstep(direction)
	if(istype(get_turf(src), /turf/space))
		if(!overlay_applied)
			overlays += thruster_overlay
			overlay_applied = TRUE
	else
		if(overlay_applied)
			overlays -= thruster_overlay
			overlay_applied = FALSE
	return step(src,direction)

/obj/mecha/working/clarke/mechsteprand()
	return step_rand(src)

/obj/mecha/working/clarke/Process_Spacemove(var/check_drift = 0)
	return TRUE

/obj/mecha/working/clarke/startMechWalking()
	icon_state = initial_icon + "-move"

/obj/mecha/working/clarke/connect()
	if(scrubber_port)
		return 0
	return ..()

/obj/mecha/working/clarke/proc/connect_scrubber(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || scrubber_port || !new_port || new_port.connected_device)
		return 0

	//Make sure are close enough for a valid connection
	if(new_port.loc != src.loc)
		return 0

	//Perform the connection
	scrubber_port = new_port
	scrubber.connect(new_port)

	log_message("Connected to gas port.")
	return 1

/obj/mecha/working/clarke/proc/disconnect_scrubber()
	if(!scrubber_port)
		return 0

	scrubber.disconnect()

	scrubber_port = null
	src.log_message("Disconnected from gas port.")
	return 1

/obj/mecha/working/clarke/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];scrubber_interface=1'>Scrubber interface</a>
						<br>
						<span id="scrubbing_port">[src.scrubber_port ? "<a href='?src=\ref[src];scrubber_disconnect=1'>Disconnect Scrubber to Port</a>" : "<a href='?src=\ref[src];scrubber_connect=1'>Connect Scrubber to Port</a>"]</span>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/working/clarke/Topic(href, href_list)
	. = ..()
	if (href_list["scrubber_interface"])
		if(usr != src.occupant)
			return
		scrubber.ui_interact(occupant)
		return
	if (href_list["scrubber_connect"])
		if(usr != src.occupant)
			return
		var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector/) in loc
		if(possible_port)
			if(connect_scrubber(possible_port))
				src.occupant_message("<span class='notice'>[name] connects to the port.</span>")
				send_byjax(src.occupant, "exosuit.browser", "scrubbing_port", src.scrubber_port ? "<a href='?src=\ref[src];scrubber_disconnect=1'>Disconnect Scrubber from Port</a>" : "<a href='?src=\ref[src];scrubber_connect=1'>Connect Scrubber to Port</a>")
			else
				src.occupant_message("<span class='warning'>[name] failed to connect to the port.</span>")
		else
			src.occupant_message("Nothing happens")
		return
	if (href_list["scrubber_disconnect"])
		if(usr != src.occupant)
			return
		if(disconnect_scrubber())
			src.occupant_message("<span class='notice'>[name] disconnects from the port.</span>")
			send_byjax(src.occupant, "exosuit.browser", "scrubbing_port", src.scrubber_port ? "<a href='?src=\ref[src];scrubber_disconnect=1'>Disconnect Scrubber from Port</a>" : "<a href='?src=\ref[src];scrubber_connect=1'>Connect Scrubber to Port</a>")
		else
			src.occupant_message("<span class='warning'>[name] is not connected to the port at the moment.</span>")
		return
	return
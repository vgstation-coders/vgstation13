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

/obj/mecha/working/clarke/New()
	..()
	thruster_overlay = image('icons/mecha/mecha.dmi', src, "[initial(icon_state)]-thruster_overlay")
	scrubber = new(src)

/obj/mecha/working/clarke/Destroy()
	qdel(scrubber)
	scrubber = null
	..()

/obj/mecha/working/clarke/check_for_support()
	return 1

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

/obj/mecha/working/clarke/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];scrubbing=1'><span id="scrubbing_command">[scrubber.on?"Deactivate":"Activate"] scrubber</span></a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/working/clarke/Topic(href, href_list)
	..()
	if (href_list["scrubbing"])
		scrubber.on = !scrubber.on
		send_byjax(src.occupant,"exosuit.browser","scrubbing_command","[scrubber.on?"Deactivate":"Activate"] scrubber")
		src.occupant_message("<font color=\"[scrubber.on?"#00f\">Activated":"#f00\">Deactivated"] scrubber.</font>")
	return
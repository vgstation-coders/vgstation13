/obj/mecha/working/hamsandwich
	desc = "Combining man and machine for a better, stronger engineer."
	name = "Hamsandwich"
	icon_state = "hamsandwich"
	initial_icon = "hamsandwich"
	step_in = 1
	step_energy_drain = 2
	max_temperature = 100000
	health = 100
	wreckage = /obj/effect/decal/mecha_wreckage/ripley
	max_equip = 4
	cargo_capacity = 20
	var/image/thruster_overlay
	var/scrubbing = FALSE
	var/obj/machinery/portable_atmospherics/scrubber/mech/scrubber

/obj/mecha/working/hamsandwich/New()
	..()
	thruster_overlay = image('icons/mecha/mecha.dmi', src, "[initial(icon_state)]-thruster_overlay")
	scrubber = new(src)

/obj/mecha/working/hamsandwich/Destroy()
	qdel(scrubber)
	scrubber = null
	..()

/obj/mecha/working/hamsandwich/check_for_support()
	return 1

/obj/mecha/working/hamsandwich/mechturn(direction)
	dir = direction
	playsound(src,'sound/mecha/mechmove01.ogg',40,1)
	return 1

/obj/mecha/working/hamsandwich/mechstep(direction)
	if(istype(get_turf(src), /turf/space))
		overlays += thruster_overlay
	else
		overlays -= thruster_overlay
	return step(src,direction)

/obj/mecha/working/hamsandwich/mechsteprand()
	return step_rand(src)

/obj/mecha/working/hamsandwich/Process_Spacemove(var/check_drift = 0)
	return TRUE

/obj/mecha/working/hamsandwich/startMechWalking()
	icon_state = initial_icon + "-move"

/obj/mecha/working/hamsandwich/get_commands()
	var/output = {"<div class='wr'>
						<div class='header'>Special</div>
						<div class='links'>
						<a href='?src=\ref[src];scrubbing=1'><span id="scrubbing_command">[scrubbing?"Deactivate":"Activate"] scrubber</span></a>
						</div>
						</div>
						"}
	output += ..()
	return output

/obj/mecha/working/hamsandwich/Topic(href, href_list)
	..()
	if (href_list["scrubbing"])
		scrubbing = !scrubbing
		scrubber.on = !scrubber.on
		send_byjax(src.occupant,"exosuit.browser","scrubbing_command","[scrubbing?"Deactivate":"Activate"] scrubber")
		src.occupant_message("<font color=\"[scrubbing?"#00f\">Activated":"#f00\">Deactivated"] scrubber.</font>")
	return
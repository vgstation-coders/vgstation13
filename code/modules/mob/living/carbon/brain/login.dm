/mob/living/carbon/brain/Login()
	clear_fullscreens()
	. = ..()
	if(istype(controlling, /mob) && mind)
		mind.transfer_to(controlling)
		if(connected_to && istype(connected_to, /obj/machinery/controller_pod))
			var/obj/machinery/controller_pod/pod = connected_to
			if(istype(controlling, /mob))
				var/mob/M = controlling
				if(M.client)
					M.client.screen.Add(pod.eject_button)
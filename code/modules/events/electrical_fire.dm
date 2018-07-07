/datum/event/electrical_fire

/datum/event/electrical_fire/announce()
	command_alert(/datum/command_alert/electrical_storm)

/datum/event/electrical_fire/start()
	var/list/possibleEpicentres = list()
	for(var/obj/effect/landmark/newEpicentre in landmarks_list)
		if(newEpicentre.name == "lightsout") //We're piggybacking off of the lightsout event to save on mapping
			possibleEpicentres += newEpicentre

	var/obj/effect/landmark/epicentre = pick(possibleEpicentres)

	for(var/obj/machinery/M in range(epicentre,25))
		if(is_type_in_list(M, list(/obj/machinery/door, /obj/machinery/disposal, /obj/machinery/atmospherics, /obj/machinery/light)))
			continue
		if(M.pixel_y != 0 || M.pixel_x != 0)
			continue
		to_chat(world, "[M] ignited [formatJumpTo(M.loc)]")
		if(prob(60))
			spark(M, 5)
		if(prob(40))
			M.ignite(T0C+35000)
		if(prob(15))
			break

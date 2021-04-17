//throws an ancient cryopod at the station

/datum/event/ancientpod

/datum/event/ancientpod/can_start()
	return 20

/datum/event/ancientpod/start()
    var/obj/machinery/cryopod/pod = new /obj/machinery/cryopod(random_start_turf(1))
    pod.ThrowAtStation()

/datum/event/ancientpod/announce()
    command_alert(/datum/command_alert/ancientpod)
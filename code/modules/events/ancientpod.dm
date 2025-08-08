//throws an ancient cryopod at the station

/datum/event/ancientpod
    alert_type = /datum/command_alert/ancientpod

/datum/event/ancientpod/can_start()
	return 20

/datum/event/ancientpod/start()
    var/obj/machinery/cryopod/pod = new /obj/machinery/cryopod(random_start_turf(zlevel))
    pod.ThrowAtCenterZ(zlevel = src.zlevel)

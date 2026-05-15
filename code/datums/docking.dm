/datum/shuttle_dock_request
	var/datum/shuttle/initiator
	var/datum/shuttle/target
	var/obj/docking_port/shuttle/dynamic/pa  // dynamic port on initiator
	var/obj/docking_port/shuttle/dynamic/pb  // dynamic port on target
	var/mode = SDR_MODE_IN_PLACE
	var/expires_at = 0   // world.time after which expire() fires
	var/resolved = FALSE  // guard so accept/reject/cancel/expire can't double-fire
	var/announced = FALSE  // dedupe arrival-time crew announcement

// Destination port subtype that carries a back-reference to the request that created it.
/obj/docking_port/destination/dock_request
	var/datum/shuttle_dock_request/source_req

/datum/shuttle_dock_request/New(datum/shuttle/init, datum/shuttle/tgt, obj/docking_port/shuttle/dynamic/p_init, obj/docking_port/shuttle/dynamic/p_tgt, m)
	..()
	initiator = init
	target = tgt
	pa = p_init
	pb = p_tgt
	mode = m
	expires_at = world.time + SDR_REQUEST_TIMEOUT

/datum/shuttle_dock_request/proc/clear_pending()
	if(initiator?.pending_request == src)
		initiator.pending_request = null
	if(target?.pending_request == src)
		target.pending_request = null

/datum/shuttle_dock_request/proc/accept()
	if(resolved)
		return
	resolved = TRUE
	clear_pending()
	if(mode == SDR_MODE_IN_PLACE)
		initiator.accept_dock_request_in_place(src)
	else
		initiator.accept_dock_request_rendezvous(src)

/datum/shuttle_dock_request/proc/reject(reason)
	if(resolved)
		return
	resolved = TRUE
	clear_pending()
	for(var/obj/machinery/computer/shuttle_control/C in initiator.control_consoles)
		C.announce("Docking request denied by [target.name][reason ? ": [reason]" : "."]")

/datum/shuttle_dock_request/proc/cancel()
	if(resolved)
		return
	resolved = TRUE
	clear_pending()
	for(var/obj/machinery/computer/shuttle_control/C in initiator.control_consoles)
		C.announce("Docking request cancelled.")
	for(var/obj/machinery/computer/shuttle_control/C in target.control_consoles)
		C.announce("Docking request from [initiator.name] withdrawn.")

/datum/shuttle_dock_request/proc/expire()
	if(resolved)
		return
	resolved = TRUE
	clear_pending()
	for(var/obj/machinery/computer/shuttle_control/C in initiator.control_consoles)
		C.announce("Docking request to [target.name] timed out.")

// Fired once when a shuttle finishes its move into a dock_request destination.
// Tells both crews where the docking ended up; for in-place mode this includes
// the target's docking-port location so the host knows which airlock they're
// connected to.
/datum/shuttle_dock_request/proc/fire_arrival_announcement(datum/shuttle/arrived)
	if(announced)
		return
	announced = TRUE
	if(mode == SDR_MODE_RENDEZVOUS)
		for(var/obj/machinery/computer/shuttle_control/C in initiator.control_consoles)
			C.announce("Rendezvous with [target.name] complete.")
		for(var/obj/machinery/computer/shuttle_control/C in target.control_consoles)
			C.announce("Rendezvous with [initiator.name] complete.")
	else
		var/area/pb_area = get_area(pb)
		var/loc_label = pb_area ? pb_area.name : pb.areaname
		for(var/obj/machinery/computer/shuttle_control/C in initiator.control_consoles)
			C.announce("Docking complete. Now docked to [target.name] at [loc_label].")
		for(var/obj/machinery/computer/shuttle_control/C in target.control_consoles)
			C.announce("[initiator.name] has docked at [loc_label].")

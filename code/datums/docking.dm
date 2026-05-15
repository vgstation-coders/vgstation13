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

// Dynamic shuttle docking port: lives on a shuttle hull at a valid ship-to-ship
// docking location. Marks where another shuttle could dock against this one.
// Mappers place these inside shuttle DMMs and configure whitelist/blacklist.
//
// NOT picked as the shuttle's primary linked_port (see /datum/shuttle/initialize).
/obj/docking_port/shuttle/dynamic
	name = "dynamic docking port"
	icon_state = "docking_dynamic"
	areaname = "rendezvous"

	// If non-null and non-empty, only shuttles whose datum istype() one of these paths may dock here. Null/empty means no whitelist constraint.
	var/list/shuttle_whitelist = null
	// Shuttles whose datum istype() any of these paths may not dock here.
	var/list/shuttle_blacklist = list()

/obj/docking_port/shuttle/dynamic/can_shuttle_move(datum/shuttle/S)
	if(S && linked_shuttle == S)
		return 1
	return 0

/obj/docking_port/shuttle/dynamic/proc/allows_shuttle(datum/shuttle/S)
	if(!S)
		return FALSE
	if(shuttle_whitelist && shuttle_whitelist.len)
		var/matched = FALSE
		for(var/T in shuttle_whitelist)
			if(istext(T))
				T = text2path(T)
			if(T && istype(S, T))
				matched = TRUE
				break
		if(!matched)
			return FALSE
	for(var/T in shuttle_blacklist)
		if(istext(T))
			T = text2path(T)
		if(T && istype(S, T))
			return FALSE
	return TRUE

// A dynamic port is "occupied" if some shuttle has a dock_request commitment
// against it; either docked alongside (current_port is a dock_request with
// pa==src or pb==src) or inbound to one (destination_port likewise). This
// covers both "another ship is here right now" and "another ship is enroute
// and has reserved this slot".
/obj/docking_port/shuttle/dynamic/proc/is_occupied()
	for(var/datum/shuttle/S in shuttles)
		var/obj/docking_port/destination/dock_request/cur = S.current_port
		if(istype(cur) && cur.source_req && (cur.source_req.pa == src || cur.source_req.pb == src))
			return TRUE
		var/obj/docking_port/destination/dock_request/dst = S.destination_port
		if(istype(dst) && dst.source_req && (dst.source_req.pa == src || dst.source_req.pb == src))
			return TRUE
	return FALSE

// Shuttle-to-shuttle docking request handshake. See
// docs/superpowers/specs/2026-04-29-shuttle-dock-request-design.md for the
// full design. This datum tracks one outstanding handshake.
//
// SDR_* macros (modes, result codes, timeout) live in __DEFINES so they're
// visible to all callers regardless of .dme include order.

/datum/shuttle_dock_request
	var/datum/shuttle/initiator
	var/datum/shuttle/target
	var/obj/docking_port/shuttle/dynamic/pa  // dynamic port on initiator
	var/obj/docking_port/shuttle/dynamic/pb  // dynamic port on target
	var/mode = SDR_MODE_IN_PLACE
	var/expires_at = 0   // world.time after which expire() fires
	var/datum/virtual_z/chosen_rendezvous_vz  // populated after rendezvous accept
	var/resolved = FALSE  // guard so accept/reject/cancel/expire can't double-fire
	var/announced = FALSE  // dedupe arrival-time crew announcement

// Destination port subtype that carries a back-reference to the request
// that created it. /datum/shuttle/proc/move_to_dock uses this to fire the
// arrival announcement when the initiator parks at the dest.
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

// Fired by /datum/shuttle/proc/move_to_dock when a shuttle arrives at a
// /obj/docking_port/destination/dock_request that points back to this request.
// Single-fire: subsequent arrivals (e.g. target arriving second in rendezvous
// mode) are no-ops.
//
// Both shuttles' on_dock_request_completed() hooks fire so per-shuttle
// behaviour (announcements, achievements, logging) can opt in. The base hook
// is a no-op — see /datum/shuttle/proc/on_dock_request_completed.
/datum/shuttle_dock_request/proc/fire_arrival_announcement(datum/shuttle/arrived)
	if(announced)
		return
	announced = TRUE
	initiator.on_dock_request_completed(target, mode, pa, pb)
	target.on_dock_request_completed(initiator, mode, pb, pa)

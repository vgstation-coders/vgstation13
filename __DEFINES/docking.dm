// Shuttle-to-shuttle dock-request macros.
#define SDR_MODE_IN_PLACE     1  // initiator parks alongside target inside target's current vlevel
#define SDR_MODE_RENDEZVOUS   2  // both shuttles transit to a per-pair rendezvous vlevel

#define SDR_OK_PENDING        0  // request armed, waiting for target's response
#define SDR_OK_AUTO_ACCEPTED  1  // resolved synchronously (target had auto_accept_requests, or silent flag)
#define SDR_ERR_SELF          2
#define SDR_ERR_BUSY          3
#define SDR_ERR_TRANSIT       4
#define SDR_ERR_BAD_LOCATION  5
#define SDR_ERR_NO_COMPATIBLE_PORT 6
#define SDR_ERR_VISITORS_PRESENT 7  // would-be rendezvous would strand inbound/docked third parties

#define SHUTTLE_DOCKING_PROHIBITED 0 // handshake refused; shuttle is never listed as a docking target.
#define SHUTTLE_DOCKING_HIDDEN     1 // dock-requests succeed but the shuttle is hidden from the console list.
#define SHUTTLE_DOCKING_VISIBLE    2 // dock-requests succeed and the shuttle is listed on shuttle control consoles.

#define SDR_REQUEST_TIMEOUT (60 SECONDS)

#define SDR_DEBUG_PORT_SELECTION FALSE // Set to TRUE to spam admin chat with port-selection trace lines from /datum/shuttle/proc/find_compatible_dock_pair. Use this if you're making a new shuttle and want to test the dynamic ports.

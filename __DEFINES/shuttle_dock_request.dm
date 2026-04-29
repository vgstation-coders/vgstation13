// Shuttle-to-shuttle dock-request macros. Lives in __DEFINES so the codes are
// visible to any caller (subsystems, admin verbs, computers) regardless of
// where shuttle_dock_request.dm sits in the .dme include order.

// --- Modes ---
#define SDR_MODE_IN_PLACE     1  // initiator parks alongside target inside target's current vlevel
#define SDR_MODE_RENDEZVOUS   2  // both shuttles transit to a per-pair rendezvous vlevel

// --- Result codes returned by /datum/shuttle/proc/request_docking() ---
#define SDR_OK_PENDING        0  // request armed, waiting for target's response
#define SDR_OK_AUTO_ACCEPTED  1  // resolved synchronously (target had auto_accept_requests, or silent flag)
#define SDR_ERR_SELF          2
#define SDR_ERR_BUSY          3
#define SDR_ERR_TRANSIT       4
#define SDR_ERR_BAD_LOCATION  5
#define SDR_ERR_NO_COMPATIBLE_PORT 6
#define SDR_ERR_VISITORS_PRESENT 7  // would-be rendezvous would strand inbound/docked third parties

// --- Tunables ---
#define SDR_REQUEST_TIMEOUT (60 SECONDS)

// Set to TRUE to spam admin chat with port-selection trace lines from
// /datum/shuttle/proc/find_compatible_dock_pair. Leave FALSE in shipped builds.
#define SDR_DEBUG_PORT_SELECTION FALSE

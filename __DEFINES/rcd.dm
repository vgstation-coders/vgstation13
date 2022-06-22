//RCD schematic bitflags.
#define RCD_SELF_SANE    1  // Check proximity ourselves.
#define RCD_GET_TURF     2  // If used on objs/mobs, get the turf instead.
#define RCD_RANGE        4  // Use range() instead of adjacency. (old RPD behaviour.) (overriden by RCD_SELF_SANE)
#define RCD_SELF_COST    8  // Handle energy usage ourselves. (energy availability still checked).
#define RCD_ALLOW_SWITCH 16 // Allow schematic to be switched even if this one is currently in use.
#define RCD_Z_UP		 32 // Must have Z level above to use
#define RCD_Z_DOWN 		 64 // Must have Z level below to use

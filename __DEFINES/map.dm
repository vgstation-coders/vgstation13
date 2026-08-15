///Map generation defines
#define BIOME_LOWEST_HUMIDITY "biome_lowest_humidity"
#define BIOME_LOW_HUMIDITY "biome_low_humidity"
#define BIOME_MEDIUM_HUMIDITY "biome_medium_humidity"
#define BIOME_HIGH_HUMIDITY "biome_high_humidity"
#define BIOME_HIGHEST_HUMIDITY "biome_highest_humidity"

#define BIOME_COLDEST "coldest"
#define BIOME_COLD "cold"
#define BIOME_WARM "warm"
#define BIOME_TEMPERATE "perfect"
#define BIOME_HOT "hot"
#define BIOME_HOTTEST "hottest"

#define BIOME_COLDEST_CAVE "coldest_cave"
#define BIOME_COLD_CAVE "cold_cave"
#define BIOME_WARM_CAVE "warm_cave"
#define BIOME_HOT_CAVE "hot_cave"

#define RUIN_TYPE_GENERIC 	(1<<0)
#define RUIN_TYPE_SNOW 		(1<<1)
#define RUIN_TYPE_JUNGLE 	(1<<2)
#define RUIN_TYPE_TROPICAL 	(1<<3)
#define RUIN_TYPE_LAVA 		(1<<4)
#define RUIN_TYPE_URBAN 	(1<<5)
#define RUIN_TYPE_XENO 		(1<<6)
#define RUIN_TYPE_WET 		(1<<7)

#define RUIN_COST_LIGHT     1 //no substantialloot; mostly fluff
#define RUIN_COST_MEDIUM    3 //decent loot
#define RUIN_COST_HEAVY     9 //best loot or lots of loot

#define RUIN_BUDGET_PLANET  10 //max per planet
#define RUIN_BUDGET_JUNGLE  20 //max for junglestation

// Allocation sizing for virtual z-levels
#define ALLOCATION_SMALL		92 // can fit 25 in one zlevel
#define ALLOCATION_QUADRANT		245 // can fit 4 in one zlevel
#define ALLOCATION_FULL			500 // takes up the whole zlevel

// Virtual z-level spacing
#define VIRTUAL_Z_SPACING	10
#define RUIN_PLACEMENT_PADDING 		5 // Padding around ruins when placing them in vlevels to avoid edge issues
#define LANDING_ZONE_EDGE_BUFFER 	11 // Buffer distance from vlevel edges for shuttle landing zones

// Story generator defines
#define STORY_NT		1
#define STORY_WIZARD 	(1<<1)
#define STORY_NINJA 	(1<<2)
#define STORY_COMMANDO	(1<<3)
#define STORY_CLOWN		(1<<4)
#define STORY_GREY		(1<<5)
#define STORY_VOX		(1<<6)
#define STORY_SYNDICATE	(1<<7)

#define STORY_RECENT_THRESHOLD 70 // Threshold in years - stories younger than this spawn hostile mobs, older spawn corpses
#define STORY_MISSING_CHANCE 25 // Chance that a story landmark spawns nothing (body is missing)
#define STORY_DISEASE_CHANCE 10 // Chance that a spawned character is infected with a random disease

#define VZ_TELEPORTATION_ALLOWED		1		// Teleportation is allowed
#define VZ_TELEPORTATION_EXPENSIVE		(1<<1)  // Teleportation is allowed using real Bluespace Crystals
#define VZ_TELEPORTATION_FORBIDDEN		(1<<2)  // Teleportation is forbidden

// This v-level is a...
#define VZ_TRANSIT		1		// shuttle transit area
#define VZ_PARKING		2		// shuttle parking area
#define VZ_PLANET		3		// planet
#define VZ_PROTECTED	4		// protected area (centcomm, inaccessible dungeons, away missions, etc)
#define VZ_SPACE		5		// space area (station, encounter areas, derelict, dj sat, etc)

// Whether the Odyssey shuttle is in hyperspace, deep space, or docked at a planet
#define ODYSSEY_STATE_HYPERSPACE (1<<0)
#define ODYSSEY_STATE_DEEPSPACE  (1<<1)
#define ODYSSEY_STATE_PLANETSIDE (1<<2)

// System vLevel offset - system vLevels (station, centcomm, etc) use IDs 101+
// to differentiate them from dynamically created vLevels which use IDs 1+
#define SYSTEM_VLEVEL_OFFSET	100

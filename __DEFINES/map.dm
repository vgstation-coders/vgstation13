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

#define SECTOR_SIZE 100 //max width/height of a sector in turfs. temporary - will be dynamic later
#define RUIN_PLACEMENT_PADDING 5 // Padding around ruins when placing them in sectors to avoid edge issues
#define LANDING_ZONE_EDGE_BUFFER 11 // Buffer distance from sector edges for shuttle landing zones

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

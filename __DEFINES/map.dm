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

#define LOOT_TYPE_BEACH (1<<0)
#define LOOT_TYPE_DESERT (1<<1)
#define LOOT_TYPE_GRASS (1<<2)
#define LOOT_TYPE_JUNGLE (1<<3)
#define LOOT_TYPE_LAVA (1<<4)
#define LOOT_TYPE_SNOW (1<<5)
#define LOOT_TYPE_URBAN (1<<6)
#define LOOT_TYPE_XENO (1<<7)

#define SECTOR_SIZE 100 //max width/height of a sector in turfs. temporary - will be dynamic later
#define RUIN_PLACEMENT_PADDING 5 // Padding around ruins when placing them in sectors to avoid edge issues
#define LANDING_ZONE_EDGE_BUFFER 11 // Buffer distance from sector edges for shuttle landing zones

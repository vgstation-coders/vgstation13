// Helpers for checking whether a z-level conforms to a specific requirement

// Basic levels
#define is_centcom_level(z) SSmapping.level_trait(z, ZTRAIT_CENTCOM)

#define is_station_level(z) SSmapping.level_trait(z, ZTRAIT_STATION)

#define is_mining_level(z) SSmapping.level_trait(z, ZTRAIT_MINING)

#define is_reebe(z) SSmapping.level_trait(z, ZTRAIT_REEBE)

#define is_transit_level(z) SSmapping.level_trait(z, ZTRAIT_TRANSIT)

#define is_away_level(z) SSmapping.level_trait(z, ZTRAIT_AWAY)

// If true, the singularity cannot strip away asteroid turf on this Z
#define is_planet_level(z) (GLOB.z_is_planet["z"])

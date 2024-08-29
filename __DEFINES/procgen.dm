//Dedicated Z level
#define PG_Z			100

//Generator States
#define PG_INACTIVE		-1
#define PG_INIT			0
#define PG_MAPPING		1
#define PG_DECORATION	2
#define PG_POPULATION	3
#define PG_LOOT			4
//#define PG_VAULT 		5 //for spawning vaults

//Planet Types
#define PG_ASTEROIDS	/datum/procgen/celestial_body/asteroids
#define PG_MOON			/datum/procgen/celestial_body/moon
#define PG_PLANET		/datum/procgen/celestial_body/planet
#define PG_XENO			/datum/procgen/celestial_body/xeno

//Atmos Levels
#define PG_VACUUM		/datum/procedural_atmosphere/vacuum
#define PG_THIN			/datum/procedural_atmosphere/thin
#define	PG_BREATHABLE	/datum/procedural_atmosphere/breathable
#define PG_TOXIC		/datum/procedural_atmosphere/toxic

//Preciptation Levels
#define PG_NO_PRECIP	0
#define PG_L_PRECIP		1
#define PG_M_PRECIP		2
#define	PG_H_PRECIP		3
#define	PG_VH_PRECIP	4

//Temperature Levels
#define PG_FROZEN		0
#define	PG_COLD			1
#define	PG_BRISK		2
#define	PG_TEMPERATE	3
#define	PG_WARM			4
#define	PG_HOT			5
#define	PG_LAVA			6

//Biomes
#define PG_PERMAFROST		/datum/procedural_biome/permafrost
#define PG_ICE_SHEET		/datum/procedural_biome/ice_sheet
#define PG_TUNDRA			/datum/procedural_biome/tundra
#define PG_TAIGA			/datum/procedural_biome/taiga
#define PG_FOREST			/datum/procedural_biome/forest
#define PG_PLAINS			/datum/procedural_biome/plains
#define PG_SHRUBLAND		/datum/procedural_biome/shrubland
#define PG_SWAMPLAND		/datum/procedural_biome/swamp
#define PG_RAINFOREST		/datum/procedural_biome/rainforest
#define PG_SAVANNA			/datum/procedural_biome/savanna
#define PG_DESERT			/datum/procedural_biome/desert
#define PG_MAGMA			/datum/procedural_biome/magma
#define PG_ASH				/datum/procedural_biome/ash
#define PG_ASTEROID			/datum/procedural_biome/asteroid
#define PG_COMET			/datum/procedural_biome/comet
#define PG_ROCK				/datum/procgen/biome/rock

//History
#define PG_UNEXPLORED	/datum/procedural_civilization/unexplored
#define PG_YOUNG_CIV	/datum/procedural_civilization/young
#define PG_OLD_CIV		/datum/procedural_civilization/old
#define PG_FUTURE_CIV	/datum/procedural_civilization/future

//Altitude
#define PG_LOW_ALT	-2.5
#define PG_MED_ALT	0
#define PG_HIGH_ALT	2.5

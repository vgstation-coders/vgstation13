#define RUINTYPE_SPACE "Space"
#define RUINTYPE_LAVA "Lava"
#define RUINTYPE_SNOW "Snow"
#define RUINTYPE_SAND "Sand"
#define RUINTYPE_JUNGLE "Jungle"
#define RUINTYPE_ROCK "Rock"
#define RUINTYPE_BEACH "Beach"
#define RUINTYPE_WASTE "Waste"
#define RUINTYPE_YELLOW "Yellow"
#define RUINTYPE_XENO "Xeno"
#define RUINTYPE_DESERT "Desert"
#define RUINTYPE_WATER "Water"
#define RUINTYPE_URBAN "Urban"

/// do not actually use this for your ruin type, this is for the ruintype_to_list proc
#define RUINTYPE_EVERYTHING "Everything"

// HEY LISTEN!
// IF YOU ADD NEW A NEW RUIN TYPE
// PLEASE MAKE SURE YOU ADD IT TO THE BELOW LIST AND PROC!

#define RUINTYPE_LIST_ALL list(\
	RUINTYPE_SPACE,\
	RUINTYPE_LAVA,\
	RUINTYPE_ICE,\
	RUINTYPE_SAND,\
	RUINTYPE_JUNGLE,\
	RUINTYPE_ROCK,\
	RUINTYPE_BEACH,\
	RUINTYPE_WASTE,\
	RUINTYPE_YELLOW,\
	RUINTYPE_EVERYTHING)

/* /proc/ruintype_to_list(ruintype)
	if(ruintype == RUINTYPE_EVERYTHING)
		return SSmapping.ruins_templates
	else
		return SSmapping.ruin_types_list[ruintype] */

/*
Maps described in the catalogue must be described with at least one or more of the following tags.

*Loot Summary
Minor Loot = Has negligable/no loot at all, only contains fluff items or just the loot found from enemy drops or structures in the ruin.
Medium Loot = Has a pool of loot that is useful for the average player or ship, but not in large amounts, and does not have more than one or two boss drops.
Major Loot = Contains a large pool of loot useful to the average player or ship. Or includes more boss drops or necropolis loot than there are challenges for.
*/
#define RUIN_TAG_MINOR_LOOT "Minor Loot"
#define RUIN_TAG_MEDIUM_LOOT "Medium Loot"
#define RUIN_TAG_MAJOR_LOOT "Major Loot"

/*Combat Summary
No Combat = Contains no enemies or combat challenges.
Minor Combat Challenge = Has only 1-2 hit melee mobs in small or moderate amounts.
Medium Combat Challenge = Contains more than just simple low health melee mobs, or a moderate amount of mobs.
Boss Combat Challenge = Contains either one or more bossmobs, has a large number of mobs that are either overwhelming or considerably challenging, or has a significant combat challenge overall.
*/
#define RUIN_TAG_NO_COMBAT "No Combat"
#define RUIN_TAG_MINOR_COMBAT "Minor Combat Challenge"
#define RUIN_TAG_MEDIUM_COMBAT "Medium Combat Challenge"
#define RUIN_TAG_HARD_COMBAT "Hard Combat Challenge"
#define RUIN_TAG_BOSS_COMBAT "Boss Combat Challenge"


/*Qualities
Megafauna = Map contains one or more megafauna.
Antag Gear = Map contains one or more items typically only obtainable by antag roles.
Necropolis Loot = Map contains an item or chest from the necropolis loot pool.
Liveable = The entirety of the map is inhabitable without protective gear, and the map is not surrounded by an inhospitable environment.
Inhospitable = The majority of the map is uninhabitable without protective gear, and the map is not surrounded by a hospitable environment.
Shelter = The map contains a portion that is hospitable without protective gear, with a surrounding section that is inhospitable. Or the map is an enclosed hospitable space that spawns on an inhospitable planet.
Bad Shelter = The map contains a portion that is inhospitable without protective gear, with a surround section that is hospitable. Or the map is an enclosed inhospitable space that spawn on a hospitable planet.
No Content = A map that contains no objects. It contains only turfs, walls, and or areas.
Hazardous = Contains hazardous environment elements. Elements include but are not limited to: Mines, IEDs, Chasms appearing more than twice or more than once if one is 3x3 or more, disease spawns, beartraps.
Unknown Details = Something about the map can't be checked with a map editor alone, and has not been tested for confirmation yet.
Lava = Contains lava or liquid plasma tiles.
Ghost Role = Contains a ghost role.
*/
#define RUIN_TAG_MEGAFAUNA "Megafauna"
#define RUIN_TAG_LIVEABLE "Liveable"
#define RUIN_TAG_INHOSPITABLE "Inhospitable"
#define RUIN_TAG_SHELTER "Shelter"
#define RUIN_TAG_BAD_SHELTER "Bad Shelter"
#define RUIN_TAG_NO_CONTENT "No Content"
#define RUIN_TAG_HAZARDOUS "Hazardous"
#define RUIN_TAG_UNKNOWN_DETAILS "Unknown Details"
#define RUIN_TAG_LAVA "Lava"

#define TURF_DRY 0
#define TURF_WET_WATER 1
#define TURF_WET_LUBE 2
#define TURF_WET_ICE 3

#define TURF_CONTAINS_ROCKERNAUT 1
#define TURF_CONTAINS_BOSS 2

#define SLIP_HAS_MAGBOOTS -1 // Magbooties !


#define MINE_DIFFICULTY_NORM 1
#define MINE_DIFFICULTY_TOUGH 3
#define MINE_DIFFICULTY_DENSE 5
#define MINE_DIFFICULTY_GLHF 9

#define MINE_DURATION 100

/*
TURF_REAGENT_ENTER - applies the reagents when a mob or obj enters the turf
TURF_REAGENT_EXIT - same as above, but upon exiting
TURF_REAGENT_PROCESS - applies the reagents to all mobs in the turf when process is fired (roughly every 2 seconds)
TURF_REAGENT_INGORES_INVULNERABLE - applies reagents to mobs, even if they have the INVULNERABLE flag
TURF_REAGENT_FILLS_CONTAINERS - allows mobs to click on the turf with a reagent container in hand to fill it with the reagents.
*/
#define TURF_REAGENT_ENTER					(1 << 0)
#define TURF_REAGENT_EXIT					(1 << 1)
#define TURF_REAGENT_PROCESS				(1 << 2)
#define TURF_REAGENT_INGORES_INVULNERABLE	(1 << 3)
#define TURF_REAGENT_FILLS_CONTAINERS		(1 << 4)

#define WALL_OVERLAY 1
#define RWALL_OVERLAY 2

//Environment smash flags
#define SMASH_LIGHT_STRUCTURES 1	//tables, racks
#define SMASH_CONTAINERS 2	//closets, crates
#define SMASH_WALLS 4
#define SMASH_RWALLS 8
#define SMASH_ASTEROID 16
#define OPEN_DOOR_WEAK 32 //If the mob can attack and open unpowered doors
#define OPEN_DOOR_STRONG 64 //If the mob can attack and open powered doors
#define OPEN_DOOR_SMART 128 //If the mob can open doors more intelligently than the average bear (MUST BE COMBINED WITH OPEN_DOOR_WEAK or OPEN_DOOR_STRONG to function!!!)

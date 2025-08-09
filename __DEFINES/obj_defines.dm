//Blacksmithing quality
//The B prefix stands for blacksmith

#define B_AWFUL 1
#define B_SHODDY 2
#define B_POOR 3
#define B_AVERAGE 4
#define B_GOOD 5
#define B_SUPERIOR 6
#define B_EXCELLENT 7
#define B_MASTERWORK 8
#define B_LEGENDARY 9

var/list/qualityByString = list(
		B_AWFUL = "Awful",
		B_SHODDY = "Shoddy",
		B_POOR = "Poor",
		B_AVERAGE = "Average",
		B_GOOD = "Good",
		B_SUPERIOR = "Superior",
		B_EXCELLENT = "Excellent",
		B_MASTERWORK = "Masterwork",
		B_LEGENDARY = "Legendary")

//Daemons
#define DAEMON_EXAMINE 	1
#define DAEMON_AFTATT	2

// Shields
// SHIELD_xxx is to be given to shields
// IGNORE_xxx is to be given to thrown items
// If "IGNORE" is higher than "SHIELD", then the thrown item will always pass.
#define IGNORE_SOME_SHIELDS 1
#define SHIELD_ADVANCED 2

//Glue states
#define GLUE_STATE_NONE 0
#define GLUE_STATE_TEMP 1
#define GLUE_STATE_PERMA 2

// Spawners

#define SPAWN_ON_TURF "turf"
#define SPAWN_ON_LOC "loc"

// Slime extract application flags
#define SLIME_GREY 1
#define SLIME_GOLD 2
#define SLIME_SILVER 4
#define SLIME_METAL 8
#define SLIME_PURPLE 16
#define SLIME_DARKPURPLE 32
#define SLIME_ORANGE 64
#define SLIME_YELLOW 128
#define SLIME_RED 256
#define SLIME_BLUE 512
#define SLIME_DARKBLUE 1024
#define SLIME_PINK 2048
#define SLIME_GREEN 4096
#define SLIME_LIGHTPINK 8192
#define SLIME_BLACK 16384
#define SLIME_OIL 32768
#define SLIME_ADAMANTINE 65536
#define SLIME_BLUESPACE 131072
#define SLIME_PYRITE 262144
#define SLIME_CERULEAN 524288
#define SLIME_SEPIA 1048576
#define ALL_SLIMES 2097151 //sum of above, 2097152 - 1

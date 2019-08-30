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

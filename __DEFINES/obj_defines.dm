//Quality

#define AWFUL 1
#define SHODDY 2
#define POOR 3
#define AVERAGE 4
#define GOOD 5
#define SUPERIOR 6
#define EXCELLENT 7
#define MASTERWORK 8
#define LEGENDARY 9

var/list/qualityByString = list(
		AWFUL = "Awful",
		SHODDY = "Shoddy",
		POOR = "Poor",
		AVERAGE = "Average",
		GOOD = "Good",
		SUPERIOR = "Superior",
		EXCELLENT = "Excellent",
		MASTERWORK = "Masterwork",
		LEGENDARY = "Legendary")

//Daemons
#define DAEMON_EXAMINE 	1
#define DAEMON_AFTATT	2

// Shields
// SHIELD_xxx is to be given to shields
// IGNORE_xxx is to be given to thrown items
// If "IGNORE" is higher than "SHIELD", then the thrown item will always pass.
#define IGNORE_SOME_SHIELDS 1
#define SHIELD_ADVANCED 2

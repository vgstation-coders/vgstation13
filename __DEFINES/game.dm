#define EMBED_THROWING_SPEED 20

#define MOB_RUN_TALLY 1
#define MOB_WALK_TALLY 4

#define NO_SLOWDOWN 1

//NOTE: With a ticklag of 0.33, testing showed the following "ticklag granularity" effect:
//Any slowdown between 1.00 and 1.32 was effectively the same, unless combined with another slowdown (i.e. a hardsuit with 1.3 slowdown doesn't slow down a healthy running human)
//Any slowdown between 0.67 and 0.99 was effectively the same, unless combined with another slowdown (i.e. a slowdown of 0.95 is the same as a slowdown of 0.8 for a healthy running human)
#define HARDSUIT_SLOWDOWN_LOW 1.4
#define HARDSUIT_SLOWDOWN_MED 1.6 //doesn't actually seem to be any slower than 1.4, unless combined with another source of slowdown
#define HARDSUIT_SLOWDOWN_HIGH 1.8
#define HARDSUIT_SLOWDOWN_BULKY 2

#define NO_SHOES_SLOWDOWN 1.4
#define MISC_SHOE_SLOWDOWN 1.4
#define MAGBOOTS_SLOWDOWN_LOW NO_SLOWDOWN //CE's magboots are magic yo
#define MAGBOOTS_SLOWDOWN_MED 1.75
#define MAGBOOTS_SLOWDOWN_HIGH 2.33
#define SHACKLE_SHOES_SLOWDOWN 15

#define MINIGUN_SLOWDOWN_NONWIELDED 1.4
#define MINIGUN_SLOWDOWN_WIELDED 8

#define FIREAXE_SLOWDOWN 1.4

// Cyborgs & MoMMI defines
#define CYBORG_STARTING_TONER 40
#define CYBORG_MAX_TONER 100
#define CYBORG_PHOTO_COST 20

#define MEDICAL_MAX_KIT 10
#define STANDARD_MAX_KIT 15
#define SUPPLY_MAX_WRAP 24
#define ENGINEERING_MAX_COIL 50
#define MOMMI_MAX_COIL 50

#define SILICON_NO_CHARGE_SLOWDOWN 1.4
#define SILICON_NO_CELL_SLOWDOWN 15

#define CYBORG_ENGINEERING_SPEED_MODIFIER 1
#define CYBORG_MEDICAL_SPEED_MODIFIER 1
#define CYBORG_SYNDICATE_SPEED_MODIFIER 1
#define CYBORG_SUPPLY_SPEED_MODIFIER 1
#define CYBORG_JANITOR_SPEED_MODIFIER 1
#define CYBORG_COMBAT_SPEED_MODIFIER 1
#define CYBORG_STANDARD_SPEED_MODIFIER 1
#define CYBORG_SERVICE_SPEED_MODIFIER 1
#define CYBORG_SECURITY_SPEED_MODIFIER 1
#define CYBORG_TG17355_SPEED_MODIFIER 1

#define MOMMI_SOVIET_SPEED_MODIFIER 1
#define MOMMI_NT_SPEED_MODIFIER 1

#define SILICON_MOBILITY_MODULE_SPEED_MODIFIER 0.75 //Silicon's speed var is multiplied by the mobility module modifier
#define SILICON_VTEC_SPEED_BONUS 0.25 //But the VTEC Bonus is ADDED to their movement_speed_modifier

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

#define COMMAND_POSITIONS list("Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director", "Chief Medical Officer")
#define ENGINEERING_POSITIONS list("Chief Engineer", "Station  Engineer", "Atmospheric Technician", "Mechanic")
#define MEDICAL_POSITIONS list("Chief Medical Officer", "Medical Doctor", "Geneticist", "Virologist", "Paramedic", "Chemist")
#define SCIENCE_POSITIONS list("Research Director", "Scientist", "Geneticist", "Roboticist", "Mechanic")
#define CIVILIAN_POSITIONS list("Head of Personnel", "Bartender", "Botanist", "Chef", "Janitor", "Librarian", "Internal Affairs Agent", "Chaplain", "Clown", "Mime", "Assistant")
#define CARGO_POSITIONS list("Head of Personnel", "Quartermaster", "Cargo Technician", "Shaft Miner")
#define SECURITY_POSITIONS list("Head of Security", "Warden", "Detective", "Security Officer")

#define ALWAYSTRUE 2

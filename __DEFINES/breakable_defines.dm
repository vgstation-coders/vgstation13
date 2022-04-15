//Breakable objects
#define BREAKABLE_UNARMED (1<<0)	//Object can break by being hit with an unarmed attack.
#define BREAKABLE_WEAPON (1<<1)		//Object can break by being hit with a weapon. This includes projectiles.
#define BREAKABLE_AS_THROWN (1<<2)	//Object can break when it ballistically collides with something.
#define BREAKABLE_AS_MELEE (1<<3)	//Object can break when it's used as a melee weapon to hit something.
#define BREAKABLE_MOB (1<<4)		//Object can break when it's used to hit or collides with a mob. If disabled, overrides other flags.
#define BREAKABLE_HIT ( BREAKABLE_UNARMED | BREAKABLE_WEAPON )	//Object can break by being hit with either an unarmed attack or a weapon.
#define BREAKABLE_AS_ALL ( BREAKABLE_AS_THROWN | BREAKABLE_AS_MELEE | BREAKABLE_MOB )	//Object can break when it's used as a melee weapon, or when it ballistically collides with something.
#define BREAKABLE_ALL ALL			//Object can break by being hit, or when used to hit something as a melee or a thrown weapon.

//Standard damage_armor levels for breakable objects. Note that if an attack exceeds damage_armor it does full damage unless lessened by damage_resist.
#define BREAKARMOR_NOARMOR 0			//Plastically deforms at the slightest application of force.
#define BREAKARMOR_FLIMSY 2 			//Can only resist the weakest of attacks
#define BREAKARMOR_WEAK 5				//Can resist weak attacks
#define BREAKARMOR_MEDIUM 10			//Resistant to most attacks
#define BREAKARMOR_STRONG 20			//Only very powerful attacks will cause any damage
#define BREAKARMOR_UNYIELDING 50		//Anything but a devastatingly powerful attack will glance off harmlessly
#define BREAKARMOR_INVINCIBLE INFINITY	//Any power the world could conjure would be as a summer breeze against a stone wall
/* Projectile calibers */

#define MM9 "9mm"
#define MM12 "12mm"

#define POINT357 "357"
#define POINT38 ".38"
#define POINT380 ".380AUTO"
#define POINT45 ".45"
#define POINT50 ".50"
#define POINT75 ".75"
#define POINT762 "a762"
#define POINT762X55 "7.62x55"
#define NAGANTREVOLVER "7.62x38R"
#define BROWNING50 ".50BMG"
#define NTLR22 ".22LR"

#define ROCKETGRENADE "rpg"
#define GUIDEDROCKET "guided rocket"


#define PULSE "pulse"
#define GAUGE12 "12 gauge"
#define GAUGEFLARE "flare"

/* Lawgiver */
#define LAWGIVER_MODE_KIND_ENERGY "energy"
#define LAWGIVER_MODE_KIND_BULLET "bullet"
#define LAWGIVER_MAX_AMMO 5

//gun shit - prepare to have various things added to this, also, moved here because it's more tidy
#define SILENCECOMP  1 		//Silencer-compatible
#define AUTOMAGDROP  2		//Does the mag drop when it's empty?
#define EMPTYCASINGS 4		//Does the gun eject empty casings?
#define SCOPED		 8		//Attachable scope?
#define CHAMBERSPENT 16		//Spent casings stay in the gun until reloaded
#define MAG_OVERLAYS 32		//this gun uses magazine overlays instead of flat sprites with magazines included

//projectiles bouncing off and phasing through obstacles
#define PROJREACT_WALLS		1//includes opaque doors
#define PROJREACT_WINDOWS	2//includes transparent doors
#define PROJREACT_OBJS		4//structures, machines and items
#define PROJREACT_MOBS		8//all mobs
#define PROJREACT_BLOB		16//blob

#define CRIT_CHANCE_RANGED 2
#define CRIT_CHANCE_MELEE 15

#define CRIT_MULTIPLIER 3

#define MAX_DAMAGE_FOR_RAMPUP_MELEE 80
#define MAX_PROB_RAMPUP_MELEE 45

#define MAX_DAMAGE_FOR_RAMPUP_DIST 80
#define MAX_PROB_RAMPUP_DIST 10

//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31
#if DM_VERSION < 513
#error Your version of byond is too old, you need version 513 or higher
#endif
#define RUNWARNING // disable if they re-enable run() in 507 or newer.
                   // They did, tested in 508.1296 - N3X

// Defines for the shuttle
#define SHUTTLE_ON_STANDBY 0
#define SHUTTLE_ON_STATION 1
#define SHUTTLE_ON_CENTCOM 2

#ifndef RUNWARNING
#warn If you have issues with retrieving logs update byond on the server and client to 507.1277 or greater, or uncomment RUNWARNING
#endif

#define DEBUG
#define PROFILE_MACHINES // Disable when not debugging.

#define ARBITRARILY_LARGE_NUMBER 10000 //Used in delays.dm and vehicle.dm. Upper limit on delays
#define ARBITRARILY_PLANCK_NUMBER 1.417*(10**32) //1.417×10^32. Because ARBITRARILY_LARGE_NUMBER is too small and INF is too large
#define MAX_VALUE 65535

#ifdef PROFILE_MACHINES
#define CHECK_DISABLED(TYPE) if(disable_##TYPE) return
var/global/disable_scrubbers = 0
var/global/disable_vents     = 0
#else
#define CHECK_DISABLED(TYPE) /* DO NOTHINK */
#endif

#define PIPING_LAYER(base, piping_layer) base + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

#define PIPING_LAYER_DEFAULT	3 //starting value - this is the "central" pipe
#define PIPING_LAYER_INCREMENT	1 //how much the smallest step in piping_layer is

#define PIPING_LAYER_MIN	1
#define PIPING_LAYER_MAX	5

#define PIPING_LAYER_P_X		5*PIXEL_MULTIPLIER //each positive increment of piping_layer changes the pixel_x by this amount
#define PIPING_LAYER_P_Y		-5*PIXEL_MULTIPLIER //same, but negative because they form a diagonal
#define PIPING_LAYER_LCHANGE	0.05 //how much the layer var changes per increment

#define mouse_respawn_time 5 //Amount of time that must pass between a player dying as a mouse and repawning as a mouse. In minutes.

#define DEFAULT_LOBBY_TIME 5 MINUTES

// Pressure limits.
#define HAZARD_HIGH_PRESSURE 550	//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 	//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE 50 	//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE 20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5	//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define BODYTEMP_AUTORECOVERY_DIVISOR 0.5 //This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MAXIMUM 2.0 //Maximum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 0.5 .

#define BODYTEMP_COLD_DIVISOR 200 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.

#define PRESSUREFACTOR_NO_LINEAR 1.5  // Where growth of the pressure factor stops being linear
#define COLD_PRESSUREFACTOR_MAX (PRESSUREFACTOR_NO_LINEAR)/((-1/PRESSUREFACTOR_NO_LINEAR)+1)    // The highest that heat loss can be multiplied by due to pressure. Depends on where non linear starts.

#define BODYTEMP_HEAT_DIVISOR 80 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_HEATING_MAX 10 //The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT 360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT 220.15 // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE 5000	//These need better heat protect
#define FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE 30000 //what max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 30000 //for fire helmet quality items (red and white hardhats)

#define HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 600	//For normal helmets

#define ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 600	//For armor

#define GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE 1500		//For some gloves
#define SHOE_MAX_HEAT_PROTECTION_TEMPERATURE 1500		//For gloves

#define IS_SPACE_COLD 1
#define PRESSURE_DAMAGE_COEFFICIENT 4 //The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE 4	//This used to be 20... I got this much random rage for some retarded decision by polymorph?! Polymorph now lies in a pool of blood with a katana jammed in his spleen. ~Errorage --PS: The katana did less than 20 damage to him :(
#define LOW_PRESSURE_DAMAGE 2 	//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define PRESSURE_SUIT_REDUCTION_COEFFICIENT 0.8 //This is how much (percentual) a suit with the flag STOPSPRESSUREDMG reduces pressure.
#define PRESSURE_HEAD_REDUCTION_COEFFICIENT 0.4 //This is how much (percentual) a helmet/hat with the flag STOPSPRESSUREDMG reduces pressure.

// Heat Conductivity - 1 is fully conductive, 0 is fully insulative.
#define ARMOUR_HEAT_CONDUCTIVITY		0.4	//For armour
#define INS_ARMOUR_HEAT_CONDUCTIVITY 	0.2	//For heat insulated suits like hardsuits or jumpers.

#define MASK_HEAT_CONDUCTIVITY			0.4	//For normal masks
#define INS_MASK_HEAT_CONDUCTIVITY 		0.2	//For heat insulated masks such as a balaclavas, scarves & gas masks

#define JUMPSUIT_HEAT_CONDUCTIVITY		0.4 //For normal jumpsuits
#define INS_JUMPSUIT_HEAT_CONDUCTIVITY	0.1 //For heat insulated jumpsuits, if such a thing is even possible.

#define SHOE_HEAT_CONDUCTIVITY			0.4	//For normal shoes.
#define INS_SHOE_HEAT_CONDUCTIVITY		0.3	//For insulated shoes like jackboots or magboots.

#define HELMET_HEAT_CONDUCTIVITY		0.4 //For helmets
#define INS_HELMET_HEAT_CONDUCTIVITY	0.2 //For heat insulated helmets

#define GLOVES_HEAT_CONDUCTIVITY		0.4	//For normal gloves.
#define INS_GLOVES_HEAT_CONDUCTIVITY	0.2	//For some heat insulated gloves (black and yellow.)

#define SNOWGEAR_HEAT_CONDUCTIVITY 		0.2	// for now
#define SPACESUIT_HEAT_CONDUCTIVITY		0	// until a time where space is no longer cold

// Doors!
#define DOOR_CRUSH_DAMAGE 10

// Factor of how fast mob nutrition decreases
#define HUNGER_FACTOR 0.15  // Please remember when editing this that it will also affect hypothermia.

#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD	150+T0C
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST	100+T0C
#define FIRE_SPREAD_RADIOSITY_SCALE		0.85
#define FIRE_CARBON_ENERGY_RELEASED	  500000 //Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED	 3000000 //Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE			40000 //For small fires

//#define WATER_BOIL_TEMP 393

var/turf/space/Space_Tile = locate(/turf/space) // A space tile to reference when atmos wants to remove excess heat.

//This was a define, but I changed it to a variable so it can be changed in-game.(kept the all-caps definition because... code...) -Errorage
var/MAX_EXPLOSION_RANGE = 14
//#define MAX_EXPLOSION_RANGE		14					// Defaults to 12 (was 8) -- TLE

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define HUMAN_REVERSESTRIP_DELAY 20
#define MONKEY_STRIP_DELAY 40
#define MONKEY_REVERSESTRIP_DELAY 5

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.
#define ROLE_SELECT_AFK_BUFFER  1 // Default value.

//WEIGHT CLASSES
#define W_CLASS_TINY 1
#define W_CLASS_SMALL 2
#define W_CLASS_MEDIUM 3
#define W_CLASS_LARGE 4
#define W_CLASS_HUGE 5
#define W_CLASS_GIANT 20


//ITEM INVENTORY SLOT BITMASKS
#define SLOT_OCLOTHING 1
#define SLOT_ICLOTHING 2
#define SLOT_GLOVES 4
#define SLOT_EYES 8
#define SLOT_EARS 16
#define SLOT_MASK 32
#define SLOT_HEAD 64
#define SLOT_FEET 128
#define SLOT_ID 256
#define SLOT_BELT 512
#define SLOT_BACK 1024
#define SLOT_POCKET 2048		//this is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 4096	//this is to deny items with a w_class of 2 or 1 to fit in pockets.
#define SLOT_TWOEARS 8192
#define SLOT_LEGS = 16384


//MANNEQUIN SLOT BITMASKS
#define SLOT_MANNEQUIN_ICLOTHING	"uniform"
#define SLOT_MANNEQUIN_FEET			"shoes"
#define SLOT_MANNEQUIN_GLOVES		"gloves"
#define SLOT_MANNEQUIN_EARS			"earset"
#define SLOT_MANNEQUIN_OCLOTHING	"suit"
#define SLOT_MANNEQUIN_EYES			"glasses"
#define SLOT_MANNEQUIN_BELT			"belt"
#define SLOT_MANNEQUIN_MASK			"mask"
#define SLOT_MANNEQUIN_HEAD			"hat"
#define SLOT_MANNEQUIN_BACK			"backpack"
#define SLOT_MANNEQUIN_ID			"idcard"


//FLAGS BITMASK

//Item flags!
#define PROXMOVE	1	// Will the code check us when we move or when something moves near us? Note that if the item doesn't have this flag, HasProximity() will never execute for it.
#define FPRINT		2	// takes a fingerprint
#define INVULNERABLE 8
#define HEAR		16 // This flag is necessary to give an item (or mob) the ability to hear spoken messages! Mobs without a client still won't hear anything unless given HEAR_ALWAYS
#define HEAR_ALWAYS 32 // Assign a virtualhearer to the mob even when no client is controlling it. (technically not an item flag, but related to the above)

#define TWOHANDABLE	64
#define MUSTTWOHAND	128
#define SLOWDOWN_WHEN_CARRIED 256 //Apply slowdown when carried in hands, instead of only when worn

#define NOBLOODY	512	// used to items if they don't want to get a blood overlay

#define NO_ATTACK_MSG 	1024 // when an item has this it produces no "X has been hit by Y with Z" message with the default handler
#define NO_THROW_MSG 	2048 // produce no "X has thrown Y" message when somebody throws this item
#define NO_STORAGE_MSG 	4096 // produce no "X puts the Y into the backpack" message when somebody moves this item in their inventory

#define OPENCONTAINER	8192  // is an open container for chemistry purposes
#define	NOREACT 		16384 // Reagents don't react inside this container.

#define TIMELESS		32768 // Immune to time manipulation.

#define SILENTCONTAINER	65536 //reactions inside make no noise
#define ATOM_INITIALIZED 131072 // initialize() was called

#define ALL ~0
#define NONE 0

//airflow flags!

#define ON_BORDER 1   // item has priority to check when entering or leaving
#define IMPASSABLE 2  // item will make things auto_fail on prox checks through it


//sharpness flags
#define SHARP_TIP 		 1 // Has a pointy-stabby end, such as a syringe or a knife tip.
#define SHARP_BLADE		 2 // Has a blade long and thin enough to slice something with.
#define SERRATED_BLADE	 4 // Has saw-like teeth to cut through harder materials, however messily. The serrated edge may not necessarily be sharp!
#define CHOPWOOD		 8 // Kind of an abstract one: The implement is suitable to chop wood with. Essentially a saw or something big enough.
#define INSULATED_EDGE 	 16 // One of the edges of this thing is insulated, even though the rest of it isn't.
#define HOT_EDGE 		 32 // The blade of this thing can produce enough heat to melt through things, even if not sharp.
#define CUT_WALL 64 //Will cut through walls and girders when the item has this flag
#define CUT_AIRLOCK 128 //Will cut through airlocks when the item has this flag

//flags for pass_flags
#define PASSTABLE	1
#define PASSGLASS	2
#define PASSGRILLE	4
#define PASSMOB		8
#define PASSBLOB	16
#define PASSMACHINE	32 //computers, vending machines, rnd machines
#define PASSDOOR	64 //not just airlocks, but also firelocks, windoors etc
#define PASSGIRDER	128 //not just airlocks, but also firelocks, windoors etc

#define PASSALL 191 //really ugly, shouldn't this be PASSTABLE|PASSGLASS|PASSGRILLE etc?


/*
	These defines are used specifically with the atom/movable/languages bitmask.
	They are used in atom/movable/Hear() and atom/movable/say() to determine whether hearers can understand a message.

	They also have a secondary use in to_bump() code for living mobs, in the mob_bump_flag and mob_swap_flags/mob_push_flags vars
*/

#define HUMAN 1
#define MONKEY 2
#define ALIEN 4
#define ROBOT 8
#define SLIME 16
#define SIMPLE_ANIMAL 32

#define ALLMOBS 63 //update this

//turf-only flags
#define NOJAUNT		1
#define NO_MINIMAP  2 //Invisible to minimaps (fuck minimaps)


//slots
#define slot_back 1
#define slot_wear_mask 2
#define slot_handcuffed 3
#define slot_belt 4
#define slot_wear_id 5
#define slot_ears 6
#define slot_glasses 7
#define slot_gloves 8
#define slot_head 9
#define slot_shoes 10
#define slot_wear_suit 11
#define slot_w_uniform 12
#define slot_l_store 13
#define slot_r_store 14
#define slot_s_store 15
#define slot_in_backpack 16
#define slot_legcuffed 17
#define slot_legs 18

#define is_valid_hand_index(index) ((index > 0) && (index <= held_items.len))

//Cant seem to find a mob bitflags area other than the powers one

// bitflags for mob parts

#define HEAD			1		//specifically the top of the head- imagine it as the scalp.
#define EYES			2048
#define MOUTH			4096
#define EARS			8192

#define UPPER_TORSO		2
#define LOWER_TORSO		4
#define LEG_LEFT		8
#define LEG_RIGHT		16
#define FOOT_LEFT		32
#define FOOT_RIGHT		64
#define ARM_LEFT		128
#define ARM_RIGHT		256
#define HAND_LEFT		512
#define HAND_RIGHT		1024


// bitflags for clothing parts

#define FULL_TORSO		(UPPER_TORSO|LOWER_TORSO)
#define FACE			(EYES|MOUTH|BEARD)	//38912
#define BEARD			32768
#define FULL_HEAD		(HEAD|EYES|MOUTH|EARS)
#define LEGS			(LEG_LEFT|LEG_RIGHT) 		// 24
#define FEET			(FOOT_LEFT|FOOT_RIGHT) 	//96
#define ARMS			(ARM_LEFT|ARM_RIGHT)		//384
#define HANDS			(HAND_LEFT|HAND_RIGHT) //1536
#define FULL_BODY		(FULL_HEAD|HANDS|FULL_TORSO|ARMS|FEET|LEGS)
#define IGNORE_INV		16384 // Don't make stuff invisible


// bitflags for invisibility
// Used in body_parts_covered

#define HIDEGLOVES			HANDS
#define HIDEJUMPSUIT		(ARMS|LEGS|FULL_TORSO)
#define HIDESHOES			FEET
#define HIDEMASK			FACE
#define HIDEEARS			EARS
#define HIDEEYES			EYES
#define HIDEFACE			FACE
#define HIDEHEADHAIR 		65536
#define MASKHEADHAIR		131072
#define HIDEBEARDHAIR		BEARD
#define HIDEHAIR			(HIDEHEADHAIR|HIDEBEARDHAIR)//98304
#define	HIDESUITSTORAGE		LOWER_TORSO

// bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection() as well as calculate_affecting_pressure() now
// The values here should add up to 1.
// Hands and feet have 2.5%, arms and legs 7.5%, each of the torso parts has 15%, and each of the head parts has 7.5%

#define COVER_PROTECTION_HEAD			0.075
#define COVER_PROTECTION_EYES			0.075
#define COVER_PROTECTION_MOUTH			0.075
#define COVER_PROTECTION_EARS			0.075

#define COVER_PROTECTION_UPPER_TORSO	0.15
#define COVER_PROTECTION_LOWER_TORSO	0.15
#define COVER_PROTECTION_LEG_LEFT		0.075
#define COVER_PROTECTION_LEG_RIGHT		0.075
#define COVER_PROTECTION_FOOT_LEFT		0.025
#define COVER_PROTECTION_FOOT_RIGHT		0.025
#define COVER_PROTECTION_ARM_LEFT		0.075
#define COVER_PROTECTION_ARM_RIGHT		0.075
#define COVER_PROTECTION_HAND_LEFT		0.025
#define COVER_PROTECTION_HAND_RIGHT		0.025

var/global/list/BODY_PARTS = list(HEAD,EYES,EARS,MOUTH,UPPER_TORSO,LOWER_TORSO,LEG_RIGHT,LEG_LEFT,FOOT_LEFT,FOOT_RIGHT,ARM_LEFT,ARM_RIGHT,HAND_LEFT,HAND_RIGHT)
var/global/list/BODY_COVER_VALUE_LIST=list("[HEAD]" = COVER_PROTECTION_HEAD,"[EYES]" = COVER_PROTECTION_EYES,"[EARS]" = COVER_PROTECTION_EARS, "[MOUTH]" = COVER_PROTECTION_MOUTH, "[UPPER_TORSO]" = COVER_PROTECTION_UPPER_TORSO,"[LOWER_TORSO]" = COVER_PROTECTION_LOWER_TORSO,"[LEG_LEFT]" = COVER_PROTECTION_LEG_LEFT,"[LEG_RIGHT]" = COVER_PROTECTION_LEG_RIGHT,"[FOOT_LEFT]" = COVER_PROTECTION_FOOT_LEFT,"[FOOT_RIGHT]" = COVER_PROTECTION_FOOT_RIGHT,"[ARM_LEFT]" = COVER_PROTECTION_ARM_LEFT,"[ARM_RIGHT]" = COVER_PROTECTION_ARM_RIGHT,"[HAND_LEFT]" = COVER_PROTECTION_HAND_LEFT,"[HAND_RIGHT]" = COVER_PROTECTION_HAND_RIGHT)


//bitflags for mutations
	// Extra powers:
#define SHADOW			(1<<10)	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			(1<<11)	// supersonic screaming (25%)
#define EXPLOSIVE		(1<<12)	// exploding on-demand (15%)
#define REGENERATION	(1<<13)	// superhuman regeneration (30%)
#define REPROCESSOR		(1<<14)	// eat anything (50%)
#define SHAPESHIFTING	(1<<15)	// take on the appearance of anything (40%)
#define PHASING			(1<<16)	// ability to phase through walls (40%)
#define SHIELD			(1<<17)	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		(1<<18)	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		(1<<19)	// ability to shoot electric attacks (15%)


// String identifiers for associative list lookup

// mob/var/list/mutations

// Used in preferences.
#define DISABILITY_FLAG_NEARSIGHTED 1
#define DISABILITY_FLAG_FAT         2
#define DISABILITY_FLAG_EPILEPTIC   4
#define DISABILITY_FLAG_DEAF        8
#define DISABILITY_FLAG_BLIND       16
#define DISABILITY_FLAG_MUTE		32
#define DISABILITY_FLAG_VEGAN		64
#define DISABILITY_FLAG_ASTHMA 128
#define DISABILITY_FLAG_LACTOSE		256

///////////////////////////////////////
// MUTATIONS
///////////////////////////////////////



// Generic mutations:
#define	M_TK			1
#define M_RESIST_COLD	2
#define M_XRAY			3
#define M_HULK			4
#define M_CLUMSY			5
#define M_FAT				6
#define M_HUSK			7
#define M_NOCLONE			8

// Extra powers:
#define M_LASER			9 	// harm intent - click anywhere to shoot lasers from eyes
#define M_CLAWS			10	// Deal extra damage with punches (but without gloves), can butcher animals without tools
#define M_BEAK			11	// Can buther animals without tools
#define M_TALONS		12  // Bonus kick damage
#define M_STONE_SKIN	13  // hard skin

//#define HEAL			12 	// (Not implemented) healing people with hands
//#define SHADOW		13 	// (Not implemented) shadow teleportation (create in/out portals anywhere) (25%)
//#define SCREAM		14 	// (Not implemented) supersonic screaming (25%)
//#define EXPLOSIVE		15 	// (Not implemented) exploding on-demand (15%)
//#define REGENERATION	16 	// (Not implemented) superhuman regeneration (30%)
//#define REPROCESSOR	17 	// (Not implemented) eat anything (50%)
//#define SHAPESHIFTING	18 	// (Not implemented) take on the appearance of anything (40%)
//#define PHASING		19 	// (Not implemented) ability to phase through walls (40%)
//#define SHIELD		20 	// (Not implemented) shielding from all projectile attacks (30%)
//#define SHOCKWAVE		21 	// (Not implemented) attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
//#define ELECTRICITY	22 	// (Not implemented) ability to shoot electric attacks (15%)

//2spooky
#define M_SKELETON 29

// Other Mutations:
#define M_NO_BREATH		100 	// no need to breathe
#define M_REMOTE_VIEW	101 	// remote viewing
#define M_REGEN			102 	// health regen
#define M_RUN			103 	// no slowdown
#define M_REMOTE_TALK	104 	// remote talking
#define M_MORPH			105 	// changing appearance
#define M_RESIST_HEAT	106 	// heat resistance
#define M_HALLUCINATE	107 	// hallucinations
#define M_FINGERPRINTS	108 	// no fingerprints
#define M_NO_SHOCK		109 	// insulated hands
#define M_DWARF			110 	// table climbing
#define M_UNBURNABLE	111		// can't get set on fire

// Goon muts
#define M_OBESITY       200		// Decreased metabolism
#define M_TOXIC_FARTS   201		// Duh
#define M_STRONG        202		// (Nothing)
#define M_SOBER         203		// Increased alcohol metabolism
#define M_PSY_RESIST    204		// Block remoteview
#define M_SUPER_FART    205		// Duh
#define M_SMILE         206		// :)
#define M_ELVIS         207		// You ain't nothin' but a hound dog.
#define M_HORNS         208

// /vg/ muts
#define M_LOUD		308		// CAUSES INTENSE YELLING
#define M_WHISPER	309		// causes quiet whispering
#define M_DIZZY		310		// Trippy.
#define M_SANS		311		// IF YOU SEE THIS WHILST BROWSING CODE, YOU HAVE BEEN VISITED BY: THE FONT OF SHITPOSTING. GREAT LUCK AND WEALTH WILL COME TO YOU, BUT ONLY IF YOU SAY 'I love comic sans' IN YOUR PR.
#define M_FARSIGHT	312		// Increases mob's view range by 2
#define M_NOIR		313		// aww yis detective noir
#define M_VEGAN		314
#define M_ASTHMA	315
#define M_LACTOSE	316

var/global/list/NOIRMATRIX = list(0.33,0.33,0.33,0,\
				 				  0.33,0.33,0.33,0,\
								  0.33,0.33,0.33,0,\
								  0.00,0.00,0.00,1,\
								  0.00,0.00,0.00,0)

// Bustanuts
#define M_HARDCORE      300

//disabilities
#define NEARSIGHTED		1
#define EPILEPSY		2
#define COUGHING		4
#define TOURETTES		8
#define NERVOUS			16
#define ASTHMA		32
#define LACTOSE		64

//sdisabilities
#define BLIND			1
#define MUTE			2
#define DEAF			4

//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

// channel numbers for power
#define EQUIP	1
#define LIGHT	2
#define ENVIRON	3
#define TOTAL	4	//for total power used only
#define STATIC_EQUIP 5
#define STATIC_LIGHT	6
#define STATIC_ENVIRON	7

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse
#define FORCEDISABLE 32 //forced to be off, such as by a random event

//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

#define ENGINE_EJECT_Z	3

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

#define GAS_O2 	(1 << 0)
#define GAS_N2	(1 << 1)
#define GAS_PL	(1 << 2)
#define GAS_CO2	(1 << 3)
#define GAS_N2O	(1 << 4)


#define INV_SLOT_SIGHT "sight_slot"
#define INV_SLOT_TOOL "tool_slot"

//#define IS_MODE_COMPILED(MODE) (ispath(text2path("/datum/gamemode/"+(MODE))))


var/list/global_mutations = list() // list of hidden mutation things

//Bluh shields


//Damage things	//TODO: merge these down to reduce on defines
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define HALLOSS		"halloss"
#define BRAIN 		"brain"

#define STUN		"stun"
#define WEAKEN		"weaken"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define AGONY		"agony" // Added in PAIN!
#define STUTTER		"stutter"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"

#define CUT 		"cut"
#define BRUISE		"bruise"
#define SLUR 		"slur"

//intent flags yay
#define I_HELP		"help"
#define I_DISARM	"disarm"
#define I_GRAB		"grab"
#define I_HURT		"hurt"

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define SUICIDE_ACT_BRUTELOSS 1
#define SUICIDE_ACT_FIRELOSS 2
#define SUICIDE_ACT_TOXLOSS 4
#define SUICIDE_ACT_OXYLOSS 8
#define SUICIDE_ACT_CUSTOM 16

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN		1
#define CANKNOCKDOWN	2
#define CANPARALYSE	4
#define CANPUSH		8
#define UNPACIFIABLE 16		//Immune to pacify effects.
#define GODMODE		4096
#define FAKEDEATH	8192	//Replaces stuff like changeling.changeling_fakedeath
#define XENO_HOST	32768	//Tracks whether we're gonna be a baby alien's mummy.

var/static/list/scarySounds = list('sound/weapons/thudswoosh.ogg','sound/weapons/Taser.ogg','sound/weapons/armbomb.ogg','sound/voice/hiss1.ogg','sound/voice/hiss2.ogg','sound/voice/hiss3.ogg','sound/voice/hiss4.ogg','sound/voice/hiss5.ogg','sound/voice/hiss6.ogg','sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg','sound/items/Welder.ogg','sound/items/Welder2.ogg','sound/machines/airlock.ogg','sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')

//Grab levels
#define GRAB_PASSIVE	1
#define GRAB_AGGRESSIVE	2
#define GRAB_NECK		3
#define GRAB_UPGRADING	4
#define GRAB_KILL		5

//Security levels
#define SEC_LEVEL_RAINBOW	-1
#define SEC_LEVEL_GREEN		0
#define SEC_LEVEL_BLUE		1
#define SEC_LEVEL_RED		2
#define SEC_LEVEL_DELTA		3

#define TRANSITIONEDGE	7 //Distance from edge to move to another z-level
/*
var/list/liftable_structures = list(\

	/obj/machinery/r_n_d/fabricator/mechanic_fab/autolathe, \
	/obj/machinery/constructable_frame, \
	/obj/machinery/portable_atmospherics/hydroponics, \
	/obj/machinery/computer, \
	/obj/machinery/optable, \
	/obj/structure/dispenser, \
	/obj/machinery/gibber, \
	/obj/machinery/microwave, \
	/obj/machinery/vending, \
	/obj/machinery/seed_extractor, \
	/obj/machinery/space_heater, \
	/obj/machinery/recharge_station, \
	/obj/machinery/flasher, \
	/obj/structure/stool, \
	/obj/structure/closet, \
	/obj/machinery/photocopier, \
	/obj/structure/filingcabinet, \
	/obj/structure/reagent_dispensers, \
	/obj/machinery/portable_atmospherics/canister)
*/
//A set of constants used to determine which type of mute an admin wishes to apply:
//Please read and understand the muting/automuting stuff before changing these. MUTE_IC_AUTO etc = (MUTE_IC << 1)
//Therefore there needs to be a gap between the flags for the automute flags
#define MUTE_IC			1
#define MUTE_OOC		2
#define MUTE_PRAY		4
#define MUTE_ADMINHELP	8
#define MUTE_DEADCHAT	16
#define MUTE_ALL		31

//Number of identical messages required to get the spam-prevention automute thing to trigger warnings and automutes
#define SPAM_TRIGGER_WARNING 5
#define SPAM_TRIGGER_AUTOMUTE 10

//Some constants for DB_Ban
#define BANTYPE_PERMA		1
#define BANTYPE_TEMP		2
#define BANTYPE_JOB_PERMA	3
#define BANTYPE_JOB_TEMP	4
#define BANTYPE_ANY_FULLBAN	5 //used to locate stuff to unban.
#define BANTYPE_APPEARANCE	6
#define BANTYPE_OOC_PERMA	7
#define BANTYPE_OOC_TEMP	8

#define SEE_INVISIBLE_MINIMUM 5

#define SEE_INVISIBLE_OBSERVER_NOLIGHTING 15	//Used by Ghosts when they click "Toggle Darkness".

#define INVISIBILITY_LIGHTING 20	//Used by the lighting_overlay. Any value bellow that one will let you see in the dark.

#define SEE_INVISIBLE_LIVING 25		//This what players have by default.

#define SEE_INVISIBLE_LEVEL_ONE 35	//Used by mobs under certain conditions.
#define INVISIBILITY_LEVEL_ONE 35	//Used by infrared beams.

#define SEE_INVISIBLE_LEVEL_TWO 45	//Used by mobs under certain conditions.
#define INVISIBILITY_LEVEL_TWO 45	//Used by turrets inside their covers.

#define INVISIBILITY_CULTJAUNT 50	//Used by cult
#define SEE_INVISIBLE_CULTJAUNT 50	//Used by cult

#define INVISIBILITY_OBSERVER 60	//Used by Ghosts.
#define SEE_INVISIBLE_OBSERVER 60	//Used by Ghosts.

#define INVISIBILITY_MAXIMUM 100

/*
FOR IN-GAME TESTING PURPOSES (var/sight bitflags)

BLIND		1
SEE_MOBS	4
SEE_OBJS	8
SEE_TURFS	16
SEE_SELF	32
SEE_INFRA	64
SEE_PIXELS	256
*/

// Object specific defines.
#define CANDLE_LUM 2 //For how bright candles are.


// Some mob defines below.
#define AI_CAMERA_LUMINOSITY 5

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define HOSTILE_STANCE_IDLE 1
#define HOSTILE_STANCE_ALERT 2
#define HOSTILE_STANCE_ATTACK 3
#define HOSTILE_STANCE_ATTACKING 4
#define HOSTILE_STANCE_TIRED 5

#define BEE_ROAMING 0
#define BEE_OUT_FOR_PLANTS 1
#define BEE_OUT_FOR_ENEMIES 2
#define BEE_HEADING_HOME 3
#define BEE_SWARM 4
#define BEE_BUILDING 5

//for infestation events
#define LOC_KITCHEN 0
#define LOC_ATMOS 1
#define LOC_INCIN 2
#define LOC_CHAPEL 3
#define LOC_LIBRARY 4
#define LOC_HYDRO 5
#define LOC_VAULT 6
#define LOC_TECH 7

#define VERM_MICE    0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2
#define VERM_SLIMES  3
#define VERM_BATS    4
#define VERM_BORERS  5
#define VERM_MIMICS  6
#define VERM_ROACHES 7
#define VERM_GREMLINS 8
#define VERM_BEES 9
#define VERM_HORNETS 10
#define VERM_SYPHONER 11
#define VERM_GREMTIDE 12
#define VERM_CRABS 13
#define VERM_DIONA 14
#define VERM_MUSHMEN 15
#define VERM_FROGS 14
#define VERM_SNAILS 15


#define MONSTER_BEAR    0
#define MONSTER_CREATURE 1
#define MONSTER_XENO 2
#define MONSTER_HIVEBOT  3
#define MONSTER_ZOMBIE    4
#define MONSTER_SKRITE  5
#define MONSTER_SQUEEN  6
#define MONSTER_FROG 7
#define MONSTER_GOLIATH 8
#define MONSTER_DAVID 9
#define MONSTER_MADCRAB 10
#define MONSTER_MEATBALLER 11
#define MONSTER_BIG_ROACH 12
#define MONSTER_ROACH_QUEEN 13

#define ROUNDSTART_LOGOUT_REPORT_TIME 6000 //Amount of time (in deciseconds) after the rounds starts, that the player disconnect report is issued.

// Special 'weapons', used in damage procs
#define WPN_HIGH_BODY_TEMP "High Body Temperature"
#define WPN_LOW_BODY_TEMP  "Low Body Temperature"
#define RAD_INTERNAL "Radiation internal application"
#define RAD_EXTERNAL "Radiation external application"

///////////////////ORGAN DEFINES///////////////////

#define ORGAN_CUT_AWAY		1
#define ORGAN_GAUZED		2
#define ORGAN_ATTACHABLE	4
#define ORGAN_BLEEDING		8
#define ORGAN_BROKEN		32
#define ORGAN_DESTROYED		64
#define ORGAN_ROBOT			128
#define ORGAN_SPLINTED		256
#define SALVED				512
#define ORGAN_DEAD			1024
#define ORGAN_MUTATED		2048
#define ORGAN_PEG			4096 // ROB'S MAGICAL PEGLEGS v2
#define ORGAN_MALFUNCTIONING 8192


//Admin Permissions
//Please don't edit these values without speaking to [current /vg/ host here] first
//Currently at the limit for rank bitflags, if any are needed to be added in the future then consider replacement of R_MOD as we don't use it at time of writing, or merge R_STEALTH into R_ADMIN.

#define R_BUILDMODE		1
#define R_ADMIN			2
#define R_BAN			4
#define R_FUN			8
#define R_SERVER		16
#define R_DEBUG			32
#define R_POSSESS		64
#define R_PERMISSIONS	128
#define R_STEALTH		256
#define R_REJUVINATE	512
#define R_VAREDIT		1024
#define R_SOUNDS		2048
#define R_SPAWN			4096
#define R_MOD			8192
#define R_ADMINBUS		16384
#define R_POLLING		32768

#define R_MAXPERMISSION 32768 //This holds the maximum value for a permission. It is used in iteration, so keep it updated.

#define R_HOST			65535

//Preference toggles
#define SOUND_ADMINHELP	1
#define SOUND_MIDI		2
#define SOUND_AMBIENCE	4
#define SOUND_LOBBY		8
#define CHAT_OOC		16
#define CHAT_DEAD		32
#define CHAT_GHOSTEARS	64
#define CHAT_GHOSTSIGHT	128
#define CHAT_PRAYER		256
#define CHAT_RADIO		512
#define CHAT_ATTACKLOGS	1024
#define CHAT_DEBUGLOGS	2048
#define CHAT_LOOC		4096
#define CHAT_GHOSTRADIO 8192
#define SOUND_STREAMING 16384 // /vg/
#define CHAT_GHOSTPDA   32768
#define AUTO_DEADMIN	65536

#define TOGGLES_DEFAULT (SOUND_ADMINHELP|SOUND_MIDI|SOUND_AMBIENCE|SOUND_LOBBY|CHAT_OOC|CHAT_DEAD|CHAT_GHOSTEARS|CHAT_GHOSTSIGHT|CHAT_PRAYER|CHAT_RADIO|CHAT_ATTACKLOGS|CHAT_LOOC|SOUND_STREAMING)

//////////////////////////////////
// ROLES 2.0
//////////////////////////////////
// First bit is no/yes.
// Second bit is persistence (save to char prefs).
// Third bit is whether we polled for that role yet.
#define ROLEPREF_ENABLE         1 // Enable role for this character.
#define ROLEPREF_PERSIST        2 // Used to flag a pref as Always/Never
#define ROLEPREF_POLLED         4 // Have we polled this guy?
#define ROLEPREF_SAVE           8 // Flag the pref to be saved permanently.

#define ROLEPREF_NEVER   ROLEPREF_PERSIST
#define ROLEPREF_NO      0
#define ROLEPREF_YES     ROLEPREF_ENABLE
#define ROLEPREF_ALWAYS  (ROLEPREF_ENABLE|ROLEPREF_PERSIST)

// Masks.
#define ROLEPREF_VALMASK  3 // 0b00000011 - Used to get ROLEPREF flags without the ROLEPREF_POLLED and ROLEPREF_SAVE bits

// Should correspond to jobbans, too.
#define ROLE_BORER      	"borer"
#define ROLE_PAI        	"pAI"
#define ROLE_PLANT      	"Dionaea"
#define ROLE_POSIBRAIN  	"posibrain"
#define ROLE_MINOR			"minor roles"
#define ROLE_ALIEN			"xenomorph"
#define ROLE_STRIKE			"striketeam"

#define AGE_MIN 17			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be

/*//Languages!
#define LANGUAGE_HUMAN		1
#define LANGUAGE_ALIEN		2
#define LANGUAGE_DOG		4
#define LANGUAGE_CAT		8
#define LANGUAGE_BINARY		16
#define LANGUAGE_OTHER		32768

#define LANGUAGE_UNIVERSAL	65535
*/

#define LEFT 1
#define RIGHT 2

// for secHUDs and medHUDs and variants. The number is the location of the image on the list hud_list of humans.
#define HEALTH_HUD          "health" // a simple line rounding the mob's number health
#define STATUS_HUD          "status" // alive, dead, diseased, etc.
#define RECORD_HUD			"record" // what medbay has set your records to
#define ID_HUD              "id" // the job asigned to your ID
#define WANTED_HUD          "wanted" // wanted, released, parroled, security status
#define IMPLOYAL_HUD		"imployal" // loyality implant
#define IMPCHEM_HUD		    "impchem" // chemical implant
#define IMPTRACK_HUD		"imptrack" // tracking implant
#define SPECIALROLE_HUD 	"specialrole" // AntagHUD image
#define STATUS_HUD_OOC		"status_ooc" // STATUS_HUD without virus db check for someone being ill.
#define DIAG_HEALTH_HUD		"diag_health" // Diagnostic HUD - health bar
#define DIAG_CELL_HUD		"diag_cell" // Diagnostic HUD - power cell status for cyborgs, mechs
#define CONSTRUCT_HUD		"const_health" // Artificer HUD

// Hypothermia - using the swiss staging system. - called by the proc undergoing_hypothermia() in handle_hypothermia.dm
#define NO_HYPOTHERMIA			0	// >35C   - Fine
#define MILD_HYPOTHERMIA		1	// 32-35C - Awake and shivering
#define MODERATE_HYPOTHERMIA	2	// 28-35C - Drowsy, not shivering.
#define SEVERE_HYPOTHERMIA 		3	// 20-28C - Unconcious, not shivering
#define PROFOUND_HYPOTHERMIA 	4	// <20C   - No vital signs.

//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_2SLOW		1	//20-40 bpm
#define PULSE_SLOW		2	//40-60 bpm
#define PULSE_NORM		3	//60-90 bpm
#define PULSE_FAST		4	//90-120 bpm
#define PULSE_2FAST		5	//>120 bpm
#define PULSE_THREADY	6	//occurs during hypovolemic shock

//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

var/list/RESTRICTED_CAMERA_NETWORKS = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	CAMERANET_THUNDER,
	CAMERANET_ERT,
	CAMERANET_NUKE,
	CAMERANET_CREED
	)

//Generic species flags.
#define NO_BREATHE 1
#define NO_SCAN 2
#define NO_PAIN 4
#define IS_SLOW 8
#define IS_PLANT 16
#define IS_WHITELISTED 32
#define RAD_ABSORB 64
#define REQUIRE_LIGHT 128
#define HYPOTHERMIA_IMMUNE 256
#define PLASMA_IMMUNE 512
#define RAD_GLOW 1024
#define ELECTRIC_HEAL 2048
#define SPECIES_NO_MOUTH 4096
//#define REQUIRE_DARK 8192
#define RAD_IMMUNE 16384

//Species anatomical flags.
#define HAS_SKIN_TONE 1
#define HAS_LIPS 2
#define HAS_UNDERWEAR 4
#define HAS_TAIL 8
#define CAN_BE_FAT 16
#define IS_BULKY 32 //can't wear exosuits, gloves, masks, or hardsuits
#define NO_SKIN 64
#define NO_BLOOD 128
#define HAS_SWEAT_GLANDS 256
#define NO_BONES 512
#define NO_STRUCTURE 1024	//no vessels, muscles, or any sort of internal structure, uniform throughout
#define MULTICOLOR 2048	//skin color is unique rather than tone variation
#define ACID4WATER 4096 //Acid now acts like water, and vice versa.
#define NO_BALD 8192 //cannot lose hair through being shaved/radiation/etc

var/default_colour_matrix = list(1,0,0,0,\
								 0,1,0,0,\
								 0,0,1,0,\
								 0,0,0,1)

//species chemical flags
#define NO_DRINK 1
#define NO_EAT 2
#define NO_SPLASH 4
#define NO_INJECT 8
#define NO_CRYO 16


// from bay station
#define INFECTION_LEVEL_ONE 100
#define INFECTION_LEVEL_TWO 500
#define INFECTION_LEVEL_THREE 1000

//Diseases, Virus, Antigens
#define	SPREAD_BLOOD	1//can be extracted from the carrier's blood, all diseases have this by default.
#define	SPREAD_CONTACT	2//touching or bumping into someone may transmit the virus, virus can survive on items for a while. gloves lower the chance of transmission.
#define	SPREAD_AIRBORNE	4//carrier mobs will periodically release invisible clouds that carry the virus to adjacent mobs that can breath it.
#define SPREAD_COLONY 8 //like contact, but only spreads to suited individuals or pressure-resistant clothing.
#define SPREAD_MEMETIC 16 //spreads on hearing, doesn't appear on goggles


#define EFFECT_DANGER_HELPFUL	"0"
#define EFFECT_DANGER_FLAVOR	"1"
#define EFFECT_DANGER_ANNOYING	"2"
#define EFFECT_DANGER_HINDRANCE	"3"
#define EFFECT_DANGER_HARMFUL	"4"
#define EFFECT_DANGER_DEADLY	"5"

#define	ANTIGEN_BLOOD	"blood"
#define	ANTIGEN_COMMON	"common"
#define	ANTIGEN_RARE	"rare"
#define	ANTIGEN_ALIEN	"alien"

//blood antigens
#define	ANTIGEN_O	"O"
#define	ANTIGEN_A	"A"
#define	ANTIGEN_B	"B"
#define	ANTIGEN_RH	"Rh"
//common antigens
#define	ANTIGEN_Q	"Q"
#define	ANTIGEN_U	"U"
#define	ANTIGEN_V	"V"
//rare antigens
#define	ANTIGEN_M	"M"
#define	ANTIGEN_N	"N"
#define	ANTIGEN_P	"P"
//alien antigens
#define	ANTIGEN_X	"X"
#define	ANTIGEN_Y	"Y"
#define	ANTIGEN_Z	"Z"

//Language flags.
#define WHITELISTED 1  // Language is available if the speaker is whitelisted.
#define RESTRICTED 2   // Language can only be accquired by spawning or an admin.
#define CAN_BE_SECONDARY_LANGUAGE 4 // Language is available on character setup as secondary language.

// Hairstyle flags
#define HAIRSTYLE_CANTRIP 1 // 5% chance of tripping your stupid ass if you're running.

// equip_to_slot_if_possible flags
#define EQUIP_FAILACTION_NOTHING 0
#define EQUIP_FAILACTION_DELETE 1
#define EQUIP_FAILACTION_DROP 2

//mob_can_equip flags
#define CANNOT_EQUIP 0
#define CAN_EQUIP 1
#define CAN_EQUIP_BUT_SLOT_TAKEN 2

// Vampire power defines
#define VAMP_REJUV    1
#define VAMP_GLARE    2
#define VAMP_HYPNO    3
#define VAMP_SHAPE    4
#define VAMP_VISION   5
#define VAMP_DISEASE  6
#define VAMP_CLOAK    7
#define VAMP_BATS     8
#define VAMP_SCREAM   9
#define VAMP_HEAL     10
#define VAMP_JAUNT    11
#define VAMP_SLAVE    12
#define VAMP_BLINK    13
#define VAMP_MATURE   14
#define VAMP_SHADOW   15
#define VAMP_CHARISMA 16
#define VAMP_UNDYING  17
#define VAMP_CAPE	  18
#define STARTING_BLOOD 10

#define VAMP_FAILURE -1

// Moved from machine_interactions.dm
#define STATION_Z  1
#define CENTCOMM_Z 2
#define TELECOMM_Z 3
#define DERELICT_Z 4
#define ASTEROID_Z 5
#define SPACEPIRATE_Z 6

// canGhost(Read|Write) flags
#define PERMIT_ALL 1

// Bay fixed recursive_mob_check (so shit can hear things from inside a container)
// Unfortunately, it created incredible amounts of lag.
// Comment the following line if you want it anyway.
#define USE_BROKEN_RECURSIVE_MOBCHECK


//////////////////
// RECYCLING SHIT
//////////////////

// Sorting categories
#define NOT_RECYCLABLE   0
#define RECYK_MISC       1
#define RECYK_GLASS      2
#define RECYK_BIOLOGICAL 3
#define RECYK_METAL      4
#define RECYK_ELECTRONIC 5
#define RECYK_WOOD		 6

////////////////
// job.info_flags
#define JINFO_SILICON 1 // Silicon job

// The default value for all uses of set background. Set background can cause gradual lag and is recommended you only turn this on if necessary.
// 1 will enable set background. 0 will disable set background.
#define BACKGROUND_ENABLED 0

// multitool_topic() shit
#define MT_ERROR  -1
#define MT_UPDATE 1
#define MT_REINIT 2

#define AUTOIGNITION_WOOD  573.15
#define AUTOIGNITION_PAPER 519.15

// snow business
#define SNOWBALL_MINIMALTEMP 265	//about -10°C, the minimal temperature at which a thrown snowball can cool you down.
#define SNOWBALL_TIMELIMIT 400	//in deciseconds, how long after being spawn does the snowball disappears if it hasn't been picked up

#define SNOWSPREAD_MAXTEMP 296.15	//23°C, the maximal temperature (in Kelvin) at which cosmic snow will spread to adjacent tiles
#define COSMICSNOW_MINIMALTEMP 233	//-40°C, the lowest temperature at which Cosmic snow will cool down its surroundings

//the following defines refer to the number of cosmic snow tiles in the world.
#define COSMICFREEZE_LEVEL_1 300	//Cosmic snow now has a chance to spawn a sappling upon spreading.
#define COSMICFREEZE_LEVEL_2 600	//Cosmic snow now has a chance to spawn a snowman upon spreading.
#define COSMICFREEZE_LEVEL_3 1400	//Pine Trees now has a chance to spawn a spiderling upon growing.
#define COSMICFREEZE_LEVEL_4 1500	//(triggered once per round) Space bears spawn around the station.
#define COSMICFREEZE_LEVEL_5 2200	//Pine Trees now have a chance to spawn a Space Bear upon growing.
#define COSMICFREEZE_END 2500	//All the snow procs come to a stop, snow no longer spread.


//used to define machine behaviour in attackbys and other code situations
#define EMAGGABLE		1 //can we emag it? If this is flagged, the machine calls emag()
#define SCREWTOGGLE		2 //does it toggle panel_open when hit by a screwdriver?
#define CROWDESTROY		4 //does hitting a panel_open machine with a crowbar disassemble it?
#define WRENCHMOVE		8 //does hitting it with a wrench toggle its anchored state?
#define FIXED2WORK		16 //does it need to be anchored to work? Try to use this with WRENCHMOVE - hooks into power code
#define EJECTNOTDEL		32 //when we destroy the machine, does it remove all its items or destroy them?
#define WELD_FIXED		64 //if it is attacked by a welder and is anchored, it'll toggle between welded and unwelded to the floor
#define MULTITOOL_MENU	128 //if it has multitool menu functionality inherently
#define PURCHASER		256 //it connects to the centcom database at roundstart
#define WIREJACK		512 //can we wirejack it? if flagged, machine calls wirejack()
#define SHUTTLEWRENCH	1024 //if this flag exists, the computer can be wrenched on shuttle floors
#define SECUREDPANEL 2048 //it won't let you open the deconstruction panel if you don't have the linked account number. Originally used for custom vending machines

#define MAX_N_OF_ITEMS 999 // Used for certain storage machinery, BYOND infinite loop detector doesn't look things over 1000.


///////////////////////
///////RESEARCH////////
///////////////////////
//used in rdmachines, to define certain behaviours
//bitflags are my waifu - Comic

//NB TRUELOCKS should ONLY be used for machines that produce stuff that's not good in an emergency i.e. a gun fabricator. Be very careful with it
#define CONSOLECONTROL		1	//does the console control it? can't be interacted if not linked
#define HASOUTPUT			2	//does it have an output? - mainly for fabricators
#define TAKESMATIN			4	//does it takes materials (sheets) - mainly for fabricators
#define NANOTOUCH			8	//does it have a nanoui when you smack it with your hand? - mainly for fabricators
#define HASMAT_OVER			16	//does it have overlays for when you load materials in? - mainly for fabricators
#define ACCESS_EMAG			32	//does it lose all its access when smacked by an emag? incompatible with CONSOLECONTROl, for obvious reasons
#define LOCKBOXES			64	//does it spawn a lockbox around a design which is said to be locked? - for fabricators
#define TRUELOCKS			128 //does it make a truly locked lockbox? If not set, the lockboxes made are unlockable by any crew with an ID
#define IGNORE_MATS			256 //does it ignore material requirements for designs? - warning, can be OP
#define IGNORE_CHEMS		512 //does it ignore chemical requirements for designs? - also super OP
#define FAB_RECYCLER		1024//does it recycle materials from items? used for autolathe checks

// Mecca scanner flags
#define MECH_SCAN_FAIL		1 // Cannot be scanned at all.
#define MECH_SCAN_ILLEGAL	2 // Can only be scanned by the antag scanner.
#define MECH_SCAN_ACCESS	4 // Can only be scanned with the access required for the machine


// EMOTES!
#define VISIBLE 1
#define HEARABLE 2


// /vg/ - Pipeline processing (enables exploding pipes and whatnot)
// COMMENT OUT TO DISABLE
// #define ATMOS_PIPELINE_PROCESSING 1

#define MAXIMUM_FREQUENCY 1600
#define MINIMUM_FREQUENCY 1200

// /vg/ - Mining flags
#define DIG_ROCKS	1	//mining turfs - minerals, the asteroid stuff, you know
#define DIG_SOIL	2	//dirt - this flag gives it shovel functionality
#define DIG_WALLS	4	//metal station walls - not the mineral ones
#define DIG_RWALLS	8	//reinforced station walls - beware

// For first investigation_log arg
// Easier to idiot-proof it this way.
#define I_HREFS    "hrefs"
#define I_NOTES    "notes"
#define I_NTSL     "ntsl"
#define I_SINGULO  "singulo"
#define I_ATMOS    "atmos"
#define I_CHEMS	   "chems"
#define I_WIRES    "wires"
#define I_GHOST    "poltergeist"
#define I_ARTIFACT "artifacts"


// delayNext() flags.
#define DELAY_MOVE    1
#define DELAY_ATTACK  2
#define DELAY_SPECIAL 4
#define DELAY_THROW 8
#define DELAY_ALL (DELAY_MOVE|DELAY_ATTACK|DELAY_SPECIAL|DELAY_THROW)

//singularity defines
#define STAGE_ONE 	1
#define STAGE_TWO 	3
#define STAGE_THREE	5
#define STAGE_FOUR	7
#define STAGE_FIVE	9
#define STAGE_SUPER	11
#define STAGE_SSGSS	13

//Human Overlays Indexes/////////THIS DEFINES WHAT LAYERS APPEARS ON TOP OF OTHERS
#define FIRE_LAYER				1		//If you're on fire (/tg/ shit)
#define MUTANTRACE_LAYER		2		//TODO: make part of body?
#define MUTATIONS_LAYER			3
#define DAMAGE_LAYER			4
#define UNIFORM_LAYER			5
#define SHOES_LAYER				6
#define GLOVES_LAYER			7
#define EARS_LAYER				8
#define SUIT_LAYER				9
#define GLASSES_LAYER			10
#define BELT_LAYER				11		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		12
#define HAIR_LAYER				13		//TODO: make part of head layer?
#define GLASSES_OVER_HAIR_LAYER	14
#define FACEMASK_LAYER			15
#define HEAD_LAYER				16
#define BACK_LAYER				17		//Back should be above head so that headgear doesn't hides backpack when facing north
#define ID_LAYER				18		//IDs should be visible above suits and backpacks
#define HANDCUFF_LAYER			19
#define LEGCUFF_LAYER			20
#define HAND_LAYER				21
#define TAIL_LAYER				22		//bs12 specific. this hack is probably gonna come back to haunt me
#define TARGETED_LAYER			23		//BS12: Layer for the target overlay from weapon targeting system
#define TOTAL_LAYERS			23
//////////////////////////////////


//COMMENT IF YOUR DREAMDAEMON VERSION IS BELOW 507.1248
#define BORDER_USE_TURF_EXIT 1

////////////////////////
////PDA APPS DEFINES////
////////////////////////
#define PDA_APP_ALARM			100
#define PDA_APP_RINGER			101
#define PDA_APP_SPAMFILTER		102
#define PDA_APP_BALANCECHECK	103
#define PDA_APP_STATIONMAP		104
#define PDA_APP_SNAKEII			105
#define PDA_APP_MINESWEEPER		106
#define PDA_APP_SPESSPETS		107

#define PDA_APP_SNAKEII_MAXSPEED		9
#define PDA_APP_SNAKEII_MAXLABYRINTH	8

//Some alien checks for reagents for alien races.
#define IS_DIONA 1
#define IS_VOX 2
#define IS_PLASMA 3


//Turf Construction defines
#define BUILD_SILENT_FAILURE -1		//We failed but don't give an error message
#define BUILD_FAILURE 0				//We failed so give an error message
#define BUILD_SUCCESS 1			//Looks for a lattice to build.
#define BUILD_IGNORE 2		//Ignores the need for lattice to build.


#define ARENA_SETUP 0		//under construction/resetting the arena
#define ARENA_AVAILABLE 1	//arena is ready for a new game
#define ARENA_INGAME 2		//a game is currently being played in the arena
#define ARENA_ENDGAME 3		//a game just finished and the arena is about to reset

// Languages
#define LANGUAGE_GALACTIC_COMMON "Galactic Common"
#define LANGUAGE_HUMAN "Sol Common"
#define LANGUAGE_UNATHI "Sinta'unathi"
#define LANGUAGE_CATBEAST "Siik'tajr"
#define LANGUAGE_SKRELLIAN "Skrellian"
#define LANGUAGE_ROOTSPEAK "Rootspeak"
#define LANGUAGE_TRADEBAND "Tradeband"
#define LANGUAGE_GUTTER "Gutter"
#define LANGUAGE_GREY "Grey"
#define LANGUAGE_XENO "Xenomorph"
#define LANGUAGE_CLATTER "Clatter"
#define LANGUAGE_MONKEY "Monkey"
#define LANGUAGE_VOX "Vox-pidgin"
#define LANGUAGE_CULT "Cult"
#define LANGUAGE_MOUSE "Mouse"
#define LANGUAGE_GOLEM "Golem"
#define LANGUAGE_SLIME "Slime"
#define LANGUAGE_MARTIAN "Martian"
#define LANGUAGE_INSECT "Insectoid"
#define LANGUAGE_DEATHSQUAD "Deathsquad"

//#define SAY_DEBUG 1
#ifdef SAY_DEBUG
	#warn SOME ASSHOLE FORGOT TO COMMENT SAY_DEBUG BEFORE COMMITTING
	#define say_testing(a,x) to_chat(a, ("([__FILE__]:[__LINE__] say_testing) [x]"))
#else
	#define say_testing(a,x)
//	null << "[x][a]")
#endif

#define ASTAR_DEBUG 0
#if ASTAR_DEBUG == 1
#warn "Astar debug is on. Don't forget to turn it off after you've done :)"
#define astar_debug(text) to_chat(world, text)
#else
#define astar_debug(text)
#endif

#define BSQL_DEBUG_CONNECTION 0
#if BSQL_DEBUG_CONNECTION == 1
#warn "BSQL_DEBUG_CONNECTION MUST BE SET TO 0 BEFORE COMMITING."
#endif

//#define JUSTFUCKMYSHITUP 1
#ifdef JUSTFUCKMYSHITUP
#define writepanic(a) if(ticker && ticker.current_state >= 3 && world.cpu > 100) write_panic(a)
#warn IMA FUCK YOUR SHIT UP
var/proccalls = 1
//keep a list of last 10 proccalls maybe?
/proc/write_panic(a)
	set background = 1
	panicfile["[proccalls]"] << a
	if(++proccalls > 200)
		proccalls = 1

#else
	#define writepanic(a) null << a
#endif

//Default frequencies of signal based RC stuff, because comic and his magic numbers.
#define FREQ_DISPOSAL 1367


//Ore processing types for the ore processor
#define ORE_PROCESSING_GENERAL 1
#define ORE_PROCESSING_ALLOY 2

//SOUND CHANNELS
#define CHANNEL_WEATHER				1018
#define CHANNEL_MEDBOTS				1019
#define CHANNEL_BALLOON				1020
#define CHANNEL_GRUE				1021	//only ever used to allow the ambient grue sound to be made to stop playing
#define CHANNEL_LOBBY				1022
#define CHANNEL_AMBIENCE			1023
#define CHANNEL_ADMINMUSIC			1024
#define CHANNEL_STARMAN				1025

//incorporeal_move values
#define INCORPOREAL_DEACTIVATE	0
#define INCORPOREAL_GHOST		1
#define INCORPOREAL_ETHEREAL_IMPROVED 1.5
#define INCORPOREAL_ETHEREAL	2
#define GHOST_MOVEDELAY 1
#define ETHEREAL_IMPROVED_MOVEDELAY 1.5
#define ETHEREAL_MOVEDELAY 2


//MALFUNCTION FLAGS
#define COREFIRERESIST 1
#define HIGHRESCAMS 2

//Mob sizes
#define SIZE_TINY	1 //Mice, lizards, borers, kittens - mostly things that can fit into a man's palm
#define SIZE_SMALL	2 //Monkeys, dionae, cats, dogs
#define SIZE_NORMAL	3 //Humanoids, robots, small slimes and most of the other animals
#define SIZE_BIG	4 //The AI, large slimes, wizard 'creatures', goliaths, hivebots
#define SIZE_HUGE	5 //Pine trees

#define ADIABATIC_EXPONENT		0.667	//This means something g-guys

//For mob/proc/show_message (code/modules/mob/mob.dm @ 248)
#define MESSAGE_SEE		1 //Visible message
#define MESSAGE_HEAR	2 //Hearable message

//Food flags. code/modules/reagents/reagent_containers/food/snacks.dm
#define FOOD_MEAT	1
#define FOOD_ANIMAL	2
#define FOOD_SWEET	4
#define FOOD_LIQUID	8
#define FOOD_SKELETON_FRIENDLY 16 //Can be eaten by skeletons
#define FOOD_LACTOSE 32 //Contains MILK
/*
 *
 *
 * Logging define
 *
 *
 */
#define WARNING(MSG) world.log << "##WARNING: [MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr]."
#define warning(msg) world.log << "## WARNING: [msg]"
#define testing(msg) world.log << "## TESTING: [msg]"
#define log_game(text) diary << html_decode("\[[time_stamp()]]GAME: [text]")

#define log_vote(text) diary << html_decode("\[[time_stamp()]]VOTE: [text]")

#define log_access(text) diary << html_decode("\[[time_stamp()]]ACCESS: [text]")

#define log_say(text) diary << html_decode("\[[time_stamp()]]SAY: [text]")

#define log_ooc(text) diary << html_decode("\[[time_stamp()]]OOC: [text]")

#define log_whisper(text) diary << html_decode("\[[time_stamp()]]WHISPER: [text]")

#define log_cultspeak(text) diary << html_decode("\[[time_stamp()]]CULT: [text]")

#define log_narspeak(text) diary << html_decode("\[[time_stamp()]]NARSIE: [text]")

#define log_emote(text) diary << html_decode("\[[time_stamp()]]EMOTE: [text]")

#define log_attack(text) diaryofmeanpeople << html_decode("\[[time_stamp()]]ATTACK: [text]")

#define log_adminsay(text) diary << html_decode("\[[time_stamp()]]ADMINSAY: [text]")

#define log_adminwarn(text) diary << html_decode("\[[time_stamp()]]ADMINWARN: [text]")

#define log_pda(text) diary << html_decode("\[[time_stamp()]]PDA: [text]")

#define log_rc(text) diary << html_decode("\[[time_stamp()]]RC: [text]")

#define log_blobspeak(text) diary << html_decode("\[[time_stamp()]]BLOB: [text]")
#define log_blobtelepathy(text) diary << html_decode("\[[time_stamp()]]BLOBTELE: [text]")

//OOC isbanned
#define oocban_isbanned(key) oocban_keylist.Find("[ckey(key)]")

//message modes. you're not supposed to mess with these.
#define MODE_HEADSET "headset"
#define MODE_ROBOT "robot"
#define MODE_R_HAND "right hand"
#define MODE_L_HAND "left hand"
#define MODE_INTERCOM "intercom"
#define MODE_BINARY "binary"
#define MODE_WHISPER "whisper"
#define MODE_SECURE_HEADSET "secure headset"
#define MODE_DEPARTMENT "department"
#define MODE_ALIEN "alientalk"
#define MODE_HOLOPAD "holopad"
#define MODE_CHANGELING "changeling"
#define MODE_CULTCHAT "cultchat"
#define MODE_ANCIENT "ancientchat"
#define MODE_MUSHROOM "sporechat"
#define MODE_BORER "borerchat"

//Hardcore mode stuff

#define STARVATION_MIN 60 //If you have less nutrition than this value, the hunger indicator starts flashing

#define STARVATION_NOTICE 45 //If you have more nutrition than this value, you get an occasional message reminding you that you're going to starve soon

#define STARVATION_WEAKNESS 20 //Otherwise, if you have more nutrition than this value, you occasionally become weak and receive minor damage

#define STARVATION_NEARDEATH 5 //Otherwise, if you have more nutrition than this value, you have seizures and occasionally receive damage

//If you have less nutrition than STARVATION_NEARDEATH, you start getting damage

#define STARVATION_OXY_DAMAGE 2.5
#define STARVATION_TOX_DAMAGE 2.5
#define STARVATION_BRAIN_DAMAGE 2.5

#define STARVATION_OXY_HEAL_RATE 1 //While starving, THIS much oxygen damage is restored per life tick (instead of the default 5)

// Disposals destinations.

#define DISP_DISPOSALS      "Disposals"
#define DISP_CARGO_BAY      "Cargo Bay"
#define DISP_QM_OFFICE      "QM Office"
#define DISP_ENGINEERING    "Engineering"
#define DISP_CE_OFFICE      "CE Office"
#define DISP_ATMOSPHERICS   "Atmospherics"
#define DISP_SECURITY       "Security"
#define DISP_HOS_OFFICE     "HoS Office"
#define DISP_MEDBAY         "Medbay"
#define DISP_CMO_OFFICE     "CMO Office"
#define DISP_CHEMISTRY      "Chemistry"
#define DISP_RESEARCH       "Research"
#define DISP_RD_OFFICE      "RD Office"
#define DISP_ROBOTICS       "Robotics"
#define DISP_HOP_OFFICE     "HoP Office"
#define DISP_LIBRARY        "Library"
#define DISP_CHAPEL         "Chapel"
#define DISP_THEATRE        "Theatre"
#define DISP_BAR            "Bar"
#define DISP_KITCHEN        "Kitchen"
#define DISP_HYDROPONICS    "Hydroponics"
#define DISP_JANITOR_CLOSET "Janitor Closet"
#define DISP_GENETICS       "Genetics"
#define DISP_TELECOMMS      "Telecomms"
#define DISP_MECHANICS      "Mechanics"
#define DISP_TELESCIENCE    "Telescience"

//Human attack types
#define NORMAL_ATTACK 0
#define ATTACK_BITE 1
#define ATTACK_KICK 2

//Special attack returns (for procs like kick_act and bite_act)
#define SPECIAL_ATTACK_SUCCESS 0
#define SPECIAL_ATTACK_CANCEL 1 //Default return for the procs; cancel the special attack and perform a normal click instead
#define SPECIAL_ATTACK_FAILED 2

// Defines for the map writer, moved here for reasons.
#define DMM_IGNORE_AREAS 1
#define DMM_IGNORE_TURFS 2
#define DMM_IGNORE_OBJS 4
#define DMM_IGNORE_NPCS 8
#define DMM_IGNORE_PLAYERS 16
#define DMM_IGNORE_MOBS 24

//Cancer defines for the scanners
#define CANCER_STAGE_BENIGN 1 //Not 100 % medically correct, but we'll assume benign cancer never fails to worsen. No effect, but can be detected before it fucks you up. Instant
#define CANCER_STAGE_SMALL_TUMOR 300 //Cancer starts to have small effects depending on what the affected limb is, generally inconclusive ones. 5 minutes
#define CANCER_STAGE_LARGE_TUMOR 600 //Cancer starts to have serious effects depending on what the affected limb is, generally obvious one, up to visible tumor growth. 15 minutes
#define CANCER_STAGE_METASTASIS 1200 //Cancer has maximal effects, growing out of control in the organ, and can start "colonizing" other organs very quickly, dooming the patient. 30 minutes

#define EVENT_OBJECT_INDEX "o"
#define EVENT_PROC_INDEX "p"

#define BOMBERMAN "bomberman"

// /proc/is_honorable() flags.
#define HONORABLE_BOMBERMAN  1
#define HONORABLE_HIGHLANDER 2
#define HONORABLE_NINJA      4
#define HONORABLE_ALL        HONORABLE_BOMBERMAN|HONORABLE_HIGHLANDER|HONORABLE_NINJA

#define SPELL_ANIMATION_TTL 2 MINUTES

//Grasp indexes
#define GRASP_RIGHT_HAND 1
#define GRASP_LEFT_HAND 2

#define BLOB_CORE_PROPORTION 20

//Holomap filters
#define HOLOMAP_FILTER_DEATHSQUAD				1
#define HOLOMAP_FILTER_ERT						2
#define HOLOMAP_FILTER_NUKEOPS					4
#define HOLOMAP_FILTER_ELITESYNDICATE			8
#define HOLOMAP_FILTER_VOX						16
#define HOLOMAP_FILTER_STATIONMAP				32
#define HOLOMAP_FILTER_STATIONMAP_STRATEGIC		64//features markers over the captain's office, the armory, the SMES
#define HOLOMAP_FILTER_CULT						128//bloodstone locators

#define HOLOMAP_AREACOLOR_COMMAND		"#447FC299"
#define HOLOMAP_AREACOLOR_SECURITY		"#AE121299"
#define HOLOMAP_AREACOLOR_MEDICAL		"#35803099"
#define HOLOMAP_AREACOLOR_SCIENCE		"#A154A699"
#define HOLOMAP_AREACOLOR_ENGINEERING	"#F1C23199"
#define HOLOMAP_AREACOLOR_CARGO			"#E06F0099"
#define HOLOMAP_AREACOLOR_HALLWAYS		"#FFFFFF66"
#define HOLOMAP_AREACOLOR_ARRIVALS		"#0000FFCC"
#define HOLOMAP_AREACOLOR_ESCAPE		"#FF0000CC"

#define HOLOMAP_EXTRA_STATIONMAP				"stationmapformatted"
#define HOLOMAP_EXTRA_STATIONMAP_STRATEGIC		"stationmapstrategic"
#define HOLOMAP_EXTRA_STATIONMAPAREAS			"stationareas"
#define HOLOMAP_EXTRA_STATIONMAPSMALL_NORTH		"stationmapsmallnorth"
#define HOLOMAP_EXTRA_STATIONMAPSMALL_SOUTH		"stationmapsmallsouth"
#define HOLOMAP_EXTRA_STATIONMAPSMALL_EAST		"stationmapsmalleast"
#define HOLOMAP_EXTRA_STATIONMAPSMALL_WEST		"stationmapsmallwest"
#define HOLOMAP_EXTRA_CULTMAP					"cultmap"

#define HOLOMAP_MARKER_SMES				"smes"
#define HOLOMAP_MARKER_DISK				"diskspawn"
#define HOLOMAP_MARKER_SKIPJACK			"skipjack"
#define HOLOMAP_MARKER_SYNDISHUTTLE		"syndishuttle"
#define HOLOMAP_MARKER_BLOODSTONE		"bloodstone"
#define HOLOMAP_MARKER_BLOODSTONE_BROKEN	"bloodstone-broken"
#define HOLOMAP_MARKER_BLOODSTONE_ANCHOR	"bloodstone-narsie"
#define HOLOMAP_MARKER_CULT_ALTAR		"altar"
#define HOLOMAP_MARKER_CULT_FORGE		"forge"
#define HOLOMAP_MARKER_CULT_SPIRE		"spire"
#define HOLOMAP_MARKER_CULT_ENTRANCE	"path_entrance"
#define HOLOMAP_MARKER_CULT_EXIT		"path_exit"
#define HOLOMAP_MARKER_CULT_RUNE		"rune"

#define HOLOMAP_DRAW_NORMAL	0
#define HOLOMAP_DRAW_FULL	1
#define HOLOMAP_DRAW_EMPTY	2

#define DEFAULT_BLOOD "#A10808"
#define DEFAULT_FLESH "#FFC896"

//Return values for /obj/machinery/proc/npc_tamper_act(mob/living/L)
#define NPC_TAMPER_ACT_FORGET 1 //Don't try to tamper with this again
#define NPC_TAMPER_ACT_NOMSG  2 //Don't produce a visible message

//Changing the order of these needlessly will break functionality of the client holding lists
#define NO_ANIMATION 0
#define ITEM_ANIMATION 1
#define PERSON_ANIMATION 2

//For client preferences.
#define CREDITS_NEVER "Never"
#define CREDITS_ALWAYS "Always"
#define CREDITS_NO_RERUNS "No Reruns"
#define JINGLE_NEVER "Never"
#define JINGLE_CLASSIC "Classics"
#define JINGLE_ALL "All"

#define GOLEM_RESPAWN_TIME 10 MINUTES	//how much time must pass before someone who dies as an adamantine golem can use the golem rune again

#define BEESPECIES_NORMAL	"bees"
#define BEESPECIES_VOX		"chill bugs"
#define BEESPECIES_HORNET	"hornets"
#define BEESPECIES_BLOOD	"hell bugs"

//mob/proc/is_pacified()
#define VIOLENCE_SILENT		0
#define VIOLENCE_DEFAULT	1
#define VIOLENCE_GUN		2

// Used to determine which HUD is in use
#define HUD_NONE 0
#define HUD_MEDICAL 1
#define HUD_SECURITY 2

//Cyborg components
#define COMPONENT_BROKEN -1
#define COMPONENT_MISSING 0
#define COMPONENT_INSTALLED 1

//Glidesize
#define INERTIA_MOVEDELAY 5
#define FRACTIONAL_GLIDESIZES 1
#ifdef FRACTIONAL_GLIDESIZES
#define DELAY2GLIDESIZE(delay) (WORLD_ICON_SIZE / max(Ceiling(delay / world.tick_lag), 1))
#else
#define DELAY2GLIDESIZE(delay) (Ceiling(WORLD_ICON_SIZE / max(Ceiling(delay / world.tick_lag), 1)))
#endif

//Custom vending machines
#define CUSTOM_VENDING_MAX_SLOGAN_LENGTH	50
#define CUSTOM_VENDING_MAX_NAME_LENGTH	25
#define CUSTOM_VENDING_MAX_SLOGANS	5

#define MACHINE "machine"
#define COMPUTER "computer"
#define EMBEDDED_CONTROLLER "embedded controller"
#define OTHER "other"

// How many times to retry winset()ing window parameters before giving up
#define WINSET_MAX_ATTEMPTS 10

// E-Sports teams
#define ESPORTS_CULTISTS "Team Geometer"
#define ESPORTS_SECURITY "Team Security"

var/list/weekend_days = list("Friday", "Saturday", "Sunday")
#define IS_WEEKEND (weekend_days.Find(time2text(world.timeofday, "Day")))

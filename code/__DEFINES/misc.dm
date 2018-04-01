// Byond direction defines, because I want to put them somewhere.
// #define NORTH 1
// #define SOUTH 2
// #define EAST 4
// #define WEST 8

#define TEXT_NORTH			"[NORTH]"
#define TEXT_SOUTH			"[SOUTH]"
#define TEXT_EAST			"[EAST]"
#define TEXT_WEST			"[WEST]"

//These get to go at the top, because they're special
//You can use these defines to get the typepath of the currently running proc/verb (yes procs + verbs are objects)
/* eg:
/mob/living/carbon/human/death()
	to_chat(world, THIS_PROC_TYPE_STR) //You can only output the string versions
Will print: "/mob/living/carbon/human/death" (you can optionally embed it in a string with () (eg: the _WITH_ARGS defines) to make it look nicer)
*/
#define THIS_PROC_TYPE .....
#define THIS_PROC_TYPE_STR "[THIS_PROC_TYPE]" //Because you can only obtain a string of THIS_PROC_TYPE using "[]", and it's nice to just +/+= strings
#define THIS_PROC_TYPE_STR_WITH_ARGS "[THIS_PROC_TYPE]([args.Join(",")])"
#define THIS_PROC_TYPE_WEIRD ...... //This one is WEIRD, in some cases (When used in certain defines? (eg: ASSERT)) THIS_PROC_TYPE will fail to work, but THIS_PROC_TYPE_WEIRD will work instead
//define THIS_PROC_TYPE_WEIRD_STR "[THIS_PROC_TYPE_WEIRD]" //Included for completeness
//define THIS_PROC_TYPE_WEIRD_STR_WITH_ARGS "[THIS_PROC_TYPE_WEIRD]([args.Join(",")])" //Ditto

#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

#define JANUARY		1
#define FEBRUARY	2
#define MARCH		3
#define APRIL		4
#define MAY			5
#define JUNE		6
#define JULY		7
#define AUGUST		8
#define SEPTEMBER	9
#define OCTOBER		10
#define NOVEMBER	11
#define DECEMBER	12

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR				"New Year"
#define VALENTINES				"Valentine's Day"
#define APRIL_FOOLS				"April Fool's Day"
#define EASTER					"Easter"
#define HALLOWEEN				"Halloween"
#define CHRISTMAS				"Christmas"
#define FESTIVE_SEASON			"Festive Season"

//Human Overlays Indexes/////////
#define MUTATIONS_LAYER			26		//mutations. Tk headglows, cold resistance glow, etc
#define BODY_BEHIND_LAYER		25		//certain mutantrace features (tail when looking south) that must appear behind the body parts
#define BODYPARTS_LAYER			24		//Initially "AUGMENTS", this was repurposed to be a catch-all bodyparts flag
#define BODY_ADJ_LAYER			23		//certain mutantrace features (snout, body markings) that must appear above the body parts
#define BODY_LAYER				22		//underwear, undershirts, socks, eyes, lips(makeup)
#define FRONT_MUTATIONS_LAYER	21		//mutations that should appear above body, body_adj and bodyparts layer (e.g. laser eyes)
#define DAMAGE_LAYER			20		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			19
#define ID_LAYER				18
#define HANDS_PART_LAYER		18
#define GLOVES_LAYER			17
#define SHOES_LAYER				16
#define EARS_LAYER				15
#define SUIT_LAYER				14
#define GLASSES_LAYER			13
#define BELT_LAYER				12		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		11
#define NECK_LAYER				10
#define BACK_LAYER				9
#define HAIR_LAYER				8		//TODO: make part of head layer?
#define FACEMASK_LAYER			7
#define HEAD_LAYER				6
#define HANDCUFF_LAYER			5
#define LEGCUFF_LAYER			4
#define HANDS_LAYER				3
#define BODY_FRONT_LAYER		2
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			26		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;

//Human Overlay Index Shortcuts for alternate_worn_layer, layers
//Because I *KNOW* somebody will think layer+1 means "above"
//IT DOESN'T OK, IT MEANS "UNDER"
#define UNDER_SUIT_LAYER			SUIT_LAYER+1

//AND -1 MEANS "ABOVE", OK?, OK!?!
#define ABOVE_SHOES_LAYER			SHOES_LAYER-1
#define ABOVE_BODY_FRONT_LAYER		BODY_FRONT_LAYER-1


//Security levels
#define SEC_LEVEL_GREEN	0
#define SEC_LEVEL_BLUE	1
#define SEC_LEVEL_RED	2
#define SEC_LEVEL_DELTA	3

//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

// Cargo-related stuff.
#define MANIFEST_ERROR_CHANCE		5
#define MANIFEST_ERROR_NAME			1
#define MANIFEST_ERROR_CONTENTS		2
#define MANIFEST_ERROR_ITEM			4

#define TRANSITIONEDGE			7 //Distance from edge to move to another z-level

#define BE_CLOSE 1		//in the case of a silicon, to select if they need to be next to the atom
#define NO_DEXTERY 1	//if other mobs (monkeys, aliens, etc) can use this
//used by canUseTopic()

//singularity defines
#define STAGE_ONE 1
#define STAGE_TWO 3
#define STAGE_THREE 5
#define STAGE_FOUR 7
#define STAGE_FIVE 9
#define STAGE_SIX 11 //From supermatter shard

//SSticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

//FONTS:
// Used by Paper and PhotoCopier (and PaperBin once a year).
// Used by PDA's Notekeeper.
// Used by NewsCaster and NewsPaper.
// Used by Modular Computers
#define PEN_FONT "Verdana"
#define FOUNTAIN_PEN_FONT "Segoe Script"
#define CRAYON_FONT "Comic Sans MS"
#define PRINTER_FONT "Times New Roman"
#define SIGNFONT "Times New Roman"

#define RESIZE_DEFAULT_SIZE 1

//transfer_ai() defines. Main proc in ai_core.dm
#define AI_TRANS_TO_CARD	1 //Downloading AI to InteliCard.
#define AI_TRANS_FROM_CARD	2 //Uploading AI from InteliCard
#define AI_MECH_HACK		3 //Malfunctioning AI hijacking mecha

//check_target_facings() return defines
#define FACING_SAME_DIR											1
#define FACING_EACHOTHER										2
#define FACING_INIT_FACING_TARGET_TARGET_FACING_PERPENDICULAR	3 //Do I win the most informative but also most stupid define award?


//Cache of bloody footprint images
//Key:
//"entered-[blood_state]-[dir_of_image]"
//or: "exited-[blood_state]-[dir_of_image]"
GLOBAL_LIST_EMPTY(bloody_footprints_cache)

//Bloody shoes/footprints
#define MAX_SHOE_BLOODINESS			100
#define BLOODY_FOOTPRINT_BASE_ALPHA	150
#define BLOOD_GAIN_PER_STEP			100
#define BLOOD_LOSS_PER_STEP			5
#define BLOOD_LOSS_IN_SPREAD		20

//Bloody shoe blood states
#define BLOOD_STATE_HUMAN			"blood"
#define BLOOD_STATE_XENO			"xeno"
#define BLOOD_STATE_OIL				"oil"
#define BLOOD_STATE_NOT_BLOODY		"no blood whatsoever"

//suit sensors: sensor_mode defines

#define SENSOR_OFF 0
#define SENSOR_LIVING 1
#define SENSOR_VITALS 2
#define SENSOR_COORDS 3

//suit sensors: has_sensor defines

#define BROKEN_SENSORS -1
#define NO_SENSORS 0
#define HAS_SENSORS 1
#define LOCKED_SENSORS 2

//Wet floor type flags. Stronger ones should be higher in number.
#define TURF_DRY		0
#define TURF_WET_WATER	1
#define TURF_WET_PERMAFROST	2
#define TURF_WET_ICE 4
#define TURF_WET_LUBE	8

#define IS_WET_OPEN_TURF(O) O.GetComponent(/datum/component/wet_floor)

//Maximum amount of time, (in deciseconds) a tile can be wet for.
#define MAXIMUM_WET_TIME 5 MINUTES

//unmagic-strings for types of polls
#define POLLTYPE_OPTION		"OPTION"
#define POLLTYPE_TEXT		"TEXT"
#define POLLTYPE_RATING		"NUMVAL"
#define POLLTYPE_MULTI		"MULTICHOICE"
#define POLLTYPE_IRV		"IRV"



//subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

//Gets the turf this atom inhabits
#define get_turf(A) (get_step(A, 0))

//Ghost orbit types:
#define GHOST_ORBIT_CIRCLE		"circle"
#define GHOST_ORBIT_TRIANGLE	"triangle"
#define GHOST_ORBIT_HEXAGON		"hexagon"
#define GHOST_ORBIT_SQUARE		"square"
#define GHOST_ORBIT_PENTAGON	"pentagon"

//Ghost showing preferences:
#define GHOST_ACCS_NONE		1
#define GHOST_ACCS_DIR		50
#define GHOST_ACCS_FULL		100

#define GHOST_ACCS_NONE_NAME		"default sprites"
#define GHOST_ACCS_DIR_NAME			"only directional sprites"
#define GHOST_ACCS_FULL_NAME		"full accessories"

#define GHOST_ACCS_DEFAULT_OPTION	GHOST_ACCS_FULL

GLOBAL_LIST_INIT(ghost_accs_options, list(GHOST_ACCS_NONE, GHOST_ACCS_DIR, GHOST_ACCS_FULL)) //So save files can be sanitized properly.

#define GHOST_OTHERS_SIMPLE 			1
#define GHOST_OTHERS_DEFAULT_SPRITE		50
#define GHOST_OTHERS_THEIR_SETTING 		100

#define GHOST_OTHERS_SIMPLE_NAME 			"white ghost"
#define GHOST_OTHERS_DEFAULT_SPRITE_NAME 	"default sprites"
#define GHOST_OTHERS_THEIR_SETTING_NAME 	"their setting"

#define GHOST_OTHERS_DEFAULT_OPTION			GHOST_OTHERS_THEIR_SETTING

#define GHOST_MAX_VIEW_RANGE_DEFAULT 10
#define GHOST_MAX_VIEW_RANGE_MEMBER 14


GLOBAL_LIST_INIT(ghost_others_options, list(GHOST_OTHERS_SIMPLE, GHOST_OTHERS_DEFAULT_SPRITE, GHOST_OTHERS_THEIR_SETTING)) //Same as ghost_accs_options.

//pda fonts
#define MONO		"Monospaced"
#define VT			"VT323"
#define ORBITRON	"Orbitron"
#define SHARE		"Share Tech Mono"

//Color Defines
#define OOC_COLOR  "#002eb8"

/////////////////////////////////////
// atom.appearence_flags shortcuts //
/////////////////////////////////////

/*

// Disabling certain features
#define APPEARANCE_IGNORE_TRANSFORM			RESET_TRANSFORM
#define APPEARANCE_IGNORE_COLOUR			RESET_COLOR
#define	APPEARANCE_IGNORE_CLIENT_COLOUR		NO_CLIENT_COLOR
#define APPEARANCE_IGNORE_COLOURING			RESET_COLOR|NO_CLIENT_COLOR
#define APPEARANCE_IGNORE_ALPHA				RESET_ALPHA
#define APPEARANCE_NORMAL_GLIDE				~LONG_GLIDE

// Enabling certain features
#define APPEARANCE_CONSIDER_TRANSFORM		~RESET_TRANSFORM
#define APPEARANCE_CONSIDER_COLOUR			~RESET_COLOUR
#define APPEARANCE_CONSIDER_CLIENT_COLOUR	~NO_CLIENT_COLOR
#define APPEARANCE_CONSIDER_COLOURING		~RESET_COLOR|~NO_CLIENT_COLOR
#define APPEARANCE_CONSIDER_ALPHA			~RESET_ALPHA
#define APPEARANCE_LONG_GLIDE				LONG_GLIDE

*/

// Consider these images/atoms as part of the UI/HUD
#define APPEARANCE_UI_IGNORE_ALPHA			RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|RESET_ALPHA|PIXEL_SCALE
#define APPEARANCE_UI						RESET_COLOR|RESET_TRANSFORM|NO_CLIENT_COLOR|PIXEL_SCALE

//Just space
#define SPACE_ICON_STATE	"[((x + y) ^ ~(x * y) + z) % 25]"

// Maploader bounds indices
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

// Defib stats
#define DEFIB_TIME_LIMIT 120
#define DEFIB_TIME_LOSS 60

// Diagonal movement
#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

#define DEADCHAT_ARRIVALRATTLE "arrivalrattle"
#define DEADCHAT_DEATHRATTLE "deathrattle"
#define DEADCHAT_REGULAR "regular-deadchat"

// Bluespace shelter deploy checks
#define SHELTER_DEPLOY_ALLOWED "allowed"
#define SHELTER_DEPLOY_BAD_TURFS "bad turfs"
#define SHELTER_DEPLOY_BAD_AREA "bad area"
#define SHELTER_DEPLOY_ANCHORED_OBJECTS "anchored objects"

//debug printing macros
#define debug_world(msg) if (GLOB.Debug2) to_chat(world, "DEBUG: [msg]")
#define debug_usr(msg) if (GLOB.Debug2&&usr) to_chat(usr, "DEBUG: [msg]")
#define debug_admins(msg) if (GLOB.Debug2) to_chat(GLOB.admins, "DEBUG: [msg]")
#define debug_world_log(msg) if (GLOB.Debug2) log_world("DEBUG: [msg]")

#define INCREMENT_TALLY(L, stat) if(L[stat]){L[stat]++}else{L[stat] = 1}

//TODO Move to a pref
#define STATION_GOAL_BUDGET  1

//Luma coefficients suggested for HDTVs. If you change these, make sure they add up to 1.
#define LUMA_R 0.213
#define LUMA_G 0.715
#define LUMA_B 0.072

//different types of atom colorations
#define ADMIN_COLOUR_PRIORITY 		1 //only used by rare effects like greentext coloring mobs and when admins varedit color
#define TEMPORARY_COLOUR_PRIORITY 	2 //e.g. purple effect of the revenant on a mob, black effect when mob electrocuted
#define WASHABLE_COLOUR_PRIORITY 	3 //color splashed onto an atom (e.g. paint on turf)
#define FIXED_COLOUR_PRIORITY 		4 //color inherent to the atom (e.g. blob color)
#define COLOUR_PRIORITY_AMOUNT 4 //how many priority levels there are.

//Endgame Results
#define NUKE_NEAR_MISS 1
#define NUKE_MISS_STATION 2
#define NUKE_SYNDICATE_BASE 3
#define STATION_DESTROYED_NUKE 4
#define STATION_EVACUATED 5
#define BLOB_WIN 8
#define BLOB_NUKE 9
#define BLOB_DESTROYED 10
#define CULT_ESCAPE 11
#define CULT_FAILURE 12
#define CULT_SUMMON 13
#define NUKE_MISS 14
#define OPERATIVES_KILLED 15
#define OPERATIVE_SKIRMISH 16
#define REVS_WIN 17
#define REVS_LOSE 18
#define WIZARD_KILLED 19
#define STATION_NUKED 20
#define CLOCK_SUMMON 21
#define CLOCK_SILICONS 22
#define CLOCK_PROSELYTIZATION 23
#define SHUTTLE_HIJACK 24

#define FIELD_TURF 1
#define FIELD_EDGE 2

//gibtonite state defines
#define GIBTONITE_UNSTRUCK 0
#define GIBTONITE_ACTIVE 1
#define GIBTONITE_STABLE 2
#define GIBTONITE_DETONATE 3

//for obj explosion block calculation
#define EXPLOSION_BLOCK_PROC -1

//for determining which type of heartbeat sound is playing
#define BEAT_FAST 1
#define BEAT_SLOW 2
#define BEAT_NONE 0

//http://www.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
#define MOUSE_OPACITY_TRANSPARENT 0
#define MOUSE_OPACITY_ICON 1
#define MOUSE_OPACITY_OPAQUE 2

//world/proc/shelleo
#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

//server security mode
#define SECURITY_SAFE 1
#define SECURITY_ULTRASAFE 2
#define SECURITY_TRUSTED 3

//Dummy mob reserve slots
#define DUMMY_HUMAN_SLOT_PREFERENCES "dummy_preference_preview"
#define DUMMY_HUMAN_SLOT_ADMIN "admintools"
#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"

#define PR_ANNOUNCEMENTS_PER_ROUND 5 //The number of unique PR announcements allowed per round
									//This makes sure that a single person can only spam 3 reopens and 3 closes before being ignored

#define MAX_PROC_DEPTH 195 // 200 proc calls deep and shit breaks, this is a bit lower to give some safety room

#define DUMMY_HUMAN_SLOT_MANIFEST "dummy_manifest_generation"

#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

//gold slime core spawning
#define NO_SPAWN 0
#define HOSTILE_SPAWN 1
#define FRIENDLY_SPAWN 2

//slime core activation type
#define SLIME_ACTIVATE_MINOR 1
#define SLIME_ACTIVATE_MAJOR 2

#define LUMINESCENT_DEFAULT_GLOW 2

#define RIDING_OFFSET_ALL "ALL"

//stack recipe placement check types
#define STACK_CHECK_CARDINALS "cardinals" //checks if there is an object of the result type in any of the cardinal directions
#define STACK_CHECK_ADJACENT "adjacent" //checks if there is an object of the result type within one tile

//text files
#define BRAIN_DAMAGE_FILE "traumas.json"
#define ION_FILE "ion_laws.json"
#define PIRATE_NAMES_FILE "pirates.json"


//Fullscreen overlay resolution in tiles.
#define FULLSCREEN_OVERLAY_RESOLUTION_X 15
#define FULLSCREEN_OVERLAY_RESOLUTION_Y 15

#define SUMMON_GUNS "guns"
#define SUMMON_MAGIC "magic"

//Run the world with this parameter to enable a single run though of the game setup and tear down process with unit tests in between
#define TEST_RUN_PARAMETER "test-run"
//Force the log directory to be something specific in the data/logs folder
#define OVERRIDE_LOG_DIRECTORY_PARAMETER "log-directory"
//Prevent the master controller from starting automatically, overrides TEST_RUN_PARAMETER
#define NO_INIT_PARAMETER "no-init"

#define EGG_LAYING_MESSAGES list("lays an egg.","squats down and croons.","begins making a huge racket.","begins clucking raucously.")

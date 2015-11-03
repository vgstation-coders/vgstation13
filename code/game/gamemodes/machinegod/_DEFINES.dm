// Global variables.
/var/global/list/clockobelisks 		= list()
/var/global/list/tinkcaches			= list()
/var/global/list/clockcult_powers	= null // List of all power datums, initialized when the first slab gets New()'d.

/var/global/clockcult_TC = 0

// Component types, use these.
#define CLOCK_VANGUARD		"vanguard"
#define CLOCK_BELLIGERENT	"belligerent"
#define CLOCK_REPLICANT		"replicant"
#define CLOCK_HIEROPHANT	"hierophant"
#define CLOCK_GEIS			"geis"

/var/global/list/CLOCK_COMP_IDS = list(
	CLOCK_VANGUARD,
	CLOCK_BELLIGERENT,
	CLOCK_REPLICANT,
	CLOCK_HIEROPHANT,
	CLOCK_GEIS
)

/var/global/list/CLOCK_COMP_IDS_NAMES = list(
	CLOCK_VANGUARD		= "vanguard cogwheel",
	CLOCK_BELLIGERENT	= "belligerent eye",
	CLOCK_REPLICANT		= "replicant alloy",
	CLOCK_HIEROPHANT	= "hierophant ansible",
	CLOCK_GEIS			= "geis capacitor"
)

/var/global/list/CLOCK_COMP_NAMES_IDS = list(
	"vanguard cogwheel"		= CLOCK_VANGUARD,
	"belligerent eye"		= CLOCK_BELLIGERENT,
	"replicant alloy"		= CLOCK_REPLICANT,
	"hierophant ansible"	= CLOCK_HIEROPHANT,
	"geis capacitor"		= CLOCK_GEIS
)

/var/global/list/CLOCK_COMP_IDS_PATHS = list(
	CLOCK_VANGUARD		= /obj/item/clock_component/vanguard,
	CLOCK_BELLIGERENT	= /obj/item/clock_component/belligerent,
	CLOCK_REPLICANT		= /obj/item/clock_component/replicant,
	CLOCK_HIEROPHANT	= /obj/item/clock_component/hierophant,
	CLOCK_GEIS			= /obj/item/clock_component/geis
)

// Modified types, using these typepaths will make the component spawn with alpha = 0.
/var/global/list/CLOCK_COMP_IDS_PATHS_NO_ALPHA = list(
	CLOCK_VANGUARD		= /obj/item/clock_component/vanguard	{alpha = 0;},
	CLOCK_BELLIGERENT	= /obj/item/clock_component/belligerent	{alpha = 0;},
	CLOCK_REPLICANT		= /obj/item/clock_component/replicant	{alpha = 0;},
	CLOCK_HIEROPHANT	= /obj/item/clock_component/hierophant	{alpha = 0;},
	CLOCK_GEIS			= /obj/item/clock_component/geis		{alpha = 0;}
)

// Loudness
#define CLOCK_CALC			0
#define CLOCK_WHISPERED		1
#define CLOCK_SPOKEN		2
#define CLOCK_CHANTED		3

// Categories
#define CLOCK_DRIVER		1
#define CLOCK_SCRIPTS		2
#define CLOCK_APPLICATIONS	3
#define CLOCK_REVENANT		4
#define CLOCK_JUDGEMENT		5

// Slab production timings (in ticks from the obj process).
#define CLOCKSLAB_TICKS_UNTARGETED		90
#define CLOCKSLAB_TICKS_TARGETED		120

// Daemon production timings (in ticks from the obj process).
#define CLOCKDAEMON_TICKS_UNTARGETED	15
#define CLOCKDAEMON_TICKS_TARGETED		23 // Yes the design docs say 45 seconds, this is 46, but it's the only way to keep the code relatively simple.

// Slab defines
#define CLOCKSLAB_CAPACITY				10

#define CLOCKCACHE_CAPACITY				50


// POWER SPECIFIC DEFINES.
#define CLOCK_HIEROPHANT_DURATION		15 // Time the hierophant power lasts, note that this is in object process ticks (2 seconds per tick).

// Define for the language.
#define LANGUAGE_CLOCKCULT "Clockwork Cult"

#define CLOCK_JUDICIAL_VISOR_DELAY      2 MINUTES

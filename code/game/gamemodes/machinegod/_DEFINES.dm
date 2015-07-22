//Component types, use these.

#define CLOCK_VANGUARD		"vanguard"
#define CLOCK_BELLIGERENT	"belligerent"
#define CLOCK_REPLICANT		"replicant"
#define CLOCK_HIEROPHANT	"hierophant"
#define CLOCK_GEIS			"geis"

/var/const/list/CLOCK_COMP_IDS = list(
	CLOCK_VANGUARD,
	CLOCK_BELLIGERENT,
	CLOCK_REPLICANT,
	CLOCK_HIEROPHANT,
	CLOCK_GEIS
)

//Loudness
#define CLOCK_WHISPERED		1
#define CLOCK_SPOKEN		2
#define CLOCK_CHANTED		3

//Categories
#define CLOCK_DRIVER		1
#define CLOCK_SCRIPTS		2
#define CLOCK_APPLICATIONS	3
#define CLOCK_REVENANT		4
#define CLOCK_JUDGEMENT		5

//Slab production timings.
#define CLOCKSLAB_TICKS_UNTARGETED		90
#define CLOCKSLAB_TICKS_TARGETED		120

//Slab defines
#define CLOCKSLAB_CAPACITY				10

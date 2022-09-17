#define HIDES_IDENTITY_DEFAULT 0
#define HIDES_IDENTITY_ALWAYS 1
#define HIDES_IDENTITY_NEVER -1

//clothing flags
#define MASKINTERNALS           (1 << 0) // mask allows internals
#define NOSLIP				    (1 << 1) //prevents from slipping on wet floors, etc
#define BLOCK_GAS_SMOKE_EFFECT  (1 << 2) //blocks the effect that chemical clouds would have on a mob
#define ONESIZEFITSALL          (1 << 3)
#define PLASMAGUARD             (1 << 4) //Does not get contaminated by plasma.
#define BLOCK_BREATHING         (1 << 5) //When worn, prevents breathing!
#define GOLIATH_REINFORCEABLE   (1 << 6)
#define HIVELORD_REINFORCEABLE  (1 << 7)
#define BASILISK_REINFORCEABLE  (1 << 8)
#define CANEXTINGUISH 		    (1 << 9)
#define CONTAINPLASMAMAN        (1 << 10)
#define IGNORE_LUBE             (1 << 11)
#define MAGPULSE		        (1 << 12) //prevents slipping in space, singulo pulling, etc
#define GENDERFIT			    (1 << 13) //Toggles gender fitting so it appends _f for female mob icon.
#define COLORS_OVERLAY          (1 << 14)//if toggled on, the color variable will also modify the color of how it looks on the wearer

//clothing audible emote flags
#define CLOTHING_SOUND_SCREAM "scream"
#define CLOTHING_SOUND_COUGH "cough"

//clothing sound priority flags, if it's higher it will play first
#define CLOTHING_SOUND_LOW_PRIORITY 1
#define CLOTHING_SOUND_MED_PRIORITY 2
#define CLOTHING_SOUND_HIGH_PRIORITY 3

// Laser tag
#define LT_MODE_TEAM "team"
#define LT_MODE_FFA "free for all"
#define LT_FIREMODE_LASER "laser"
#define LT_FIREMODE_TASER "taser"

// voice changer

#define VOICE_CHANGER_SAYS "says"
#define VOICE_CHANGER_STATES "states"

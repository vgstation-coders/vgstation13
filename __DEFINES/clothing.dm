#define HIDES_IDENTITY_DEFAULT 0
#define HIDES_IDENTITY_ALWAYS 1


//clothing flags
#define MASKINTERNALS		1 // mask allows internals
#define NOSLIP				2 //prevents from slipping on wet floors, etc
#define BLOCK_GAS_SMOKE_EFFECT 4 //blocks the effect that chemical clouds would have on a mob
#define ONESIZEFITSALL		8
#define PLASMAGUARD 		16 //Does not get contaminated by plasma.
#define BLOCK_BREATHING 	32 //When worn, prevents breathing!
#define GOLIATHREINFORCE 	64
#define CANEXTINGUISH 		128
#define CONTAINPLASMAMAN 	256
#define IGNORE_LUBE			512
#define MAGPULSE			1024 //prevents slipping in space, singulo pulling, etc 
#define GENDERFIT			2048 //Toggles gender fitting so it appends _f for female mob icon.

//clothing audible emote flags
#define CLOTHING_SOUND_SCREAM "scream"
#define CLOTHING_SOUND_COUGH "cough"

//clothing sound priority flags, if it's higher it will play first
#define CLOTHING_SOUND_LOW_PRIORITY 1
#define CLOTHING_SOUND_MED_PRIORITY 2
#define CLOTHING_SOUND_HIGH_PRIORITY 3
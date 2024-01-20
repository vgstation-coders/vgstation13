/*		WIZARD SPELL FLAGS		*/
#define GHOSTCAST		1	//can a ghost cast it?
#define NEEDSCLOTHES	2	//does it need the wizard garb to cast? Nonwizard spells should not have this
#define NEEDSHUMAN		4	//does it require the caster to be human?
#define Z2NOCAST		8	//if this is added, the spell can't be cast at centcomm
#define STATALLOWED		16	//if set, the user doesn't have to be conscious to cast. Required for ghost spells
#define IGNOREPREV		32	//if set, each new target does not overlap with the previous one
//The following flags only affect different types of spell, and therefore overlap
//Targeted spells
#define INCLUDEUSER		64	//does the spell include the caster in its target selection?
#define SELECTABLE		128	//can you select each target for the spell?
//AOE spells
#define IGNOREDENSE		64	//are dense turfs ignored in selection?
#define IGNORESPACE		128	//are space turfs ignored in selection?
#define NODUPLICATE		256 //can we put the same summon type on the same tile?
//End split flags
#define CONSTRUCT_CHECK	512	//used by construct spells - checks for nullrods
#define NO_BUTTON		1024	//spell won't show up in the HUD with this
#define WAIT_FOR_CLICK	2048//spells wait for you to click on a target to cast
#define TALKED_BEFORE	4096//spells require you to have heard the person you are casting it upon
#define CAN_CHANNEL_RESTRAINED 8192 //channeled spells that you can cast despite having handcuffs on
#define LOSE_IN_TRANSFER 16384 //If your mind is transferred, you'll lose this spell.
#define IS_HARMFUL 32768	//For pacify checks to determine whether the spell can be cast
#define NO_TURNING 65536 //User does not turn around to face the target when using the spell

//invocation
#define SpI_SHOUT	"shout"
#define SpI_WHISPER	"whisper"
#define SpI_EMOTE	"emote"
#define SpI_NONE	"none"

//upgrading
#define Sp_SPEED	"cooldown"
#define Sp_POWER	"power"
#define Sp_MOVE		"mobility"
#define Sp_AMOUNT	"amount"
#define Sp_RANGE	"range"

#define Sp_TOTAL	"total"

//casting costs
#define Sp_RECHARGE	1
#define Sp_CHARGES	2
#define Sp_HOLDVAR	4
#define Sp_GRADUAL	8
#define Sp_PASSIVE 16

//spell range
#define SELFCAST -1
#define GLOBALCAST -2

//buying costs
#define Sp_BASE_PRICE 20

//Autocast flags
#define AUTOCAST_NOTARGET 1 //For spells with complex targeting (AI can't pick a target)

// For helpers
#define USER_TYPE_WIZARD "wiz"
#define USER_TYPE_MALFAI "malf"
#define USER_TYPE_CULT "cult"
#define USER_TYPE_GENETIC "genetic"
#define USER_TYPE_XENOMORPH "xeno"
#define USER_TYPE_ZOMBIE "zombie"
#define USER_TYPE_NOUSER "no_user"
#define USER_TYPE_OTHER "other"
#define USER_TYPE_SPELLBOOK "spellbook"
#define USER_TYPE_ARTIFACT "artifact"
#define USER_TYPE_VAMPIRE "vampire"
#define USER_TYPE_SPIDER "spider"
#define USER_TYPE_MECH "mech"
#define USER_TYPE_CHANGELING "changeling"
#define USER_TYPE_PULSEDEMON "pulsedemon"
#define USER_TYPE_GRUE "grue"
#define USER_TYPE_GYMRAT "gymrat"

//Spell aspect flags
#define SPELL_FIRE 1 //Fire based spells
#define SPELL_WATER 2 //Water/liquid based spells
#define SPELL_AIR 4 //Air based spells
#define SPELL_GROUND 8 //Earthen based spells
#define SPELL_NECROTIC 16 //Necromantic spells

//Spell specializations, used for spellbook lists
#define SPELL_SPECIALIZATION_OFFENSIVE 1
#define SPELL_SPECIALIZATION_DEFENSIVE 2
#define SPELL_SPECIALIZATION_UTILITY 4

#define SSOFFENSIVE SPELL_SPECIALIZATION_OFFENSIVE
#define SSDEFENSIVE SPELL_SPECIALIZATION_DEFENSIVE
#define SSUTILITY SPELL_SPECIALIZATION_UTILITY

//Telepathy specific flags
#define SPECIFIC_TELEPATHY 1
#define LOCAL_TELEPATHY 2
#define GLOBAL_TELEPATHY 4

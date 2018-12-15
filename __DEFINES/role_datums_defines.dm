// Dynamic Mode
#define CURRENT_LIVING_PLAYERS	"living"
#define CURRENT_LIVING_ANTAGS	"antags"
#define CURRENT_DEAD_PLAYERS	"dead"
#define CURRENT_OBSERVERS	"observers"

// Faction IDs
#define BLOODCULT "cult of Nar-Sie"
#define REVOLUTION "revolution"
#define ERT "emergency response team"
#define DEATHSQUAD "Nanotrasen deathsquad"
#define SYNDICATE "syndicate"
#define SYNDITRAITORS "syndicate agents"
#define SYNDIOPS "syndicate operatives"
#define SYNDIESQUAD "syndicate elite strike team"
#define CUSTOMSQUAD "custom squad"
#define VOXSHOAL "vox Shoal"
#define BLOBCONGLOMERATE "blob conglomerate"
#define CLOCKWORK "clockwork"
//-------
#define HIVEMIND "changeling hivemind"
#define WIZFEDERATION "wizard federation"
#define VAMPIRELORDS "vampire lords"
#define CULT "generic cult"
#define LEGACY_CULT "Ancient Cult of Nar-Sie"
#define GREYTIDE_FAC "Greytide mindlink"
// Role IDs
#define TRAITOR "traitor"
#define ROGUE "rogue agent"//double agents
#define CHANGELING "changeling"
#define VAMPIRE "vampire"
#define WIZARD "wizard"
#define CULTIST "cultist"
#define LEGACY_CULTIST "legacy cultist"
#define NUKE_OP "nuclear operative"
#define HEADREV "head revolutionary"
#define REV "revolutionary"
#define WIZAPP "wizard's apprentice"
#define MADMONKEY "monkey fever infected"
#define WISHGRANTERAVATAR "avatar of the Wish Granter"
#define HIGHLANDER "highlander"
#define DEATHSQUADIE "death commando"
#define SYNDIESQUADIE "syndicate commando"
#define RESPONDER "emergency responder"
#define MALF "malfunctioning AI"
#define VOXRAIDER "vox raider"
#define BLOBOVERMIND "blob overmind"
#define HIGHLANDER "highlander"
#define IMPLANTSLAVE "Greytider"
#define SURVIVOR "Survivor"
#define CRUSADER "Crusader"
#define MAGICIAN "Magician"
#define IMPLANTLEADER "Grey Leader"
#define CLOCKWORK_GRAVEKEEPER "clockwork gravekeeper"

#define GREET_DEFAULT		"default"
#define GREET_ROUNDSTART	"roundstart"
#define GREET_LATEJOIN		"latejoin"
#define GREET_ADMINTOGGLE	"admintoggle"
#define GREET_CUSTOM		"custom"
#define GREET_MIDROUND		"midround"
#define GREET_MASTER		"master"

#define GREET_AUTOTATOR		"autotator"

#define GREET_CONVERTED		"converted"
#define GREET_PAMPHLET		"pamphlet"
#define GREET_SOULSTONE		"soulstone"
#define GREET_SOULBLADE		"soulblade"
#define GREET_RESURRECT		"resurrect"


//////////////////////////////////CULT STUFF////////////////////////////////////
#define CULT_MENDED		-1
#define CULT_PROLOGUE	0
#define CULT_ACT_I		1
#define CULT_ACT_II		2
#define CULT_ACT_III	3
#define CULT_ACT_IV		4
#define CULT_EPILOGUE	5

#define BLOODCOST_TARGET_BLEEDER	"bleeder"
#define BLOODCOST_AMOUNT_BLEEDER	"bleeder_amount"
#define BLOODCOST_TARGET_GRAB	"grabbed"
#define BLOODCOST_AMOUNT_GRAB	"grabbed_amount"
#define BLOODCOST_TARGET_HANDS	"hands"
#define BLOODCOST_AMOUNT_HANDS	"hands_amount"
#define BLOODCOST_TARGET_HELD	"held"
#define BLOODCOST_AMOUNT_HELD	"held_amount"
#define BLOODCOST_LID_HELD		"held_lid"
#define BLOODCOST_TARGET_SPLATTER	"splatter"
#define BLOODCOST_AMOUNT_SPLATTER	"splatter_amount"
#define BLOODCOST_TARGET_BLOODPACK	"bloodpack"
#define BLOODCOST_AMOUNT_BLOODPACK	"bloodpack_amount"
#define BLOODCOST_HOLES_BLOODPACK	"bloodpack_noholes"
#define BLOODCOST_TARGET_CONTAINER	"container"
#define BLOODCOST_AMOUNT_CONTAINER	"container_amount"
#define BLOODCOST_LID_CONTAINER	"container_lid"
#define BLOODCOST_TARGET_USER	"user"
#define BLOODCOST_AMOUNT_USER	"user_amount"
#define BLOODCOST_TOTAL		"total"
#define BLOODCOST_RESULT	"result"
#define BLOODCOST_FAILURE	"failure"

#define RITUALABORT_ERASED	"erased"
#define RITUALABORT_STAND	"too far"
#define RITUALABORT_GONE	"moved away"
#define RITUALABORT_BLOCKED	"blocked"
#define RITUALABORT_BLOOD	"channel cancel"
#define RITUALABORT_TOOLS	"moved talisman"
#define RITUALABORT_REMOVED	"victim removed"
#define RITUALABORT_CONVERT	"convert success"
#define RITUALABORT_SACRIFICE	"convert failure"
#define RITUALABORT_FULL	"no room"
#define RITUALABORT_CONCEAL	"conceal"
#define RITUALABORT_NEAR	"near"
#define RITUALABORT_MISSING	"missing"
#define RITUALABORT_OUTPOST "outpost"

#define TATTOO_POOL		"Blood Communion"
#define TATTOO_SILENT	"Silent Casting"
#define TATTOO_DAGGER	"Blood Dagger"
#define TATTOO_HOLY		"Unholy Protection"
#define TATTOO_FAST		"Rapid Tracing"
#define TATTOO_CHAT		"Dark Communication"
#define TATTOO_MANIFEST	"Pale Body"
#define TATTOO_MEMORIZE	"Arcane Knowledge"
#define TATTOO_SHORTCUT	"Shortcut Tracer"

#define	TOME_CLOSED	1
#define	TOME_OPEN	2

#define	RUNE_CAN_ATTUNE	0
#define	RUNE_CAN_IMBUE	1
#define	RUNE_CANNOT		2

#define	MAX_TALISMAN_PER_TOME	5

#define SACRIFICE_CHANGE_COOLDOWN	30 MINUTES

#define CONVERSION_REFUSE	-1
#define CONVERSION_NOCHOICE	0
#define CONVERSION_ACCEPT	1

////////////////////////////////////////////////////////////////////////////////

// -- Objectives flags

#define FACTION_OBJECTIVE 1

// -- Cult 2.0 states
#define CULT_PRELUDE 		0 // First objective
#define CULT_INTERMEDIATE	1 // Second (objective)
#define CULT_SUMMON 		2 // Summon objective
#define CULT_FINALE			3 // Nar-Sie cometh

#define BE_TRAITOR "Be_Traitor"
#define BE_PAI "Be_PAI"
#define BE_NINJA "Be_Ninja"


#define FROM_GHOSTS 1
#define FROM_PLAYERS 2

#define PROTECTED_TRAITOR_PROB 66 // Probability than a protected role is rejected from the candidate list

#define ADD_REVOLUTIONARY_FAIL_IS_COMMAND -1
#define ADD_REVOLUTIONARY_FAIL_IS_JOBBANNED -2
#define ADD_REVOLUTIONARY_FAIL_IS_IMPLANTED -3
#define ADD_REVOLUTIONARY_FAIL_IS_REV -4

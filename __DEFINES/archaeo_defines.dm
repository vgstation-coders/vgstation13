#define ARCHAEO_BOWL "bowl"
#define ARCHAEO_URN "urn"
#define ARCHAEO_CUTLERY "cutlery"
#define ARCHAEO_STATUETTE "statuette"
#define ARCHAEO_INSTRUMENT "instrument"
#define ARCHAEO_KNIFE "knife"
#define ARCHAEO_RITUALKNIFE "ritualknife"
#define ARCHAEO_COIN "coin"
#define ARCHAEO_HANDCUFFS "handcuffs"
#define ARCHAEO_BEARTRAP "beartrap"
#define ARCHAEO_LIGHTER "lighter"
#define ARCHAEO_BOX "box"
#define ARCHAEO_GASTANK "gastank"
#define ARCHAEO_TOOL "tool"
#define ARCHAEO_METAL "metal"
#define ARCHAEO_PEN "pen"
#define ARCHAEO_CRYSTAL "smallcrystal"
#define ARCHAEO_CULTBLADE "cultblade"
#define ARCHAEO_TELEBEACON "telebeacon"
#define ARCHAEO_CLAYMORE "claymore"
#define ARCHAEO_CULTROBES "cultrobes"
#define ARCHAEO_SOULSTONE "soulstone"
#define ARCHAEO_SHARD "shard"
#define ARCHAEO_RODS "rods"
#define ARCHAEO_STOCKPARTS "stockparts"
#define ARCHAEO_KATANA "katana"
#define ARCHAEO_LASER "laser"
#define ARCHAEO_GUN "gun"
#define ARCHAEO_UNKNOWN "unknown"
#define ARCHAEO_FOSSIL "fossil"
#define ARCHAEO_SHELL "shell"
#define ARCHAEO_PLANT "plant"
#define ARCHAEO_EGG "egg"
#define ARCHAEO_REMAINS_HUMANOID "remains_humanoid"
#define ARCHAEO_REMAINS_ROBOT "remains_robot"
#define ARCHAEO_REMAINS_XENO "remains_xeno"
#define ARCHAEO_MASK "mask"
#define ARCHAEO_DICE "dice"
#define ARCHAEO_SPACESUIT "spacesuit"
#define ARCHAEO_EXCASUIT "excasuit"
#define ARCHAEO_ANOMSUIT "anomsuit"
#define ARCHAEO_LANCE "lance"
#define ARCHAEO_ROULETTE "roulette"
#define ARCHAEO_ROBOT "robot"
#define ARCHAEO_SASH "sash"
#define ARCHAEO_TOY "toy"
#define ARCHAEO_LARGE_CRYSTAL "largecrystal"
#define ARCHAEO_CHAOS "chaos"
#define ARCHAEO_GUITAR "guitar"
#define ARCHAEO_SUPERSHARD "supermatter shard"
#define ARCHAEO_TOYBOX "mechanical toybox"
#define ARCHAEO_POCKETWATCH "pocketwatch"
#define ARCHAEO_MIRROR "pocket mirror"

#define DIGSITE_GARDEN "garden"
#define DIGSITE_ANIMAL "animal"
#define DIGSITE_HOUSE "house"
#define DIGSITE_TECHNICAL "technical"
#define DIGSITE_TEMPLE "temple"
#define DIGSITE_WAR "war"

#define ARTIFACT_EFFECT_TOUCH 0
#define ARTIFACT_EFFECT_AURA 1
#define ARTIFACT_EFFECT_PULSE 2

#define ARTIFACT_STYLE_ANOMALY "ano"
#define ARTIFACT_STYLE_ANCIENT "ancient"
#define ARTIFACT_STYLE_MARTIAN "martian"
#define ARTIFACT_STYLE_WIZARD "wizard"
#define ARTIFACT_STYLE_ELDRITCH "eldritch"
#define ARTIFACT_STYLE_PRECURSOR "precursor"
#define ARTIFACT_STYLE_UNKNOWN "unknown"
#define ARTIFACT_STYLE_RELIQUARY "reliquary"

var/list/goon_style_effect_types = list(
	ARTIFACT_STYLE_ANCIENT = 7,
	ARTIFACT_STYLE_MARTIAN = 7,
	ARTIFACT_STYLE_WIZARD = 7,
	ARTIFACT_STYLE_ELDRITCH = 7,
	ARTIFACT_STYLE_PRECURSOR = 7,
	ARTIFACT_STYLE_UNKNOWN = 1,
	ARTIFACT_STYLE_RELIQUARY = 4
	)

var/list/vg_style_effect_types = list(
	ARTIFACT_STYLE_ANOMALY = 12
	)

var/list/all_artifact_style_effect_types = vg_style_effect_types + goon_style_effect_types
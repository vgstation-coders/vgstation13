
//eggs
//droppings
//footprints
//alien clothing

//DNA sampling from fossils, or a new archaeo type specifically for it?

//descending order of likeliness to spawn
#define DIGSITE_GARDEN 1
#define DIGSITE_ANIMAL 2
#define DIGSITE_HOUSE 3
#define DIGSITE_TECHNICAL 4
#define DIGSITE_TEMPLE 5
#define DIGSITE_WAR 6

/proc/get_responsive_reagent(var/find_type)
	switch(find_type)
		if(ARCHAEO_BOWL)
			return "mercury"
		if(ARCHAEO_URN)
			return "mercury"
		if(ARCHAEO_CUTLERY)
			return "mercury"
		if(ARCHAEO_STATUETTE)
			return "mercury"
		if(ARCHAEO_INSTRUMENT)
			return "mercury"
		if(ARCHAEO_COIN)
			return "iron"
		if(ARCHAEO_KNIFE)
			return "iron"
		if(ARCHAEO_HANDCUFFS)
			return "mercury"
		if(ARCHAEO_BEARTRAP)
			return "mercury"
		if(ARCHAEO_LIGHTER)
			return "mercury"
		if(ARCHAEO_BOX)
			return "mercury"
		if(ARCHAEO_GASTANK)
			return "mercury"
		if(ARCHAEO_TOOL)
			return "iron"
		if(ARCHAEO_METAL)
			return "iron"
		if(ARCHAEO_PEN)
			return "mercury"
		if(ARCHAEO_CRYSTAL)
			return "nitrogen"
		if(ARCHAEO_CULTBLADE)
			return "potassium"
		if(ARCHAEO_TELEBEACON)
			return "potassium"
		if(ARCHAEO_CLAYMORE)
			return "iron"
		if(ARCHAEO_CULTROBES)
			return "potassium"
		if(ARCHAEO_SOULSTONE)
			return "nitrogen"
		if(ARCHAEO_SHARD)
			return "nitrogen"
		if(ARCHAEO_RODS)
			return "iron"
		if(ARCHAEO_STOCKPARTS)
			return "potassium"
		if(ARCHAEO_KATANA)
			return "iron"
		if(ARCHAEO_LASER)
			return "iron"
		if(ARCHAEO_GUN)
			return "iron"
		if(ARCHAEO_UNKNOWN)
			return "mercury"
		if(ARCHAEO_FOSSIL)
			return "carbon"
		if(ARCHAEO_SHELL)
			return "carbon"
		if(ARCHAEO_PLANT)
			return "carbon"
		if(ARCHAEO_REMAINS_HUMANOID)
			return "carbon"
		if(ARCHAEO_REMAINS_XENO)
			return "carbon"
		if(ARCHAEO_MASK)
			return "mercury"
		if(ARCHAEO_DICE)
			return "mercury"
		if(ARCHAEO_SPACESUIT)
			return "potassium"
		if(ARCHAEO_LANCE)
			return "iron"
		if(ARCHAEO_REMAINS_ROBOT)
			return "iron"
		if(ARCHAEO_ROBOT)
			return "iron"
	return "plasma"

//see /turf/unsimulated/mineral/New() in code/modules/mining/mine_turfs.dm
/proc/get_random_digsite_type()
	return pick(100;DIGSITE_GARDEN,95;DIGSITE_ANIMAL,90;DIGSITE_HOUSE,85;DIGSITE_TECHNICAL,80;DIGSITE_TEMPLE,75;DIGSITE_WAR)

/proc/get_random_find_type(var/digsite)


	var/find_type = 0
	switch(digsite)
		if(DIGSITE_GARDEN)
			find_type = pick(\
			100;ARCHAEO_PLANT,\
			25;ARCHAEO_SHELL,\
			25;ARCHAEO_FOSSIL,\
			5;ARCHAEO_REMAINS_XENO,\
			5;ARCHAEO_BEARTRAP\
			)
		if(DIGSITE_ANIMAL)
			find_type = pick(\
			100;ARCHAEO_FOSSIL,\
			50;ARCHAEO_SHELL,\
			50;ARCHAEO_PLANT,\
			25;ARCHAEO_BEARTRAP,\
			5;ARCHAEO_REMAINS_XENO\
			)
		if(DIGSITE_HOUSE)
			find_type = pick(\
			100;ARCHAEO_BOWL,\
			100;ARCHAEO_URN,\
			100;ARCHAEO_CUTLERY,\
			100;ARCHAEO_STATUETTE,\
			100;ARCHAEO_INSTRUMENT,\
			100;ARCHAEO_PEN,\
			100;ARCHAEO_LIGHTER,\
			100;ARCHAEO_BOX,\
			75;ARCHAEO_DICE,\
			75;ARCHAEO_COIN,\
			75;ARCHAEO_UNKNOWN,\
			50;ARCHAEO_SHARD,\
			50;ARCHAEO_RODS,\
			25;ARCHAEO_METAL,\
			5;ARCHAEO_REMAINS_HUMANOID\
			)
		if(DIGSITE_TECHNICAL)
			find_type = pick(\
			100;ARCHAEO_METAL,\
			100;ARCHAEO_GASTANK,\
			100;ARCHAEO_TELEBEACON,\
			100;ARCHAEO_TOOL,\
			100;ARCHAEO_STOCKPARTS,\
			75;ARCHAEO_SHARD,\
			75;ARCHAEO_RODS,\
			75;ARCHAEO_UNKNOWN,\
			50;ARCHAEO_HANDCUFFS,\
			50;ARCHAEO_BEARTRAP,\
			25;ARCHAEO_SPACESUIT,\
			10;ARCHAEO_ROBOT,\
			5;ARCHAEO_REMAINS_ROBOT\
			)
		if(DIGSITE_TEMPLE)
			find_type = pick(\
			200;ARCHAEO_CULTROBES,\
			100;ARCHAEO_URN,\
			100;ARCHAEO_BOWL,\
			100;ARCHAEO_KNIFE,\
			100;ARCHAEO_CRYSTAL,\
			75;ARCHAEO_MASK,\
			75;ARCHAEO_CULTBLADE,\
			50;ARCHAEO_SOULSTONE,\
			50;ARCHAEO_UNKNOWN,\
			25;ARCHAEO_HANDCUFFS,\
			25;ARCHAEO_BEARTRAP,\
			10;ARCHAEO_KATANA,\
			10;ARCHAEO_CLAYMORE,\
			10;ARCHAEO_SHARD,\
			10;ARCHAEO_RODS,\
			10;ARCHAEO_METAL\
			)
		if(DIGSITE_WAR)
			find_type = pick(\
			100;ARCHAEO_GUN,\
			100;ARCHAEO_KNIFE,\
			75;ARCHAEO_LASER,\
			75;ARCHAEO_KATANA,\
			75;ARCHAEO_CLAYMORE,\
			75;ARCHAEO_LANCE,\
			50;ARCHAEO_UNKNOWN,\
			50;ARCHAEO_CULTROBES,\
			50;ARCHAEO_CULTBLADE,\
			25;ARCHAEO_HANDCUFFS,\
			25;ARCHAEO_BEARTRAP,\
			25;ARCHAEO_TOOL,\
			10;ARCHAEO_ROBOT,\
			5;ARCHAEO_REMAINS_ROBOT\
			)
	return find_type

var/list/responsive_carriers = list( \
	"carbon", \
	"potassium", \
	"hydrogen", \
	"nitrogen", \
	"mercury", \
	"iron", \
	"chlorine", \
	"phosphorus", \
	"plasma")

var/list/finds_as_strings = list( \
	"Trace organic cells", \
	"Long exposure particles", \
	"Trace water particles", \
	"Crystalline structures", \
	"Metallic derivative", \
	"Metallic composite", \
	"Metamorphic/igneous rock composite", \
	"Metamorphic/sedimentary rock composite", \
	"Anomalous material" )

#undef DIGSITE_GARDEN
#undef DIGSITE_ANIMAL
#undef DIGSITE_HOUSE
#undef DIGSITE_TECHNICAL
#undef DIGSITE_TEMPLE
#undef DIGSITE_WAR

#define MOBFISHCATCH = 1
#define ITEMFISHCATCH = 2
#define SALVAGECATCH = 3

#define METALMAG = 4
#define FLEXMAG = 5		//Changes according to the salvage group's magnetism

datum/anglerCatch
var/theCatch = null	//What we're actually catching
var/typeOfCatch = 0	//Tells it what calcs to go through, itemfish don't get mutations for example
var/baseChance = 100	//Chance of being caught without bait or Z level modifiers. 100 base for flexibility.
var/portionConsume = 0	//How much bait the catch consumes
var/list/zLevelWeight = list(	//Set to 0 to make a catch not appear on a Z level. Higher relative to others = more common on that Z
	STATION_Z = 1,	//Acts as a multiplier on base catch chance. 0 cannot be caught on that Z, 1 is just base chance, etc
	CENTCOMM_Z = 1,
	TELECOMM_Z = 1,
	DERELICT_Z = 1,
	ASTEROID_Z = 1,
	SPACEPIRATE_Z = 1
)

datum/anglerCatch/proc/analyzerDescription()
	return "It sure is a fish."

datum/anglerCatch/proc/catchFailureCond(var/obj/item/weapon/bait/baitUsed)
	return TRUE //Returning false skips adding something to the pool of possible catches.

datum/anglerCatch/proc/specCatchMod(var/obj/item/weapon/bait/baitUsed)
	return 0	//For adding special conditions to the chance of catching something like time of day or threat.

datum/anglerCatch/proc/decideMutation(var/obj/item/weapon/bait/baitUsed)

datum/anglerCatch/proc/specialEffects(var/obj/item/weapon/bait/baitUsed)


datum/anglerCatch/salvage/salvGroup
	var/associatedVault = null
	var/spawnCost = 10
	var/uniqueSpawn = FALSE		//If the group can only spawn once per Z
	var/list/groupedSalvage = list()

datum/anglerCatch/salvage/salvGroup/proc/specGroupMod(var/datum/anglerCatch/salvage/S)
	return S

datum/anglerCatch/salvage
	var/typeOfMagnetism = NOMAG		//Uses NOMAG, NORTHMAG, and SOUTHMAG defines from bait.dm. Affects certain salvage catches. If the salvage is north charged then north mag will repel, south will attract, vice versa. Metalmag is attracted to both poles.


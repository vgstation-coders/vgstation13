#define NOMAG 0
#define NORTHMAG 1
#define SOUTHMAG 2

/obj/item/weapon/bait/custom

/datum/bait
	var/catchPower = 0	//Increases favored list chances. Generic "good points" for many item fish
	var/catchAttraction = 0	//How quickly it catches something, just a higher chance of a catch each tick
	var/catchSizeAdd = 0	//Additive to catch size.
	var/catchSizeMult = 1	//Catch size multiplier. More universal than add. 1.1 would just be 10% larger.
	var/portionSize = 1	//Amount of uses the bait has
	var/salvageAttraction = 0 //How likely it is to catch salvage. Is weighed against catchAttraction to decide which is caught.
	var/magnetPole = NOMAG //North and south attract metal catches. Magnetic catches have like repel like, unlike is extra attracted to each other.

	var/list/favoredMutations = list()	//A list of mutations with individually tweakable values. Generally for mutations the bait is more likely to produce.
	var/list/exclusiveMutations = list()	//The bait can only catch these mutations, will ignore others. Leave empty to keep it unrestricted.
	var/list/rejectedMutations = list() //Can't mutate into anything on this list.
	var/list/favoredSpecies = list()	//Like favoredMutations but for species.
	var/list/exclusiveSpecies = list()	//Like exclusiveMutations but for species
	var/list/rejectedSpecies = list() //Can't catch anything on this list.

/datum/bait/recalculateValue()
	var/powMod = catchPower*0.1 + 1
	for(var/fS in favoredSpecies)
		favoredSpecies[fS] *= powMod
	for(var/fM in favoredMutations)
		favoredMutations[fM] *= powMod

/datum/bait/proc/baitOnMobCatch(var/mob/living/simple_animal/hostile/fishing/theFish)
	theFish.catchSize += catchSizeAdd
	theFish.catchSize *= catchSizeMult

/datum/bait/proc/specCatchModifier(var/cChance)
	return cChance	//For bait with special properties BYOND what it can normally do

/datum/bait/proc/specMutModifier(var/mChance)
	return mChance	//Like speccatchmodifier but for mutations

/datum/bait/proc/catchChance()
	return min(catchAttraction, 100)

/datum/bait/proc/analyzerDescription()
	return "The bait doesn't seem to have any unusual properties."

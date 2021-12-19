#define SALV_MAGNET_BONUS 75

proc/anglerProcessCatch(var/obj/item/weapon/bait/baitUsed, var/hookOnZ)
	var/datum/anglerCatch/theCatch = anglerCatchChance(baitUsed)
	if(!theCatch)
		return FALSE
	switch(theCatch.typeOfCatch)
		if(MOBFISHCATCH)
			catchMobFish(theCatch, baitUsed)
		if(ITEMFISHCATCH)
			catchItemFish(theCatch, baitUsed)
		if(SALVAGECATCH)
			catchSalvage(theCatch, baitUsed)

proc/anglerCatchChance(var/fishChance, var/salvChance, var/hookOnZ)
	if(prob(baitUsed.catchAttraction))	//Fish get priority because they're actively seeking bait
		var/fishCatch = anglerFishCalc(baitUsed)
		return fishCatch
	if(prob(baitUsed.salvageAttraction))
		var/salvCatch = anglerSalvCalc(baitUsed)
		return salvCatch
	return 0

//Calculating which catch, both mobs and fish-themed items.

proc/anglerFishCalc(baitUsed, hookOnZ)
	var/list/catchPool = anglerPossibleFish(baitUsed)
	var/theCatch = pickweight(catchPool)
	return theCatch

proc/anglerPossibleFish(baitUsed, hookOnZ)
	var/list/possibleCatch = list()
	if(baitUsed.exclusiveSpecies.len)
		for(var/datum/anglerCatch/fish/AC in baitUsed.exclusiveSpecies)
			var/cChance = anglerCatchModifiers()
			possibleCatch += list(AC[cChance])
		return possibleCatch
	for(var/datum/anglerCatch/fish/AC in subtypesof(datum/anglerCatch/fish))
		if(AC in baitUsed.rejectedSpecies)
			continue
		if(!AC.catchFailureCond(baitUsed))
			continue
		var/cChance = anglerCatchModifiers(baitUsed, hookOnZ)
		possibleCatch += list(AC[cChance])
	return possibleCatch

proc/anglerCatchModifiers(baitUsed, AC, hookOnZ)
	var/theChance = AC.baseChance
	theChance *= baitUsed.zLevelWeight[hookOnZ]
	theChance += baitUsed.favoredSpecies[AC]
	theChance = baitUsed.specCatchModifier(theChance)	//By default returns itself, for special bait
	theChance = AC.specCatchMod(theChance, baitUsed)	//Like above but for the catch itself, overwrites above in most cases by intention
	return theChance

//Calculating salvage

proc/anglerSalvCalc(var/obj/item/weapon/bait/baitUsed, var/hookOnZ)
	zSalvCheck(hookOnZ)
	var/salvZ = salvAssociateZ(hookOnZ)
	var/caughtSalv = (baitUsed, salvZ)

proc/salvAssociateZ(hookOnZ)
	for(var/datum/zLevelSalvage/sZ in zSalvageMaster)
		if(hookOnZ == sZ.linkedZ)
			return sZ

proc/pickMagSalv(baitUsed, salvZ)
	var/theSalv = null
	if(baitUsed.magnetPole == NORTHMAG)
		if(prob(SALV_MAGNET_BONUS + baitUsed.salvageAttraction))
			theSalv = pick_n_take(salvZ.southSalvage)
		else
			theSalv = pick_n_take(salvZ.noMagSalvage)
	if(baitUsed.magnetPole == SOUTHMAG)
		if(prob(SALV_MAGNET_BONUS + baitUsed.salvageAttraction))
			theSalv = pick_n_take(salvZ.northSalvage)
		else
			theSalv = pick_n_take(salvZ.noMagSalvage)
	if(baitUsed.magnetPole == NOMAG)
		theSalv = pick(salvZ.noMagSalvage, salvZ.northSalvage, salvZ.southSalvage)
		theSalv = pick_n_take(theSalv)
	return theSalv



/obj/proc/angler_effect(var/obj/item/weapon/bait/baitUsed)
	return


//Catching procs

proc/catchMobFish(theCatch, baitUsed)
	var/mob/living/simple_animal/hostile/fishing/theFish = theCatch
	baitUsed.baitOnMobCatch(theFish)
	angler_mutateDecide(theFish, baitUsed)

proc/catchItemFish(theCatch, baitUsed)
	var/obj/theFish = new theCatch.theCatch
	theFish.angler_effect(baitUsed)


proc/catchSalvage(theCatch, baitUsed)





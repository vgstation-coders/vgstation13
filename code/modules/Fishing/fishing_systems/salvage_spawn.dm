#define SALVPOINT_BASE_MIN 10
#define SALVPOINT_BASE_MAX 50

var/global/list/spawned_vaults = list()	//Not sure if this already exists, add to vault spawn proc if not

datum/zLevelSalvage
	var/linkedZ = null
	var/beenPopulated = FALSE
	var/list/noMagSalvage = list()
	var/list/northSalvage = list()
	var/list/southSalvage = list()

datum/zLevelSalvage/zOne
	linkedZ = STATION_Z

datum/zLevelSalvage/zTwo	//Just in case
	linkedZ = CENTCOMM_Z

datum/zLevelSalvage/zThree
	linkedZ = TELECOMM_Z

datum/zLevelSalvage/zFour
	linkedZ = DERELICT_Z

datum/zLevelSalvage/zFive
	linkedZ = ASTEROID_Z

datum/zLevelSalvage/zSix
	linkedZ = SPACEPIRATE_Z

var/global/list/zSalvageMaster = list()	//Add to server init, ```new zLevelSalvage``` etc


proc/zSalvCheck(var/hookZ)
	for(var/datum/zLevelSalvage/salvZ in zSalvageMaster)
		if(hookZ == salvZ.linkedZ)
			if(salvZ.beenPopulated)
				return
			salvZ = new salvZ
			zSalvCalc(salvZ)

proc/zSalvCalc(var/salvZ)
	var/salvPoints = decideSalvPoints()
	var/list/vaultByZ = getVaultSalv(salvZ)
	var/list/salvPool = populateSalvagePool(vaultByZ, salvZ)
	var/list/salvList = populateSalvageList(salvPoints, salvPool)
	salvGUnpack(salvList, salvZ)
	salvZ.beenPopulated = TRUE

proc/decideSalvPoints()
	var/sPoints = 0
	sPoints += rand(SALVPOINT_BASE_MIN, SALVPOINT_BASE_MAX)
	sPoints += player_list.len	//There's more salvage in a populated area of space, obviously
	return sPoints

proc/getVaultSalv(salvZ)
	var/list/zVaults = list()
	for(var/V in spawned_vaults)
		if(V.loc.z == salvZ.linkedZ)
			zVaults += V
	return zVaults

proc/populateSalvagePool(vaultByZ, salvZ)
	var/list/salvGPool = list()
	for(var/datum/anglerCatch/salvage/salvGroup/SG in subtypesof(datum/anglerCatch/salvage/salvGroup))
		if(SG.associatedVault && !SG.associatedVault in spawned_vaults)
			continue
		var/SGweight = 0
		SGweight +=	SG.baseChance
		SGweight *= SG.zLevelWeight[salvZ.linkedZ]
		if(SGWeight)
			salvGPool += SG
	return salvGPool

proc/populateSalvageList(salvPoints, salvPool)
	var/list/SL = list()
	for(var/datum/anglerCatch/salvage/salvGroup/SP in salvPool)
		var/datum/anglerCatch/salvage/salvGroup/SG = pickweight(salvPool)
		salvPool -= SG
		if(SG.spawnCost > salvPoints)
			continue
		salvPoints -= SG.spawnCost
		SL += SG
	return SL

proc/salvGUnpack(list/salvList, salvZ)
	var/list/sUnpack = list()
	for(var/datum/anglerCatch/salvage/salvGroup/SG in salvList)
		for(var/datum/anglerCatch/salvage/S in SG.groupedSalvage)
			if(istype(S, datum/anglerCatch/salvage/salvGroup))
				continue	//Just in case
			var/datum/anglerCatch/salvage/nS = new S
			if(SG.typeOfMagnetism && nS.typeOfMagnetism == FLEXMAG)
				nS.typeOfMagnetism = SG.typeOfMagnetism
			nS = SG.specGroupMod(nS)
			switch(nS.typeOfMagnetism)
				if(nS.NOMAG || nS.FLEXMAG)
					salvZ.noMagSalvage += nS
				if(nS.NORTHMAG)
					salvZ.northSalvage += nS
				if(nS.SOUTHMAG)
					salvZ.southSalvage += nS

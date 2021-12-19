var/global/list/aAnalyzerMobFishPages = list()
var/global/list/aAnalyzerItemFishPages = list()
var/global/list/aAnalyzerMutPages = list()

/obj/item/device/angler_analyzer
	desc = "A handheld scanner that reports and catalogues information relevant to space fish, anglers, and their tools."
	name = "angling analyzer"
	icon_state = "mining"
	item_state = "analyzer"
	w_class = W_CLASS_SMALL
	flags = 0
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	var/lastScanTime = 0
	var/scanCooldown = 5 SECONDS	//Really just exists because spam clicking would make the serb mad
	var/datum/angler_analyzer_data/lastScan = null

/obj/item/device/angler_analyzer/preattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(cooldownCheck())
		analyzeCatch(user, target)
	else
		to_chat(user, "<span class='warning'>\The [src] is still processing previous data.</span>"))
	..()

/obj/item/device/angler_analyzer/proc/cooldownCheck()
	if(world.time - lastScanTime >= scanCooldown)
		lastScanTime = world.time
		return TRUE
	else
		return FALSE

/obj/item/device/angler_analyzer/proc/analyzeCatch(mob/user var/atom/aTarg)
	if(isBait(aTarg))
		analyzeBait(user, aTarg)
	if(isfish(aTarg))
		giveMobStats(user, aTarg)
		analyzeMobFish(aTarg)
	else if(isItemFish())
		analyzeItemFish(aTarg)

/obj/item/device/angler_analyzer/proc/analyzeMobFish(var/mob/living/simple_animal/hostile/fishing/theFish)
	var/datum/angler_analyzer_mutation/mutDat = null
	if(theFish.mutation)
		for(var/datum/angler_analyzer_mutation/A in aAnalyzerMutPages))
			if(istype(theFish.mutation, A.mutationType))
				mutDat = A
				break
		if(!mutDat)
			mutDat = createMutPage(theFish.mutation)
	for(var/datum/angler_analyzer_data/mobFish/mF in aAnalyzerMobFishPages)
		if(istype(theFish, mF.dataTarget))
			mF.updatePage(theFish, mutDat)
			return
	for(var/datum/angler_analyzer_data/mobFish/mF in subtypesof(datum/angler_analyzer_data/mobFish))
		if(istype(theFish, mF.dataTarget))
			mF = new mF
			aAnalyzerMobFishPages += mF
			mF.updatePage(theFish, mutDat)

/obj/item/device/angler_analyzer/proc/analyzeItemFish(var/obj/iFish)
//	var/datum/angler_analyzer_data/itemFish/iFData = null
	for(var/datum/angler_analyzer_data/itemFish/iFData in aAnalyzerItemFishPages)
		if(istype(iFish, iFData.dataTarget))
			iFData.reportUniqueAtt(iFish, src)
			return
	for(var/datum/angler_analyzer_data/itemFish/iFData in subtypesof(datum/angler_analyzer_data/itemFish))
		if(istype(iFish, iFData.dataTarget))
			iFData = new iFData
			aAnalyzerItemFishPages += iFData
			iFData.reportUniqueAtt(iFish, src)

/obj/item/device/angler_analyzer/proc/analyzeBait(mob/user, var/obj/item/theBait)
	to_chat(user, )



/obj/item/device/angler_analyzer/proc/giveStats(var/datum/angler_analyzer_data/toStat = lastScan)
	if(!toStat)
		to_chat(user, "<span class='warning'>No data found.</span>")
		return
	var/scanMessage = null
	if(istype(toStat, /datum/angler_analyzer_data/mobFish))
		scanMessage = collectMobStats(toStat)
	else if(istype(toStat, datum/angler_analyzer_data/itemFish))
		scanMessage = collectItemStats(toStat)
	to_chat(user, scanMessage)

/obj/item/device/angler_analyzer/proc/collectMobStats(var/datum/angler_analyzer_data/mobFish/M)
	var/mob/living/simple_animal/hostile/fishing/theFish = M.dataTarget
	var/statM = "<span class='notice'>Scan results for [theFish.name]</span>"
	statM += "<span class='notice'><br>\The [theFish.name] has a size of [theFish.catchSize] units.</span>"
	if(!theFish.mutation || theFish.isLiar)
		statM += "<span class='notice'><br>It is not a mutant.</span>"
	else
		statM += "<span class='notice'><br>It has \the [theFish.mutation.mutName] mutation."
	return statM

/obj/item/device/angler_analyzer/proc/collectItemStats(var/datum/angler_analyzer_data/itemFish/I)
	var/statI = "<span class='notice'>Scan results for [I.dataTarget.name]</span>"
	statI += "<span class='notice'><br>[I.scanInfo]</span>"
	return statI


/obj/item/device/angler_analyzer/createMutPage(var/datum/angler_mutation/theMut)
	for(var/datum/angler_analyzer_mutation/aM in subtypesof(datum/angler_analyzer_mutation))
		if(theMut == aM.mutationType)
			aM = new aM
			aAnalyzerMutPages += aM
			break


/obj/item/device/angler_analyzer/attack_self(mob/living/user)
	var/list/aOptions = list("Latest Scan", "Browse Scans", "Print Book", "Cancel")
	var/aChoice = input(user, "Choose an action.", "Angler Analyzer") in null|aOptions
	switch(aChoice)
		if("Cancel")
			return
		if("Latest Scan")
			giveStats()
		if("Browse Scans")
			browseScans(user)
		if("Print Book")
			printBook()

/obj/item/device/angler_analyzer/proc/browseScans(mob/living/user)
	var/list/bOptions = list("View large catches", "View small catches", "Cancel")
	var/bChoice = input(user, "View which group?", "Angler Analyzer") in null|bOptions
	switch(bChoice)
		if("View large catches")
			var/mChoice = input(user, "Which large catch?", "Angler Analyzer") in null|aAnalyzerMobFishPages
			giveStats(mChoice)
		if("View small catches")
			var/iChoice = input(user, "Which small catch?", "Angler Analyzer") in null|aAnalyzerItemFishPages
			giveStats(iChoice)
		if("Cancel")
			return

//Oh god more UI shit AHHHHH

/obj/item/

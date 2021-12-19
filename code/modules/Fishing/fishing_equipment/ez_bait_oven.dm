#define EZ_PROCESS_BAIT "Process Bait"
#define EZ_SET_MODE	"Set Mode"
#define EZ_RESET_MODE "Reset Mode"
#define EZ_EJECT_INGREDIENTS "Eject Ingredients"

#define EZ_BAIT_FLOUR "Add Flour"
#define EZ_BAIT_FERMENT "Ferment"
#define EZ_BAIT_COMPRESS "Compress"
#define EZ_BAIT_ELECTRIFY "Electrify"
#define EZ_BAIT_MINCE "Mince"
#define EZ_BAIT_BOIL "Boil"
#define EZ_BAIT_IRRADIATE "Irradiate"
#define EZ_BAIT_GILD "Gild"
#define EZ_BAIT_PLASMA "Introduce Plasma"


#define EZ_MULT 0
#define EZ_ADD 1

//To Do:
//Make only some things max(0, var), catchSize should be able to go negative
//Radial menu ****
//More cooking options?
//Upgrades
//Sound effects
//Send new cBait to proc, receive it back ****
//Lists like favored and such, how the fuck am I doing those
//Add mutations and species to cooking methods, good balance method
//Wait the whole busy timer thing barely works and really does need a spawn() for animations




	//Portion+, power-, salvage- add flour	****
	//Power+, Attraction+, portion--, takes time ferment	****
	//Size+, attraction-, portion--, compress ****
	//Power+, salvage++, portion-, changes mag, electrify ****
	//Attraction++, size-, power-, mince ****
	//Attraction+, salvage--, power -, boil
	//Size+, attraction--, mutation tinkering, irradiate ****
	//Size-, portion-, attraction-, power++ or mutation stuff?, dehydrate
	//All?, mutagen blasma ****
	//


/obj/machinery/ez_bait_oven
	name = "EZ-Bait-Oven"
	desc = ""
	icon = ''
	icon_state = ""
	/obj/item/weapon/cell/connected_cell = null
	battery_dependent = TRUE
	machine_flags = SCREWTOGGLE | WRENCHMOVE
	var/ezbMode = null
	var/ezBusy = FALSE
	var/busyTimer = 0
	var/manipTier = 0

	var/obj/item/weapon/bait/custom/ezBait = null
	var/list/heldBait = list()
	var/obj/item/weapon/reagent_containers/glass/beaker/ezBeaker = null
	var/obj/item/stack/sheet/mineral/heldMaterial = null


/obj/machinery/ez_bait_oven/New()
	..()
	var/obj/item/weapon/reagent_containers/glass/beaker/fBeaker = new /obj/item/weapon/reagent_containers/glass/beaker(src)
	fBeaker.reagents.add_reagent(FLOUR, 50)
	ezBeaker = fBeaker

/obj/machinery/ez_bait_oven/proc/toggleBusy(var/bTime)
	update_icon()
	if(!ezBusy)
		bTime = max(1 SECONDS, bTime * 1 - (manipTier*0.1))
		busyTimer = world.time + bTime
		ezBusy = TRUE
		processing_objects.Add(src)
	else
		ezBusy = FALSE
		processing_objects.Remove(src)

/obj/machinery/ez_bait_oven/process()
	if(world.time >= busyTimer)
		finishBait()

/obj/machinery/ez_bait_oven/AltClick(mob/user)	//Half copy pasted from microwaves
	if(stat & NOPOWER)
		return ..()
	if(isAdminGhost(user) || (!user.incapacitated() && Adjacent(user) && user.dexterity_check()))
		if(!checkEZBait())
			return
		if(ezBusy)
			to_chat(user, "<span class='notice'>The [src] is still busy and cannot be tampered with.</span>")
			return
		if(issilicon(user) && !attack_ai(user))	//Just took all this from microwaves because sanity is hard
			return ..()
		var/list/choices = list(
			list(EZ_PROCESS_BAIT, "radial_cook"),
			list(EZ_EJECT_INGREDIENTS, "radial_eject"),
			list(EZ_SET_MODE, "radial_chem_notrash"),
			list(EZ_RESET_MODE, "radial_examine")
		)
		var/ezJob = show_radial_menu(user, loc, choices, custom_check = new /callback(src, .proc/radial_check, user))
		activateEZB(ezJob)

/obj/machinery/ez_bait_oven/kick_act(mob/living/carbon/human/user)
	..()
	if(ezbMode)
		processBait(user)
	else
		ezEject()

/obj/machinery/ez_bait_oven/attackby(var/obj/item/O, var/mob/user)
	if(ezBusy)
		to_chat(user, "<span class='notice'>The [src] is still busy and cannot be tampered with.</span>")
		return
	..()
	if(istype(/obj/item/weapon/reagent_containers/glass/beaker))
		if(panel_open)
			addBeaker(O)
		else if(O.reagents.total_volume)
			fillBeaker(O, user)
	else if(isBait(O))
		addBait(O)

/obj/machinery/ez_bait_oven/proc/fillBeaker(var/obj/item/weapon/reagent_containers/glass/beaker/fBeaker, mob/user)
	if(fBeaker.reagents.reagent_list.len > 1)
		to_chat(user, "<span class='notice'>The [src] buzzes, the ingredient must be pure.</span>")
		return
	for(var/datum/reagent/R in fBeaker.reagents)
		if(R != FLOUR)
			to_chat(user, "<span class='notice'>The [src] buzzes, it can't accept that chemical.</span>")
			return
	fBeaker.transfer(ezBeaker, user)

/obj/machinery/ez_bait_oven/proc/addBeaker(var/obj/item/weapon/reagent_containers/glass/beaker/aBeaker, mob/user)
	if(!aBeaker.is_open_container())
		to_chat(user, "<span class='notice'>A closed container can't fit in \the [src].</span>")
		return
	if(ezBeaker)
		ezBeaker.forceMove(loc)
		to_chat(user, "<span class='notice'>You switch \the [ezBeaker] for the [aBeaker].</span>")
		ezBeaker = aBeaker
		ezBeaker.forceMove(src)

/obj/machinery/ez_bait_oven/proc/addBait(var/obj/item/toEZB, mob/user)
	if(istype(toEZB, /obj/item/weapon/bait/custom))
		to_chat(user, "<span class='notice'>This cannot be further processed.</span>")
		return
	if(heldBait.len >= 3)
		to_chat(user, "<span class='notice'>The [src] is already full.</span>")
		return
	if(user.drop_item(toEZB))
		toEZB.forceMove(src)
		heldBait += toEZB
		to_chat(user, "<span class='notice'>You add \the [toEZB] to \the [src].</span>")

/obj/machinery/ez_bait_oven/proc/processBait(mob/user)
	if(!checkEZBait())
		return
	var/toBeBait = new var/obj/item/weapon/bait/custom(src)
	if(!ezbMode)
		pickEZBMode()
		modePathway(toBeBait)
		ezbMode = null
	else
		modePathway(toBeBait)
	if(ezBait)
		for(var/obj/item/B in heldBait)
			qdel(B)

/obj/machinery/ez_bait_oven/proc/pickEZBMode()
	var/list/ezbOptions = list(
		EZ_BAIT_FLOUR,
		EZ_BAIT_FERMENT,
		EZ_BAIT_COMPRESS,
		EZ_BAIT_ELECTRIFY,
		EZ_BAIT_MINCE,
		EZ_BAIT_BOIL,
		EZ_BAIT_IRRADIATE,
		EZ_BAIT_GILD,
		EZ_BAIT_PLASMA
	)
	ezbMode = input(user,"How would you like to process your bait?","EZ Bait Oven") in null|ezbOptions

/obj/machinery/ez_bait_oven/proc/modePathway(var/obj/item/weapon/bait/custom/cBait)
	if(!ezbMode)
		return
	switch(ezbMode)
		if(EZ_BAIT_FLOUR)
			ezFlour(cBait)
		if(EZ_BAIT_FERMENT)
			ezFerment(cBait)
		if(EZ_BAIT_COMPRESS)
			ezCompress(cBait)
		if(EZ_BAIT_ELECTRIFY)
			ezElectrify(cBait)
		if(EZ_BAIT_MINCE)
			ezMince(cBait)
		if(EZ_BAIT_BOIL)
			ezBoil(cBait)
		if(EZ_BAIT_IRRADIATE)
			ezIrradiate(cBait)
		if(EZ_BAIT_GILD)
			ezGild(cBait)
		if(EZ_BAIT_PLASMA)
			ezPlasma(cBait)


/obj/machinery/ez_bait_oven/proc/checkEZBait()
	if(ezBusy)
		return FALSE
	for(var/obj/item/HB in heldBait)
		if(HB.loc != src)
			ezEject()	//Something went wrong, time to puke
			return FALSE
	return TRUE


/obj/machinery/ez_bait_oven/proc/activateEZB(var/ezJob)
	switch(ezJob)
		if(EZ_PROCESS_BAIT)
			processBait()
		if(EZ_RESET_MODE)
			to_chat(user, "<span class='notice'>The [src] emits a sharp clicking sound.</span>")
			ezbMode = null
		if(EZ_EJECT_INGREDIENTS)
			ezEject()
		if(EZ_SET_MODE)
			pickEZBMode()

/obj/machinery/ez_bait_oven/proc/finishBait()
	playsound(src, 'sound/machines/ding.ogg', 75, 1)
	ezBait.forceMove(loc)
	ezBait = null
	toggleBusy()

/obj/machinery/ez_bait_oven/proc/ezEject()
	for(var/obj/item/B in heldBait)
		B.forceMove(loc)
		heldBait -= B
	if(heldMaterial)
		heldMaterial.forceMove(loc)
		heldMaterial = null


//Generic recyclable procs///////////

/obj/machinery/ez_bait_oven/proc/handleSpeciesLists()	//I feel terrible writing this. I just couldn't think of a better way. I'm sorry.
	var/fsList = list()
	var/esList = list()
	var/rsList = list()
	for(var/obj/item/B in heldBait)
		for(var/datum/anglerCatch/S in B.baitValue.favoredSpecies)
			fsList[S] += [S]
		for(var/datum/anglerCatch/S in B.baitValue.exclusiveSpecies)
			esList += S		//This should increase the chances of double entries being picked in bait with multiple exclusive species and is intentional
		for(var/datum/anglerCatch/S in B.baitValue.rejectedSpecies)
			if(is_type_in_list(rsList, S))	//Rejected species lists shouldn't be long so this should be fine.
				continue
			rsList += S
	ezBait.baitValue.favoredSpecies = fsList
	ezBait.baitValue.exclusiveSpecies = esList
	ezBait.baitValue.rejectedSpecies = rsList

/obj/machinery/ez_bait_oven/proc/handleMutationLists()
	var/fmList = list()
	var/emList = list()
	var/rmList = list()
	for(var/obj/item/B in heldBait)
		for(var/datum/angler_mutation/M in B.baitValue.favoredMutations)
			fmList[M] += [M]
		for(var/datum/angler_mutation/M in B.baitValue.exclusiveMutations)
			emList += M
		for(var/datum/angler_mutation/M in B.baitValue.rejectedMutations)
			if(is_type_in_list(rmList, M))
				continue
			rmList += M
	ezBait.baitValue.favoredMutations = fmList
	ezBait.baitValue.exclusiveMutations = emList
	ezBait.baitValue.rejectedMutations = rmList


/obj/machinery/ez_bait_oven/proc/averageAndMod(var/mathType, var/list/statVals, var/statMod)
	var/averagedStat = 0
	for(var/V in statVals)
		switch(mathType)
			if(EZ_MULT)
				averagedStat += V * statMod
			if(EZ_ADD)
				averagedStat += V + statMod
	averagedStat /= statVals.len
	return max(0, averagedStat)


/obj/machinery/ez_bait_oven/proc/sumAndMod(var/mathType, var/list/statVals, var/statMod)
	var/sumStat = 0
	for(var/V in statVals)
		switch(mathType)
			if(EZ_MULT)
				sumStat += V * statMod
			if(EZ_ADD)
				sumStat += V + statMod
	return max(0, sumStat)


//Different types of bait combining///////////////

/obj/machinery/ez_bait_oven/proc/ezFerment(var/obj/item/bait/custom/cBait)
	toggleBusy(180 SECONDS)
	to_chat(user, "<span class='notice'>The [src] begins fermenting the ingredients.</span>")
	var/list/fermPow = list()
	var/list/fermAttr = list()
	var/list/fermPort = list()
	for(var/obj/item/B in heldBait)
		fermPow += B.baitValue.catchPower
		fermAttr += B.baitValue.catchAttraction
		fermPort += B.baitValue.portionSize
	cBait.baitValue.catchPower = averageAndMod(EZ_MULT, fermPow, 1.5)
	cBait.baitValue.catchAttraction	= averageAndMod(EZ_MULT, fermAttr, 1.2) + fermAttr.len)
	cBait.baitValue.portionSize = averageAndMod(EZ_MULT, fermPort, 0.5)


/obj/machinery/ez_bait_oven/proc/ezFlour(var/obj/item/bait/custom/cBait)
	if(ezBeaker.reagents.total_volume < 10)
		to_chat(user, "<span class='notice'>The [src] buzzes, it does not have enough flour.</span>")
		return
	toggleBusy(3 SECONDS)
	ezBeaker.reagents.remove_reagents(FLOUR, 10)
	var/list/flourPow = list()
	var/list/flourPort = list()
	var/list/flourSalv = list()
	for(var/obj/item/B in heldBait)
		flourPow += B.baitValue.catchPower
		flourPort += B.baitValue.portionSize
		flourSalv += B.baitValue.salvageAttraction
	cBait.baitValue.portionSize = sumAndMod(EZ_ADD, flourPort, 10)
	cBait.baitValue.catchPower = averageAndMod(EZ_MULT, flourPow, 0.8)
	cbait.baitValue.salvageAttraction = averageAndMod(EZ_MULT, flourSalv, 0.5)

/obj/machinery/ez_bait_oven/proc/ezCompress(var/obj/item/bait/custom/cBait, var/compMod)
	toggleBusy(10 SECONDS)
	var/list/compSizeA = list()
	var/list/compSizeM = list()
	var/list/compAttr = list()
	var/list/compPort = list()
	for(var/obj/item/B in heldBait)
		compSizeA += B.baitValue.catchSizeAdd
		compSizeM += B.baitValue.catchSizeMult
		compAttr += B.baitValue.catchAttraction
		compPort += B.baitValue.portionSize
	cBait.baitValue.catchSizeAdd = averageAndMod(EZ_ADD, compSizeA, 1)
	cBait.baitValue.catchSizeMult = averageAndMod(EZ_MULT, compSizeM, 1.20)
	cBait.baitValue.catchAttraction = sumAndMod(EZ_MULT, compAttr, 0.1)
	cBait.baitValue.portionSize = averageAndMod(EZ_MULT, compPort, 0.1)

/obj/machinery/ez_bait_oven/proc/ezElectrify(var/obj/item/bait/custom/cBait)
	if(connected_cell.charge < 500)
		to_chat(user, "<span class='notice'>The [src] buzzes, its [connected_cell] does not have enough charge.</span>")
		return
	toggleBusy(1 SECONDS)
	connected_cell.charge -= 500
	var/list/elecPow = list()
	var/list/elecSalv = list()
	var/list/elecPort = list()
	for(var/obj/item/B in heldBait)
		elecPow += B.baitValue.catchPower
		elecSalv += B.baitValue.salvageAttraction
		elecPort += B.baitValue.portionSize
	cBait.baitValue.catchPower = averageAndMod(EZ_ADD, elecPow, rand(5,10))
	cBait.baitValue.salvageAttraction = averageAndMod(EZ_ADD, elecSalv, 20)
	cBait.baitValue.portionSize = averageAndMod(EZ_MULT, elecPort, 0.5)
	cBait.baitValue.magnetPole = pick(NORTHMAG, SOUTHMAG)

/obj/machinery/ez_bait_oven/proc/ezMince(var/obj/item/bait/custom/cBait)
	toggleBusy(3 SECONDS)
	var/list/minceAttr = list()
	var/list/minceSizeA = list()
	var/list/minceSizeM = list()
	var/list/mincePow = list()
	for(var/obj/item/B in heldBait)
		minceAttr += B.baitValue.catchAttraction
		minceSizeA += B.baitValue.catchSizeAdd
		minceSizeM += B.baitValue.catchSizeMult
		mincePow += B.baitValue.catchPower
	cBait.baitValue.catchAttraction = averageAndMod(EZ_MULT, minceAttr, 2)
	cBait.baitValue.catchSizeAdd = averageAndMod(EZ_ADD, minceSizeA, 3)
	cBait.baitValue.catchSizeMult = averageAndMod(EZ_MULT, minceSizeM, 1.1)
	cBait.baitValue.catchPower = averageAndMod(EZ_MULT, mincePow, 0.5)

/obj/machinery/ez_bait_oven/proc/ezIrradiate(var/obj/item/bait/custom/cBait)
	if(heldMaterial != /obj/item/stack/sheet/mineral/uranium)
		return
	if(!use.heldMaterial(3))
		return
	toggleBusy(5 SECONDS)
	var/list/irradSizeA = list()
	var/list/irradSizeM = list()
	var/list/irradAttr = list()
	var/list/irradPow = list()
	for(var/obj/item/B in heldBait)
		irradSizeA += B.baitValue.catchSizeAdd
		irradSizeM += B.baitValue.catchSizeMult
		irradAttr += B.baitValue.catchAttraction
		irradPow += B.baitValue.catchPower
	cBait.baitValue.catchSizeAdd = averageAndMod(EZ_MULT, irradSizeA, 1.3)
	cBait.baitValue.catchSizeMult = averageAndMod(EZ_ADD, irradSizeM, 0.2)
	cBait.baitValue.catchAttraction = averageAndMod(EZ_MULT, irradAttr, 0.1)
	cBait.baitValue.catchPower = averageAndMod(EZ_ADD, irradPow, rand(-30, 30))

/obj/machinery/ez_bait_oven/proc/ezGild(var/obj/item/bait/custom/cBait)
	if(heldMaterial != /obj/item/stack/sheet/mineral/gold)
		return
	if(!use.heldMaterial(3))
		return
	toggleBusy(5 SECONDS)
	var/list/gildSalv = list()
	var/list/gildPort = list()
	var/list/gildAttr = list()
	for(var/obj/item/B in heldBait)
		gildSalv += B.baitValue.salvageAttraction
		gildSalv += B.baitValue.portionSize
		gildSalv += B.baitValue.catchAttraction
	cBait.baitValue.salvageAttraction = sumAndMod(EZ_MULT, gildSalv, 0.5)
	cBait.baitValue.portionSize = sumAndMod(EZ_ADD, gildPort, 0)
	cBait.baitValue.catchAttraction = averageAndMod(EZ_ADD, gildAttr, 10)

/obj/machinery/ez_bait_oven/proc/ezPlasma(var/obj/item/bait/custom/cBait)
	if(heldMaterial != /obj/item/stack/sheet/mineral/plasma)
		return
	if(!use.heldMaterial(3))
		return
	toggleBusy(5 SECONDS)
	var/list/plasPow = list()
	var/list/plasAttr = list()
	var/list/plasSizeA = list()
	var/list/plasSizeM = list()
	for(var/obj/item/B in heldBait)
		plasPow += B.baitValue.catchPower
		plasAttr += B.baitValue.catchAttraction
		plasSizeA += B.baitValue.catchSizeAdd
	cBait.baitValue.catchPower = averageAndMod(EZ_ADD, plasPow, rand(-20, 20))
	cBait.baitValue.catchAttraction = averageAndMod(EZ_ADD, plasAttr, rand(-10, 10))
	cBait.baitValue.catchSizeAdd = averageAndMod(EZ_ADD, plasAttr, rand(-4, 4))
	cBait.baitValue.portionSize = rand(5, 25)








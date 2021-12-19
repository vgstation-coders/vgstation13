datum/angler_analyzer_data
	var/dataTarget = null	//The associated catch's typepath
	var/targetImage = null
	var/list/preferredZ = list()
	var/infoText = null	//In-game wiki desc + flavor/fluff

datum/angler_analyzer_mutation
	var/datum/angler_mutation/mutationType = null	//The actual mutation datum
	var/descMut = null	//In-game wiki description + flavor/fluff
	//var/rarityValue = 1	//Multiplies research value

//mobFish///////////////////

datum/angler_analyzer_data/mobFish
	var/list/cSizeList = list()	//The catchSizes of caught mobs of this type
	var/list/mutFound = list()	//Mutations possessed by mobs of this type found
	var/list/uniqueInteract = list()	//Mutations with a unique effect on this mob, ie: Meel mutations that affect egg chems.

datum/angler_analyzer_data/mobFish/proc/updatePage(var/mob/living/simple_animal/hostile/fishing/theFish, var/datum/angler_analyzer_mutation/aMut)
	if(aMut && !is_type_in_list(aMut, mutFound))
		mutFound += aMut
	cSizeList += theFish.catchSize




datum/angler_analyzer_data/mobFish/station_sucker
	dataTarget = /mob/living/simple_animal/hostile/fishing/station_sucker
	targetImage = //how does this work
	preferredZ = //fill in later
	uniqueInteract = list()
	infoText = ""

datum/angler_analyzer_data/mobFish/carry_crab
	dataTarget =
	targetImage =
	preferredZ =
	uniqueInteract = list()
	infoText =

datum/angler_analyzer_data/mobFish/change_ling
	dataTarget =
	targetImage =
	preferredZ =
	uniqueInteract = list()
	infoText =

datum/angler_analyzer_data/mobFish/eswordfish
	dataTarget =
	targetImage =
	preferredZ =
	uniqueInteract = list()
	infoText =

datum/angler_analyzer_data/mobFish/fermurtle
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/flamelfin
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/kleptopus
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/meel
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/porpal
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/puffbumper
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/snitchrimp
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/space_shark
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/star_drake
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/star_jelly
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

datum/angler_analyzer_data/mobFish/stonegulper
	dataTarget =
	targetImage =
	preferredZ =
	infoText =

//mutations///////////////

datum/angler_analyzer_mutation/proc/



//itemFish////////////

datum/angler_analyzer_data/itemFish
	var/uniqueAttributes = null
	var/scanInfo = ""

datum/angler_analyzer_data/itemFish/proc/reportUniqueAtt(var/obj/iFish, var/obj/item/device/angler_analyzer/aA)
	return

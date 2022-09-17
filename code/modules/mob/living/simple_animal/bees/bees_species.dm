//Beekeeping 3.5 by Deity Link

//SPECIES DATUM

//BUG DATUM

//QUEEN BUG DATUM

//QUEEN BUG PACKET

//TYPES FOR CASUAL SPAWNS

//the framework will be expanded later for bugs other than bees, ones that don't have queens, hives...

//////////////////////////////////////
//           NORMAL BEES            //
//////////////////////////////////////

/datum/bee_species
	var/name = "apis mellifera"
	var/common_name = BEESPECIES_NORMAL
	var/prefix = ""
	var/worker_product = HONEY
	var/queen_product = ROYALJELLY
	var/list/toxic_reagents = list(
		TOXIN = 2,
		STOXIN = 1,
		FLUORINE = 1,
		RADIUM = 3,
		FUEL = 2,
		VOMIT = 1,
		BLEACH = 2,
		PLANTBGONE = 3,
		PLASMA = 2,
		SACID = 1,
		PACID = 3,
		CYANIDE = 4,
		AMATOXIN = 2,
		AMANATIN = 3,
		POISONBERRYJUICE = 2,
		CARPOTOXIN = 2,
		ZOMBIEPOWDER = 3,
		MINDBREAKER = 1,
		PLASTICIDE = 2,
		GRUE_BILE = 1,
	)
	var/angery = 1
	var/max_queen_inside = 1
	var/queen_wanders = 1
	var/toxic_threshold_anger = 33//percentage of apiary toxicity before bees that come out feel like killing stuff instead of pollinating.
	var/toxic_threshold_death = 50//percentage of apiary toxicity before bees outside the hive start dying of toxicity.
	var/bee_type = /datum/bee
	var/queen_type = /datum/bee/queen_bee

	var/min_oxy = 5
	var/max_oxy = 0
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/minbodytemp = 0
	var/maxbodytemp = 360
	var/corpse = /obj/effect/decal/cleanable/bee

	var/slow = 1
	var/damage_coef = 1
	var/toxic_coef = 1

	var/pierce_chance = 0//100 = always pierce through protection
	var/pierce_damage = 0//100 = deals 100 of the damage if pierce procs

	var/wild = 0	//wild bees will be angry all the time and never get exhausted

/datum/bee_species/proc/after_sting(var/mob/living/L, var/sting_quality)
	return

//////////////////////////////////////==================================================================================================================================
//             VOX BEES             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////==================================================================================================================================

/datum/bee_species/chill
	name = "apis chiliverax"
	common_name = BEESPECIES_VOX
	prefix = "chill_"
	worker_product = CHILLWAX
	queen_product = CHILLWAX
	toxic_reagents = list(
		BLEACH = 2,
		PLANTBGONE = 3,
		CYANIDE = 4,
		PLASTICIDE = 2,
	)
	angery = 0//never gets mad ever
	toxic_threshold_anger = 90//unless you're really pushing it
	max_queen_inside = 2
	queen_wanders = 0
	bee_type = /datum/bee/chill
	queen_type = /datum/bee/queen_bee/chill

	min_oxy = 0
	max_oxy = 1
	min_n2 = 5
	maxbodytemp = 400
	corpse = /obj/effect/decal/cleanable/bee/chill

	damage_coef = 0
	toxic_coef = 0

/datum/bee/chill
	corpse = /obj/effect/decal/cleanable/bee/chill

/datum/bee/chill/New()
	..()
	species = bees_species[BEESPECIES_VOX]

/datum/bee/queen_bee/chill
	corpse = /obj/effect/decal/cleanable/bee/queen_bee/chill

/datum/bee/queen_bee/chill/New()
	..()
	species = bees_species[BEESPECIES_VOX]

//can only occur when fired from a chillgun
/datum/bee_species/chill/after_sting(var/mob/living/L, var/sting_quality)
	if (L.reagents)
		L.reagents.add_reagent(CHILLWAX,1)


//////////////////////////////////////==================================================================================================================================
//              HORNETS             ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////==================================================================================================================================

/datum/bee_species/hornet
	name = "vespa crabro"
	common_name = BEESPECIES_HORNET
	prefix = "hornet_"
	worker_product = null
	queen_product = ROYALJELLY
	toxic_reagents = list()

	angery = 1
	toxic_threshold_anger = 90//unless you're really pushing it
	max_queen_inside = 1
	queen_wanders = 0
	bee_type = /datum/bee/hornet
	queen_type = /datum/bee/queen_bee/hornet

	corpse = /obj/effect/decal/cleanable/bee/hornet

	slow = 0
	damage_coef = 3
	toxic_coef = 0.75

	pierce_chance = 20
	pierce_damage = 40

	wild = 1

/datum/bee/hornet
	corpse = /obj/effect/decal/cleanable/bee/hornet

/datum/bee/hornet/New()
	..()
	species = bees_species[BEESPECIES_HORNET]

/datum/bee/queen_bee/hornet
	corpse = /obj/effect/decal/cleanable/bee/queen_bee/hornet

/datum/bee/queen_bee/hornet/New()
	..()
	species = bees_species[BEESPECIES_HORNET]


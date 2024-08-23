//Cvilizations are defined here. Civilizations represent the random items which can be found on the planet and vary by tech level. Different races appear on certain planets.

var/list/datum/procgen/civilization/civilizations = list(
	/datum/procgen/civilization/unexplored,
	/datum/procgen/civilization/young,
	/datum/procgen/civilization/old,
	/datum/procgen/civilization/future
)

/datum/procgen/civilization
	var/weight

/datum/procgen/civilization/unexplored
	weight = PG_UNEXPLORED_WEIGHT

/datum/procgen/civilization/young
	weight = PG_YOUNG_CIV_WEIGHT

/datum/procgen/civilization/old
	weight = PG_OLD_CIV_WEIGHT

/datum/procgen/civilization/future
	weight = PG_FUTURE_CIV_WEIGHT

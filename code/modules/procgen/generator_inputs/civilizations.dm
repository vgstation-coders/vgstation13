//Cvilizations are defined here. Civilizations represent the random items which can be found on the planet and vary by tech level. Different races appear on certain planets.

/datum/procgen/civilization
	var/weight
	var/human_items = list()
	var/xeno_items = list()

/datum/procgen/civilization/unexplored
	name = "Unexplored"
	desc = "This celestial body has never been explored by sentient life."
	weight = PG_UNEXPLORED_WEIGHT

/datum/procgen/civilization/young
	name = "Young Civilization"
	desc = "This celestial body shows signs of a young civiliziation which was prematurely wiped out."
	weight = PG_YOUNG_CIV_WEIGHT

/datum/procgen/civilization/old
	name = "Old Civilization"
	desc = "This celestial body shows signs of a well-established civilization which has long since disappeared."
	weight = PG_OLD_CIV_WEIGHT

/datum/procgen/civilization/future
	name = "Future Civilization"
	desc = "This celestial body shows signs of a highly-advanced civilization which has left the planet."
	weight = PG_FUTURE_CIV_WEIGHT

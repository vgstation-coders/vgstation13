/datum/map_element/event
	type_abbreviation = "EV"

	var/announcement_info

/datum/map_element/event/pre_load()
	.=..()

	announce()

/datum/map_element/event/proc/announce()
	if(!announcement_info)
		return

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "[announcement_info]")

/datum/map_element/event/example
	file_path = "maps/randomvaults/events/example.dmm"

/datum/map_element/event/caravan
	file_path = "maps/randomvaults/events/trader_ship.dmm"

	announcement_info = "<i>A caravan from a nearby solar system has decided to approach station.</i>"

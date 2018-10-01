/*
	Something to hold variables associated with runes that go throughout the world
*/

var/list/rune_list_legacy = list() // All the runes in the world.

/datum/rune_controller
	var/revive_counter = 0
	var/list/sacrificed = list()
	var/harvested
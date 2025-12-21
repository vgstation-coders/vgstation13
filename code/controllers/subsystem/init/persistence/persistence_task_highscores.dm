
// This task has a unit test on code/modules/unit_tests/highscores.dm
/datum/persistence_task/highscores
	execute = TRUE
	name = "Money highscores"
	file_path = "data/persistence/money_highscores.json"

/datum/persistence_task/highscores/on_init()
	var/to_read = read_file()
	if(!to_read)
		log_debug("[name] task found an empty file on [file_path]")
		return

	for (var/list/L in to_read)

		// --------- LEGACY READING FOR MALFORMED JSON FILES ------------
		if (L["fields"])
			var/list/L2 = L["fields"]
			if (!L2)
				to_chat(world, "uuuh L2 doesn't exist")
			var/datum/data/record/money/record = new(L2["ckey"], L2["role"], L2["cash"], L2["shift_duration"], L2["date"])
			data += record
			return
		// -- END LEGACY
		else
			var/datum/data/record/money/record = new(L["ckey"], L["role"], L["cash"], L["shift_duration"], L["date"])
			data += record

/datum/persistence_task/highscores/on_shutdown()
	var/list/L = list()
	for(var/datum/data/record/money/record in data)
		L += list(record.fields)
	write_file(L)

/datum/persistence_task/highscores/proc/insert_records(list/records, var/ckey_unique = FALSE)
	data += records
	global.cmp_field = "cash"
	sortTim(data, /proc/cmp_records_numerically)

	if (ckey_unique)
		// This is already timSorted, so only keep the first one.
		var/found_ckeys = list()
		for(var/datum/data/record/money/record in data)
			if (record.fields["ckey"] in found_ckeys)
				data -= record
			found_ckeys += record.fields["ckey"]

	if (data.len > 5)
		data.Cut(6) // we only store the top 5
	for(var/datum/data/record/money/record in data)
		if(record in records)
			if(data[1] == record)
				announce_new_highest_record(record)
			else
				announce_new_record(record)

/datum/persistence_task/highscores/proc/announce_new_highest_record(var/datum/data/record/money/record)
	var/name = "Richest escape ever"
	var/desc = "You broke the record of the richest escape! $[record.fields["cash"]] chips accumulated."
	give_award(record.fields["ckey"], /obj/item/weapon/reagent_containers/food/drinks/golden_cup, name, desc)

/datum/persistence_task/highscores/proc/announce_new_record(var/datum/data/record/money/record)
	var/name = "Good rich escape"
	var/desc = "You made it to the top 5! You accumulated $[record.fields["cash"]]."
	give_award(record.fields["ckey"], /obj/item/clothing/accessory/medal/gold, name, desc, FALSE)

/datum/persistence_task/highscores/proc/clear_records()
	data = list()
	fdel(file(file_path))

/datum/persistence_task/highscores/trader
	execute = TRUE
	name = "Trader shoal highscores"
	file_path = "data/persistence/trader_highscores.json"

/datum/persistence_task/highscores/trader/announce_new_highest_record(var/datum/data/record/money/record)
	var/name = "Richest shoal haul ever"
	var/desc = "You broke the record of the richest shoal haul! $[record.fields["cash"]] chips accumulated."
	give_award(record.fields["ckey"], /obj/item/weapon/reagent_containers/food/drinks/golden_cup, name, desc)

/datum/persistence_task/highscores/trader/announce_new_record(var/datum/data/record/money/record)
	var/name = "Good rich shoal haul"
	var/desc = "You made it to the top 5! You accumulated $[record.fields["cash"]]."
	give_award(record.fields["ckey"], /obj/item/clothing/accessory/medal/gold, name, desc, FALSE)

// -- Betris Highscores

/datum/persistence_task/highscores/tetris
	name = "Tetris all-time high scores"
	execute = TRUE
	file_path = "data/persistence/tetris_highscores.json"

/datum/persistence_task/highscores/tetris/on_shutdown()
	var/list/temp_data = list()
	for (var/obj/machinery/computer/tetris/T in tetris_machines)
		for (var/list/L in T.leaderboard_this_round)
			var/datum/data/record/money/M = new(
				ckey = L["ckey"],
				role = L["role"],
				cash = L["cash"]
			)
			temp_data += M

	for (var/list/L in deleted_machines_tetris_highscores)
		var/datum/data/record/money/M = new(
			ckey = L["ckey"],
			role = L["role"],
			cash = L["cash"]
		)
		temp_data += M

	insert_records(temp_data, TRUE) // Does the trimming and all that stuff

	. = ..() // Insert the record

/datum/persistence_task/highscores/tetris/announce_new_highest_record(var/datum/data/record/money/record)
	var/name = "Best scientist ever"
	var/desc = "You broke the record of the most productive scientist! [record.fields["cash"]] research points accumulated."
	give_award(record.fields["ckey"], /obj/item/weapon/reagent_containers/food/drinks/golden_cup, name, desc)

/datum/persistence_task/highscores/tetris/announce_new_record(var/datum/data/record/money/record)
	var/name = "Brightest minds of Nanotrasen"
	var/desc = "You made it to the top 5! You accumulated [record.fields["cash"]]  research points."
	give_award(record.fields["ckey"], /obj/item/clothing/accessory/medal/gold, name, desc, FALSE)

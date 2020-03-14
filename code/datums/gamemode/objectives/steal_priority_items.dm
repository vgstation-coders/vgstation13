/datum/objective/steal_priority
	explanation_text = "Acquire a number of priority items."
	name = "(vox raiders) Acquire items"
	var/num
	var/list/item_names = list()

/datum/objective/steal_priority/New(var/list/items)
	. = ..()
	for (var/type in items)
		var/obj/O = type
		item_names += initial(O.name)

/datum/objective/steal_priority/PostAppend()
	. = ..()
	num = rand(1, 3)
	explanation_text = "Acquire [num] priority items, among the following list: [english_list(item_names)]."

/datum/objective/steal_priority/IsFulfilled()
	var/datum/faction/vox_shoal/VS = faction
	if (!VS)
		return FALSE
	return VS.got_items >= num
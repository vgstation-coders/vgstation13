/datum/objective/eet/books
	explanation_text = "Preserve the 10 finest works of literature the crew has created in your archives."
	name = "Sample literature (EET)"

/datum/objective/eet/books/IsFulfilled()
	if (..())
		return TRUE
	if(!eet_arch)
		return FALSE
	var/counter = 0
	var/list/valid_types = list(/obj/item/weapon/book, \
								/obj/item/weapon/tome, \
								/obj/item/weapon/tome_legacy, \
								/obj/item/weapon/spellbook, \
								/obj/item/weapon/storage/bible)
	for(var/obj/item/I in eet_arch.contents)
		if(is_type_in_list(I,valid_types))
			counter++
	if(counter>=10)
		return TRUE
	return FALSE
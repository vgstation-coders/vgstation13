/datum/job/hop/New()
	..()
	title = "First Mate"
	head_position = 1
	command_positions |= list(title)

/datum/job/assistant/New()
	..()
	title = "Deckhand"

/datum/outfit/assistant/New()
	..()
	for(var/key in items_to_spawn)
		var/list/L = items_to_spawn[key]
		if(!islist(L))
			continue
		var/list/uniform = L[slot_w_uniform_str]
		if(islist(uniform) && !("Deckhand" in uniform))
			uniform["Deckhand"] = /obj/item/clothing/under/color/grey


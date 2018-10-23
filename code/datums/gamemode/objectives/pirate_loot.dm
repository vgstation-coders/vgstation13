/datum/objective/pirate_loot
	explanation_text = "Acquire Booty."
	name = "(pirate) acquire loot"
	var/total_loot = 0

/datum/objective/pirate_loot/IsFulfilled()
	if(faction && istype(faction, /datum/faction/pirate_raiders))
		var/datum/faction/pirate_raiders/PR = faction
		if(PR.assoc_shuttle)
			var/obj/structure/closet/crate/chest/C = locate(/obj/structure/closet/crate/chest) in PR.assoc_shuttle.linked_area
			if(C)
				total_loot = 0
				for(var/obj/I in C)
					if(shop_prices[I.type])
						total_loot += shop_prices[I.type]
			format_explanation()
			return TRUE
	return FALSE

/datum/objective/pirate_loot/format_explanation()
	explanation_text = "You've collected a total of [total_loot] credits of loot, without losing the chest!"

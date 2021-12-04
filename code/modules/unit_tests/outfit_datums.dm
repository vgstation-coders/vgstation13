/datum/unit_test/outfit_datums

// Make sure that the slots indexes used by outfit datums are indeed slot indexes.
// Spawn a human of each race and equip items to make sure they're of the correct type.
// Spawn a backback and put all the items to collect to make sure there's enough room.

/datum/unit_test/outfit_datums/start()
	for (var/type in subtypesof(/datum/outfit))
		var/datum/outfit/O = new type
		for (var/species in O.items_to_spawn)
			// Testing all species.
			var/list/to_recycle = list()
			var/list/L = O.items_to_spawn[species]
			var/mob/living/carbon/human/H = new(run_loc_top_right)
			if (species != "Default")
				var/datum/species/S = species
				H.set_species(initial(S.name))
			for (var/slot in L)
				if (isnull(text2num(slot)))
					fail("Outfit [O.type] : list [species] doesn't have a number index at slot [slot].")
				var/obj_type = L[slot]
				if (islist(obj_type)) // Special objects for alt-titles. Equip them all, delete, then equip the first one.
					var/list/L2 = obj_type
					for (var/alt_title in L2)
						obj_type = L2[alt_title]
						var/obj/item/alt_title_item = new obj_type(get_turf(H))
						if(!H.equip_to_slot_or_del(alt_title_item, text2num(slot), TRUE))
							fail("[obj_type] not equipped on [species]; alt-title: [alt_title]")
						qdel(alt_title_item)
					obj_type = L2[L2[1]] // L2[1] = first alt-title. L2[L2[1]] = first item path.
				var/obj/item/item = new obj_type(get_turf(H))
				to_recycle += item
				if(!H.equip_to_slot_or_del(item, text2num(slot), TRUE))
					fail("[obj_type] not equipped on [species]")
			for (var/object in to_recycle)
				qdel(object)
				to_recycle -= object
			qdel(H)

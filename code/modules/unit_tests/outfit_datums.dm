/datum/unit_test/outfit_datums

// Make sure that the slots indexes used by outfit datums are indeed slot indexes.

/datum/unit_test/outfit_datums/start()
    for (var/type in subtypesof(/datum/outfit))
        var/datum/outfit/O = new
        for (var/list in O.items_to_spawn)
            for (var/slot in list)
                if (text2num(slot) == "")
                    fail("Outfit [O.type] : list [list] doesn't have a number index at slot [slot].")

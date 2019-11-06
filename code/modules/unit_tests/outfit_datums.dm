/datum/unit_test/outfit_datums

// Make sure that the slots indexes used by outfit datums are indeed slot indexes.

/datum/unit_test/outfit_datums/start()
    for (var/type in subtypesof(/datum/outfit))
        var/datum/outfit/O = new
        for (var/L in O.items_to_spawn)
            for (var/slot in L)
                if (text2num(slot) == "")
                    fail("Outfit [O.type] : list [L] doesn't have a number index at slot [slot].")

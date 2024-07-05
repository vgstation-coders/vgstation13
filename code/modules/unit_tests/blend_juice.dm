/datum/unit_test/grind_juice/start()
    var/turf/T = locate(100,100,1) // just for chemical reactions so they don't runtime
    var/obj/item/weapon/reagent_containers/glass/mortar/M = new(T)
    var/obj/machinery/reagentgrinder/R = new(T)
    var/mob/user = new(T)
    var/obj/item/O
    for(var/itempath in subtypesof(/obj/item))
        O = itempath
        if(!initial(O.blend_reagent) && !initial(O.juice_reagent) && (!initial(O.grind_flags) || (initial(O.flags) & NOREACT)))
            continue // NOREACT is here because any transferred reagents will react on grind, doesn't fit tests so skipped
        O = new itempath(T)
        if(O.reagents && !O.reagents.amount_cache.len && !O.blend_reagent && !O.juice_reagent)
            QDEL_NULL(O) // nothing comes from this item so move on
            continue
        R.holdingitems += O
        if(O.juice_reagent)
            R.juice()
            if(!R.beaker.reagents.has_reagent(O.juice_reagent))
                fail("Reagent ID [O.juice_reagent] was not created from juicing [O.type] in [R].")
            R.beaker.reagents.clear_reagents()
            QDEL_LIST_CUT(R.holdingitems)
            O = new itempath(T)
            R.holdingitems += O
        var/non_nutriment_volume
        var/required
        var/amount
        var/list/reagent_check
        if(O.blend_reagent || (O.grind_flags & GRIND_TRANSFER))
            reagent_check = get_reagents_to_check(O)
            non_nutriment_volume = get_non_nutriment_volume(O)
            required = clamp(R.beaker.reagents.maximum_volume - non_nutriment_volume, 0, O.grind_amount)
            R.grind()
            if(reagent_check && !R.beaker.reagents.has_all_reagents(reagent_check))
                fail("[O.type] does not have the reagents [json_encode(reagent_check)] from being grinded in [R]. (got [R.beaker.reagents.get_reagent_ids()])")
            if(required)
                if(!R.beaker.reagents.has_reagent(O.blend_reagent))
                    fail("Reagent ID [O.blend_reagent] was not created from grinding [O.type] in [R].")
                amount = R.beaker.reagents.get_reagent_amount(O.blend_reagent)
                if(amount < required)
                    fail("Reagent ID [O.blend_reagent] was not created to [required] units from grinding [O.type] in [R]. (got [amount])")
        R.beaker.reagents.clear_reagents()
        QDEL_LIST_CUT(R.holdingitems)
        O = new itempath(T)
        M.crushable = O
        reagent_check = get_reagents_to_check(O)
        non_nutriment_volume = get_non_nutriment_volume(O)
        required = clamp(M.reagents.maximum_volume - non_nutriment_volume, 0, O.grind_amount)
        M.attack_self(user)
        if(O.juice_reagent) //mortars prioritise this
            if(!M.reagents.has_reagent(O.juice_reagent))
                fail("Reagent ID [O.juice_reagent] was not created from juicing [O.type] in [M].")
        else if(O.blend_reagent || (O.grind_flags & GRIND_TRANSFER))
            //if(reagent_check && !M.reagents.has_all_reagents(reagent_check))
            //    fail("[O.type] does not have the reagents [json_encode(reagent_check)] from being grinded in [M]. (got [M.reagents.get_reagent_ids()])")
            if(required)
                if(!M.reagents.has_reagent(O.blend_reagent))
                    fail("Reagent ID [O.blend_reagent] was not created from grinding [O.type] in [M].")
                amount = M.reagents.get_reagent_amount(O.blend_reagent)
                if(amount < required)
                    fail("Reagent ID [O.blend_reagent] was not created to [required] units from grinding [O.type] in [M]. (got [amount])")
        M.crushable = null
        M.reagents.clear_reagents()
        QDEL_NULL(O)
    qdel(M)
    qdel(R)
    qdel(user)

/datum/unit_test/grind_juice/proc/get_non_nutriment_volume(obj/item/O)
    if(!O.reagents)
        return 0
    . = O.reagents.total_volume
    if(O.grind_flags & GRIND_NUTRIMENT_TO_REAGENT)
        if(.)
            . -= O.reagents.get_reagent_amount(NUTRIMENT)
            
/datum/unit_test/grind_juice/proc/get_reagents_to_check(obj/item/O)
    if(!O.reagents)
        return null
    var/list/L = get_list_of_keys(O.reagents.amount_cache.Copy())
    if(O.grind_flags & GRIND_NUTRIMENT_TO_REAGENT)
        L.Remove(NUTRIMENT)
    return L
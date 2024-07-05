/datum/unit_test/grind_juice/start()
    var/turf/T = locate(100,100,1) // just for chemical reactions so they don't runtime
    var/obj/item/weapon/reagent_containers/glass/mortar/M = new(T)
    var/obj/machinery/reagentgrinder/R = new(T)
    var/mob/user = new(T)
    var/obj/item/O
    for(var/itempath in subtypesof(/obj/item))
        O = itempath
        if(!initial(O.blend_reagent) && !initial(O.juice_reagent) && !initial(O.grind_flags))
            continue
        O = new itempath(T)
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
            non_nutriment_volume = O.reagents ? (O.grind_flags & GRIND_NUTRIMENT_TO_REAGENT ? O.reagents.total_volume - O.reagents.get_reagent_amount(NUTRIMENT) : O.reagents.total_volume) : 0
            required = clamp(R.beaker.reagents.maximum_volume - non_nutriment_volume, 0, O.grind_amount)
            reagent_check = O.reagents ? get_list_of_keys(O.reagents.amount_cache.Copy()) : null
            R.grind()
            if(reagent_check && !R.beaker.reagents.has_all_reagents(reagent_check))
                fail("[O.type] does not have the reagents [json_encode(reagent_check)] from being grinded in [R]. (got [json_encode(get_list_of_keys(R.beaker.reagents.amount_cache))])")
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
        non_nutriment_volume = O.reagents ? (O.grind_flags & GRIND_NUTRIMENT_TO_REAGENT ? O.reagents.total_volume - O.reagents.get_reagent_amount(NUTRIMENT) : O.reagents.total_volume) : 0
        required = clamp(M.reagents.maximum_volume - non_nutriment_volume, 0, O.grind_amount)
        reagent_check = O.reagents ? get_list_of_keys(O.reagents.amount_cache.Copy()) : null
        M.attack_self(user)
        if(O.juice_reagent) //mortars prioritise this
            if(!M.reagents.has_reagent(O.juice_reagent))
                fail("Reagent ID [O.juice_reagent] was not created from juicing [O.type] in [M].")
        else if(O.blend_reagent || (O.grind_flags & GRIND_TRANSFER))
            if(reagent_check && !M.reagents.has_all_reagents(reagent_check))
                fail("[O.type] does not have the reagents [json_encode(reagent_check)] from being grinded in [M]. (got [json_encode(get_list_of_keys(M.reagents.amount_cache))])")
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
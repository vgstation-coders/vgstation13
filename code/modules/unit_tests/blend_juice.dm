/datum/unit_test/grind_juice/start()
    var/turf/T = locate(100,100,1) // just for chemical reactions so they don't runtime
    var/obj/item/weapon/reagent_containers/glass/mortar/M = new(T)
    var/obj/machinery/reagentgrinder/R = new(T)
    var/mob/user = new(T)
    var/obj/item/I
    for(var/itempath in subtypesof(/obj/item))
        I = itempath
        if(!initial(I.blend_reagent) && !initial(I.juice_reagent)) // not testing transfers for now
            continue
        I = new itempath(T)
        R.holdingitems += I
        if(I.juice_reagent)
            R.juice()
            if(!R.beaker.reagents.has_reagent(I.juice_reagent))
                fail("Reagent ID [I.juice_reagent] was not created from juicing [I.type] in [R].")
            R.beaker.reagents.clear_reagents()
            QDEL_LIST_CUT(R.holdingitems)
            I = new itempath(T)
            R.holdingitems += I
        var/non_nutriment_volume
        var/required
        var/amount
        if(I.blend_reagent)
            non_nutriment_volume = I.reagents ? I.reagents.total_volume - I.reagents.get_reagent_amount(NUTRIMENT) : 0
            required = clamp(R.beaker.reagents.maximum_volume - non_nutriment_volume, 0, I.grind_amount)
            R.grind()
            if(required)
                if(!R.beaker.reagents.has_reagent(I.blend_reagent))
                    fail("Reagent ID [I.blend_reagent] was not created from grinding [I.type] in [R].")
                amount = R.beaker.reagents.get_reagent_amount(I.blend_reagent)
                if(amount < required)
                    fail("Reagent ID [I.blend_reagent] was not created to [required] units from grinding [I.type] in [R]. (got [amount])")
        R.beaker.reagents.clear_reagents()
        QDEL_LIST_CUT(R.holdingitems)
        I = new itempath(T)
        M.crushable = I
        non_nutriment_volume = I.reagents ? I.reagents.total_volume - I.reagents.get_reagent_amount(NUTRIMENT) : 0
        required = clamp(M.reagents.maximum_volume - non_nutriment_volume, 0, I.grind_amount)
        M.attack_self(user)
        if(I.juice_reagent) //mortars prioritise this
            if(!M.reagents.has_reagent(I.juice_reagent))
                fail("Reagent ID [I.juice_reagent] was not created from juicing [I.type] in [M].")
        else if(I.blend_reagent && required)
            if(!M.reagents.has_reagent(I.blend_reagent))
                fail("Reagent ID [I.blend_reagent] was not created from grinding [I.type] in [M].")
            amount = M.reagents.get_reagent_amount(I.blend_reagent)
            if(amount < required)
                fail("Reagent ID [I.blend_reagent] was not created to [required] units from grinding [I.type] in [M]. (got [amount])")
        M.crushable = null
        M.reagents.clear_reagents()
        QDEL_NULL(I)
    qdel(M)
    qdel(R)
    qdel(user)
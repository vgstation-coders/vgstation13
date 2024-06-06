/datum/unit_test/grind_juice/start()
    var/obj/item/weapon/reagent_containers/glass/mortar/M = new
    var/obj/machinery/reagentgrinder/R = new
    var/mob/user = new
    var/obj/item/I
    for(var/itempath in subtypesof(/obj/item))
        I = itempath
        if(!initial(I.blend_reagent) && !initial(I.juice_reagent)) // not testing transfers for now
            continue
        I = new itempath
        R.holdingitems += I
        R.juice()
        if(!R.beaker.reagents.has_reagent(I.juice_reagent))
            fail("Reagent ID [I.juice_reagent] was not created from juicing [I] in [R].")
        R.holdingitems.Cut()
        R.beaker.reagents.clear_reagents()
        if(!I || I.gcDestroyed)
            I = new itempath
        R.holdingitems += I
        R.grind()
        var/amount
        var/required = I.grind_amount
        if(I.blend_reagent)
            if(!R.beaker.reagents.has_reagent(I.blend_reagent))
                fail("Reagent ID [I.blend_reagent] was not created from blending [I] in [R].")
            amount = R.beaker.reagents.get_reagent_amount(I.blend_reagent)
            if(amount < required)
                fail("Reagent ID [I.blend_reagent] was not created to [required] units from blending [I] in [R]. (got [amount])")
        R.holdingitems.Cut()
        R.beaker.reagents.clear_reagents()
        if(!I || I.gcDestroyed)
            I = new itempath
        M.crushable = I
        M.attack_self(user)
        if(I.juice_reagent) //mortars prioritise this
            if(!M.reagents.has_reagent(I.juice_reagent))
                fail("Reagent ID [I.juice_reagent] was not created from juicing \the [I] in [M].")
        else if(I.blend_reagent)
            if(!M.reagents.has_reagent(I.blend_reagent))
                fail("Reagent ID [I.blend_reagent] was not created from blending \the [I] in [M].")
            amount = M.reagents.get_reagent_amount(I.blend_reagent)
            if(amount < required)
                fail("Reagent ID [I.blend_reagent] was not created to [required] units from blending [I] in [M]. (got [amount])")
        M.crushable = null
        M.reagents.clear_reagents()
        QDEL_NULL(I)
    qdel(M)
    qdel(R)
    qdel(user)
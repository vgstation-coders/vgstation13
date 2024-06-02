/datum/unit_test/grind_juice/start()
    var/obj/item/weapon/reagent_containers/glass/mortar/M = new
    var/obj/machinery/reagentgrinder/R = new
    var/mob/user = new
    var/lists = list(juice_items,blend_items)
    for(var/list/items in lists)
        for(var/type in items)
            if(islist(items[type]))
                var/list/reagentlist = items[type]
                if(!reagentlist.len) //not testing this for now
                    continue
                R.holdingitems += new type
                var/name = "[R.holdingitems[1]]"
                if(items == juice_items)
                    R.juice(TRUE)
                else
                    R.grind(TRUE)
                if(!R.beaker.reagents.has_reagent(reagentlist[1]))
                    fail("Reagent ID [reagentlist[1]] was not created from [items == juice_items ? "juic" : "grind"]ing [name] in [R].")
                var/amount = R.beaker.reagents.get_reagent_amount(reagentlist[1])
                var/required = abs(reagentlist[reagentlist[1]])
                if(amount < required)
                    fail("Reagent ID [reagentlist[1]] was not created to [required] units from [items == juice_items ? "juic" : "grind"]ing [name] in [R]. (got [amount])")
                QDEL_LIST_CUT(R.holdingitems)
                R.beaker.reagents.clear_reagents()
                if(items == blend_items && (type in juice_items)) //mortars prioritise this so skip it
                    continue
                M.crushable = new type
                name = M.crushable.name
                M.attack_self(user)
                if(!M.reagents.has_reagent(reagentlist[1]))
                    fail("Reagent ID [reagentlist[1]] was not created from [items == juice_items ? "juic" : "grind"]ing \the [name] in [M].")
                amount = M.reagents.get_reagent_amount(reagentlist[1])
                if(amount < required)
                    fail("Reagent ID [reagentlist[1]] was not created to [required] units from [items == juice_items ? "juic" : "grind"]ing [name] in [M]. (got [amount])")
                QDEL_NULL(M.crushable)
                M.reagents.clear_reagents()
    qdel(M)
    qdel(R)
    qdel(user)
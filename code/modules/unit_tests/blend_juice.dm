/datum/unit_test/grind_juice/start()
    var/obj/item/weapon/reagent_containers/glass/mortar/M = new
    var/mob/user = new
    var/lists = list(juice_items,blend_items)
    for(var/list/items in lists)
        for(var/type in items)
            if(islist(items[type]))
                var/list/reagentlist = items[type]
                if(!reagentlist.len)
                    continue
                if(items == blend_items && (type in juice_items)) //mortars prioritise this so skip it
                    continue
                var/obj/item/object = new type
                M.attackby(object,user)
                M.attack_self(user)
                if(!M.reagents.has_reagent(reagentlist[1]))
                    fail("Reagent ID [reagentlist[1]] was not created from grinding [object].")
                qdel(object)
                M.reagents.clear_reagents()
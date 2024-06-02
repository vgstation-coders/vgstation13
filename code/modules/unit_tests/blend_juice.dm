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
                var/obj/item/object = new type
                M.attackby(object,user)
                M.attack_self(user)
                assert_eq(M.reagents.has_reagent(reagentlist[1]), TRUE)
                qdel(object)
                M.reagents.clear_reagents()
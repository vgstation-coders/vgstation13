//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_spaghetti()
    if(get_item_by_slot(slot_l_store))
        handle_spaghetti_pocket(slot_l_store)
    if(get_item_by_slot(slot_r_store))
        handle_spaghetti_pocket(slot_r_store)

/mob/living/carbon/human/proc/handle_spaghetti_pocket(var/slot)
    var/obj/item/I = get_item_by_slot(slot)
    if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti))
        if(prob(5))
            visible_message("<span class='notice'>[src] spills his spaghetti</span>","<span class='notice'>You spill your spaghetti</span>")
            new /obj/effect/decal/cleanable/spaghetti_spill(src.loc)
            playsound(loc, 'sound/effects/splat.ogg', 50, 1)
            qdel(I)
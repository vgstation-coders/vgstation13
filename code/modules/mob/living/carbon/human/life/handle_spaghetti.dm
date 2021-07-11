//Refer to life.dm for caller

/mob/living/carbon/human/proc/handle_spaghetti(var/chance) //Checks pockets for spaghetti -kanef
    if(get_item_by_slot(slot_l_store))
        handle_spaghetti_pocket(slot_l_store,chance)
    if(get_item_by_slot(slot_r_store))
        handle_spaghetti_pocket(slot_r_store,chance)

/mob/living/carbon/human/proc/handle_spaghetti_pocket(var/slot,var/chance) //Acts on specific pocket -kanef
    var/obj/item/I = get_item_by_slot(slot)
    if(istype(I,/obj/item/weapon/reagent_containers/food/snacks/boiledspaghetti))
        if(prob(chance))
            visible_message("<span class='notice'>[src] spills their spaghetti.</span>","<span class='notice'>You spill your spaghetti.</span>")
            if (prob(90)) //90% chance to make you stutter what you say for a while, otherwise nothing at all, you spilled your spaghetti
                apply_effect(10, STUTTER)
            else
                Mute(10)
            new /obj/effect/decal/cleanable/spaghetti_spill(src.loc) //Spawn the mess
            playsound(loc, 'sound/effects/splat.ogg', 50, 1)
            qdel(I)
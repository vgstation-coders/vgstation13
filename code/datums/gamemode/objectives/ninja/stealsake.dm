/datum/objective/stealsake
    name = "\[Ninja\] Steal a bottle of sake"
    explanation_text = "You have gone without a drink for far too long. Steal a bottle of sake, the only beverage worthy of your consumption."

/datum/objective/stealsake/IsFulfilled()
    if(..())
        return TRUE
    
    if (owner && owner.current)
        for(var/obj/O in get_contents_in_object(owner.current))
            if (istype(O, /obj/item/weapon/reagent_containers/food/drinks/bottle/sake))
                return TRUE
    return FALSE

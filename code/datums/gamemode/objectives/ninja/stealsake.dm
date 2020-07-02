/datum/objective/stealsake
    name = "\[Ninja\] Steal sake"
    explanation_text = "Steal a bottle of sake, or have sake in your system when you escape."

/datum/objective/stealsake/IsFulfilled()
    if(..())
        return TRUE
    
    if (owner && owner.current)
        for(var/obj/item/weapon/reagent_containers/O in recursive_type_check(owner.current, /obj/item/weapon/reagent_containers))
            if (istype(O, /obj/item/weapon/reagent_containers/food/drinks/bottle/sake))
                return TRUE
            else if(O.reagents.has_reagent(SAKE))
                return TRUE
        if (owner.current.reagents.has_reagent(SAKE))
            return TRUE
    return FALSE

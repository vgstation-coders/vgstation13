/datum/objective/stealsake
    name = "\[Ninja\] Steal a bottle of sake"
    explanation_text = "Steal a bottle of Uchuujin Junmai Ginjo Sake."

/datum/objective/stealsake/IsFulfilled()
    if(..())
        return TRUE
    
    if (owner && owner.current)
        for(var/obj/O in get_contents_in_object(owner.current))
            if (istype(O, /obj/item/weapon/reagent_containers/food/drinks/bottle/sake))
                return TRUE
    return FALSE

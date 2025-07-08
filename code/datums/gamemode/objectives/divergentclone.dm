/datum/objective/freeform/divergentclone_neutral
    explanation_text = "Convince the world that you are the real <person>, or at least as real as the other copy."

/datum/objective/freeform/divergentclone_neutral/format_explanation()
    return "Convince the world that you are the real [owner.name], or at least as real as the other copy."

/datum/objective/freeform/divergentclone_neutral/PostAppend()
    explanation_text = format_explanation()
    return TRUE

/datum/objective/freeform/divergentclone_evil
    explanation_text = "Convince the world that you are the real <person> at any cost, be that by talk, violence or subterfuge. Do not let anyone get in your way, including your original copy."

/datum/objective/freeform/divergentclone_evil/format_explanation()
    return "Convince the world that you are the real [owner.name] at any cost, be that by talk, violence or subterfuge. Do not let anyone get in your way, including your original copy."

/datum/objective/freeform/divergentclone_evil/PostAppend()
    explanation_text = format_explanation()
    return TRUE

/datum/objective/divergentclone/spawn_in
    explanation_text = "Reincarnate as a divergent clone."
    name = "Reincarnate"

/datum/objective/divergentclone/spawn_in/IsFulfilled()
    if(..())
        return TRUE
    if(!owner || !owner.current)
        return FALSE

    var/datum/role/divergentclone/role = owner.GetRole(DIVERGENTCLONE)
    if(role?.has_spawned_in)
        return TRUE

/datum/objective/acquire_personal_id
    explanation_text = "Acquire an ID card matching your name or DNA."
    name = "Acquire personal ID card"

/datum/objective/acquire_personal_id/IsFulfilled()
    if(..())
        return TRUE
    
    if(!owner || !owner.current)
        return FALSE
    
    for(var/obj/O in get_contents_in_object(owner.current))
        var/obj/item/weapon/card/id/I
        if(istype(O, /obj/item/weapon/card/id))
            I = O
        else if(istype(O, /obj/item/device/pda))
            var/obj/item/device/pda/P = O
            I = P.id
        else
            continue
        var/datum/dna/D = owner.current.dna
        if((I?.dna_hash == D.unique_enzymes) || (I?.registered_name == owner.name))
            return TRUE
            
    return FALSE
        




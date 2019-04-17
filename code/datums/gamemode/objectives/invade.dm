/datum/objective/invade
    name = "Invade the station."
    explanation_text = "We must grow and expand. Fill this station with our spores. Cover X station tiles."
    var/target = 0

/datum/objective/invade/PostAppend()
    var/datum/faction/blob_conglomerate/F = faction
    if (!istype(F))
        return FALSE
    target = F.blobwincount
    explanation_text = "We must grow and expand. Fill this station with our spores. Cover [target] station tiles."
    return TRUE

/datum/objective/invade/IsFulfilled()
    if (..())
        return TRUE
    else
        return (blobs.len >= (target * 0.95))

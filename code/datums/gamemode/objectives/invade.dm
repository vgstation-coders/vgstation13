/datum/objective/invade
    name = "Invade the station."
    explanation_text = "We must grow and expand. Fill this station with our spores. Cover X station tiles."

/datum/objective/invade/PostAppend()
    explanation_text = "We must grow and expand. Fill this station with our spores. Cover [map.blobwincount] station tiles."

/datum/objective/invade/IsFulfilled()
    if (..())
        return TRUE
    else
        return (map.blobwincount <= blobs)
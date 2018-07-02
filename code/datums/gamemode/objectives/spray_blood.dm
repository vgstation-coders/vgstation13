// Legacy cult

/datum/objective/spray_blood
    explanation_text = "Spray blood on the station to thin the veil of reality and allow Nar-Sie to come closer from us."
    name = "Spray blood on the station."
    var/floor_limit = 15 // Abritary, to fix later

    flags =  FACTION_OBJECTIVE


/datum/objective/spray_blood/IsFulfilled()
    var/datum/faction/cult/narsie/cult_fac = faction
    return (cult_fac.bloody_floors.len >= floor_limit)

/datum/objective/summon_narsie/feedbackText()
    return "<span class = 'sinister'>You succesfully defiled the floors of this station. The veil between this world and Nar'Sie grows thinner.</span>"

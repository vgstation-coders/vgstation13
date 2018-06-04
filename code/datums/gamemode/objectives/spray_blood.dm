// Legacy cult

/datum/objective/spray_blood
    explanation_text = "Spray blood on the station to thin the veil of reality and allow Nar-Sie to come closer from us."
    name = "Spray blood on the station."
    var/floor_limit = 150 // Abritary, to fix later
    var/datum/faction/cult/narsie/cult_fac = null

/datum/objective/spray_blood/IsFulfilled()
    return (cult_fac.bloody_floors.len >= floor_limit)
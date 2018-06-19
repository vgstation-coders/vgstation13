// Legacy cult

/datum/objective/convert_people
    explanation_text = "Gather an army of followers "
    name = "Convert people to the Cult of the Geometer of blood."
    var/cultists_target = 9
    var/datum/faction/cult/narsie/cult_fac = null

/datum/objective/convert_people/IsFulfilled()
    return (cult_fac.members >= cultists_target)

/datum/objective/summon_narsie/feedbackText()
    return "<span class = 'sinister'>You succesfully converted enough people to server the Geometer of Blood. The veil between this world and Nar'Sie grows thinner.</span>"
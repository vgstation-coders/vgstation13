// Legacy cult

/datum/objective/convert_people
    explanation_text = "Gather an army of followers "
    name = "Convert people to the Cult of the Geometer of blood."
    var/cultists_target = 3

    flags =  FACTION_OBJECTIVE


/datum/objective/convert_people/IsFulfilled()
    return (faction.members.len >= cultists_target)

/datum/objective/summon_narsie/feedbackText()
    return "<span class = 'sinister'>You succesfully converted enough people to server the Geometer of Blood. The veil between this world and Nar'Sie grows thinner.</span>"
/datum/objective/acquire_blood
	var/blood_objective = 150 // -- I don't remember the actual blood count needed, this is a placeholder.
	explanation_text = "Acquire 500 units of blood."
	name = "(vampire) Acquire blood"

/datum/objective/acquire_blood/New()
	blood_objective = round(rand(3, 8)) * 50 // Between 150 and 400.

/datum/objective/acquire_blood/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/vampire/V = owner.GetRole(VAMPIRE)
	if (!V)
		message_admins("BUG: [owner.current] was given a vampire objective but is not a vampire.")
		return FALSE

	if (V.blood_total >= blood_objective)
		return TRUE

	return FALSE
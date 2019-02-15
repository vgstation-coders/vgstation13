/datum/objective/acquire_blood
	var/blood_objective = 150 // -- I don't remember the actual blood count needed, this is a placeholder.
	explanation_text = "Acquire 150 units of blood."
	name = "(vampire) Acquire blood"

/datum/objective/acquire_blood/PostAppend()
	blood_objective = round(rand(3, 8)) * 50 // Between 150 and 400.
	explanation_text = "Acquire [blood_objective] units of blood."
	return TRUE

/datum/objective/acquire_blood/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/vampire/V = isvampire(owner.current)
	if (!V)
		message_admins("BUG: [owner.current] was given a vampire objective but is not a vampire.")
		return FALSE

	if (V.total_blood_collected >= blood_objective)
		return TRUE

	return FALSE

/datum/objective/acquire_soulpower
	var/soul_objective = 100
	explanation_text = "Acquire 100 soul power from living and thinking humans.."
	name = "(vampire) Acquire soul power"

/datum/objective/acquire_soulpower/PostAppend()
	soul_objective = round(rand(2, 6)) * 50 // Between 100 and 300.
	explanation_text = "Acquire [soul_objective] soul power from living and thinking humans."
	return TRUE

/datum/objective/acquire_soulpower/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/vampire/V = isvampire(owner.current)
	if (!V)
		message_admins("BUG: [owner.current] was given a vampire objective but is not a vampire.")
		return FALSE

	if (V.soulpower >= soul_objective)
		return TRUE

	return FALSE

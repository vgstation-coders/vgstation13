/datum/objective/pulse_demon/infest
	explanation_text = "Hijack APCs."
	name = "Hijack APCs (as Pulse Demon)"
	var/amount = 20

/datum/objective/pulse_demon/infesty/PostAppend()
	. = ..()
	amount = rand(3,5) * 5
	explanation_text = "Hijack [amount] APCs"

/datum/objective/pulse_demon/infest/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/pulse_demon/PD = owner.GetRole(PULSEDEMON)
	return PD.controlled_apcs.len >= amount

/datum/objective/pulse_demon/tamper
	explanation_text = "Cause mischief amongst the machines in rooms with APCs you've hijacked, and defend yourself from anyone trying to stop you."
	name = "Tamper Machinery"

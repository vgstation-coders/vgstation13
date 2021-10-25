/datum/objective/pulse_demon/infest
	explanation_text = "Hijack 20 APCs."
	name = "Hijack APCs (as Pulse Demon)"

/datum/objective/pulse_demon/infest/IsFulfilled()
	if (..())
		return TRUE
	var/datum/role/pulse_demon/PD = owner.GetRole(PULSEDEMON)
	return PD.controlled_apcs.len >= 20

/datum/objective/pulse_demon/tamper
	explanation_text = "Cause mischief amongst the machines in rooms with APCs you've hijacked, and defend yourself from anyone trying to stop you."
	name = "Tamper Machinery"

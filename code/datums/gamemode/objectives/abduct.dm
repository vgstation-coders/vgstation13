/datum/objective/abduct
	explanation_text = "Abduct qualified personnel from a departement."
	name = "(vox raiders) Abduct personnel"
	var/num

/datum/objective/abduct/New(var/dept, var/max_abduct=1)
	. = ..()
	num = rand(1, max_abduct)
	explanation_text = "Abduct [num] qualified personnel from the [dept] departement."

/datum/objective/abduct/IsFulfilled()
	var/datum/faction/vox_shoal/VS = faction
	if (!VS)
		return FALSE
	return VS.got_personnel >= num
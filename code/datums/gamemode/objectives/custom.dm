/datum/objective/custom
	name = "Custom objective"
	explanation_text = "Just be yourself"
	force_success = TRUE

var/list/predefined_custom_objectives = list(
	"Go on a date with the station's AI.",
	"Rename all rooms in the station to something silly.",
	"Accelerate.",
	"Steal every last pen on the station. Every single one of them.",
	"Get your revenge.",
	"Do as you wish.",
)

//if user passed - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(var/mob/user, var/datum/faction/faction)
	if (!user)
		return
	if (faction)
		src.faction = faction
	var/txt = stripped_input(user, "What should be the text of this objective?","Custom objective", pick(predefined_custom_objectives), MAX_OBJECTIVE_LEN)
	explanation_text = txt

// Fullfilled as per admin wishes
/datum/objective/custom
	name = "Custom objective"
	explanation_text = "Just be yourself"
	force_success = TRUE

var/list/predefined_custom_objectives = list(
	// Open ended ; low chance of being picked
	10;"Go on a date with the station's AI.",
	10;"Rename all rooms in the station to something silly.",
	10;"Accelerate.",
	10;"Steal every last pen on the station. Every single one of them.",
	10;"Get your revenge.",
	10;"Do as you wish.",

	// Slightly more directed. Higher chance of being picked.
	50;"Steal one of the key items to NanoTrasen's organisation. This includes a pinpointer, a nuclear authentification disk, and a hand teleporter.",
	50;"Disrupt the station's command structure.",
	50;"Sabotage the station's power net and atmospheric regulation system.",
	50;"Sabotage the station's medical facilities.",
	50;"Sabotage the station's research activities.",
	50;"Cripple the station's mining activities.",
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
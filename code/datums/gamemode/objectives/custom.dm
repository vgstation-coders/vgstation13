/datum/objective/custom
	name = "Custom objective"
	explanation_text = "Just be yourself"
	force_success = TRUE

var/list/predefined_custom_objectives = list(	
	// Open ended ; low chance of being picked10; "Go on a date with the station's AI.",
	"Rename all rooms in the station to something silly." = 10,
	"Accelerate." = 10,
	"Steal every last pen on the station. Every single one of them." = 10,
	"Get your revenge." = 10,
	"Do as you wish." = 10,

	// Slightly more directed. Higher chance of being picked.
	"Steal one of the key items to NanoTrasen's organisation. This includes a pinpointer, a nuclear authentification disk, and a hand teleporter." = 50,
	"Disrupt the station's command structure." = 50,
	"Sabotage the station's power net and atmospheric regulation system." = 50,
	"Sabotage the station's medical facilities." = 50,
	"Sabotage the station's research activities." = 50,
	"Cripple the station's mining activities." = 50,
	)

//if user passed - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(var/mob/user, var/datum/faction/faction)
	if (!user)
		return
	if (faction)
		src.faction = faction

	var/default_objective = pickweight(predefined_custom_objectives)

	var/txt = stripped_input(user, "What should be the text of this objective?","Custom objective", default_objective, MAX_OBJECTIVE_LEN)
	explanation_text = txt

// Fullfilled as per admin wishes
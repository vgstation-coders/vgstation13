/datum/objective/custom
	name = "Custom objective"
	explanation_text = "Just be yourself"
	force_success = TRUE

//if not auto generated - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(var/text, var/auto_target = TRUE, var/is_auto_generated = TRUE, var/datum/faction/faction)
	if (is_auto_generated)
		return
	if (faction)
		src.faction = faction
	var/txt = input(owner, "What should be the text of this objective?","Custom objective", "Just be yourself")
	explanation_text = txt

// Fullfilled as per admin wishes
/datum/objective/custom
	name = "Custom objective"
	explanation_text = "Just be yourself"
	force_success = TRUE

//if user passed - means that this will be called as an explicit custom objective and will require user input
/datum/objective/custom/New(var/mob/user, var/datum/faction/faction)
	if (!user)
		return
	if (faction)
		src.faction = faction
	var/txt = input(user, "What should be the text of this objective?","Custom objective", "Just be yourself")
	explanation_text = txt

// Fullfilled as per admin wishes
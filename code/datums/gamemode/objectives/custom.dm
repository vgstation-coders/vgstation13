/datum/objective/custom
	name = "Custom objective"
	explanation_text = "Just be yourself"

/datum/objective/custom/New(var/text,var/auto_target = TRUE, var/mob/user)
	if (!user)
		return
	var/txt = input(user,"What should be the text of this objective?","Custom objective", "Just be yourself")
	explanation_text = txt

// Fullfilled as per admin wishes
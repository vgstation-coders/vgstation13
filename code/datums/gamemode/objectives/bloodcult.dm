
//We don't bother with IsFulfilled() in here, these aren't shown on the scoreboard, and mostly serve for cultists checking their notes.

/datum/objective/bloodcult
	name = "Cultist of Nar-Sie"
	explanation_text = "Nar-Sie, the Geometer of Blood, harbinger of gunk and chaos, has guided you to this Space Station to spread the cult's influence, and ultimately bring it into the blood realm. Occult activities aboard the station will eventually bring forth an Eclipse, during which you may perform your last ritual."
	flags = FREEFORM_OBJECTIVE


/datum/objective/bloodcult_escape
	name = "Cultist of Nar-Sie (Escape)"
	explanation_text = "The Eclipse came and went, and you didn't perform the ritual. No matter, you may find another opportunity aboard another Space Station. Escape alive and free aboard the Escape Shuttle with as many cultists as possible."
	flags = FREEFORM_OBJECTIVE
	var/escaped_on_shuttle = 0
	var/escaped_on_pods = 0

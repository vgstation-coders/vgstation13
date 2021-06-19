/datum/objective/spider
	name = "Spider."
	explanation_text = "Terrorize the crew, and above all, break every light source you come across."
	var/broken_lights = 0

/datum/objective/spider/extraInfo()
	explanation_text += " ([broken_lights] lights broken by spiders in total.)"

/datum/objective/spider/IsFulfilled()
	if (..())
		return TRUE

	if (broken_lights > 1)
		return TRUE//it's more of a formality really
	return FALSE

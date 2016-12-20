/mob/living/carbon/monkey/say_quote(var/text)
	return "chimpers, [text]";

/mob/living/carbon/monkey/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(other)
		other = other.GetSource()
	if(issilicon(other))
		return 1

	if(speaking && speaking.name == LANGUAGE_GALACTIC_COMMON)
		if(dexterity_check())
			return 1

	return ..()

/mob/living/carbon/monkey/can_read()
	if(dexterity_check())
		return TRUE
	return ..()

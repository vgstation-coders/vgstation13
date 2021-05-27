var/global/list/outbreak_level_words=list(
	/* 1 */ 'sound/AI/one.ogg',
	/* 2 */ 'sound/AI/two.ogg',
	/* 3 */ 'sound/AI/three.ogg',
	/* 4 */ 'sound/AI/four.ogg',
	/* 5 */ 'sound/AI/five.ogg',
	/* 6 */ 'sound/AI/six.ogg',
	/* 7 */ 'sound/AI/seven.ogg',
	/* 8 */ 'sound/AI/eight.ogg' /* outbreak of a disease of combined badness level of 15 or 16, yikes! */,
)	/* 9 */ /*This one is reserved for Blob, we don't use it.*/

/proc/biohazard_alert(var/level)
	var/datum/command_alert/biohazard_alert/CA = new /datum/command_alert/biohazard_alert
	if (level)//The initial Blob announcement will have a random level between 4 and 7
		CA.level_max = level
		CA.level_min = level
	return CA.announce()

/*
#warn TELL N3X15 TO COMMENT THIS SHIT OUT
/mob/verb/test_biohazard()
	biohazard_alert()
*/

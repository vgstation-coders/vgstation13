var/global/list/outbreak_level_words=list(
	/* 1 */ 'sound/AI/one.ogg',
	/* 2 */ 'sound/AI/two.ogg',
	/* 3 */ 'sound/AI/three.ogg',
	/* 4 */ 'sound/AI/four.ogg',
	/* 5 */ 'sound/AI/five.ogg',
	/* 6 */ 'sound/AI/six.ogg',
	/* 7 */ 'sound/AI/seven.ogg',
)
/proc/biohazard_alert()
	command_alert(/datum/command_alert/biohazard_alert)

/proc/biohazard_alert_minor()
	command_alert(/datum/command_alert/biohazard_alert/minor)

/proc/biohazard_alert_major()
	command_alert(/datum/command_alert/biohazard_alert/major)

/*
#warn TELL N3X15 TO COMMENT THIS SHIT OUT
/mob/verb/test_biohazard()
	biohazard_alert()
*/

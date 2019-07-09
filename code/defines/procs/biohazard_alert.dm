var/global/list/outbreak_level_words=list(
	/* 1 */ 'sound/vox_fem/one.ogg',
	/* 2 */ 'sound/vox_fem/two.ogg',
	/* 3 */ 'sound/vox_fem/three.ogg',
	/* 4 */ 'sound/vox_fem/four.ogg',
	/* 5 */ 'sound/vox_fem/five.ogg',
	/* 6 */ 'sound/vox_fem/six.ogg',
	/* 7 */ 'sound/vox_fem/seven.ogg',
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

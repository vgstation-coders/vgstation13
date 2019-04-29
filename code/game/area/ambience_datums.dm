//the datums are more apt to be for things that can loop. But the "single use" files can still be done. they should just have a long cooldown on them.

//generic ambience.


/datum/ambience/generic1
	sound = 'sound/ambience/ambigen1.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic2
	sound = 'sound/ambience/ambigen2.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic3
	sound = 'sound/ambience/ambigen3.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic4
	sound = 'sound/ambience/ambigen4.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic5
	sound = 'sound/ambience/ambigen5.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic6
	sound = 'sound/ambience/ambigen6.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic7
	sound = 'sound/ambience/ambigen7.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic8
	sound = 'sound/ambience/ambigen8.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic9
	sound = 'sound/ambience/ambigen9.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic10
	sound = 'sound/ambience/ambigen10.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic11
	sound = 'sound/ambience/ambigen11.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic12
	sound = 'sound/ambience/ambigen12.ogg'
	length = 15 SECONDS + 30 SECONDS

/datum/ambience/generic13
	sound = 'sound/ambience/ambigen13.ogg'
	length = 15 SECONDS + 30 SECONDS
	prob_fire = 0 // Disabled for now.

/datum/ambience/generic14
	sound = 'sound/ambience/ambigen14.ogg'
	length = 15 SECONDS + 30 SECONDS

//tcomms.
/datum/ambience/tcomms1
	sound = 'sound/ambience/ambisin2.ogg'
	length = 12 SECONDS + 30 SECONDS

/datum/ambience/tcomms2
	sound = 'sound/ambience/signal.ogg'
	length = 11 SECONDS + 30 SECONDS

/datum/ambience/tcomms3
	sound = 'sound/ambience/ambigen10.ogg'
	length = 20 SECONDS + 20 SECONDS

//maint.
/datum/ambience/maint1
	sound = 'sound/ambience/spookymaint1.ogg'
	length = 41 SECONDS + 30 SECONDS //smaller ""cooldown""

/datum/ambience/maint2
	sound = 'sound/ambience/spookymaint2.ogg'
	length = 34 SECONDS + 30 SECONDS //smaller ""cooldown""


//the mines.
/datum/ambience/minecraft
	sound = 'sound/ambience/ambimine.ogg'
	length = 1 MINUTES + 17 SECONDS

/datum/ambience/dorf
	sound = 'sound/ambience/song_game.ogg'
	length = 3 MINUTES + 51 SECONDS

//Derelict

/datum/ambience/derelict1
	sound = 'sound/ambience/derelict1.ogg'
	length = 4 SECONDS + 2 MINUTES

/datum/ambience/derelict2
	sound = 'sound/ambience/derelict2.ogg'
	length = 3 SECONDS + 2 MINUTES

/datum/ambience/derelict3
	sound = 'sound/ambience/derelict3.ogg'
	length = 4 SECONDS + 2 MINUTES

/datum/ambience/derelict4
	sound = 'sound/ambience/derelict4.ogg'
	length = 2 SECONDS + 2 MINUTES

//Ghetto bar.
/datum/ambience/ghetto
	sound = 'sound/ambience/ghetto.ogg'
	length = 6 SECONDS + 2 MINUTES

//AI ambience. come on and slam.


/datum/ambience/AI
	sound = 'sound/ambience/ambimalf.ogg'
	length = 18 SECONDS + 2 MINUTES

//engineering ambience
/datum/ambience/engi1
	length = 15 SECONDS + 2 MINUTES
	sound = 'sound/ambience/ambisin1.ogg'

/datum/ambience/engi2
	length = 12 SECONDS + 2 MINUTES
	sound = 'sound/ambience/ambisin2.ogg'

/datum/ambience/engi3
	length = 12 SECONDS + 2 MINUTES
	sound = 'sound/ambience/ambisin3.ogg'

/datum/ambience/engi4
	length = 15 SECONDS + 2 MINUTES
	sound = 'sound/ambience/ambisin4.ogg'



//Chapel Ambience

/datum/ambience/holy1
	length = 24 SECONDS + 2 MINUTES //doesn't need to be 100% accurate. should be in the ballpark though.
	sound = 'sound/ambience/ambicha1.ogg' //the actual file it points to.

/datum/ambience/holy2
	length = 11 SECONDS + 2 MINUTES //two minutes extra so people aren't spammed in the chapel.
	sound = 'sound/ambience/ambicha2.ogg'

/datum/ambience/holy3
	length = 12 SECONDS + 2 MINUTES
	sound = 'sound/ambience/ambicha3.ogg'

/datum/ambience/holy4
	length = 18 SECONDS + 2 MINUTES
	sound = 'sound/ambience/ambicha4.ogg'

//Morgue Ambience

/datum/ambience/ded1
	length = 1 MINUTES
	sound = 'sound/ambience/ambimo1.ogg'

/datum/ambience/ded2
	length = 23 SECONDS
	sound = 'sound/ambience/ambimo2.ogg'

//space ambience

/datum/ambience/spaced1
	length = 3 MINUTES + 15 SECONDS
	sound = 'sound/ambience/ambispace.ogg'

/datum/ambience/spaced2
	length = 1 MINUTES + 41 SECONDS
	sound = 'sound/ambience/spookyspace1.ogg'

/datum/ambience/spaced3
	length = 1 MINUTES + 42 SECONDS
	sound = 'sound/ambience/spookyspace2.ogg'

//Music - TODO, refactor this once the background music part of the Subsystem is done.

/datum/ambience/mainmusic
	length = 51 SECONDS
	sound = 'sound/music/main.ogg'

/datum/ambience/spacemusic
	length = 3 MINUTES + 34 SECONDS
	sound = 'sound/music/space.ogg'

/datum/ambience/traitormusic
	length = 5 MINUTES + 30 SECONDS
	sound = 'sound/music/traitor.ogg'

/datum/ambience/torvusmusic
	length = 2 MINUTES + 1 SECONDS
	sound = 'sound/music/torvus.ogg'


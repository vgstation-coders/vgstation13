
var/global/list/area_ambience_sounds=list(
	AREA_AMB_SPACE = list(
		'sound/ambience/ambispace.ogg',
		'sound/music/space.ogg',
		'sound/music/main.ogg',
		'sound/music/traitor.ogg',
		'sound/ambience/spookyspace1.ogg',
		'sound/ambience/spookyspace2.ogg'
	),
	AREA_AMB_CHAPEL = list(
		'sound/ambience/ambicha1.ogg',
		'sound/ambience/ambicha2.ogg',
		'sound/ambience/ambicha3.ogg',
		'sound/ambience/ambicha4.ogg'
	),
	AREA_AMB_MORGUE = list(
		'sound/ambience/ambimo1.ogg',
		'sound/ambience/ambimo2.ogg',
		'sound/music/main.ogg'
	),
	AREA_AMB_ENGINE = list(
		'sound/ambience/ambisin1.ogg',
		'sound/ambience/ambisin2.ogg',
		'sound/ambience/ambisin3.ogg',
		'sound/ambience/ambisin4.ogg'
	),
	AREA_AMB_AI = list(
		'sound/ambience/ambimalf.ogg'
	),
	AREA_AMB_GHETTO = list(
		'sound/ambience/ghetto.ogg'
	),
	AREA_AMB_DERELICT = list(
		'sound/ambience/derelict1.ogg',
		'sound/ambience/derelict2.ogg',
		'sound/ambience/derelict3.ogg',
		'sound/ambience/derelict4.ogg'
	),
	AREA_AMB_MINE = list(
		'sound/ambience/ambimine.ogg',
		'sound/ambience/song_game.ogg',
		'sound/music/torvus.ogg'
	),
	AREA_AMB_MAINT = list(
		'sound/ambience/spookymaint1.ogg',
		'sound/ambience/spookymaint2.ogg'
	),
	AREA_AMB_TCOMMS = list(//if(istype(src, /area/tcommsat) || istype(src, /area/turret_protected/tcomwest) || istype(src, /area/turret_protected/tcomeast) || istype(src, /area/turret_protected/tcomfoyer) || istype(src, /area/turret_protected/tcomsat))
		'sound/ambience/ambisin2.ogg',
		'sound/ambience/signal.ogg',
		//'sound/ambience/signal.ogg', // Was listed twice.
		'sound/ambience/ambigen10.ogg'
	),
	AREA_AMB_DEFAULT = list(
		'sound/ambience/ambigen1.ogg',
		'sound/ambience/ambigen3.ogg',
		'sound/ambience/ambigen4.ogg',
		'sound/ambience/ambigen5.ogg',
		'sound/ambience/ambigen6.ogg',
		'sound/ambience/ambigen7.ogg',
		'sound/ambience/ambigen8.ogg',
		'sound/ambience/ambigen9.ogg',
		'sound/ambience/ambigen10.ogg',
		'sound/ambience/ambigen11.ogg',
		'sound/ambience/ambigen12.ogg',
		'sound/ambience/ambigen14.ogg'
	)
)
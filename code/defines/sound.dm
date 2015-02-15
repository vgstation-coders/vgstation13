#define SOUND_AIRLOCK "airlock"
#define SOUND_CROWBAR "crowbar"

/world/New()
	..()
	gen_sounds()

var/list/sounds = list()

proc/gen_sounds()
	sounds[SOUND_AIRLOCK] = sound('sound/machines/airlock.ogg')
	sounds[SOUND_CROWBAR] = sound('sound/items/Crowbar.ogg')

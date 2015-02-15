#define AIRLOCK "airlock open"
#define CROWBAR "crowbar"

/world/New()
	..()
	gen_sounds()

var/list/sounds = list()

proc/gen_sounds()
	sounds[AIRLOCK] = sound('sound/machines/airlock.ogg')
	sounds[CROWBAR] = sound('sound/items/Crowbar.ogg')

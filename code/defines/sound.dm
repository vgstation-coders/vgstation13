#define SOUND_AIRLOCK "airlock"
#define SOUND_CROWBAR "crowbar"
#define SOUND_SLIP "slip"

/world/New()
	..()
	gen_sounds()

var/list/sounds = list()

proc/gen_sounds()
	sounds[SOUND_AIRLOCK] = sound('sound/machines/airlock.ogg')
	sounds[SOUND_CROWBAR] = sound('sound/items/Crowbar.ogg')
	sounds[SOUND_SLIP] = sound('sound/misc/slip.ogg')

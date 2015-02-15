#define AIRLOCK_OPEN "airlock open"
#define AIRLOCK_CLOSE "airlock close"

world/
	New()
		..()
		gen_sounds()

var
	list/sounds = list()

proc
	gen_sounds()
		var/sound/sound = sound('sound/machines/airlock.ogg')
		sounds[AIRLOCK_OPEN] = sound
		sound = sound('sound/machines/airlock.ogg')
		sounds[AIRLOCK_CLOSE] = sound

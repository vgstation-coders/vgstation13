#define SOUND_AIRLOCK "airlock"
#define SOUND_BANG "bang"
#define SOUND_CLICK "click"
#define SOUND_CROWBAR "crowbar"
#define SOUND_DECONSTRUCT "deconstruct"
#define SOUND_FLASH "flash"
#define SOUND_RATCHET "ratchet"
#define SOUND_SCREWDRIVER "screwdriver"
#define SOUND_SLIP "slip"
#define SOUND_WIRECUTTER "wirecutter"

/world/New()
	..()
	gen_sounds()

var/list/sounds = list()

proc/gen_sounds()
	sounds[SOUND_AIRLOCK] = sound('sound/machines/airlock.ogg')
	sounds[SOUND_BANG] = sound('sound/effects/bang.ogg')
	sounds[SOUND_CLICK] = sound('sound/machines/click.ogg')
	sounds[SOUND_CROWBAR] = sound('sound/items/Crowbar.ogg')
	sounds[SOUND_DECONSTRUCT] = sound('sound/items/Deconstruct.ogg')
	sounds[SOUND_FLASH] = sound('sound/weapons/flash.ogg')
	sounds[SOUND_RATCHET] = sound('sound/items/Ratchet.ogg')
	sounds[SOUND_SCREWDRIVER] = sound('sound/items/Screwdriver.ogg')
	sounds[SOUND_SLIP] = sound('sound/misc/slip.ogg')
	sounds[SOUND_WIRECUTTER] = sound('sound/items/Wirecutter.ogg')

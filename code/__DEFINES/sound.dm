#define SOUND_AIRLOCK "airlock"
#define SOUND_BANG "bang"
#define SOUND_BLADE_SLICE "blade_slice"
#define SOUND_BLOODY_SLICE "bloody_slice"
#define SOUND_CLICK "click"
#define SOUND_CROWBAR "crowbar"
#define SOUND_DECONSTRUCT "deconstruct"
#define SOUND_FLASH "flash"
#define SOUND_GLASS_BREAK_ONE "glass_break_one"
#define SOUND_GLASS_BREAK_TWO "glass_break_two"
#define SOUND_GLASS_BREAK_THREE "glass_break_three"
#define SOUND_PUNCH_MISS "punch_miss"
#define SOUND_RATCHET "ratchet"
#define SOUND_SCREWDRIVER "screwdriver"
#define SOUND_SLIP "slip"
#define SOUND_TOOL_HIT "tool_hit"
#define SOUND_WIRECUTTER "wirecutter"

#define SOUND_LIST_SHATTER "shatter"

/world/New()
	..()
	gen_sounds()

var/list/sounds = list()

proc/gen_sounds()
	sounds[SOUND_AIRLOCK] = sound('sound/machines/airlock.ogg')
	sounds[SOUND_BANG] = sound('sound/effects/bang.ogg')
	sounds[SOUND_BLADE_SLICE] = sound('sound/weapons/bladeslice.ogg')
	sounds[SOUND_BLOODY_SLICE] = sound('sound/weapons/bloodyslice.ogg')
	sounds[SOUND_CLICK] = sound('sound/machines/click.ogg')
	sounds[SOUND_CROWBAR] = sound('sound/items/Crowbar.ogg')
	sounds[SOUND_DECONSTRUCT] = sound('sound/items/Deconstruct.ogg')
	sounds[SOUND_FLASH] = sound('sound/weapons/flash.ogg')
	sounds[SOUND_GLASS_BREAK_ONE] = sound('sound/effects/Glassbr1.ogg')
	sounds[SOUND_GLASS_BREAK_TWO] = sound('sound/effects/Glassbr2.ogg')
	sounds[SOUND_GLASS_BREAK_THREE] = sound('sound/effects/Glassbr3.ogg')
	sounds[SOUND_PUNCH_MISS] = sound('sound/weapons/punchmiss.ogg')
	sounds[SOUND_RATCHET] = sound('sound/items/Ratchet.ogg')
	sounds[SOUND_SCREWDRIVER] = sound('sound/items/Screwdriver.ogg')
	sounds[SOUND_SLIP] = sound('sound/misc/slip.ogg')
	sounds[SOUND_TOOL_HIT] = sound('sound/weapons/toolhit.ogg')
	sounds[SOUND_WIRECUTTER] = sound('sound/items/Wirecutter.ogg')

	sounds[SOUND_LIST_SHATTER] = list(sounds[SOUND_GLASS_BREAK_ONE], sounds[SOUND_GLASS_BREAK_TWO], sounds[SOUND_GLASS_BREAK_THREE])

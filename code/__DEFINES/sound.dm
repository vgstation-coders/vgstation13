#define SOUND_AIRLOCK "airlock"
#define SOUND_BANG "bang"
#define SOUND_BLADE_SLICE "blade_slice"
#define SOUND_BLOODY_SLICE "bloody_slice"
#define SOUND_CLICK "click"
#define SOUND_CLOWN_STEP_ONE "clown_step_one"
#define SOUND_CLOWN_STEP_TWO "clown_step_two"
#define SOUND_CROWBAR "crowbar"
#define SOUND_DECONSTRUCT "deconstruct"
#define SOUND_EXPLOSION_ONE "explosion_one"
#define SOUND_EXPLOSION_TWO "explosion_two"
#define SOUND_EXPLOSION_THREE "explosion_three"
#define SOUND_EXPLOSION_FOUR "explosion_four"
#define SOUND_EXPLOSION_FIVE "explosion_five"
#define SOUND_EXPLOSION_SIX "explosion_six"
#define SOUND_EXPLOSION_FAR "explosion_far"
#define SOUND_FLASH "flash"
#define SOUND_GIB_ONE "gib_one"
#define SOUND_GIB_TWO "gib_two"
#define SOUND_GIB_THREE "gib_three"
#define SOUND_GLASS_BREAK_ONE "glass_break_one"
#define SOUND_GLASS_BREAK_TWO "glass_break_two"
#define SOUND_GLASS_BREAK_THREE "glass_break_three"
#define SOUND_MECH_STEP_ONE "mech_step_one"
#define SOUND_MECH_STEP_TWO "mech_step_two"
#define SOUND_PAGE_TURN_ONE "page_turn_one"
#define SOUND_PAGE_TURN_TWO "page_turn_two"
#define SOUND_PUNCH_MISS "punch_miss"
#define SOUND_PUNCH_ONE "punch_one"
#define SOUND_PUNCH_TWO "punch_two"
#define SOUND_PUNCH_TREE "punch_three"
#define SOUND_PUNCH_FOUR "punch_four"
#define SOUND_RATCHET "ratchet"
#define SOUND_SCREWDRIVER "screwdriver"
#define SOUND_SLIP "slip"
#define SOUND_SPARK_ONE "spark_one"
#define SOUND_SPARK_TWO "spark_two"
#define SOUND_SPARK_THREE "spark_three"
#define SOUND_SPARK_FOUR "spark_four"
#define SOUND_TOOL_HIT "tool_hit"
#define SOUND_WIRECUTTER "wirecutter"

#define SOUND_CLOWN_STEP "clown_step"
#define SOUND_EXPLOSION "explosion"
#define SOUND_GIB "gib"
#define SOUND_MECH_STEP "mech_step"
#define SOUND_PAGE_TURN "page_turn"
#define SOUND_PUNCH "punch"
#define SOUND_SHATTER "shatter"
#define SOUND_SPARK "spark"

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
	sounds[SOUND_CLOWN_STEP_ONE] = ('sound/effects/clownstep1.ogg')
	sounds[SOUND_CLOWN_STEP_TWO] = ('sound/effects/clownstep2.ogg')
	sounds[SOUND_CROWBAR] = sound('sound/items/Crowbar.ogg')
	sounds[SOUND_DECONSTRUCT] = sound('sound/items/Deconstruct.ogg')
	sounds[SOUND_EXPLOSION_ONE] = sound('sound/effects/Explosion1.ogg')
	sounds[SOUND_EXPLOSION_TWO] = sound('sound/effects/Explosion2.ogg')
	sounds[SOUND_EXPLOSION_THREE] = sound('sound/effects/Explosion3.ogg')
	sounds[SOUND_EXPLOSION_FOUR] = sound('sound/effects/Explosion4.ogg')
	sounds[SOUND_EXPLOSION_FIVE] = sound('sound/effects/Explosion5.ogg')
	sounds[SOUND_EXPLOSION_SIX] = sound('sound/effects/Explosion6.ogg')
	sounds[SOUND_EXPLOSION_FAR] = sound('sound/effects/explosionfar.ogg')
	sounds[SOUND_FLASH] = sound('sound/weapons/flash.ogg')
	sounds[SOUND_GIB_ONE] = sound('sound/effects/gib1.ogg')
	sounds[SOUND_GIB_TWO] = sound('sound/effects/gib2.ogg')
	sounds[SOUND_GIB_THREE] = sound('sound/effects/gib3.ogg')
	sounds[SOUND_GLASS_BREAK_ONE] = sound('sound/effects/Glassbr1.ogg')
	sounds[SOUND_GLASS_BREAK_TWO] = sound('sound/effects/Glassbr2.ogg')
	sounds[SOUND_GLASS_BREAK_THREE] = sound('sound/effects/Glassbr3.ogg')
	sounds[SOUND_MECH_STEP_ONE] = sound('sound/mecha/mechstep1.ogg')
	sounds[SOUND_MECH_STEP_TWO] = sound('sound/mecha/mechstep2.ogg')
	sounds[SOUND_PAGE_TURN_ONE] = sound('sound/effects/pageturn1.ogg')
	sounds[SOUND_PAGE_TURN_TWO] = sound('sound/effects/pageturn2.ogg')
	sounds[SOUND_PUNCH_MISS] = sound('sound/weapons/punchmiss.ogg')
	sounds[SOUND_PUNCH_ONE] = sound('sound/weapons/punch1.ogg')
	sounds[SOUND_PUNCH_TWO] = sound('sound/weapons/punch2.ogg')
	sounds[SOUND_PUNCH_THREE] = sound('sound/weapons/punch3.ogg')
	sounds[SOUND_PUNCH_FOUR] = sound('sound/weapons/punch4.ogg')
	sounds[SOUND_RATCHET] = sound('sound/items/Ratchet.ogg')
	sounds[SOUND_SCREWDRIVER] = sound('sound/items/Screwdriver.ogg')
	sounds[SOUND_SLIP] = sound('sound/misc/slip.ogg')
	sounds[SOUND_SPARK_ONE] = sound('sound/effects/sparks1.ogg')
	sounds[SOUND_SPARK_TWO] = sound('sound/effects/sparks2.ogg')
	sounds[SOUND_SPARK_THREE] = sound('sound/effects/sparks3.ogg')
	sounds[SOUND_SPARK_FOUR] = sound('sound/effects/sparks4.ogg')
	sounds[SOUND_TOOL_HIT] = sound('sound/weapons/toolhit.ogg')
	sounds[SOUND_WIRECUTTER] = sound('sound/items/Wirecutter.ogg')

	sounds[SOUND_CLOWN_STEP] = list(sounds[SOUND_CLOWN_STEP_ONE], sounds[SOUND_CLOWN_STEP_TWO])
	sounds[SOUND_EXPLOSION] = list(sounds[SOUND_EXPLOSION_ONE], sounds[SOUND_EXPLOSION_TWO], sounds[SOUND_EXPLOSION_THREE], sounds[SOUND_EXPLOSION_FOUR], sounds[SOUND_EXPLOSION_FIVE], sounds[SOUND_EXPLOSION_SIX])
	sounds[SOUND_GIB] = list(sounds[SOUND_GIB_ONE], sounds[SOUND_GIB_TWO], sounds[SOUND_GIB_THREE])
	sounds[SOUND_MECH_STEP] = list(sounds[SOUND_MECH_STEP_ONE], sounds[SOUND_MECH_STEP_TWO])
	sounds[SOUND_PAGE_TURN] = list(sounds[SOUND_PAGE_TURN_ONE], sounds[SOUND_PAGE_TURN_TWO])
	sounds[SOUND_PUNCH] = list(sounds[SOUND_PUNCH_ONE], sounds[SOUND_PUNCH_TWO], sounds[SOUND_PUNCH_THREE], sounds[SOUND_PUNCH_FOUR])
	sounds[SOUND_SHATTER] = list(sounds[SOUND_GLASS_BREAK_ONE], sounds[SOUND_GLASS_BREAK_TWO], sounds[SOUND_GLASS_BREAK_THREE])
	sounds[SOUND_SPARK] = list(sounds[SOUND_SPARK_ONE], sounds[SOUND_SPARK_TWO], sounds[SOUND_SPARK_THREE], sounds[SOUND_SPARK_FOUR])

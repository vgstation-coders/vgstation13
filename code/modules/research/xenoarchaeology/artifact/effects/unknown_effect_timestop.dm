/datum/artifact_effect/timestop
	effecttype = "timestop"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_PULSE)

	var/mob/caster
	var/spell/aoe_turf/fall/fall
	var/stop_length
	copy_for_battery = list("stop_length")

/datum/artifact_effect/timestop/New()
	..()
	caster = new
	caster.invisibility = 101
	caster.setDensity(FALSE)
	caster.anchored = 1
	caster.flags = INVULNERABLE
	fall = new /spell/aoe_turf/fall
	caster.add_spell(fall)
	fall.spell_flags = 0
	fall.invocation_type = SpI_NONE
	fall.the_world_chance = 0
	chargelevelmax = rand(30, 200)
	effectrange = rand(2, 15)
	fall.range = effectrange
	fall.sleeptime = rand(10,chargelevelmax*2)
	spawn(10) //this is here to give the anomaly battery thing enough time to set variables in the right places
		if(stop_length) //because this is all done in such an awful way
			fall.sleeptime = stop_length
		else
			stop_length = fall.sleeptime

/datum/artifact_effect/timestop/Destroy()
	fall = null
	qdel(caster)
	caster = null
	..()

/datum/artifact_effect/timestop/DoEffectTouch(var/mob/user)
	if(holder)
		stop_time()

/datum/artifact_effect/timestop/DoEffectPulse()
	if(holder)
		stop_time()

/datum/artifact_effect/timestop/proc/stop_time()
	caster.forceMove(get_turf(holder))
	fall.perform(caster, skipcharge = 1)
	caster.forceMove(null)
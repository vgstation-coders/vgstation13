// Make sure to use two newlines between each effect and one newline between each method.
// Fully read through the example effect below to get an idea of what attributes and procs are available.
// Babel Syndrome provides a good example of the usage of affect_voice, affect_mob_voice, etc.

/datum/disease2/effect
	var/name = "Example syndrome"
		// Try to have a self-descriptive name, eg. "Hearing Loss", "Toxin Sublimation".
		// Failing that, call it "X syndrome". It's important that effect names are consistent.
	var/desc = "This symptom is currently undocumented."
	var/encyclopedia = ""
	var/stage = -1
		// Diseases start at stage 1. They slowly and cumulatively proceed their way up.
		// Try to keep more severe effects in the later stages.
	var/badness = EFFECT_DANGER_ANNOYING
		// How dangerous the symptom is.
		// EFFECT_DANGER_HELPFUL = generally helpful (ex: full glass syndrome)
		// EFFECT_DANGER_FLAVOR = neutral, just flavor text (ex: headache)
		// EFFECT_DANGER_ANNOYING = minor inconvenience (ex: tourettes)
		// EFFECT_DANGER_HINDRANCE = severe inconvenience (ex: random tripping)
		// EFFECT_DANGER_HARMFUL = likely to indirectly lead to death (ex: Harlequin Ichthyosis)
		// EFFECT_DANGER_DEADLY = will definitely kill you (ex: gibbingtons/necrosis)

	var/chance = 3
		// Under normal conditions, the percentage chance per tick to activate.
	var/max_chance = 6
		// Maximum percentage chance per tick.

	var/multiplier = 1
		// How strong the effects are. Use this in activate().
	var/max_multiplier = 1
		// Maximum multiplier.

	var/count = 0
		// How many times the effect has activated so far.
	var/max_count = -1
		// How many times the effect should be allowed to activate. If -1, always activate.

	var/affect_voice = 0
	var/affect_voice_active = 0
		// Read through Hanging Man's / Pro-tagonista syndrome to know how to use these.

	var/datum/disease2/disease/virus
		// Parent virus. Plans to generalize these are underway.

	var/restricted = 0
	// If 1, will never appear randomly in a disease, requiring instead to be manually set in the code. If 2, will not either appear in the encyclopedia.
// The actual guts of the effect. Has a prob(chance)% to get called per tick.
/datum/disease2/effect/proc/activate(var/mob/living/carbon/mob)

// If activation makes any permanent changes to the effect, this is where you undo them.
// Will not get called if the virus has never been activated.
/datum/disease2/effect/proc/deactivate(var/mob/living/carbon/mob)

/datum/disease2/effect/proc/affect_mob_voice(var/datum/speech/speech)
	// Called by /mob/living/carbon/human/treat_speech
/datum/disease2/effect/proc/on_touch(var/mob/living/carbon/mob, var/toucher, var/touched, var/touch_type)
	// Called when the sufferer of the symptom bumps, is bumped, or is touched by hand.
/datum/disease2/effect/proc/on_death(var/mob/living/carbon/mob)
	// Called when the sufferer of the symptom dies

// Most of the stuff below shouldn't be changed when you make a new effect.
/datum/disease2/effect/New(var/datum/disease2/disease/D)
	virus=D

/datum/disease2/effect/proc/can_run_effect(var/active_stage = -1)
	if((count < max_count || max_count == -1) && (stage <= active_stage || active_stage == -1) && prob(chance))
		return 1
	return 0

/datum/disease2/effect/proc/run_effect(var/mob/living/carbon/human/mob)
	activate(mob)
	count += 1

/datum/disease2/effect/proc/disable_effect(var/mob/living/carbon/human/mob)
	if (count > 0)
		deactivate(mob)

/datum/disease2/effect/proc/minormutate()
	if (prob(20))
		chance = rand(initial(chance), max_chance)

/datum/disease2/effect/proc/multiplier_tweak(var/tweak)
	multiplier = Clamp(multiplier+tweak,1,max_multiplier)

/datum/disease2/effect/proc/getcopy(var/datum/disease2/disease/disease)
	var/datum/disease2/effect/new_e = new type(disease)
	new_e.chance = chance
	new_e.multiplier = multiplier
	new_e.stage = stage
	return new_e
////////////////////////SPECIAL/////////////////////////////////

//Vampire Diseased Touch
/datum/disease2/effect/organs/vampire
	stage = 1
	restricted = 2//symptoms won't randomly mutate into this one & won't appear in the symptom encyclopedia

/datum/disease2/effect/wizarditis/single
	stage = 1
	restricted = 2//symptoms won't randomly mutate into this one & won't appear in the symptom encyclopedia

/datum/disease2/effect/magnitis/single
	stage = 1
	restricted = 2//symptoms won't randomly mutate into this one & won't appear in the symptom encyclopedia


/datum/disease2/effect/blob_spores
	name = "Blob Spores"
	desc = "They seem inert for the most part, but appear to randomly pulsate once in a while."
	encyclopedia = "They will cause their carrier to spawn blob upon their death, potentially more the longer the pathogen matured in the host's body. Some additional blob spores may even emanate from their body."
	stage = 1
	badness = EFFECT_DANGER_HINDRANCE
	restricted = 1//symptoms won't randomly mutate into this one
	chance = 100
	max_chance = 100
	var/looks = "new"


/datum/disease2/effect/blob_spores/on_death(var/mob/living/carbon/mob)
	//first of all is there a blob on top of us
	var/turf/T = get_turf(mob)
	var/obj/effect/blob/B = locate() in T

	if (!B)//if not, let's just spawn one.
		new /obj/effect/blob/normal(T, looks, TRUE)

	virus.cure(mob)//finally let's remove the spores now that they've matured


/datum/disease2/effect/blob_spores/getcopy(var/datum/disease2/disease/disease)
	var/datum/disease2/effect/blob_spores/new_e = ..(disease)
	new_e.looks = looks
	return new_e

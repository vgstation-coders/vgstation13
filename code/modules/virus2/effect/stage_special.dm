////////////////////////SPECIAL/////////////////////////////////


/*/datum/disease2/effect/alien
	name = "Unidentified Foreign Body"
	stage = 4
	activate(var/mob/living/carbon/mob)
		to_chat(mob, "<span class='warning'>You feel something tearing its way out of your stomach...</span>")
		mob.adjustToxLoss(10)
		mob.updatehealth()
		if(prob(40))
			if(mob.client)
				mob.client.mob = new/mob/living/carbon/alien/larva(mob.loc)
			else
				new/mob/living/carbon/alien/larva(mob.loc)
			var/datum/disease2/disease/D = mob:virus2
			mob:gib()
			del D*/


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
		B = new /obj/effect/blob/normal(T,looks,1)

	if (B)//then let's just pulse him as many times as we activated on a row (up to 10 times)
		spawn()
			for(var/j = 1 to min(30,round(count/10)))//max number of pulses reached after about 10 minutes (300 activations, 1 every 2 second in BYOND time)
				if ((j%5) == 0)//up to 6 spores spawned
					var/mob/living/simple_animal/hostile/blobspore/S = new (T)
					S.blob_looks(looks)
				for(var/i = 1; i < 8; i += i)
					B.Pulse(0, i, null)
				sleep(2)

	virus.cure(mob)//finally let's remove the spores now that they've matured


/datum/disease2/effect/blob_spores/getcopy(var/datum/disease2/disease/disease)
	var/datum/disease2/effect/blob_spores/new_e = ..(disease)
	new_e.looks = looks
	return new_e

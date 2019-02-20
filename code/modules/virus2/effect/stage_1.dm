/datum/disease2/effect/invisible
	name = "Waiting Syndrome"
	stage = 1

/datum/disease2/effect/invisible/activate(var/mob/living/carbon/mob)
		return


/datum/disease2/effect/sneeze
	name = "Coldingtons Effect"
	stage = 1

/datum/disease2/effect/sneeze/activate(var/mob/living/carbon/mob)
	mob.say("*sneeze")
	if (prob(50))
		var/obj/effect/decal/cleanable/mucus/M= locate(/obj/effect/decal/cleanable/mucus) in get_turf(mob)
		if(M==null)
			M = new(get_turf(mob))
		else
			if(M.dry)
				M.dry=0
		M.virus2 |= virus_copylist(mob.virus2)


/datum/disease2/effect/gunck
	name = "Flemmingtons"
	stage = 1

/datum/disease2/effect/gunck/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'> Mucous runs down the back of your throat.</span>")


/datum/disease2/effect/drool
	name = "Saliva Effect"
	stage = 1

/datum/disease2/effect/drool/activate(var/mob/living/carbon/mob)
	mob.say("*drool")


/datum/disease2/effect/twitch
	name = "Twitcher"
	stage = 1

/datum/disease2/effect/twitch/activate(var/mob/living/carbon/mob)
	mob.say("*twitch")


/datum/disease2/effect/headache
	name = "Headache"
	stage = 1

/datum/disease2/effect/headache/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>Your head hurts a bit</span>")


/datum/disease2/effect/itching
	name = "Itching"
	stage = 1

/datum/disease2/effect/itching/activate(var/mob/living/carbon/mob)
	var/mob/living/carbon/human/H = mob
	if (istype(H) && H.species && H.species.anatomy_flags & NO_SKIN)
		to_chat(mob, "<span class='warning'>Your bones itch!</span>")
	else
		to_chat(mob, "<span class='warning'>Your skin itches!</span>")


/datum/disease2/effect/drained
	name = "Drained Feeling"
	stage = 1

/datum/disease2/effect/drained/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class='warning'>You feel drained.</span>")


/datum/disease2/effect/eyewater
	name = "Watery Eyes"
	stage = 1

/datum/disease2/effect/eyewater/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<SPAN CLASS='warning'>Your eyes sting and water!</SPAN>")


/datum/disease2/effect/wheeze
	name = "Wheezing"
	stage = 1

/datum/disease2/effect/wheeze/activate(var/mob/living/carbon/mob)
	mob.emote("me",1,"wheezes.")


/datum/disease2/effect/optimistic
	name = "Full Glass Syndrome"
	stage = 1

/datum/disease2/effect/optimistic/activate(var/mob/living/carbon/mob)
	to_chat(mob, "<span class = 'notice'>You feel optimistic!</span>")
	if (mob.reagents.get_reagent_amount(TRICORDRAZINE) < 1)
		mob.reagents.add_reagent(TRICORDRAZINE, 1)


/datum/disease2/effect/spyndrome
	name = "Gyroscopic Manipulation Syndrome"
	stage = 1

/datum/disease2/effect/spyndrome/activate(var/mob/living/carbon/mob)
	if (mob.reagents.get_reagent_amount(GYRO) < 1)
		mob.reagents.add_reagent(GYRO, 1)

/datum/disease2/effect/bee_vomit
	name = "Melisso-Emeto Syndrome"
	stage = 1
	max_multiplier = 10

/datum/disease2/effect/bee_vomit/activate(var/mob/living/carbon/mob)
	if (mob.reagents.get_reagent_amount(HONEY) < 10+multiplier*2)
		mob.reagents.add_reagent(HONEY, 1)

	if((mob.reagents.get_reagent_amount(HONEY)>= 10+multiplier*2) && prob(10))
		if(prob(25))
			to_chat(mob, "<span class='warning'>You feel a buzzing in your throat</span>")
		spawn(5 SECONDS)
			var/turf/simulated/T = get_turf(mob)
			if(prob(30))
				playsound(T, 'sound/effects/splat.ogg', 50, 1)
				mob.visible_message("<span class='warning'>[mob] spits out a bee!</span>","<span class='danger'>You throw up a bee!</span>")
				T.add_vomit_floor(mob, 1, 1, 1)
			for(var/i = 0 to multiplier)
				new/mob/living/simple_animal/bee(get_turf(mob))
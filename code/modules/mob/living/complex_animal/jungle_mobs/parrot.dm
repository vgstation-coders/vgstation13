/mob/living/simple_animal/complex/parrot
	name="\improper Parrot"
	desc="BWAK!"
	icon_state="parrot_fly"
	icon_living = "parrot_fly"
	icon_dead = "parrot_dead"
	size=SIZE_TINY
	health=30
	maxHealth=30
	max_food=20
	food_flags = ANIMAL_HERBIVORE
	melee_damage_upper=14
	melee_damage_lower=6 
	behavior_flags = ANIMAL_BEHAVIOR_AVOID_PRED | ANIMAL_BEHAVIOR_RETALIATE
	movespeed=3
	petable=TRUE
	flying=TRUE
	pass_flags = PASSTABLE | PASSRAILING | PASSMACHINE | PASSMOB
	flags = HEAR | PROXMOVE | HEAR_ALWAYS
	var/obj/cur_perch=null
	var/list/builtin_phrases=list("Hi.","Hello!","Cracker?","BAWWWWK george mellons griffing me!")
	var/list/heard_phrases=list()
	var/list/valid_perches=list(/obj/structure/computerframe, 		/obj/structure/displaycase, \
									/obj/structure/filingcabinet,		/obj/machinery/teleport, \
									/obj/machinery/computer,			/obj/machinery/cloning/clonepod, \
									/obj/machinery/dna_scannernew,		/obj/machinery/telecomms, \
									/obj/machinery/nuclearbomb,			/obj/machinery/particle_accelerator, \
									/obj/machinery/recharge_station,	/obj/machinery/smartfridge, \
									/obj/machinery/suit_storage_unit,	/obj/structure/flora/tree)


/mob/living/simple_animal/complex/parrot/Hear(var/datum/speech/speech, var/rendered_speech="")
	if(speech.speaker && speech.speaker != src && !(speech.message in heard_phrases) && !(speech.message in builtin_phrases)  ) //Don't imitate ourselves
		if(heard_phrases.len >= 20)
			heard_phrases -= pick(heard_phrases)
		heard_phrases |= speech.message
	..()

/mob/living/simple_animal/complex/parrot/tick_state_idle()
	if(!..())
		return FALSE
	if(prob(50))
		var/obj/perch=find_pearch()
		if(perch)
			visible_message("\The [src] flies to a comfortable spot.")
			behavior_state=ANIMAL_STATE_SPECIAL
			walk_to(src,perch,1,movespeed)
			cur_perch=perch
	return TRUE

/mob/living/simple_animal/complex/parrot/tick_state_special()
	if(!..())
		return FALSE
	if(Adjacent(cur_perch))
		forceMove(cur_perch.loc)
	if(loc==cur_perch?.loc)
		icon_state = "parrot_sit"
	if(prob(20) || !cur_perch)
		cur_perch=null
		icon_state="parrot_fly"
		behavior_state=ANIMAL_STATE_IDLE
		visible_message("\The [src] flies away.")
	return TRUE


/mob/living/simple_animal/complex/parrot/get_idle_sounds()
	if(prob(10))
		var/list/allphrases=list()
		allphrases|=builtin_phrases
		allphrases|=heard_phrases
		say(pick(allphrases))

//we don't fear people
/mob/living/simple_animal/complex/parrot/determine_isthreat(var/mob/individual)
	if(istype(individual,/mob/living/carbon))
		return FALSE
	if(istype(individual,/mob/living/silicon))
		return FALSE
	return ..()

/mob/living/simple_animal/complex/parrot/trypet(mob/living/carbon/human/M)
	..()
	emote("me", EMOTE_AUDIBLE, "croons.")


/mob/living/simple_animal/complex/parrot/proc/find_pearch()
	var/list/obj/candidates=list()
	for(var/obj/O in cache_objects_in_view)
		for(var/T in valid_perches)
			if(istype(O,T))
				candidates+=O
				break
	if(!candidates.len)
		return null
	return pick(candidates)


/mob/living/simple_animal/complex/parrot/get_butchering_products()
	return list(/datum/butchering_product/feathers)

#define GORILLA_HANDS_LAYER 1
#define GORILLA_TOTAL_LAYERS 1

/mob/living/simple_animal/hostile/gorilla
	name = "Gorilla"
	desc = "A ground-dwelling, predominantly herbivorous ape that inhabits the forests of central Africa."
	icon = 'icons/mob/gorilla.dmi'
	icon_state = "crawling"
	icon_state = "crawling"
	icon_living = "crawling"
	icon_dead = "dead"
	speak_chance = 80
	maxHealth = 220
	health = 220
	loot = list(/obj/effect/gibspawner/generic)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/gorilla = 4)
	response_help  = "prods"
	response_disarm = "challenges"
	response_harm   = "thumps"
	speed = 1
	melee_damage_lower = 15
	melee_damage_upper = 18
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1.5)
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attacktext = "pummels"
	attack_sound = 'sound/weapons/punch1.ogg'
	dextrous = TRUE
	possible_a_intents = list(INTENT_HELP, INTENT_GRAB, INTENT_DISARM, INTENT_HARM)
	faction = list("jungle")
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	minbodytemp = 270
	maxbodytemp = 350
	unique_name = TRUE
	var/list/gorilla_overlays[GORILLA_TOTAL_LAYERS]
	var/oogas = 0

// Gorillas like to dismember limbs from unconcious mobs.
// Returns null when the target is not an unconcious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/gorilla/proc/target_bodyparts(atom/the_target)
	var/list/parts = list()
	if(iscarbon(the_target))
		var/mob/living/carbon/C = the_target
		if(C.stat >= UNCONSCIOUS)
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.body_part != HEAD && BP.body_part != CHEST)
					if(BP.dismemberable)
						parts += BP
			return parts

/mob/living/simple_animal/hostile/gorilla/AttackingTarget()
	if(client)
		oogaooga()
	var/list/parts = target_bodyparts(target)
	if(parts)
		if(!parts.len)
			return FALSE
		var/obj/item/bodypart/BP = pick(parts)
		BP.dismember()
		return ..()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(prob(80))
			var/atom/throw_target = get_edge_target_turf(L, dir)
			L.throw_at(throw_target, rand(1,2), 7, src)
		else
			L.Knockdown(20)
			visible_message("<span class='danger'>[src] knocks [L] down!</span>")

/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	var/list/parts = target_bodyparts(target)
	return ..() && !istype(the_target, /mob/living/carbon/monkey) && (!parts  || parts.len > 3)


/mob/living/simple_animal/hostile/gorilla/CanSmashTurfs(turf/T)
	return iswallturf(T)


/mob/living/simple_animal/hostile/gorilla/gib(no_brain)
	if(!no_brain)
		var/mob/living/brain/B = new(drop_location())
		B.name = real_name
		B.real_name = real_name
		if(mind)
			mind.transfer_to(B)
	..()

/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		playsound(src, "sound/creatures/gorilla.ogg", 200)
	..()

/mob/living/simple_animal/hostile/gorilla/can_use_guns(obj/item/G)
	to_chat(src, "<span class='warning'>Your meaty finger is much too large for the trigger guard!</span>")
	return FALSE


/mob/living/simple_animal/hostile/gorilla/proc/oogaooga()
	oogas++
	if(oogas >= rand(2,6))
		playsound(src, "sound/creatures/gorilla.ogg", 200)
		oogas = 0


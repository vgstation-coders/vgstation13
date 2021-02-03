/mob/living/simple_animal/hostile/shade
	name = "red shade"
	real_name = "red shade"
	desc = "A vengeful spirit"
	icon = 'icons/mob/mob.dmi'
	icon_state = "red shade"
	icon_living = "red shade"
	icon_dead = "shade_dead"
	maxHealth = 20
	health = 20
	speak_chance = 33
	turns_per_move = 5
	speak = list("...blood...","...destroy...","...others...")
	speak_emote = list("hisses")
	emote_hear = list("wails","screeches")
	response_help  = "puts their hand through"
	response_disarm = "flails at"
	response_harm   = "punches"
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "torments"
	attack_sound = 'sound/hallucinations/growl1.ogg'
	minbodytemp = 0
	maxbodytemp = 4000
	min_oxy = 0
	max_co2 = 0
	max_tox = 0
	speed = 1
	faction = "cult"
	status_flags = CANPUSH
	supernatural = TRUE
	flying = TRUE
	meat_type = /obj/item/weapon/ectoplasm
	mob_property_flags = MOB_SUPERNATURAL
	alpha = 180

/mob/living/simple_animal/hostile/shade/New()
	..()
	add_language(LANGUAGE_CULT)
	add_language(LANGUAGE_GALACTIC_COMMON)
	default_language = all_languages[LANGUAGE_CULT]

/mob/living/simple_animal/hostile/shade/death(var/gibbed = FALSE)
	var/turf/T = get_turf(src)
	if (T)
		playsound(T, get_sfx("soulstone"), 50,1)
		new /obj/item/weapon/ectoplasm (T)
		qdel (src)

/mob/living/simple_animal/hostile/shade/say(var/message)
	. = ..(message, "C")

/mob/living/simple_animal/hostile/shade/proc/buff()
	//same damage and health as regular shades
	melee_damage_lower = 8
	melee_damage_upper = 8
	maxHealth = 50
	health = 50
	alpha = 255

/mob/living/simple_animal/hostile/shade/gib(var/animation = 0, var/meat = 1)
	death(TRUE)
	monkeyizing = TRUE
	canmove = FALSE
	icon = null
	invisibility = 101

	dead_mob_list -= src

	qdel(src)

/mob/living/simple_animal/hostile/shade/Process_Spacemove(var/check_drift = 0)
	return 1

/mob/living/simple_animal/hostile/shade/FindTarget()
	. = ..()
	if(.)
		emote("me",,"wails at [.]!")

/mob/living/simple_animal/hostile/shade/cult/CanAttack(var/atom/the_target)
	if(ismob(the_target))
		var/mob/M = the_target
		if(isanycultist(M))
			return 0
	return ..(the_target)

/mob/living/simple_animal/hostile/shade/cultify()
	return

/mob/living/simple_animal/hostile/shade/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/soulstone))
		to_chat(user,"<span class='warning'>The red shade doesn't seem to have an actual soul to capture.</span>")
		return
	return ..()

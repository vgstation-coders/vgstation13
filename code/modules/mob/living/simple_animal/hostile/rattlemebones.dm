/mob/living/simple_animal/hostile/rattlemebones
	name = "hanging skeleton model"
	desc = "It's an anatomical model of a human skeletal system made of plaster."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "hangskele"
	icon_living = "hangskele"
	faction = "skeleton"
	icon_dead = null
	wander = FALSE
	speak_chance = 1
	speak = list(
		"Don't rattle me bones!",
		"You can take your fill, but don't rattle me bones!",
		"Careful, my friend, or I'll rattle and shake!",
		"You can use your skill to take what you will!"
		)
	speak_emote = list("rattles")
	response_help = "rattles"
	response_disarm = "rattles"
	response_harm = "rattles"
	maxHealth = 75
	health = 75
	melee_damage_lower = 10
	melee_damage_upper = 25
	attack_sound = "sound/effects/rattling_bones.ogg"
	mob_property_flags = MOB_CONSTRUCT
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0
	anchored = 1
	a_intent = I_HURT
	var/rattled = FALSE

/mob/living/simple_animal/hostile/rattlemebones/Bumped(atom/thing)
	if(ismob(thing))
		var/mob/M = thing
		if(M.faction == "skeleton")
			return
	if(!rattled)
		visible_message("<b>[name]</b> [pick(speak_emote)], \"<span class='danger'>I TOLD YOU NOT TO RATTLE ME BONES!</span>\"")
		rattle()
		for(var/mob/living/simple_animal/hostile/rattlemebones/R in view(src))
			R.rattle()

/mob/living/simple_animal/hostile/rattlemebones/proc/rattle()
	rattled = TRUE
	anchored = 0
	for(var/i in contents)
		if(istype(i, /obj/abstract/mover))
			qdel(i)

/mob/living/simple_animal/hostile/rattlemebones/to_bump(atom/Obstacle)
	Bumped(Obstacle)
	..()

/mob/living/simple_animal/hostile/rattlemebones/death(var/gibbed = FALSE)
	visible_message("<span class='warning'>\The [src] collapses into a pile of bones!</span>")
	name = "pile of bones"
	desc = "It looks like a pile of human bones."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	icon_dead = "remains"
	..(gibbed)

/mob/living/simple_animal/hostile/rattlemebones/ListTargets()
	if(!rattled)
		return list()
	return ..()
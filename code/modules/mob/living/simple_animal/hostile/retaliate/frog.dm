/mob/living/simple_animal/hostile/retaliate/frog
	name = "frog"
	desc = "It seems a little sad."
	icon_state = "frog"
	icon_living = "frog"
	icon_dead = "frog_dead"
	speak = list("ribbit","croak")
	emote_see = list("hops in a circle.", "shakes.")
	speak_chance = 1
	turns_per_move = 5
	maxHealth = 15
	health = 15
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "bites"
	response_help  = "pets"
	response_disarm = "pokes"
	response_harm   = "splats"
	density = FALSE
	ventcrawler = VENTCRAWLER_ALWAYS
	faction = list("hostile")
	attack_sound = 'sound/effects/reee.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/nugget = 1)
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/retaliate/frog/Initialize()
	. = ..()
	if(prob(1))
		name = "rare frog"
		desc = "It seems a little smug."
		icon_state = "rare_frog"
		icon_living = "rare_frog"
		icon_dead = "rare_frog_dead"
		butcher_results = list(/obj/item/reagent_containers/food/snacks/nugget = 5)

/mob/living/simple_animal/hostile/retaliate/frog/Crossed(AM as mob|obj)
	if(!stat && isliving(AM))
		var/mob/living/L = AM
		if(L.mob_size > MOB_SIZE_TINY)
			playsound(src, 'sound/effects/huuu.ogg', 50, 1)

/mob/living/simple_animal/hostile/lizard
	name = "lizard"
	desc = "A cute tiny lizard."
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	speak_emote = list("hisses")
	health = 5
	maxHealth = 5
	attacktext = "bites"
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"

	size = SIZE_TINY
	mob_property_flags = MOB_NO_PETRIFY //Can't get petrified (nethack references)
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal/lizard
	held_items = list()

	stop_automated_movement_when_pulled = TRUE
	environment_smash_flags = FALSE
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	vision_range = 6
	aggro_vision_range = 6
	idle_vision_range = 6

	var/static/list/edibles = list(/mob/living/simple_animal/cockroach, /obj/item/weapon/reagent_containers/food/snacks/roach_eggs) //Add bugs to this as they get added in

/mob/living/simple_animal/hostile/lizard/proc/gulp(var/atom/eat_this)
		visible_message("\The [name] consumes [eat_this] in a single gulp.", "<span class='notice'>You consume [eat_this] in a single gulp.</span>")
		playsound(get_turf(src),'sound/items/egg_squash.ogg', rand(30,70), 1)
		qdel(eat_this)
		adjustBruteLoss(-2)

/mob/living/simple_animal/hostile/lizard/ListTargets()
	var/list/L = new()
	L.Add(oview(vision_range, src))
	return L

/mob/living/simple_animal/hostile/lizard/CanAttack(var/atom/the_target)//Can we actually attack a possible target?
	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE
	if(is_type_in_list(the_target, edibles))
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/lizard/AttackingTarget()
	if(is_type_in_list(target, edibles))
		return TRUE
	else
		return ..()

/mob/living/simple_animal/hostile/lizard/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


/mob/living/simple_animal/hostile/lizard/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Object"

	if(isUnconscious())
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))

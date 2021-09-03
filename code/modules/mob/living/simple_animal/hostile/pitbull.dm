/mob/living/simple_animal/hostile/pitbull
	name = "pitbull"
	icon_state = "pitbull"
	icon_living = "pitbull"
	icon_dead = "pitbull_dead"
	speak_chance = 20
	emote_hear = list("growls", "barks")
	response_help = "pets"
	response_disarm = "gently pushes aside"
	response_harm = "hits"

	health = 25
	maxHealth = 25
	turns_per_move =2//I don't know what this does
	speed = 4
	move_to_delay = 3

	melee_damage_lower = 3
	melee_damage_upper = 5
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	var/faction_original
	var/list/friends_temp = list() //a temporary list to hold the values in friends while it becomes empty during treachery

	var/treachery_chance = 0.25
	var/treacherous = FALSE
	var/calmdown_chance = 20

/mob/living/simple_animal/hostile/pitbull/New()
	..()
	pitbulls_exclude_kinlist.Add(src)
	desc = pick(
		"There is no such thing as a bad dog, only bad owners.",
		"Blame the owner not the breed!",
		"My dog would never do that.",
		"He's a big baby at heart.",
		"Man's best friend.",
		"Over 4 million pitbulls did not kill or hurt anyone today. Stop the myth.",
		"Good with kids.")

/mob/living/simple_animal/hostile/pitbull/ListTargets()
	var/list/L = ..()
	for(var/mob/M in L)
		if(M in pitbulls_exclude_kinlist)
			L.Remove(M)
	return L

/mob/living/simple_animal/hostile/pitbull/Life()
	if(prob(treachery_chance))
		Treachery() //empties the friend list and faction allignment

	if(treacherous && prob(calmdown_chance))
		Calmdown() //repopulates the friend list and realligns our faction
	..()

/mob/living/simple_animal/hostile/pitbull/proc/Treachery()
	faction_original = faction
	faction = ""
	friends_temp = friends.Copy()
	friends = list()
	treacherous = TRUE

/mob/living/simple_animal/hostile/pitbull/proc/Calmdown()
	faction = faction_original
	friends = friends_temp.Copy()
	if(target && ismob(target))
		var/mob/M = target
		if((M.faction == faction) || (M in src.friends))//stop chasing our friend when we calm down
			LoseTarget()
	treacherous = FALSE

/mob/living/simple_animal/hostile/pitbull/attackby(obj/item/I, mob/user)
	..()
	if(istype(I,/obj/item/weapon/pickaxe/shovel))
		if(prob(10))
			gib()
		else
			adjustBruteLoss(25)//instakill

/mob/living/simple_animal/hostile/pitbull/summoned_pitbull
	faction = "wizard" // so they get along with other wizard mobs
	meat_type = /obj/item/weapon/ectoplasm //a magical dog

/mob/living/simple_animal/hostile/pitbull/summoned_pitbull/death(var/gibbed = FALSE)
	..()
	if(!gibbed)
		if(prob(95))
			animate(src, alpha = 0, time = 4 SECONDS)
			spawn(4 SECONDS)
				qdel(src)
		else
			gib()
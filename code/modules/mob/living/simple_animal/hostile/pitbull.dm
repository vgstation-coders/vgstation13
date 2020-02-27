//[]TODO: increase the chance of pitbulls targetting younger aged crew according to character preferences or something, alot of people wanted this but I have no idea how to code it. - realestestate

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
	turns_per_move =2//I don't know what this does //default 3
	speed = 4
	move_to_delay = 3 //debug: was 3

	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	var/faction_original
	var/list/friends_temp = list() //a temporary list to hold the values in friends while it becomes empty during treachery

	var/treachery_chance = 0.25
	var/treacherous = FALSE


var/list/pitbulls = list()

/mob/living/simple_animal/hostile/pitbull/New()
	..()
	pitbulls.Add(src)
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
		if(M in pitbulls) //if(pitbulls[src] == M) was the original
			L.Remove(M)
	return L

/mob/living/simple_animal/hostile/pitbull/Life()
	if(prob(treachery_chance))
		Treachery() //empties the friend list and faction allignment

	if(treacherous && prob(5))
		Calmdown() //repopulates the friend list and realligns our faction
	..()

/mob/living/simple_animal/hostile/pitbull/proc/Treachery() //something isn't working and pitbulls are attacking other pitbulls when becoming treacherous
	faction_original = faction
	faction = ""
	friends_temp = friends
	friends.Cut()
	treacherous = TRUE

/mob/living/simple_animal/hostile/pitbull/proc/Calmdown()
	faction = faction_original
	friends = friends_temp
	if(target && ismob(target))
		var/mob/M = target
		if((M.faction == faction) || (M in src.friends))//stop chasing our friend when we calm down
			LoseTarget()
	treacherous = FALSE

//some dude named yclat asked for this, I'm so fucking sorry ahhhhhhh
/mob/living/simple_animal/hostile/pitbull/attackby(obj/item/I, mob/user)
	..()
	if(istype(I,/obj/item/weapon/pickaxe/shovel))
		if(prob(10))
			gib()
		else
			adjustBruteLoss(25)//instakill

/mob/living/simple_animal/hostile/pitbull/summoned_pitbull
	faction = "wizard"

/mob/living/simple_animal/hostile/pitbull/summoned_pitbull/death()
	..(TRUE)
	var/mob/my_wiz = pitbulls[src]
	pitbulls_count_by_wizard[my_wiz]--
	if(pitbulls_count_by_wizard[my_wiz] == 0)
		pitbulls_count_by_wizard -= my_wiz
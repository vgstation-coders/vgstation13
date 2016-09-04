/mob/living/simple_animal/hostile/necro
	var/mob/creator
/mob/living/simple_animal/hostile/necro/skeleton
	name = "skeleton"
	desc = "Truly the ride never ends."
	icon_state = "skelly"
	icon_living = "skelly"
	icon_dead = "skelly_dead"
	icon_gib = "skelly_dead"
	speak_chance = 0
	turns_per_move = 1
	can_butcher = 0
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 8
	move_to_delay = 3
	maxHealth = 50
	health = 50

	can_butcher = 0

	harm_intent_damage = 10
	melee_damage_lower = 5
	melee_damage_upper = 10
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	environment_smash = 1
	meat_type = null

/mob/living/simple_animal/hostile/necro/zombie
	name = "zombie"
	desc = "A reanimated corpse that looks like it has seen better days."
	icon_state = "zombie"
	icon_living = "zombie"
	icon_dead = "zombie_dead"
	icon_gib = "zombie_dead"
	speak_chance = 0
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	speed = 2
	move_to_delay = 6
	maxHealth = 100
	health = 100
	canRegenerate = 1
	minRegenTime = 300
	maxRegenTime = 1800


	harm_intent_damage = 15
	melee_damage_lower = 10
	melee_damage_upper = 20
	attacktext = "bites"
	attack_sound = 'sound/weapons/bite.ogg'

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	environment_smash = 1

/mob/living/simple_animal/hostile/necro/New(loc, mob/living/Owner, datum/mind/Controller)
	..()
	if(Owner && Controller)
		faction = "\ref[Owner]"
		if(Controller)
			mind = Controller
			ckey = ckey(mind.key)
			to_chat(src, "<big><span class='warning'>You have been risen from the dead by your new master, [Owner]. Do his bidding so long as he lives, for when he falls so do you.</span></big>")
		var/ref = "\ref[Owner.mind]"
		var/list/necromancers
		if(!(Owner.mind in ticker.mode.necromancer))
			ticker.mode:necromancer[ref] = list()
		necromancers = ticker.mode:necromancer[ref]
		necromancers.Add(Controller)
		ticker.mode:necromancer[ref] = necromancers
		ticker.mode.update_necro_icons_added(Owner.mind)
		ticker.mode.update_necro_icons_added(Controller)
		ticker.mode.update_all_necro_icons()
		ticker.mode.risen.Add(Controller)
	name += " ([rand(1,1000)])"

/mob/living/simple_animal/hostile/necro/copy/ListTargets()
	. = ..()
	return . - creator

/mob/living/simple_animal/hostile/necro/zombie/leatherman
	..()
	name = "leatherman"
	icon_dead = "zombie_leather_dead"
	icon_gib = "zombie_leather_dead"
	icon_state = "zombie_leather"
	icon_living = "zombie_leather"
	desc = "Fuck you!"

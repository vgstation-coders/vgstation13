/mob/living/simple_animal/lizard
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

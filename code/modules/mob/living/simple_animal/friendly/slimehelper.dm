/mob/living/simple_animal/hostile/helperslime
	name = "Yuu"
	desc = "A cute slime that picks up slime cores"
	icon_state = "helperslime"
	icon_living = "helperslime"
	icon_dead = "helperslime_dead"
	speak_emote = list("goops")
	health = 90
	maxHealth = 90
	attacktext = "glomps"
	response_help  = "hugs"
	response_disarm = "shoos"
	response_harm   = "slaps"
	wander = 0
	faction = list("neutral","slimesummon")
	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	size = SIZE_BIG
	held_items = list()
	wanted_objects = list(/obj/item/slime_extract)
/mob/living/simple_animal/penguin
	name = "penguin"

	desc = "Noot."
	icon_state = "penguin"
	icon_living = "penguin"
	icon_dead = ("penguin_dead")
	size = SIZE_NORMAL
	speak = list("Noot.", "Noot!", "Pree!")
	speak_emote = list("noots", "calls")
	emote_hear = list("squaks", "screeches")
	emote_see = list("shakes", "shivers")
	emote_sound = list("sound/voice/penguin.ogg")
	speak_chance = 1
	turns_per_move = 5

	speak_override = TRUE


	can_breed = 1
	species_type = /mob/living/simple_animal/penguin
	childtype = /mob/living/simple_animal/penguin/chick
	child_amount = 1
	holder_type = null

	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	min_oxy = 16      // Require atleast 16kPA oxygen
	minbodytemp = 223 // Below -50 Degrees Celcius
	maxbodytemp = 323 // Above 50 Degrees Celcius

/mob/living/simple_animal/penguin/New()
	.=..()
	gender = pick(MALE, FEMALE)

/mob/living/simple_animal/penguin/chick
	name = "penguin chick"

	desc = "Peep!"
	icon_state = "penguin_chick"
	icon_living = "penguin_chick"
	icon_dead = ("penguin_chick_dead")
	size = SIZE_SMALL
	holder_type = /obj/item/weapon/holder/animal // bomber making an inhand for baby penguins when
	speak_emote = list("peeps", "calls")

/mob/living/simple_animal/penguin/sombrero
	name = "Peng Peng"

	desc = "This penguin knows how to party."
	icon_state = "penguin_sombrero"
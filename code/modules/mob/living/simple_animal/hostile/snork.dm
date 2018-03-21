//Inherits heavily from frog.dm

/mob/living/simple_animal/hostile/frog/snork
	name = "mutated assistant"
	desc = "Radiation and twisted experiments have created this monster of a man.  What purpose it had is unknowable."
	
	icon_state = "tide_feral"
	icon_living = "tide_feral"
	icon_dead = "tide_dead"

	health = 60
	maxHealth = 60

	speak_chance = 1
	emote_hear = list("growls", "mumbles something")
	emote_see = list("scans the area")

	ranged = 1
	ranged_cooldown_cap = 8
	ranged_message = "leaps"

	harm_intent_damage = 5

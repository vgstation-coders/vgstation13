/mob/living/carbon/not_human/gondola
	name = "gondola"
	desc = "A calming presence in this strange land."
	icon = 'icons/mob/gondola.dmi'

	icon_state_standing = "gondola"
	icon_state_lying = "gondola_lying"
	icon_state_dead = "gondola_dead"

	maxHealth = 75
	health = 75

	held_items = list()

	size = SIZE_NORMAL
	status_flags = CANSTUN|CANKNOCKDOWN|CANPARALYSE|CANPUSH
	mob_bump_flag = HUMAN
	mob_push_flags = ALLMOBS
	mob_swap_flags = ALLMOBS

/mob/living/carbon/not_human/gondola/New()
	icon_state_standing = pick("gondola","gondola_1")
	icon_state_lying = "[icon_state_standing]_lying"
	icon_state_dead = "[icon_state_dead]_dead"
	..()


/mob/living/carbon/not_human/gondola/say()
	return
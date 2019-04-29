/mob/living/carbon/monkey/rock
	name = "rock"
	voice_name = "rock"
	speak_emote = list("grinds")
	icon_state = "rock1"
	meat_type = /obj/item/stack/ore/diamond
	species_type = /mob/living/carbon/monkey/rock
	flag = NO_BREATHE

	mob_bump_flag = MONKEY
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL|ALIEN

	canWearClothes = 0
	canWearHats = 1
	canWearGlasses = 1
	greaterform = "Golem"
	languagetoadd = LANGUAGE_GOLEM

/mob/living/carbon/monkey/rock/passive_emote()
	emote(pick("scratch","jump","roll"))

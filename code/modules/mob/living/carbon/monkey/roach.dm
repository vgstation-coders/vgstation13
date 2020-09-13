/mob/living/carbon/monkey/roach
	name = "roach"
	voice_name = "roach"
	speak_emote = list("hisses")
	icon_state = "bigroach"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/roach/big
	species_type = /mob/living/carbon/monkey/roach
	flag = RAD_IMMUNE

	mob_bump_flag = MONKEY
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL|ALIEN

	canWearClothes = 0
	canWearHats = 1
	canWearGlasses = 0
	greaterform = "Insectoid"
	languagetoadd = LANGUAGE_INSECT

/mob/living/carbon/monkey/roach/passive_emote()
	emote(pick("scratch","jump","roll"))

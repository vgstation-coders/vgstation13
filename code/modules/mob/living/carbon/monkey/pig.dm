/mob/living/carbon/monkey/pig
	name = "pig"
	voice_name = "pig"
	speak_emote = list("snorts")
	icon_state = "pig1"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal
	species_type = /mob/living/carbon/monkey/pig

	mob_bump_flag = MONKEY
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL|ALIEN

	canWearClothes = 0
	canWearGlasses = 0
	greaterform = "Suid"
	languagetoadd = LANGUAGE_SUID

/mob/living/carbon/monkey/pig/put_in_hand_check(var/obj/item/W)	//Pigs don't have hands.
	return 0
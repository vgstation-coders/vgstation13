/mob/living/carbon/monkey/roach
	name = "isopod"
	voice_name = "isopod"
	speak_emote = list("chirrups")
	icon_state = "isopod"
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/roach/big/isopod
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
	emote(pick("scratch","scuttle","roll"))


/mob/living/carbon/monkey/roach/update_icons()
	update_hud()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	overlays.Cut()
	var/matrix/M = matrix()
	for(var/image/I in overlays_standing)
		overlays += I

	if(stat == DEAD)
		icon_state = "[initial(icon_state)]_dead"
		src.transform = M
	else if(resting)
		icon_state = "[initial(icon_state)]_sleep"
	else if(lying || stunned)
		icon_state = "[initial(icon_state)]_sleep"
		M.Turn(90)
		M.Translate(1,-6)
		src.transform = M
	else
		icon_state = "[initial(icon_state)]"
		src.transform = M

/mob/living/carbon/monkey/roach/death(gibbed)
	..()
	for (var/obj/item/I in get_all_slots())
		drop_from_inventory(I) // Floating hat, mask and bag looks silly as fuck
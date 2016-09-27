/mob/living/carbon/monkey/skellington
	name = "skull"
	voice_name = "skull"
	icon_state = "skull"
	attack_text = "bites"
	species_type = /mob/living/carbon/monkey/skellington
	can_butcher = 0 //It's a skull, what do you expect?
	canWearClothes = 0
	canWearHats = 0
	canWearGlasses = 0
	languagetoadd = LANGUAGE_CLATTER
	brute_damage_modifier = 2
	movement_speed_modifier = 0.23
	greaterform = "Skellington"

/mob/living/carbon/monkey/skellington/say(var/message)
	if (prob(25))
		message += "  ACK ACK!"

	return ..(message)


/mob/living/carbon/monkey/skellington/put_in_hand_check(var/obj/item/W)
	return 0

/mob/living/carbon/monkey/skellington/New()
	..()
	set_hand_amount(0)

/mob/living/carbon/monkey/skellington/plasma
	name = "flaming skull"
	voice_name = "flaming skull"
	icon_state = "flaming_skull"
	greaterform = "Plasmaman"
	light_range = 2
	light_power = 0.5
	light_color = "#FAA019"
	species_type = /mob/living/carbon/monkey/skellington/plasma
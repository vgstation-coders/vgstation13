/mob/living/carbon/metroid/gold
	subtype = "gold"
	icon_state = "gold baby metroid"
	primarytype = /mob/living/carbon/metroid/gold
	adulttype = /mob/living/carbon/metroid/adult/gold
	coretype = /obj/item/metroid_core/gold

/mob/living/carbon/metroid/adult/gold
	icon_state = "gold adult metroid"
	subtype = "gold"
	primarytype = /mob/living/carbon/metroid/gold
	adulttype = /mob/living/carbon/metroid/adult/gold
	coretype = /obj/item/metroid_core/gold

	mutationtypes = list(
		/mob/living/carbon/metroid/gold,
		// /mob/living/carbon/metroid/adamantine
	)

/obj/item/metroid_core/gold
	name = "gold metroid core"
	icon_state = "gold metroid core"


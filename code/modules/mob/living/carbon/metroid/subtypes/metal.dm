/mob/living/carbon/metroid/metal
	subtype = "metal"
	icon_state = "metal baby metroid"
	primarytype = /mob/living/carbon/metroid/metal
	adulttype = /mob/living/carbon/metroid/adult/metal
	coretype = /obj/item/metroid_core/metal

/mob/living/carbon/metroid/adult/metal
	icon_state = "metal adult metroid"
	subtype = "metal"
	primarytype = /mob/living/carbon/metroid/metal
	adulttype = /mob/living/carbon/metroid/adult/metal
	coretype = /obj/item/metroid_core/metal

	mutationtypes=list(
//		/mob/living/carbon/metroid/silver,
		/mob/living/carbon/metroid/electric,
		/mob/living/carbon/metroid/gold
	)

/obj/item/metroid_core/metal
	name = "metal metroid core"
	icon_state = "metal metroid core"


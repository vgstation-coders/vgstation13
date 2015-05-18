/obj/item/weapon/reagent_containers/pill/patch
	name = "chemical patch"
	desc = "A chemical patch for touch based applications."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bandaid"
	item_state = "bandaid"
	possible_transfer_amounts = null
	volume = 50
	apply_type = TOUCH
	apply_method = "apply"
	apply_method_plural = "applies"

/obj/item/weapon/reagent_containers/pill/patch/New()
	..()
	icon_state = "bandaid"

/obj/item/weapon/reagent_containers/pill/patch/afterattack(obj/target, mob/user , proximity)
	return // thanks inheritance again
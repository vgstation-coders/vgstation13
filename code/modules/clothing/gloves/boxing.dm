/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxingred"
	item_state = "boxingred"
	species_fit = list(VOX_SHAPED)
	bonus_knockout = 12

/obj/item/clothing/gloves/boxing/dexterity_check()
	return 0 //Wearing boxing gloves makes you less dexterious (so, for example, you can't use computers)

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	species_fit = list(VOX_SHAPED)

/obj/item/clothing/gloves/boxing/attackby(obj/W, mob/user)
	..()

	if(istype(W, /obj/item/bear_hands))
		visible_message("\the [user] attaches \the [W] to \the [src]")
		new/obj/item/clothing/gloves/boxing/bear(get_turf(src))
		user.drop_item(W, force_drop = 1)
		user.drop_item(src, force_drop = 1)
		qdel(W)
		qdel(src)

/obj/item/clothing/gloves/boxing/bear
	name = "bear gauntlets"
	desc = "Time to get things done with your bear hands."
	icon_state = "bear_gloves"
	item_state = "bear_gloves"

	damage_added = 5
	origin_tech = Tc_COMBAT + "=2;"
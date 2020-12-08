/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxingred"
	item_state = "boxingred"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)
	bonus_knockout = 12

/obj/item/clothing/gloves/boxing/dexterity_check()
	return 0 //Wearing boxing gloves makes you less dexterious (so, for example, you can't use computers)

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"
	item_state = "boxinggreen"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"
	item_state = "boxingblue"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"
	item_state = "boxingyellow"
	species_fit = list(VOX_SHAPED, INSECT_SHAPED)

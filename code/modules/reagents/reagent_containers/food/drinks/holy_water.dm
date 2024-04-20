/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "Flask of Holy Water"
	desc = "A flask of the chaplain's holy water."
	icon_state = "holyflask"
	bottleheight = 25
	molotov = -1
	isGlass = 1
	smashtext = ""
	smashname = "broken flask"
	controlled_splash = TRUE

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/New()
	..()
	reagents.add_reagent(HOLYWATER, 100)

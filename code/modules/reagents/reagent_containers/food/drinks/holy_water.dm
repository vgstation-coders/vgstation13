/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater
	name = "flask of Holy Water"
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

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/sacredwater
	name = "flask of Sacred Water"
	desc = "Spreads a sacred flame when thrown to the floor, burning the unholy."
	icon_state = "sacredwater"
	bottleheight = 21
	molotov = -1
	isGlass = 1
	smashtext = ""
	smashname = "broken flask"
	controlled_splash = TRUE

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/sacredwater/New()
	..()
	reagents.clear_reagents()
	reagents.add_reagent(SACREDWATER, 100)

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/sacredwater/pre_throw(var/atom/movable/target,var/mob/living/user)
	icon_state = "sacredwater_thrown"
	..()

/obj/item/weapon/reagent_containers/food/drinks/bottle/holywater/sacredwater/throw_impact(atom/impacted_atom, speed, mob/user)
	icon_state = "sacredwater"
	..()

/obj/structure/closet/coffin
	name = "coffin"
	desc = "It's a burial receptacle for the dearly departed."
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

	starting_materials = list(MAT_WOOD = 5*CC_PER_SHEET_MISC)

/obj/structure/closet/coffin/Destroy()
	new /obj/item/stack/sheet/wood(loc,3) //This will result in 3 dropped if destroyed, or 5 if deconstructed
	..()

/obj/structure/closet/coffin/update_icon()
	if(!opened)
		icon_state = icon_closed
	else
		icon_state = icon_opened
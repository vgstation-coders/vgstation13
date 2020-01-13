/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	desc = "A bit classier than just chucking bottles onto the bar."
	req_access = list(access_bar)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"


/obj/structure/closet/secure_closet/bar/atoms_to_spawn()
	return list(
		/obj/item/weapon/reagent_containers/food/drinks/beer = 10,
	)

/obj/structure/closet/secure_closet/bar/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

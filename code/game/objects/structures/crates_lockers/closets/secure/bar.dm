/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	desc = "A bit classier than just chucking bottles onto the bar."
	req_access = list(access_bar)
	icon_state = "cabinetdetective"
	is_wooden = TRUE
	starting_materials = list(MAT_WOOD = 2*CC_PER_SHEET_WOOD)
	w_type = RECYK_WOOD
	overlay_x = -1

/obj/structure/closet/secure_closet/bar/atoms_to_spawn()
	return list(
		/obj/item/weapon/reagent_containers/food/drinks/beer = 10,
	)
#define STUNGLOVES_CHARGE_COST 2500

/obj/item/clothing/gloves/attackby(obj/item/weapon/W, mob/user)
	if(istype(src, /obj/item/clothing/gloves/boxing))	//quick fix for stunglove overlay not working nicely with boxing gloves.
		to_chat(user, "<span class='notice'>That won't work.</span>")//i'm not putting my lips on that!

		..()
		return
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(!wired)
			if(C.amount >= 2)
				C.use(2)
				wired = 1
				siemens_coefficient = 3.0
				to_chat(user, "<span class='notice'>You wrap some wires around [src].</span>")
				update_icon()
			else
				to_chat(user, "<span class='notice'>There is not enough wire to cover [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] are already wired.</span>")

	else if(istype(W, /obj/item/weapon/cell))
		if(!wired)
			to_chat(user, "<span class='notice'>[src] need to be wired first.</span>")
		else if(!cell)
			if(user.drop_item(W, src))
				cell = W
				to_chat(user, "<span class='notice'>You attach a cell to [src].</span>")
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] already have a cell.</span>")

	else if(iswirecutter(W))
		if(cell)
			cell.updateicon()
			cell.forceMove(get_turf(src.loc))
			cell = null
			to_chat(user, "<span class='notice'>You cut the cell away from [src].</span>")
			update_icon()
			return
		if(wired) //wires disappear into the void because fuck that shit
			wired = 0
			siemens_coefficient = initial(siemens_coefficient)
			to_chat(user, "<span class='notice'>You cut the wires away from [src].</span>")
			update_icon()
		..()
	return

/obj/item/clothing/gloves/update_icon()
	..()
	overlays.len = 0
	if(wired)
		overlays += image(icon = icon, icon_state = "gloves_wire")
	if(cell)
		overlays += image(icon = icon, icon_state = "gloves_cell")
	if(wired && cell)
		item_state = "stungloves"
	else
		item_state = icon_state
	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.update_inv_gloves()

/obj/item/clothing/gloves/Touch(atom/A, mob/living/user, prox)
	if(!isliving(A))
		return
	if(!cell)
		return

	var/mob/living/L = A
	if(prox == TRUE)//Stungloves. ANY contact will stun the alien.
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(H.check_body_part_coverage(HANDS,src)) //can't touch someone if something is on top of them
				return
		visible_message("<span class='danger'>\The [A] has been touched with the stun gloves by [user]!</span>")

		if(cell.charge >= STUNGLOVES_CHARGE_COST)
			cell.charge -= STUNGLOVES_CHARGE_COST

			add_logs(user, A, "stungloved", admin = TRUE)

			var/armorblock = L.run_armor_check(user.zone_sel.selecting, "energy")
			L.apply_effects(5,5,0,0,5,0,0,armorblock)

		else
			add_logs(user, A, "attempted to stunglove", admin = TRUE)

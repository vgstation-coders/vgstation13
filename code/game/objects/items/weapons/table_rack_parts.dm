/* Table parts and rack parts
 * Contains:
 *		table parts
 *		reinforced table Parts
 *		wooden table parts
 * 		wooden poker table parts
 * 		glass table parts
 *		rack parts
 */

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	starting_materials = list(MAT_IRON = 3750)
	w_type = RECYK_METAL
	melt_temperature=MELTPOINT_STEEL
	flags = FPRINT
	siemens_coefficient = 1
	attack_verb = list("slams", "bashes", "batters", "bludgeons", "thrashes", "whacks")

/obj/item/weapon/table_parts/cultify()
	new /obj/item/weapon/table_parts/wood(loc)
	..()

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W, mob/user)
	..()
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/metal, user.loc, 1, user)
		qdel(src)
		return
	if (istype(W, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = W
		if (rods.amount >= 4)
			new /obj/item/weapon/table_parts/reinforced(user.loc)
			to_chat(user, "<span class='notice'>You reinforce the [name].</span>")
			rods.use(4)
			qdel(src)
		else if (rods.amount < 4)
			to_chat(user, "<span class='warning'>You need at least four rods to do this.</span>")
		return
	if (istype(W, /obj/item/stack/sheet/glass/glass))
		var/obj/item/stack/sheet/glass/glass = W
		if (glass.amount >= 1)
			new /obj/item/weapon/table_parts/glass(user.loc)
			to_chat(user, "<span class='notice'>You add glass panes to \the [name].</span>")
			glass.use(1)
			qdel(src)

/obj/item/weapon/table_parts/attack_self(mob/user)
	new /obj/structure/table(user.loc)
	user.drop_item(src, force_drop = 1)
	qdel(src)


/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	starting_materials = list(MAT_IRON = 7500)
	w_type = RECYK_METAL
	melt_temperature=MELTPOINT_STEEL
	flags = FPRINT
	siemens_coefficient = 1

/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/metal, user.loc, 1, user)
		drop_stack(/obj/item/stack/rods, user.loc, 1, user)
		qdel(src)

/obj/item/weapon/table_parts/reinforced/attack_self(mob/user)
	new /obj/structure/table/reinforced(user.loc)
	user.drop_item(src, force_drop = 1)
	qdel(src)
	return


/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = 0

/obj/item/weapon/table_parts/wood/cultify()
	return

/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/wood, user.loc, 1, user)
		qdel(src)
		return
	if (istype(W, /obj/item/stack/tile/grass))
		var/obj/item/stack/tile/grass/Grass = W

		if(!Grass.use(1))
			return

		new /obj/item/weapon/table_parts/wood/poker(user.loc)
		visible_message("<span class='notice'>[user] adds grass to the wooden table parts.</span>")
		qdel(src)

/obj/item/weapon/table_parts/wood/poker
	name = "gambling table parts"
	icon_state = "gambling_tableparts"

/obj/item/weapon/table_parts/wood/attack_self(mob/user)
	new /obj/structure/table/woodentable(user.loc)
	user.drop_item(src, force_drop = 1)
	qdel(src)
	return

/obj/item/weapon/table_parts/wood/poker/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/wood, user.loc, 1, user)
		drop_stack(/obj/item/stack/tile/grass, user.loc, 1, user)
		qdel(src)

/obj/item/weapon/table_parts/wood/poker/attack_self(mob/user)
	new /obj/structure/table/woodentable/poker(user.loc)
	user.drop_item(src, force_drop = 1)
	qdel(src)

/obj/item/weapon/table_parts/glass
	name = "glass table parts"
	desc = "Glass table parts for the spaceman with style."
	icon = 'icons/obj/items.dmi'
	icon_state = "glass_tableparts"
	starting_materials = list(MAT_GLASS = 3750)
	w_type = RECYK_GLASS
	melt_temperature=MELTPOINT_GLASS
	flags = FPRINT
	siemens_coefficient = 0 //copying from glass sheets and shards even if its bad balance

/obj/item/weapon/table_parts/glass/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/glass/glass, loc, 1, user)
		drop_stack(/obj/item/stack/sheet/metal, loc, 1, user)
		qdel(src)

/obj/item/weapon/table_parts/glass/attack_self(mob/user)
	new /obj/structure/table/glass(user.loc)
	qdel(src)


/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = FPRINT
	siemens_coefficient = 1
	starting_materials = list(MAT_IRON = 3750)
	w_type = RECYK_METAL
	melt_temperature=MELTPOINT_STEEL

/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W, mob/user)
	..()
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/metal, user.loc, 1, user)
		qdel(src)
		return
	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(0, user))
			to_chat(user, "You begin slicing through \the [src].")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, src, 60))
				to_chat(user, "You cut \the [src] into a gun stock.")
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/metal_gun_stock/I = new (user.loc)
					user.put_in_hands(I)
					qdel(src)
				else
					new /obj/item/weapon/metal_gun_stock(loc)
					qdel(src)
		else
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")

/obj/item/weapon/rack_parts/attack_self(mob/user)
	var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
	R.add_fingerprint(user)
	user.drop_item(src, force_drop = 1)
	qdel(src)

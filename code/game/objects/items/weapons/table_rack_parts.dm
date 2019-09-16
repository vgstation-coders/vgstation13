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
	var/table_type = /obj/structure/table
	sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2

/obj/item/weapon/table_parts/cultify()
	new /obj/item/weapon/table_parts/wood(loc)
	..()

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W, mob/user)
	..()
	if (iswrench(W))
		drop_stack(sheet_type, user.loc, sheet_amount, user)
		qdel(src)
		return
	if (iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(1, user))
			to_chat(user, "You begin the delicate process of heating and moulding \the [src].")
			playsound(user, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, src, 180))
				to_chat(user, "You finish bending the metal into the shape of an ansible.")
				if(src.loc == user)
					user.drop_item(src, force_drop = 1)
					var/obj/item/weapon/ghetto_ansible/I = new (user.loc)
					user.put_in_hands(I)
					qdel(src)
				else
					new /obj/item/weapon/ghetto_ansible(loc)
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
	if (istype(W, /obj/item/stack/sheet/glass/plasmaglass))
		var/obj/item/stack/sheet/glass/plasma = W
		if (plasma.amount >= 1)
			new /obj/item/weapon/table_parts/glass/plasma(user.loc)
			to_chat(user, "<span class='notice'>You add plasma glass panes to \the [name].</span>")
			plasma.use(1)
			qdel(src)
/obj/item/weapon/table_parts/attack_self(mob/user)
	if(locate(/obj/structure/table) in get_turf(user))
		to_chat(user, "<span class='warning'>There is already a table here!</span>")
		return

	new table_type(user.loc)
	user.drop_item(src, force_drop = 1)
	qdel(src)

/obj/item/weapon/table_parts/clockworkify()
	GENERIC_CLOCKWORK_CONVERSION(src, /obj/item/weapon/table_parts/clockwork, CLOCKWORK_GENERIC_GLOW)

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
	table_type = /obj/structure/table/reinforced

/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(sheet_type, user.loc, 1, user)
		drop_stack(/obj/item/stack/rods, user.loc, 1, user)
		qdel(src)

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = 0
	table_type = /obj/structure/table/woodentable
	sheet_type = /obj/item/stack/sheet/wood

/obj/item/weapon/table_parts/wood/cultify()
	return

/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(sheet_type, user.loc, 1, user)
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
	table_type = /obj/structure/table/woodentable/poker
	sheet_type = /obj/item/stack/sheet/wood

/obj/item/weapon/table_parts/wood/poker/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(sheet_type, user.loc, 1, user)
		drop_stack(/obj/item/stack/tile/grass, user.loc, 1, user)
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
	table_type = /obj/structure/table/glass

/obj/item/weapon/table_parts/glass/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/glass/glass, loc, 1, user)
		drop_stack(sheet_type, loc, 1, user)
		qdel(src)

/obj/item/weapon/table_parts/glass/plasma
	name = "glass table parts"
	desc = "Glass table parts in solid plasma. As stylish as they are sturdy."
	icon = 'icons/obj/items.dmi'
	icon_state = "plasma_tableparts"
	starting_materials = list(MAT_PLASMA = 3750)
	w_type = RECYK_GLASS
	melt_temperature=MELTPOINT_PLASMA
	flags = FPRINT
	siemens_coefficient = 0 //copying from glass sheets and shards even if its bad balance
	table_type = /obj/structure/table/glass/plasma

/obj/item/weapon/table_parts/glass/attackby(obj/item/weapon/W, mob/user)
	if (iswrench(W))
		drop_stack(/obj/item/stack/sheet/glass/plasmaglass, loc, 1, user)
		drop_stack(sheet_type, loc, 1, user)
		qdel(src)

/obj/item/weapon/table_parts/clockwork
	name = "brass table parts"
	desc = "Parts of a slightly beveled brass table."
	icon_state = "brass_tableparts"
	starting_materials = list(MAT_BRASS = 15000)
	table_type = /obj/structure/table/reinforced/clockwork
	sheet_type = /obj/item/stack/sheet/brass
	sheet_amount = 4

/obj/item/weapon/table_parts/clockwork/cultify()
	return

/obj/item/weapon/table_parts/clockwork/clockworkify()
	return

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
	var/sheet_amount = 1

/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W, mob/user)
	..()
	if (iswrench(W))
		drop_stack(sheet_type, user.loc, sheet_amount, user)
		qdel(src)
		return
	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.remove_fuel(1, user))
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
			return

/obj/item/weapon/rack_parts/attack_self(mob/user)
	var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
	R.add_fingerprint(user)
	user.drop_item(src, force_drop = 1)
	qdel(src)

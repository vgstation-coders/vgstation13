/*
 * Plasma glass sheet
 */
/obj/item/stack/sheet/glass/basic/plasma
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	p_amt = CC_PER_SHEET_PLASMA
	g_amt = CC_PER_SHEET_GLASS
	origin_tech = "materials=3;plasmatech=2"
	created_window = /obj/structure/window/plasmabasic

/obj/item/stack/sheet/glass/basic/plasma/recycle(var/obj/machinery/mineral/processing_unit/recycle/rec)
	rec.addMaterial("plasma",1)
	rec.addMaterial("glass", 1)
	return 1

/obj/item/stack/sheet/glass/basic/plasma/attack_self(mob/user as mob)
	construct_window(user)

/obj/item/stack/sheet/glass/basic/plasma/attackby(obj/item/W, mob/user)
	if( istype(W, /obj/item/stack/rods) )
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/glass/reinforced/plasma/RG = new (user.loc)
		RG.add_fingerprint(user)
		RG.add_to_stacks(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/basic/plasma/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if (!G && !RG && replace)
			user.put_in_hands(RG)
	else
		return ..()

/*
 * Reinforced plasma glass sheet
 */
/obj/item/stack/sheet/glass/reinforced/plasma
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	p_amt = CC_PER_SHEET_PLASMA
	g_amt = CC_PER_SHEET_GLASS
	m_amt = CC_PER_SHEET_METAL / 2
	origin_tech = "materials=4;plasmatech=2"
	created_window = /obj/structure/window/plasmareinforced

/obj/item/stack/sheet/glass/reinforced/plasma/recycle(var/obj/machinery/mineral/processing_unit/recycle/rec)
	rec.addMaterial("plasma",1)
	rec.addMaterial("glass", 1)
	rec.addMaterial("iron",  0.5)
	return 1

/obj/item/stack/sheet/glass/reinforced/plasma/attack_self(mob/user as mob)
	construct_window(user)
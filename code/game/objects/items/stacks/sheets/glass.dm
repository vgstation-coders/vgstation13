/* Glass stack types
 * Contains:
 *		Glass sheets
 *		Reinforced glass sheets
 *		Plasma Glass Sheets
 *		Reinforced Plasma Glass Sheets (AKA Holy fuck strong windows)
 *		Smart Glass Sheets
 */

/obj/item/stack/sheet/glass
	w_type = RECYK_GLASS
	melt_temperature = MELTPOINT_GLASS
	var/reinforced = 0
	var/rglass = 0
	//For solars created from this glass type
	var/glass_quality = 0.5 //Quality of a solar made from this
	var/shealth = 5 //Health of a solar made from this
	var/sname = "glass"
	var/shard_type = /obj/item/weapon/shard
	mat_type = MAT_GLASS
	siemens_coefficient = 0 //does not conduct

/obj/item/stack/sheet/glass/attackby(obj/item/W, mob/user)
	if(issolder(W))
		new /obj/item/weapon/circuitboard/blank(user.loc)
		to_chat(user, "<span class='notice'>You fashion a blank circuitboard out of the glass.</span>")
		playsound(src.loc, 'sound/items/Welder.ogg', 35, 1)
		src.use(1)
	if(istype(W, /obj/item/stack/rods) && !reinforced)
		var/obj/item/stack/rods/V  = W
		var/obj/item/stack/sheet/glass/RG = new rglass()
		RG.forceMove(user.loc) //This is because new() doesn't call forceMove, so we're forcemoving the new sheet to make it stack with other sheets on the ground.
		RG.add_fingerprint(user)
		V.use(1)
		var/obj/item/stack/sheet/glass/G = src
		src = null
		var/replace = (user.get_inactive_hand()==G)
		G.use(1)
		if (!G && !RG && replace)
			if(isMoMMI(user))
				RG.forceMove(get_turf(user))
			else
				user.put_in_hands(RG)
	else
		return ..()

/*
 * Glass sheets
 */

/obj/item/stack/sheet/glass/glass
	name = "glass"
	desc = "HOLY SHEET! That is a lot of glass."
	singular_name = "glass sheet"
	icon_state = "sheet-glass"
	starting_materials = list(MAT_GLASS = 3750)
	origin_tech = Tc_MATERIALS + "=1"
	rglass = /obj/item/stack/sheet/glass/rglass

/obj/item/stack/sheet/glass/glass/New(var/loc, var/amount=null)
	recipes = glass_recipes
	..()

/obj/item/stack/sheet/glass/glass/cyborg
	starting_materials = null

/obj/item/stack/sheet/glass/glass/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(CC.amount < 2) //Cost changed from 5 to 2, so that you get 15 tiles from a cable coil instead of only 6 (!)
			to_chat(user, "<B>There is not enough wire in this coil. You need at least two lengths.</B>")
			return
		CC.use(2)
		src.use(1)

		to_chat(user, "<span class='notice'>You attach some wires to the [name].</span>")//the dreaded dubblespan

		drop_stack(/obj/item/stack/light_w, get_turf(user), 1, user)
	else
		return ..()


/*
 * Reinforced glass sheets
 */

/obj/item/stack/sheet/glass/rglass
	name = "reinforced glass"
	desc = "Glass which seems to have rods or something stuck in them."
	singular_name = "reinforced glass sheet"
	sname = "glass_ref"
	icon_state = "sheet-rglass"
	starting_materials = list(MAT_IRON = 1875, MAT_GLASS = 3750)
	origin_tech = Tc_MATERIALS + "=2"
	reinforced = 1
	glass_quality = 1
	shealth = 10

/obj/item/stack/sheet/glass/rglass/New(var/loc, var/amount=null)
	recipes = rglass_recipes
	..()


/obj/item/stack/sheet/glass/rglass/cyborg
	starting_materials = null

/*
 * Plasma Glass sheets
 */

/obj/item/stack/sheet/glass/plasmaglass
	name = "plasma glass"
	desc = "A very strong and very resistant sheet of a plasma-glass alloy."
	singular_name = "glass sheet"
	icon_state = "sheet-plasmaglass"
	sname = "plasma"
	starting_materials = list(MAT_GLASS = CC_PER_SHEET_GLASS, MAT_PLASMA = CC_PER_SHEET_MISC)
	origin_tech = Tc_MATERIALS + "=3;" + Tc_PLASMATECH + "=2"
	rglass = /obj/item/stack/sheet/glass/plasmarglass
	perunit = 2875 //average of plasma and glass
	melt_temperature = MELTPOINT_STEEL + 500
	glass_quality = 1.15 //Can you imagine a world in which plasmaglass is worse than rglass
	shealth = 20
	shard_type = /obj/item/weapon/shard/plasma

/obj/item/stack/sheet/glass/plasmaglass/New(var/loc, var/amount=null)
	recipes = plasmaglass_recipes
	..()


/*
 * Reinforced plasma glass sheets
 */
/obj/item/stack/sheet/glass/plasmarglass
	name = "reinforced plasma glass"
	desc = "Plasma glass which seems to have rods or something stuck in them."
	singular_name = "reinforced plasma glass sheet"
	icon_state = "sheet-plasmarglass"
	sname = "plasma_ref"
	starting_materials = list(MAT_IRON = 1875, MAT_GLASS = CC_PER_SHEET_GLASS, MAT_PLASMA = CC_PER_SHEET_MISC)
	melt_temperature = MELTPOINT_STEEL+500 // I guess...?
	origin_tech = Tc_MATERIALS + "=4;" + Tc_PLASMATECH + "=2"
	perunit = 2875
	reinforced = 1
	glass_quality = 1.3
	shealth = 30
	shard_type = /obj/item/weapon/shard/plasma

/obj/item/stack/sheet/glass/plasmarglass/New(var/loc, var/amount=null)
	recipes = plasmarglass_recipes
	..()

var/list/datum/stack_recipe/glass_recipes = list (
	new/datum/stack_recipe("window", /obj/structure/window/loose, 1, time = 10, on_floor = TRUE),
	new/datum/stack_recipe("full window", /obj/structure/window/full/loose, 2, time = 10, on_floor = TRUE),
	)

var/list/datum/stack_recipe/rglass_recipes = list (
	new/datum/stack_recipe("window", /obj/structure/window/reinforced/loose, 1, time = 10, on_floor = TRUE),
	new/datum/stack_recipe("full window", /obj/structure/window/full/reinforced/loose, 2, time = 10, on_floor = TRUE),
	new/datum/stack_recipe("windoor", /obj/structure/windoor_assembly/, 5, time = 10, start_unanchored = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("glass tile", /obj/item/stack/glass_tile/rglass, 1, time = 2, on_floor = TRUE),
	)

var/list/datum/stack_recipe/plasmaglass_recipes = list (
	new/datum/stack_recipe("window", /obj/structure/window/plasma/loose, 1, time = 10, on_floor = TRUE),
	new/datum/stack_recipe("full window", /obj/structure/window/full/plasma/loose, 2, time = 10, on_floor = TRUE),
	)

var/list/datum/stack_recipe/plasmarglass_recipes = list (
	new/datum/stack_recipe("window", /obj/structure/window/reinforced/plasma/loose, 1, time = 10, on_floor = TRUE),
	new/datum/stack_recipe("full window", /obj/structure/window/full/reinforced/plasma/loose, 2, time = 10, on_floor = TRUE),
	new/datum/stack_recipe("windoor", /obj/structure/windoor_assembly/plasma, 5, time = 10, start_unanchored = TRUE, on_floor = TRUE),
	new/datum/stack_recipe("glass tile", /obj/item/stack/glass_tile/rglass/plasma, 1, time = 2, on_floor = TRUE),
	)
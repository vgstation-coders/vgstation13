/* Diffrent misc types of sheets
 * Contains:
 *		Metal
 *		Plasteel
 *		Wood
 *		Cloth
 *		Cardboard
 *		Bones
 */

/*
 * Metal
 */
/obj/item/stack/sheet/metal
	name = "metal"
	desc = "Sheets made out of metal. It has been dubbed Metal Sheets."
	singular_name = "metal sheet"
	icon_state = "sheet-metal"
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL)
	w_type = RECYK_METAL
	throwforce = 14.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = Tc_MATERIALS + "=1"
	melt_temperature = MELTPOINT_STEEL
	mat_type = MAT_IRON
	perunit = CC_PER_SHEET_METAL

/obj/item/stack/sheet/metal/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/item/stack/sheet/metal/blob_act()
	qdel(src)

/obj/item/stack/sheet/metal/singularity_act()
	qdel(src)
	return 2

// Diet metal.
/obj/item/stack/sheet/metal/cyborg
	starting_materials = null

/obj/item/stack/sheet/metal/New(var/loc, var/amount=null)
	recipes = metal_recipes
	return ..()

/*
 * Plasteel
 */
/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-plasteel"
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL, MAT_PLASMA = CC_PER_SHEET_PLASMA) // Was 7500, which doesn't make any fucking sense
	perunit = 2875 //average of plasma and metal
	throwforce = 15.0
	flags = FPRINT
	siemens_coefficient = 1
	origin_tech = Tc_MATERIALS + "=2"
	w_type = RECYK_METAL
	melt_temperature = MELTPOINT_STEEL+500

/obj/item/stack/sheet/plasteel/New(var/loc, var/amount=null)
		recipes = plasteel_recipes
		return ..()

/*
 * Wood
 */
/obj/item/stack/sheet/wood
	name = "wooden plank"
	desc = "One can only guess that this is wood."
	singular_name = "wooden plank"
	irregular_plural = "wooden plank"
	icon_state = "sheet-wood"
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 1 //Not used here the same way as elsewhere; see burnFireFuel() below.
	sheettype = "wood"
	w_type = RECYK_WOOD
	siemens_coefficient = 0 //no conduct
	mat_type = MAT_WOOD
	perunit = CC_PER_SHEET_WOOD

/obj/item/stack/sheet/wood/getFireFuel()
	return (amount - 1 + fire_fuel) / 5 //Each plank essentially has 0.2 fire_fuel.

/obj/item/stack/sheet/wood/burnFireFuel(used_fuel_ratio, used_reactants_ratio)
	var/expected_to_burn = used_fuel_ratio * used_reactants_ratio * amount //The expected number of planks to burn. Can be fractional.
	var/actually_burned = round(expected_to_burn) //Definitely burn the floor of that many.
	fire_fuel -= expected_to_burn - actually_burned //Subtract the remainder from fire_fuel.
	if(fire_fuel <= 0) //If that brings it below zero, burn another plank and increase fire_fuel to track the next fractional plank burned.
		++actually_burned
		++fire_fuel
	if(actually_burned)
		var/ashtype = ashtype()
		new ashtype(loc) //use() will delete src without calling ashify(), so here we spawn ashes if any planks burned, whether or not the object was destroyed.
	use(actually_burned)

/obj/item/stack/sheet/wood/afterattack(atom/Target, mob/user, adjacent, params)
	..()
	if(adjacent)
		if(isturf(Target) || istype(Target, /obj/structure/lattice))
			var/turf/T = get_turf(Target)
			if(T.canBuildLattice(src))
				if(src.use(1))
					to_chat(user, "<span class='notice'>Constructing some foundations ...</span>")
					playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
					new /obj/structure/lattice/wood(T)

/obj/item/stack/sheet/wood/cultify()
	return

/obj/item/stack/sheet/wood/New(var/loc, var/amount=null)
	recipes = wood_recipes
	return ..()

/*
 * Cloth
 */
/obj/item/stack/sheet/cloth
	name = "cloth"
	desc = "This roll of cloth is made from only the finest chemicals and bunny rabbits."
	singular_name = "cloth roll"
	icon_state = "sheet-cloth"
	origin_tech = Tc_MATERIALS + "=2"

/*
 * Cardboard
 */
/obj/item/stack/sheet/cardboard	//BubbleWrap //what???
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	flags = FPRINT
	origin_tech = Tc_MATERIALS + "=1"
	starting_materials = list(MAT_CARDBOARD = CC_PER_SHEET_CARDBOARD)
	w_type=RECYK_MISC

/obj/item/stack/sheet/cardboard/New(var/loc, var/amount=null)
		recipes = cardboard_recipes
		return ..()

/obj/item/stack/sheet/cardboard/recycle(var/datum/materials/rec)
	rec.addAmount(MAT_CARDBOARD, amount * get_material_cc_per_sheet(MAT_CARDBOARD))
	return 1

/*
 * /vg/ charcoal
 */
var/list/datum/stack_recipe/charcoal_recipes = list ()

/obj/item/stack/sheet/charcoal	//N3X15
	name = "charcoal"
	desc = "Yum."
	singular_name = "charcoal sheet"
	icon_state = "sheet-charcoal"
	flags = FPRINT
	origin_tech = Tc_MATERIALS + "=1"
	autoignition_temperature=AUTOIGNITION_WOOD

/obj/item/stack/sheet/charcoal/New(var/loc, var/amount=null)
		recipes = charcoal_recipes
		return ..()


/obj/item/stack/sheet/bone
	name = "bone"
	desc = "Boney.  Probably has some marrow left."
	singular_name = "bone"
	origin_tech = Tc_BIOTECH + "=1"
	icon_state = "sheet-bone"
	//item_state = "bone"

/obj/item/stack/sheet/brass
	name = "brass"
	desc = "Large sheets made out of brass."
	singular_name = "brass sheet"
	icon_state = "sheet-brass"
	sheettype = "clockwork"
	flags = FPRINT
	origin_tech = Tc_ANOMALY + "=1"
	starting_materials = list(MAT_BRASS = CC_PER_SHEET_BRASS)
	mat_type = MAT_BRASS

/obj/item/stack/sheet/brass/New(var/loc, var/amount=null)
	recipes = brass_recipes
	return ..()

/obj/item/stack/sheet/ralloy
	name = "replicant alloy"
	desc = "It's as if it's calling to be moulded into something greater."
	singular_name = "replicant alloy"
	icon_state = "sheet-alloy"
	flags = FPRINT
	origin_tech = Tc_ANOMALY + "=1"
	starting_materials = list(MAT_RALLOY = CC_PER_SHEET_RALLOY)
	mat_type = MAT_RALLOY

/obj/item/stack/sheet/ralloy/New(var/loc, var/amount=null)
	recipes = ralloy_recipes
	return ..()

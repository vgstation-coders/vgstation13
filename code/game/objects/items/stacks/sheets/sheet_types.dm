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
	siemens_coefficient = 0 //no conduct
	w_type = RECYK_WOOD
	starting_materials = list(MAT_WOOD = CC_PER_SHEET_WOOD)
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
	desc = "Some linen, made out of flax."
	singular_name = "lengths of cloth"
	icon_state = "sheet-cloth"
	item_state = "sheet-cloth"
	origin_tech = Tc_MATERIALS + "=2"
	autoignition_temperature = AUTOIGNITION_FABRIC
	fire_fuel = 1
	siemens_coefficient = 0.2
	w_type = RECYK_FABRIC
	starting_materials = list(MAT_FABRIC = CC_PER_SHEET_FABRIC)
	mat_type = MAT_FABRIC
	perunit = CC_PER_SHEET_FABRIC
	color = COLOR_LINEN

/obj/item/stack/sheet/cloth/New(loc, amount, var/param_color = null)
	..()
	recipes = cloth_recipes_by_hand
	if (param_color)
		color = param_color

/obj/item/stack/sheet/cloth/getFireFuel()
	return (amount - 1 + fire_fuel) / 10 //Each piece essentially has 0.1 fire_fuel.

/obj/item/stack/sheet/cloth/burnFireFuel(used_fuel_ratio, used_reactants_ratio)
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

/obj/item/stack/sheet/cloth/can_stack_with(obj/item/other_stack)
	if(ispath(other_stack) && (src.type == other_stack))
		return (uppertext(color) == COLOR_LINEN)

	if (src.type == other_stack.type)
		if (src.color == other_stack.color)
			return TRUE
		else
			to_chat(usr, "<span class='warning'>You cannot stack cloth rolls of different colors.</span>")
	return FALSE

/obj/item/stack/sheet/cloth/dye_act(var/obj/structure/reagent_dispensers/cauldron/cauldron, var/mob/user)
	to_chat(user, "<span class='notice'>You begin dyeing \the [src].</span>")
	playsound(cauldron.loc, 'sound/effects/slosh.ogg', 25, 1)
	if (do_after(user, cauldron, 30))
		var/mixed_color = mix_color_from_reagents(cauldron.reagents.reagent_list, TRUE)
		var/mixed_alpha = mix_alpha_from_reagents(cauldron.reagents.reagent_list)
		color = BlendRGB(color, mixed_color, mixed_alpha/255)
		user.update_inv_hands()
	return TRUE

/obj/item/stack/sheet/cloth/copy_evidences(var/obj/item/stack/from)
	..(from)
	color = from.color
	update_icon()

/obj/item/stack/sheet/cloth/use(var/amount)
	. = ..()
	update_icon()

/obj/item/stack/sheet/cloth/add(var/amount)
	. = ..()
	update_icon()

/obj/item/stack/sheet/cloth/extra_message()
	if (!in_needles_or_machine())
		return "<br><b>More recipes available when using knitting needles or a sewing machine</b>.<br>"
	return null

/obj/item/stack/sheet/cloth/proc/in_needles_or_machine()
	if(istype(loc, /obj/item/knitting_needles) || istype(loc, /obj/machinery/sewing_machine))
		return TRUE
	return FALSE

/obj/item/stack/sheet/cloth/time_modifier(var/_time)
	if(istype(loc, /obj/machinery/sewing_machine))
		var/obj/machinery/sewing_machine/SM = loc
		var/time_modifier = 0.5
		time_modifier = max(0.1, 0.5 - (0.1*SM.manipulator_rating))
		playsound(get_turf(src), 'sound/machines/sewing_machine.ogg', 50, 1)
		SM.operating = 1
		SM.update_icon()
		return _time * time_modifier
	else if (istype(loc, /obj/item/knitting_needles))
		var/obj/item/knitting_needles/KS = loc
		KS.knitting = 1
		KS.update_icon()
		playsound(get_turf(src), 'sound/machines/dial_reset.ogg', 50, 1)
		return _time * 0.75
	return _time

/obj/item/stack/sheet/cloth/stop_build(var/_last_crafting = FALSE)
	if (_last_crafting)
		if(istype(loc, /obj/machinery/sewing_machine))
			var/obj/machinery/sewing_machine/SM = loc
			SM.operating = 0
			SM.update_icon()
		else if (istype(loc, /obj/item/knitting_needles))
			var/obj/item/knitting_needles/KS = loc
			KS.knitting = 0
			KS.update_icon()

/obj/item/stack/sheet/cloth/on_empty()
	if(istype(loc, /obj/machinery/sewing_machine))
		var/obj/machinery/sewing_machine/SM = loc
		SM.stored_cloth = null
		SM.update_icon()
	else if (istype(loc, /obj/item/knitting_needles))
		var/obj/item/knitting_needles/KS = loc
		KS.stored_cloth = null
		KS.update_icon()
	..()

/obj/item/stack/sheet/cloth/loc_override()
	if (istype(loc, /obj/machinery/sewing_machine))
		var/obj/machinery/sewing_machine/SM = loc
		return SM.get_output()
	return null

/obj/item/stack/sheet/cloth/allow_use(var/mob/living/user)
	if (in_needles_or_machine())
		return loc.Adjacent(user)
	else
		return (user.get_active_hand() == src)

/obj/item/stack/sheet/cloth/list_recipes(var/mob/user, var/recipes_sublist)
	if (in_needles_or_machine())
		recipes = cloth_recipes_by_hand + cloth_recipes_with_tool
	else
		recipes = cloth_recipes_by_hand
	..()

/obj/item/stack/sheet/cloth/update_icon()
	if(amount == 1)
		icon_state = "sheet-cloth-single"
		name = "piece of [initial(name)]"
	else if(amount >= (MAX_SHEET_STACK_AMOUNT / 2))
		icon_state = "sheet-cloth-large"
		name = singular_name
	else
		icon_state = "sheet-cloth"
		name = singular_name

/obj/item/stack/sheet/cloth/examine()
	..()
	if(amount == 1)
		to_chat(usr, "<span class='info'>Enough for a rag maybe...</span>")
	else if(amount >= (MAX_SHEET_STACK_AMOUNT / 2))
		to_chat(usr, "<span class='info'>Now all you need is a loom or some sewing implements.</span>")
	else
		to_chat(usr, "<span class='info'>Can be used on its own to produce some basic items and clothing, but more can be made using the proper tools.</span>")


/*
 * Wax
 */
/obj/item/stack/sheet/wax
	name = "wax"
	desc = "Some wax cake, made out of beeswax."
	singular_name = "wax cake"
	icon_state = "sheet-wax"
	item_state = "sheet-wax"
	origin_tech = Tc_MATERIALS + "=2;" + Tc_BIOTECH + "=2"
	melt_temperature = MELTPOINT_WAX
	siemens_coefficient = 0.1
	w_type = RECYK_WAX
	starting_materials = list(MAT_FABRIC = CC_PER_SHEET_WAX)
	mat_type = MAT_WAX
	perunit = CC_PER_SHEET_WAX
	color = COLOR_BEESWAX
	var/image/glint

/obj/item/stack/sheet/wax/New(loc, amount, var/param_color = null)
	..()
	if (param_color)
		color = param_color
	if (isobj(loc))
		var/obj/O = loc
		if (O.reagents)//most likely a microwave
			var/datum/reagent/wax/W = O.reagents.get_reagent(WAX)
			if (W)
				amount = max(1,round(W.volume * WAX_SHEETS_PER_POWDER))
				color = W.data["color"]
	recipes = wax_recipes
	//adding a glint to both the object
	glint = image('icons/obj/stacks_sheets.dmi',src,"sheet-wax-glint")
	glint.blend_mode = BLEND_ADD
	overlays += glint
	//and the dynamic in-hand overlay
	var/image/glintleft = image(inhand_states["left_hand"], src, "sheet-wax-glint")
	var/image/glintright = image(inhand_states["right_hand"], src, "sheet-wax-glint")
	glintleft.blend_mode = BLEND_ADD
	glintright.blend_mode = BLEND_ADD
	dynamic_overlay["[HAND_LAYER]-[GRASP_LEFT_HAND]"] = glintleft
	dynamic_overlay["[HAND_LAYER]-[GRASP_RIGHT_HAND]"] = glintright

/obj/item/stack/sheet/wax/can_stack_with(obj/item/other_stack)
	if(ispath(other_stack) && (src.type == other_stack))
		return (uppertext(color) == COLOR_BEESWAX)

	if (src.type == other_stack.type)
		if (src.color == other_stack.color)
			return TRUE
		else
			to_chat(usr, "<span class='warning'>You cannot stack wax cakes of different colors.</span>")
	return FALSE

/obj/item/stack/sheet/wax/copy_evidences(var/obj/item/stack/from)
	..(from)
	color = from.color

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
	autoignition_temperature = AUTOIGNITION_PAPER

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
	autoignition_temperature = AUTOIGNITION_ORGANIC

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

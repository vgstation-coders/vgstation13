/* Diffrent misc types of sheets
 * Contains:
 *		Metal
 *		Plasteel
 *		Wood
 *		Cloth
 *		Cardboard
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

/obj/item/stack/sheet/metal/resetVariables()
	return ..("recipes", "pixel_x", "pixel_y")

/obj/item/stack/sheet/metal/ex_act(severity)
	switch(severity)
		if(1.0)
			returnToPool(src)
			return
		if(2.0)
			if (prob(50))
				returnToPool(src)
				return
		if(3.0)
			if (prob(5))
				returnToPool(src)
				return
		else
	return

/obj/item/stack/sheet/metal/blob_act()
	returnToPool(src)

/obj/item/stack/sheet/metal/singularity_act()
	returnToPool(src)
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
	starting_materials = list(MAT_IRON = CC_PER_SHEET_METAL, MAT_PLASMA = CC_PER_SHEET_MISC) // Was 7500, which doesn't make any fucking sense
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
	name = "wooden planks"
	desc = "One can only guess that this is a bunch of wood."
	singular_name = "wood plank"
	icon_state = "sheet-wood"
	origin_tech = Tc_MATERIALS + "=1;" + Tc_BIOTECH + "=1"
	autoignition_temperature=AUTOIGNITION_WOOD
	sheettype = "wood"
	w_type = RECYK_WOOD

/obj/item/stack/sheet/wood/afterattack(atom/Target, mob/user, adjacent, params)
	..()
	if(adjacent)
		if(isturf(Target) || istype(Target, /obj/structure/lattice))
			var/turf/T = get_turf(Target)
			if(T.canBuildLattice(src))
				if(src.use(1))
					to_chat(user, "<span class='notice'>Constructing some foundations ...</span>")
					playsound(get_turf(src), 'sound/weapons/Genhit.ogg', 50, 1)
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

/obj/item/stack/sheet/cloth/New()
	recipes = cloth_recipes
	return ..()

/obj/item/stack/sheet/cloth/attack(mob/living/carbon/human/M, mob/user)
	if(!istype(M))
		return ..()
	if(user.a_intent != I_HELP)
		return ..()

	var/datum/organ/external/affecting = M.get_organ(user.zone_sel.selecting)

	if(affecting.open == 0)
		var/success = FALSE
		for(var/datum/wound/W in affecting.wounds)
			if(W.internal)
				continue
			if(!W.bleeding())
				continue
			if(W.damage_type != CUT)
				continue

			success = TRUE

		if(!success)
			to_chat(user, "<span class='notice'>You don't see any bleeding on \the [M]'s [affecting.display_name].</span>")
			return

		user.visible_message("<span class='notice'>\The [user] starts wrapping up the bleeding wound on \the [M]'s [affecting.display_name].</span>",
		"<span class='info'>You start wrapping up \the [M]'s [affecting.display_name] to stop the bleeding. This will take about 6 seconds.</span>")
		if(do_after(user, M, 6 SECONDS) && use(1))
			success = FALSE
			for(var/datum/wound/W in affecting.wounds)
				if(W.internal)
					continue
				if(!W.bleeding())
					continue
				if(W.damage_type != CUT)
					continue
				success = TRUE

				W.bandaged = 1
				user.visible_message("<span class='notice'>[user] wraps up \the [W.desc] on [M]'s [affecting.display_name] with \the [src], stopping the bleeding.</span>", \
								"<span class='notice'>You wrap up \the [W.desc] on [M]'s [affecting.display_name] with \the [src], stopping the bleeding.</span>")

			if(!success)
				to_chat(user, "<span class='info'>It seems like the bleeding stopped by itself while you were applying \the [src] to the wound.</span>")
		else
			to_chat(user, "<span class='notice'>You were interrupted while wrapping \the [M]'s bleeding wound.</span>")
	else
		if(can_operate(M, user))        //Checks if mob is lying down on table for surgery
			do_surgery(M,user,src)


/*
 * Cardboard
 */
/obj/item/stack/sheet/cardboard	//BubbleWrap
	name = "cardboard"
	desc = "Large sheets of card, like boxes folded flat."
	singular_name = "cardboard sheet"
	icon_state = "sheet-card"
	flags = FPRINT
	origin_tech = Tc_MATERIALS + "=1"
	starting_materials = list(MAT_CARDBOARD = 3750)
	w_type=RECYK_MISC

/obj/item/stack/sheet/cardboard/New(var/loc, var/amount=null)
		recipes = cardboard_recipes
		return ..()

/obj/item/stack/sheet/cardboard/recycle(var/datum/materials/rec)
	rec.addAmount(MAT_CARDBOARD, amount)
	return 1

/*
 * /vg/ charcoal
 */
var/global/list/datum/stack_recipe/charcoal_recipes = list ()

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

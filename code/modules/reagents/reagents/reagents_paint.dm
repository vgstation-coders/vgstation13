
/*
	/datum/reagent/paint 			= Acrylic Paint
	/datum/reagent/paint/nanopaint	= Nano Paint
	/datum/reagent/paint/flaxoil	= Flax Oil
	/datum/reagent/acetone			= Acetone
*/

/datum/reagent/paint
	name = "Acrylic Paint"
	id = ACRYLIC
	description = "Grab your brushes and paint rollers, and get creative."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#FFFFFF"
	density = 1.808
	specheatcap = 0.85
	flags = CHEMFLAG_PIGMENT
	data = list(
		"color" = "#FFFFFF",
		)

//Mixing Acrylic paints together blends them together using the RYB color space
/datum/reagent/paint/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/added_color = base_color
	if (admin)
		added_color = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
	else if (added_data)
		added_color = added_data["color"]
	data["color"] = BlendRYB(added_color, base_color, added_volume / (added_volume+volume))
	color = data["color"]

/datum/reagent/paint/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
	else if (admin)
		data["color"] = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
		color = data["color"]

/datum/reagent/paint/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(0.3)//paint is toxic yo

/datum/reagent/paint/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(ishuman(M))
		var/blood_data = list(
			"viruses"		=null,
			"blood_DNA"		="wet paint",
			"blood_colour"	= data["color"],
			"blood_type"	="paint",
			"resistances"	=null,
			"trace_chem"	=null,
			"virus2" 		=list(),
			"immunity" 		=null,
			)
		var/mob/living/carbon/human/H = M
		H.bloody_body_from_data(copy_blood_data(blood_data),0,src)
		H.bloody_hands_from_data(copy_blood_data(blood_data),2,src)
		H.add_blood_to_feet(3, data["color"], list("wet paint" = "paint"), paint_light == PAINTLIGHT_FULL)
		for(var/i = 1 to H.held_items.len)
			var/obj/item/I = H.held_items[i]
			if(istype(I))
				I.add_blood_from_data(blood_data)

/datum/reagent/paint/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	var/paint_data = list(
		"viruses"		=null,
		"blood_DNA"		="wet paint",
		"blood_colour"	= data["color"],
		"blood_type"	="paint",
		"resistances"	=null,
		"trace_chem"	=null,
		"virus2" 		=list(),
		"immunity" 		=null,
		)

	O.add_blood_from_data(paint_data)

/datum/reagent/paint/reaction_turf(var/turf/T, var/volume, var/list/splashplosion=list())
	if(..())
		return TRUE

	var/turf/U = get_turf(holder.my_atom)
	if(isfloor(T))
		T.apply_paint_overlay(data["color"], 255, list(), id == NANOPAINT)
		if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && !(R in splashplosion) && T.Adjacent(R))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(data["color"], 255, get_dir_cardinal(R,T), "border_splatter", list(), id == NANOPAINT)
				else if (iswall(R) && !(R in splashplosion))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(data["color"], 255, get_dir_cardinal(R,T), "wall_splatter", list(), id == NANOPAINT)
	else if(iswall(T))
		if (T == U)
			T.apply_paint_overlay(data["color"], 255, list(), id == NANOPAINT)//if we're on top somehow, paint the whole tile
		else if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && (R in splashplosion))
					if (get_dir(T,U) & direction)
						T.apply_paint_stroke(data["color"], 255, get_dir_cardinal(T,R), "wall_splatter", list(), id == NANOPAINT)
		else
			T.apply_paint_stroke(data["color"], 255, get_dir_cardinal(T,U), "wall_splatter", list(), id == NANOPAINT)

//----------------------------------------------------------------------------------------------------

/datum/reagent/paint/nanopaint
	name = "Nano Paint"
	id = NANOPAINT
	description = "A paint with unaturally bright properties."
	paint_light = PAINTLIGHT_FULL

//Mixing Nano-paints together adds them together using the RGB color space
/datum/reagent/paint/nanopaint/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/added_color = base_color
	if (admin)
		added_color = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
	else if (added_data)
		added_color = added_data["color"]
	data["color"] = AddRGB(base_color, added_color, added_volume / volume)
	color = data["color"]

/datum/reagent/paint/nanopaint/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
	else if (admin)
		data["color"] = input(admin,"Paint Color","Choose a Paint Color","#FFFFFF") as color
		color = data["color"]

/datum/reagent/paint/nanopaint/special_behaviour()
	//turning acrylic into more nano-paint while also mixing their colours
	for (var/datum/reagent/R in holder.reagent_list)
		if ((R.id == ACRYLIC) || (R.id == FLAXOIL))
			var/added_volume = R.volume
			var/added_color = R.data["color"]
			data["color"] = AddRGB(added_color, data["color"], volume / added_volume)
			color = data["color"]
			holder.del_reagent(R.id)
			volume += added_volume

/datum/reagent/paint/nanopaint/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	M.adjustToxLoss(0.2)//nano paint is even more toxic yo

//----------------------------------------------------------------------------------------------------

/datum/reagent/flaxoil
	name = "Flax Oil"
	id = FLAXOIL
	description = "An oil used in painting. Copies the coloration and opacity of reagents it is mixed with."
	color = "#E6C530"
	alpha = 50
	reagent_state = REAGENT_STATE_LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	density = 1.808
	specheatcap = 0.85
	flags = CHEMFLAG_PIGMENT
	data = list(
		"color" = "#E6C530",
		"alpha" = 50,
		)

/datum/reagent/flaxoil/handle_data_mix(var/list/added_data=null, var/added_volume, var/mob/admin)
	var/base_color = data["color"]
	var/base_alpha = data["alpha"]
	var/added_color = base_color
	var/added_alpha = base_alpha
	if (added_data)
		added_color = added_data["color"]
		added_alpha = added_data["alpha"]
	data["color"] = BlendRYB(added_color, base_color, added_volume / (added_volume+volume))
	color = data["color"]
	data["alpha"] = ((base_alpha * volume) + (added_alpha * added_volume)) / (added_volume+volume)
	alpha = data["alpha"]

/datum/reagent/flaxoil/handle_data_copy(var/list/added_data=null, var/added_volume, var/mob/admin)
	if (added_data)
		data["color"] = added_data["color"]
		color = data["color"]
		data["alpha"] = added_data["alpha"]
		alpha = data["alpha"]

/datum/reagent/flaxoil/special_behaviour()
	var/list/other_reagents = holder.reagent_list - src
	for (var/datum/reagent/R in other_reagents)
		if (R.id == GLUE) //Adding glue lets us turn flax oil into acrylic which won't change color any longer, so we probably don't want to match the color of glue
			other_reagents -= R
	if (other_reagents.len <= 0)
		return
	var/target_color = mix_color_from_reagents(other_reagents)
	var/target_alpha = mix_alpha_from_reagents(other_reagents)
	data["color"] = BlendRYB(data["color"], target_color, 0.5)
	color = data["color"]
	data["alpha"] = (data["alpha"] + target_alpha) / 2
	alpha = data["alpha"]

/datum/reagent/flaxoil/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return 1

	if(ishuman(M))
		var/blood_data = list(
			"viruses"		=null,
			"blood_DNA"		="wet paint",
			"blood_colour"	= data["color"],
			"blood_type"	="paint",
			"resistances"	=null,
			"trace_chem"	=null,
			"virus2" 		=list(),
			"immunity" 		=null,
			)
		var/mob/living/carbon/human/H = M
		H.bloody_body_from_data(copy_blood_data(blood_data),0,src)
		H.bloody_hands_from_data(copy_blood_data(blood_data),2,src)
		H.add_blood_to_feet(3, data["color"], list("wet paint" = "paint"))
		for(var/i = 1 to H.held_items.len)
			var/obj/item/I = H.held_items[i]
			if(istype(I))
				I.add_blood_from_data(blood_data)

/datum/reagent/flaxoil/reaction_obj(var/obj/O, var/volume)
	if(..())
		return 1

	var/paint_data = list(
		"viruses"		=null,
		"blood_DNA"		="wet paint",
		"blood_colour"	= data["color"],
		"blood_type"	="paint",
		"resistances"	=null,
		"trace_chem"	=null,
		"virus2" 		=list(),
		"immunity" 		=null,
		)

	O.add_blood_from_data(paint_data)

/datum/reagent/flaxoil/reaction_turf(var/turf/T, var/volume, var/list/splashplosion=list())
	if(..())
		return TRUE

	var/turf/U = get_turf(holder.my_atom)
	if(isfloor(T))
		T.apply_paint_overlay(data["color"], data["alpha"], list(), FALSE)
		if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && !(R in splashplosion) && T.Adjacent(R))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(data["color"], data["alpha"], get_dir_cardinal(R,T), "border_splatter", list(), FALSE)
				else if (iswall(R) && !(R in splashplosion))
					if (get_dir(R,U) & get_dir(R,T))
						R.apply_paint_stroke(data["color"], data["alpha"], get_dir_cardinal(R,T), "wall_splatter", list(), FALSE)
	else if(iswall(T))
		if (T == U)
			T.apply_paint_overlay(data["color"], data["alpha"], list(), FALSE)//if we're on top somehow, paint the whole tile
		else if (splashplosion.len > 0)
			for (var/direction in cardinal)
				var/turf/R = get_step(T,direction)
				if (isfloor(R) && (R in splashplosion))
					if (get_dir(T,U) & direction)
						T.apply_paint_stroke(data["color"], data["alpha"], get_dir_cardinal(T,R), "wall_splatter", list(), FALSE)
		else
			T.apply_paint_stroke(data["color"], data["alpha"], get_dir_cardinal(T,U), "wall_splatter", list(), FALSE)

//----------------------------------------------------------------------------------------------------

/datum/reagent/acetone
	name = "Acetone"
	id = ACETONE
	description = "Removes paint off floors, and everywhere else."
	reagent_state = REAGENT_STATE_LIQUID
	color = "#303030"
	alpha = 100

/datum/reagent/acetone/reaction_turf(var/turf/T, var/volume)
	if(..())
		return TRUE

	for (var/obj/effect/decal/cleanable/C in T)
		if ("wet paint" in C.blood_DNA)
			qdel(C)

	T.remove_paint_overlay(TRUE)

/datum/reagent/acetone/reaction_obj(var/obj/O, var/volume)
	if(..())
		return TRUE

	if ("wet paint" in O.blood_DNA)
		O.clean_blood()
	O.color = ""

/datum/reagent/acetone/reaction_mob(var/mob/living/M, var/method = TOUCH, var/volume, var/list/zone_sels = ALL_LIMBS)
	if(..())
		return TRUE

	if(iscarbon(M))
		var/mob/living/carbon/H = M
		for(var/obj/item/I in H.held_items)
			if ("wet paint" in I.blood_DNA)
				I.clean_blood()

		for(var/obj/item/clothing/C in M.get_equipped_items())
			if ("wet paint" in C.blood_DNA)
				if (C.clean_blood())
					H.update_inv_by_slot(C.slot_flags)
	M.color = ""

/datum/reagent/acetone/on_mob_life(var/mob/living/M)
	if(..())
		return 1
	for (var/datum/reagent/R in M.reagents.reagent_list)
		if (R.flags & CHEMFLAG_PIGMENT)
			M.reagents.remove_reagent(R.id, 2)

	if (tick < 50)
		if(prob(5))
			M.emote(pick("stare", "giggle"), null, null, TRUE)
	else
		if(prob(5))
			M.emote(pick("twitch","drool","moan"), null, null, TRUE)
		M.adjustBrainLoss(1)

//----------------------------------------------------------------------------------------------------

#define PAINT_CLEANER_AGENT_MULTIPLIER 2 // How effective cleaning products are, compared to water (aka they count as if there was n times water instead)

/proc/get_reagent_paint_cleaning_percent(obj/container)
	if(container.reagents)
		var/cleaner_volume = container.reagents.get_reagent_amount(WATER)
		cleaner_volume += container.reagents.get_reagent_amount(CLEANER)
		cleaner_volume += container.reagents.get_reagent_amount(BLEACH) * PAINT_CLEANER_AGENT_MULTIPLIER
		cleaner_volume += container.reagents.get_reagent_amount(ACETONE) * PAINT_CLEANER_AGENT_MULTIPLIER
		return (cleaner_volume > 0 ? cleaner_volume / container.reagents.total_volume : 0)
	else
		return 0

#undef PAINT_CLEANER_AGENT_MULTIPLIER

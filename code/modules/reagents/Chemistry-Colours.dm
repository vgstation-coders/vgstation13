/*
 * Returns:
 * 	#RRGGBB(AA) on success, null on failure
 */
/proc/mix_color_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/color
	var/reagent_color
	var/vol_counter = 0
	var/vol_temp
	// see libs/IconProcs/IconProcs.dm
	for(var/datum/reagent/reagent in reagent_list)
		if(reagent.id == BLOOD && reagent.data["blood_colour"])
			reagent_color = reagent.data["blood_colour"]
		else
			reagent_color = reagent.color

		vol_temp = reagent.volume
		vol_counter += vol_temp

		if(isnull(color))
			color = reagent.color
		else if(length(color) >= length(reagent_color))
			color = BlendRGB(color, reagent_color, vol_temp/vol_counter)
		else
			color = BlendRGB(reagent_color, color, vol_temp/vol_counter)

	return color

/proc/mix_alpha_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/alpha
	var/total_alpha

	for(var/datum/reagent/reagent in reagent_list)
		total_alpha += reagent.alpha

	alpha = total_alpha / reagent_list.len

	return alpha

/proc/get_reagent_name(var/obj/item/weapon/reagent_containers/food/drinks/drinkingglass/DG, var/mug = FALSE)
	if(!DG)
		return
	var/glassormug = "glass"
	if(mug)
		glassormug = "mug"
	var/list/reagent_list = DG.reagents.reagent_list
	if(!reagent_list.len)
		DG.name = "[glassormug] of...nothing?"
		DG.desc = "You can't see anything inside that [glassormug], odd"//this shouldn't ever happen
	else if(reagent_list.len > 4)
		DG.name = "mixture of chemicals"
		DG.desc = "There's too many different chemicals in the [glassormug], you cannot tell them apart."
		DG.viewcontents = 0
	else
		var/highest_quantity = 0
		for(var/datum/reagent/reagent in reagent_list)
			var/new_reag = DG.reagents.get_reagent_amount(reagent.id)
			if(new_reag > highest_quantity)
				highest_quantity = new_reag
				DG.name = "[glassormug] of [reagent.name]"
				DG.desc = reagent.description

/proc/get_weighted_reagent_color(var/datum/reagents/V)
	var/list/colors = list(0,0,0)
	var/totalvolume = V.total_volume
	for(var/datum/reagent/R in V.reagent_list)
		colors[1] += (GetRedPart(R.color) * (R.volume / totalvolume))
		colors[2] += (GetGreenPart(R.color) * (R.volume / totalvolume))
		colors[3] += (GetBluePart(R.color) * (R.volume / totalvolume))
	return rgb(colors[1], colors[2], colors[3])

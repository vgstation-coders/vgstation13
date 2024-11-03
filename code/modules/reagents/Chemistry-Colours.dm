/*
 * Returns:
 * 	#RRGGBB(AA) on success, null on failure
 */
/proc/mix_color_from_reagents(const/list/reagent_list, var/pigments_only = FALSE)
	if(!istype(reagent_list))
		return

	var/color
	var/reagent_color
	var/vol_counter = 0
	var/vol_temp
	// see libs/IconProcs/IconProcs.dm
	for(var/datum/reagent/reagent in reagent_list)
		if (reagent.id == BLACKCOLOR)
			return "#000000"
		if (pigments_only && !(reagent.flags & CHEMFLAG_PIGMENT))
			continue
		if(reagent.id == BLOOD && reagent.data["blood_colour"])
			reagent_color = reagent.data["blood_colour"]
		else
			reagent_color = reagent.color

		vol_temp = reagent.volume
		vol_counter += vol_temp

		if(isnull(color))
			color = reagent.color
		else if(length(color) >= length(reagent_color))
			color = BlendRYB(reagent_color, color, vol_temp/vol_counter)
		else
			color = BlendRYB(color, reagent_color, vol_temp/vol_counter)

	return color

/proc/mix_alpha_from_reagents(const/list/reagent_list)
	if(!istype(reagent_list))
		return

	var/alpha
	var/total_alpha
	var/total_volume

	for(var/datum/reagent/reagent in reagent_list)
		if (reagent.id == BLACKCOLOR)
			return 255
		total_alpha += (reagent.alpha * reagent.volume)
		total_volume += reagent.volume

	alpha = total_alpha / total_volume

	return alpha

/proc/get_weighted_reagent_color(var/datum/reagents/V)
	var/list/colors = list(0,0,0)
	var/totalvolume = V.total_volume
	for(var/datum/reagent/R in V.reagent_list)
		colors[1] += (GetRedPart(R.color) * (R.volume / totalvolume))
		colors[2] += (GetGreenPart(R.color) * (R.volume / totalvolume))
		colors[3] += (GetBluePart(R.color) * (R.volume / totalvolume))
	return rgb(colors[1], colors[2], colors[3])

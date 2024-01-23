/proc/getIconMask(atom/A)//By yours truly. Creates a dynamic mask for a mob/whatever. /N
	var/icon/alpha_mask = new(A.icon,A.icon_state)//So we want the default icon and icon state of A.
	for(var/I in A.overlays)//For every image in overlays. var/image/I will not work, don't try it.
		if(I:layer>A.layer)
			continue//If layer is greater than what we need, skip it.
		var/icon/image_overlay = new(I:icon,I:icon_state)//Blend only works with icon objects.
		//Also, icons cannot directly set icon_state. Slower than changing variables but whatever.
		alpha_mask.Blend(image_overlay,ICON_OR)//OR so they are lumped together in a nice overlay.
	return alpha_mask//And now return the mask.

/mob/proc/AddCamoOverlay(atom/A)//A is the atom which we are using as the overlay.
	var/icon/opacity_icon = new(A.icon, A.icon_state)//Don't really care for overlays/underlays.
	//Now we need to culculate overlays+underlays and add them together to form an image for a mask.
	//var/icon/alpha_mask = getFlatIcon(src)//Accurate but SLOW. Not designed for running each tick. Could have other uses I guess.
	var/icon/alpha_mask = getIconMask(src)//Which is why I created that proc. Also a little slow since it's blending a bunch of icons together but good enough.
	opacity_icon.AddAlphaMask(alpha_mask)//Likely the main source of lag for this proc. Probably not designed to run each tick.
	opacity_icon.ChangeOpacity(0.4)//Front end for MapColors so it's fast. 0.5 means half opacity and looks the best in my opinion.
	for(var/i=0,i<5,i++)//And now we add it as overlays. It's faster than creating an icon and then merging it.
		var/image/I = image("icon" = opacity_icon, "icon_state" = A.icon_state, "layer" = layer+0.8)//So it's above other stuff but below weapons and the like.
		switch(i)//Now to determine offset so the result is somewhat blurred.
			if(1)
				I.pixel_x--
			if(2)
				I.pixel_x++
			if(3)
				I.pixel_y--
			if(4)
				I.pixel_y++
		overlays += I//And finally add the overlay.

/proc/getHologramIcon(icon/A, safety=1)//If safety is on, a new icon is not created.
	var/icon/flat_icon = safety ? A : new(A)//Has to be a new icon to not constantly change the same icon.
	flat_icon.ColorTone(rgb(125,180,225))//Let's make it bluish.
	flat_icon.ChangeOpacity(0.5)//Make it half transparent.
	var/icon/alpha_mask = new('icons/effects/effects.dmi', "scanline")//Scanline effect.
	flat_icon.AddAlphaMask(alpha_mask)//Finally, let's mix in a distortion effect.
	return flat_icon

/proc/getStaticIcon(icon/A, safety=1)
	var/icon/flat_icon = safety ? A : new(A)
	flat_icon.Blend(rgb(255, 255, 255))
	flat_icon.BecomeAlphaMask()
	var/icon/static_icon = new/icon('icons/effects/effects.dmi', "static_base")
	static_icon.AddAlphaMask(flat_icon)
	return static_icon

/proc/getBlankIcon(icon/A, safety=1)
	var/icon/flat_icon = safety ? A : new(A)
	flat_icon.Blend(rgb(255, 255, 255))
	flat_icon.BecomeAlphaMask()
	var/icon/blank_icon = new/icon('icons/effects/effects.dmi', "blank_base")
	blank_icon.AddAlphaMask(flat_icon)
	return blank_icon

/proc/getLetterImage(atom/A, letter = "", uppercase = 0)
	if(!A)
		return

	var/icon/atom_icon = new(A.icon, A.icon_state)

	if(!letter)
		letter = copytext(A.name, 1, 2)
		if(uppercase == 1)
			letter = uppertext(letter)
		else if(uppercase == -1)
			letter = lowertext(letter)

	var/image/text_image = new(loc = A)
	text_image.maptext = "<font size = 8><b>[letter]</b></font>"
	text_image.color = AverageColor(atom_icon)
	text_image.pixel_x = 6*PIXEL_MULTIPLIER
	text_image.pixel_y = 5*PIXEL_MULTIPLIER
	del(atom_icon)
	return text_image

//For photo camera.
/proc/build_composite_icon(atom/A)
	var/icon/composite = icon(A.icon, A.icon_state, A.dir, 1)
	for(var/O in A.overlays)
		var/image/I = O
		var/icon/C = icon(I.icon, I.icon_state, I.dir, 1)
		C.Blend(I.color, ICON_MULTIPLY)
		composite.Blend(C, ICON_OVERLAY)
	return composite

/proc/adjust_brightness(var/color, var/value)
	if (!color)
		return "#FFFFFF"
	if (!value)
		return color

	var/list/RGB = ReadRGB(color)
	RGB[1] = clamp(RGB[1]+value,0,255)
	RGB[2] = clamp(RGB[2]+value,0,255)
	RGB[3] = clamp(RGB[3]+value,0,255)
	return rgb(RGB[1],RGB[2],RGB[3])

/proc/adjust_RGB(var/color, var/red, var/green, var/blue)
	if (!color)
		return "#FFFFFF"
	if (!red && !green && !blue)
		return color

	var/list/RGB = ReadRGB(color)
	RGB[1] = clamp(RGB[1]+red,0,255)
	RGB[2] = clamp(RGB[2]+green,0,255)
	RGB[3] = clamp(RGB[3]+blue,0,255)
	return rgb(RGB[1],RGB[2],RGB[3])

/proc/ListColors(var/icon/I, var/ignoreGreyscale = 0)
	var/list/colors = list()
	for(var/x_pixel = 1 to I.Width())
		for(var/y_pixel = 1 to I.Height())
			var/this_color = I.GetPixel(x_pixel, y_pixel)
			if(this_color)
				if (ignoreGreyscale && ReadHSV(RGBtoHSV(this_color))[2] == 0) //If saturation is 0, must be greyscale
					continue
				colors.Add(this_color)
	return colors

/proc/AverageColor(var/icon/I, var/accurate = 0, var/ignoreGreyscale = 0)
//Accurate: Use more accurate color averaging, usually has better results and prevents muddied or overly dark colors. Mad thanks to wwjnc.
//ignoreGreyscale: Excempts greyscale colors from the color list, useful for filtering outlines or plate overlays.
	var/list/colors = ListColors(I, ignoreGreyscale)
	if(!colors.len)
		return null

	var/list/colorsum = list(0, 0, 0) //Holds the sum of the RGB values to calculate the average
	var/list/RGB = list(0, 0, 0) //Temp list for each color
	var/total = colors.len

	var/final_average
	if (accurate) //keeping it legible
		for(var/i = 1 to total)
			RGB = ReadRGB(colors[i])
			colorsum[1] += RGB[1]*RGB[1]
			colorsum[2] += RGB[2]*RGB[2]
			colorsum[3] += RGB[3]*RGB[3]
		final_average = rgb(sqrt(colorsum[1]/total), sqrt(colorsum[2]/total), sqrt(colorsum[3]/total))
	else
		for(var/i = 1 to total)
			RGB = ReadRGB(colors[i])
			colorsum[1] += RGB[1]
			colorsum[2] += RGB[2]
			colorsum[3] += RGB[3]
		final_average = rgb(colorsum[1]/total, colorsum[2]/total, colorsum[3]/total)
	return final_average

/proc/empty_Y_space(var/icon/I) //Returns the amount of lines containing only transparent pixels in an icon, starting from the bottom
	for(var/y_pixel = 1 to I.Height())
		for(var/x_pixel = 1 to I.Width())
			if (I.GetPixel(x_pixel, y_pixel))
				return y_pixel - 1
	return null

/proc/has_icon(var/icon/I, var/wanted_state = null)
	if(!I)
		return FALSE

	var/found = FALSE

	for(var/found_state in icon_states(I,1))
		if(found_state == wanted_state)
			found = TRUE
			break

	if(found)
		return TRUE
	else
		return FALSE

//returns the number of direction a given icon_state has, or 0 if it's not 1, 4 or 8 (such as in the case of an animated state)
//should be accurate most of the time, but no guarrantees
/proc/get_icon_dir_count(icon, icon_state)
	var/iconKey = "misc"
	iconCache[iconKey] << icon(icon,icon_state)
	var/haystack = "[iconCache.ExportText(iconKey)]"
	if (findtextEx(haystack, "iVBORw0KGgoAAAANSUhEUgAAACAAAAAg"))//yeah I found those patterns by reading strings of icons converted to base64
		return 1
	if (findtextEx(haystack, "iVBORw0KGgoAAAANSUhEUgAAACAAAABA"))
		return 4
	if (findtextEx(haystack, "iVBORw0KGgoAAAANSUhEUgAAACAAAABg"))
		return 8
	return 0 //unknown pattern, most likely something animated, oh well. be sure to account for that in your proc call.

//clamps the HSV brightness of an RGB color to [lower, upper]
/proc/ColorVClamp(var/rgb, var/lower = 0, var/upper = 255)
	var/list/hsv_list = ReadHSV(RGBtoHSV(rgb))
	hsv_list[3] = clamp(hsv_list[3], lower, upper)
	if (hsv_list.len == 4)
		return HSVtoRGB(hsv(hsv_list[1], hsv_list[2], hsv_list[3], hsv_list[4]))
	return HSVtoRGB(hsv(hsv_list[1], hsv_list[2], hsv_list[3]))


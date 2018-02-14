
/obj/effect/rune/proc/get_uristrune_cult(word1, word2, word3,var/mob/living/M = null)
	var/animated

	if(get_uristrune_name(word1, word2, word3))
		animated = 1
	else
		animated = 0

	var/bits = word_to_uristrune_bit(word1) \
			 | word_to_uristrune_bit(word2) \
			 | word_to_uristrune_bit(word3)

	if(M && istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		return get_uristrune(bits, animated, H.species.blood_color)
	else
		return get_uristrune(bits, animated)



var/list/uristrune_cache = list()

/obj/effect/rune/proc/get_uristrune(symbol_bits, animated = 0, bloodcolor = DEFAULT_BLOOD)
	var/lookup = "[symbol_bits]-[animated]-[bloodcolor]"

	if(lookup in uristrune_cache)
		return uristrune_cache[lookup]

	var/icon/I = icon('icons/effects/uristrunes.dmi', "blank")

	for(var/i = 0, i < 10, i++)
		if(symbol_bits & (1 << i))
			I.Blend(icon('icons/effects/uristrunes.dmi', "rune-[1 << i]"), ICON_OVERLAY)

	var/finalblood = bloodcolor
	var/list/blood_hsl = rgb2hsl(GetRedPart(bloodcolor),GetGreenPart(bloodcolor),GetBluePart(bloodcolor))
	if(blood_hsl.len)
		var/list/blood_rgb = hsl2rgb(blood_hsl[1],blood_hsl[2],50)//producing a color that is neither too bright nor too dark
		if(blood_rgb.len)
			finalblood = rgb(blood_rgb[1],blood_rgb[2],blood_rgb[3])

	var/bc1 = finalblood
	var/bc2 = finalblood
	bc1 += "C8"
	bc2 += "64"

	I.SwapColor(rgb(0, 0, 0, 100), bc1)
	I.SwapColor(rgb(0, 0, 0, 50), bc1)

	for(var/x = 1, x <= WORLD_ICON_SIZE, x++)
		for(var/y = 1, y <= WORLD_ICON_SIZE, y++)
			var/p = I.GetPixel(x, y)

			if(p == null)
				var/n = I.GetPixel(x, y + 1)
				var/s = I.GetPixel(x, y - 1)
				var/e = I.GetPixel(x + 1, y)
				var/w = I.GetPixel(x - 1, y)

				if(n == "#000000" || s == "#000000" || e == "#000000" || w == "#000000")
					I.DrawBox(bc1, x, y)

				else
					var/ne = I.GetPixel(x + 1, y + 1)
					var/se = I.GetPixel(x + 1, y - 1)
					var/nw = I.GetPixel(x - 1, y + 1)
					var/sw = I.GetPixel(x - 1, y - 1)

					if(ne == "#000000" || se == "#000000" || nw == "#000000" || sw == "#000000")
						I.DrawBox(bc2, x, y)

	I.MapColors(0.5,0,0,0,0.5,0,0,0,0.5)//we'll darken that color a bit

	icon = I

	if(animated)//This masterpiece of a color matrix stack produces a nice animation no matter which color was the blood used for the rune.
		animate(src, color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 10, loop = -1)//1
		animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 2)//2
		animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 2)//3
		animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1.5)//4
		animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1.5)//5
		animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
		animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
		animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
		animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 5)//9
		animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)//8
		animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)//7
		animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)//6
		animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 1)//5
		animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 1)//4
		animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 1)//3
		animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 1)//2


var/list/word_to_uristrune_table = null

/proc/word_to_uristrune_bit(word)
	if(word_to_uristrune_table == null)
		word_to_uristrune_table = list()

		var/bit = 1
		var/list/words = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "mgar", "balaq", "karazet", "geeri")

		while(length(words))
			var/w = pick(words)

			word_to_uristrune_table[w] = bit

			words -= w
			bit <<= 1

	return word_to_uristrune_table[word]



/proc/get_uristrune_cult(word1, word2, word3,var/mob/living/M = null)
	var/animated

	if((word1 == cultwords["travel"] && word2 == cultwords["self"])						\
	|| (word1 == cultwords["join"] && word2 == cultwords["blood"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["join"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["see"] && word2 == cultwords["blood"] && word3 == cultwords["hell"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["destroy"] && word3 == cultwords["other"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["technology"])	\
	|| (word1 == cultwords["travel"] && word2 == cultwords["blood"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["see"] && word2 == cultwords["hell"] && word3 == cultwords["join"])		\
	|| (word1 == cultwords["blood"] && word2 == cultwords["join"] && word3 == cultwords["hell"])	\
	|| (word1 == cultwords["hide"] && word2 == cultwords["see"] && word3 == cultwords["blood"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["travel"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["travel"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["technology"] && word3 == cultwords["join"])	\
	|| (word1 == cultwords["hell"] && word2 == cultwords["blood"] && word3 == cultwords["join"])	\
	|| (word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["hide"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["travel"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["travel"] && word2 == cultwords["technology"] && word3 == cultwords["other"])	\
	|| (word1 == cultwords["join"] && word2 == cultwords["other"] && word3 == cultwords["self"])	\
	|| (word1 == cultwords["hide"] && word2 == cultwords["other"] && word3 == cultwords["see"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["other"])	\
	|| (word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["blood"])	\
	|| (word1 == cultwords["self"] && word2 == cultwords["other"] && word3 == cultwords["technology"])	\
	|| (word1 == cultwords["travel"] && word2 == cultwords["other"])						\
	|| (word1 == cultwords["join"] && word2 == cultwords["hide"] && word3 == cultwords["technology"])	)
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

/proc/get_uristrune_name(word1, word2, word3)
	if((word1 == cultwords["travel"] && word2 == cultwords["self"]))
		return "Travel Self"
	else if((word1 == cultwords["join"] && word2 == cultwords["blood"] && word3 == cultwords["self"]))
		return "Convert"
	else if((word1 == cultwords["hell"] && word2 == cultwords["join"] && word3 == cultwords["self"]))
		return "Tear Reality"
	else if((word1 == cultwords["see"] && word2 == cultwords["blood"] && word3 == cultwords["hell"]))
		return "Summon Tome"
	else if((word1 == cultwords["hell"] && word2 == cultwords["destroy"] && word3 == cultwords["other"]))
		return "Armor"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["technology"]))
		return "EMP"
	else if((word1 == cultwords["travel"] && word2 == cultwords["blood"] && word3 == cultwords["self"]))
		return "Drain"
	else if((word1 == cultwords["see"] && word2 == cultwords["hell"] && word3 == cultwords["join"]))
		return "See Invisible"
	else if((word1 == cultwords["blood"] && word2 == cultwords["join"] && word3 == cultwords["hell"]))
		return "Raise Dead"
	else if((word1 == cultwords["hide"] && word2 == cultwords["see"] && word3 == cultwords["blood"]))
		return "Hide Runes"
	else if((word1 == cultwords["hell"] && word2 == cultwords["travel"] && word3 == cultwords["self"]))
		return "Astral Journey"
	else if((word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["travel"]))
		return "Manifest Ghost"
	else if((word1 == cultwords["hell"] && word2 == cultwords["technology"] && word3 == cultwords["join"]))
		return "Imbue Talisman"
	else if((word1 == cultwords["hell"] && word2 == cultwords["blood"] && word3 == cultwords["join"]))
		return "Sacrifice"
	else if((word1 == cultwords["blood"] && word2 == cultwords["see"] && word3 == cultwords["hide"]))
		return "Reveal Runes"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["travel"] && word3 == cultwords["self"]))
		return "Wall"
	else if((word1 == cultwords["travel"] && word2 == cultwords["technology"] && word3 == cultwords["other"]))
		return "Free Cultist"
	else if((word1 == cultwords["join"] && word2 == cultwords["other"] && word3 == cultwords["self"]))
		return "Summon Cultist"
	else if((word1 == cultwords["hide"] && word2 == cultwords["other"] && word3 == cultwords["see"]))
		return "Deafen"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["other"]))
		return "Blind"
	else if((word1 == cultwords["destroy"] && word2 == cultwords["see"] && word3 == cultwords["blood"]))
		return "Blood Boil"
	else if((word1 == cultwords["self"] && word2 == cultwords["other"] && word3 == cultwords["technology"]))
		return "Communicate"
	else if((word1 == cultwords["travel"] && word2 == cultwords["other"]))
		return "Travel Other"
	else if((word1 == cultwords["join"] && word2 == cultwords["hide"] && word3 == cultwords["technology"]))
		return "Stun"
	else
		return null

var/list/uristrune_cache = list()

/proc/get_uristrune(symbol_bits, animated = 0, bloodcolor = "#A10808")
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
		var/list/blood_rbg = hsl2rgb(blood_hsl[1],blood_hsl[2],128)//producing a color that is neither too bright nor too dark
		if(blood_hsl.len)
			finalblood = rgb(blood_rbg[1],blood_rbg[2],blood_rbg[3])

	var/bc1 = finalblood
	var/bc2 = finalblood
	bc1 += "C8"
	bc2 += "64"
	I.SwapColor(rgb(0, 0, 0, 100), bc1)
	I.SwapColor(rgb(0, 0, 0, 50), bc1)

	for(var/x = 1, x <= 32, x++)
		for(var/y = 1, y <= 32, y++)
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

	var/icon/result = icon(I, "")

	I.MapColors(0.5,0,0,0,0.5,0,0,0,0.5)//we'll darken that color a bit

	var/icon/I1 = icon(I, "")
	I1.MapColors(1,0.05,0,0,1,0.05,0.05,0,1)
	result.Insert(I1,  "", frame = 1, delay = 10)

/*
	I.MapColors(rgb(0x80,0,0,0), rgb(0,0x80,0,0), rgb(0,0,0x80,0), rgb(0,0,0,0xff))//we'll darken that color a bit

	var/icon/I1 = icon(I, "")
	I1.MapColors(rgb(0xff,0x08,0,0), rgb(0,0xff,0x08,0), rgb(0x08,0,0xff,0), rgb(0,0,0,0xff))
	result.Insert(I1,  "", frame = 1, delay = 10)
*/

	if(animated == 1)
		var/icon/I2 = icon(I, "")
		I2.MapColors(1.125,0.06,0,0,1.125,0.06,0.06,0,1.125)

		var/icon/I3 = icon(I, "")
		I3.MapColors(1.25,0.12,0,0,1.25,0.12,0.12,0,1.25)

		var/icon/I4 = icon(I, "")
		I4.MapColors(1.375,0.19,0,0,1.375,0.19,0.19,0,1.375)

		var/icon/I5 = icon(I, "")
		I5.MapColors(1.5,0.27,0,0,1.5,0.27,0.27,0,1.5)

		var/icon/I6 = icon(I, "")
		I6.MapColors(1.625,0.35,0.06,0.06,1.625,0.35,0.35,0.06,1.625)

		var/icon/I7 = icon(I, "")
		I7.MapColors(1.75,0.45,0.12,0.12,1.75,0.45,0.45,0.12,1.75)

		var/icon/I8 = icon(I, "")
		I8.MapColors(1.875,0.56,0.19,0.19,1.875,0.56,0.56,0.19,1.875)

		var/icon/I9 = icon(I, "")
		I9.MapColors(2,0.67,0.27,0.27,2,0.67,0.67,0.27,2)

/*
	I.MapColors(rgb(0x80,0,0,0), rgb(0,0x80,0,0), rgb(0,0,0x80,0), rgb(0,0,0,0xff))//we'll darken that color a bit

	var/icon/I1 = icon(I, "")
	I1.MapColors(rgb(0xff,0x08,0,0), rgb(0,0xff,0x08,0), rgb(0x08,0,0xff,0), rgb(0,0,0,0xff))
	result.Insert(I1,  "", frame = 1, delay = 10)

	if(animated == 1)
		var/icon/I2 = icon(I, "")
		I2.MapColors(rgb(0xff,0x0c,0,0), rgb(0,0xff,0x0c,0), rgb(0x0c,0,0xff,0), rgb(0,0,0,0xff))
		I2.SetIntensity(1.125)

		var/icon/I3 = icon(I, "")
		I3.MapColors(rgb(0xff,0x18,0,0), rgb(0,0xff,0x18,0), rgb(0x18,0,0xff,0), rgb(0,0,0,0xff))
		I3.SetIntensity(1.25)

		var/icon/I4 = icon(I, "")
		I4.MapColors(rgb(0xff,0x24,0,0), rgb(0,0xff,0x24,0), rgb(0x24,0,0xff,0), rgb(0,0,0,0xff))
		I4.SetIntensity(1.375)

		var/icon/I5 = icon(I, "")
		I5.MapColors(rgb(0xff,0x30,0,0), rgb(0,0xff,0x30,0), rgb(0x30,0,0xff,0), rgb(0,0,0,0xff))
		I5.SetIntensity(1.5)

		var/icon/I6 = icon(I, "")
		I6.MapColors(rgb(0xff,0x36,0x0c,0), rgb(0x0c,0xff,0x36,0), rgb(0x36,0x0c,0xff,0), rgb(0,0,0,0xff))
		I6.SetIntensity(1.625)

		var/icon/I7 = icon(I, "")
		I7.MapColors(rgb(0xff,0x42,0x18,0), rgb(0x18,0xff,0x42,0), rgb(0x42,0x18,0xff,0), rgb(0,0,0,0xff))
		I7.SetIntensity(1.75)

		var/icon/I8 = icon(I, "")
		I8.MapColors(rgb(0xff,0x48,0x24,0), rgb(0x24,0xff,0x48,0), rgb(0x48,0x24,0xff,0), rgb(0,0,0,0xff))
		I8.SetIntensity(1.875)

		var/icon/I9 = icon(I, "")
		I9.MapColors(rgb(0xff,0x54,0x30,0), rgb(0x30,0xff,0x54,0), rgb(0x54,0x30,0xff,0), rgb(0,0,0,0xff))
		I9.SetIntensity(2)
*/
		result.Insert(I2, "", frame = 2, delay = 2)
		result.Insert(I3, "", frame = 3, delay = 2)
		result.Insert(I4, "", frame = 4, delay = 1.5)
		result.Insert(I5, "", frame = 5, delay = 1.5)
		result.Insert(I6, "", frame = 6, delay = 1)
		result.Insert(I7, "", frame = 7, delay = 1)
		result.Insert(I8, "", frame = 8, delay = 1)
		result.Insert(I9, "", frame = 9, delay = 5)
		result.Insert(I8, "", frame = 10, delay = 1)
		result.Insert(I7, "", frame = 11, delay = 1)
		result.Insert(I6, "", frame = 12, delay = 1)
		result.Insert(I5, "", frame = 13, delay = 1)
		result.Insert(I4, "", frame = 14, delay = 1)
		result.Insert(I3, "", frame = 15, delay = 1)
		result.Insert(I2, "", frame = 16, delay = 1)

	uristrune_cache[lookup] = result

	return result

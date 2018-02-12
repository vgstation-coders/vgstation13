//RUNE OBJECT




//RUNE ACTIVATION TYPES




//NULLROD CHECK


var/list/rune_list = list()//all runes currently in the world
var/list/uristrune_cache = list()//icon cache, so the whole blending process is only done once per rune.


/obj/effect/rune
	desc = "A strange collection of symbols drawn in blood."
	anchored = 1
	icon = 'icons/effects/uristrunes.dmi'
	icon_state = ""
	layer = RUNE_LAYER
	plane = ABOVE_TURF_PLANE

	//A rune is made of up to 3 words
	var/datum/cultword/word1
	var/datum/cultword/word2
	var/datum/cultword/word3

	//An image we'll show to the AI instead of the rune
	var/image/blood_image

	//When a rune is created, we see if there's any data to copy from the blood used (colour, DNA, viruses) for all 3 words
	var/datum/reagent/blood/blood1
	var/datum/reagent/blood/blood2
	var/datum/reagent/blood/blood3

	//Used when a nullrod is preventing a rune's activation
	var/nullblock = 0


	var/datum/rune_spell/active_spell = null

/obj/effect/rune/New()
	..()
	blood_image = image(src)

	//AI cannot see runes, instead they see blood splatters.
	for(var/mob/living/silicon/ai/AI in player_list)
		if(AI.client)
			AI.client.images += blood_image

	rune_list.Add(src)

/obj/effect/rune/Destroy()

	for(var/mob/living/silicon/ai/AI in player_list)
		if (AI.client)
			AI.client.images -= blood_image
	qdel(blood_image)
	blood_image = null

	rune_list.Remove(src)
	..()

/obj/effect/rune/examine(var/mob/user)
	..()
	var/rune_name = get_rune_spell(null, null, "examine", word1,word2,word3)

	//cultists can read the words, and be informed if it calls a spell
	if (iscultist(user))
		to_chat(user, "<span class='info'>It reads: <i>[word1.rune] [word2.rune] [word3.rune]</i>.[rune_name ? " That's \a <b>[rune_name.name]</b> rune." : "It doesn't match any rune spells."]</span>")
	if (rune_name)
		if (rune_name.Act_restriction <= TODO INSERT CULT CHECK HERE)
			to_chat(user, "<span class='info'>[rune_name.desc]</span>")
		else
			to_chat(user, "<span class='warning'>The veil is still too thick for you to draw power from this rune.</span>")

	//so do observers
	else if (isobserver(user))
		to_chat(user, "<span class='info'>[rune_name ? "That's \a <b>[rune_name.name]</b> rune." : "It doesn't match any rune spell."]</span>")

	//cultists can read the words, but not the meaning (though they can always check it up). Also has a chance to trigger a taunt from Nar-Sie.
	else if(istype(user, /mob/living/carbon/human) && (user.mind.assigned_role == "Chaplain"))
		var/list/cult_blood_chaplain = list("cult", "narsie", "nar'sie", "narnar", "nar-sie")
		var/list/cult_clock_chaplain = list("ratvar", "clockwork", "ratvarism")
		if (religion_name in cult_blood_chaplain)
			to_chat(user, "<span class='info'>It reads: <i>[word1.rune] [word2.rune] [word3.rune]</i>. What spell was that already?...</span>")
			if (prob(5))
				spawn(50)
					to_chat(O, "<span class='game say'><span class='danger'>???-???</span> murmurs, <span class='sinister'>[pick(\
							"Your toys won't get you much further",\
							"Bitter that you weren't chosen?",\
							"I dig your style, but I crave for your blood.",\
							"Shall we gamble then? Obviously blood is the only acceptable bargaining chip")].</span></span>")

		//RIP Velard
		else if (religion_name in cult_clock_chaplain)
			to_chat(user, "<span class='info'>It reads a bunch of stupid shit.</span>")
			if (prob(5))
				spawn(50)=
					to_chat(O, "<span class='game say'><span class='danger'>???-???</span> murmurs, <span class='sinister'>[pick(\
							"Oh just fuck off",)].</span></span>")


/obj/effect/rune/update_icon()
	var/datum/rune_spell/spell = get_rune_spell(null, null, "examine", word1, word2, word3)

	var/animated = 0
	if(spell && spell.Act_restriction <= TODO INSERT CULT CHECK HERE)
		animated = 1
	else
		animated = 0

	var/lookup = "[word1.icon_state]-[animated]-[blood1.data["blood_colour"]]-[word2.icon_state]-[animated]-[blood2.data["blood_colour"]]-[word3.icon_state]-[animated]-[blood3.data["blood_colour"]]"

	if (lookup in uristrune_cache)
		icon = uristrune_cache[lookup]
	else
		var/icon/I1 = icon('icons/effects/uristrunes.dmi', "")
		if (word1)
			I1 = make_uristword(word1,blood1,animated)
		var/icon/I2 = icon('icons/effects/uristrunes.dmi', "")
		if (word2)
			I2 = make_uristword(word2,blood2,animated)
		var/icon/I3 = icon('icons/effects/uristrunes.dmi', "")
		if (word3)
			I3 = make_uristword(word3,blood3,animated)

		var/icon/I = icon('icons/effects/uristrunes.dmi', "")
		I.Blend(I1.Blend(I2.Blend(I3, ICON_OVERLAY), ICON_OVERLAY), ICON_OVERLAY)

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

/obj/effect/rune/proc/make_uristword(var/datum/cultword/word, var/datum/reagent/blood/blood, var/animated)
	var/icon/I = icon('icons/effects/uristrunes.dmi', "")
	var/lookupword = "[word.icon_state]-[animated]-[blood.data["blood_colour"]]"
	if(lookupword in uristrune_cache)
		I = uristrune_cache[lookupword]
	else
		I.Blend(icon('icons/effects/uristrunes.dmi', word.icon_state), ICON_OVERLAY)
		var/finalblood = blood.data["blood_colour"]
		var/list/blood_hsl = rgb2hsl(GetRedPart(finalblood),GetGreenPart(finalblood),GetBluePart(finalblood))
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
	return I


/obj/effect/rune/attackby(obj/I, mob/user)
	if(istype(I, /obj/item/weapon/nullrod))
		to_chat(user, "<span class='notice'>You disrupt the vile magic with the deadening field of \the [I]!</span>")
		qdel(src)
		return
	return

/proc/write_rune_word(var/turf/T,var/datum/reagent/blood/source,var/word = "")
	if (!word)
		return 0

	//Is there already a rune on the turf? if yes, let's try adding a word to it.
	var/obj/effect/rune/R = locate() in T
	if (!R)
		R = new/obj/effect/rune(T)

	//Let's add a word at the end of the pile. This way each world could technically have its own color.
	if (!word1)
		word1 = word
		blood1 = new()
		if (source.data["blood_colour"])
		blood1.data["blood_colour"] = source.data["blood_colour"]
		if (source.data["blood_type"])
			blood1.data["blood_DNA"] = source.data["blood_type"]
		else
			blood1.data["blood_DNA"] = "O+"
		if (source.data["virus2"])
			blood1.data["virus2"] = virus_copylist(source.data["virus2"])

	else if (!word2)
		word2 = word
		blood2 = new()
		if (source.data["blood_colour"])
		blood2.data["blood_colour"] = source.data["blood_colour"]
		if (source.data["blood_type"])
			blood2.data["blood_DNA"] = source.data["blood_type"]
		else
			blood2.data["blood_DNA"] = "O+"
		if (source.data["virus2"])
			blood2.data["virus2"] = virus_copylist(source.data["virus2"])

	else if (!word3)
		word3 = word
		blood3 = new()
		if (source.data["blood_colour"])
		blood3.data["blood_colour"] = source.data["blood_colour"]
		if (source.data["blood_type"])
			blood3.data["blood_DNA"] = source.data["blood_type"]
		else
			blood3.data["blood_DNA"] = "O+"
		if (source.data["virus2"])
			blood3.data["virus2"] = virus_copylist(source.data["virus2"])

	//think twice before touching runes made with contaminated blood
	virus2 = blood1.data["virus2"] | blood2.data["virus2"] | blood3.data["virus2"]

/obj/effect/rune/attack_animal(var/mob/living/simple_animal/user)
	if(istype(user, /mob/living/simple_animal/construct/harvester))
		trigger(user)

/obj/effect/rune/attack_paw(var/mob/living/user)
	if(ismonkey(M))
		trigger(user)

/obj/effect/rune/attack_hand(var/mob/living/user)
	trigger(user)

/obj/effect/rune/trigger(var/mob/living/user)
	user.delayNextAttack(5)
	if(!iscultist(user))
		to_chat(user, "You can't mouth the arcane scratchings without fumbling over them.")
		return

	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		to_chat(user, "You are unable to speak the words of the rune.")//TODO; SILENT CASTING ALLOWS MUZZLED CAST
		return

	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle()

	active_spell = get_rune_spell(user, src, "ritual" , word1, word2, word3)

	if (!active_spell)
		return fizzle()


/obj/effect/rune/proc/fizzle(var/mob/living/user)
	user.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP"))
	visible_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>","<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", "<span class='warning'>You hear a faint fizzle.</span>")

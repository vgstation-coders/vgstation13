



var/list/friendly_rune_list = list()//all peaceful runes currently in the world

/obj/effect/friendly_rune
	desc = "A strange collection of symbols drawn in blood."
	anchored = 1
	icon = 'icons/effects/uristrunes.dmi'
	icon_state = ""
	layer = RUNE_LAYER
	plane = ABOVE_TURF_PLANE

	//Whether the rune is pulsating
	var/animated = 0

	//A rune is made of up to 3 words
	var/datum/friendly_cultword/word1
	var/datum/friendly_cultword/word2
	var/datum/friendly_cultword/word3

	//An image we'll show to the AI instead of the rune
	var/image/blood_image

	//When a rune is created, we see if there's any data to copy from the blood used (colour, DNA, viruses) for all 3 words
	var/datum/reagent/blood/blood1
	var/datum/reagent/blood/blood2
	var/datum/reagent/blood/blood3
	var/list/datum/disease2/disease/virus2 = list()

	//The spell currently triggered by the rune. Prevents a rune from being used by different cultists at the same time.
	var/datum/friendly_rune_spell/active_spell = null

	//Prevents the same rune from being concealed/revealed several times on a row.
	var/conceal_cooldown = 0

/obj/effect/friendly_rune/New()
	..()
	blood_image = image(src)

	//AI cannot see runes, instead they see blood splatters.
	for(var/mob/living/silicon/ai/AI in player_list)
		if(AI.client)
			AI.client.images += blood_image

	friendly_rune_list.Add(src)

/obj/effect/friendly_rune/Destroy()
	for(var/mob/living/silicon/ai/AI in player_list)
		if (AI.client)
			AI.client.images -= blood_image
	qdel(blood_image)
	blood_image = null

	word1 = null
	word2 = null
	word3 = null

	blood1 = null
	blood2 = null
	blood3 = null

	if (active_spell)
		active_spell.abort()
		active_spell = null

	friendly_rune_list.Remove(src)

	..()

/obj/effect/friendly_rune/examine(var/mob/user)
	..()
	var/datum/friendly_rune_spell/rune_name = friendly_get_rune_spell(null, null, "examine", word1,word2,word3)
	to_chat(user, "<span class='info'>It reads: <i>[word1 ? "[word1.rune]" : ""] [word2 ? "[word2.rune]" : ""] [word3 ? "[word3.rune]" : ""]</i>.[rune_name ? " That's a <b>[initial(rune_name.name)]</b> rune." : "It doesn't match any rune spells."]</span>")
	if(rune_name)
		to_chat(user, initial(rune_name.desc))

/obj/effect/friendly_rune/cultify()
	return

/obj/effect/friendly_rune/ex_act(var/severity)
	switch (severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(15))
				qdel(src)

/obj/effect/friendly_rune/emp_act()
	return

/obj/effect/friendly_rune/blob_act()
	return

/obj/effect/friendly_rune/update_icon()
	var/datum/friendly_rune_spell/spell = friendly_get_rune_spell(null, null, "examine", word1, word2, word3)

	if(spell)
		animated = 1
	else
		animated = 0

	var/lookup = ""
	if (word1)
		lookup += "[word1.icon_state]-[animated]-[blood1.data["blood_colour"]]"
	if (word2)
		lookup += "-[word2.icon_state]-[animated]-[blood2.data["blood_colour"]]"
	if (word3)
		lookup += "-[word3.icon_state]-[animated]-[blood3.data["blood_colour"]]"

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
		I.Blend(I1, ICON_OVERLAY)
		I.Blend(I2, ICON_OVERLAY)
		I.Blend(I3, ICON_OVERLAY)
		icon = I
		uristrune_cache[lookup] = I

	if(animated)
		idle_pulse()
	else
		animate(src)

/obj/effect/friendly_rune/proc/idle_pulse()
	//This masterpiece of a color matrix stack produces a nice animation no matter which color was the blood used for the rune.
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


/obj/effect/friendly_rune/proc/one_pulse()
	animate(src, color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(2,0.67,0.27,0,0.27,2,0.67,0,0.67,0.27,2,0,0,0,0,1,0,0,0,0), time = 2)
	animate(color = list(1.875,0.56,0.19,0,0.19,1.875,0.56,0,0.56,0.19,1.875,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.75,0.45,0.12,0,0.12,1.75,0.45,0,0.45,0.12,1.75,0,0,0,0,1,0,0,0,0), time = 1)
	animate(color = list(1.625,0.35,0.06,0,0.06,1.625,0.35,0,0.35,0.06,1.625,0,0,0,0,1,0,0,0,0), time = 0.75)
	animate(color = list(1.5,0.27,0,0,0,1.5,0.27,0,0.27,0,1.5,0,0,0,0,1,0,0,0,0), time = 0.75)
	animate(color = list(1.375,0.19,0,0,0,1.375,0.19,0,0.19,0,1.375,0,0,0,0,1,0,0,0,0), time = 0.5)
	animate(color = list(1.25,0.12,0,0,0,1.25,0.12,0,0.12,0,1.25,0,0,0,0,1,0,0,0,0), time = 0.5)
	animate(color = list(1.125,0.06,0,0,0,1.125,0.06,0,0.06,0,1.125,0,0,0,0,1,0,0,0,0), time = 0.25)
	animate(color = list(1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0), time = 1)

	spawn (10)
		if(animated)
			idle_pulse()
		else
			animate(src)


/obj/effect/friendly_rune/proc/make_uristword(var/datum/friendly_cultword/word, var/datum/reagent/blood/blood, var/animated)
	var/icon/I = icon('icons/effects/uristrunes.dmi', "")
	if (!blood)
		blood = new
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
	return I


/obj/effect/friendly_rune/attackby(obj/I, mob/user)
	if(isholyweapon(I))
		to_chat(user, "<span class='notice'>Oh, come on now. Why would you want to destroy that?</span>")
		return
	return

/obj/effect/friendly_rune/Crossed(var/atom/movable/mover)
	if(ismob(mover))
		var/mob/user = mover
		var/datum/friendly_rune_spell/rune_effect = friendly_get_rune_spell(user, src, "walk" , word1, word2, word3)
		if(rune_effect)
			rune_effect.Added(mover)

/obj/effect/friendly_rune/Uncrossed(var/atom/movable/mover)
	if(active_spell && ismob(mover))
		active_spell.Removed(mover)
		
/proc/friendly_write_rune_word(var/turf/T,var/datum/reagent/blood/source,var/word = null)
	if (!word)
		return 0

	//Is there already a rune on the turf? if yes, let's try adding a word to it.
	var/obj/effect/friendly_rune/rune = locate() in T
	if (!rune)
		rune = new/obj/effect/friendly_rune(T)

	if (rune.word1 && rune.word2 && rune.word3)
		return 0

	//Let's add a word at the end of the pile. This way each world could technically have its own color.
	if (!rune.word1)
		rune.word1 = word
		rune.blood1 = new()
		if (source.data["blood_colour"])
			rune.blood1.data["blood_colour"] = source.data["blood_colour"]
		else
			rune.blood1.data["blood_colour"] = DEFAULT_BLOOD
		if (source.data["blood_type"])
			rune.blood1.data["blood_type"] = source.data["blood_type"]
		else
			rune.blood1.data["blood_type"] = "O+"
		if (source.data["blood_DNA"])
			rune.blood1.data["blood_DNA"] = source.data["blood_DNA"]
		else
			rune.blood1.data["blood_DNA"] = "O+"
		if (source.data["virus2"])
			rune.blood1.data["virus2"] = virus_copylist(source.data["virus2"])

	else if (!rune.word2)
		rune.word2 = word
		rune.blood2 = new()
		if (source.data["blood_colour"])
			rune.blood2.data["blood_colour"] = source.data["blood_colour"]
		else
			rune.blood1.data["blood_colour"] = DEFAULT_BLOOD
		if (source.data["blood_type"])
			rune.blood2.data["blood_type"] = source.data["blood_type"]
		else
			rune.blood2.data["blood_type"] = "O+"
		if (source.data["blood_DNA"])
			rune.blood2.data["blood_DNA"] = source.data["blood_DNA"]
		else
			rune.blood2.data["blood_DNA"] = "O+"
		if (source.data["virus2"])
			rune.blood2.data["virus2"] = virus_copylist(source.data["virus2"])

	else if (!rune.word3)
		rune.word3 = word
		rune.blood3 = new()
		if (source.data["blood_colour"])
			rune.blood3.data["blood_colour"] = source.data["blood_colour"]
		else
			rune.blood1.data["blood_colour"] = DEFAULT_BLOOD
		if (source.data["blood_type"])
			rune.blood3.data["blood_type"] = source.data["blood_type"]
		else
			rune.blood3.data["blood_type"] = "O+"
		if (source.data["blood_DNA"])
			rune.blood3.data["blood_DNA"] = source.data["blood_DNA"]
		else
			rune.blood3.data["blood_DNA"] = "O+"
		if (source.data["virus2"])
			rune.blood3.data["virus2"] = virus_copylist(source.data["virus2"])

	if (rune.blood3)
		rune.virus2 = rune.blood1.data["virus2"] | rune.blood2.data["virus2"] | rune.blood3.data["virus2"]
		rune.update_icon()
		return 1//That rune now has 3 words, that's a wrap.
	else if (rune.blood2)
		rune.virus2 = rune.blood1.data["virus2"] | rune.blood2.data["virus2"]
	else if (rune.blood1)
		rune.virus2 = rune.blood1.data["virus2"]

	rune.update_icon()
	return 2//There's room for more words on this rune, let's immediately prompt the player to write another one.

/proc/friendly_erase_rune_word(var/turf/T)
	var/obj/effect/friendly_rune/rune = locate() in T
	if(!rune)
		return null

	var/word_erased

	if (rune.word3)
		word_erased = rune.word3.rune
		rune.word3 = null
		rune.blood3 = null
		rune.update_icon()
		if (rune.active_spell)
			rune.active_spell.abort(RITUALABORT_ERASED)
			rune.active_spell = null
			rune.overlays.len = 0
	else if (rune.word2)
		word_erased = rune.word2.rune
		rune.word2 = null
		rune.blood2 = null
		rune.update_icon()
	else if (rune.word1)
		word_erased = rune.word1.rune
		rune.word1 = null
		rune.blood1 = null
		qdel(rune)
	else
		message_admins("Error! Trying to erase a word from a rune with no words!")
		qdel(rune)
		return null
	return word_erased

	

/obj/effect/friendly_rune/attack_animal(var/mob/living/simple_animal/user)
	if(istype(user, /mob/living/simple_animal/construct))
		trigger(user)

/obj/effect/friendly_rune/attack_paw(var/mob/living/user)
	if(ismonkey(user))
		trigger(user)

/obj/effect/friendly_rune/attack_hand(var/mob/living/user)
	trigger(user)
	
/obj/effect/friendly_rune/attack_robot(var/mob/living/user)
	trigger(user)

/obj/effect/friendly_rune/proc/trigger(var/mob/living/user,var/talisman_trigger=0)
	user.delayNextAttack(5)

	if(!iscultist(user) && !iscultistsilicon(user))
		to_chat(user, "<span class='danger'>You can't mouth the arcane scratchings without fumbling over them.</span>")
		return

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(C.muted())
			to_chat(user, "<span class='danger'>You find yourself unable to focus your mind on the arcane words of the rune.</span>")
			return

	var/silent_casting = user.checkTattoo(TATTOO_SILENT)

	if(!silent_casting)
		if(user.is_wearing_item(/obj/item/clothing/mask/muzzle, slot_wear_mask))
			to_chat(user, "<span class='danger'>You are unable to speak the words of the rune because of \the [user.wear_mask].</span>")
			return
		if(user.is_mute())
			to_chat(user, "<span class='danger'>You don't have the ability to perform rituals without voicing the incantations, there has to be some way...</span>")
			return

	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle(user)

	if (active_spell)//rune is already channeling a spell? let's see if we can interact with it somehow.
		active_spell.midcast(user)
		return

	active_spell = friendly_get_rune_spell(user, src, "ritual" , word1, word2, word3)

	if(!active_spell)
		return fizzle(user)
	else if(active_spell.destroying_self)
		active_spell = null

/obj/effect/friendly_rune/proc/fizzle(var/mob/living/user)
	var/silent = user.checkTattoo(TATTOO_SILENT)
	if(!silent)
		user.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP","I'F ON'Y I 'AD 'TAB' E"))
	one_pulse()
	visible_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>",\
	"<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>",\
	"<span class='warning'>You hear a faint fizzle.</span>")
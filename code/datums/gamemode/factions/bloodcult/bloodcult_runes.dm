
var/list/runes = list()
var/list/rune_appearances_cache = list()

/obj/effect/rune //Abstract, currently only supports blood as a reagent without some serious overriding.
	name = "rune"
	desc = "A strange collection of symbols drawn in blood."
	anchored = 1
	icon = 'icons/effects/deityrunes.dmi'
	icon_state = ""
	layer = RUNE_LAYER
	plane = ABOVE_TURF_PLANE

	mouse_opacity = 1 //So we can actually click these

	//Whether the rune is pulsating
	var/animated = 0
	var/activated = 0 // how many times the rune was activated. goes back to 0 if a word is erased.

	//A rune is made of up to 3 words.
	var/datum/rune_word/word1
	var/datum/rune_word/word2
	var/datum/rune_word/word3

	//An image we'll show to the AI instead of the rune
	var/image/blood_image

	//When a rune is created, we see if there's any data to copy from the blood used (colour, DNA, viruses) for all 3 words
	var/datum/reagent/blood/blood1
	var/datum/reagent/blood/blood2
	var/datum/reagent/blood/blood3
	var/list/datum/disease2/disease/virus2 = list()

	//Used when a nullrod is preventing a rune's activation TODO: REWORK NULL ROD INTERACTIONS
	var/nullblock = 0

	//The spell currently triggered by the rune. Prevents a rune from being used by different cultists at the same time.
	var/datum/rune_spell/active_spell = null

	//Prevents the same rune from being concealed/revealed several times on a row.
	var/conceal_cooldown = 0

/obj/effect/rune/New()
	..()
	blood_image = image(src)

	//AI cannot see runes, instead they see blood splatters.
	for(var/mob/living/silicon/ai/AI in player_list)
		if(AI.client)
			AI.client.images += blood_image

	runes += src

	//adding to holomaps
	var/datum/holomap_marker/holomarker = new()
	holomarker.id = HOLOMAP_MARKER_CULT_RUNE
	holomarker.filter = HOLOMAP_FILTER_CULT
	holomarker.x = src.x
	holomarker.y = src.y
	holomarker.z = src.z
	holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[src]"] = holomarker


/obj/effect/rune/Destroy()
	for(var/mob/living/silicon/ai/AI in player_list)
		if (AI.client)
			AI.client.images -= blood_image
	QDEL_NULL(blood_image)

	if (word1)
		erase_word(word1.english,blood1)
		word1 = null
	if (word2)
		erase_word(word2.english,blood2)
		word2 = null
	if (word3)
		erase_word(word3.english,blood3)
		word3 = null

	blood1 = null
	blood2 = null
	blood3 = null

	if (active_spell)
		active_spell.abort()
		active_spell = null

	runes -= src

	//removing from holomaps
	holomap_markers -= HOLOMAP_MARKER_CULT_RUNE+"_\ref[src]"

	..()

/obj/effect/rune/ErasableRune()
	if (activated)
		return FALSE
	return TRUE

/obj/effect/rune/examine(var/mob/user)
	..()
	if(can_read_rune(user) || isobserver(user))
		var/datum/rune_spell/rune_name = get_rune_spell(null, null, "examine", word1,word2,word3)
		to_chat(user, "<span class='info'>It reads: <i>[word1 ? "[word1.rune]" : ""][word2 ? " [word2.rune]" : ""][word3 ? " [word3.rune]" : ""]</i>. [rune_name ? " That's a <b>[initial(rune_name.name)]</b> rune." : "It doesn't match any rune spells."]</span>")
		if(rune_name)
			to_chat(user, initial(rune_name.desc))
			if (istype(active_spell,/datum/rune_spell/portalentrance))
				var/datum/rune_spell/portalentrance/PE = active_spell
				if (PE.network)
					to_chat(user, "<span class='info'>This entrance was attuned to the <b>[PE.network]</b> path.</span>")
			if (istype(active_spell,/datum/rune_spell/portalexit))
				var/datum/rune_spell/portalexit/PE = active_spell
				if (PE.network)
					to_chat(user, "<span class='info'>This exit was attuned to the <b>[PE.network]</b> path.</span>")

	//"Cult" chaplains can read the words, but they have to figure out the spell themselves. Also has a chance to trigger a taunt from Nar-Sie.
	else if(istype(user, /mob/living/carbon/human) && (user.mind.assigned_role == "Chaplain"))
		var/list/cult_blood_chaplain = list("cult", "narsie", "nar'sie", "narnar", "nar-sie")
		var/list/cult_clock_chaplain = list("ratvar", "clockwork", "ratvarism")
		if (religion_name in cult_blood_chaplain)
			to_chat(user, "<span class='info'>It reads: <i>[word1.rune] [word2.rune] [word3.rune]</i>. What spell was that already?...</span>")
			if (prob(5))
				spawn(50)
					to_chat(user, "<span class='game say'><span class='danger'>???-???</span> murmurs, <span class='sinister'>[pick(\
							"Your toys won't get you much further",\
							"Bitter that you weren't chosen?",\
							"I dig your style, but I crave for your blood.",\
							"Shall we gamble then? Obviously blood is the only acceptable bargaining chip")].</span></span>")

		//RIP Velard
		else if (religion_name in cult_clock_chaplain)
			to_chat(user, "<span class='info'>It reads a bunch of stupid shit.</span>")
			if (prob(5))
				spawn(50)
					to_chat(user, "<span class='game say'><span class='danger'>???-???</span> murmurs, <span class='sinister'>[pick(\
							"Oh just fuck off",)].</span></span>")

/obj/effect/rune/proc/can_read_rune(var/mob/user) //Overload for specific criteria.
	return iscultist(user)

/obj/effect/rune/cultify()
	return

/obj/effect/rune/salt_act()
	var/turf/T = get_turf(src)
	anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_break", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	if (active_spell)
		active_spell.salt_act(T)
	qdel(src)

/obj/effect/rune/proc/write_word(var/word,var/datum/reagent/blood/blood)
	if (!word)
		return
	var/turf/T = get_turf(src)
	var/write_color = DEFAULT_BLOOD
	if (blood && blood.data["blood_colour"])
		write_color = blood.data["blood_colour"]
	anim(target = T, a_icon = 'icons/effects/deityrunes.dmi', flick_anim = "[word]-write", lay = layer+0.1, col = write_color, plane = plane)

/obj/effect/rune/proc/erase_word(var/word,var/datum/reagent/blood/blood)
	if (!word)
		return
	var/turf/T = get_turf(src)
	var/erase_color = DEFAULT_BLOOD
	if (blood && blood.data["blood_colour"])
		erase_color = blood.data["blood_colour"]
	anim(target = T, a_icon = 'icons/effects/deityrunes.dmi', flick_anim = "[word]-erase", lay = layer+0.1, col = erase_color, plane = plane)

/obj/effect/rune/proc/cast_word(var/word)
	if (!word)
		return
	var/atom/movable/overlay/A = anim(target = get_turf(src), a_icon = 'icons/effects/deityrunes.dmi', a_icon_state = "[word]-tear", lay = layer+0.2, plane = plane)
	animate(A, alpha = 0,time = 5)

/obj/effect/rune/ex_act(var/severity)
	switch (severity)
		if (1)
			qdel(src)
		if (2)
			if (prob(15))
				qdel(src)

/obj/effect/rune/emp_act()
	return

/obj/effect/rune/blob_act()
	return

/obj/effect/rune/update_icon(var/draw_up_to = 3)
	var/datum/rune_spell/spell = get_rune_spell(null, null, "examine", word1, word2, word3)

	if (active_spell)
		return

	overlays.len = 0

	if(spell && activated)
		animated = 1
		draw_up_to = 3
	else
		animated = 0

	var/lookup = ""
	if (word1)
		lookup += "[word1.english]-[animated]-[blood1.data["blood_colour"]]"
	if (word2 && draw_up_to >= 2)
		lookup += "-[word2.english]-[animated]-[blood2.data["blood_colour"]]"
	if (word3 && draw_up_to >= 3)
		lookup += "-[word3.english]-[animated]-[blood3.data["blood_colour"]]"

	var/image/rune_render
	if (lookup in rune_appearances_cache)
		rune_render = image(rune_appearances_cache[lookup])
	else
		var/image/I1 = image('icons/effects/deityrunes.dmi',src,"")
		if (word1)
			I1.icon_state = word1.english
			if (blood1.data["blood_colour"])
				I1.color = blood1.data["blood_colour"]
		var/image/I2 = image('icons/effects/deityrunes.dmi',src,"")
		if (word2 && draw_up_to >= 2)
			I2.icon_state = word2.english
			if (blood2.data["blood_colour"])
				I2.color = blood2.data["blood_colour"]
		var/image/I3 = image('icons/effects/deityrunes.dmi',src,"")
		if (word3 && draw_up_to >= 3)
			I3.icon_state = word3.english
			if (blood3.data["blood_colour"])
				I3.color = blood3.data["blood_colour"]

		rune_render = image('icons/effects/deityrunes.dmi',src,"")
		rune_render.overlays += I1
		rune_render.overlays += I2
		rune_render.overlays += I3

		if(animated)
			if (word1)
				var/image/I =  image('icons/effects/deityrunes.dmi',src,"[word1.english]-tear")
				I.color = "black"
				I.appearance_flags = RESET_COLOR
				rune_render.overlays += I
			if (word2)
				var/image/I =  image('icons/effects/deityrunes.dmi',src,"[word2.english]-tear")
				I.color = "black"
				I.appearance_flags = RESET_COLOR
				rune_render.overlays += I
			if (word3)
				var/image/I =  image('icons/effects/deityrunes.dmi',src,"[word3.english]-tear")
				I.color = "black"
				I.appearance_flags = RESET_COLOR
				rune_render.overlays += I

		rune_appearances_cache[lookup] = rune_render
	overlays += rune_render

	if(animated)
		idle_pulse()
	else
		animate(src)

/obj/effect/rune/proc/idle_pulse()
	//This masterpiece of a color matrix stack produces a nice animation no matter which color the rune is.
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


/obj/effect/rune/proc/one_pulse()
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


/obj/effect/rune/Crossed(var/atom/movable/mover)
	if (ismob(mover))
		var/mob/user = mover
		var/datum/rune_spell/rune_effect = get_rune_spell(user, src, "walk" , word1, word2, word3)
		if (rune_effect)
			rune_effect.Added(mover)

/obj/effect/rune/Uncrossed(var/atom/movable/mover)
	if (active_spell && ismob(mover))
		active_spell.Removed(mover)

/obj/effect/rune/attack_animal(var/mob/living/simple_animal/user)
	if(istype(user, /mob/living/simple_animal/construct))
		trigger(user)
	if(istype(user, /mob/living/simple_animal/shade))
		trigger(user)

/obj/effect/rune/attack_paw(var/mob/living/user)
	if(ismonkey(user))
		assume_contact_diseases(user)
		trigger(user)

/obj/effect/rune/attack_alien(var/mob/living/user)
	if(isalien(user))
		trigger(user)

/obj/effect/rune/attack_hand(var/mob/living/user)
	assume_contact_diseases(user)
	trigger(user)

/obj/effect/rune/attack_robot(var/mob/living/user) //Allows for robots to remotely trigger runes, since attack_robot has infinite range.
	trigger(user)

/obj/effect/rune/proc/assume_contact_diseases(var/mob/living/user)
	var/block = 0
	var/bleeding = 0
	block = user.check_contact_sterility(HANDS)
	bleeding = user.check_bodypart_bleeding(HANDS)
	user.assume_contact_diseases(virus2,src,block,bleeding)

/obj/effect/rune/attackby(obj/I, mob/user)
	..()
	if(isholyweapon(I))
		to_chat(user, "<span class='notice'>You disrupt the vile magic with the deadening field of \the [I]!</span>")
		qdel(src)
		return
	if(istype(I, /obj/item/weapon/tome) || istype(I, /obj/item/weapon/melee/cultblade) || istype(I, /obj/item/weapon/melee/soulblade) || istype(I, /obj/item/weapon/melee/blood_dagger))
		trigger(user)
	if(istype(I, /obj/item/weapon/talisman))
		var/obj/item/weapon/talisman/T = I
		T.imbue(user,src)
	return

/obj/effect/rune/proc/trigger(var/mob/living/user, var/talisman_trigger=0)
	user.delayNextAttack(5)

	if(!iscultist(user))
		to_chat(user, "<span class='danger'>You can't mouth the arcane scratchings without fumbling over them.</span>")
		return

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if (C.occult_muted())
			to_chat(user, "<span class='danger'>You find yourself unable to focus your mind on the arcane words of the rune.</span>")
			return
		if(C.lying)
			to_chat(user, "<span class='warning'>You need to stand upright for the ritual to proceed properly.</span>")
			return

	if(!user.checkTattoo(TATTOO_SILENT))
		if(user.wear_mask?.is_muzzle)
			to_chat(user, "<span class='danger'>You are unable to speak the words of the rune because of \the [user.wear_mask].</span>")
			return

		if(user.is_mute())
			to_chat(user, "<span class='danger'>You don't have the ability to perform rituals without voicing the incantations, there has to be some way...</span>")
			return

	if(!word1 || !word2 || !word3 || prob(user.getBrainLoss()))
		return fizzle(user)

	add_hiddenprint(user)

	if(active_spell)//rune is already channeling a spell? let's see if we can interact with it somehow.
		if(talisman_trigger)
			var/datum/rune_spell/active_spell_typecast = active_spell
			if(!istype(active_spell_typecast))
				return
			active_spell_typecast.midcast_talisman(user)
		else
			active_spell.midcast(user)
		return

	reveal()//concealed rune get automatically revealed upon use (either through using Seer or an attuned talisman). Placed after midcast: exception for Path talismans.

	active_spell = get_rune_spell(user, src, "ritual", word1, word2, word3)

	if (!active_spell)
		return fizzle(user)
	else
		if (active_spell.destroying_self)
			active_spell = null

/obj/effect/rune/proc/fizzle(var/mob/living/user)
	var/silent = user.checkTattoo(TATTOO_SILENT)
	if(!silent)
		user.say(pick("B'ADMINES SP'WNIN SH'T","IC'IN O'OC","RO'SHA'M I'SA GRI'FF'N ME'AI","TOX'IN'S O'NM FI'RAH","IA BL'AME TOX'IN'S","FIR'A NON'AN RE'SONA","A'OI I'RS ROUA'GE","LE'OAN JU'STA SP'A'C Z'EE SH'EF","IA PT'WOBEA'RD, IA A'DMI'NEH'LP","I'F ON'Y I 'AD 'TAB' E"))
	one_pulse()
	visible_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>",\
	"<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>",\
	"<span class='warning'>You hear a faint fizzle.</span>")

/obj/effect/rune/proc/conceal()
	if(active_spell && !active_spell.can_conceal)
		active_spell.abort(RITUALABORT_CONCEAL)
	alpha = 0
	if (word1)
		erase_word(word1.english,blood1)
	if (word2)
		erase_word(word2.english,blood2)
	if (word3)
		erase_word(word3.english,blood3)
	spawn(6)
		invisibility=INVISIBILITY_OBSERVER
		alpha = 127

/obj/effect/rune/proc/reveal() //Returns 1 if rune was revealed from a invisible state.
	if(invisibility != 0)
		invisibility=0
		if (!(active_spell?.custom_rune))
			overlays.len = 0
			if (word1)
				write_word(word1.english,blood1)
			if (word2)
				write_word(word2.english,blood2)
			if (word3)
				write_word(word3.english,blood3)
			spawn(8)
				alpha = 255
				update_icon()
		else
			alpha = 255
		conceal_cooldown = 1
		spawn(100)
			if (src && loc)
				conceal_cooldown = 0
		return 1
	return 0

/obj/effect/rune/proc/manage_diseases(var/datum/reagent/blood/source)
	virus2 = list()

	if (blood1)
		blood1.data["virus2"] = virus_copylist(source.data["virus2"])
		var/list/datum/disease2/disease/blood1_diseases = blood1.data["virus2"]
		for (var/ID in blood1_diseases)
			var/datum/disease2/disease/V = blood1_diseases[ID]
			if(istype(V))
				virus2["[V.uniqueID]-[V.subID]"] = V.getcopy()
	if (blood2)
		blood2.data["virus2"] = virus_copylist(source.data["virus2"])
		var/list/datum/disease2/disease/blood2_diseases = blood2.data["virus2"]
		for (var/ID in blood2_diseases)
			if (ID in virus2)
				continue
			var/datum/disease2/disease/V = blood2_diseases[ID]
			if(istype(V))
				virus2["[V.uniqueID]-[V.subID]"] = V.getcopy()
	if (blood3)
		blood3.data["virus2"] = virus_copylist(source.data["virus2"])
		var/list/datum/disease2/disease/blood3_diseases = blood3.data["virus2"]
		for (var/ID in blood3_diseases)
			if (ID in virus2)
				continue
			var/datum/disease2/disease/V = blood3_diseases[ID]
			if(istype(V))
				virus2["[V.uniqueID]-[V.subID]"] = V.getcopy()

/obj/effect/rune/clean_act(var/cleanliness)
	if ((cleanliness >= CLEANLINESS_SPACECLEANER) && (!activated))
		qdel(src)

/proc/write_rune_word(var/turf/T, var/datum/rune_word/word = null, var/datum/reagent/blood/source, var/mob/caster = null)
	if (!word)
		return RUNE_WRITE_CANNOT

	if (!source)
		source = new

	//Add word to a rune if there is one, otherwise create one. However, there can be no more than 3 words.
	//Returns 0 if failure, 1 if finished a rune, 2 if success but rune still has room for words.

	var/newrune = FALSE
	var/obj/effect/rune/rune = locate() in T
	if(!rune)
		rune = new /obj/effect/rune(T)
		newrune = TRUE

	if (rune.word1 && rune.word2 && rune.word3)
		return RUNE_WRITE_CANNOT

	if (caster)
		if (newrune)
			log_admin("BLOODCULT: [key_name(caster)] has created a new rune at [T.loc] (@[T.x],[T.y],[T.z]).")
			message_admins("BLOODCULT: [key_name(caster)] has created a new rune at [formatJumpTo(T)].")
		rune.add_hiddenprint(caster)

	rune.write_word(word.english,source)

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
		spawn (8)
			rune.update_icon(1)

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
		spawn (8)
			rune.update_icon(2)

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
		spawn (8)
			rune.update_icon(3)

	rune.manage_diseases(source)

	if (rune.blood3)
		TriggerCultRitual(ritualtype = /datum/bloodcult_ritual/always_active/draw_rune, extrainfo = list("erased" = FALSE))
		return RUNE_WRITE_COMPLETE
	return RUNE_WRITE_CONTINUE

/proc/erase_rune_word(var/turf/T)
	var/obj/effect/rune/rune = locate() in T
	if(!rune)
		return null

	var/word_erased

	if(rune.word3)
		rune.erase_word(rune.word3.english, rune.blood3)
		word_erased = rune.word3.rune
		rune.word3 = null
		rune.blood3 = null
		rune.update_icon()
		TriggerCultRitual(ritualtype = /datum/bloodcult_ritual/always_active/draw_rune, extrainfo = list("erased" = TRUE))
		if (rune.active_spell)
			rune.active_spell.abort(RITUALABORT_ERASED)
			rune.active_spell = null
			rune.overlays.len = 0
	else if(rune.word2)
		rune.erase_word(rune.word2.english, rune.blood2)
		word_erased = rune.word2.rune
		rune.word2 = null
		rune.blood2 = null
		rune.update_icon()
	else if(rune.word1)
		rune.erase_word(rune.word1.english, rune.blood1)
		word_erased = rune.word1.rune
		rune.word1 = null
		rune.blood1 = null
		qdel(rune)
	else
		message_admins("Error! Trying to erase a word from a rune with no words!")
		qdel(rune)
		return null
	rune.activated = 0
	return word_erased


/proc/write_full_rune(var/turf/T, var/spell_type, var/datum/reagent/blood/source, var/mob/caster = null)
	if (!spell_type)
		return

	var/datum/rune_spell/spell_instance = spell_type
	var/datum/rune_word/word1_instance = initial(spell_instance.word1)
	var/datum/rune_word/word2_instance = initial(spell_instance.word2)
	var/datum/rune_word/word3_instance = initial(spell_instance.word3)
	write_rune_word(T, rune_words[initial(word1_instance.english)], source, caster)
	write_rune_word(T, rune_words[initial(word2_instance.english)], source, caster)
	write_rune_word(T, rune_words[initial(word3_instance.english)], source, caster)

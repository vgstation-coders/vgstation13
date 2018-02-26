//THE SPELLS PROC'D BY THE RUNES

/datum/rune_spell
	var/name = "default name"
	var/desc = "default description"
	var/Act_restriction = CULT_PROLOGUE
	var/obj/spell_holder = null
	var/mob/activator = null
	var/datum/cultword/word1 = null
	var/datum/cultword/word2 = null
	var/datum/cultword/word3 = null
	var/teleporter = 0//teleporter runes only need the first two words to be valid
	var/invocation = "Lo'Rem Ip'Sum"

/datum/rune_spell/New(var/mob/user, var/obj/holder, var/use = "ritual")
	spell_holder = holder
	activator = user

	switch (use)
		if ("ritual")
			cast()

/datum/rune_spell/Destroy()
	if (spell_holder)
		if (istype(spell_holder, /obj/effect/rune))
			var/obj/effect/rune/rune_holder = spell_holder
			rune_holder.active_spell = null
		spell_holder = null
	word1 = null
	word2 = null
	word3 = null
	activator = null
	..()

/datum/rune_spell/proc/cast()
	qdel(src)

/datum/rune_spell/proc/abort(var/cause = "erased")
	switch (cause)
		if ("erased")
			if (istype (spell_holder,/obj/effect/rune))
				spell_holder.visible_message("<span class='warning'>The rune's destruction ended the ritual.</span>")
	del(src)


//Called whenever a rune gets activated or examined
/proc/get_rune_spell(var/mob/user, var/obj/spell_holder, var/use = "ritual", var/datum/cultword/word1, var/datum/cultword/word2, var/datum/cultword/word3)
	if (!word1 || !word2 || !word3)
		return
	for(var/subtype in subtypesof(/datum/rune_spell))
		var/datum/rune_spell/instance = subtype
		if (initial(instance.teleporter) && word1.type == initial(instance.word1) && word2.type == initial(instance.word2))
			switch (use)
				if ("ritual")
					return new subtype(user, spell_holder, use, word3)
				if ("examine")
					return instance
		else if (word1.type == initial(instance.word1) && word2.type == initial(instance.word2) && word3.type == initial(instance.word3))
			switch (use)
				if ("ritual")
					return new subtype(user, spell_holder, use)
				if ("examine")
					return instance
			return new subtype(user, spell_holder, use)
	return null

//RUNE I
/datum/rune_spell/raisestructure
	name = "Raise Structure"
	desc = "Drag-in eldritch structures from the realm of Nar-Sie."
	Act_restriction = CULT_PROLOGUE
	word1 = /datum/cultword/blood
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/join

//RUNE II
/datum/rune_spell/communication
	name = "Communication"
	desc = "Speak so that every cultists may hear your voice."
	Act_restriction = CULT_PROLOGUE
	invocation = "O bidai nabora se'sma!"
	var/obj/effect/cult_ritual/cult_communication/comms = null
	var/destroying_self = 0
	word1 = /datum/cultword/self
	word2 = /datum/cultword/other
	word3 = /datum/cultword/technology

/datum/rune_spell/communication/cast()
	var/mob/living/user = activator
	if (user.loc != spell_holder.loc)
		abort("too far")
	else
		user.say(invocation)
		comms = new /obj/effect/cult_ritual/cult_communication(spell_holder.loc,user,src)

/datum/rune_spell/communication/abort(var/cause = "erased")
	switch (cause)
		if ("too far")
			spell_holder.visible_message("<span class='warning'>The [name] ritual requires you to stand on top of the rune.</span>")
		if ("moved away")
			spell_holder.visible_message("<span class='warning'>The ritual ends as you move away from the rune.</span>")
	..()


/datum/rune_spell/communication/Destroy()
	if (destroying_self)
		return
	destroying_self = 1
	qdel(comms)
	comms = null
	..()

/obj/effect/cult_ritual/cult_communication
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "rune_communication"
	pixel_y = 8
	alpha = 200
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	mouse_opacity = 0
	flags = HEAR|PROXMOVE
	var/mob/living/caster = null
	var/datum/rune_spell/communication/source = null
	var/ending = ""


/obj/effect/cult_ritual/cult_communication/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/communication/runespell)
	..()
	caster = user
	source = runespell

/obj/effect/cult_ritual/cult_communication/Destroy()
	caster = null
	source.abort(ending)
	source = null
	..()

/obj/effect/cult_ritual/cult_communication/Hear(var/datum/speech/speech, var/rendered_message="")
	if(speech.speaker && speech.speaker.loc == loc)//&& iscultist DUH
		var/speaker_name = speech.speaker.name
		if (ishuman(speech.speaker))
			var/mob/living/carbon/human/H = speech.speaker
			speaker_name = H.real_name
		rendered_message = speech.render_message()
		for(var/mob/living/L in player_list)//&& iscultist DUH
			to_chat(L, "<span class='game say'><b>[speaker_name]</b>'s voice echoes in your head, <B><span class='sinister'>[speech.message]</span></B></span>")
		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><b>[speaker_name]</b> communicates, <span class='sinister'>[speech.message]</span></span>")
		log_cultspeak("[key_name(speech.speaker)] Cult Communicate Rune: [rendered_message]")

/obj/effect/cult_ritual/cult_communication/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		qdel(src)

/obj/effect/cult_ritual/cultify()
	return

/obj/effect/cult_ritual/ex_act(var/severity)
	return

/obj/effect/cult_ritual/emp_act()
	return

/obj/effect/cult_ritual/blob_act()
	return


//RUNE III
/datum/rune_spell/summontome
	name = "Summon Tome"
	desc = "Bring forth an arcane tome filled with Nar-Sie's knowledge."
	Act_restriction = CULT_ACT_I
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	word1 = /datum/cultword/see
	word2 = /datum/cultword/blood
	word3 = /datum/cultword/hell

//RUNE IV
/datum/rune_spell/conjuretalisman
	name = "Conjure Talisman"
	desc = "Can turn some runes into talismans."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/join

//RUNE V
/datum/rune_spell/conversion
	name = "Conversion"
	desc = "Open the eyes of the unbelievers."
	Act_restriction = CULT_ACT_I
	invocation = "Mah'weyh pleggh at e'ntrath!"
	word1 = /datum/cultword/join
	word2 = /datum/cultword/blood
	word3 = /datum/cultword/self

//RUNE VI
/datum/rune_spell/stun
	name = "Stun"
	desc = "Overwhelm your victim's senses with pure energy so they become catatonic for a moment."
	Act_restriction = CULT_ACT_I
	invocation = "Fuu ma'jin!"
	word1 = /datum/cultword/join
	word2 = /datum/cultword/hide
	word3 = /datum/cultword/technology

//RUNE VII
/datum/rune_spell/blind
	name = "Blind"
	desc = "Get the edge over nearby enemies by removing their senses."
	Act_restriction = CULT_ACT_I
	invocation = "Sti' kaliesin!"
	word1 = /datum/cultword/destroy
	word2 = /datum/cultword/see
	word3 = /datum/cultword/other
	word3 = /datum/cultword/other

//RUNE VIII
/datum/rune_spell/mute
	name = "Mute"
	desc = "Silence and deafen nearby enemies."
	Act_restriction = CULT_ACT_I
	invocation = "Sti' kaliedir!"
	word1 = /datum/cultword/hide
	word2 = /datum/cultword/other
	word3 = /datum/cultword/see

//RUNE IX
/datum/rune_spell/hide
	name = "Hide"
	desc = "Hide runes, blood stains, corpses, structures, and other compromising items."
	Act_restriction = CULT_ACT_I
	invocation = "Kla'atu barada nikt'o!"
	word1 = /datum/cultword/hide
	word2 = /datum/cultword/see
	word3 = /datum/cultword/blood

//RUNE X
/datum/rune_spell/reveal
	name = "Reveal"
	desc = "Reveal what you have previously hidden."
	Act_restriction = CULT_ACT_I
	invocation = "Nikt'o barada kla'atu!"
	word1 = /datum/cultword/blood
	word2 = /datum/cultword/see
	word3 = /datum/cultword/hide

//RUNE XI
/datum/rune_spell/seer
	name = "Seer"
	desc = "See the invisible, the dead, hear their voice."
	Act_restriction = CULT_ACT_I
	invocation = "Rash'tla sektath mal'zua. Zasan therium viortia."
	word1 = /datum/cultword/see
	word2 = /datum/cultword/hell
	word3 = /datum/cultword/join

//RUNE XII
/datum/rune_spell/summonrobes
	name = "Summon Robes"
	desc = "Wear the robes of those who follow Nar-Sie."
	Act_restriction = CULT_ACT_II
	invocation = "Sa tatha najin"
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/destroy
	word3 = /datum/cultword/other

//RUNE XIII
/datum/rune_spell/door
	name = "Door"
	desc = "More obstacles for your enemies to overcome."
	Act_restriction = CULT_ACT_II
	invocation = "Khari'd! Eske'te tannin!"
	word1 = /datum/cultword/destroy
	word2 = /datum/cultword/travel
	word3 = /datum/cultword/self

//RUNE XIV
/datum/rune_spell/fervor
	name = "Fervor"
	desc = "Inspire nearby cultists to purge their stuns and raise their movement speed."
	Act_restriction = CULT_ACT_II
	invocation = "Khari'd! Gual'te nikka!"
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/other

//RUNE XV
/datum/rune_spell/summoncultist
	name = "Summon Cultist"
	desc = "Bring forth one of your fellow believers, no matter how far they are, as long as their heart beats"
	Act_restriction = CULT_ACT_II
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	word1 = /datum/cultword/join
	word2 = /datum/cultword/other
	word3 = /datum/cultword/self

//RUNE XVI
/datum/rune_spell/portalentrance
	name = "Portal Entrance"
	desc = "Take a shortcut through the veil between this world and the other one."
	Act_restriction = CULT_ACT_II
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/self

/datum/rune_spell/portalentrance/New(var/mob/user, var/obj/holder, var/datum/cultword/w3)
	..()
	teleporter = 1
	if (w3)
		word3 = w3.type

//RUNE XVII
/datum/rune_spell/portalexit
	name = "Portal Exit"
	desc = "We hope you enjoyed your flight with Air Nar-Sie"//might change it later or not.
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/other

/datum/rune_spell/portalexit/New(var/mob/user, var/obj/holder, var/datum/cultword/w3)
	..()
	teleporter = 1
	if (w3)
		word3 = w3.type

//RUNE XVIII
/datum/rune_spell/pulse
	name = "Pulse"
	desc = "Scramble the circuits of nearby devices"
	Act_restriction = CULT_ACT_II
	invocation = "Ta'gh fara'qha fel d'amar det!"
	word1 = /datum/cultword/destroy
	word2 = /datum/cultword/see
	word3 = /datum/cultword/technology

//RUNE XIX
/datum/rune_spell/astraljourney
	name = "Astral Journey"
	desc = "Leave your body so you can converse with the dead and observe your targets."
	Act_restriction = CULT_ACT_II
	invocation = "Fwe'sh mah erl nyag r'ya!"
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/travel
	word3 = /datum/cultword/self

//RUNE XX
/datum/rune_spell/resurrect
	name = "Resurrect"
	desc = "Create a strong body for your fallen allies to inhabit."
	Act_restriction = CULT_ACT_III
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!"
	word1 = /datum/cultword/blood
	word2 = /datum/cultword/join
	word3 = /datum/cultword/hell








/*
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
*/
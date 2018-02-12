//THE SPELLS PROC'D BY THE RUNES

/datum/rune_spell
	var/name = "default name"
	var/description = "default description"
	var/Act_restriction = 0
	var/obj/spell_holder = null
	var/mob/activator = null
	var/datum/cultword/word1 = null
	var/datum/cultword/word2 = null
	var/datum/cultword/word3 = null
	var/teleporter = 0//teleporter runes only need the first two words to be valid
	var/invocation = "Lo'Rem Ip'Sum"

/datum/rune_spell/New(var/mob/user, var/obj/holder)
	spell_holder = holder
	activator = user

	switch (use)
		if ("examine")//we only need the datum to exist for the time it takes someproc to get its vars.
			spawn(10)
				qdel(src)
		if ("ritual")
			cast()

/datum/rune_spell/Destroy()
	if (spell_holder)
		spell_holder.active_spell = null
		spell_holder = null
	..()

/datum/rune_spell/proc/cast()
	var/mob/living/user = activator
	user.say(invocation)
	qdel(src)


//Called whenever a rune gets activated or examined
/proc/get_rune_spell(var/mob/user, var/obj/spell_holder, var/use = "ritual", var/datum/cultword/word1, var/datum/cultword/word2, var/datum/cultword/word3)
	if (!word1 || !word2 || !word3)
		return

	for(var/subtype in typesof(/datum/rune_spell)-/datum/rune_spell)
		if (subtype.teleporter && word1.type == subtype.word1 && word2.type == subtype.word2)
			return new subtype(user, spell_holder, use, word3)
		else if (word1.type == subtype.word1 && word2.type == subtype.word2 && word3.type == subtype.word3)
			return new subtype(user, spell_holder, use)
		else return null

//RUNE I
/datum/rune_spell/raisestructure
	name = "Raise Structure"
	description = "Drag-in eldritch structures from the realm of Nar-Sie."
	Act_restriction = CULT_PROLOGUE
	word1 = /datum/cultword/blood
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/join

//RUNE II
/datum/rune_spell/communication
	name = "Communication"
	description = "Speak so that every cultists may hear your voice."
	Act_restriction = CULT_PROLOGUE
	word1 = /datum/cultword/self
	word2 = /datum/cultword/other
	word3 = /datum/cultword/technology
	invocation = "O bidai nabora se'sma!"

//RUNE III
/datum/rune_spell/summontome
	name = "Summon Tome"
	description = "Bring forth an arcane tome filled with Nar-Sie's knowledge."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/see
	word2 = /datum/cultword/blood
	word3 = /datum/cultword/hell
	invocation = "N'ath reth sh'yro eth d'raggathnor!"

//RUNE IV
/datum/rune_spell/conjuretalisman
	name = "Conjure Talisman"
	description = "Can turn some runes into talismans."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/join
	invocation = "H'drak v'loso, mir'kanas verbot!"

//RUNE V
/datum/rune_spell/conversion
	name = "Conversion"
	description = "Open the eyes of the unbelievers."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/join
	word2 = /datum/cultword/blood
	word3 = /datum/cultword/self
	invocation = "Mah'weyh pleggh at e'ntrath!"

//RUNE VI
/datum/rune_spell/stun
	name = "Stun"
	description = "Overwhelm your victim's senses with pure energy so they become catatonic for a moment."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/join
	word2 = /datum/cultword/hide
	word3 = /datum/cultword/technology
	invocation = "Fuu ma'jin!"

//RUNE VII
/datum/rune_spell/blind
	name = "Blind"
	description = "Get the edge over nearby enemies by removing their senses."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/destroy
	word2 = /datum/cultword/see
	word3 = /datum/cultword/other
	invocation = "Sti' kaliesin!"

//RUNE VIII
/datum/rune_spell/mute
	name = "Mute"
	description = "Silence and deafen nearby enemies."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/hide
	word2 = /datum/cultword/other
	word3 = /datum/cultword/see
	invocation = "Sti' kaliedir!"

//RUNE IX
/datum/rune_spell/hide
	name = "Hide"
	description = "Hide runes, blood stains, corpses, structures, and other compromising items."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/hide
	word2 = /datum/cultword/see
	word3 = /datum/cultword/blood
	invocation = "Kla'atu barada nikt'o!"

//RUNE X
/datum/rune_spell/reveal
	name = "Reveal"
	description = "Reveal what you have previously hidden."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/blood
	word2 = /datum/cultword/see
	word3 = /datum/cultword/hide
	invocation = "Nikt'o barada kla'atu!"

//RUNE XI
/datum/rune_spell/seer
	name = "Seer"
	description = "See the invisible, the dead, hear their voice."
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/see
	word2 = /datum/cultword/hell
	word3 = /datum/cultword/join
	invocation = "Rash'tla sektath mal'zua. Zasan therium viortia."

//RUNE XII
/datum/rune_spell/summonrobes
	name = "Summon Robes"
	description = "Wear the robes of those who follow Nar-Sie."
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/destroy
	word3 = /datum/cultword/other
	invocation = "Sa tatha najin"

//RUNE XIII
/datum/rune_spell/door
	name = "Door"
	description = "More obstacles for your enemies to overcome."
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/destroy
	word2 = /datum/cultword/travel
	word3 = /datum/cultword/self
	invocation = "Khari'd! Eske'te tannin!"

//RUNE XIV
/datum/rune_spell/fervor
	name = "Fervor"
	description = "Inspire nearby cultists to purge their stuns and raise their movement speed."
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/other
	invocation = "Khari'd! Gual'te nikka!"

//RUNE XV
/datum/rune_spell/summoncultist
	name = "Summon Cultist"
	description = "Bring forth one of your fellow believers, no matter how far they are, as long as their heart beats"
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/join
	word2 = /datum/cultword/other
	word3 = /datum/cultword/self
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"

//RUNE XVI
/datum/rune_spell/portalentrance
	name = "Portal Entrance"
	description = "Take a shortcut through the veil between this world and the other one."
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/self
	teleporter = 1
	invocation = "Sas'so c'arta forbici!"

/datum/rune_spell/teleportentrance/New(var/mob/user, var/obj/holder, var/datum/cultword/w3)
	..()
	word3 = w3.type

//RUNE XVII
/datum/rune_spell/portalexit
	name = "Portal Exit"
	description = "We hope you enjoyed your flight with Air Nar-Sie"//might change it later or not.
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/other
	teleporter = 1

/datum/rune_spell/teleportexit/New(var/mob/user, var/obj/holder, var/datum/cultword/w3)
	..()
	word3 = w3.type

//RUNE XVIII
/datum/rune_spell/pulse
	name = "Pulse"
	description = "Scramble the circuits of nearby devices"
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/destroy
	word2 = /datum/cultword/see
	word3 = /datum/cultword/technology
	invocation = "Ta'gh fara'qha fel d'amar det!"

//RUNE XIX
/datum/rune_spell/astraljourney
	name = "Astral Journey"
	description = "Leave your body so you can converse with the dead and observe your targets."
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/travel
	word3 = /datum/cultword/self
	invocation = "Fwe'sh mah erl nyag r'ya!"

//RUNE XX
/datum/rune_spell/resurrect
	name = "Resurrect"
	description = "Create a strong body for your fallen allies to inhabit."
	Act_restriction = CULT_ACT_III
	word1 = /datum/cultword/blood
	word2 = /datum/cultword/join
	word3 = /datum/cultword/hell
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!"









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
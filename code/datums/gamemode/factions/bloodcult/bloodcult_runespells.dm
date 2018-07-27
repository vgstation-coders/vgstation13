//THE SPELLS PROC'D BY THE RUNES

#define RUNE_STAND	1

/datum/rune_spell
	var/name = "default name"
	var/desc = "default description"
	var/Act_restriction = CULT_PROLOGUE
	var/obj/spell_holder = null//the rune or talisman
	var/mob/activator = null//the original mob that proc'd the spell
	var/datum/cultword/word1 = null
	var/datum/cultword/word2 = null
	var/datum/cultword/word3 = null
	var/teleporter = 0//teleporter runes only need the first two words to be valid
	var/invocation = "Lo'Rem Ip'Sum"
	var/cost_invoke = 0//blood cost upon cast
	var/cost_upkeep = 0//blood cost upon upkeep proc
	var/rune_flags = null //RUNE_STAND
	var/list/contributors = list()//multiple cultists can join a single summoning
	var/image/progbar = null
	var/remaining_cost = 0
	var/accumulated_blood = 0
	var/destroying_self = 0
	var/cancelling = 3
	var/talisman_absorb = RUNE_CAN_IMBUE
	var/page = "Lorem ipsum dolor sit amet, consectetur adipiscing elit,\
			 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\
			  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut\
			   aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\
			    voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint\
			     occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

/datum/rune_spell/New(var/mob/user, var/obj/holder, var/use = "ritual")
	spell_holder = holder
	activator = user

	switch (use)
		if ("ritual")
			pre_cast()

/datum/rune_spell/Destroy()
	destroying_self = 1
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

/datum/rune_spell/proc/pre_cast()
	var/mob/living/user = activator

	if (istype (spell_holder,/obj/effect/rune))
		if ((rune_flags & RUNE_STAND) && (user.loc != spell_holder.loc))
			abort("too far")
		else
			user.say(invocation,"C")
			cast()
	else if (istype (spell_holder,/obj/item/weapon/talisman))
		user.whisper(invocation)
		cast_talisman()

/datum/rune_spell/proc/midcast(var/mob/add_cultist)
	return

/datum/rune_spell/proc/cast_talisman(var/mob/user, var/mob/target)
	cast()//by default, talismans work just like runes, but may be set to work differently.

/datum/rune_spell/proc/cast()
	spell_holder.visible_message("<span class='warning'>This rune wasn't properly set up, tell a coder.</span>")
	qdel(src)

/datum/rune_spell/proc/abort(var/cause = "erased")
	switch (cause)
		if ("erased")
			if (istype (spell_holder,/obj/effect/rune))
				spell_holder.visible_message("<span class='warning'>The rune's destruction ended the ritual.</span>")
		if ("too far")
			if (activator)
				to_chat(activator, "<span class='warning'>The [name] ritual requires you to stand on top of the rune.</span>")
		if ("moved away")
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual ends as you move away from the rune.</span>")
		if ("channel cancel")
			spell_holder.visible_message("<span class='warning'>Deprived of blood, the channeling is disrupted.</span>")
		if ("moved talisman")
			spell_holder.visible_message("<span class='warning'>The necessary tools have been misplaced.</span>")

	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)
	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/proc/update_progbar()
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[round((min(1, accumulated_blood / remaining_cost) * 100), 10)]"
	return

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
				if ("imbue")
					return subtype
		else if (word1.type == initial(instance.word1) && word2.type == initial(instance.word2) && word3.type == initial(instance.word3))
			switch (use)
				if ("ritual")
					return new subtype(user, spell_holder, use)
				if ("examine")
					return instance
				if ("imbue")
					return subtype
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
	cost_upkeep = 1
	remaining_cost = 300
	accumulated_blood = 0
	page = "A very greedy rune. very thirsty. Alone, the ritual will be long and exhausting. With others, it will be quick and effortless. \
	 Nevertheless, an essential rune, for the cult needs an altar where to commune with Nar-Sie, and perform the Sacrifice when the time has come. \
	 As the veil thins and the blood flows, the altar will allow the cultists to perform new rituals, namely, the exchange of blood, for a shard of the Soulstone. \
	 You may use them to trap the souls of defeated foes, or channel those the dead. You can make even better use of them after raising a forge, and placing them \
	 inside a Construct Shell, or a Cult Blade. Lastly, raising an Arcaneum will let you permanently imbue your skin with a gift from Nar Sie. Follow your purpose \
	 and you may see even more gifts come your way."

/datum/rune_spell/raisestructure/cast()
	var/mob/living/user = activator
	contributors.Add(user)
	update_progbar()
	if (user.client)
		user.client.images |= progbar
	spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
	to_chat(activator, "<span class='rose'>This ritual's blood toll can be substantially reduced by having multiple cultists partake in it.</span>")
	spawn()
		payment()

/datum/rune_spell/raisestructure/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/raisestructure/midcast(var/mob/add_cultist)
	if (add_cultist in contributors)
		return
	add_cultist.say(invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/raisestructure/abort(var/cause = "erased")
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	..()

/datum/rune_spell/raisestructure/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		var/summoners = 0
		for(var/mob/living/L in contributors)
			if (iscultist(L) && (L in range(spell_holder,1)) && (L.stat == CONSCIOUS))
				summoners++
			else
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep,contributors[L])
			if (data["result"] == "failure")//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data["total"]
				contributors[L] = data["result"]
				make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				if(accumulated_blood && !(locate(/obj/effect/decal/cleanable/blood/splatter) in spell_holder.loc))
					var/obj/effect/decal/cleanable/blood/splatter/S = new(spell_holder.loc)//splash
					S.amount = 2
				abort("channel cancel")
				return

		//do we have multiple cultists? let's reward their cooperation
		switch(summoners)
			if (1)
				remaining_cost = 300
			if (2)
				remaining_cost = 120
			if (3)
				remaining_cost = 18
			if (4 to INFINITY)
				remaining_cost = 0


		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/raisestructure/proc/success()
	new /obj/structure/cult/altar(spell_holder.loc)
	qdel(spell_holder)//this will cause this datum to del as well

//RUNE II
/datum/rune_spell/communication
	name = "Communication"
	desc = "Speak so that every cultists may hear your voice."
	Act_restriction = CULT_PROLOGUE
	invocation = "O bidai nabora se'sma!"
	rune_flags = RUNE_STAND
	var/obj/effect/cult_ritual/cult_communication/comms = null
	word1 = /datum/cultword/self
	word2 = /datum/cultword/other
	word3 = /datum/cultword/technology
	page = "You are not alone. Never forget it. The cult's true strength lies in its numbers, and how well each individual cooperates with the rest. \
		This rune is your main mean of cooperation. Its ritual lets you open a communication channel straight into the mind of every other cultists, \
		including constructs and soul blades. Just speak, and your words will instantly reach their minds. Keep the cult updated on your activities."

/datum/rune_spell/communication/cast()
	var/mob/living/user = activator
	comms = new /obj/effect/cult_ritual/cult_communication(spell_holder.loc,user,src)

/datum/rune_spell/communication/cast_talisman()//we write our message on the talisman, like in previous versions.
	var/message = sanitize(input("Write a message to send to your acolytes.", "Blood Letter", "") as null|message, MAX_MESSAGE_LEN)
	if(!message)
		return

	var/datum/faction/bloodcult = find_active_faction(BLOODCULT)
	for(var/datum/mind/M in bloodcult.members)
		to_chat(M.current, "<span class='game say'><b>[activator.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[message]</span></B></span>")

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[activator.real_name]</b> communicates, <span class='sinister'>[message]</span></span>")

	log_cultspeak("[key_name(activator)] Cult Communicate Talisman: [message]")

	qdel(src)

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


/obj/effect/cult_ritual/cult_communication/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/communication/runespell)
	..()
	caster = user
	source = runespell

/obj/effect/cult_ritual/cult_communication/Destroy()
	caster = null
	source = null
	..()

/obj/effect/cult_ritual/cult_communication/Hear(var/datum/speech/speech, var/rendered_message="")
	if(speech.speaker && speech.speaker.loc == loc)
		var/speaker_name = speech.speaker.name
		if (isliving(speech.speaker))
			var/mob/living/L = speech.speaker
			if (!iscultist(L))//geez we don't want that now do we
				return
		if (ishuman(speech.speaker))
			var/mob/living/carbon/human/H = speech.speaker
			speaker_name = H.real_name
		rendered_message = speech.render_message()
		var/datum/faction/bloodcult = find_active_faction(BLOODCULT)
		for(var/datum/mind/M in bloodcult.members)
			if (M.current == speech.speaker)//echoes are annoying
				continue
			to_chat(M.current, "<span class='game say'><b>[speaker_name]</b>'s voice echoes in your head, <B><span class='sinister'>[speech.message]</span></B></span>")
		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><b>[speaker_name]</b> communicates, <span class='sinister'>[speech.message]</span></span>")
		log_cultspeak("[key_name(speech.speaker)] Cult Communicate Rune: [rendered_message]")

/obj/effect/cult_ritual/cult_communication/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		if (source)
			source.abort("moved away")
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
	cost_invoke = 4
	page = "Knowledge is of the essence. Becoming useful to the cult isn't simple, but having a desire to learn and improve is the first step. \
		This rune is the first step on this journey, you don't have to study all the runes right away but the answer to your current conundrum could be in one of them. \
		The tome in your hands is the produce of this ritual, by having it open in your hands, the meaning of every rune can freely flow into your mind, \
		which means that you can trace them more easily. Be mindful though, if anyone spots this tome in your hand, your devotion to Nar-Sie will be immediately exposed."

/datum/rune_spell/summontome/cast()
	spell_holder.visible_message("<span class='rose'>The rune's symbols merge into each others, and an Arcane Tome takes form in their place</span>")
	var/turf/T = get_turf(spell_holder)
	var/obj/item/weapon/tome/AT = new (T)
	anim(target = AT, a_icon = 'icons/effects/effects.dmi', flick_anim = "tome_spawn")
	qdel(spell_holder)

/datum/rune_spell/summontome/cast_talisman()//The talisman simply turns into a tome.
	var/turf/T = get_turf(spell_holder)
	var/obj/item/weapon/tome/AT = new (T)
	if (spell_holder == activator.get_active_hand())
		activator.drop_item(spell_holder, T)
		activator.put_in_active_hand(AT)
	else//are we using the talisman from a tome?
		activator.put_in_hands(AT)
	flick("tome_spawn",AT)
	qdel(src)

//RUNE IV
/datum/rune_spell/conjuretalisman
	name = "Conjure Talisman"
	desc = "Can turn some runes into talismans."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	Act_restriction = CULT_ACT_I
	word1 = /datum/cultword/hell
	word2 = /datum/cultword/technology
	word3 = /datum/cultword/join
	cost_invoke = 2
	cost_upkeep = 1
	remaining_cost = 5
	talisman_absorb = RUNE_CANNOT
	var/obj/item/weapon/tome/target = null
	var/obj/item/weapon/talisman/tool = null
	page = "Runes are powerful, but they're not always convenient. They require time to be set up, cannot be moved, and more importantly, are highly visible, unless hidden, \
		which would require additional preparation. With that in mind, cultists need an alternative to use their powers reliably. This rune provides that alternative in the form \
		of talismans. Created in exchange of a drop of blood, these sheets can absorb a rune, and then be used to channel its power. They're easy to conceal until used, and can be stored \
		inside an arcane tome however most talismans are weaker than the rune they're imbued from. Exceptions exist, as the Stun rune which becomes much more potent when used directly in contact with a target. \
		Other exceptions are the Door, Portal Entrance, and Conversion runes which will be attuned with the talisman instead of absorbed, allowing them to be triggered remotely, and also \
		the Portal Exit rune, which can be used to immediately jaunt toward the Exit it was attuned to. One last use for this rune, is a ritual allowing a talisman to be transmitted directly \
		inside an arcane tome carried by a fellow cultist. The ritual takes a bit of time and blood, but can save your acolyte some precious time."


/datum/rune_spell/conjuretalisman/cast()
	var/obj/item/weapon/talisman/AT = locate() in get_turf(spell_holder)
	if (AT)
		if (AT.spell_type)
			var/mob/living/user = activator
			var/list/valid_tomes = list()
			var/i = 0
			for (var/obj/item/weapon/tome/T in arcane_tomes)
				i++
				var/mob/M = T.loc
				if (!M)	continue
				if (!istype(M))
					M = M.loc
				if (!istype(M))
					M = M.loc
				if (!istype(M))
					continue
				else
					valid_tomes["[i] - Tome carried by [M.real_name] ([T.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = T
			if (valid_tomes.len <= 0)
				to_chat(user, "<span class='warning'>No cultists are currently carrying a tome.</span>")
				qdel(src)
				return

			var/datum/rune_spell/spell = AT.spell_type
			var/chosen_tome = input(user,"Choose a tome where to transfer this [initial(spell.name)] talisman.", "Transfer talisman", null) as null|anything in valid_tomes
			if (!chosen_tome)
				qdel(src)
				return

			target = valid_tomes[chosen_tome]
			tool = AT

			if (target.talismans.len >= MAX_TALISMAN_PER_TOME)
				to_chat(activator, "<span class='warning'>This tome cannot contain any more talismans.</span>")
				abort("no room")

			contributors.Add(user)
			update_progbar()
			if (user.client)
				user.client.images |= progbar
			spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
			spawn()
				payment()
		else
			to_chat(activator, "<span class='warning'>You may only transfer an imbued or attuned talisman.</span>")
	else
		spell_holder.visible_message("<span class='rose'>The blood drops merge into each others, and a talisman takes form in their place</span>")
		var/turf/T = get_turf(spell_holder)
		AT = new (T)
		anim(target = AT, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_imbue")
		qdel(src)

/datum/rune_spell/conjuretalisman/abort(var/cause = "erased")
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	..()

/datum/rune_spell/conjuretalisman/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++

		if (tool && tool.loc != spell_holder.loc)
			abort("moved talisman")

		//are our payers still here and about?
		for(var/mob/living/L in contributors)
			if (!iscultist(L) || !(L in range(spell_holder,1)) || (L.stat != CONSCIOUS))
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep,contributors[L])
			if (data["result"] == "failure")//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data["total"]
				contributors[L] = data["result"]
				make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				abort("channel cancel")
				return


		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/conjuretalisman/proc/success()
	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)
	if (progbar)
		progbar.loc = null
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")

	if (target.talismans.len < MAX_TALISMAN_PER_TOME)
		target.talismans.Add(tool)
		tool.forceMove(target)
		to_chat(activator, "<span class='notice'>You slip \the [tool] into \the [target].</span>")
		if (target.state == TOME_OPEN && ismob(target.loc))
			var/mob/M = target.loc
			M << browse_rsc('icons/tomebg.png', "tomebg.png")
			M << browse(target.tome_text(), "window=arcanetome;size=512x375")
	else
		to_chat(activator, "<span class='warning'>This tome cannot contain any more talismans.</span>")
	qdel(src)

//RUNE V
/datum/rune_spell/conversion
	name = "Conversion"
	desc = "Open the eyes of the unbelievers."
	Act_restriction = CULT_ACT_I
	invocation = "Mah'weyh pleggh at e'ntrath!"
	word1 = /datum/cultword/join
	word2 = /datum/cultword/blood
	word3 = /datum/cultword/self
	talisman_absorb = RUNE_CAN_ATTUNE

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
	name = "Deaf-Mute"
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
	talisman_absorb = RUNE_CAN_ATTUNE

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
	teleporter = 1
	talisman_absorb = RUNE_CAN_ATTUNE

/datum/rune_spell/portalentrance/New(var/mob/user, var/obj/holder, var/datum/cultword/w3)
	..()
	if (w3)
		word3 = w3.type

//RUNE XVII
/datum/rune_spell/portalexit
	name = "Portal Exit"
	desc = "We hope you enjoyed your flight with Air Nar-Sie"//might change it later or not.
	Act_restriction = CULT_ACT_II
	word1 = /datum/cultword/travel
	word2 = /datum/cultword/other
	teleporter = 1
	talisman_absorb = RUNE_CAN_ATTUNE

/datum/rune_spell/portalexit/New(var/mob/user, var/obj/holder, var/datum/cultword/w3)
	..()
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

#undef RUNE_STAND
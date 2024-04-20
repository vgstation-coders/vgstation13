

//Returns a rune spell based on the given 3 words.
/proc/get_rune_spell(var/mob/user, var/obj/spell_holder, var/use = "ritual", var/datum/rune_word/word1, var/datum/rune_word/word2, var/datum/rune_word/word3)
	if(!word1 || !word2 || !word3)
		return
	for(var/subtype in subtypesof(/datum/rune_spell))
		var/datum/rune_spell/instance = subtype
		if(word1.type == initial(instance.word1) && word2.type == initial(instance.word2) && word3.type == initial(instance.word3))
			switch (use)
				if ("ritual")
					return new subtype(user, spell_holder, use)
				if ("examine")
					return instance
				if ("walk")
					if (initial(instance.walk_effect))
						return new subtype(user, spell_holder, use)
					else
						return null
				if ("imbue")
					return subtype
			return new subtype(user, spell_holder, use)
	return null


/datum/rune_spell
	var/secret = FALSE						// When set to true, this spell will not appear in the list of runes, when using the "Draw Rune with a Guide" button.
	var/name = "rune spell"					// The spell's name.
	var/desc = "you shouldn't be reading this."   			// Appears to cultists when examining a rune that triggers this spell
	var/desc_talisman = "you shouldn't be reading this."  	// Appears to cultists when examining a taslisman that triggers this spell
	var/obj/spell_holder = null				//The rune or talisman calling the spell. If using a talisman calling an attuned rune, the holder is the rune.
	var/mob/activator = null				//The original mob that cast the spell
	var/datum/rune_word/word1 = null
	var/datum/rune_word/word2 = null
	var/datum/rune_word/word3 = null
	var/invocation = "Lo'Rem Ip'Sum"		//Spoken whenever cast.
	var/touch_cast = 0			//If set to 1, will proc cast_touch() when touching someone with an imbued talisman (example: Stun)
	var/can_conceal = 0			//If set to 1, concealing the rune will not abort the spell. (example: Path Exit)
	var/rune_flags = null 		//If set to RUNE_STAND (or 1), the user will need to stand right above the rune to use cast the spell
	var/walk_effect = 0 //If set to 1, procs Added() when step over
	var/custom_rune	= FALSE // Prevents the rune's normal UpdateIcon() from firing.

	//Optional (These vars aren't used by default rune code, but many runes make use of them, so set them up as you need, the comments below are suggestions)
	var/cost_invoke = 0						//Blood cost upon cast
	var/cost_upkeep = 0						//Blood cost upon upkeep proc
	var/list/contributors = list()			//List of people currently participating in the ritual
	var/remaining_cost = 0					//How much blood to gather for the ritual to succeed
	var/accumulated_blood = 0				//How much blood has been gathered so far
	var/cancelling = 3						//Check this variable to abort the ritual due to blood flow being interrupted
	var/list/ingredients = list()			//Items that should be on the rune for it to work
	var/list/ingredients_found = list()		//Items that are found on the rune

	var/destroying_self = 0		//Sanity var to prevent abort loops, ignore
	var/image/progbar = null	//Bar for channeling spells

	var/talisman_absorb = RUNE_CAN_IMBUE	//Whether the rune is absorbed into the talisman (and thus deleted), or linked to the talisman (RUNE_CAN_ATTUNE)
	var/talisman_uses = 1					//How many times can a spell be cast from a single talisman. The talisman disappears upon the last use.

	var/page = "Lorem ipsum dolor sit amet, consectetur adipiscing elit,\
			 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\
			  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut\
			   aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\
			    voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint\
			     occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." //Arcane tome page description.

/datum/rune_spell/New(var/mob/user, var/obj/holder, var/use = "ritual", var/mob/target)
	spell_holder = holder
	activator = user

	if(use == "ritual")
		pre_cast()
	else if(use == "touch" && target)
		cast_touch(target) //Skips pre_cast() for talismans)


/datum/rune_spell/Destroy()
	destroying_self = 1
	if(spell_holder)
		if(istype(spell_holder, /obj/effect/rune))
			var/obj/effect/rune/rune_holder = spell_holder
			rune_holder.active_spell = null
		spell_holder = null
	word1 = null
	word2 = null
	word3 = null
	activator = null
	..()

/datum/rune_spell/proc/invoke(var/mob/user, var/text="", var/whisper=0)
	if(user.checkTattoo(TATTOO_SILENT) || (spell_holder.icon_state == "temp"))
		return
	if(!whisper)
		user.say(text,"C")
	else
		user.whisper(text)

/datum/rune_spell/proc/pre_cast()
	if(istype(spell_holder,/obj/effect/rune))
		var/obj/effect/rune/R = spell_holder
		R.activated++
		R.update_icon()
		if (R.word1)// "invisible" temporary runes spawned by some talismans shouldn't display those
			R.cast_word(R.word1.english)
			R.cast_word(R.word2.english)
			R.cast_word(R.word3.english)
		if((rune_flags & RUNE_STAND) && (get_turf(activator) != get_turf(spell_holder)))
			abort(RITUALABORT_STAND)
		else
			invoke(activator,invocation)
			cast()
	else if(istype (spell_holder,/obj/item/weapon/talisman))
		invoke(activator,invocation,1)//talisman incantations are whispered
		cast_talisman()

/datum/rune_spell/proc/pay_blood()
	var/data = use_available_blood(activator, cost_invoke)
	if(data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
		to_chat(activator, "<span class='warning'>This ritual requires more blood than you can offer.</span>")
		return 0
	else
		return 1

/datum/rune_spell/proc/Added(var/mob/M)

/datum/rune_spell/proc/Removed(var/mob/M)

/datum/rune_spell/proc/midcast(var/mob/add_cultist)
	return

/datum/rune_spell/proc/cast() //Override for your spell functionality.
	spell_holder.visible_message("<span class='warning'>This rune wasn't properly set up, tell a coder.</span>")
	qdel(src)

/datum/rune_spell/proc/abort(var/cause) //The error message for aborting, usable by any runeset.
	if(destroying_self)
		return
	destroying_self = 1
	switch(cause)
		if (RITUALABORT_ERASED)
			if (istype (spell_holder,/obj/effect/rune))
				spell_holder.visible_message("<span class='warning'>The rune's destruction ended the ritual.</span>")
		if (RITUALABORT_STAND)
			if (activator)
				to_chat(activator, "<span class='warning'>The [name] ritual requires you to stand on top of the rune.</span>")
		if (RITUALABORT_GONE)
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual ends as you move away from the rune.</span>")
		if (RITUALABORT_BLOCKED)
			if (activator)
				to_chat(activator, "<span class='warning'>There is a building blocking the ritual..</span>")
		if (RITUALABORT_BLOOD)
			spell_holder.visible_message("<span class='warning'>Deprived of blood, the channeling is disrupted.</span>")
		if (RITUALABORT_TOOLS)
			if (activator)
				to_chat(activator, "<span class='warning'>The necessary tools have been misplaced.</span>")
		if (RITUALABORT_TOOLS)
			spell_holder.visible_message("<span class='warning'>The ritual ends as the victim gets pulled away from the rune.</span>")
		if (RITUALABORT_CONVERT)
			if (activator)
				to_chat(activator, "<span class='notice'>The conversion ritual successfully brought a new member to the cult. Inform them of the current situation so they can take action.</span>")
		if (RITUALABORT_REFUSED)
			if (activator)
				to_chat(activator, "<span class='notice'>The conversion ritual ended with the target being restrained by some eldritch contraption. Deal with them how you see fit so their life may serve our plans.</span>")
		if (RITUALABORT_NOCHOICE)
			if (activator)
				to_chat(activator, "<span class='notice'>The target never manifested any clear reaction to the ritual. As such they were automatically restrained.</span>")
		if (RITUALABORT_SACRIFICE)
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual ends leaving behind nothing but a creepy chest, filled with your lost soul's belongings.</span>")
		if (RITUALABORT_CONCEAL)
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual is disrupted by the rune's sudden phasing out.</span>")
		if (RITUALABORT_NEAR)
			if (activator)
				to_chat(activator, "<span class='warning'>You cannot perform this ritual that close from another similar structure.</span>")
		if (RITUALABORT_OVERCROWDED)
			if (activator)
				to_chat(activator, "<span class='warning'>There are too many human cultists and constructs already.</span>")

	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if ((HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]") in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"]
		holomarker.id = HOLOMAP_MARKER_CULT_RUNE
		holomarker.color = null
		holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"] = holomarker

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/proc/salt_act(var/turf/T)
	return

/datum/rune_spell/proc/missing_ingredients_count()
	var/list/missing_ingredients = ingredients.Copy()
	var/turf/T = get_turf(spell_holder)
	for (var/path in missing_ingredients)
		var/atom/A = locate(path) in T
		if (A)
			missing_ingredients -= path
			ingredients_found += A

	if (missing_ingredients.len > 0)
		var/missing = "You need "
		var/i = 1
		for (var/I in missing_ingredients)
			i++
			var/atom/A = I
			missing += "\a [initial(A.name)]"
			if (i <= missing_ingredients.len)
				missing += ", "
				if (i == missing_ingredients.len)
					missing += "and "
			else
				missing += "."
		to_chat(activator, "<span class='warning'>The necessary ingredients for this ritual are missing. [missing]</span>")
		abort(RITUALABORT_MISSING)
		return 1
	return 0

/datum/rune_spell/proc/update_progbar()
	if(!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[round((min(1, accumulated_blood / remaining_cost) * 100), 10)]"
	return

/datum/rune_spell/proc/cast_talisman() //Override for unique talisman behavior.
	cast()

/datum/rune_spell/proc/cast_touch(var/mob/M) //Behavior on using the talisman on somebody. See - stun talisman.
	return

/datum/rune_spell/proc/midcast_talisman(var/mob/add_cultist)
	return



////////////////////////////////////////////////////////////////////
//																  //
//							RAISE STRUCTURE						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/raisestructure
	name = "Raise Structure"
	desc = "Drag-in eldritch structures from the realm of Nar-Sie."
	desc_talisman = "Use to begin raising a structure where you stand."
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/join
	cost_upkeep = 1
	remaining_cost = 300
	accumulated_blood = 0
	page = "Channel this rune to create either an Altar, a Forge, or a Spire. You can speed up the ritual by having other cultist touch the rune, or by wearing cult garments. \
		<br><br>Altars let you commune with Nar-Sie, conjure soul gems, and keep tabs on the cult's members and activities over the station.\
		<br><br>Forges let you craft armors, powerful blades, as well as construct shells. Blades and shells can be combined with soul gems to great effect, \
		but note that Forges tend to sear those who stay near them too long. You can mitigate the effect with cult apparel, or use the Fervor rune to reset your temperature.\
		<br><br>Spires provide easy communication for the cult in the entire region. Use :x (or .x, or #x) to use cult chat after one is built."
	var/turf/loc_memory = null
	var/spawntype = /obj/structure/cult/altar

/datum/rune_spell/raisestructure/proc/proximity_check()
	var/obj/effect/rune/R = spell_holder
	if (locate(/obj/structure/cult) in range(R.loc,0))
		abort(RITUALABORT_BLOCKED)
		return FALSE

	if (locate(/obj/machinery/door/mineral/cult) in range(R.loc,1))
		abort(RITUALABORT_NEAR)
		return FALSE

	else return TRUE

/datum/rune_spell/raisestructure/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	var/mob/living/user = activator

	proximity_check() //See above

	var/list/choices = list(
		list("Altar", "radial_altar", "The nexus of a cult base. Lets you commune with Nar-Sie, conjure soul gems, and keep tabs on the cult's members and activities over the station."),
		list("Spire", "radial_spire", "Allows all cultists in the level to communicate with each others using :x"),
		list("Forge", "radial_forge", "Can be used to forge of cult blades and armor, as well as construct shells. Standing close for too long without proper cult attire can be a searing experience."),
		list("Pylon", "radial_pylon", "Provides some light in the surrounding area, and has some use in rituals.")
	)
	var/structure = show_radial_menu(user,R.loc,choices,'icons/obj/cult_radial3.dmi',"radial-cult")

	if(!R.Adjacent(user) || !structure )
		abort()
		return

	if(R.active_spell)
		to_chat(user, "<span class='rose'>A structure is already being raised from this rune, so you contribute to that instead.</span>")
		R.active_spell.midcast(user)
		return

	switch(structure)
		if("Altar")
			spawntype = /obj/structure/cult/altar
		if("Spire")
			spawntype = /obj/structure/cult/spire
		if("Forge")
			spawntype = /obj/structure/cult/forge
		if("Pylon")
			spawntype = /obj/structure/cult/pylon

	if(!spell_holder)
		return
	loc_memory = spell_holder.loc
	contributors.Add(user)
	update_progbar()
	if(user.client)
		user.client.images |= progbar
	spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
	to_chat(activator, "<span class='rose'>This ritual's can be sped up by having multiple cultists partake in it or by wearing cult attire.</span>")
	spawn()
		payment()

/datum/rune_spell/raisestructure/cast_talisman() //Raise structure talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/raisestructure/midcast(var/mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/raisestructure/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	..()

/datum/rune_spell/raisestructure/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		var/summoners = 2//the higher, the easier it is to perform the ritual without many cultists. default=2
		for(var/mob/living/L in contributors)
			if (iscultist(L) && (L in range(spell_holder,1)) && (L.stat == CONSCIOUS))
				summoners++
				summoners += round(L.get_cult_power()/30)	//For every 30 cult power, you count as one additional cultist. So with Robes and Shoes, you already count as 3 cultists.
			else											//This makes using the rune alone hard at roundstart, but fairly easy later on.
				if (L.client)
					L.client.images -= progbar
				contributors.Remove(L)
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep,contributors[L])
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
				make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		if(amount_paid) //3 seconds without blood and the ritual fails.
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				if(accumulated_blood && !(locate(/obj/effect/decal/cleanable/blood/splatter) in loc_memory))
					var/obj/effect/decal/cleanable/blood/splatter/S = new (loc_memory)//splash
					S.amount = 2
				abort(RITUALABORT_BLOOD)
				return

		switch(summoners)
			if (1)
				remaining_cost = 300
			if (2)
				remaining_cost = 120
			if (3)
				remaining_cost = 18
			if (4 to INFINITY)
				remaining_cost = 0

		if(accumulated_blood >= remaining_cost )
			proximity_check()
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/raisestructure/proc/success()
	new spawntype(spell_holder.loc)
	qdel(spell_holder) //Deletes the datum as well.

////////////////////////////////////////////////////////////////////
//																  //
//							COMMUNICATION						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/communication
	name = "Communication"
	desc = "Speak so that every cultists may hear your voice. Can be used even when there is no spire nearby."
	desc_talisman = "Use it to write and send a message to all followers of Nar-Sie. When in the middle of a ritual, use it again to transmit a message that will be remembered by all."
	invocation = "O bidai nabora se'sma!"
	rune_flags = RUNE_STAND
	talisman_uses = 10
	var/obj/effect/cult_ritual/cult_communication/comms = null
	word1 = /datum/rune_word/self
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/technology
	page = "By standing on top of the rune and touching it, everyone in the cult will then be able to hear what you say or whisper. \
		You will also systematically speak in the language of the cult when using it.\
		<br><br>Talismans imbued with this rune can be used 10 times to send messages to the rest of the cult.\
		<br><br>Lastly touching the rune a second time while you are already using it lets you set cult reminders that will be heard by newly converts and added to their notes.\
		<br><br>This rune persists upon use, allowing repeated usage."

/datum/rune_spell/communication/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()
	var/mob/living/user = activator
	comms = new /obj/effect/cult_ritual/cult_communication(spell_holder.loc,user,src)

/datum/rune_spell/communication/midcast(var/mob/living/user)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!istype(cult))
		return
	if (!istype(user)) // Ghosts
		return
	var/reminder = input("Write the reminder.", text("Cult reminder")) as null | message
	if (!reminder)
		return
	reminder = strip_html_simple(reminder) // No weird HTML
	var/number = cult.cult_reminders.len
	var/text = "[number + 1]) [reminder], by [user.real_name]."
	cult.cult_reminders += text
	for(var/datum/role/cultist/C in cult.members)
		var/datum/mind/M = C.antag
		if (iscultist(M.current))//failsafe for cultist brains put in MMIs
			to_chat(M.current, "<span class='game say'><b>[user.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[reminder]</span></span>")
			to_chat(M.current, "<span class='notice'>This message will be remembered by all current cultists, and by new converts as well.</span>")
			M.store_memory("Cult reminder: [text].")

	for(var/mob/living/simple_animal/astral_projection/A in astral_projections)
		to_chat(A, "<span class='game say'><b>[user.real_name]</b> communicates, <span class='sinister'>[reminder]</span></span>. (Cult reminder)")
		to_chat(A, "<span class='notice'>This message will be remembered by all current cultists, and by new converts as well.</span>")

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[user.real_name]</b> communicates, <span class='sinister'>[reminder]</span></span>. (Cult reminder)")

	log_cultspeak("[key_name(user)] Cult reminder: [reminder]")

/datum/rune_spell/communication/cast_talisman()//we write our message on the talisman, like in previous versions.
	var/message = sanitize(input("Write a message to send to your acolytes.", "Blood Letter", "") as null|message, MAX_MESSAGE_LEN)
	if(!message)
		return

	var/datum/faction/bloodcult = find_active_faction_by_member(iscultist(activator))
	for(var/datum/role/cultist/C in bloodcult.members)
		var/datum/mind/M = C.antag
		if (iscultist(M.current))//failsafe for cultist brains put in MMIs
			to_chat(M.current, "<span class='game say'><b>[activator.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[message]</span></B></span>")

	for(var/mob/living/simple_animal/astral_projection/A in astral_projections)
		to_chat(A, "<span class='game say'><b>[activator.real_name]</b> communicates, <span class='sinister'>[message]</span></span>")

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[activator.real_name]</b> communicates, <span class='sinister'>[message]</span></span>")

	log_cultspeak("[key_name(activator)] Cult Communicate Talisman: [message]")

	qdel(src)

/datum/rune_spell/communication/Destroy()
	destroying_self = 1
	if (comms)
		qdel(comms)
	comms = null
	..()

/obj/effect/cult_ritual/cult_communication
	anchored = 1
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
		var/mob/living/L
		if (isliving(speech.speaker))
			L = speech.speaker
			if (!iscultist(L))//geez we don't want that now do we
				return
		if (ishuman(speech.speaker))
			var/mob/living/carbon/human/H = speech.speaker
			speaker_name = H.real_name
			L = speech.speaker
		rendered_message = speech.render_message()
		var/datum/faction/bloodcult = find_active_faction_by_member(iscultist(L))
		for(var/datum/role/cultist/C in bloodcult.members)
			var/datum/mind/M = C.antag
			if (M.current == speech.speaker)//echoes are annoying
				continue
			if (iscultist(M.current))//failsafe for cultist brains put in MMIs
				to_chat(M.current, "<span class='game say'><b>[speaker_name]</b>'s voice echoes in your head, <B><span class='sinister'>[speech.message]</span></B></span>")
		for(var/mob/living/simple_animal/astral_projection/A in astral_projections)
			to_chat(A, "<span class='game say'><b>[speaker_name]</b> communicates, <span class='sinister'>[speech.message]</span></span>")
		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><b>[speaker_name]</b> communicates, <span class='sinister'>[speech.message]</span></span>")
		log_cultspeak("[key_name(speech.speaker)] Cult Communicate Rune: [rendered_message]")

/obj/effect/cult_ritual/cult_communication/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)

////////////////////////////////////////////////////////////////////
//																  //
//							Paraphernalia						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/paraphernalia
	name = "Paraphernalia"
	desc = "Produce various apparatus such as talismans."
	desc_talisman = "LIKE, HOW, NO SERIOUSLY CALL AN ADMIN."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/join
	cost_invoke = 2
	cost_upkeep = 1
	remaining_cost = 5
	talisman_absorb = RUNE_CANNOT
	var/obj/item/weapon/tome/target = null
	var/obj/item/weapon/talisman/tool = null
	page = "This rune lets you conjure occult items carefully crafted in the realm of Nar-Sie, such as the tome you are currently holding, or talismans that let you carry a rune's power in your pocket.\
		<br><br>Each conjured item takes a small drop of your blood so be sure to manage yourself.\
		<br><br>Once you've imbued a rune into a talisman, you can then place the talisman back on top of this rune and activate it again to send it to one of your fellow cultist's arcane tome should they carry one.\
		<br><br>This rune persists upon use, allowing repeated usage."


/datum/rune_spell/paraphernalia/cast()
	var/obj/effect/rune/R = spell_holder
	var/obj/item/weapon/talisman/AT = locate() in get_turf(spell_holder)
	if (AT)
		if (AT.spell_type)
			var/mob/living/user = activator
			var/list/valid_tomes = list()
			var/i = 0
			for (var/obj/item/weapon/tome/T in arcane_tomes)
				var/mob/M = get_holder_of_type(T,/mob/living)
				if (M && iscultist(M))
					i++
					valid_tomes["[i] - Tome carried by [M.real_name] ([T.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = T
			for (var/spell/cult/arcane_dimension/A in arcane_pockets)
				if (A.holder && A.holder.loc && ismob(A.holder) && A.stored_tome)
					i++
					var/mob/M = A.holder
					valid_tomes["[i] - Tome in [M.real_name]'s arcane dimension ([A.stored_tome.talismans.len]/[MAX_TALISMAN_PER_TOME])"] = A.stored_tome
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
				abort(RITUALABORT_FULL)
				return

			R.one_pulse()
			contributors.Add(user)
			update_progbar()
			if (user.client)
				user.client.images |= progbar
			spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
			spawn()
				payment()
		else
			to_chat(activator, "<span class='warning'>You may only transfer an imbued or attuned talisman.</span>")
			qdel(src)
	else
		var/choices = list(
			list("Talisman", "radial_paraphernalia_talisman", "Can absorb runes (or attune to them in some cases), allowing you to carry their power in your pocket. Has a few other miscellaneous uses."),
			list("Blood Candle", "radial_paraphernalia_candle", "A candle that can burn up to a full hour. Offers moody lighting."),
			list("Tempting Goblet", "radial_paraphernalia_goblet", "A classy holder for your beverage of choice. Prank your enemies by hitting them with a goblet full of blood."),
			list("Coffer", "radial_paraphernalia_coffer", "Keep your occult lab orderly by storing your cult paraphernalia in those coffers."),
			list("Ritual Knife", "radial_paraphernalia_knife", "A long time ago a wizard enchanted one of those to infiltrate the realm of Nar-Sie and steal some soul stone shards. Now it's just a cool knife. Don't rely on it in a fight though."),
			list("Arcane Tome", "radial_paraphernalia_tome", "Bring forth an arcane tome filled with Nar-Sie's knowledge. Harmful to the uninitiated in more ways than one. Ghosts can flick their pages."),
			)
		var/task = show_radial_menu(activator,get_turf(spell_holder),choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
		if (!spell_holder.Adjacent(activator) || !task || gcDestroyed)
			qdel(src)
			return
		if (pay_blood())
			R.one_pulse()
			var/obj/spawned_object
			var/turf/T = get_turf(spell_holder)
			switch (task)
				if ("Talisman")
					spawned_object = new /obj/item/weapon/talisman(T)
				if ("Blood Candle")
					spawned_object = new /obj/item/candle/blood(T)
				if ("Tempting Goblet")
					spawned_object = new /obj/item/weapon/reagent_containers/food/drinks/cult(T)
				if ("Coffer")
					spawned_object = new /obj/item/weapon/storage/cult(T)
				if ("Ritual Knife")
					spawned_object = new /obj/item/weapon/kitchen/utensil/knife/large/ritual(T)
				if ("Arcane Tome")
					spawned_object = new /obj/item/weapon/tome(T)
			spell_holder.visible_message("<span class='rose'>The blood drops merge into the rune, and \a [spawned_object] materializes on top.</span>")
			anim(target = spawned_object, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_imbue")
			new /obj/effect/afterimage/black(T,spawned_object)
			qdel(src)


/datum/rune_spell/paraphernalia/midcast(var/mob/add_cultist) // failsafe should someone be hogging the radial menu.
	var/obj/effect/rune/R = spell_holder
	R.active_spell = null
	R.trigger(add_cultist)
	qdel(src)

/datum/rune_spell/paraphernalia/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	..()


/datum/rune_spell/paraphernalia/cast_talisman()//there should be no ways for this to ever proc
	return


/datum/rune_spell/paraphernalia/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++

		if (tool && tool.loc != spell_holder.loc)
			abort(RITUALABORT_TOOLS)

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
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
				make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				abort(RITUALABORT_BLOOD)
				return


		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/paraphernalia/proc/success()
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
			M << browse(target.tome_text(), "window=arcanetome;size=537x375")
	else
		to_chat(activator, "<span class='warning'>This tome cannot contain any more talismans.</span>")
	qdel(src)

var/list/converted_minds = list()

////////////////////////////////////////////////////////////////////
//																  //
//								CONVERSION						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/conversion
	name = "Conversion"
	desc = "The unenlightened will be made humble before Nar-Sie, or their lives will come to a fantastic end."
	desc_talisman = "Use to remotely trigger the rune and incapacitate someone on top."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/blood
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "By touching this rune while a non-cultist stands above it, you will knock them down and keep them unable to move or speak as Nar-Sie's words reach out to them. \
		The ritual will take longer on trained security personnel and some Nanotrasen official, but can also be sped up by wearing cult robes or armor.\
		<br><br>If the target is willing and there are few enough cult members, they will be converted and become an honorary cultist.\
		<br><br>However if the target has a loyalty implants or the cult already has 9 human members, they will instead be restrained by ghastly bindings. \
		More than one construct of each time will also reduce the maximum amount of permitted human cultists.\
		<br><br>Do not seek to convert everyone, instead use the Seer or Astral Journey runes first to locate the most interesting candidates.\
		<br><br>Touching the rune again during the early part of the ritual lets you toggle it between \"conversion\" and \"entrapment\", should you just want to restrain someone.\
		<br><br>By attuning a talisman to this rune, you can trigger it remotely, but you will have to move closer afterwards or the ritual will stop.\
		<br><br>This rune persists upon use, allowing repeated usage."
	var/remaining = 100
	var/mob/living/carbon/victim = null
	var/flavor_text = 0
	var/success = CONVERSION_NOCHOICE
	var/list/impede_medium = list(
		"Security Officer",
		"Warden",
		"Detective",
		"Head of Security",
		"Internal Affairs Agent",
		"Head of Personnel",
		)
	var/list/impede_hard = list(
		"Chaplain",
		"Captain",
		)
	var/obj/effect/cult_ritual/conversion/conversion = null

	var/phase = 1
	var/entrapment = FALSE


/datum/rune_spell/conversion/Destroy()
	if(conversion)
		conversion.Die()
	..()

/datum/rune_spell/conversion/update_progbar()//progbar tracks conversion progress instead of paid blood
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[min(100,round((100-remaining), 10))]"
	return

/datum/rune_spell/conversion/cast()
	var/obj/effect/rune/R = spell_holder
	var/mob/converter = activator//trying to fix logs showing the converter as *null*

	R.one_pulse()
	var/turf/T = R.loc
	var/list/targets = list()

	//first lets check for a victim on top of the rune
	for (var/mob/living/silicon/S in T) // Has science gone too far????
		if (S.cult_permitted || Holiday == APRIL_FOOLS_DAY)
			if (!iscultist(S))
				targets.Add(S)

	for (var/mob/living/carbon/C in T)//all carbons can be converted...but only carbons. no cult silicons. (unless it's April 1st)
		if (!iscultist(C) && !C.isDead())//no more corpse conversions!
			targets.Add(C)
	if (targets.len > 0)
		victim = pick(targets)
	else
		to_chat(activator, "<span class='warning'>There needs to be a potential convert standing or lying on top of the rune.</span>")
		qdel(src)
		return

	var/mob/convertee = victim//trying to fix logs showing the victim as *null*

	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)

	update_progbar()
	if (activator.client)
		activator.client.images |= progbar

	//secondly, let's stun our victim and begin the ritual
	to_chat(victim, "<span class='danger'>Occult energies surge from below your [issilicon(victim) ? "actuators" : "feet"] and seep into your [issilicon(victim) ? "chassis" : "body"].</span>")
	victim.Silent(5)
	victim.Knockdown(5)
	victim.Stun(5)
	if (isalien(victim))
		victim.Paralyse(5)
	victim.overlay_fullscreen("conversionborder", /obj/abstract/screen/fullscreen/conversion_border)
	victim.overlay_fullscreen("conversionred", /obj/abstract/screen/fullscreen/conversion_red)
	victim.update_fullscreen_alpha("conversionred", 255, 5)
	victim.update_fullscreen_alpha("conversionborder", 255, 5)
	conversion = new(T)
	flick("rune_convert_start",conversion)
	for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
		if (M.client)
			M.playsound_local(T, 'sound/effects/convert_start.ogg', 75, 0, -4)

	for(var/obj/item/device/gps/secure/SPS in get_contents_in_object(victim))
		SPS.OnMobDeath(victim)//Think carefully before converting a sec officer

	if (!cult.CanConvert())
		to_chat(activator, "<span class='warning'>There are already too many cultists. \The [victim] will be made a prisoner.</span>")

	if (victim.mind)
		if (victim.mind.assigned_role in impede_medium)
			to_chat(victim, "<span class='warning'>Your devotion to Nanotrasen slows down the ritual.</span>")
			to_chat(activator, "<span class='warning'>Their devotion to Nanotrasen is strong, the ritual will take longer.</span>")

		if (victim.mind.assigned_role in impede_hard)
			var/higher_cause = "Space Jesus"
			switch(victim.mind.assigned_role)
				if ("Captain")
					higher_cause = "Nanotrasen"
				if ("Chaplain")
					higher_cause = "[victim.mind.faith ? "[victim.mind.faith.deity_name]" : "Space Jesus"]"
			to_chat(victim, "<span class='warning'>Your devotion to [higher_cause] slows down the ritual.</span>")
			to_chat(activator, "<span class='warning'>Their devotion to [higher_cause] is amazing, the ritual will be lengthy.</span>")

	spawn()
		while (remaining > 0)
			if (destroying_self || !spell_holder || !activator || !victim)
				return
			//first let's make sure they're on the rune
			if (victim.loc != T)//Removed() should take care of it, but just in case
				victim.clear_fullscreen("conversionred", 10)
				victim.clear_fullscreen("conversionborder", 10)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'sound/effects/convert_abort.ogg', 50, 0, -4)
				conversion.icon_state = ""
				flick("rune_convert_abort",conversion)
				abort(RITUALABORT_REMOVED)
				return

			//and that we're next to them
			if (!spell_holder.Adjacent(activator))
				cancelling--
				if (cancelling <= 0)
					victim.clear_fullscreen("conversionred", 10)
					victim.clear_fullscreen("conversionborder", 10)
					for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
						if (M.client)
							M.playsound_local(T, 'sound/effects/convert_abort.ogg', 50, 0, -4)
					conversion.icon_state = ""
					flick("rune_convert_abort",conversion)
					abort(RITUALABORT_GONE)
					return

			else
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'sound/effects/convert_process.ogg', 10, 0, -4)
				//then progress through the ritual
				victim.Silent(5)
				victim.Knockdown(5)
				victim.Stun(5)
				if (isalien(victim))
					victim.Paralyse(5)
				var/progress = 10//10 seconds to reach second phase for a naked cultist
				progress += activator.get_cult_power()//down to 1-2 seconds when wearing cult gear
				var/delay = 0
				if (victim.mind)
					if (victim.mind.assigned_role in impede_medium)
						delay = 1
						progress = progress/2

					if (victim.mind.assigned_role in impede_hard)
						delay = 1
						progress = progress/4

				if (delay)
					progress = clamp(progress,1,10)
				remaining -= progress
				update_progbar()
				victim.update_fullscreen_alpha("conversionred", 164-remaining, 8)

				//spawning some messages
				var/threshold = min(100,round((100-remaining), 10))
				if (flavor_text < 3)
					if (flavor_text == 0 && threshold > 10)//it's ugly but gotta account for the possibility of several messages appearing at once
						to_chat(victim, "<span class='sinister'>WE ARE THE BLOOD PUMPING THROUGH THE FABRIC OF SPACE</span>")
						flavor_text++
					if (flavor_text == 1 && threshold > 40)
						to_chat(victim, "<span class='sinister'>THE GEOMETER CALLS FOR YET ANOTHER FEAST</span>")
						flavor_text++
					if (flavor_text == 2 && threshold > 70)
						to_chat(victim, "<span class='sinister'>FRIEND OR FOE, YOU TOO SHALL JOIN THE FESTIVITIES</span>")
						flavor_text++
			sleep(10)

		if (activator && activator.client)
			activator.client.images -= progbar

		//alright, now the second phase, which always lasts an additional 10 seconds, but no longer requires the proximity of the activator.
		phase = 2
		var/acceptance = "Never"
		victim.Silent(15)
		victim.Knockdown(15)
		victim.Stun(15)
		if (isalien(victim))
			victim.Paralyse(15)

		if (victim.client)
			if(victim.mind.assigned_role == "Chaplain")
				acceptance = "Chaplain"
			else
				acceptance = get_role_desire_str(victim.client.prefs.roles[CULTIST])

				for(var/obj/item/weapon/implant/loyalty/I in victim)
					if(I.imp_in)
						acceptance = "Implanted"
		else if (!victim.mind)
			acceptance = "Mindless"

		if (jobban_isbanned(victim, CULTIST) || isantagbanned(victim))
			acceptance = "Banned"


		if ((acceptance == "Always" || acceptance == "Yes") && !cult.CanConvert())
			acceptance = "Overcrowded"

		if (entrapment)
			acceptance = "Overcrowded"

		//Players with cult enabled in their preferences will always get converted.
		//Others get a choice, unless they're cult-banned or have their preferences set to Never (or disconnected), in which case they always die.
		var/conversion_delay = 100
		switch (acceptance)
			if ("Always","Yes")
				conversion.icon_state = "rune_convert_good"
				to_chat(activator, "<span class='sinister'>The ritual immediately stabilizes, \the [victim] appears eager help prepare the festivities.</span>")
				cult.send_flavour_text_accept(victim, activator)
				success = CONVERSION_ACCEPT
				conversion_delay = 30
			if ("No","???","Never")
				if (victim.client)
					to_chat(activator, "<span class='sinister'>The ritual arrives in its final phase. How it ends depends now of \the [victim]. You do not have to remain adjacent for the remainder of the ritual.</span>")
					spawn()
						if (alert(victim, "The Cult of Nar-Sie has much in store for you, but what specifically?","You have 10 seconds to decide","Join the Cult","Become Prisoner") == "Join the Cult")
							conversion.icon_state = "rune_convert_good"
							success = CONVERSION_ACCEPT
							to_chat(victim, "<span class='sinister'>THAT IS GOOD. COME CLOSER. THERE IS MUCH TO TEACH YOU</span>")
						else
							to_chat(victim, "<span class='danger'>THAT IS ALSO GOOD, FOR YOU WILL ENTERTAIN US</span>")
							success = CONVERSION_REFUSE
				else//converting a braindead carbon will always lead to them being captured
					to_chat(activator, "<span class='sinister'>\The [victim] doesn't really seem to have all their wits about them. Letting the ritual conclude will let you restrain them.</span>")
			if ("Implanted")
				if (victim.client)
					to_chat(activator, "<span class='sinister'>A loyalty implant interferes with the ritual. They will not be able to accept the conversion.</span>")
					to_chat(victim, "<span class='danger'>Your loyalty implant prevents you from hearing any more of what they have to say.</span>")
					success = CONVERSION_REFUSE
				else//converting a braindead carbon will always lead to them being captured
					to_chat(activator, "<span class='sinister'>\The [victim] doesn't really seem to have all their wits about them. Letting the ritual conclude will let you restrain them.</span>")
			if ("Chaplain")//Chaplains can never be converted
				if (victim.client)
					to_chat(activator, "<span class='sinister'>Chaplains won't ever let themselves be converted. They will be restrained.</span>")
					to_chat(victim, "<span class='danger'>Your devotion to [victim.mind.faith ? "[victim.mind.faith.deity_name]" : "Space Jesus"] shields you from Nar-Sie's temptations.</span>")
					success = CONVERSION_REFUSE
				else//converting a braindead carbon will always lead to them being captured
					to_chat(activator, "<span class='sinister'>\The [victim] doesn't really seem to have all their wits about them. Letting the ritual conclude will let you restrain them.</span>")
			if ("Banned")
				conversion.icon_state = "rune_convert_bad"
				to_chat(activator, "<span class='sinister'>Given how unstable the ritual is becoming, \The [victim] will surely be consumed entirely by it. They weren't meant to become one of us.</span>")
				to_chat(victim, "<span class='danger'>Except your past actions have displeased us. You will be our snack before the feast begins. \[You are banned from this role\]</span>")
				success = CONVERSION_BANNED
			if ("Mindless")
				conversion.icon_state = "rune_convert_bad"
				to_chat(activator, "<span class='sinister'>This mindless creature will be sacrificed.</span>")
				success = CONVERSION_MINDLESS
			if ("Overcrowded")
				to_chat(victim, "<span class='sinister'>EXCEPT...THERE ARE NO VACANT SEATS LEFT!</span>")
				success = CONVERSION_OVERCROWDED
				conversion_delay = 30

		//since we're no longer checking for the cultist's adjacency, let's finish this ritual without a loop
		sleep(conversion_delay)

		if (destroying_self || !spell_holder || !activator || !victim)
			return

		if (victim.loc != T)//Removed() should take care of it, but just in case
			victim.clear_fullscreen("conversionred", 10)
			victim.clear_fullscreen("conversionborder", 10)
			for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
				if (M.client)
					M.playsound_local(T, 'sound/effects/convert_abort.ogg', 50, 0, -4)
			conversion.icon_state = ""
			flick("rune_convert_abort",conversion)
			abort(RITUALABORT_REMOVED)
			return

		if (victim.mind && !(victim.mind in converted_minds))
			converted_minds += victim.mind
			if (!cult)
				message_admins("Blood Cult: A conversion ritual occured...but we cannot find the cult faction...")//failsafe in case of admin varedit fuckery
			var/datum/role/streamer/streamer_role = activator?.mind?.GetRole(STREAMER)
			if(streamer_role && streamer_role.team == ESPORTS_CULTISTS)
				streamer_role.conversions += IS_WEEKEND ? 2 : 1
				streamer_role.update_antag_hud()

		switch (success)
			if (CONVERSION_ACCEPT)
				conversion.layer = BELOW_OBJ_LAYER
				conversion.plane = OBJ_PLANE
				victim.clear_fullscreen("conversionred", 10)
				victim.clear_fullscreen("conversionborder", 10)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'sound/effects/convert_success.ogg', 75, 0, -4)
				//new cultists get purged of the debuffs
				victim.SetKnockdown(0)
				victim.SetStunned(0)
				victim.SetSilent(0)
				if (isalien(victim))
					victim.SetParalysis(0)
				//let's also remove cult cuffs if they have them
				if (istype(victim.handcuffed,/obj/item/weapon/handcuffs/cult))
					victim.drop_from_inventory(victim.handcuffed)
				//and their loyalty implants are removed, so they can't mislead security, not that the conversion should even go through
				victim.implant_pop()
				for(var/obj/item/weapon/implant/holy/H in victim)
					to_chat(victim, "<span class='warning'>The ritual's energies have completely fried the holy implant that was lodged in your skull.</span>")
					qdel(H)
				convert(convertee, converter)
				conversion.icon_state = ""
				TriggerCultRitual(/datum/bloodcult_ritual/conversion, converter, list("victim" = convertee))
				flick("rune_convert_success",conversion)
				message_admins("BLOODCULT: [key_name(convertee)] has been converted by [key_name(converter)].")
				log_admin("BLOODCULT: [key_name(convertee)] has been converted by [key_name(converter)].")
				if (issilicon(victim))
					var/mob/living/silicon/S = victim
					S.laws = new /datum/ai_laws/cultimov
					to_chat(S, "<span class='sinister'>Laws updated.</span>")
					S << sound('sound/machines/lawsync.ogg')
					if (isrobot(S))
						var/mob/living/silicon/robot/robit = S
						robit.disconnect_AI()
				if (istype(victim, /mob/living/carbon/complex/gondola)) //fug.....
					var/mob/living/carbon/complex/gondola/gondola = victim
					gondola.icon_state_standing = pick("gondola_c","gondola_c_tome")
					gondola.icon_state_lying = "[gondola.icon_state_standing]_lying"
					gondola.icon_state_dead = "gondola_skull"
					gondola.icon_state = gondola.icon_state_standing
				abort(RITUALABORT_CONVERT)
				return
			if (CONVERSION_NOCHOICE, CONVERSION_REFUSE, CONVERSION_OVERCROWDED)
				conversion.icon_state = ""
				flick("rune_convert_refused",conversion)
				for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
					if (M.client)
						M.playsound_local(T, 'sound/effects/convert_abort.ogg', 75, 0, -4)

				victim.Silent(8)
				victim.Knockdown(7)
				victim.Stun(6)
				victim.Jitter(5)
				if (isalien(victim))
					victim.Paralyse(8)

				//let's start by removing any cuffs they might already have
				if (victim.handcuffed)
					var/obj/item/weapon/handcuffs/cuffs = victim.handcuffed
					victim.u_equip(cuffs)

				var/obj/item/weapon/handcuffs/cult/restraints = new(victim)
				victim.handcuffed = restraints
				restraints.on_restraint_apply(victim)//a jolt of pain to slow them down
				restraints.gaoler = iscultist(converter)
				victim.update_inv_handcuffed()	//update handcuff overlays

				if (success == CONVERSION_NOCHOICE)
					if (convertee.mind)//no need to generate logs when capturing mindless monkeys
						to_chat(victim, "<span class='danger'>Because you didn't give your answer in time, you were automatically made prisoner.</span>")
						message_admins("BLOODCULT: [key_name(convertee)] has timed-out during conversion by [key_name(converter)].")
						log_admin("BLOODCULT: [key_name(convertee)] has timed-out during conversion by [key_name(converter)].")

					abort(RITUALABORT_NOCHOICE)
				else if (success == CONVERSION_REFUSE)
					message_admins("BLOODCULT: [key_name(convertee)] has refused conversion by [key_name(converter)].")
					log_admin("BLOODCULT: [key_name(convertee)] has refused conversion by [key_name(converter)].")

					abort(RITUALABORT_REFUSED)
				else
					message_admins("BLOODCULT: [key_name(convertee)] was made prisoner by [key_name(converter)] because the cult is overcrowded.")
					log_admin("BLOODCULT: [key_name(convertee)] was made prisoner by [key_name(converter)] because the cult is overcrowded.")

					abort(RITUALABORT_REFUSED)

			if (CONVERSION_BANNED)

				message_admins("BLOODCULT: [key_name(convertee)] died because they were converted by [key_name(converter)] while cult-banned.")
				log_admin("BLOODCULT: [key_name(convertee)] died because they were converted by [key_name(converter)] while cult-banned.")
				conversion.icon_state = ""
				flick("rune_convert_failure",conversion)

				//sacrificed victims have all their stuff stored in a coffer that also contains their skull and a cup of their blood, should they have either
				victim.boxify(TRUE, FALSE, "cult")
				abort(RITUALABORT_SACRIFICE)

			if (CONVERSION_MINDLESS)

				conversion.icon_state = ""
				flick("rune_convert_failure",conversion)

				victim.boxify(TRUE, FALSE, "cult")
				abort(RITUALABORT_SACRIFICE)

/datum/rune_spell/conversion/proc/convert(var/mob/M, var/mob/converter)
	var/datum/role/cultist/newCultist = new
	newCultist.AssignToRole(M.mind,1)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
	cult.HandleRecruitedRole(newCultist)
	newCultist.OnPostSetup()
	newCultist.Greet(GREET_CONVERTED)
	newCultist.conversion["converted"] = activator

/datum/rune_spell/conversion/midcast(var/mob/add_cultist)
	if (add_cultist != activator)
		return
	if (phase == 1)
		if (entrapment)
			to_chat(add_cultist, "<span class='notice'>You perform the conversion sign, allowing the victim to become a cultist if they qualify.</span>")
			entrapment = FALSE
		else
			to_chat(add_cultist, "<span class='warning'>You perform the entrapment sign, ensuring that the victim will be restrained.</span>")
			entrapment = TRUE

/datum/rune_spell/conversion/Removed(var/mob/M)
	if (victim == M)
		for(var/mob/living/L in dview(world.view, spell_holder.loc, INVISIBILITY_MAXIMUM))
			if (L.client)
				L.playsound_local(spell_holder.loc, 'sound/effects/convert_abort.ogg', 50, 0, -4)
		conversion.icon_state = ""
		flick("rune_convert_abort",conversion)
		abort(RITUALABORT_REMOVED)

/datum/rune_spell/conversion/cast_talisman()//handled by /obj/item/weapon/talisman/proc/trigger instead
	return

/datum/rune_spell/conversion/abort(var/cause)
	if (victim)
		victim.clear_fullscreen("conversionred", 10)
		victim.clear_fullscreen("conversionborder", 10)
		victim = null
	..()

/obj/effect/cult_ritual/conversion
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = "rune_convert_process"
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/conversion/proc/Die()
	spawn(10)
		qdel(src)


////////////////////////////////////////////////////////////////////
//																  //
//								STUN							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/stun
	name = "Stun"
	desc = "Overwhelm everyone's senses with a blast of pure chaotic energy. Cultists will recover their senses a bit faster."
	desc_talisman = "Use to produce a smaller radius blast, or touch someone with it to focus the entire power of the spell on their person."
	invocation = "Fuu ma'jin!"
	touch_cast = 1
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/hide
	word3 = /datum/rune_word/technology
	page = "Concentrated chaotic energies violently released that will temporarily enfeeble anyone in a large radius, even cultists, although those recover a second faster than non-cultists.\
		<br><br>When cast from a talisman, the energy affects creatures in a smaller radius and for a smaller duration, which might still be useful in an enclosed space.\
		<br><br>However the real purpose of this rune when imbued into a talisman is revealed when you directly touch someone with it, as all of the energies will be concentrated onto their single body, \
		paralyzing and muting them for a longer duration. This application was created to allow cultists to easily kidnap crew members to convert or torture."


/datum/rune_spell/stun/pre_cast()
	var/mob/living/user = activator

	if (istype (spell_holder,/obj/effect/rune))
		invoke(user,invocation)
		cast()
	else if (istype (spell_holder,/obj/item/weapon/talisman))
		invoke(user,invocation,1)
		cast_talisman()

/datum/rune_spell/stun/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	new/obj/effect/cult_ritual/stun(R.loc)

	qdel(R)

/datum/rune_spell/stun/cast_talisman()
	var/turf/T = get_turf(spell_holder)
	new/obj/effect/cult_ritual/stun(T,2)
	qdel(src)

/datum/rune_spell/stun/cast_touch(var/mob/M)
	anim(target = M, a_icon = 'icons/effects/64x64.dmi', flick_anim = "touch_stun", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = ABOVE_LIGHTING_PLANE)

	playsound(spell_holder, 'sound/effects/stun_talisman.ogg', 25, 0, -5)
	if (prob(15))//for old times' sake
		invoke(activator,"Dream sign ''Evil sealing talisman''!",1)
	else
		invoke(activator,invocation,1)

	if(issilicon(M))
		to_chat(M, "<span class='danger'>WARNING: Short-circuits detected, Rebooting...</span>")
		M.Knockdown(15)

	else if(iscarbon(M))
		to_chat(M, "<span class='danger'>A surge of dark energies takes hold of your limbs. You stiffen and fall down.</span>")
		var/mob/living/carbon/C = M
		C.flash_eyes(visual = 1)
		if (!(M_HULK in C.mutations))
			to_chat(M, "<span class='danger'>You find yourself unable to say a word.</span>")
			C.Silent(15)
		C.Knockdown(15)//used to be 25
		C.Stun(15)//used to be 25
		if (isalien(C))
			C.Paralyse(15)

	if (!(locate(/obj/effect/stun_indicator) in M))
		new /obj/effect/stun_indicator(M)

	qdel(src)

/obj/effect/cult_ritual/stun
	icon_state = "stun_warning"
	color = "black"
	anchored = 1
	alpha = 0
	plane = HIDING_MOB_PLANE
	mouse_opacity = 0
	var/stun_duration = 5

/obj/effect/cult_ritual/stun/New(turf/loc,var/type=1)
	..()

	switch (type)
		if (1)
			stun_duration++
			anim(target = loc, a_icon = 'icons/effects/64x64.dmi', flick_anim = "rune_stun", sleeptime = 20, lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = ABOVE_LIGHTING_PLANE)
			icon = 'icons/effects/480x480.dmi'
			pixel_x = -224
			pixel_y = -224
			animate(src,alpha = 255,time = 10)
		if (2)
			stun_duration--
			anim(target = loc, a_icon = 'icons/effects/64x64.dmi', flick_anim = "talisman_stun", sleeptime = 20, lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = ABOVE_LIGHTING_PLANE)
			icon = 'icons/effects/224x224.dmi'
			pixel_x = -96
			pixel_y = -96
			animate(src,alpha = 255,time = 10)

	playsound(src, 'sound/effects/stun_rune_charge.ogg', 75, 0, 0)
	spawn(20)
		playsound(src, 'sound/effects/stun_rune.ogg', 75, 0, 0)
		visible_message("<span class='warning'>The rune explodes in a bright flash of chaotic energies.</span>")

		var/list/mobs_to_stun = get_all_mobs_in_dview(get_turf(src))

		for(var/mob/living/L in mobs_to_stun)
			var/duration = stun_duration
			var/dist = cheap_pythag(L.x - src.x, L.y - src.y)
			if (type == 1 && dist>=8)
				continue
			if (type == 2 && dist>=4)//talismans have a reduced range
				continue
			shadow(L,loc,"rune_stun")
			if (iscultist(L))
				duration--
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.flash_eyes(visual = 1)
				if(C.stuttering < 1 && (!(M_HULK in C.mutations)))
					C.stuttering = 1
				C.Knockdown(duration)
				C.Stun(duration)
				if (isalien(C))
					C.Paralyse(duration)

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Knockdown(duration)//TODO: TEST THAT
		qdel(src)



////////////////////////////////////////////////////////////////////
//																  //
//								CONFUSION						  //
//																  //
////////////////////////////////////////////////////////////////////

var/list/confusion_victims = list()

/datum/rune_spell/confusion
	name = "Confusion"
	desc = "Sow panic in the mind of your enemies, and obscure cameras."
	desc_talisman = "Sow panic in the mind of your enemies, and obscure cameras. The effect is shorter than when used from a rune."
	invocation = "Sti' kaliesin!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/other
	page = "This rune instills paranoia in the heart and mind of your enemies. \
	Every non-cultist human in range will see their surroundings appear covered with occult markings, and everyone will look like monsters to them. \
	HUDs won't help officer differentiate their owns for the duration of the illusion.\
	<br><br>Robots in view will be simply blinded for a short while, cameras however will remain dark until someone resets their wiring.\
	<br><br>Because it also causes a few seconds of blindness to those affected, this rune is useful as both a way to initiate a fight, escape, or kidnap someone amidst the chaos."
	var/rune_duration=300//times are in tenths of a second
	var/talisman_duration=200
	var/hallucination_radius=25

/datum/rune_spell/confusion/cast(var/duration = rune_duration)
	new /obj/effect/cult_ritual/confusion(spell_holder,duration,hallucination_radius, null, activator)
	qdel(spell_holder)

/datum/rune_spell/confusion/cast_talisman()//talismans have the same range, but the effect lasts shorter.
	cast(talisman_duration)

/obj/effect/cult_ritual/confusion
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = ABOVE_LIGHTING_PLANE
	mouse_opacity = 0
	var/duration = 5
	var/hallucination_radius=25

/obj/effect/cult_ritual/confusion/New(turf/loc,var/duration=300,var/radius=25,var/mob/specific_victim=null, var/culprit)
	..()
	//Alright, this is a pretty interesting rune, first of all we prepare the fake cult floors & walls that the victims will see.
	var/turf/T = get_turf(src)
	var/list/hallucinated_turfs = list()
	playsound(T, 'sound/effects/confusion_start.ogg', 75, 0, 0)
	for(var/turf/U in range(T,radius))
		if (istype(U,/area/chapel))//the chapel is protected against such illusions, the mobs in it will still be affected however.
			continue
		var/dist = cheap_pythag(U.x - T.x, U.y - T.y)
		if (dist < 15 || prob((radius-dist)*4))
			var/image/I_turf
			if (U.density)
				I_turf = image(icon = 'icons/turf/walls.dmi', loc = U, icon_state = "cult[U.junction]")//will preserve wall smoothing
			else
				I_turf = image(icon = 'icons/turf/floors.dmi', loc = U, icon_state = "cult")
				//if it's a floor, give it a chance to have some runes written on top
				if (rune_appearances_cache.len > 0 && prob(7))
					var/lookup = pick(rune_appearances_cache)//finally a good use for that cache
					var/image/I = rune_appearances_cache[lookup]
					I_turf.overlays += I
			hallucinated_turfs.Add(I_turf)

	//now let's round up our victims: any non-cultist with an unobstructed line of sight to the rune/talisman will be affected
	var/list/potential_victims = list()

	if (specific_victim)
		potential_victims.Add(specific_victim)
	else
		for(var/mob/living/M in dview(world.view, T, INVISIBILITY_MAXIMUM))
			potential_victims.Add(M)

	var/ritual_victim_count = 0
	for(var/mob/living/M in potential_victims)

		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (iscultist(C))
				continue

			if(C.stat == CONSCIOUS)
				ritual_victim_count++

			var/datum/confusion_manager/CM
			if (M in confusion_victims)
				CM = confusion_victims[M]
			else
				CM = new(M,duration)
				confusion_victims[M] = CM

			spawn()
				CM.apply_confusion(T,hallucinated_turfs)

		if (issilicon(M) && !isAI(M))//Silicons get a fade to black, then just a flash, until I can think of something else
			shadow(M,T)
			M.overlay_fullscreen("blindblack", /obj/abstract/screen/fullscreen/black)
			M.update_fullscreen_alpha("blindblack", 255, 5)
			spawn(5)
				M.clear_fullscreen("blindblack", animate = 0)
				M.flash_eyes(visual = 1)

	//temp ritual stuff
	if(culprit && ritual_victim_count > 0)
		TriggerCultRitual(/datum/bloodcult_ritual/sow_confusion, culprit, list("victimcount" = ritual_victim_count))

	//now to blind cameras, the effects on cameras do not time out, but they can be fixed
	if (!specific_victim)
		for(var/obj/machinery/camera/C in dview(world.view, T, INVISIBILITY_MAXIMUM))
			shadow(C,T)
			var/col = C.color
			animate(C, color = col, time = 4)
			animate(color = "black", time = 5)
			animate(color = col, time = 5)
			C.vision_flags = BLIND//Anyone using a security cameras computer will only see darkness
			C.setViewRange(-1)//The camera won't reveal the area for the AI anymore

	qdel(src)

//each affected mob gets their own
/datum/confusion_manager
	var/time_of_last_confusion = 0
	var/list/my_hallucinated_stuff = list()
	var/mob/victim = null
	var/duration = 300

/datum/confusion_manager/New(var/mob/M,var/D)
	..()
	victim = M
	duration = D

/datum/confusion_manager/Destroy()
	my_hallucinated_stuff = list()
	victim = null
	..()

/datum/confusion_manager/proc/apply_confusion(var/turf/T,var/list/hallucinated_turfs)
	shadow(victim,T)//shadow trail moving from the spell_holder to the victim
	anim(target = victim, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_blind", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)

	if (!time_of_last_confusion)
		start_confusion(T,hallucinated_turfs)
		return
	if (victim.mind)
		message_admins("BLOODCULT: [key_name(victim)] had the effects of Confusion refreshed back to [duration/10] seconds.")
		log_admin("BLOODCULT: [key_name(victim)] had the effects of Confusion refreshed by back to [duration/10] seconds.")
	var/time_key = world.time
	time_of_last_confusion = time_key
	victim.update_fullscreen_alpha("blindblack", 255, 5)
	sleep (10)
	refresh_confusion(T,hallucinated_turfs,time_key)

/datum/confusion_manager/proc/start_confusion(var/turf/T,var/list/hallucinated_turfs)
	var/time_key = world.time
	time_of_last_confusion = time_key
	if (victim.mind)
		message_admins("BLOODCULT: [key_name(victim)] is now under the effects of Confusion for [duration/10] seconds.")
		log_admin("BLOODCULT: [key_name(victim)] is now under the effects of Confusion for [duration/10] seconds.")
	to_chat(victim, "<span class='danger'>Your vision goes dark, panic and paranoia take their toll on your mind.</span>")
	victim.overlay_fullscreen("blindborder", /obj/abstract/screen/fullscreen/confusion_border)//victims DO still get blinded for a second
	victim.overlay_fullscreen("blindblack", /obj/abstract/screen/fullscreen/black)//which will allow us to subtly reveal the surprise
	victim.update_fullscreen_alpha("blindblack", 255, 5)
	victim.playsound_local(victim, 'sound/effects/confusion.ogg', 50, 0, 0, 0, 0)
	sleep(10)
	victim.overlay_fullscreen("blindblind", /obj/abstract/screen/fullscreen/blind)
	refresh_confusion(T,hallucinated_turfs,time_key)

/datum/confusion_manager/proc/refresh_confusion(var/turf/T,var/list/hallucinated_turfs,var/time_key)
	victim.update_fullscreen_alpha("blindblind", 255, 0)
	victim.update_fullscreen_alpha("blindblack", 0, 10)
	victim.update_fullscreen_alpha("blindblind", 0, 80)
	victim.update_fullscreen_alpha("blindborder", 150, 5)

	if (victim.client)
		var/static/list/hallucination_mobs = list("faithless","forgotten","otherthing")
		victim.client.images.Remove(my_hallucinated_stuff)//removing images caused by every blind rune used consecutively on that mob
		my_hallucinated_stuff = hallucinated_turfs.Copy()
		for(var/mob/living/L in range(T,25))//All mobs in a large radius will look like monsters to the victims.
			if (L == victim)
				continue//the victims still see themselves as humans (or whatever they are)
			var/image/override_overlay = image(icon = 'icons/mob/animal.dmi', loc = L, icon_state = pick(hallucination_mobs))
			override_overlay.override = TRUE
			my_hallucinated_stuff.Add(override_overlay)
		victim.client.images.Add(my_hallucinated_stuff)
		victim.regular_hud_updates()//data huds are disabled for the duration of the confusion

	sleep(duration-5)

	if (time_of_last_confusion != time_key)//only the last applied confusion gets to end it
		return

	victim.update_fullscreen_alpha("blindborder", 0, 5)
	victim.overlay_fullscreen("blindwhite", /obj/abstract/screen/fullscreen/white)
	victim.update_fullscreen_alpha("blindwhite", 255, 3)
	sleep(5)
	confusion_victims.Remove(victim)
	victim.update_fullscreen_alpha("blindwhite", 0, 12)
	victim.clear_fullscreen("blindblack", animate = 0)
	victim.clear_fullscreen("blindborder", animate = 0)
	victim.clear_fullscreen("blindblind", animate = 0)
	anim(target = victim, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_blind_remove", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	if (victim.client)
		victim.client.images.Remove(my_hallucinated_stuff)//removing images caused by every blind rune used consecutively on that mob
	if (victim.mind)
		message_admins("BLOODCULT: [key_name(victim)] is no longer under the effects of Confusion.")
		log_admin("BLOODCULT: [key_name(victim)] is no longer under the effects of Confusion.")
	sleep(15)
	victim.clear_fullscreen("blindwhite", animate = 0)
	qdel(src)

////////////////////////////////////////////////////////////////////
//																  //
//								DEAF-MUTE						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/deafmute
	name = "Deaf-Mute"
	desc = "Silence and deafen nearby enemies. Including robots."
	desc_talisman = "Silence and deafen nearby enemies. Including robots. The effect is shorter than when used from a rune."
	invocation = "Sti' kaliedir!"
	word1 = /datum/rune_word/hide
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/see
	page = "This rune causes every non-cultist (both humans and robots) in a 7 tile radius to be unable to speak 30 seconds, and unable to hear for 50 seconds. \
		The durations are halved when cast from a talisman.\
		<br><br>This rune is great to sow disorder and delay the arrival of security, and can potentially combo with a Stun talisman used on an area. The only downside is that you can't hear them scream while they are muted."
	var/deaf_rune_duration=50//times are in seconds
	var/deaf_talisman_duration=30
	var/mute_rune_duration=25
	var/mute_talisman_duration=15
	var/effect_range=7

/datum/rune_spell/deafmute/cast(var/deaf_duration = deaf_rune_duration, var/mute_duration = mute_rune_duration)
	var/ritual_victim_count = 0
	for(var/mob/living/M in range(effect_range,get_turf(spell_holder)))
		if (iscultist(M))
			continue
		ritual_victim_count += 1
		M.overlay_fullscreen("deafborder", /obj/abstract/screen/fullscreen/deafmute_border)//victims see a red overlay fade in-out for a second
		M.update_fullscreen_alpha("deafborder", 100, 5)
		M.Deafen(deaf_duration)
		M.Mute(mute_duration)
		if (!(M.sdisabilities & DEAF))
			to_chat(M,"<span class='notice'>The world around you suddenly becomes quiet.</span>")
		if (!(M.sdisabilities & MUTE))
			if (iscarbon(M))
				to_chat(M,"<span class='warning'>You feel a terrible chill! You find yourself unable to speak a word...</span>")
			else if (issilicon(M))
				to_chat(M,"<span class='warning'>A shortcut appears to have temporarily disabled your speaker!</span>")
		spawn(8)
			M.update_fullscreen_alpha("deafborder", 0, 5)
			sleep(8)
			M.clear_fullscreen("deafborder", animate = 0)
	if(activator && ritual_victim_count > 0)
		TriggerCultRitual(/datum/bloodcult_ritual/silence_lambs, activator, list("victimcount" = ritual_victim_count))
	qdel(spell_holder)

/datum/rune_spell/deafmute/cast_talisman()
	cast(deaf_talisman_duration, mute_talisman_duration)


////////////////////////////////////////////////////////////////////
//																  //
//								CONCEAL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/conceal
	name = "Conceal"
	desc = "Hide runes and cult structures. Some runes can still be used when concealed, but using them might reveal them."
	desc_talisman = "Hide runes and cult structures. Covers a smaller range than when used from a rune."
	invocation = "Kla'atu barada nikt'o!"
	word1 = /datum/rune_word/hide
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/blood
	page = "This rune allows you to hide every rune and structures in a circular 7 tile range around it. You cannot hide a rune or structure that got revealed less than 10 seconds ago. Affects through walls.\
		<br><br>The talisman version has a 5 tile radius."
	var/rune_effect_range=7
	var/talisman_effect_range=5

/datum/rune_spell/conceal/cast(var/effect_range = rune_effect_range,var/size='icons/effects/480x480.dmi')
	var/turf/T = get_turf(spell_holder)
	var/atom/movable/overlay/animation = anim(target = T, a_icon = size, a_icon_state = "rune_conceal", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE*effect_range, offY = -WORLD_ICON_SIZE*effect_range, plane = ABOVE_LIGHTING_PLANE)
	animation.alpha = 0
	animate(animation, alpha = 255, time = 2)
	animate(alpha = 0, time = 3)
	//for(var/turf/U in range(effect_range,T))//DEBUG
	//	var/dist = cheap_pythag(U.x - T.x, U.y - T.y)
	//	if (dist <= effect_range+0.5)
	//		U.color = "red"
	to_chat(activator, "<span class='notice'>All runes and cult structures in range hide themselves behind a thin layer of reality.</span>")
	//playsound(T, 'sound/effects/conceal.ogg', 50, 0, -4)

	for(var/obj/structure/cult/S in range(effect_range,T))
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		if (S.conceal_cooldown)
			continue
		if (dist <= effect_range+0.5)
			S.conceal()

	for(var/obj/effect/rune/R in range(effect_range,T))
		if (R == spell_holder)
			continue
		if (R.conceal_cooldown)
			continue
		var/dist = cheap_pythag(R.x - T.x, R.y - T.y)
		if (dist <= effect_range+0.5)
			R.conceal()
			var/atom/movable/overlay/trail = shadow(R,T,"rune_conceal")
			trail.alpha = 0
			animate(trail, alpha = 200, time = 2)
			animate(alpha = 0, time = 3)
	qdel(spell_holder)

/datum/rune_spell/conceal/cast_talisman()
	cast(talisman_effect_range,'icons/effects/352x352.dmi')


////////////////////////////////////////////////////////////////////
//																  //
//								REVEAL							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/reveal
	name = "Reveal"
	desc = "Reveal what you have previously hidden, terrifying enemies in the process."
	desc_talisman = "Reveal what you have previously hidden, terrifying enemies in the process. The effect is shorter than when used from a rune."
	invocation = "Nikt'o barada kla'atu!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/hide
	page = "This rune (whose words are the same as the Conceal rune in reverse) lets you reveal every rune and structures in a circular 7 tile range around it.\
		<br><br>Each revealed rune will stun non-cultists in a 3 tile range around them, stunning and muting them for 2 seconds, up to a total of 10 seconds. Affects through walls. The stun ends if the victims are moved away from where they stand, unless they get knockdown first, so you might want to follow up with a Stun talisman."

	walk_effect = TRUE

	var/effect_range=7
	var/shock_range=3
	var/shock_per_obj=2
	var/max_shock=10
	var/last_threshold = -1
	var/total_uses = 5

/datum/rune_spell/reveal/cast()
	var/turf/T = get_turf(spell_holder)
	//for(var/turf/U in range(effect_range,T))//DEBUG
	//	var/dist = cheap_pythag(U.x - T.x, U.y - T.y)
	//	if (dist <= effect_range+0.5)
	//		U.color = "red"

	var/list/shocked = list()
	to_chat(activator, "<span class='notice'>All concealed runes and cult structures in range phase back into reality, stunning nearby foes.</span>")
	playsound(T, 'sound/effects/reveal.ogg', 50, 0, -2)

	for(var/obj/structure/cult/concealed/S in range(effect_range,T))//only concealed structures trigger the effect
		var/dist = cheap_pythag(S.x - T.x, S.y - T.y)
		if (dist <= effect_range+0.5)
			anim(target = S, a_icon = 'icons/effects/224x224.dmi', flick_anim = "rune_reveal", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE*shock_range, offY = -WORLD_ICON_SIZE*shock_range, plane = ABOVE_LIGHTING_PLANE)
			for(var/mob/living/L in viewers(S))
				if (iscultist(L))
					continue
				var/dist2 = cheap_pythag(L.x - S.x, L.y - S.y)
				if (dist2 > shock_range+0.5)
					continue
				shadow(L,S.loc,"rune_reveal")
				if (L in shocked)
					shocked[L] = min(shocked[L]+shock_per_obj,max_shock)
				else
					shocked[L] = 2
			S.reveal()

	for(var/obj/effect/rune/R in range(effect_range,T))
		var/dist = cheap_pythag(R.x - T.x, R.y - T.y)
		if (dist <= effect_range+0.5)
			if (R.reveal())//only hidden runes trigger the effect
				anim(target = R, a_icon = 'icons/effects/224x224.dmi', flick_anim = "rune_reveal", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE*shock_range, offY = -WORLD_ICON_SIZE*shock_range, plane = ABOVE_LIGHTING_PLANE)
				for(var/mob/living/L in viewers(R))
					if (iscultist(L))
						continue
					var/dist2 = cheap_pythag(L.x - R.x, L.y - R.y)
					if (dist2 > shock_range+0.5)
						continue
					shadow(L,R.loc,"rune_reveal")
					if (L in shocked)
						shocked[L] = min(shocked[L]+shock_per_obj,max_shock)
					else
						shocked[L] = 2

	for(var/mob/living/L in shocked)
		new /obj/effect/cult_ritual/reveal(L.loc, L, shocked[L])
		TriggerCultRitual(/datum/bloodcult_ritual/reveal_truth, activator, list("shocked" = shocked))
		to_chat(L, "<span class='danger'>You feel a terrifying shock resonate within your body as the hidden runes are revealed!</span>")
		L.update_fullscreen_alpha("shockborder", 100, 5)
		spawn(8)
			L.update_fullscreen_alpha("shockborder", 0, 5)
			sleep(8)
			L.clear_fullscreen("shockborder", animate = 0)

	qdel(spell_holder)

/datum/rune_spell/reveal/Added(var/mob/mover)
	if (total_uses <= 0)
		return
	if (!isliving(mover))
		return
	var/mob/living/L = mover
	if (last_threshold + 20 SECONDS > world.time)
		return
	if (!iscultist(L))
		total_uses--
		last_threshold = world.time
		var/list/seers = list()
		for (var/mob/living/seer in range(7, get_turf(spell_holder)))
			if (iscultist(seer) && seer.client)
				var/image/image_intruder = image(L, loc = seer, layer = ABOVE_LIGHTING_LAYER, dir = L.dir)
				var/delta_x = (L.x - seer.x)
				var/delta_y = (L.y - seer.y)
				image_intruder.pixel_x = delta_x*WORLD_ICON_SIZE
				image_intruder.pixel_y = delta_y*WORLD_ICON_SIZE
				seers += seer
				seer.client.images += image_intruder // see the mover for a set period of time
				spawn(3)
					seer.client.images -= image_intruder // see the mover for a set period of time
					qdel(image_intruder)
		var/count = 10 SECONDS
		do
			for (var/mob/living/seer in seers)
				if (seer.gcDestroyed)
					seers -= seer
					continue
				var/image/image_intruder = image(L, loc = seer, layer = ABOVE_LIGHTING_LAYER, dir = L.dir)
				var/delta_x = (L.x - seer.x)
				var/delta_y = (L.y - seer.y)
				image_intruder.pixel_x = delta_x*WORLD_ICON_SIZE
				image_intruder.pixel_y = delta_y*WORLD_ICON_SIZE
				seer.client.images += image_intruder // see the mover for a set period of time
				spawn(3)
					seer.client.images -= image_intruder // see the mover for a set period of time
					qdel(image_intruder)
			count--
		while (count && seers.len)

/datum/rune_spell/reveal/cast_talisman()
	shock_per_obj = 1.5
	max_shock = 8
	cast()


/obj/effect/cult_ritual/reveal
	anchored = 1
	icon_state = "rune_reveal"
	layer = NARSIE_GLOW
	plane = ABOVE_LIGHTING_PLANE
	flags = PROXMOVE
	var/mob/living/victim = null
	var/duration = 2

/obj/effect/cult_ritual/reveal/Destroy()
	victim = null
	anim(target = loc, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_reveal-stop", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE)
	..()

/obj/effect/cult_ritual/reveal/New(var/turf/loc,var/mob/living/vic=null,var/dur=2)
	..()
	if (!vic)
		vic = locate() in loc
		if (!vic)
			qdel(src)
			return
	playsound(loc, 'sound/effects/shock.ogg', 20, 0, 0)
	victim = vic
	duration = dur
	victim.Stun(duration)
	victim.Mute(duration/2)
	if (isalien(victim))
		victim.Paralyse(duration)
	spawn (duration*10)
		if (src && loc && victim && victim.loc == loc && !victim.knockdown)
			to_chat(victim, "<span class='warning'>You come back to your senses.</span>")
			victim.AdjustStunned(-duration)
			victim.AdjustMute(-duration/2)
			if (isalien(victim))
				victim.AdjustParalysis(-duration)
			victim = null
		qdel(src)

/obj/effect/cult_ritual/reveal/HasProximity(var/atom/movable/AM)//Pulling victims will immediately dispel the effects
	if (!victim)
		qdel(src)
		return

	if (victim.loc != loc)
		if (!victim.knockdown)//if knockdown (by any cause), moving away doesn't purge you from the remaining stun.
			if (victim.pulledby)
				to_chat(victim, "<span class='warning'>You come back to your senses as \the [victim.pulledby] drags you away.</span>")
			victim.AdjustStunned(-duration)
			victim.AdjustMute(-duration/2)
			if (isalien(victim))
				victim.AdjustParalysis(-duration)
			victim = null
		qdel(src)


////////////////////////////////////////////////////////////////////
//																  //
//								SEER							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/seer
	name = "Seer"
	desc = "See the invisible, the dead, the concealed, and the propensity of the living to serve our agenda."
	desc_talisman = "For a whole minute, you may see the invisible, the dead, the concealed, and the propensity of the living to serve our agenda."
	invocation = "Rash'tla sektath mal'zua. Zasan therium viortia."
	rune_flags = RUNE_STAND
	talisman_uses = 10
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/hell
	word3 = /datum/rune_word/join
	page = "This rune grants the ability to see invisible ghosts, runes, and structures, but most of all, it also reveals the willingness of crew members to accept conversion, indicated by marks over their heads:\
		<br><br><b>Green marks</b> indicate people who will always accept conversion.\
		<br><br><b>Yellow marks</b> indicate people who might either accept or refuse.\
		<br><br><b>Red marks with two spikes</b> indicate loyalty implanted crew members, who will thus automatically refuse conversion regardless of their will.\
		<br><br><b>Red marks with three spikes</b> indicate crew members who have pledged themselves to fight the cult, and while they might not automatically refuse conversion, are very unlikely to be develop into useful cultists.\
		<br><br>Also note that you can activate runes while they are concealed. In talisman form, it has 10 uses that last for a minute each. Activate the talisman before moving into a public area so nobody hears you whisper the invocation.\
		<br><br>This rune persists upon use, allowing repeated usage."
	cost_invoke = 5
	var/obj/effect/cult_ritual/seer/seer_ritual = null
	var/talisman_duration = 60 SECONDS

/datum/rune_spell/seer/Destroy()
	destroying_self = 1
	if (seer_ritual && !seer_ritual.talisman)
		qdel(seer_ritual)
	seer_ritual = null
	..()

/datum/rune_spell/seer/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		seer_ritual = new /obj/effect/cult_ritual/seer(R.loc,activator,src)
	else
		qdel(src)

/datum/rune_spell/seer/cast_talisman()
	var/mob/living/M = activator

	if (locate(/obj/effect/cult_ritual/seer) in M)
		var/obj/item/weapon/talisman/T = spell_holder
		T.uses++
		to_chat(M, "<span class='warning'>You are still under the effects of a Seer talisman.</span>")
		qdel(src)
		return

	M.see_invisible_override = SEE_INVISIBLE_OBSERVER
	M.apply_vision_overrides()
	anim(target = M, a_icon = 'icons/effects/160x160.dmi', a_icon_state = "rune_seer", lay = ABOVE_OBJ_LAYER, offX = -WORLD_ICON_SIZE*2, offY = -WORLD_ICON_SIZE*2, plane = OBJ_PLANE, invis = INVISIBILITY_OBSERVER, alph = 200, sleeptime = talisman_duration, animate_movement = TRUE)
	new /obj/effect/cult_ritual/seer(activator,activator,null,TRUE, talisman_duration)
	qdel(src)

var/list/seer_rituals = list()

/obj/effect/cult_ritual/seer
	anchored = 1
	icon = 'icons/effects/160x160.dmi'
	icon_state = "rune_seer"
	pixel_x = -WORLD_ICON_SIZE*2
	pixel_y = -WORLD_ICON_SIZE*2
	alpha = 200
	invisibility=INVISIBILITY_OBSERVER
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	mouse_opacity = 0
	flags = PROXMOVE
	var/mob/living/caster = null
	var/datum/rune_spell/seer/source = null
	var/list/propension = list()
	var/talisman = FALSE

/obj/effect/cult_ritual/seer/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/seer/runespell,var/talisman_ritual = FALSE,var/talisman_duration = 60 SECONDS)
	..()
	seer_rituals.Add(src)
	processing_objects.Add(src)
	talisman = talisman_ritual
	caster = user
	source = runespell
	if (!caster)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)
		return
	caster.apply_hud(new /datum/visioneffect/cult_conversion)
	to_chat(caster, "<span class='notice'>You find yourself able to see through the gaps in the veil. You can see and interact with the other side, and also find out the crew's propensity to be successfully converted, whether they are <b><font color='green'>Willing</font></b>, <b><font color='orange'>Uncertain</font></b>, or <b><font color='red'>Unconvertible</font></b>.</span>")
	if (talisman)
		spawn(talisman_duration)
			qdel(src)


/obj/effect/cult_ritual/seer/Destroy()
	seer_rituals.Remove(src)
	processing_objects.Remove(src)
	caster.remove_hud_by_type(/datum/visioneffect/cult_conversion)
	to_chat(caster, "<span class='notice'>You can no longer discern through the veil.</span>")
	caster = null
	if (source)
		source.abort()
	source = null
	..()

/obj/effect/cult_ritual/seer/HasProximity(var/atom/movable/AM)
	if (!talisman)
		if (!caster || caster.loc != loc)
			qdel(src)

/*
/obj/effect/cult_ritual/seer/process()
	if (caster && caster.client)
		caster.client.images -= propension
		propension.len = 0

		for(var/mob/living/carbon/C in dview(caster.client.view+DATAHUD_RANGE_OVERHEAD, get_turf(src), INVISIBILITY_MAXIMUM))
			C.update_convertibility()
			propension += C.hud_list[CONVERSION_HUD]

		caster.client.images += propension
*/

////////////////////////////////////////////////////////////////////
//																  //
//							SUMMON ROBES						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/summonrobes
	name = "Summon Robes"
	desc = "Swap your clothes for the robes of Nar-Sie's followers. Significantly improves the efficiency of some rituals. Provides a tesseract to instantly swap back to your old clothes."
	desc_talisman = "Swap your clothes for the robes of Nar-Sie's followers. Significantly improves the efficiency of some rituals. Provides a tesseract to instantly swap back to your old clothes. Using the tesseract will also give you the talisman back, granted it has some uses left."
	invocation = "Sa tatha najin"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/destroy
	word3 = /datum/rune_word/other
	talisman_uses = 5
	page = "This rune, which you have to stand above to use, equips your character in cult apparel. Namely, a hood, robes, shoes, gloves, and a backpack.\
		<br><br>Wearing cult gear speeds up channeling of Conversion and Raise Structures runes, but the hood can also be toggled to hide your face and voice, granting you sweet anonymity (so long as you don't forget to pocket your ID card).\
		<br><br>After using the rune, a Blood Tesseract appears in your hand, containing clothes that had to be swapped out because you were already wearing them in your head/suit slots. \
		You can use it to get your clothing back instantly, or throw the tesseract to break it and get its content back this way.\
		<br><br>Lastly, the talisman version has 5 uses, and gets back in your hand after you use the Blood Tesseract. The inventory of your backpack gets always gets transferred upon use.\
		<br><br>This rune persists upon use, allowing repeated usage."
	var/list/slots_to_store = list(
		slot_shoes,
		slot_head,
		slot_gloves,
		slot_back,
		slot_wear_suit,
		slot_s_store,
		)

/datum/rune_spell/summonrobes/cast()
	var/obj/effect/rune/R = spell_holder
	if (istype(R))
		R.one_pulse()


	var/list/potential_targets = list()
	var/turf/TU = get_turf(spell_holder)

	var/snow = FALSE
	var/datum/zLevel/Z = map.zLevels[TU.z]
	if (istype(Z, /datum/zLevel/snowsurface))
		snow = TRUE

	for(var/mob/living/carbon/C in TU)
		potential_targets += C
	if(potential_targets.len == 0)
		to_chat(activator, "<span class='warning'>There needs to be someone standing or lying on top of the rune.</span>")
		qdel(src)
		return
	var/mob/living/carbon/target
	if(activator in potential_targets)
		target = activator
	else
		target = pick(potential_targets)

	if (!ishuman(target) && !ismonkey(target))
		qdel(src)
		return

	anim(target = target, a_icon = 'icons/effects/64x64.dmi', flick_anim = "rune_robes", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = ABOVE_LIGHTING_PLANE)

	var/obj/item/weapon/blood_tesseract/BT = new(get_turf(activator))
	if (istype (spell_holder,/obj/item/weapon/talisman))
		var/obj/item/weapon/talisman/T = spell_holder
		activator.u_equip(spell_holder)
		if (T.uses > 1)
			BT.remaining = spell_holder
			spell_holder.forceMove(BT)

	for(var/slot in slots_to_store)
		var/obj/item/user_slot = target.get_item_by_slot(slot)
		if (user_slot)
			BT.stored_gear[num2text(slot)] = user_slot
	//looping again in case the suit had a stored item
	for(var/slot in BT.stored_gear)
		var/obj/item/user_slot = BT.stored_gear[slot]
		BT.stored_gear[slot] = user_slot
		if(istype(user_slot, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = user_slot
			S.close(target)
		if(istype(user_slot, /obj/item/clothing/suit/storage))
			var/obj/item/clothing/suit/storage/S = user_slot
			S.hold.close(target)
		if(istype(user_slot, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = user_slot
			for (var/obj/item/clothing/accessory/storage/S in U.accessories)
				S.hold.close(target)
		target.u_equip(user_slot)
		user_slot.forceMove(BT)

	if(snow)
		if (ismonkey(target))
			target.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood/snow(target), slot_head)	// hood now comes from the robes for humans
			target.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes/snow(target), slot_w_uniform)
		else
			target.equip_to_slot_or_drop(new /obj/item/clothing/suit/cultrobes/snow(target), slot_wear_suit)
	else
		if (ismonkey(target))
			target.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood(target), slot_head)	// hood now comes from the robes for humans
			target.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes(target), slot_w_uniform)
		else
			target.equip_to_slot_or_drop(new /obj/item/clothing/suit/cultrobes(target), slot_wear_suit)

	if(isplasmaman(target))
		if (num2text(slot_s_store) in BT.stored_gear)
			var/obj/item/I = BT.stored_gear[num2text(slot_s_store)]
			BT.stored_gear -= num2text(slot_s_store)
			I.forceMove(target)
			target.equip_to_slot_or_drop(I, slot_s_store)

	if (!ismonkey(target))
		target.equip_to_slot_or_drop(new /obj/item/clothing/shoes/cult(target), slot_shoes)
		target.equip_to_slot_or_drop(new /obj/item/clothing/gloves/black/cult(target), slot_gloves)

	//transferring backpack items
	var/obj/item/weapon/storage/backpack/cultpack/new_pack = new (target)
	if ((num2text(slot_back) in BT.stored_gear))
		var/obj/item/stored_slot = BT.stored_gear[num2text(slot_back)]
		if (istype (stored_slot,/obj/item/weapon/storage/backpack))
			for(var/obj/item/I in stored_slot)
				I.forceMove(new_pack)
	target.equip_to_slot_or_drop(new_pack, slot_back)

	activator.put_in_hands(BT)
	if(iscultist(target))
		to_chat(target, "<span class='notice'>Robes and gear of the followers of Nar-Sie manifests around your body. You feel empowered.</span>")
	else
		to_chat(target, "<span class='warning'>Robes and gear of the followers of Nar-Sie manifests around your body. You feel sickened.</span>")
	to_chat(activator, "<span class='notice'>A [BT] materializes in your hand, you may use it to instantly swap back into your stored clothing.</span>")
	qdel(src)



////////////////////////////////////////////////////////////////////
//																  //
//								DOOR							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/door
	name = "Door"
	desc = "Raise a door to impede your enemies. It automatically opens and closes behind you, but the others may eventually break it down."
	desc_talisman = "Use to remotely trigger the rune and have it spawn a door to block your enemies."
	invocation = "Khari'd! Eske'te tannin!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/travel
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "This rune spawns a Cult Door immediately upon use, for a cost of 10u of blood.\
		<br><br>This rune cannot be activated if there's another cult door currently adjacent to it.\
		<br><br>Cult doors can be broken down relatively quickly with weapons, but let cultist move through them with barely any slowdown, making them great to retreat. Spawning them in maintenance will exasperate the crew.\
		<br><br>Lastly, the rune can be attuned to a talisman to be remotely activated. Allowing for interesting traps if the rune was concealed."
	cost_invoke = 10

/datum/rune_spell/door/cast()
	var/obj/effect/rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		if (locate(/obj/machinery/door/mineral/cult) in range(spell_holder,1))
			abort(RITUALABORT_NEAR)
		else
			new /obj/machinery/door/mineral/cult(get_turf(spell_holder))
			qdel(spell_holder)
	qdel(src)


////////////////////////////////////////////////////////////////////
//																  //
//								FERVOR							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/fervor
	name = "Fervor"
	desc = "Inspire nearby cultists to purge their stuns and raise their movement speed."
	desc_talisman = "Use to inspire nearby cultists to purge their stuns and raise their movement speed."
	invocation = "Khari'd! Gual'te nikka!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/technology
	word3 = /datum/rune_word/other
	page = "For a 20u blood cost, this rune immediately buffs all cultists in a 7 tile range by immediately removing any stuns, oxygen loss damage, holy water, and various other bad conditions.\
		<br><br>Additionally, it injects them with 1u of hyperzine, negating slowdown from low health or clothing. This makes it a very potent rune in a fight, especially as a follow up to a flash bang, or prior to a fight. Best used as a talisman. "
	cost_invoke = 20
	var/effect_range = 7

/datum/rune_spell/fervor/cast()
	var/obj/effect/rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		for(var/mob/living/L in range(effect_range,get_turf(spell_holder)))
			if (iscarbon(L))
				var/mob/living/carbon/C = L
				if (C.occult_muted())
					continue
			if(L.stat != DEAD && iscultist(L))
				playsound(L, 'sound/effects/fervor.ogg', 50, 0, -2)
				anim(target = L, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_fervor", lay = NARSIE_GLOW, plane = ABOVE_LIGHTING_PLANE, direction = L.dir)
				L.oxyloss = 0
				L.halloss = 0
				L.paralysis = 0
				L.stunned = 0
				L.knockdown = 0
				L.remove_jitter()
				L.next_pain_time = 0
				L.bodytemperature = 310
				L.blinded = 0
				L.eye_blind = 0
				L.eye_blurry = 0
				L.ear_deaf = 0
				L.ear_damage = 0
				L.say_mute = 0
				if(istype(L, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = L
					H.pain_shock_stage = 0
				L.update_canmove()
				L.stat = CONSCIOUS
				if (L.reagents)
					L.reagents.del_reagent(HOLYWATER)
					L.reagents.add_reagent(HYPERZINE,1)
		qdel(spell_holder)
	qdel(src)

////////////////////////////////////////////////////////////////////
//																  //
//							BLOOD MAGNETISM						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/bloodmagnetism
	name = "Blood Magnetism"
	desc = "Bring forth one of your fellow believers, no matter how far they are, as long as their heart beats."
	desc_talisman = "Use to begin the Blood Magnetism ritual where you stand."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	word1 = /datum/rune_word/join
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/self
	page = "This rune actually has two different rituals built into it:\
		<br><br>The first one, Summon Cultist, lets you summon a cultist from anywhere in the world whether they're alive or dead, for a cost of 50u of blood, which can be split by having other cultists participate in the ritual. \
		The ritual will fail however should the target cultist be anchored to their location, or have a holy implant.\
		<br><br>The second ritual, Rejoin Cultist, lets you summon yourself next to the target cultist instead for a cost of 15u of blood. \
		Other cultists can participate in the second ritual to accompany you, but the cost will remain 15u for every participating cultist. \
		Again, the ritual will fail if the target has a holy implant (or has been made to drink\
		<br><br>This rune persists upon use, allowing repeated usage."
	remaining_cost = 10
	cost_upkeep = 1
	var/rejoin = 0
	var/mob/target = null
	var/list/feet_portals = list()
	var/cost_summon = 50//you probably don't want to pay that up alone
	var/cost_rejoin = 15//static cost for every contributor

/datum/rune_spell/bloodmagnetism/Destroy()
	target = null
	for (var/guy in feet_portals)
		var/obj/O = feet_portals[guy]
		qdel(O)
		feet_portals -= guy
	feet_portals = list()
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	spell_holder.overlays -= image('icons/effects/effects.dmi',"rune_summon")
	..()


/datum/rune_spell/bloodmagnetism/abort()
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	spell_holder.overlays -= image('icons/effects/effects.dmi',"rune_summon")
	for (var/guy in feet_portals)
		var/obj/O = feet_portals[guy]
		qdel(O)
	..()

/datum/rune_spell/bloodmagnetism/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	rejoin = alert(activator, "Will you pull them toward you, or pull yourself toward them?","Blood Magnetism","Summon Cultist","Rejoin Cultist") == "Rejoin Cultist"

	var/list/possible_targets = list()
	var/list/prisoners = list()
	var/datum/faction/bloodcult/bloodcult = find_active_faction_by_member(iscultist(activator))
	for(var/datum/role/cultist/C in bloodcult.members)
		var/datum/mind/M = C.antag
		if (M.current)
			if (M.current.occult_muted())
				continue
			possible_targets.Add(M.current)

	//Prisoners are valid Blood Magnetism targets!
	for(var/obj/item/weapon/handcuffs/cult/cuffs in bloodcult.bindings)
		if (iscarbon(cuffs.loc))
			var/mob/living/carbon/C = cuffs.loc
			if (C.handcuffed == cuffs)
				prisoners.Add(C)

	var/list/annotated_targets = list()
	var/list/visible_mobs = viewers(activator)
	var/i = 1
	for(var/mob/M in possible_targets)
		var/status = ""
		if(M == activator)
			status = " (You)"
		else if(M in visible_mobs)
			status = " (Visible)"
		else if(M.isDead())
			status = " (Dead)"
		annotated_targets["\Roman[i]-[M.real_name][status]"] = M
		i++

	for(var/mob/M in prisoners)
		annotated_targets["\Roman[i]-[M.real_name] (Prisoner)"] = M
		i++

	var/choice = input(activator, "Choose who you wish to [rejoin ? "rejoin" : "summon"]", "Blood Magnetism") as null|anything in annotated_targets
	if (!choice)
		qdel(src)
		return
	target = annotated_targets[choice]
	if (!target)
		qdel(src)
		return

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
	if (!rejoin)
		spell_holder.overlays += image('icons/effects/effects.dmi',"rune_summon")
	else
		feet_portals.Add(activator)
		var/obj/effect/cult_ritual/feet_portal/P = new (activator.loc, activator, src)
		feet_portals[activator] = P
	to_chat(activator, "<span class='rose'>This ritual's blood toll can be substantially reduced by having multiple cultists partake in it.</span>")
	spawn()
		payment()

/datum/rune_spell/bloodmagnetism/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/bloodmagnetism/midcast(var/mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar
	if (rejoin)
		feet_portals.Add(add_cultist)
		var/obj/effect/cult_ritual/feet_portal/P = new (add_cultist.loc, add_cultist, src)
		feet_portals[add_cultist] = P

/datum/rune_spell/bloodmagnetism/proc/payment()//an extra payment is spent at the end of the channeling, and shared between contributors
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		for(var/mob/living/L in contributors)
			if (!iscultist(L) || !(L in range(spell_holder,1)) || (L.stat != CONSCIOUS))
				if (L.client)
					L.client.images -= progbar
				var/obj/effect/cult_ritual/feet_portal/P = feet_portals[L]
				qdel(P)
				feet_portals.Remove(L)
				contributors.Remove(L)
		//alright then, time to pay in blood
		var/amount_paid = 0
		for(var/mob/living/L in contributors)
			var/data = use_available_blood(L, cost_upkeep/contributors.len,contributors[L])//always 1u total per payment
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
				var/obj/effect/cult_ritual/feet_portal/P = feet_portals[L]
				qdel(P)
				feet_portals.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
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
				abort(RITUALABORT_BLOOD)
				return

		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/bloodmagnetism/proc/success()
	if (target.occult_muted())
		for(var/mob/living/L in contributors)
			to_chat(activator, "<span class='warning'>The ritual failed, the target seems to be under a curse that prevents us from reaching them through the veil.</span>")
	else
		if (rejoin)
			var/list/valid_turfs = list()
			for(var/turf/T in orange(target,1))
				if(!T.has_dense_content())
					valid_turfs.Add(T)
			if (valid_turfs.len)
				for(var/mob/living/L in contributors)
					use_available_blood(L, cost_rejoin,contributors[L])
					make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 3)
					var/atom/movable/overlay/landing_animation = anim(target = L, a_icon = 'icons/effects/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = SNOW_OVERLAY_LAYER, plane = EFFECTS_PLANE)
					playsound(L, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
					spawn(10)
						playsound(L, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
						new /obj/effect/bloodcult_jaunt(get_turf(L),L,pick(valid_turfs))
						flick("cult_jaunt_land",landing_animation)
		else
			if(target.locked_to || !isturf(target.loc))
				to_chat(target, "<span class='warning'>You feel that some force wants to pull you through the veil, but cannot proceed while you are buckled or inside something.</span>")
				for(var/mob/living/L in contributors)
					to_chat(activator, "<span class='warning'>The ritual failed, the target seems to be anchored to where they are.</span>")
			else
				for(var/mob/living/L in contributors)
					use_available_blood(L, cost_summon/contributors.len,contributors[L])
					make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 3)
				var/atom/movable/overlay/landing_animation = anim(target = src.target, a_icon = 'icons/effects/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = SNOW_OVERLAY_LAYER, plane = EFFECTS_PLANE)
				var/mob/M = target//so we keep track of them after the datum is ded until we jaunt
				var/turf/T = get_turf(spell_holder)
				playsound(M, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
				spawn(10)
					playsound(M, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
					new /obj/effect/bloodcult_jaunt(get_turf(M),M,T)
					flick("cult_jaunt_land",landing_animation)

	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/obj/effect/cult_ritual/feet_portal
	anchored = 1
	icon_state = "rune_rejoin"
	pixel_y = -10
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	flags = PROXMOVE
	var/mob/living/caster = null
	var/turf/source = null

/obj/effect/cult_ritual/feet_portal/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/seer/runespell)
	..()
	caster = user
	source = get_turf(runespell.spell_holder)
	if (!caster)
		qdel(src)
		return

/obj/effect/cult_ritual/feet_portal/Destroy()
	caster = null
	source = null
	..()

/obj/effect/cult_ritual/feet_portal/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		forceMove(get_turf(caster))

////////////////////////////////////////////////////////////////////
//																  //
//							PATH ENTRANCE						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/portalentrance
	name = "Path Entrance"
	desc = "Take a shortcut through the veil between this world and the other one."
	desc_talisman = "Use to remotely trigger the rune and force objects and creatures on top through the Path."
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/self
	word3 = /datum/rune_word/other
	talisman_absorb = RUNE_CAN_ATTUNE
	can_conceal = 1
	page = "This rune lets you set teleportation networks between any two tiles in the worlds, when used in combination with the Path Exit rune. \
		Upon its first use, the rune asks you to set a path for it to attune to. There are 10 possible paths, each corresponding to a cult word.\
		<br><br> Upon subsequent uses the rune will, after a 1 second delay, teleport everything not anchored above it to the Path Exit attuned to the same word (if there aren't any, no teleportation will occur).\
		<br><br>Talismans will remotely activate this rune.\
		<br><br>You can deactivate a Path Entrance by simply using the Erase Word spell on it once, and rewrite Other afterwards.\
		<br><br>Lastly if the crew destroys this rune using salt or holy salts, they will learn the direction toward the corresponding Exit if it's on the same level."
	var/network = ""

/datum/rune_spell/portalentrance/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = rune_words_english.Copy()

	network = input(activator, "Choose an available Path, you may change paths later by erasing the rune.", "Path Entrance") as null|anything in available_networks
	if (!network)
		qdel(src)
		return

	var/datum/rune_word/W = rune_words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('icons/obj/cult.dmi',"path_pad")
	I_crystals.plane = relative_plane_to_plane(OBJ_PLANE,spell_holder.plane)
	I_crystals.layer = BELOW_TABLE_LAYER
	var/image/I_stone = image('icons/obj/cult.dmi',"path_entrance")
	I_stone.plane = relative_plane_to_plane(ABOVE_TURF_PLANE,spell_holder.plane)
	I_stone.layer = ABOVE_TILE_LAYER
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.english]-0-[DEFAULT_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in rune_appearances_cache)
		I_network = image(rune_appearances_cache[lookup])
	else
		I_network = image('icons/effects/deityrunes.dmi',src,W.english)
		I_network.color = DEFAULT_BLOOD
	I_network.plane = relative_plane_to_plane(ABOVE_TURF_PLANE,spell_holder.plane)
	I_network.layer = BLOOD_LAYER
	I_network.transform /= 1.5
	I_network.pixel_x = round(W.offset_x*0.75)
	I_network.pixel_y = -3 + round(W.offset_y*0.75)

	spell_holder.overlays.len = 0
	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network
	custom_rune = TRUE

	to_chat(activator, "<span class='notice'>This rune will now let you travel through the \"[network]\" Path.</span>")

	if ((HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]") in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"]
		holomarker.id = HOLOMAP_MARKER_CULT_ENTRANCE
		holomarker.color = W.color
		holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"] = holomarker

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/portalentrance/midcast(var/mob/add_cultist)
	if (istype(spell_holder, /obj/item/weapon/talisman))
		invoke(add_cultist,invocation,1)
	else
		invoke(add_cultist,invocation)

	var/turf/destination = null
	for (var/datum/rune_spell/portalexit/P in bloodcult_exitportals)
		if (P.network == network)
			destination = get_turf(P.spell_holder)
			break

	if (!destination)
		to_chat(activator, "<span class='warning'>The \"[network]\" Path is closed. Set up a Path Exit rune to establish a Path.</span>")
		return

	var/turf/T = get_turf(spell_holder)
	var/atom/movable/overlay/landing_animation = anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "cult_jaunt_prepare", lay = SNOW_OVERLAY_LAYER, plane = EFFECTS_PLANE)
	playsound(T, 'sound/effects/cultjaunt_prepare.ogg', 75, 0, -3)
	spawn(10)
		playsound(T, 'sound/effects/cultjaunt_land.ogg', 30, 0, -3)
		new /obj/effect/bloodcult_jaunt(T,null,destination,T, activator = activator)
		flick("cult_jaunt_land",landing_animation)

/datum/rune_spell/portalentrance/midcast_talisman(var/mob/add_cultist)
	midcast(add_cultist)

/datum/rune_spell/portalentrance/salt_act(var/turf/T)
	var/turf/destination = null
	for (var/datum/rune_spell/portalexit/P in bloodcult_exitportals)
		if (P.network == network)
			destination = get_turf(P.spell_holder)
			new /obj/effect/bloodcult_jaunt/traitor(T,null,destination,null)
			break


////////////////////////////////////////////////////////////////////
//																  //
//								PATH EXIT						  //
//																  //
////////////////////////////////////////////////////////////////////

var/list/bloodcult_exitportals = list()

/datum/rune_spell/portalexit
	name = "Path Exit"
	desc = "We hope you enjoyed your flight with Air Nar-Sie."//might change it later or not.
	desc_talisman = "Use to immediately jaunt through the Path."
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/rune_word/travel
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/self
	talisman_absorb = RUNE_CAN_IMBUE
	can_conceal = 1
	page = "This rune lets you set free teleports between any two tiles in the worlds, when used in combination with the Path Entrance rune. \
		Upon its first use, the rune asks you to set a path for it to attune to. There are 10 possible paths, each corresponding to a cult word.\
		<br><br>Unlike for entrances, there may only exist 1 exit for each path.\
		<br><br>By using a talisman on an attuned rune, the talisman will teleport you to that rune immediately upon use.\
		<br><br>By using a talisman on a non-attuned rune, the rune will be absorbed instead, and you'll be able to set a destination path on the talisman, allowing you to check which path exits currently exist.\
		<br><br>You can deactivate a Path Exit by simply using the Erase Word spell on it once, and rewrite Self afterwards.\
		<br><br>Lastly if an empty jaunt bubble pops over the rune with an ominous noise, that means a corresponding path entrance has been destroyed and the location of this rune might end up compromised."
	var/network = ""

/datum/rune_spell/portalexit/New()
	..()
	bloodcult_exitportals.Add(src)

/datum/rune_spell/portalexit/Destroy()
	bloodcult_exitportals.Remove(src)
	..()

/datum/rune_spell/portalexit/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = rune_words_english.Copy()
	for (var/datum/rune_spell/portalexit/P in bloodcult_exitportals)
		if (P.network)
			available_networks -= P.network

	if (available_networks.len <= 0)
		to_chat(activator, "<span class='warning'>There is no room for any more Paths through the veil.</span>")
		qdel(src)
		return

	network = input(activator, "Choose an available Path, you may free the path later by erasing the rune.", "Path Exit") as null|anything in available_networks
	if (!network)
		qdel(src)
		return

	var/datum/rune_word/W = rune_words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('icons/obj/cult.dmi',"path_crystals")
	I_crystals.plane = relative_plane_to_plane(OBJ_PLANE,spell_holder.plane)
	I_crystals.layer = BELOW_TABLE_LAYER
	var/image/I_stone = image('icons/obj/cult.dmi',"path_stone")
	I_stone.plane = relative_plane_to_plane(ABOVE_TURF_PLANE,spell_holder.plane)
	I_stone.layer = ABOVE_TILE_LAYER
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.english]-0-[DEFAULT_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in rune_appearances_cache)
		I_network = image(rune_appearances_cache[lookup])
	else
		I_network = image('icons/effects/deityrunes.dmi',src,W.english)
		I_network.color = DEFAULT_BLOOD
	I_network.plane = relative_plane_to_plane(ABOVE_TURF_PLANE,spell_holder.plane)
	I_network.layer = BLOOD_LAYER
	I_network.transform /= 1.5
	I_network.pixel_x = round(W.offset_x*0.75)
	I_network.pixel_y = -3 + round(W.offset_y*0.75)

	spell_holder.overlays.len = 0
	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network
	custom_rune = TRUE

	to_chat(activator, "<span class='notice'>This rune will now serve as a destination for the \"[network]\" Path.</span>")

	if ((HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]") in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"]
		holomarker.id = HOLOMAP_MARKER_CULT_EXIT
		holomarker.color = W.color
		holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"] = holomarker

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/portalexit/midcast(var/mob/add_cultist)
	to_chat(add_cultist, "<span class='notice'>You may teleport to this rune by using a Path Entrance, or a talisman attuned to it.</span>")

/datum/rune_spell/portalexit/midcast_talisman(var/mob/add_cultist)
	var/turf/T = get_turf(add_cultist)
	invoke(add_cultist,invocation,1)
	anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_teleport")
	new /obj/effect/bloodcult_jaunt (T, add_cultist, get_turf(spell_holder))

/datum/rune_spell/portalexit/cast_talisman()
	var/obj/item/weapon/talisman/T = spell_holder
	T.uses++//so the talisman isn't deleted when setting the network
	var/list/valid_choices = list()
	for (var/datum/rune_spell/portalexit/P in bloodcult_exitportals)
		if (P.network)
			valid_choices.Add(P.network)
			valid_choices[P.network] = P
	if (valid_choices.len <= 0)
		to_chat(activator, "<span class='warning'>There are currently no Paths through the veil.</span>")
		qdel(src)
		return
	var/network = input(activator, "Choose an available Path.", "Path Talisman") as null|anything in valid_choices
	if (!network)
		qdel(src)
		return

	invoke(activator,"[rune_words_english[network]]!",1)

	to_chat(activator, "<span class='notice'>This talisman will now serve as a key to the \"[network]\" Path.</span>")

	var/datum/rune_spell/portalexit/PE = valid_choices[network]

	T.attuned_rune = PE.spell_holder
	T.word_pulse(rune_words[network])

/datum/rune_spell/portalexit/salt_act(var/turf/T)
	if (T != spell_holder.loc)
		var/turf/destination = null
		for (var/datum/rune_spell/portalexit/P in bloodcult_exitportals)
			if (P.network == network)
				destination = get_turf(P.spell_holder)
			new /obj/effect/bloodcult_jaunt/traitor(T,null,destination,null)
			break

////////////////////////////////////////////////////////////////////
//																  //
//								PULSE							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/pulse
	name = "Pulse"
	desc = "Scramble the circuits of nearby devices."
	desc_talisman = "Use to scramble the circuits of nearby devices."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/technology
	page = "This rune triggers a series of short-range EMPs that messes with electronic machinery, devices, and robots.\
		<br><br>Affects things up to 3 tiles away, but only adjacent targets will take the full force of the EMP.\
		<br><br>Best used as a talisman."

/datum/rune_spell/pulse/cast()
	var/turf/T = get_turf(spell_holder)
	playsound(T, 'sound/items/Welder2.ogg', 25, 1)
	T.hotspot_expose(700,125,surfaces=1)
	spawn(0)
		for(var/i = 0; i < 3; i++)
			empulse(T, 1, 3)
			sleep(20)
	qdel(spell_holder)

//RUNE XIX
/datum/rune_spell/astraljourney
	name = "Astral Journey"
	desc = "Channel a fragment of your soul into an astral projection so you can spy on the crew and communicate your findings with the rest of the cult."
	desc_talisman = "Leave your body so you can go spy on your enemies."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/travel
	word3 = /datum/rune_word/self
	page = "Upon use, your soul will float above your body, allowing you to freely move invisibly around the Z-Level. Words you speak while in this state will be heard by everyone in the cult. You can also become tangible which lets you converse with people, but taking any damage while in this state will end the ritual. Your body being moved away from the rune will also end the ritual. Should your body die while you were still using the rune, a shade will form wherever your astral projection stands."
	rune_flags = RUNE_STAND
	var/mob/living/simple_animal/astral_projection/astral = null
	var/cultist_key = ""
	var/list/restricted_verbs = list()

/datum/rune_spell/astraljourney/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	cultist_key = activator.key

	to_chat(activator, "<span class='notice'>As you recite the invocation, you feel your consciousness rise up in the air above your body.</span>")
	//astral = activator.ghostize(1,1)
	astral = new(activator.loc)
	astral.ascend(activator)
	activator.ajourn = src

	step(astral,NORTH)
	astral.dir = SOUTH

	spawn()
		handle_astral()

/datum/rune_spell/astraljourney/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)


/datum/rune_spell/astraljourney/abort(var/cause)
	qdel(astral)
	..()

/datum/rune_spell/astraljourney/proc/handle_astral()
	while(!destroying_self && activator && activator.stat != DEAD && astral && astral.loc && activator.loc == spell_holder.loc)
		sleep(10)
	abort()

/datum/rune_spell/astraljourney/Removed(var/mob/M)
	if (M == activator)
		abort(RITUALABORT_GONE)

////////////////////////////////////////////////////////////////////
//																  //
//							REINCARNATION						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/rune_spell/reincarnation
	name = "Reincarnation"
	desc = "Provide shades with a replica of their original body."
	desc_talisman = "Provide shades with a replica of their original body."
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!"
	word1 = /datum/rune_word/blood
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/hell
	page = "This rune lets you provide a shade with a body replicated from the one they originally had (or at least the one their soul remembers them having)\
		<br><br>The shade must stand above the rune for the ritual to begin. However mind that this rune has a very steep cost in blood of 300u that have to be paid over 60 seconds of channeling. \
		Other cultists can join in the ritual to help you share the burden you might prefer having a construct use their connection to the other side to bypass the blood cost entirely.\
		<br><br>Note that the resulting body might look much paler than the original, this is an unfortunate side-effect that you may have to resolve on your own.\
		<br><br>This rune persists upon use, allowing repeated usage."
	cost_upkeep = 5
	remaining_cost = 300
	var/obj/effect/cult_ritual/resurrect/husk = null
	var/mob/living/simple_animal/shade/shade = null

/datum/rune_spell/reincarnation/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	shade = locate(/mob/living/simple_animal/shade) in R.loc
	if (!shade)
		to_chat(activator, "<span class='warning'>There needs to be a shade standing above the rune.</span>")
		qdel(src)
		return

	husk = new (R.loc)
	flick("rune_resurrect_start", husk)
	shade.forceMove(husk)

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('icons/obj/cult.dmi',"build")
	to_chat(activator, "<span class='rose'>This ritual has a very high blood cost per second, but it can be completed faster by having multiple cultists partake in it.</span>")
	spawn()
		payment()

/datum/rune_spell/reincarnation/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/reincarnation/midcast(var/mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/reincarnation/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"build")
	if (shade)
		shade.loc = husk.loc
	if (husk)
		qdel(husk)
	if (spell_holder.loc && (!cause || cause != RITUALABORT_MISSING))
		new /obj/effect/gibspawner/human(spell_holder.loc)
	..()

/datum/rune_spell/reincarnation/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
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
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)//out of blood are we?
				contributors.Remove(L)
			else
				amount_paid += data[BLOODCOST_TOTAL]
				contributors[L] = data[BLOODCOST_RESULT]
				make_tracker_effects(L.loc,spell_holder, 1, "soul", 3, /obj/effect/tracker/drain, 1)//visual feedback

		accumulated_blood += amount_paid

		//if there's no blood for over 3 seconds, the channeling fails
		if (amount_paid)
			cancelling = 3
		else
			cancelling--
			if (cancelling <= 0)
				abort(RITUALABORT_BLOOD)
				return

		if (accumulated_blood >= remaining_cost)
			success()
			return

		update_progbar()

		sleep(10)
	message_admins("A rune ritual has iterated for over 1000 blood payment procs. Something's wrong there.")

/datum/rune_spell/reincarnation/proc/success()
	spell_holder.overlays -= image('icons/obj/cult.dmi',"build")
	var/resurrector = activator.real_name
	if (shade && husk)
		shade.loc = husk.loc
		var/mob/M = shade.reset_body()
		qdel(husk)
		playsound(M, 'sound/effects/spawn.ogg', 50, 0, 0)
		var/datum/role/cultist/newCultist = iscultist(M)
		if (!newCultist)
			newCultist = new
			newCultist.AssignToRole(M.mind,1)
			var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
			if (!cult)
				cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
			cult.HandleRecruitedRole(newCultist)
			newCultist.OnPostSetup()
			newCultist.Greet(GREET_RESURRECT)
			newCultist.conversion["resurrected"] = resurrector

		if (ishuman(M))
			var/mob/living/carbon/human/vessel = M
			vessel.my_appearance.r_hair = 218
			vessel.my_appearance.g_hair = 148
			vessel.my_appearance.b_hair = 123
			vessel.my_appearance.r_facial = 218
			vessel.my_appearance.g_facial = 148
			vessel.my_appearance.b_facial = 123
			vessel.my_appearance.r_eyes = 187
			vessel.my_appearance.g_eyes = 21
			vessel.my_appearance.b_eyes = 21
			vessel.my_appearance.s_tone = 45 // super duper albino

			// purely cosmetic tattoos. giving cultists some way to have tattoos until those get reworked
			newCultist.tattoos[TATTOO_POOL] = new /datum/cult_tattoo/bloodpool()
			newCultist.tattoos[TATTOO_HOLY] = new /datum/cult_tattoo/holy()
			newCultist.tattoos[TATTOO_MANIFEST] = new /datum/cult_tattoo/manifest()

			vessel.equip_or_collect(new /obj/item/clothing/under/leather_rags(vessel), slot_w_uniform)

		M.regenerate_icons()

	else
		for(var/mob/living/L in contributors)
			to_chat(activator, "<span class='warning'>Something went wrong with the ritual, the shade appears to have vanished.</span>")


	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

/obj/effect/cult_ritual/resurrect
	anchored = 1
	icon_state = "rune_resurrect"
	layer = SHADOW_LAYER
	plane = ABOVE_HUMAN_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/resurrect/New(turf/loc)
	..()
	overlays += "summoning"


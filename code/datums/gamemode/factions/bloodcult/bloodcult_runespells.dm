
#define RUNE_STAND	1

//Returns a rune spell based on the given 3 words.
/proc/get_rune_spell(var/mob/user, var/obj/spell_holder, var/use = "ritual", var/datum/runeset/word1, var/datum/runeset/word2, var/datum/runeset/word3)
	if(!word1 || !word2 || !word3)
		return
	for(var/runeset in subtypesof(/datum/rune_spell))
		for(var/runespell in subtypesof(runeset))
			var/datum/rune_spell/instance = runespell
			if(word1.type == initial(instance.word1) && word2.type == initial(instance.word2) && word3.type == initial(instance.word3))
				switch (use)
					if ("ritual")
						return new runespell(user, spell_holder, use)
					if ("examine")
						return instance
					if ("walk")
						if (initial(instance.walk_effect))
							return new runespell(user, spell_holder, use)
						else
							return null
					if ("imbue")
						return runespell
				return new runespell(user, spell_holder, use)
	return null

/proc/shadow(var/atom/C,var/turf/T,var/sprite="rune_blind")//based on the holopad rays I made a few months ago
	var/disty = C.y - T.y
	var/distx = C.x - T.x
	var/newangle
	if(!disty)
		if(distx >= 0)
			newangle = 90
		else
			newangle = 270
	else
		newangle = arctan(distx/disty)
		if(disty < 0)
			newangle += 180
		else if(distx < 0)
			newangle += 360
	var/matrix/M1 = matrix()
	var/matrix/M2 = turn(M1.Scale(1,sqrt(distx*distx+disty*disty)),newangle)
	return anim(target = C, a_icon = 'icons/effects/96x96.dmi', flick_anim = sprite, lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE, offY = -WORLD_ICON_SIZE, plane = LIGHTING_PLANE, trans = M2)


/datum/rune_spell //Abstract base. Includes channeled and instant use runes.
	var/name = "Cult Rune"		      //To be used for various purposes, in blood cult for tome entry.
	var/desc = "Does magical things."   //This one is used by blood cult for the tome as well.
	var/obj/spell_holder = null				//The rune or talisman calling the spell. If using a talisman calling an attuned rune, the holder is the rune.
	var/mob/activator = null				//The original mob that cast the spell
	var/runeset_identifier
	var/datum/runeword/word1 = null
	var/datum/runeword/word2 = null
	var/datum/runeword/word3 = null
	var/invocation = "Lo'Rem Ip'Sum"		//Spoken whenever cast.
	var/touch_cast = 0			//If set to 1, will proc cast_touch() when touching someone with an imbued talisman (example: Stun)
	var/can_conceal = 0			//If set to 1, concealing the rune will not abort the spell. (example: Path Exit)
	var/rune_flags = null 		//If set to RUNE_STAND (or 1), the user will need to stand right above the rune to use cast the spell
	var/walk_effect = 0 //If set to 1, procs Added() when step over

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

/datum/rune_spell/New(var/mob/user, var/obj/holder, var/use = "ritual", var/mob/target)
	spell_holder = holder
	activator = user

	if(use == "ritual")
		pre_cast()


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
	if(user.checkTattoo(TATTOO_SILENT))
		return
	if(!whisper)
		user.say(text,"C")
	else
		user.whisper(text)

/datum/rune_spell/proc/pre_cast() //Override for pre-cast checks.
	if(istype(spell_holder,/obj/effect/rune))
		if((rune_flags & RUNE_STAND) && (activator.loc != spell_holder.loc))
			abort(RITUALABORT_STAND)
		else
			invoke(activator,invocation)
			cast()

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
		if (RITUALABORT_SACRIFICE)
			if (activator)
				to_chat(activator, "<span class='warning'>Whether because of their defiance, or Nar-Sie's thirst for their blood, the ritual ends leaving behind nothing but a creepy chest.</span>")
		if (RITUALABORT_CONCEAL)
			if (activator)
				to_chat(activator, "<span class='warning'>The ritual is disrupted by the rune's sudden phasing out.</span>")
		if (RITUALABORT_NEAR)
			if (activator)
				to_chat(activator, "<span class='warning'>You cannot perform this ritual that close from another similar structure.</span>")
		if (RITUALABORT_OUTPOST)
			if (activator)
				to_chat(activator, "<span class='sinister'>The veil here is still too dense to allow raising structures from the realm of Nar-Sie. We must raise our structure in the heart of the station.</span>")
	..()


	for(var/mob/living/L in contributors)
		if (L.client)
			L.client.images -= progbar
		contributors.Remove(L)

	if (activator && activator.client)
		activator.client.images -= progbar

	if (progbar)
		progbar.loc = null

	if (HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]" in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"]
		holomarker.id = HOLOMAP_MARKER_CULT_RUNE
		holomarker.color = null
		holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"] = holomarker

	if (spell_holder.icon_state == "temp")
		qdel(spell_holder)
	else
		qdel(src)

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


////////////////////Blood Cult Runespells

/datum/rune_spell/blood_cult
	name = "Blood Cult Rune"
	desc = "Spooky."
	invocation = "Lo'Rem Ip'Sum"

	runeset_identifier = "blood_cult"

	var/desc_talisman = "It's a talisman."  //Talisman description. Non-cultists don't see this.
	var/talisman_absorb = RUNE_CAN_IMBUE	//Whether the rune is absorbed into the talisman (and thus deleted), or linked to the talisman (RUNE_CAN_ATTUNE)
	var/talisman_uses = 1					//How many times can a spell be cast from a single talisman. The talisman disappears upon the last use.

	var/Act_restriction = CULT_PROLOGUE		//locks the rune to the cult's progression
	var/page = "Lorem ipsum dolor sit amet, consectetur adipiscing elit,\
			 sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\
			  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut\
			   aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in\
			    voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint\
			     occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." //Arcane tome page description.
	var/constructs_can_use = 1

/datum/rune_spell/blood_cult/New(var/mob/user, var/obj/holder, var/use = "ritual", var/mob/target)
	spell_holder = holder
	activator = user

	if(use == "ritual")
		pre_cast()
	else if(use == "touch" && target)
		cast_touch(target) //Skips pre_cast() for talismans

/datum/rune_spell/blood_cult/pre_cast()
	if(Act_restriction > veil_thickness)
		to_chat(activator, "<span class='danger'>The veil is still too thick for you to draw power from this rune.</span>")
		switch(veil_thickness)
			if(CULT_PROLOGUE)
				to_chat(activator, "<span class='danger'>Raise an Altar.</span>")
			if(CULT_ACT_I)
				to_chat(activator, "<span class='danger'>Perform more conversions.</span>")
			if(CULT_ACT_II)
				to_chat(activator, "<span class='danger'>Perform the Sacrifice.</span>")
		return
	if(istype(spell_holder,/obj/effect/rune))
		if((rune_flags & RUNE_STAND) && (activator.loc != spell_holder.loc))
			abort(RITUALABORT_STAND)
		else
			invoke(activator,invocation)
			cast()
	else if(istype (spell_holder,/obj/item/weapon/talisman))
		invoke(activator,invocation,1)//talisman incantations are whispered
		cast_talisman()

/datum/rune_spell/blood_cult/proc/cast_talisman() //Override for unique talisman behavior.
	cast()

/datum/rune_spell/blood_cult/proc/cast_touch(var/mob/M) //Behavior on using the talisman on somebody. See - stun talisman.
	return

/datum/rune_spell/blood_cult/proc/midcast_talisman(var/mob/add_cultist)
	return



//RUNE I
/datum/rune_spell/blood_cult/raisestructure
	name = "Raise Structure"
	desc = "Drag-in eldritch structures from the realm of Nar-Sie."
	desc_talisman = "Use to begin raising a structure where you stand."
	Act_restriction = CULT_PROLOGUE
	word1 = /datum/runeword/blood_cult/blood
	word2 = /datum/runeword/blood_cult/technology
	word3 = /datum/runeword/blood_cult/join
	cost_upkeep = 1
	remaining_cost = 300
	accumulated_blood = 0
	page = "A very greedy rune. very thirsty. Alone, the ritual will be long and exhausting. With others, it will be quick and effortless. \
	 Nevertheless, an essential rune, for the cult needs an altar where to commune with Nar-Sie, and perform the Sacrifice when the time has come. \
	 As the veil thins and the blood flows, the altar will allow the cultists to perform new rituals, namely, the exchange of blood, for a shard of the Soulstone. \
	 You may use them to trap the souls of defeated foes, or channel those the dead. You can make even better use of them after raising a forge, and placing them \
	 inside a Construct Shell, or a Cult Blade. Lastly, raising an Arcaneum will let you permanently imbue your skin with a gift from Nar Sie. Follow your purpose \
	 and you may see even more gifts come your way."
	var/turf/loc_memory = null
	var/spawntype = /obj/structure/cult/altar

/datum/rune_spell/blood_cult/raisestructure/proc/proximity_check()
	var/obj/effect/rune/R = spell_holder
	if (locate(/obj/structure/cult) in range(R.loc,1))
		abort(RITUALABORT_BLOCKED)
		return FALSE

	if (locate(/obj/machinery/door/mineral/cult) in range(R.loc,1))
		abort(RITUALABORT_NEAR)
		return FALSE

	else return TRUE

/datum/rune_spell/blood_cult/raisestructure/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	var/mob/living/user = activator

	proximity_check() //See above

	if (veil_thickness < CULT_ACT_III && user.z != map.zMainStation)
		abort(RITUALABORT_OUTPOST)
		return FALSE

	var/list/choices = list(
		list("Altar", "radial_altar", "The nexus of a cult base. Has many uses. More runes will also become usable after the first altar has been raised."),
		list("Spire (locked)", "radial_locked1", "Reach Act 1 to unlock the Spire."),
		list("Forge (locked)", "radial_locked2", "Reach Act 2 to unlock the Forge.")
	)
	if(veil_thickness >= CULT_ACT_I)
		choices[2] = list("Spire", "radial_spire", "Lets human cultists acquire Arcane Tattoos, providing various buffs. New tattoos are available at each subsequent Act.")
	if(veil_thickness >= CULT_ACT_II)
		choices[3] = list("Forge", "radial_forge", "Can be used to forge of cult blades and armor, as well as construct shells. Standing close for too long without proper cult attire can be a searing experience.")

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
		if("Spire (locked)")
			to_chat(user,"Reach Act 1 to unlock the Spire. It allows human cultists to acquire Arcane Tattoos, providing various buffs.")
			abort()
			return
		if("Forge (locked)")
			to_chat(user,"Reach Act 2 to unlock the Forge. It enables the forging of cult blades and armor, as well as new construct shells.")
			abort()
			return

	loc_memory = spell_holder.loc
	contributors.Add(user)
	update_progbar()
	if(user.client)
		user.client.images |= progbar
	spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
	to_chat(activator, "<span class='rose'>This ritual's blood toll can be substantially reduced by having multiple cultists partake in it or by wearing cult attire.</span>")
	spawn()
		payment()

/datum/rune_spell/blood_cult/raisestructure/cast_talisman() //Raise structure talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/blood_cult/raisestructure/midcast(var/mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/blood_cult/raisestructure/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	..()

/datum/rune_spell/blood_cult/raisestructure/proc/payment()
	var/failsafe = 0
	while(failsafe < 1000)
		failsafe++
		//are our payers still here and about?
		var/summoners = 0
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

/datum/rune_spell/blood_cult/raisestructure/proc/success()
	new spawntype(spell_holder.loc)
	if (spawntype == /obj/structure/cult/altar)
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if(cult)
			cult.stage(CULT_ACT_I)
		else
			message_admins("Blood Cult: An altar was raised... but we cannot find the cult faction. Excellent bus.")
	qdel(spell_holder) //Deletes the datum as well.

//RUNE II
/datum/rune_spell/blood_cult/communication
	name = "Communication"
	desc = "Speak so that every cultists may hear your voice."
	desc_talisman = "Use it to write and send a message to all followers of Nar-Sie. When in the middle of a ritual, use it again to transmit a message that will be remembered by all."
	Act_restriction = CULT_PROLOGUE
	invocation = "O bidai nabora se'sma!"
	rune_flags = RUNE_STAND
	talisman_uses = 5
	var/obj/effect/cult_ritual/cult_communication/comms = null
	word1 = /datum/runeword/blood_cult/self
	word2 = /datum/runeword/blood_cult/other
	word3 = /datum/runeword/blood_cult/technology
	page = "You are not alone. Never forget it. The cult's true strength lies in its numbers, and how well each individual cooperates with the rest. \
		This rune is your main mean of cooperation. Its ritual lets you open a communication channel straight into the mind of every other cultists, \
		including constructs and soul blades. Just speak, and your words will instantly reach their minds. Keep the cult updated on your activities."

/datum/rune_spell/blood_cult/communication/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()
	var/mob/living/user = activator
	comms = new /obj/effect/cult_ritual/cult_communication(spell_holder.loc,user,src)

/datum/rune_spell/blood_cult/communication/midcast(var/mob/living/user)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!istype(cult))
		return
	if (!istype(user)) // Ghosts
		return
	var/reminder = input("Write the reminder.", text("Cult reminder")) as null | message
	if (!reminder)
		return
	reminder = utf8_sanitize(reminder) // No weird HTML
	var/number = cult.cult_reminders.len
	var/text = "[number + 1]) [reminder], by [user.real_name]."
	cult.cult_reminders += text
	for(var/datum/role/cultist/C in cult.members)
		var/datum/mind/M = C.antag
		if (M.GetRole(CULTIST))//failsafe for cultist brains put in MMIs
			to_chat(M.current, "<span class='game say'><b>[user.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[reminder]</span></span>")
			to_chat(M.current, "<span class='notice'>This message will be remembered by all current cultists, and by new converts as well.</span>")
			M.store_memory("Cult reminder: [text].")

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[user.real_name]</b> communicates, <span class='sinister'>[reminder]</span></span>. (Cult reminder)")

	log_cultspeak("[key_name(user)] Cult reminder: [reminder]")

/datum/rune_spell/blood_cult/communication/cast_talisman()//we write our message on the talisman, like in previous versions.
	var/message = sanitize(input("Write a message to send to your acolytes.", "Blood Letter", "") as null|message, MAX_MESSAGE_LEN)
	if(!message)
		return

	var/datum/faction/bloodcult = find_active_faction_by_member(activator.mind.GetRole(CULTIST))
	for(var/datum/role/cultist/C in bloodcult.members)
		var/datum/mind/M = C.antag
		if (M.GetRole(CULTIST))//failsafe for cultist brains put in MMIs
			to_chat(M.current, "<span class='game say'><b>[activator.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[message]</span></B></span>")

	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[activator.real_name]</b> communicates, <span class='sinister'>[message]</span></span>")

	log_cultspeak("[key_name(activator)] Cult Communicate Talisman: [message]")

	qdel(src)

/datum/rune_spell/blood_cult/communication/Destroy()
	destroying_self = 1
	if (comms)
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
	var/datum/rune_spell/blood_cult/communication/source = null


/obj/effect/cult_ritual/cult_communication/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/blood_cult/communication/runespell)
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
		var/datum/faction/bloodcult = find_active_faction_by_member(L.mind.GetRole(CULTIST))
		for(var/datum/role/cultist/C in bloodcult.members)
			var/datum/mind/M = C.antag
			if (M.current == speech.speaker)//echoes are annoying
				continue
			if (M.GetRole(CULTIST))//failsafe for cultist brains put in MMIs
				to_chat(M.current, "<span class='game say'><b>[speaker_name]</b>'s voice echoes in your head, <B><span class='sinister'>[speech.message]</span></B></span>")
		for(var/mob/dead/observer/O in player_list)
			to_chat(O, "<span class='game say'><b>[speaker_name]</b> communicates, <span class='sinister'>[speech.message]</span></span>")
		log_cultspeak("[key_name(speech.speaker)] Cult Communicate Rune: [rendered_message]")

/obj/effect/cult_ritual/cult_communication/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)

//RUNE III
/datum/rune_spell/blood_cult/summontome
	name = "Summon Tome"
	desc = "Bring forth an arcane tome filled with Nar-Sie's knowledge."
	desc_talisman = "Turns into an arcane tome upon use."
	Act_restriction = CULT_ACT_I
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	word1 = /datum/runeword/blood_cult/see
	word2 = /datum/runeword/blood_cult/blood
	word3 = /datum/runeword/blood_cult/hell
	cost_invoke = 4
	page = "Knowledge is of the essence. Becoming useful to the cult isn't simple, but having a desire to learn and improve is the first step. \
		This rune is the first step on this journey, you don't have to study all the runes right away but the answer to your current conundrum could be in one of them. \
		The tome in your hands is the produce of this ritual, by having it open in your hands, the meaning of every rune can freely flow into your mind, \
		which means that you can trace them more easily. Be mindful though, if anyone spots this tome in your hand, your devotion to Nar-Sie will be immediately exposed."

/datum/rune_spell/blood_cult/summontome/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		spell_holder.visible_message("<span class='rose'>The rune's symbols merge into each others, and an Arcane Tome takes form in their place</span>")
		var/turf/T = get_turf(spell_holder)
		var/obj/item/weapon/tome/AT = new (T)
		anim(target = AT, a_icon = 'icons/effects/effects.dmi', flick_anim = "tome_spawn")
		qdel(spell_holder)
	else
		qdel(src)

/datum/rune_spell/blood_cult/summontome/cast_talisman()//The talisman simply turns into a tome.
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
/datum/rune_spell/blood_cult/conjuretalisman
	name = "Conjure Talisman"
	desc = "Can turn some runes into talismans."
	desc_talisman = "LIKE, HOW, NO SERIOUSLY CALL AN ADMIN."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	Act_restriction = CULT_ACT_I
	word1 = /datum/runeword/blood_cult/hell
	word2 = /datum/runeword/blood_cult/technology
	word3 = /datum/runeword/blood_cult/join
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


/datum/rune_spell/blood_cult/conjuretalisman/cast()
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
		if (pay_blood())
			R.one_pulse()
			spell_holder.visible_message("<span class='rose'>The blood drops merge into each others, and a talisman takes form in their place</span>")
			var/turf/T = get_turf(spell_holder)
			AT = new (T)
			anim(target = AT, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_imbue")
		qdel(src)

/datum/rune_spell/blood_cult/conjuretalisman/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	..()


/datum/rune_spell/blood_cult/conjuretalisman/cast_talisman()//there should be no ways for this to ever proc
	return


/datum/rune_spell/blood_cult/conjuretalisman/proc/payment()
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

/datum/rune_spell/blood_cult/conjuretalisman/proc/success()
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

//RUNE V
/datum/rune_spell/blood_cult/conversion
	name = "Conversion"
	desc = "The unenlightened will be made humble before Nar-Sie, or their lives will come to a fantastic end."
	desc_talisman = "Use to remotely trigger the rune and incapacitate someone on top."
	Act_restriction = CULT_ACT_I
	invocation = "Mah'weyh pleggh at e'ntrath!"
	word1 = /datum/runeword/blood_cult/join
	word2 = /datum/runeword/blood_cult/blood
	word3 = /datum/runeword/blood_cult/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "The cult needs many followers to properly thrive, but the teachings of Nar-Sie are extensive, and most cultists learned them over the course of many years. \
		You won't always have that sort of time however, this is what the Conversion ritual is for. By making an unbeliever appear before Nar-Sie, their eyes will open \
		in a matter of seconds, that is, if their mind can handle it. Those either too weak, or of an impenetrable mind will be purged, and devoured by Nar-Sie. \
		In this case, their remains will be converted into a container where to retrieve their belongings, along with a portion of their blood. \
		Also, know that you can quicken the ritual by wearing formal cult attire, and that the vessel will remain incapacitated for the duration of the ritual."
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


/datum/rune_spell/blood_cult/conversion/Destroy()
	if(conversion)
		conversion.Die()
	..()

/datum/rune_spell/blood_cult/conversion/update_progbar()//progbar tracks conversion progress instead of paid blood
	if (!progbar)
		progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = spell_holder, "icon_state" = "prog_bar_0")
		progbar.pixel_z = WORLD_ICON_SIZE
		progbar.plane = HUD_PLANE
		progbar.layer = HUD_ABOVE_ITEM_LAYER
		progbar.appearance_flags = RESET_COLOR
	progbar.icon_state = "prog_bar_[min(100,round((100-remaining), 10))]"
	return

/datum/rune_spell/blood_cult/conversion/cast()
	var/obj/effect/rune/R = spell_holder
	var/mob/converter = activator//trying to fix logs showing the converter as *null*

	R.one_pulse()
	var/turf/T = R.loc
	var/list/targets = list()

	//first lets check for a victim above
	for (var/mob/living/silicon/S in T) // Has science gone too far????
		if (S.cult_permitted || Holiday == APRIL_FOOLS_DAY)
			if (!iscultist(S))
				targets.Add(S)

	for (var/mob/living/carbon/C in T)//all carbons can be converted...but only carbons. no cult silicons.
		if (!iscultist(C))
			targets.Add(C)
	if (targets.len > 0)
		victim = pick(targets)
	else
		to_chat(activator, "<span class='warning'>There needs to be a potential convert standing or lying on top of the rune.</span>")
		qdel(src)
		return

	update_progbar()
	if (activator.client)
		activator.client.images |= progbar

	//secondly, let's stun our victim and begin the ritual
	to_chat(victim, "<span class='danger'>Occult energies surge from below your [issilicon(victim) ? "actuators" : "feet"] and seep into your [issilicon(victim) ? "chassis" : "body"].</span>")
	victim.Silent(5)
	victim.Knockdown(5)
	victim.Stun(5)
	victim.overlay_fullscreen("conversionborder", /obj/abstract/screen/fullscreen/conversion_border)
	victim.overlay_fullscreen("conversionred", /obj/abstract/screen/fullscreen/conversion_red)
	victim.update_fullscreen_alpha("conversionred", 255, 5)
	victim.update_fullscreen_alpha("conversionborder", 255, 5)
	conversion = new(T)
	flick("rune_convert_start",conversion)
	playsound(R, 'sound/effects/convert_start.ogg', 75, 0, -4)

	for(var/obj/item/device/gps/secure/SPS in get_contents_in_object(victim))
		SPS.OnMobDeath(victim)//Think carefully before converting a sec officer

	if (victim.mind)
		if (victim.mind.assigned_role in impede_medium)
			to_chat(victim, "<span class='warning'>Your sense of duty impedes down the ritual.</span>")
			to_chat(activator, "<span class='warning'>Their will is strong, the ritual will take longer.</span>")

		if (victim.mind.assigned_role in impede_hard)
			to_chat(victim, "<span class='warning'>Your devotion to higher causes impedes the ritual.</span>")
			to_chat(activator, "<span class='warning'>Their willpower is amazing, the ritual will be exhausting.</span>")

	for(var/obj/item/weapon/implant/loyalty/I in victim)
		if(I.implanted)
			to_chat(victim, "<span class='warning'>Your loyalty implants drastically slows down the ritual's progression.</span>")
			to_chat(activator, "<span class='warning'>Their mind seems to reject the ritual by reflex. The ritual will take much longer.</span>")
			break


	spawn()
		while (remaining > 0)
			if (destroying_self || !spell_holder || !activator || !victim)
				return
			//first let's make sure they're on the rune
			if (victim.loc != T)//Removed() should take care of it, but just in case
				victim.clear_fullscreen("conversionred", 10)
				victim.clear_fullscreen("conversionborder", 10)
				playsound(R, 'sound/effects/convert_abort.ogg', 50, 0, -4)
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
					playsound(R, 'sound/effects/convert_abort.ogg', 50, 0, -4)
					conversion.icon_state = ""
					flick("rune_convert_abort",conversion)
					abort(RITUALABORT_GONE)
					return

			else
				playsound(R, 'sound/effects/convert_process.ogg', 10, 0, -4)
				//then progress through the ritual
				victim.Silent(5)
				victim.Knockdown(5)
				victim.Stun(5)
				var/progress = 10//10 seconds to reach second phase for a naked cultist
				progress += activator.get_cult_power()//down to 1-2 seconds when wearing cult gear
				var/delay = 0
				for(var/obj/item/weapon/implant/loyalty/I in victim)
					if(I.implanted)
						delay = 1
						progress = progress/4
						break
				if (victim.mind)
					if (victim.mind.assigned_role in impede_medium)
						progress = progress/2

					if (victim.mind.assigned_role in impede_hard)
						delay = 1
						progress = progress/4

				if (delay)
					progress = Clamp(progress,1,10)
				remaining -= progress
				update_progbar()
				victim.update_fullscreen_alpha("conversionred", 164-remaining, 8)

				//spawning some messages
				var/threshold = min(100,round((100-remaining), 10))
				if (flavor_text < 3)
					if (flavor_text == 0 && threshold > 10)//it's ugly but gotta account for the possibility of several messages appearing at once
						to_chat(victim, "<span class='sinister'>Your blood pulses.</span>")
						flavor_text++
					if (flavor_text == 1 && threshold > 40)
						to_chat(victim, "<span class='sinister'>Your head throbs.</span>")
						flavor_text++
					if (flavor_text == 2 && threshold > 70)
						to_chat(victim, "<span class='sinister'>The world goes red.</span>")
						flavor_text++
			sleep(10)

		if (activator && activator.client)
			activator.client.images -= progbar

		//alright, now the second phase, which always lasts an additional 10 seconds, but no longer requires the proximity of the activator.
		var/acceptance = "Never"
		victim.Silent(15)
		victim.Knockdown(15)
		victim.Stun(15)

		if (victim.client && victim.mind.assigned_role != "Chaplain")//Chaplains can never be converted
			acceptance = get_role_desire_str(victim.client.prefs.roles[CULTIST])
		if (jobban_isbanned(victim, CULTIST) || isantagbanned(victim))
			acceptance = "Banned"

		//Players with cult enabled in their preferences will always get converted.
		//Others get a choice, unless they're cult-banned or have their preferences set to Never (or disconnected), in which case they always die.
		switch (acceptance)
			if ("Always","Yes")
				conversion.icon_state = "rune_convert_good"
				to_chat(activator, "<span class='sinister'>\The [victim] effortlessly opens himself to the teachings of Nar-Sie. They will undoubtedly become one of us when the ritual concludes.</span>")
				to_chat(victim, "<span class='sinister'>Your begin hearing strange words, straight into your mind. Somehow you think you can understand their meaning. A sense of dread and fascination comes over you.</span>")
				success = CONVERSION_ACCEPT
			if ("No","???")
				to_chat(activator, "<span class='sinister'>The ritual arrives in its final phase. How it ends depends now of \the [victim].</span>")
				spawn()
					if (alert(victim, "You feel the gaze of an alien entity, it speaks into your mind. It has much to share with you, but time is of the essence. Will you open your mind to it? Or will you become its sustenance? Decide now!","You have 10 seconds","Join the Cult","Be Devoured") == "Join the Cult")
						conversion.icon_state = "rune_convert_good"
						success = CONVERSION_ACCEPT
						to_chat(victim, "<span class='sinister'>As you let the strange words into your mind, you find yourself suddenly understanding their meaning. A sense of dread and fascination comes over you.</span>")
					else
						conversion.icon_state = "rune_convert_bad"
						to_chat(victim, "<span class='danger'>You won't let it have its way with you! Better die now as a human, than serve them.</span>")
						success = CONVERSION_REFUSE

			if ("Never","Banned")
				conversion.icon_state = "rune_convert_bad"
				to_chat(activator, "<span class='sinister'>\The [victim]'s mind appears to be completely impervious to the Geometer of Blood's words of power. If they won't become one of us, they won't need their body any longer.</span>")
				to_chat(victim, "<span class='danger'>A sense of dread comes over you, as you feel under the gaze of a cosmic being. You cannot hear its voice, but you can feel its thirst...for your blood!</span>")
				success = CONVERSION_REFUSE

		//since we're no longer checking for the cultist's adjacency, let's finish this ritual without a loop
		sleep(100)

		if (destroying_self || !spell_holder || !activator || !victim)
			return

		if (victim.loc != T)//Removed() should take care of it, but just in case
			victim.clear_fullscreen("conversionred", 10)
			victim.clear_fullscreen("conversionborder", 10)
			playsound(R, 'sound/effects/convert_abort.ogg', 50, 0, -4)
			conversion.icon_state = ""
			flick("rune_convert_abort",conversion)
			abort(RITUALABORT_REMOVED)
			return

		//No matter the end result, counts as progress toward the cult's goals, as long as the victim was an actual player
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (victim.mind)
			if (cult)
				spawn(5)//waiting half a second to make sure that the sacrifice objective won't designate a victim that just refused conversion
					cult.stage(CULT_ACT_II)
			else
				message_admins("Blood Cult: A conversion ritual occured...but we cannot find the cult faction...")//failsafe in case of admin varedit fuckery
			cult_risk(activator)//risk of exposing the cult early if too many conversions

		switch (success)
			if (CONVERSION_ACCEPT)
				conversion.layer = BELOW_OBJ_LAYER
				conversion.plane = OBJ_PLANE
				victim.clear_fullscreen("conversionred", 10)
				victim.clear_fullscreen("conversionborder", 10)
				playsound(R, 'sound/effects/convert_success.ogg', 75, 0, -4)
				//new cultists get purged of the debuffs
				victim.SetKnockdown(0)
				victim.SetStunned(0)
				victim.SetSilent(0)
				//and their loyalty implants are removed, so they can't mislead security
				for(var/obj/item/weapon/implant/loyalty/I in victim)
					I.forceMove(T)
					I.implanted = 0
					spell_holder.visible_message("<span class='warning'>\The [I] pops out of \the [victim]'s head.</span>")
				convert(victim, converter)
				conversion.icon_state = ""
				flick("rune_convert_success",conversion)
				abort(RITUALABORT_CONVERT)
				message_admins("BLOODCULT: [key_name(victim)] has been converted by [key_name(converter)].")
				log_admin("BLOODCULT: [key_name(victim)] has been converted by [key_name(converter)].")
				if (issilicon(victim))
					var/mob/living/silicon/S = victim
					S.laws = new /datum/ai_laws/cultimov
					to_chat(S, "<span class='sinister'>Laws updated.</span>")
					S << sound('sound/machines/lawsync.ogg')
					if (isrobot(S))
						var/mob/living/silicon/robot/robit = S
						robit.disconnect_AI()
				return
			if (CONVERSION_NOCHOICE)
				to_chat(victim, "<span class='danger'>As you stood there, unable to make a choice for yourself, the Geometer of Blood ran out of patience and chose for you.</span>")
			if (CONVERSION_REFUSE)
				to_chat(victim, "<span class='danger'>Your mind was impervious to the teachings of Nar-Sie. Being of no use for the cult, your body was be devoured when the ritual ended. Your blood and equipment now belong to the cult.</span>")
				switch(acceptance)
					if ("Never")
						to_chat(victim, "The conversion automatically failed due to your cult preferences being set to Never. By setting them to No, you may instead choose whether to accept or refuse a conversion.")
					if ("Banned")
						to_chat(victim, "The conversion automatically failed due to your account being banned from the cultist role.")

		cult.send_flavour_text_refuse(victim, converter)
		message_admins("BLOODCULT: [key_name(victim)] refused conversion by [key_name(converter)], and died.")
		log_admin("BLOODCULT: [key_name(victim)] refused conversion by [key_name(converter)], and died.")
		to_chat(converter, "<span class='sinister'>\The [victim] was pulled through the veil, their body was devoured by Nar-Sie and their possession stored inside this coffer.</span>")

		playsound(R, 'sound/effects/convert_failure.ogg', 75, 0, -4)
		conversion.icon_state = ""
		flick("rune_convert_failure",conversion)

		//sacrificed victims have all their stuff stored in a coffer that also contains their skull and a cup of their blood, should they have either
		var/obj/item/weapon/storage/cult/coffer = new(T)
		var/obj/item/weapon/reagent_containers/food/drinks/cult/cup = new(coffer)
		if (istype(victim,/mob/living/carbon/human) && victim.dna)
			victim.take_blood(cup, cup.volume)//Up to 60u
			cup.on_reagent_change()//so we get the reagentsfillings overlay
			new/obj/item/weapon/skull(coffer)
			to_chat(converter, "<span class='sinister'>Inside you may also find a cup filled with a portion of the blood left in their body, along with their skull to potentially use in a resurrection ritual.</span>")
		if (isslime(victim))
			cup.reagents.add_reagent(SLIMEJELLY, 50)
			to_chat(converter, "<span class='sinister'>Inside you may also find a cup filled with a slimy substance.</span>")
		if (isalien(victim))//w/e
			cup.reagents.add_reagent(RADIUM, 50)
			to_chat(converter, "<span class='sinister'>Inside you may also find a cup filled with a green radioactive liquid.</span>")

		for(var/obj/item/weapon/implant/loyalty/I in victim)
			I.implanted = 0
		for(var/obj/item/I in victim)
			victim.u_equip(I)
			if(I)
				I.forceMove(victim.loc)
				I.reset_plane_and_layer()
				I.dropped(victim)
				I.forceMove(coffer)

		qdel(victim)
		abort(RITUALABORT_SACRIFICE)

/datum/rune_spell/blood_cult/conversion/proc/convert(var/mob/M, var/mob/converter)
	var/datum/role/cultist/newCultist = new
	newCultist.AssignToRole(M.mind,1)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!cult)
		cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
	cult.HandleRecruitedRole(newCultist)
	newCultist.OnPostSetup()
	newCultist.Greet(GREET_CONVERTED)
	cult.send_flavour_text_accept(victim, converter)
	newCultist.conversion["converted"] = activator

/datum/rune_spell/blood_cult/conversion/Removed(var/mob/M)
	if (victim == M)
		playsound(spell_holder, 'sound/effects/convert_abort.ogg', 50, 0, -4)
		conversion.icon_state = ""
		flick("rune_convert_abort",conversion)
		abort(RITUALABORT_REMOVED)

/datum/rune_spell/blood_cult/conversion/cast_talisman()//handled by /obj/item/weapon/talisman/proc/trigger instead
	return

/datum/rune_spell/blood_cult/conversion/abort(var/cause)
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
	plane = LIGHTING_PLANE
	mouse_opacity = 0

/obj/effect/cult_ritual/conversion/proc/Die()
	spawn(10)
		qdel(src)

//RUNE VI
/datum/rune_spell/blood_cult/stun
	name = "Stun"
	desc = "Overwhelm everyone's senses with a blast of pure chaotic energy. Cultists will recover their senses a bit faster."
	desc_talisman = "Use to produce a smaller radius blast, or touch someone with it to focus the entire power of the spell on their person."
	Act_restriction = CULT_ACT_I
	invocation = "Fuu ma'jin!"
	touch_cast = 1
	word1 = /datum/runeword/blood_cult/join
	word2 = /datum/runeword/blood_cult/hide
	word3 = /datum/runeword/blood_cult/technology
	page = "Many fear the cult for their powers. Some seek refuge in religion, but no one will be spared from the chaotic energies at work in this ritual. Yourself included. \
		By itself, it is a very unstable and dangerous rune that cultists should only ever use when in a pinch, or to create a state of chaos, but other runes already fit \
		that purpose better, namely, the Blind and Deaf-Mute runes. Unlike those runes, cultists will also be affected by the energy released, although they will recover their senses faster. \
		HOWEVER, this rune can be put to a much better use, once it has been imbued into a talisman. By touching someone with this talisman, the entire power of the rune will be focus on their \
		person, paralyzing them for almost half a minute, and muting them for half that duration."


/datum/rune_spell/blood_cult/stun/pre_cast()
	if (Act_restriction > veil_thickness)
		to_chat(activator, "<span class='danger'>The veil is still too thick for you to draw power from this rune.</span>")
		return

	var/mob/living/user = activator

	if (istype (spell_holder,/obj/effect/rune))
		invoke(user,invocation)
		cast()
	else if (istype (spell_holder,/obj/item/weapon/talisman))
		invoke(user,invocation,1)
		cast_talisman()

/datum/rune_spell/blood_cult/stun/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	new/obj/effect/cult_ritual/stun(R.loc)

	qdel(R)

/datum/rune_spell/blood_cult/stun/cast_talisman()
	var/turf/T = get_turf(spell_holder)
	new/obj/effect/cult_ritual/stun(T,2)
	qdel(src)

/datum/rune_spell/blood_cult/stun/cast_touch(var/mob/M)
	anim(target = M, a_icon = 'icons/effects/64x64.dmi', flick_anim = "touch_stun", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = LIGHTING_PLANE)

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

	if (!(locate(/obj/effect/stun_indicator) in M))
		new /obj/effect/stun_indicator(M)

	qdel(src)

/obj/effect/cult_ritual/stun
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	mouse_opacity = 0
	var/stun_duration = 5

/obj/effect/cult_ritual/stun/New(turf/loc,var/type=1)
	..()
	switch (type)
		if (1)
			stun_duration++
			flick("rune_stun",src)
		if (2)
			stun_duration--
			flick("talisman_stun",src)

	playsound(src, 'sound/effects/stun_rune.ogg', 75, 0, 0)
	spawn(10)
		visible_message("<span class='warning'>The rune explodes in a bright flash of chaotic energies.</span>")

		for(var/mob/living/L in viewers(src))
			var/duration = stun_duration
			if (type == 2 && get_dist(L,src)>=5)//talismans have a reduced range
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

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Knockdown(duration)//TODO: TEST THAT
		qdel(src)

var/list/blind_victims = list()

//RUNE VII
/datum/rune_spell/blood_cult/blind
	name = "Confusion"//Can't just call it "blind" anymore, can we?
	desc = "Sow panic in the mind of your enemies, and obscure cameras."
	desc_talisman = "Sow panic in the mind of your enemies, and obscure cameras. The effect is shorter than when used from a rune."
	Act_restriction = CULT_ACT_I
	invocation = "Sti' kaliesin!"
	word1 = /datum/runeword/blood_cult/destroy
	word2 = /datum/runeword/blood_cult/see
	word3 = /datum/runeword/blood_cult/other
	page = "This ritual projects the thoughts of Nar-Sie onto any visible enemy, giving them a taste of the future, and making them unable to differentiate \
		their allies from our believers. The effects of surprise is especially powerful in the first few seconds. The confusion expires after half a minute, \
		a bit less when cast from a talisman. A side effect of the ritual appears to obscure the screens of cameras in range, and until anyone repairs them. \
		This makes it essential for keeping cult activities undercover from the eyes of the authorities. Robots will be briefly blinded by the ritual."
	var/rune_duration=300//times are in tenths of a second
	var/talisman_duration=200
	var/hallucination_radius=25

/datum/rune_spell/blood_cult/blind/cast(var/duration = rune_duration)
	new /obj/effect/cult_ritual/confusion(spell_holder,duration,hallucination_radius)
	qdel(spell_holder)

/datum/rune_spell/blood_cult/blind/cast_talisman()//talismans have the same range, but the effect lasts shorter.
	cast(talisman_duration)

/obj/effect/cult_ritual/confusion
	anchored = 1
	icon = 'icons/effects/64x64.dmi'
	icon_state = ""
	pixel_x = -WORLD_ICON_SIZE/2
	pixel_y = -WORLD_ICON_SIZE/2
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	mouse_opacity = 0
	var/duration = 5
	var/hallucination_radius=25

/obj/effect/cult_ritual/confusion/New(turf/loc,var/duration=300,var/radius=25,var/mob/specific_victim=null)
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
				if (uristrune_cache.len > 0 && prob(7))
					var/lookup = pick(uristrune_cache)//finally a good use for that cache
					var/icon/I = uristrune_cache[lookup]
					I_turf.overlays.Add(I)
			hallucinated_turfs.Add(I_turf)

	//now let's round up our victims: any non-cultist with an unobstructed line of sight to the rune/talisman will be affected
	var/list/potential_victims = list()
	var/list/victims = list()

	if (specific_victim)
		potential_victims.Add(specific_victim)
	else
		for(var/mob/living/M in viewers(T))
			potential_victims.Add(M)

	for(var/mob/living/M in potential_victims)
		if (iscarbon(M))//mite do something with silicons later
			var/mob/living/carbon/C = M
			if (iscultist(C))
				continue
			to_chat(C, "<span class='danger'>Your vision goes dark, panic and paranoia take their toll on your mind.</span>")
			shadow(C,T)//shadow trail moving from the spell_holder to the victim
			anim(target = C, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_blind", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
			if (!(C in blind_victims))
				C.overlay_fullscreen("blindborder", /obj/abstract/screen/fullscreen/conversion_border)//victims DO still get blinded for a second
				C.overlay_fullscreen("blindblack", /obj/abstract/screen/fullscreen/black)//which will allow us to subtly reveal the surprise
				C.update_fullscreen_alpha("blindblack", 255, 5)
			else
				C.update_fullscreen_alpha("blindblack", 255, 5)
			C.playsound_local(C, 'sound/effects/confusion.ogg', 50, 0, 0, 0, 0)
			victims.Add(C)
		if (issilicon(M) && !isAI(M))//Silicons get a fade to black, then just a flash, until I can think of something else
			shadow(M,T)
			M.overlay_fullscreen("blindblack", /obj/abstract/screen/fullscreen/black)
			M.update_fullscreen_alpha("blindblack", 255, 5)
			spawn(5)
				M.clear_fullscreen("blindblack", animate = 0)
				M.flash_eyes(visual = 1)
	if (!specific_victim)
		for(var/obj/machinery/camera/C in view(T))//the effects on cameras do not time out, but they can be fixed
			shadow(C,T)
			var/col = C.color
			animate(C, color = col, time = 4)
			animate(color = "black", time = 5)
			animate(color = col, time = 5)
			C.vision_flags = BLIND//Anyone using a security cameras computer will only see darkness
			C.setViewRange(-1)//The camera won't reveal the area for the AI anymore

	spawn(10)
		for(var/mob/living/carbon/C in victims)
			var/new_victim = 0
			if (!(C in blind_victims))
				new_victim = 1
				C.overlay_fullscreen("blindblind", /obj/abstract/screen/fullscreen/blind)
			C.update_fullscreen_alpha("blindblind", 255, 0)
			C.update_fullscreen_alpha("blindblack", 0, 10)
			C.update_fullscreen_alpha("blindblind", 0, 80)
			C.update_fullscreen_alpha("blindborder", 150, 5)
			if (C.client)
				var/list/my_hallucinated_stuff = hallucinated_turfs.Copy()
				for(var/mob/living/L in range(T,25))//All mobs in a large radius will look like monsters to the victims.
					if (L == C || !("cult" in L.static_overlays))
						continue//the victims still see themselves as humans (or whatever they are)
					my_hallucinated_stuff.Add(L.static_overlays["cult"])
				if (!new_victim)
					my_hallucinated_stuff.Add(blind_victims[C])
					C.client.images.Remove(blind_victims[C])//removing the images from client.images after adding them to my_hallucinated_stuff
				blind_victims[C] = my_hallucinated_stuff//allows us to seamlessly refresh their duration.
				C.client.images.Add(blind_victims[C])
				var/hallenght = my_hallucinated_stuff.len
				spawn(duration-5)
					if (C in blind_victims)
						var/list/LI = blind_victims[C]
						if (LI.len == hallenght)//this checks whether this proc comes from the last blind rune the victim was affected from
							C.update_fullscreen_alpha("blindborder", 0, 5)
							C.overlay_fullscreen("blindwhite", /obj/abstract/screen/fullscreen/white)
							C.update_fullscreen_alpha("blindwhite", 255, 3)
							sleep(5)
							blind_victims.Remove(C)
							C.update_fullscreen_alpha("blindwhite", 0, 12)
							C.clear_fullscreen("blindblack", animate = 0)
							C.clear_fullscreen("blindborder", animate = 0)
							C.clear_fullscreen("blindblind", animate = 0)
							anim(target = C, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_blind_remove", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
							C.client.images.Remove(my_hallucinated_stuff)//removing images caused by every blind rune used consecutively on that mob
							sleep(15)
							C.clear_fullscreen("blindwhite", animate = 0)
		qdel(src)

//RUNE VIII
/datum/rune_spell/blood_cult/deafmute
	name = "Deaf-Mute"
	desc = "Silence and deafen nearby enemies. Including robots."
	desc_talisman = "Silence and deafen nearby enemies. Including robots. The effect is shorter than when used from a rune."
	Act_restriction = CULT_ACT_I
	invocation = "Sti' kaliedir!"
	word1 = /datum/runeword/blood_cult/hide
	word2 = /datum/runeword/blood_cult/other
	word3 = /datum/runeword/blood_cult/see
	page = "Hear no evil, Speak no evil, what your enemies will see remains for you to decide. This ritual inspire its victims with fright, making them unable to hear or speak for around half a minute. \
		Note that their speech will come back a bit sooner than their hearing, and that this ritual won't prevent them from writing down messages or using non-vocal means of communication. \
		Still, it appears to affect robots the same way it affects humans. Furthermore, the ritual isn't flashy, and affects people in range even behind obstacles, so cultists may abuse this spell \
		without exposing themselves directly. People near you when using the talisman may still hear you whisper however."
	var/deaf_rune_duration=50//times are in seconds
	var/deaf_talisman_duration=30
	var/mute_rune_duration=25
	var/mute_talisman_duration=15
	var/effect_range=7

/datum/rune_spell/blood_cult/deafmute/cast(var/deaf_duration = deaf_rune_duration, var/mute_duration = mute_rune_duration)
	for(var/mob/living/M in range(effect_range,get_turf(spell_holder)))
		if (iscultist(M))
			continue
		M.overlay_fullscreen("deafborder", /obj/abstract/screen/fullscreen/conversion_border)//victims DO still get blinded for a second
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

	qdel(spell_holder)

/datum/rune_spell/blood_cult/deafmute/cast_talisman()
	cast(deaf_talisman_duration, mute_talisman_duration)

//RUNE IX
/datum/rune_spell/blood_cult/hide
	name = "Conceal"
	desc = "Hide runes and cult structures. Some runes can still be used when concealed, but using them might reveal them."
	desc_talisman = "Hide runes and cult structures. Covers a smaller range than when used from a rune."
	Act_restriction = CULT_ACT_I
	invocation = "Kla'atu barada nikt'o!"
	word1 = /datum/runeword/blood_cult/hide
	word2 = /datum/runeword/blood_cult/see
	word3 = /datum/runeword/blood_cult/blood
	page = "This rune allows you to hide every rune and structures in a circular 7 tile range around it. You cannot hide a rune or structure that got revealed less than 10 seconds ago. Affects through walls. The talisman version has a 5 tile radius. "
	var/rune_effect_range=7
	var/talisman_effect_range=5

/datum/rune_spell/blood_cult/hide/cast(var/effect_range = rune_effect_range,var/size='icons/effects/480x480.dmi')
	var/turf/T = get_turf(spell_holder)
	var/atom/movable/overlay/animation = anim(target = T, a_icon = size, a_icon_state = "rune_conceal", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE*effect_range, offY = -WORLD_ICON_SIZE*effect_range, plane = LIGHTING_PLANE)
	animation.alpha = 0
	animate(animation, alpha = 255, time = 2)
	animate(alpha = 0, time = 3)
	//for(var/turf/U in range(effect_range,T))//DEBUG
	//	var/dist = cheap_pythag(U.x - T.x, U.y - T.y)
	//	if (dist <= effect_range+0.5)
	//		U.color = "red"
	to_chat(activator, "<span class='notice'>All runes and cult structures in range hide themselves behind a thin layer of reality.</span>")
	playsound(T, 'sound/effects/conceal.ogg', 50, 0, -4)

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

/datum/rune_spell/blood_cult/hide/cast_talisman()
	cast(talisman_effect_range,'icons/effects/352x352.dmi')

//RUNE X
/datum/rune_spell/blood_cult/reveal
	name = "Reveal"
	desc = "Reveal what you have previously hidden, terrifying enemies in the process."
	desc_talisman = "Reveal what you have previously hidden, terrifying enemies in the process. The effect is shorter than when used from a rune."
	Act_restriction = CULT_ACT_I
	invocation = "Nikt'o barada kla'atu!"
	word1 = /datum/runeword/blood_cult/blood
	word2 = /datum/runeword/blood_cult/see
	word3 = /datum/runeword/blood_cult/hide
	page = "This rune (whose words are the same as the Conceal rune in reverse) lets you reveal every rune and structures in a circular 7 tile range around it. Each revealed rune will stun non-cultists in a 3 tile range around them, stunning and muting them for 2 seconds, up to a total of 10 seconds. Affects through walls. The stun ends if the victims are moved away from where they stand, unless they get knockdown first, so you might want to follow up with a Stun talisman. "

	walk_effect = TRUE

	var/effect_range=7
	var/shock_range=3
	var/shock_per_obj=2
	var/max_shock=10
	var/last_threshold = -1
	var/total_uses = 5

/datum/rune_spell/blood_cult/reveal/cast()
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
			anim(target = S, a_icon = 'icons/effects/224x224.dmi', flick_anim = "rune_reveal", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE*shock_range, offY = -WORLD_ICON_SIZE*shock_range, plane = LIGHTING_PLANE)
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
				anim(target = R, a_icon = 'icons/effects/224x224.dmi', flick_anim = "rune_reveal", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE*shock_range, offY = -WORLD_ICON_SIZE*shock_range, plane = LIGHTING_PLANE)
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
		to_chat(L, "<span class='danger'>The shock of having occult symbols suddenly revealed to you leaves you temporarily unable to move or talk.</span>")
		L.update_fullscreen_alpha("shockborder", 100, 5)
		spawn(8)
			L.update_fullscreen_alpha("shockborder", 0, 5)
			sleep(8)
			L.clear_fullscreen("shockborder", animate = 0)

	qdel(spell_holder)

/datum/rune_spell/blood_cult/reveal/Added(var/mob/mover)
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
			if (iscultist(seer) && seer.client && seer.client.screen)
				var/image/image_intruder = image(L, loc = seer, layer = ABOVE_LIGHTING_LAYER, dir = L.dir)
				var/delta_x = (L.x - seer.x)
				var/delta_y = (L.y - seer.y)
				image_intruder.pixel_x = delta_x*WORLD_ICON_SIZE
				image_intruder.pixel_y = delta_y*WORLD_ICON_SIZE
				seers += seer
				seer << image_intruder // see the mover for a set period of time
				anim(location = get_turf(seer), target = seer, a_icon = 'icons/effects/224x224.dmi', flick_anim = "rune_reveal", lay = NARSIE_GLOW, offX = 0, offY = 0, plane = LIGHTING_PLANE)
				spawn(3)
					del image_intruder
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
				seer << image_intruder
				spawn(3)
					del image_intruder
			count--
		while (count && seers.len)

/datum/rune_spell/blood_cult/reveal/cast_talisman()
	shock_per_obj = 1.5
	max_shock = 8
	cast()


/obj/effect/cult_ritual/reveal
	anchored = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "rune_reveal"
	layer = NARSIE_GLOW
	plane = LIGHTING_PLANE
	mouse_opacity = 0
	flags = PROXMOVE
	var/mob/living/victim = null
	var/duration = 2

/obj/effect/cult_ritual/reveal/Destroy()
	victim = null
	anim(target = loc, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_reveal-stop", lay = NARSIE_GLOW, plane = LIGHTING_PLANE)
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
	spawn (duration*10)
		if (src && loc && victim && victim.loc == loc && !victim.knockdown)
			to_chat(victim, "<span class='warning'>You come back to your senses.</span>")
			victim.AdjustStunned(-duration)
			victim.AdjustMute(-duration/2)
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
			victim = null
		qdel(src)

//RUNE XI
/datum/rune_spell/blood_cult/seer
	name = "Seer"
	desc = "See the invisible, the dead, the concealed. If you give them a writing sheet, they may relay a message to you."
	desc_talisman = "For a few seconds, you may see the invisible, the dead, the concealed. If you give them a writing sheet, they may relay a message to you."
	Act_restriction = CULT_ACT_I
	invocation = "Rash'tla sektath mal'zua. Zasan therium viortia."
	rune_flags = RUNE_STAND
	talisman_uses = 5
	word1 = /datum/runeword/blood_cult/see
	word2 = /datum/runeword/blood_cult/hell
	word3 = /datum/runeword/blood_cult/join
	page = "This rune grants you the ability to see the invisible, including observers and concealed runes and structures. The talisman version has 5 uses, which grant you the ability for 8 seconds each. Remember that runes can still be activated while they are concealed! "
	cost_invoke = 5
	var/obj/effect/cult_ritual/seer/seer_ritual = null
	var/talisman_duration = 80 //tenths of a second

/datum/rune_spell/blood_cult/seer/Destroy()
	destroying_self = 1
	if (seer_ritual)
		qdel(seer_ritual)
	seer_ritual = null
	..()

/datum/rune_spell/blood_cult/seer/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		seer_ritual = new /obj/effect/cult_ritual/seer(R.loc,activator,src)
	else
		qdel(src)

/datum/rune_spell/blood_cult/seer/cast_talisman()
	var/mob/living/M = activator
	M.see_invisible_override = SEE_INVISIBLE_OBSERVER
	M.apply_vision_overrides()
	to_chat(M, "<span class='notice'>As the talisman disappears into dust, you find yourself able to see through the gaps in the veil. You can see and interact with the other side, for a few seconds.</span>")
	anim(target = M, a_icon = 'icons/effects/160x160.dmi', a_icon_state = "rune_seer", lay = ABOVE_OBJ_LAYER, offX = -WORLD_ICON_SIZE*2, offY = -WORLD_ICON_SIZE*2, plane = OBJ_PLANE, invis = INVISIBILITY_OBSERVER, alph = 200, sleeptime = talisman_duration)
	spawn(talisman_duration)
		M.see_invisible_override = 0
		M.apply_vision_overrides()
		to_chat(M, "<span class='notice'>You can no longer discern through the veil.</span>")
	qdel(src)

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
	var/datum/rune_spell/blood_cult/seer/source = null


/obj/effect/cult_ritual/seer/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/blood_cult/seer/runespell)
	..()
	caster = user
	source = runespell
	if (!caster)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)
		return
	caster.see_invisible_override = SEE_INVISIBLE_OBSERVER
	caster.apply_vision_overrides()
	to_chat(caster, "<span class='notice'>You find yourself able to see through the gaps in the veil. You can see and interact with the other side.</span>")

/obj/effect/cult_ritual/seer/Destroy()
	if (caster)
		caster.see_invisible_override = 0
		caster.apply_vision_overrides()
		to_chat(caster, "<span class='notice'>You can no longer discern through the veil.</span>")
	caster = null
	if (source)
		source.abort()
	source = null
	..()

/obj/effect/cult_ritual/seer/HasProximity(var/atom/movable/AM)
	if (!caster || caster.loc != loc)
		qdel(src)


//RUNE XII
/datum/rune_spell/blood_cult/summonrobes
	name = "Summon Robes"
	desc = "Swap your clothes for the robes of Nar-Sie's followers. Significantly improves the efficiency of some rituals. Provides a tesseract to instantly swap back to your old clothes."
	desc_talisman = "Swap your clothes for the robes of Nar-Sie's followers. Significantly improves the efficiency of some rituals. Provides a tesseract to instantly swap back to your old clothes. Using the tesseract will also give you the talisman back, granted it has some uses left."
	Act_restriction = CULT_ACT_II
	invocation = "Sa tatha najin"
	word1 = /datum/runeword/blood_cult/hell
	word2 = /datum/runeword/blood_cult/destroy
	word3 = /datum/runeword/blood_cult/other
	rune_flags = RUNE_STAND
	talisman_uses = 3
	page = "This rune, which you have to stand above to use, equips your character with cult gear. Namely, Cult Hood, Cult Robes, Cult Shoes, and a Cult Backpack. Wearing cult gear improves your efficiency with a few rituals (see Tools section bellow) on top of granting you very decent armor values. After using the rune, a Blood Tesseract appears in your hand, containing clothes that had to be swapped out because you were already wearing them in your head/suit slots. You can use it to get your clothing back instantly. Lastly, the talisman version has 3 uses, and gets back in your hand after you use the Blood Tesseract. The inventory of your backpack gets always gets transferred upon use. "
	var/list/slots_to_store = list(
		slot_shoes,
		slot_head,
		slot_back,
		slot_wear_suit,
		slot_s_store,
		)

/datum/rune_spell/blood_cult/summonrobes/cast()
	var/obj/effect/rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (!ishuman(activator) && !ismonkey(activator))
		qdel(src)
		return

	anim(target = activator, a_icon = 'icons/effects/64x64.dmi', flick_anim = "rune_robes", lay = NARSIE_GLOW, offX = -WORLD_ICON_SIZE/2, offY = -WORLD_ICON_SIZE/2, plane = LIGHTING_PLANE)

	var/obj/item/weapon/blood_tesseract/BT = new(get_turf(activator))
	if (istype (spell_holder,/obj/item/weapon/talisman))
		var/obj/item/weapon/talisman/T = spell_holder
		activator.u_equip(spell_holder)
		if (T.uses > 1)
			BT.remaining = spell_holder
			spell_holder.forceMove(BT)

	for(var/slot in slots_to_store)
		var/obj/item/user_slot = activator.get_item_by_slot(slot)
		if (user_slot)
			BT.stored_gear[num2text(slot)] = user_slot
	//looping again in case the suit had a stored item
	for(var/slot in BT.stored_gear)
		var/obj/item/user_slot = BT.stored_gear[slot]
		BT.stored_gear[slot] = user_slot
		if(istype(user_slot, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = user_slot
			S.close(activator)
		activator.u_equip(user_slot)
		user_slot.forceMove(BT)

	if(isplasmaman(activator))
		activator.equip_to_slot_or_drop(new /obj/item/clothing/head/helmet/space/plasmaman/cultist(activator), slot_head)
		activator.equip_to_slot_or_drop(new /obj/item/clothing/suit/space/plasmaman/cultist(activator), slot_wear_suit)
	else
		activator.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood(activator), slot_head)
		if (ismonkey(activator))
			activator.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes(activator), slot_w_uniform)
		else
			activator.equip_to_slot_or_drop(new /obj/item/clothing/suit/cultrobes(activator), slot_wear_suit)

	if (!ismonkey(activator))
		activator.equip_to_slot_or_drop(new /obj/item/clothing/shoes/cult(activator), slot_shoes)

	//transferring backpack items
	var/obj/item/weapon/storage/backpack/cultpack/new_pack = new (activator)
	if ((num2text(slot_back) in BT.stored_gear))
		var/obj/item/stored_slot = BT.stored_gear[num2text(slot_back)]
		if (istype (stored_slot,/obj/item/weapon/storage/backpack))
			for(var/obj/item/I in stored_slot)
				I.forceMove(new_pack)
	activator.equip_to_slot_or_drop(new_pack, slot_back)

	activator.put_in_hands(BT)
	to_chat(activator, "<span class='notice'>Robes and gear of the followers of Nar-Sie manifests around your body. You feel empowered.</span>")
	to_chat(activator, "<span class='notice'>You \a [BT] materializes in your hand, you may use it to instantly swap back into your stored clothing.</span>")
	qdel(src)


//RUNE XIII
/datum/rune_spell/blood_cult/door
	name = "Door"
	desc = "Raise a door to impede your enemies. It automatically opens and closes behind you, but the others may eventually break it down."
	desc_talisman = "Use to remotely trigger the rune and have it spawn a door to block your enemies."
	Act_restriction = CULT_ACT_II
	invocation = "Khari'd! Eske'te tannin!"
	word1 = /datum/runeword/blood_cult/destroy
	word2 = /datum/runeword/blood_cult/travel
	word3 = /datum/runeword/blood_cult/self
	talisman_absorb = RUNE_CAN_ATTUNE
	page = "This rune spawns a Cult Door immediately upon use, for a cost of 10u of blood. This rune cannot be activated if there's another cult door currently adjacent to it. Cult doors can be broken down relatively quickly with weapons, but let cultist move through them with barely any slowdown, making them great to retreat. Spawning them in maintenance will exasperate the crew. Lastly, they can be remotely activated using a talisman. "
	cost_invoke = 10

/datum/rune_spell/blood_cult/door/cast()
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

//RUNE XIV
/datum/rune_spell/blood_cult/fervor
	name = "Fervor"
	desc = "Inspire nearby cultists to purge their stuns and raise their movement speed."
	desc_talisman = "Use to inspire nearby cultists to purge their stuns and raise their movement speed."
	Act_restriction = CULT_ACT_II
	invocation = "Khari'd! Gual'te nikka!"
	word1 = /datum/runeword/blood_cult/travel
	word2 = /datum/runeword/blood_cult/technology
	word3 = /datum/runeword/blood_cult/other
	page = "For a 20u blood cost, this rune immediately buffs all cultists in a 7 tile range by immediately removing any stuns, oxygen loss damage, holy water, and various other bad conditions. Additionally, it injects them with 1u of hyperzine, negating slowdown from low health or clothing. This makes it a very potent rune in a fight, especially as a follow up to a flash bang, or prior to a fight. Best used as a talisman. "
	cost_invoke = 20
	var/effect_range = 7

/datum/rune_spell/blood_cult/fervor/cast()
	var/obj/effect/rune/R = spell_holder
	if (istype(R))
		R.one_pulse()

	if (pay_blood())
		for(var/mob/living/L in range(effect_range,get_turf(spell_holder)))
			if(L.stat != DEAD && iscultist(L))
				playsound(L, 'sound/effects/fervor.ogg', 50, 0, -2)
				anim(target = L, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_fervor", lay = NARSIE_GLOW, plane = LIGHTING_PLANE, direction = L.dir)
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

//RUNE XV
/datum/rune_spell/blood_cult/summoncultist
	name = "Blood Magnetism"
	desc = "Bring forth one of your fellow believers, no matter how far they are, as long as their heart beats"
	desc_talisman = "Use to begin the Blood Magnetism ritual where you stand."
	Act_restriction = CULT_ACT_II
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	word1 = /datum/runeword/blood_cult/join
	word2 = /datum/runeword/blood_cult/other
	word3 = /datum/runeword/blood_cult/self
	page = "This rune actually has two different rituals, which you can choose between upon casting, both rituals have a 10 seconds base cast time. The first one, Summon Cultist, lets you summon a cultist from anywhere in the world whether they're alive or dead, for a cost of 50u of blood, which can be split by having other cultists participate in the ritual. The second ritual, Rejoin Cultist, lets you summon yourself next to the target cultist instead for a cost of 15u of blood. Other cultists can participate in the second ritual to accompany you, but the cost will remain 15u for every participating cultist."
	remaining_cost = 10
	cost_upkeep = 1
	var/rejoin = 0
	var/mob/target = null
	var/list/feet_portals = list()
	var/cost_summon = 50//you probably don't want to pay that up alone
	var/cost_rejoin = 15//static cost for every contributor

/datum/rune_spell/blood_cult/summoncultist/Destroy()
	target = null
	for (var/guy in feet_portals)
		var/obj/O = feet_portals[guy]
		qdel(O)
		feet_portals -= guy
	feet_portals = list()
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	spell_holder.overlays -= image('icons/effects/effects.dmi',"rune_summon")
	..()


/datum/rune_spell/blood_cult/summoncultist/abort()
	for (var/guy in feet_portals)
		var/obj/O = feet_portals[guy]
		qdel(O)
	..()

/datum/rune_spell/blood_cult/summoncultist/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	rejoin = alert(activator, "Will you pull them toward you, or pull yourself toward them?","Blood Magnetism","Summon Cultist","Rejoin Cultist") == "Rejoin Cultist"

	var/list/possible_targets = list()
	var/datum/faction/bloodcult = find_active_faction_by_member(activator.mind.GetRole(CULTIST))
	for(var/datum/role/cultist/C in bloodcult.members)
		var/datum/mind/M = C.antag
		possible_targets.Add(M.current)

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

/datum/rune_spell/blood_cult/summoncultist/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/blood_cult/summoncultist/midcast(var/mob/add_cultist)
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

/datum/rune_spell/blood_cult/summoncultist/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	spell_holder.overlays -= image('icons/effects/effects.dmi',"rune_summon")
	..()

/datum/rune_spell/blood_cult/summoncultist/proc/payment()//an extra payment is spent at the end of the channeling, and shared between contributors
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

/datum/rune_spell/blood_cult/summoncultist/proc/success()
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
			to_chat(target, "<span class='warning'>You feel that some force wants to pull you through the veil, but cannot proceed while buckled or inside something.</span>")
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
	icon = 'icons/effects/effects.dmi'
	icon_state = "rune_rejoin"
	pixel_y = -10
	layer = ABOVE_OBJ_LAYER
	plane = OBJ_PLANE
	mouse_opacity = 0
	flags = PROXMOVE
	var/mob/living/caster = null
	var/turf/source = null

/obj/effect/cult_ritual/feet_portal/New(var/turf/loc, var/mob/living/user, var/datum/rune_spell/blood_cult/seer/runespell)
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

//RUNE XVI
/datum/rune_spell/blood_cult/portalentrance
	name = "Path Entrance"
	desc = "Take a shortcut through the veil between this world and the other one."
	desc_talisman = "Use to remotely trigger the rune and force objects and creatures on top through the Path."
	Act_restriction = CULT_ACT_II
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/runeword/blood_cult/travel
	word2 = /datum/runeword/blood_cult/self
	word3 = /datum/runeword/blood_cult/other
	talisman_absorb = RUNE_CAN_ATTUNE
	can_conceal = 1
	page = "This rune lets you set free teleports between any two tiles in the worlds, when used in combination with the Path Exit rune. Upon its first use, the rune asks you to set a path for it to attune to. There are 10 possible paths, each corresponding to a cult word. Upon subsequent uses the rune will, after a 1 second delay, teleport everything not anchored above it to the Path Exit attuned to the same word (if there aren't any, no teleportation will occur). Talismans will remotely activate this rune. You can deactivate a Path Entrance by simply using the Erase Word spell on it, and rewriting it afterwards. "
	var/network = ""

/datum/rune_spell/blood_cult/portalentrance/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = global_runesets["blood_cult"].words_english.Copy()

	network = input(activator, "Choose an available Path, you may change paths later by erasing the rune.", "Path Entrance") as null|anything in available_networks
	if (!network)
		qdel(src)
		return

	var/datum/runeword/blood_cult/W = global_runesets["blood_cult"].words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('icons/obj/cult.dmi',"path_pad")
	I_crystals.plane = OBJ_PLANE
	I_crystals.layer = BELOW_TABLE_LAYER
	var/image/I_stone = image('icons/obj/cult.dmi',"path_entrance")
	I_stone.plane = ABOVE_TURF_PLANE
	I_stone.layer = ABOVE_TILE_LAYER
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.icon_state]-0-[DEFAULT_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in uristrune_cache)
		var/icon/I = uristrune_cache[lookup]
		I_network = image(I)
	else
		var/icon/I = icon('icons/effects/uristrunes.dmi', "")
		I = R.make_iconcache(W,null,0)
		I_network = image(I)
	I_network.plane = ABOVE_TURF_PLANE
	I_network.layer = BLOOD_LAYER
	I_network.transform /= 2
	I_network.pixel_y = -3

	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network

	spell_holder.icon = initial(spell_holder.icon)

	to_chat(activator, "<span class='notice'>This rune will now let you travel through the \"[network]\" Path.</span>")

	if (HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]" in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"]
		holomarker.id = HOLOMAP_MARKER_CULT_ENTRANCE
		holomarker.color = W.color
		holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"] = holomarker

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/blood_cult/portalentrance/midcast(var/mob/add_cultist)
	if (istype(spell_holder, /obj/item/weapon/talisman))
		invoke(add_cultist,invocation,1)
	else
		invoke(add_cultist,invocation)

	var/turf/destination = null
	for (var/datum/rune_spell/blood_cult/portalexit/P in bloodcult_exitportals)
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
		new /obj/effect/bloodcult_jaunt(T,null,destination,T)
		flick("cult_jaunt_land",landing_animation)

/datum/rune_spell/blood_cult/portalentrance/midcast_talisman(var/mob/add_cultist)
	midcast(add_cultist)

//RUNE XVII
var/list/bloodcult_exitportals = list()

/datum/rune_spell/blood_cult/portalexit
	name = "Path Exit"
	desc = "We hope you enjoyed your flight with Air Nar-Sie"//might change it later or not.
	desc_talisman = "Use to immediately jaunt through the Path."
	Act_restriction = CULT_ACT_II
	invocation = "Sas'so c'arta forbici!"
	word1 = /datum/runeword/blood_cult/travel
	word2 = /datum/runeword/blood_cult/other
	word3 = /datum/runeword/blood_cult/self
	talisman_absorb = RUNE_CAN_IMBUE
	can_conceal = 1
	page = "This rune lets you set free teleports between any two tiles in the worlds, when used in combination with the Path Entrance rune. Upon its first use, the rune asks you to set a path for it to attune to. There are 10 possible paths, each corresponding to a cult word. Unlike for entrances, there may only exist 1 exit for each path. By using a talisman on an attuned rune, the talisman will teleport you to that rune immediately upon use. By using a talisman on a non-attuned rune, the rune will be absorbed instead, and you'll be able to set a destination path on the talisman, allowing you to check which path exits currently exist. You can deactivate a Path Exit by simply using the Erase Word spell on it, and rewriting it afterwards. "
	var/network = ""

/datum/rune_spell/blood_cult/portalexit/New()
	..()
	bloodcult_exitportals.Add(src)

/datum/rune_spell/blood_cult/portalexit/Destroy()
	bloodcult_exitportals.Remove(src)
	..()

/datum/rune_spell/blood_cult/portalexit/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	var/list/available_networks = global_runesets["blood_cult"].words_english.Copy()
	for (var/datum/rune_spell/blood_cult/portalexit/P in bloodcult_exitportals)
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

	var/datum/runeword/blood_cult/W = global_runesets["blood_cult"].words[network]

	invoke(activator, "[W.rune]")
	var/image/I_crystals = image('icons/obj/cult.dmi',"path_crystals")
	I_crystals.plane = OBJ_PLANE
	I_crystals.layer = BELOW_TABLE_LAYER
	var/image/I_stone = image('icons/obj/cult.dmi',"path_stone")
	I_stone.plane = ABOVE_TURF_PLANE
	I_stone.layer = ABOVE_TILE_LAYER
	I_stone.appearance_flags |= RESET_COLOR//we don't want the stone to pulse

	var/image/I_network
	var/lookup = "[W.icon_state]-0-[DEFAULT_BLOOD]"//0 because the rune will pulse anyway, and make this overlay pulse along
	if (lookup in uristrune_cache)
		var/icon/I = uristrune_cache[lookup]
		I_network = image(I)
	else
		var/icon/I = icon('icons/effects/uristrunes.dmi', "")
		I = R.make_iconcache(W,null,0)
		I_network = image(I)
	I_network.plane = ABOVE_TURF_PLANE
	I_network.layer = BLOOD_LAYER
	I_network.transform /= 2
	I_network.pixel_y = -3

	spell_holder.overlays += I_crystals
	spell_holder.overlays += I_stone
	spell_holder.overlays += I_network

	spell_holder.icon = initial(spell_holder.icon)

	to_chat(activator, "<span class='notice'>This rune will now serve as a destination for the \"[network]\" Path.</span>")

	if (HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]" in holomap_markers)
		var/datum/holomap_marker/holomarker = holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"]
		holomarker.id = HOLOMAP_MARKER_CULT_EXIT
		holomarker.color = W.color
		holomap_markers[HOLOMAP_MARKER_CULT_RUNE+"_\ref[spell_holder]"] = holomarker

	talisman_absorb = RUNE_CAN_ATTUNE//once the network has been set, talismans will attune instead of imbue

/datum/rune_spell/blood_cult/portalexit/midcast(var/mob/add_cultist)
	to_chat(add_cultist, "<span class='notice'>You may teleport to this rune by using a Path Entrance, or a talisman attuned to it.</span>")

/datum/rune_spell/blood_cult/portalexit/midcast_talisman(var/mob/add_cultist)
	var/turf/T = get_turf(add_cultist)
	invoke(add_cultist,invocation,1)
	anim(target = T, a_icon = 'icons/effects/effects.dmi', flick_anim = "rune_teleport")
	new /obj/effect/bloodcult_jaunt (T, add_cultist, get_turf(spell_holder))

/datum/rune_spell/blood_cult/portalexit/cast_talisman()
	var/obj/item/weapon/talisman/T = spell_holder
	T.uses++//so the talisman isn't deleted when setting the network
	var/list/valid_choices = list()
	for (var/datum/rune_spell/blood_cult/portalexit/P in bloodcult_exitportals)
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

	invoke(activator,"[global_runesets["blood_cult"].words_english[network]]!",1)

	to_chat(activator, "<span class='notice'>This talisman will now serve as a key to the \"[network]\" Path.</span>")

	var/datum/rune_spell/blood_cult/portalexit/PE = valid_choices[network]

	T.attuned_rune = PE.spell_holder
	T.word_pulse(global_runesets["blood_cult"].words[network])

//RUNE XVIII
/datum/rune_spell/blood_cult/pulse
	name = "Pulse"
	desc = "Scramble the circuits of nearby devices"
	desc_talisman = "Use to scramble the circuits of nearby devices."
	Act_restriction = CULT_ACT_II
	invocation = "Ta'gh fara'qha fel d'amar det!"
	word1 = /datum/runeword/blood_cult/destroy
	word2 = /datum/runeword/blood_cult/see
	word3 = /datum/runeword/blood_cult/technology
	page = "This rune triggers a series of short-range EMPs that messes with electronic machinery, devices, and silicons. Affects things up to 3 tiles away, but only adjacent targets will take the full force of the EMP. Best used as a talisman. "

/datum/rune_spell/blood_cult/pulse/cast()
	var/turf/T = get_turf(spell_holder)
	playsound(T, 'sound/items/Welder2.ogg', 25, 1)
	T.hotspot_expose(700,125,surfaces=1)
	spawn(0)
		for(var/i = 0; i < 3; i++)
			empulse(T, 1, 3)
			sleep(20)
	qdel(spell_holder)

//RUNE XIX
/datum/rune_spell/blood_cult/astraljourney
	name = "Astral Journey"
	desc = "Leave your body so you can go spy on your enemies."
	desc_talisman = "Leave your body so you can go spy on your enemies."
	Act_restriction = CULT_ACT_II
	invocation = "Fwe'sh mah erl nyag r'ya!"
	word1 = /datum/runeword/blood_cult/hell
	word2 = /datum/runeword/blood_cult/travel
	word3 = /datum/runeword/blood_cult/self
	page = "Upon use, you will fall asleep, and your soul will float above your body, allowing you to freely move around the Z-Level like a ghost would. However, you cannot talk with other ghosts, or listen to them, or use any of the usual ghost verbs beside re-entering your body. Re-entering your body, or it being moved away from the rune will end the ritual, and you'll wake up after a second or so. You might have to use the rest verb to get back up. As it can be used for any period of time, it's a great, though limited, spying tool. Should your body be destroyed while you were using the rune, attempting to re-enter it will grant you the rest of the ghost verbs and abilities back. "
	rune_flags = RUNE_STAND
	var/mob/dead/observer/deafmute/astral = null
	var/cultist_key = ""
	var/list/restricted_verbs = list()

/datum/rune_spell/blood_cult/astraljourney/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	cultist_key = activator.key
	if (ishuman(activator))
		activator.sleeping = max(activator.sleeping,2)
		activator.stat = UNCONSCIOUS
		activator.resting = 1
	activator.ajourn = spell_holder

	var/list/antag_icons = list()
	if (activator.client)
		for (var/image/I in activator.client.images)
			if (I.plane == ANTAG_HUD_PLANE)
				antag_icons += image(I,I.loc)

	to_chat(activator, "<span class='notice'>As you recite the invocation, your body falls over the rune, but your consciousness still stands up above it.</span>")
	astral = activator.ghostize(1,1)

	astral.icon = 'icons/mob/mob.dmi'
	astral.icon_state = "ghost-narsie"
	astral.overlays.len = 0
	if (ishuman(activator))
		var/mob/living/carbon/human/H = activator
		astral.overlays += H.obj_overlays[ID_LAYER]
		astral.overlays += H.obj_overlays[EARS_LAYER]
		astral.overlays += H.obj_overlays[SUIT_LAYER]
		astral.overlays += H.obj_overlays[GLASSES_LAYER]
		astral.overlays += H.obj_overlays[GLASSES_OVER_HAIR_LAYER]
		astral.overlays += H.obj_overlays[BELT_LAYER]
		astral.overlays += H.obj_overlays[BACK_LAYER]
		astral.overlays += H.obj_overlays[HEAD_LAYER]
		astral.overlays += H.obj_overlays[HANDCUFF_LAYER]

	for (var/V in astral.verbs)//restricting the verbs! all they can do is re-enter their body.
		if ((copytext("[V]",1,10) == "/mob/dead") && ("[V]" != "/mob/dead/observer/verb/reenter_corpse"))
			restricted_verbs += V
			astral.verbs -= V

	step(astral,NORTH)
	astral.dir = SOUTH
	astral.movespeed = 0.375//twice the default ghost move speed
	astral.see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

	if (astral.client)
		for (var/image/I in antag_icons)
			astral.client.images += I

	spawn()
		handle_astral()

/datum/rune_spell/blood_cult/astraljourney/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)


/datum/rune_spell/blood_cult/astraljourney/abort(var/cause)
	if (activator && activator.loc && cultist_key)
		activator.key = cultist_key
		to_chat(activator, "<span class='notice'>You reconnect with your body.</span>")
	else
		if (astral)
			to_chat(astral, "<span class='notice'>The ritual somehow lost track of your body. You are now fully disconnected from it, and a fully fledged ghost.</span>")
			for (var/V in restricted_verbs)//since they're a real ghost now, let's give them back the rest of their verbs.
				astral.verbs += V
	..()

/datum/rune_spell/blood_cult/astraljourney/proc/handle_astral()
	while(!destroying_self && activator && astral && astral.loc && activator.stat == UNCONSCIOUS && activator.loc == spell_holder.loc)
		activator.sleeping = max(activator.sleeping,2)
		sleep(10)
	abort()

/datum/rune_spell/blood_cult/astraljourney/Removed(var/mob/M)
	if (M == activator)
		abort(RITUALABORT_GONE)

//RUNE XX
/datum/rune_spell/blood_cult/resurrect
	name = "Resurrect"
	desc = "Create a strong body for your fallen allies to inhabit."
	desc_talisman = "Create a strong body for your fallen allies to inhabit."
	Act_restriction = CULT_ACT_III
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!"
	word1 = /datum/runeword/blood_cult/blood
	word2 = /datum/runeword/blood_cult/join
	word3 = /datum/runeword/blood_cult/hell
	page = "This final rune lets you bring back any dead player into the cult, by creating them a new body. Unlike other runes, this one requires a few ingredients:\
	    a Skull (obtainable from failed Conversions and Soul Stone victims)\
	    some Ashes (obtainable by burning some paper or talisman, which you can do by using them on a cult blade)\
	    any piece of Meat (obtainable in many ways)\
	    a Ghost made visible (which can be done by hitting one with your Arcane Tome, after using the Seer rune)\
		It is recommended that multiple cultists participate in this ritual, or that a stockpile of blood be used, since each participating cultists will pay 5u of blood per second, until 300u of blood is paid in total. The resurrected's cultist body has the properties of the Manifested Ghost tattoo by default."
	ingredients = list(
		/obj/item/weapon/skull,
		/obj/effect/decal/cleanable/ash,
		/obj/item/weapon/reagent_containers/food/snacks/meat,
		)
	cost_upkeep = 5
	remaining_cost = 300
	var/obj/effect/cult_ritual/resurrect/husk = null
	var/mob/dead/ghost = null

/datum/rune_spell/blood_cult/resurrect/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	if (missing_ingredients_count())
		return

	ghost = locate(/mob/dead) in R.loc
	if (!ghost)
		to_chat(activator, "<span class='warning'>You have the ingredients, now there needs to be a ghost made visible standing above the rune.</span>")
		qdel(src)
		return
	if (ghost.mind && ghost.mind.current && ghost.mind.current.ajourn && (ghost.mind.current.stat != DEAD))
		to_chat(activator, "<span class='warning'>This ghost still has a breathing body where to return to.</span>")
		qdel(src)
		return
	if (ghost.invisibility != 0)
		to_chat(activator, "<span class='warning'>You have the ingredients, but the ghost needs to be drawn onto our plane first. You already have the tools to do so.</span>")
		qdel(src)
		return

	//ingredients found? check. ghost in place and visible? check, let's go!
	for (var/atom/A in ingredients_found)
		qdel(A)

	husk = new (R.loc)
	ghost.incorporeal_move = 0
	ghost.forceMove(husk)

	contributors.Add(activator)
	update_progbar()
	if (activator.client)
		activator.client.images |= progbar
	spell_holder.overlays += image('icons/obj/cult.dmi',"runetrigger-build")
	to_chat(activator, "<span class='rose'>This ritual has a very high blood cost per second, but it can be completed faster by having multiple cultists partake in it.</span>")
	spawn()
		payment()

/datum/rune_spell/blood_cult/resurrect/cast_talisman()//we spawn an invisible rune under our feet that works like the regular one
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/blood_cult/resurrect/midcast(var/mob/add_cultist)
	if (add_cultist in contributors)
		return
	invoke(add_cultist, invocation)
	contributors.Add(add_cultist)
	if (add_cultist.client)
		add_cultist.client.images |= progbar

/datum/rune_spell/blood_cult/resurrect/abort(var/cause)
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	if (ghost)
		ghost.incorporeal_move = 1
		if (husk && husk.loc)
			ghost.loc = husk.loc
	if (husk)
		qdel(husk)
	if (spell_holder.loc && (!cause || cause != RITUALABORT_MISSING))
		new /obj/effect/gibspawner/human(spell_holder.loc)
	..()

/datum/rune_spell/blood_cult/resurrect/proc/payment()
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

/datum/rune_spell/blood_cult/resurrect/proc/success()
	spell_holder.overlays -= image('icons/obj/cult.dmi',"runetrigger-build")
	if (ghost && husk)
		var/mob/living/carbon/human/manifested/vessel = new (spell_holder.loc)
		vessel.name = ghost.name
		vessel.real_name = ghost.real_name
		vessel.ckey = ghost.ckey
		qdel(husk)

		vessel.my_appearance.r_hair = 90
		vessel.my_appearance.g_hair = 90
		vessel.my_appearance.b_hair = 90
		vessel.my_appearance.r_facial = 90
		vessel.my_appearance.g_facial = 90
		vessel.my_appearance.b_facial = 90
		vessel.my_appearance.r_eyes = 255
		vessel.my_appearance.g_eyes = 0
		vessel.my_appearance.b_eyes = 0
		vessel.status_flags &= ~GODMODE
		vessel.regenerate_icons()
		//Let's not forget to make them cultists as well
		var/datum/role/cultist/newCultist = new
		newCultist.AssignToRole(vessel.mind,1)
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (!cult)
			cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
		cult.HandleRecruitedRole(newCultist)
		newCultist.OnPostSetup()
		newCultist.Greet(GREET_RESURRECT)
		newCultist.conversion["resurrected"] = activator
	else
		for(var/mob/living/L in contributors)
			to_chat(activator, "<span class='warning'>Something went wrong with the ritual, the soul of the ghost appears to have vanished.</span>")


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
	icon = 'icons/effects/effects.dmi'
	icon_state = "rune_resurrect"
	layer = SHADOW_LAYER
	plane = ABOVE_HUMAN_PLANE
	mouse_opacity = 0



#undef RUNE_STAND

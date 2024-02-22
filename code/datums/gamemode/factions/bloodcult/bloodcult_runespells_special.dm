
// Rune Spells that aren't listed when the player tries to draw a guided rune.




////////////////////////////////////////////////////////////////////
//																  //
//							SUMMON TOME							  //
//																  //
////////////////////////////////////////////////////////////////////
//Reason: Redundant with paraphernalia. No harm in keeping the rune somewhat usable until another use is found for that word combination.

/datum/rune_spell/summontome
	secret = TRUE
	name = "Summon Tome"
	desc = "Bring forth an arcane tome filled with Nar-Sie's knowledge."
	desc_talisman = "Turns into an arcane tome upon use."
	invocation = "N'ath reth sh'yro eth d'raggathnor!"
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/blood
	word3 = /datum/rune_word/hell
	cost_invoke = 4
	page = ""

/datum/rune_spell/summontome/cast()
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


////////////////////////////////////////////////////////////////////
//																  //
//								STREAM							  //
//																  //
////////////////////////////////////////////////////////////////////
//Reason: we don't want a new cultist player to use this rune by accident, better leave it to savvy ones

/datum/rune_spell/stream
	secret = TRUE
	name = "Stream"
	desc = "Start or stop streaming on Spess.TV."
	desc_talisman = "Start or stop streaming on Spess.TV."
	invocation = "L'k' c'mm'nt 'n' s'bscr'b! P'g ch'mp! Kappah!"
	word1 = /datum/rune_word/other
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/self
	page = "This rune lets you start (or stop) streaming on Spess.TV so that you can let your audience watch and cheer for you while you slay infidels in the name of Nar-sie. #Sponsored"

/datum/rune_spell/stream/cast()
	var/datum/role/streamer/streamer = activator.mind.GetRole(STREAMER)
	if(!streamer)
		streamer = new /datum/role/streamer
		streamer.team = ESPORTS_CULTISTS
		if(!streamer.AssignToRole(activator.mind, 1))
			streamer.Drop()
			return
		streamer.OnPostSetup()
		streamer.Greet(GREET_DEFAULT)
		streamer.AnnounceObjectives()
	streamer.team = ESPORTS_CULTISTS
	if(!streamer.camera)
		streamer.set_camera(new /obj/machinery/camera/arena/spesstv(activator))
	streamer.toggle_streaming()
	qdel(src)


////////////////////////////////////////////////////////////////////
//																  //
//						    TEAR REALITY						  //
//																  //
////////////////////////////////////////////////////////////////////
//Reason: the words for that one are revealed to cultists on their UI once the Eclipse timer has reached zero

/datum/rune_spell/tearreality
	secret = TRUE
	name = "Tear Reality"
	desc = "Kickstarts the ritual to bring forth Nar-Sie."
	desc_talisman = "Use to kickstart the ritual to bring forth Nar-Sie where you stand."
	invocation = "Tok-lyr rqa'nap g'lt-ulotf!"
	word1 = /datum/rune_word/hell
	word2 = /datum/rune_word/join
	word3 = /datum/rune_word/self
	page = ""

/datum/rune_spell/tearreality/cast()
	var/obj/effect/rune/R = spell_holder
	R.one_pulse()

	//The most fickle rune there ever was
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (!istype(cult))
		to_chat(activator, "<span class='warning'>Couldn't find the cult faction. Something's broken, please report the issue to an admin or using the BugReport button at the top.</span>")
		return

	switch(cult.stage)
		if (BLOODCULT_STAGE_NORMAL)
			to_chat(activator, "<span class='sinister'>The rune pulses but no energies respond to its signal.</span>")
			to_chat(activator, "<span class='sinister'>The Eclipse is coming, but until then this rune serves no purpose.</span>")
			if (R.z != map.zMainStation)
				to_chat(activator, "<span class='sinister'>When it does, you should try again <font color='red'>aboard the station</font>.</span>")
			else if (isspace(R.loc) || is_on_shuttle(R) || (get_dist(locate(map.center_x,map.center_y,map.zMainStation),R) > 100))
				to_chat(activator, "<span class='sinister'>When it does, you should try again <font color='red'>closer from the station's center</font>.</span>")
			abort()
			return

		if (BLOODCULT_STAGE_MISSED)
			to_chat(activator, "<span class='sinister'>The rune pulses but no energies respond to its signal.</span>")
			to_chat(activator, "<span class='sinister'>The window of opportunity has passed along with the Eclipse. Make your way off this space station so you may attempt another day.</span>")
			abort()
			return

		if (BLOODCULT_STAGE_ECLIPSE)
			to_chat(activator, "<span class='sinister'>The Bloodstone has been raised! Now is not the time to use that rune.</span>")
			abort()
			return

		if (BLOODCULT_STAGE_DEFEATED)
			to_chat(activator, "<span class='sinister'>The rune pulses but no energies respond to its signal.</span>")
			to_chat(activator, "<span class='sinister'>With the Bloodstone's collapse, the veil in this region of space has fully mended itself. Another cult will make an attempt in another space station someday.</span>")
			abort()
			return

		if (BLOODCULT_STAGE_NARSIE)
			to_chat(activator, "<span class='sinister'>The tear has already be opened. Praise the Geometer in this most unholy day!</span>")
			abort()
			return

	if (cult.stage != BLOODCULT_STAGE_READY)
		to_chat(activator, "<span class='warning'>Cult faction appears to be in an unset stage. Something's broken, please report the issue to an admin or using the BugReport button at the top.</span>")
		abort()
		return

	if (R.z != map.zMainStation)
		to_chat(activator, "<span class='sinister'>The rune pulses but no energies respond to its signal.</span>")
		to_chat(activator, "<span class='sinister'>You should try again <font color='red'>aboard the station</font>.</span>")
		abort()
		return

	if (cult.tear_in_reality)
		to_chat(activator, "<span class='sinister'>The rune pulses but no energies respond to its signal.</span>")
		to_chat(activator, "<span class='sinister'>It appears that another tear is currently being opened. Somewhere...<font color='red'>to the [dir2text(get_dir(R, cult.tear_in_reality))]</font>.</span>")
		abort()
		return

	if (isspace(R.loc) || is_on_shuttle(R) || (get_dist(locate(map.center_x,map.center_y,map.zMainStation),R) > 100))
		to_chat(activator, "<span class='sinister'>The rune pulses but no energies respond to its signal.</span>")
		to_chat(activator, "<span class='sinister'>Try again <font color='red'>closer from the station's center</font>.</span>")
		abort()
		return

	//Alright now we can get down to business

/datum/rune_spell/tearreality/cast_talisman() //Tear Reality talismans create an invisible summoning rune beneath the caster's feet.
	var/obj/effect/rune/R = new(get_turf(activator))
	R.icon_state = "temp"
	R.active_spell = new type(activator,R)
	qdel(src)

/datum/rune_spell/tearreality/midcast(var/mob/add_cultist)
	//TODO

/datum/rune_spell/tearreality/abort(var/cause)
	//TODO
	..()

/*
Hall of fame of previous deprecated runes, might redesign later, noting their old word combinations there so I can easily retrieve them later.

MANIFEST GHOST: Blood 	See 	Travel
SACRIFICE: 		Hell 	Blood 	Join
DRAIN BLOOD: 	Travel 	Blood 	Self
BLOOD BOIL: 	Destroy See 	Blood

*/
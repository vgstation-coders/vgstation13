
/obj/abstract/mind_ui_element/hoverable/rune_word
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_back"
	layer = MIND_UI_BUTTON
	mouse_opacity = 0
	var/word = ""
	var/hovering = FALSE
	var/image/word_overlay

/obj/abstract/mind_ui_element/hoverable/rune_word/Appear()
	..()
	if (word && !mouse_opacity)
		mouse_opacity = 1
		flick("rune_appear",src)


/obj/abstract/mind_ui_element/hoverable/rune_word/proc/get_word_order()
	var/datum/mind_ui/bloodcult_runes/P = parent
	if(word && P.queued_rune)
		var/datum/rune_word/instance_1 = initial(P.queued_rune.word1)
		if (initial(instance_1.english) == word)
			return 1
		var/datum/rune_word/instance_2 = initial(P.queued_rune.word2)
		if (initial(instance_2.english) == word)
			return 2
		var/datum/rune_word/instance_3 = initial(P.queued_rune.word3)
		if (initial(instance_3.english) == word)
			return 3
	return 0


/obj/abstract/mind_ui_element/hoverable/rune_word/Hide()
	if (mouse_opacity)
		mouse_opacity = 0
		overlays.len = 0
		if (word_overlay)
			animate(word_overlay, alpha = 0, time = 2)
			overlays += word_overlay
		icon_state = "blank"
		if (word)
			flick("rune_hide",src)
	spawn(10)
		..()

/obj/abstract/mind_ui_element/hoverable/rune_word/Click()
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.write_rune(word)
			if (get_word_order() == 3 && icon_state == "rune_1")
				var/datum/mind_ui/bloodcult_runes/P = parent
				P.queued_rune = null
			parent.Display()

/obj/abstract/mind_ui_element/hoverable/rune_word/UpdateIcon(var/appear = FALSE)
	overlays.len = 0

	if (hovering)
		overlays += "select"

	if (word)
		icon_state = "rune_back"

		var/datum/mind_ui/bloodcult_runes/P = parent
		if(P.queued_rune)
			var/mob/user = GetUser()
			var/turf/T = get_turf(user)
			var/obj/effect/rune/rune = locate() in T

			if(!rune || !rune.word1)
				icon_state = "rune_[get_word_order()]"
			else if (rune.word1.type == initial(P.queued_rune.word1))
				if(!rune.word2)
					icon_state = "rune_[max(0, get_word_order() - 1)]"
				else if (rune.word2.type == initial(P.queued_rune.word2))
					if (!rune.word3)
						icon_state = "rune_[max(0, get_word_order() - 2)]"

		var/blood_color = DEFAULT_BLOOD
		var/mob/living/L = GetUser()
		if (isalien(L))
			blood_color = ALIEN_BLOOD
		else if (ishuman(L))
			var/mob/living/carbon/human/H = L
			if (H.species)
				blood_color = H.species.blood_color
		var/datum/rune_word/W = rune_words[word]
		word_overlay = image('icons/effects/deityrunes.dmi',src,word)
		var/image/rune_tear = image('icons/effects/deityrunes.dmi',src,"[word]-tear")
		word_overlay.color = blood_color
		rune_tear.color = "black"
		word_overlay.overlays += rune_tear
		word_overlay.pixel_x = W.offset_x
		word_overlay.pixel_y = W.offset_y
		if (appear)
			word_overlay.alpha = 0
			animate(word_overlay, alpha = 255, time = 5)
		overlays += word_overlay

/obj/abstract/mind_ui_element/hoverable/rune_word/StartHovering()
	hovering = TRUE
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/rune_word/StopHovering()
	hovering = FALSE
	UpdateIcon()

////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - RUNE WRITING					  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_runes
	uniqueID = "Bloodcult Runes"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/rune_close,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_travel,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_blood,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_join,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_hell,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_destroy,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_technology,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_self,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_see,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_other,
		/obj/abstract/mind_ui_element/hoverable/rune_word/rune_hide,
		)
	display_with_parent = FALSE
	var/datum/rune_spell/queued_rune = null

/datum/mind_ui/bloodcult_runes/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M) && iscarbon(M))
		return TRUE
	return FALSE

/datum/mind_ui/bloodcult_runes/Display()
	..()
	if(queued_rune)
		var/mob/user = GetUser()
		var/turf/T = get_turf(user)
		var/obj/effect/rune/rune = locate() in T
		if(rune)
			if (rune.word1 && rune.word1.type != initial(queued_rune.word1))
				to_chat(user, "<span class='warning'>This rune's first word conflicts with the [initial(queued_rune.name)] rune's syntax.</span>")
			else if (rune.word2 && rune.word2.type != initial(queued_rune.word2))
				to_chat(user, "<span class='warning'>This rune's second word conflicts with the [initial(queued_rune.name)] rune's syntax.</span>")
			else if (rune.word3)
				to_chat(user, "<span class='warning'>You cannot add more than 3 words to a rune.</span>")

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_close
	name = "Hide Interface"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "return"
	layer = MIND_UI_BUTTON
	var/hovering = FALSE

/obj/abstract/mind_ui_element/hoverable/rune_close/StartHovering()
	hovering = TRUE
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/rune_close/StopHovering()
	hovering = FALSE
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/rune_close/Click()
	parent.Hide()
	var/datum/mind_ui/bloodcult_runes/P = parent
	P.queued_rune = null

/obj/abstract/mind_ui_element/hoverable/rune_close/UpdateIcon()
	overlays.len = 0
	if (hovering)
		overlays += "select"

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_travel
	name = "Travel"
	word = "travel"
	offset_x = -61
	offset_y = 19

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_blood
	name = "Blood"
	word = "blood"
	offset_x = -37
	offset_y = 52

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_join
	name = "Join"
	word = "join"
	offset_x = 0
	offset_y = 64

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_hell
	name = "Hell"
	word = "hell"
	offset_x = 37
	offset_y = 52

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_destroy
	name = "Destroy"
	word = "destroy"
	offset_x = 61
	offset_y = 19

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_technology
	name = "Technology"
	word = "technology"
	offset_x = 61
	offset_y = -19

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_self
	name = "Self"
	word = "self"
	offset_x = 37
	offset_y = -52

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_see
	name = "See"
	word = "see"
	offset_x = 0
	offset_y = -64

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_other
	name = "Other"
	word = "other"
	offset_x = -37
	offset_y = -52

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_word/rune_hide
	name = "Hide"
	word = "hide"
	offset_x = -61
	offset_y = -19

//------------------------------------------------------------

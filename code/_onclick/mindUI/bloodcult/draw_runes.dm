
/obj/abstract/mind_ui_element/hoverable/rune_word
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_back"
	layer = MIND_UI_BUTTON
	var/word = ""
	var/hovering = FALSE
	var/image/word_overlay

/obj/abstract/mind_ui_element/hoverable/rune_word/Appear()
	..()
	if (word)
		mouse_opacity = 1
		flick("rune_appear",src)

/obj/abstract/mind_ui_element/hoverable/rune_word/Hide()
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

/obj/abstract/mind_ui_element/hoverable/rune_close/Click()
	var/mob/living/carbon/C = GetUser()


/obj/abstract/mind_ui_element/hoverable/rune_word/UpdateIcon(var/appear = FALSE)
	overlays.len = 0

	if (hovering)
		overlays += "select"

	if (word)
		icon_state = "rune_back"
		var/datum/mind_ui/bloodcult_runes/P = parent
		if (word in P.word_queue)
			icon_state = "rune_[min(P.word_queue.Find(word),3)]"

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
	display_with_parent = TRUE
	var/list/word_queue = list()

/datum/mind_ui/bloodcult_runes/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M) && iscarbon(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/rune_close
	name = "Hide UI"
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

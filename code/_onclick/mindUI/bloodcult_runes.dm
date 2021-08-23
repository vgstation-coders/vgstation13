
/obj/abstract/mind_ui_element/hoverable/rune_word
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_back"
	layer = MIND_UI_BUTTON
	mouse_opacity = 1
	var/word = ""
	var/hovering = FALSE

/obj/abstract/mind_ui_element/hoverable/rune_word/Appear()
	..()
	if (word)
		mouse_opacity = 1
		flick("rune_appear",src)

/obj/abstract/mind_ui_element/hoverable/rune_word/Hide()
	mouse_opacity = 0
	overlays.len = 0
	icon_state = "blank"
	if (word)
		flick("rune_hide",src)
	spawn(10)
		..()

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
		var/image/rune_blood = image('icons/effects/deityrunes.dmi',src,word)
		var/image/rune_tear = image('icons/effects/deityrunes.dmi',src,"[word]-tear")
		rune_blood.color = blood_color
		rune_tear.color = "black"
		rune_blood.overlays += rune_tear
		rune_blood.pixel_x = W.offset_x
		rune_blood.pixel_y = W.offset_y
		if (appear)
			rune_blood.alpha = 0
			animate(rune_blood, alpha = 255, time = 2)
		overlays += rune_blood

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
	icon_state = "return"

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

/obj/abstract/mind_ui_element/hoverable/test_hello/Click()
	flick("hello-click",src)
	to_chat(GetUser(), "[bicon(src)] Hello World!")

//------------------------------------------------------------
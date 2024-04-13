
////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - CULTIST							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist
	uniqueID = "Cultist"
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_cultist_panel,
		/datum/mind_ui/bloodcult_left_panel,
		/datum/mind_ui/bloodcult_right_panel,
		)
	display_with_parent = TRUE
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - RUNEDRAW						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_cultist_panel
	uniqueID = "Cultist Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/draw_runes_manual,
		/obj/abstract/mind_ui_element/hoverable/draw_runes_guided,
		/obj/abstract/mind_ui_element/hoverable/erase_runes,
		/obj/abstract/mind_ui_element/hoverable/movable/cultist,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_runes,
		)
	display_with_parent = TRUE
	offset_layer = MIND_UI_GROUP_C
	y = "BOTTOM"

/datum/mind_ui/bloodcult_cultist_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M) && iscarbon(M))
		return TRUE
	return FALSE


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/draw_runes_manual
	name = "Trace Runes Manually"
	desc = "(1 BLOOD PER WORD) Use available blood to write down words. Three words form a rune."
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_manual"
	layer = MIND_UI_BUTTON
	offset_x = 111
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/draw_runes_manual/Click()
	flick("rune_manual-click",src)
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.verbose = TRUE
		M.DisplayUI("Bloodcult Runes")

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/draw_runes_guided
	name = "Trace Rune with a Guide"
	desc = "(1 BLOOD PER WORD) Use available blood to write down words. Three words form a rune. Access a list of the well known runes."
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "rune_guide"
	layer = MIND_UI_BUTTON
	offset_x = 111
	offset_y = 39
	mouse_opacity = 1


/obj/abstract/mind_ui_element/hoverable/draw_runes_guided/Appear()
	..()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (cult.stage == BLOODCULT_STAGE_DEFEATED)
		icon_state = "rune_guide-broken"
		hover_state = FALSE


/obj/abstract/mind_ui_element/hoverable/draw_runes_guided/Click()
	if (!hover_state)
		return
	flick("rune_guide-click",src)
	var/mob/M = GetUser()
	if (M)

		var/list/available_runes = list()
		var/i = 1
		for(var/blood_spell in subtypesof(/datum/rune_spell))
			var/datum/rune_spell/instance = blood_spell
			if (initial(instance.secret))
				continue
			available_runes.Add("[initial(instance.name)] - \Roman[i]")
			available_runes["[initial(instance.name)] - \Roman[i]"] = instance
			i++
		var/spell_name = input(M,"Remember how to trace a given rune.", "Trace Rune with a Guide", null) as null|anything in available_runes

		if (spell_name)
			for(var/datum/mind_ui/bloodcult_runes/BR in parent.subUIs)
				BR.queued_rune = available_runes[spell_name]

				var/datum/role/cultist/C = iscultist(M)
				if (C)
					C.verbose = TRUE
				M.DisplayUI("Bloodcult Runes")
				break

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/erase_runes
	name = "Erase Rune"
	desc = "Remove the last word written of the rune you're standing above."
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "rune_erase"
	layer = MIND_UI_BUTTON
	offset_x = 95
	offset_y = 39
	mouse_opacity = 1

/obj/abstract/mind_ui_element/hoverable/erase_runes/Click()
	flick("rune_erase-click",src)
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.erase_rune()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/cultist
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "rune_move"
	layer = MIND_UI_BUTTON
	offset_x = 143
	offset_y = 39
	mouse_opacity = 1

	move_whole_ui = TRUE



////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - RIGHT PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_right_panel
	uniqueID = "Cultist Right Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_spells_background,
		/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/solo,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/sigil,
		/obj/abstract/mind_ui_element/hoverable/movable/cult_spells,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/hex_controller/first,
		/datum/mind_ui/hex_controller/second,
		)

	display_with_parent = TRUE
	offset_layer = MIND_UI_GROUP_C

/datum/mind_ui/bloodcult_right_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_spells_background
	name = "Cult Powers"
	icon = 'icons/ui/bloodcult/32x121.dmi'
	icon_state = "powers_bg"
	offset_x = 192
	offset_y = -96
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_spells_background/CanAppear()
	var/mob/living/M = GetUser()
	return iscarbon(M)

/obj/abstract/mind_ui_element/bloodcult_spells_background/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer
	name = "Hex Control Panel"
	icon = 'icons/ui/bloodcult/32x121.dmi'
	icon_state = "artificer_bg"
	offset_x = 192
	offset_y = -96
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer/CanAppear()
	var/mob/living/M = GetUser()
	return istype(M, /mob/living/simple_animal/construct/builder/perfect)

/obj/abstract/mind_ui_element/bloodcult_spells_background_artificer/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter
	name = "Devotion"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "devotion_counter"
	offset_x = 192
	offset_y = -110
	layer = MIND_UI_BACK+0.5

	hover_state = FALSE
	element_flags = MINDUI_FLAG_TOOLTIP|MINDUI_FLAG_PROCESSING
	tooltip_title = "Devotion"
	tooltip_content = "Performing cult activities generates devotion, which hastens the coming of the Eclipse and rewards you with new powers.<br><br>Cult activities range from using most runes, to harming living beings with cult weapons.<br><br>Some activities generate less devotion past a certain threshold. Experiment and find out."
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/CanAppear()
	var/mob/living/M = GetUser()
	if (iscarbon(M))
		return TRUE
	else if (istype(M, /mob/living/simple_animal/construct/builder/perfect))
		return TRUE
	return FALSE

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/UpdateIcon()
	overlays.len = 0
	var/datum/role/cultist/C = parent.mind.GetRole(CULTIST)
	var/devotion = min(9999,C.devotion)
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if ((cult.stage == BLOODCULT_STAGE_DEFEATED) || (cult.stage == BLOODCULT_STAGE_NARSIE))
		overlays += String2Image("[add_zero(devotion,4)]",_color="#FF0000",_pixel_x = 4,_pixel_y = 9)
	else
		overlays += String2Image("[add_zero(devotion,4)]",_color="#FFFFFF",_pixel_x = 4,_pixel_y = 9)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/solo
	icon_state = "devotion_counter_solo"
	offset_y = -92

/obj/abstract/mind_ui_element/hoverable/bloodcult_devotion_counter/solo/CanAppear()
	var/mob/living/M = GetUser()
	if (iscarbon(M))
		return FALSE
	else if (istype(M, /mob/living/simple_animal/construct/builder/perfect))
		return FALSE
	return TRUE

//////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell
	icon = 'icons/ui/bloodcult/24x24.dmi'
	icon_state = "blank"
	offset_x = 196
	invisibility = 101 	// Invisible by default
	layer = MIND_UI_BUTTON

	var/required_tattoo
	var/image/spell_overlay

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/CanAppear()
	if(!required_tattoo)
		return TRUE
	var/mob/living/M = GetUser()
	if(M.checkTattoo(required_tattoo))
		return iscarbon(M)
	return FALSE

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/Appear()
	if(!CanAppear())
		invisibility = 101
		return
	..()

/////////////////////////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool
	name = "Blood Pooling"
	offset_y = -87
	required_tattoo = TATTOO_POOL
	icon_state = "power_pool"


/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool/UpdateIcon(var/appear = FALSE)
	var/mob/living/M = GetUser()
	var/datum/role/cultist/C = iscultist(M)
	if (C.blood_pool)
		icon_state = "power_pool"
	else
		icon_state = "power_pool_off"
	base_icon_state = icon_state

	var/pool_current = 0
	for (var/datum/role/cultist/CU in blood_communion)
		if (CU.blood_pool && CU.antag && CU.antag.current && iscarbon(CU.antag.current) && !CU.antag.current.isDead())
			pool_current++
	overlays.len = 0
	overlays += String2Image("[pool_current]",_pixel_x = 2,_pixel_y = 1)

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/pool/Click()
	var/mob/living/M = GetUser()
	var/datum/role/cultist/C = iscultist(M)

	C.blood_pool = !C.blood_pool

	for (var/datum/role/cultist/CU in blood_communion)
		CU.antag.current.DisplayUI("Cultist Right Panel")

	M.update_mutations()

	if (C.blood_pool)
		to_chat(M, "<span class='warning'>You return to the blood pool. Blood costs are slightly reduced, on top of getting split between you and other cultists.</span>")
	else
		to_chat(M, "<span class='warning'>You remove yourself from the blood pool. Blood costs must now be paid on your own.</span>")
	UpdateIcon()

/////////////////////////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman
	name = "Runic Skin"
	offset_y = -31
	required_tattoo = TATTOO_RUNESTORE
	icon_state = "power_runic"

	var/obj/item/weapon/talisman/talisman

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman/UpdateIcon(var/appear = FALSE)
	overlays.len = 0

	if(talisman)
		var/image/I = image('icons/ui/bloodcult/32x32.dmi',src,"blank")
		I.appearance = talisman.appearance
		I.layer = FLOAT_LAYER
		I.plane = FLOAT_PLANE
		I.pixel_x = -2
		I.pixel_y = -5
		overlays += I
		overlays += "power_runic-over"

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/talisman/Click()
	var/mob/living/M = GetUser()

	if(talisman)
		talisman.trigger(M)
	else if(istype(M.held_items[M.active_hand], /obj/item/weapon/talisman))
		var/obj/item/weapon/talisman/T = M.held_items[M.active_hand]
		if(T.spell_type)
			M.drop_item(T, force_drop = 1)
			T.linked_ui = src
			T.forceMove(M)
			talisman = T
	else
		to_chat(M, "<span class='warning'>Hold an imbued talisman in your active hand to fuse it with your skin.</span>")
	UpdateIcon()


/////////////////////////////////////////



/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger
	name = "Blood Dagger"
	offset_y = -59
	required_tattoo = TATTOO_DAGGER
	icon_state = "power_dagger"

	var/obj/item/weapon/melee/blood_dagger/dagger

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/dagger/Click()

	var/mob/living/carbon/user = GetUser()

	if(!dagger)  // dagger not pulled out

		if (user.occult_muted())
			to_chat(user, "<span class='warning'>You try grasping your blood but you can't quite will it into the shape of a dagger.</span>")
			return
		var/list/data = use_available_blood(user, 5)
		if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
			return 0
		var/dagger_color = DEFAULT_BLOOD
		var/datum/reagent/blood/source = data["blood"]
		if (source.data["blood_colour"])
			dagger_color = source.data["blood_colour"]

		var/good_hand
		if(ishuman(user))
			var/mob/living/carbon/human/H = user


			if(H.can_use_hand(H.active_hand))
				good_hand = H.active_hand
			else
				for(var/i = 1 to H.held_items.len)
					if(H.can_use_hand(i))
						good_hand = i
						break
		else   // cultist is a monkey or alien
			if(user.can_use_hands())
				good_hand = user.active_hand

		if(good_hand)
			user.drop_item(user.held_items[good_hand], force_drop = 1)
			var/obj/item/weapon/melee/blood_dagger/BD = new (user)
			BD.originator = user
			BD.linked_ui = src
			dagger = BD
			if (dagger_color != DEFAULT_BLOOD)
				BD.icon_state += "-color"
				BD.item_state += "-color"
				BD.color = dagger_color
			user.put_in_hand(good_hand, BD)
			user.visible_message("<span class='warning'>\The [user] squeezes the blood in their hand, and it takes the shape of a dagger!</span>",
				"<span class='warning'>You squeeze the blood in your hand, and it takes the shape of a dagger.</span>")
			playsound(user, 'sound/weapons/bloodyslice.ogg', 30, 0,-2)

	else
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/reagent/blood/B = get_blood(H.vessel)
			if (B && !(H.species.flags & NO_BLOOD))
				to_chat(user, "<span class='notice'>You sheath \the [dagger] back inside your body[dagger.stacks ? ", along with the stolen blood" : ""].</span>")
				H.vessel.add_reagent(BLOOD, 5 + dagger.stacks * 5)
				H.vessel.update_total()
			else
				to_chat(user, "<span class='notice'>You sheath \the [dagger] inside your body, but the blood fails to find vessels to occupy.</span>")
		else
			to_chat(user, "<span class='notice'>You sheath \the [dagger] inside your body.</span>")
		dagger.absorbed = 1
		playsound(user, 'sound/weapons/bloodyslice.ogg', 30, 0, -2)
		qdel(dagger)

	UpdateIcon()

/////////////////////////////////////////

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/sigil
	name = "Shortcut Sigil"
	offset_y = -3
	icon_state = "power_sigil"
	required_tattoo = TATTOO_SHORTCUT

/obj/abstract/mind_ui_element/hoverable/bloodcult_spell/sigil/Click()
	var/mob/living/M = GetUser()

	to_chat(M, "<span class='notice'>Click an adjacent wall to manifest a sigil on top of it.</span>")

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/cult_spells
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "rune_move"
	layer = MIND_UI_BUTTON
	offset_x = 224
	offset_y = -96
	mouse_opacity = 1

	move_whole_ui = TRUE

////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - LEFT PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_left_panel
	uniqueID = "Cultist Left Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/bloodcult_panel,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_panel,
		/datum/mind_ui/bloodcult_help,
		)
	display_with_parent = TRUE
	x = "LEFT"

/datum/mind_ui/bloodcult_left_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel
	name = "Cult Panel"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "role"
	offset_x = 6
	offset_y = -92

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel/New()
	..()
	click_me = image(icon, src, "click")
	click_me.layer = MIND_UI_FRONT
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel/Click()
	flick("role-click",src)

	var/datum/mind_ui/bloodcult_panel/cult_panel = locate() in parent.subUIs
	if(cult_panel)
		cult_panel.Display()

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			overlays.len = 0
			switch(C.cultist_role)
				if (CULTIST_ROLE_NONE)
					if (M.client)
						M.client.images += click_me
				if (CULTIST_ROLE_ACOLYTE)
					overlays += "role_acolyte"
				if (CULTIST_ROLE_HERALD)
					overlays += "role_herald"
				if (CULTIST_ROLE_MENTOR)
					overlays += "role_mentor"

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help
	name = "How do I Cult?"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "help"
	offset_x = 6
	offset_y = -119
	var/clicked = FALSE

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/New()
	..()
	click_me = image(icon, src, "click")
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/Appear()
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (M.client)
			M.client.images -= click_me
		if (C)
			if (C.cultist_role != CULTIST_ROLE_ACOLYTE)
				invisibility = 101	// We only appear to Acolytes
			else
				..()
				if (!C.mentor && !clicked && M.client)
					M.client.images += click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_help/Click()
	flick("help-click",src)
	if (!clicked)
		clicked = TRUE
		var/mob/M = GetUser()
		if (M)
			if (M.client)
				M.client.images -= click_me
	var/datum/mind_ui/bloodcult_help/tooltip = locate() in parent.subUIs
	if(tooltip)
		tooltip.Display()


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - HEX CONTROLLER					  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/hex_controller
	uniqueID = "Hex Controller"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/hex_controller/harm,
		/obj/abstract/mind_ui_element/hoverable/hex_controller/roam,
		/obj/abstract/mind_ui_element/hoverable/hex_controller/escort,
		/obj/abstract/mind_ui_element/hoverable/hex_controller/guard,
		)
	display_with_parent = TRUE

	offset_layer = MIND_UI_GROUP_D
	var/controller = 0

/datum/mind_ui/hex_controller/Valid()
	if (!controller)
		return
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(istype(M, /mob/living/simple_animal/construct/builder/perfect))
		var/mob/living/simple_animal/construct/builder/perfect/master = M
		if (master.minions.len >= controller)
			return TRUE
	return FALSE

/datum/mind_ui/hex_controller/first
	controller = 1

/datum/mind_ui/hex_controller/second
	controller = 2

/obj/abstract/mind_ui_element/hoverable/hex_controller
	icon = 'icons/ui/bloodcult/24x24.dmi'
	offset_x = 196
	offset_y = -87
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/hex_controller/New(turf/loc, var/datum/mind_ui/hex_controller/P)
	if (!istype(P))
		qdel(src)
		return
	..()
	if (P.controller > 1)
		offset_y = -87 + (28*(P.controller-1))
	UpdateUIScreenLoc()

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/harm
	name = "Aggressive"
	icon_state = "hexcontrol_harm"

/obj/abstract/mind_ui_element/hoverable/hex_controller/harm/Click()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.passive = !H.passive
			H.update_harmglow()
			if (H.passive)
				name = "Passive"
				icon_state = "hexcontrol_passive"
				H.stance = HOSTILE_STANCE_IDLE
				H.target = null
			else
				name = "Aggressive"
				icon_state = "hexcontrol_harm"
				var/new_target = H.FindTarget()
				H.GiveTarget(new_target)
				if (H.target)
					H.MoveToTarget()
			base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/hex_controller/harm/UpdateIcon()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			if (H.passive)
				name = "Passive"
				icon_state = "hexcontrol_passive"
			else
				name = "Aggressive"
				icon_state = "hexcontrol_harm"
			base_icon_state = icon_state

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/roam
	name = "Roam"
	icon_state = "hexcontrol_roam"

/obj/abstract/mind_ui_element/hoverable/hex_controller/roam/Click()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.mode = HEX_MODE_ROAMING
			walk(H,0)
			P.Display()

/obj/abstract/mind_ui_element/hoverable/hex_controller/roam/UpdateIcon()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			switch (H.mode)
				if (HEX_MODE_ROAMING)
					icon_state = "hexcontrol_roam"
				else
					icon_state = "hexcontrol_roam-off"
			base_icon_state = icon_state

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/escort
	name = "Escort"
	icon_state = "hexcontrol_escort-off"

/obj/abstract/mind_ui_element/hoverable/hex_controller/escort/Click()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.mode = HEX_MODE_ESCORT
			H.escort_routine()
			P.Display()

/obj/abstract/mind_ui_element/hoverable/hex_controller/escort/UpdateIcon()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			switch (H.mode)
				if (HEX_MODE_ESCORT)
					icon_state = "hexcontrol_escort"
				else
					icon_state = "hexcontrol_escort-off"
			base_icon_state = icon_state

////////////////////////

/obj/abstract/mind_ui_element/hoverable/hex_controller/guard
	name = "Guard"
	icon_state = "hexcontrol_guard-off"

/obj/abstract/mind_ui_element/hoverable/hex_controller/guard/Click()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			H.mode = HEX_MODE_GUARD
			H.guard_spot = get_turf(H)
			walk(H,0)
			P.Display()

/obj/abstract/mind_ui_element/hoverable/hex_controller/guard/UpdateIcon()
	var/mob/living/simple_animal/construct/builder/perfect/M = GetUser()
	var/datum/mind_ui/hex_controller/P = parent
	if (M && P && P.controller)
		if (M.minions.len >= P.controller)
			var/mob/living/simple_animal/hostile/hex/H = M.minions[P.controller]
			switch (H.mode)
				if (HEX_MODE_GUARD)
					icon_state = "hexcontrol_guard"
				else
					icon_state = "hexcontrol_guard-off"
			base_icon_state = icon_state


//------------------------------------------------------------

////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - MAIN PANEL						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_panel
	uniqueID = "Cult Panel"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_panel_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_panel_close,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_panel_move,

		/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count,
		/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge,
		/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_front,

		/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion,

		/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_soulblades,
		/obj/abstract/mind_ui_element/bloodcult_soulblades_count,

		/obj/abstract/mind_ui_element/hoverable/bloodcult_role,
		/obj/abstract/mind_ui_element/bloodcult_your_role,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_other,
		)
	sub_uis_to_spawn = list(
		/datum/mind_ui/bloodcult_role,
		/datum/mind_ui/bloodcult_rituals,
		/datum/mind_ui/bloodcult_ritual_narsie,
		)
	display_with_parent = FALSE

	var/list/cultist_slots = list()

/datum/mind_ui/bloodcult_panel/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

/datum/mind_ui/bloodcult_panel/SpawnElements()
	..()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (istype(cult))
		for (var/i = 1 to MINDUI_MAX_CULT_SLOTS)
			var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/new_slot = new(null, src)
			elements += new_slot
			cultist_slots += new_slot

/datum/mind_ui/bloodcult_panel/Display()
	..()
	if (active)
		var/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager/slot_manager = locate() in elements
		slot_manager.UpdateIcon()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_panel_background
	name = "Cult Panel"
	icon = 'icons/ui/bloodcult/362x229.dmi'
	icon_state = "background2"
	offset_x = -165
	offset_y = -93
	alpha = 240
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_panel_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel_close
	name = "Close"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 181
	offset_y = 120
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_panel_close/Click()
	parent.Hide()


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_panel_move
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -165
	offset_y = 120
	mouse_opacity = 1

	move_whole_ui = TRUE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count
	name = "Eclipse Timer"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "blank"
	offset_x = -13
	offset_y = 88
	layer = MIND_UI_FRONT
	element_flags = MINDUI_FLAG_PROCESSING
	mouse_opacity = 0
	var/red_blink = FALSE

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_count/UpdateIcon()
	overlays.len = 0
	offset_x = -13

	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (istype(cult))
		switch(cult.stage)
			if (BLOODCULT_STAGE_NORMAL)
				var/eclipse_remaining = cult.eclipse_target - cult.eclipse_progress
				var/eclipse_ticks_to_go_at_current_rate = 999999
				if (cult.eclipse_increments > 0)
					eclipse_ticks_to_go_at_current_rate = eclipse_remaining / max(0.1, cult.eclipse_increments)
					if(SSticker.initialized)
						eclipse_ticks_to_go_at_current_rate *= (SSticker.wait/10)

				var/hours_to_go = round(eclipse_ticks_to_go_at_current_rate/3600)
				var/minutes_to_go = add_zero(num2text(round(eclipse_ticks_to_go_at_current_rate/60) % 60), 2)
				var/seconds_to_go = add_zero(num2text(round(eclipse_ticks_to_go_at_current_rate) % 60), 2)
				if (eclipse_ticks_to_go_at_current_rate <= 60)
					if (!cult.soon_announcement)
						cult.soon_announcement = TRUE
						for (var/datum/role/R in cult.members)
							var/mob/M = R.antag.current
							to_chat(M, "<span class='sinister'>The Eclipse is almost upon us...</span>")

					red_blink = !red_blink
					var/image/I = String2Image("[hours_to_go]:[minutes_to_go]:[seconds_to_go]",10,'icons/ui/font_16x16.dmi',"#FFFFFF")
					if (red_blink)
						I.color = "red"
					else
						I.color = null
					overlays += I
				else
					overlays += String2Image("[hours_to_go]:[minutes_to_go]:[seconds_to_go]",10,'icons/ui/font_16x16.dmi',"#FFFFFF")

			if (BLOODCULT_STAGE_READY)
				var/eclipse_ticks_before_end_at_current_rate = max(0, (sun.eclipse_manager.eclipse_end_time - world.time)/10)
				var/hours_to_go = round(eclipse_ticks_before_end_at_current_rate/3600)
				var/minutes_to_go = add_zero(num2text(round(eclipse_ticks_before_end_at_current_rate/60) % 60), 2)
				var/seconds_to_go = add_zero(num2text(round(eclipse_ticks_before_end_at_current_rate) % 60), 2)
				if (eclipse_ticks_before_end_at_current_rate == 0)
					red_blink = !red_blink
					var/image/I = String2Image("0:00:00",10,'icons/ui/font_16x16.dmi',"#FFFFFF")
					if (red_blink)
						I.color = "red"
					else
						I.color = null
					overlays += I
				else
					overlays += String2Image("[hours_to_go]:[minutes_to_go]:[seconds_to_go]",10,'icons/ui/font_16x16.dmi',"#FFFFFF")

			if (BLOODCULT_STAGE_ECLIPSE)
				offset_x = -24
				var/time_before_narsie = max(0, (cult.bloodstone_target_time - world.time)/10)
				var/minutes_to_go = num2text(round(time_before_narsie/60))
				var/seconds_to_go
				if (minutes_to_go == "7")//6:66 lmao
					minutes_to_go = "6"
					seconds_to_go = add_zero(num2text((min(6,round(time_before_narsie) % 60))+60), 2)
				else
					seconds_to_go = add_zero(num2text(round(time_before_narsie) % 60), 2)
				overlays += String2Image("  [minutes_to_go]:[seconds_to_go]",10,'icons/ui/font_16x16.dmi',"#FFFFFF")

			if (BLOODCULT_STAGE_NARSIE)
				overlays += String2Image("0:00:00",10,'icons/ui/font_16x16.dmi',"#FF0000")
			else
				overlays += String2Image("0:00:00",10,'icons/ui/font_16x16.dmi',"#999999")
	UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge
	name = "Blood"
	icon = 'icons/ui/bloodcult/288x16.dmi'
	icon_state = "eclipse_gauge"
	layer = MIND_UI_BUTTON
	offset_x = -128
	offset_y = 86
	element_flags = MINDUI_FLAG_PROCESSING

	var/image/mask

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge/New()
	..()
	appearance_flags |= KEEP_TOGETHER
	mask = image(icon, src, "eclipse_gauge_bg")
	mask.blend_mode = BLEND_INSET_OVERLAY
	add_particles(PS_CULT_GAUGE)

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/bloodcult_eclipse_gauge/UpdateIcon()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (istype(cult))
		switch(cult.stage)
			if (BLOODCULT_STAGE_NORMAL)
				name = "Time before the Eclipse"
				mask.pixel_x = 288*(cult.eclipse_progress/cult.eclipse_target)
				adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16,-1), list(mask.pixel_x-16,-14)))
				adjust_particles(PVAR_VELOCITY, list(-1*(mask.pixel_x)/40, 0))
				overlays.len = 0
				overlays += mask

			if (BLOODCULT_STAGE_READY)
				name = "Time until the Eclipse ends"
				mask.pixel_x = max(0, 288 - 288*((world.time - sun.eclipse_manager.eclipse_start_time)/(sun.eclipse_manager.eclipse_end_time - sun.eclipse_manager.eclipse_start_time)))
				if (sun.eclipse_manager.eclipse_end_time <= world.time)
					adjust_particles(PVAR_SPAWNING, 0)
				else
					adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16,-1), list(mask.pixel_x-16,-14)))
					adjust_particles(PVAR_VELOCITY, list((288-mask.pixel_x)/40, 0))
				overlays.len = 0
				overlays += mask

			if (BLOODCULT_STAGE_ECLIPSE)
				name = "Time until Nar-Sie rises"
				mask.pixel_x = max(0, 288*((world.time - cult.bloodstone_rising_time)/(cult.bloodstone_target_time - cult.bloodstone_rising_time)))
				adjust_particles(PVAR_POSITION, generator("box", list(mask.pixel_x-16,-1), list(mask.pixel_x-16,-14)))
				adjust_particles(PVAR_VELOCITY, list(-1*(mask.pixel_x)/40, 0))
				overlays.len = 0
				overlays += mask
			else
				adjust_particles(PVAR_SPAWNING, 0)
				mask.pixel_x = 0
				overlays.len = 0
				overlays += mask

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_front
	name = "Eclipse Timer"
	icon = 'icons/ui/bloodcult/362x229.dmi'
	icon_state = "foreground"
	offset_x = -165
	offset_y = -93
	alpha = 255
	layer = MIND_UI_FRONT
	mouse_opacity = 0

/obj/abstract/mind_ui_element/bloodcult_eclipse_timer_front/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate
	name = "Eclipse Rate"
	icon = 'icons/ui/bloodcult/104x40.dmi'
	icon_state = "eclipse_rate"
	offset_x = -9
	offset_y = 103
	layer = MIND_UI_FRONT+0.5

	hover_state = FALSE
	element_flags = MINDUI_FLAG_PROCESSING|MINDUI_FLAG_TOOLTIP
	tooltip_title = "Eclipse Rate"
	tooltip_content = "The rate at which the Eclipse is coming.<br>The rate can be increased by both generating devotion, and growing the cult's numbers.<br>Dead cultists no longer contribute to the rate, until they revive that is."
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate/Appear()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if(cult.stage != BLOODCULT_STAGE_NORMAL)
		invisibility = 101
		return
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/bloodcult_eclipse_rate/UpdateIcon()
	overlays.len = 0
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	var/eclipse_rate = min(99.999, cult.eclipse_increments)
	overlays += String2Image("[add_zero_before_and_after(round(eclipse_rate, 0.001), 2, 3)]",_pixel_x = 10,_pixel_y = 2)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion
	name = "Total Devotion"
	icon = 'icons/ui/bloodcult/104x40.dmi'
	icon_state = "total_devotion"
	offset_x = -9
	offset_y = 69
	layer = MIND_UI_FRONT+0.5

	hover_state = FALSE
	element_flags = MINDUI_FLAG_PROCESSING|MINDUI_FLAG_TOOLTIP
	tooltip_title = "Total Devotion"
	tooltip_content = "The total devotion accumulated by all cultists aboard this station."
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/hoverable/bloodcult_total_devotion/UpdateIcon()
	overlays.len = 0
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	var/total_devotion = min(9999999,cult.total_devotion)
	if ((cult.stage == BLOODCULT_STAGE_DEFEATED) || (cult.stage == BLOODCULT_STAGE_NARSIE))
		overlays += String2Image("[add_zero(total_devotion,7)]",_color="#FF0000",_pixel_x = 4,_pixel_y = 4)
	else
		overlays += String2Image("[add_zero(total_devotion,7)]",_color="#FFFFFF",_pixel_x = 4,_pixel_y = 4)


//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager
	name = "Cultist Slots"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "blank"
	element_flags = MINDUI_FLAG_PROCESSING

/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager/process()
	if (invisibility == 101)
		return
	UpdateIcon()

/obj/abstract/mind_ui_element/bloodcult_cultist_slot_manager/UpdateIcon()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	if (istype(cult))
		var/mob/M = GetUser()
		if (M)
			var/datum/role/cultist/C = iscultist(M)
			if(C)
				var/i = 1
				var/cap_placed = 0
				var/list/ritualized_soulblades = list()//lists minds that undertook a soulblade ritual, saving their cult slot for others
				var/accumulated_offset = -12 * max(0,cult.members.len - cult.max_cultist_cap) //in case of suspiciously large overflow, we shift the slots to the left so they remain centered
				var/list/free_construct_slots = list()
				var/list/construct_types = list("Artificer","Wraith","Juggernaut")
				var/datum/mind_ui/bloodcult_panel/BP = parent
				if (cult.cultist_cap == 0)//blood stone destroyed
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap/cultist_cap = locate() in BP.elements
					accumulated_offset -= 4
					cultist_cap.offset_x = -98 + accumulated_offset
					cultist_cap.UpdateUIScreenLoc()
					accumulated_offset += 7
					cap_placed = 1
				for (var/datum/role/cultist/R in cult.members)
					var/mob/O = R.antag.current
					if (!O || O.isDead())
						continue
					if (isshade(O))
						var/mob/living/simple_animal/shade/S = O
						if (S.soulblade_ritual)//we track soulbladed shades elsewhere
							ritualized_soulblades += R.antag
							continue
					if (istype(O, /mob/living/simple_animal/construct))
						var/mob/living/simple_animal/construct/cons = O
						if (!(cons.construct_type in free_construct_slots))
							free_construct_slots += cons.construct_type
							var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/S
							switch(cons.construct_type)
								if ("Artificer")
									var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer/artificer_slot = locate() in BP.elements
									artificer_slot.associated_role = R
									artificer_slot.icon_state = "slot_artificer[artificer_slot.hovering ? "-hover" : ""]"
									artificer_slot.base_icon_state = "slot_artificer"
									S = artificer_slot
								if ("Wraith")
									var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith/wraith_slot = locate() in BP.elements
									wraith_slot.associated_role = R
									wraith_slot.icon_state = "slot_wraith[wraith_slot.hovering ? "-hover" : ""]"
									wraith_slot.base_icon_state = "slot_wraith"
									S = wraith_slot
								if ("Juggernaut")
									var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut/juggernaut_slot = locate() in BP.elements
									juggernaut_slot.associated_role = R
									juggernaut_slot.icon_state = "slot_juggernaut[juggernaut_slot.hovering ? "-hover" : ""]"
									juggernaut_slot.base_icon_state = "slot_juggernaut"
									S = juggernaut_slot
							S.overlays.len = 0
							if (cons.occult_muted())
								S.overlays += "holy"
							if (C == R)
								S.overlays += "you"
							continue
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
					slot.associated_role = R
					switch(R.cultist_role)
						if (CULTIST_ROLE_NONE)
							slot.icon_state = "slot_herald[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_herald"
						if (CULTIST_ROLE_ACOLYTE)
							slot.icon_state = "slot_acolyte[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_acolyte"
						if (CULTIST_ROLE_HERALD)
							slot.icon_state = "slot_herald[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_herald"
						if (CULTIST_ROLE_MENTOR)
							slot.icon_state = "slot_mentor[slot.hovering ? "-hover" : ""]"
							slot.base_icon_state = "slot_mentor"
					slot.overlays.len = 0
					if (i > cult.cultist_cap)
						slot.overlays += "overflow"
					if (O.occult_muted())
						slot.overlays += "holy"
					if (C == R)
						slot.overlays += "you"
					if (isshade(O))
						if (!istype(O.loc, /obj/item/soulstone) && !istype(O.loc, /obj/item/weapon/melee/soulblade))
							slot.overlays += "shade"
					slot.offset_x = -98 + accumulated_offset
					accumulated_offset += 17
					slot.UpdateUIScreenLoc()
					slot.locked = FALSE
					slot.invisibility = 0
					slot.overflow = (i > cult.cultist_cap)
					if (i == cult.cultist_cap)
						var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap/cultist_cap = locate() in BP.elements
						accumulated_offset -= 4
						cultist_cap.offset_x = -98 + accumulated_offset
						cultist_cap.UpdateUIScreenLoc()
						accumulated_offset += 7
						cap_placed = 1
					i++
					if (i > MINDUI_MAX_CULT_SLOTS)//If the cult manages to overflow to over 5 cultists over the cap, we don't bother tracking them anymore.
						break
				while (i <= cult.cultist_cap)
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
					slot.overlays.len = 0
					slot.offset_x = -98 + accumulated_offset
					accumulated_offset += 17
					slot.UpdateUIScreenLoc()
					slot.associated_role = null
					slot.icon_state = "slot_empty[slot.hovering ? "-hover" : ""]"
					slot.base_icon_state = "slot_empty"
					slot.locked = FALSE
					i++
				if (!cap_placed)
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap/cultist_cap = locate() in BP.elements
					accumulated_offset -= 4
					cultist_cap.offset_x = -98 + accumulated_offset
					cultist_cap.UpdateUIScreenLoc()
					accumulated_offset += 7
				if (cult.stage != BLOODCULT_STAGE_DEFEATED)
					while (i <= cult.max_cultist_cap)
						var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
						slot.offset_x = -98 + accumulated_offset
						slot.UpdateUIScreenLoc()
						accumulated_offset += 17
						slot.overlays.len = 0
						slot.associated_role = null
						slot.icon_state = "slot_empty[slot.hovering ? "-hover" : ""]"
						slot.base_icon_state = "slot_empty"
						slot.locked = TRUE
						slot.overlays += "locked"
						i++
				while (i <= MINDUI_MAX_CULT_SLOTS)
					var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/slot = BP.cultist_slots[i]
					slot.invisibility = 101
					i++
				for (var/cons_type in construct_types)
					if (!(cons_type in free_construct_slots))
						switch(cons_type)
							if ("Artificer")
								var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer/artificer_slot = locate() in BP.elements
								artificer_slot.icon_state = "slot_artificer_empty[artificer_slot.hovering ? "-hover" : ""]"
								artificer_slot.associated_role = null
								artificer_slot.base_icon_state = "slot_artificer_empty"
								artificer_slot.overlays.len = 0
							if ("Wraith")
								var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith/wraith_slot = locate() in BP.elements
								wraith_slot.icon_state = "slot_wraith_empty[wraith_slot.hovering ? "-hover" : ""]"
								wraith_slot.associated_role = null
								wraith_slot.base_icon_state = "slot_wraith_empty"
								wraith_slot.overlays.len = 0
							if ("Juggernaut")
								var/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut/juggernaut_slot = locate() in BP.elements
								juggernaut_slot.icon_state = "slot_juggernaut_empty[juggernaut_slot.hovering ? "-hover" : ""]"
								juggernaut_slot.associated_role = null
								juggernaut_slot.base_icon_state = "slot_juggernaut_empty"
								juggernaut_slot.overlays.len = 0

				var/obj/abstract/mind_ui_element/bloodcult_soulblades_count/soulblades_count = locate() in BP.elements
				soulblades_count.overlays.len = 0
				var/obj/abstract/mind_ui_element/hoverable/bloodcult_soulblades/soulblades = locate() in BP.elements
				soulblades.tooltip_content = ""
				if (ritualized_soulblades.len > 0)
					for (var/datum/mind/blade_mind in ritualized_soulblades)
						soulblades.tooltip_content += "[blade_mind.name]<br>"
					soulblades_count.overlays += String2Image("[ritualized_soulblades.len]")
				else
					soulblades.tooltip_content = "People (both cultists and otherwise) sacrificed with an empty soul blade won't take up a slot until the blade and its shade get separated."


//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot
	name = "Cultist Slot"
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "slot_empty"
	base_icon_state = "slot_empty"
	layer = MIND_UI_BUTTON
	offset_x = -98
	offset_y = -28
	tooltip_title = "Cultist Slot"
	tooltip_content = ""
	tooltip_theme = "radial-cult"
	element_flags = MINDUI_FLAG_TOOLTIP

	var/datum/role/cultist/associated_role
	var/locked = FALSE
	var/overflow = FALSE

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/StartHovering(var/location,var/control,var/params)
	set_tooltip()
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/StopHovering()
	..()
	remove_particles()

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/proc/set_tooltip()
	if (associated_role)
		add_particles(PS_CULT_HALO)
		adjust_particles(PVAR_ICON_STATE,"cult_halo[associated_role.get_devotion_rank()]",PS_CULT_HALO)
		adjust_particles(PVAR_PLANE,HUD_PLANE,PS_CULT_HALO)
		adjust_particles(PVAR_LAYER,MIND_UI_BUTTON+0.5,PS_CULT_HALO)
		adjust_particles(PVAR_PIXEL_X,-8,PS_CULT_HALO)
		var/datum/mind/M = associated_role.antag
		tooltip_title = M.name
		var/icon/flat = getFlatIconDeluxe(sort_image_datas(get_content_image_datas(M.current)), override_dir = SOUTH)
		tooltip_content = "<img class='icon' src='data:image/png;base64,[iconsouth2base64(flat)]' style='position:relative; top:10px;'>"
		switch(associated_role.cultist_role)
			if (CULTIST_ROLE_NONE)
				tooltip_content += "Cultist Herald"
			if (CULTIST_ROLE_ACOLYTE)
				tooltip_content += "Cultist Acolyte"
				if (associated_role.mentor)
					var/datum/mind/I = associated_role.mentor.antag
					tooltip_content += "<br>Mentored by [I.name]."
			if (CULTIST_ROLE_HERALD)
				tooltip_content += "Cultist Herald"
			if (CULTIST_ROLE_MENTOR)
				tooltip_content += "Cultist Mentor"
		if (overflow)
			tooltip_content += "<br><b>overcap!</b>"//with some know-how, cultists may attempt to bypass the cap.
		tooltip_content += "<br>"
	else if (!locked)
		tooltip_title = "Cultist Slot"
		tooltip_content = "If you find a suitable candidate, use the Conversion rune to invite them."
	else
		tooltip_title = "Locked Slot"
		tooltip_content = "This slot will become available once the living population aboard the station has increased further."

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer
	name = "Artificer Slot"
	icon_state = "slot_artificer_empty"
	base_icon_state = "slot_artificer_empty"
	offset_x = 84

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/artificer/set_tooltip()
	if (associated_role)
		..()
		tooltip_content = "<br>As the first Artificer in the cult, they don't count toward the cultist cap."
	else
		tooltip_title = "Artificer Slot"
		tooltip_content = "The first Artificer in a cult won't count toward the cultist cap."

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith
	name = "Wraith Slot"
	icon_state = "slot_wraith_empty"
	base_icon_state = "slot_wraith_empty"
	offset_x = 101

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/wraith/set_tooltip()
	if (associated_role)
		..()
		tooltip_content = "<br>As the first Wraith in the cult, they don't count toward the cultist cap."
	else
		tooltip_title = "Wraith Slot"
		tooltip_content = "The first Wraith in a cult won't count toward the cultist cap."

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut
	name = "Juggernaut Slot"
	icon_state = "slot_juggernaut_empty"
	base_icon_state = "slot_juggernaut_empty"
	offset_x = 118

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_slot/juggernaut/set_tooltip()
	if (associated_role)
		..()
		tooltip_content = "<br>As the first Juggernaut in the cult, they don't count toward the cultist cap."
	else
		tooltip_title = "Juggernaut Slot"
		tooltip_content = "The first Juggernaut in a cult won't count toward the cultist cap."

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_soulblades
	name = "Soulblades"
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "blade"
	layer = MIND_UI_BUTTON
	offset_x = 140
	offset_y = -32
	tooltip_title = "Ritualized Soulblades"
	tooltip_content = ""
	tooltip_theme = "radial-cult"
	element_flags = MINDUI_FLAG_TOOLTIP

/obj/abstract/mind_ui_element/bloodcult_soulblades_count
	name = "Soulblades"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "blank"
	layer = MIND_UI_FRONT
	mouse_opacity = 0
	offset_x = 150
	offset_y = -10

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_cultist_cap
	name = "Cultist Cap"
	icon = 'icons/ui/bloodcult/16x32.dmi'
	icon_state = "cultist_cap"
	base_icon_state = "cultist_cap"
	layer = MIND_UI_BUTTON
	offset_x = 67
	offset_y = -32

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role
	name = "Choose a Role"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "role"
	offset_x = -147
	offset_y = -76
	layer = MIND_UI_BUTTON

	var/image/click_me

/obj/abstract/mind_ui_element/hoverable/bloodcult_role/New()
	..()
	click_me = image(icon, src, "click")
	click_me.layer = MIND_UI_FRONT
	animate(click_me, pixel_y = 16 , time = 7, loop = -1, easing = SINE_EASING)
	animate(pixel_y = 8, time = 7, loop = -1, easing = SINE_EASING)

/obj/abstract/mind_ui_element/hoverable/bloodcult_role/Click()
	flick("role-click",src)

	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			if (C.cultist_role != CULTIST_ROLE_NONE)
				if (C.mentor)
					to_chat(M,"<span class='notice'>You are currently in a mentorship under [C.mentor.antag.name].</span>")
				var/dat = ""
				if (C.acolytes.len > 0)
					for (var/datum/role/cultist/U in C.acolytes)
						dat += "[U.antag.name], "
					to_chat(M,"<span class='notice'>You are currently mentoring [dat]</span>")
				/* Don't think that cooldown was necessary, keeping this here in case I'm wrong in the future
				if ((world.time - C.time_role_changed_last) < 5 MINUTES)
					if ((world.time - C.time_role_changed_last) > 4 MINUTES)
						to_chat(M,"<span class='warning'>You must wait [round((5 MINUTES - (world.time - C.time_role_changed_last))/10) + 1] seconds before you can switch role.</span>")
					else
						to_chat(M,"<span class='warning'>You must wait around [round((5 MINUTES - (world.time - C.time_role_changed_last))/600) + 1] minutes before you can switch role.</span>")
					return
				else
				*/
				if (C.mentor)
					if(alert(M, "Switching roles will put an end to your mentorship by [C.mentor.antag.name]. Do you wish to proceed?", "Confirmation", "Yes", "No") == "No")
						return
				if (C.acolytes.len > 0)
					if(alert(M, "Switching roles will put an end to your mentoring of [dat] do you wish to proceed?", "Confirmation", "Yes", "No") == "No")
						return

	var/datum/mind_ui/bloodcult_role/role_popup = locate() in parent.subUIs
	if(role_popup)
		role_popup.Display()


/obj/abstract/mind_ui_element/hoverable/bloodcult_role/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		if (M.client)
			M.client.images -= click_me
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			overlays.len = 0
			switch(C.cultist_role)
				if (CULTIST_ROLE_NONE)
					if (M.client)
						M.client.images += click_me
				if (CULTIST_ROLE_ACOLYTE)
					overlays += "role_acolyte"
				if (CULTIST_ROLE_HERALD)
					overlays += "role_herald"
				if (CULTIST_ROLE_MENTOR)
					overlays += "role_mentor"


//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_your_role
	name = "your current role"
	icon = 'icons/ui/bloodcult/288x16.dmi'
	icon_state = "cultist_herald"
	offset_x = -128
	offset_y = -69
	layer = MIND_UI_FRONT

/obj/abstract/mind_ui_element/bloodcult_your_role/UpdateIcon()
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			overlays.len = 0
			switch(C.cultist_role)
				if (CULTIST_ROLE_NONE)
					icon_state = "cultist_herald"
					offset_y = -69
				if (CULTIST_ROLE_ACOLYTE)
					icon_state = "cultist_acolyte"
					if (C.mentor)
						offset_y = -55
						var/image/I = image('icons/ui/bloodcult/288x16.dmi',src,"mentored_by")
						I.pixel_x = 18
						I.pixel_y = -15
						overlays += I
						String2Maptext(C.mentor.antag.name, _pixel_x = 90, _pixel_y = -11)
					else
						offset_y = -59
				if (CULTIST_ROLE_HERALD)
					icon_state = "cultist_herald"
					offset_y = -69
				if (CULTIST_ROLE_MENTOR)
					icon_state = "cultist_mentor"
					if (C.acolytes.len > 0)
						offset_y = -55
						var/image/I = image('icons/ui/bloodcult/288x16.dmi',src,"mentoring")
						I.pixel_x = 18
						I.pixel_y = -15
						overlays += I
						var/ac = 0
						while (ac < C.acolytes.len)
							var/datum/role/cultist/U = C.acolytes[ac+1]
							String2Maptext(U.antag.name, _pixel_x = 80, _pixel_y = -11 + (-13 * ac))
							ac++
					else
						offset_y = -69
			UpdateUIScreenLoc()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_other
	name = "Newbie Tips"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "help"
	offset_x = 147
	offset_y = -76
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_other/Click()
	flick("help-click",src)
	parent.mind.DisplayUI("Cultist Help")


////////////////////////////////////////////////////////////////////
//																  //
//						BLOODCULT - RITUALS						  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_rituals
	uniqueID = "Cult Rituals"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/first,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/second,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/third,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/first,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/second,
		)
	display_with_parent = TRUE


/datum/mind_ui/bloodcult_rituals/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if ((cult.stage == BLOODCULT_STAGE_NORMAL) || (cult.stage == BLOODCULT_STAGE_MISSED) || (cult.stage == BLOODCULT_STAGE_DEFEATED))
			return TRUE
	return FALSE

/obj/abstract/mind_ui_element/ritual_holder
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "blank"
	mouse_opacity = 0

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual
	name = "Faction Ritual"
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "ritual_multi"
	offset_y = 32
	layer = MIND_UI_BUTTON

	element_flags = MINDUI_FLAG_TOOLTIP
	tooltip_title = "Ritual"
	tooltip_content = "Lorem Ipsum (you shouldn't be reading this!)"
	tooltip_theme = "radial-cult"

	var/datum/faction/bloodcult/cult
	var/datum/role/cultist/cultist

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/New(turf/loc, var/datum/mind_ui/P)
	if (!istype(P))
		qdel(src)
		return
	..()
	cult = find_active_faction_by_type(/datum/faction/bloodcult)
	var/mob/M = GetUser()
	cultist = iscultist(M)

	//This horseshit magically lets have screen objects use animate(). Maybe I should make it a default mindUI feature at some point. -Deity
	animate(src, pixel_y = 2 * PIXEL_MULTIPLIER , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = -2 * PIXEL_MULTIPLIER, time = 10, loop = -1, easing = SINE_EASING)
	var/obj/abstract/mind_ui_element/ritual_holder/my_holder = new(null, P)
	my_holder.offset_x = offset_x
	my_holder.offset_y = offset_y
	my_holder.layer = layer
	my_holder.UpdateUIScreenLoc()
	P.elements += my_holder
	my_holder.vis_contents += src

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/Appear()
	..()
	//we constantly remove ourself from client.screen, as the holder we spawned in New() takes care of displaying us in our animate()'d glory
	var/mob/M = GetUser()
	if (!M.client)
		return
	M.client.screen -= src

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/StartHovering(var/location,var/control,var/params)
	UpdateIcon()
	..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual
	name = "Faction Ritual"
	icon_state = "ritual_multi"
	offset_y = 32

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/first
	offset_x = -110

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/first/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cult.rituals[RITUAL_FACTION_1]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_multi"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_multi_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/second


/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/second/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cult.rituals[RITUAL_FACTION_2]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_multi"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_multi_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/third
	offset_x = 110

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/faction_ritual/third/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cult.rituals[RITUAL_FACTION_3]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_multi"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_multi_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual
	name = "Personal Ritual"
	icon_state = "ritual_solo"
	offset_y = 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/first
	offset_x = -55

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/first/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cultist.rituals[RITUAL_CULTIST_1]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_solo"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_solo_shape"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/second
	offset_x = 55

/obj/abstract/mind_ui_element/hoverable/bloodcult_ritual/personal_ritual/second/UpdateIcon()
	overlays.len = 0
	icon_state = "ritual_cleared"
	tooltip_title = ""
	tooltip_content = "..."
	if (cultist && (cult.stage != BLOODCULT_STAGE_DEFEATED))
		var/datum/bloodcult_ritual/BR = cultist.rituals[RITUAL_CULTIST_2]
		if (BR)
			tooltip_title = BR.name
			BR.update_desc()
			tooltip_content = BR.desc
			icon_state = "ritual_solo"
			overlays += "category_[BR.ritual_type]"
			overlays += "ritual_[BR.difficulty]"
	overlays += "ritual_solo_shape"
	base_icon_state = icon_state
	.

////////////////////////////////////////////////////////////////////
//																  //
//						BLOODCULT - RITUAL NARSIE				  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_ritual_narsie
	uniqueID = "Cult Last Ritual"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/hoverable/ritual_narsie,
		)
	display_with_parent = TRUE

/datum/mind_ui/bloodcult_ritual_narsie/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if ((cult.stage == BLOODCULT_STAGE_READY) || (cult.stage == BLOODCULT_STAGE_ECLIPSE) || (cult.stage == BLOODCULT_STAGE_NARSIE))
			return TRUE
	return FALSE

/obj/abstract/mind_ui_element/hoverable/ritual_narsie
	name = "Tear Reality"
	icon = 'icons/ui/bloodcult/40x40.dmi'
	icon_state = "ritual_narsie"
	offset_x = -4
	offset_y = 15
	layer = MIND_UI_BUTTON

	element_flags = MINDUI_FLAG_TOOLTIP
	tooltip_title = ""
	tooltip_content = "<span class='sinister'>Hell...</span><br><span class='sinister'>Join...</span><br><span class='sinister'>Self...</span><br>"
	tooltip_theme = "radial-cult"

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/New(turf/loc, var/datum/mind_ui/P)
	if (!istype(P))
		qdel(src)
		return
	..()

	//This horseshit magically lets have screen objects use animate(). Maybe I should make it a default mindUI feature at some point. -Deity
	animate(src, pixel_y = 1 * PIXEL_MULTIPLIER , time = 10, loop = -1, easing = SINE_EASING)
	animate(pixel_y = -1 * PIXEL_MULTIPLIER, time = 10, loop = -1, easing = SINE_EASING)
	var/obj/abstract/mind_ui_element/ritual_holder/my_holder = new(null, P)
	my_holder.offset_x = offset_x
	my_holder.offset_y = offset_y
	my_holder.layer = layer
	my_holder.UpdateUIScreenLoc()
	P.elements += my_holder
	my_holder.vis_contents += src

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/Appear()
	..()
	//we constantly remove ourself from client.screen, as the holder we spawned in New() takes care of displaying us in our animate()'d glory
	var/mob/M = GetUser()
	if (!M.client)
		return
	M.client.screen -= src

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/StartHovering(var/location,var/control,var/params)
	UpdateIcon()
	..()

/obj/abstract/mind_ui_element/hoverable/ritual_narsie/UpdateIcon()
	var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
	switch(cult.stage)
		if (BLOODCULT_STAGE_READY)
			if (!cult.tear_ritual)
				tooltip_content = "Hell...<br>Join...<br>Self...<br>"
			else if (!cult.tear_ritual.dance_manager)
				tooltip_content = "Eight are needed...<br>Whether followers, or prisoners...<br>"
			else
				tooltip_content = "Show me your moves...<br>"
		if (BLOODCULT_STAGE_ECLIPSE)
			tooltip_content = "Protect the Blood Stone...<br>This is your last crucible...<br>"
		if (BLOODCULT_STAGE_NARSIE)
			tooltip_content = "Rejoice...<br>Feast...<br>Harvest...<<br>"


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - ROLE							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_role
	uniqueID = "Cultist Role"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_role_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/acolyte,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/herald,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/mentor,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_role_move,
		)
	display_with_parent = TRUE//displays instantly when the cult panel is opened for the first time

	offset_layer = MIND_UI_GROUP_B

	var/selected_role = CULTIST_ROLE_NONE

/datum/mind_ui/bloodcult_role/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

/datum/mind_ui/bloodcult_role/Display()
	..()
	if (active)
		display_with_parent = FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_role_background
	name = "Choose a Role"
	icon = 'icons/ui/bloodcult/362x229.dmi'
	icon_state = "background"
	offset_x = -165
	offset_y = -93
	alpha = 240
	layer = MIND_UI_BACK

/obj/abstract/mind_ui_element/bloodcult_role_background/UpdateIcon()
	overlays.len = 0
	var/datum/mind_ui/bloodcult_role/P = parent
	switch(P.selected_role)
		if (CULTIST_ROLE_ACOLYTE)
			overlays += "acolyte"
		if (CULTIST_ROLE_HERALD)
			overlays += "herald"
		if (CULTIST_ROLE_MENTOR)
			overlays += "mentor"
		else
			overlays += "none"

/obj/abstract/mind_ui_element/bloodcult_role_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close
	name = "Close"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 181
	offset_y = 120
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_close/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select
	icon = 'icons/ui/bloodcult/40x40.dmi'
	icon_state = "button"
	layer = MIND_UI_BUTTON
	var/role_small = ""
	var/role = null

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/New()
	..()
	overlays += "overlay_[role_small]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/UpdateIcon()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		icon_state = "button-down"
	else
		icon_state = "button"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/StartHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		return
	else
		..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/StopHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == role)
		return
	else
		..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/Click()
	var/datum/mind_ui/bloodcult_role/P = parent
	P.selected_role = role
	P.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/acolyte
	name = "Acolyte"
	offset_x = -99
	offset_y = 80
	role_small = "acolyte"
	role = CULTIST_ROLE_ACOLYTE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/herald
	name = "Herald"
	offset_x = -3
	offset_y = 80
	role_small = "herald"
	role = CULTIST_ROLE_HERALD

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_select/mentor
	name = "Mentor"
	offset_x = 93
	offset_y = 80
	role_small = "mentor"
	role = CULTIST_ROLE_MENTOR

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm
	name = "Close"
	icon = 'icons/ui/bloodcult/104x40.dmi'
	icon_state = "confirm"
	offset_x = -36
	offset_y = -78
	layer = MIND_UI_BUTTON

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/UpdateIcon()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		icon_state = "confirm-grey"
	else
		icon_state = "confirm"
	base_icon_state = icon_state

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/StartHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	icon_state = "[base_icon_state]-hover"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/StopHovering()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	icon_state = "[base_icon_state]"

/obj/abstract/mind_ui_element/hoverable/bloodcult_role_confirm/Click()
	var/datum/mind_ui/bloodcult_role/P = parent
	if (P.selected_role == CULTIST_ROLE_NONE)
		return
	var/mob/M = GetUser()
	if (M)
		var/datum/role/cultist/C = iscultist(M)
		if (C)
			C.ChangeCultistRole(P.selected_role)
			parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_role_move
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON
	offset_x = -165
	offset_y = 120
	mouse_opacity = 1

	move_whole_ui = TRUE



////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - HELP							  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_help
	uniqueID = "Cultist Help"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_help_background,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous,
		/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next,
		/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_help_move,
		)
	offset_layer = MIND_UI_GROUP_C
	display_with_parent = FALSE

/datum/mind_ui/bloodcult_help/Valid()
	var/mob/M = mind.current
	if (!M)
		return FALSE
	if(iscultist(M))
		return TRUE
	return FALSE

//------------------------------------------------------------

/obj/abstract/mind_ui_element/bloodcult_help_background
	name = "How do I Cult?"
	icon = 'icons/ui/bloodcult/192x192.dmi'
	icon_state = "cult_help"
	offset_x = -80
	offset_y = -150
	layer = MIND_UI_BACK + 6
	var/current_page = 1
	var/max_page = 13

/obj/abstract/mind_ui_element/bloodcult_help_background/UpdateIcon()
	overlays.len = 0
	overlays += "cult_help[current_page]"

/obj/abstract/mind_ui_element/bloodcult_help_background/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close
	name = "Close"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "close"
	offset_x = 96
	offset_y = -38
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_close/Click()
	parent.Hide()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous
	name = "Previous Page"
	icon = 'icons/ui/bloodcult/24x24.dmi'
	icon_state = "button_prev"
	offset_x = -80
	offset_y = -150
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous/Appear()
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		if (help.current_page <= 1)
			invisibility = 101
		else
			..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_previous/Click()
	flick("button_prev-click",src)
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		help.current_page = max(help.current_page-1, 1)
		parent.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next
	name = "Next Page"
	icon = 'icons/ui/bloodcult/24x24.dmi'
	icon_state = "button_next"
	offset_x = 88
	offset_y = -150
	layer = MIND_UI_BUTTON + 6

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next/Appear()
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		if (help.current_page >= help.max_page)
			invisibility = 101
		else
			..()

/obj/abstract/mind_ui_element/hoverable/bloodcult_help_next/Click()
	flick("button_next-click",src)
	var/obj/abstract/mind_ui_element/bloodcult_help_background/help = locate() in parent.elements
	if(help)
		help.current_page = min(help.current_page+1, help.max_page)
		parent.Display()

//------------------------------------------------------------

/obj/abstract/mind_ui_element/hoverable/movable/bloodcult_help_move
	name = "Move Interface (Click and Drag)"
	icon = 'icons/ui/bloodcult/16x16.dmi'
	icon_state = "move"
	layer = MIND_UI_BUTTON + 6
	offset_x = -80
	offset_y = -38
	mouse_opacity = 1

	move_whole_ui = TRUE

//------------------------------------------------------------


////////////////////////////////////////////////////////////////////
//																  //
//					BLOODCULT - NAR-SIE HAS RISEN				  //
//																  //
////////////////////////////////////////////////////////////////////

/datum/mind_ui/bloodcult_narsie_has_risen
	uniqueID = "Nar-Sie Has Risen"
	element_types_to_spawn = list(
		/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_narsie,
		/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_has,
		/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_risen
		)
	offset_layer = MIND_UI_GROUP_D
	display_with_parent = FALSE

/datum/mind_ui/bloodcult_narsie_has_risen/Display()
	active = TRUE

	spawn()
		sleep(5)
		for (var/obj/abstract/mind_ui_element/bloodcult_particle_holder/element in elements)
			element.invisibility = 0
			element.add_particles(element.my_particle)
			sleep(10)

		for (var/obj/abstract/mind_ui_element/bloodcult_particle_holder/element in elements)
			element.adjust_particles(PVAR_SPAWNING, 0)

/obj/abstract/mind_ui_element/bloodcult_particle_holder
	mouse_opacity = 0
	icon = 'icons/ui/bloodcult/32x32.dmi'
	icon_state = "blank"
	layer = MIND_UI_FRONT
	var/my_particle

/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_narsie
	my_particle = PS_NARSIEHASRISEN1
	offset_y = 64
/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_has
	my_particle = PS_NARSIEHASRISEN2
/obj/abstract/mind_ui_element/bloodcult_particle_holder/bloodcult_risen
	my_particle = PS_NARSIEHASRISEN3
	offset_y = -64

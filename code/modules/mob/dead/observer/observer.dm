#define POLTERGEIST_COOLDOWN 300 // 30s

#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2
/mob/dead/observer
	name = "ghost"
	desc = "It's a g-g-g-g-ghooooost!" //jinkies!
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost1"
	stat = DEAD
	density = 0
	lockflags = 0 //Neither dense when locking or dense when locked to something
	canmove = 0
	blinded = 0
	anchored = 1	//  don't get pushed around
	flags = HEAR | TIMELESS
	invisibility = INVISIBILITY_OBSERVER
	universal_understand = 1
	universal_speak = 1
	//languages = ALL
	plane = GHOST_PLANE // Not to be confused with an actual ghost plane full of angry spirits.
	layer = GHOST_LAYER
	// For Aghosts dicking with telecoms equipment.
	var/obj/item/device/multitool/ghostMulti = null

	// Holomaps for ghosts
	var/obj/item/device/station_map/station_holomap = null

	var/can_reenter_corpse
	var/datum/hud/living/carbon/hud = null // hud
	var/bootime = 0
	var/next_poltergeist = 0
	var/started_as_observer //This variable is set to 1 when you enter the game as an observer.
							//If you died in the game and are a ghsot - this will remain as null.
							//Note that this is not a reliable way to determine if admins started as observers, since they change mobs a lot.
	var/has_enabled_antagHUD = 0
	var/selectedHUD = HUD_NONE // HUD_NONE, HUD_MEDICAL or HUD_SECURITY
	var/diagHUD = FALSE
	var/antagHUD = 0
	incorporeal_move = INCORPOREAL_GHOST
	var/movespeed = 0.75
	var/lastchairspin
	var/pathogenHUD = FALSE

/mob/dead/observer/New(var/mob/body=null, var/flags=1)
	change_sight(adding = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF)
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	// Our new boo spell.
	add_spell(new /spell/aoe_turf/boo, "grey_spell_ready")
	//add_spell(new /spell/ghost_show_map, "grey_spell_ready")

	can_reenter_corpse = flags & GHOST_CAN_REENTER
	started_as_observer = flags & GHOST_IS_OBSERVER

	stat = DEAD

	var/turf/T
	if(ismob(body))
		T = get_turf(body)				//Where is the body located?
		attack_log = body.attack_log	//preserve our attack logs by copying them to our ghost
		if(!istype(attack_log, /list))
			attack_log = list()
		// NEW SPOOKY BAY GHOST ICONS
		//////////////

		/*//What's the point of that? The icon and overlay renders without problem even with just the bottom part. I putting the old code in comment. -Deity Link
		if (ishuman(body))
			var/mob/living/carbon/human/H = body
			icon = H.stand_icon
			overlays = H.overlays_standing//causes issue with sepia cameras
		else
			icon = body.icon
			icon_state = body.icon_state
			overlays = body.overlays
		*/

		icon = body.icon
		icon_state = body.icon_state
		overlays = body.overlays

		// No icon?  Ghost icon time.
		if(isnull(icon) || isnull(icon_state))
			icon = initial(icon)
			icon_state = initial(icon_state)

		alpha = 127
		// END BAY SPOOKY GHOST SPRITES

		gender = body.gender
		if(body.mind && body.mind.name)
			name = body.mind.name
		else
			if(body.real_name)
				name = body.real_name
			else
				if(gender == MALE)
					name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
				else
					name = capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))

		mind = body.mind	//we don't transfer the mind but we keep a reference to it.

	if(!T)
		T = pick(latejoin)			//Safety in case we cannot find the body's position
	loc = T

	station_holomap = new(src)

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name

	start_poltergeist_cooldown() //FUCK OFF GHOSTS
	..()

/mob/dead/observer/Destroy()
	..()
	ghostMulti = null
	observers.Remove(src)

/mob/dead/observer/hasFullAccess()
	return isAdminGhost(src)

/mob/dead/observer/GetAccess()
	return isAdminGhost(src) ? get_all_accesses() : list()

/mob/dead/attackby(obj/item/W, mob/user)
	// Legacy Cult stuff
	if(istype(W,/obj/item/weapon/tome_legacy))
		cultify()//takes care of making ghosts visible
    // Big boy modern Cult 3.0 stuff
	if (iscultist(user))
		if(istype(W,/obj/item/weapon/tome))
			if(invisibility != 0 || icon_state != "ghost-narsie")
				cultify()
				user.visible_message(
					"<span class='warning'>[user] drags a ghost to our plane of reality!</span>",
					"<span class='warning'>You drag a ghost to our plane of reality!</span>"
				)
			return
		else if (istype(W,/obj/item/weapon/talisman))
			var/obj/item/weapon/talisman/T = W
			if (T.blood_text)
				to_chat(user, "<span class='warning'>This [W] has already been written on.</span>")
			var/data = use_available_blood(user, 1)
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
				to_chat(user, "<span class='warning'>You must provide the ghost some blood before it can write upon \the [W].</span>")
			else
				user.drop_item(W)
				W.forceMove(get_turf(src))
				var/message = sanitize(input(src,"\the [user] lends you a few drops of blood and \a [W], you may write down a message upon it. You have to remain above it.", "Blood Letter", "") as null|message, MAX_MESSAGE_LEN)
				if(!message)
					return
				if (W.loc != loc)
					to_chat(src, "<span class='warning'>You must remain above \the [W] to write down a message.</span>")
					return
				T.blood_text = message
				to_chat(src, "<span class='warning'>You write upon \the [W].</span>")
				visible_message("<span class='warning'>Words appear upon \the [W], written in blood.</span>")
				T.icon_state = "talisman-ghost"
				if (ishuman(user))
					var/mob/living/carbon/human/M = user
					if(!(M.dna.unique_enzymes in W.blood_DNA))
						W.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

		else if (istype(W,/obj/item/weapon/paper))
			var/obj/item/weapon/paper/P = W
			if (P.info)
				to_chat(user, "<span class='warning'>This [W] has already been written on.</span>")
			var/data = use_available_blood(user, 1)
			if (data[BLOODCOST_RESULT] == BLOODCOST_FAILURE)
				to_chat(user, "<span class='warning'>You must provide the ghost some blood before it can write upon \the [W].</span>")
			else
				user.drop_item(W)
				W.forceMove(get_turf(src))
				var/message = sanitize(input(src,"\the [user] lends you a few drops of blood and \a [W], you may write down a message upon it. You have to remain above it.", "Blood Letter", "") as null|message, MAX_MESSAGE_LEN)
				if(!message)
					return
				if (W.loc != loc)
					to_chat(src, "<span class='warning'>You must remain above \the [W] to write down a message.</span>")
					return
				P.info = message
				to_chat(src, "<span class='warning'>You write upon \the [W].</span>")
				visible_message("<span class='warning'>Words appear upon \the [W], written in blood.</span>")
				P.icon_state = "paper_words-blood"
				if (ishuman(user))
					var/mob/living/carbon/human/M = user
					if(!(M.dna.unique_enzymes in W.blood_DNA))
						W.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type

	if(istype(W,/obj/item/weapon/storage/bible) || isholyweapon(W))
		var/mob/dead/M = src
		if(src.invisibility == 0)
			M.invisibility = 60
			user.visible_message(
				"<span class='warning'>[user] banishes the ghost from our plane of reality!</span>",
				"<span class='warning'>You banish the ghost from our plane of reality!</span>"
			)

/mob/dead/observer/get_multitool(var/active_only=0)
	return ghostMulti


/mob/dead/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1
/*
Transfer_mind is there to check if mob is being deleted/not going to have a body.
Works together with spawning an observer, noted above.
*/

/mob/dead/observer/Life()
	if(timestopped)
		return 0 //under effects of time magick

	..()
	if(!loc)
		return
	if(!client)
		return 0

	regular_hud_updates()
	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(src))
			if( target.mind&&(target.mind.antag_roles.len > 0 || issilicon(target) || target.hud_list[SPECIALROLE_HUD]) )
				target_list += target
		if(target_list.len)
			assess_targets(target_list, src)
	if(selectedHUD == HUD_MEDICAL)
		process_medHUD(src)
	else if(selectedHUD == HUD_SECURITY)
		process_sec_hud(src, TRUE)
	if(diagHUD)
		process_diagnostic_hud(src)

	if(visible)
		if(invisibility == 0)
			visible.icon_state = "visible1"
		else
			visible.icon_state = "visible0"

// Direct copied from medical HUD glasses proc, used to determine what health bar to put over the targets head.
/mob/dead/proc/RoundHealth(var/health)
	switch(health)
		if(100 to INFINITY)
			return "health100"
		if(70 to 100)
			return "health80"
		if(50 to 70)
			return "health60"
		if(30 to 50)
			return "health40"
		if(18 to 30)
			return "health25"
		if(5 to 18)
			return "health10"
		if(1 to 5)
			return "health1"
		if(-99 to 0)
			return "health0"
		else
			return "health-100"
	return "0"


// Pretty much a direct copy of Medical HUD stuff, except will show ill if they are ill instead of also checking for known illnesses.

/mob/dead/proc/process_medHUD(var/mob/M)
	var/client/C = M.client
	var/image/holder
	for(var/mob/living/carbon/patient in oview(M))
		if(!check_HUD_visibility(patient, M))
			continue
		if(!C)
			return
		holder = patient.hud_list[HEALTH_HUD]
		if(holder)
			if(patient.isDead())
				holder.icon_state = "hudhealth-100"
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
			C.images += holder

		holder = patient.hud_list[STATUS_HUD]
		if(holder)
			if(patient.isDead())
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(has_recorded_disease(patient))
				holder.icon_state = "hudill_old"
			else
				var/dangerosity = has_recorded_virus2(patient)
				switch (dangerosity)
					if (1)
						holder.icon_state = "hudill"
					if (2)
						holder.icon_state = "hudill_safe"
					if (3)
						holder.icon_state = "hudill_danger"
					else
						holder.icon_state = "hudhealthy"
			/*
			else if(patient.has_brain_worms())
				var/mob/living/simple_animal/borer/B = patient.has_brain_worms()
				if(B.controlling)
					holder.icon_state = "hudbrainworm"
				else
					holder.icon_state = "hudhealthy"
			else
				holder.icon_state = "hudhealthy"
			*/

			C.images += holder

	for(var/mob/living/simple_animal/mouse/patient in oview(M))
		if(!check_HUD_visibility(patient, M))
			continue
		if(!C)
			continue
		holder = patient.hud_list[STATUS_HUD]
		if(holder)
			if(patient.isDead())
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(has_recorded_disease(patient))
				holder.icon_state = "hudill_old"
			else
				var/dangerosity = has_recorded_virus2(patient)
				switch (dangerosity)
					if (1)
						holder.icon_state = "hudill"
					if (2)
						holder.icon_state = "hudill_safe"
					if (3)
						holder.icon_state = "hudill_danger"
					else
						holder.icon_state = "hudhealthy"
			C.images += holder

/mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
	for(var/mob/living/target in target_list)
		if(target.mind)
			var/image/I
			U.client.images -= target.hud_list[SPECIALROLE_HUD]
			switch(target.mind.antag_roles.len)
				if(0)
					I = null
				if(1)
					for(var/R in target.mind.antag_roles)
						var/datum/role/role = target.mind.antag_roles[R]
						I = image('icons/role_HUD_icons.dmi', target, role.logo_state)
				else
					I = image('icons/role_HUD_icons.dmi', target, "multi-logo")
			if(I)
				I.pixel_x = 20 * PIXEL_MULTIPLIER
				I.pixel_y = 20 * PIXEL_MULTIPLIER
				I.plane = ANTAG_HUD_PLANE
				target.hud_list[SPECIALROLE_HUD] = I
				U.client.images += I
			else
				target.hud_list[SPECIALROLE_HUD] = null


		if(issilicon(target))//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len))||silicon_target.mind.special_role=="traitor")
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image('icons/mob/hud.dmi',silicon_target,"hudmalborg")
				else
					U.client.images += image('icons/mob/hud.dmi',silicon_target,"hudmalai")
	return 1

/mob/proc/ghostize(var/flags = GHOST_CAN_REENTER,var/deafmute = 0)
	if(key && !(copytext(key,1,2)=="@"))
		var/ghostype = /mob/dead/observer
		if (deafmute)
			ghostype = /mob/dead/observer/deafmute
		var/mob/dead/observer/ghost = new ghostype(src, flags)	//Transfer safety to observer spawning proc.
		ghost.attack_log += src.attack_log // Keep our attack logs.
		ghost.timeofdeath = src.timeofdeath //BS12 EDIT
		ghost.key = key
		if(ghost.client && !ghost.client.holder && !config.antag_hud_allowed)		// For new ghosts we remove the verb from even showing up if it's not allowed.
			ghost.verbs -= /mob/dead/observer/verb/toggle_antagHUD	// Poor guys, don't know what they are missing!
		return ghost

/*
This is the proc mobs get to turn into a ghost. Forked from ghostize due to compatibility issues.
*/
/mob/living/verb/ghost()
	set category = "OOC"
	set name = "Ghost"
	set desc = "Relinquish your life and enter the land of the dead."

	if(iscultist(src) && (ishuman(src)||isconstruct(src)) && veil_thickness > CULT_PROLOGUE)
		var/response = alert(src, "It doesn't have to end here, the veil is thin and the dark energies in you soul cling to this plane. You may forsake this body and materialize as a Shade.","Sacrifice Body","Shade","Ghost","Stay in body")
		switch (response)
			if ("Shade")
				dust()
				return
			if ("Stay in body")
				return

	if(src.health < 0 && stat != DEAD) //crit people
		succumb_proc(0)
		ghostize(1)
	else if(stat == DEAD)
		ghostize(1)
	else
		var/response = alert(src, "Are you -sure- you want to ghost?\n(You are alive. If you ghost, you will not be able to re-enter your current body!  You can't change your mind so choose wisely!)","Are you sure you want to ghost?","Ghost","Stay in body")
		if(response != "Ghost")
			return	//didn't want to ghost after-all
		resting = 1
		if(client && key)
			var/mob/dead/observer/ghost = ghostize(0)						//0 parameter is so we can never re-enter our body, "Charlie, you can never come baaaack~" :3
			ghost.timeofdeath = world.time // Because the living mob won't have a time of death and we want the respawn timer to work properly.
			if(ghost.client)
				ghost.client.time_died_as_mouse = world.time //We don't want people spawning infinite mice on the station
	return

// Check for last poltergeist activity.
/mob/dead/observer/proc/can_poltergeist(var/start_cooldown=1)
	if(isAdminGhost(src))
		return TRUE
	if(world.time >= next_poltergeist)
		if(start_cooldown)
			start_poltergeist_cooldown()
		return TRUE
	return FALSE

/mob/dead/observer/proc/start_poltergeist_cooldown()
	next_poltergeist=world.time + POLTERGEIST_COOLDOWN

/mob/dead/observer/proc/reset_poltergeist_cooldown()
	next_poltergeist=0

/* WHY
/mob/dead/observer/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	dir = direct
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.Crossed(src)

		var/area/A = get_area(src)
		if(A)
			A.Entered(src)

		return
	loc = get_turf(src) //Get out of closets and such as a ghost
	if((direct & NORTH) && y < world.maxy)
		y++
	else if((direct & SOUTH) && y > 1)
		y--
	if((direct & EAST) && x < world.maxx)
		x++
	else if((direct & WEST) && x > 1)
		x--

	for(var/obj/effect/step_trigger/S in get_turf(src))	//<-- this is dumb
		S.Crossed(src)

	var/area/A = get_area(src)
	if(A)
		A.Entered(src)
*/

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")
		if(ticker.mode)
			for(var/datum/faction/F in ticker.mode.factions)
				var/f_stat = F.get_statpanel_addition()
				if(f_stat)
					stat(null, f_stat)
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					var/acronym = emergency_shuttle.location == 1 ? "ETD" : "ETA"
					stat(null, "[acronym]-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

/mob/dead/observer/verb/reenter_corpse()
	set category = "Ghost"
	set name = "Re-enter Corpse"

	var/mob/M = get_top_transmogrification()
	if(!M.client)
		return
	if(!(mind && mind.current && can_reenter_corpse))
		to_chat(src, "<span class='warning'>You have no body.</span>")
		return
	if(mind.current.key && copytext(mind.current.key,1,2)!="@")	//makes sure we don't accidentally kick any clients
		to_chat(usr, "<span class='warning'>Another consciousness is in your body...It is resisting you.</span>")
		return
	if(mind.current.ajourn && istype(mind.current.ajourn,/obj/effect/rune_legacy) && mind.current.stat != DEAD) 	//check if the corpse is astral-journeying (it's client ghosted using a cultist rune).
		var/obj/effect/rune_legacy/R = mind.current.ajourn	//whilst corpse is alive, we can only reenter the body if it's on the rune
		var/datum/faction/cult/narsie/blood_cult = find_active_faction_by_member(mind.GetRole(LEGACY_CULTIST))
		var/list/cultwords
		if (istype(blood_cult))
			cultwords = blood_cult.cult_words
		else
			cultwords = null
		if(cultwords && !(R && R.word1 == cultwords["hell"] && R.word2 == cultwords["travel"] && R.word3 == cultwords["self"]))	//astral journeying rune
			to_chat(usr, "<span class='warning'>The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
			return
	completely_untransmogrify()
	mind.current.key = key
	mind.isScrying = 0
	return 1

/mob/dead/observer/verb/toggle_medHUD()
	set category = "Ghost"
	set name = "Toggle MedicHUD"
	set desc = "Toggles Medical HUD allowing you to see how everyone is doing"
	if(!client)
		return
	if(selectedHUD == HUD_MEDICAL)
		selectedHUD = HUD_NONE
		to_chat(src, "<span class='notice'><B>Medical HUD disabled.</B></span>")
	else
		selectedHUD = HUD_MEDICAL
		to_chat(src, "<span class='notice'><B>Medical HUD enabled.</B></span>")

/mob/dead/observer/verb/toggle_secHUD()
	set category = "Ghost"
	set name = "Toggle SecHUD"

	if(!client)
		return
	if(selectedHUD == HUD_SECURITY)
		selectedHUD = HUD_NONE
		to_chat(src, "<span class='notice'><B>Security HUD disabled.</b></span>")
	else
		selectedHUD = HUD_SECURITY
		to_chat(src, "<span class='notice'><B>Security HUD enabled.</b></span>")

/mob/dead/observer/verb/toggle_diagHUD()
	set category = "Ghost"
	set name = "Toggle diagnostic HUD"

	if(!client)
		return
	diagHUD = !diagHUD
	to_chat(src, "<span class='notice'><B>Diagnostic HUD [diagHUD ? "enabled" : "disabled"].")

/mob/dead/observer/verb/toggle_antagHUD()
	set category = "Ghost"
	set name = "Toggle AntagHUD"
	set desc = "Toggles AntagHUD allowing you to see who is the antagonist"
	if(!config.antag_hud_allowed && !client.holder)
		to_chat(src, "<span class='warning'>Admins have disabled this for this round.</span>")
		return
	if(!client)
		return
	var/mob/dead/observer/M = src
	if(jobban_isbanned(M, "AntagHUD"))
		to_chat(src, "<span class='danger'>You have been banned from using this feature.</span>")
		return
	if(config.antag_hud_restricted && !M.has_enabled_antagHUD &&!client.holder)
		var/response = alert(src, "If you turn this on, you will not be able to take any part in the round.","Are you sure you want to turn this feature on?","Yes","No")
		if(response == "No")
			return
		M.can_reenter_corpse = 0
	if(!M.has_enabled_antagHUD && !client.holder)
		M.has_enabled_antagHUD = 1
	if(M.antagHUD)
		M.antagHUD = 0
		to_chat(src, "<span class='notice'><B>AntagHUD Disabled</B></span>")
	else
		M.antagHUD = 1
		to_chat(src, "<span class='notice'><B>AntagHUD Enabled</B></span>")



/mob/dead/observer/verb/toggle_pathogenHUD()
	set category = "Ghost"
	set name = "Toggle PathogenHUD"
	set desc = "Toggles Pathogen HUD allowing you to see airborne pathogenic clouds, and infected items and splatters"
	if(!client)
		return
	if(pathogenHUD)
		pathogenHUD = FALSE
		to_chat(src, "<span class='notice'><B>Pathogen HUD disabled.</B></span>")
		science_goggles_wearers.Remove(src)
		if (client)
			for (var/obj/item/I in infected_items)
				client.images -= I.pathogen
			for (var/mob/living/L in infected_contact_mobs)
				client.images -= L.pathogen
			for (var/obj/effect/effect/pathogen_cloud/C in pathogen_clouds)
				client.images -= C.pathogen
			for (var/obj/effect/decal/cleanable/C in infected_cleanables)
				client.images -= C.pathogen
	else
		pathogenHUD = TRUE
		to_chat(src, "<span class='notice'><B>Pathogen HUD enabled.</B></span>")
		science_goggles_wearers.Add(src)
		if (client)
			for (var/obj/item/I in infected_items)
				if (I.pathogen)
					client.images |= I.pathogen
			for (var/mob/living/L in infected_contact_mobs)
				if (L.pathogen)
					client.images |= L.pathogen
			for (var/obj/effect/effect/pathogen_cloud/C in pathogen_clouds)
				if (C.pathogen)
					client.images |= C.pathogen
			for (var/obj/effect/decal/cleanable/C in infected_cleanables)
				if (C.pathogen)
					client.images |= C.pathogen


/mob/dead/observer/proc/dead_tele()
	set category = "Ghost"
	set name = "Teleport"
	set desc= "Teleport to a location"

	if(!istype(usr, /mob/dead/observer))
		to_chat(usr, "Not when you're not dead!")
		return
	usr.verbs -= /mob/dead/observer/proc/dead_tele
	spawn(30)
		usr.verbs += /mob/dead/observer/proc/dead_tele
	var/A
	A = input("Area to jump to", "BOOYEA", A) as null|anything in ghostteleportlocs
	var/area/thearea = ghostteleportlocs[A]
	if(!thearea)
		return

	if(thearea && thearea.anti_ethereal && !isAdminGhost(usr))
		to_chat(usr, "<span class='sinister'>As you are about to arrive, a strange dark form grabs you and sends you back where you came from.</span>")
		return

	var/list/L = list()
	var/holyblock = 0

	if((usr.invisibility == 0) || islegacycultist(usr))
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.holy)
				L+=T
			else
				holyblock = 1
	else
		for(var/turf/T in get_area_turfs(thearea.type))
			L+=T

	if(!L || !L.len)
		if(holyblock)
			to_chat(usr, "<span class='warning'>This area has been entirely made into sacred grounds, you cannot enter it while you are in this plane of existence!</span>")
		else
			to_chat(usr, "No area available.")

	usr.forceMove(pick(L))
	if(locked_to)
		manual_stop_follow(locked_to)

/mob/dead/observer/verb/follow()
	set category = "Ghost"
	set name = "Haunt" //Flavor name for following mobs
	set desc = "Haunt a mob, stalking them everywhere they go."

	var/list/mobs = getmobs()
	var/input = input("Please, select a mob!", "Haunt", null, null) as null|anything in mobs
	var/mob/target = mobs[input]
	manual_follow(target)

/mob/dead/observer/verb/end_follow()
	set category = "Ghost"
	set name = "Stop Haunting"
	set desc = "Stop haunting a mob. They weren't worth your eternal time anyways."

	if(locked_to)
		manual_stop_follow(locked_to)

//This is the ghost's follow verb with an argument
/mob/dead/observer/proc/manual_follow(var/atom/movable/target)
	if(target)
		var/turf/targetloc = get_turf(target)
		var/area/targetarea = get_area(target)
		if(targetarea && targetarea.anti_ethereal && !isAdminGhost(usr))
			to_chat(usr, "<span class='sinister'>You can sense a sinister force surrounding that mob, your spooky body itself refuses to follow it.</span>")
			return
		if(targetloc && targetloc.holy && (!invisibility || islegacycultist(src)))
			to_chat(usr, "<span class='warning'>You cannot follow a mob standing on holy grounds!</span>")
			return
		if(target != src)
			if(locked_to)
				if(locked_to == target) //Trying to follow same target, don't do anything
					return
				manual_stop_follow(locked_to) //So you can switch follow target on a whim
			target.lock_atom(src, /datum/locking_category/observer)
			to_chat(src, "<span class='sinister'>You are now haunting \the [target]</span>")

/mob/dead/observer/proc/manual_stop_follow(var/atom/movable/target)

	if(!target)
		to_chat(src, "<span class='warning'>You are not currently haunting anyone.</span>")
		return
	else
		to_chat(src, "<span class='sinister'>You are no longer haunting \the [target].</span>")
		unlock_from()

/mob/dead/observer/verb/jumptomob() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost"
	set name = "Jump to Mob"
	set desc = "Teleport to a mob"

	if(istype(usr, /mob/dead/observer)) //Make sure they're an observer!


		var/list/dest = list() //List of possible destinations (mobs)
		var/target = null	   //Chosen target.

		dest += getmobs() //Fill list, prompt user with list
		target = input("Please, select a player!", "Jump to Mob", null, null) as null|anything in dest

		if (!target)//Make sure we actually have a target
			return
		else
			var/turf/targetloc = get_turf(target)
			var/area/targetarea = get_area(target)
			if(targetarea && targetarea.anti_ethereal && !isAdminGhost(usr))
				to_chat(usr, "<span class='sinister'>You can sense a sinister force surrounding that mob, your spooky body itself refuses to jump to it.</span>")
				return
			if(targetloc && targetloc.holy && ((src.invisibility == 0) || islegacycultist(src)))
				to_chat(usr, "<span class='warning'>The mob that you are trying to follow is standing on holy grounds, you cannot reach him!</span>")
				return
			var/mob/M = dest[target] //Destination mob
			var/mob/A = src			 //Source mob
			var/turf/T = get_turf(M) //Turf of the destination mob

			if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
				A.forceMove(T)
				if(locked_to)
					manual_stop_follow(locked_to)
			else
				to_chat(A, "This mob is not located in the game world.")

/* Now a spell.  See spells.dm
/mob/dead/observer/verb/boo()
	set category = "Ghost"
	set name = "Boo!"
	set desc= "Scare your crew members because of boredom!"

	if(bootime > world.time)
		return
	bootime = world.time + 600
	var/obj/machinery/light/L = locate(/obj/machinery/light) in view(1, src)
	if(L)
		L.flicker()
	//Maybe in the future we can add more <i>spooky</i> code here!
	return
*/

/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/verb/analyze_air()
	set name = "Analyze Air"
	set category = "Ghost"

	if(!istype(usr, /mob/dead/observer))
		return

	// Shamelessly copied from the Gas Analyzers
	if (!( istype(usr.loc, /turf) ))
		return

	var/datum/gas_mixture/environment = usr.loc.return_air()

	var/pressure = environment.return_pressure()
	var/total_moles = environment.total_moles()
	var/tiles = environment.return_volume() / CELL_VOLUME

	to_chat(src, "<span class='notice'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(src, "<span class='notice'>Pressure: [round(pressure, 0.01)] kPa</span>")
	else
		to_chat(src, "<span class='warning'>Pressure: [round(pressure, 0.01)] kPa</span>")
	if(total_moles)
		for(var/g in environment.gas)
			var/datum/gas/gas = XGM.gases[g]
			var/is_safe = gas.is_human_safe(environment[g], environment)
			to_chat(src, "<span class='[is_safe ? "notice" : "warning"]'>[XGM.name[g]]: [round(environment[g] / total_moles * 100)]% ([round(environment.molar_density(g) * CELL_VOLUME, 0.01)] moles)</span>")

		to_chat(src, "<span class='notice'>Temperature: [round(environment.temperature - T0C, 0.01)]&deg;C</span>")
		to_chat(src, "<span class='notice'>Heat Capacity: [round(environment.heat_capacity() / tiles, 0.01)]</span>")


/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	if (see_invisible == SEE_INVISIBLE_OBSERVER_NOLIGHTING)
		see_invisible = SEE_INVISIBLE_OBSERVER
	else
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING

/mob/dead/observer/verb/become_mouse()
	set name = "Become mouse"
	set category = "Ghost"

	if(!config.respawn_as_mouse)
		to_chat(src, "<span class='warning'>Respawning as mouse is disabled.</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	var/response = alert(src, "Are you -sure- you want to become a mouse?","Are you sure you want to squeek?","Squeek!","Nope!")
	if(response != "Squeek!")
		return  //Hit the wrong key...again.


	//find a viable mouse candidate
	var/mob/living/simple_animal/mouse/common/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in atmos_machines)
		if(!v.welded && v.z == src.z && v.canSpawnMice==1) // No more spawning in atmos.  Assuming the mappers did their jobs, anyway.
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse/common(vent_found.loc)
	else
		to_chat(src, "<span class='warning'>Unable to find any unwelded vents to spawn mice at.</span>")

	if(host)
		if(config.uneducated_mice)
			host.universal_understand = 0
		host.ckey = src.ckey
		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")

/mob/dead/observer/verb/view_manfiest()
	set name = "View Crew Manifest"
	set category = "Ghost"

	var/dat
	dat += "<h4>Crew Manifest</h4>"
	dat += data_core.get_manifest()

	src << browse(dat, "window=manifest;size=370x420;can_close=1")

//Used for drawing on walls with blood puddles as a spooky ghost.
/mob/dead/verb/bloody_doodle()
	set category = "Ghost"
	set name = "Write in blood"
	set desc = "If the round is sufficiently spooky, write a short message in blood on the floor or a wall. Remember, no IC in OOC or OOC in IC."

	if(!(config.cult_ghostwriter))
		to_chat(src, "<span class='warning'>That verb is not currently permitted.</span>")
		return

	if (!src.stat)
		return

	if (usr != src)
		return 0 //something is terribly wrong

	var/ghosts_can_write
	var/datum/faction/cult/narsie/C = find_active_faction_by_type(/datum/faction/cult/narsie)
	if(C && C.members.len > config.cult_ghostwriter_req_cultists)
		ghosts_can_write = 1

	if (veil_thickness >= CULT_ACT_III)
		ghosts_can_write = 1

	if(!ghosts_can_write)
		to_chat(src, "<span class='warning'>The veil is not thin enough for you to do that.</span>")
		return

	var/list/choices = list()
	for(var/obj/effect/decal/cleanable/blood/B in view(1,src))
		if(B.amount > 0)
			choices += B

	if(!choices.len)
		to_chat(src, "<span class = 'warning'>There is no blood to use nearby.</span>")
		return

	var/obj/effect/decal/cleanable/blood/choice = input(src,"What blood would you like to use?") in null|choices

	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	var/turf/simulated/T = src.loc
	if (direction != "Here")
		T = get_step(T,text2dir(direction))

	if (!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	if(!choice || choice.amount == 0 || !(src.Adjacent(choice)))
		return

	var/doodle_color = (choice.basecolor) ? choice.basecolor : DEFAULT_BLOOD

	var/num_doodles = 0
	for (var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if (num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = 50

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")

	if (message)

		if (length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")

		var/obj/effect/decal/cleanable/blood/writing/W = getFromPool(/obj/effect/decal/cleanable/blood/writing,T)
		W.New(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		W.visible_message("<span class='warning'>Invisible fingers crudely paint something in blood on [T]...</span>")


// For filming shit.
/mob/dead/observer/verb/hide_sprite()
	set name = "Hide Sprite"
	set category = "Ghost"


	// Toggle alpha
	if(alpha == 127)
		alpha = 0
		mouse_opacity = 0
		to_chat(src, "<span class='warning'>Sprite hidden.</span>")
	else
		alpha = 127
		mouse_opacity = 1
		to_chat(src, "<span class='info'>Sprite shown.</span>")

/mob/dead/observer/verb/hide_ghosts()
	set name = "Hide Ghosts"
	set category = "Ghost"

	if(!client.ghost_planemaster)
		to_chat(src, "<span class='warning'>You have no ghost planemaster. Make a bug report!</span>")
		return

	if(client.ghost_planemaster.alpha == 255)
		client.ghost_planemaster.alpha = 0
		client.ghost_planemaster.mouse_opacity = 0
		to_chat(src, "<span class='info'>Ghosts hidden.</span>")
	else
		client.ghost_planemaster.alpha = 255
		client.ghost_planemaster.mouse_opacity = 1
		to_chat(src, "<span class='info'>Ghosts shown.</span>")

/mob/dead/observer/verb/toggle_station_map()
	set name = "Toggle Station Holomap"
	set desc = "Toggle station holomap on your screen"
	set category = "Ghost"

	src.station_holomap.toggleHolomap(src, FALSE) // We don't need client.eye.

/mob/dead/observer/verb/become_mommi()
	set name = "Become MoMMI"
	set category = "Ghost"

	if(!config.respawn_as_mommi)
		to_chat(src, "<span class='warning'>Respawning as MoMMI is disabled..</span>")
		return

	var/timedifference = world.time - client.time_died_as_mouse
	if(client.time_died_as_mouse && timedifference <= mouse_respawn_time * 600)
		var/timedifference_text
		timedifference_text = time2text(mouse_respawn_time * 600 - timedifference,"mm:ss")
		to_chat(src, "<span class='warning'>You may only spawn again as a mouse or MoMMI more than [mouse_respawn_time] minutes after your death. You have [timedifference_text] left.</span>")
		return

	//find a viable mouse candidate
	var/list/found_spawners = list()
	for(var/obj/machinery/mommi_spawner/s in machines)
		if(s.canSpawn())
			found_spawners.Add(s)
	if(found_spawners.len)
		var/options[found_spawners.len]
		for(var/t=1,t<=found_spawners.len,t++)
			var/obj/machinery/mommi_spawner/S = found_spawners[t]
			var/dat = text("[] on z-level = []",get_area(S),S.z)
			options[t] = dat
		var/selection = input(src,"Select a MoMMI spawn location", "Become MoMMI",null) as null|anything in options
		if(selection)
			for(var/i = 1, i<=options.len, i++)
				if(options[i] == selection)
					var/obj/machinery/mommi_spawner/final = found_spawners[i]
					final.attack_ghost(src)
					break
	else
		to_chat(src, "<span class='warning'>Unable to find any MoMMI Spawners ready to build a MoMMI in the universe. Please try again.</span>")

	//if(host)
	//	host.ckey = src.ckey
//		to_chat(host, "<span class='info'>You are now a mouse. Try to avoid interaction with players, and do not give hints away that you are more than a simple rodent.</span>")

/mob/dead/observer/verb/find_arena()
	set category = "Ghost"
	set name = "Search For Arenas"
	set desc = "Try to find an Arena to polish your robust bomb placement skills.."

	if(!arenas.len)
		to_chat(usr, "There are no arenas in the world! Ask the admins to spawn one.")
		return

	var/datum/bomberman_arena/arena_target = input("Which arena do you wish to reach?", "Arena Search Panel") in arenas
	to_chat(usr, "Reached [arena_target]")

	usr.forceMove(arena_target.center)
	to_chat(usr, "Remember to enable darkness to be able to see the spawns. Click on a green spawn between rounds to register on it.")

/mob/dead/observer/Topic(href, href_list)
	if (href_list["reentercorpse"])
		var/mob/dead/observer/A
		if(ismob(usr))
			var/mob/M = usr
			A = M.get_bottom_transmogrification()
			if(istype(A))
				A.reenter_corpse()

	//BEGIN TELEPORT HREF CODE
	if(usr != src)
		return
	..()

	if(href_list["follow"])
		var/target = locate(href_list["follow"])
		if(target)
			if(isAI(target))
				var/mob/living/silicon/ai/M = target
				target = M.eyeobj
			manual_follow(target)

	if (href_list["jump"])
		var/mob/target = locate(href_list["jump"])
		var/mob/A = usr;
		to_chat(A, "Teleporting to [target]...")
		//var/mob/living/silicon/ai/A = locate(href_list["track2"]) in mob_list
		if(target && target != usr)
			var/turf/pos = get_turf(A)
			var/turf/T=get_turf(target)
			if(T != pos)
				if(!T)
					to_chat(A, "<span class='warning'>Target not in a turf.</span>")
					return
				if(locked_to)
					manual_stop_follow(locked_to)
				forceMove(T)

	if(href_list["jumptoarenacood"])
		var/datum/bomberman_arena/targetarena = locate(href_list["targetarena"])
		if(targetarena)
			if(locked_to)
				manual_stop_follow(locked_to)
			usr.forceMove(targetarena.center)
			to_chat(usr, "Remember to enable darkness to be able to see the spawns. Click on a green spawn between rounds to register on it.")
		else
			to_chat(usr, "That arena doesn't seem to exist anymore.")

	..()

//END TELEPORT HREF CODE

/mob/dead/observer/html_mob_check()
	return 1

/mob/dead/observer/dexterity_check()
	return 1

//this is a mob verb instead of atom for performance reasons
//see /mob/verb/examinate() in mob.dm for more info
//overriden here and in /mob/living for different point span classes and sanity checks
/mob/dead/observer/pointed(atom/A as mob|obj|turf in view())
	if(!..())
		return 0
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A]</span>.")
	return 1

/mob/dead/observer/Login()
	..()
	observers += src

/mob/dead/observer/Logout()
	observers -= src
	..()

/mob/dead/observer/verb/modify_movespeed()
	set name = "Change Speed"
	set category = "Ghost"
	var/speed = input(usr,"What speed would you like to move at?","Observer Move Speed") in list("100%","125%","150%","175%","200%","FUCKING HYPERSPEED")
	if(speed == "FUCKING HYPERSPEED") //April fools
		client.move_delayer.min_delay = 0
		movespeed = 0
		return
	speed = text2num(copytext(speed,1,4))/100
	movespeed = 1/speed

/datum/locking_category/observer

/mob/dead/observer/deafmute/say(var/message)	//A ghost without access to ghostchat. An IC ghost, if you will.
	to_chat(src, "<span class='notice'>You have no lungs with which to speak.</span>")

/mob/dead/observer/deafmute/Hear(var/datum/speech/speech, var/rendered_speech="")
	if (isnull(client) || !speech.speaker)
		return

	var/source = speech.speaker.GetSource()
	var/source_turf = get_turf(source)

	say_testing(src, "/mob/dead/observer/Hear(): source=[source], frequency=[speech.frequency], source_turf=[formatJumpTo(source_turf)]")

	if (get_dist(source_turf, src) <= world.view) // If this isn't true, we can't be in view, so no need for costlier proc.
		if (source_turf in view(src))
			rendered_speech = "<B>[rendered_speech]</B>"
			to_chat(src, "<a href='?src=\ref[src];follow=\ref[source]'>(Follow)</a> [rendered_speech]")

/mob/dead/observer/hasHUD(var/hud_kind)
	switch(hud_kind)
		if(HUD_MEDICAL)
			return selectedHUD == HUD_MEDICAL
		if(HUD_SECURITY)
			return selectedHUD == HUD_SECURITY
	return

/mob/dead/observer/proc/can_reenter_corpse()
	var/mob/M = get_top_transmogrification()
	return (M && M.client && can_reenter_corpse)

/mob/dead/observer/verb/pai_signup()
	set name = "Sign up as pAI"
	set category = "Ghost"
	set desc = "Create and submit your pAI personality"

	if(!paiController.check_recruit(src))
		to_chat(src, "<span class='warning'>Not available. You may have been pAI-banned.</span>")
		return

	paiController.recruitWindow(src)

// -- Require at least 2 players to start.

// Global variable on whether an arena is being created or not
var/creating_arena = FALSE

/mob/dead/observer/verb/request_bomberman()
	set name = "Request a bomberman arena"
	set category = "Ghost"
	set desc = "Create a bomberman arena for other observers and dead players."

	if (ticker && ticker.current_state != GAME_STATE_PLAYING)
		to_chat(src, "<span class ='notice'>You can't use this verb before the game has started.</span>")
		return

	if (arenas.len)
		to_chat(src, "<span class ='notice'>There are already bomberman arenas! Use the Find Arenas verb to jump to them.</span>")
		return

	to_chat(src, "<span class='notice'>Pooling other ghosts for a bomberman arena...</span>")
	if (!creating_arena)
		creating_arena = TRUE
		new /datum/bomberman_arena(locate(250, 250, 2), pick("15x13 (2 players)","15x15 (4 players)","39x23 (10 players)"), src)
		if (!arenas.len) // Someone hit the cancel option
			creating_arena = FALSE
		return
	to_chat(src, "<span class='notice'>There were unfortunatly no available arenas.</span>")

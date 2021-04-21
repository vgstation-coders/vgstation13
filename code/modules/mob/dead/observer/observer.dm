#define GHOST_CAN_REENTER 1
#define GHOST_IS_OBSERVER 2

// Global variable on whether an arena is being created or not
var/creating_arena = FALSE

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
	var/conversionHUD = 0
	incorporeal_move = INCORPOREAL_GHOST
	var/movespeed = 0.75
	var/lastchairspin
	var/pathogenHUD = FALSE
	var/manual_poltergeist_cooldown //var-edit this to manually modify a ghost's poltergeist cooldown, set it to null to reset to global

/mob/dead/observer/New(var/mob/body=null, var/flags=1)
	change_sight(adding = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF)
	see_invisible = SEE_INVISIBLE_OBSERVER
	see_in_dark = 100
	verbs += /mob/dead/observer/proc/dead_tele

	// Our new boo spell.
	add_spell(new /spell/aoe_turf/boo, "grey_spell_ready")
	add_spell(new /spell/targeted/ghost/toggle_medHUD)
	add_spell(new /spell/targeted/ghost/toggle_darkness)
	add_spell(new /spell/targeted/ghost/become_mouse)
	add_spell(new /spell/targeted/ghost/hide_sprite)
	add_spell(new /spell/targeted/ghost/haunt)
	add_spell(new /spell/targeted/ghost/reenter_corpse)
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

	if(!name)							//To prevent nameless ghosts
		name = capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	real_name = name

	start_poltergeist_cooldown() //FUCK OFF GHOSTS
	..()

/mob/dead/observer/Destroy()
	..()
	qdel(station_holomap)
	station_holomap = null
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

	//cleaning up antagHUD and conversionHUD icons
	if(client)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "convertible") || findtext(hud.icon_state, "-logo"))
				client.images -= hud

	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(client.view+DATAHUD_RANGE_OVERHEAD, src))
			if( target.mind&&(target.mind.antag_roles.len > 0 || issilicon(target) || target.hud_list[SPECIALROLE_HUD]) )
				target_list += target
		if(target_list.len)
			assess_antagHUD(target_list, src)

	if(conversionHUD)
		var/list/target_list = list()
		for(var/mob/living/carbon/target in oview(client.view+DATAHUD_RANGE_OVERHEAD, src))
			if(target.mind && target.hud_list[CONVERSION_HUD])
				target_list += target
		if(target_list.len)
			assess_conversionHUD(target_list, src)

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

// Pretty much a direct copy of Medical HUD stuff, except will show ill if they are ill instead of also checking for known illnesses.
/mob/dead/proc/process_medHUD(var/mob/M)
	var/client/C = M.client
	var/image/holder
	for(var/mob/living/carbon/patient in oview(client.view+DATAHUD_RANGE_OVERHEAD, M))
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

	for(var/mob/living/simple_animal/mouse/patient in oview(client.view+DATAHUD_RANGE_OVERHEAD, M))
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

/mob/dead/proc/assess_antagHUD(list/target_list, mob/dead/observer/U)
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

/mob/dead/proc/assess_conversionHUD(list/target_list, mob/dead/observer/U)
	for(var/mob/living/carbon/target in target_list)
		if(target.mind)
			U.client.images -= target.hud_list[CONVERSION_HUD]
			target.update_convertibility()
			U.client.images += target.hud_list[CONVERSION_HUD]

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

	var/timetocheck = timeofdeath
	if (isbrain(src))
		var/mob/living/carbon/brain/brainmob = src
		timetocheck = brainmob.timeofhostdeath

	if(iscultist(src) && (ishuman(src)||isconstruct(src)||isbrain(src)||istype(src,/mob/living/carbon/complex/gondola)) && veil_thickness > CULT_PROLOGUE && (timetocheck == 0 || timetocheck >= world.time - DEATH_SHADEOUT_TIMER))
		var/response = alert(src, "It doesn't have to end here, the veil is thin and the dark energies in you soul cling to this plane. You may forsake this body and materialize as a Shade.","Sacrifice Body","Shade","Ghost","Stay in body")
		switch (response)
			if ("Shade")
				dust(TRUE)
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
	if(isnull(manual_poltergeist_cooldown))
		next_poltergeist=world.time + global_poltergeist_cooldown
	else
		next_poltergeist=world.time + manual_poltergeist_cooldown

/mob/dead/observer/proc/reset_poltergeist_cooldown()
	next_poltergeist=0

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		timeStatEntry()
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

/mob/dead/observer/memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

/mob/dead/observer/add_memory()
	set hidden = 1
	to_chat(src, "<span class='warning'>You are dead! You have no mind to store memory!</span>")

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

/mob/dead/observer/Logout()
	observers.Remove(src)
	..()
	spawn(0)
		if(src && !key && !transmogged_to)	//we've transferred to another mob. This ghost should be deleted.
			qdel(src)

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

/mob/dead/observer/AltClick(mob/user)
	if(isAdminGhost(user))
		var/choice_one = alert(user, "Do you wish to spawn a human?", "IC Spawning", "Yes", "No")
		if(!choice_one)
			return ..()
		if(choice_one == "Yes")
			var/choose_outfit = select_loadout()
			if(choose_outfit)
				var/datum/outfit/concrete_outfit = new choose_outfit
				var/mob/living/carbon/human/sHuman = new /mob/living/carbon/human(get_turf(src))
				sHuman.name = name
				sHuman.real_name = real_name
				concrete_outfit.equip(sHuman, TRUE)
				client?.prefs.copy_to(sHuman)
				sHuman.dna.UpdateSE()
				sHuman.dna.UpdateUI()
				sHuman.ckey = ckey
				qdel(src)
			return
	return ..()

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
	plane = LIGHTING_PLANE
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
	var/medHUD = 0
	var/antagHUD = 0
	incorporeal_move = INCORPOREAL_GHOST
	var/movespeed = 0.75
	var/lastchairspin

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
	if(istype(W,/obj/item/weapon/tome))
		var/mob/dead/M = src
		if(src.invisibility != 0)
			M.invisibility = 0
			user.visible_message(
				"<span class='warning'>[user] drags ghost, [M], to our plane of reality!</span>",
				"<span class='warning'>You drag [M] to our plane of reality!</span>"
			)
		else
			user.visible_message (
				"<span class='warning'>[user] just tried to smash his book into that ghost!  It's not very effective</span>",
				"<span class='warning'>You get the feeling that the ghost can't become any more visible.</span>"
			)

	if(istype(W,/obj/item/weapon/storage/bible) || istype(W,/obj/item/weapon/nullrod))
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


	if(client.images.len)
		for(var/image/hud in client.images)
			if(findtext(hud.icon_state, "hud", 1, 4))
				client.images.Remove(hud)
	if(antagHUD)
		var/list/target_list = list()
		for(var/mob/living/target in oview(src))
			if( target.mind&&(target.mind.special_role||issilicon(target)) )
				target_list += target
		if(target_list.len)
			assess_targets(target_list, src)
	if(medHUD)
		process_medHUD(src)

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
	for(var/mob/living/carbon/human/patient in oview(M))
		var/foundVirus = 0
		if(patient && patient.virus2 && patient.virus2.len)
			foundVirus = 1
		else if (patient && patient.viruses && patient.viruses.len)
			foundVirus = 1
		if(!C)
			return
		holder = patient.hud_list[HEALTH_HUD]
		if(holder)
			if(patient.stat == 2)
				holder.icon_state = "hudhealth-100"
			else
				holder.icon_state = "hud[RoundHealth(patient.health)]"
			C.images += holder

		holder = patient.hud_list[STATUS_HUD]
		if(holder)
			if(patient.stat == 2)
				holder.icon_state = "huddead"
			else if(patient.status_flags & XENO_HOST)
				holder.icon_state = "hudxeno"
			else if(foundVirus)
				holder.icon_state = "hudill"
			else if(patient.has_brain_worms())
				var/mob/living/simple_animal/borer/B = patient.has_brain_worms()
				if(B.controlling)
					holder.icon_state = "hudbrainworm"
				else
					holder.icon_state = "hudhealthy"
			else
				holder.icon_state = "hudhealthy"

			C.images += holder

/mob/dead/proc/assess_targets(list/target_list, mob/dead/observer/U)
	var/icon/tempHud = 'icons/mob/hud.dmi'
	for(var/mob/living/target in target_list)
		if(iscarbon(target))
			switch(target.mind.special_role)
				if("traitor","Syndicate")
					U.client.images += image(tempHud,target,"hudsyndicate")
				if("Revolutionary")
					U.client.images += image(tempHud,target,"hudrevolutionary")
				if("Head Revolutionary")
					U.client.images += image(tempHud,target,"hudheadrevolutionary")
				if("Cultist")
					U.client.images += image(tempHud,target,"hudcultist")
				if("Changeling")
					U.client.images += image(tempHud,target,"hudchangeling")
				if("Wizard","Fake Wizard")
					U.client.images += image(tempHud,target,"hudwizard")
				if("Hunter","Sentinel","Drone","Queen")
					U.client.images += image(tempHud,target,"hudalien")
				if("Death Commando")
					U.client.images += image(tempHud,target,"huddeathsquad")
				if("Vampire")
					U.client.images += image(tempHud,target,"vampire")
				if("VampThrall")
					U.client.images += image(tempHud,target,"vampthrall")
				else//If we don't know what role they have but they have one.
					U.client.images += image(tempHud,target,"hudunknown1")
		else if(issilicon(target))//If the silicon mob has no law datum, no inherent laws, or a law zero, add them to the hud.
			var/mob/living/silicon/silicon_target = target
			if(!silicon_target.laws||(silicon_target.laws&&(silicon_target.laws.zeroth||!silicon_target.laws.inherent.len))||silicon_target.mind.special_role=="traitor")
				if(isrobot(silicon_target))//Different icons for robutts and AI.
					U.client.images += image(tempHud,silicon_target,"hudmalborg")
				else
					U.client.images += image(tempHud,silicon_target,"hudmalai")
	return 1

/mob/proc/ghostize(var/flags = GHOST_CAN_REENTER)
	if(key && !(copytext(key,1,2)=="@"))
		var/mob/dead/observer/ghost = new(src, flags)	//Transfer safety to observer spawning proc.
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

	if(src.health < 0 && stat != DEAD) //crit people
		succumb()
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
/mob/dead/observer/Move(NewLoc, direct)
	dir = direct
	if(NewLoc)
		loc = NewLoc
		for(var/obj/effect/step_trigger/S in NewLoc)
			S.Crossed(src)

		var/area/A = get_area_master(src)
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

	var/area/A = get_area_master(src)
	if(A)
		A.Entered(src)
*/

/mob/dead/observer/can_use_hands()	return 0
/mob/dead/observer/is_active()		return 0

/mob/dead/observer/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Station Time: [worldtime2text()]")
		if(ticker)
			if(ticker.mode)
//				to_chat(world, "DEBUG: ticker not null")
				if(ticker.mode.name == "AI malfunction")
//					to_chat(world, "DEBUG: malf mode ticker test")
					if(ticker.mode:malf_mode_declared)
						stat(null, "Time left: [max(ticker.mode:AI_win_timeleft/(ticker.mode:apcs/3), 0)]")
		if(emergency_shuttle)
			if(emergency_shuttle.online && emergency_shuttle.location < 2)
				var/timeleft = emergency_shuttle.timeleft()
				if (timeleft)
					stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")

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
	if(mind.current.ajourn && mind.current.stat != DEAD) 	//check if the corpse is astral-journeying (it's client ghosted using a cultist rune).
		var/obj/effect/rune/R = mind.current.ajourn	//whilst corpse is alive, we can only reenter the body if it's on the rune
		if(!(R && R.word1 == cultwords["hell"] && R.word2 == cultwords["travel"] && R.word3 == cultwords["self"]))	//astral journeying rune
			to_chat(usr, "<span class='warning'>The astral cord that ties your body and your spirit has been severed. You are likely to wander the realm beyond until your body is finally dead and thus reunited with you.</span>")
			return
	if(mind && mind.current && mind.current.ajourn)
		mind.current.ajourn.ajourn = null
		mind.current.ajourn = null
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
	if(medHUD)
		medHUD = 0
		to_chat(src, "<span class='notice'><B>Medical HUD Disabled</B></span>")
	else
		medHUD = 1
		to_chat(src, "<span class='notice'><B>Medical HUD Enabled</B></span>")

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

	if((usr.invisibility == 0) || (ticker && ticker.mode && (ticker.mode.name == "cult") && (usr.mind in ticker.mode.cult)))
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
		if(targetloc && targetloc.holy && ((!invisibility) || (mind in ticker.mode.cult)))
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
			if(targetloc && targetloc.holy && ((src.invisibility == 0) || (src.mind in ticker.mode.cult)))
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

	to_chat(src, "<span class='notice'><B>Results:</B></span>")
	if(abs(pressure - ONE_ATMOSPHERE) < 10)
		to_chat(src, "<span class='notice'>Pressure: [round(pressure,0.1)] kPa</span>")
	else
		to_chat(src, "<span class='warning'>Pressure: [round(pressure,0.1)] kPa</span>")
	if(total_moles)
		var/o2_concentration = environment.oxygen/total_moles
		var/n2_concentration = environment.nitrogen/total_moles
		var/co2_concentration = environment.carbon_dioxide/total_moles
		var/plasma_concentration = environment.toxins/total_moles

		var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)
		if(abs(n2_concentration - N2STANDARD) < 20)
			to_chat(src, "<span class='notice'>Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='warning'>Nitrogen: [round(n2_concentration*100)]% ([round(environment.nitrogen,0.01)] moles)</span>")

		if(abs(o2_concentration - O2STANDARD) < 2)
			to_chat(src, "<span class='notice'>Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='warning'>Oxygen: [round(o2_concentration*100)]% ([round(environment.oxygen,0.01)] moles)</span>")

		if(co2_concentration > 0.01)
			to_chat(src, "<span class='warning'>CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)</span>")
		else
			to_chat(src, "<span class='notice'>CO2: [round(co2_concentration*100)]% ([round(environment.carbon_dioxide,0.01)] moles)</span>")

		if(plasma_concentration > 0.01)
			to_chat(src, "<span class='warning'>Plasma: [round(plasma_concentration*100)]% ([round(environment.toxins,0.01)] moles)</span>")

		if(unknown_concentration > 0.01)
			to_chat(src, "<span class='warning'>Unknown: [round(unknown_concentration*100)]% ([round(unknown_concentration*total_moles,0.01)] moles)</span>")

		to_chat(src, "<span class='notice'>Temperature: [round(environment.temperature-T0C,0.1)]&deg;C</span>")
		to_chat(src, "<span class='notice'>Heat Capacity: [round(environment.heat_capacity(),0.1)]</span>")


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
		to_chat(src, "<span class='warning'>Respawning as mouse is disabled..</span>")
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
	var/mob/living/simple_animal/mouse/host
	var/obj/machinery/atmospherics/unary/vent_pump/vent_found
	var/list/found_vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/v in atmos_machines)
		if(!v.welded && v.z == src.z && v.canSpawnMice==1) // No more spawning in atmos.  Assuming the mappers did their jobs, anyway.
			found_vents.Add(v)
	if(found_vents.len)
		vent_found = pick(found_vents)
		host = new /mob/living/simple_animal/mouse(vent_found.loc)
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
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/C = ticker.mode
		if(C.cult.len > config.cult_ghostwriter_req_cultists)
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
		if(locked_to)
			manual_stop_follow(locked_to)
		usr.forceMove(targetarena.center)
		to_chat(usr, "Remember to enable darkness to be able to see the spawns. Click on a green spawn between rounds to register on it.")

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
	usr.visible_message("<span class='deadsay'><b>[src]</b> points to [A]</span>")
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

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

/mob/dead/observer/verb/hide_sprite()
	set name = "Hide Sprite"
	set category = "Ghost"

	if(alpha == 127)
		alpha = 0
		mouse_opacity = 0
		to_chat(src, "<span class='warning'>Sprite hidden.</span>")
	else
		alpha = 127
		mouse_opacity = 1
		to_chat(src, "<span class='info'>Sprite shown.</span>")

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

/mob/dead/observer/verb/toggle_darkness()
	set name = "Toggle Darkness"
	set category = "Ghost"

	if (see_invisible == SEE_INVISIBLE_OBSERVER_NOLIGHTING)
		see_invisible = SEE_INVISIBLE_OBSERVER
	else
		see_invisible = SEE_INVISIBLE_OBSERVER_NOLIGHTING


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

/mob/dead/observer/verb/pai_signup()
	set name = "Sign up as pAI"
	set category = "Ghost"
	set desc = "Create and submit your pAI personality"

	if(!paiController.check_recruit(src))
		to_chat(src, "<span class='warning'>Not available. You may have been pAI-banned.</span>")
		return

	paiController.recruitWindow(src)

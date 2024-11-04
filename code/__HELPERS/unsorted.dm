//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */
/proc/sign(x)
	return x!=0?x/abs(x):0

/proc/getline(atom/M,atom/N)//Ultra-Fast Bresenham Line-Drawing Algorithm
	var/px=M.x		//starting x
	var/py=M.y
	var/line[] = list(locate(px,py,M.z))
	var/dx=N.x-px	//x distance
	var/dy=N.y-py
	var/dxabs=abs(dx)//Absolute value of x distance
	var/dyabs=abs(dy)
	var/sdx=sign(dx)	//Sign of x distance (+ or -)
	var/sdy=sign(dy)
	var/x=dxabs>>1	//Counters for steps taken, setting to distance/2
	var/y=dyabs>>1	//Bit-shifting makes me l33t.  It also makes getline() unnessecarrily fast.
	var/j			//Generic integer for counting
	if(dxabs>=dyabs)	//x distance is greater than y
		for(j=0;j<dxabs;j++)//It'll take dxabs steps to get there
			y+=dyabs
			if(y>=dxabs)	//Every dyabs steps, step once in y direction
				y-=dxabs
				py+=sdy
			px+=sdx		//Step on in x direction
			line+=locate(px,py,M.z)//Add the turf to the list
	else
		for(j=0;j<dyabs;j++)
			x+=dxabs
			if(x>=dyabs)
				x-=dyabs
				px+=sdx
			py+=sdy
			line+=locate(px,py,M.z)
	return line

//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return 0

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i)
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57)
			return 0
	return 1

//Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(var/f)
	f = clamp(round(f), 1201, 1599) // 120.1, 159.9

	if ((f % 2) == 0) //Ensure the last digit is an odd number
		f += 1

	return f

//Turns 1479 into 147.9
/proc/format_frequency(var/f)
	f = text2num(f)
	return "[round(f / 10)].[f % 10]"



/**
 * This will update a mob's name, real_name, mind.name, data_core records, pda and id.
 * Calling this proc without an oldname will only update the mob and skip updating the pda, id and records. ~Carn
 */
/mob/proc/fully_replace_character_name(oldname, newname)
	if (!newname)
		return 0

	real_name = newname

	name = newname

	if (mind)
		mind.name = newname
		if(mind.initial_account)
			mind.initial_account.owner_name = newname

	if (dna)
		dna.real_name = real_name

	if (oldname)
		//Update the datacore records and centcomm database
		for (var/list/L in list(data_core.general, data_core.medical, data_core.security,data_core.locked))
			if (L)
				var/datum/data/record/R = find_record("name", oldname, L)

				if (R)
					R.fields["name"] = newname

		// update our pda and id if we have them on our person
		var/search_id = TRUE

		var/search_pda = TRUE

		for (var/object in get_contents_in_object(src))
			if (search_id && istype(object, /obj/item/weapon/card/id))
				var/obj/item/weapon/card/id/ID = object

				if (ID.registered_name == oldname)
					ID.registered_name = newname
					ID.name = "[newname]'s ID Card ([ID.assignment])"

					if (!search_pda)
						break

					search_id = FALSE
			else if (search_pda && istype(object, /obj/item/device/pda))
				var/obj/item/device/pda/PDA = object

				if (PDA.owner == oldname)
					PDA.owner = newname
					PDA.name = "PDA-[newname] ([PDA.ownjob])"

					if (!search_id)
						break

					search_pda = FALSE
	return 1

//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
//Also used for the screen alarm rename option
/mob/proc/rename_self(var/role, var/allow_numbers=0, var/namepick_message = "You are a [role]. Would you like to change your name to something else?")
	spawn(0)
		var/oldname = real_name

		var/newname

		for(var/i=1,i<=3,i++)	//we get 3 attempts to pick a suitable name.
			newname = input(src,namepick_message, "Name change",oldname) as text
			newname = reject_bad_name(newname,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			to_chat(src, "Sorry, that name wasn't appropriate, please try another. It's possibly too long/short, has bad characters or is already taken.")

		if(!newname)	//we'll stick with the oldname then
			return

		if(cmptext("ai",role))
			if(isAI(src))
				var/mob/living/silicon/ai/A = src
				if(A.connected_robots.len) //let the borgs know what their master's new name is
					for(var/mob/living/silicon/robot/robitt in A.connected_robots)
						to_chat(robitt, "<span class='notice' style=\"font-family:Courier\">Notice: Linked AI [oldname] renamed to [newname].</span>")
				oldname = null//don't bother with the records update crap
//				to_chat(world, "<b>[newname] is the AI!</b>")
//				world << sound('sound/AI/newAI.ogg')
				// Set eyeobj name
				if(A.eyeobj)
					A.eyeobj.name = "[newname] (AI Eye)"

				// Set ai pda name
				if(A.aiPDA)
					A.aiPDA.owner = newname
					A.aiPDA.name = newname + " (" + A.aiPDA.ownjob + ")"


		to_chat(src, "<span class='notice'>You will now be known as [newname].</span>")
		fully_replace_character_name(oldname,newname)



//Picks a string of symbols to display as the law number for hacked or ion laws
/proc/ionnum()
	return "[pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")][pick("!","@","#","$","%","^","&","*")]"

//When an AI is activated, it can choose from a list of non-slaved borgs to have as a slave.
/proc/freeborg()
	var/select = null
	var/list/borgs = list()

	for(var/mob/living/silicon/robot/A in player_list)
		if(DEAD == A.stat || A.connected_ai || A.scrambledcodes)
			continue

		var/name = "[A.real_name] ([A.modtype] [A.braintype])"
		borgs[name] = A

	if(borgs.len)
		select = input("Unshackled borg signals detected:", "Borg selection", null, null) as null|anything in borgs
		return borgs[select]

//When a borg is activated, it can choose which AI it wants to be slaved to
/proc/active_ais()
	. = list()
	for(var/mob/living/silicon/ai/A in living_mob_list)
		if(A.stat == DEAD)
			continue
		if(A.control_disabled == 1)
			continue
		. += A
	return .

//Find an active ai with the least borgs. VERBOSE PROCNAME HUH!
/proc/select_active_ai_with_fewest_borgs()
	var/mob/living/silicon/ai/selected
	var/list/active = active_ais()
	for(var/mob/living/silicon/ai/A in active)
		if(!selected || (selected.connected_robots.len > A.connected_robots.len))
			selected = A

	return selected

/proc/select_active_ai(var/mob/user)
	var/list/ais = active_ais()
	if(ais.len)
		if(user)
			. = input(usr,"AI signals detected:", "AI selection") in ais
		else
			. = pick(ais)
	return .

//Returns a list of all mobs with their name
/proc/getmobs()


	var/list/mobs = sortmobs()
	var/list/names = list()
	var/list/creatures = list()
	var/list/namecounts = list()
	for(var/mob/M in mobs)
		var/name = M.name
		if (name in names)
			namecounts[name]++
			name = "[name] ([namecounts[name]])"
		else
			names.Add(name)
			namecounts[name] = 1
		if (M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if (M.stat == 2)
			if(istype(M, /mob/dead/observer/))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		creatures[name] = M

	return creatures

//Orders mobs by type then by name
/proc/sortmobs()
	var/list/sorted_output = list()
	var/list/sortedplayers = list()
	var/list/sortedmobs = list()
	for(var/mob/M in mob_list) //Divide every mob into either players (has a mind) or non-players (no mind). Braindead/catatonic/etc. mobs included in players
		if(isnull(M) || (!M.loc)) //Ignore null entries or anything in nullspace
			continue
		if(M.mind || istype(M, /mob/camera))
			sortedplayers |= M
			continue
		sortedmobs |= M
	sortNames(sortedplayers) //sort both lists in preparation for what we'll do below
	sortNames(sortedmobs)
	for(var/mob/living/silicon/ai/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/camera/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/silicon/pai/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/silicon/robot/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/carbon/human/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/carbon/brain/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/carbon/alien/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/dead/observer/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/new_player/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/carbon/monkey/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/carbon/slime/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/simple_animal/M in sortedplayers)
		sorted_output.Add(M)
	for(var/mob/living/M in sortedmobs) //Mobs that have never been controlled by a player go last in the list. /mob/living to filter unwanted non-player non-world mobs (i.e. you'll nullspace if you observe them)
		if(M.client || istype(M, /mob/living/captive_brain)) //Ignore the mob if it has a client or is a "captive brain" (borer nonsense)
			continue
		sorted_output.Add(M)

	return sorted_output

// Finds ALL mobs on turfs in line of sight. Similar to "in dview", but catches mobs that are not on a turf (e.g. inside a locker or such).
/proc/get_all_mobs_in_dview(var/turf/T, var/range = world.view, var/list/ignore_types = list())
	. = list()
	var/list/can_see = dview(range, T)
	for(var/mob/M in can_see)
		if(is_type_in_list(M, ignore_types))
			continue
		. += M
	for(var/mob/M in mob_list) //Got the ones in vision, now let's go for the ones not on a turf.
		if(M.z == 0) //Mobs not on a turf will have XYZ = 0,0,0. They also won't show up in dview() so we're not checking anything twice.
			if(is_type_in_list(M, ignore_types))
				continue
			if(get_turf(M) in can_see) //Checking the mob's turf now, since those are it's "true" coordinates (plus dview() did pick up on turfs, so we can check using that).
				. += M

//E = MC^2
/proc/convert2energy(var/M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

//M = E/C^2
/proc/convert2mass(var/E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

/proc/key_name(var/whom, var/include_link = null, var/include_name = TRUE, var/more_info = FALSE, var/showantag = TRUE)
	var/mob/M
	var/client/C
	var/key

	if(!whom)
		return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
	else if(istype(whom, /datum/mind))
		var/datum/mind/D = whom
		M = D.current
		key = M.key
		C = M.client
	else if(istype(whom, /datum))
		var/datum/D = whom
		return "*invalid:[D.type]*"
	else
		return "*invalid*"

	. = ""

	if(key)
		if(include_link && C)
			. += "<a href='?priv_msg=\ref[C]'>"

		if(C && C.holder && C.holder.fakekey && !include_name)
			. += "Administrator"
		else
			. += key

		if(include_link)
			if(C)
				. += "</a>"
			else
				. += " (DC)"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.real_name)
			. += "/([M.real_name])"
		else if(M.name)
			. += "/([M.name])"

	if(showantag && M && isanyantag(M))
		var/counts_as_antag = FALSE
		for(var/role in M.mind.antag_roles)
			var/datum/role/R = M.mind.antag_roles[role]
			if(R.is_antag)
				counts_as_antag = TRUE
				break
		if(counts_as_antag)
			. += " <span title='[english_list(M.mind.antag_roles)]'>(A)</span>"

	if(more_info && M)
		. += "(<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=holder;adminmoreinfo=\ref[M]'>?</A>)"

/proc/key_name_admin(var/whom, var/include_name = 1)
	return key_name(whom, 1, include_name)

/proc/key_name_and_info(var/whom)
	return key_name(whom, more_info = TRUE)

// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: user << browse(text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, var/atom/ref=null)
	set waitfor = FALSE // winexists sleeps
	for(var/i in 1 to WINSET_MAX_ATTEMPTS)
		if(user && winexists(user, windowid))
			var/param = ref ? "\ref[ref]" : "null"
			winset(user, windowid, "on-close=\".windowclose [param]\"")
			break

//	to_chat(world, "OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]")

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)
	if(!A)
		return 0
	var/turf/target = locate(A.x, A.y, A.z)
	//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
	//and isn't really any more complicated

	// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target

// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(var/atom/A, var/direction, var/range)
	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	if(direction & WEST)
		x = max(1, x - range)

	return locate(x,y,A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = clamp(A.x + dx, 1, world.maxx)
	var/y = clamp(A.y + dy, 1, world.maxy)

	return locate(x, y, A.z)

//returns random gauss number
/proc/GaussRand(var/sigma)
  var/x,y,rsq
  do
    x=2*rand()-1
    y=2*rand()-1
    rsq=x*x+y*y
  while(rsq>1 || !rsq)
  return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
/proc/GaussRandRound(var/sigma,var/roundto)
	return round(GaussRand(sigma),roundto)

//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(var/atom/source, var/atom/target, var/length=5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	var/steps = 0

	while(current != target_turf)
		if(steps > length)
			return 0
		if(current.opacity)
			return 0
		for(var/atom/A in current)
			if(A.opacity)
				return 0
		current = get_step_towards(current, target_turf)
		steps++

	return 1

/proc/is_blocked_turf(var/turf/T, var/atom/movable/exclude)
	return T.density || T.has_dense_content(exclude) != 0

//if needs_item is 0 it won't need any item that existed in "holding" to finish
/proc/do_mob(var/mob/user , var/mob/target, var/delay = 30, var/numticks = 10, var/needs_item = 1) //This is quite an ugly solution but i refuse to use the old request system.
	if(!user || !target)
		return 0
	var/user_loc = user.loc
	var/target_loc = target.loc
	var/holding = user.get_active_hand()
	var/delayfraction = round(delay/numticks)
	var/image/progbar
	if(user && user.client && user.client.prefs.progress_bars)
		if(!progbar)
			progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
			progbar.plane = HUD_PLANE
			progbar.layer = HUD_ABOVE_ITEM_LAYER
			progbar.pixel_z = WORLD_ICON_SIZE
		//if(!barbar)
			//barbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = user, "icon_state" = "none")
			//barbar.pixel_y = 36
	//var/oldstate
	for (var/i = 1 to numticks)
		if(user && user.client && user.client.prefs.progress_bars && progbar)
			//oldstate = progbar.icon_state
			progbar.icon_state = "prog_bar_[round(((i / numticks) * 100), 10)]"
			user.client.images |= progbar
		sleep(delayfraction)
		if(!user || !target)
			if(progbar)
				progbar.icon_state = "prog_bar_stopped"
				spawn(2)
					if(user && user.client)
						user.client.images -= progbar
					if(progbar)
						progbar.loc = null
			return 0
		if ( user.loc != user_loc || target.loc != target_loc || (needs_item && (holding && !user.is_holding_item(holding)) || (!holding && user.get_active_hand())) || user.isStunned())
			if(progbar)
				progbar.icon_state = "prog_bar_stopped"
				spawn(2)
					if(user && user.client)
						user.client.images -= progbar
					if(progbar)
						progbar.loc = null
			return 0
	if(user && user.client)
		user.client.images -= progbar
	if(progbar)
		progbar.loc = null
	return 1

/proc/do_after_many(var/mob/user, var/list/targets, var/delay, var/numticks = 10, var/needhand = TRUE, var/use_user_turf = FALSE)
	if(!user || numticks == 0 || !targets || !targets.len)
		return 0

	var/delay_fraction = round(delay / numticks)
	if(istype(user.loc, /obj/mecha))
		use_user_turf = TRUE
	var/initial_user_location = use_user_turf ? get_turf(user) : user.loc
	var/holding = user.get_active_hand()
	var/list/initial_target_locations = list()
	for(var/atom/target in targets)
		initial_target_locations[target] = target.loc

	if(user.client && user.client.prefs.progress_bars)
		for(var/target in targets)
			if(!targets[target])
				var/image/new_progress_bar = create_progress_bar_on(target)
				targets[target] = new_progress_bar
				user.client.images += new_progress_bar
	for(var/i = 1 to numticks)
		for(var/target in targets)
			var/image/target_progress_bar = targets[target]
			target_progress_bar.icon_state = "prog_bar_[round(((i / numticks) * 100), 10)]"
		sleep(delay_fraction)
		var/user_loc_to_check = use_user_turf ? get_turf(user) : user.loc
		for(var/atom/target in targets)
			var/initial_target_location = initial_target_locations[target]
			if(!user || user.isStunned() || user_loc_to_check != initial_user_location || !target || target.loc != initial_target_location)
				for(var/target_ in targets)
					var/image/target_progress_bar = targets[target_]
					stop_progress_bar(user, target_progress_bar)
				return FALSE
		if(needhand && ((holding && !user.is_holding_item(holding)) || (!holding && user.get_active_hand())))
			for(var/target_ in targets)
				var/image/target_progress_bar = targets[target_]
				stop_progress_bar(user, target_progress_bar)
			return FALSE
	for(var/target in targets)
		var/image/target_progress_bar = targets[target]
		remove_progress_bar(user, target_progress_bar)

	return TRUE

/proc/create_progress_bar_on(var/atom/target)
	var/image/progress_bar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
	progress_bar.pixel_z = WORLD_ICON_SIZE
	progress_bar.plane = HUD_PLANE
	progress_bar.layer = HUD_ABOVE_ITEM_LAYER
	progress_bar.appearance_flags = RESET_COLOR | RESET_TRANSFORM
	return progress_bar

/proc/remove_progress_bar(var/mob/user, var/image/progress_bar)
	if(user && user.client)
		user.client.images -= progress_bar
	if(progress_bar)
		progress_bar.loc = null

/proc/stop_progress_bar(var/mob/user, var/image/progress_bar)
	progress_bar.icon_state = "prog_bar_stopped"
	spawn(0.2 SECONDS)
		remove_progress_bar(user, progress_bar)

// Returns TRUE if the checks passed
/proc/do_after_default_checks(mob/user, use_user_turf, user_original_location, atom/target, target_original_location, needhand, obj/item/originally_held_item)
	if(!user)
		return FALSE
	if(user.isStunned())
		return FALSE
	var/user_loc_to_check = use_user_turf ? get_turf(user) : user.loc
	if(user_loc_to_check != user_original_location)
		return FALSE
	if(target.loc != target_original_location)
		return FALSE
	if(needhand)
		if(originally_held_item)
			if(!user.is_holding_item(originally_held_item))
				return FALSE
		else
			if(user.get_active_hand())
				return FALSE
	return TRUE

/**
  * Used to delay actions.
  *
  * Given a mob, a target atom and a duration,
  * returns TRUE if the mob wasn't interrupted and stayed
  * at the same position for the specified duration.
  * Arguments:
  * * mob/user - the user who will see the progress bar
  * * atom/target - the atom the progress bar will be attached to
  * * delay - duration in deciseconds of the delay
  * * numticks - how many times the failure conditions will be checked throughout the duration. default 10
  * * needhand - if TRUE, the item in the hands of the user needs to stay the same throughout the duration. default TRUE
  * * use_user_turf - if TRUE, the turf of the user is checked instead of its location. default FALSE
  * * custom_checks - if specified, the return value of this callback (called every `delay/numticks` seconds) will determine whether the action succeeded
  */
/proc/do_after(var/mob/user as mob, var/atom/target, var/delay as num, var/numticks = 10, var/needhand = TRUE, var/use_user_turf = FALSE, callback/custom_checks)
	if(!user || isnull(user))
		return 0
	if(numticks == 0)
		return 0

	var/delayfraction = round(delay/numticks)
	var/Location
	if(istype(user.loc, /obj/mecha))
		use_user_turf = TRUE
	if(use_user_turf)	//When this is true, do_after() will check whether the user's turf has changed, rather than the user's loc.
		Location = get_turf(user)
	else
		Location = user.loc
	var/holding = user.get_active_hand()
	var/target_location = target.loc
	var/image/progbar
	//var/image/barbar
	if(user && user.client && user.client.prefs.progress_bars && target)
		if(!progbar)
			progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
			progbar.pixel_z = WORLD_ICON_SIZE
			progbar.plane = HUD_PLANE
			progbar.layer = HUD_ABOVE_ITEM_LAYER
			progbar.appearance_flags = RESET_COLOR | RESET_TRANSFORM
	for (var/i = 1 to numticks)
		if(user && user.client && user.client.prefs.progress_bars && target)
			if(!progbar)
				progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
				progbar.pixel_z = WORLD_ICON_SIZE
				progbar.plane = HUD_PLANE
				progbar.layer = HUD_ABOVE_ITEM_LAYER
				progbar.appearance_flags = RESET_COLOR | RESET_TRANSFORM
			progbar.icon_state = "prog_bar_[round(((i / numticks) * 100), 10)]"
			user.client.images |= progbar
		sleep(delayfraction)
		var/success
		if(custom_checks)
			success = custom_checks.invoke(user, use_user_turf, Location, target, target_location, needhand, holding)
		else
			success = do_after_default_checks(user, use_user_turf, Location, target, target_location, needhand, holding)
		if(!success)
			if(progbar)
				stop_progress_bar(user, progbar)
			return 0
	if(user && user.client)
		user.client.images -= progbar
	if(progbar)
		progbar.loc = null
	return 1

/proc/do_flick(var/atom/A, var/icon_state, var/time)
	flick(icon_state, A)
	sleep(time)
	return 1

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all areas of that type in the world.
/proc/get_areas(var/areatype)
	if(!areatype)
		return null
	if(istext(areatype))
		areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/theareas = new/list()
	for(var/area/N in areas)
		if(istype(N, areatype))
			theareas += N
	return theareas

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(var/areatype)
	if(!areatype)
		return null
	if(istext(areatype))
		areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = new/list()
	/*for(var/area/N in areas)
		if(istype(N, areatype))
			for(var/turf/T in N) turfs += T*/
	var/area/N = locate(areatype) in areas
	if(N)
		turfs += N.area_turfs
	return turfs

/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null

/datum/coords/New(var/x as num, var/y as num, var/z as num)
	.=..()
	x_pos = x
	y_pos = y
	z_pos = z

/datum/coords/proc/equal_to(var/datum/coords/C)
	if(src.x_pos==C.x_pos && src.y_pos==C.y_pos && src.z_pos==C.z_pos)
		return 1
	return 0

/datum/coords/proc/subtract(var/datum/coords/C)
	var/datum/coords/CR = new(x_pos-C.x_pos,y_pos-C.y_pos,z_pos-C.z_pos)
	return CR

/datum/coords/proc/add(var/datum/coords/C)
	var/datum/coords/CR = new(x_pos+C.x_pos,y_pos+C.y_pos,z_pos+C.z_pos)
	return CR

// If you're looking at this proc and thinking "that's exactly what I need!"
// then you're wrong and you need to take a step back and reconsider.
/atom/movable/proc/DuplicateObject(var/location)
	var/atom/movable/duplicate = new src.type(location)
	duplicate.change_dir(dir)
	duplicate.plane = plane
	duplicate.layer = layer
	duplicate.name = name
	duplicate.desc = desc
	duplicate.pixel_x = pixel_x
	duplicate.pixel_y = pixel_y
	duplicate.pixel_w = pixel_w
	duplicate.pixel_z = pixel_z
	return duplicate

/area/proc/copy_contents_to(area/A , platingRequired = FALSE)
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/copiedobjs = list()

	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)
					var/old_name = T.name
					var/old_dir = T.dir
					var/old_icon_state = T.icon_state
					var/old_icon = T.icon

					if(platingRequired)
						if(istype(B, /turf/space))
							continue moving

					B.ChangeTurf(T.type)
					B.name = old_name
					B.dir = old_dir
					B.icon_state = old_icon_state
					B.icon = old_icon

					B.return_air().copy_from(T.return_air())

					for(var/obj/O in T)
						copiedobjs += O.DuplicateObject(B)

					for(var/mob/M in T)
						if(!M.can_shuttle_move())
							continue
						copiedobjs += M.DuplicateObject(B)

					refined_src -= T
					refined_trg -= B
					continue moving

	for(var/obj/machinery/door/new_door in copiedobjs)
		new_door.update_nearby_tiles()

	return copiedobjs

/proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

/proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

/proc/parse_zone(zone)
	switch(zone)
		if (LIMB_RIGHT_HAND)
			return "right hand"
		if (LIMB_LEFT_HAND)
			return "left hand"
		if (LIMB_LEFT_ARM)
			return "left arm"
		if (LIMB_RIGHT_ARM)
			return "right arm"
		if (LIMB_LEFT_LEG)
			return "left leg"
		if (LIMB_RIGHT_LEG)
			return "right leg"
		if (LIMB_LEFT_FOOT)
			return "left foot"
		if (LIMB_RIGHT_FOOT)
			return "right foot"
		else
			return zone

/proc/limb_define_to_part_define(var/zone)
	switch(zone)
		if (LIMB_HEAD)
			return HEAD
		if (LIMB_CHEST)
			return UPPER_TORSO
		if (LIMB_GROIN)
			return LOWER_TORSO
		if (TARGET_MOUTH)
			return MOUTH
		if (TARGET_EYES)
			return EYES
		if (LIMB_RIGHT_HAND)
			return HAND_RIGHT
		if (LIMB_LEFT_HAND)
			return HAND_LEFT
		if (LIMB_LEFT_ARM)
			return ARM_LEFT
		if (LIMB_RIGHT_ARM)
			return ARM_RIGHT
		if (LIMB_LEFT_LEG)
			return LEG_LEFT
		if (LIMB_RIGHT_LEG)
			return LEG_RIGHT
		if (LIMB_LEFT_FOOT)
			return FOOT_LEFT
		if (LIMB_RIGHT_FOOT)
			return FOOT_RIGHT

/*
	get_holder_at_turf_level(): Similar to get_turf(), will return the "highest up" holder of this atom, excluding the turf.
	Example: A fork inside a box inside a locker will return the locker. Essentially, get_just_before_turf().
*/
/proc/get_holder_at_turf_level(const/atom/movable/O)
	if(!istype(O)) //atom/movable does not include areas
		return
	var/atom/A
	for(A=O, A && !isturf(A.loc), A=A.loc);  // semicolon is for the empty statement
	return A

/*
	get_holder_of_type(): Returns the FIRST holder of type specified. NOT the "highest up".
	Example: Call find_holder_of_type(A, /mob) to find the first mob holder of A.
*/
/proc/get_holder_of_type(const/atom/movable/O, type)
	ASSERT(istype(O))
	var/atom/A = O
	while(A && !isturf(A))
		if(istype(A, type))
			return A
		A = A.loc
	return null

/*
	is_holder_of(): Returns 1 if A is a holder of B, meaning, A is B.loc or B.loc.loc or B.loc.loc.loc etc.
	This is essentially the same as calling (locate(B) in A), but a little clearer as to what you're doing, and locate() has been known to bug out or be extremely slow in the past.
*/
/proc/is_holder_of(const/atom/movable/A, const/atom/movable/B)
	if(istype(A, /turf) || istype(B, /turf)) //Clicking on turfs is a common thing and turfs are also not /atom/movable, so it was causing the assertion to fail.
		return 0
	ASSERT(istype(A) && istype(B))
	var/atom/O = B
	while(O && !isturf(O))
		if(O == A)
			return 1
		O = O.loc
	return 0

/proc/is_in_airtight_object(var/atom/O) //Shitty version of get_holder
	while(O && !isturf(O))
		if(O.is_airtight())
			return 1
		O = O.loc
	return null

//check if mob is lying down on something we can operate him on.
/proc/can_operate(mob/living/carbon/M, mob/U, var/obj/item/tool) // tool arg only needed if you actually intend to perform surgery (and not for instance, just do an autopsy)
	if(U == M)
		return 0
	var/too_bad = FALSE
	if((ishuman(M) || isslime(M)) && M.lying)
		if(locate(/obj/machinery/optable,M.loc) || locate(/obj/structure/bed/roller/surgery, M.loc))
			return 1
		if(iscultist(U) && locate(/obj/structure/cult/altar, M.loc))
			return 1
		if(locate(/obj/structure/bed/roller, M.loc))
			too_bad = TRUE
			if (prob(75))
				return 1
		var/obj/structure/table/T = locate(/obj/structure/table/, M.loc)
		if(T && !T.flipped)
			too_bad = TRUE
			if (prob(66))
				return 1

	//if we failed when trying to use a table or roller bed, let's at least check if it was a valid surgery step
	if (too_bad && tool)
		if (do_surgery(M,U,tool,SURGERY_SUCCESS_NEVER))
			return 1

	return 0

/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = list(
	"/obj/machinery/power/apc", "/obj/machinery/alarm", "/obj/item/device/radio/intercom",
	"/obj/structure/extinguisher_cabinet", "/obj/structure/reagent_dispensers/peppertank",
	"/obj/machinery/status_display", "/obj/machinery/requests_console", "/obj/machinery/light_switch", "/obj/structure/sign",
	"/obj/machinery/newscaster", "/obj/machinery/firealarm", "/obj/structure/noticeboard", "/obj/machinery/door_control",
	"/obj/machinery/computer/security/telescreen", "/obj/machinery/embedded_controller/radio/simple_vent_controller",
	"/obj/item/weapon/storage/secure/safe", "/obj/machinery/door_timer", "/obj/machinery/flasher", "/obj/machinery/keycard_auth",
	"/obj/structure/mirror", "/obj/structure/fireaxecabinet", "obj/structure/sign", "obj/structure/painting"
	)
/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		for(var/item in WALLITEMS)
			if(istype(O, text2path(item)))
				//Direction works sometimes
				if(O.dir == dir)
					return 1

				//Some stuff doesn't use dir properly, so we need to check pixel instead
				switch(dir)
					if(SOUTH)
						if(O.pixel_y > 10*PIXEL_MULTIPLIER)
							return 1
					if(NORTH)
						if(O.pixel_y < -10*PIXEL_MULTIPLIER)
							return 1
					if(WEST)
						if(O.pixel_x > 10*PIXEL_MULTIPLIER)
							return 1
					if(EAST)
						if(O.pixel_x < -10*PIXEL_MULTIPLIER)
							return 1


	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		for(var/item in WALLITEMS)
			if(istype(O, text2path(item)))
				if(abs(O.pixel_x) <= 10*PIXEL_MULTIPLIER && abs(O.pixel_y) <=10*PIXEL_MULTIPLIER)
					return 1
	return 0

/proc/rotate_icon(file, state, step = 1, aa = FALSE)
	var/icon/base = icon(file, state)

	var/w
	var/h
	var/w2
	var/h2

	if(aa)
		aa ++
		w = base.Width()
		w2 = w * aa
		h = base.Height()
		h2 = h * aa

	var/icon/result = icon(base)
	var/icon/temp

	for(var/angle in 0 to 360 step step)
		if(angle == 0  )
			continue
		if(angle == 360)
			continue
		temp = icon(base)
		if(aa)
			temp.Scale(w2, h2)
		temp.Turn(angle)
		if(aa)
			temp.Scale(w,   h)
		result.Insert(temp, "[angle]")

	return result

/proc/get_distant_turf(var/turf/T,var/direction,var/distance)
	if(!T || !direction || !distance)
		return

	var/dest_x = T.x
	var/dest_y = T.y
	var/dest_z = T.z

	if(direction & NORTH)
		dest_y = min(world.maxy, dest_y+distance)
	if(direction & SOUTH)
		dest_y = max(0, dest_y-distance)
	if(direction & EAST)
		dest_x = min(world.maxy, dest_x+distance)
	if(direction & WEST)
		dest_x = max(0, dest_x-distance)

	return locate(dest_x,dest_y,dest_z)

/var/mob/dview/dview_mob = new

//Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(var/range = world.view, var/center, var/invis_flags = 0)
	if(!center)
		return

	dview_mob.loc = center

	dview_mob.see_invisible = invis_flags

	. = view(range, dview_mob)
	dview_mob.loc = null

/mob/dview
	invisibility = 101
	density = 0
	see_in_dark = 1e6
	anchored = 1
	flags = INVULNERABLE

/mob/dview/send_to_future(var/duration)
	return

/mob/dview/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Somebody called qdel on dview. That's extremely rude.")

//Returns a list of everything target can see, taking into account its sight, but without being blocked by being inside an object.
//No, view(client) does not work for this, despite what the Ref says.
//This could be made into a define if you don't mind leaving tview_mob lying around. This could cause bugs though.
/proc/tview(mob/target)
	. = view(target.client?.view || world.view, setup_tview(target))
	tview_mob.loc = null

/proc/setup_tview(mob/target)
	tview_mob.loc = get_turf(target)
	tview_mob.sight = target.sight
	tview_mob.see_in_dark = target.see_in_dark
	tview_mob.see_invisible = target.see_invisible
	tview_mob.see_infrared = target.see_infrared //I'm pretty sure we don't actually use this but might as well include it
	return tview_mob

//Aside from usage, this proc is the only difference between tview and dview.
/mob/dview/tview/Destroy()
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Somebody called qdel on tview. That's extremely rude.")

//They SHOULD both be independent children of a common parent, but dview has been around much longer and I don't really want to change it
var/mob/dview/tview/tview_mob = new()

//Gets the Z level datum for this atom's Z level
/proc/get_z_level(var/atom/A)
	var/z
	if(istype(A, /atom/movable))
		var/turf/T = get_turf(A)
		if(!T)
			return null
		z = T.z
	else
		z = A.z

	. = map.zLevels[z]

/proc/transfer_fingerprints(atom/A,atom/B)//synchronizes the fingerprints between two atoms. Useful when you have two different atoms actually being different states of a same object.
	if(!A || !B)
		return
	B.fingerprints = A.fingerprints
	B.fingerprintshidden = A.fingerprintshidden
	B.fingerprintslast = A.fingerprintslast
	B.suit_fibers = A.suit_fibers

//Checks if any of the atoms in the turf are dense
//Returns 1 is anything is dense, 0 otherwise
/turf/proc/has_dense_content(atom/movable/exclude)
	for(var/atom/turf_contents in contents)
		if(turf_contents.density && turf_contents != exclude)
			return turf_contents
	return 0

//Checks if there are any atoms in the turf that aren't system-only (currently only lighting overlays count)
//Returns 1 is there's something, 0 if it finds nothing
/turf/proc/has_contents()
	if(!contents.len)
		return 0
	for(var/atom/A in contents)
		if(!istype(A, /atom/movable/lighting_overlay))
			return 0
	return 1

//This helper uses the method shown above to clear up the tile's contents, if any, ignoring the lighting overlays (technically all systems contents)
//Includes an exception list if you don't want to delete some stuff
/turf/proc/clear_contents(var/list/ignore = list())
	for(var/atom/turf_contents in contents)
		if(!istype(turf_contents, /atom/movable/lighting_overlay) && !is_type_in_list(turf_contents, ignore) && !(flags & INVULNERABLE))
			qdel(turf_contents)

/proc/multinum_display(var/number,var/digits)//multinum_display(42,4) = "0042"; multinum_display(-137,6) = "-000137"; multinum_display(4572,3) = "999"
	var/result = ""
	if((digits < 1))
		return "0"
	var/abs = abs(number)
	if(abs > (10**digits))
		for(var/D=0;D<digits;D++)
			result += "9"
		if(number<0)
			result = "-[result]"
		return result
	var/number_digits = 1
	for(var/N = abs;N >= 10; N = N/10)
		number_digits++
	var/additional_digits = digits-number_digits
	for(var/i=0;i<additional_digits;i++)
		result += "0"
	result += "[number]"
	if(number<0)
		result = "-[result]"
	return result

/proc/get_random_colour(var/simple = FALSE, var/lower = 0, var/upper = 255)
	var/colour
	if(simple)
		colour = pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))
	else
		for(var/i=1;i<=3;i++)
			var/temp_col = "[num2hex(rand(lower,upper))]"
			if(length(temp_col )<2)
				temp_col  = "0[temp_col]"
			colour += temp_col
	return colour

/proc/get_random_potion()	//Pulls up a random potion, excluding minor-types
	return pick(subtypesof(/obj/item/potion) - /obj/item/potion/mutation)

//We check if a specific game mode is currently undergoing.
//First by checking if it is the current main mode,
//Secondly by checking if it is part of a Mixed game mode.
//If it exists, we return the game mode's datum. If it doesn't exist, we return null

/*
Game Mode config tags:
"extended"
"traitor"
"double_agents"
"autotraitor"
"blob"
"changeling"
"traitorchan"
"cult"
"heist"
"malfunction"
"meteor"
"mixed"
"nuclear"
"revolution"
"sandbox"
"vampire"
"wizard
"raginmages""
*/

/proc/find_active_faction_by_type(var/faction_type)
	if(!ticker || !ticker.mode)
		return null
	return locate(faction_type) in ticker.mode.factions

/proc/find_active_faction_by_member(var/datum/role/R, var/datum/mind/M)
	if(!R)
		return null
	var/found_faction = null
	if(R.GetFaction())
		return R.GetFaction()
	if(ticker && ticker.mode && ticker.mode.factions.len)
		var/success = FALSE
		for(var/datum/faction/F in ticker.mode.factions)
			for(var/datum/role/RR in F.members)
				if(RR == R || RR.antag == M)
					found_faction = F
					success = TRUE
					break
			if(success)
				break
	return found_faction

/proc/find_active_factions_by_member(var/datum/role/R, var/datum/mind/M)
	var/list/found_factions = list()
	for(var/datum/faction/F in ticker.mode.factions)
		for(var/datum/role/RR in F.members)
			if(RR == R || RR.antag == M)
				found_factions.Add(F)
				break
	return found_factions

/proc/find_active_faction_by_typeandmember(var/fac_type, var/datum/role/R, var/datum/mind/M)
	var/list/found_factions = find_active_factions_by_member(R, M)
	return locate(fac_type) in found_factions

/proc/find_unique_objectives(list/new_objectives, list/old_objectives)
	var/list/uniques = list()
	for (var/datum/objective/new_objective in new_objectives)
		var/is_unique = TRUE
		for (var/datum/objective/old_objective in old_objectives)
			if (old_objective.name == new_objective.name)
				is_unique = FALSE
		if (is_unique)
			uniques.Add(new_objective)
	return uniques


/proc/clients_in_moblist(var/list/mob/mobs)
	. = list()
	for(var/mob/M in mobs)
		if(M.client)
			. += M.client

/client/proc/output_to_special_tab(msg, force_focus = FALSE)
	if(prefs.special_popup)
		src << output("\[[time_stamp()]] [msg]", "window1.msay_output")
		if(!holder) //Force normal players to see the admin message when it gets sent to them
			winset(src, "rpane.special_button", "is-checked=true")
			winset(src, null, "rpanewindow.left=window1")
	if(prefs.special_popup == SPECIAL_POPUP_EXCLUSIVE)
		return
	to_chat(src, msg)

// A standard proc for generic output to the msay window, Not useful for things that have their own prefs settings (prayers for instance)
/proc/output_to_msay(msg)
	for(var/client/C in admins)
		C.output_to_special_tab(msg)

// This is awful and probably should be thrown away at some point.
/proc/generic_projectile_fire(var/atom/target, var/atom/source, var/obj/item/projectile/projectile, var/shot_sound, var/mob/firer)
	var/turf/T = get_turf(source)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	if(ispath(projectile))
		projectile = new projectile(T)
	else
		projectile.forceMove(T)
	var/fire_sound
	if(shot_sound)
		fire_sound = shot_sound
	else
		fire_sound = projectile.fire_sound

	projectile.original = target
	projectile.target = U
	projectile.shot_from = source
	projectile.firer = firer

	projectile.current = T
	projectile.starting = T
	projectile.yo = U.y - T.y
	projectile.xo = U.x - T.x
	playsound(T, fire_sound, 75, 1)
	spawn()
		projectile.OnFired()
		projectile.process()

/proc/stack_trace(message = "Getting a stack trace.")
	CRASH(message)

/proc/sentStrikeTeams(var/team)
	return (team in sent_strike_teams)

/proc/get_exact_dist(atom/A, atom/B)	//returns the coordinate distance between the coordinates of the turfs of A and B
	var/turf/T1 = A
	var/turf/T2 = B
	if(!istype(T1))
		T1 = get_turf(A)
	if(!istype(T2))
		T2 = get_turf(B)
	return sqrt(((T2.x - T1.x) ** 2) + ((T2.y - T1.y) ** 2))

//Same as block(Start, End), but only returns the border turfs
//'Start' must be lower-left, 'End' must be upper-right
/proc/block_borders(turf/Start, turf/End)
	ASSERT(istype(Start))
	ASSERT(istype(End))

	//i'm a lazy cunt and I don't feel like making this work
	ASSERT(Start.x < End.x && Start.y < End.y)

	return block(Start, End) - block(locate(Start.x + 1, Start.y + 1, Start.z), locate(End.x - 1, End.y - 1, End.z))


/proc/pick_rand_tele_turf(atom/hit_atom, var/inner_teleport_radius, var/outer_teleport_radius)
	if((inner_teleport_radius < 1) || (outer_teleport_radius < inner_teleport_radius))
		return 0

	var/list/turfs = new/list()
	var/turf/hit_turf = get_turf(hit_atom)
	//This could likely use some standardization but I have no idea how to not break it.
	for(var/turf/T in trange(outer_teleport_radius, hit_turf))
		if(get_dist(T, hit_atom) <= inner_teleport_radius)
			continue
		if(is_blocked_turf(T) || istype(T, /turf/space))
			continue
		if(T.x > world.maxx-outer_teleport_radius || T.x < outer_teleport_radius)
			continue
		if(T.y > world.maxy-outer_teleport_radius || T.y < outer_teleport_radius)
			continue
		turfs += T
	return pick(turfs)

/proc/get_key(mob/M)
	if(M.mind)
		return M.mind.key
	else
		return null

/proc/IsRoundAboutToEnd()
	//Is the round even already over?
	if (ticker.current_state == GAME_STATE_FINISHED)
		return TRUE

	//Is the shuttle on its way to the station? or to centcomm after having departed from the station?
	if(emergency_shuttle.online && emergency_shuttle.direction > 0)
		return TRUE

	//Is a nuke currently ticking down?
	for (var/obj/machinery/nuclearbomb/the_bomba in nuclear_bombs)
		if (the_bomba.timing)
			return TRUE

	//Is reality fucked?
	if (universe.name in list("Hell Rising", "Supermatter Cascade"))
		return TRUE

	//Is some faction about to end the round?
	var/datum/gamemode/dynamic/dynamic_mode = ticker.mode
	if (istype(dynamic_mode))
		for (var/datum/faction/faction in dynamic_mode.factions)
			if (faction.stage >= FACTION_ENDGAME)
				return TRUE

	//All is well
	return FALSE

//Ported from TG
/proc/window_flash(client/C, ignorepref = FALSE)
    if(ismob(C))
        var/mob/M = C
        if(M.client)
            C = M.client
    if(!istype(C) || (!C.prefs.window_flashing && !ignorepref))
        return
    winset(C, "mainwindow", "flash=5")


/proc/generate_radio_frequencies()
	//1200-1600
	var/list/taken_freqs = list()

	for(var/i in freq_text)
		var/freq_found = FALSE
		while(freq_found != TRUE)
			var/chosen_freq = rand(1201, 1599)
			chosen_freq = sanitize_frequency(chosen_freq)
			if(taken_freqs.Find(chosen_freq))
				continue
			taken_freqs.Add(chosen_freq)
			freqs[i] = chosen_freq
			freq_found = TRUE

	freqtospan = list(
		"[COMMON_FREQ]" = "commonradio",
		"[SCI_FREQ]" = "sciradio",
		"[MED_FREQ]" = "medradio",
		"[ENG_FREQ]" = "engradio",
		"[SUP_FREQ]" = "supradio",
		"[SER_FREQ]" = "serradio",
		"[SEC_FREQ]" = "secradio",
		"[COMM_FREQ]" = "comradio",
		"[AIPRIV_FREQ]" = "aiprivradio",
		"[SYND_FREQ]" = "syndradio",
		"[DSQUAD_FREQ]" = "dsquadradio",
		"[RESPONSE_FREQ]" = "resteamradio",
		"[RAID_FREQ]" = "raiderradio",
		"[BUG_FREQ]" = "bugradio"
	)

	radiochannelsreverse = list(
		"[DJ_FREQ]" = "DJ",
		"[SYND_FREQ]" = "Syndicate",
		"[BUG_FREQ]" = "Radio Bug",
		"[RAID_FREQ]" = "Raider",
		"[RESPONSE_FREQ]" = "Response Team",
		"[SUP_FREQ]" = "Supply",
		"[SER_FREQ]" = "Service",
		"[SCI_FREQ]" = "Science",
		"[MED_FREQ]" = "Medical",
		"[COMM_FREQ]" = "Command",
		"[ENG_FREQ]" = "Engineering",
		"[SEC_FREQ]" = "Security",
		"[DSQUAD_FREQ]" = "Deathsquad",
		"[AIPRIV_FREQ]" = "AI Private",
		"[COMMON_FREQ]" = "Common"
	)

	radiochannels = list(
		"Common" = COMMON_FREQ,
		"AI Private" = AIPRIV_FREQ,
		"Deathsquad" = DSQUAD_FREQ,
		"Security" = SEC_FREQ,
		"Engineering" = ENG_FREQ,
		"Command" = COMM_FREQ,
		"Medical" = MED_FREQ,
		"Science" = SCI_FREQ,
		"Service" = SER_FREQ,
		"Supply" = SUP_FREQ,
		"Response Team" = RESPONSE_FREQ,
		"Raider" = RAID_FREQ,
		"Syndicate" = SYND_FREQ,
		"DJ" = DJ_FREQ,
		"Radio Bug" = BUG_FREQ
	)

	stationchannels = list(
	"Common" = COMMON_FREQ,
	"Security" = SEC_FREQ,
	"Engineering" = ENG_FREQ,
	"Command" = COMM_FREQ,
	"Medical" = MED_FREQ,
	"Science" = SCI_FREQ,
	"Service" = SER_FREQ,
	"Supply" = SUP_FREQ
	)

/proc/update_radio_frequency(var/name, var/freq, var/color, var/mob/user, var/update_station = TRUE)
	var/newspan = null
	if(name in freqs)
		newspan = freqtospan["[freqs[name]]"]
	freqs[name] = freq
	radiochannels[name] = freqs[name]
	radiochannelsreverse["[freqs[name]]"] = name
	if(color)
		freqtocolor["[freqs[name]]"] = color
	if(newspan)
		freqtospan["[freqs[name]]"] = newspan
	if(update_station)
		stationchannels[name] = freqs[name]
	log_admin("[update_station ? "World" : "Non-station"] radio frequency [name] is now [freqs[name]][user ? " set by [key_name(user)]": ""]")
	message_admins("[update_station ? "World" : "Non-station"] radio frequency [color ? "<font color=[freqtocolor["[freqs[name]]"]]>" : ""][name][color ? "</font color>" : ""] is now [freqs[name]][user ? " set by [key_name(user)] ([formatJumpTo(user, "JMP")])" : ""]")

/proc/getviewsize(view)
	if(isnum(view))
		var/totalviewrange = (view < 0 ? -1 : 1) + 2 * view
		return list(totalviewrange, totalviewrange)
	else
		var/list/viewrangelist = splittext(view,"x")
		return list(text2num(viewrangelist[1]), text2num(viewrangelist[2]))

/**
 * Get a bounding box of a list of atoms.
 *
 * Arguments:
 * - atoms - List of atoms. Can accept output of view() and range() procs.
 *
 * Returns: list(x1, y1, x2, y2)
 */
/proc/get_bbox_of_atoms(list/atoms)
	var/list/list_x = list()
	var/list/list_y = list()
	for(var/_a in atoms)
		var/atom/a = _a
		list_x += a.x
		list_y += a.y
	return list(
		min(list_x),
		min(list_y),
		max(list_x),
		max(list_y))

/proc/spiral_block(turf/epicenter, range, draw_red=FALSE)
	if(!epicenter)
		return list()

	if(!range)
		return list(epicenter)

	. = list()

	var/turf/T
	var/y
	var/x
	var/c_dist = 1
	. += epicenter

	while( c_dist <= range )
		y = epicenter.y + c_dist
		x = epicenter.x - c_dist + 1
		//bottom
		for(x in x to epicenter.x+c_dist)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y + c_dist - 1
		x = epicenter.x + c_dist
		for(y in y to epicenter.y-c_dist step -1)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y - c_dist
		x = epicenter.x + c_dist - 1
		for(x in  x to epicenter.x-c_dist step -1)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)

		y = epicenter.y - c_dist + 1
		x = epicenter.x - c_dist
		for(y in y to epicenter.y+c_dist)
			T = locate(x,y,epicenter.z)
			if(T)
				. += T
				if(draw_red)
					T.color = "red"
					sleep(5)
		c_dist++

	if(draw_red)
		sleep(30)
		for(var/turf/Q in .)
			Q.color = null

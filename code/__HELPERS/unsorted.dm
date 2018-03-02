//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/*
 * A large number of misc global procs.
 */

/proc/SAFE_CRASH(var/msg)
	CRASH(msg)

//Returns location. Returns null if no location was found.
/proc/get_teleport_loc(turf/location,mob/target,distance = 1, density = 0, errorx = 0, errory = 0, eoffsetx = 0, eoffsety = 0)
/*
Location where the teleport begins, target that will teleport, distance to go, density checking 0/1(yes/no).
Random error in tile placement x, error in tile placement y, and block offset.
Block offset tells the proc how to place the box. Behind teleport location, relative to starting location, forward, etc.
Negative values for offset are accepted, think of it in relation to North, -x is west, -y is south. Error defaults to positive.
Turf and target are seperate in case you want to teleport some distance from a turf the target is not standing on or something.
*/

	var/dirx = 0//Generic location finding variable.
	var/diry = 0

	var/xoffset = 0//Generic counter for offset location.
	var/yoffset = 0

	var/b1xerror = 0//Generic placing for point A in box. The lower left.
	var/b1yerror = 0
	var/b2xerror = 0//Generic placing for point B in box. The upper right.
	var/b2yerror = 0

	errorx = abs(errorx)//Error should never be negative.
	errory = abs(errory)
	//var/errorxy = round((errorx+errory)/2)//Used for diagonal boxes.

	switch(target.dir)//This can be done through equations but switch is the simpler method. And works fast to boot.
	//Directs on what values need modifying.
		if(1)//North
			diry+=distance
			yoffset+=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(2)//South
			diry-=distance
			yoffset-=eoffsety
			xoffset+=eoffsetx
			b1xerror-=errorx
			b1yerror-=errory
			b2xerror+=errorx
			b2yerror+=errory
		if(4)//East
			dirx+=distance
			yoffset+=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx
		if(8)//West
			dirx-=distance
			yoffset-=eoffsetx//Flipped.
			xoffset+=eoffsety
			b1xerror-=errory//Flipped.
			b1yerror-=errorx
			b2xerror+=errory
			b2yerror+=errorx

	var/turf/destination=locate(location.x+dirx,location.y+diry,location.z)

	if(destination)//If there is a destination.
		if(errorx||errory)//If errorx or y were specified.
			var/destination_list[] = list()//To add turfs to list.
			//destination_list = new()
			/*This will draw a block around the target turf, given what the error is.
			Specifying the values above will basically draw a different sort of block.
			If the values are the same, it will be a square. If they are different, it will be a rectengle.
			In either case, it will center based on offset. Offset is position from center.
			Offset always calculates in relation to direction faced. In other words, depending on the direction of the teleport,
			the offset should remain positioned in relation to destination.*/

			var/turf/center = locate((destination.x+xoffset),(destination.y+yoffset),location.z)//So now, find the new center.

			//Now to find a box from center location and make that our destination.
			for(var/turf/T in block(locate(center.x+b1xerror,center.y+b1yerror,location.z), locate(center.x+b2xerror,center.y+b2yerror,location.z) ))
				if(density&&T.density)
					continue//If density was specified.
				if(T.x>world.maxx || T.x<1)
					continue//Don't want them to teleport off the map.
				if(T.y>world.maxy || T.y<1)
					continue
				destination_list += T
			if(destination_list.len)
				destination = pick(destination_list)
			else
				return

		else//Same deal here.
			if(density&&destination.density)
				return
			if(destination.x>world.maxx || destination.x<1)
				return
			if(destination.y>world.maxy || destination.y<1)
				return
	else
		return

	return destination

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

//Ensure the frequency is within bounds of what it should be sending/recieving at
/proc/sanitize_frequency(var/f)
	f = Clamp(round(f), 1201, 1599) // 120.1, 159.9

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

	if (dna)
		dna.real_name = real_name

	if (oldname)
		/*
		 * Update the datacore records!
		 * This is going to be a bit costly.
		 */
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

		for (var/datum/mind/themind in ticker.minds)
			if (themind)
				var/found = 0
				for (var/datum/objective/objective in themind.objectives)
					if (objective && objective.target == mind)
						found = 1
						objective.explanation_text = replacetext(objective.explanation_text, oldname, newname)
						themind.memory = replacetext(themind.memory, oldname, newname)
				if(themind.current && found)
					var/obj_count = 1
					to_chat(themind.current, "<span class='danger'>Objectives Updated</span>")
					to_chat(themind.current, "<span class='notice'>Your current objectives:</span>")
					for(var/datum/objective/objective in themind.objectives)
						to_chat(themind.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
						obj_count++
	return 1

//Generalised helper proc for letting mobs rename themselves. Used to be clname() and ainame()
//Last modified by Carn
/mob/proc/rename_self(var/role, var/allow_numbers=0)
	spawn(0)
		var/oldname = real_name

		var/time_passed = world.time
		var/newname

		for(var/i=1,i<=3,i++)	//we get 3 attempts to pick a suitable name.
			newname = input(src,"You are a [role]. Would you like to change your name to something else?", "Name change",oldname) as text
			if((world.time-time_passed)>300)
				return	//took too long
			newname = reject_bad_name(newname,allow_numbers)	//returns null if the name doesn't meet some basic requirements. Tidies up a few other things like bad-characters.

			for(var/mob/living/M in player_list)
				if(M == src)
					continue
				if(!newname || M.real_name == newname)
					newname = null
					break
			if(newname)
				break	//That's a suitable name!
			to_chat(src, "Sorry, that [role]-name wasn't appropriate, please try another. It's possibly too long/short, has bad characters or is already taken.")

		if(!newname)	//we'll stick with the oldname then
			return

		if(cmptext("ai",role))
			if(isAI(src))
				var/mob/living/silicon/ai/A = src
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

/proc/get_sorted_mobs()
	var/list/old_list = getmobs()
	var/list/AI_list = list()
	var/list/Dead_list = list()
	var/list/keyclient_list = list()
	var/list/key_list = list()
	var/list/logged_list = list()
	for(var/named in old_list)
		var/mob/M = old_list[named]
		if(issilicon(M))
			AI_list |= M
		else if(isobserver(M) || M.stat == 2)
			Dead_list |= M
		else if(M.key && M.client)
			keyclient_list |= M
		else if(M.key)
			key_list |= M
		else
			logged_list |= M
		old_list.Remove(named)
	var/list/new_list = list()
	new_list += AI_list
	new_list += keyclient_list
	new_list += key_list
	new_list += logged_list
	new_list += Dead_list
	return new_list

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
	var/list/moblist = list()
	var/list/sortmob = sortNames(mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/camera/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/pai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/silicon/robot/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/alien/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/slime/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
//	for(var/mob/living/silicon/hivebot/M in world)
//		mob_list.Add(M)
//	for(var/mob/living/silicon/hive_mainframe/M in world)
//		mob_list.Add(M)
	return moblist

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

// Finds ALL mobs in range, including those within something's contents (e.g. inside a locker or such)
/proc/get_all_mobs_in_range(var/turf/T, var/range = world.view, var/list/ignore_types = list())
	. = list()
	for(var/mob/M in mob_list)
		if(is_type_in_list(M, ignore_types))
			continue
		var/turf/mob_turf = get_turf(M)
		if(!mob_turf || mob_turf.z != T.z) //because get_dist doesn't account for z levels
			continue
		if(get_dist(T, mob_turf) <= range) //here we are checking the distance on the mob's turf and not the mob itself, since mobs in a locker or such will have XYZ = 0,0,0
			. += M

//E = MC^2
/proc/convert2energy(var/M)
	var/E = M*(SPEED_OF_LIGHT_SQ)
	return E

//M = E/C^2
/proc/convert2mass(var/E)
	var/M = E/(SPEED_OF_LIGHT_SQ)
	return M

/proc/key_name(var/whom, var/include_link = null, var/include_name = TRUE, var/more_info = FALSE)
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
	if(!user.client)
		return
	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	winset(user, windowid, "on-close=\".windowclose [param]\"")

//	to_chat(world, "OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]")


// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(var/atomref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

//	to_chat(world, "windowclose: [atomref]")
	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		var/href = "close=1"
		if(hsrc)
//			to_chat(world, "[src] Topic [href] [hsrc]")
			usr = src.mob
			src.Topic(href, params2list(href), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src && src.mob)
//		to_chat(world, "[src] was [src.mob.machine], setting to null")
		src.mob.unset_machine()
	return

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(var/atom/A, var/direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return 0
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
	var/x = Clamp(A.x + dx, 1, world.maxx)
	var/y = Clamp(A.y + dy, 1, world.maxy)

	return locate(x, y, A.z)

//returns random gauss number
proc/GaussRand(var/sigma)
  var/x,y,rsq
  do
    x=2*rand()-1
    y=2*rand()-1
    rsq=x*x+y*y
  while(rsq>1 || !rsq)
  return sigma*y*sqrt(-2*log(rsq)/rsq)

//returns random gauss number, rounded to 'roundto'
proc/GaussRandRound(var/sigma,var/roundto)
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

/proc/is_blocked_turf(var/turf/T)
	var/cant_pass = 0
	if(T.density)
		cant_pass = 1
	for(var/atom/A in T)
		if(A.density)//&&A.anchored
			cant_pass = 1
	return cant_pass

/proc/get_step_towards2(var/atom/ref , var/atom/trg)
	var/base_dir = get_dir(ref, get_step_towards(ref,trg))
	var/turf/temp = get_step_towards(ref,trg)

	if(is_blocked_turf(temp))
		var/dir_alt1 = turn(base_dir, 90)
		var/dir_alt2 = turn(base_dir, -90)
		var/turf/turf_last1 = temp
		var/turf/turf_last2 = temp
		var/free_tile = null
		var/breakpoint = 0

		while(!free_tile && breakpoint < 10)
			if(!is_blocked_turf(turf_last1))
				free_tile = turf_last1
				break
			if(!is_blocked_turf(turf_last2))
				free_tile = turf_last2
				break
			turf_last1 = get_step(turf_last1,dir_alt1)
			turf_last2 = get_step(turf_last2,dir_alt2)
			breakpoint++

		if(!free_tile)
			return get_step(ref, base_dir)
		else
			return get_step_towards(ref,free_tile)

	else
		return get_step(ref, base_dir)

/proc/do_mob(var/mob/user , var/mob/target, var/delay = 30, var/numticks = 10) //This is quite an ugly solution but i refuse to use the old request system.
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
		if ( user.loc != user_loc || target.loc != target_loc || user.get_active_hand() != holding || user.isStunned())
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

// Creates a progress bar locked on `target` and returns it
/proc/create_progress_bar_on(var/atom/target)
	var/image/progress_bar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
	progress_bar.pixel_z = WORLD_ICON_SIZE
	progress_bar.plane = HUD_PLANE
	progress_bar.layer = HUD_ABOVE_ITEM_LAYER
	progress_bar.appearance_flags = RESET_COLOR
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
		if(needhand && !user.do_after_hand_check(holding))
			for(var/target_ in targets)
				var/image/target_progress_bar = targets[target_]
				stop_progress_bar(user, target_progress_bar)
			return FALSE
	for(var/target in targets)
		var/image/target_progress_bar = targets[target]
		remove_progress_bar(user, target_progress_bar)

	return TRUE

/proc/do_after(var/mob/user as mob, var/atom/target, var/delay as num, var/numticks = 10, var/needhand = TRUE, var/use_user_turf = FALSE)
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
			progbar.appearance_flags = RESET_COLOR
		//if(!barbar)
			//barbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "none")
			//barbar.pixel_y = 36
	//var/oldstate
	for (var/i = 1 to numticks)
		if(user && user.client && user.client.prefs.progress_bars && target)
			if(!progbar)
				progbar = image("icon" = 'icons/effects/doafter_icon.dmi', "loc" = target, "icon_state" = "prog_bar_0")
				progbar.pixel_z = WORLD_ICON_SIZE
				progbar.plane = HUD_PLANE
				progbar.layer = HUD_ABOVE_ITEM_LAYER
				progbar.appearance_flags = RESET_COLOR
			//oldstate = progbar.icon_state
			progbar.icon_state = "prog_bar_[round(((i / numticks) * 100), 10)]"
			user.client.images |= progbar
		sleep(delayfraction)
		//if(user.client && progbar.icon_state != oldstate)
			//user.client.images.Remove(progbar)
		var/user_loc_to_check
		if(use_user_turf)
			user_loc_to_check = get_turf(user)
		else
			user_loc_to_check = user.loc
		if(!user || user.isStunned() || !(user_loc_to_check == Location) || !(target.loc == target_location))
			if(progbar)
				progbar.icon_state = "prog_bar_stopped"
				spawn(2)
					if(user && user.client)
						user.client.images -= progbar
					if(progbar)
						progbar.loc = null
			return 0
		if(needhand && !user.do_after_hand_check(holding))	//Sometimes you don't want the user to have to keep their active hand
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

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: 1 if found, 0 if not.
/proc/hasvar(var/datum/A, var/varname)
	if(A.vars.Find(lowertext(varname)))
		return 1
	else
		return 0

//Returns sortedAreas list if populated
//else populates the list first before returning it
/proc/SortAreas()
	for(var/area/A in areas)
		sortedAreas.Add(A)

	sortTim(sortedAreas, /proc/cmp_name_asc)

/area/proc/addSorted()
	sortedAreas.Add(src)
	sortTim(sortedAreas, /proc/cmp_name_asc)

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

//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all atoms	(objs, turfs, mobs) in areas of that type of that type in the world.
/proc/get_area_all_atoms(var/areatype)
	if(!areatype)
		return null
	if(istext(areatype))
		areatype = text2path(areatype)
	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/atoms = new/list()
	for(var/area/N in areas)
		if(istype(N, areatype))
			for(var/atom/A in N)
				atoms += A
	return atoms

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

proc/DuplicateObject(obj/original, var/perfectcopy = 0 , var/sameloc = 0)
	if(!original)
		return null

	var/obj/O = null

	if(sameloc)
		O=new original.type(original.loc)
	else
		O=new original.type(locate(0,0,0))

	if(perfectcopy)
		if((O) && (original))
			for(var/V in original.vars)
				if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","group")))
					O.vars[V] = original.vars[V]
	return O


/area/proc/copy_contents_to(var/area/A , var/platingRequired = 0 )
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

	var/list/toupdate = new/list()

	var/list/copiedobjs = list()

	moving:
		for (var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(istype(B, /turf/space))
							continue moving

					var/turf/X = B.ChangeTurf(T.type)
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					var/list/objs = new/list()
					var/list/newobjs = new/list()
					var/list/mobs = new/list()
					var/list/newmobs = new/list()

					for(var/obj/O in T)

						if(!istype(O,/obj))
							continue

						objs += O


					for(var/obj/O in objs)
						newobjs += DuplicateObject(O , 1)


					for(var/obj/O in newobjs)
						O.forceMove(X)

					for(var/mob/M in T)

						if(!M.can_shuttle_move())
							continue
						mobs += M

					for(var/mob/M in mobs)
						newmobs += DuplicateObject(M , 1)

					for(var/mob/M in newmobs)
						M.forceMove(X)

					copiedobjs += newobjs
					copiedobjs += newmobs



					for(var/V in T.vars)
						if(!(V in list("type","loc","locs","vars", "parent", "parent_type","verbs","ckey","key","x","y","z","contents", "luminosity")))
							X.vars[V] = T.vars[V]

//					var/area/AR = X.loc

//					if(AR.dynamic_lighting)
//						X.opacity = !X.opacity
//						X.sd_SetOpacity(!X.opacity)			//TODO: rewrite this code so it's not messed by lighting ~Carn

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving




	var/list/doors = new/list()

	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			for(var/obj/machinery/door/D2 in T1)
				doors += D2
			/*if(T1.parent)
				SSair.groups_to_rebuild += T1.parent
			else
				SSair.mark_for_update(T1)*/

	for(var/obj/O in doors)
		O:update_nearby_tiles()

	return copiedobjs

//chances are 1:value. anyprob(1) will always return true
proc/anyprob(value)
	return (rand(1,value)==value)

proc/view_or_range(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = view(distance,center)
		if("range")
			. = range(distance,center)
	return

proc/oview_or_orange(distance = world.view , center = usr , type)
	switch(type)
		if("view")
			. = oview(distance,center)
		if("range")
			. = orange(distance,center)
	return

proc/get_mob_with_client_list()
	var/list/mobs = list()
	for(var/mob/M in mob_list)
		if (M.client)
			mobs += M
	return mobs


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

//Quick type checks for some tools
var/global/list/common_tools = list(
/obj/item/stack/cable_coil,
/obj/item/weapon/wrench,
/obj/item/weapon/weldingtool,
/obj/item/weapon/screwdriver,
/obj/item/weapon/wirecutters,
/obj/item/device/multitool,
/obj/item/weapon/crowbar)

/proc/is_surgery_tool(obj/item/W as obj)
	return (	\
	istype(W, /obj/item/weapon/scalpel)			||	\
	istype(W, /obj/item/weapon/hemostat)		||	\
	istype(W, /obj/item/weapon/retractor)		||	\
	istype(W, /obj/item/weapon/cautery)			||	\
	istype(W, /obj/item/weapon/bonegel)			||	\
	istype(W, /obj/item/weapon/bonesetter)
	)

//check if mob is lying down on something we can operate him on.
/proc/can_operate(mob/living/carbon/M, mob/U)
	if(U == M)
		return 0
	if(ishuman(M) && M.lying)
		if(locate(/obj/machinery/optable,M.loc) || locate(/obj/structure/bed/roller/surgery, M.loc))
			return 1
		if(locate(/obj/structure/bed/roller, M.loc) && prob(75))
			return 1
		var/obj/structure/table/T = locate(/obj/structure/table/, M.loc)
		if(T && !T.flipped && prob(66))
			return 1
	return 0

/*
Checks if that loc and dir has a item on the wall
*/
var/list/WALLITEMS = list(
	"/obj/machinery/power/apc", "/obj/machinery/alarm", "/obj/item/device/radio/intercom",
	"/obj/structure/extinguisher_cabinet", "/obj/structure/reagent_dispensers/peppertank",
	"/obj/machinery/status_display", "/obj/machinery/requests_console", "/obj/machinery/light_switch", "/obj/effect/sign",
	"/obj/machinery/newscaster", "/obj/machinery/firealarm", "/obj/structure/noticeboard", "/obj/machinery/door_control",
	"/obj/machinery/computer/security/telescreen", "/obj/machinery/embedded_controller/radio/simple_vent_controller",
	"/obj/item/weapon/storage/secure/safe", "/obj/machinery/door_timer", "/obj/machinery/flasher", "/obj/machinery/keycard_auth",
	"/obj/structure/mirror", "/obj/structure/closet/fireaxecabinet", "obj/structure/sign", "obj/structure/painting"
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

proc/rotate_icon(file, state, step = 1, aa = FALSE)
	var icon/base = icon(file, state)

	var w, h, w2, h2

	if(aa)
		aa ++
		w = base.Width()
		w2 = w * aa
		h = base.Height()
		h2 = h * aa

	var icon{result = icon(base); temp}

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

/proc/print_runtime(exception/e)
	world.log << "[time_stamp()] Runtime detected\n[e] at [e.file]:[e.line]\n [e.desc]"

/proc/transfer_fingerprints(atom/A,atom/B)//synchronizes the fingerprints between two atoms. Useful when you have two different atoms actually being different states of a same object.
	if(!A || !B)
		return
	B.fingerprints = A.fingerprints
	B.fingerprintshidden = A.fingerprintshidden
	B.fingerprintslast = A.fingerprintslast

//Checks if any of the atoms in the turf are dense
//Returns 1 is anything is dense, 0 otherwise
/turf/proc/has_dense_content()
	for(var/atom/turf_contents in contents)
		if(turf_contents.density)
			return 1
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

/proc/spiral_block(var/turf/epicenter,var/max_range,var/inward=0,var/draw_red=0)//alternative to block. instead of being listed from bottom to top, turfs are listed spiraling inward/outward.
	var/list/spiraled_turfs = list()

	//epicenter coordinates
	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	//world limits
	var/south_limit = 1 - y0
	var/west_limit = 1 - x0
	var/north_limit = world.maxy - y0
	var/east_limit = world.maxx - x0

	var/max_steps = (max_range*2 + 1) * (max_range*2 + 1)

	var/pointer_x = 0
	var/pointer_y = 0
	var/segment = 0
	var/movement_dir = NORTH
	var/segment_length = 1

	if(inward)
		pointer_x = -max_range
		pointer_y = -max_range
		segment_length = max_range*2+1
		segment = 1

		for(var/sstep=max_steps-1;sstep>=0;sstep--)
			if((pointer_x >= west_limit) && (pointer_x <= east_limit) && (pointer_y >= south_limit) && (pointer_y <= north_limit))//are we inside the map's boundaries
				var/turf/T = locate(x0+pointer_x,y0+pointer_y,z0)
				spiraled_turfs += T
				if(draw_red)
					T.color = "red"
			if(sstep && ((sstep%segment_length) == 0))
				switch(movement_dir)//clockwise spiral
					if(NORTH)
						movement_dir = EAST
					if(EAST)
						movement_dir = SOUTH
					if(SOUTH)
						movement_dir = WEST
					if(WEST)
						movement_dir = NORTH
				if(!segment)
					segment = 1
				else
					segment = 0
					segment_length--

			switch(movement_dir)
				if(NORTH)
					pointer_y++
				if(EAST)
					pointer_x++
				if(SOUTH)
					pointer_y--
				if(WEST)
					pointer_x--
			if(draw_red)
				sleep(1)
	else
		for(var/sstep in 1 to max_steps)
			if((pointer_x >= west_limit) && (pointer_x <= east_limit) && (pointer_y >= south_limit) && (pointer_y <= north_limit))//are we inside the map's boundaries
				var/turf/T = locate(x0+pointer_x,y0+pointer_y,z0)
				spiraled_turfs += T
				if(draw_red)
					T.color = "red"

			switch(movement_dir)
				if(NORTH)
					pointer_y++
				if(EAST)
					pointer_x++
				if(SOUTH)
					pointer_y--
				if(WEST)
					pointer_x--

			if((sstep%segment_length) == 0)
				switch(movement_dir)//clockwise spiral
					if(NORTH)
						movement_dir = EAST
					if(EAST)
						movement_dir = SOUTH
					if(SOUTH)
						movement_dir = WEST
					if(WEST)
						movement_dir = NORTH
				if(!segment)
					segment = 1
				else
					segment = 0
					segment_length++
			if(draw_red)
				sleep(1)

	if(draw_red)
		sleep(30)
		for(var/turf/T in spiraled_turfs)
			T.color = null

	return spiraled_turfs

/proc/get_random_colour(var/simple, var/lower, var/upper)
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

/proc/find_active_mode(var/mode_ctag)
	var/found_mode = null
	if(ticker && ticker.mode)
		if(ticker.mode.config_tag == mode_ctag)
			found_mode = ticker.mode
		else if(ticker.mode.name == "mixed")
			var/datum/game_mode/mixed/mixed_mode = ticker.mode
			for(var/datum/game_mode/GM in mixed_mode.modes)
				if(GM.config_tag == mode_ctag)
					found_mode = GM
					break
	return found_mode

/proc/clients_in_moblist(var/list/mob/mobs)
	. = list()
	for(var/mob/M in mobs)
		if(M.client)
			. += M.client


// A standard proc for generic output to the msay window, Not useful for things that have their own prefs settings (prayers for instance)
/proc/output_to_msay(msg)
	var/sane_msg = strict_ascii(msg)
	for(var/client/C in admins)
		if(C.prefs.special_popup)
			C << output("\[[time_stamp()]] [sane_msg]", "window1.msay_output")
		else
			to_chat(C, msg)

/proc/generic_projectile_fire(var/atom/target, var/atom/source, var/obj/item/projectile/projectile, var/shot_sound)
	var/turf/T = get_turf(source)
	var/turf/U = get_turf(target)
	if (!T || !U)
		return
	var/obj/item/projectile/A
	A = new projectile(T)
	var/fire_sound
	if(shot_sound)
		fire_sound = shot_sound
	else
		fire_sound = A.fire_sound

	A.original = target
	A.target = U
	A.shot_from = source
	if(istype(source, /mob))
		A.firer = source
	A.current = T
	A.starting = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	playsound(T, fire_sound, 50, 1)
	A.OnFired()
	spawn()
		A.process()


//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(world.tick_usage, world.cpu) / 100) * max(Master.sleep_delta,1)), 1)

/proc/stoplag()
	. = 0
	var/i = 1
	do
		. += round(i*DELTA_CALC)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (world.tick_usage > min(TICK_LIMIT_TO_RUN, CURRENT_TICKLIMIT))

#undef DELTA_CALC


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

/proc/seedify(obj/item/O, obj/machinery/seed_extractor/extractor = null, mob/living/user = null)
	if(!O)
		CRASH("Something called seedify() without anything to make seeds of.")

	var/min_seeds = 1
	var/max_seeds = 2
	var/seedloc = O.loc
	var/datum/seed/new_seed_type

	if(extractor)
		seedloc = get_turf(extractor)
		min_seeds = extractor.min_seeds
		max_seeds = extractor.max_seeds

	var/produce = rand(min_seeds,max_seeds)

	if(user)
		user.drop_item(O, force_drop = TRUE)

	if(istype(O, /obj/item/weapon/grown))
		var/obj/item/weapon/grown/F = O
		if(F.plantname)
			new_seed_type = plant_controller.seeds[F.plantname]
	else
		if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/F = O
			if(F.plantname)
				new_seed_type = plant_controller.seeds[F.plantname]
		else
			var/obj/item/F = O
			if(F.nonplant_seed_type)
				while(min_seeds <= produce)
					new F.nonplant_seed_type(seedloc)
					min_seeds++
				qdel(F)
				return TRUE

	if(new_seed_type)
		while(min_seeds <= produce)
			var/obj/item/seeds/seeds = new(seedloc)
			seeds.seed_type = new_seed_type.name
			seeds.update_seed()
			min_seeds++
	else
		return FALSE

	qdel(O)
	return TRUE

//Same as block(Start, End), but only returns the border turfs
//'Start' must be lower-left, 'End' must be upper-right
/proc/block_borders(turf/Start, turf/End)
	ASSERT(istype(Start))
	ASSERT(istype(End))

	//i'm a lazy cunt and I don't feel like making this work
	ASSERT(Start.x < End.x && Start.y < End.y)

	return block(Start, End) - block(locate(Start.x + 1, Start.y + 1, Start.z), locate(End.x - 1, End.y - 1, End.z))

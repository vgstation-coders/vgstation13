/proc/dopage(src,target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_area(const/atom/O)
	RETURN_TYPE(/area)
	if(isarea(O))
		return O
	var/turf/T = get_turf(O)
	if(T)
		return T.loc

/proc/get_area_by_name(N) //get area by its name
	for(var/area/A in areas)
		if(A.name == N)
			return A
	return 0

/proc/get_area_name(atom/X, format_text = FALSE)
	var/area/A = isarea(X) ? X : get_area(X)
	if(!A)
		return null
	return format_text ? format_text(A.name) : A.name

/proc/in_range(atom/source, mob/user)
	if(source.Adjacent(user))
		return 1
	else if(istype(user) && user.mutations && user.mutations.len)
		if((M_TK in user.mutations) && (get_dist(user,source) < tk_maxrange))
			return 1

	return 0 //not in range and not telekinetic

// Like view but bypasses luminosity check
/proc/get_hear(var/range, var/atom/source)


	var/lum = source.luminosity
	source.luminosity = 6

	var/list/heard = view(range, source)
	source.luminosity = lum

	return heard


/proc/alone_in_area(var/area/the_area, var/mob/must_be_alone, var/check_type = /mob/living/carbon)
	var/area/our_area = get_area(the_area)
	for(var/C in living_mob_list)
		if(!istype(C, check_type))
			continue
		if(C == must_be_alone)
			continue
		if(our_area == get_area(C))
			return 0
	return 1

/proc/circlerange(center=usr,radius=3)


	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)


	var/turf/centerturf = get_turf(center)
	var/list/atoms = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/A in view(radius, centerturf))
		var/dx = A.x - centerturf.x
		var/dy = A.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			atoms += A

	//turfs += centerturf
	return atoms

/proc/get_dist_euclidian(atom/Loc1 as turf|mob|obj,atom/Loc2 as turf|mob|obj)
	var/dx = Loc1.x - Loc2.x
	var/dy = Loc1.y - Loc2.y

	var/dist = sqrt(dx**2 + dy**2)

	return dist

/proc/circlerangeturfs(center=usr,radius=3)


	var/turf/centerturf = get_turf(center)
	if(!centerturf)
		to_chat(usr, "cant get a center turf?")
		return
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in range(radius, centerturf))
		if(!T)
			continue
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/circleviewturfs(center=usr,radius=3)		//Is there even a diffrence between this proc and circlerangeturfs()?


	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/turf/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T
	return turfs

/proc/recursive_type_check(atom/O, type = /atom)
	var/list/processing_list = list(O)
	var/list/processed_list = new/list()
	var/found_atoms = new/list()

	while (processing_list.len)
		var/atom/A = processing_list[1]

		if (istype(A, type))
			found_atoms |= A

		for (var/atom/B in A)
			if (!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_atoms

//var/debug_mob = 0

/proc/get_contents_in_object(atom/O, type_path = /atom/movable)
	if (O)
		return recursive_type_check(O, type_path) - O
	else
		return new/list()

#define SIGN(X) ((X<0)?-1:1)

proc/inLineOfSight(X1,Y1,X2,Y2,Z=1,PX1=16.5,PY1=16.5,PX2=16.5,PY2=16.5)
	var/turf/T
	if(X1==X2)
		if(Y1==Y2)
			return 1 //Light cannot be blocked on same tile
		else
			var/s = SIGN(Y2-Y1)
			Y1+=s
			while(Y1!=Y2)
				T=locate(X1,Y1,Z)
				if(T.opacity)
					return 0
				Y1+=s
	else
		var/m=(32*(Y2-Y1)+(PY2-PY1))/(32*(X2-X1)+(PX2-PX1))
		var/b=(Y1+PY1/32-0.015625)-m*(X1+PX1/32-0.015625) //In tiles
		var/signX = SIGN(X2-X1)
		var/signY = SIGN(Y2-Y1)
		if(X1<X2)
			b+=m
		while(X1!=X2 || Y1!=Y2)
			if(round(m*X1+b-Y1))
				Y1+=signY //Line exits tile vertically
			else
				X1+=signX //Line exits tile horizontally
			T=locate(X1,Y1,Z)
			if(T.opacity)
				return 0
	return 1
#undef SIGN

proc/isInSight(var/atom/A, var/atom/B)
	var/turf/Aturf = get_turf(A)
	var/turf/Bturf = get_turf(B)

	if(!Aturf || !Bturf)
		return 0

	if(inLineOfSight(Aturf.x,Aturf.y, Bturf.x,Bturf.y,Aturf.z))
		return 1

	else
		return 0

/proc/get_cardinal_step_away(atom/start, atom/finish) //returns the position of a step from start away from finish, in one of the cardinal directions
	//returns only NORTH, SOUTH, EAST, or WEST
	var/dx = finish.x - start.x
	var/dy = finish.y - start.y
	if(abs(dy) > abs (dx)) //slope is above 1:1 (move horizontally in a tie)
		if(dy > 0)
			return get_step(start, SOUTH)
		else
			return get_step(start, NORTH)
	else
		if(dx > 0)
			return get_step(start, WEST)
		else
			return get_step(start, EAST)

/proc/try_move_adjacent(atom/movable/AM)
	var/turf/T = get_turf(AM)
	for(var/direction in cardinal)
		if(AM.Move(get_step(T, direction)))
			break

/proc/get_mob_by_key(var/key)
	for(var/mob/M in mob_list)
		if(M.ckey == lowertext(key))
			return M
	return null

// Comment out when done testing shit.
//#define DEBUG_ROLESELECT

#ifdef DEBUG_ROLESELECT
#define roleselect_debug(x) testing(x)
#warn DEBUG_ROLESELECT is defined!
#else
# define roleselect_debug(x)
#endif

// Will return a list of active candidates. It increases the buffer 5 times until it finds a candidate which is active within the buffer.
/proc/get_active_candidates(var/role_id=null, var/buffer=ROLE_SELECT_AFK_BUFFER, var/poll=0)
	var/list/candidates = list() //List of candidate mobs to assume control of the new larva ~fuck you
	var/i = 0
	while(candidates.len <= 0 && i < 5)
		roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Player list is [player_list.len] items long.")
		for(var/mob/dead/observer/G in player_list)
			if(G.mind && G.mind.current && G.mind.current.stat != DEAD)
				roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Skipping [G]  - Shitty candidate.")
				continue

			if(!G.client.desires_role(role_id,display_to_user=(poll!=0 && i==0) ? poll : 0)) // Only ask once.
				roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Skipping [G]  - Doesn't want role.")
				continue

			if(((G.client.inactivity/10)/60) > buffer + i) // the most active players are more likely to become an alien
				roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Skipping [G]  - Inactive.")
				continue

			roleselect_debug("get_active_candidates(role_id=[role_id], buffer=[buffer], poll=[poll]): Selected [G] as candidate.")
			candidates += G
		i++
	return candidates

/proc/get_candidates(var/role_id=null)
	. = list()
	for(var/mob/dead/observer/G in player_list)
		if(!(G.mind && G.mind.current && G.mind.current.stat != DEAD))
			if(!G.client.is_afk() && (role_id==null || G.client.desires_role(role_id)))
				. += G.client

/proc/ScreenText(obj/O, maptext="", screen_loc="CENTER-7,CENTER-7", maptext_height=480, maptext_width=480)
	if(!isobj(O))
		O = new /obj/abstract/screen/text()
	O.maptext = maptext
	O.maptext_height = maptext_height
	O.maptext_width = maptext_width
	O.screen_loc = screen_loc
	return O

/proc/Show2Group4Delay(obj/O, list/group, delay=0)
	if(!isobj(O))
		return
	if(!group)
		group = clients
	for(var/client/C in group)
		C.screen += O
	if(delay)
		spawn(delay)
			for(var/client/C in group)
				C.screen -= O

/proc/flick_overlay(image/I, list/show_to, duration)
	set waitfor = FALSE
	for(var/client/C in show_to)
		C.images += I
	sleep(duration)
	for(var/client/C in show_to)
		C.images -= I

/proc/get_active_player_count()
	// Get active players who are playing in the round
	var/active_players = 0
	for(var/i = 1; i <= player_list.len; i++)
		var/mob/M = player_list[i]
		if(M && M.client)
			if(istype(M, /mob/new_player)) // exclude people in the lobby
				continue
			else if(isobserver(M)) // Ghosts are fine if they were playing once (didn't start as observers)
				var/mob/dead/observer/O = M
				if(O.started_as_observer) // Exclude people who started as observers
					continue
			active_players++
	return active_players

/datum/projectile_data
	var/src_x
	var/src_y
	var/time
	var/distance
	var/power_x
	var/power_y
	var/dest_x
	var/dest_y

/datum/projectile_data/New(var/src_x, var/src_y, var/time, var/distance, \
						   var/power_x, var/power_y, var/dest_x, var/dest_y)
	src.src_x = src_x
	src.src_y = src_y
	src.time = time
	src.distance = distance
	src.power_x = power_x
	src.power_y = power_y
	src.dest_x = dest_x
	src.dest_y = dest_y

/proc/projectile_trajectory(var/src_x, var/src_y, var/rotation, var/angle, var/power)


	// returns the destination (Vx,y) that a projectile shot at [src_x], [src_y], with an angle of [angle],
	// rotated at [rotation] and with the power of [power]
	// Thanks to VistaPOWA for this function

	var/power_x = power * cos(angle)
	var/power_y = power * sin(angle)
	var/time = 2* power_y / 10 //10 = g

	var/distance = time * power_x

	var/dest_x = src_x + distance*sin(rotation);
	var/dest_y = src_y + distance*cos(rotation);

	return new /datum/projectile_data(src_x, src_y, time, distance, power_x, power_y, dest_x, dest_y)


/proc/mobs_in_area(var/area/the_area, var/client_needed=0, var/moblist=mob_list)
	var/list/mobs_found[0]
	var/area/our_area = get_area(the_area)
	for(var/mob/M in moblist)
		if(client_needed && !M.client)
			continue
		if(our_area != get_area(M))
			continue
		mobs_found += M
	return mobs_found

/proc/GetRedPart(const/hexa)
	return hex2num(copytext(hexa, 2, 4))

/proc/GetGreenPart(const/hexa)
	return hex2num(copytext(hexa, 4, 6))

/proc/GetBluePart(const/hexa)
	return hex2num(copytext(hexa, 6, 8))

/proc/GetHexColors(const/hexa)
	return list(
		GetRedPart(hexa),
		GetGreenPart(hexa),
		GetBluePart(hexa),
		)

/proc/rgb2hsl(var/red, var/grn, var/blu)

	red /= 255
	grn /= 255
	blu /= 255

	var/lo = min(red, grn, blu)
	var/hi = max(red, grn, blu)
	var/hue = 0
	var/sat = 0
	var/lgh = (lo + hi)/2

	if(lo != hi)
		if(lgh < 0.5)
			sat = (hi - lo) / (hi + lo)
		else
			sat = (hi - lo) / (2 - hi - lo)
		if(red == hi)
			hue = (grn - blu) / (hi - lo)
		else if(grn == hi)
			hue = 2 + (blu - red) / (hi - lo)
		else
			hue = 4 + (red - grn) / (hi - lo)
		if(hue<0)
			hue += 6

	lgh = round(lgh * 100, 1)
	sat = round(sat * 100, 1)

	hue = round((hue / 6) * 360, 1)

	return list(
		hue,
		sat,
		lgh,
		)

/proc/hsl2rgb(var/hue, var/sat, var/lgh)

	hue /= 360
	sat /= 100
	lgh /= 100

	var/red = 0
	var/grn = 0
	var/blu = 0

	if(!sat)
		red = lgh
		grn = lgh
		blu = lgh
	else
		var/temp1 = 0
		var/temp2 = 0
		var/temp3 = 0
		if(lgh < 0.5)
			temp2 = lgh * (1 + sat)
		else
			temp2 = lgh + sat - lgh * sat
		temp1 = 2 * lgh - temp2

		temp3 = hue + 1/3
		if(temp3 > 1)
			temp3--
		if(6*temp3<1)
			red = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2*temp3<1)
			red = temp2
		else if(3*temp3<2)
			red = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			red = temp1

		temp3 = hue
		if(6*temp3<1)
			grn = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2*temp3<1)
			grn = temp2
		else if(3*temp3<2)
			grn = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			grn = temp1

		temp3 = hue - 1/3
		if(temp3 < 0)
			temp3++
		if(6*temp3<1)
			blu = temp1 + (temp2 - temp1) * 6 * temp3
		else if(2*temp3<1)
			blu = temp2
		else if(3*temp3<2)
			blu = temp1 + (temp2 - temp1) * ((2/3) - temp3) * 6
		else
			blu = temp1

	red = round(red*255, 1)
	grn = round(grn*255, 1)
	blu = round(blu*255, 1)

	return list(
		red,
		grn,
		blu,
		)

/proc/MixColors(const/list/colors)
	var/list/reds = new
	var/list/blues = new
	var/list/greens = new
	var/list/weights = new

	for (var/i = 0, ++i <= colors.len)
		reds.Add(GetRedPart(colors[i]))
		blues.Add(GetBluePart(colors[i]))
		greens.Add(GetGreenPart(colors[i]))
		weights.Add(1)

	var/r = mixOneColor(weights, reds)
	var/g = mixOneColor(weights, greens)
	var/b = mixOneColor(weights, blues)
	return rgb(r,g,b)

/proc/mixOneColor(var/list/weight, var/list/color)
	if(!weight || !color || length(weight) != length(color))
		return 0

	var/contents = length(weight)

	// normalize weights
	var/listsum = 0

	for(var/i = 1, i <= contents, i++)
		listsum += weight[i]

	for(var/i = 1, i <= contents, i++)
		weight[i] /= listsum

	// mix them
	var/mixedcolor = 0

	for(var/i = 1, i <= contents, i++)
		mixedcolor += weight[i] * color[i]

	// until someone writes a formal proof for this algorithm, let's keep this in
	//if(mixedcolor<0x00 || mixedcolor>0xFF)
	//	return 0
	// that's not the kind of operation we are running here, nerd
	return clamp(round(mixedcolor), 0, 255)

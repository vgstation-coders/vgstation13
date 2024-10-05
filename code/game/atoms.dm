var/global/list/del_profiling = list()
var/global/list/gdel_profiling = list()
var/global/list/ghdel_profiling = list()

#define HOLYWATER_DURATION 8 MINUTES

/atom

	var/ghost_read  = 1 // All ghosts can read
	var/ghost_write = 0 // Only aghosts can write
	var/blessed=0 // Chaplain did his thing. (set by bless() proc, which is called by holywater)
	/// pass_flags that this atom has. If any of this matches a pass_flag on a moving thing, by default, we let them through.
	var/pass_flags_self = NONE
	var/flags = FPRINT
	var/flow_flags = 0
	var/list/fingerprints
	var/list/fingerprintshidden
	var/fingerprintslast = null
	var/fingerprintslastTS = null
	var/list/blood_DNA
	var/blood_color
	var/had_blood //Something was bloody at some point.
	var/germ_level = 0 // The higher the germ level, the more germ on the atom.
	var/penetration_dampening = 5 //drains some of a projectile's penetration power whenever it goes through the atom
	var/throw_impact_sound = 'sound/weapons/genhit2.ogg'
	var/admin_desc //Allows admins to see admin-exclusive examines, such as notifications for custom variables

	///Chemistry.
	var/datum/reagents/reagents = null

	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.

	var/list/beams

	var/labeled //Stupid and ugly way to do it, but the alternative would probably require rewriting everywhere a name is read.
	var/min_harm_label = 0 //Minimum langth of harm-label to be effective. 0 means it cannot be harm-labeled. If any label should work, set this to 1 or 2.
	var/harm_labeled = 0 //Length of current harm-label. 0 if it doesn't have one.
	var/list/harm_label_examine //Messages that appears when examining the item if it is harm-labeled. Message in position 1 is if it is harm-labeled but the label is too short to work, while message in position 2 is if the harm-label works.
	//var/harm_label_icon_state //Makes sense to have this, but I can't sprite. May be added later.
	var/list/last_beamchecks // timings for beam checks.
	var/ignoreinvert = 0
	var/timestopped

	appearance_flags = TILE_BOUND|LONG_GLIDE|TILE_MOVER
	/// sources of setting KEEP_TOGETHER on an atom
	var/list/keep_together_sources
	var/slowdown_modifier //modified on how fast a person can move over the tile we are on, see turf.dm for more info
	/// Last name used to calculate a color for the chatmessage overlays
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays
	var/chat_color
	/// A luminescence-shifted value of the last color calculated for chatmessage overlays
	var/chat_color_darkened
	/// The chat color var, without alpha.
	var/chat_color_hover

	var/emagged = 0 // Some things other than machinery can be
	var/emag_cost = 0 // Emag energy cost (in MJ)
	var/arcanetampered = 0 //A looot of things can be


	var/image/moody_light
	var/list/moody_lights

/atom/proc/beam_connect(var/obj/effect/beam/B)
	if(!last_beamchecks)
		last_beamchecks = list()
	if(!beams)
		beams = list()
	if(!(B in beams))
		beams.Add(B)
	return 1

/atom/proc/beam_disconnect(var/obj/effect/beam/B)
	if (beams)
		beams.Remove(B)

/atom/proc/apply_beam_damage(var/obj/effect/beam/B)
	return 1

/atom/proc/handle_beams()
	return 1

/atom/variable_edited(variable_name, old_value, new_value)
	.=..()

	switch(variable_name)
		if("light_color")
			set_light(l_color = new_value)
			return 1
		if("light_range")
			set_light(new_value)
			return 1
		if("light_power")
			set_light(l_power = new_value)

		if("contents")
			if(islist(new_value))
				if(length(new_value) == 0) //empty list
					return 0 //Replace the contents list with an empty list, nullspacing everything
				else
					//If the new value is a list with objects, don't nullspace the old objects, and merge the two lists together peacefully
					contents.Add(new_value)
					return 1


//pixelshift - max pixels to shift on each shake
//speed - The speed of each shake
//loop - How many shakes to perform
//Total shaking time is equal to speed * loops
/atom/proc/shake_animation(pixelshiftx = 3, pixelshifty = 3, speed = 0.2 SECONDS, loops = 3)
	set waitfor = 0
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shakedirections = 0
	while(shakedirections < loops)
		if(!src)
			return

		//pick random values to shift to, exclude the initial position
		var/shiftx = rand(1,pixelshiftx)
		var/shifty = rand(1,pixelshifty)
		if(prob(50))
			shiftx = -shiftx
		if(prob(50))
			shifty = -shifty

		animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = speed)
		shakedirections = shakedirections + 1
		sleep(speed)
		pixel_x = initialpixelx
		pixel_y = initialpixely

//xy: 1 if shakes horizontally, 2 if vertical, 3 if both
/atom/proc/shake(var/xy, var/intensity, mob/user) //Zth. SHAKE IT. Vending machines' kick uses this
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y

	switch(xy)
		if(1)
			src.pixel_x += rand(-intensity, intensity) * PIXEL_MULTIPLIER
		if(2)
			src.pixel_y += rand(-intensity, intensity) * PIXEL_MULTIPLIER
		if(3)
			src.pixel_x += rand(-intensity, intensity) * PIXEL_MULTIPLIER
			src.pixel_y += rand(-intensity, intensity) * PIXEL_MULTIPLIER

	spawn(2)
	src.pixel_x = old_pixel_x
	src.pixel_y = old_pixel_y

// NOTE FROM AMATEUR CODER WHO STRUGGLED WITH RUNTIMES
// throw_impact is called multiple times when an item is thrown: see /atom/movable/proc/hit_check at atoms_movable.dm
// Do NOT delete an item as part of its throw_impact unless you've checked the hit_atom is a turf, as that's effectively the last time throw_impact is called in a single throw.
// Otherwise, shit will runtime in the subsequent throw_impact calls.
/atom/proc/throw_impact(atom/hit_atom, var/speed, mob/user, var/list/impact_whitelist)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		if (M.hitby(src,speed,src.dir,impact_whitelist))
			playsound(loc,'sound/effects/slap2.ogg', 15, 1)//grabbed the item
		else
			playsound(src, src.throw_impact_sound, 80, 1)
		log_attack("<font color='red'>[hit_atom] ([M ? M.ckey : "what"]) was hit by [src] thrown by [user] ([user ? user.ckey : "what"])</font>")

	else if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			O.set_glide_size(0)
			step(O, src.dir)
		O.hitby(src,speed)

	else if(isturf(hit_atom) && !istype(src,/obj/mecha))//heavy mechs don't just bounce off walls, also it can fuck up rocket dashes
		var/turf/T = hit_atom
		if(T.density)
			if (isturf(loc))
				spawn(2)
					step(src, turn(src.dir, 180))
			if(istype(src,/mob/living))
				var/mob/living/M = src
				M.take_organ_damage(10)
	INVOKE_EVENT(src, /event/throw_impact, "hit_atom" = hit_atom, "speed" = speed, "user" = user, "thrown_atom" = src)

/atom/Destroy()
	QDEL_NULL(reagents)

	if(density)
		densityChanged()
	// Idea by ChuckTheSheep to make the object even more unreferencable.
	invisibility = 101
	if(istype(beams, /list) && beams.len)
		beams.len = 0
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.zone?.burnable_atoms -= src
	/*if(istype(beams) && beams.len)
		for(var/obj/effect/beam/B in beams)
			if(B && B.target == src)
				B.target = null
			if(B.master && B.master.target == src)
				B.master.target = null
		beams.len = 0
	*/
	remove_particles()
	QDEL_NULL(firelightdummy)
	..()

/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

/atom/proc/check_eye(user as mob)
	if (istype(user, /mob/living/silicon/ai)) // WHYYYY
		return 1
	return

/atom/proc/on_reagent_change()
	return

// This proc is intended to be called by `to_bump` whenever a movable
// object bumps into this atom.
/atom/proc/Bumped(atom/movable/AM)
	return

//When this object is bumped by BYOND, what should actually get bumped? Usually itself but there are some cases where it differs.
//When not returning src, it should generally be called recursively on the found target in case that one also returns something else. Just don't make a cycle.
//Yes it would be more logical to handle that elsewhere but it would also be more complicated
/atom/proc/get_bump_target()
	return src

/atom/proc/setDensity(var/density)
	if (density == src.density)
		return FALSE // No need to invoke the event when we're not doing any actual change
	src.density = density
	densityChanged()

/atom/proc/densityChanged()
	INVOKE_EVENT(src, /event/density_change, "atom" = src)
	if(beams && beams.len) // If beams is not a list something bad happened and we want to have a runtime to lynch whomever is responsible.
		beams.len = 0
	if(!isturf(src))
		var/turf/T = get_turf(src)
		if(T)
			T.densityChanged()

// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
/atom/proc/is_open_container()
	return flags & OPENCONTAINER

/atom/proc/reagent_transfer_message(var/transfer_amt)
	return "<span class='notice'>You transfer [transfer_amt] units of the solution to \the [src.name].</span>"

// For when we want an open container that doesn't show its reagents on examine
/atom/proc/hide_own_reagents()
	return FALSE

// As a rule of thumb, should smoke be able to pop out from inside this object?
// Currently only used for chemical reactions, see Chemistry-Recipes.dm
/atom/proc/is_airtight()
	return 0

/*//Convenience proc to see whether a container can be accessed in a certain way.

/atom/proc/can_subract_container()
	return flags & EXTRACT_CONTAINER

/atom/proc/can_add_container()
	return flags & INSERT_CONTAINER
*/

/atom/proc/allow_drop()
	return 1

/atom/proc/HasProximity(atom/movable/AM as mob|obj) //IF you want to use this, the atom must have the PROXMOVE flag, and the moving atom must also have the PROXMOVE flag currently to help with lag
	return

/atom/proc/emp_act(var/severity)
	set waitfor = FALSE
	return

/atom/proc/kick_act(mob/living/carbon/human/user) //Called when this atom is kicked. If returns 1, normal click action will be performed after calling this (so attack_hand() in most cases)
	return 1

/atom/proc/bite_act(mob/living/carbon/human/user) //Called when this atom is bitten. If returns 1, same as kick_act()
	return 1

/atom/proc/bullet_act(var/obj/item/projectile/Proj)
	return PROJECTILE_COLLISION_DEFAULT

/atom/proc/photography_act(var/obj/item/device/camera/camera) //Called when this atom has its picture taken by a camera
	return

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return 1
	else if(src in container)
		return 1
	return

/atom/proc/recursive_in_contents_of(atom/container)
	if(!loc)
		return FALSE
	if(loc == container)
		return TRUE
	return loc.recursive_in_contents_of(container)

/atom/proc/projectile_check()
	return

//Override this to have source respond differently to visible_messages said by an atom A
/atom/proc/on_see(var/message, var/blind_message, var/drugged_message, var/blind_drugged_message, atom/A)

/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */


/atom/proc/search_contents_for(path,list/filter_path=null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found


/*
 *	atom/proc/contains_atom_from_list(var/list/L)
 *	Basically same as above but it takes a list of paths (like list(/mob/living/,/obj/machinery/something,...))
 * RETURNS: a found atom
 */
/atom/proc/contains_atom_from_list(var/list/L)
	for(var/atom/A in src)
		for(var/T in L)
			if(istype(A,T))
				return A
		if(A.contents.len)
			var/atom/R = A.contains_atom_from_list(L)
			if(R)
				return R
	return 0


/*
Beam code by Gunbuddy

Beam() proc will only allow one beam to come from a source at a time.  Attempting to call it more than
once at a time per source will cause graphical errors.
Also, the icon used for the beam will have to be vertical and 32x32.
The math involved assumes that the icon is vertical to begin with so unless you want to adjust the math,
its easier to just keep the beam vertical.
*/
/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50, maxdistance=10)
	//BeamTarget represents the target for the beam, basically just means the other end.
	//Time is the duration to draw the beam
	//Icon is obviously which icon to use for the beam, default is beam.dmi
	//Icon_state is what icon state is used. Default is b_beam which is a blue beam.
	//Maxdistance is the longest range the beam will persist before it gives up.
	var/EndTime=world.time+time
	var/broken = 0
	var/obj/item/projectile/beam/lightning/light = new /obj/item/projectile/beam/lightning
	while(BeamTarget&&world.time<EndTime&&get_dist(src,BeamTarget)<maxdistance&&z==BeamTarget.z)

	//If the BeamTarget gets deleted, the time expires, or the BeamTarget gets out
	//of range or to another z-level, then the beam will stop.  Otherwise it will
	//continue to draw.

		//dir=get_dir(src,BeamTarget)	//Causes the source of the beam to rotate to continuosly face the BeamTarget.

		for(var/obj/effect/overlay/beam/O in orange(10,src))	//This section erases the previously drawn beam because I found it was easier to
			if(O.BeamSource==src)				//just draw another instance of the beam instead of trying to manipulate all the
				qdel(O)					//pieces to a new orientation.
		var/Angle=round(Get_Angle(src,BeamTarget))
		var/icon/I=new(icon,icon_state)
		I.Turn(Angle)
		var/DX=(WORLD_ICON_SIZE*BeamTarget.x+BeamTarget.pixel_x)-(WORLD_ICON_SIZE*x+pixel_x)
		var/DY=(WORLD_ICON_SIZE*BeamTarget.y+BeamTarget.pixel_y)-(WORLD_ICON_SIZE*y+pixel_y)
		var/N=0
		var/length=round(sqrt((DX)**2+(DY)**2))
		for(N,N<length,N+=WORLD_ICON_SIZE)
			var/obj/effect/overlay/beam/X=new /obj/effect/overlay/beam(loc)
			X.BeamSource=src
			if(N+WORLD_ICON_SIZE>length)
				var/icon/II=new(icon,icon_state)
				II.DrawBox(null,1,(length-N),WORLD_ICON_SIZE,WORLD_ICON_SIZE)
				II.Turn(Angle)
				X.icon=II
			else
				X.icon=I
			var/Pixel_x=round(sin(Angle)+WORLD_ICON_SIZE*sin(Angle)*(N+WORLD_ICON_SIZE/2)/WORLD_ICON_SIZE)
			var/Pixel_y=round(cos(Angle)+WORLD_ICON_SIZE*cos(Angle)*(N+WORLD_ICON_SIZE/2)/WORLD_ICON_SIZE)
			if(DX==0)
				Pixel_x=0
			if(DY==0)
				Pixel_y=0
			if(Pixel_x>WORLD_ICON_SIZE)
				for(var/a=0, a<=Pixel_x,a+=WORLD_ICON_SIZE)
					X.x++
					Pixel_x-=WORLD_ICON_SIZE
			if(Pixel_x<-WORLD_ICON_SIZE)
				for(var/a=0, a>=Pixel_x,a-=WORLD_ICON_SIZE)
					X.x--
					Pixel_x+=WORLD_ICON_SIZE
			if(Pixel_y>WORLD_ICON_SIZE)
				for(var/a=0, a<=Pixel_y,a+=WORLD_ICON_SIZE)
					X.y++
					Pixel_y-=WORLD_ICON_SIZE
			if(Pixel_y<-WORLD_ICON_SIZE)
				for(var/a=0, a>=Pixel_y,a-=WORLD_ICON_SIZE)
					X.y--
					Pixel_y+=WORLD_ICON_SIZE
			X.pixel_x=Pixel_x
			X.pixel_y=Pixel_y
			var/turf/TT = get_turf(X.loc)
			if(TT.density)
				qdel(X)
				break
			for(var/obj/O in TT)
				if(!O.Cross(light))
					broken = 1
					break
				else if(O.density)
					broken = 1
					break
			if(broken)
				qdel(X)
				break
		sleep(3)	//Changing this to a lower value will cause the beam to follow more smoothly with movement, but it will also be more laggy.
					//I've found that 3 ticks provided a nice balance for my use.
	for(var/obj/effect/overlay/beam/O in orange(10,src)) if(O.BeamSource==src) qdel(O)

//Woo hoo. Overtime
//All atoms
/atom/proc/examine(mob/user, var/size = "", var/show_name = TRUE, var/show_icon = TRUE)
	//This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [src]."
	if(is_blood_stained())
		var/stain_text = get_stain_text(FALSE)
		f_name = "[get_indefinite_article(stain_text, gender)] <span class='danger'><span style='color: [get_stain_text_color()]'>[stain_text]</span></span> [name]!"

	if(show_name)
		to_chat(user, "[show_icon ? bicon(src) : ""] That's [f_name]" + size)
	if(desc)
		to_chat(user, desc)

	if(reagents && is_open_container() && !hide_own_reagents()) //is_open_container() isn't really the right proc for this, but w/e
		if(get_dist(user,src) > 3)
			to_chat(user, "<span class='info'>You can't make out the contents.</span>")
		else
			reagents.get_examine(user)
	if(on_fire)
		user.simple_message("<span class='danger'>OH SHIT! IT'S ON FIRE!</span>",\
			"<span class='info'>It's on fire, man.</span>")
	if(charred_overlay)
		to_chat(user, span_info("It's covered in ash."))
	if(min_harm_label && harm_labeled)
		if(harm_labeled < min_harm_label)
			to_chat(user, harm_label_examine[1])
		else
			to_chat(user, harm_label_examine[2])

	var/obj/item/device/camera_bug/bug = locate() in src
	if(bug)
		var/this_turf = get_turf(src)
		var/user_turf = get_turf(user)
		var/distance = get_dist(this_turf, user_turf)
		if(Adjacent(user))
			to_chat(user, "<a href='?src=\ref[src];bug=\ref[bug]'>There's something hidden in there.</a>")
		else if(isobserver(user) || prob(100 / (distance + 2)))
			to_chat(user, "There's something hidden in there.")
	if(isliving(user) && user.mind)
		for(var/datum/role/R in get_list_of_elements(user.mind.antag_roles))
			var/antag_text = R.role_examine_text_addition(src)
			if(antag_text)
				to_chat(user, "[antag_text]\n")
	INVOKE_EVENT(src, /event/examined, "user" = user)

/atom/Topic(href, href_list)
	. = ..()
	if(.)
		return
	var/obj/item/device/camera_bug/bug = locate(href_list["bug"])
	if(istype(bug))
		. = 1
		if(isAdminGhost(usr))
			bug.removed(null, null, FALSE)
		if(ishuman(usr) && !usr.incapacitated() && Adjacent(usr) && usr.dexterity_check())
			bug.removed(usr)

/atom/proc/relaymove()
	INVOKE_EVENT(src, /event/relaymoved, "mover" = src)

// Try to override a mob's eastface(), westface() etc. (CTRL+RIGHTARROW, CTRL+LEFTARROW). Return 1 if successful, which blocks the mob's own eastface() etc.
// Called first on the mob's loc (turf, locker, mech), then on whatever the mob is buckled to, if anything.
/atom/proc/relayface()
	return

// Severity is actually "distance".
// 1 is pretty much just del(src).
// 2 is moderate damage.
// 3 is light damage.
//
// child is set to the child object that exploded, if available.
/atom/proc/ex_act(var/severity, var/child=null, var/mob/whodunnit)
	return

/atom/proc/mech_drill_act(var/severity, var/child=null)
	return ex_act(severity, child)

/atom/proc/can_mech_drill()
	return dissolvable()

/atom/proc/blob_act(destroy = 0, var/obj/effect/blob/source = null)
	if(flags & INVULNERABLE)
		return
	var/_target

	if(isturf(src))
		_target = src
	else
		_target = loc

	if(source)
		anim(target = _target, a_icon = source.icon, flick_anim = "blob_act", sleeptime = 15, direction = get_dir(source, src), lay = BLOB_SPORE_LAYER, plane = BLOB_PLANE)
	else
		anim(target = _target, a_icon = 'icons/mob/blob/blob.dmi', flick_anim = "blob_act", sleeptime = 15, lay = BLOB_SPORE_LAYER, plane = BLOB_PLANE)

/atom/proc/singularity_act()
	return

//Called when a shuttle collides with an atom
/atom/proc/shuttle_act(var/datum/shuttle/S)
	return

/atom/proc/clean_act(var/cleanliness)//1 = contact with water (splashed with water, removes glue from objs), 2 = space cleaner or efficient cleaning (showers, sink, soap), 3 = bleach
	if (cleanliness >= CLEANLINESS_SPACECLEANER)
		clean_blood()
		if(charred_overlay)
			cut_overlay(charred_overlay)
	if (cleanliness >= CLEANLINESS_BLEACH)
		color = ""
	if (cleanliness >= CLEANLINESS_WATER)//I mean, not sure why we'd ever add a rank below water but, futur-proofing and all that jazz
		extinguish()//Fire.dm

/atom/proc/wind_act(var/differential, var/list/connecting_turfs)
	return

//Called on every object in a shuttle which rotates
/atom/proc/map_element_rotate(var/angle)
	change_dir(turn(src.dir, -angle))

	if(canSmoothWith()) //Smooth the smoothable
		spawn //Usually when this is called right after an atom is moved. Not having this "spawn" here will cause this atom to look for its neighbours BEFORE they have finished moving, causing bad stuff.
			relativewall()
			relativewall_neighbours()

	if(pixel_x || pixel_y)
		var/cosine	= cos(angle)
		var/sine	= sin(angle)
		var/newX = (cosine	* pixel_x) + (sine	* pixel_y)
		var/newY = -(sine	* pixel_x) + (cosine* pixel_y)

		pixel_x = newX
		pixel_y = newY

/atom/proc/singularity_pull()
	return

/**
 * Returns the cost of emagging this machine (emag_cost by default)
 * @param user /mob The mob that used the emag.
 * @param emag /obj/item/weapon/card/emag The emag used on this device.
 * @return number Cost to emag.
 */
/atom/proc/getEmagCost(var/mob/user, var/obj/item/weapon/card/emag/emag)
	return emag_cost

/atom/proc/can_emag()
	return TRUE

/atom/proc/emag_act(var/mob/user)
	return

/atom/proc/slime_act()
	return

/atom/proc/supermatter_act(atom/source, severity)
	qdel(src)
	return 1

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//SUICIDE_ACT_BRUTELOSS = 1
//SUICIDE_ACT_FIRELOSS = 2
//SUICIDE_ACT_TOXLOSS = 4
//SUICIDE_ACT_OXYLOSS = 8
//Output a creative message and then return the damagetype done
/atom/proc/suicide_act(var/mob/living/user)
	return

// Returns TRUE if it's been handled, children should return if parent has already handled
/atom/proc/hitby(var/atom/movable/AM)
	. = isobserver(AM)

/atom/proc/add_hiddenprint(mob/M as mob)
	if(isnull(M))
		return
	if(isnull(M.key))
		return
	if (!(flags & FPRINT))
		return
	if((fingerprintslastTS == time_stamp()) && (fingerprintslast == M.key)) //otherwise holding arrow on airlocks spams fingerprints onto it
		return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna))
			return 0
		if (H.gloves)
			fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []",H.real_name, H.key)
			fingerprintslast = H.key
			fingerprintslastTS = time_stamp()
			return 0
		if (!( src.fingerprints ))
			fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []",H.real_name, H.key)
			fingerprintslast = H.key
			fingerprintslastTS = time_stamp()
			return 1
	else
		var/ghost = ""
		if (isobserver(M))
			ghost = isAdminGhost(M) ? "ADMINGHOST" : "GHOST"
		fingerprintshidden += text("\[[time_stamp()]\] [ghost ? "([ghost])" : ""] Real name: [], Key: []",M.real_name, M.key)
		fingerprintslast = M.key
		fingerprintslastTS = time_stamp()
	return

/atom/proc/add_fingerprint(mob/living/M as mob)
	if(isnull(M))
		return
	if(isAI(M))
		return
	if(isnull(M.key))
		return
	if (!(flags & FPRINT))
		return
	if((fingerprintslastTS == time_stamp()) && (fingerprintslast == M.key)) //otherwise holding arrow on airlocks spams fingerprints onto it
		return
	if (ishuman(M))
		//Add the list if it does not exist.
		if(!fingerprintshidden)
			fingerprintshidden = list()

		//Fibers~
		add_fibers(M)

		//He has no prints!
		if (M_FINGERPRINTS in M.mutations)
			fingerprintshidden += "\[[time_stamp()]\] (Has no fingerprints) Real name: [M.real_name], Key: [M.key]"
			fingerprintslast = M.key
			fingerprintslastTS = time_stamp()
			return 0		//Now, lets get to the dirty work.
		//First, make sure their DNA makes sense.
		var/mob/living/carbon/human/H = M
		if (!istype(H.dna, /datum/dna) || !H.dna.uni_identity || (length(H.dna.uni_identity) != 32))
			if(!istype(H.dna, /datum/dna))
				H.dna = new /datum/dna(null)
				H.dna.real_name = H.real_name
				H.dna.flavor_text = H.flavor_text
		H.check_dna_integrity()

		//Now, deal with gloves.
		if (H.gloves && H.gloves != src)
			fingerprintshidden += text("\[[time_stamp()]\] (Wearing gloves). Real name: [], Key: []", H.real_name, H.key)
			fingerprintslast = H.key
			fingerprintslastTS = time_stamp()
			H.gloves.add_fingerprint(M)

		//Deal with gloves the pass finger/palm prints.
		if(H.gloves != src)
			if(prob(75) && istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0
			else if(H.gloves && !istype(H.gloves, /obj/item/clothing/gloves/latex))
				return 0

		//More adminstuffz
		var/ghost = ""
		if (isobserver(M))
			ghost = isAdminGhost(M) ? "ADMINGHOST" : "GHOST"
		fingerprintshidden += text("\[[time_stamp()]\] [ghost ? "([ghost]) " : ""]Real name: [], Key: []", M.real_name, M.key)
		fingerprintslast = M.key
		fingerprintslastTS = time_stamp()

		//Make the list if it does not exist.
		if(!fingerprints)
			fingerprints = list()

		//Hash this shit.
		var/full_print = md5(H.dna.uni_identity)

		// Add the fingerprints
		fingerprints[full_print] = full_print

		return 1
	else
		//Smudge up dem prints some
		if(fingerprintslast != M.key)
			fingerprintshidden += text("\[[time_stamp()]\] Real name: [], Key: []", M.real_name, M.key)
			fingerprintslast = M.key
			fingerprintslastTS = time_stamp()

	//Cleaning up shit.
	if(fingerprints && !fingerprints.len)
		fingerprints = null
	return


/atom/proc/transfer_fingerprints_to(var/atom/A)
	if(!istype(A.fingerprints,/list))
		A.fingerprints = list()
	if(!istype(A.fingerprintshidden,/list))
		A.fingerprintshidden = list()

	//skytodo
	//A.fingerprints |= fingerprints            //detective
	//A.fingerprintshidden |= fingerprintshidden    //admin
	if(fingerprints)
		A.fingerprints |= fingerprints.Copy()            //detective
	if(fingerprintshidden && istype(fingerprintshidden))
		A.fingerprintshidden |= fingerprintshidden.Copy()    //admin	A.fingerprintslast = fingerprintslast

//Atomic level procs to be used elsewhere.
/atom/proc/apply_luminol(var/atom/A)
	return had_blood

/atom/proc/clear_luminol(var/atom/A)
	return had_blood

//returns 1 if made bloody, returns 0 otherwise
/atom/proc/add_blood(var/mob/living/carbon/human/M)
	.=TRUE
	if(!M)//if the blood is of non-human source
		if(!blood_DNA || !istype(blood_DNA, /list))
			blood_DNA = list()
		blood_color = blood_DNA.len ? BlendRYB(blood_color, DEFAULT_BLOOD, 0.5) : DEFAULT_BLOOD //mix new color into existing blood_color if applicable
		had_blood = TRUE
		return TRUE
	if (!( istype(M, /mob/living/carbon/human) ))
		return FALSE
	if (!istype(M.dna, /datum/dna))
		M.dna = new /datum/dna(null)
		M.dna.real_name = M.real_name
	M.check_dna_integrity()
	if (!(flags & FPRINT))
		return FALSE
	if(!blood_DNA || !istype(blood_DNA, /list))	//if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()
	if (M.species)
		blood_color = blood_DNA.len ? BlendRYB(blood_color, M.species.blood_color, 0.5) : M.species.blood_color
	else
		blood_color = blood_DNA.len ? BlendRYB(blood_color, DEFAULT_BLOOD, 0.5) : DEFAULT_BLOOD
	return TRUE

//this proc exists specifically for cases where the mob that originated the blood (aka the "donor") might not exist anymore, leading to bugs galore
/atom/proc/add_blood_from_data(var/list/blood_data)
	if (!( istype(blood_data) ))
		return FALSE

	if (!( src.flags & FPRINT))
		return FALSE

	if(!istype(blood_DNA, /list))	//if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()

	blood_color = blood_DNA.len ? BlendRYB(blood_color, blood_data["blood_colour"], 0.5) : blood_data["blood_colour"] //mix new color into existing blood_color if applicable
	return TRUE

/atom/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0, active = 0, steal_reagents_from_mob = 1)
	if( istype(src, /turf/simulated) )
		var/obj/effect/decal/cleanable/vomit/this
		if(active)
			this = new /obj/effect/decal/cleanable/vomit/active(src)
		else
			this = new /obj/effect/decal/cleanable/vomit(src)

		if (M)
			this.virus2 += virus_copylist(M.virus2)

		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"

		if(active && steal_reagents_from_mob && M && M.reagents)
			M.reagents.trans_to(this, M.reagents.total_volume * 0.1)


/atom/proc/clean_blood()
	src.germ_level = 0
	if(istype(blood_DNA, /list))
		//del(blood_DNA)
		blood_DNA.len = 0
		return 1
	if(istype(had_blood,/obj/effect/decal/cleanable/blueglow))
		clear_luminol()

/atom/proc/ErasableRune() // god that's dumb but I need to work them into that iscleanaway macro somehow
	return FALSE

/atom/proc/get_global_map_pos()
	if(!islist(global_map) || isemptylist(global_map))
		return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=global_map.len,cur_x++)
		y_arr = global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	to_chat(world, "X = [cur_x]; Y = [cur_y]")
	if(cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0

/atom/movable/proc/checkpass(passflag)
	return pass_flags&passflag

/datum/proc/setGender(gend = FEMALE)
	if(!("gender" in vars))
		CRASH("The [src] doesn't have a gender variable.")
	if(ishuman(src))
		ASSERT(gend != PLURAL && gend != NEUTER)
	src:gender = gend

/atom/setGender(gend = FEMALE)
	gender = gend

/mob/living/carbon/human/setGender(gend = FEMALE)
	if(species.gender)	//species-level gender override
		gend = species.gender
	else if(gend == PLURAL || gend == NEUTER || (gend != FEMALE && gend != MALE))
		CRASH("SOMEBODY SET A BAD GENDER ON [src] [gend]")
	// var/old_gender = src.gender
	src.gender = gend
	// testing("Set [src]'s gender to [gend], old gender [old_gender] previous gender [prev_gender]")

/atom/proc/mop_act(obj/item/weapon/mop/M, mob/user)
	return 0

/atom/proc/change_area(var/area/oldarea, var/area/newarea)
	change_area_name(oldarea.name, newarea.name)

/atom/proc/change_area_name(var/oldname, var/newname)
	name = replacetext(name,oldname,newname)

//Called in /spell/aoe_turf/boo/cast() (code/modules/mob/dead/observer/spells.dm)
/atom/proc/spook(mob/dead/observer/ghost, var/log_this = FALSE)
	if(!can_spook())
		return 0
	if(log_this)
		investigation_log(I_GHOST, "|| was Boo!'d by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
	return 1

/atom/proc/can_spook(var/msg = 1)
	if(blessed)
		if(msg)
			to_chat(usr, "Your hand goes right through \the [src]... Is that some holy water dripping from it?")
		return FALSE
	return TRUE

/mob/var/list/atom/arcane_tampered_atoms = list()

/atom/proc/arcane_act(var/mob/user, var/recursive = FALSE)
	if(user)
		arcanetampered = user
		user.arcane_tampered_atoms.Add(src)
	else
		arcanetampered = TRUE
	if(recursive)
		for(var/atom/A in contents)
			A.arcane_act(user,TRUE)
	return "E'MAGI!"

//Called on holy_water's reaction_obj()
/atom/proc/bless()
	if(arcanetampered)
		if(ismob(arcanetampered))
			var/mob/M = arcanetampered
			M.arcane_tampered_atoms.Remove(src)
		arcanetampered = FALSE
		visible_message("<span class='sinister'>The arcane properties of \the [src] vanish!</span>")
		for(var/atom/A in contents)
			A.bless()
	blessed = 1

/atom/proc/update_icon()

/atom/proc/add_overlay(overlay_appearances)
	overlays += overlay_appearances

/atom/proc/cut_overlay(overlay_appearances)
	overlays -= overlay_appearances

/atom/proc/splashable()
	return TRUE

/obj/item/weapon/storage/splashable() // I don't know where to put this, aaaaaaaaaaaaaa
	return FALSE

/atom/proc/dissolvable()
	return 0

/atom/proc/salt_act()
	return

/atom/proc/acid_melt()
	return

/atom/proc/get_inaccuracy(var/atom/target, var/spread, var/obj/mecha/chassis)
	var/turf/targloc = get_turf(target)
	if(!spread)
		return target
	var/turf/curloc = get_turf(src)
	var/list/turf/shot_spread = list()
	for(var/turf/T in trange(min(spread, max(0, get_dist(curloc, targloc)-1)), targloc))
		if(chassis)
			var/dir_to_targ = get_dir(chassis, T)
			if(dir_to_targ && !(dir_to_targ & chassis.dir))
				continue
		shot_spread += T
	var/turf/newtarget = pick(shot_spread)
	if(newtarget == targloc)
		return target
	return newtarget

/atom/proc/animationBolt(var/mob/firer)
	return

//Called when loaded by the map loader
/atom/proc/spawned_by_map_element(datum/map_element/ME, list/objects)
	return

/atom/proc/toggle_timeless()
	flags ^= TIMELESS
	return flags & TIMELESS

/atom/proc/is_visible()
	if(invisibility || alpha <= 1)
		return FALSE
	else
		return TRUE


/atom/proc/get_last_player_touched()	//returns a reference to the mob of the ckey that last touched the atom
	for(var/client/C in clients)
		if(uppertext(C.ckey) == uppertext(fingerprintslast))
			return C.mob

/atom/initialize()
	if(canSmoothWith())
		relativewall()
	flags |= ATOM_INITIALIZED

/atom/proc/get_cell()
	return

/atom/proc/on_syringe_injection(var/mob/user, var/obj/item/weapon/reagent_containers/syringe/tool)
	if(!reagents)
		return INJECTION_RESULT_FAIL
	if(reagents.is_full())
		to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		return INJECTION_RESULT_FAIL
	return INJECTION_RESULT_SUCCESS

/atom/proc/is_hot()
	return

/atom/proc/thermal_energy_transfer()
	return

/atom/proc/update_keep_together()
	appearance_flags &= ~KEEP_TOGETHER
	if(length(keep_together_sources))
		appearance_flags |= KEEP_TOGETHER

/atom/proc/suitable_colony()
	return FALSE

//Used for map persistence. Returns an associative list with some of our most pertinent variables. This list will be used ad-hoc by our relevant map_persistence_type datum to reconstruct this atom from scratch.
/atom/proc/atom2mapsave()
	. = list()
	.["x"] = x
	.["y"] = y
	.["z"] = z
	.["type"] = type
	.["pixel_x"] = pixel_x
	.["pixel_y"] = pixel_y
	.["dir"] = dir
	.["icon_state"] = icon_state
	.["color"] = color
	.["age"] = getPersistenceAge() + 1

//We were just created using nothing but this associative list's ["x"], ["y"], ["z"] and ["type"]. OK, what else?
/atom/proc/post_mapsave2atom(var/list/L)
	return

//Behold, my shitty attempt at an interface in DM. Or at least skimping on 1 atom-level variable so I don't get blamed for wasting RAM.
/atom/proc/getPersistenceAge()
	return 1
/atom/proc/setPersistenceAge()
	return

//Called when a conveyor belt is pointing into us and an atom is coming in.
/atom/proc/conveyor_act(var/atom/movable/AM, var/obj/machinery/conveyor/CB)
	return

/atom/proc/contains(atom/A)
	if(!A)
		return FALSE
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return TRUE

/**
	Attempt to heat this object from a presumed heat source.
	@args:
		A: Atom: The source of the heat
		user: mob: Whomever may be trying to heat this object

	@return:
		TRUE if succesful
		FALSE if not succesful
		NULL if override not defined
**/
/atom/proc/attempt_heating(atom/A, mob/user)
	return

/atom/proc/process_temperature()
	return

/atom/proc/update_temperature_overlays()
	return

/atom/proc/on_vending_machine_spawn()
	return

/atom/proc/get_stain_text(colored_text = TRUE) //"blood-and-vomit-stained"
	if (blood_DNA?.len)
		var/stains[0]
		for (var/this_blood_DNA in blood_DNA)
			if (this_blood_DNA)
				var/stain_name = get_stain_name(blood_DNA[this_blood_DNA])
				if (stain_name)
					stains[stain_name]++
		if (stains.len)
			for (var/thisstain in stains)
				. += "[. ? "and-" : ""][thisstain]-"
			. += "stained"
			if (colored_text && blood_color)
				. = "<span style='color: [get_stain_text_color()]'>[.]</span>"

/atom/proc/get_stain_name(var/stain_type) //"AB+" -> "blood", "oil" -> "oil"
	if (findtextEx("A+A-B+B-AB+AB-O+O-", stain_type))
		return "blood"
	else if (stain_type == "N/A")
		return
	else
		return stain_type

/atom/proc/get_stain_text_color(var/stain_color)
	return ColorVClamp(stain_color ? stain_color : blood_color, DYNAMIC_TEXT_COLOR_V_MIN, DYNAMIC_TEXT_COLOR_V_MAX)

/atom/proc/a_stained(colored_text = TRUE)
	var/stain_text = get_stain_text(FALSE)
	var/indef_art = get_indefinite_article(stain_text, gender)
	if (colored_text && blood_color)
		stain_text = "<span style='color: [get_stain_text_color()]'>[stain_text]</span>"
	return indef_art + " " + stain_text

/atom/proc/get_heat_conductivity()
	return 1

/atom/proc/is_blood_stained()
	if (blood_color && blood_DNA && blood_DNA.len)
		return TRUE
	return FALSE

//Single overlay moody light
/atom/proc/update_moody_light(var/moody_icon = 'icons/lighting/moody_lights.dmi', var/moody_state = "white", var/moody_alpha = 255, var/moody_color = "#ffffff", var/offX = 0, var/offY = 0)
	overlays -= moody_light
	var/area/here = get_area(src)
	if (here && here.dynamic_lighting)
		moody_light = image(moody_icon, src, moody_state)
		moody_light.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
		moody_light.plane = LIGHTING_PLANE
		moody_light.blend_mode = BLEND_ADD
		moody_light.alpha = moody_alpha
		moody_light.color = moody_color
		moody_light.pixel_x = offX
		moody_light.pixel_y = offY
		overlays += moody_light
	luminosity = max(luminosity, 2)

/atom/proc/kill_moody_light()
	overlays -= moody_light
	luminosity = initial(luminosity)
	moody_light = null

//Multi-overlay moody lights. don't combine both procs on a single atom, use one or the other.
/atom/proc/update_moody_light_index(var/index, var/moody_icon = 'icons/lighting/moody_lights.dmi', var/moody_state = "white", var/moody_alpha = 255, var/moody_color = "#ffffff", var/offX = 0, var/offY = 0, var/image_override = null)
	if (!index)
		return
	if (isnull(moody_lights))
		moody_lights = list()
	if (index in moody_lights)
		overlays -= moody_lights[index]
	var/area/here = get_area(src)
	if (here && here.dynamic_lighting)
		if (image_override)
			moody_light = image_override
		else
			moody_light = image(moody_icon, src, moody_state)
		moody_light.appearance_flags |= RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM
		moody_light.plane = LIGHTING_PLANE
		moody_light.blend_mode = BLEND_ADD
		moody_light.alpha = moody_alpha
		moody_light.color = moody_color
		moody_light.pixel_x = offX
		moody_light.pixel_y = offY
		moody_lights[index] = moody_light
		overlays += moody_lights[index]
	luminosity = max(luminosity, 2)

/atom/proc/kill_moody_light_index(var/index)
	if (isnull(moody_lights))
		moody_lights = list()
	if (!index || !(index in moody_lights))
		return
	overlays -= moody_lights[index]
	moody_lights.Remove(index)
	if (moody_lights.len <= 0)
		luminosity = initial(luminosity)

/atom/proc/kill_moody_light_all()
	if (isnull(moody_lights))
		moody_lights = list()
	for (var/i in moody_lights)
		overlays -= moody_lights[i]
		moody_lights.Remove(i)
	luminosity = initial(luminosity)

/atom/proc/silicate_act(var/atom/A, var/mob/user)
	return FALSE

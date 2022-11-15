/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	flags = FPRINT
	layer = BELOW_OBJ_LAYER
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/opened = 0
	var/welded = 0
	var/locked = 0
	var/broken = 0
	var/large = 1
	var/pick_up_stuff = 1 // Pick up things that spawn at this location.
	var/wall_mounted = 0 //never solid (You can always pass over it)
	health = 100
	var/lastbang
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.
	var/breakout_time = 2 //2 minutes by default
	var/sound_file = 'sound/machines/click.ogg'
	var/required_quirk = MODULE_CAN_CLOSE_CLOSETS
	var/has_electronics = 0
	var/has_lock_type = null //The type this closet should be converted to if made ID secured
	var/has_lockless_type = null //The type this closet should be converted to if made no longer ID secured
	var/is_wooden = null //used in dismantling cabinet-type closets
	var/obj/item/weapon/circuitboard/airlock/electronics

	starting_materials = list(MAT_IRON = 2*CC_PER_SHEET_METAL)
	w_type = RECYK_METAL
	ignoreinvert = 1

	var/time_initialized_at = 0

/obj/structure/closet/splashable()
	return FALSE

/obj/structure/closet/New()
	..()
	if (has_lock_type)
		desc += " It has a slot for locking circuitry."
	else if (has_lockless_type)
		desc += " The locking circuitry could be unmounted if unlocked."
	if(ticker && ticker.current_state >= GAME_STATE_PLAYING)
		initialize()

// Returns null or a list of items to spawn
/obj/structure/closet/proc/atoms_to_spawn()
	return null

// Creates the items this closet is supposed to contain and places them inside
// Override this if you need custom logic
/obj/structure/closet/proc/spawn_contents()
	var/list/to_spawn = atoms_to_spawn()
	for(var/path in to_spawn)
		var/amount = to_spawn[path] || 1
		for(var/i in 1 to amount)
			var/atom/A = new path(src)
			A.initialize()  // recursive

/obj/structure/closet/basic
	has_lock_type = /obj/structure/closet/secure_closet/basic

/obj/structure/closet/proc/canweld()
	if(is_wooden)
		return 0
	else
		return 1

/obj/structure/closet/initialize()
	..()
	if (!time_initialized_at)
		time_initialized_at = world.time
		spawn_contents()
	else
		//haha, so you'd like to initialize twice huh? you got some explaining to do kid.
		message_admins("[src] at ([x],[y],[z]) tried to initialize at time = [world.time] despite having already initialized at time = [time_initialized_at]")
		ASSERT(!time_initialized_at)
		return
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		if(!ticker || ticker.current_state < GAME_STATE_PLAYING)
			take_contents()
	else
		setDensity(FALSE)

/obj/structure/closet/spawned_by_map_element()
	..()
	take_contents()

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/proc/can_open()
	if(src.welded)
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && !closet.wall_mounted)
			return 0

	for(var/mob/living/carbon/carbon in src.loc)
		if (carbon.mutual_handcuffs)
			if (carbon.mutual_handcuffed_to.loc == src.loc || carbon.loc == src.loc)
				return 0
	return 1

/obj/structure/closet/proc/dump_contents()
	if(usr)
		var/mob/living/L = usr
		var/obj/machinery/power/supermatter/SM = locate() in contents
		if(istype(SM))
			message_admins("[L.name] ([L.ckey]) opened \the [src] that contained supermatter (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[L.x];Y=[L.y];Z=[L.z]'>JMP</a>)")
			log_game("[L.name] ([L.ckey]) opened \the [src] that contained supermatter (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[L.x];Y=[L.y];Z=[L.z]'>JMP</a>)")


	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src)
		AD.forceMove(src.loc)

	for(var/obj/O in src)
		if(O != src.electronics) //Don't dump your electronics
			O.forceMove(src.loc)

	for(var/mob/M in src)
		M.forceMove(src.loc)
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/closet/proc/take_contents()
	for(var/atom/movable/AM in src.loc)
		if(insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open(mob/user)
	if(src.opened)
		return 0

	if(!src.can_open())
		return 0

	src.icon_state = src.icon_opened
	src.opened = 1
	setDensity(FALSE)
	src.dump_contents()
	playsound(src, sound_file, 15, 1, -3)
	if(arcanetampered)
		src.insert(user)
		if(src.close())
			if(src.canweld())
				src.welded =! src.welded
			src.update_icon()
	return 1

/obj/structure/closet/proc/insert(var/atom/movable/AM)


	if(contents.len >= storage_capacity)
		return -1

	// Prevent AIs from being crammed into lockers. /vg/ Redmine #153 - N3X
	if(istype(AM, /mob/living/silicon/ai) || istype(AM, /mob/living/simple_animal/scp_173))
		return 0

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.locked_to)
			return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
	else if(!istype(AM, /obj/item) && !istype(AM, /obj/effect/dummy/chameleon))
		return 0
	else if(AM.density || AM.anchored || istype(AM,/obj/structure/closet))
		return 0
	AM.forceMove(src)
	return 1

/obj/structure/closet/proc/close(mob/user)
	if(!src.opened)
		return 0
	if(!src.can_close())
		return 0

	take_contents()

	/* /vg/: Delete if there's no code in here we need.
	var/itemcount = 0

	//Cham Projector Exception
	for(var/obj/effect/dummy/chameleon/AD in src.loc)
		if(itemcount >= storage_capacity)
			break
		AD.forceMove(src)
		itemcount++

	for(var/obj/item/I in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(!I.anchored)
			I.forceMove(src)
			itemcount++

	for(var/mob/M in src.loc)
		if(itemcount >= storage_capacity)
			break
		if(istype (M, /mob/dead/observer))
			continue
		if(M.locked_to)
			continue

		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src

		M.forceMove(src)
		itemcount++
	*/
	src.icon_state = src.icon_closed
	src.opened = 0
	setDensity(initial(density))
	playsound(src, sound_file, 15, 1, -3)
	return 1

/obj/structure/closet/proc/toggle(mob/user)
	if(src.opened)
		return src.close(user)
	return src.open(user)

/obj/structure/closet/proc/add_lock(var/obj/item/weapon/circuitboard/airlock/E, var/mob/user)
	if(has_lock_type && !electronics && E && E.icon_state != "door_electronics_smoked")
		E.playtoolsound(src, 100)
		user.visible_message("[user] is installing electronics on \the [src].", "You start to install electronics into \the [src].")
		if(do_after(user, src, 40))
			var/obj/structure/closet/new_closet
			new_closet = change_type(has_lock_type)

			if(new_closet)
				if(!(user.drop_item(E, new_closet)))
					return //Abort if we can't drop the electronics for some reason (eg. Superglue)

				to_chat(user, "<span class='notice'>You installed the electronics!</span>")
				new_closet.electronics = E
				E.installed = 1

				if(E.one_access)
					new_closet.req_access = null
					new_closet.req_one_access = E.conf_access
				else
					new_closet.req_access = E.conf_access

				new_closet.locked = 0
				new_closet.update_icon()
			else
				//Should not happen
				to_chat(user, "<span class='notice'>Wierd, the electronics won't fit.</span>")
	else if(!has_lock_type)
		to_chat(user, "<span class='notice'>There's no slot for the electronics</span>")


/obj/structure/closet/proc/remove_lock(var/mob/user)
	if(has_lockless_type)
		electronics.playtoolsound(src, 100)
		user.visible_message("[user] is removing \the [src]'s electronics.", "You start removing \the [src]'s electronics.")
		if(do_after(user, src, 40))
			var/obj/structure/closet/new_closet
			new_closet = change_type(has_lockless_type)

			if(new_closet)
				new_closet.dump_electronics()
				new_closet.broken = 0
				new_closet.locked = 0
				new_closet.update_icon()
			else
				//Should not happen
				to_chat(user, "<span class='notice'>Weird, you can't get the electronics out.</span>")
	else
		to_chat(user, "<span class='notice'>You can't get the electronics out</span>")

/obj/structure/closet/proc/dump_electronics()
	var/obj/item/weapon/circuitboard/airlock/E
	if (!electronics)
		E = new/obj/item/weapon/circuitboard/airlock(loc)
		if(req_access && req_access.len)
			E.conf_access = req_access
		else if(req_one_access && req_one_access.len)
			E.conf_access = req_one_access
			E.one_access = 1
	else
		E = electronics
		electronics = null
		E.forceMove(loc)
		E.installed = 0

	if (broken == 1)
		E.icon_state = "door_electronics_smoked"

	req_access = null
	req_one_access = null

	return E



// Might come handy for painting crates and lockers some day.
// Using it to change from secure to non secure lockers for now
/obj/structure/closet/proc/change_type(var/new_type)
	ASSERT(new_type)//Ensure it's not null

	var/obj/structure/closet/new_closet = new new_type(loc)

	new_closet.contents = src.contents

	new_closet.broken = src.broken
	new_closet.welded = src.welded
	new_closet.locked = src.locked

	new_closet.fingerprints = src.fingerprints
	new_closet.fingerprintshidden = src.fingerprintshidden

	new_closet.electronics = src.electronics
	new_closet.req_access = src.req_access
	new_closet.req_one_access = src.req_one_access

	new_closet.update_icon()

	qdel(src)
	return new_closet

// this should probably use dump_contents()
/obj/structure/closet/ex_act(severity)
	var/obj/item/weapon/circuitboard/airlock/E
	switch(severity)
		if(1)
			broken = 1
			if(has_electronics)//If it's got electronics, generate them/pull them out
				E = dump_electronics()
				E.forceMove(src)
			for(var/atom/movable/A in src)//pulls everything else out of the locker and hits it with an explosion
				A.forceMove(src.loc)
				A.ex_act(severity++)
			dump_contents()
			qdel(src)
		if(2)
			if(prob(50))
				broken = 1
				if(has_electronics)
					E = dump_electronics()
					E.forceMove(src)
				for (var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity++)
				dump_contents()
				qdel(src)
		if(3)
			if(prob(5))
				broken = 1
				if(has_electronics)
					E = dump_electronics()
					E.forceMove(src)
				for(var/atom/movable/A as mob|obj in src)
					A.forceMove(src.loc)
					A.ex_act(severity++)
				dump_contents()
				qdel(src)

/obj/structure/closet/shuttle_act()
	for(var/atom/movable/AM in contents)
		AM.forceMove(src.loc)
		AM.shuttle_act()

	..()

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	. = ..()
	if(health <= 0)
		broken = 1
		if(has_electronics)
			dump_electronics()
		dump_contents()
		qdel(src)

	return

/obj/structure/closet/beam_connect(var/obj/effect/beam/B)
	if(!processing_objects.Find(src))
		processing_objects.Add(src)
//		testing("Connected [src] with [B]!")
	return ..()

/obj/structure/closet/beam_disconnect(var/obj/effect/beam/B)
	..()
	if(beams.len==0)
		// I hope to christ this doesn't break shit.
		processing_objects.Remove(src)

/obj/structure/closet/process()
	//..()
	for(var/obj/effect/beam/B in beams)
		health -= B.get_damage()

	if(health <= 0)
		broken = 1
		if(has_electronics)
			dump_electronics()
		dump_contents()
		qdel(src)

// This is broken, see attack_ai.
/obj/structure/closet/attack_robot(mob/living/silicon/robot/user as mob)
	if(isMoMMI(user) || HAS_MODULE_QUIRK(user, required_quirk))
		src.add_hiddenprint(user)
		add_fingerprint(user)
		return src.attack_hand(user)
	..(user)

/obj/machinery/closet/attack_ai(mob/user as mob)
	if(isMoMMI(user))
		src.add_hiddenprint(user)
		add_fingerprint(user)
		return src.attack_hand(user)
	..(user)

/obj/structure/closet/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash_flags & SMASH_CONTAINERS)
//		user.do_attack_animation(src, user) //This will look stupid
		visible_message("<span class='warning'>[user] destroys the [src]. </span>")
		broken = 1
		if(has_electronics)
			dump_electronics()
		dump_contents()
		qdel(src)

// this should probably use dump_contents()
/obj/structure/closet/blob_act()
	anim(target = loc, a_icon = 'icons/mob/blob/blob.dmi', flick_anim = "blob_act", sleeptime = 15, lay = 12)
	if(prob(75))
		broken = 1
		if(has_electronics)
			dump_electronics()
		dump_contents()
		qdel(src)

/obj/structure/closet/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(src.opened)
		if(istype(W, /obj/item/weapon/grab))
			if(src.large)
				var/obj/item/weapon/grab/G = W
				src.MouseDropTo(G.affecting, user)	//act like they were dragged onto the closet
			else
				to_chat(user, "<span class='notice'>The locker is too small to stuff [W] into!</span>")
		if(istype(W,/obj/item/tk_grab))
			return 0

		if(iswelder(W) && canweld())
			var/obj/item/tool/weldingtool/WT = W
			if(!WT.remove_fuel(1,user))
				return
			materials.makeSheets(src)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been cut apart by [user] with \the [WT].</span>", 1, "You hear welding.", 2)
			if(has_electronics)
				dump_electronics()
			dump_contents()
			qdel(src)
			return

		if((istype(W, /obj/item/tool/crowbar)) && is_wooden)
			var/obj/item/tool/crowbar/WT = W
			materials.makeSheets(src)
			for(var/mob/M in viewers(src))
				M.show_message("<span class='notice'>\The [src] has been dismantled by [user] with \the [WT].</span>", 1)
			if(has_electronics)
				dump_electronics()
			dump_contents()
			qdel(src)
			return

		user.drop_item(W, src.loc)

	else if(istype(W, /obj/item/stack/package_wrap))
		return
	else if(iswelder(W) && canweld())
		var/obj/item/tool/weldingtool/WT = W
		if(!WT.remove_fuel(1,user))
			return
		src.welded =! src.welded
		src.update_icon()
		for(var/mob/M in viewers(src))
			M.show_message("<span class='warning'>[src] has been [welded?"welded shut":"unwelded"] by [user.name].</span>", 1, "You hear welding.", 2)
	else if(istype(W, /obj/item/weapon/circuitboard/airlock) && src.has_lock_type) //testing with crowbars for now, will use circuits later
		add_lock(W, user)
		return
	else if(!place(user, W))
		src.attack_hand(user)
	return

/obj/structure/closet/proc/place(var/mob/user, var/obj/item/I)
	return 0

/obj/structure/closet/MouseDropTo(atom/movable/O, mob/user, var/needs_opened = 1, var/show_message = 1, var/move_them = 1)
	if(!isturf(O.loc))
		return 0
	if(user.incapacitated())
		return 0
	if((!( istype(O, /atom/movable) ) || O.anchored || !user.Adjacent(O) || !user.Adjacent(src)))
		return 0
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc? Will also check for null loc
		return 0
	if(needs_opened && !src.opened)
		return 0
	if(istype(O, /obj/structure/closet))
		return 0
	if(move_them)//We've already checked for adjacency so it's fine to use forceMove, it also guarrantees that they won't bump into us?
		O.forceMove(user.loc)
		sleep(1)
		O.forceMove(src.loc)
	if(show_message && user != O)
		user.show_viewers("<span class='danger'>[user] stuffs [O] into [src]!</span>")
	src.add_fingerprint(user)
	return 1

/obj/structure/closet/relaymove(mob/user as mob)
	if(user.stat || !isturf(src.loc))
		return

	if(!src.open(user))
		if(!lastbang)
			to_chat(user, "<span class='notice'>It won't budge!</span>")
			lastbang = 1
			for (var/mob/M in hearers(src, null))
				to_chat(M, text("<FONT size=[]>BANG, bang!</FONT>", max(0, 5 - get_dist(src, M))))
			spawn(30)
				lastbang = 0


/obj/structure/closet/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/closet/attack_hand(mob/user as mob)
	if(!Adjacent(user))
		return
	src.add_fingerprint(user)

	var/mob/living/L = user
	if(src.opened==0 && L && L.client && L.hallucinating()) //If the closet is CLOSED and user is hallucinating
		if(prob(10))
			var/client/C = L.client
			var/image/temp_overlay = image(src.icon, icon_state=src.icon_opened) //Get the closet's OPEN icon
			temp_overlay.override = 1
			temp_overlay.loc = src

			var/image/spooky_overlay
			switch(rand(0,5))
				if(0)
					spooky_overlay = image('icons/mob/animal.dmi',icon_state="hunter",dir=turn(L.dir,180))
				if(1)
					spooky_overlay = image('icons/mob/animal.dmi',icon_state="zombie",dir=turn(L.dir,180))
				if(2)
					spooky_overlay = image('icons/mob/horror.dmi',icon_state="horror_[pick("male","female")]",dir=turn(L.dir,180))
				if(3)
					spooky_overlay = image('icons/mob/animal.dmi',icon_state="faithless",dir=turn(L.dir,180))
				if(4)
					spooky_overlay = image('icons/mob/animal.dmi',icon_state="carp",dir=turn(L.dir,180))
				if(5)
					spooky_overlay = image('icons/mob/animal.dmi',icon_state="skelly",dir=turn(L.dir,180))

			if(!spooky_overlay)
				return

			temp_overlay.overlays += spooky_overlay

			C.images += temp_overlay
			L << sound('sound/machines/click.ogg')
			L << sound('sound/hallucinations/scary.ogg')
			L.Knockdown(5)
			L.Stun(5)

			sleep(50)

			if(C)
				C.images -= temp_overlay
			return

	if(!src.toggle(user))
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user as mob)
	src.add_fingerprint(user)

	if(!src.toggle(user))
		to_chat(usr, "<span class='notice'>It won't budge!</span>")

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(usr.incapacitated())
		return

	if (isrobot(usr))
		var/mob/living/silicon/robot/R = usr
		if(isMoMMI(R) || HAS_MODULE_QUIRK(R, required_quirk))
			src.attack_robot(R)
			return

	if(ishuman(usr))
		src.attack_hand(usr)
		return

	to_chat(usr, "<span class='warning'>You can't toggle the open state of [src].</span>")

/obj/structure/closet/update_icon()//Putting the welded stuff in updateicon() so it's easy to overwrite for special cases (Fridges, cabinets, and whatnot)
	overlays.len = 0
	if(!opened)
		icon_state = icon_closed
		if(welded)
			overlays += image(icon = icon, icon_state = "welded")
	else
		icon_state = icon_opened

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open(AM)
	if(AM.loc == src)
		return 0
	return 1

/obj/structure/closet/proc/on_do_after(mob/user, use_user_turf, user_original_location, atom/target, target_original_location, needhand, obj/item/originally_held_item)
	. = do_after_default_checks(arglist(args))
	if(.)
		shake_closet()


/obj/structure/closet/proc/shake_closet()
	shake_animation(3, 3, 0.2, 15)
	playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
	spawn(2)
		playsound(src, 'sound/effects/grillehit.ogg', 50, 1)
		spawn(2)
			playsound(src, 'sound/effects/grillehit.ogg', 50, 1)


/obj/structure/closet/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"opened",
		"welded",
		"locked",
		"broken",
		"health")

	reset_vars_after_duration(resettable_vars, duration)

/obj/structure/closet/examine(mob/user)
	..()
	if(!opened && isobserver(user) && !istype(user,/mob/dead/observer/deafmute)) //Fuck off phantom mask users
		var/mob/dead/observer/ghost = user
		if(!isAdminGhost(ghost) && ghost.mind && ghost.mind.current)
			if(ghost.mind.isScrying || ghost.mind.current.ajourn) //Scrying or astral travel, fuck them.
				return
		to_chat(ghost, "It contains: <span class='info'>[counted_english_list(contents)]</span>.")
		investigation_log(I_GHOST, "|| had its contents checked by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")




// -- Vox raiders.

/obj/structure/closet/loot
	name = "Loot closet"
	desc = "Store the valuables here for a direct transfer to the shoal. We make much bluespace."

/obj/structure/closet/loot/Destroy()
	for (var/datum/faction/vox_shoal/VS in ticker.mode.factions)
		VS.our_bounty_lockers -= src
	return ..()

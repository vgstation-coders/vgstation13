// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/weapon/storage
	name = "storage"
	icon = 'icons/obj/storage/storage.dmi'
	w_class = W_CLASS_MEDIUM

	// These two accept a string containing the type path and the following optional prefixes:
	//  = - Strict type matching.  Will NOT check for subtypes.
	var/list/can_only_hold = new/list() //List of objects which this item can store (if set, it can't store anything else)
	var/list/cant_hold = new/list() //List of objects which this item can't store (in effect even if can_only_hold is set)
	var/list/fits_ignoring_w_class = new/list() //List of objects which will fit in this item, regardless of size. Doesn't restrict to ONLY items of these types, and doesn't ignore max_combined_w_class. (in effect even if can_only_hold isn set)
	var/list/is_seeing = new/list() //List of mobs which are currently seeing the contents of this item's storage
	var/fits_max_w_class = W_CLASS_SMALL //Max size of objects that this object can store (in effect even if can_only_hold is set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 7 //The number of storage slots in this container.
	var/obj/abstract/screen/storage/boxes = null
	var/obj/abstract/screen/close/closer = null
	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/foldable = null	// BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	var/foldable_amount = 1 // Number of foldables to produce, if any - N3X
	var/internal_store = 0

/obj/item/weapon/storage/MouseDrop(obj/over_object as obj)
	if (ishuman(usr) || ismonkey(usr)) //so monkeys can take off their backpacks -- Urist
		var/mob/M = usr
		if(istype(over_object, /obj/structure/table) && M.Adjacent(over_object) && Adjacent(M))
			var/mob/living/L = usr
			if(istype(L) && !(L.incapacitated() || L.lying))
				empty_contents_to(over_object)

		if(!( istype(over_object, /obj/abstract/screen/inventory) ))
			return ..()

		if(!(src.loc == usr) || (src.loc && src.loc.loc == usr))
			return

		playsound(get_turf(src), "rustle", 50, 1, -5)
		if(!( M.restrained() ) && !( M.stat ))
			var/obj/abstract/screen/inventory/OI = over_object

			if(OI.hand_index && M.put_in_hand_check(src, OI.hand_index))
				M.u_equip(src, 0)
				M.put_in_hand(OI.hand_index, src)
				src.add_fingerprint(usr)

			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if (usr.s_active)
				usr.s_active.close(usr)
			src.show_to(usr)
			return
	return

/obj/item/weapon/storage/proc/empty_contents_to(var/atom/place)
	var/turf = get_turf(place)
	for(var/obj/objects in contents)
		remove_from_storage(objects, turf)
		objects.pixel_x = rand(-6,6) * PIXEL_MULTIPLIER
		objects.pixel_y = rand(-6,6) * PIXEL_MULTIPLIER

/obj/item/weapon/storage/proc/return_inv()


	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/weapon/storage/proc/show_to(mob/user as mob)
	if(!user.incapacitated())
		if(user.s_active != src)
			for(var/obj/item/I in src)
				if(I.on_found(user))
					return
	if(user.s_active)
		user.s_active.hide_from(user)
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.contents
	user.s_active = src
	is_seeing |= user
	return

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)


	if(!user.client)
		return
	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.contents
	if(user.s_active == src)
		user.s_active = null
	is_seeing -= user
	return

/obj/item/weapon/storage/proc/close(mob/user as mob)


	src.hide_from(user)
	user.s_active = null
	return

//This proc draws out the inventory and places the items on it. tx and ty are the upper left tile and mx, my are the bottm right.
//The numbers are calculated from the bottom-left The bottom-left slot being 1,1.
/obj/item/weapon/storage/proc/orient_objs(tx, ty, mx, my)
	var/cx = tx
	var/cy = ty
	src.boxes.screen_loc = "[tx],[ty] to [mx],[my]"
	for(var/obj/O in src.contents)
		O.screen_loc = "[cx],[cy]"
		O.hud_layerise()
		cx++
		if (cx > mx)
			cx = tx
			cy--
	src.closer.screen_loc = "[mx+1],[my]"
	return

//This proc draws out the inventory and places the items on it. It uses the standard position.
/obj/item/weapon/storage/proc/standard_orient_objs(var/rows, var/cols, var/list/obj/item/display_contents)
	var/cx = 4
	var/cy = 2+rows
	src.boxes.screen_loc = "4:[WORLD_ICON_SIZE/2],2:[WORLD_ICON_SIZE/2] to [4+cols]:[WORLD_ICON_SIZE/2],[2+rows]:[WORLD_ICON_SIZE/2]"

	if(display_contents_with_number)
		for(var/datum/numbered_display/ND in display_contents)
			ND.sample_object.mouse_opacity = 2
			ND.sample_object.screen_loc = "[cx]:[WORLD_ICON_SIZE/2],[cy]:[WORLD_ICON_SIZE/2]"
			ND.sample_object.maptext = "<font color='white'>[(ND.number > 1)? "[ND.number]" : ""]</font>"
			ND.sample_object.hud_layerise()
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	else
		for(var/obj/O in contents)
			O.mouse_opacity = 2 //This is here so storage items that spawn with contents correctly have the "click around item to equip"
			O.screen_loc = "[cx]:[WORLD_ICON_SIZE/2],[cy]:[WORLD_ICON_SIZE/2]"
			O.maptext = ""
			O.hud_layerise()
			cx++
			if (cx > (4+cols))
				cx = 4
				cy--
	src.closer.screen_loc = "[4+cols+1]:[WORLD_ICON_SIZE/2],2:[WORLD_ICON_SIZE/2]"
	return

/datum/numbered_display
	var/obj/item/sample_object
	var/number

	New(obj/item/sample as obj)
		if(!istype(sample))
			qdel(src)
			return
		sample_object = sample
		number = 1

//This proc determins the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/weapon/storage/proc/orient2hud(mob/user as mob)


	var/adjusted_contents = contents.len

	//Numbered contents display
	var/list/datum/numbered_display/numbered_contents
	if(display_contents_with_number)
		numbered_contents = list()
		adjusted_contents = 0
		for(var/obj/item/I in contents)
			var/found = 0
			for(var/datum/numbered_display/ND in numbered_contents)
				if(ND.sample_object.type == I.type)
					ND.number++
					found = 1
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add( new/datum/numbered_display(I) )

	//var/mob/living/carbon/human/H = user
	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if (adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	src.standard_orient_objs(row_num, col_count, numbered_contents)
	return

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/weapon/storage/proc/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(!istype(W))
		return //Not an item

	if(src.loc == W)
		return 0 //Means the item is already in the storage item
	if(contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [src] is full, make some space.</span>")
		return 0 //Storage item is full
	if(usr && (W.cant_drop > 0))
		if(!stop_messages)
			usr << "<span class='notice'>You can't let go of \the [W]!</span>"
		return 0 //Item is stuck to our hands

	if(W.wielded || istype(W, /obj/item/offhand))
		var/obj/item/offhand/offhand = W
		var/obj/item/ref_name = W
		if(istype(offhand))
			ref_name = offhand.wielding
		to_chat(usr, "<span class='notice'>Unwield \the [ref_name] first.</span>")
		return

	if(can_only_hold.len)
		var/ok = 0
		for(var/A in can_only_hold)
			if(dd_hasprefix(A,"="))
				// Force strict matching of type.
				// No subtypes allowed.
				if("[W.type]"==copytext(A,2))
					ok = 1
					break
			else if(istype(W, text2path(A) ))
				ok = 1
				break
			else if(fits_ignoring_w_class.len)
				for(var/B in fits_ignoring_w_class)
					if(dd_hasprefix(B,"="))
						// Force strict matching of type.
						// No subtypes allowed.
						if("[W.type]"==copytext(B,2))
							ok = 1
							break
					else if(istype(W, text2path(B) ))
						ok = 1
						break

		if(!ok)
			if(!stop_messages)
				if (istype(W, /obj/item/weapon/hand_labeler))
					return 0
				to_chat(usr, "<span class='notice'>\The [src] cannot hold \the [W].</span>")
			return 0

	for(var/A in cant_hold) //Check for specific items which this container can't hold.
		var/nope=0
		if(dd_hasprefix(A,"="))
			// Force strict matching of type.
			// No subtypes allowed.
			if("[W.type]"==copytext(A,2))
				nope = 1
		else if(istype(W, text2path(A) ))
			nope = 1
		if(nope)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>\The [src] cannot hold \the [W].</span>")
			return 0

	if (W.w_class > fits_max_w_class)
		var/yeh = 0
		if(fits_ignoring_w_class.len)
			for(var/A in fits_ignoring_w_class)
				if(dd_hasprefix(A,"="))
					// Force strict matching of type.
					// No subtypes allowed.
					if("[W.type]"==copytext(A,2))
						yeh = 1
						break
				else if(istype(W, text2path(A) ))
					yeh = 1
					break
		if(!yeh)
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>\The [W] is too big for \the [src].</span>")
			return 0

	var/sum_w_class = W.w_class
	for(var/obj/item/I in contents)
		sum_w_class += I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.

	if(sum_w_class > max_combined_w_class)
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [src] is full, make some space.</span>")
		return 0

	if(W.w_class >= src.w_class && (istype(W, /obj/item/weapon/storage)))
		if(!istype(src, /obj/item/weapon/storage/backpack/holding))	//bohs should be able to hold backpacks again. The override for putting a boh in a boh is in backpack.dm.
			if(!stop_messages)
				to_chat(usr, "<span class='notice'>\The [src] cannot hold \the [W] as it's a storage item of the same size.</span>")
			return 0 //To prevent the stacking of same sized storage items.

	return 1

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/weapon/storage/proc/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	if(!istype(W))
		return 0
	if(usr)
		usr.u_equip(W,0)
		usr.update_icons()	//update our overlays
	W.forceMove(src)
	W.on_enter_storage(src)
	if(usr)
		if (usr.client && usr.s_active != src)
			usr.client.screen -= W
		//W.dropped(usr)
		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/weapon/gun/energy/crossbow))
			for(var/mob/M in viewers(usr, null))
				if (M == usr)
					to_chat(usr, "<span class='notice'>You put \the [W] into \the [src].</span>")
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is...
					M.show_message("<span class='notice'>[usr] puts \the [W] into \the [src].</span>")
				else if (W.w_class >= W_CLASS_MEDIUM) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>[usr] puts \the [W] into \the [src].</span>")

		src.orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	W.mouse_opacity = 2 //So you can click on the area around the item to equip it, instead of having to pixel hunt
	update_icon()
	return 1

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
//force needs to be 1 if you want to override the can_be_inserted() if the target's a storage item.
/obj/item/weapon/storage/proc/remove_from_storage(obj/item/W as obj, atom/new_location, var/force = 0)
	if(!istype(W))
		return 0

	if(!force && istype(new_location, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/A = new_location
		if(!A.can_be_inserted(W, 1))
			return 0

	if(istype(src, /obj/item/weapon/storage/fancy))
		var/obj/item/weapon/storage/fancy/F = src
		F.update_icon(1)

	for(var/mob/M in range(1, get_turf(src)))
		if (M.s_active == src)
			if (M.client)
				M.client.screen -= W

	if(new_location)
		var/mob/M
		if(ismob(loc))
			M = loc
			W.dropped(M)
		if(ismob(new_location))
			M = new_location
			M.put_in_active_hand(W)
		else
			if(istype(new_location, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/A = new_location
				A.handle_item_insertion(W, 1)
			else
				W.forceMove(new_location)
	else
		W.forceMove(get_turf(src))

	if(usr)
		src.orient2hud(usr)
		if(usr.s_active)
			usr.s_active.show_to(usr)
	if(W.maptext)
		W.maptext = ""
	W.reset_plane_and_layer()
	W.on_exit_storage(src)
	update_icon()
	W.mouse_opacity = initial(W.mouse_opacity)
	return 1

//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/W as obj, mob/user as mob)
	if(!Adjacent(user,MAX_ITEM_DEPTH))
		return
	..()

	// /vg/ #11: Recursion.
	/*if(istype(W,/obj/item/weapon/implanter/compressed))
		return*/

	if(isrobot(user))
		if(isMoMMI(user))
			var/mob/living/silicon/robot/mommi/M = user
			if(M.is_in_modules(W))
				to_chat(user, "<span class='notice'>You can't throw away something built into you.</span>")
				return //Mommis cant give away their modules but can place other items
		else
			to_chat(user, "<span class='notice'>You're a robot. No.</span>")
			return //Robots can't interact with storage items.


	if(!can_be_inserted(W))
		return

	if(istype(W, /obj/item/weapon/tray))
		var/obj/item/weapon/tray/T = W
		if(T.calc_carry() > 0)
			if(prob(85))
				to_chat(user, "<span class='warning'>The tray won't fit in \the [src].</span>")
				return
			else
				user.drop_item(W, user.loc)
				to_chat(user, "<span class='warning'>God damnit!</span>")
				return

	return handle_item_insertion(W)

/obj/item/weapon/storage/dropped(mob/user as mob)
	..()

/obj/item/weapon/storage/MouseDrop(over_object, src_location, over_location)
	..()
	orient2hud(usr)
	if (over_object == usr && (in_range(src, usr) || is_holder_of(usr, src)))
		if (usr.s_active)
			usr.s_active.close(usr)
		src.show_to(usr)
	return

/obj/item/weapon/storage/attack_hand(mob/user as mob)
	playsound(get_turf(src), "rustle", 50, 1, -5)

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((H.l_store == src || H.r_store == src || H.head == src) && !H.get_active_hand())	//Prevents opening if it's in a pocket or head slot. Terrible kludge, I'm sorry.
			return ..()
	else if(isMoMMI(user))
		var/mob/living/silicon/robot/mommi/MoM = user
		if(MoM.head_state == src) //I'm so sorry. We have exactly one storage item that goes on head, and it can't hold any items while equipped. This is so you can actually take it off.
			return ..()

	src.orient2hud(user)
	var/atom/maxloc = src.loc
	if(src.internal_store)
		for(var/i = 1; i++ <= internal_store)
			if(maxloc == user)
				break
			if(maxloc.loc)
				maxloc = maxloc.loc
	if (maxloc == user)
		if (user.s_active)
			user.s_active.close(user)
		src.show_to(user)
	else
		..()
		for(var/mob/M in range(1))
			if (M.s_active == src)
				src.close(M)
	src.add_fingerprint(user)
	return

/obj/item/weapon/storage/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/weapon/storage/throw_at()
	close_all() //How are you going to see whats inside this thing while throwing it
	..()

/obj/item/weapon/storage/recycle(var/datum/materials/rec)
	if(contents)
		mass_remove(get_turf(src))
	return ..()

/obj/item/weapon/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			to_chat(usr, "\The [src] will now pick up all items on a tile at once.")
		if(0)
			to_chat(usr, "\The [src] will now pick up one item at a time.")


/obj/item/weapon/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.isUnconscious() || usr.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	mass_remove(T)

/obj/item/weapon/storage/New()
	. = ..()

	if(allow_quick_empty)
		verbs += /obj/item/weapon/storage/verb/quick_empty
	else
		verbs -= /obj/item/weapon/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/weapon/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/weapon/storage/verb/toggle_gathering_mode

	src.boxes = getFromPool(/obj/abstract/screen/storage)
	src.boxes.name = "storage"
	src.boxes.master = src
	src.boxes.icon_state = "block"
	src.boxes.screen_loc = "7,7 to 10,8"
	src.boxes.layer = HUD_BASE_LAYER
	src.closer = getFromPool(/obj/abstract/screen/close)
	src.closer.master = src
	src.closer.icon_state = "x"
	src.closer.layer = HUD_ITEM_LAYER
	orient2hud()

/obj/item/weapon/storage/emp_act(severity)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/item/weapon/storage/ex_act(var/severity,var/child=null)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.ex_act(severity)
	..()

// BubbleWrap - A box can be folded up to make card
/obj/item/weapon/storage/attack_self(mob/user as mob)

	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(src.verbs.Find(/obj/item/weapon/storage/verb/quick_empty))
			src.quick_empty()
			return

	//Otherwise we'll try to fold it.
	if ( contents.len )
		return

	if ( !ispath(src.foldable) )
		return
	var/found = 0
	// Close any open UI windows first
	for(var/mob/M in range(1))
		if (M.s_active == src)
			src.close(M)
		if ( M == user )
			found = 1
	if ( !found )	// User is too far away
		return
	// Now make the cardboard
	to_chat(user, "<span class='notice'>You fold \the [src] flat.</span>")
	new src.foldable(get_turf(src),foldable_amount)
	qdel(src)
//BubbleWrap END
/obj/item/weapon/storage/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == src && M.client)
			cansee |= M
		else
			is_seeing -= M
	return cansee

/obj/item/weapon/storage/proc/close_all()
	for(var/mob/M in is_seeing)
		close(M)
		. = 1 //returns 1 if any mobs actually got a close(M) call

/obj/item/weapon/storage/Destroy()
	close_all()
	returnToPool(boxes)
	returnToPool(closer)
	boxes = null
	closer = null
	for(var/atom/movable/AM in contents)
		qdel(AM)
	contents = null
	..()

/obj/item/weapon/storage/preattack(atom/target, mob/user, adjacent, params)
	if(!adjacent)
		return 0
	if(use_to_pickup)
		if(collection_mode) //Mode is set to collect all items on a tile and we clicked on a valid one.
			var/turf/gather_location
			if(isturf(target.loc))
				if(!can_be_inserted(target))
					return 0 //letting the click process continue
				gather_location = target.loc
			else if(isturf(target))
				gather_location = target
			else
				return 0
			var/list/rejections = list()
			var/success = 0
			var/failure = 0

			for(var/obj/item/I in gather_location)
				if(I.type in rejections) // To limit bag spamming: any given type only complains once
					continue
				if(I.anchored)
					continue
				if(!can_be_inserted(I))	// Note can_be_inserted still makes noise when the answer is no
					rejections += I.type	// therefore full bags are still a little spammy
					failure = 1
					continue
				success = 1
				handle_item_insertion(I, 1)	//The 1 stops the "You put the [target] into [src]" insertion message from being displayed.
			if(success && !failure)
				to_chat(user, "<span class='notice'>You put everything into \the [src].</span>")
				return 1
			else if(success)
				to_chat(user, "<span class='notice'>You put some things into \the [src].</span>")
				return 1
			else
				to_chat(user, "<span class='notice'>You fail to pick anything up with \the [src].</span>")
				return 0

		else if(can_be_inserted(target))
			handle_item_insertion(target)
			return 1
	return 0

/obj/item/weapon/storage/OnMobDeath(mob/wearer as mob)
	for(var/obj/item/I in contents)
		I.OnMobDeath(wearer)

/obj/item/weapon/storage/stripped(mob/wearer as mob, mob/stripper as mob)
	for(var/obj/item/I in contents)
		I.stripped(wearer,stripper)

/obj/item/weapon/storage/proc/mass_remove(var/atom/A)
	for(var/obj/item/O in contents)
		remove_from_storage(O, A)

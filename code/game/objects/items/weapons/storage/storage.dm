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
	var/list/items_to_spawn = new/list() //Preset list of items to spawn
	var/fits_max_w_class = W_CLASS_SMALL //Max size of objects that this object can store (in effect even if can_only_hold is set)
	var/max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	var/storage_slots = 0 //The number of storage slots in this container.
	var/obj/abstract/screen/storage/boxes = null
	var/obj/abstract/screen/storage/xtra = null //This is just an extra space that shows up when we have a full row, but we're not full yet.
	var/obj/abstract/screen/close/closer = null
	var/use_to_pickup	//Set this to make it possible to use this item in an inverse way, so you can have the item in your hand and click items on the floor to pick them up.
	var/display_contents_with_number	//Set this to make the storage item group contents of the same type and display them as a number.
	var/allow_quick_empty	//Set this variable to allow the object to have the 'empty' verb, which dumps all the contents on the floor.
	var/allow_quick_gather	//Set this variable to allow the object to have the 'toggle mode' verb, which quickly collects all items from a tile.
	var/collection_mode = 1;  //0 = pick one at a time, 1 = pick all on tile
	var/foldable = null	// BubbleWrap - if set, can be folded (when empty) into a sheet of cardboard
	var/foldable_amount = 1 // Number of foldables to produce, if any - N3X
	var/internal_store = 0
	var/list/no_storage_slot = new/list()//if the item is equipped in a slot that is contained in this list, the item will act purely as a clothing item and not a storage item (ie plastic bags over head)
	var/rustle_sound = "rustle"
	var/storage_locked = FALSE //you can't interact with the contents of locked storage
	var/can_add_combinedwclass = FALSE
	var/can_add_storageslots = FALSE
	var/can_increase_wclass_stored = FALSE

/obj/item/weapon/storage/proc/can_use()
	return TRUE

/obj/item/weapon/storage/on_mousedrop_to_inventory_slot()
	playsound(src, rustle_sound, 50, 1, -5)

/obj/item/weapon/storage/MouseDropFrom(obj/over_object as obj)
	if(!storage_locked && over_object == usr && (in_range(src, usr) || is_holder_of(usr, src) || distance_interact(usr)))
		show_to(usr)
		return
	if(!storage_locked && ishuman(usr) || ismonkey(usr) || isrobot(usr) && is_holder_of(usr, src))
		if(istype(over_object, /obj/structure/table) && usr.Adjacent(over_object) && Adjacent(usr))
			var/mob/living/L = usr
			if(istype(L) && !(L.incapacitated() || L.lying))
				if(can_use())
					empty_contents_to(over_object)
					return

	return ..()

/obj/item/weapon/storage/AltClick(mob/user)
	if(storage_locked || !(in_range(src, user) || is_holder_of(user, src) || distance_interact(user)))
		return ..()
	show_to(user)

/obj/item/weapon/storage/examine(mob/user)
	..()
	if(storage_locked)
		to_chat(user, "<span class='info'>\The [src] seems to be locked.</span>")
	if(isobserver(user) && !istype(user,/mob/dead/observer/deafmute)) //phantom mask users
		var/mob/dead/observer/ghost = user
		if(!isAdminGhost(ghost) && ghost.mind && ghost.mind.current)
			if(ghost.mind.isScrying || ghost.mind.current.ajourn) //scrying or astral travel
				return
		to_chat(ghost, "It contains: <span class='info'>[counted_english_list(contents)]</span>.")
		investigation_log(I_GHOST, "|| had its contents checked by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")

//override to allow certain circumstances of looking inside this item if not holding or adjacent
//distance interact can let you use storage even inside a mecha (see screen_objects.dm L160)
//and also pull items out of that storage; it can be quite powerful, add narrow conditions
/obj/item/weapon/storage/proc/distance_interact(mob/user)
	return FALSE

/obj/item/weapon/storage/Adjacent(var/atom/neighbor)
	if(ismob(neighbor) && distance_interact(neighbor))
		return TRUE
	else
		return ..()

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
	if(!user.client)
		is_seeing -= user
		return

	if(!user.incapacitated())
		if(user.s_active != src)
			for(var/obj/item/I in src)
				if(I.on_found(null, user))
					return

	if(user.s_active)
		user.s_active.hide_from(user)

	//We re-orient our items every time we want to show them to someone. Technically, this is wasteful, and it would be more efficient to rebuild this only when adding/removing items from us.
	//However, most of the (thousands of) instances of items being spawned inside containers simply use the unsafe method of directly new()ing the thing into the content list.
	//This does not use any helpers whatsoever. In fact, according to BYOND docs, it's by design that spawning new items inside us does not call Entered() or leave any trace at all. (thanks BYOND!)
	//So, if you want to optimize storagecode further... you'd have to hunt down EVERY SINGLE instance of things being spawned inside containers, and make it call handle_item_insertion() instead.
	orient2hud(user)

	user.client.screen += src.boxes
	user.client.screen += src.closer
	user.client.screen += src.xtra
	user.client.screen += src.contents
	user.s_active = src
	is_seeing |= user

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)
	if(!user.client)
		return

	if(user.s_active != src)
		return

	user.client.screen -= src.boxes
	user.client.screen -= src.closer
	user.client.screen -= src.xtra
	user.client.screen -= src.contents
	user.s_active = null
	is_seeing -= user

/obj/item/weapon/storage/proc/close(mob/user as mob)
	src.hide_from(user)

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
	src.xtra.screen_loc = src.closer.screen_loc
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
	src.xtra.screen_loc = src.closer.screen_loc

/datum/numbered_display
	var/obj/item/sample_object
	var/number = 0

/datum/numbered_display/New(obj/item/sample as obj)
	if(!istype(sample))
		qdel(src)
		return
	sample_object = sample
	number = sample_object.get_storage_number_display_value()

/obj/item/proc/get_storage_number_display_value()
	return 1

/obj/item/stack/get_storage_number_display_value()
	return amount

//This proc determines the size of the inventory to be displayed. Please touch it only if you know what you're doing.
/obj/item/weapon/storage/proc/orient2hud()
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
					ND.number += I.get_storage_number_display_value()
					found = 1
					break
			if(!found)
				adjusted_contents++
				numbered_contents.Add( new/datum/numbered_display(I) )

	//var/mob/living/carbon/human/H = user
	var/row_num = 0
	var/col_count = min(7,storage_slots) -1
	if(col_count < 0)
		col_count = 6 //Show 7 inventory slots instead of breaking the inventory
	if(adjusted_contents > 7)
		row_num = round((adjusted_contents-1) / 7) // 7 is the maximum allowed width.
	if(adjusted_contents && (adjusted_contents % 7 == 0) && !is_full()) //If we have a full row of items, but we still have leftover space... Show our "xtra" icon
		xtra.invisibility = 0
		var/biggest_w_class_we_can_fit = min(fits_max_w_class, max_combined_w_class - get_sum_w_class())
		xtra.name = "You may still fit a [wclass2text(biggest_w_class_we_can_fit)] item inside. Click here to store items."
	else
		xtra.invisibility = 101
	src.standard_orient_objs(row_num, col_count, numbered_contents)

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/weapon/storage/proc/can_be_inserted(obj/item/W as obj, stop_messages = 0)
	if(W == src)
		if(!stop_messages)
			to_chat(usr, "<span class = 'notice'>No matter how hard you try, you can't seem to manage to fit \the [src] inside of itself.</span>")
		return //No putting ourselves into ourselves
	if(storage_locked)
		to_chat(usr, "<span class = 'notice'>You can't seem to get \the [src] to open.</span>")
		return
	if(!istype(W))
		return //Not an item
	if(!W.can_be_stored(src)) //Snowflake item-side whether this item can be stored within our item.
		return 0
	if(isliving(loc))
		var/mob/living/L = loc
		for (var/i in no_storage_slot)
			if(L.is_wearing_item(src, i)) //prevents putting items into a storage item that's equipped on a no_storage_slot
				return FALSE

	if(src.loc == W)
		return 0 //Means the item is already in the storage item
	if(usr && (W.cant_drop > 0))
		if(!stop_messages)
			to_chat(usr,"<span class='notice'>You can't let go of \the [W]!</span>")
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

	var/stacktypefound = FALSE
	if(istype(W,/obj/item/stack))
		var/obj/item/stack/S = W
		for(var/obj/item/stack/otherS in src)
			if(otherS.type == S.type)
				if(otherS.amount < otherS.max_amount)
					return TRUE
				stacktypefound = TRUE
	if((storage_slots && (contents.len >= storage_slots)) || (get_sum_w_class() + W.w_class > max_combined_w_class))
		if(!stop_messages)
			to_chat(usr, "<span class='notice'>\The [src] is full[stacktypefound ? " of this kind of stack": ""], make some space.</span>")
		return 0 //Storage item is full

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

	if(istype(W,/obj/item/stack))
		var/obj/item/stack/S = W
		for(var/obj/item/stack/otherS in src)
			if(otherS.amount < otherS.max_amount && otherS.type == S.type)
				var/to_transfer = min(S.amount, otherS.max_amount - otherS.amount)
				otherS.add(to_transfer)
				if(usr)
					add_fingerprint(usr)
					if(!prevent_warning)
						for(var/mob/M in viewers(usr, null)) //If someone is standing close enough, they can tell what it is, otherwise they can only see large or normal items from a distance
							if(M == usr)
								to_chat(usr, "You add [to_transfer] [((to_transfer > 1) && S.irregular_plural) ? S.irregular_plural : "[S.singular_name]\s"] to \the [otherS]. It now contains [otherS.amount] [(otherS.irregular_plural && otherS.amount > 1) ? otherS.irregular_plural : "[otherS.singular_name]"].")
							else if (!stealthy(usr) && ((M in range(1)) || W.w_class >= W_CLASS_MEDIUM))
								M.show_message("<span class='notice'>[usr] puts \the [W] into \the [src].</span>")
				S.use(to_transfer)
				refresh_all()
				return 1

	if(usr) //WHYYYYY

		usr.u_equip(W,0)
		W.dropped(usr) // we're skipping u_equip's forcemove to turf but we still need the item to unset itself
		usr.update_icons()

	W.forceMove(src)
	W.on_enter_storage(src)
	if(usr)
		if (usr.client && usr.s_active != src)
			usr.client.screen -= W
		add_fingerprint(usr)

		if(!prevent_warning && !istype(W, /obj/item/weapon/gun/energy/crossbow))
			for(var/mob/M in viewers(usr, null)) //If someone is standing close enough, they can tell what it is, otherwise they can only see large or normal items from a distance
				if(M == usr)
					to_chat(usr, "<span class='notice'>You put \the [W] into \the [src].</span>")
				else if (!stealthy(usr) && ((M in range(1)) || W.w_class >= W_CLASS_MEDIUM))
					M.show_message("<span class='notice'>[usr] puts \the [W] into \the [src].</span>")

	W.mouse_opacity = 2 //So you can click on the area around the item to equip it, instead of having to pixel hunt
	update_icon()

	refresh_all()
	return 1

/obj/item/weapon/storage/can_quick_store(var/obj/item/I)
	return can_use() && can_be_inserted(I,1)

/obj/item/weapon/storage/quick_store(var/obj/item/I,mob/user)
	..()
	return handle_item_insertion(I,0)

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
//force needs to be 1 if you want to override the can_be_inserted() if the target's a storage item.
/obj/item/weapon/storage/proc/remove_from_storage(obj/item/W, atom/new_location, var/force = 0, var/refresh = 1)
	if(!istype(W))
		return 0

	if(!force && istype(new_location, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/A = new_location
		if(!A.can_be_inserted(W, 1))
			return 0

	if(istype(src, /obj/item/weapon/storage/fancy))
		var/obj/item/weapon/storage/fancy/F = src
		F.update_icon(1)

	if(new_location)
		var/mob/M
		if(ismob(loc))
			M = loc
			W.dropped(M)
		if(ismob(new_location))
			M = new_location
			if(!M.put_in_active_hand(W))
				return 0
		else
			if(istype(new_location, /obj/item/weapon/storage))
				var/obj/item/weapon/storage/A = new_location
				A.handle_item_insertion(W, 1)
			else
				W.forceMove(new_location)
	else
		W.forceMove(get_turf(src))

	if(W.maptext)
		W.maptext = ""
	W.reset_plane_and_layer()
	W.on_exit_storage(src)
	update_icon()
	W.mouse_opacity = initial(W.mouse_opacity)

	for(var/mob/M in is_seeing)
		if (M.client)
			M.client.screen -= W

	if (refresh)
		refresh_all()

	return 1

//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/W as obj, mob/user as mob)
	if(!Adjacent(user,MAX_ITEM_DEPTH) && !distance_interact(user))
		return

	//Allow smashing of storage items on harm intent without also putting the weapon into the container.
	if(valid_item_attack(W, usr))
		return ..()

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

	if(istype(W, /obj/item/weapon/storage_key))
		var/obj/item/weapon/storage_key/stkey = W
		if(stkey.type_limit.len && !stkey.type_limit.Find(src))
			to_chat(user, "<span class='notice'>\The [stkey] doesn't work on \the [src].</span>")
			return
		storage_locked = !storage_locked
		to_chat(user, "<span class='notice'>You [(storage_locked)? "" : "un"]lock \the [src] with \the [stkey].</span>")
		return

	if(istype(W, /obj/item/weapon/hand_labeler))
		var/obj/item/weapon/hand_labeler/L = W
		if(L.mode)
			return

	if(!can_be_inserted(W))
		if(istype(W, /obj/item/weapon/glue))
			return
		else
			return TRUE

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

/obj/item/weapon/storage/attack_hand(mob/user as mob)
	if(!stealthy(user))
		playsound(src, rustle_sound, 50, 1, -5)

	if (user.s_active == src) // Click on the backpack again to close it.
		close(user)
		src.add_fingerprint(user)
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((H.l_store == src || H.r_store == src || H.head == src) && !H.get_active_hand())	//Prevents opening if it's in a pocket or head slot. Terrible kludge, I'm sorry.
			return ..()
	else if(isMoMMI(user))
		var/mob/living/silicon/robot/mommi/MoM = user
		if(MoM.head_state == src) //I'm so sorry. We have exactly one storage item that goes on head, and it can't hold any items while equipped. This is so you can actually take it off.
			return ..()

	var/atom/maxloc = src.loc
	if(src.internal_store)
		for(var/i = 1; i++ <= internal_store)
			if(maxloc == user)
				break
			if(maxloc.loc)
				maxloc = maxloc.loc

	if (maxloc == user && !storage_locked)
		show_to(user)
		src.add_fingerprint(user)
		return
	else
		..()
		close_all()
		src.add_fingerprint(user)

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

	if((!ishigherbeing(usr) && (src.loc != usr)) || usr.isUnconscious() || usr.restrained())
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

	src.boxes = new /obj/abstract/screen/storage
	src.boxes.name = "storage"
	src.boxes.master = src
	src.boxes.icon_state = "block"
	src.boxes.screen_loc = "7,7 to 10,8"
	src.boxes.layer = HUD_BASE_LAYER
	src.closer = new /obj/abstract/screen/close
	src.closer.master = src
	src.closer.icon_state = "x"
	src.closer.layer = HUD_ITEM_LAYER
	src.xtra = new /obj/abstract/screen/storage
	src.xtra.master = src
	src.xtra.icon_state = "xtra_inv"
	src.xtra.layer = HUD_ITEM_LAYER
	src.xtra.alpha = 210

	if(items_to_spawn.len)
		var/total_w_class = 0
		var/usable_items = 0
		var/biggest_w_class = 0
		for(var/item in items_to_spawn)
			var/picked_item = item
			var/obj/item/current_item
			var/amount = 1
			if(islist(item))
				var/list/item_list = item
				if(item_list.len)
					picked_item = pick(item_list)
			if(ispath(picked_item, /obj/item))
				if(items_to_spawn[item] && isnum(items_to_spawn[item]))
					amount = items_to_spawn[item]
				for(var/i = 1, i <= amount, i++)
					current_item = new picked_item(src)
					if(current_item)
						usable_items++
						total_w_class += current_item.w_class
						if(current_item.w_class > biggest_w_class)
							biggest_w_class = current_item.w_class
		if(total_w_class > max_combined_w_class && can_add_combinedwclass)
			max_combined_w_class = total_w_class
		if(usable_items > storage_slots && can_add_storageslots)
			storage_slots = usable_items
		if(biggest_w_class > fits_max_w_class && can_increase_wclass_stored)
			fits_max_w_class = biggest_w_class

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

/obj/item/weapon/storage/attack_self(mob/user as mob) // BubbleWrap - A box can be folded up to make card
	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(src.verbs.Find(/obj/item/weapon/storage/verb/quick_empty) && contents.len)
			src.quick_empty()
			return

	//Otherwise we'll try to fold it.
	if(contents.len)
		return

	if(!ispath(src.foldable))
		return

	to_chat(user, "<span class='notice'>You fold \the [src] flat.</span>")
	var/folded = new src.foldable(get_turf(src),foldable_amount)
	user.u_equip(src)
	user.put_in_hands(folded)
	transfer_fingerprints_to(folded)
	qdel(src)

/obj/item/weapon/storage/proc/can_see_contents()
	var/list/cansee = list()
	for(var/mob/M in is_seeing)
		if(M.s_active == src && M.client)
			cansee |= M
		else
			is_seeing -= M
	return cansee

/obj/item/weapon/storage/proc/refresh_all()
	for(var/mob/M in is_seeing)
		show_to(M)

	orient2hud()

/obj/item/weapon/storage/proc/close_all()
	for(var/mob/M in is_seeing)
		close(M)
		. = 1 //returns 1 if any mobs actually got a close(M) call

/obj/item/weapon/storage/Destroy()
	close_all()
	if(boxes)
		QDEL_NULL(boxes)
	if(closer)
		QDEL_NULL(closer)
	if(xtra)
		QDEL_NULL(xtra)
	QDEL_LIST_NULL(contents)
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
		I.stripped(wearer, stripper)

/obj/item/weapon/storage/proc/mass_remove(var/atom/A)
	for(var/obj/item/O in contents)
		remove_from_storage(O, A, refresh = 0)

	refresh_all()

/obj/item/weapon/storage/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	//Forbids wearing a storage item in a  no_storage_slot (ie plastic bags over head) with something already inside
	.=..()
	for (var/i in no_storage_slot)
		if(contents.len && (slot == i))
			return CANNOT_EQUIP

/obj/item/weapon/storage/proc/get_sum_w_class()
	. = 0
	for(var/obj/item/I in contents)
		. += I.w_class

/obj/item/weapon/storage/proc/is_full()
	return (storage_slots && (contents.len >= storage_slots)) || (get_sum_w_class() >= max_combined_w_class)

/obj/item/weapon/storage/ignite()
	if(!istype(loc, /turf)) //worn or held items don't ignite (for now >:^) )
		return 0
	var/turf/T = get_turf(src)
	mass_remove(T) //dump contents if it's burning
	..()

/obj/item/weapon/storage_key
	name = "storage key"
	desc = "Might open what you want opened, or lock what you want locked."
	var/list/type_limit = list()
	icon = 'icons/obj/weapons.dmi'
	icon_state = "sword0"

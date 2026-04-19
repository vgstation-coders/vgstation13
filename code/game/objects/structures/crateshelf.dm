#define DEFAULT_SHELF_CAPACITY 3 // Default capacity of the shelf
#define DEFAULT_SHELF_USE_DELAY 1 SECONDS // Default interaction delay of the shelf
#define DEFAULT_SHELF_VERTICAL_OFFSET 11 // Vertical pixel offset of shelving-related things.

/obj/structure/rack/crate_shelf
	name = "crate shelf"
	desc = "It's a shelf! For storing crates!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "shelf_base"
	var/wrecked_icon_state = "shelf_wreck"
	density = TRUE
	anchored = TRUE
	health = 50 // A bit stronger than a regular rack
	parts = /obj/item/weapon/rack_parts/shelf
	pass_flags_self = null

	var/mob/living/carbon/human/trappeduser
	var/trapping = FALSE
	var/capacity = DEFAULT_SHELF_CAPACITY
	var/use_delay = DEFAULT_SHELF_USE_DELAY
	var/list/shelf_contents
	var/osha_violation = FALSE // Have the screws been loosened by a DEVIOUS FIEND
	var/damage_amount= 25 //for badminnery
	var/made_in_china = FALSE //gibs if true
	var/collapsed = FALSE

/obj/structure/rack/crate_shelf/tall
	capacity = 12

/obj/structure/rack/crate_shelf/centcomm_provided/
	var/how_cheap_percent = 20

/obj/structure/rack/crate_shelf/New()
	. = ..()
	var/mutable_appearance/base = mutable_appearance(icon = 'icons/obj/objects.dmi', icon_state = "shelf_overlay", layer = BELOW_OBJ_LAYER + 0.01, plane = FLOAT_PLANE)
	base.plane = FLOAT_PLANE
	overlays += base
	shelf_contents = new/list(capacity) // Initialize our shelf's contents list, this will be used later.
	var/stack_layer // This is used to generate the sprite layering of the shelf pieces.
	var/stack_offset // This is used to generate the vertical offset of the shelf pieces.
	var/stack_plane = FLOAT_PLANE
	for(var/i in 1 to (capacity - 1))
		if(i >= 3) // If we're at or above three, we'll be on the way to going off the tile we're on. This allows mobs to be below the shelf when this happens.
			stack_plane = HUMAN_PLANE
		stack_layer  = BELOW_OBJ_LAYER + (0.02 * i) - 0.01 // Make each shelf piece render above the last, but below the crate that should be on it.
		stack_offset = DEFAULT_SHELF_VERTICAL_OFFSET * i // Make each shelf piece physically above the last.
		var/mutable_appearance/nextshelf = mutable_appearance(icon = 'icons/obj/objects.dmi', icon_state = "shelf_stack", layer = stack_layer, plane = stack_plane)
		stack_layer += 0.2
		nextshelf.pixel_y = stack_offset
		overlays += nextshelf
		var/mutable_appearance/nextshelf_olay = mutable_appearance(icon = 'icons/obj/objects.dmi', icon_state = "shelf_overlay", layer = stack_layer, plane = stack_plane)
		nextshelf_olay.pixel_y = stack_offset
		overlays += nextshelf_olay
	spawn(0) // Wait for other atoms on this turf to finish spawning, then absorb any mapped shelvable objects.
		absorb_turf_contents()
	return

/obj/structure/rack/crate_shelf/proc/absorb_turf_contents()
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/obj/O in T)
		if(O == src)
			continue
		if(!can_shelf(O))
			continue
		if(!shelf_contents.Find(null))
			return // Shelf is full.
		force_load(O)

/obj/structure/rack/crate_shelf/centcomm_provided/New()
	. = ..()
	if(prob(how_cheap_percent))
		osha_violation = TRUE

/obj/structure/rack/crate_shelf/Destroy()
	QDEL_LIST(shelf_contents)
	if (trappeduser)
		unlock_atom(trappeduser)
	trappeduser = null
	..()
	return ..()

/obj/structure/rack/crate_shelf/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are some <b>bolts</b> holding [src] together.</span>"
	if(shelf_contents.Find(null)) // If there's an empty space in the shelf, let the examiner know.
		. += "<span class='notice'>You could <b>drag</b> a crate or recharge pack into [src]."
	if(contents.len) // If there are any crates in the shelf, let the examiner know.
		. += "<span class='notice'>You could <b>drag</b> something out of [src]."
		. += "<span class='notice'>[src] contains:</span>"
		for(var/obj/stored in shelf_contents)
			. += "[stored]"
	if(osha_violation)
		. += "<span class='warning'>It doesn't look very sturdy.</span>"

/obj/structure/rack/crate_shelf/proc/can_shelf(obj/O)
	return istype(O, /obj/structure/closet/crate) || istype(O, /obj/structure/vendomatpack)

/obj/structure/rack/crate_shelf/attackby(obj/item/weapon/W as obj, mob/living/user, params)
	if(W.is_wrench(user) && can_disassemble())
		W.playtoolsound(src, 50)
		destroy(!trapping)
	else if(W.is_screwdriver(user))
		W.playtoolsound(src, 50)
		osha_violation = !osha_violation
		visible_message("[user] [osha_violation?"loosens":"tightens"] \the [src]'s bolts.", "You [osha_violation?"loosen":"tighten"] \the [src]'s bolts.")

/obj/structure/rack/crate_shelf/attack_hand(mob/living/user)
	if(collapsed)
		visible_message("[user] begins clearing \the [src] debris.", "You begins clearing \the [src] debris.")
		if(do_after(user,src,5 SECONDS))
			visible_message("[user] clears \the [src] debris.", "You clear \the [src] debris.")
			destroy()

/obj/structure/rack/crate_shelf/destroy(dropParts = TRUE)
	var/turf/dump_turf = get_turf(src)
	for(var/obj/stored in shelf_contents)
		force_unload(stored, dump_turf)
		step(stored, pick(cardinal)) // Shuffle the contents around as though they've fallen down.
		if(prob(5)) // Open the crate!
			var/obj/structure/closet/crate/crate = stored
			if(istype(crate) && crate.open())
				crate.visible_message("<span class='warning'>[crate]'s lid falls open!</span>")
	if(trapping)
		unlock_atom(trappeduser)
		trappeduser = null
		trapping = FALSE
	return ..()

/obj/structure/rack/crate_shelf/proc/relay_container_resist_act(mob/living/user, obj/structure/closet/crate)
	to_chat(user, "<span class='notice'>You begin attempting to knock [crate] out of [src].</span>")
	if(do_after(user, 30 SECONDS, target = crate))
		if(!user || user.stat != CONSCIOUS || user.loc != crate || crate.loc != src)
			return // If the user is in a strange condition, return early.
		visible_message("<span class='warning'>[crate] falls off of [src]!</span>",
						"<span class='notice'>You manage to knock [crate] free of [src].</span>",
						"<span class='notice'>You hear a thud.</span>")
		crate.forceMove(get_turf(src)) // Drop the crate onto the shelf,
		step_rand(crate, 1) // Then try to push it somewhere.
		crate.plane = initial(crate.plane)
		crate.layer = initial(crate.layer) // Reset the crate back to having the default layer, otherwise we might get strange interactions.
		crate.pixel_y = initial(crate.pixel_y) // Reset the crate back to having no offset, otherwise it will be floating.
		shelf_contents[shelf_contents.Find(crate)] = null // Remove the reference to the crate from the list.
		handle_visuals()

/obj/structure/rack/crate_shelf/proc/handle_visuals()
	vis_contents = contents // It really do be that shrimple.
	return

// Used when a mob attempts to put a crate or recharge pack on the rack.
/obj/structure/rack/crate_shelf/proc/load(obj/stored, mob/user)
	if(!can_shelf(stored))
		return FALSE
	var/next_free = shelf_contents.Find(null) // Find the first empty slot in the shelf.
	if(!next_free) // If we don't find an empty slot, return early.
		to_chat(user, "<span class='warning'>\The [src] is full!</span>")
		return FALSE
	if(do_after(user, use_delay, target = stored))
		return force_load(stored, next_free)
	return FALSE // If the do_after() is interrupted, return FALSE!

// Directly inserts an object into the rack.
// next_free: Used for if you're trying to insert an object into a specific position. Default: next available slot
// Returns FALSE if the object can't be forced on for whatever reason.
/obj/structure/rack/crate_shelf/proc/force_load(obj/stored, next_free)
	if(!can_shelf(stored))
		return FALSE
	if(!next_free)
		next_free = shelf_contents.Find(null) // Find the first empty slot in the shelf.
		if(!next_free)
			return FALSE //No slots open!
	if(shelf_contents[next_free] != null)
		return FALSE // Can't load if no room.
	if(istype(stored, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/crate = stored
		if(crate.opened) // If the crate is open, try to close it.
			if(!crate.close())
				return FALSE // If we fail to close it, don't load it into the shelf.
	shelf_contents[next_free] = stored // Insert a reference to the object into the free slot.
	stored.forceMove(src) // Insert the object into the shelf.
	stored.pixel_y = DEFAULT_SHELF_VERTICAL_OFFSET * (next_free - 1) // Adjust the vertical offset to look like it's on the shelf.
	stored.plane = FLOAT_PLANE
	if(next_free >= 3) // If we're at or above three, we'll be on the way to going off the tile we're on. This allows mobs to be below the object when this happens.
		stored.plane = HUMAN_PLANE
	stored.layer = BELOW_OBJ_LAYER + 0.02 * (next_free - 1) // Adjust the layer of the object to look like it's in the shelf.
	handle_visuals()
	return TRUE

// Used when a mob attempts take an object off the rack.
/obj/structure/rack/crate_shelf/proc/unload(obj/stored, mob/user, turf/unload_turf)
	if(!unload_turf)
		unload_turf = get_turf(user) // If a turf somehow isn't passed into the proc, put it at the user's feet.
	if(unload_turf.density)
		return
	if((locate(/obj/structure/closet/crate) in unload_turf) || (locate(/obj/structure/vendomatpack) in unload_turf))
		to_chat(user,"<span class='warning'>There is already something in the way.</span>")
		return
	if(do_after(user, use_delay, target = stored))
		return force_unload(stored, unload_turf)
	return FALSE  // If the do_after() is interrupted, return FALSE!

// Directly removes a specific object from the rack.
// unload_turf: Used to specify where the object will be dropped. default: get_turf(src)
// Returns FALSE if the object does not exist on the rack.
/obj/structure/rack/crate_shelf/proc/force_unload(obj/stored, turf/unload_turf)
	if(!shelf_contents.Find(stored))
		return FALSE // If something has happened to the object while we were waiting, abort!
	if(!unload_turf)
		unload_turf = get_turf(src)
	stored.plane = initial(stored.plane)
	stored.layer = initial(stored.layer) // Reset the object back to having the default layer, otherwise we might get strange interactions.
	stored.pixel_y = initial(stored.pixel_y) // Reset the object back to having no offset, otherwise it will be floating.
	stored.forceMove(unload_turf)
	shelf_contents[shelf_contents.Find(stored)] = null // We do this instead of removing it from the list to preserve the order of the shelf.
	handle_visuals()
	return TRUE

/obj/structure/rack/crate_shelf/Bumped(atom/movable/AM)
	..()
	var/bump_amt = 0
	if(istype(AM,/obj))
		if(istype(AM,/obj/item/projectile))
			bump_amt = 1
		else
			var/obj/O = AM
			switch(O.w_class)
				if(W_CLASS_TINY, W_CLASS_SMALL)
					bump_amt = 1
				if(W_CLASS_MEDIUM)
					bump_amt = 2
				if(W_CLASS_LARGE,W_CLASS_HUGE,W_CLASS_GIANT)
					bump_amt = 3
	else if(istype(AM,/mob/living))
		var/mob/living/M = AM
		if(M.reagents)
			if(M.reagents.get_sportiness() > 1)
				bump_amt = 2
		if(M_HULK in M.mutations)
			bump_amt = 3
		else
			bump_amt = 1
	else if(istype(AM,/obj/structure/bed/chair/vehicle))
		bump_amt = 3

	wobble(bump_amt,AM)

/obj/structure/rack/crate_shelf/tackled(mob/living/user) //why would you tackle this you big dumb idiot
	..()
	var/bump_amt
	if(M_HULK in user.mutations)
		bump_amt = 4
	else
		bump_amt = 3

	wobble(bump_amt, user)

/obj/structure/rack/crate_shelf/ex_act(severity)
	var/bump_amt = 0
	switch(severity)
		if(1.0)
			bump_amt = 2
		if(2.0)
			if(prob(50))
				bump_amt = 3
			else
				destroy(FALSE)
				return
		if(3.0)
			if(prob(25))
				destroy(TRUE)
				return
			else
				bump_amt = 4
	wobble(bump_amt)

//Tilt the shelves when hit.
//Power:
//1: Bumped or hit by small object
//2: Hit by med object
//3: Hit by large object or vehicle
//4: Bombed
//Loosening the bolts with a screwdriver doubles power
/obj/structure/rack/crate_shelf/proc/wobble(var/power,var/atom/movable/wobbler = null)
	if(collapsed) //it won't fall on you if it already fell over
		return
	var/wobble_roll = power * 25 * (osha_violation?2:1)
	var/wobble_amount = floor(clamp(rand(1,wobble_roll),0,100)/5)
	var/wobble_dir
	if(wobbler)
		wobble_dir = get_dir(src,wobbler)
	var/wobble_x = 0
	var/wobble_y = 0
	if(wobble_dir)
		switch(wobble_dir)
			if(NORTH)
				wobble_x = 0
				wobble_y = -wobble_amount
			if(SOUTH)
				wobble_x = 0
				wobble_y = wobble_amount
			if(WEST)
				wobble_x = wobble_amount
				wobble_y = 0
			if(EAST)
				wobble_x = -wobble_amount
				wobble_y = 0
			if(NORTHWEST)
				wobble_x = wobble_amount/2
				wobble_y = -wobble_amount/2
			if(NORTHEAST)
				wobble_x = -wobble_amount/2
				wobble_y = -wobble_amount/2
			if(SOUTHWEST)
				wobble_x = wobble_amount/2
				wobble_y = wobble_amount/2
			if(SOUTHEAST)
				wobble_x = -wobble_amount/2
				wobble_y = wobble_amount/2
	else
		wobble_x = rand(0,wobble_amount)
		wobble_y = rand(0,wobble_amount)
	animate(src, pixel_x = pixel_x + wobble_x, pixel_y = pixel_y + wobble_y, time = 0.2 SECONDS)
	sleep(0.2 SECONDS)
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)

	if(wobble_amount > 5)
		post2liveleak(wobble_dir)

/datum/locking_category/shelf
	flags = LOCKED_SHOULD_LIE

/obj/structure/rack/crate_shelf/proc/post2liveleak(var/tipdir)
	collapsed = TRUE
	var/turf/fallturf = get_turf(get_step(src,tipdir))
	if(fallturf.density) //fall in the opposite direction if there's a wall in the way
		fallturf = get_turf(get_step(src,opposite_dirs[tipdir]))
		if(fallturf.density) //won't fall if blocked by walls in both dirs
			return
	forceMove(fallturf)
	playsound(src,'sound/effects/plate_drop.ogg',60,1)
	icon_state = wrecked_icon_state
	overlays.Cut()
	plane = HUMAN_PLANE

	for(var/obj/stored in shelf_contents)
		force_unload(stored, fallturf)
		step(stored, pick(cardinal))
		if(prob(50))
			var/obj/structure/closet/crate/crate = stored
			if(istype(crate) && crate.open())
				crate.visible_message("<span class='warning'>[crate]'s lid falls open!</span>")

	for(var/mob/living/carbon/human/H in fallturf)
		if(made_in_china)
			H.gib()
			return
		var/datum/organ/external/injuredorgan = H.pick_usable_organ(LIMB_HEAD,LIMB_CHEST,LIMB_GROIN,LIMB_LEFT_ARM,
								LIMB_RIGHT_ARM,LIMB_LEFT_HAND,LIMB_RIGHT_HAND,LIMB_LEFT_LEG,
								LIMB_RIGHT_LEG,LIMB_LEFT_FOOT,LIMB_RIGHT_FOOT)
		H.audible_scream()
		H.visible_message("<span class='warning'>\The [src] falls onto [H]!</span>",
						"<span class='warning'>You get stuck under \the [src]!.</span>",
						"<span class='warning'>Something heavy fell and pinned you to the floor!</span>")
		lock_atom(H, /datum/locking_category/shelf)

		if(injuredorgan?.take_damage(damage_amount - 10, 0, damage_amount, SERRATED_BLADE & SHARP_BLADE))
			H.UpdateDamageIcon()
			H.updatehealth()

		H.update_canmove()
		trapping = TRUE
		return

#define DEFAULT_SHELF_CAPACITY 3 // Default capacity of the shelf
#define DEFAULT_SHELF_USE_DELAY 1 SECONDS // Default interaction delay of the shelf
#define DEFAULT_SHELF_VERTICAL_OFFSET 11 // Vertical pixel offset of shelving-related things.

/obj/structure/rack/crate_shelf
	name = "crate shelf"
	desc = "It's a shelf! For storing crates!"
	icon = 'icons/obj/objects.dmi'
	icon_state = "shelf_base"
	density = TRUE
	anchored = TRUE
	health = 50 // A bit stronger than a regular rack
	parts = /obj/item/weapon/rack_parts/shelf

	var/capacity = DEFAULT_SHELF_CAPACITY
	var/use_delay = DEFAULT_SHELF_USE_DELAY
	var/list/shelf_contents

/obj/structure/rack/crate_shelf/tall
	capacity = 12

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
	return

/obj/structure/rack/crate_shelf/Destroy()
	QDEL_LIST(shelf_contents)
	return ..()

/obj/structure/rack/crate_shelf/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are some <b>bolts</b> holding [src] together.</span>"
	if(shelf_contents.Find(null)) // If there's an empty space in the shelf, let the examiner know.
		. += "<span class='notice'>You could <b>drag</b> a crate into [src]."
	if(contents.len) // If there are any crates in the shelf, let the examiner know.
		. += "<span class='notice'>You could <b>drag</b> a crate out of [src]."
		. += "<span class='notice'>[src] contains:</span>"
		for(var/obj/structure/closet/crate/crate in shelf_contents)
			. += "[crate]"

/obj/structure/rack/crate_shelf/attackby(obj/item/weapon/W as obj, mob/living/user, params)
	if(W.is_wrench(user) && can_disassemble())
		W.playtoolsound(src, 50)
		destroy(TRUE)

/obj/structure/rack/crate_shelf/proc/relay_container_resist_act(mob/living/user, obj/structure/closet/crate)
	to_chat(user, "<span class='notice'>You begin attempting to knock [crate] out of [src].</span>")
	if(do_after(user, 30 SECONDS, target = crate))
		if(!user || user.stat != CONSCIOUS || user.loc != crate || crate.loc != src)
			return // If the user is in a strange condition, return early.
		visible_message("<span class='warning'>[crate] falls off of [src]!</span>",
						"<span class='notice'>You manage to knock [crate] free of [src].</span>",
						"<span class='notice>You hear a thud.</span>")
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

/obj/structure/rack/crate_shelf/proc/load(obj/structure/closet/crate/crate, mob/user)
	var/next_free = shelf_contents.Find(null) // Find the first empty slot in the shelf.
	if(!next_free) // If we don't find an empty slot, return early.
		to_chat(user, "<span class='warning'>\The [src] is full!</span>")
		return FALSE
	if(do_after(user, use_delay, target = crate))
		if(shelf_contents[next_free] != null)
			return FALSE // Something has been added to the shelf while we were waiting, abort!
		if(crate.opened) // If the crate is open, try to close it.
			if(!crate.close())
				return FALSE // If we fail to close it, don't load it into the shelf.
		shelf_contents[next_free] = crate // Insert a reference to the crate into the free slot.
		crate.forceMove(src) // Insert the crate into the shelf.
		crate.pixel_y = DEFAULT_SHELF_VERTICAL_OFFSET * (next_free - 1) // Adjust the vertical offset of the crate to look like it's on the shelf.
		crate.plane = FLOAT_PLANE
		if(next_free >= 3) // If we're at or above three, we'll be on the way to going off the tile we're on. This allows mobs to be below the crate when this happens.
			crate.plane = HUMAN_PLANE
		crate.layer = BELOW_OBJ_LAYER + 0.02 * (next_free - 1) // Adjust the layer of the crate to look like it's in the shelf.
		handle_visuals()
		return TRUE
	return FALSE // If the do_after() is interrupted, return FALSE!

/obj/structure/rack/crate_shelf/proc/unload(obj/structure/closet/crate/crate, mob/user, turf/unload_turf)
	if(!unload_turf)
		unload_turf = get_turf(user) // If a turf somehow isn't passed into the proc, put it at the user's feet.
	if(unload_turf.density)
		return
	if(locate(/obj/structure/closet/crate) in unload_turf)
		to_chat(user,"<span class='warning'>There is already a crate here.</span>")
		return
	if(do_after(user, use_delay, target = crate))
		if(!shelf_contents.Find(crate))
			return FALSE // If something has happened to the crate while we were waiting, abort!
		crate.plane = initial(crate.plane)
		crate.layer = initial(crate.layer) // Reset the crate back to having the default layer, otherwise we might get strange interactions.
		crate.pixel_y = initial(crate.pixel_y) // Reset the crate back to having no offset, otherwise it will be floating.
		crate.forceMove(unload_turf)
		shelf_contents[shelf_contents.Find(crate)] = null // We do this instead of removing it from the list to preserve the order of the shelf.
		handle_visuals()
		return TRUE
	return FALSE  // If the do_after() is interrupted, return FALSE!

/obj/structure/rack/crate_shelf/destroy(dropParts = TRUE)
	var/turf/dump_turf = get_turf(src)
	for(var/obj/structure/closet/crate/crate in shelf_contents)
		crate.plane = initial(crate.plane)
		crate.layer = initial(crate.layer) // Reset the crates back to default visual state
		crate.pixel_y = initial(crate.pixel_y)
		crate.forceMove(dump_turf)
		step(crate, pick(cardinal)) // Shuffle the crates around as though they've fallen down.
		if(prob(5)) // Open the crate!
			if(crate.open())
				crate.visible_message("<span class='warning'>[crate]'s lid falls open!</span>")
		shelf_contents[shelf_contents.Find(crate)] = null
	return ..()

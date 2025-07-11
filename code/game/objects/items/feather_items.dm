// Consolidated file for all craftable feather objects because they all share the color logic.

/obj/item/clothing/suit/feathercoat
	name = "feather coat"
	desc = "A coat made from locally-sourced feathers."
	icon_state = "feathercoat"
	item_state = "feathercoat"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY | ONESIZEFITSALL
	var/feather_color = null
	var/feather_color_name = null
	dyeable_parts = list("main")
	dye_base_iconstate_override = "feathercoat"

/obj/item/clothing/suit/feathercoat/update_icon()
	. = ..()
	if(feather_color)
		color = feather_color
	else
		color = null
	// Ensure overlays (worn sprite) are also colored
	if(overlays && overlays.len)
		for(var/image/I in overlays)
			if(feather_color)
				I.color = feather_color
			else
				I.color = null
	. = ..()

/obj/item/clothing/suit/feathercoat/New(loc, color = null, color_name = null)
	..(loc)
	cloth_icon = src.icon // Set cloth_icon at runtime
	if(color)
		feather_color = color
		// Set up dyed_parts for overlay coloring
		dyed_parts = list("main" = list(feather_color, 255))
	if(color_name)
		feather_color_name = color_name
	if(feather_color_name)
		name = "[feather_color_name] feather coat"
	else
		name = "feather coat"
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/clothing/suit/feathercoat/equipped(mob/user, slot)
	..()
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/clothing/suit/feathervest
	name = "feather vest"
	desc = "A vest made from locally-sourced feathers."
	icon_state = "feathervest"
	item_state = "feathervest"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/clothing.dmi', "right_hand" = 'icons/mob/in-hand/right/clothing.dmi')
	body_parts_covered = FULL_TORSO|ARMS
	species_fit = list(VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY
	var/feather_color = null
	var/feather_color_name = null
	dyeable_parts = list("main")
	dye_base_iconstate_override = "feathervest"

/obj/item/clothing/suit/feathervest/update_icon()
	. = ..()
	if(feather_color)
		color = feather_color
	else
		color = null
	// Ensure overlays (worn sprite) are also colored
	if(overlays && overlays.len)
		for(var/image/I in overlays)
			if(feather_color)
				I.color = feather_color
			else
				I.color = null
	. = ..()

/obj/item/clothing/suit/feathervest/New(loc, color = null, color_name = null)
	..(loc)
	cloth_icon = src.icon // Set cloth_icon at runtime
	if(color)
		feather_color = color
		// Set up dyed_parts for overlay coloring
		dyed_parts = list("main" = list(feather_color, 255))
	if(color_name)
		feather_color_name = color_name
	if(feather_color_name)
		name = "[feather_color_name] feather vest"
	else
		name = "feather vest"
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/clothing/suit/feathervest/equipped(mob/user, slot)
	..()
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/mounted/frame/wreath/feather
	name = "feather wreath"
	desc = "A decorative wreath made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_feather"
	var/feather_color = null // Hexcode for feather color
	var/feather_color_name = null // Name of the feather color
	var/singular_name = null

/obj/item/mounted/frame/wreath/feather/update_icon()
	if(feather_color)
		color = feather_color
	else
		color = null
	. = ..()

/obj/item/mounted/frame/wreath/feather/New(loc, color = null, color_name = null, singular = null)
	. = ..(loc)
	if(color)
		feather_color = color
		src.color = color
	if(color_name)
		feather_color_name = color_name
	if(singular)
		singular_name = singular
	if(feather_color_name)
		name = "[feather_color_name] feather wreath"
		singular_name = name
	else
		name = "feather wreath"
		if(!singular_name) singular_name = name
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/mounted/frame/wreath/feather/do_build(turf/on_wall, mob/user)
	// Pass feather color data to the structure
	new /obj/structure/wreath/feather(get_turf(src), get_dir(on_wall, user), 1, src.feather_color, src.feather_color_name, src.singular_name)
	qdel(src)

// Feather wreath structure (mounted on wall)
/obj/structure/wreath/feather
	name = "feather wreath"
	desc = "A decorative wreath made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "wreath_feather"
	var/feather_color = null
	var/feather_color_name = null
	var/singular_name = null

/obj/structure/wreath/feather/New(loc, dir, built = 1, color = null, color_name = null, singular = null)
	..(loc, dir, built)
	if(color)
		feather_color = color
		src.color = color
	if(color_name)
		feather_color_name = color_name
	if(singular)
		singular_name = singular
	if(feather_color_name)
		name = "[feather_color_name] feather wreath"
		singular_name = name
	else
		name = "feather wreath"
		if(!singular_name) singular_name = name
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/structure/wreath/feather/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \\the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry \\the [src] off of the wall.</span>")
			// Pass feather color data back to the item
			new /obj/item/mounted/frame/wreath/feather(get_turf(user), src.feather_color, src.feather_color_name, src.singular_name)
			qdel(src)
			return
	return ..()

// Okay, so its not exactly a wreath, nor is it christmas-themed, but it uses the same code.
/obj/item/mounted/frame/dreamcatcher
	name = "dreamcatcher"
	desc = "A decorative dreamcatcher made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "dreamcatcher" // item in-hand or on ground
	var/feather_color = null // Hexcode for feather color
	var/feather_color_name = null // Name of the feather color
	var/singular_name = null

/obj/item/mounted/frame/dreamcatcher/update_icon()
	if(feather_color)
		color = feather_color
	else
		color = null
	. = ..()


/obj/item/mounted/frame/dreamcatcher/New(loc, color = null, color_name = null, singular = null)
	. = ..(loc)
	if(color)
		feather_color = color
		src.color = color
	if(color_name)
		feather_color_name = color_name
	if(singular)
		singular_name = singular
	if(feather_color_name)
		name = "[feather_color_name] feather dreamcatcher"
		singular_name = name
	else
		name = "feather dreamcatcher"
		if(!singular_name) singular_name = name
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()


/obj/item/mounted/frame/dreamcatcher/do_build(turf/on_wall, mob/user)
	// Pass feather color data to the structure
	new /obj/structure/dreamcatcher(on_wall, null, 1, src.feather_color, src.feather_color_name, src.singular_name)
	qdel(src)

// Feather dreamcatcher structure (mounted on wall)
/obj/structure/dreamcatcher
	name = "feather dreamcatcher"
	desc = "A decorative dreamcatcher made of locally-sourced feathers."
	icon = 'icons/obj/christmas.dmi'
	icon_state = "dreamcatcher" // use a wall-mount-aligned icon state
	var/feather_color = null
	var/feather_color_name = null
	var/singular_name = null

/obj/structure/dreamcatcher/New(loc, dir, built = 1, color = null, color_name = null, singular = null)
	..(loc, dir, built)
	if(color)
		feather_color = color
		src.color = color
	if(color_name)
		feather_color_name = color_name
	if(singular)
		singular_name = singular
	if(feather_color_name)
		name = "[feather_color_name] feather dreamcatcher"
		singular_name = name
	else
		name = "feather dreamcatcher"
		if(!singular_name) singular_name = name
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/structure/dreamcatcher/attackby(obj/item/W as obj, mob/user as mob)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \\the [src] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "<span class='notice'>You pry \\the [src] off of the wall.</span>")
			// Pass feather color data back to the item
			new /obj/item/mounted/frame/dreamcatcher(get_turf(user), src.feather_color, src.feather_color_name, src.singular_name)
			qdel(src)
			return
	return ..()

// Feather pillow item (uses bedsheet logic as a base)
/obj/item/weapon/pillow
	name = "pillow"
	desc = "A handmade pillow, perfect for resting your head."
	icon = 'icons/obj/items.dmi'
	icon_state = "pillow"
	item_state = "pillow"
	w_class = W_CLASS_TINY
	_color = "white"
	clothing_flags = COLORS_OVERLAY
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	species_fit = list(VOX_SHAPED)
	w_type = RECYK_FABRIC
	flammable = TRUE
	starting_materials = list(MAT_FABRIC = 500)

/obj/item/weapon/pillow/New(loc, color = null, color_name = null)
	..(loc)
	if(color)
		src.color = color
	else
		src.color = "white"
	var/image/I = image(icon, src, "pillow-overlay")
	I.appearance_flags = RESET_COLOR
	I.color = src.color
	overlays += I
	if(color_name)
		src.name = "[color_name] feather pillow"
	else
		src.name = "feather pillow"


/obj/item/weapon/pen/quill
	name = "quill"
	desc = "A writing instrument made from a colored feather."
	icon = 'icons/obj/items.dmi'
	icon_state = "quill"
	item_state = "pen"
	w_class = W_CLASS_TINY
	var/feather_color = null
	var/feather_color_name = null

/obj/item/weapon/pen/quill/update_icon()
	if(feather_color)
		src.color = feather_color
	else
		src.color = null
	. = ..()

/obj/item/weapon/pen/quill/New(loc, color = null, color_name = null)
	..(loc)
	if(color)
		feather_color = color
		src.color = color
	if(color_name)
		feather_color_name = color_name
	if(feather_color_name)
		src.name = "[feather_color_name] quill pen"
	else
		src.name = "quill pen"
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/weapon/featherduster
	name = "feather duster"
	desc = "A fluffy duster made from colored feathers. Only good for light cleaning."
	icon = 'icons/obj/items.dmi'
	icon_state = "featherduster"
	item_state = "featherduster"
	w_class = W_CLASS_TINY
	var/feather_color = null
	var/feather_color_name = null

/obj/item/weapon/featherduster/update_icon()
	if(feather_color)
		src.color = feather_color
	else
		src.color = null
	. = ..()

/obj/item/weapon/featherduster/New(loc, color = null, color_name = null)
	..(loc)
	if(color)
		feather_color = color
		src.color = color
	if(color_name)
		feather_color_name = color_name
	if(feather_color_name)
		src.name = "[feather_color_name] feather duster"
	else
		src.name = "feather duster"
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

	// Only clean dirt, cobwebs, crumbs
/obj/item/weapon/featherduster/proc/clean(turf/simulated/A as turf)
	var/cleaned = FALSE
	for(var/obj/effect/decal/cleanable/O in A)
		if(istype(O, /obj/effect/decal/cleanable/dirt) || istype(O, /obj/effect/decal/cleanable/cobweb) || istype(O, /obj/effect/decal/cleanable/cobweb2) || istype(O, /obj/effect/decal/cleanable/crumbs))
			qdel(O)
			cleaned = TRUE
	if(cleaned)
		playsound(src, 'sound/effects/mop1.ogg', 25, 1)

/obj/item/weapon/featherduster/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A))
		return
	if(istype(A, /turf/simulated))
		clean(get_turf(A))
		return
	if(istype(A, /obj/effect/decal/cleanable/dirt) || istype(A, /obj/effect/decal/cleanable/cobweb) || istype(A, /obj/effect/decal/cleanable/cobweb2) || istype(A, /obj/effect/decal/cleanable/crumbs))
		qdel(A)
		playsound(src, 'sound/effects/mop1.ogg', 25, 1)
		return
	return ..()

/obj/item/clothing/head/headdress
	name = "feather headdress"
	desc = "A ceremonial headdress adorned with colorful feathers."
	icon_state = "headdress"
	item_state = "headdress"
	w_class = W_CLASS_TINY
	body_parts_covered = HEAD | UPPER_TORSO
	species_fit = list(VOX_SHAPED)
	clothing_flags = COLORS_OVERLAY
	var/feather_color = null
	var/feather_color_name = null

/obj/item/clothing/head/headdress/update_icon()
	if(feather_color)
		color = feather_color
	else
		color = null
	// Ensure overlays (worn sprite) are also colored
	if(overlays && overlays.len)
		for(var/image/I in overlays)
			if(feather_color)
				I.color = feather_color
			else
				I.color = null
	. = ..()

/obj/item/clothing/head/headdress/New(loc, color = null, color_name = null)
	..(loc)
	if(color)
		feather_color = color
		// Set up dyed_parts for overlay coloring
		dyed_parts = list("main" = list(feather_color, 255))
	if(color_name)
		feather_color_name = color_name
	if(feather_color_name)
		name = "[feather_color_name] feather headdress"
	else
		name = "feather headdress"
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

/obj/item/clothing/head/headdress/equipped(mob/user, slot)
	..()
	if(hascall(src, "update_icon"))
		call(src, "update_icon")()

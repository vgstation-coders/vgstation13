/obj/structure/easel
	name = "easel"
	desc = "Painters' best friend, always there to support their art"
	icon = 'icons/obj/painting_items.dmi'
	icon_state = "easel"
	density = 1
	plane = OBJ_PLANE
	layer = EASEL_LAYER

	var/obj/structure/painting/custom/painting = null

	var/rest_overlay = "easel_rest" // Piece the canvas will rest upon
	var/holder_overlay = "easel_holder" // Piece holding the canvas in place

	var/rest_default_y = 10 // Adjusted for a small (14x14) canvas
	var/holder_default_y = 24

	var/rest_sprite_height = 2 // How many pixels of the easel rest should sjut out under the canvas

	starting_materials = list(MAT_WOOD = 3*CC_PER_SHEET_WOOD)
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 5

/obj/structure/easel/New()
	..()
	update_icon()

/obj/structure/easel/Destroy()
	if (painting)
		qdel(painting)
	painting = null
	..()

/obj/structure/easel/attackby(obj/item/I, mob/user)

	// Deconstruct
	if (I.is_wrench(user))
		if (painting)
			painting.to_item(user)
		materials.makeSheets(src.loc)
		qdel(src)
		return

	// Place painting
	if (!painting && istype(I, /obj/item/mounted/frame/painting/custom))
		if(user.drop_item(I, loc))
			var/obj/item/mounted/frame/painting/custom/frame = I
			painting = frame.to_structure(null, user)
			transfer_fingerprints(frame, painting)
			painting.add_fingerprint(user)
			qdel(frame)
			lock_atom(painting)
			to_chat(user, "<span class='notice'>You attach \the [painting] to \the [src]...</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 25, 1)
			update_icon()
			return

	..()

/obj/structure/easel/unlock_atom(var/atom/movable/AM)
	..()
	if (painting == AM)
		painting = null
		update_icon()

/obj/structure/easel/update_icon()
	overlays.Cut()
	var/image/easel_holder = image(icon, null, holder_overlay, EASEL_OVERLAY_LAYER)
	easel_holder.plane = relative_plane(ABOVE_HUMAN_PLANE)
	var/image/rest = image(icon, rest_overlay)

	if (painting)
		rest.pixel_y = painting.pixel_y + painting.painting_data.offset_y
		easel_holder.pixel_y = painting.pixel_y + painting.painting_data.offset_y + painting.painting_data.bitmap_height
	else
		rest.pixel_y = rest_default_y
		easel_holder.pixel_y = holder_default_y

	rest.pixel_y -= rest_sprite_height

	overlays += easel_holder
	overlays += rest

/obj/item/mounted/frame/trophy_mount
	name = "trophy mount"
	desc = "A wooden trophy mount."
	icon = 'icons/obj/items.dmi'
	icon_state = "trophy_mount"
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	w_type = RECYK_WOOD
	frame_material = /obj/item/stack/sheet/wood
	sheets_refunded = 2
	autoignition_temperature = AUTOIGNITION_WOOD
	var/obj/item/held_item

/obj/item/mounted/frame/trophy_mount/Destroy()
	if(held_item)
		qdel(held_item)
		held_item = null
	..()

/obj/item/mounted/frame/trophy_mount/update_icon()
	if(!held_item)
		overlays.len = 0
		name = initial(name)
		desc = initial(desc)
		return
	name = "[held_item.name]"
	desc = "\A [held_item] mounted on a wooden trophy mount for display."
	var/image/temp = new (src)
	var/mutable_appearance/MA = new(held_item.appearance)
	MA.transform = matrix()
	MA.dir = SOUTH
	MA.plane = FLOAT_PLANE
	if(istype(held_item, /obj/item/organ/external/head))	//not every item can be tailored to fit well, but heads get special consideration
		MA.pixel_y = -8 * PIXEL_MULTIPLIER
	temp.appearance = MA
	overlays += temp.appearance

/obj/item/mounted/frame/trophy_mount/examine(mob/user)
	..()
	to_chat(user, held_item.desc)

/obj/item/mounted/frame/trophy_mount/attackby(obj/item/weapon/W, mob/user)
	..()
	if(iswrench(W))
		return
	if(held_item)
		to_chat(user, "This [initial(name)] already has \a [held_item] mounted on it.")
		return
	if(user.drop_item(W, src))
		user.visible_message("\The [user] mounts \the [W] onto \the [src].", "You mount \the [W] onto \the [src].")
		held_item = W
		update_icon()

/obj/item/mounted/frame/trophy_mount/attack_self(mob/user)
	if(held_item)
		var/obj/item/I = held_item
		held_item.forceMove(get_turf(src))
		user.put_in_hands(held_item)
		held_item = null
		update_icon()
		user.visible_message("\The [user] removes \the [I] from \the [src].", "You remove \the [I] from \the [src].")

/obj/item/mounted/frame/trophy_mount/do_build(turf/on_wall, mob/user)
	if(!user.drop_item(src))
		to_chat(user, "<span class='warning'>You can't let go of \the [src]!</span>")
		return
	user.visible_message("\The [user] hangs \the [src] on \the [on_wall].", "You hang \the [src] on \the [on_wall].")
	add_fingerprint(user)
	var/obj/structure/trophy_mount/T = new(get_turf(src))
	if(held_item)
		held_item.forceMove(T)
		T.held_item = held_item
		held_item = null
	T.update_icon()
	transfer_fingerprints(src, T)
	var/direction = get_dir(user,on_wall)
	if(direction & NORTH)
		T.pixel_y = WORLD_ICON_SIZE
	if(direction & SOUTH)
		T.pixel_y = -WORLD_ICON_SIZE
	if(direction & EAST)
		T.pixel_x = WORLD_ICON_SIZE
	if(direction & WEST)
		T.pixel_x = -WORLD_ICON_SIZE
	playsound(on_wall, 'sound/items/Deconstruct.ogg', 25, 1)
	qdel(src)

/obj/structure/trophy_mount
	name = "trophy mount"
	desc = "A wooden trophy mount."
	icon = 'icons/obj/items.dmi'
	icon_state = "trophy_mount"
	autoignition_temperature = AUTOIGNITION_WOOD
	anchored = 1
	var/obj/item/held_item

/obj/structure/trophy_mount/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>\The [src] is mounted securely. You'll need something to pry it off the wall.</span>")

/obj/structure/trophy_mount/attackby(obj/item/weapon/W, mob/user)
	if(iscrowbar(W))
		to_chat(user, "You begin prying the [initial(name)] off the wall.")
		playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "You pry the [initial(name)] off of the wall.")
			add_fingerprint(user)
			var/obj/item/mounted/frame/trophy_mount/T = new(get_turf(user))
			if(held_item)
				held_item.forceMove(T)
				T.held_item = held_item
				held_item = null
			T.update_icon()
			transfer_fingerprints(src, T)
			qdel(src)

/obj/structure/trophy_mount/Destroy()
	if(held_item)
		qdel(held_item)
		held_item = null
	..()

/obj/structure/trophy_mount/update_icon()
	if(!held_item)
		overlays.len = 0
		name = initial(name)
		desc = initial(desc)
		return
	name = "[held_item.name]"
	desc = "\A [held_item] mounted on a wooden trophy mount for display."
	var/datum/log/L = new
	held_item.examine(L)
	desc += "\n[L.log]"
	qdel(L)
	var/image/temp = new (src)
	var/mutable_appearance/MA = new(held_item.appearance)
	MA.transform = matrix()
	MA.dir = SOUTH
	MA.plane = FLOAT_PLANE
	if(istype(held_item, /obj/item/organ/external/head))	//not every item can be tailored to fit well, but heads get special consideration
		MA.pixel_y = -8 * PIXEL_MULTIPLIER
	temp.appearance = MA
	overlays += temp.appearance

/obj/structure/trophy_mount/examine(mob/user)
	..()
	to_chat(user, held_item.desc)
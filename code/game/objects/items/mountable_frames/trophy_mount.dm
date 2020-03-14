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
	var/list/params_list
	var/icon/clicked

/obj/item/mounted/frame/trophy_mount/New()
	..()
	update_icon()

/obj/item/mounted/frame/trophy_mount/Destroy()
	if(held_item)
		qdel(held_item)
		held_item = null
	..()

/obj/item/mounted/frame/trophy_mount/update_icon()
	overlays.Cut()
	if(!held_item)
		name = initial(name)
		desc = initial(desc)
	else
		name = "[held_item.name]"
		desc = "\A [held_item] mounted on a wooden trophy mount for display."
		var/mutable_appearance/temp = new(held_item.appearance)
		temp.transform = matrix()
		temp.dir = SOUTH
		temp.plane = FLOAT_PLANE
		if(params_list && params_list.len)
			var/clamp_x = clicked.Width() / 2
			var/clamp_y = clicked.Height() / 2
			temp.pixel_x = Clamp(text2num(params_list["icon-x"]) - clamp_x, -clamp_x, clamp_x)
			temp.pixel_y = Clamp(text2num(params_list["icon-y"]) - clamp_y, -clamp_y, clamp_y)

		overlays += temp

	clicked = new/icon(src.icon, src.icon_state, src.dir)

/obj/item/mounted/frame/trophy_mount/examine(mob/user)
	..()
	if(held_item)
		held_item.examine(user, "", FALSE)

/obj/item/mounted/frame/trophy_mount/attackby(obj/item/weapon/W, mob/user, params)
	if(iswrench(W) && held_item)
		to_chat(user, "<span class='notice'>\The [held_item] is in the way!</span>")
		return
	if(..())
		return
	params_list = params2list(params)
	mount_item(W, user)

/obj/item/mounted/frame/trophy_mount/AltClick(mob/user)
	var/obj/item/I = user.get_active_hand()
	if(I && I != src)
		params_list = list()
		mount_item(I, user)

/obj/item/mounted/frame/trophy_mount/proc/mount_item(obj/item/weapon/W, mob/user)
	if(!isturf(loc))
		if(user)
			to_chat(user, "<span class = 'warning'>You can't quite mount \the [W] onto \the [src]. Try placing it down on something.</span>")
		return
	if(held_item)
		if(user)
			to_chat(user, "This [initial(name)] already has \a [held_item] mounted on it.")
		return
	if(user)
		if(user.drop_item(W, src))
			user.visible_message("\The [user] mounts \the [W] onto \the [src].", "You mount \the [W] onto \the [src].")
		else
			return
	held_item = W
	w_class = max(initial(w_class),held_item.w_class)
	update_icon()


/obj/item/mounted/frame/trophy_mount/attack_self(mob/user)
	if(held_item)
		var/obj/item/I = held_item
		held_item.forceMove(get_turf(src))
		user.put_in_hands(held_item)
		held_item = null
		w_class = initial(w_class)
		params_list = list()
		update_icon()
		user.visible_message("\The [user] removes \the [I] from \the [src].", "You remove \the [I] from \the [src].")

/obj/item/mounted/frame/trophy_mount/do_build(turf/on_wall, mob/user)
	if(!user.drop_item(src))
		to_chat(user, "<span class='warning'>You can't let go of \the [src]!</span>")
		return
	user.visible_message("\The [user] hangs \the [src] on \the [on_wall].", "You hang \the [src] on \the [on_wall].")
	add_fingerprint(user)
	var/obj/structure/trophy_mount/T = new(get_turf(src))
	T.name = name
	T.desc = desc
	if(held_item)
		held_item.forceMove(T)
		T.held_item = held_item
		held_item = null
		T.params_list = params_list
	T.overlays += appearance
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
	var/list/params_list

/obj/structure/trophy_mount/attack_hand(mob/user)
	to_chat(user, "<span class='notice'>\The [src] is mounted securely. You'll need something to pry it off the wall.</span>")

/obj/structure/trophy_mount/attackby(obj/item/weapon/W, mob/user)
	if(iscrowbar(W))
		to_chat(user, "You begin prying \the [initial(name)] off the wall.")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		if(do_after(user, src,10))
			to_chat(user, "You pry \the [initial(name)] off of the wall.")
			add_fingerprint(user)
			var/obj/item/mounted/frame/trophy_mount/T = new(get_turf(user))
			if(held_item)
				held_item.forceMove(T)
				T.mount_item(held_item)
				held_item = null
				T.params_list = params_list
			transfer_fingerprints(src, T)
			qdel(src)

/obj/structure/trophy_mount/Destroy()
	if(held_item)
		to_chat(world, "held item destroyed.")
		qdel(held_item)
		held_item = null
	..()

/obj/structure/trophy_mount/examine(mob/user)
	..()
	if(held_item)
		held_item.examine(user, "", FALSE)
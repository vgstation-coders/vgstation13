/obj/structure/bed/chair/vehicle/cart/cargo
	name = "cargo cart"

/obj/structure/bed/chair/vehicle/cart/cargo/MouseDropTo(var/atom/movable/AM, var/mob/user)
	if(user.incapacitated() || user.lying)
		return ..()
	if(!Adjacent(user) || !user.Adjacent(src) || !src.Adjacent(AM))
		return ..()
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.w_class >= W_CLASS_LARGE)
			return ..()
	if(isobj(AM))
		var/obj/O = AM
		if(O.anchored)
			return ..()
	if(ismob(AM))
		var/mob/M = AM
		if(M.size >= SIZE_BIG)
			return
		return ..()
	.=..()
	to_chat(user, "[.]")
	if(!.)
		return buckle(AM, user)

/obj/structure/bed/chair/vehicle/cart/cargo/proc/buckle(var/atom/movable/AM, var/mob/user)
	if(user.size <= SIZE_SMALL) //Begone, mice
		return
	if(!user.has_hand_check()) //look ma, no hands!
		return
	if(AM.locked_to)
		to_chat(user, "<span class='warning'>\The [AM] is already locked to something.</span>")
		return
	if(AM.get_locked().len)
		to_chat(user, "<span class='warning'>Something is buckled into \the [AM].</span>")
		return
	if(get_locked().len)
		to_chat(user, "<span class='warning'>Something else is already buckled into \the [src]!</span>")
		return

	visible_message(\
		"<span class='notice'>\The [AM] is buckled in to \the [src] by \the [user]!</span>")

	playsound(src, 'sound/misc/buckle_click.ogg', 50, 1)
	add_fingerprint(user)

	lock_atom(AM, mob_lock_type)
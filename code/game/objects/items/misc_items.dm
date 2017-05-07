/obj/item/seeing_stone
	name = "seeing stone"
	desc = "Made from an enchanted mineral, peering through the lens in this stone is like looking into the Veil itself."
	icon_state = "seeing_stone"
	w_class = W_CLASS_TINY
	var/using = FALSE
	var/event_key

/obj/item/seeing_stone/attack_self(mob/user)
	..()
	if(using)
		stop_using(user)
	else
		start_using(user)

/obj/item/seeing_stone/proc/mob_moved(var/list/event_args, var/mob/holder)
	if(using)
		stop_using(holder)

/obj/item/seeing_stone/proc/start_using(mob/user)
	event_key = user.on_moved.Add(src, "mob_moved")
	user.visible_message("\The [user] holds \the [src] up to \his eye.","You hold \the [src] up to your eye.")
	user.see_invisible = INVISIBILITY_MAXIMUM
	user.see_invisible_override = INVISIBILITY_MAXIMUM
	if(user && user.client)
		var/client/C = user.client
		C.color = list(
						0.8,0,	0,	0,
						0.8,0,	0,	0,
				 		1,	0,	0,	0)
	using = TRUE

/obj/item/seeing_stone/proc/stop_using(mob/user)
	user.on_moved.Remove(event_key)
	user.visible_message("\The [user] lowers \the [src].","You lower \the [src].")
	user.see_invisible = initial(user.see_invisible)
	user.see_invisible_override = 0
	if(user && user.client)
		var/client/C = user.client
		C.color = initial(C.color)
	using = FALSE
/obj/structure/cross
	name = "wooden cross"
	icon_state = "cross"
	desc = "recquiscat in pace"

/obj/structure/cross/attackby(var/obj/item/weapon/W, var/mob/user)
	..()
	if(istype(W,/obj/item/weapon/pen))
		var/n_name = copytext(sanitize(input(user, "What would you like to write on the cross?", "Cross", null) as text|null), 1, MAX_NAME_LEN*3)
		if(n_name && Adjacent(user) && !user.stat)
			name = "[n_name]"
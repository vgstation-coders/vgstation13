/obj/item/weapon/gun/flintlock
	name = "plasma flintlock"
	desc = "A futuristic take on a primitive design. The flint strikes plasma powder to ignite it, sending a crude sphere hurtling at speeds in the rough direction of where you wanted to aim."
	icon_state = "plasma_flintlock"
	recoil = 1
	conventional_firearm = 0
	caliber = list(CRUDEBALL = 1)
	slot_flags = SLOT_BELT
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	var/loaded
	var/cocked

/obj/item/weapon/gun/flintlock/process_chambered()
	return in_chamber //Most of the process is done by hand by the player

/obj/item/weapon/gun/flintlock/isHandgun()
	return TRUE

/obj/item/weapon/gun/flintlock/update_icon()
	if(cocked && in_chamber)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_fired"

/obj/item/weapon/gun/flintlock/can_discharge()
	return (loaded && cocked)

/obj/item/weapon/gun/flintlock/attack_hand(mob/user)
	if(user.is_holding_item(src) && loaded && in_chamber)
		if(!cocked)
			user.visible_message("<span class = 'warning'>\The [user] cocks the flint on \the [src].</span>","<span class = 'notice'>You cock back the flint on \the [src].</span>")
			cocked = TRUE
		else
			user.visible_message("<span class = 'notice'>\The [user] uncocks the flint on \the [src].</span>")
			cocked = FALSE
		update_icon()
		return
	..()

/obj/item/weapon/gun/flintlock/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/crude_ball) && !in_chamber)
		to_chat(user, "<span class = 'notice'>You load \the [I] into \the [src].</span>")
		user.drop_item(I)
		qdel(I)
		var/obj/item/projectile/crude_ball/CB = new(src)
		in_chamber = CB
		update_icon()
		return
	else if(!loaded && I.reagents && I.reagents.has_reagent(PLASMA, 5) && I.is_open_container() && I.reagents.remove_reagent(PLASMA, 5))
		to_chat(user, "<span class = 'notice'>You powder \the [src] with \the [I].</span>")
		loaded = TRUE
		update_icon()
		return
	..()

/obj/item/crude_ball
	name = "crude metal ball"
	desc = "Doesn't look like you can do much with this."
	icon_state = "crude_ball"

/obj/item/projectile/crude_ball //Seperate subtype so people can't just throw crude balls at people to kill them
	name = "crude metal ball"
	desc = "You shouldn't even be able to see this."
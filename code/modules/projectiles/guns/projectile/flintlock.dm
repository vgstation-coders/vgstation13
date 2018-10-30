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
	var/loaded = FALSE
	var/cocked = FALSE

/obj/item/weapon/gun/flintlock/is_open_container()
	return TRUE

/obj/item/weapon/gun/flintlock/process_chambered()
	return in_chamber //Most of the process is done by hand by the player

/obj/item/weapon/gun/flintlock/isHandgun()
	return TRUE

/obj/item/weapon/gun/flintlock/update_icon()
	if(in_chamber)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]_fired"


/obj/item/weapon/gun/flintlock/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/crude_ball) && !in_chamber)
		to_chat(user, "<span class = 'notice'>You load \the [I] into \the [src].</span>")
		user.drop_item(I)
		qdel(I)
		var/obj/item/projectile/crude_ball/CB = new(src)
		in_chamber = CB
		update_icon()
		return
	..()

/obj/item/crude_ball
	name = "crude metal ball"
	desc = "Doesn't look like you can do much with this."
	icon_state = "crude_ball"

/obj/item/projectile/crude_ball //Seperate subtype so people can't just throw crude balls at people to kill them
	name = "crude metal ball"
	icon_state = "crudeball"
	nodamage = 0
	phase_type = PROJREACT_WINDOWS
	penetration = 10
	damage = 30

/obj/item/weapon/storage/bag/shot_bag
	name = "bag of shot"
	desc = "hopefully contains enough crudely fashioned spheres for a flintlock."
	icon = 'icons/obj/dice.dmi'
	icon_state = "dicebag"
	slot_flags = SLOT_BELT | SLOT_POCKET
	fits_max_w_class = W_CLASS_SMALL
	storage_slots = 21
	can_only_hold = list("/obj/item/crude_ball")
	display_contents_with_number = TRUE

/obj/item/weapon/storage/bag/shot_bag/full/New()
	..()
	for(var/i=1 to storage_slots)
		new /obj/item/crude_ball(src)
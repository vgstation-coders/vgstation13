
/obj/item/mouse_cage
	name = "small cage"
	desc = "A safe place where to keep tiny animals safe. Fit with a drinking bottle that can be refilled."
	icon = 'icons/obj/virology.dmi'
	icon_state = "cage"
	density = 1
	anchored = 0
	pressure_resistance = 5
	flags = FPRINT  | OPENCONTAINER

	var/lock_type = /datum/locking_category/buckle/cage

	var/mob/living/simple_animal/mouse/mouse = null


/obj/item/mouse_cage/New()
	..()
	create_reagents(10)

/obj/item/mouse_cage/Destroy()
	if (mouse)
		unlock_atom(mouse)
		mouse.pixel_x = 0
		mouse.pixel_y = 0
		mouse = null
	..()

/datum/locking_category/buckle/cage

/obj/item/mouse_cage/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/item/mouse_cage/attack_hand(var/mob/user)
	if (mouse)
		if( !user.get_active_hand() )
			unlock_atom(mouse)
			mouse.pixel_x = 0
			mouse.pixel_y = 0
			mouse.scoop_up(user)
			user.visible_message("<span class='notice'>[user] picks up \the [mouse].</span>", "<span class='notice'>You pick up \the [mouse].</span>")
			mouse = null
	else
		MouseDropFrom(user)

/obj/item/mouse_cage/attackby(var/obj/O,var/mob/user)
	. = ..()

	if (!mouse && istype (O,/obj/item/weapon/holder/animal/mouse))
		var/obj/item/weapon/holder/animal/mouse/store = O
		var/mob/living/simple_animal/mouse/inside = store.stored_mob
		if(!user.drop_item(O, loc))
			to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
			return
		mouse = inside
		qdel(store)
		mouse.forceMove(loc)
		mouse.pixel_x = pixel_x
		mouse.pixel_y = pixel_y+5
		lock_atom(mouse,lock_type)

/obj/item/mouse_cage/pickup(mob/user)
	if (mouse)
		mouse.forceMove(src)
		var/image/I = image(mouse.icon, src, mouse.icon_state, layer+1, mouse.dir)
		I.pixel_y = 5
		overlays += I

/obj/item/mouse_cage/dropped(mob/user)
	overlays.len = 0
	spawn(1)
		if (mouse)
			mouse.forceMove(loc)
			mouse.pixel_x = pixel_x
			mouse.pixel_y = pixel_y+5


/obj/item/mouse_cage/MouseDropFrom(var/over_object)
	if(!usr.incapacitated() && (usr.contents.Find(src) || Adjacent(usr)))
		if(!istype(usr, /mob/living/carbon/slime) && !istype(usr, /mob/living/simple_animal))
			if(istype(over_object,/obj/abstract/screen/inventory))
				var/obj/abstract/screen/inventory/OI = over_object

				if(OI.hand_index && usr.put_in_hand_check(src, OI.hand_index))
					usr.u_equip(src, 0)
					usr.put_in_hand(OI.hand_index, src)
					src.add_fingerprint(usr)

			else if(istype(over_object,/mob/living))
				if(usr == over_object)
					if( !usr.get_active_hand() )
						usr.put_in_hands(src)
						usr.visible_message("<span class='notice'>[usr] picks up the [src].</span>", "<span class='notice'>You pick up \the [src].</span>")
	return ..()

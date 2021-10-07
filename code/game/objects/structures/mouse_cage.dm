
/obj/item/critter_cage
	name = "small cage"
	desc = "A safe place where to keep tiny animals safe. Fit with a drinking bottle that can be refilled."
	icon = 'icons/obj/virology.dmi'
	icon_state = "cage"
	density = 1
	anchored = 0
	pressure_resistance = 5
	flags = FPRINT  | OPENCONTAINER

	var/lock_type = /datum/locking_category/buckle/cage

	var/atom/movable/critter = null


/obj/item/critter_cage/New()
	..()
	create_reagents(10)

/obj/item/critter_cage/Destroy()
	if (critter)
		unlock_atom(critter)
		critter.forceMove(get_turf(src))
		critter = null
	..()

/datum/locking_category/buckle/cage

/obj/item/critter_cage/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/item/critter_cage/attack_hand(var/mob/user)
	if (critter)
		if( !user.get_active_hand() )
			unlock_atom(critter)
			if(isliving(critter))
				var/mob/living/L = critter
				L.scoop_up(user)
			else
				var/matrix/grow = matrix()
				grow.Scale(1)
				critter.transform = grow
				user.put_in_hands(critter)
			user.visible_message("<span class='notice'>[user] picks up \the [critter].</span>", "<span class='notice'>You pick up \the [critter].</span>")
			critter = null
	else
		MouseDropFrom(user)

/obj/item/critter_cage/attackby(var/obj/O,var/mob/user)
	. = ..()

	if (isturf(loc))
		if (!critter && istype (O,/obj/item/weapon/holder/animal))
			var/obj/item/weapon/holder/animal/store = O
			var/mob/living/simple_animal/inside = store.stored_mob
			if (inside.size > SIZE_TINY)
				to_chat(user, "<span class='warning'>\The [inside] is too big for \the [src]!</span>")
				return
			if(!user.drop_item(O, loc))
				to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
				return
			critter = inside
			qdel(store)
			critter.forceMove(loc)
			lock_atom(critter,lock_type)
		if(!critter && istype(O, /obj/item/device/mmi))
			var/obj/item/device/mmi/M = O
			if(!M.brainmob)
				to_chat(user, "<span class='warning'>Without a brain inside that won't accomplish a thing.</span>")
			else
				if(user.drop_item(M, loc))
					var/matrix/shrink = matrix()
					shrink.Scale(0.5)
					M.transform = shrink
					critter = M
					critter.forceMove(loc)
					lock_atom(critter, lock_type)
		if (istype (O,/obj/item/weapon/reagent_containers/food/snacks))
			if(!user.drop_item(O, loc))
				to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
				return
			O.forceMove(loc)
			O.pixel_x = pixel_x
			O.pixel_y = pixel_y-9
	else
		to_chat(user, "<span class='warning'>Put the cage down before placing anything inside.</span>")

/obj/item/critter_cage/lock_atom(var/atom/movable/AM)
	. = ..()
	if (.)
		AM.plane = MOB_PLANE
		AM.pixel_x = pixel_x
		if(isliving(critter))
			AM.pixel_y = pixel_y+5
		else
			AM.pixel_y = pixel_y-3

/obj/item/critter_cage/unlock_atom(var/atom/movable/AM)
	. = ..()
	if (.)
		AM.plane = initial(AM.plane)
		AM.pixel_x = initial(AM.pixel_x)
		AM.pixel_y = initial(AM.pixel_y)

/obj/item/critter_cage/pickup(var/mob/user)//When we pick up the cage, let's move the critter inside
	if (critter)
		critter.forceMove(src)
		var/image/I = image(critter.icon, src, critter.icon_state, layer+1, critter.dir)
		I.pixel_y = 5
		overlays += I

/obj/item/critter_cage/dropped(var/mob/user)//When we drop the cage, let's place the mouse back on top of it
	overlays.len = 0

	if (critter)
		critter.forceMove(loc)
		critter.pixel_x = pixel_x
		critter.pixel_y = pixel_y+5

/obj/item/critter_cage/setPixelOffsetsFromParams(params, mob/user, base_pixx = 0, base_pixy = 0, clamp = TRUE)
	. = ..()//If we're placing the cage on a table, let's make sure that their offset gets properly updated

	if (. && critter)
		critter.forceMove(loc)
		critter.pixel_x = pixel_x
		critter.pixel_y = pixel_y+5

/obj/item/critter_cage/MouseDropFrom(atom/over_object)
	MouseDropPickUp(over_object)
	return ..()

/obj/item/critter_cage/with_mouse
	icon_state = "cage_map"

/obj/item/critter_cage/with_mouse/New()
	..()
	icon_state = "cage"
	if (loc)
		critter = new /mob/living/simple_animal/mouse/balbc/named(loc)
		lock_atom(critter,lock_type)

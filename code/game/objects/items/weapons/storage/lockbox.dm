/obj/item/weapon/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	w_class = W_CLASS_LARGE
	fits_max_w_class = W_CLASS_MEDIUM
	max_combined_w_class = 14 //The sum of the w_classes of all the items in this storage item.
	storage_slots = 4
	req_one_access = list(access_armory)
	var/locked = 1
	var/broken = 0
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"
	var/tracked_access = "It doesn't look like it's ever been used."
	health = 50

/obj/item/weapon/storage/lockbox/can_use()
	return broken || !locked

/obj/item/weapon/storage/lockbox/attack_robot(var/mob/user)
	to_chat(user, "<span class='rose'>This box was not designed for use by non-organics.</span>")
	return

/obj/item/weapon/storage/lockbox/proc/toggle(var/mob/user, var/id_name)
	if(allowed(user))
		. = TRUE
		locked = !locked
		user.visible_message("<span class='notice'>The lockbox has been [locked ? null : "un"]locked by [user].</span>", "<span class='rose'>You [locked ? null : "un"]lock the box.</span>")
		tracked_access = "The tracker reads: 'Last locked by [id_name || get_id_name(user)].'"
		if(locked)
			icon_state = icon_locked
		else
			icon_state = icon_closed
	else
		to_chat(user, "<span class='notice'>Access Denied.</span>")
		return FALSE

/proc/get_id_name(var/mob/user)
	if (ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/O = H.get_item_by_slot(slot_wear_id)
		var/obj/item/weapon/card/id/I = null
		if (isPDA(O))
			var/obj/item/device/pda/P = O
			I = P.id
		if (isID(O))
			I = O
		if (!I)
			I = locate() in H.held_items
		if (I)
			return I.registered_name
		else
			return "UNKNOWN" // Shouldn't happen but eh
	
	else if (issilicon(user)) // Currently, borgos cannot open lockboxes, but if you want to make a module who can, this will work.
		return "[user]"


/obj/item/weapon/storage/lockbox/oneuse/toggle(var/mob/user, var/id_name)
	. = ..()
	if (.)
		for(var/atom/movable/A in src)
			remove_from_storage(A, get_turf(src))
		qdel(src)

/obj/item/weapon/storage/lockbox/attackby(obj/item/weapon/W, mob/user)
	if (isID(W))
		var/obj/item/weapon/card/id/I = W
		if(broken)
			to_chat(user, "<span class='rose'>It appears to be broken.</span>")
			return
		return toggle(user, I.registered_name)
	if (isPDA(W))
		var/obj/item/device/pda/P = W 
		var/obj/item/weapon/card/id/I = P.id
		if (!I)
			return
		if(broken)
			to_chat(user, "<span class='rose'>It appears to be broken.</span>")
			return
		return toggle(user, I.registered_name)
	if(!locked)
		. = ..()
	else
		to_chat(user, "<span class='warning'>It's locked!</span>")

/obj/item/weapon/storage/lockbox/emag_act(var/mob/user)
	if (broken)
		return FALSE
	broken = 1
	locked = 0
	desc = "It appears to be broken."
	icon_state = src.icon_broken
	user.visible_message("<span class='danger'>\The [src] has been broken by \the [user] with an electromagnetic card!</span>", "<span class='notice'>You break open \the [src].</span>", "<span class='notice'>You hear a faint click sound.</span>", range = 3)
	return TRUE

/obj/item/weapon/storage/lockbox/oneuse/emag_act(var/mob/user)
	. = ..()
	if (.)
		for(var/atom/movable/A in src)
			remove_from_storage(A, get_turf(src))
		qdel(src)


/obj/item/weapon/storage/lockbox/show_to(mob/user as mob)
	if(locked)
		to_chat(user, "<span class='warning'>It's locked!</span>")
	else
		..()
	return

/obj/item/weapon/storage/lockbox/bullet_act(var/obj/item/projectile/Proj)
	// WHY MUST WE DO THIS
	// WHY
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet))
		if(!istype(Proj ,/obj/item/projectile/beam/lasertag) && !istype(Proj ,/obj/item/projectile/beam/practice) && !Proj.nodamage)
			health -= Proj.damage
	..()
	if(health <= 0)
		for(var/atom/movable/A in src)
			remove_from_storage(A, get_turf(src))

		qdel(src)
	return

/obj/item/weapon/storage/lockbox/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if(prob(80))
				for(var/atom/movable/A in src)
					remove_from_storage(A, get_turf(src))
					A.ex_act(3)
				qdel(src)
		if(3)
			if(prob(50))
				for(var/atom/movable/A in src)
					remove_from_storage(A, get_turf(src))
				qdel(src)

/obj/item/weapon/storage/lockbox/emp_act(severity)
	..()
	if(!broken)
		var/probab
		switch(severity)
			if(1)
				probab = 80
			if(2)
				probab = 50
		if(prob(probab))
			. = TRUE
			locked = !locked
			src.update_icon()
			if(!locked)
				for(var/atom/movable/A in src)
					remove_from_storage(A, get_turf(src))


/obj/item/weapon/storage/lockbox/oneuse/emp_act(severity)
	. = ..()
	if (.)
		qdel(src)

/obj/item/weapon/storage/lockbox/update_icon()
	..()
	if (broken)
		icon_state = src.icon_broken
	else if(locked)
		icon_state = src.icon_locked
	else
		icon_state = src.icon_closed
	return

/obj/item/weapon/storage/lockbox/loyalty
	name = "lockbox (loyalty implants)"
	req_one_access = list(access_security)

/obj/item/weapon/storage/lockbox/loyalty/New()
	..()
	new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implantcase/loyalty(src)
	new /obj/item/weapon/implanter/loyalty(src)

/obj/item/weapon/storage/lockbox/tracking
	name = "lockbox (tracking implants)"
	req_one_access = list(access_security)
	storage_slots = 5

/obj/item/weapon/storage/lockbox/tracking/New()
	..()
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantcase/tracking(src)
	new /obj/item/weapon/implantpad(src)
	new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/lockbox/chem
	name = "lockbox (chemical implants)"
	req_one_access = list(access_security)
	storage_slots = 5

/obj/item/weapon/storage/lockbox/chem/New()
	..()
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/implantcase/chem(src)
	new /obj/item/weapon/reagent_containers/syringe(src)
	new /obj/item/weapon/implanter(src)

/obj/item/weapon/storage/lockbox/clusterbang
	name = "lockbox (clusterbang)"
	desc = "You have a bad feeling about opening this."
	req_one_access = list(access_security)

/obj/item/weapon/storage/lockbox/clusterbang/New()
	..()
	new /obj/item/weapon/grenade/flashbang/clusterbang(src)

/obj/item/weapon/storage/lockbox/secway
	name = "lockbox (secway keys)"
	desc = "Nobody knows this mall better than I do."
	req_one_access = list(access_security)

/obj/item/weapon/storage/lockbox/secway/New()
	..()
	new /obj/item/key/security(src)
	new /obj/item/key/security(src)
	new /obj/item/key/security(src)
	new /obj/item/key/security(src)

/obj/item/weapon/storage/lockbox/unlockable
	name = "semi-secure lockbox"
	desc = "A securable locked box. Can't lock anything, but can track whoever used it."
	req_one_access = list()

/obj/item/weapon/storage/lockbox/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>[tracked_access]</span>")

/obj/item/weapon/storage/lockbox/unlockable/attackby(obj/O as obj, mob/user as mob)
	if (istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/ID = O
		if(src.broken)
			to_chat(user, "<span class='rose'>It appears to be broken.</span>")
			return
		else
			src.locked = !( src.locked )
			if(src.locked)
				src.icon_state = src.icon_locked
				to_chat(user, "<span class='rose'>You lock the [src.name]!</span>")
				tracked_access = "The tracker reads: 'Last locked by [ID.registered_name]'."
				return
			else
				src.icon_state = src.icon_closed
				to_chat(user, "<span class='rose'>You unlock the [src.name]!</span>")
				tracked_access = "The tracker reads: 'Last unlocked by [ID.registered_name].'"
				return
	else
		. = ..()

/obj/item/weapon/storage/lockbox/coinbox
	name = "coinbox"
	desc = "A secure container for the profits of a vending machine."
	icon_state = "coinbox+l"
	w_class = W_CLASS_SMALL
	can_only_hold = list("/obj/item/voucher","/obj/item/weapon/coin","/obj/item/weapon/reagent_containers/food/snacks/customizable/candy/coin","/obj/item/weapon/reagent_containers/food/snacks/chococoin")
	max_combined_w_class = 30
	force = 8
	throwforce = 10
	storage_slots = 20
	req_one_access = list(access_qm)
	locked = 1
	broken = 0
	icon_locked = "coinbox+l"
	icon_closed = "coinbox"
	icon_broken = "coinbox+b"

/obj/item/weapon/storage/lockbox/lawgiver
	name = "lockbox (lawgiver)"
	req_one_access = list(access_armory)

/obj/item/weapon/storage/lockbox/lawgiver/New()
	..()
	new /obj/item/weapon/gun/lawgiver(src)

/obj/item/weapon/storage/lockbox/lawgiver/with_magazine/New()
	..()
	new /obj/item/ammo_storage/magazine/lawgiver(src)

/obj/item/weapon/storage/lockbox/oneuse
	desc = "A locked box. When unlocked, the case will fall apart."

/obj/item/weapon/storage/lockbox/AltClick()
	if(verb_togglelock())
		return
	return ..()

/obj/item/weapon/storage/lockbox/verb/verb_togglelock()
	set src in oview(1) // One square distance
	set category = "Object"
	set name = "Toggle Lock"

	if(usr.incapacitated()) // Don't use it if you're not able to! Checks for stuns, ghost and restrain
		return

	if(!Adjacent(usr) || usr.loc == src)
		return

	if(src.broken)
		return

	if (ishuman(usr))
		if (locked)
			toggle(usr)
			return 1
	else
		to_chat(usr, "<span class='warning'>You lack the dexterity to do this.</span>")
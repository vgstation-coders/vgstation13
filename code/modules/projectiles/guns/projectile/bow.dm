/obj/item/weapon/arrow

	name = "bolt"
	desc = "It's got a tip for you - get the point?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	flags = FPRINT
	throwforce = 8
	w_class = W_CLASS_MEDIUM
	sharpness = 1
	sharpness_flags = SHARP_TIP

/obj/item/weapon/arrow/proc/removed() //Helper for metal rods falling apart.
	return

/obj/item/weapon/arrow/quill

	name = "vox quill"
	desc = "A wickedly barbed quill from some bizarre animal."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "quill"
	throwforce = 5

/obj/item/weapon/arrow/rod

	name = "metal rod"
	desc = "Don't cry for me, Orithena."
	icon_state = "metal-rod"

/obj/item/weapon/arrow/rod/removed(mob/user)
	if(throwforce == 15) // The rod has been superheated - we don't want it to be useable when removed from the bow.
		to_chat(user, "[src] shatters into a scattering of overstressed metal shards as it leaves the crossbow.")
		var/obj/item/weapon/shard/shrapnel/S = new()
		S.forceMove(get_turf(src))
		qdel(src)

/obj/item/weapon/crossbow

	name = "powered crossbow"
	desc = "A 2557AD twist on an old classic. Pick up that can."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "crossbow"
	item_state = "crossbow-solid"
	w_class = W_CLASS_HUGE
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT | SLOT_BACK

	w_class = W_CLASS_MEDIUM

	var/tension = 0                       // Current draw on the bow.
	var/max_tension = 5                   // Highest possible tension.
	var/release_speed = 5                 // Speed per unit of tension.
	var/mob/living/current_user = null    // Used to see if the person drawing the bow started drawing it.
	var/obj/item/weapon/arrow = null      // Nocked arrow.
	var/obj/item/weapon/cell/cell = null  // Used for firing special projectiles like rods.

/obj/item/weapon/crossbow/get_cell()
	return cell

/obj/item/weapon/crossbow/attackby(obj/item/W as obj, mob/user as mob)
	if(!arrow)
		if (istype(W,/obj/item/weapon/arrow))
			if(!user.drop_item(W, src))
				user << "<span class='warning'>You can't let go of \the [W]!</span>"
				return

			arrow = W
			user.visible_message("[user] slides [arrow] into [src].","You slide [arrow] into [src].")
			icon_state = "crossbow-nocked"
			return
		else if(istype(W,/obj/item/stack/rods))
			var/obj/item/stack/rods/R = W
			R.use(1)
			arrow = new /obj/item/weapon/arrow/rod(src)
			arrow.fingerprintslast = src.fingerprintslast
			arrow.forceMove(src)
			icon_state = "crossbow-nocked"
			user.visible_message("[user] haphazardly jams [arrow] into [src].","You jam [arrow] into [src].")
			if(cell)
				if(cell.charge >= 500)
					to_chat(user, "<span class='notice'>[arrow] plinks and crackles as it begins to glow red-hot.</span>")
					arrow.throwforce = 15
					arrow.icon_state = "metal-rod-superheated"
					cell.charge -= 500
			return

	if(istype(W, /obj/item/weapon/cell))
		if(!cell)
			if(!user.drop_item(W, src))
				user << "<span class='warning'>You can't let go of \the [W]!</span>"
				return

			cell = W
			to_chat(user, "<span class='notice'>You jam [cell] into [src] and wire it to the firing coil.</span>")
			if(arrow)
				if(istype(arrow,/obj/item/weapon/arrow/rod) && arrow.throwforce < 15 && cell.charge >= 500)
					to_chat(user, "<span class='notice'>[arrow] plinks and crackles as it begins to glow red-hot.</span>")
					arrow.throwforce = 15
					arrow.icon_state = "metal-rod-superheated"
					cell.charge -= 500
		else
			to_chat(user, "<span class='notice'>[src] already has a cell installed.</span>")

	else if(W.is_screwdriver(user))
		if(cell)
			var/obj/item/C = cell
			C.forceMove(get_turf(user))
			cell = null
			to_chat(user, "<span class='notice'>You jimmy [cell] out of [src] with [W].</span>")
		else
			to_chat(user, "<span class='notice'>[src] doesn't have a cell installed.</span>")

	else
		..()

/obj/item/weapon/crossbow/attack_self(mob/living/user as mob)
	if(tension)
		if(arrow)
			user.visible_message("[user] relaxes the tension on [src]'s string and removes [arrow].","You relax the tension on [src]'s string and remove [arrow].")
			var/obj/item/weapon/arrow/A = arrow
			A.forceMove(get_turf(src))
			A.removed(user)
			arrow = null
		else
			user.visible_message("[user] relaxes the tension on [src]'s string.","You relax the tension on [src]'s string.")
		tension = 0
		icon_state = "crossbow"
	else
		draw(user)

/obj/item/weapon/crossbow/proc/draw(var/mob/user as mob)


	if(!arrow)
		to_chat(user, "You don't have anything nocked to [src].")
		return

	if(user.restrained())
		return

	current_user = user

	user.visible_message("[user] begins to draw back the string of [src].","You begin to draw back the string of [src].")
	tension = 1
	spawn(25) increase_tension(user)

/obj/item/weapon/crossbow/proc/increase_tension(var/mob/user as mob)


	if(!arrow || !tension || current_user != user) //Arrow has been fired, bow has been relaxed or user has changed.
		return

	tension++
	icon_state = "crossbow-drawn"

	if(tension>=max_tension)
		tension = max_tension
		to_chat(usr, "[src] clunks as you draw the string to its maximum tension!")
	else
		user.visible_message("[usr] draws back the string of [src]!","You continue drawing back the string of [src]!")
		spawn(25) increase_tension(user)

/obj/item/weapon/crossbow/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)

	if (istype(target, /obj/item/weapon/storage/backpack ))
		src.dropped()
		return

	else if (target.loc == user.loc)
		return

	else if (locate (/obj/structure/table, src.loc))
		return

	else if(target == user)
		return

	if(!tension)
		to_chat(user, "You haven't drawn back the bolt!")
		return 0

	if (!arrow)
		to_chat(user, "You have no arrow nocked to [src]!")
		return 0
	else
		spawn(0) Fire(target,user,params)

/obj/item/weapon/crossbow/proc/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0)


	add_fingerprint(user)

	var/turf/curloc = get_turf(user)
	var/turf/targloc = get_turf(target)
	if (!istype(targloc) || !istype(curloc))
		return

	user.visible_message("<span class='danger'>[user] releases [src] and sends [arrow] streaking toward [target]!</span>","<span class='danger'>You release [src] and send [arrow] streaking toward [target]!</span>")

	var/obj/item/weapon/arrow/A = arrow
	A.forceMove(get_turf(user))
	A.throw_at(target,10,tension*release_speed)
	arrow = null
	tension = 0
	icon_state = "crossbow"

/obj/item/weapon/crossbow/dropped(mob/user)
	if(arrow)
		var/obj/item/weapon/arrow/A = arrow
		A.forceMove(get_turf(src))
		A.removed(user)
		arrow = null
		tension = 0
		icon_state = "crossbow"



/* construction*/
/obj/item/crossbowframe
	name = "crossbow frame"
	desc = "A half-finished crossbow."
	icon_state = "crossbowframe0"
	item_state = "crossbow-solid"

	var/buildstate = 0

/obj/item/crossbowframe/update_icon()
	icon_state = "crossbowframe[buildstate]"

/obj/item/crossbowframe/examine(mob/user)
	. = ..()
	switch(buildstate)
		if(1) to_chat(user, "It has a loose rod frame in place.")
		if(2) to_chat(user, "It has a steel backbone welded in place.")
		if(3) to_chat(user, "It has a steel backbone and a cell mount installed.")
		if(4) to_chat(user, "It has a steel backbone, plastic lath and a cell mount installed.")
		if(5) to_chat(user, "It has a steel cable loosely strung across the lath.")

/obj/item/crossbowframe/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/rods))
		if(buildstate == 0)
			var/obj/item/stack/rods/R = W
			if(R.use(3))
				to_chat(user, "<span class='notice'>You assemble a backbone of rods around the wooden stock.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least three rods to complete this task.</span>")
			return
	else if(iswelder(W))
		if(buildstate == 1)
			var/obj/item/weapon/weldingtool/T = W
			if(T.remove_fuel(0,user))
				if(!src || !T.isOn()) return
				playsound(src.loc, 'sound/items/Welder2.ogg', 100, 1)
				to_chat(user, "<span class='notice'>You weld the rods into place.</span>")
			buildstate++
			update_icon()
		return
	else if(istype(W,/obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(buildstate == 2)
			if(C.use(5))
				to_chat(user, "<span class='notice'>You wire a crude cell mount into the top of the crossbow.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least five segments of cable coil to complete this task.</span>")
			return
		else if(buildstate == 4)
			if(C.use(5))
				to_chat(user, "<span class='notice'>You string a steel cable across the crossbow's lath.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least five segments of cable coil to complete this task.</span>")
			return

	else if(istype(W,/obj/item/stack/sheet/mineral/plastic))
		if(buildstate == 3)
			var/obj/item/stack/sheet/mineral/plastic/P = W
			if(P.use(3))
				to_chat(user, "<span class='notice'>You assemble and install a heavy plastic lath onto the crossbow.</span>")
				buildstate++
				update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least three plastic sheets to complete this task.</span>")
	/*else if(istype(W,/obj/item/stack/sheet/mineral/plastic) && W.get_material_name() == "plastic")
		if(buildstate == 3)
			to_chat(user, "<span class='notice'>You assemble and install a heavy plastic lath onto the crossbow.</span>")
			buildstate++
			update_icon()
			else
				to_chat(user, "<span class='notice'>You need at least three plastic sheets to complete this task.</span>")
			return*/
	else if(istype(W,/obj/item/weapon/screwdriver))
		if(buildstate == 5)
			to_chat(user, "<span class='notice'>You secure the crossbow's various parts.</span>")
			new /obj/item/weapon/crossbow(get_turf(src))
			qdel(src)
		return
	else
		..()


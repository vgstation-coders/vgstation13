/obj/item/device/blinder
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera."
	icon_state = "polaroid"
	item_state = "polaroid"
	w_class = W_CLASS_SMALL
	flags = FPRINT
	siemens_coefficient = 1
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=1;" + Tc_ENGINEERING + "=1"
	starting_materials = list(MAT_IRON = 2000)
	w_type = RECYK_ELECTRONIC
	var/obj/item/weapon/cell/cell = null
	var/obj/item/weapon/light/bulb/flashbulb = null
	var/start_with_bulb = TRUE
	var/decon_path = /obj/item/device/camera
	var/powercost = 10000
	var/base_desc = ""

/obj/item/device/blinder/get_cell()
	return cell

/obj/item/device/blinder/Destroy()
	if(cell)
		qdel(cell)
		cell = null
	if(flashbulb)
		qdel(flashbulb)
		flashbulb = null
	..()

/obj/item/device/blinder/New(var/empty = FALSE)
	..()
	if(empty == TRUE)
		start_with_bulb = FALSE
	if(start_with_bulb)
		flashbulb = new(src)
	update_verbs()
	base_desc = desc
	update_desc()

/obj/item/device/blinder/proc/update_desc()
	if(cell)
		desc = "[base_desc] There is a power cell in the film chamber for some reason."
	else
		desc = "[base_desc] The film chamber is filled with wire for some reason."

/obj/item/device/blinder/examine(mob/user)
	..()
	if(flashbulb && flashbulb.status >= LIGHT_BROKEN)
		to_chat(user, "<span class='warning'>\The [src]'s flashbulb is broken.</span>")
	else if (!flashbulb)
		to_chat(user, "<span class='info'>\The [src] appears to be missing a flashbulb.</span>")

/obj/item/device/blinder/attack_self(mob/user as mob)
	if(!flashbulb || flashbulb.status >= LIGHT_BROKEN || !cell)
		if (user)
			user.visible_message("*click click*", "<span class='danger'>*click*</span>")
			playsound(user, 'sound/weapons/empty.ogg', 100, 1)
		else
			src.visible_message("*click click*")
			playsound(src, 'sound/weapons/empty.ogg', 100, 1)
		return

	if(cell)
		if(cell.charge < powercost)
			user.visible_message("[user] presses the button on \the [src], but the flashbulb merely flickers.","You press the button on \the [src], but the flashbulb merely flickers.")
			to_chat(user, "<span class='warning'>There's not enough energy in the cell to power the flashbulb!</span>")
			playsound(src, 'sound/weapons/empty.ogg', 100, 1)
			return

		var/flash_turf = get_turf(src)
		if(!flash_turf)
			return
		for(var/mob/living/M in get_hearers_in_view(7, flash_turf))
			flash(get_turf(M), M)


		user.visible_message("<span class='danger'>[user] overloads \the [src]'s flash bulb!</span>","<span class='danger'>You overload \the [src]'s flash bulb!</span>")
		to_chat(user, "<span class='warning'>\The [src]'s flash bulb shatters!</span>")

		cell.charge -= powercost
		cell.updateicon()

		flashbulb.shatter(verbose = FALSE)
		update_verbs()

/obj/item/device/blinder/proc/flash(var/turf/T , var/mob/living/M)
	playsound(src, 'sound/weapons/flash.ogg', 100, 1)

	if(M.blinded)
		return

	M.flash_eyes(visual = 1, affect_silicon = 1)

	if(issilicon(M))
		M.Knockdown(rand(5, 10))
		M.visible_message("<span class='warning'>[M]'s sensors are overloaded by the flash of light!</span>","<span class='warning'>Your sensors are overloaded by the flash of light!</span>")

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/organ/internal/eyes/E = H.internal_organs_by_name["eyes"]
		if (E && E.damage >= E.min_bruised_damage)
			to_chat(M, "<span class='warning'>Your eyes start to burn badly!</span>")
	M.update_icons()

/obj/item/device/blinder/proc/update_verbs()
	if(cell)
		verbs += /obj/item/device/blinder/verb/remove_cell
	else
		verbs -= /obj/item/device/blinder/verb/remove_cell
	if(flashbulb && flashbulb.status >= LIGHT_BROKEN)
		verbs += /obj/item/device/blinder/verb/remove_bulb
	else
		verbs -= /obj/item/device/blinder/verb/remove_bulb

/obj/item/device/blinder/verb/remove_cell()
	set name = "Remove power cell"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!cell)
		return
	else
		to_chat(usr, "You remove \the [cell] from \the [src].")
		usr.put_in_hands(cell)
		cell = null
		update_desc()
	update_verbs()

/obj/item/device/blinder/verb/remove_bulb()
	set name = "Remove broken bulb"
	set category = "Object"
	set src in range(0)

	if(usr.isUnconscious())
		to_chat(usr, "You can't do that while unconscious.")
		return

	if(!flashbulb)
		return
	else
		flashbulb.forceMove(get_turf(loc))
		usr.put_in_hands(flashbulb)
		to_chat(usr, "You remove the broken [flashbulb.name] from \the [src].")
		flashbulb = null
	update_verbs()

/obj/item/device/blinder/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(cell)
			to_chat(user, "<span class='warning'>There is already a power cell inside \the [src].</span>")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		cell = W
		user.visible_message("[user] inserts \the [W] into \the [src].","You insert \the [W] into \the [src].")
		update_desc()
		update_verbs()

	if(istype(W, /obj/item/weapon/light/bulb))
		if(flashbulb)
			if(flashbulb.status >= LIGHT_BROKEN)
				to_chat(user, "<span class='warning'>You need to remove the damaged bulb first.</span>")
				return
			else
				to_chat(user, "There is already a perfectly good bulb inside \the [src].")
				return
		var/obj/item/weapon/light/bulb/B = W
		if(B.status == LIGHT_BROKEN)
			to_chat(user, "<span class='warning'>That [B.name] is broken, it won't function in \the [src].</span>")
			return
		else if(B.status == LIGHT_BURNED)
			to_chat(user, "<span class='warning'>That [B.name] is burned out, it won't function in \the [src].</span>")
			return
		if(!user.drop_item(W, src))
			to_chat(user, "<span class='warning'>You can't let go of \the [W]!</span>")
			return 1
		flashbulb = B
		user.visible_message("[user] inserts \the [W] into \the [src].","You insert \the [W] into \the [src].")
		update_verbs()

	if(istype(W, /obj/item/device/camera_film))
		to_chat(user, "<span class='notice'>There's no room in \the [src]'s film chamber with the [cell ? "power cell" : "wire"] inside it.</span>")
		return

	if(iswirecutter(W))
		if(cell)
			to_chat(user, "<span class='warning'>You can't reach the wires with the power cell in the way.</span>")
			return
		to_chat(user, "You cut the wires out of the film chamber.")
		playsound(user, 'sound/items/Wirecutter.ogg', 50, 1)
		if(src.loc == user)
			user.drop_item(src, force_drop = 1)
			var/obj/item/device/camera/I = new decon_path(get_turf(user), empty = TRUE)
			handle_camera(I)
			user.put_in_hands(I)
		else
			var/obj/item/device/camera/I = new decon_path(get_turf(loc), empty = TRUE)
			handle_camera(I)
		var/obj/item/stack/cable_coil/C = new (get_turf(user))
		C.amount = 5
		qdel(src)

/obj/item/device/blinder/proc/handle_camera(obj/item/device/camera/camera)
	if(flashbulb)
		camera.flashbulb = flashbulb
		flashbulb.forceMove(camera)
		flashbulb = null

/obj/item/weapon/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/obj/item/weapon/implant/imp = null

/obj/item/weapon/implanter/proc/update()



/obj/item/weapon/implanter/update()
	if (src.imp)
		src.icon_state = "implanter1"
	else
		src.icon_state = "implanter0"
	return


/obj/item/weapon/implanter/attack(mob/M as mob, mob/user as mob)
	if (!istype(M, /mob/living/carbon))
		return
	if (user && src.imp)
		for (var/mob/O in viewers(M, null))
			O.show_message("<span class='warning'>[user] is attempting to implant [M].</span>", 1)

		var/turf/T1 = get_turf(M)
		if (T1 && ((M == user) || do_after(user,M, 50)))
			if(user && M && (get_turf(M) == T1) && src && src.imp)
				for (var/mob/O in viewers(M, null))
					O.show_message("<span class='warning'>[M] has been implanted by [user].</span>", 1)

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with [src.name] ([src.imp.name])  by [user.name] ([user.ckey])</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] ([src.imp.name]) to implant [M.name] ([M.ckey])</font>")
				msg_admin_attack("[user.name] ([user.ckey]) implanted [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")

				user.show_message("<span class='warning'>You implanted the implant into [M].</span>")
				if(src.imp.implanted(M, user))
					src.imp.forceMove(M)
					src.imp.imp_in = M
					src.imp.implanted = 1
					if (ishuman(M))
						var/mob/living/carbon/human/H = M
						var/datum/organ/external/affected = H.get_organ(user.zone_sel.selecting)
						affected.implants += src.imp
						imp.part = affected
				M:implanting = 0
				src.imp = null
				update()
	return


/obj/item/weapon/implanter/traitor
	name = "greytide conversion kit"
	desc = "Any humanoid injected with this implant will become loyal to the injector and the greytide, unless of course the host is already loyal to someone else."

/obj/item/weapon/implanter/traitor/New()
	src.imp = new /obj/item/weapon/implant/traitor(src)
	..()
	update()
	return

/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"

/obj/item/weapon/implanter/loyalty/New()
	src.imp = new /obj/item/weapon/implant/loyalty( src )
	..()
	update()
	return



/obj/item/weapon/implanter/explosive
	name = "implanter (E)"

/obj/item/weapon/implanter/explosive/New()
	src.imp = new /obj/item/weapon/implant/explosive( src )
	..()
	update()
	return

/obj/item/weapon/implanter/adrenalin
	name = "implanter-adrenalin"

/obj/item/weapon/implanter/adrenalin/New()
	src.imp = new /obj/item/weapon/implant/adrenalin(src)
	..()
	update()
	return

/obj/item/weapon/implanter/compressed
	name = "implanter (C)"
	icon_state = "cimplanter1"

	var/list/forbidden_types=list(
		// /obj/item/weapon/storage/bible // VG #11 - Recursion.
	)

/obj/item/weapon/implanter/compressed/New()
	imp = new /obj/item/weapon/implant/compressed( src )
	..()
	update()
	return

/obj/item/weapon/implanter/compressed/update()
	if (imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"
	return

/obj/item/weapon/implanter/compressed/attack(mob/M as mob, mob/user as mob)
	// Attacking things in your hands tends to make this fuck up.
	if(!istype(M))
		return
	var/obj/item/weapon/implant/compressed/c = imp
	if (!c)
		return
	if (c.scanned == null)
		to_chat(user, "Please scan an object with the implanter first.")
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(var/obj/item/I, mob/user as mob)
	if(is_type_in_list(I,forbidden_types))
		to_chat(user, "<span class='warning'>A red light flickers on the implanter.</span>")
		return
	if(istype(I) && imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if (c.scanned)
			if(istype(I,/obj/item/weapon/storage))
				..()
				return
			to_chat(user, "<span class='warning'>Something is already scanned inside the implant!</span>")
			return
		if(user)
			user.u_equip(I,0)
			user.update_icons()	//update our overlays
		c.scanned = I
		c.scanned.forceMove(c)
		update()

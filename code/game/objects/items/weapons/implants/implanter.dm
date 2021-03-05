/obj/item/weapon/implanter
	name = "implanter"
	desc = "A small device used to apply implants to people."
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter0"
	item_state = "syringe_0"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/obj/item/weapon/implant/imp = null
	var/imp_type = null

/obj/item/weapon/implanter/proc/update()
	desc = initial(desc)
	icon_state = "implanter[imp? 1:0]"
	if(imp)
		desc += "<br>It is loaded with a [imp.name]."

/obj/item/weapon/implanter/attack(var/atom/target, mob/user as mob)
	if(!user)
		return
	var/mob/living/carbon/M = null
	if(istype(target, /mob/living/carbon))
		M = target
	if(!imp)
		if(istype(target, /obj/item/weapon/implant/))
			var/obj/item/weapon/implant/timp = target
			timp.forceMove(src)
			user.show_message("<span class='warning'>You load \the [timp] into \the [src].</span>")
			imp = timp
			imp.implanted = null
			imp.imp_in = null
			update()
			return
		if(ismob(target))
			user.show_message("<span class='warning'>There is no implant in \the [src].</span>")
			return
	if(M)
		for (var/mob/O in viewers(M, null))
			O.show_message("<span class='warning'>[user] is attempting to implant [M].</span>", 1)

		var/turf/T1 = get_turf(M)
		if(T1 && ((M == user) || do_after(user,M, 50)))
			if(user && M && (get_turf(M) == T1) && src && imp)
				for (var/mob/O in viewers(M, null))
					O.show_message("<span class='warning'>[M] has been implanted by [user].</span>", 1)

				M.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with \the [name] ([imp.name]) by [key_name(user)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used \the [name] ([imp.name]) to implant [key_name(M)]</font>")
				msg_admin_attack("[key_name(user)] implanted [key_name(M)] with \the [name] ([imp.name]) (INTENT: [uppertext(user.a_intent)]) at [formatJumpTo(get_turf(user))]")

				user.show_message("<span class='warning'>You implanted the implant into [M].</span>")
				if(imp.implanted(M, user))
					imp.forceMove(M)
					imp.imp_in = M
					imp.implanted = 1
					if(ishuman(M))
						var/mob/living/carbon/human/H = M
						var/datum/organ/external/affected = H.get_organ(user.zone_sel.selecting)
						affected.implants += imp
						imp.part = affected
				M:implanting = 0
				imp = null
				update()


/obj/item/weapon/implanter/New()
	if(imp_type)
		imp = new imp_type(src)
		..()
		update()

/obj/item/weapon/implanter/spesstv
	name = "promotional Spess.TV implanter"
	desc = "Does anyone know where the implanter went? I have a lockbox full of loyalty implants here..."

/obj/item/weapon/implanter/traitor
	name = "greytide conversion kit"
	desc = "Any humanoid injected with this implant will become loyal to the injector and the greytide, unless of course the host is already loyal to someone else."
	imp_type = /obj/item/weapon/implant/traitor

/obj/item/weapon/implanter/loyalty
	name = "implanter-loyalty"
	desc = "Any humanoid injected with this implant will become somewhat loyal to Nanotrasen and the local Heads of Staff."
	imp_type = /obj/item/weapon/implant/loyalty

/obj/item/weapon/implanter/explosive
	name = "implanter (E)"
	desc = "A small device used to apply implants to people. This one has a microphone and some circuitry attached for some reason."
	imp_type = /obj/item/weapon/implant/explosive

/obj/item/weapon/implanter/adrenalin
	name = "implanter-adrenalin"
	desc = "A small device used to apply implants to people. This one has a microphone and some circuitry attached for some reason."
	imp_type = /obj/item/weapon/implant/adrenalin

/obj/item/weapon/implanter/peace
	name = "implanter-pax"
	desc = "Any humanoid injected with this implant will become unable to perform most physical acts of aggression."
	imp_type = /obj/item/weapon/implant/peace

/obj/item/weapon/implanter/holy
	name = "implanter-holy"
	desc = "This microscripture implanter helps those affected by the Occult from manifesting unwanted abilities."
	imp_type = /obj/item/weapon/implant/holy

/obj/item/weapon/implanter/compressed
	name = "implanter (C)"
	icon_state = "cimplanter1"
	desc = "A small device used to apply implants to people. This one has a microphone and some circuitry attached for some reason."
	imp_type = /obj/item/weapon/implant/compressed

	var/list/forbidden_types=list(
		// /obj/item/weapon/storage/bible // VG #11 - Recursion.
	)

/obj/item/weapon/implanter/compressed/update()
	if(imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"

/obj/item/weapon/implanter/compressed/attack(mob/M as mob, mob/user as mob)
	// Attacking things in your hands tends to make this fuck up.
	if(!istype(M))
		return
	var/obj/item/weapon/implant/compressed/c = imp
	if(!c)
		return
	if(c.scanned == null)
		to_chat(user, "Please scan an object with the implanter first.")
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(var/obj/item/I, mob/user as mob)
	if(is_type_in_list(I,forbidden_types))
		to_chat(user, "<span class='warning'>A red light flickers on the implanter.</span>")
		return
	if(istype(I) && imp)
		var/obj/item/weapon/implant/compressed/c = imp
		if(c.scanned)
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

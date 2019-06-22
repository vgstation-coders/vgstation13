/obj/item/weapon/implanter
	name = "implanter"
	icon = 'icons/obj/items.dmi'
	icon_state = "implanter"
	item_state = "implanter"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	var/obj/item/weapon/implant/held_implant = null
	var/implant_path = null
	
/obj/item/weapon/implanter/New()
	if(implant_path)
		src.held_implant = new implant_path(src)
		..()
		update_icon()	
		
/obj/item/weapon/implanter/update_icon()
	overlays.len = 0

	if(held_implant)
		var/image/implant_graphic = image('icons/obj/items.dmi', src, "implanter_overlay")
		implant_graphic.icon *= held_implant.implant_color
		overlays += implant_graphic

/obj/item/weapon/implanter/attack(mob/target, mob/user)
	if(!istype(target, /mob/living/carbon))
		return
	if(user && held_implant)
		user.visible_message("<span class='warning'>[user] is attempting to implant [target].</span>")
		var/turf/target_turf = get_turf(target)
		if(target_turf && ((target == user) || do_after(user,target, 50)))
			if(user && target && (get_turf(target) == target_turf) && src && held_implant) //Sanity check to ensure both people stand still
				user.visible_message("<span class='warning'>[target] has been implanted by [user].</span>")

				target.attack_log += text("\[[time_stamp()]\] <font color='orange'> Implanted with \the [name] ([held_implant.name]) by [key_name(user)]</font>")
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used \the [name] ([held_implant.name]) to implant [key_name(target)]</font>")
				msg_admin_attack("[key_name(user)] implanted [key_name(target)] with \the [name] ([held_implant.name]) (INTENT: [uppertext(user.a_intent)]) at [formatJumpTo(get_turf(user))]")

				user.show_message("<span class='warning'>You implanted the implant into [target].</span>")
				if(held_implant.attempt_implant(target, user))
					held_implant.forceMove(target)
					held_implant.implanted_mob = target
					held_implant.implant_status = 1
					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						var/datum/organ/external/affected = H.get_organ(user.zone_sel.selecting)
						affected.implants += held_implant
						held_implant.implanted_bodypart = affected
				target:implanting = 0
				held_implant = null
				update_icon()

/obj/item/weapon/implanter/traitor
	name = "greytide implanter"
	desc = "Any humanoid injected with this implant will become loyal to the injector and the Greytide unless, of course, the host is already loyal to someone else."
	implant_path = /obj/item/weapon/implant/traitor


/obj/item/weapon/implanter/loyalty
	name = "loyalty implanter"
	implant_path = /obj/item/weapon/implant/loyalty

/obj/item/weapon/implanter/explosive
	name = "explosive implanter"
	implant_path = /obj/item/weapon/implant/explosive

/obj/item/weapon/implanter/adrenalin
	name = "adrenalin implanter"
	implant_path = /obj/item/weapon/implant/adrenalin

/obj/item/weapon/implanter/peace
	name = "pax implanter"
	implant_path = /obj/item/weapon/implant/peace

/obj/item/weapon/implanter/compressed
	name = "matter compression implanter"
	icon_state = "cimplanter1"
	implant_path = /obj/item/weapon/implant/compressed
	var/list/forbidden_types = list()

/obj/item/weapon/implanter/compressed/update_icon()
	if(held_implant)
		var/obj/item/weapon/implant/compressed/c = held_implant
		if(!c.scanned)
			icon_state = "cimplanter1"
		else
			icon_state = "cimplanter2"
	else
		icon_state = "cimplanter0"

/obj/item/weapon/implanter/compressed/attack(mob/target, mob/user)
	if(!istype(target))
		return
	var/obj/item/weapon/implant/compressed/c = held_implant
	if(!c)
		return
	if(c.scanned == null)
		to_chat(user, "Please scan an object with the implanter first.")
		return
	..()

/obj/item/weapon/implanter/compressed/afterattack(var/obj/item/I, mob/user as mob)
	if(is_type_in_list(I,forbidden_types))
		to_chat(user, "<span class='warning'>A red light flickers on the implanter. This item cannot be scanned.</span>")
		return
	if(istype(I) && held_implant)
		var/obj/item/weapon/implant/compressed/c = held_implant
		if(c.scanned)
			if(istype(I,/obj/item/weapon/storage))
				..()
				return
			to_chat(user, "<span class='warning'>Something is already scanned inside the implant!</span>")
			return
		if(user)
			user.u_equip(I,0)
			user.update_icons()
		c.scanned = I
		c.scanned.forceMove(c)
		update_icon()

/obj/item/weapon/implantpad
	name = "implantpad"
	desc = "Used to modify implants."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantpad-0"
	item_state = "electronic"
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_SMALL
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/obj/item/weapon/implantcase/case = null
	var/broadcasting = null
	var/listening = 1.0

/obj/item/weapon/implantpad/update_icon()
	if (case)
		icon_state = "implantpad-1"
	else
		icon_state = "implantpad-0"


/obj/item/weapon/implantpad/attack_hand(mob/user)
	if (case && user.is_holding_item(src))
		eject(user)
	else
		return ..()

/obj/item/weapon/implantpad/proc/eject(mob/user)
	user.put_in_hands(case)

	case.add_fingerprint(user)
	case = null

	add_fingerprint(user)
	update_icon()


/obj/item/weapon/implantpad/attackby(obj/item/weapon/implantcase/C, mob/user)
	..()
	if(istype(C, /obj/item/weapon/implantcase))
		if(!case)
			if(user.drop_item(C, src))
				case = C
	else
		return
	update_icon()


/obj/item/weapon/implantpad/attack_self(mob/user)
	user.set_machine(src)
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if (case)
		if(case.imp)
			if(istype(case.imp, /obj/item/weapon/implant))
				dat += case.imp.get_data()
				if(istype(case.imp, /obj/item/weapon/implant/tracking))
					dat += {"ID (1-100):
					<A href='byond://?src=\ref[src];tracking_id=-10'>-</A>
					<A href='byond://?src=\ref[src];tracking_id=-1'>-</A> [case.imp:id]
					<A href='byond://?src=\ref[src];tracking_id=1'>+</A>
					<A href='byond://?src=\ref[src];tracking_id=10'>+</A><BR>\[<A href='byond://?src=\ref[src];eject=1'>eject</A>\]"}
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")


/obj/item/weapon/implantpad/Topic(href, href_list)
	..()
	if (usr.incapacitated() || !in_range(src, usr))
		return
	usr.set_machine(src)
	if (href_list["tracking_id"])
		var/obj/item/weapon/implant/tracking/T = case.imp
		T.id += text2num(href_list["tracking_id"])
		T.id = min(100, T.id)
		T.id = max(1, T.id)

	if (href_list["eject"])
		if (case && (usr.is_holding_item(src) || Adjacent(usr)))
			eject(usr)

		attack_self(usr)

		add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")

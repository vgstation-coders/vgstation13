/obj/item/weapon/clipboard
	name = "clipboard"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "clipboard"
	item_state = "clipboard"
	throwforce = 0
	w_class = W_CLASS_SMALL
	throw_speed = 3
	throw_range = 10
	var/obj/item/weapon/pen/haspen		//The stored pen.
	var/obj/item/weapon/toppaper	//The topmost piece of paper.
	flags = FPRINT
	slot_flags = SLOT_BELT
	autoignition_temperature = AUTOIGNITION_WOOD
	fire_fuel = 3

/obj/item/weapon/clipboard/New()
	. = ..()
	update_icon()

/obj/item/weapon/clipboard/MouseDrop(obj/over_object as obj) //Quick clipboard fix. -Agouri
	if(ishuman(usr))
		var/mob/M = usr
		if(!(istype(over_object, /obj/abstract/screen/inventory) ))
			return ..()

		if(!M.incapacitated() && Adjacent(usr))
			var/obj/abstract/screen/inventory/OI = over_object

			if(OI.hand_index && M.put_in_hand_check(src, OI.hand_index))
				M.u_equip(src, 0)
				M.put_in_hand(OI.hand_index, src)
				src.add_fingerprint(usr)
			return

/obj/item/weapon/clipboard/update_icon()
	overlays.len = 0
	if(toppaper)
		overlays += toppaper.icon_state
		overlays += toppaper.overlays
	else
		var/obj/item/weapon/photo/Ph = locate(/obj/item/weapon/photo) in src
		if(Ph)
			overlays += image(Ph.icon)
	if(haspen)
		overlays += image(icon, "clipboard_pen")
	overlays += image(icon, "clipboard_over")
	return

/obj/item/weapon/clipboard/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/paper) || istype(W, /obj/item/weapon/photo))
		if(user.drop_item(W, src))
			if(istype(W, /obj/item/weapon/paper))
				toppaper = W
			to_chat(user, "<span class='notice'>You clip the [W] onto \the [src].</span>")
			update_icon()
	else if(toppaper)
		toppaper.attackby(usr.get_active_hand(), usr)
		update_icon()
	return

/obj/item/weapon/clipboard/attack_self(mob/user as mob)
	var/dat = "<title>Clipboard</title>"
	if(haspen)
		dat += "<A href='?src=\ref[src];pen=1'>Remove Pen</A><BR><HR>"
	else
		dat += "<A href='?src=\ref[src];addpen=1'>Add Pen</A><BR><HR>"

	//The topmost paper. I don't think there's any way to organise contents in byond, so this is what we're stuck with.	-Pete
	if(toppaper)
		var/obj/item/weapon/paper/P = toppaper
		dat += "<A href='?src=\ref[src];write=\ref[P]'>Write</A> <A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR><HR>"

	for(var/obj/item/weapon/paper/P in src)
		if(P==toppaper)
			continue
		dat += "<A href='?src=\ref[src];remove=\ref[P]'>Remove</A> - <A href='?src=\ref[src];top=\ref[P]'>Move to Top</A> - <A href='?src=\ref[src];read=\ref[P]'>[P.name]</A><BR>"
	for(var/obj/item/weapon/photo/Ph in src)
		dat += "<A href='?src=\ref[src];remove=\ref[Ph]'>Remove</A> - <A href='?src=\ref[src];look=\ref[Ph]'>[Ph.name]</A><BR>"

	user << browse(dat, "window=clipboard")
	onclose(user, "clipboard")
	add_fingerprint(usr)
	return

/obj/item/weapon/clipboard/Topic(href, href_list)
	..()
	if((usr.stat || usr.restrained()))
		return

	if(usr.contents.Find(src))

		if(href_list["pen"])
			if(haspen)
				haspen.forceMove(usr.loc)
				usr.put_in_hands(haspen)
				haspen = null

		if(href_list["addpen"])
			if(!haspen)
				if(istype(usr.get_active_hand(), /obj/item/weapon/pen))
					var/obj/item/weapon/pen/W = usr.get_active_hand()
					if(usr.drop_item(W, src))
						haspen = W
						to_chat(usr, "<span class='notice'>You slot the pen into \the [src].</span>")

		if(href_list["write"])
			var/obj/item/P = locate(href_list["write"])
			if(P && P.loc == src)
				if(usr.get_active_hand())
					P.attackby(usr.get_active_hand(), usr)

		if(href_list["remove"])
			var/obj/item/P = locate(href_list["remove"])
			if(!(P.loc == src))
				var/message = "<span class='warning'>[usr]([usr.key]) has tried to remove something it shouldn't from the clipboard<span>"
				message_admins(message)
				message += "[P]"
				log_game(message)
				admin_log.Add(message)
				return
			if(P)
				P.forceMove(usr.loc)
				usr.put_in_hands(P)
				if(P == toppaper)
					toppaper = null
					var/obj/item/weapon/paper/newtop = locate(/obj/item/weapon/paper) in src
					if(newtop && (newtop != P))
						toppaper = newtop
					else
						toppaper = null

		if(href_list["read"])
			var/obj/item/weapon/paper/P = locate(href_list["read"])
			if(P)
				P.show_text(usr)

		if(href_list["look"])
			var/obj/item/weapon/photo/P = locate(href_list["look"])
			if(P)
				P.show(usr)

		if(href_list["top"])
			var/obj/item/P = locate(href_list["top"])
			if(P && (P.loc == src))
				toppaper = P
				to_chat(usr, "<span class='notice'>You move [P.name] to the top.</span>")

		//Update everything
		attack_self(usr)
		update_icon()
	return

/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1.0
	var/oxygentanks = 10
	var/plasmatanks = 10
	var/list/oxytanks = list()	//sorry for the similar var names
	var/list/platanks = list()


/obj/structure/dispenser/oxygen
	plasmatanks = 0

/obj/structure/dispenser/plasma
	oxygentanks = 0

/obj/structure/dispenser/empty
	plasmatanks = 0
	oxygentanks = 0


/obj/structure/dispenser/New()
	. = ..()
	while(oxygentanks>0)
		var/obj/item/weapon/tank/oxygen/O = new(src)
		oxytanks.Add(O)
		oxygentanks--
	while(plasmatanks>0)
		var/obj/item/weapon/tank/plasma/P = new(src)
		platanks.Add(P)
		plasmatanks--
	update_icon()

/obj/structure/dispenser/update_icon()
	overlays.len = 0
	switch(oxytanks.len)
		if(1 to 3)
			overlays += image(icon = icon, icon_state = "oxygen-[oxytanks.len]")
		if(4 to INFINITY)
			overlays += image(icon = icon, icon_state = "oxygen-4")
	switch(platanks.len)
		if(1 to 4)
			overlays += image(icon = icon, icon_state = "plasma-[platanks.len]")
		if(5 to INFINITY)
			overlays += image(icon = icon, icon_state = "plasma-5")


/obj/structure/dispenser/attack_robot(mob/user as mob)
	return attack_hand(user)

/obj/structure/dispenser/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = "[src]<br><br>"

	dat += {"Oxygen tanks: [oxytanks.len] - [oxytanks.len ? "<A href='?src=\ref[src];oxygen=1'>Dispense</A>" : "empty"]<br>
		Plasma tanks: [platanks.len] - [platanks.len ? "<A href='?src=\ref[src];plasma=1'>Dispense</A>" : "empty"]"}
	user << browse(dat, "window=dispenser")
	onclose(user, "dispenser")
	return


/obj/structure/dispenser/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/tank/oxygen) || istype(I, /obj/item/weapon/tank/air) || istype(I, /obj/item/weapon/tank/anesthetic))
		if(oxytanks.len < 10)
			if(user.drop_item(I, src))
				oxytanks.Add(I)
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		updateUsrDialog()
		return
	if(istype(I, /obj/item/weapon/tank/plasma))
		if(platanks.len < 10)
			if(user.drop_item(I, src))
				platanks.Add(I)
				to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
				update_icon()
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		updateUsrDialog()
		return
	if(iswrench(I))
		if(anchored)
			to_chat(user, "<span class='notice'>You lean down and unwrench [src].</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 0
		else
			to_chat(user, "<span class='notice'>You wrench [src] into place.</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			anchored = 1
		return

/obj/structure/dispenser/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return
	if(Adjacent(usr))
		usr.set_machine(src)
		if(href_list["oxygen"])
			if(oxytanks.len > 0)
				var/obj/item/weapon/tank/oxygen/O = oxytanks[oxytanks.len]
				oxytanks.Remove(O)
				usr.put_in_hands(O)
				to_chat(usr, "<span class='notice'>You take [O] out of [src].</span>")
				update_icon()
		if(href_list["plasma"])
			if(platanks.len > 0)
				var/obj/item/weapon/tank/plasma/P = platanks[platanks.len]
				platanks.Remove(P)
				usr.put_in_hands(P)
				to_chat(usr, "<span class='notice'>You take [P] out of [src].</span>")
				update_icon()
		add_fingerprint(usr)
		updateUsrDialog()
	else
		usr << browse(null, "window=dispenser")
		return
	return

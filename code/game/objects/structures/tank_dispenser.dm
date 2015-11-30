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
	update_icon()


/obj/structure/dispenser/update_icon()
	overlays.len = 0
	switch(oxygentanks)
		if(1 to 3)	overlays += "oxygen-[oxygentanks]"
		if(4 to INFINITY) overlays += "oxygen-4"
	switch(plasmatanks)
		if(1 to 4)	overlays += "plasma-[plasmatanks]"
		if(5 to INFINITY) overlays += "plasma-5"


/obj/structure/dispenser/attack_robot(mob/user as mob)
	if(isMoMMI(user))
		return attack_hand(user)
	return ..()

/obj/structure/dispenser/attack_hand(mob/user as mob)
	user.set_machine(src)
	var/dat = "[src]<br><br>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\objects\structures\tank_dispenser.dm:38: dat += "Oxygen tanks: [oxygentanks] - [oxygentanks ? "<A href='?src=\ref[src];oxygen=1'>Dispense</A>" : "empty"]<br>"
	dat += {"Oxygen tanks: [oxygentanks] - [oxygentanks ? "<A href='?src=\ref[src];oxygen=1'>Dispense</A>" : "empty"]<br>
		Plasma tanks: [plasmatanks] - [plasmatanks ? "<A href='?src=\ref[src];plasma=1'>Dispense</A>" : "empty"]"}
	// END AUTOFIX
	user << browse(dat, "window=dispenser")
	onclose(user, "dispenser")
	return


/obj/structure/dispenser/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/tank/oxygen) || istype(I, /obj/item/weapon/tank/air) || istype(I, /obj/item/weapon/tank/anesthetic))
		if(oxygentanks < 10)
			user.drop_item(I, src)
			oxytanks.Add(I)
			oxygentanks++
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		updateUsrDialog()
		return
	if(istype(I, /obj/item/weapon/tank/plasma))
		if(plasmatanks < 10)
			user.drop_item(I, src)
			platanks.Add(I)
			plasmatanks++
			to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] is full.</span>")
		updateUsrDialog()
		return
	if(istype(I, /obj/item/weapon/wrench))
		if(anchored)
			to_chat(user, "<span class='notice'>You lean down and unwrench [src].</span>")
			anchored = 0
		else
			to_chat(user, "<span class='notice'>You wrench [src] into place.</span>")
			anchored = 1
		return

/obj/structure/dispenser/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return
	if(Adjacent(usr))
		usr.set_machine(src)
		if(href_list["oxygen"])
			if(oxygentanks > 0)
				var/obj/item/weapon/tank/oxygen/O
				if(oxytanks.len == oxygentanks)
					O = oxytanks[1]
					oxytanks.Remove(O)
				else
					O = new /obj/item/weapon/tank/oxygen(loc)
				O.loc = loc
				to_chat(usr, "<span class='notice'>You take [O] out of [src].</span>")
				oxygentanks--
				update_icon()
		if(href_list["plasma"])
			if(plasmatanks > 0)
				var/obj/item/weapon/tank/plasma/P
				if(platanks.len == plasmatanks)
					P = platanks[1]
					platanks.Remove(P)
				else
					P = new /obj/item/weapon/tank/plasma(loc)
				P.loc = loc
				to_chat(usr, "<span class='notice'>You take [P] out of [src].</span>")
				plasmatanks--
				update_icon()
		add_fingerprint(usr)
		updateUsrDialog()
	else
		usr << browse(null, "window=dispenser")
		return
	return
/obj/structure/closet/secure_closet
	var/panel_open = 0
	var/l_hacking = 0

/obj/structure/closet/secure_closet/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(istype(W, /obj/item/tool/screwdriver))
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the service panel.</span>")
	else if(istype(W, /obj/item/device/multitool) && panel_open && !l_hacking)
		to_chat(user, "<span class='danger'>Now attempting to reset internal memory, please hold.</span>")
		l_hacking = 1
		if(do_after(user, 100, target = src))
			if(prob(40))
				to_chat(user, "<span class='danger'>Internal memory reset.  Please give it a few seconds to reinitialize.</span>")
				sleep(rand(40, 80))
				locked = 0
				update_icon()
			else
				to_chat(user, "<span class='danger'>Unable to reset internal memory.</span>")
		l_hacking = 0


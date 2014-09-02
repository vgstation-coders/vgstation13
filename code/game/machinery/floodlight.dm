/obj/machinery/floodlight
	name = "\improper Emergency Floodlight"
	desc = "A floodlight independant of the power network used to light up rooms during emergencies and construction."
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = 1
	var/on = 0
	var/obj/item/weapon/cell/high/cell = null
	var/use = 5
	var/unlocked = 0
	var/open = 0
	var/brightness_on = 8		//This time justified in balance. Encumbering but nice lightening

/obj/machinery/floodlight/New()
	src.cell = new(src)
	..()

/obj/machinery/floodlight/proc/updateicon()
	icon_state = "flood[open ? "o" : ""][open && cell ? "b" : ""]0[on]"

/obj/machinery/light_switch/examine()
	..()
	if(usr && !usr.stat)
		usr << "[desc] It is [on? "on" : "off"]."

/obj/machinery/floodlight/process()
	if(on)
		cell.charge -= use
		if(cell.charge <= 0)
			spawn(5)
				on = 0
				updateicon()
				SetLuminosity(0)
				src.visible_message("<span class='warning'>[src] shuts down due to a lack of power!</span>")
				return

/obj/machinery/light_switch/attack_paw(mob/user)
	src.attack_hand(user)

/obj/machinery/light_switch/attack_ghost(var/mob/dead/observer/G)
	if(!G.can_poltergeist())
		G << "<span class='warning'>Your poltergeist abilities are still cooling down.</span>"
		return 0
	return ..()

/obj/machinery/floodlight/attack_hand(mob/user as mob)

	src.add_fingerprint(user)

	if(open && cell)
		if(ishuman(user))
			if(!user.get_active_hand())
				user.put_in_hands(cell)
				cell.loc = user.loc
		else
			cell.loc = loc

		cell.add_fingerprint(user)
		cell.updateicon()

		src.cell = null
		user.visible_message("<span class='warning'>[user] removes [src]'s power cell!</span>", "<span class='notice'>You remove [src]'s power cell..</span>")
		updateicon()
		return

	if(on)
		on = 0
		user.visible_message("<span class='warning'>[user] turns [src] off!</span>", "<span class='notice'>You turn [src] off.</span>")
		SetLuminosity(0)
		updateicon()

	else
		if(!cell)
			return
		if(cell.charge <= 0)
			return
		on = 1
		user.visible_message("<span class='warning'>[user] turns [src] on!</span>", "<span class='notice'>You turn [src] on.</span>")
		SetLuminosity(brightness_on)
		updateicon()


/obj/machinery/floodlight/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		if (!open)
			playsound(get_turf(src), 'sound/items/Screwdriver.ogg', 50, 1)
			if(unlocked)
				unlocked = 0
				user.visible_message("<span class='warning'>[user] screws [src]'s battery panel back in place!</span>", "<span class='notice'>You screw [src]'s battery panel back in place.</span>")
			else
				unlocked = 1
				user.visible_message("<span class='warning'>[user] unscrews [src]'s battery panel!</span>", "<span class='notice'>You unscrew [src]'s battery panel.</span>")

	if (istype(W, /obj/item/weapon/crowbar))
		if(unlocked)
			playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
			if(open)
				open = 0
				overlays = null
				user.visible_message("<span class='warning'>[user] crowbars [src]'s battery panel back in place!</span>", "<span class='notice'>You crowbar [src]'s battery panel back in place.</span>")
			else
				if(unlocked)
					open = 1
					user.visible_message("<span class='warning'>[user] removes [src]'s battery panel!</span>", "<span class='notice'>You remove [src]'s battery panel.</span>")

	if (istype(W, /obj/item/weapon/cell))
		if(open)
			if(cell)
				user << "<span class='warning'>There is a power cell installed already</span>."
			else
				user.drop_item()
				W.loc = src
				cell = W
				user.visible_message("<span class='warning'>[user] inserts [W] into [src]!</span>", "<span class='notice'>You insert [W] into [src].</span>")
				updateicon()

//these are probably broken

/obj/machinery/floodlight
	name = "emergency floodlight"
	icon = 'icons/obj/machines/floodlight.dmi'
	icon_state = "flood00"
	density = 1
	var/on = 0
	var/obj/item/weapon/cell/high/cell = /obj/item/weapon/cell/high
	var/powercost = 5
	light_range = 5
	light_power = 2

	machine_flags = SCREWTOGGLE | WRENCHMOVE

/obj/machinery/floodlight/get_cell()
	return cell

/obj/machinery/floodlight/New()
	cell = new cell(src)
	..()

/obj/machinery/floodlight/update_icon()

	icon_state = "flood[panel_open ? "o" : ""][panel_open && cell ? "b" : ""]0[on]"

/obj/machinery/floodlight/process()
	if(on)
		if(cell && cell.use(powercost))
			if(cell.charge < powercost)
				on = 0
				update_icon()
				kill_light()
				visible_message("<span class='warning'>\The [src] shuts down!</span>")
				return

		else
			on = 0
			update_icon()
			kill_light()
			visible_message("<span class='warning'>\The [src] shuts down!</span>")
			return

/obj/machinery/floodlight/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	return src.attack_hand(user)

/obj/machinery/floodlight/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/floodlight/attack_hand(mob/user as mob)
	if(panel_open && cell)
		if(ishuman(user) || isMoMMI(user)) //Allow MoMMIs to do it, too
			user.put_in_hands(cell)
			cell.add_fingerprint(user)
			cell.updateicon()
			cell = null
			user.visible_message("<span class='notice'>[user] removes \the [src]'s power cell</span>", \
			"<span class='notice'>You remove \the [src]'s power cell</span>")
			update_icon()
			return

	if(on)
		on = 0
		kill_light()
	else
		if(!cell || !cell.charge > powercost)
			return
		on = 1
		set_light()

	user.visible_message("<span class='notice'>[user] turns \the [src] [on ? "on":"off"].</span>", \
	"<span class='notice'>You turn \the [src] [on ? "on":"off"].</span>")

	update_icon()

/obj/machinery/floodlight/attack_ghost(var/mob/dead/observer/ghost)
	if(!can_spook())
		return FALSE
	if(!ghost.can_poltergeist())
		to_chat(ghost, "Your poltergeist abilities are still cooling down.")
		return FALSE
	investigation_log(I_GHOST, "|| was switched [on ? "off" : "on"] by [key_name(ghost)][ghost.locked_to ? ", who was haunting [ghost.locked_to]" : ""]")
	return ..()

/obj/machinery/floodlight/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if(istype(W, /obj/item/weapon/cell))
		if(panel_open)
			if(cell)
				to_chat(user, "<span class='warning'>There is a power cell already installed.</span>")
				return
			else
				if(user.drop_item(W, src))
					cell = W
					user.visible_message("<span class='notice'>[user] inserts \the [W] into \the [src].</span>", \
					"<span class='notice'>You insert \the [W] into \the [src].</span>")
					update_icon()

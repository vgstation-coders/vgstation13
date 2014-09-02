/obj/machinery/cell_charger
	name = "\improper cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 10
	active_power_usage = 50
	power_channel = EQUIP
	var/obj/item/weapon/cell/charging = null
	var/chargelevel = -1

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

	proc
		updateicon()
			icon_state = "ccharger[charging ? 1 : 0]"

			if(charging && !(stat & (BROKEN|NOPOWER)) )

				var/newlevel = 	round(charging.percent() * 4.0 / 99)
				//world << "nl: [newlevel]"

				if(chargelevel != newlevel)

					overlays.Cut()
					overlays += "ccharger-o[newlevel]"

					chargelevel = newlevel
			else
				overlays.Cut()
	examine()
		set src in oview(5)
		..()
		usr << "There's [charging ? "a" : "no"] cell in the charger."
		if(charging)
			usr << "Current charge: [charging.charge]"

	attackby(obj/item/weapon/W, mob/user)
		if(stat & BROKEN)
			return

		if(istype(W, /obj/item/weapon/cell) && anchored)
			if(charging)
				user << "<span class='warning'>There is a cell in [src] already!</span>"
				return
			else
				var/area/a = loc.loc // Gets our locations location, like a dream within a dream
				if(!isarea(a))
					return
				if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
					user << "<span class='warning'>[src] blinks red as you try to insert [W]!</span>"
					return

				user.drop_item()
				W.loc = src
				charging = W
				user.visible_message("<span class='warning'>[user] inserts [W] into [src]!</span>", "<span class='notice'>You insert [W] into [src].</span>")
				chargelevel = -1
			updateicon()
		else if(istype(W, /obj/item/weapon/wrench))
			if(charging)
				user << "<span class='warning'>Remove the cell first!</span>"
				return

			user.visible_message("<span class='warning'>[user] starts [anchored ? "attaching" : "detaching"] [src] [anchored ? "to" : "from"] the ground!</span>", "<span class='notice'>You start [anchored ? "attaching" : "detaching"] [src] [anchored ? "to" : "from"] the ground.</span>", "<span class='notice'>You hear a ratchet.</span>")
			playsound(get_turf(src), 'sound/items/Ratchet.ogg', 75, 1)
			if(do_after(user,30))
				anchored = !anchored
				user.visible_message("<span class='warning'>[user] [anchored ? "attaches" : "detaches"] [src] [anchored ? "to" : "from"] the ground!</span>", "<span class='notice'>You [anchored ? "attach" : "detach"] [src] [anchored ? "to" : "from"] the ground.</span>")

	attack_hand(mob/user)
		if(charging)
			usr.put_in_hands(charging)
			charging.add_fingerprint(user)
			charging.updateicon()

			src.charging = null
			user.visible_message("<span class='warning'>[user] removes the cell from [src]!", "<span class='notice'>You remove the cell from [src].</span>")
			chargelevel = -1
			updateicon()

	attack_ai(mob/user)
		return

	emp_act(severity)
		if(stat & (BROKEN|NOPOWER))
			return
		if(charging)
			charging.emp_act(severity)
		..(severity)


	process()
		//world << "ccpt [charging] [stat]"
		if(!charging || (stat & (BROKEN|NOPOWER)) || !anchored)
			return

		use_power(200)		//this used to use CELLRATE, but CELLRATE is fucking awful. feel free to fix this properly!
		charging.give(150)	//25 % inneficiency

		updateicon()

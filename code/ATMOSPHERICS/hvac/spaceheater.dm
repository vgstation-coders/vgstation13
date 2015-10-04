/obj/machinery/space_heater
	anchored = 0
	density = 1
	icon = 'icons/obj/atmos.dmi'
	icon_state = "sheater0"
	name = "space heater"
	desc = "Made by Space Amish using traditional space techniques, this heater is guaranteed not to set the station on fire."
	var/obj/item/weapon/cell/cell
	var/on = 0
	var/set_temperature = 50		// in celcius, add T0C for kelvin
	var/heating_power = 40000
	var/base_state = "sheater"

	light_power_on = 0.75
	light_range_on = 2
	light_color = LIGHT_COLOR_ORANGE

	ghost_read = 0
	ghost_write = 0

	flags = FPRINT
	machine_flags = SCREWTOGGLE


/obj/machinery/space_heater/New()
	..()
	cell = new(src)
	cell.charge = 1000
	cell.maxcharge = 1000
	update_icon()
	return

/obj/machinery/space_heater/update_icon()
	overlays.len = 0
	icon_state = "[base_state][on]"
	set_light(on ? light_range_on : 0, light_power_on)
	if(panel_open)
		overlays  += "[base_state]-open"
	return

/obj/machinery/space_heater/examine(mob/user)
	..()
	user << "<span class='info'>\icon[src]\The [src.name] is [on ? "on" : "off"] and the hatch is [panel_open ? "open" : "closed"].</span>"
	if(panel_open)
		user << "<span class='info'>The power cell is [cell ? "installed" : "missing"].</span>"
	else
		user << "<span class='info'>The charge meter reads [cell ? round(cell.percent(),1) : 0]%</span>"

/obj/machinery/space_heater/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(cell)
		cell.emp_act(severity)
	..(severity)

/obj/machinery/space_heater/attackby(obj/item/I, mob/user)
	..()
	if(istype(I, /obj/item/weapon/cell))
		if(panel_open)
			if(cell)
				user << "There is already a power cell inside."
				return
			else
				// insert cell
				var/obj/item/weapon/cell/C = usr.get_active_hand()
				if(istype(C))
					user.drop_item(C, src)
					cell = C
					C.add_fingerprint(usr)

					user.visible_message("<span class='notice'>[user] inserts a power cell into [src].</span>", "<span class='notice'>You insert the power cell into [src].</span>")
		else
			user << "The hatch must be open to insert a power cell."
			return
	return

/obj/machinery/space_heater/togglePanelOpen(var/obj/toggleitem, mob/user)
	..()
	update_icon()
	if(!panel_open && user.machine == src)
		user << browse(null, "window=spaceheater")
		user.unset_machine()

/obj/machinery/space_heater/

/obj/machinery/space_heater/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	interact(user)

/obj/machinery/space_heater/interact(mob/user as mob)

	if(panel_open)

		var/dat
		dat = "Power cell: "
		if(cell)
			dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
		else
			dat += "<A href='byond://?src=\ref[src];op=cellinstall'>Removed</A><BR>"


		// AUTOFIXED BY fix_string_idiocy.py
		// C:\Users\Rob\\documents\\\projects\vgstation13\code\game\\machinery\spaceheater.dm:99: dat += "Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>"
		dat += {"Power Level: [cell ? round(cell.percent(),1) : 0]%<BR><BR>
			Set Temperature:
			<A href='?src=\ref[src];op=temp;val=-5'>-</A>
			[set_temperature]&deg;C
			<A href='?src=\ref[src];op=temp;val=5'>+</A><BR>"}
		// END AUTOFIX
		user.set_machine(src)
		user << browse("<HEAD><TITLE>Space Heater Control Panel</TITLE></HEAD><TT>[dat]</TT>", "window=spaceheater")
		onclose(user, "spaceheater")




	else
		on = !on
		user.visible_message("<span class='notice'>[user] switches [on ? "on" : "off"] the [src].</span>","<span class='notice'>You switch [on ? "on" : "off"] the [src].</span>")
		update_icon()
	return


/obj/machinery/space_heater/Topic(href, href_list)
	if (usr.stat)
		return
	if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.set_machine(src)

		switch(href_list["op"])

			if("temp")
				var/value = text2num(href_list["val"])

				// limit to 20-90 degC
				set_temperature = Clamp(set_temperature + value, 20, 90)

			if("cellremove")
				if(panel_open && cell && !usr.get_active_hand())
					cell.updateicon()
					usr.put_in_hands(cell)
					cell.add_fingerprint(usr)
					cell = null
					usr.visible_message("<span class='notice'>[usr] removes the power cell from \the [src].</span>", "<span class='notice'>You remove the power cell from \the [src].</span>")

			if("cellinstall")
				if(panel_open && !cell)
					var/obj/item/weapon/cell/C = usr.get_active_hand()
					if(istype(C))
						usr.drop_item(C, src)
						cell = C
						C.add_fingerprint(usr)

						usr.visible_message("<span class='notice'>[usr] inserts a power cell into \the [src].</span>", "<span class='notice'>You insert the power cell into \the [src].</span>")

		updateDialog()
	else
		usr << browse(null, "window=spaceheater")
		usr.unset_machine()
	return



/obj/machinery/space_heater/process()
	if(on)
		if(cell && cell.charge > 0)

			var/turf/simulated/L = loc
			if(istype(L))
				var/datum/gas_mixture/env = L.return_air()
				if(env.temperature != set_temperature + T0C)

					var/transfer_moles = 0.25 * env.total_moles()

					var/datum/gas_mixture/removed = env.remove(transfer_moles)

					//world << "got [transfer_moles] moles at [removed.temperature]"

					if(removed)

						var/heat_capacity = removed.heat_capacity()
						//world << "heating ([heat_capacity])"
						if(heat_capacity) // Added check to avoid divide by zero (oshi-) runtime errors -- TLE
							if(removed.temperature < set_temperature + T0C)
								removed.temperature = min(removed.temperature + heating_power/heat_capacity, 1000) // Added min() check to try and avoid wacky superheating issues in low gas scenarios -- TLE
							else
								removed.temperature = max(removed.temperature - heating_power/heat_capacity, TCMB)
							cell.use(heating_power/20000)

						//world << "now at [removed.temperature]"

					env.merge(removed)

					//world << "turf now at [env.temperature]"


		else
			on = 0
			update_icon()


	return

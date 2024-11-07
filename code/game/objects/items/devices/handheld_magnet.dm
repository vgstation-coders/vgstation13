/obj/item/device/handheld_magnet
	name = "portable mini-magnet"
	desc = "A device used to pull in metallic objects. Requires a power cell to function."
	icon_state = "hhmagnet0"
	flags = FPRINT
	slot_flags = SLOT_BELT
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	materials = list(MAT_IRON = 5000, MAT_GLASS = 1000, MAT_DIAMOND = 1000, MAT_SILVER = 1000)
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_STEEL
	origin_tech = Tc_MAGNETS + "=5;" + Tc_ENGINEERING + "=4;" + Tc_MATERIALS + "=4;" + Tc_PROGRAMMING + "=3;" + Tc_BLUESPACE + "=3"
	autoignition_temperature = AUTOIGNITION_PLASTIC
	var/on = 0
	var/base_state = "hhmagnet"
	var/obj/item/weapon/cell/power_src = null
	var/power_usage = 250
	var/pull_interval = 1
	var/magnetic_field = 2
	var/pullcounter = 1

/obj/item/device/handheld_magnet/attack_self(mob/user)
	if (power_src == null || power_src.charge == 0)
		to_chat(user, "<span class='warning'>[src] is unresponsive. Perhaps there's something wrong with its power supply...</span>")
		return
	if (power_src.charge > 0 && power_src.charge < power_usage)
		// suck up the rest of remaining power
		power_src.use(power_usage)
		to_chat(user, "<span class='warning'>[src] flickers a bit, but then dies. Perhaps there's something wrong with its power supply...</span>")
		return

	var/dat = {"Power: <a href='?src=\ref[src];toggleon=1'>[on ? "On" : "Off"]</a><br>
	Range: <a href='?src=\ref[src];magfield=1'>[magnetic_field] metres</a><br>
	Interval: <a href='?src=\ref[src];interval=1'>[pull_interval] deciseconds</a><br>
	[power_src ? "[power_src] charge: [round(power_src.percent())]%" : "No power cell inserted"]"}

	var/datum/browser/popup = new(user, "\ref[src]", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/item/device/handheld_magnet/Topic(href, href_list)
	if(..())
		return 1
	if(href_list["toggleon"])
		on = !on
		icon_state = "[base_state][on]"

		if (on)
			to_chat(usr, "<span class='notice'>You turn on [src].</span>")
			playsound(src, 'sound/items/radio_jammer.wav', 100, 1)
			magnet_process()
		else
			to_chat(usr, "<span class='warning'>You turn off [src].</span>")
			pullcounter = 1
	else if(href_list["magfield"])
		magnetic_field = input(usr,"Set magnetic field range, from 1 to 7","Field range",magnetic_field) as num
		if(!magnetic_field)
			magnetic_field = 1
		magnetic_field = clamp(magnetic_field,1,7)
	else if(href_list["interval"])
		pull_interval = input(usr,"Set magnetic pull interval","Pull interval",pull_interval) as num
		if(!pull_interval)
			pull_interval = 1
		pull_interval = max(pull_interval,1)
	updateUsrDialog()

/obj/item/device/handheld_magnet/attack_hand(mob/user)
	if (power_src && user.is_holding_item(src))
		user.put_in_hands(power_src)
		power_src.add_fingerprint(user)
		power_src.updateicon()

		// Don't rip out cells while the device is working
		// Or at least if its still charged
		if (on)
			if (electrocute_mob(user, power_src, src))
				user.visible_message("<span class='warning'>[user] gets shocked as [src] is still working!</span>", "<span class='warning'>You get shocked as [src] is still working!</span>")
				spark(src)

		src.power_src = null
		user.visible_message("<span class='notice'>[user] removes the cell from [src].</span>", "<span class='notice'>You remove the cell from [src].</span>")
		return
	..()

/obj/item/device/handheld_magnet/attackby(obj/item/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/cell))
		if (power_src)
			to_chat(user, "<span class='warning'>There is already a cell inside, remove it first.</span>")
			return
		if (user.drop_item(W, src))
			power_src = W
			user.visible_message("<span class='notice'>[user] inserts a cell into [src].</span>", "<span class='notice'>You insert a cell into [src].</span>")
			src.add_fingerprint(user)
			return
	..()

/obj/item/device/handheld_magnet/proc/magnet_process()
	while(on)
		if (power_src == null || !power_src.use((power_usage*magnetic_field)/pull_interval))
			on = 0
			icon_state = "[base_state][on]"
			visible_message("<span class='warning'>[src] suddenly shuts down!</span>")
			return

		var/turf/T = get_turf(src)
		if(T)
			var/turfloc = isturf(loc) && !anchored
			var/objloc = FALSE
			if(isobj(loc) && loc.loc && isturf(loc.loc))
				var/obj/O = loc
				if(!O.anchored)
					objloc = TRUE
			for(var/obj/O in orange(magnetic_field, T))
				if(can_pull(O))
					if(ismecha(O))
						continue
					if(O.w_class && pullcounter % O.w_class != 0) // bigger items take longer
						continue
					if(istype(O,/obj/structure) && pullcounter % 2 == 0) // as do dense ones
						continue
					//if(round((1/O.siemens_coefficient)) > 0 && pullcounter % round((1/O.siemens_coefficient)) != 0) // higher coefficient pulls better
						//continue
					if(turfloc) // if on a turf, just send us after anything
						step_towards(src, O)
						break
					if(objloc) // putting this in something unanchored jumps it towards the target!
						step_towards(loc, O)
						break
					if(get_dist(O,T) < magnetic_field/2 && istype(O,/obj/structure/closet))
						var/obj/structure/closet/CL = O
						CL.open()
					step_towards(O, T)

			var/mobloc = FALSE
			if(ismob(loc) && loc.loc && isturf(loc.loc))
				var/mob/M = loc
				if(!M.anchored)
					mobloc = M.size
			for(var/mob/living/L in orange(magnetic_field, T))
				if(get_dist(L,T) < magnetic_field/2)
					for(var/slot in list(slot_l_store,slot_r_store))
						var/obj/item/store = L.get_item_by_slot(slot)
						if(can_pull(store))
							visible_message("<span class='danger'>[src] rips [store] out of [L]'s pocket!")
							L.u_equip(store)
				if(L.anchored || !(L.mob_property_flags & MOB_ROBOTIC))
					continue
				if(mobloc < L.size)
					step_towards(loc, L)
					break
				if(L.size && pullcounter % L.size != 0) // bigger things take longer
					continue
				step_towards(L, T)

			if(!T.has_gravity() && mobloc)
				for(var/turf/simulated/wall/W in spiral_block(T,magnetic_field))
					if((W.walltype == "metal" || W.walltype == "rwall") && get_dist(loc,W) > 1) // gets nearest one
						step_towards(loc, W)
						break

		sleep(pull_interval)
		pullcounter++
		updateUsrDialog()

/obj/item/device/handheld_magnet/proc/can_pull(obj/O) // the iron stuff is basically hotfixed onto this because is_conductor() is WAY too broad for this lil thing
	. = O && !O.anchored 
	if(.)
		for(var/atom/A in O.contents)
			if(can_pull(A))
				return TRUE
	. &= O && ((MAT_IRON in O.starting_materials) || (O.reagents?.has_reagent(IRON)))

/obj/item/device/handheld_magnet/examine(mob/user)
	..()
	to_chat(user, "<span class='warning'>It's turned [on ? "on!" : "off."]</span>")
	// Can only see cell charge % if its turned on
	to_chat(user, "There is [power_src ? "a" : "no"] power cell inside.")
	if (power_src)
		to_chat(user, "Its current charge is [round(power_src.percent())]%")

/obj/item/device/handheld_magnet/admin/New()
	. = ..()
	power_src = new /obj/item/weapon/cell/infinite(src)
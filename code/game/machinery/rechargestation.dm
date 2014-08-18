/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 5
	active_power_usage = 1000
	var/mob/occupant = null
	var/opened = 0.0

	New()
		. = ..()
		build_icon()

		component_parts = newlist(
			/obj/item/weapon/circuitboard/recharge_station,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/manipulator,
			/obj/item/weapon/stock_parts/matter_bin,
			/obj/item/weapon/stock_parts/matter_bin
		)

		RefreshParts()

	Destroy()
		src.go_out()
		..()


	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					new /obj/item/weapon/circuitboard/recharge_station(src.loc)
					qdel(src)
					return
			if(3.0)
				if (prob(25))
					src.anchored = 0
					src.build_icon()
			else
		return


	attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
		// Wrench to toggle anchor
		if (istype(W, /obj/item/weapon/wrench))
			if (occupant)
				user << "\red You cannot unwrench this [src], it's occupado."
				return 1
				playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
			if(anchored)
				user << "\blue You begin to unfasten \the [src]..."
				if (do_after(user, 40))
					user.visible_message( \
						"[user] unfastens \the [src].", \
						"\blue You have unfastened \the [src].", \
						"You hear a ratchet.")
					anchored=0
			else
				user << "\blue You begin to fasten \the [src]..."
				if (do_after(user, 20))
					user.visible_message( \
						"[user] fastens \the [src].", \
						"\blue You have fastened \the [src].", \
						"You hear a ratchet.")
					anchored=1
			src.build_icon()
			return 1
			/*// Weld to disassemble.
		else if(istype(W, /obj/item/weapon/weldingtool))
			if (occupant)
				user << "\red You cannot disassemble this [src], it's occupado."
				return 1
			if (!anchored)
				user << "\red \The [src] is too unstable to weld!  The anchoring bolts need to be tightened."
				return 1
			playsound(get_turf(src), 'sound/items/Welder.ogg', 50, 1)
			user << "\blue You begin to cut \the [src] into pieces..."
			if (do_after(user, 40))
				user.visible_message( \
					"[user] disassembles \the [src].", \
					"\blue You have disassembled \the [src].", \
					"You hear welding.")
				anchored=0
				new /obj/item/weapon/circuitboard/recharge_station(src.loc)
				var/obj/item/weapon/wire/wire = new (src.loc)
				wire.amount=4
				new /obj/item/weapon/stock_parts/manipulator(src.loc)
				new /obj/item/weapon/stock_parts/manipulator(src.loc)
				new /obj/item/weapon/stock_parts/matter_bin(src.loc)
				new /obj/item/weapon/stock_parts/matter_bin(src.loc)
				new /obj/item/stack/sheet/metal(src.loc,amount=5)
				del(src)
				return
			src.build_icon()
			return 1 */ //Inconsistent with other methods and unintuitive so I'm commenting this out
		else if (istype(W, /obj/item/weapon/screwdriver))
			if (!opened)
				src.opened = 1
				user << "You open the maintenance hatch of [src]."
				//src.icon_state = "autolathe_t"
			else
				src.opened = 0
				user << "You close the maintenance hatch of [src]."
				//src.icon_state = "autolathe"
				return 1
		else if(istype(W, /obj/item/weapon/crowbar))
			if (occupant)
				user << "\red You cannot disassemble this [src], it's occupado."
				return 1
			if(anchored)
				user << "You have to unanchor the [src] first!"
				return
			if (opened)
				playsound(get_turf(src), 'sound/items/Crowbar.ogg', 50, 1)
				var/obj/machinery/constructable_frame/machine_frame/M = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				M.state = 2
				M.icon_state = "box_1"
				for(var/obj/I in component_parts)
					if(I.reliability != 100 && crit_fail)
						I.crit_fail = 1
					I.loc = src.loc
				del(src)
				return
		return ..()

	process()
		if(stat & (NOPOWER|BROKEN) || !anchored)
			return

		if(src.occupant)
			process_occupant()
		return 1


	allow_drop()
		return 0


	relaymove(mob/user as mob)
		if(user.stat)
			return
		src.go_out()
		return

	emp_act(severity)
		if(stat & (BROKEN|NOPOWER))
			..(severity)
			return
		if(occupant)
			occupant.emp_act(severity)
			go_out()
		..(severity)

	proc

		build_icon()
			if(stat & (NOPOWER|BROKEN) || !anchored)
				icon_state = "borgcharger"
			else
				if(src.occupant)
					icon_state = "borgcharger1"
				else
					icon_state = "borgcharger0"

		process_occupant()
			if(src.occupant)
				if (istype(occupant, /mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = occupant
					restock_modules()
					if(!R.cell)
						return
					else if(R.cell.charge >= R.cell.maxcharge)
						R.cell.charge = R.cell.maxcharge
						return
					else
						R.cell.charge = min(R.cell.charge + 200, R.cell.maxcharge)
						return

		go_out()
			if(!( src.occupant ))
				return
			//for(var/obj/O in src)
			//	O.loc = src.loc
			if (src.occupant.client)
				src.occupant.client.eye = src.occupant.client.mob
				src.occupant.client.perspective = MOB_PERSPECTIVE
			src.occupant.loc = src.loc
			src.occupant = null
			build_icon()
			src.use_power = 1
			return

		restock_modules()
			if(src.occupant)
				if(istype(occupant, /mob/living/silicon/robot))
					var/mob/living/silicon/robot/R = occupant
					if(R.module && R.module.modules)
						var/list/um = R.contents|R.module.modules
						// ^ makes sinle list of active (R.contents) and inactive modules (R.module.modules)
						for(var/obj/O in um)
							// Engineering
							if(istype(O,/obj/item/stack/sheet/metal) || istype(O,/obj/item/stack/sheet/rglass) || istype(O,/obj/item/stack/sheet/glass) || istype(O,/obj/item/weapon/cable_coil))
								if(O:amount < 50)
									O:amount += 2
								if(O:amount > 50)
									O:amount = 50
							// Security
							if(istype(O,/obj/item/device/flash))
								if(O:broken)
									O:broken = 0
									O:times_used = 0
									O:icon_state = "flash"
							if(istype(O,/obj/item/weapon/gun/energy/taser/cyborg))
								if(O:power_supply.charge < O:power_supply.maxcharge)
									O:power_supply.give(O:charge_cost)
									O:update_icon()
								else
									O:charge_tick = 0
							if(istype(O,/obj/item/weapon/melee/baton))
								var/obj/item/weapon/melee/baton/B = O
								if(B.bcell)
									B.bcell.charge = B.bcell.maxcharge
							//Service
							if(istype(O,/obj/item/weapon/reagent_containers/food/condiment/enzyme))
								if(O.reagents.get_reagent_amount("enzyme") < 50)
									O.reagents.add_reagent("enzyme", 2)
							//Medical
							if(istype(O,/obj/item/weapon/reagent_containers/glass/bottle/robot))
								var/obj/item/weapon/reagent_containers/glass/bottle/robot/B = O
								if(B.reagent && (B.reagents.get_reagent_amount(B.reagent) < B.volume))
									B.reagents.add_reagent(B.reagent, 2)
							if(istype(O,/obj/item/stack/medical/bruise_pack) || istype(O,/obj/item/stack/medical/ointment))
								if(O:amount < O:max_amount)
									O:amount += 2
								if(O:amount > O:max_amount)
									O:amount = O:max_amount
							if(istype(O,/obj/item/weapon/melee/defibrillator))
								var/obj/item/weapon/melee/defibrillator/D = O
								D.charges = initial(D.charges)
							//Janitor
							if(istype(O, /obj/item/device/lightreplacer))
								var/obj/item/device/lightreplacer/LR = O
								LR.Charge(R)

						if(R)
							if(R.module)
								R.module.respawn_consumable(R)

						//Emagged items for janitor and medical borg
						if(R.module.emag)
							if(istype(R.module.emag, /obj/item/weapon/reagent_containers/spray))
								var/obj/item/weapon/reagent_containers/spray/S = R.module.emag
								if(S.name == "Polyacid spray")
									S.reagents.add_reagent("pacid", 2)
								else if(S.name == "Lube spray")
									S.reagents.add_reagent("lube", 2)


	verb
		move_eject()
			set category = "Object"
			set src in oview(1)
			if (usr.stat != 0)
				return
			src.go_out()
			add_fingerprint(usr)
			return

		move_inside()
			set category = "Object"
			set src in oview(1)
			// Broken or unanchored?  Fuck off.
			if(stat & (NOPOWER|BROKEN) || !anchored)
				return
			if (usr.stat == 2)
				//Whoever had it so that a borg with a dead cell can't enter this thing should be shot. --NEO
				return
			if (!(istype(usr, /mob/living/silicon/)))
				usr << "\blue <B>Only non-organics may enter the recharger!</B>"
				return
			if (src.occupant)
				usr << "\blue <B>The cell is already occupied!</B>"
				return
			if (!usr:cell)
				usr<<"\blue Without a powercell, you can't be recharged."
				//Make sure they actually HAVE a cell, now that they can get in while powerless. --NEO
				return
			usr.stop_pulling()
			if(usr && usr.client)
				usr.client.perspective = EYE_PERSPECTIVE
				usr.client.eye = src
			usr.loc = src
			src.occupant = usr
			/*for(var/obj/O in src)
				O.loc = src.loc*/
			src.add_fingerprint(usr)
			build_icon()
			src.use_power = 2
			return






/obj/machinery/recharger
	name = "recharger"
	desc = "A charging station for energy weapons that draws from the area's power. Simply insert an energy weapon with a cell to begin recharging."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	anchored = 1
	use_power = 1
	idle_power_usage = 4
	active_power_usage = 250


	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

	var/self_powered = 0
	var/charging_speed_modifier = 1 //The higher this value is, the faster the charging (increases energy used and deposited to gun each process() call, multiplier)
	var/efficiency_modifier = 1 // This value is the multiplier of excess power loss, the closer it is to zero, the less energy is wasted, min cap is 50% of usual loss

	var/obj/item/weapon/charging = null

	var/appearance_backup = null

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY

/obj/machinery/recharger/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/recharger,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor
	) // Fashioned from the cell charger, they both serve a similar purpose
	RefreshParts()
	if(self_powered)
		use_power = 0
		idle_power_usage = 0
		active_power_usage = 0

/obj/machinery/recharger/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts) // 1x - 0.5x loss multiplier
		T += SM.rating
	efficiency_modifier = 0.25*(5-T)
	T = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts) // 1x - 3x charging multiplier
		T += C.rating
	charging_speed_modifier = round(T/2) // rounds down because fractional speed modifiers can cause problems with weapons that have clearly defined "energy units" such as the lawgiver and the pulse rifle, it is unlikely that someone's not going to muster up two of the same capacitor when modifying the charger
	T = 0


/obj/machinery/recharger/Destroy()
	if(charging)
		charging.appearance = appearance_backup
		charging.update_icon()
		charging.forceMove(loc)
		charging = null
	appearance_backup=null
	..()

/obj/machinery/recharger/attackby(obj/item/weapon/G, mob/user)
	if(issilicon(user))
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(!HAS_MODULE_QUIRK(R, MODULE_IS_THE_LAW))
				return 1
		else
			return 1
	. = ..()
	if(.)
		return
	if(stat & (NOPOWER | BROKEN))
		to_chat(user, "<span class='notice'>[src] isn't connected to a power source.</span>")
		return 1
	if(panel_open)
		to_chat(user, "You can't insert anything into \the [src] while the maintenance panel is open.</span>")
		return 1
	if(charging)
		if(isgripper(G) && isrobot(user))
			attack_hand(user)
			return 1
		to_chat(user, "<span class='warning'>There's \a [charging] already charging inside!</span>")
		return 1
	if(!anchored)
		to_chat(user, "<span class='warning'>You must secure \the [src] before you can make use of it!</span>")
		return 1
	if(istype(G, /obj/item/weapon/gun/energy) || istype(G, /obj/item/weapon/melee/baton) || istype(G, /obj/item/energy_magazine) || istype(G, /obj/item/ammo_storage/magazine/lawgiver) || istype(G, /obj/item/weapon/rcs))
		if (istype(G, /obj/item/weapon/gun/energy/gun/nuclear) || istype(G, /obj/item/weapon/gun/energy/crossbow))
			to_chat(user, "<span class='notice'>Your gun's recharge port was removed to make room for a miniaturized reactor.</span>")
			return 1
		if (istype(G, /obj/item/weapon/gun/energy/staff))
			to_chat(user, "<span class='notice'>The recharger rejects the magical apparatus.</span>")
			return 1
		if(!user.drop_item(G, src))
			user << "<span class='warning'>You can't let go of \the [G]!</span>"
			return 1
		appearance_backup = G.appearance
		var/matrix/M = matrix()
		M.Scale(0.625)
		M.Translate(0,6)
		G.transform = M
		charging = G
		if(!self_powered)
			use_power = 2
		update_icon()
		return 1

/obj/machinery/recharger/togglePanelOpen(var/obj/toggleitem, mob/user)
	if(charging)
		to_chat(user, "The maintenance panel is blocked by \the [charging]!")
		return 1
	return ..()


/obj/machinery/recharger/wrenchAnchor(var/mob/user)
	if(charging)
		to_chat(user, "<span class='notice'>Remove the charging item first!</span>")
		return FALSE
	. = ..()
	if(!.)
		return
	pixel_x = 0
	pixel_y = 0
	update_icon()

/obj/machinery/recharger/attack_hand(mob/user)
	if(issilicon(user))
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			if(!HAS_MODULE_QUIRK(R, MODULE_IS_THE_LAW))
				return 1
		else
			return 1
	if(..())
		return 1

	add_fingerprint(user)

	if(charging && Adjacent(user))
		charging.appearance = appearance_backup
		charging.update_icon()
		charging.forceMove(loc)
		user.put_in_hands(charging)
		charging = null
		if(!self_powered)
			use_power = 1
		appearance_backup=null
		update_icon()

/obj/machinery/recharger/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/recharger/process()
	if(!anchored)
		icon_state = "recharger4"
		return

	if(!self_powered && (stat & (NOPOWER|BROKEN)))
		if(charging)//Spit out anything being charged if it loses power or breaks
			charging.appearance = appearance_backup
			charging.update_icon()
			charging.forceMove(loc)
			visible_message("<span class='notice'>[src] powers down and ejects \the [charging].</span>")
			charging = null
			use_power = 1
			appearance_backup=null
			update_icon()
		return

	if(charging)
		if(istype(charging, /obj/item))
			charging.recharger_process(src)
		var/charge_unit
		if(istype(charging, /obj/item/weapon/gun/energy)) // Original values: 100e charged, 150e wasted,
			var/obj/item/weapon/gun/energy/E = charging
			charge_unit = 100 * charging_speed_modifier
			if((E.power_supply.charge + charge_unit) < E.power_supply.maxcharge)
				E.power_supply.give(charge_unit)
				icon_state = "recharger1"
				if(!self_powered)
					use_power(charge_unit + 150 * efficiency_modifier * charging_speed_modifier)
				update_icon()
			else
				E.power_supply.charge = E.power_supply.maxcharge
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/energy_magazine))//pulse rifle rounds, Original values: 3rnd charged, 250e consumed, let's say 50e per round + 100e waste
			var/obj/item/energy_magazine/M = charging
			charge_unit = 3 * charging_speed_modifier
			if((M.bullets + charge_unit) < M.max_bullets)
				M.bullets = min(M.max_bullets,M.bullets+charge_unit)
				icon_state = "recharger1"
				if(!self_powered)
					use_power(150 * charging_speed_modifier + 100 * efficiency_modifier * charging_speed_modifier)
				update_icon()
			else
				M.bullets = M.max_bullets
				update_icon()
				icon_state = "recharger2"
			return
		else if(istype(charging, /obj/item/weapon/melee/baton)) //25e power loss is so minor that the game shouldn't bother calculating the efficiency of better parts for it
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175*charging_speed_modifier))
					icon_state = "recharger1"
					if(!self_powered)
						use_power(200*charging_speed_modifier)
				else
					icon_state = "recharger2"
			else
				icon_state = "recharger0"

		else if(istype(charging, /obj/item/weapon/rcs))
			var/obj/item/weapon/rcs/rcs = charging
			if(rcs.cell)
				if(rcs.cell.give(175*charging_speed_modifier))
					icon_state = "recharger1"
					if(!self_powered)
						use_power(200*charging_speed_modifier)
				else
					icon_state = "recharger2"
			else
				icon_state = "recharger0"

/obj/machinery/recharger/proc/try_use_power(var/amount)
	if(self_powered)
		return
	use_power(amount)

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(istype(charging,  /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = charging
		if(E.power_supply)
			E.power_supply.emp_act(severity)

	else if(istype(charging, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = charging
		if(B.bcell)
			B.bcell.charge = 0
	..(severity)

/obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.

	if(charging)
		overlays.len = 0
		charging.update_icon()
		overlays += charging.appearance
		icon_state = "recharger1"
	else if(!anchored)
		overlays.len = 0
		icon_state = "recharger4"
	else
		overlays.len = 0
		icon_state = "recharger0"

/obj/machinery/recharger/self_powered	//ideal for the Thunderdome
	self_powered = 1

/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"


/obj/machinery/recharger/wallcharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(charging)
		if(istype(charging, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = charging
			if(E.power_supply.charge < E.power_supply.maxcharge)
				E.power_supply.give(100)
				icon_state = "wrecharger1"
				if(!self_powered)
					use_power(250)
			else
				icon_state = "wrecharger2"
			return
		if(istype(charging, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = charging
			if(B.bcell)
				if(B.bcell.give(175))
					icon_state = "wrecharger1"
					if(!self_powered)
						use_power(200)
				else
					icon_state = "wrecharger2"
			else
				icon_state = "wrecharger3"

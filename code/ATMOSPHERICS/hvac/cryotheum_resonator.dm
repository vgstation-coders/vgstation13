
/obj/machinery/cryotheum_resonator
	density = 1
	// Thank you Falcon2436 for making the sprites!
	icon = 'icons/obj/machines/cryotheum_resonator.dmi'
	icon_state = "machine_powered"
	name = "bluespace cryotheum resonator"
	desc = "Cutting-edge technology that uses a bluespace crystal to resonate the properties of cryotheum into nearby oxygen."
	flags = FPRINT
	machine_flags = EMAGGABLE | WRENCHMOVE | FIXED2WORK | SHUTTLEWRENCH
	var/activated = FALSE
	var/obj/item/bluespace_crystal/crystal
	ghost_read = 0
	ghost_write = 0

/obj/machinery/cryotheum_resonator/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>\The [src.name] is currently [activated ? "active" : "inactive"].</span>")
	if(crystal == null)
		to_chat(user, "<span class='info'>There is no bluespace crystal installed.</span>")
	else
		to_chat(user, "<span class='info'>[crystal] is installed.</span>")

/obj/machinery/cryotheum_resonator/update_icon()
	overlays.len = 0
	if(stat & ( NOPOWER | FORCEDISABLE | BROKEN ))
		icon_state = "machine_unpowered"
		if(crystal != null)
			overlays += image(icon = icon, icon_state = "crystal_unpowered")
	else
		icon_state = "machine_powered"
		if(crystal != null)
			overlays += image(icon = icon, icon_state = "field")
			overlays += image(icon = icon, icon_state = "crystal")
		if(activated)
			overlays += image(icon = icon, icon_state = "pulse")

/obj/machinery/cryotheum_resonator/emp_act(severity)
	..(severity)

/obj/machinery/cryotheum_resonator/emag_act(mob/user)
	if(!emagged)
		spark(src)
		to_chat(user, "<span class='warning'>You disable the safety features on \the [src].</span>")
		log_game("Cryotheum Resonator emagged by [user.ckey]([user]) at ([x],[y],[z]).")
		emagged = TRUE
		return 1
	else
		spark(src)
		to_chat(user, "<span class='warning'>The safety features are already disabled! But you zap it again anyways.</span>")
		return 1

/obj/machinery/cryotheum_resonator/process()
	if(activated)
		if(stat & (NOPOWER))
			visible_message("<span class='info'>\The [src] deactivates as it runs out of power!")
			activated = 0
			update_icon()
			return
		else if(stat & ( FORCEDISABLE | BROKEN | EMPED))
			visible_message("<span class='info'>\The [src] hums as it deactivates!</span>")
			activated = 0
			update_icon()
			return
		else
			// Emagging it makes it run a tiny bit faster, but has a small chance to cause problems.
			if(emagged && prob(0.1))
				// Try a max of 5 times to find a good turf to spawn portals on.
				var/turf/A_location
				var/turf/B_location
				for(var/i = 1 to 5)
					var/x_offset = rand(-1, 1)
					var/y_offset = rand(-1, 1)
					if(x_offset == 0 && y_offset == 0)
						x_offset = 1
					A_location = locate(loc.x+x_offset, loc.y+y_offset, loc.z)
					if(istype(A_location, /turf) && !istype(A_location, /turf/simulated/wall))
						break
					else if(i == 5)
						return
				for(var/i = 1 to 5)
					var/x_offset = rand(-8,8)
					var/y_offset = rand(-8,8)
					if(x_offset == 0 && y_offset == 0)
						x_offset = 1
					B_location = locate(loc.x+x_offset, loc.y+y_offset, loc.z)
					if(istype(B_location, /turf) && !istype(B_location, /turf/simulated/wall))
						break
					else if(i == 5)
						return
				playsound(loc, 'sound/hallucinations/scary.ogg', 60, 0)
				shake_animation(5, 5, 0.1, 15)
				visible_message("<span class='danger'>\The [src] begins to shake and warp reality!")
				var/obj/effect/portal/portal_A = new(A_location, 600) // One minute duration.
				var/obj/effect/portal/portal_B = new(B_location, 600)
				portal_A.target = portal_B
				portal_B.target = portal_A
				portal_A.blend_icon(portal_B)
				portal_B.blend_icon(portal_A)
				portal_A.purge_beams()
				portal_B.purge_beams()
				portal_A.add_beams()
				portal_B.add_beams()
				portal_B.connect_atmospheres()
				return
			var/turf/simulated/L = get_turf(src)
			if(istype(L))
				var/datum/gas_mixture/environment = L.return_air()
				if(environment.molar_density(GAS_CRYOTHEUM) > MOLES_CRYOTHEUM_VISIBLE / CELL_VOLUME )
					// We want the amount of oxygen converted into cryotheum to be a constant amount that acts only upon the gasses contained with the tile this machine is on.
					// Getting the environment gives us the total gas contained within a single ZAS zone, for instance, a contiguous room. So we take a tile-sized slice of the
					// entire zone's gas, operate on that, then merge it back into the ZAS zone. We don't care about the temperature or pressure of the oxygen we're converting,
					// only the raw mol amount.
					var/datum/gas_mixture/tile_above_gas = environment.remove_volume( CELL_VOLUME )
					if(tile_above_gas)
						var/oxygen_mols_to_convert = min( get_conversion_amount(), tile_above_gas[GAS_OXYGEN])
						tile_above_gas.adjust_gas(GAS_OXYGEN, -oxygen_mols_to_convert, FALSE);
						tile_above_gas.adjust_gas(GAS_CRYOTHEUM, oxygen_mols_to_convert, FALSE);
						// Arbitary numbers to make the environment a cooler, down to a minimum.
						tile_above_gas.add_thermal_energy(oxygen_mols_to_convert * -20000, 232.8952)
					environment.merge( tile_above_gas )
	else if( icon_state == "machine_unpowered" && !(stat & ( NOPOWER | FORCEDISABLE | BROKEN )))
		update_icon()

// Returns how many mols of oxygen on the tile directly above the machine are turned into cryotheum per process tick.
/obj/machinery/cryotheum_resonator/proc/get_conversion_amount()
	var/amount = 0
	if(crystal != null)
		if(istype(crystal, /obj/item/bluespace_crystal/artificial))
			amount = 120
		else if(istype(crystal, /obj/item/bluespace_crystal/flawless))
			amount = 950
		else
			amount = 240
	if(emagged)
		amount *= 1.2
	return amount

/obj/machinery/cryotheum_resonator/attackby(obj/item/I, mob/user)
	..()
	if(issolder(I) && emagged)
		var/obj/item/tool/solder/S = I
		if(S.remove_fuel(2,user))
			to_chat(user, "<span class='warning'>You re-solder the safety features on \the [src].</span>")
			emagged = FALSE
	else if(istype(I, /obj/item/bluespace_crystal))
		if(crystal == null)
			var/obj/item/bluespace_crystal/new_crystal = I
			if(user.drop_item(new_crystal, src))
				crystal = new_crystal
				crystal.add_fingerprint(user)
				user.visible_message("<span class='notice'>[user] inserts \the [new_crystal] into \the [src].</span>", "<span class='notice'>You carefully insert \the [new_crystal] into the containment field of \the [src.name].</span>")
				update_icon()
		else
			to_chat(user, "A bluespace crystal is already installed into \the [src].")
	else if(istype(I, /obj/item/device/multitool))
		if(activated)
			to_chat(user, "You can't remove the bluespace crystal while \the [src] is running!")
		else if(crystal != null)
			user.visible_message("<span class='notice'>[user] uses [I] to weaken the containment field and remove [crystal] from [src].</span>", "<span class='notice'>You use [I] to weaken the containment field and remove [crystal].</span>")
			crystal.forceMove(loc)
			crystal = null
			update_icon()

/obj/machinery/cryotheum_resonator/attack_hand(mob/user as mob)
	if(issilicon(user))
		add_hiddenprint(user)
	else
		add_fingerprint(user)
	..()
	if(!anchored)
		to_chat(user, "\The [src] needs to be anchored first!")
		return
	if(crystal == null)
		to_chat(user, "\The [src] is unresponsive, as it has no bluespace crystal!")
		return
	if(stat & (NOPOWER | FORCEDISABLE | BROKEN | EMPED))
		to_chat(user, "\The [src] is unresponsive.")
		return
	else
		activated = !activated
		user.visible_message("<span class='notice'>[user] [activated ? "activates" : "deactivates"] [src].</span>","<span class='notice'>You [activated ? "activate" : "deactivate"] [src].</span>")
		log_game("Cryotheum Resonator turned [activated ? "on" : "off"] by [user.ckey]([user]) at ([x],[y],[z]).")
		update_icon()

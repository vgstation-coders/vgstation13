//Silicon Diagnostic HUD

/datum/visioneffect/diagnostic
	name = "diagnostic hud"

/datum/visioneffect/diagnostic/process_hud(var/mob/M)
	..()
	if(!M.client)
		return
	diagnostic_hud_users |= M

	var/client/C = M.client
	var/image/holder
	var/turf/T = get_turf(M)

	for(var/mob/living/silicon/robot/borg in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(borg, M))
			continue

		holder = borg.hud_list[DIAG_HEALTH_HUD]
		if(holder)
			C.images += holder
			if(borg.isDead())
				holder.icon_state = "huddiagdead"
			else
				holder.icon_state = cyborg_health_to_icon_state(borg.health / borg.maxHealth)

		holder = borg.hud_list[DIAG_CELL_HUD]
		if(holder)
			C.images += holder
			var/obj/item/weapon/cell/borg_cell = borg.get_cell()
			if(!borg_cell)
				holder.icon_state = "hudnobatt"
			else
				var/charge_ratio = borg_cell.charge / borg_cell.maxcharge
				holder.icon_state = power_cell_charge_to_icon_state(charge_ratio)

	for(var/obj/mecha/exosuit in range(C.view+DATAHUD_RANGE_OVERHEAD,T))
		if(!check_HUD_visibility(exosuit, M))
			continue

		holder = exosuit.hud_list[DIAG_HEALTH_HUD]
		if(holder)
			C.images += holder
			var/integrity_ratio = exosuit.health / initial(exosuit.health)
			holder.icon_state = mech_integrity_to_icon_state(integrity_ratio)

		holder = exosuit.hud_list[DIAG_CELL_HUD]
		if(holder)
			C.images += holder
			var/obj/item/weapon/cell/exosuit_cell = exosuit.get_cell()
			if(!exosuit_cell)
				holder.icon_state = "hudnobatt"
			else
				var/charge_ratio = exosuit_cell.charge / exosuit_cell.maxcharge
				holder.icon_state = power_cell_charge_to_icon_state(charge_ratio)

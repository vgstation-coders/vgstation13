/datum/artifact_effect/cellcharge
	effecttype = "cellcharge"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 3
	var/next_message

/datum/artifact_effect/cellcharge/DoEffectTouch(var/mob/user)
	var/obj/item/weapon/cell/target_cell = user.get_cell()
	if(target_cell)
		if(isrobot(user) && (world.time >= next_message))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Large energy boost detected!</span>")
		target_cell.charge += rand() * 100
		if(target_cell.charge > target_cell.maxcharge)
			target_cell.charge = target_cell.maxcharge
		if(world.time >= next_message)
			next_message = world.time + 50
		return TRUE

/datum/artifact_effect/cellcharge/DoEffectAura()
	if(holder)
		for(var/atom/movable/C in range(effectrange, holder))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)	
				if(isrobot(C) && (world.time >= next_message))
					to_chat(C, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")
				target_cell.charge += 25
				if(target_cell.charge > target_cell.maxcharge)
					target_cell.charge = target_cell.maxcharge
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge += 25
		if(world.time >= next_message)
			next_message = world.time + 300
		return TRUE

/datum/artifact_effect/cellcharge/DoEffectPulse()
	if(holder)
		for(var/atom/movable/C in range(effectrange, holder))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)	
				if(isrobot(C) && (world.time >= next_message))
					to_chat(C, "<span class='notice'>SYSTEM ALERT: Large energy boost detected!</span>")
				target_cell.charge += rand() * 100
				if(target_cell.charge > target_cell.maxcharge)
					target_cell.charge = target_cell.maxcharge
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge += rand() * 100
		if(world.time >= next_message)
			next_message = world.time + 300
		return TRUE

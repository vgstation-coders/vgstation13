
//todo
/datum/artifact_effect/celldrain
	effecttype = "celldrain"
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 3
	var/next_message

/datum/artifact_effect/celldrain/DoEffectTouch(var/mob/user)
	var/obj/item/weapon/cell/target_cell = user.get_cell()
	if(target_cell)
		if(isrobot(user) && (world.time >= next_message))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Large energy drain detected!</span>")
		target_cell.charge = max(target_cell.charge - rand() * 100, 0)
		if(world.time >= next_message)
			next_message = world.time + 50
		return TRUE

/datum/artifact_effect/celldrain/DoEffectAura()
	if(holder)
		for(var/atom/movable/C in range(effectrange, holder))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)	
				if(isrobot(C) && (world.time >= next_message))
					to_chat(C, "<span class='notice'>SYSTEM ALERT: Energy drain detected!</span>")
				target_cell.charge = max(target_cell.charge - 50, 0)
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge = max(S.charge - 50, 0)
		if(world.time >= next_message)
			next_message = world.time + 300
		return TRUE

/datum/artifact_effect/celldrain/DoEffectPulse()
	if(holder)
		for(var/atom/movable/C in range(effectrange, holder))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)	
				if(isrobot(C) && (world.time >= next_message))
					to_chat(C, "<span class='notice'>SYSTEM ALERT: Large energy drain detected!</span>")
				target_cell.charge = max(target_cell.charge - rand() * 100, 0)
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge = max(S.charge - rand() * 100, 0)
		if(world.time >= next_message)
			next_message = world.time + 300
		return TRUE

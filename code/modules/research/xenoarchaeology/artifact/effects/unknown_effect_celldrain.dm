/datum/artifact_effect/celldrain
	effecttype = "celldrain"
	valid_style_types = list(ARTIFACT_STYLE_ANOMALY, ARTIFACT_STYLE_ANCIENT, ARTIFACT_STYLE_PRECURSOR, ARTIFACT_STYLE_RELIQUARY)
	effect = list(ARTIFACT_EFFECT_TOUCH, ARTIFACT_EFFECT_AURA, ARTIFACT_EFFECT_PULSE)
	effect_type = 3
	var/next_message

/datum/artifact_effect/celldrain/DoEffectTouch(var/mob/user)
	var/obj/item/weapon/cell/target_cell = user.get_cell()
	if(target_cell)
		if(isrobot(user) && (world.time >= next_message))
			to_chat(user, "<span class='notice'>SYSTEM ALERT: Large energy drain detected!</span>")
			next_message = world.time + 50
		target_cell.use(500)
		return TRUE

/datum/artifact_effect/celldrain/DoEffectAura()
	if(holder)
		for(var/atom/movable/C in range(effectrange, get_turf(holder)))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)
				if(isrobot(C) && (world.time >= next_message))
					to_chat(C, "<span class='notice'>SYSTEM ALERT: Energy drain detected!</span>")
					next_message = world.time + 300
				target_cell.use(200)
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge = max(0, S.charge - 2000)
		return TRUE

/datum/artifact_effect/celldrain/DoEffectPulse()
	if(holder)
		for(var/atom/movable/C in range(effectrange, get_turf(holder)))
			var/obj/item/weapon/cell/target_cell = C.get_cell()
			if(target_cell)
				if(isrobot(C) && (world.time >= next_message))
					to_chat(C, "<span class='notice'>SYSTEM ALERT: Large energy drain detected!</span>")
					next_message = world.time + 300
				target_cell.use(300 * chargelevelmax)
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge = max(0, S.charge - 3000 * chargelevelmax)
		return TRUE
